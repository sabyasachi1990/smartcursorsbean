USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF.PlannedandActualHours_Sp]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 Create Procedure [dbo].[WF.PlannedandActualHours_Sp]
 AS
 BEGIN
 --Exec [WF.PlannedandActualHours_Sp]

 Select EmployeeId,FirstName, SystemType,StartDate,EndDate,[Chargeable],[Non-Chargeable],[Non-Working],Total,
 case when [Unaccountable]<0 then 0 else [Unaccountable] end  Unaccountable,
case when Unaccountable>0 then 0 else Unaccountable end Overruntime,
  OverRunHours, TenantId,Types--,DefaultWorkingHours
  From 
 (
 select EmployeeId,FirstName,Type, SystemType,StartDate,EndDate,[Chargeable],[Non-Chargeable],[Non-Working], SUM([Chargeable]+[Non-Chargeable]+[Non-Working]) AS Total,
 (DefaultWorkingHours-([Chargeable]+[Non-Chargeable]+[Non-Working])) AS Unaccountable,Types,
 OverRunHours, TenantId--,DefaultWorkingHours

  from 
 (
 select EmployeeId,FirstName,Type, SystemType,StartDate,EndDate,
 isnull([Chargeable],0)[Chargeable],isnull([Non-Chargeable],0)[Non-Chargeable],isnull([Non-Working],0)[Non-Working],
 sum(isnull([Chargeable],0)+isnull([Non-Chargeable],0)+isnull([Non-Working],0)) AS Total,
 OverRunHours, TenantId,DefaultWorkingHours,Types
  from  
 (
 select distinct  EmployeeId,FirstName, Type, SystemType,ChargeType,StartDate,EndDate,ChargeType AS Types,
       CAST ( PlannedHours AS decimal(28,2)) AS TotalHours ,
         CAST (OverRunHours AS decimal(28,2)) OverRunHours,
        TenantId,DefaultWorkingHours FROM 
	 (
	   select distinct E.Id AS  EmployeeId,E.FirstName,'P.H' AS Type,'CaseGroup' AS SystemType,'Chargeable' as ChargeType,TSK.StartDate,TSK.EndDate,
 	   RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tsk.Hours) + 60 *  DATEPART(MINUTE, tsk.Hours) + 3600 * DATEPART(HOUR, tsk.Hours )),0) / 3600 AS VARCHAR),2) + '.' +
       RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tsk.Hours) + 60 *  DATEPART(MINUTE, tsk.Hours) + 3600 * DATEPART(HOUR, tsk.Hours )),0) / 60) % 60 AS VARCHAR),2)As PlannedHours ,
	   RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tsk.IsOverRunHours) + 60 *  DATEPART(MINUTE, tsk.IsOverRunHours) + 3600 * DATEPART(HOUR, tsk.IsOverRunHours )),0) / 3600 AS VARCHAR),2) + '.' +
       RIGHT('0' + CAST(( isnull(sum(DATEPART(SECOND, tsk.IsOverRunHours) + 60 *  DATEPART(MINUTE, tsk.IsOverRunHours) + 3600 * DATEPART(HOUR, tsk.IsOverRunHours )),0) / 60) % 60 AS VARCHAR),2)As  OverRunHours,
       EE.TenantId AS TenantId,CC.DefaultWorkingHours
			from WorkFlow.ScheduleTask tsk
		 inner join WorkFlow.CaseGroup CG on tsk.CaseId = CG.Id
		inner join Common.Employee E on tsk.EmployeeId = E.Id  
		 --Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		 --LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		          INNER JOIN Common.Company EE ON EE.Id=tsk.CompanyId
				  INNER JOIN Common.Localization CC ON CC.CompanyId=tsk.CompanyId 
		where  tsk.Status=1
			Group by E.FirstName,tsk.StartDate,tsk.Enddate,E.Id,e.EmployeeId ,EE.TenantId ,CC.DefaultWorkingHours
	
	    union all
	------------------------- TimeLogItem.SystemType='LeaveApplication'=1

 		 select 	distinct  E.Id AS  EmployeeId,E.FirstName,'P.H'as Type,'LeaveApplication' AS SystemType,'Non-Working' as ChargeType,TLI.Startdate,TLI.Enddate, 
		CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) ActHours,'00.00' AS OverRunHours 
	    ,ee.TenantId,CC.DefaultWorkingHours
		from  Common.TimeLogItem TLI
		inner join Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		inner join Common.Employee E on E.Id = TLD.EmployeeId 
		 --Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		 -- LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		 LEFT join hr.LeaveApplication as La on La.Id=TLI.SystemId
		          INNER JOIN Common.Company EE ON EE.Id=TLI.CompanyId
				  INNER JOIN Common.Localization CC ON CC.CompanyId=TLI.CompanyId 

		where  TLI.IsSystem=1 and TLI.SystemType='LeaveApplication' and TLI.Status=1 and La.leavestatus in ('Submitted','Recommended','Approved','For Cancellation')
		Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId ,EE.TenantId ,CC.DefaultWorkingHours

		union all
		------------------------ TimeLogItem.SystemType='Calender'=2


        	 select 	distinct  E.Id AS  EmployeeId,E.FirstName,'P.H'as Type,'Calender' AS SystemType,'Non-Working' as ChargeType,TLI.Startdate,TLI.Enddate, 
		CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) ActHours,'00.00' AS OverRunHours 
	    ,ee.TenantId,CC.DefaultWorkingHours
		from  Common.TimeLogItem TLI
		inner join Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		inner join Common.Employee E on E.Id = TLD.EmployeeId 
		 --Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		 -- LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		  INNER JOIN Common.Company EE ON EE.Id=TLI.CompanyId
				  INNER JOIN Common.Localization CC ON CC.CompanyId=TLI.CompanyId 
		where  TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=0 and  TLI.IsMain=0
		Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId ,EE.TenantId ,CC.DefaultWorkingHours

			union all
		------------------------ TimeLogItem.SystemType='Calender'=2


       select 	distinct  E.Id AS  EmployeeId,E.FirstName,'P.H'as Type,'Calender' AS SystemType,'Non-Working' as ChargeType,TLI.Startdate,TLI.Enddate, 
		CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) ActHours,'00.00' AS OverRunHours 
	    ,ee.TenantId,CC.DefaultWorkingHours
		from  Common.TimeLogItem TLI
		inner join Common.Employee E on E.CompanyId = TLI.CompanyId
		 --Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		 -- LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		 		  INNER JOIN Common.Company EE ON EE.Id=TLI.CompanyId
				  INNER JOIN Common.Localization CC ON CC.CompanyId=TLI.CompanyId 
		where  TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and  TLI.IsMain=0
		Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId ,EE.TenantId ,CC.DefaultWorkingHours
	 
	  union all
	 
	 select 	distinct E.Id AS  EmployeeId,E.FirstName,  'A.H'as Type,'CaseGroup' AS SystemType,'Chargeable' as ChargeType,TLD.Date as Startdate,t.Enddate, 
		 RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
         RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2)As ActHours,'00.00' AS OverRunHours 
	    ,ee.TenantId,CC.DefaultWorkingHours
	     FROM Common.TimeLog T
		 INNER JOIN Common.TimeLogDetail TLD ON T.Id=TLD.MasterId
		 INNER JOIN Common.TimeLogItem TLI ON TLI.Id=T.TimeLogItemId
		 left JOIN WorkFlow.CaseGroup C on TLI.SystemId = C.Id
		 INNER JOIN Common.Employee E on T.EmployeeId = E.Id  
		--INNER Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
        --INNER join Common.Department D  ON D.ID=HR.DepartmentId
       --INNER join Common.DepartmentDesignation DD ON DD.ID=HR.DepartmentDesignationId
	     INNER JOIN Common.Company EE ON EE.Id=C.CompanyId
		 		 INNER JOIN Common.Localization CC ON CC.CompanyId=C.CompanyId 
	     where T.Status=1 AND SystemType='CaseGroup' and TLI.ChargeType='Chargeable'  AND t.Status=1   AND TLD.Duration <> '00:00:00.0000000'
		 --and E.FirstName='Aprianti'
		 --and TLD.Date between '2019-03-31 00:00:00.0000000' and '2019-04-06 00:00:00.0000000'

         group by  EE.TenantId ,E.Id ,E.FirstName,t.Enddate,TLD.Date,CC.DefaultWorkingHours
		  --order by  TLD.Date

		 union all

		 	 select 	distinct E.Id AS  EmployeeId,E.FirstName,'A.H'as Type,'Calender' AS SystemType,'Non-Chargeable' as ChargeType,T.Startdate,t.Enddate, 
		CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) ActHours,'00.00' AS OverRunHours 
	    ,ee.TenantId,C.DefaultWorkingHours
	     FROM Common.TimeLog T
		 INNER JOIN Common.TimeLogDetail TLD ON T.Id=TLD.MasterId
		 INNER JOIN Common.TimeLogItem TLI ON TLI.Id=T.TimeLogItemId
		 --left JOIN WorkFlow.CaseGroup C on TLI.SystemId = C.Id
		 INNER JOIN Common.Employee E on T.EmployeeId = E.Id  
		--INNER Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
        --INNER join Common.Department D  ON D.ID=HR.DepartmentId
       --INNER join Common.DepartmentDesignation DD ON DD.ID=HR.DepartmentDesignationId
	     INNER JOIN Common.Company EE ON EE.Id=TLI.CompanyId
		 		 INNER JOIN Common.Localization C ON C.CompanyId=TLI.CompanyId 
	     where  T.Status=1 AND TLI.ChargeType='Non-Chargeable' AND TLI.SystemType='Calender'  and TLI.hours<>'0.00' 
		 --and E.FirstName='Aprianti'
		 --and T.Startdate between '2019-03-31 00:00:00.0000000' and '2019-04-06 00:00:00.0000000'


         group by  EE.TenantId ,E.Id ,E.FirstName,T.Startdate,t.Enddate,C.DefaultWorkingHours


		
		 UNION ALL

		 	 select 	distinct E.Id AS  EmployeeId,E.FirstName,'A.H'as Type,'Time Log Item' AS SystemType,'Non-Chargeable' as ChargeType,TLD.Date AS StartDate,t.Enddate, 
		 RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
         RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2)As ActHours,'00.00' AS OverRunHours 
	    ,ee.TenantId,C.DefaultWorkingHours
	     FROM Common.TimeLog T
		 INNER JOIN Common.TimeLogDetail TLD ON T.Id=TLD.MasterId
		 INNER JOIN Common.TimeLogItem TLI ON TLI.Id=T.TimeLogItemId
		 --left JOIN WorkFlow.CaseGroup C on TLI.SystemId = C.Id
		 INNER JOIN Common.Employee E on T.EmployeeId = E.Id  
		--INNER Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
        --INNER join Common.Department D  ON D.ID=HR.DepartmentId
       --INNER join Common.DepartmentDesignation DD ON DD.ID=HR.DepartmentDesignationId
	     INNER JOIN Common.Company EE ON EE.Id=TLI.CompanyId
		 		 INNER JOIN Common.Localization C ON C.CompanyId=TLI.CompanyId 
	     where  T.Status=1 AND TLI.ChargeType='Non-Chargeable' AND TLI.SystemType='Time Log Item'  AND tld.Duration <> '00:00:00.0000000' 
		 --and E.FirstName='Aprianti'
		 --and TLD.Date between '2019-03-31 00:00:00.0000000' and '2019-04-06 00:00:00.0000000'


         group by  EE.TenantId ,E.Id ,E.FirstName,TLD.Date,t.Enddate,C.DefaultWorkingHours

		  	 union all

		 		 select 	distinct  E.Id AS  EmployeeId,E.FirstName,'A.H'as Type,'Calender' AS SystemType,'Non-Working' as ChargeType,TLI.Startdate,TLI.Enddate, 
		CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) ActHours,'00.00' AS OverRunHours 
	    ,ee.TenantId,C.DefaultWorkingHours
	     FROM Common.TimeLogItem TLI
		 --INNER JOIN Common.TimeLogItemDetail TLD ON TLD.TimeLogItemId=TLI.Id
		 --left JOIN WorkFlow.CaseGroup C on TLI.SystemId = C.Id
		 INNER JOIN Common.Employee E on TLI.CompanyId = E.CompanyId
		--INNER Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
        --INNER join Common.Department D  ON D.ID=HR.DepartmentId
       --INNER join Common.DepartmentDesignation DD ON DD.ID=HR.DepartmentDesignationId
	     INNER JOIN Common.Company EE ON EE.Id=TLI.CompanyId
		 		 INNER JOIN Common.Localization C ON C.CompanyId=TLI.CompanyId 
	     where   TLI.ChargeType IN ('Non-Available','Non-Working') AND TLI.SystemType='Calender'  and TLI.hours<>'0.00' 
		 and tli.Status=1 AND TLI.ApplyToAll=1 AND IsMain=0
	--and  FirstName='Aprianti' and StartDate between '2019-10-27 00:00:00.0000000' and '2019-11-02 00:00:00.0000000'
	
         group by  EE.TenantId ,E.Id ,E.FirstName,TLI.Startdate,TLI.Enddate,C.DefaultWorkingHours


		 		 UNION ALL

		 	 select 	distinct E.Id AS  EmployeeId,E.FirstName,'A.H'as Type,'Time Log Item' AS SystemType,'Non-Working' as ChargeType,TLD.Date AS StartDate,t.Enddate, 
		 RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
         RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2)As ActHours,'00.00' AS OverRunHours 
	    ,ee.TenantId,C.DefaultWorkingHours
	     FROM Common.TimeLog T
		 INNER JOIN Common.TimeLogDetail TLD ON T.Id=TLD.MasterId
		 INNER JOIN Common.TimeLogItem TLI ON TLI.Id=T.TimeLogItemId
		 --left JOIN WorkFlow.CaseGroup C on TLI.SystemId = C.Id
		 INNER JOIN Common.Employee E on T.EmployeeId = E.Id  
		--INNER Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
        --INNER join Common.Department D  ON D.ID=HR.DepartmentId
       --INNER join Common.DepartmentDesignation DD ON DD.ID=HR.DepartmentDesignationId
	     INNER JOIN Common.Company EE ON EE.Id=TLI.CompanyId
		 		 INNER JOIN Common.Localization C ON C.CompanyId=TLI.CompanyId 
	     where  T.Status=1 AND TLI.ChargeType in ('Non-Available','Non-Working')  AND TLI.SystemType='Time Log Item'  AND tld.Duration <> '00:00:00.0000000' 
		 --and E.FirstName='Aprianti'
		 --and TLD.Date between '2019-03-31 00:00:00.0000000' and '2019-04-06 00:00:00.0000000'


         group by  EE.TenantId ,E.Id ,E.FirstName,TLD.Date,t.Enddate,C.DefaultWorkingHours


		 		  	 union all
	 	 select 	distinct E.Id AS  EmployeeId,E.FirstName,'A.H'as Type,'LeaveApplication' AS SystemType,'Non-Working' as ChargeType,TLI.Startdate,TLI.Enddate, 
		CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) ActHours,'00.00' AS OverRunHours 
	    ,ee.TenantId,C.DefaultWorkingHours
	     FROM Common.TimeLogItem TLI 
		 INNER JOIN Common.TimeLogItemDetail TLD ON TLD.TimeLogItemId=TLI.Id
		 --INNER JOIN Common.TimeLogItem TLI ON TLI.Id=T.TimeLogItemId
		 Inner JOIN hr.LeaveApplication as La on La.Id=TLI.SystemId
		 --left JOIN WorkFlow.CaseGroup C on TLI.SystemId = C.Id
		 INNER JOIN Common.Employee E on TLD.EmployeeId = E.Id  
		--INNER Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
        --INNER join Common.Department D  ON D.ID=HR.DepartmentId
       --INNER join Common.DepartmentDesignation DD ON DD.ID=HR.DepartmentDesignationId
	     INNER JOIN Common.Company EE ON EE.Id=TLI.CompanyId
		 INNER JOIN Common.Localization C ON C.CompanyId=TLI.CompanyId 
	     where   TLI.ChargeType ='Non-Available' AND TLI.SystemType ='LeaveApplication'  AND LA.LeaveStatus IN ('Approved','For Cancellation') and TLI.hours<>'0.00' 
		 --and E.FirstName='Aprianti'
		 --and TLI.Startdate between '2019-09-29 00:00:00.0000000' and '2019-10-05 00:00:00.0000000'
		      group by  EE.TenantId ,E.Id ,E.FirstName,TLI.Startdate,TLI.Enddate,C.DefaultWorkingHours

          )GG
		-- where FirstName like '%Tan Khoon Guan%' and StartDate between '2019-08-09' and '2019-08-09' --and Type='A.H'
		 --ORDER BY Startdate 
		 )as AA
		 pivot
		 (
		 sum(TotalHours) for ChargeType in ([Chargeable],[Non-Chargeable],[Non-Working])
		 )As pivottable
		 Group by  EmployeeId,FirstName,Type, SystemType,StartDate,EndDate,[Chargeable],[Non-Chargeable],[Non-Working],OverRunHours, TenantId,DefaultWorkingHours,Types


		 )as BB
		 
		 --where TenantId='A8628250-BB08-401D-BFA2-EFAE351FEDDD' and FirstName like '%Tan Khoon Guan%' --and StartDate between '2019-08-04' and '2019-08-10'
		 --and Type='A.H'
		 Group by  EmployeeId,FirstName,Type, SystemType,StartDate,EndDate,[Chargeable],[Non-Chargeable],[Non-Working],OverRunHours, TenantId,DefaultWorkingHours,Types
		 )as CC
		-- order by StartDate
		 END
GO
