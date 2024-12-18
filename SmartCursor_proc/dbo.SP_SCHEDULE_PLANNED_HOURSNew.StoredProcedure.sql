USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SCHEDULE_PLANNED_HOURSNew]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--========================================================================14 ==================================================================
create Procedure [dbo].[SP_SCHEDULE_PLANNED_HOURSNew]  -----  -- Summary (OUTSIDE )

 @Fromdate date,
 @ToDate date,
 @DesignationName nvarchar (max),
 @DepartmentId nvarchar (max),
 @EmployeeId nvarchar (max), 
 @CompanyId int
 AS
 BEGIN
  declare @DesignationId nvarchar (max)
    Set @DesignationId=( SELECT DISTINCT LEFT(Desg,Len(Desg)-1) as   Desg FROM 
  (
   SELECT FF.Id , 
  (
   SELECT CAST(DD.Id AS nvarchar(100)) + ',' AS [text()]  FROM  Common.DepartmentDesignation DD
   INNER JOIN Common.Department D ON D.ID=DD.DepartmentId
   WHERE DD.Name IN (select items from dbo.SplitToTable(@DesignationName,',')) 
    AND DD.DepartmentId IN (select items from dbo.SplitToTable(@DepartmentId,',')) 
   AND CompanyId=@CompanyId
    FOR XML PATH ('')
	) AS Desg FROM Common.DepartmentDesignation FF 
	   WHERE ff.Name IN (select items from dbo.SplitToTable(@DesignationName,',')) 
      AND FF.DepartmentId IN (select items from dbo.SplitToTable(@DepartmentId,',')) 
	)HH
	)

	 --   Declare @Fromdate date='02/09/2020 00:00:00 AM'
  --      Declare @ToDate date='02/15/2020 00:00:00 AM'
		--Declare @EmployeeId  uniqueidentifier='B1107A1A-C74B-7A21-ED0A-F8454D1528C8'
		--Declare @DepartmentId uniqueidentifier=NUll
		----'B72E0F75-0361-45CD-83AB-42C891E84552'
		--Declare @DesignationId uniqueidentifier=NUll
		----'DEB181C7-7362-4197-9A5A-B907DDC5CC0A'
  --      Declare @CompanyId int=10

DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),STARTDATE DATE,ENDDATE DATE,
TOATLHOURS varchar(max),IsOverRunHours varchar(max),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(100),PHOTOURL NVARCHAR(1000),SystemId UNIQUEIDENTIFIER NULL ,SystemType NVARCHAR(1000), IsType int)


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
  IF (@EmployeeId IS NULL AND  @DepartmentId IS NULL  AND @DesignationId IS NULL)
  BEGIN
     Insert Into @OUTPUT
	 --==============================================   CaseGroup STEP 1    ==========================================================================
	  select EMPLOYEENAME,CsrSdate,csrEdate,cast(cast (sum(TOATLHOURS ) / 60 + (sum(TOATLHOURS ) % 60) / 100.0  as decimal(28,2)) as  varchar(max)) As TOATLHOURS,
	  cast(cast(sum(ISOVERRUNHOURS )/60.0  as decimal(28,2)) as varchar) As ISOVERRUNHOURS,EMPLOYEEID,
	    EMPLOYEEAUTONUMBER, PHOTOURL, SystemId,  SystemType, IsType from 
	 (
      select  E.FirstName as EMPLOYEENAME,st.Task,@CsrSdate as CsrSdate ,@csrEdate  as csrEdate ,st.PlannedHours As TOATLHOURS ,
			 st.OverRunHours As  ISOVERRUNHOURS,E.Id AS EMPLOYEEID,
		     e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,ST.CaseId AS SystemId, 'CaseGroup'AS 'SystemType', 0 as  IsType 
		     from WorkFlow.ScheduleTaskNew ST
		          inner join WorkFlow.CaseGroup CG on ST.CaseId = CG.Id
		          inner join Common.Employee E on ST.EmployeeId = E.Id  
		          Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		          LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		     where st.CompanyId = @CompanyId 
				  --AND CAST (ST.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
				  --AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') 
				  --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')

                  AND ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                       else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
				  AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		          AND ST.StartDate >= @CsrSdate And ST.EndDate <=@csrEdate and st.Status=1 ---and CG.ServiceNatureType = 0  ---- Need to Check 
		    		     Group by E.FirstName,st.Task,st.PlannedHours,st.OverRunHours,ST.StartDate,ST.Enddate,E.Id,e.EmployeeId, ST.CaseId,MR.Small  
			 )kk
			 group by EMPLOYEENAME,CsrSdate,csrEdate,EMPLOYEEID,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,  SystemType, IsType
	
	
	Union all
	--============================== LeaveApplication  STEP 2 ===============================================

     select  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate ,CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS ISOVERRUNHOURS,
		     E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 1 as IsType 
		     from  Common.TimeLogItem TLI
		           inner join Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		           inner join Common.Employee E on E.Id = TLD.EmployeeId 
		           Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		           LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		           LEFT join hr.LeaveApplication as La on La.Id=TLI.SystemId
		    where TLI.CompanyId = @CompanyId 
			      --AND CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
			      --AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') 
			      --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')

                  AND  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                        else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date)
				  AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		          AND  TLI.StartDate >=@CsrSdate And TLI.EndDate <=@csrEdate
		          AND TLI.IsSystem=1 and TLI.Status=1 and TLI.SystemType='LeaveApplication'  and La.leavestatus in ('Submitted','Recommended','Approved','For Cancellation')
		   Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

   Union all
		--================================== Calender STEP 3 =============================================
     
	 select  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate ,CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS,'00.00' AS ISOVERRUNHOURS,
		     E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 2 as IsType 
		     from  Common.TimeLogItem TLI
		           inner join Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		           inner join Common.Employee E on E.Id = TLD.EmployeeId 
		           Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		           LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		    where TLI.CompanyId = @CompanyId 
			    --   AND CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
				   --AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%')
				   --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
                   AND  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                        else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
				   AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		           AND  TLI.StartDate >= @CsrSdate And TLI.EndDate <=@csrEdate
		           AND TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=0 and TLI.IsMain=0 -- Need to Check 
		    Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

   Union all
   --================================== Calender ApplyToAll STEP 4 =============================================

	select  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate ,CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS ISOVERRUNHOURS,
		    E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 2 as IsType 
		    from  Common.TimeLogItem TLI
		          inner join Common.Employee E on E.CompanyId = TLI.CompanyId
		          Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		          LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		    where TLI.CompanyId = @CompanyId 
			       --AND CAST (E.Id  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
			       --AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') 
			       --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
                   AND ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                       else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
			       AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		           AND  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		           AND TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and TLI.IsMain=0 -- Need to Check 
		   Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 
   END 
   ELSE 
   BEGIN 
       Insert Into @OUTPUT
	 --==============================================   CaseGroup STEP 1    ==========================================================================
	  select EMPLOYEENAME,CsrSdate,csrEdate,cast(cast (sum(TOATLHOURS ) / 60 + (sum(TOATLHOURS ) % 60) / 100.0  as decimal(28,2)) as  varchar(max)) As TOATLHOURS,
	  cast(cast(sum(ISOVERRUNHOURS )/60.0  as decimal(28,2)) as varchar) As ISOVERRUNHOURS,EMPLOYEEID,
	    EMPLOYEEAUTONUMBER, PHOTOURL, SystemId,  SystemType, IsType from 
	 (
      select  E.FirstName as EMPLOYEENAME,st.Task,@CsrSdate as CsrSdate ,@csrEdate  as csrEdate ,st.PlannedHours As TOATLHOURS ,
			 st.OverRunHours As  ISOVERRUNHOURS,E.Id AS EMPLOYEEID,
		     e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,ST.CaseId AS SystemId, 'CaseGroup'AS 'SystemType', 0 as  IsType 
		     from WorkFlow.ScheduleTaskNew ST
		          inner join WorkFlow.CaseGroup CG on ST.CaseId = CG.Id
		          inner join Common.Employee E on ST.EmployeeId = E.Id  
		          Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id and st.DepartmentId=hr.DepartmentId and st.DesignationId=hr.DepartmentDesignationId
		          LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		     where st.CompanyId = @CompanyId 
				  AND (CAST (ST.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%')  OR
			           CAST (ST.EmployeeId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@EmployeeId,',')) )
				  AND (CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') OR 
				      CAST (hr.DepartmentId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DepartmentId,',')) )
				  AND ( CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%') OR
				       CAST (hr.DepartmentDesignationId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DesignationId,',')) )

                  AND ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                       else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
				  AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		          AND ST.StartDate >= @CsrSdate And ST.EndDate <=@csrEdate and st.Status=1 ---and CG.ServiceNatureType = 0  ---- Need to Check 
		     Group by E.FirstName,st.Task,st.PlannedHours,st.OverRunHours,ST.StartDate,ST.Enddate,E.Id,e.EmployeeId, ST.CaseId,MR.Small  
			 )kk
			 group by EMPLOYEENAME,CsrSdate,csrEdate,EMPLOYEEID,EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,  SystemType, IsType
	
	Union all
	--============================== LeaveApplication  STEP 2 ===============================================

     select  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate ,CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS ISOVERRUNHOURS,
		     E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 1 as IsType 
		     from  Common.TimeLogItem TLI
		           inner join Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		           inner join Common.Employee E on E.Id = TLD.EmployeeId 
		           Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		           LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		           LEFT join hr.LeaveApplication as La on La.Id=TLI.SystemId
		    where TLI.CompanyId = @CompanyId 
				  AND (CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%')  OR
			           CAST (TLD.EmployeeId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@EmployeeId,',')) )
				  AND (CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') OR 
				      CAST (hr.DepartmentId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DepartmentId,',')) )
				  AND ( CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%') OR
				       CAST (hr.DepartmentDesignationId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DesignationId,',')) )

                  AND  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                        else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date)
				  AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		          AND  TLI.StartDate >=@CsrSdate And TLI.EndDate <=@csrEdate
		          AND TLI.IsSystem=1 and TLI.Status=1 and TLI.SystemType='LeaveApplication'  and La.leavestatus in ('Submitted','Recommended','Approved','For Cancellation')
		   Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

   Union all
		--================================== Calender STEP 3 =============================================
     
	 select  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate ,CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS,'00.00' AS ISOVERRUNHOURS,
		     E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 2 as IsType 
		     from  Common.TimeLogItem TLI
		           inner join Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		           inner join Common.Employee E on E.Id = TLD.EmployeeId 
		           Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		           LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		    where TLI.CompanyId = @CompanyId 
				   AND (CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%')  OR
			           CAST (TLD.EmployeeId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@EmployeeId,',')) )
				   AND (CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') OR 
				      CAST (hr.DepartmentId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DepartmentId,',')) )
				   AND ( CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%') OR
				       CAST (hr.DepartmentDesignationId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DesignationId,',')) )
                   AND  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                        else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
				   AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		           AND  TLI.StartDate >= @CsrSdate And TLI.EndDate <=@csrEdate
		           AND TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=0 and TLI.IsMain=0 -- Need to Check 
		    Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

   Union all
   --================================== Calender ApplyToAll STEP 4 =============================================

	select  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate ,CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS ISOVERRUNHOURS,
		    E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 2 as IsType 
		    from  Common.TimeLogItem TLI
		          inner join Common.Employee E on E.CompanyId = TLI.CompanyId
		          Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		          LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		    where TLI.CompanyId = @CompanyId 
				   AND (CAST (E.Id  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%')  OR
			           CAST (E.Id  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@EmployeeId,',')) )
				   AND (CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') OR 
				      CAST (hr.DepartmentId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DepartmentId,',')) )
				   AND ( CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%') OR
				       CAST (hr.DepartmentDesignationId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DesignationId,',')) )
                   AND ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                       else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
			       AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		           AND  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		           AND TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and TLI.IsMain=0 -- Need to Check 
		   Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 
   END 

	
	Fetch Next From Week_Csr into @CsrSdate,@csrEdate
    End
   
   close Week_Csr
   Deallocate Week_Csr
  

  Select EMPLOYEENAME ,STARTDATE ,ENDDATE ,TOATLHOURS ,IsOverRunHours ,EMPLOYEEID ,EMPLOYEEAUTONUMBER ,PHOTOURL ,SystemId  ,SystemType , IsType
  From @OUTPUT
 End
 end

GO
