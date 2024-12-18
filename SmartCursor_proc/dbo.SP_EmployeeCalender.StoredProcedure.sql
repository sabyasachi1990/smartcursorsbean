USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_EmployeeCalender]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_EmployeeCalender]( @FROMDATE DATETIME, @TODATE DATETIME, @COMPANYID BIGINT,
 @USERNAME NVARCHAR(500))  
AS   
 BEGIN   
 ---------------------------------**********************BEGIN************* --------------------------------------------------  
 ---------------------AUTHOR ------------****SREENIVSULU G****----------**24-12-2016**----------------------------------------  
  DECLARE @EMPLOYEEID UNIQUEIDENTIFIER  
  DECLARE @EMPLOYEENAME NVARCHAR(1000)  
  SET @EMPLOYEEID = (SELECT Top 1 id FROM [Common].[Employee] WHERE COMPANYID=@COMPANYID AND USERNAME=@USERNAME)  
  SET @EMPLOYEENAME = (SELECT Top 1 FirstName FROM [Common].[Employee] WHERE COMPANYID=@COMPANYID AND USERNAME=@USERNAME)  
  DECLARE @STARTDATE DATETIME =@FROMDATE  
  DECLARE @ENDDATE DATETIME=@TODATE  
  DECLARE @CNT INT = 0  
  DECLARE @TABLE TABLE (ID INT IDENTITY (1, 1), DT DATE, DTNAME VARCHAR (100))   
  WHILE @STARTDATE < = @ENDDATE  
  BEGIN  
  IF DATENAME (WEEKDAY, @STARTDATE) IN ('SATURDAY', 'SUNDAY','MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY')  
  INSERT INTO @TABLE  
  VALUES (@STARTDATE, DATENAME(WEEKDAY, @STARTDATE))   
  SET @STARTDATE = DATEADD(D, 1, @STARTDATE)  
  END  
  
 ----------------------------------------------===================================----------------------------------------  
  DECLARE @OUTPUT TABLE (CompanyId BIGINT,TaskId UNIQUEIDENTIFIER NULL,CaseId  UNIQUEIDENTIFIER NULL,TimeLogItemId  UNIQUEIDENTIFIER NULL,  
    Type NVARCHAR(100),Title  NVARCHAR(500),TaskName  NVARCHAR(500),Hours DECIMAL(10,2) DEFAULT (0),Fromdate DATETIME2(7) ,  
    Todate  DATETIME2(7),StartDate  DATETIME2(7) NULL,EndDate  DATETIME2(7) NULL,EmployeeId UNIQUEIDENTIFIER ,  
    EmployeeName  NVARCHAR(1000), Status BIT,Remarks  NVARCHAR(1000),RecOrder  INT DEFAULT (1),UserCreated  NVARCHAR(500),  
    CreatedDate DATETIME2(7) NULL,ModifiedBy   NVARCHAR(500),ModifiedDate DATETIME2(7) NULL,RecordStatus  NVARCHAR(1000),IsSystem BIT,IsOverRun BIT,IsOverRunHours time null)  
  
 ----------------------------------CASE SCHEDULE TASK------------------------------------------------------  
  
  INSERT INTO @OUTPUT(CompanyId ,TaskId ,CaseId  ,TimeLogItemId  ,Type ,Title  ,TaskName  ,Hours,   Fromdate  ,Todate  ,StartDate ,  
       EndDate  ,EmployeeId ,EmployeeName  ,Status,Remarks,RecOrder  ,UserCreated  ,CreatedDate,ModifiedBy  ,  
       ModifiedDate ,RecordStatus  ,IsSystem,IsOverRun,IsOverRunHours) -- ,IsOverRunHours time null
    
    SELECT S.CompanyId,s.Id,c.Id,NULL,C.SystemRefNo,CL.Name,  S.Title, (SUM(DATEDIFF(MINUTE,0,S.HOURS))/60)+(SUM(DATEDIFF(MINUTE,0,S.HOURS))%60.0)/100   AS HOURS,CONVERT(DATE,  S.StartDate),CONVERT(DATE,  S.EndDate),  
       CONVERT(DATE,  S.StartDate),CONVERT(DATE,  S.EndDate), @EMPLOYEEID,@EMPLOYEENAME,1, S.Remarks,   
       S.RecOrder, S.UserCreated,S.CreatedDate, S.ModifiedBy, S.ModifiedDate,ci.Name,1 ,S.IsOverRun,
	  case when s.IsOverRunHours  is null then '00:00:00' ELSE s.IsOverRunHours end as 'IsOverRunHours'
      FROM [WorkFlow].[Client] CL	   
	  JOIN [WorkFlow].[CaseGroup] C   ON CL.Id=C.ClientId
     JOIN  [WorkFlow].[ScheduleTask] S ON C.Id=S.CaseId   
  join Common.Company ci on c.ServiceCompanyId = ci.Id  
      WHERE S.EmployeeId = @EMPLOYEEID   
      AND S.CompanyId=@COMPANYID  
      AND S.StartDate<=@TODATE  
      AND S.EndDate >=@FROMDATE  
   AND S.IsOverRun!=1--IsOverRun  
     GROUP BY S.CompanyId,C.SystemRefNo, S.Title,C.SystemRefNo, S.StartDate,S.EndDate,  S.Remarks,  
      S.RecOrder, S.UserCreated, S.CreatedDate, S.ModifiedBy, S.ModifiedDate,S.IsOverRun,c.Id,ci.Name,s.IsOverRunHours,s.Id,Cl.name 
 -----------------------------------Time Log Item---------------------------------------------------------------  
  INSERT INTO @OUTPUT(CompanyId ,TaskId ,CaseId  ,TimeLogItemId  ,Type ,Title  ,TaskName  ,Hours,   Fromdate  ,Todate  ,StartDate ,  
       EndDate  ,EmployeeId ,EmployeeName  ,Status,Remarks,RecOrder  ,UserCreated  ,CreatedDate,ModifiedBy  ,  
       ModifiedDate ,RecordStatus  ,IsSystem,IsOverRun)  
   
  select CompanyId ,newid() ,CaseId  ,TimeLogItemId  ,Type ,Title  ,TaskName  ,Hours,   Fromdate  ,Todate  ,StartDate ,  
       EndDate  ,EmployeeId ,EmployeeName  ,Status,Remarks,RecOrder  ,UserCreated  ,CreatedDate,ModifiedBy  ,  
       ModifiedDate ,RecordStatus  ,IsSystem, null from 
	   (	   
	   select CompanyId ,newid() as TaskId ,CaseId  ,TimeLogItemId  ,Type ,Title  ,  TaskName,
    case when DaysPoints='0.00' THEN
	 CASE WHEN StartingDate > Todate THEN '0.00' WHEN StartingDate = EndingDate THEN
			    CASE WHEN StartingDate between FromDate and Todate THEN (datediff(DAY,StartingDate,EndingDate)+1) *Hourspercent
					 ELSE '0.00' END
					 WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *Hourspercent  
					 WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
				CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00'
				ELSE (datediff(DAY,FromDate,EndingDate)+1) *Hourspercent END
					 WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *Hourspercent
					 WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *Hourspercent
				END
				ELSE 
				 CASE WHEN StartingDate > Todate THEN '0.00' WHEN StartingDate  = Fromdate
	and EndingDate=Todate then (datediff(DAY,StartingDate,EndingDate)) 
  *Hourspercent + DaysPoints * Hourspercent WHEN StartingDate = EndingDate THEN
  CASE WHEN StartingDate between FromDate and Todate THEN (datediff(DAY,StartingDate,EndingDate)) 
  *Hourspercent + DaysPoints * Hourspercent
  ELSE '0.00' END
  WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *Hourspercent  
  WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
  CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00' 
  ELSE (datediff(DAY,FromDate,EndingDate)) *Hourspercent + DaysPoints * Hourspercent END
  WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *Hourspercent
  WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *Hourspercent
  END END as 'Hours',    Fromdate  ,Todate  ,StartDate ,  
         EndDate  ,EmployeeId ,EmployeeName  ,Status,Remarks,RecOrder  ,UserCreated  ,CreatedDate,ModifiedBy  ,  
         ModifiedDate ,RecordStatus  ,IsSystem,0 as  IsOverRun
       from  
     (    
     select  CompanyId ,TaskId ,CaseId  ,TimeLogItemId  ,Type ,Title  ,TaskName  ,Hours, pp.CreatedDate as Fromdate   
      ,pp.CreatedDate as  Todate  ,pp.CreatedDate as StartDate ,  
       pp.CreatedDate as  EndDate  ,EmployeeId ,EmployeeName  ,Status,Remarks,RecOrder  ,UserCreated  ,  
       p.CreatedDate,ModifiedBy  , cast(StartDate as Date) as 'startingDate',cast(EndDate as Date) as 'EndingDate', 
         ModifiedDate ,RecordStatus  ,IsSystem,Days,  
     '0.'+SUBSTRING(CAST(Days AS VARCHAR(20)), CHARINDEX('.', CAST(Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints',  
     isnull(nullif(hours,0)/nullif(Days,0),0) as'Hourspercent'  
     From   
     (  
     select TI.CompanyId,Newid() as TaskId,  
     '00000000-0000-0000-0000-000000000000' as 'CaseId',Ti.Id as TimeLogItemId,  
     StartDate,EndDate,TI.Hours,Ti.Days,Type,SystemType as Title,  
     SubType as 'TaskName',E.Id as 'EmployeeId',e.FirstName as 'EmployeeName',  
     TI.Status,TI.Remarks,TI.RecOrder  ,TI.UserCreated  ,TI.CreatedDate,TI.ModifiedBy  ,  
     TI.ModifiedDate ,'Added'as RecordStatus  ,TI.IsSystem  
      FROM Common.TimeLogItem as TI  
     INNER JOIN Common.TimeLogItemDetail as TD on Td.TimeLogItemId=TI.Id  
     INNER JOIN Common.Employee as E ON E.Id=Td.EmployeeId 
	 LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id  
     where SystemType not in ('CaseGroup','WorkWeekSetup')
       AND  TD.EmployeeId = @EMPLOYEEID   
       AND TI.CompanyId=@COMPANYID  
       AND TI.StartDate<=@TODATE  
       AND TI.EndDate >=@FROMDATE 
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
			  not in ('Approve Cancelled','Rejected','Cancelled') 

 UNION ALL
	    select TI.CompanyId,Newid() as TaskId,  
     '00000000-0000-0000-0000-000000000000' as 'CaseId',Ti.Id as TimeLogItemId,  
     StartDate,EndDate,Ti.Hours,TI.Days,Type,SystemType as Title,  SubType as 'TaskName'
     ,R.Employeeid as 'EmployeeId',R.FirstName as 'EmployeeName',  
     TI.Status,TI.Remarks,TI.RecOrder  ,TI.UserCreated  ,TI.CreatedDate,TI.ModifiedBy  ,  
     TI.ModifiedDate ,'Added'as RecordStatus  ,TI.IsSystem  
      FROM Common.TimeLogItem as TI  
	  LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id 
	    CROSS JOIN
	(
	select E.FirstName,E.Id as 'Employeeid',  
          E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL'  from Common.Employee as E
		   INNER JOIN HR.LeaveApplication LA ON E.Id=La.EmployeeId
		   INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
		   INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
		   INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
		   LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
	 where E.CompanyId=@COMPANYID AND LA.LeaveStatus not in ('Rejected','ApproveCancelled','Cancelled')
	) as R	 
	    where  SystemType not in ('CaseGroup','WorkWeekSetup') 
	 and ApplyToAll=1
       AND R.Employeeid = @EMPLOYEEID  	
       AND TI.CompanyId=@COMPANYID  
       AND TI.StartDate<=@TODATE  
       AND TI.EndDate >=@FROMDATE   
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
			  not in ('Approve Cancelled','Rejected','Cancelled')
     ) as P  
     cross Join  
     (  
     SELECT  TOP (DATEDIFF(DAY, @FromDate, @Todate) + 1)  
       CreatedDate = convert(Date,DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @FromDate))  
       FROM    sys.all_objects a  
       CROSS JOIN sys.all_objects b  
     ) AS PP  
     where case when StartDate > PP.CreatedDate then null  
     when  EndDate < PP.CreatedDate then null  
     ELSE pp.CreatedDate END is not null  
     ) AS P  
	 	   where  case when CAST(startingDate as date)> Fromdate then null
	  when cast(EndingDate as date) < Fromdate then null
	  ELSE Fromdate END is not null
UNION ALL
	   select CompanyId ,TaskId ,CaseId  ,TimeLogItemId  ,Type ,Title  , TaskName  ,
    case when DaysPoints='0.00' THEN
	 CASE WHEN StartingDate > Todate THEN '0.00' WHEN StartingDate = EndingDate THEN
			    CASE WHEN StartingDate between FromDate and Todate THEN (datediff(DAY,StartingDate,EndingDate)+1) *Hourspercent
					 ELSE '0.00' END
					 WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *Hourspercent  
					 WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
				CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00'
				ELSE (datediff(DAY,FromDate,EndingDate)+1) *Hourspercent END
					 WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *Hourspercent
					 WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *Hourspercent
				END
				ELSE 
				 CASE WHEN StartingDate > Todate THEN '0.00' WHEN StartingDate  = Fromdate
	and EndingDate=Todate then (datediff(DAY,StartingDate,EndingDate)) 
  *Hourspercent + DaysPoints * Hourspercent WHEN StartingDate = EndingDate THEN
  CASE WHEN StartingDate between FromDate and Todate THEN (datediff(DAY,StartingDate,EndingDate)) 
  *Hourspercent + DaysPoints * Hourspercent
  ELSE '0.00' END
  WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *Hourspercent  
  WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
  CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00' 
  ELSE (datediff(DAY,FromDate,EndingDate)) *Hourspercent + DaysPoints * Hourspercent END
  WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *Hourspercent
  WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *Hourspercent
  END  END as 'Hours', Fromdate  ,Todate  ,StartDate ,  
         EndDate  ,EmployeeId ,EmployeeName  ,Status,Remarks,RecOrder  ,UserCreated  ,CreatedDate,ModifiedBy  ,  
         ModifiedDate ,RecordStatus  ,IsSystem,0  
       from  
     (    
     select  CompanyId ,TaskId ,CaseId  ,TimeLogItemId  ,Type ,Title  ,TaskName  ,Hours, pp.CreatedDate as Fromdate   
      ,pp.CreatedDate as  Todate  ,pp.CreatedDate as StartDate ,  
       pp.CreatedDate as  EndDate  ,EmployeeId ,EmployeeName  ,Status,Remarks,RecOrder  ,UserCreated  ,  
       p.CreatedDate,ModifiedBy  ,  cast(StartDate as Date) as 'startingDate',cast(EndDate as Date) as 'EndingDate', 
         ModifiedDate ,RecordStatus  ,IsSystem,Days,  
     '0.'+SUBSTRING(CAST(Days AS VARCHAR(20)), CHARINDEX('.', CAST(Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints',  
     isnull(nullif(hours,0)/nullif(Days,0),0) as'Hourspercent'  
     From   
     (  
 select TI.CompanyId,Newid() as TaskId,  
     '00000000-0000-0000-0000-000000000000' as 'CaseId',Ti.Id as TimeLogItemId,  
     StartDate,EndDate,Ti.Hours,TI.Days,Type,SystemType as Title,  
     SubType as 'TaskName',E.Employeeid as 'EmployeeId',e.FirstName as 'EmployeeName',  
     TI.Status,TI.Remarks,TI.RecOrder  ,TI.UserCreated  ,TI.CreatedDate,TI.ModifiedBy  ,  
     TI.ModifiedDate ,'Added'as RecordStatus  ,TI.IsSystem  
      FROM Common.TimeLogItem as TI  
	  LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id 
	 CROSS JOIN
	(
	select E.FirstName,E.Id as 'Employeeid',  
          E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL'  from Common.Employee as E
	 INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
      INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
      INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
      LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
	where E.CompanyId=@COMPANYID
	) as E
	     where  SystemType not in ('CaseGroup','WorkWeekSetup')
	 and ApplyToAll=1
       AND E.Employeeid = @EMPLOYEEID   
       AND TI.CompanyId=@COMPANYID  
       AND TI.StartDate<=@TODATE  
       AND TI.EndDate >=@FROMDATE 
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
			  not in ('Approve Cancelled','Rejected','Cancelled')  

UNION ALL
	    select TI.CompanyId,Newid() as TaskId,  
     '00000000-0000-0000-0000-000000000000' as 'CaseId',Ti.Id as TimeLogItemId,  
     StartDate,EndDate,TI.Hours,TI.Days,Type,SystemType as Title,SubType as 'TaskName'
     ,R.Employeeid as 'EmployeeId',R.FirstName as 'EmployeeName',  
     TI.Status,TI.Remarks,TI.RecOrder  ,TI.UserCreated  ,TI.CreatedDate,TI.ModifiedBy  ,  
     TI.ModifiedDate ,'Added'as RecordStatus  ,TI.IsSystem  
      FROM Common.TimeLogItem as TI  
	  LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id 
	    CROSS JOIN
	(
	select E.FirstName,E.Id as 'Employeeid',  
          E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL'  from Common.Employee as E
		   INNER JOIN HR.LeaveApplication LA ON E.Id=La.EmployeeId
		   INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
		   INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
		   INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
		   LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
	 where E.CompanyId=@COMPANYID AND LA.LeaveStatus not in ('Rejected','ApproveCancelled','Cancelled')
	) as R	 
	    where  SystemType not in ('CaseGroup','WorkWeekSetup')
	 and ApplyToAll=1
       AND R.Employeeid = @EMPLOYEEID  	
       AND TI.CompanyId=@COMPANYID  
       AND TI.StartDate<=@TODATE  
       AND TI.EndDate >=@FROMDATE 
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
			  not in ('Approve Cancelled','Rejected','Cancelled')  

     ) as P  
     cross Join  
     (  
     SELECT  TOP (DATEDIFF(DAY, @FromDate, @Todate) + 1)  
       CreatedDate = convert(Date,DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @FromDate))  
       FROM    sys.all_objects a  
       CROSS JOIN sys.all_objects b  
     ) AS PP  
     where case when StartDate > PP.CreatedDate then null  
     when  EndDate < PP.CreatedDate then null  
     ELSE pp.CreatedDate END is not null  
     ) AS P  
	 	   where  case when CAST(startingDate as date)> Fromdate then null
	  when cast(EndingDate as date) < Fromdate then null
	  ELSE Fromdate END is not null
	  )
	   as a
  
-----------------------------------Time Log Item---------------------------------------------------------------  
  
  
  SELECT * FROM @OUTPUT  
END  
















GO
