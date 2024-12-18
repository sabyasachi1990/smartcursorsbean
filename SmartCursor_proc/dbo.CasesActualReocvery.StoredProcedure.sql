USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CasesActualReocvery]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[CasesActualReocvery]  --  Exec [dbo].[CasesActualReocvery] '38286b5b-60d2-46e8-9b70-600bca83e274'      
 @CaseId UNIQUEIDENTIFIER      
 as      
 Begin      
         
DECLARE @EmployeePlannedRecovey TABLE ( CaseId UNIQUEIDENTIFIER,EmployeeId UNIQUEIDENTIFIER,DepartmentId UNIQUEIDENTIFIER,DesignationId UNIQUEIDENTIFIER,      
EmployeeName NVARCHAR(max),Department NVARCHAR(max),Designation NVARCHAR(max),levelrank int,      
PlannedHours nvarchar(max),OverRunHours NVARCHAR(max),TotalHours NVARCHAR(max),ChargeOutRate decimal(28,9),PlannedCost decimal(28,9),OverRunCost decimal(28,9)      
,StartDate datetime2,EndDate datetime2      
)      
DECLARE @EmployeeActualRecovey TABLE ( CaseId UNIQUEIDENTIFIER,EmployeeId UNIQUEIDENTIFIER,DepartmentId UNIQUEIDENTIFIER,DesignationId UNIQUEIDENTIFIER,      
EmployeeName NVARCHAR(max),Department NVARCHAR(max),Designation NVARCHAR(max),levelrank int,      
Hours nvarchar(max),ChargeOutRate decimal(28,9),ActualCost decimal(28,9)      
,StartDate datetime2,EndDate datetime2,CompanyId int      
)      
DECLARE @EmployeeActualDetailRecovey TABLE ( CaseId UNIQUEIDENTIFIER,EmployeeId UNIQUEIDENTIFIER,DepartmentId UNIQUEIDENTIFIER,DesignationId UNIQUEIDENTIFIER,      
EmployeeName NVARCHAR(max),Department NVARCHAR(max),Designation NVARCHAR(max),levelrank int,      
ChargeOutRate decimal(28,9),StartDate datetime2,EndDate datetime2,CompanyId int      
)      
         
DECLARE @CaseRecovey TABLE ( CaseId UNIQUEIDENTIFIER,CaseFee money,ChargeOutRate decimal(28,9),PlannedCost decimal(28,9),OverRunCost decimal(28,9),CompanyId int)      
      
 --==================================================Planned Each case wise task hous,PlannedCost,OverRunCost =====================================================================        
   insert into @CaseRecovey      
   select CaseId,isnull(d.CaseFee,0) as CaseFee,isnull((sum(ChargeOutRateNew)/nullif(sum(TotalHours)/60.0,0)),0) as ChargeOutRate,      
   sum(ChargeOutRateNew) as PlannedCost,0,d.CaseCompanyId as CompanyId from       
    (      
      select dISTINCT st.CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,ST.Level,PlannedHours,ChargeOutRate,(PlannedHours) as TotalHours,      
      (TotalHours*ChargeOutRate) as ChargeOutRateNew,st.CompanyId from      
      (      
       select TLI.CompanyId,SystemId as CaseId,TL.EmployeeId,TLD.DepartmentId,TLD.DesignationId,TLD.Level,SUM(DATEDIFF(minute, '00:00:00', TLD.Duration))/60.0 as PlannedHours,            
   SUM(DATEDIFF(minute, '00:00:00', TLD.Duration))/60.0 as TotalHours,isnull(TLD.ChargeoutRate,0) as ChargeoutRate        
      From Common.TimeLog As TL (NOLOCK)     
    Inner Join Common.TimeLogItem As TLI (NOLOCK) On TLI.Id=TL.TimeLogItemId       
    Inner Join Common.TimeLogDetail As TLD (NOLOCK) On TLD.MasterId=TL.Id      
    ---inner join hr.EmployeeDepartment hr on hr.EmployeeId=tl.EmployeeId and tld.date between hr.EffectiveFrom and isnull(hr.EffectiveTo,getutcdate())      
     Where SystemId=@caseid and       
    Duration<>'00:00:00.0000000' and SystemId is not null      
    group by SystemId,tl.EmployeeId ,Hours,Level ,ChargeoutRate ,TLI.CompanyId, DepartmentId,DesignationId     
      )st      
 )k      
 INNER join       
    (      
      select Id,isnull(BaseFee,0) AS CaseFee,CompanyId AS CaseCompanyId FROM WorkFlow.CaseGroup (NOLOCK) Where Id=@CaseId      
    ) d on  d.Id=k.CaseId and d.CaseCompanyId=k.CompanyId       
  where CaseId=@CaseId      
   group  by k.CaseId,d.CaseFee,d.CaseCompanyId      
      order by k.CaseId      
--================================================== Planned Each Employee wise task hous,PlannedCost,OverRunCost ==================================================================      
 insert into @EmployeePlannedRecovey      
    select CaseId,EmployeeId,k.DepartmentId,k.DesignationId,k.EmployeeName,k.Department,k.Designation,k.LevelRank,cast(sum(PlannedHours)/60.0  as Decimal(28,2))as PlannedHours,      
    cast(sum(OverRunHours)/60.0  as Decimal(28,2))as OverRunHours,cast(sum(TotalHours)/60.0  as Decimal(28,2))as TotalHours,      
 isnull((sum(ChargeOutRateNew)/nullif((sum(TotalHours)/60.0),0)),0) as ChargeOutRate,sum(ChargeOutRateNew) as PlannedCost,sum(OverRunCost) as OverRunCost,min(StartDate) as StartDate ,max(EndDate) EndDate from       
    (      
       select dISTINCT st.CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,st.FirstName as EmployeeName,st.Code as Department,st.designationcode as Designation,st.Level as LevelRank,PlannedHours,OverRunHours,ChargeOutRate,      
   (PlannedHours+OverRunHours) as TotalHours,(TotalHours*ChargeOutRate) as ChargeOutRateNew,(PlannedHoursnew*ChargeOutRate) as OverRunCost,StartDate,EndDate from      
      (      
       select distinct s.CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,e.FirstName,d.Code,dd.Code as designationcode,ST.Level,sum(isnull(PlannedHours,0)) as PlannedHours,sum(isnull(PlannedHours,0))/60.0 as PlannedHoursnew,sum(isnull(OverRunHours,0
  
))  as OverRunHours,      
     sum(isnull(OverRunHours,0))/60.0 as OverRunHoursnew,      
     (sum(PlannedHours) +sum(isnull(OverRunHours,0)))/60.0 as TotalHours,isnull(sw.ChargeoutRate,st.ChargeoutRate) as ChargeoutRate,min(st.StartDate) as StartDate ,max(st.EndDate) EndDate     
 from       
   WorkFlow.ScheduleDetailNew st (NOLOCK)     
     inner join WorkFlow.ScheduleNew s (NOLOCK) on s.id=st.MasterId      
   left join WorkFlow.ScheduleTaskNew sw (NOLOCK) on sw.EmployeeId=st.EmployeeId and sw.CaseId=s.CaseId     
   join common.Employee as e (NOLOCK) on e.id=st.EmployeeId    
   join common.Department as d (NOLOCK) on d.id=st.DepartmentId    
   join common.DepartmentDesignation as dd (NOLOCK) on dd.id= st.DesignationId    
   inner join WorkFlow.CaseGroup c (NOLOCK) on c.id=s.CaseId      
   where s.CaseId=@CaseId         
     
    group by S.CaseId,ST.EmployeeId,st.DepartmentId,st.DesignationId,e.FirstName,d.Code,dd.Code,st.Level,st.StartDate,st.EndDate,s.CompanyId  ,st.ChargeoutRate,sw.ChargeoutRate  
      )st      
 )k      
     
   group  by CaseId,EmployeeId,k.DepartmentId,k.DesignationId,EmployeeName,Department,Designation,LevelRank      
      order by CaseId      
      
--================================================== Actual Each Employee wise task hous,ActualCost ==================================================================      
      insert into @EmployeeActualRecovey       
         SELECT Distinct    
       SystemId as Caseid,EmployeeId,DepartmentId,DesignationId,EmployeeName,Department,Designation,LevelRank,      
         
    cast(cast (sum(Hours ) / 60 + (sum(Hours ) % 60) / 100.0  as decimal(28,2)) as  varchar(max)) as Hours,      
   --cast((sum(Hours)/60.0) as Decimal(28,2)) as Hours,      
   --isnull((sum(ActCost)/nullif((sum(Hours)/60.0),0)),0) as ChargeOutRate,    
   ChargeOutRate,    
   sum(ActCost) as ActCost,min(StartDate) as StartDate,max(EndDate) as EndDate,CompanyId from       
   (      
  SELECT Distinct SystemId,EmployeeId,DepartmentId,DesignationId,EmployeeName,Department,Designation,LevelRank,StartDate,EndDate,Hours,ChargeOutRate,((Hours/60.0)*ChargeOutRate) as ActCost,CompanyId from       
  (      
    SELECT Distinct s.CaseId as SystemId,st.EmployeeId,st.DepartmentId,st.DesignationId,e.FirstName as EmployeeName,isnull(sw.department,d.code) as Department,isnull(sw.designation,dd.code) as Designation,sw.LEVEL as LevelRank,min(Date) as StartDate,max(Date) as EndDate,sum(((DATEPART(HOUR,Duration)
  
*60)+((DATEPART(MINUTE,Duration))))) as       
          Hours , (case when sum(((DATEPART(HOUR,Duration)
  
*60)+((DATEPART(MINUTE,Duration)))))is not null then isnull(sw.ChargeoutRate,0) else st.ChargeoutRate end)ChargeoutRate,st.CompanyId      
    From      
    WorkFlow.ScheduleDetailNew st (NOLOCK)     
      inner join WorkFlow.ScheduleNew s (NOLOCK) on s.id=st.MasterId      
    inner join WorkFlow.CaseGroup c (NOLOCK) on c.id=s.CaseId     
 inner join common.Employee as e (NOLOCK) on e.id=st.EmployeeId  
 join common.Department as d (NOLOCK) on d.id=st.DepartmentId    
 join common.DepartmentDesignation as dd (NOLOCK) on dd.id=st.DesignationId    
 
   left join       
  (      
    Select Distinct TLI.SystemId as CaseId,tl.EmployeeId ,Date,Duration ,ChargeoutRate ,TLD.Level,d.Code as department,dd.Code as designation    
    From Common.TimeLog As TL (NOLOCK)     
    Inner Join Common.TimeLogItem As TLI (NOLOCK) On TLI.Id=TL.TimeLogItemId       
    Inner Join Common.TimeLogDetail As TLD (NOLOCK) On TLD.MasterId=TL.Id  
	join common.Department as d (NOLOCK) on d.id=TLD.DepartmentId    
 join common.DepartmentDesignation as dd (NOLOCK) on dd.id=TLD.DesignationId    
    ---inner join hr.EmployeeDepartment hr on hr.EmployeeId=tl.EmployeeId and tld.date between hr.EffectiveFrom and isnull(hr.EffectiveTo,getutcdate())      
     Where --SystemId=@caseid and       
    Duration<>'00:00:00.0000000' and SystemId is not null      
    group by SystemId,tl.EmployeeId ,Date,Duration ,ChargeoutRate,TLD.Level ,d.Code,dd.Code  
   )sw on sw.EmployeeId=st.EmployeeId and sw.CaseId=s.CaseId      
     
   where   s.CaseId=@CaseId      
        
      group by s.CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,st.ChargeOutRate,st.StartDate,st.EndDate,sw.EmployeeId, S.CompanyId,c.CreatedDate,sw.Level  ,e.FirstName,d.Code,dd.Code,st.CompanyId ,sw.ChargeoutRate ,sw.department,sw.designation  
   )hh       
    )ST      
        
   group by ST.SystemId,ST.EmployeeId,st.DepartmentId,st.DesignationId,st.EmployeeName,st.Department,st.Designation,st.LevelRank,StartDate,EndDate,CompanyId,ChargeOutRate     
    ORDER BY CaseId     
    --================================================== Actual Each Employee wise task hous,PlannedCost,OverRunCost =====================================================      
 --     insert into @EmployeeActualDetailRecovey      
 --  SELECT Distinct  ST.CaseId,ST.EmployeeId,st.DepartmentId,st.DesignationId,st.EmployeeName,st.Department,st.Designation,st.LevelRank,(isnull(ChargeOutRate,0)) as ChargeOutRate,StartDate,EndDate,CompanyId FROM       
 --   (      
 --        select Distinct CompanyId,CaseId,EmployeeId,DepartmentId,DesignationId,EmployeeName,Department,Designation, ChargeOutRate,StartDate,EndDate,CreatedDate,      
 --  EmployeeIdNEW,LevelRank from       
 --  (      
 --    select Distinct S.CompanyId,s.CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,e.FirstName as EmployeeName,d.Code as Department,dd.Code as Designation,cast(st.ChargeOutRate as Decimal(28,9)) as       
 --          ChargeOutRate,st.Level  as LevelRank,st.StartDate,st.EndDate,c.CreatedDate,      
 --   sw.EmployeeId  as  EmployeeIdNEW from        
 --   WorkFlow.ScheduleDetailNew st      
 --     inner join WorkFlow.ScheduleNew s on s.id=st.MasterId      
 --   inner join WorkFlow.CaseGroup c on c.id=s.CaseId     
 --inner join common.Employee as e on e.id=st.EmployeeId    
 --join common.Department as d on d.id=st.DepartmentId    
 --join common.DepartmentDesignation as dd on dd.id=st.DesignationId    
 --  left join       
 -- (      
 --   Select Distinct SystemId as CaseId,tl.EmployeeId           
 --   From Common.TimeLog As TL      
 --   Inner Join Common.TimeLogItem As TLI On TLI.Id=TL.TimeLogItemId       
 --   Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id      
 --   -inner join hr.EmployeeDepartment hr on hr.EmployeeId=tl.EmployeeId and tld.date between hr.EffectiveFrom and isnull(hr.EffectiveTo,getutcdate())      
 --    Where --SystemId=@caseid and       
 --   Duration<>'00:00:00.0000000' and SystemId is not null      
 --   group by SystemId,tl.EmployeeId      
 --  )sw on sw.EmployeeId=st.EmployeeId and sw.CaseId=s.CaseId      
     
 --  where   s.CaseId=@CaseId      
        
 --     group by s.CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,st.ChargeOutRate,st.StartDate,st.EndDate,sw.EmployeeId, S.CompanyId,c.CreatedDate,st.Level  ,e.FirstName,d.Code,dd.Code    
 --  )hh       
 --   )ST      
        
 --  group by ST.CaseId,ST.EmployeeId,st.DepartmentId,st.DesignationId,st.EmployeeName,st.Department,st.Designation,st.LevelRank,StartDate,EndDate,CompanyId,ChargeOutRate      
 --   ORDER BY CaseId 
 
--==============================================================Get data from this tables @CaseRecovey,@EmployeeRecovey,@EmployeeDetailRecovey  =================================   

exec [dbo].[CaseSPlannedReocvery]  @caseId ,1

     select EmployeeId,Designation,[Name],[Level] ,[Start Date],[End Date],Hours as 'Hours',      
  cast(isnull(ChargeOutRate,0) as decimal(28,2)) as 'Charge-Out Rate',      
        cast(ISNULL((FeeAllocationPer*CaseFee)/100,0) as decimal(28,2)) as 'Fee Allocation($)',      
        cast(isnull(FeeAllocationPer,0) as decimal(28,2)) as 'Fee Allocation(%)' ,      
        cast(isnull(ActualCost ,0) as decimal(28,2)) as 'Cost($)',      
       cast(ISNULL((((FeeAllocationPer*CaseFee)/100)/(NULLIF(ActualCost,0)))*100,0) as decimal(28,2)) AS 'Fee Recovery(%)'  from      
   (      
    select Ea.EmployeeId,EA.Designation,EA.EmployeeName as 'Name',EA.levelrank as 'Level',EA.StartDate as 'Start Date',      
 EA.EndDate as 'End Date',C.CaseId,EA.Hours,EA.ChargeOutRate,EA.ActualCost,      
     isnull((ea.ActualCost/nullif((c.PlannedCost),0)),0)*100 as FeeAllocationPer,c.CaseFee        
  from   @EmployeeActualRecovey EA      
  --left  join @EmployeePlannedRecovey  E on EA.CaseId=E.CaseId and EA.EmployeeId=E.EmployeeId AND PlannedHours<>'0.00'      
     LEFT JOIN @CaseRecovey C ON Ea.CaseId=C.CaseId      
     --where PlannedHours<>'0.00'      
     --AND C.CaseId ='56993CB7-2158-44E3-A371-0C05911F5126'       
     --AND C.CompanyId=1      
  )jj     
   order by jj.Name      
      
 --    UNION ALL      
 --  --SELECT EmployeeId,Designation,EmployeeName AS 'Name', levelrank AS 'Level',StartDate AS 'Start Date',EndDate AS 'End Date','0.00' as 'Hours',      
 --  --ChargeOutRate as 'Charge-Out Rate',0.000000 as 'Fee Allocation($)',0.000000 as 'Fee Allocation(%)' ,0.000000 as 'Cost($)',0.0000000 AS 'Fee Recovery(%)'       
 --  --,0 OverRunCost,0 PlannedCost,0 OverRunCosts      
 --  --FROM @EmployeeActualDetailRecovey      
 --  -- order by jj.Name      
      
      
 --     SELECT EmployeeId,Designation,EmployeeName AS 'Name', levelrank AS 'Level',      
 --  startDate AS 'Start Date',EndDate AS 'End Date','0.00' as 'Hours',      
 --  cast(isnull(ChargeOutRate,0)  as decimal(28,2))  as 'Charge-Out Rate',      
 --     cast(ISNULL((FeeAllocationPer*CaseFee)/100,0) as decimal(28,2)) as 'Fee Allocation($)',cast(isnull(FeeAllocationPer,0) as decimal(28,2)) as 'Fee Allocation(%)' ,0.000000 as 'Cost($)',0.0000000 AS 'Fee Recovery(%)'      
         
 --    from      
 --  (      
 --   select Ea.EmployeeId,EA.Designation,EA.EmployeeName,EA.levelrank ,EA.StartDate ,EA.ChargeOutRate,      
 --EA.EndDate,C.CaseId,isnull((e.OverRunCost/nullif((c.PlannedCost-c.OverRunCost),0)),0)*100 as FeeAllocationPer,c.CaseFee        
 -- from   @EmployeeActualDetailRecovey EA      
 -- left  join @EmployeePlannedRecovey  E on EA.CaseId=E.CaseId and EA.EmployeeId=E.EmployeeId AND PlannedHours<>'0.00'      
 --    LEFT JOIN @CaseRecovey C ON E.CaseId=C.CaseId      
 -- where Ea.EmployeeId is not null      
 -- )jj      
 --   order by jj.Name       
      
 ------     SELECT EmployeeId,Designation,EmployeeName AS 'Name', levelrank AS 'Level',StartDate AS 'Start Date',EndDate AS 'End Date','0.00' as 'Hours',      
 ------  isnull(ChargeOutRate,0) as 'Charge-Out Rate',      
 ------  ISNULL((FeeAllocationPer*CaseFee)/100,0) as 'Fee Allocation($)',isnull(FeeAllocationPer,0) as 'Fee Allocation(%)' ,0.000000 as 'Cost($)',0.0000000 AS 'Fee Recovery(%)'  from      
 ------  (      
 ------   select Ea.EmployeeId,EA.Designation,EA.EmployeeName,EA.levelrank ,EA.StartDate ,EA.ChargeOutRate,      
 ------EA.EndDate,C.CaseId,isnull((e.OverRunCost/nullif((c.PlannedCost-c.OverRunCost),0)),0)*100 as FeeAllocationPer,c.CaseFee        
 ------ from   @EmployeeActualDetailRecovey EA      
 ------ left  join @EmployeePlannedRecovey  E on EA.CaseId=E.CaseId and EA.EmployeeId=E.EmployeeId AND PlannedHours<>'0.00'      
 ------    LEFT JOIN @CaseRecovey C ON E.CaseId=C.CaseId      
 ------ where Ea.EmployeeId is not null      
 ------    --where PlannedHours<>'0.00'      
 ------    --AND C.CaseId ='56993CB7-2158-44E3-A371-0C05911F5126'       
 ------    --AND C.CompanyId=1      
 ------ )jj      
      
      
END
GO
