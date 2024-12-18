USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SCHEDULE_PLANNED_HOURS_Pending]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_SCHEDULE_PLANNED_HOURS_Pending]  -----  -- Summary (OUTSIDE )

 @Fromdate date,
 @ToDate date,
 @DesignationId uniqueidentifier,
 @DepartmentId uniqueidentifier,
 @EmployeeId  uniqueidentifier, 
 @CompanyId int
 AS
 BEGIN
--- exec [dbo].[SP_SCHEDULE_PLANNED_HOURS_Pending]'02/09/2020 00:00:00 AM','02/15/2020 00:00:00 AM',null,null,'B1107A1A-C74B-7A21-ED0A-F8454D1528C8',10


 	--    Declare @Fromdate date='02/09/2020 00:00:00 AM'
  --      Declare @ToDate date='02/15/2020 00:00:00 AM'
		--Declare @EmployeeId  uniqueidentifier='B1107A1A-C74B-7A21-ED0A-F8454D1528C8'


	-------------------------------- -- Summary (OUTSIDE ) 
  -- Declare @Fromdate date='2018-01-30'
  --      Declare @ToDate date='2019-01-05'
		--Declare @EmployeeId  uniqueidentifier=null
		--Declare @DepartmentId uniqueidentifier=NUll
		----'B72E0F75-0361-45CD-83AB-42C891E84552'
		--Declare @DesignationId uniqueidentifier=NUll
		----'DEB181C7-7362-4197-9A5A-B907DDC5CC0A'
  --      Declare @CompanyId int=1


  DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),STARTDATE DATE,
		  ENDDATE DATE,TOATLHOURS varchar(max),ISOVERRUNHOURS varchar(max),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(100),
          PHOTOURL NVARCHAR(1000),SystemId UNIQUEIDENTIFIER NULL,SystemType NVARCHAR(50), IsType int)


--Insert Into @OUTPUT
  Begin
  Declare @CsrSdate Date,@csrEdate date
  Declare @Temp table (StartDate date,Enddate date)


  ;with cte as
  (
    select @FROMDATE StartDate, DATEADD(wk, DATEDIFF(wk, 0, @FROMDATE), 5) EndDate
    union all
    select dateadd(ww, 1, StartDate),dateadd(ww, 1, EndDate)
    from cte where dateadd(ww, 1, StartDate)<=  @TODATE
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

  IF (@EmployeeId IS NULL AND @DepartmentId IS NULL AND @DesignationId IS NULL )
  BEGIN 
  Insert Into @OUTPUT

	----======================================ScheduleTask STEP 1 ====================================================
	 select EMPLOYEENAME,CsrSdate,csrEdate,cast(cast(sum(TOATLHOURS )/60.0  as decimal(28,2)) as varchar) As TOATLHOURS,
	  cast(cast(sum(ISOVERRUNHOURS )/60.0  as decimal(28,2)) as varchar) As ISOVERRUNHOURS,EMPLOYEEID,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,SystemType,IsType from 
	(
	select  E.FirstName as EMPLOYEENAME,st.Title,@CsrSdate as CsrSdate,@csrEdate as csrEdate,((DATEPART(HOUR,st.Hours)*60)+((DATEPART(MINUTE,st.Hours))))As TOATLHOURS ,
			 ((DATEPART(HOUR,st.IsOverRunHours)*60)+((DATEPART(MINUTE,st.IsOverRunHours))))As  ISOVERRUNHOURS,E.Id AS EMPLOYEEID,
		    e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,ST.CaseId AS SystemId, 'CaseGroup'AS SystemType, 0 as  IsType 
		    from WorkFlow.ScheduleTask ST (NOLOCK)
		         inner join WorkFlow.CaseGroup CG (NOLOCK) on ST.CaseId = CG.Id
		         Inner Join ClientCursor.Opportunity o (NOLOCK) on o.Id=cg.OpportunityId
	             inner join Common.Employee E (NOLOCK) on ST.EmployeeId = E.Id  
		         Inner Join [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
		         LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		   where st.CompanyId = @CompanyId and  o.Stage='Pending' 
		      --   AND CAST (ST.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%')
		      --   AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') 
			     --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
                 AND ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                      else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
				 AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		         AND ST.StartDate >= @CsrSdate And ST.EndDate <= @csrEdate and st.Status=1 ---and CG.ServiceNatureType = 0  ---- Need to Check 
		  Group by E.FirstName,st.Title,ST.StartDate,ST.Enddate,E.Id,e.EmployeeId, ST.CaseId, ST.SystemType,MR.Small ,st.Hours ,st.IsOverRunHours
		  )kk
		  group by EMPLOYEENAME,CsrSdate,csrEdate,EMPLOYEEID,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,SystemType,IsType
	 END 
	  ELSE 
	  BEGIN 
	  Insert Into @OUTPUT
		 select EMPLOYEENAME,CsrSdate,csrEdate,cast(cast(sum(TOATLHOURS )/60.0  as decimal(28,2)) as varchar) As TOATLHOURS,
	  cast(cast(sum(ISOVERRUNHOURS )/60.0  as decimal(28,2)) as varchar) As ISOVERRUNHOURS,EMPLOYEEID,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,SystemType,IsType from 
	(
	select  E.FirstName as EMPLOYEENAME,st.Title,@CsrSdate as CsrSdate,@csrEdate as csrEdate,((DATEPART(HOUR,st.Hours)*60)+((DATEPART(MINUTE,st.Hours))))As TOATLHOURS ,
			 ((DATEPART(HOUR,st.IsOverRunHours)*60)+((DATEPART(MINUTE,st.IsOverRunHours))))As  ISOVERRUNHOURS,E.Id AS EMPLOYEEID,
		    e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,ST.CaseId AS SystemId, 'CaseGroup'AS SystemType, 0 as  IsType 
		    from WorkFlow.ScheduleTask ST (NOLOCK)
		         inner join WorkFlow.CaseGroup CG (NOLOCK) on ST.CaseId = CG.Id
		         Inner Join ClientCursor.Opportunity o (NOLOCK) on o.Id=cg.OpportunityId
	             inner join Common.Employee E (NOLOCK) on ST.EmployeeId = E.Id  
		         Inner Join [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
		         LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		   where st.CompanyId = @CompanyId and  o.Stage='Pending' 
		         AND CAST (ST.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%')
		      --   AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') 
			     --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
                 AND ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                      else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
				 AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		         AND ST.StartDate >= @CsrSdate And ST.EndDate <= @csrEdate and st.Status=1 ---and CG.ServiceNatureType = 0  ---- Need to Check 
		  Group by E.FirstName,st.Title,ST.StartDate,ST.Enddate,E.Id,e.EmployeeId, ST.CaseId, ST.SystemType,MR.Small ,st.Hours ,st.IsOverRunHours
		  )kk
		  group by EMPLOYEENAME,CsrSdate,csrEdate,EMPLOYEEID,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,SystemType,IsType

	  END 
	Fetch Next From Week_Csr into @CsrSdate,@csrEdate
    End

   close Week_Csr
   Deallocate Week_Csr
  

  Select EMPLOYEENAME ,STARTDATE ,ENDDATE ,TOATLHOURS ,ISOVERRUNHOURS ,EMPLOYEEID ,EMPLOYEEAUTONUMBER ,
         PHOTOURL ,SystemId ,SystemType , IsType 
  From @OUTPUT
 End
 end 


GO
