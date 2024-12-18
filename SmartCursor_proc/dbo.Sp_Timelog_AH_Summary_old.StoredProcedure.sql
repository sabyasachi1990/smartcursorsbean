USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Timelog_AH_Summary_old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 --Exec [dbo].[Sp_Timelog_AH_Summary_old]  '2018-12-30','2019-01-05',null,null,'7dd26e99-26d2-4df3-9aeb-b91dceebe45b',1

CREATE  PROCEDURE [dbo].[Sp_Timelog_AH_Summary_old]  -----  -- Summary (OUTSIDE )

 @Fromdate date, 
 @ToDate date,
 @DepartmentId uniqueidentifier,
 @DesignationId uniqueidentifier,
 @EmployeeId  uniqueidentifier, 
 @CompanyId int

 AS
 BEGIN


	 --   Declare @Fromdate date='2018-01-01'
  --      Declare @ToDate date='2018-09-29'
		--Declare @EmployeeId  uniqueidentifier='9A6068A7-1AEC-24A4-819A-3F3C3E29805B'
		--Declare @DepartmentId uniqueidentifier=NUll
		----'B72E0F75-0361-45CD-83AB-42C891E84552'
		--Declare @DesignationId uniqueidentifier=NUll
		----'DEB181C7-7362-4197-9A5A-B907DDC5CC0A'
  --      Declare @CompanyId int=1

	--------------TImeLog=cases=0

	SELECT DISTINCT EMPLOYEENAME,STARTDATE,ENDDATE,
	(CAST((TOATLHOURS)/60 AS varchar(6)) + '.' + CAST((TOATLHOURS)%60 As varchar(20))) As TOTALHOURS,Cast(0 as decimal(10,2)) AS IsOverRunHours,EMPLOYEEID,
	EMPLOYEEAUTONUMBER,PHOTOURL,SystemId,SystemType AS 'SystemType', 0 as IsType 
	FROM
	(
	SELECT DISTINCT  E.FirstName as EMPLOYEENAME,T.StartDate as STARTDATE, 
		T.Enddate AS ENDDATE,--SUM(DATEDIFF(MINUTE,0,TLD.Duration))/60.0 As TOATLHOURS,0 AS IsOverRunHours,
		SUM(DATEPART(hh,duration)*60+DATEPART(MI,duration)) As TOATLHOURS,E.Id AS EMPLOYEEID,
		e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,TLI.Id AS SystemId,TLI.SystemType 
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
        AND   ((@FromDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
        then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
        else EffectiveTo end  as Date)) or (@ToDate between cast(EffectiveFrom as date) and 
       cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
       Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and T.StartDate >= @Fromdate And T.EndDate <= @ToDate --and CG.ServiceNatureType = 0
		GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.Id, TLI.SystemType,MR.Small  
		)AS AA
	
	UNION ALL
	------------------------- TimeLogItem.SystemType='LeaveApplication'=1

   SELECT DIstinct E.FirstName as EMPLOYEENAME,TLI.StartDate as STARTDATE,
	    TLI.Enddate AS ENDDATE,SUM(distinct TLI.Hours) As TOATLHOURS, Cast(0 as decimal(10,2)) AS IsOverRunHours,
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
		and   ((@FromDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
		 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
		else EffectiveTo end  as Date)) or (@ToDate between cast(EffectiveFrom as date) and 
		cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
		Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLI.StartDate >= @Fromdate And TLI.EndDate <= @ToDate AND TLI.Status=1
		and TLI.IsSystem=1 and TLI.SystemType='LeaveApplication'  and La.leavestatus in ('Approved','For Cancellation')
		GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

		UNION ALL
		------------------------ TimeLogItem.SystemType='Calender'=2


    SELECT DISTINCT E.FirstName as EMPLOYEENAME,TLI.StartDate as STARTDATE,
	    TLI.Enddate AS ENDDATE,SUM(distinct TLI.Hours) As TOATLHOURS, Cast(0 as decimal(10,2)) AS IsOverRunHours,
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
        and   ((@FromDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
		then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
		else EffectiveTo end  as Date)) or (@ToDate between cast(EffectiveFrom as date) and 
		cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
		Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLI.StartDate >= @Fromdate And TLI.EndDate <= @ToDate
		and TLI.IsSystem=1 and TLI.SystemType='Calender' and TLI.IsMain=0 ----
		GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 


		union all

		     select DIstinct E.FirstName as EMPLOYEENAME,TLI.StartDate as STARTDATE,
	    TLI.Enddate AS ENDDATE,SUM(distinct TLI.Hours) As TOATLHOURS, 0.00 AS ISOVERRUNHOURS,
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
			and   ((@FromDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
			 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
			else EffectiveTo end  as Date)) or (@ToDate between cast(EffectiveFrom as date) and 
			cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
			Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLI.StartDate >= @Fromdate And TLI.EndDate <= @ToDate
		and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and TLI.IsMain=0 -- Need to Check 
		Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 


			union all


			 SELECT  E.FirstName as EMPLOYEENAME,	TLI.StartDate as STARTDATE,
	    TLI.Enddate AS ENDDATE,
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
		and   ((@FromDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
		 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
		else EffectiveTo end  as Date)) or (@ToDate between cast(EffectiveFrom as date) and 
		cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
		Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLD.Date >= @FromDate And TLd.Date <= @ToDate  and TLI.SystemType='Time Log Item' and TLI.Status=1 and TLI.ApplyToAll is null and tld.Duration <> '00:00:00.0000000'
	GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

		END
GO
