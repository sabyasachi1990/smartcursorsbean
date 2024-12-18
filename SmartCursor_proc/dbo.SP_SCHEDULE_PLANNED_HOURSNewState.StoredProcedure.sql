USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SCHEDULE_PLANNED_HOURSNewState]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Exec [dbo].[SP_SCHEDULE_PLANNED_HOURSNewState] '2022-06-06','2022-06-30','Senior','A7256B56-9B23-4EAE-9A77-86E7AD7EEC7E','6F88A5D2-57BA-4AC4-B664-1C81C32C92B2', 2050  
  
CREATE Procedure [dbo].[SP_SCHEDULE_PLANNED_HOURSNewState]-----  -- Summary (OUTSIDE )  
 @Fromdate date,  
 @ToDate date,  
 @DesignationName nvarchar (max),  
 @DepartmentId nvarchar (max),  
 @EmployeeId nvarchar (max),   
 @CompanyId int  
  
 AS  
 BEGIN  
  
--DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),STARTDATE DATE,ENDDATE DATE,  
--      TOATLHOURS varchar(max),IsOverRunHours varchar(max),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(100),PHOTOURL NVARCHAR(1000),  
--      SystemId UNIQUEIDENTIFIER NULL ,SystemType NVARCHAR(1000), IsType int,ClientName NVARCHAR (200),CaseState NVARCHAR (40),CaseNumber NVARCHAR (100),  
--      OppState nvarchar(40),ServiceGroup nvarchar(20),ServiceCode nvarchar(20),Likelihood nvarchar(40) , CaseId UNIQUEIDENTIFIER,TaskDate DATE,  
--      Task Nvarchar(1000), ClientId UNIQUEIDENTIFIER,IsOverRun  int, LeaveStatus Nvarchar(200)   
--       )  
  
  
Begin  
Declare @CsrSdate Date,@csrEdate date  
--Declare #Temp table (StartDate date,Enddate date)  
Create table #Temp (StartDate date,Enddate date)  
  
;with cte as  
(  
  select @FROMDATE StartDate, DATEADD(wk, DATEDIFF(wk, 0, @FROMDATE), 5) EndDate  
  union all  
  select dateadd(ww, 1, StartDate),dateadd(ww, 1, EndDate)  
  from cte where dateadd(ww, 1, StartDate)<=  @TODATE  
)  
  Insert Into #Temp  
  select StartDate,EndDate  
  from cte  
  
--Declare #task table (aaCaseId uniqueidentifier,aaEmployeeId uniqueidentifier,aaTaskDate date,aaTask nvarchar(max))  
Create table #task (aaCaseId uniqueidentifier,aaEmployeeId uniqueidentifier,aaTaskDate date,aaTask nvarchar(max))  
insert into #task  
select Distinct AA.CaseId AS AACaseId ,AA.EmployeeId AS AAEmployeeId ,CONVERT( DATE,AA.StartDate) AS AATaskDate,  
-----------========================================  
 STUFF((  
   select Distinct  ', ' + A.Task  
FROM WorkFlow.ScheduleTaskNew A (Nolock)  
 where A.CaseId=AA.CaseId AND A.EmployeeId=AA.EmployeeId AND CONVERT( DATE,A.StartDate)=  CONVERT( DATE,AA.StartDate)  
 and a.CompanyId=@CompanyId  
  FOR XML PATH('')), 1, 1, '') AS AATask  
  --=======================================================================  
 FROM WorkFlow.ScheduleTaskNew AA  
where AA.Status=1 and aa.CompanyId=@CompanyId  
  
BEGIN  
      
       --Insert Into @OUTPUT  
    ;WITH Output_Tbl AS  
    (  
  --==============================================   CaseGroup STEP 1    ==========================================================================  
   select EMPLOYEENAME,CsrSdate,csrEdate,cast(cast (sum(TOATLHOURS ) / 60 + (sum(TOATLHOURS ) % 60) / 100.0  as decimal(28,2)) as  varchar(max))  As TOATLHOURS,  
   cast(cast (sum(ISOVERRUNHOURS ) / 60 + (sum(ISOVERRUNHOURS ) % 60) / 100.0  as decimal(28,2)) as  varchar(max))  As ISOVERRUNHOURS,EMPLOYEEID,  
     EMPLOYEEAUTONUMBER, PHOTOURL, SystemId,  SystemType, IsType,ClientName, CaseState,CaseNumber, OppState, ServiceGroup, ServiceCode ,  
  Likelihood ,  CaseId,TaskDate,REPLACE(AATask, '&amp;', '&') as Task ,ClientId, sum(IsOverRun) as IsOverRun,LeaveStatus   
  from   
  (  
      select  E.FirstName as EMPLOYEENAME,st.Task,TEP.StartDate as CsrSdate ,TEP.EndDate  as csrEdate ,st.PlannedHours As TOATLHOURS ,  
    st.OverRunHours As  ISOVERRUNHOURS,E.Id AS EMPLOYEEID,  
       e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,ST.CaseId AS SystemId, 'CaseGroup'AS 'SystemType', 0 as  IsType   
     ,  CG.Name as ClientName,cg.Stage as CaseState,cg.CaseNumber,o.Stage as OppState,sg.Code as ServiceGroup,ss.Code as ServiceCode  ,cg.Likelihood,
      cg.Id as CaseId,convert( date,ST.StartDate) TaskDate,cg.ClientId as ClientId,isnull(case when IsOverRun=1 then convert (int,IsOverRun) end,0)  as IsOverRun,  
      NULL AS LeaveStatus  
       from WorkFlow.ScheduleTaskNew ST (Nolock)  
            inner join WorkFlow.CaseGroup CG (Nolock) on ST.CaseId = CG.Id  
      left  join ClientCursor.Opportunity o (Nolock) on o.Id=cg.OpportunityId  
      --inner JOIN WORKFLOW.CLIENT C (Nolock) ON C.ID=CG.CLIENTID  
      inner join Common.ServiceGroup sg (Nolock) on sg.id=cg.ServiceGroupId   
      inner join Common.Service ss (Nolock) on ss.id=cg.ServiceId   
            inner join Common.Employee E (Nolock) on ST.EmployeeId = E.Id  and E.DepartmentId=ST.DepartmentId  and  E.DesignationId =  ST.DesignationId 
           -- Inner Join [HR].[EmployeeDepartment] as HR (Nolock) on HR.EmployeeId = E.Id --and st.DepartmentId=hr.DepartmentId and st.DesignationId=hr.DepartmentDesignationId  and   
      --isnull(hr.LevelRank,0)=isnull(st.Level,0)  
      --Left join Common.Department D (Nolock) ON D.ID=ST.DepartmentId  
      --left join Common.DepartmentDesignation DD (Nolock) ON DD.ID=ST.DesignationId  
            LEFT JOIN Common.MediaRepository as MR (Nolock) ON MR.Id=E.PhotoId  
      INNER JOIN #Temp TEP ON cast(ST.StartDate AS date) >= TEP.StartDate And cast(ST.EndDate AS date) <=TEP.EndDate  
            where st.CompanyId = @CompanyId   
      AND --(CAST (ST.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%')  OR  
              CAST (ST.EmployeeId  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@EmployeeId,',')) --)  
      --AND --(CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') OR   
      --    CAST (ST.DepartmentId  AS NVARCHAR(max)) in ( select items  from dbo.SplitToTable(@DepartmentId,',')) --)  
      --AND --( CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%') OR  
      --     CAST (dd.Code  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@DesignationName,',')) --)  
      --  ---  
      --            AND ((TEP.StartDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))   
      --                 else EffectiveTo end  as Date)) or (TEP.EndDate between cast(EffectiveFrom as date)   
      --AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date))  
      --or ST.StartDate=cast(EffectiveFrom as date) or ST.EndDate= cast(EffectiveTo as date)  
     -- )  
            AND cast(ST.StartDate AS date) >= TEP.StartDate And cast(ST.EndDate AS date) <=TEP.EndDate   
      and st.Status=1 ---and CG.ServiceNatureType = 0  ---- Need to Check   
       Group by E.FirstName,st.Task,st.PlannedHours,st.OverRunHours,ST.StartDate,ST.Enddate,E.Id,e.EmployeeId, ST.CaseId,MR.Small    
    ,cg.Name ,cg.Stage ,cg.CaseNumber,o.Stage ,sg.Code ,ss.Code  ,cg.Likelihood  ,cg.id,cg.ClientId,isnull(case when IsOverRun=1 then convert (int,IsOverRun) end,0)  
    ,TEP.StartDate,TEP.EndDate  
    )kk  
    LEFT JOIN   
(  
 select * from #task  
 )GG ON GG.aaCaseId=KK.CaseId where GG.aaEmployeeId=KK.EMPLOYEEID AND GG.aaTaskDate=KK.TaskDate  
    group by EMPLOYEENAME,CsrSdate,csrEdate,EMPLOYEEID,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,  SystemType, IsType  
    ,ClientName, CaseState,CaseNumber, OppState, ServiceGroup, ServiceCode ,Likelihood ,  CaseId,TaskDate,GG.AATask,ClientId,LeaveStatus  
   
 Union all  
 --============================== LeaveApplication  STEP 2 ===============================================  
  
     select  E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate ,CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS ISOVERRUNHOURS,  
       E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 1 as IsType   
     ,   TLI.SubType as ClientName,null as CaseState,null as CaseNumber,null as OppState,null as ServiceGroup,null as ServiceCode ,null as Likelihood , null as CaseId,  
     convert( date, TLI.StartDate) TaskDate,null as Task,null as ClientId,0 as IsOverRun,TLI.SystemSubTypeStatus AS LeaveStatus --La.LeaveStatus  
       from  Common.TimeLogItem TLI (Nolock)  
             inner join Common.TimeLogItemDetail TLD (Nolock) on TLD.TimelogitemId=TLI.Id  
             inner join Common.Employee E (Nolock) on E.Id = TLD.EmployeeId 
             --Inner Join [HR].[EmployeeDepartment] as HR (Nolock) on HR.EmployeeId = E.Id   
        --inner join Common.Department D (Nolock) ON D.ID=HR.DepartmentId  
        --inner join Common.DepartmentDesignation DD (Nolock) ON DD.ID=HR.DepartmentDesignationId  
             LEFT JOIN Common.MediaRepository as MR (Nolock) ON MR.Id=E.PhotoId  
             --LEFT join hr.LeaveApplication as La (Nolock) on La.Id=TLI.SystemId  
       INNER JOIN #Temp TEP ON cast(TLI.StartDate AS date)  >= TEP.StartDate And cast(TLI.EndDate AS date) <=TEP.EndDate  
      where TLI.CompanyId = @CompanyId   
      AND --(CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%')  OR  
              CAST (TLD.EmployeeId  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@EmployeeId,','))-- )  
      --AND --(CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') OR   
      --    CAST (hr.DepartmentId  AS NVARCHAR(max)) in ( select items  from dbo.SplitToTable(@DepartmentId,',')) --)  
      --AND --( CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%') OR  
      --     CAST (dd.Code AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@DesignationName,',')) --)  
  
      --            AND  ((TEP.StartDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))   
      --                  else EffectiveTo end  as Date)) or (TEP.EndDate between cast(EffectiveFrom as date)  
      --AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))  
            AND  cast(TLI.StartDate AS date) >=TEP.StartDate And cast(TLI.EndDate AS date) <=TEP.EndDate  
            AND TLI.IsSystem=1 and TLI.Status=1 and TLI.SystemType='LeaveApplication'  and TLI.SystemSubTypeStatus in ('Submitted','Recommended','Approved','For Cancellation')  
     Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small, TLI.SubType   
      ,TEP.StartDate,TEP.EndDate,TLI.SystemSubTypeStatus  
   Union all  
  --================================== Calender STEP 3 =============================================  
       
  select  E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate ,CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS,'00.00' AS ISOVERRUNHOURS,  
       E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 2 as IsType  
     ,   TLI.SubType as ClientName,null as CaseState,null as CaseNumber,null as OppState,null as ServiceGroup,null as ServiceCode,null as Likelihood  , null as CaseId,  
        convert( date, TLI.StartDate) TaskDate ,null as Task,null as ClientId ,0 as IsOverRun, NULL AS LeaveStatus  
       from  Common.TimeLogItem TLI (Nolock)  
             inner join Common.TimeLogItemDetail TLD (Nolock) on TLD.TimelogitemId=TLI.Id  
             inner join Common.Employee E (Nolock) on E.Id = TLD.EmployeeId   
             --Inner Join [HR].[EmployeeDepartment] as HR (Nolock) on HR.EmployeeId = E.Id  
         --inner join Common.Department D (Nolock) ON D.ID=HR.DepartmentId  
      --inner join Common.DepartmentDesignation DD (Nolock) ON DD.ID=HR.DepartmentDesignationId  
             LEFT JOIN Common.MediaRepository as MR (Nolock) ON MR.Id=E.PhotoId  
        INNER JOIN #Temp TEP ON cast(TLI.StartDate AS date) >= TEP.StartDate And cast(TLI.EndDate AS date) <=TEP.EndDate  
      where TLI.CompanyId = @CompanyId   
       AND --(CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%')  OR  
              CAST (TLD.EmployeeId  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@EmployeeId,',')) --)  
       --AND --(CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') OR   
       --   CAST (hr.DepartmentId  AS NVARCHAR(max)) in ( select items  from dbo.SplitToTable(@DepartmentId,','))-- )  
       --AND --( CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%') OR  
       --    CAST (dd.Code  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@DesignationName,',')) --)  
       --            AND  ((TEP.StartDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))   
       --                 else EffectiveTo end  as Date)) or (TEP.EndDate between cast(EffectiveFrom as date)   
       --AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))  
             AND  cast(TLI.StartDate AS date) >= TEP.StartDate And cast(TLI.EndDate AS date) <=TEP.EndDate  
             AND TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=0 and TLI.IsMain=0 -- Need to Check   
      Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small, TLI.SubType   
    ,TEP.StartDate,TEP.EndDate  
   Union all  
   --================================== Calender ApplyToAll STEP 4 =============================================  
  
 select  E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate ,CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS ISOVERRUNHOURS,  
      E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 2 as IsType   
    ,   TLI.SubType as ClientName,null as CaseState,null as CaseNumber,null as OppState,null as ServiceGroup,null as ServiceCode,null as Likelihood, null as CaseId ,  
       convert( date, TLI.StartDate) TaskDate ,null as Task ,null as ClientId ,0 as IsOverRun, NULL AS LeaveStatus  
      from  Common.TimeLogItem TLI (Nolock)  
            inner join Common.Employee E (Nolock) on E.CompanyId = TLI.CompanyId  
           -- Inner Join [HR].[EmployeeDepartment] as HR (Nolock) on HR.EmployeeId = E.Id  
         --inner join Common.Department D (Nolock) ON D.ID=HR.DepartmentId  
      --inner join Common.DepartmentDesignation DD (Nolock) ON DD.ID=HR.DepartmentDesignationId  
            LEFT JOIN Common.MediaRepository as MR (Nolock) ON MR.Id=E.PhotoId  
      INNER JOIN #Temp TEP ON cast(TLI.StartDate AS date) >= TEP.StartDate And cast(TLI.EndDate AS date) <=TEP.EndDate  
      where TLI.CompanyId = @CompanyId   
       AND --(CAST (E.Id  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%')  OR  
              CAST (E.Id  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@EmployeeId,','))-- )  
       --AND --(CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') OR   
       --   CAST (hr.DepartmentId  AS NVARCHAR(max)) in ( select items  from dbo.SplitToTable(@DepartmentId,',')) --)  
       --AND --( CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%') OR  
       --    CAST (dd.Code  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@DesignationName,',')) --)  
          --         AND ((TEP.StartDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))   
          --             else EffectiveTo end  as Date)) or (TEP.EndDate between cast(EffectiveFrom as date)   
          --AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))  
             AND  cast(TLI.StartDate AS date) >= TEP.StartDate And cast(TLI.EndDate AS date) <= TEP.EndDate  
             AND TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and TLI.IsMain=0 -- Need to Check   
     Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small , TLI.SubType   
      ,TEP.StartDate,TEP.EndDate  
     union all  
       --================================== TrainingType STEP 5 =============================================  
       
  select  E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate ,ISNULL(CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)),'0.00' )As TOATLHOURS,'00.00' AS ISOVERRUNHOURS,  
       E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 2 as IsType  
     ,   TLI.SubType as ClientName,null as CaseState,null as CaseNumber,null as OppState,null as ServiceGroup,null as ServiceCode,null as Likelihood  , null as CaseId,  
        convert( date, TLI.StartDate) TaskDate ,null as Task,null as ClientId ,0 as IsOverRun, NULL AS LeaveStatus  
       from  Common.TimeLogItem TLI (Nolock)  
             inner join Common.TimeLogItemDetail TLD (Nolock) on TLD.TimelogitemId=TLI.Id  
             inner join Common.Employee E (Nolock) on E.Id = TLD.EmployeeId   
             --Inner Join [HR].[EmployeeDepartment] as HR (Nolock) on HR.EmployeeId = E.Id  
         --inner join Common.Department D (Nolock) ON D.ID=HR.DepartmentId  
      --inner join Common.DepartmentDesignation DD (Nolock) ON DD.ID=HR.DepartmentDesignationId  
             LEFT JOIN Common.MediaRepository as MR (Nolock) ON MR.Id=E.PhotoId  
        INNER JOIN #Temp TEP ON cast(TLI.StartDate AS date) >= TEP.StartDate And cast(TLI.EndDate AS date) <=TEP.EndDate  
      where TLI.CompanyId = @CompanyId   
       AND --(CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%')  OR  
              CAST (TLD.EmployeeId  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@EmployeeId,',')) --)  
       --AND --(CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') OR   
       --   CAST (hr.DepartmentId  AS NVARCHAR(max)) in ( select items  from dbo.SplitToTable(@DepartmentId,','))-- )  
       --AND --( CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%') OR  
       --    CAST (dd.Code  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DesignationName,',')) --)  
       --            AND  ((TEP.StartDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))   
       --                 else EffectiveTo end  as Date)) or (TEP.EndDate between cast(EffectiveFrom as date)   
       --AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))  
             AND  cast(TLI.StartDate AS date) >= TEP.StartDate And cast(TLI.EndDate AS date) <=TEP.EndDate  
             AND TLI.SystemType='Training' and TLI.Status=1  and TLI.IsSystem=1  
      Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small, TLI.SubType   
  
    ,TEP.StartDate,TEP.EndDate  
  
   )  
  Select EMPLOYEENAME ,CsrSdate STARTDATE ,csrEdate ENDDATE ,TOATLHOURS ,IsOverRunHours ,EMPLOYEEID ,EMPLOYEEAUTONUMBER ,PHOTOURL ,SystemId  ,SystemType , IsType  
 , ClientName, CaseState,CaseNumber, OppState, ServiceGroup, ServiceCode,Likelihood,  CaseId,TaskDate,Task,ClientId,IsOverRun,LeaveStatus  
  From Output_Tbl  
   END   
  
   
 --Fetch Next From Week_Csr into @CsrSdate,@csrEdate  
 --   End  
     
 --  close Week_Csr  
 --  Deallocate Week_Csr  
    
  
   
 End  
DROP TABLE #Temp  
DROP TABLE #task  
  
END  
GO
