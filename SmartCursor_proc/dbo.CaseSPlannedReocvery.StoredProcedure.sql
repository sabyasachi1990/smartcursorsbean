USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CaseSPlannedReocvery]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[CaseSPlannedReocvery]  --  Exec [dbo].[CasesPlannedReocvery] '38286b5b-60d2-46e8-9b70-600bca83e274'    
 @CaseId UNIQUEIDENTIFIER ,
 @Isactual bit
 as    
 Begin    
 --sp_helptext CasesActualReocvery  
     --select * from Workflow.ScheduleDetailnew where EmployeeId='7d8d537a-8ed1-4da9-8df1-3d71131ecd30' and MasterId='0E288341-5F97-4BD8-9155-0A3F04207F2A'  
 -- select * from workflow.schedulenew where caseid='38286b5b-60d2-46e8-9b70-600bca83e274'  
 --select * from hr.EmployeeDepartment where EmployeeId='7D8D537A-8ED1-4DA9-8DF1-3D71131ECD30' and DepartmentId='F45239EF-29FC-4A98-9542-F68BEE93A36C' and DepartmentDesignationId='4A204A47-CA5B-4FF2-BA52-C001411487DD'  
DECLARE @EmployeeRecovey TABLE ( CaseId UNIQUEIDENTIFIER,EmployeeId UNIQUEIDENTIFIER,DepartmentId UNIQUEIDENTIFIER,DesignationId UNIQUEIDENTIFIER,    
EmployeeName NVARCHAR(max),Department NVARCHAR(max),Designation NVARCHAR(max),levelrank int,    
PlannedHours nvarchar(max),OverRunHours NVARCHAR(max),TotalHours NVARCHAR(max),ChargeOutRate decimal(28,9),PlannedCost decimal(28,9),OverRunCost decimal(28,9)    
,StartDate datetime2,EndDate datetime2    
)    
DECLARE @EmployeeDetailRecovey TABLE ( CaseId UNIQUEIDENTIFIER,EmployeeId UNIQUEIDENTIFIER,DepartmentId UNIQUEIDENTIFIER,DesignationId UNIQUEIDENTIFIER,    
EmployeeName NVARCHAR(max),Department NVARCHAR(max),Designation NVARCHAR(max),levelrank int,    
ChargeOutRate decimal(28,9),StartDate datetime2,EndDate datetime2,CompanyId int    
)    
       
DECLARE @CaseRecovey TABLE ( CaseId UNIQUEIDENTIFIER,CaseFee money,ChargeOutRate decimal(28,9),PlannedCost decimal(28,9),OverRunCost decimal(28,9),CompanyId int)    
    
 --================================================== Each case wise task hous,PlannedCost,OverRunCost =========================================================================      
   insert into @CaseRecovey    
   select CaseId,isnull(d.CaseFee,0) as CaseFee,isnull((sum(ChargeOutRateNew)/nullif(sum(TotalHours)/60.0,0)),0) as ChargeOutRate,    
   sum(ChargeOutRateNew) as PlannedCost,sum(OverRunCost) as OverRunCost,d.CaseCompanyId as CompanyId from     
    (    
      select dISTINCT st.CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,ST.Level,PlannedHours,OverRunHours,ChargeOutRate,(PlannedHours+OverRunHours) as TotalHours,    
      (TotalHours*ChargeOutRate) as ChargeOutRateNew,(OverRunHoursnew*ChargeOutRate) as OverRunCost,st.CompanyId from    
      (    
       select st.CompanyId,CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,ST.Level,sum(isnull(PlannedHours,0)) as PlannedHours,sum(isnull(OverRunHours,0))  as OverRunHours,    
    sum(isnull(OverRunHours,0))/60.0 as OverRunHoursnew,    
    (sum(PlannedHours) +sum(isnull(OverRunHours,0)))/60.0 as TotalHours,isnull(st.ChargeoutRate,0) as ChargeoutRate from     
       WorkFlow.ScheduleTaskNew st    
    where st.CaseId=@CaseId  
       group by  st.CompanyId,CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,st.ChargeoutRate,ST.Level    
      )st    
 )k 
 INNER join     
    (    
      select Id,isnull(BaseFee,0) AS CaseFee,CompanyId AS CaseCompanyId FROM WorkFlow.CaseGroup where id=@CaseId   
    ) d on  d.Id=k.CaseId and d.CaseCompanyId=k.CompanyId     
   Where k.CaseId=@CaseId   
   group  by k.CaseId,d.CaseFee,d.CaseCompanyId    
      order by k.CaseId    
--================================================== Each Employee wise task hous,PlannedCost,OverRunCost =========================================================================    
 insert into @EmployeeRecovey    
   
    select CaseId,EmployeeId,k.DepartmentId,k.DesignationId,k.EmployeeName,k.Department,k.Designation,k.LevelRank,    
     
 cast(cast (sum(PlannedHours ) / 60 + (sum(PlannedHours ) % 60) / 100.0  as decimal(28,2)) as  varchar(max)) as PlannedHours,    
 cast(cast (sum(OverRunHours ) / 60 + (sum(OverRunHours ) % 60) / 100.0  as decimal(28,2)) as  varchar(max)) as OverRunHours,    
 cast(cast (sum(TotalHours ) / 60 + (sum(TotalHours ) % 60) / 100.0  as decimal(28,2)) as  varchar(max)) as TotalHours,    
  
 isnull(ChargeoutRate,0) as ChargeOutRate,sum(ChargeOutRateNew) as PlannedCost,sum(OverRunCost) as OverRunCost,min(StartDate) as StartDate ,max(EndDate) EndDate from     
    (    
      select dISTINCT st.CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,st.FirstName as EmployeeName,st.department as Department,st.designationcode as Designation,st.level as LevelRank,PlannedHours,OverRunHours,ChargeOutRate,    
   (PlannedHours+OverRunHours) as TotalHours,(TotalHours*ChargeOutRate) as ChargeOutRateNew,(PlannedHoursnew*ChargeOutRate) as OverRunCost,StartDate,EndDate from    
      (    
        select distinct s.CaseId,st1.EmployeeId,st1.DepartmentId,st1.DesignationId,e.FirstName,isnull(ss.Code,d.Code) as department,isnull(ss.designation,dd.Code) as designationcode,ss.Level as level,sum(isnull(PlannedHours,0)) as PlannedHours,sum(isnull(PlannedHours,0))/60.0 as PlannedHoursnew,sum(isnull(OverRunHours,
0))  as OverRunHours,    
     sum(isnull(OverRunHours,0))/60.0 as OverRunHoursnew,    
     (sum(PlannedHours) +sum(isnull(OverRunHours,0)))/60.0 as TotalHours, (case when ((sum(PlannedHours) +sum(isnull(OverRunHours,0)))/60.0) is not null then isnull(ss.ChargeoutRate,0) else st1.ChargeoutRate end)  as ChargeoutRate,min(ss.StartDate) as StartDate ,max(ss.EndDate) EndDate
	 --,ss.ChargeoutRate as sscharge, st1.ChargeoutRate as stcharge 
 from     
   WorkFlow.ScheduleDetailNew st1    
     inner join WorkFlow.ScheduleNew s on s.id=st1.MasterId   
   join common.Employee as e on e.id=st1.EmployeeId  
   join common.Department as d on d.id=st1.DepartmentId  
   join common.DepartmentDesignation as dd on dd.id= st1.DesignationId  
  
   inner join WorkFlow.CaseGroup c on c.id=s.CaseId   
   
    left join       
  (      
    Select Distinct sw.EmployeeId,sw.CaseId,d.Code ,dd.Code as designation ,sw.ChargeoutRate,sw.StartDate,sw.EndDate,sw.level,sw.PlannedHours,sw.OverRunHours   
    From WorkFlow.ScheduleDetailNew st    
     inner join WorkFlow.ScheduleNew s on s.id=st.MasterId    
   left join WorkFlow.ScheduleTaskNew sw on sw.EmployeeId=st.EmployeeId and sw.CaseId=s.CaseId   
   join common.Employee as e on e.id=st.EmployeeId  
   join common.Department as d on d.id=sw.DepartmentId  
   join common.DepartmentDesignation as dd on dd.id= sw.DesignationId  
   inner join WorkFlow.CaseGroup c on c.id=s.CaseId  
   where s.CaseId=@CaseId
    group by d.Code,dd.Code  ,sw.EmployeeId,sw.CaseId,sw.ChargeoutRate,sw.StartDate,sw.EndDate,sw.Level,sw.PlannedHours,sw.OverRunHours
   )ss on ss.EmployeeId=st1.EmployeeId and ss.CaseId=s.CaseId    
     
   where s.CaseId=@caseId    
   
    group by S.CaseId,ST1.EmployeeId,st1.DepartmentId,st1.DesignationId,e.FirstName,d.Code,dd.Code,s.CompanyId,st1.ChargeoutRate,ss.Code,ss.designation,ss.ChargeoutRate,ss.StartDate,ss.EndDate,ss.Level,ss.PlannedHours,ss.OverRunHours
      
      )st   
      
 ) k  
 group  by k.CaseId,k.EmployeeId,k.DepartmentId,k.DesignationId,k.EmployeeName,k.Department,k.Designation,k.LevelRank,k.ChargeoutRate  
 order by CaseId  
  
--================================================== Each Employee wise task hous,PlannedCost,OverRunCost =========================================================================    
      insert into @EmployeeDetailRecovey    
         
         select Distinct S.CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,e.FirstName as EmployeeName,d.Code as Department,dd.Code as Designation,st.Level as levelrank,cast(sw.ChargeoutRate as Decimal(28,9)) as ChargeOutRate,    
    case when st.StartDate is null then min(sw.StartDate) else st.StartDate end StartDate ,case when st.EndDate is null then max(sw.EndDate) else st.EndDate end EndDate,    
   s.CompanyId  
   from       
   WorkFlow.ScheduleDetailNew st    
     inner join WorkFlow.ScheduleNew s on s.id=st.MasterId    
   left join WorkFlow.ScheduleTaskNew sw on sw.EmployeeId=st.EmployeeId and sw.CaseId=s.CaseId   
   join common.Employee as e on e.id=st.EmployeeId  
   join common.Department as d on d.id=st.DepartmentId  
   join common.DepartmentDesignation as dd on dd.id= st.DesignationId  
  
   inner join WorkFlow.CaseGroup c on c.id=s.CaseId    
   where s.CaseId=@CaseId      
   
    group by S.CaseId,ST.EmployeeId,st.DepartmentId,st.DesignationId,e.FirstName,d.Code,dd.Code,st.Level,st.StartDate,st.EndDate,s.CompanyId  ,sw.ChargeoutRate  
    ORDER BY CaseId   
   
--==============================================================Get data from this tables @CaseRecovey,@EmployeeRecovey,@EmployeeDetailRecovey  ================================= 

if(@Isactual=1)
begin
insert into Workflow.plannedRecovery 
select newId(),@CaseId, EmployeeId,null,Designation,cast(isnull(ChargeOutRate,0) as decimal(28,2)) as 'Charge-Out Rate',    
   cast(isnull((FeeAllocationPer*CaseFee)/100,0) as decimal(28,2)) as 'Fee Allocation($)',cast(isnull(FeeAllocationPer,0) as decimal(28,2)) as 'Fee Allocation(%)',[Start Date],[End Date] from 
   (    
     select e.Designation,E.EmployeeId,e.StartDate as 'Start Date',    
  e.EndDate as 'End Date',E.ChargeOutRate,   
     isnull((E.OverRunCost/nullif((c.PlannedCost-c.OverRunCost),0)),0)*100 as FeeAllocationPer,c.CaseFee     
  from @EmployeeRecovey E     
     Left JOIN @CaseRecovey C ON c.CaseId=E.CaseId 
	 )gg 
	 
end


else
begin


   select EmployeeId,Designation,[Name],[Level] ,[Start Date],[End Date],PlannedHours as 'Hours',OverRunHours as 'Overrun Hours',    
   cast(isnull(ChargeOutRate,0) as decimal(28,2)) as 'Charge-Out Rate',    
   cast(isnull((FeeAllocationPer*CaseFee)/100,0) as decimal(28,2)) as 'Fee Allocation($)',    
   cast(isnull(FeeAllocationPer,0) as decimal(28,2)) as 'Fee Allocation(%)' ,    
  cast( isnull(PlannedCost,0) as decimal(28,2)) as 'Cost($)',    
   cast(isnull((((FeeAllocationPer*CaseFee)/100)/(NULLIF(PlannedCost,0)))*100,0) as decimal(28,2)) AS 'Fee Recovery(%)'  from    
   (    
     select e.Designation,e.EmployeeName as 'Name',e.levelrank as 'Level',e.StartDate as 'Start Date',    
  e.EndDate as 'End Date',C.CaseId,E.EmployeeId,PlannedHours,OverRunHours,TotalHours,E.ChargeOutRate,E.PlannedCost,E.OverRunCost,    
     isnull((E.OverRunCost/nullif((c.PlannedCost-c.OverRunCost),0)),0)*100 as FeeAllocationPer,c.CaseFee      
  from @EmployeeRecovey E   
  --left join @EmployeeDetailRecovey as ed on ed.EmployeeId=e.EmployeeId  
     Left JOIN @CaseRecovey C ON c.CaseId=E.CaseId    
     --where TotalHours<>'0.00'      
     --AND C.CaseId ='6A1D90F4-4603-469A-9284-08A82579C2DA'     
     --AND C.CompanyId=1    
   )gg    
   --UNION ALL    
   --SELECT EmployeeId,Designation,EmployeeName AS 'Name', levelrank AS 'Level',StartDate AS 'Start Date',EndDate AS 'End Date','0.00' as 'Hours','0.00' as 'Overrun Hours',    
   --cast(ChargeOutRate as decimal(28,2)) as 'Charge-Out Rate',0.000000 as 'Fee Allocation($)',0.000000 as 'Fee Allocation(%)' ,0.000000 as 'Cost($)',0.0000000 AS 'Fee Recovery(%)'     
   --FROM @EmployeeDetailRecovey    
   order by gg.Name    
  end  
     --WHERE CaseId ='6A1D90F4-4603-469A-9284-08A82579C2DA'     
  --WHERE  CompanyId=1    
  --ORDER BY CaseId    
    
    
      
  --select  id,CaseNumber,CompanyId,isnull(Fee,0) as'Fee Allocation($)',isnull((isnull(Fee,0)/nullif(isnull(TargettedRecovery,0),0))*100,0) as 'Cost($)',    
  --isnull(TargettedRecovery,0) as 'Fee Recovery(%)'     
  --from WorkFlow.CaseGroup     
  --where id not in     
  --(    
  --select distinct caseid from WorkFlow.Schedule s     
  --inner join WorkFlow.ScheduleDetailNew sd on sd.MasterId=s.Id    
  --)    
    
    
END


--create table Workflow.plannedRecovery(
--Id uniqueIdentifier,
--CaseId uniqueIdentifier,
--EmployeeId uniqueIdentifier,
--Department nvarchar(200),
--Designation nvarchar(300),
--ChargeoutRate decimal(15,10),
--FeeAllocationdollar decimal(15,10),
--Feeallocationpercentage decimal(15,10),
--StartDate datetime2(7),
--EndDate datetime2(7)
--);


--delete from Workflow.PlannedRecovery where caseid in ()
GO
