USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SCHEDULE_DETAIL_PLANNED_HOURS_old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create  Procedure [dbo].[SP_SCHEDULE_DETAIL_PLANNED_HOURS_old]
 @FROMDATE DATE,
 @TODATE DATE, 
  @EMPLOYEEID UNIQUEIDENTIFIER,
 @COMPANYID BIGINT 

 As
 Begin
 
DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),
                        CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),CASENAME NVARCHAR(1000), STARTDATE DATE,
						ENDDATE DATE,TOATLHOURS MONEY,IsOverRunHours Money,CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000),SCHEDULETYPEID UNIQUEIDENTIFIER NULL,SUBTYPE NVARCHAR(1000), OppSTAGE NVARCHAR(50), SCHEDULETYPE NVARCHAR(100), IsType bit)


--Insert Into @OUTPUT
Begin
Declare @CsrSdate Date,
		@csrEdate date
Declare @Temp table (StartDate date,Enddate date)


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
Insert Into @Temp
select StartDate,EndDate
from cte

Declare Week_Csr Cursor for 
	Select StartDate,Enddate from @Temp
Open Week_Csr
Fetch Next From Week_Csr into @CsrSdate,@csrEdate
While @@FETCH_STATUS=0
Begin
Insert Into @OUTPUT
 select E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID,e.EmployeeId AS EMPLOYEENUMBER,
	C.NAME AS CLIENTNAME ,CG.SYSTEMREFNO AS CASENUMBER, C.NAME AS CASENAME,@CsrSdate,@csrEdate ,
		 CAST (SUM(DATEDIFF(MINUTE,0,ST.Hours))/60.0  AS DECIMAL (20,2))As TOATLHOURS,
		 isnull(CAST (SUM(DATEDIFF(MINUTE,0,ST.IsOverRunHours))/60.0  AS DECIMAL (20,2)),0.00) As IsOverRunHours,CG.ID AS CASEID,
		MR.Small as PHOTOURL,ST.CaseId AS SCHEDULETYPEID, NULL AS SUBTYPE,o.stage as OppSTAGE,
		   'CaseGroup' AS  SCHEDULETYPE, 0 as  IsType 
		from WorkFlow.ScheduleTask ST
		 inner join WorkFlow.CaseGroup CG on ST.CaseId = CG.Id
		left join ClientCursor.Opportunity o on o.CaseId=cg.Id
		  inner JOIN WORKFLOW.CLIENT C ON C.ID=CG.CLIENTID
		inner join Common.Employee E on ST.EmployeeId = E.Id  
		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		 LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		where st.CompanyId = @CompanyId and
			ST.EmployeeId = @EmployeeId
and   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and ST.StartDate >= @CsrSdate And ST.EndDate <=@csrEdate and st.Status=1
		---and o.Status=1  AND  (O.IsTemp=0 OR O.IsTemp IS NULL)
		Group by E.FirstName,ST.StartDate,o.stage,ST.Enddate,E.Id,e.EmployeeId, ST.CaseId, ST.SystemType,MR.Small, CG.ID,C.NAME,CG.SYSTEMREFNO
	
	union all
	------------------------- TimeLogItem.SystemType='LeaveApplication'=1

       select  E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,
	  TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, NULL AS CASENAME,
	@CsrSdate,@csrEdate ,SUM(distinct TLI.Hours) As TOATLHOURS, 0.00 AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,
		 MR.Small as PHOTOURL,
		 TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE, 1 as IsType 
		from  Common.TimeLogItem TLI
		inner join Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		inner join Common.Employee E on E.Id = TLD.EmployeeId 
		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		 LEFT join hr.LeaveApplication as La on La.Id=TLI.SystemId
		where TLI.CompanyId = @CompanyId and 
			TLD.EmployeeId  = @EmployeeId AND 
  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		and TLI.IsSystem=1 and TLI.SystemType='LeaveApplication' and TLI.Status=1 and La.leavestatus in ('Submitted','Recommended','Approved','For Cancellation')
		Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small ,TLI.SubType

		union all
		------------------------ TimeLogItem.SystemType='Calender'=2


        select  E.FirstName as EMPLOYEENAME,	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,
		  TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,
		@CsrSdate,@csrEdate ,SUM(distinct TLI.Hours) As TOATLHOURS, 0.00 AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,
	 MR.Small as PHOTOURL,
		 TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,2 as IsType 
		from  Common.TimeLogItem TLI
		inner join Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		inner join Common.Employee E on E.Id = TLD.EmployeeId 
		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		where TLI.CompanyId = @CompanyId and 
			TLD.EmployeeId  = @EmployeeId AND 
  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		 and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=0 and  TLI.IsMain=0
		Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small,TLI.SubType 

			union all
		------------------------ TimeLogItem.SystemType='Calender'=2


        select  E.FirstName as EMPLOYEENAME,	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,
		  TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,
		@CsrSdate,@csrEdate ,SUM( distinct TLI.Hours) As TOATLHOURS, 0.00 AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,
	 MR.Small as PHOTOURL,
		 TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,2 as IsType 
		from  Common.TimeLogItem TLI
		inner join Common.Employee E on E.CompanyId = TLI.CompanyId
		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		where TLI.CompanyId = @CompanyId and 
			E.Id  = @EmployeeId AND 
  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		 and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and  TLI.IsMain=0
		Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small,TLI.SubType 


Fetch Next From Week_Csr into @CsrSdate,@csrEdate
End

close Week_Csr
Deallocate Week_Csr
  

  Select EMPLOYEENAME ,EMPLOYEEID ,EMPLOYEENUMBER , CLIENTNAME ,CASENUMBER ,CASENAME , STARTDATE ,	ENDDATE ,TOATLHOURS ,IsOverRunHours ,CASEID ,PHOTOURL ,SCHEDULETYPEID ,SUBTYPE , OppSTAGE, SCHEDULETYPE , IsType 
  From @OUTPUT
 End

END







GO
