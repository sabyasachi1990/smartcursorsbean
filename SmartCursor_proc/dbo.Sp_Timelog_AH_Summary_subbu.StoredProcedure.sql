USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Timelog_AH_Summary_subbu]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--Exec [dbo].[Sp_Timelog_AH_Summary]  '2018-12-30','2019-01-05',null,null,'7dd26e99-26d2-4df3-9aeb-b91dceebe45b',1

CReate PROCEDURE [dbo].[Sp_Timelog_AH_Summary_subbu]  -----  -- Summary (OUTSIDE )

 @Fromdate date,
 @ToDate date,
 @DesignationId uniqueidentifier,
 @DepartmentId uniqueidentifier,
 @EmployeeId  uniqueidentifier, 
 @CompanyId int
 AS
 BEGIN


	 --   Declare @Fromdate date='2018-12-30'
  --      Declare @ToDate date='2019-01-05'
		--Declare @EmployeeId  uniqueidentifier='630d8a35-0bcb-44b9-9309-9415dd7eb8c5'
		--Declare @DepartmentId uniqueidentifier=NUll
		----'B72E0F75-0361-45CD-83AB-42C891E84552'
		--Declare @DesignationId uniqueidentifier=NUll
		----'DEB181C7-7362-4197-9A5A-B907DDC5CC0A'
  --     Declare @CompanyId int=1

DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),STARTDATE DATE,ENDDATE DATE,
TOTALHOURS MONEY,IsOverRunHours Money,EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(100),PHOTOURL NVARCHAR(1000),SystemId UNIQUEIDENTIFIER,SystemType NVARCHAR(1000), IsType bit)


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



SELECT DISTINCT  E.FirstName as EMPLOYEENAME,@CsrSdate, 
		@csrEdate,--SUM(DATEDIFF(MINUTE,0,TLD.Duration))/60.0 As TOATLHOURS,0 AS IsOverRunHours,
		(CAST((SUM(DATEPART(hh,tld.Duration)*60+DATEPART(MI,tld.Duration)))/60 AS varchar(6)) + '.' + CAST((SUM(DATEPART(hh,tld.Duration)*60+DATEPART(MI,tld.Duration)))%60 As varchar(20))) As TOTALHOURS,Cast(0 as decimal(10,2)) AS IsOverRunHours,E.Id AS EMPLOYEEID,
		e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,TLI.Id AS SystemId,TLI.SystemType,0 as IsType  
		FROM Common.TimeLog T
		INNER JOIN Common.TimeLogDetail TLD ON T.Id=TLD.MasterId
		INNER JOIN Common.TimeLogItem TLI ON TLI.Id=T.TimeLogItemId
		LEFT JOIN WorkFlow.CaseGroup CG on TLI.SystemId = CG.Id
		INNER JOIN Common.Employee E on T.EmployeeId = E.Id  
		INNER JOIN [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		WHERE T.CompanyId = @CompanyId and t.Status=1 AND SystemType='CaseGroup' AND t.Status=1 AND tld.Duration <> '00:00:00.0000000' and 
		CAST (T.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') AND 
        CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') AND
        CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
        AND   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
        then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
        else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
       cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
       Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and T.StartDate >= @CsrSdate And T.EndDate <= @csrEdate --and CG.ServiceNatureType = 0
		GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.Id, TLI.SystemType,MR.Small  
		--)AS AA
	
	UNION ALL
	------------------------- TimeLogItem.SystemType='LeaveApplication'=1

   SELECT DIstinct E.FirstName as EMPLOYEENAME,@CsrSdate,
	    @csrEdate,SUM(distinct TLI.Hours) As TOATLHOURS, Cast(0 as decimal(10,2)) AS IsOverRunHours,
		E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		 TLI.SystemId AS SystemId, TLI.SystemType AS 'SystemType', 1 as IsType 
		from  Common.TimeLogItem TLI
		INNER JOIN Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		INNER JOIN Common.Employee E on E.Id = TLD.EmployeeId 
		INNER JOIN [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		LEFT JOIN hr.LeaveApplication as La on La.Id=TLI.SystemId
		WHERE TLI.CompanyId = @CompanyId and 
		CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') AND 
		CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') AND
		CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
		and   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
		 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
		else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
		cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
		Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate AND TLI.Status=1
		and TLI.IsSystem=1 and TLI.SystemType='LeaveApplication'  and La.leavestatus in ('Approved','For Cancellation')
		GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

		UNION ALL
		------------------------ TimeLogItem.SystemType='Calender'=2


    SELECT DISTINCT E.FirstName as EMPLOYEENAME,@CsrSdate,
	    @csrEdate,SUM(distinct TLI.Hours) As TOATLHOURS, Cast(0 as decimal(10,2)) AS IsOverRunHours,
		E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		TLI.SystemId AS SystemId, TLI.SystemType AS 'SystemType', 2 as IsType 
	    from  Common.TimeLogItem TLI
		INNER JOIN  Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		INNER JOIN Common.Employee E on E.Id = TLD.EmployeeId 
		INNER JOIN  [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		--INNER join hr.LeaveApplication as La on La.Id=TLI.SystemId
		where TLI.CompanyId = @CompanyId  AND TLI.Status=1 AND TLI.ApplyToAll=0 AND
		CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') AND 
        CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') AND
        CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
        and   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
		then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
		else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
		cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
		Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		and TLI.IsSystem=1 and TLI.SystemType='Calender' and TLI.IsMain=0 ----
		GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 


		union all

		     select DIstinct E.FirstName as EMPLOYEENAME,@CsrSdate,
	    @csrEdate,SUM(distinct TLI.Hours) As TOATLHOURS, 0.00 AS ISOVERRUNHOURS,
		E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		 TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 3 as IsType 
		from  Common.TimeLogItem TLI
		inner join Common.Employee E on E.CompanyId = TLI.CompanyId
		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		where TLI.CompanyId = @CompanyId and 
			CAST (E.Id  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') AND 
			CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') AND
			CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
			and   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
			 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
			else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
			cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
			Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and TLI.IsMain=0 -- Need to Check 
		Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 


			union all


			 SELECT  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate,
	(CAST((SUM(DATEPART(hh,tld.Duration)*60+DATEPART(MI,tld.Duration)))/60 AS varchar(6)) + '.' + CAST((SUM(DATEPART(hh,tld.Duration)*60+DATEPART(MI,tld.Duration)))%60 As varchar(20))) As TOATLHOURS, 0 AS IsOverRunHours,
	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		 TLI.SystemId AS SystemId, TLI.SystemType AS 'SystemType', 4 as IsType 
	 	from  Common.TimeLogItem TLI
		Inner Join Common.TimeLog L on l.TimeLogItemId=TLI.id
		Inner Join Common.TimeLogDetail TLD ON TLD.MasterId=L.Id
		inner join Common.Employee E on E.Id = L.EmployeeId
		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = L.EmployeeId
		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
WHERE TLI.CompanyId = @CompanyId and 
		CAST (L.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') AND 
		CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') AND
		CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
		and   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
		 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
		else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
		cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
		Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLD.Date >= @CsrSdate And TLd.Date <= @csrEdate  and TLI.SystemType='Time Log Item' and TLI.Status=1 and TLI.ApplyToAll is null 
		and tld.Duration <> '00:00:00.0000000'
	 GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 


	
	Fetch Next From Week_Csr into @CsrSdate,@csrEdate
End

close Week_Csr
Deallocate Week_Csr
  

  Select EMPLOYEENAME ,STARTDATE ,ENDDATE ,
TOTALHOURS ,IsOverRunHours ,EMPLOYEEID ,EMPLOYEEAUTONUMBER ,PHOTOURL ,SystemId  ,SystemType ,IsType
  From @OUTPUT
 END
 END
GO
