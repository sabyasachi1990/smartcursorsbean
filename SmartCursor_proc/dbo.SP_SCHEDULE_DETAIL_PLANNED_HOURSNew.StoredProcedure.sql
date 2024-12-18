USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SCHEDULE_DETAIL_PLANNED_HOURSNew]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---EXEC [dbo].[SP_SCHEDULE_DETAIL_PLANNED_HOURSNew] '2022-05-30','2022-06-30', 'E33C3D29-C93F-49F5-A6C2-9E82C36BD3F6', 2050  
  
  
CREATE  Procedure [dbo].[SP_SCHEDULE_DETAIL_PLANNED_HOURSNew]  
 @FROMDATE DATE,  
 @TODATE DATE,   
 @EMPLOYEEID UNIQUEIDENTIFIER,  
 @COMPANYID BIGINT   
  
 As  
 Begin  
   
--DECLARE  
-- @FROMDATE DATE = '2022-05-30',  
-- @TODATE DATE = '2022-06-30',   
-- @EMPLOYEEID UNIQUEIDENTIFIER = 'E33C3D29-C93F-49F5-A6C2-9E82C36BD3F6',--'54EB3FE5-2147-4243-BE51-B591F7596672',  
-- @COMPANYID BIGINT = 2050  
  
  
  
  
--DECLARE @OUTPUT TABLE   
  
CREATE TABLE #OutPut_Tbl  
( EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),  
                        CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),CASENAME NVARCHAR(1000), STARTDATE DATE,  
      ENDDATE DATE,TOATLHOURS varchar(max),IsOverRunHours varchar(max),CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000),  
      SCHEDULETYPEID UNIQUEIDENTIFIER NULL,SUBTYPE NVARCHAR(1000), OppSTAGE NVARCHAR(50), SCHEDULETYPE NVARCHAR(100), IsType bit,  
      LeaveStatus NVARCHAR(100))  
  
  
--Insert Into @OUTPUT  
Begin  
Declare @CsrSdate Date,  
  @csrEdate date  
--Declare @Temp table (StartDate date,Enddate date)  
CREATE TABLE #Temp (StartDate date,Enddate date)  
  
  
;with cte as  
(  
  select @FROMDATE StartDate,   
    DATEADD(wk, DATEDIFF(wk, 0, @FROMDATE), 5) EndDate  
  union all  
  select dateadd(ww, 1, StartDate),  
    dateadd(ww, 1, EndDate)  
  from cte  
  where dateadd(ww, 1, StartDate)<=  @TODATE  
)  
Insert Into #Temp  
select StartDate,EndDate  
from cte  
  
WHILE ((SELECT COUNT(*) FROM #Temp) > 0)  
BEGIN  
 SELECT TOP 1 @CsrSdate = StartDate,@csrEdate = Enddate FROM #Temp  
  
--Declare Week_Csr Cursor for   
-- Select StartDate,Enddate from @Temp  
--Open Week_Csr  
--Fetch Next From Week_Csr into @CsrSdate,@csrEdate  
--While @@FETCH_STATUS=0  
  
  
BEGIN  
Insert Into #OutPut_Tbl  
 select EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,CsrSdate,csrEdate,cast(cast (sum(TOATLHOURS ) / 60 + (sum(TOATLHOURS ) % 60) / 100.0  as decimal(28,2)) as  varchar(max)) As TOATLHOURS,  
   cast(cast (sum(ISOVERRUNHOURS ) / 60 + (sum(ISOVERRUNHOURS ) % 60) / 100.0  as decimal(28,2)) as  varchar(max)) As ISOVERRUNHOURS,  
 CASEID,PHOTOURL,SCHEDULETYPEID,SUBTYPE,OppSTAGE,SCHEDULETYPE,IsType,LeaveStatus from   
(  
   select E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID,e.EmployeeId AS EMPLOYEENUMBER,st.Task,  
       Cg.NAME AS CLIENTNAME ,CG.SYSTEMREFNO AS CASENUMBER, Cg.NAME AS CASENAME,@CsrSdate as CsrSdate,@csrEdate as csrEdate,st.PlannedHours TOATLHOURS ,  
    OverRunHours As  ISOVERRUNHOURS,CG.ID AS CASEID,  
    MR.Small as PHOTOURL,ST.CaseId AS SCHEDULETYPEID, NULL AS SUBTYPE,o.stage as OppSTAGE,'CaseGroup' AS  SCHEDULETYPE, 0 as  IsType,Null as LeaveStatus    
        from WorkFlow.ScheduleTaskNew ST (NOLOCK)  
            inner join WorkFlow.CaseGroup CG (NOLOCK) on ST.CaseId = CG.Id  
            left join ClientCursor.Opportunity o (NOLOCK) on o.Id=cg.OpportunityId --- new changes 27-01-2020  
            --inner JOIN WORKFLOW.CLIENT C (NOLOCK) ON C.ID=CG.CLIENTID  --parvathi
            inner join Common.Employee E (NOLOCK) on ST.EmployeeId = E.Id    
            --Inner Join [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id --and st.DepartmentId=hr.DepartmentId and st.DesignationId=hr.DepartmentDesignationId --parvathi 
       --and isnull(st.Level,0)=isnull(hr.LevelRank,0)  
            LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
       where st.CompanyId = @CompanyId and ST.EmployeeId = @EmployeeId  
         --         and   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))   
         --               else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date)  
         --and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date))  
      --or ST.StartDate=cast(EffectiveFrom as date) or ST.EndDate= cast(EffectiveTo as date)  
      --)  
            and ST.StartDate >= @CsrSdate And ST.EndDate <=@csrEdate and st.Status=1  
  
     Group by E.FirstName,st.Task,st.PlannedHours,st.OverRunHours,ST.StartDate,o.stage,ST.Enddate,E.Id,e.EmployeeId, ST.CaseId,MR.Small, CG.ID,Cg.NAME,CG.SYSTEMREFNO  
     )kk  
      group by EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,CsrSdate,csrEdate,  
            CASEID,PHOTOURL,SCHEDULETYPEID,SUBTYPE,OppSTAGE,SCHEDULETYPE,IsType,LeaveStatus   
   
 union all  
 ------------------------- TimeLogItem.SystemType='LeaveApplication'=1  
  
      select  E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, NULL AS CASENAME,  
           @CsrSdate,@csrEdate , CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS,' 00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,  
        MR.Small as PHOTOURL,TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE, 1 as IsType,TLI.SystemSubTypeStatus    
       from  Common.TimeLogItem TLI (NOLOCK)  
             inner join Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id  
             inner join Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId   
             --Inner Join [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id  
             LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
             --LEFT join hr.LeaveApplication as La (NOLOCK) on La.Id=TLI.SystemId --parvathi 
       where TLI.CompanyId = @CompanyId and TLD.EmployeeId  = @EmployeeId   
       --   AND ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))   
       --                else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date)   
       --and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))  
             and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate  
             and TLI.IsSystem=1 and TLI.SystemType='LeaveApplication' and TLI.Status=1 and TLI.SystemSubTypeStatus in ('Submitted','Recommended','Approved','For Cancellation')  
      Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small ,TLI.SubType,TLI.SystemSubTypeStatus  
  
 union all  
  ------------------------ TimeLogItem.SystemType='Calender'=2  
  
  
        select  E.FirstName as EMPLOYEENAME, E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,  
         @CsrSdate,@csrEdate ,CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,  
            MR.Small as PHOTOURL, TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,2 as IsType,Null as LeaveStatus   
         from  Common.TimeLogItem TLI (NOLOCK)  
         inner join Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id  
         inner join Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId   
         --Inner Join [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id  --parvathi 
         LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
         where TLI.CompanyId = @CompanyId and TLD.EmployeeId  = @EmployeeId  
         --   AND ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))   
         --                else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date)  
         --and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))  
               and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate  
               and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=0 and  TLI.IsMain=0  
         Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small,TLI.SubType   
  
 union all  
  ------------------------ TimeLogItem.SystemType='Calender'=2  
  
  
        select  E.FirstName as EMPLOYEENAME, E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,  
          @CsrSdate,@csrEdate ,CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,  
             MR.Small as PHOTOURL,TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,2 as IsType,Null as LeaveStatus    
          from  Common.TimeLogItem TLI (NOLOCK)  
                inner join Common.Employee E (NOLOCK) on E.CompanyId = TLI.CompanyId  
                --Inner Join [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id  --parvathi
                LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
          where TLI.CompanyId = @CompanyId and E.Id  = @EmployeeId   
          --AND ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))   
          --                 else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date)   
          --and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))  
                and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate  
                and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and  TLI.IsMain=0  
        Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small,TLI.SubType   
  
     -------------------------------------------------Training--------------------  
  union all    
        select  E.FirstName as EMPLOYEENAME, E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,  
         @CsrSdate,@csrEdate ,ISNULL(CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)),'0.00') As TOATLHOURS, '00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,  
            MR.Small as PHOTOURL, TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,2 as IsType,Null as LeaveStatus    
         from  Common.TimeLogItem TLI (NOLOCK)  
         inner join Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id  
         inner join Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId   
         --Inner Join [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id  --parvathi 
         LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
         where TLI.CompanyId = @CompanyId and TLD.EmployeeId  = @EmployeeId  
         --   AND ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))   
         --                else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date)  
         --and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))  
               and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate  
               and TLI.SystemType='Training' and TLI.Status=1   
         Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small,TLI.SubType   
  
  
--Fetch Next From Week_Csr into @CsrSdate,@csrEdate  
  
End  
  
 DELETE FROM #Temp WHERE StartDate = @CsrSdate AND Enddate = @csrEdate  
  
--close Week_Csr  
--Deallocate Week_Csr  
END    
  
  Select EMPLOYEENAME ,EMPLOYEEID ,EMPLOYEENUMBER , CLIENTNAME ,CASENUMBER ,CASENAME , STARTDATE , ENDDATE ,TOATLHOURS ,IsOverRunHours ,CASEID ,PHOTOURL ,SCHEDULETYPEID ,SUBTYPE , OppSTAGE, SCHEDULETYPE , IsType,LeaveStatus   
  From #OutPut_Tbl  
  
  DROP TABLE #Temp  
 End  
 DROP TABLE #OutPut_Tbl  
END  
GO
