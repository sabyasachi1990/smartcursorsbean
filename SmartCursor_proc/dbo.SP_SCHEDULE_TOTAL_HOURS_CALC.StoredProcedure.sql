USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SCHEDULE_TOTAL_HOURS_CALC]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_SCHEDULE_TOTAL_HOURS_CALC](
	@FROMDATE DATE,
	@TODATE DATE,
	@COMPANYID BIGINT,
	@TYPE INT,
	@DESIGNATIONID UNIQUEIDENTIFIER,
	@DEPARTMENTID UNIQUEIDENTIFIER,
	@EMPLOYEEID UNIQUEIDENTIFIER)
AS
BEGIN
	BEGIN TRY
		DECLARE @EMPLOYEETABLE TABLE (EMPID UNIQUEIDENTIFIER, EMPNAME NVARCHAR(1000))
		DECLARE @TODAYDATE DATE = CONVERT(DATE, GETDATE())
		DECLARE @EMPLOYEE_ID_NEW UNIQUEIDENTIFIER 
		DECLARE @A  uniqueidentifier,@B uniqueidentifier,@C Datetime,@D Datetime,@P decimal(10,2)  
		 DECLARE @START_DATE DATE

		DECLARE @OUTPUT TABLE (EMPLOYEENAME NVARCHAR (1000), STARTDATE DATE,  ENDDATE DATE, TOTALMINUTES BIGINT,TOATLHOURS MONEY, TOTALOVERRUNMINUTES BIGINT,IsOverRunHours Money,EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(100),PHOTOURL NVARCHAR(1000), SystemId UNIQUEIDENTIFIER, SystemType nvarchar(100), IsActualHrs bit)

		BEGIN

			--INSERT INTO @EMPLOYEETABLE
			--SELECT DISTINCT E.ID, E.FIRSTNAME  FROM HR.EMPLOYEEDEPARTMENT ED 
			--JOIN COMMON.EMPLOYEE E ON E.ID = ED.EMPLOYEEID
			--WHERE ED.STATUS = 1 AND ((ED.ENDDATE >= @TODAYDATE OR ED.ENDDATE IS NULL) AND ED.EFFECTIVEFROM <= @TODAYDATE) AND 
			--E.COMPANYID = @COMPANYID AND E.ISHRONLY = 1  or ED.DepartmentId = (CASE WHEN @DEPARTMENTID IS NOT NULL THEN  @DEPARTMENTID ELSE NULL END)
			--OR ED.DepartmentDesignationId =(CASE WHEN @DESIGNATIONID IS NOT NULL THEN  @DESIGNATIONID ELSE NULL END) or ED.EmployeeId = (CASE WHEN @EMPLOYEEID IS NOT NULL THEN  @EMPLOYEEID ELSE NULL END) 
			
			IF((@DEPARTMENTID IS NULL) AND (@DESIGNATIONID IS NULL) AND (@EMPLOYEEID IS NULL))
			BEGIN
				INSERT INTO @EMPLOYEETABLE
				SELECT DISTINCT E.ID, E.FIRSTNAME  FROM HR.EMPLOYEEDEPARTMENT ED 
				JOIN COMMON.EMPLOYEE E ON E.ID = ED.EMPLOYEEID
				WHERE ED.STATUS = 1 AND ((ED.ENDDATE >= @TODAYDATE OR ED.ENDDATE IS NULL) AND ED.EFFECTIVEFROM <= @TODAYDATE) AND E.COMPANYID = @COMPANYID AND E.ISHRONLY = 1
			END
			else IF((@DEPARTMENTID IS NOT NULL) AND (@DESIGNATIONID IS NOT NULL) AND (@EMPLOYEEID IS NOT NULL))
			BEGIN
				INSERT INTO @EMPLOYEETABLE
				SELECT DISTINCT E.ID, E.FIRSTNAME  FROM HR.EMPLOYEEDEPARTMENT ED 
				JOIN COMMON.EMPLOYEE E ON E.ID = ED.EMPLOYEEID
				WHERE ED.STATUS = 1 AND ((ED.ENDDATE >= @TODAYDATE OR ED.ENDDATE IS NULL) AND ED.EFFECTIVEFROM <= @TODAYDATE) AND E.COMPANYID = @COMPANYID AND ED.DEPARTMENTID = @DEPARTMENTID AND ED.DepartmentDesignationId = @DESIGNATIONID AND ED.EmployeeId = @EMPLOYEE_ID_NEW AND E.ISHRONLY = 1
			END
			else IF (@DEPARTMENTID IS NOT NULL)
			BEGIN
				IF(@DESIGNATIONID IS NOT NULL)
				BEGIN
					INSERT INTO @EMPLOYEETABLE
					SELECT DISTINCT E.ID, E.FIRSTNAME  FROM HR.EMPLOYEEDEPARTMENT ED 
					JOIN COMMON.EMPLOYEE E ON E.ID = ED.EMPLOYEEID
					WHERE ED.STATUS = 1 AND ((ED.ENDDATE >= @TODAYDATE OR ED.ENDDATE IS NULL) AND ED.EFFECTIVEFROM <= @TODAYDATE) AND ED.DEPARTMENTID = @DEPARTMENTID AND ED.DepartmentDesignationId = @DESIGNATIONID AND E.COMPANYID = @COMPANYID AND E.ISHRONLY = 1
				END
				ELSE IF(@EMPLOYEEID IS NOT NULL)
				BEGIN
					INSERT INTO @EMPLOYEETABLE
					SELECT DISTINCT E.ID, E.FIRSTNAME  FROM HR.EMPLOYEEDEPARTMENT ED 
					JOIN COMMON.EMPLOYEE E ON E.ID = ED.EMPLOYEEID
					WHERE ED.STATUS = 1 AND ((ED.ENDDATE >= @TODAYDATE OR ED.ENDDATE IS NULL) AND ED.EFFECTIVEFROM <= @TODAYDATE) AND ED.DEPARTMENTID = @DEPARTMENTID AND ED.EmployeeId = @EMPLOYEE_ID_NEW AND E.COMPANYID = @COMPANYID AND E.ISHRONLY = 1
				END
				ELSE IF(@EMPLOYEEID IS NOT NULL AND @DESIGNATIONID IS NOT NULL)
				BEGIN
					INSERT INTO @EMPLOYEETABLE
					SELECT DISTINCT E.ID, E.FIRSTNAME  FROM HR.EMPLOYEEDEPARTMENT ED 
					JOIN COMMON.EMPLOYEE E ON E.ID = ED.EMPLOYEEID
					WHERE ED.STATUS = 1 AND ((ED.ENDDATE >= @TODAYDATE OR ED.ENDDATE IS NULL) AND ED.EFFECTIVEFROM <= @TODAYDATE) AND ED.DEPARTMENTID = @DEPARTMENTID AND ED.DepartmentDesignationId = @DESIGNATIONID AND ED.EmployeeId = @EMPLOYEE_ID_NEW AND E.COMPANYID = @COMPANYID AND E.ISHRONLY = 1
				END
				ELSE IF(@EMPLOYEEID IS NOT NULL AND @DESIGNATIONID IS NULL)
				BEGIN
					INSERT INTO @EMPLOYEETABLE
					SELECT DISTINCT E.ID, E.FIRSTNAME  FROM HR.EMPLOYEEDEPARTMENT ED 
					JOIN COMMON.EMPLOYEE E ON E.ID = ED.EMPLOYEEID
					WHERE ED.STATUS = 1 AND ((ED.ENDDATE >= @TODAYDATE OR ED.ENDDATE IS NULL) AND ED.EFFECTIVEFROM <= @TODAYDATE) AND ED.DEPARTMENTID = @DEPARTMENTID AND  ED.EmployeeId = @EMPLOYEE_ID_NEW AND E.COMPANYID = @COMPANYID AND E.ISHRONLY = 1
				END
				ELSE
				BEGIN
					INSERT INTO @EMPLOYEETABLE
					SELECT DISTINCT E.ID, E.FIRSTNAME  FROM HR.EMPLOYEEDEPARTMENT ED 
					JOIN COMMON.EMPLOYEE E ON E.ID = ED.EMPLOYEEID
					WHERE ED.STATUS = 1 AND ((ED.ENDDATE >= @TODAYDATE OR ED.ENDDATE IS NULL) AND ED.EFFECTIVEFROM <= @TODAYDATE) AND ED.DEPARTMENTID = @DEPARTMENTID AND E.COMPANYID = @COMPANYID AND E.ISHRONLY = 1
				END
			END
			ELSE IF (@DESIGNATIONID IS NOT NULL)
			BEGIN
				IF(@EMPLOYEEID IS NOT NULL)
				BEGIN
					INSERT INTO @EMPLOYEETABLE
					SELECT DISTINCT E.ID, E.FIRSTNAME  FROM HR.EMPLOYEEDEPARTMENT ED 
					JOIN COMMON.EMPLOYEE E ON E.ID = ED.EMPLOYEEID
					WHERE ED.STATUS = 1 AND ((ED.ENDDATE >= @TODAYDATE OR ED.ENDDATE IS NULL) AND ED.EFFECTIVEFROM <= @TODAYDATE) AND ED.DEPARTMENTID = @DEPARTMENTID AND ED.EmployeeId = @EMPLOYEE_ID_NEW AND E.COMPANYID = @COMPANYID AND E.ISHRONLY = 1
				END
				ELSE
				BEGIN
					INSERT INTO @EMPLOYEETABLE
					SELECT DISTINCT E.ID, E.FIRSTNAME  FROM HR.EMPLOYEEDEPARTMENT ED 
					JOIN COMMON.EMPLOYEE E ON E.ID = ED.EMPLOYEEID
					WHERE ED.STATUS = 1 AND ((ED.ENDDATE >= @TODAYDATE OR ED.ENDDATE IS NULL) AND ED.EFFECTIVEFROM <= @TODAYDATE) AND DEPARTMENTDESIGNATIONID=@DESIGNATIONID AND E.COMPANYID = @COMPANYID AND E.ISHRONLY = 1
				END
			END
			ELSE IF (@EMPLOYEEID IS NOT NULL)
			BEGIN
				INSERT INTO @EMPLOYEETABLE
				SELECT DISTINCT E.ID, E.FIRSTNAME  FROM HR.EMPLOYEEDEPARTMENT ED 
				JOIN COMMON.EMPLOYEE E ON E.ID = ED.EMPLOYEEID
				WHERE ED.STATUS = 1 AND ((ED.ENDDATE >= @TODAYDATE OR ED.ENDDATE IS NULL) AND ED.EFFECTIVEFROM <= @TODAYDATE) AND ED.EmployeeId = @EMPLOYEEID AND E.COMPANYID = @COMPANYID AND E.ISHRONLY = 1
			END				
			
		END
		--select * from @EMPLOYEETABLE
		DECLARE EMPLOYEE_CURSOR CURSOR FOR SELECT EMPID FROM @EMPLOYEETABLE
		OPEN EMPLOYEE_CURSOR
		FETCH NEXT FROM EMPLOYEE_CURSOR INTO @EMPLOYEE_ID_NEW
		WHILE(@@FETCH_STATUS = 0)
		BEGIN

			--DECLARE @START_DATE DATE
			DECLARE WORKWEEK_EMPLOYEE_HOURS_CURSOR CURSOR FOR SELECT * FROM FC_WORKWEEK(@FROMDATE,@TODATE)  
			OPEN WORKWEEK_EMPLOYEE_HOURS_CURSOR
			FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_CURSOR INTO @START_DATE
				WHILE @@FETCH_STATUS=0
				BEGIN  
				    declare @ToDate_New date = DATEADD(D, 6, @START_DATE)	
					INSERT INTO @OUTPUT (EMPLOYEENAME , STARTDATE,  ENDDATE, TOTALMINUTES ,TOATLHOURS , TOTALOVERRUNMINUTES ,IsOverRunHours ,EMPLOYEEID ,EMPLOYEEAUTONUMBER ,PHOTOURL, SystemId , SystemType , IsActualHrs)
					EXEC [SP_SCHEDULAR_TOTAL_HOURS_CALCULATION]  @COMPANYID=@COMPANYID,@W_FROMDATE=@START_DATE, @W_TODATE=@ToDate_New,@EMPLOYEEID=@EMPLOYEE_ID_NEW

					FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_CURSOR INTO @START_DATE
				END 
			CLOSE WORKWEEK_EMPLOYEE_HOURS_CURSOR
			DEALLOCATE WORKWEEK_EMPLOYEE_HOURS_CURSOR

			FETCH NEXT FROM EMPLOYEE_CURSOR INTO @EMPLOYEE_ID_NEW

		END 
		CLOSE EMPLOYEE_CURSOR
		DEALLOCATE EMPLOYEE_CURSOR

-------------------------------------- *********************************

--DECLARE @OUTPUT TABLE (EMPLOYEENAME NVARCHAR (1000), STARTDATE DATE,  ENDDATE DATE, TOTALMINUTES BIGINT,TOATLHOURS MONEY, TOTALOVERRUNMINUTES BIGINT,IsOverRunHours Money,EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(2000),PHOTOURL NVARCHAR(1000), SystemId UNIQUEIDENTIFIER, SystemType nvarchar(100), IsActualHrs bit)


BEGIN
INSERT INTO  @OUTPUT 

Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,0 as TOTALMINUTES ,sum(TotalHours) as 'TotalHours',0 as TOTALOVERRUNMINUTES,0 As IsOverRunHours,
Employeeid,Employeeautonumber,PHOTOURL ,NULL as SystemId, ' ' as SystemType, 1 as IsActualHrs
From 
(
Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
else coalesce(TotalHours,0) END as 'TotalHours',
Employeeid,Employeeautonumber,PHOTOURL,NULL as SystemId, ' ' as SystemType, 1 as IsActualHrs
	FROM 
	(
		SELECT distinct  FirstName,FromDate as 'StartDate',Todate as 'Enddate',startingdate,EndingDate,
		CASE WHEN StartingDate > Todate THEN '0.00' WHEN StartingDate = EndingDate THEN
		CASE WHEN StartingDate between FromDate and Todate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay
		ELSE '0.00' END
		WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay  
		WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
		CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00'
		ELSE (datediff(DAY,FromDate,EndingDate)+1) *HoursPerDay END
		WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *HoursPerDay
		WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *HoursPerDay
		END as 'TotalHours',
		Employeeid,Employeeautonumber,Null As PHOTOURL,NULL as SystemId, ' ' as SystemType, 1 as IsActualHrs
		FROM  
		(
			SELECT distinct E.FirstName,E.Id as 'Employeeid',
			E.EmployeeId as 'Employeeautonumber',--MR.Small as 'PHOTOURL',
			CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',
			CASE WHEN @ToDate < TI.EndDate THEN @ToDate ELSE TI.EndDate END  AS 'EndingDate',
			TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay' from
			Common.TimeLogItem as TI
			INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id
			INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId and E.IsHROnly=1
			INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID
			INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID 
			INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID 
			LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
			LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
			WHERE ApplyToAll <>1 and
			E.CompanyId=@CompanyId and
			TI.id= @A and
			E.Id= @B and
			-- EMPDEPT.DEPARTMENTID=@DEPARTMENTID and
			StartDate >=@FromDate and StartDate <=@ToDate
			and SystemType not in ('CaseGroup','WorkWeekSetup') 
			and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
			And TI.SystemType <> 'LeaveApplication'
		) AS P
		CROSS JOIN
		(
			SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate 
			FROM FC_WORKWEEK(@FROMDATE,@TODATE) 
		) AS PP
	) AS P
) AS P
Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL

--order by FirstName,StartDate
UNION ALL

Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,0 as TOTALMINUTES ,sum(TotalHours) as 'TotalHours',0 as TOTALOVERRUNMINUTES,0 As IsOverRunHours,
Employeeid,Employeeautonumber,PHOTOURL ,NULL as SystemId, ' ' as SystemType, 1 as IsActualHrs
From 
(
Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
else coalesce(TotalHours,0) END as 'TotalHours',
Employeeid,Employeeautonumber,PHOTOURL, NULL as SystemId, ' ' as SystemType, 1 as IsActualHrs
FROM 
(
SELECT distinct  FirstName,FromDate as 'StartDate',Todate as 'Enddate',startingdate,EndingDate,
CASE WHEN StartingDate > Todate THEN '0.00'
WHEN StartingDate = EndingDate THEN
CASE WHEN StartingDate between FromDate and Todate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay
ELSE '0.00' END
WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay  
WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00'
ELSE (datediff(DAY,FromDate,EndingDate)+1) *HoursPerDay END
WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *HoursPerDay
WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *HoursPerDay
END as 'TotalHours',
Employeeid,Employeeautonumber,PHOTOURL,NULL as SystemId, ' ' as SystemType, 1 as IsActualHrs
FROM  
(
SELECT distinct  
CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',  
CASE WHEN @ToDate < TI.EndDate THEN @ToDate ELSE TI.EndDate END  AS 'EndingDate',  
TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(Ti.Days,0),0) as 'HoursPerDay' from  
Common.TimeLogItem as TI 
LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id 
	   
WHERE  ApplyToAll=1 and
TI.CompanyId=@CompanyId and  
TI.id= @A and  
StartDate >=@FromDate and StartDate <=@ToDate
and SystemType not in ('CaseGroup','WorkWeekSetup')
and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
And TI.SystemType <> 'LeaveApplication'
) AS P  
CROSS JOIN  
(  
SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate   
FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
) AS PP 
CROSS JOIN
(
select E.FirstName,E.Id as 'Employeeid',  
E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL' 
From Common.Employee as E
INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
where E.CompanyId=@CompanyId and E.IsHROnly=1
and E.Id= @B 
--and  
--  EMPDEPT.DEPARTMENTID=@DEPARTMENTID   
) as A
) AS P
) AS P
Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL
--order by FirstName,StartDate
END

-------------------------------------- *********************************

		--Select EMPLOYEENAME, STARTDATE,  ENDDATE, (TOTALMINUTES / 60 + (TOTALMINUTES % 60) / 100.0) AS TOATLHOURS1,TOATLHOURS, (TOTALOVERRUNMINUTES / 60 + (TOTALOVERRUNMINUTES % 60) / 100.0) AS ISOVERRUNHOURS,EMPLOYEEID,EMPLOYEEAUTONUMBER ,PHOTOURL, SystemId, SystemType, IsActualHrs
		--From @OUTPUT

		--------------------------------------------

		
----Exec [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_Both] '2018-10-28 00:00:00' ,'2018-12-01 00:00:00',1,'{ea0d8440-07ae-4e0a-99c0-1ac072432549}'
--Exec [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_Both] @FROMDATE ,@TODATE,@COMPANYID,@EMPLOYEEID -- Added By Nagendra

If @EMPLOYEEID Is Not null
Begin
    
	
		 DECLARE  @Puja  TABLE (id uniqueidentifier, Employeeid uniqueidentifier,FromDate datetime,ToDate Datetime,hours decimal(10,2))  
  --DECLARE @A  uniqueidentifier,@B uniqueidentifier,@C Datetime,@D Datetime,@P decimal(10,2)  
   
  INSERT INTO @Puja  
  SELECT DISTINCT TI.Id,TD.EmployeeId,  
      CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',  
      CASE WHEN @ToDate < EndDate THEN @ToDate ELSE EndDate END  AS 'EndingDate',  
      '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'hoursdays'  
  FROM Common.TimeLogItem as TI  
    INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id  
    INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId  
	LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id  
  WHERE ApplyToAll <>1 and  
     E.CompanyId=@CompanyId and  
        E.Id=@EMPLOYEEID and
     StartDate >=@FromDate and StartDate <=@ToDate and SystemType not in ('CaseGroup','WorkWeekSetup') 
	  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
	  And TI.SystemType <> 'LeaveApplication'
   UNION ALL  
     SELECT distinct TI.Id, A.Employeeid,   
      CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',    
         CASE WHEN @ToDate < EndDate THEN @ToDate ELSE EndDate END  AS 'EndingDate',    
            '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'hoursdays'    
     FROM Common.TimeLogItem as TI   
	 LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id 
	  
  CROSS JOIN  
      (  
     select E.Id as 'Employeeid'   from Common.Employee as E  
     where E.CompanyId=@CompanyId  
	 and E.Id=@EMPLOYEEID
      ) as A  
  WHERE ApplyToAll =1 and    
     TI.CompanyId=@CompanyId and  
	    case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')  and
		 SystemType not in ('CaseGroup','WorkWeekSetup') and
   --TI.id in ('78CC6BCA-4FD1-4768-9B40-FC46495550F1') and    
     StartDate >=@FromDate and StartDate <=@ToDate  
	 And TI.SystemType <> 'LeaveApplication'

		--DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),CASENAME NVARCHAR(1000), STARTDATE DATE,  ENDDATE DATE,TOATLHOURS MONEY,ISOVERRUNHOURS Money,CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000), SCHEDULETYPEID UNIQUEIDENTIFIER NULL, SCHEDULETYPE NVARCHAR(100), IsActualHrs bit)   -- ScheduleTypeid means Calender / LeaveApplication Id - Added by SSK)
		
 DECLARE Year_Count cursor for SELECT * FROM @Puja --where hours <> '0.00'  
  OPEN Year_Count  
  FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P  
  WHILE @@FETCH_STATUS = 0  
  BEGIN  
IF @P ='0.00'  
BEGIN  


INSERT INTO @OUTPUT (EMPLOYEENAME,STARTDATE,ENDDATE,EMPLOYEEID,EMPLOYEEAUTONUMBER,TOATLHOURS,IsOverRunHours,PHOTOURL,SystemId,SystemType)	
SELECT FirstName as 'EMPLOYEENAME',StartDate,Enddate,Employeeid,Employeeautonumber,sum(TotalHours) as 'TotalHours',
		'0', PHOTOURL, SystemId, SystemType 
 FROM   
	(  
	SELECT id,Subtype,FirstName,StartDate,Enddate,CASE WHEN EndingDate < StartDate THEN '0.00'  
           ELSE coalesce(TotalHours,0) END as 'TotalHours',  
		   Employeeid,Employeeautonumber,PHOTOURL,SystemId, SystemType  
    FROM   
		(  
		 SELECT DISTINCT  id,Subtype,FirstName,FromDate as 'StartDate',Todate as 'Enddate',startingdate,EndingDate,  
			    CASE WHEN StartingDate > Todate THEN '0.00' WHEN StartingDate = EndingDate THEN
			    CASE WHEN StartingDate between FromDate and Todate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay
					 ELSE '0.00' END
					 WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay  
					 WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
				CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00'
				ELSE (datediff(DAY,FromDate,EndingDate)+1) *HoursPerDay END
					 WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *HoursPerDay
					 WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *HoursPerDay
				END as 'TotalHours',Employeeid,Employeeautonumber,PHOTOURL,SystemId , SystemType 
		 FROM    
			(  
			SELECT DISTINCT Ti.Id,SubType as 'Subtype',E.FirstName,E.Id as 'Employeeid',  
				   E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL',  TI.EndDate,
				   CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',  
				   CASE WHEN @ToDate < TI.EndDate THEN @ToDate ELSE TI.EndDate END  AS 'EndingDate',  
				   Ti.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',
				   '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints', SystemId, SystemType   from  
			Common.TimeLogItem as TI  
				   INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id  
				   INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId  
				   INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
				   INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
				   INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
				   LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId 
				   LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id  
			WHERE  case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
			 and SystemType not in ('CaseGroup','WorkWeekSetup') and
				   ApplyToAll <>1 AND  
				   E.CompanyId=@CompanyId AND  
				  TI.id= @A and  
				  E.Id= @B and  
				  E.ID=@EMPLOYEEID AND  
				  StartDate >=@FromDate and StartDate <=@ToDate 
				  And TI.SystemType <> 'LeaveApplication' 
			) AS P  
			CROSS JOIN  
					  (  
						SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate   
						FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
					  ) AS PP  
		 ) AS P  
	) AS P 
   Group by Subtype,
   FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL,SystemId, SystemType  
UNION ALL

 SELECT FirstName as 'EMPLOYEENAME',StartDate,Enddate,Employeeid,Employeeautonumber,sum(TotalHours) as 'TotalHours',
		'0', PHOTOURL, SystemId, SystemType  from 
		(
		SELECT id,FirstName,Subtype,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
				else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType
		FROM 
			(
			SELECT DISTINCT  Id,Subtype,startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',
				   CASE WHEN StartingDate > Todate THEN '0.00'
				    WHEN StartingDate = EndingDate THEN
			       CASE WHEN StartingDate between FromDate and Todate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay
						ELSE '0.00' END
						WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay  
						WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
				   CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00'
				   ELSE (datediff(DAY,FromDate,EndingDate)+1) *HoursPerDay END
					    WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *HoursPerDay
					    WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *HoursPerDay
				   END as 'TotalHours',DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType
				   FROM  
					  (
					   SELECT DISTINCT TI.Id,Subtype,
					          CASE WHEN @FromDate > StartDate then @FromDate ELSE StartDate END as 'StartingDate',
							  CASE WHEN @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'  
							  ,Ti.EndDate,TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',  
							 '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints' , SystemId , SystemType
					   FROM Common.TimeLogItem as TI 
					   LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id  
		
				       WHERE ApplyToAll = 1 and 
					      case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
						  not in ('Approve Cancelled','Rejected','Cancelled')  and 
						  SystemType not in ('CaseGroup','WorkWeekSetup') and
						     TI.CompanyId=@CompanyId 
						   and  
						    TI.id= @A 
							--and  
							--EMPDEPT.DEPARTMENTID=@DEPARTMENTID   
						  and StartDate >=@FromDate and StartDate <=@ToDate  
						  And TI.SystemType <> 'LeaveApplication'
					 ) AS P  
					CROSS JOIN  
					   (  
					   SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
					   ) AS PP  
					CROSS JOIN
						(
						 SELECT E.FirstName,E.Id as 'Employeeid',  
							    E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL'  from Common.Employee as E
							    INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
						        INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
						        INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
						        LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
						 WHERE E.CompanyId=@CompanyId
						    and  
						    E.Id= @B  
							and E.Id=@EMPLOYEEID
						) as A
				) AS P
			) AS P
			GROUP BY id,FirstName,Subtype,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType
			END
ELSE
	BEGIN
	--Print 1236598
			INSERT INTO @OUTPUT (EMPLOYEENAME,STARTDATE,ENDDATE,EMPLOYEEID,EMPLOYEEAUTONUMBER,TOATLHOURS,PHOTOURL,IsOverRunHours,SystemId,SystemType)	
			 Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,Employeeid,Employeeautonumber,
		SUM(TotalHours) as 'TotalHours',PHOTOURL,'0',  SystemId, SystemType  from   
  (  
   Select Subtype,FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'  
       else coalesce(TotalHours,0) END as 'TotalHours',  
    Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType  --  SystemId, adeed SSk  
   FROM   
   (  
   SELECT distinct Subtype, startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',  
   CASE WHEN cast(StartingDate as Date)   > Todate THEN '0.00'
	 	 WHEN cast(StartingDate as Date)   = cast(EndingDate as date) THEN
  CASE WHEN cast(StartingDate as Date) >= FromDate and cast(StartingDate as Date)   <=Todate THEN (datediff(DAY,StartingDate,EndingDate)) 
  *HoursPerDay + DaysPoints * HoursPerDay  
  ELSE '0.00' END
  WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay  
  WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
  CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00' 
  ELSE (datediff(DAY,FromDate,EndingDate)) *HoursPerDay + DaysPoints * HoursPerDay END
  WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *HoursPerDay
  WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *HoursPerDay
  END as 'TotalHours',
   
	DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType  --  SystemId, adeed SSk 
    FROM    
     (  
      SELECT distinct Subtype,E.FirstName,E.Id as 'Employeeid',  SystemId, SystemType, --  SystemId, adeed SSk
       E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL',  
      case when @FromDate > StartDate then @FromDate ELSE StartDate END   
          as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'  
          ,Ti.EndDate,TI.Hours,Ti.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',  
          '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'  
      FROM Common.TimeLogItem as TI  
       INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id  
       INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId  
       INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
       INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
          INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
       LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
      --  and SystemType not in ('LeaveApplication') 
	   LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
      where ApplyToAll <>1  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
	  not in ('Approve Cancelled','Rejected','Cancelled')  and
	  SystemType not in ('CaseGroup','WorkWeekSetup') and
       E.CompanyId=@CompanyId   
       and  
        TI.id= @A and  
        E.Id= @B   
        and  E.Id=@EMPLOYEEID
        --EMPDEPT.DEPARTMENTID=@DEPARTMENTID   
      and StartDate >=@FromDate and StartDate <=@ToDate 
	  And TI.SystemType <> 'LeaveApplication'   
     ) AS P  
    CROSS JOIN  
       (  
       SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
       ) AS PP  
    ) AS P  
     ) AS P  
   Group by Subtype,FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType 
   UNION ALL
   Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,Employeeid,Employeeautonumber,
		SUM(TotalHours) as 'TotalHours',PHOTOURL,'0',  SystemId, SystemType from    -- SystemId added SSK
		(
		 Select Subtype,FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType -- -- SystemId added SSK
		 FROM 
			(
			SELECT distinct Subtype, startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',
				CASE WHEN cast(StartingDate as Date)   > Todate THEN '0.00'
	 	 WHEN cast(StartingDate as Date)   = cast(EndingDate as date) THEN
  CASE WHEN cast(StartingDate as Date) >= FromDate and cast(StartingDate as Date)   <=Todate THEN (datediff(DAY,StartingDate,EndingDate)) 
  *HoursPerDay + DaysPoints * HoursPerDay  
  ELSE '0.00' END
  WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay  
  WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
  CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00' 
  ELSE (datediff(DAY,FromDate,EndingDate)) *HoursPerDay + DaysPoints * HoursPerDay END
  WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *HoursPerDay
  WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *HoursPerDay
  END as 'TotalHours',
				
				DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType -- SystemId added SSK
				FROM  
					(
					 SELECT DISTINCT Subtype, SystemId, SystemType,case when @FromDate > StartDate then @FromDate ELSE StartDate END   
							as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'  
							,Ti.EndDate,TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',  
							'0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'  
					FROM Common.TimeLogItem as TI 
					 LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
					 WHERE     case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
					 not in ('Approve Cancelled','Rejected','Cancelled')   and 
					 SystemType not in ('CaseGroup','WorkWeekSetup') and
				     ApplyToAll = 1 and  
						  TI.CompanyId=@CompanyId 
						   and  TI.id= @A  
						   and StartDate >=@FromDate and StartDate <=@ToDate  
						   And TI.SystemType <> 'LeaveApplication'
					 ) AS P  
					CROSS JOIN  
					   (  
					   SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
					   ) AS PP  
					CROSS JOIN
						(
						select E.FirstName,E.Id as 'Employeeid',  
							  E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL'  from Common.Employee as E
						 INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
						  INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
						  INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
						  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
						where E.CompanyId=@CompanyId
						    and  
						    E.Id= @B
							and E.Id=@EMPLOYEEID  
						) as A
				) AS P
					) AS P
			Group by Subtype,FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType -- SystemId added SSK

			END
			  FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P  
    END  
    CLOSE Year_Count  
    DEALLOCATE Year_Count

		--SELECT EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,STARTDATE,ENDDATE,SUm(TOATLHOURS) as TOATLHOURS,Sum(Isnull(IsOverRunHours,0)) As ISOVERRUNHOURS ,CASEID,PHOTOURL,SCHEDULETYPEID, SCHEDULETYPE , 0 as IsActualHrs
		--FROM @OUTPUT 
		--GROUP BY EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,STARTDATE,ENDDATE,CASEID,PHOTOURL,SCHEDULETYPEID,SCHEDULETYPE
		--ORDER BY CASENUMBER  -- Old condition
--Print 'Employeeid is not null'
END

If @EMPLOYEEID Is Null
BEGIN

				 DECLARE  @Puja1  TABLE (id uniqueidentifier, Employeeid uniqueidentifier,FromDate datetime,ToDate Datetime,hours decimal(10,2))  
  --DECLARE @A  uniqueidentifier,@B uniqueidentifier,@C Datetime,@D Datetime,@P decimal(10,2)  
   
  INSERT INTO @Puja1  
  SELECT DISTINCT TI.Id,TD.EmployeeId,  
      CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',  
      CASE WHEN @ToDate < EndDate THEN @ToDate ELSE EndDate END  AS 'EndingDate',  
      '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'hoursdays'  
  FROM Common.TimeLogItem as TI  
    INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id  
    INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId  
	LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id  
  WHERE ApplyToAll <>1 and  
     E.CompanyId=@CompanyId and  
        --E.Id=@EMPLOYEEID and
     StartDate >=@FromDate and StartDate <=@ToDate and SystemType not in ('CaseGroup','WorkWeekSetup') 
	  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
	  And TI.SystemType <> 'LeaveApplication'
   UNION ALL  
     SELECT distinct TI.Id, A.Employeeid,   
      CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',    
         CASE WHEN @ToDate < EndDate THEN @ToDate ELSE EndDate END  AS 'EndingDate',    
            '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'hoursdays'    
     FROM Common.TimeLogItem as TI   
	 LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id  
  CROSS JOIN  
      (  
     select E.Id as 'Employeeid'   from Common.Employee as E  
     where E.CompanyId=@CompanyId  
	 --and E.Id=@EMPLOYEEID
      ) as A  
  WHERE ApplyToAll =1 and    
     TI.CompanyId=@CompanyId and  
	    case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')  and
		 SystemType not in ('CaseGroup','WorkWeekSetup') and
   --TI.id in ('78CC6BCA-4FD1-4768-9B40-FC46495550F1') and    
     StartDate >=@FromDate and StartDate <=@ToDate 
	 And TI.SystemType <> 'LeaveApplication' 

		--DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),CASENAME NVARCHAR(1000), STARTDATE DATE,  ENDDATE DATE,TOATLHOURS MONEY,ISOVERRUNHOURS Money,CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000), SCHEDULETYPEID UNIQUEIDENTIFIER NULL, SCHEDULETYPE NVARCHAR(100), IsActualHrs bit)   -- ScheduleTypeid means Calender / LeaveApplication Id - Added by SSK)
		
 DECLARE Year_Count cursor for SELECT * FROM @Puja1 --where hours <> '0.00'  
  OPEN Year_Count  
  FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P  
  WHILE @@FETCH_STATUS = 0  
  BEGIN  
IF @P ='0.00'  
BEGIN  


INSERT INTO @OUTPUT (EMPLOYEENAME,STARTDATE,ENDDATE,EMPLOYEEID,EMPLOYEEAUTONUMBER,TOATLHOURS,IsOverRunHours,PHOTOURL,SystemId,SystemType)	
SELECT FirstName as 'EMPLOYEENAME',StartDate,Enddate,Employeeid,Employeeautonumber,sum(TotalHours) as 'TotalHours',
		'0', PHOTOURL, SystemId, SystemType 
 FROM   
	(  
	SELECT id,Subtype,FirstName,StartDate,Enddate,CASE WHEN EndingDate < StartDate THEN '0.00'  
           ELSE coalesce(TotalHours,0) END as 'TotalHours',  
		   Employeeid,Employeeautonumber,PHOTOURL,SystemId, SystemType  
    FROM   
		(  
		 SELECT DISTINCT  id,Subtype,FirstName,FromDate as 'StartDate',Todate as 'Enddate',startingdate,EndingDate,  
			    CASE WHEN StartingDate > Todate THEN '0.00' WHEN StartingDate = EndingDate THEN
			    CASE WHEN StartingDate between FromDate and Todate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay
					 ELSE '0.00' END
					 WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay  
					 WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
				CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00'
				ELSE (datediff(DAY,FromDate,EndingDate)+1) *HoursPerDay END
					 WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *HoursPerDay
					 WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *HoursPerDay
				END as 'TotalHours',Employeeid,Employeeautonumber,PHOTOURL,SystemId , SystemType 
		 FROM    
			(  
			SELECT DISTINCT Ti.Id,SubType as 'Subtype',E.FirstName,E.Id as 'Employeeid',  
				   E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL',  TI.EndDate,
				   CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',  
				   CASE WHEN @ToDate < TI.EndDate THEN @ToDate ELSE TI.EndDate END  AS 'EndingDate',  
				   Ti.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',
				   '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints', SystemId, SystemType   from  
			Common.TimeLogItem as TI  
				   INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id  
				   INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId  
				   INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
				   INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
				   INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
				   LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId 
				   LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id  
			WHERE  case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
			 and SystemType not in ('CaseGroup','WorkWeekSetup') and
				   ApplyToAll <>1 AND  
				   E.CompanyId=@CompanyId AND  
				  TI.id= @A and  
				  E.Id= @B and  
				  --E.ID=@EMPLOYEEID AND  
				  StartDate >=@FromDate and StartDate <=@ToDate 
				  And TI.SystemType <> 'LeaveApplication' 
			) AS P  
			CROSS JOIN  
					  (  
						SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate   
						FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
					  ) AS PP  
		 ) AS P  
	) AS P 
   Group by Subtype,
   FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL,SystemId, SystemType  
UNION ALL

 SELECT FirstName as 'EMPLOYEENAME',StartDate,Enddate,Employeeid,Employeeautonumber,sum(TotalHours) as 'TotalHours',
		'0', PHOTOURL, SystemId, SystemType  from 
		(
		SELECT id,FirstName,Subtype,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
				else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType
		FROM 
			(
			SELECT DISTINCT  Id,Subtype,startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',
				   CASE WHEN StartingDate > Todate THEN '0.00'
				    WHEN StartingDate = EndingDate THEN
			       CASE WHEN StartingDate between FromDate and Todate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay
						ELSE '0.00' END
						WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay  
						WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
				   CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00'
				   ELSE (datediff(DAY,FromDate,EndingDate)+1) *HoursPerDay END
					    WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *HoursPerDay
					    WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *HoursPerDay
				   END as 'TotalHours',DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType
				   FROM  
					  (
					   SELECT DISTINCT TI.Id,Subtype,
					          CASE WHEN @FromDate > StartDate then @FromDate ELSE StartDate END as 'StartingDate',
							  CASE WHEN @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'  
							  ,Ti.EndDate,TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',  
							 '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints' , SystemId , SystemType
					   FROM Common.TimeLogItem as TI 
					   LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id  
		
				       WHERE ApplyToAll = 1 and 
					      case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
						  not in ('Approve Cancelled','Rejected','Cancelled')  and 
						  SystemType not in ('CaseGroup','WorkWeekSetup') and
						     TI.CompanyId=@CompanyId 
						   and  
						    TI.id= @A 
							--and  
							--EMPDEPT.DEPARTMENTID=@DEPARTMENTID   
						  and StartDate >=@FromDate and StartDate <=@ToDate 
						  And TI.SystemType <> 'LeaveApplication' 
					 ) AS P  
					CROSS JOIN  
					   (  
					   SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
					   ) AS PP  
					CROSS JOIN
						(
						 SELECT E.FirstName,E.Id as 'Employeeid',  
							    E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL'  from Common.Employee as E
							    INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
						        INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
						        INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
						        LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
						 WHERE E.CompanyId=@CompanyId
						    and  
						    E.Id= @B  
							--and E.Id=@EMPLOYEEID
						) as A
				) AS P
			) AS P
			GROUP BY id,FirstName,Subtype,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType
			END
ELSE
	BEGIN
			INSERT INTO @OUTPUT (EMPLOYEENAME,STARTDATE,ENDDATE,EMPLOYEEID,EMPLOYEEAUTONUMBER,TOATLHOURS,PHOTOURL,IsOverRunHours,SystemId,SystemType)	
			 Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,Employeeid,Employeeautonumber,
		SUM(TotalHours) as 'TotalHours',PHOTOURL,'0',  SystemId, SystemType  from   
  (  
   Select Subtype,FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'  
       else coalesce(TotalHours,0) END as 'TotalHours',  
    Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType  --  SystemId, adeed SSk  
   FROM   
   (  
   SELECT distinct Subtype, startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',  
   CASE WHEN cast(StartingDate as Date)   > Todate THEN '0.00'
	 	 WHEN cast(StartingDate as Date)   = cast(EndingDate as date) THEN
  CASE WHEN cast(StartingDate as Date) >= FromDate and cast(StartingDate as Date)   <=Todate THEN (datediff(DAY,StartingDate,EndingDate)) 
  *HoursPerDay + DaysPoints * HoursPerDay  
  ELSE '0.00' END
  WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay  
  WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
  CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00' 
  ELSE (datediff(DAY,FromDate,EndingDate)) *HoursPerDay + DaysPoints * HoursPerDay END
  WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *HoursPerDay
  WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *HoursPerDay
  END as 'TotalHours',
   
	DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType  --  SystemId, adeed SSk 
    FROM    
     (  
      SELECT distinct Subtype,E.FirstName,E.Id as 'Employeeid',  SystemId, SystemType, --  SystemId, adeed SSk
       E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL',  
      case when @FromDate > StartDate then @FromDate ELSE StartDate END   
          as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'  
          ,Ti.EndDate,TI.Hours,Ti.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',  
          '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'  
      FROM Common.TimeLogItem as TI  
       INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id  
       INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId  
       INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
       INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
          INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
       LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
      --  and SystemType not in ('LeaveApplication') 
	   LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
      where ApplyToAll <>1  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
	  not in ('Approve Cancelled','Rejected','Cancelled')  and
	  SystemType not in ('CaseGroup','WorkWeekSetup') and
       E.CompanyId=@CompanyId   
       and  
        TI.id= @A and  
        E.Id= @B   
        --and  E.Id=@EMPLOYEEID
        --EMPDEPT.DEPARTMENTID=@DEPARTMENTID   
      and StartDate >=@FromDate and StartDate <=@ToDate 
	  And TI.SystemType <> 'LeaveApplication'   
     ) AS P  
    CROSS JOIN  
       (  
       SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
       ) AS PP  
    ) AS P  
     ) AS P  
   Group by Subtype,FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType 
   UNION ALL
   Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,Employeeid,Employeeautonumber,
		SUM(TotalHours) as 'TotalHours',PHOTOURL,'0',  SystemId, SystemType from    -- SystemId added SSK
		(
		 Select Subtype,FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType -- -- SystemId added SSK
		 FROM 
			(
			SELECT distinct Subtype, startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',
				CASE WHEN cast(StartingDate as Date)   > Todate THEN '0.00'
	 	 WHEN cast(StartingDate as Date)   = cast(EndingDate as date) THEN
  CASE WHEN cast(StartingDate as Date) >= FromDate and cast(StartingDate as Date)   <=Todate THEN (datediff(DAY,StartingDate,EndingDate)) 
  *HoursPerDay + DaysPoints * HoursPerDay  
  ELSE '0.00' END
  WHEN FromDate <= StartingDate and Todate >= EndingDate THEN (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay  
  WHEN FromDate >= StartingDate and Todate >= EndingDate THEN 
  CASE WHEN FromDate > EndingDate and Todate > EndingDate THEN '0.00' 
  ELSE (datediff(DAY,FromDate,EndingDate)) *HoursPerDay + DaysPoints * HoursPerDay END
  WHEN FromDate >= StartingDate and Todate <= EndingDate then (datediff(DAY,FromDate,Todate)+1) *HoursPerDay
  WHEN FromDate <= StartingDate and Todate <= EndingDate then (datediff(DAY,StartingDate,Todate)+1) *HoursPerDay
  END as 'TotalHours',
				
				DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType -- SystemId added SSK
				FROM  
					(
					 SELECT DISTINCT Subtype, SystemId, SystemType,case when @FromDate > StartDate then @FromDate ELSE StartDate END   
							as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'  
							,Ti.EndDate,TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',  
							'0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'  
					FROM Common.TimeLogItem as TI 
					 LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
					 WHERE     case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
					 not in ('Approve Cancelled','Rejected','Cancelled')   and 
					 SystemType not in ('CaseGroup','WorkWeekSetup') and
				     ApplyToAll = 1 and  
						  TI.CompanyId=@CompanyId 
						   and  TI.id= @A  
						   and StartDate >=@FromDate and StartDate <=@ToDate 
						   And TI.SystemType <> 'LeaveApplication' 
					 ) AS P  
					CROSS JOIN  
					   (  
					   SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
					   ) AS PP  
					CROSS JOIN
						(
						select E.FirstName,E.Id as 'Employeeid',  
							  E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL'  from Common.Employee as E
						 INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
						  INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
						  INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
						  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
						where E.CompanyId=@CompanyId
						    and  
						    E.Id= @B
							--and E.Id=@EMPLOYEEID  
						) as A
				) AS P
					) AS P
			Group by Subtype,FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType -- SystemId added SSK

			END
			  FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P  
    END  
    CLOSE Year_Count  
    DEALLOCATE Year_Count

	End


	END TRY
	BEGIN CATCH
		PRINT('FAILED..!')
	END CATCH

		--Select EMPLOYEENAME, STARTDATE,  ENDDATE, TOATLHOURS, Isnull((TOTALOVERRUNMINUTES / 60 + (TOTALOVERRUNMINUTES % 60) / 100.0),0)  AS ISOVERRUNHOURS,EMPLOYEEID,EMPLOYEEAUTONUMBER ,PHOTOURL, SystemId, SystemType, Isnull(IsActualHrs,0) As IsActualHrs
		--From @OUTPUT 
		--Group By EMPLOYEENAME, STARTDATE,  ENDDATE, TOATLHOURS, (TOTALOVERRUNMINUTES / 60 + (TOTALOVERRUNMINUTES % 60) / 100.0),EMPLOYEEID,EMPLOYEEAUTONUMBER ,PHOTOURL, SystemId, SystemType, IsActualHrs


Begin

DECLARE @OUTPUT1 TABLE (EMPLOYEENAME NVARCHAR (1000), STARTDATE DATE,  ENDDATE DATE, TOTALMINUTES BIGINT,TOATLHOURS MONEY, TOTALOVERRUNMINUTES BIGINT,IsOverRunHours Money,EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(100),PHOTOURL NVARCHAR(1000), SystemId UNIQUEIDENTIFIER, SystemType nvarchar(100), IsActualHrs bit)

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
If @DEPARTMENTID Is null And @DESIGNATIONID Is null And @EMPLOYEEID Is Null
	Begin
Insert Into @OUTPUT1(EMPLOYEENAME,EMPLOYEEID,EMPLOYEEAUTONUMBER,STARTDATE,ENDDATE,TOATLHOURS,TOTALOVERRUNMINUTES,IsOverRunHours,PHOTOURL,SystemId,SystemType,IsActualHrs)
  Select EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,@CsrSdate,@csrEdate,SUM(TLI.Hours),0,'0.0',null,null,SystemType,0
  From Common.TimeLogItem as TLI
  Inner join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
  Inner Join Common.Employee As EMP On EMP.Id=TLID.EmployeeId
  --INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON EMPDEPT.EMPLOYEEID = EMP.Id 
  --INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
 -- INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
  --LEFT JOIN Common.MediaRepository as MR ON MR.Id=EMP.PhotoId
  Where TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate And Tli.CompanyId=@COMPANYID And TLI.SystemType = 'LeaveApplication'
  Group by EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SystemType
  End
Else If @DEPARTMENTID Is not null And @DESIGNATIONID Is null And @EMPLOYEEID Is Null
	Begin
	Insert Into @OUTPUT1		(EMPLOYEENAME,EMPLOYEEID,EMPLOYEEAUTONUMBER,STARTDATE,ENDDATE,TOATLHOURS,TOTALOVERRUNMINUTES,IsOverRunHours,PHOTOURL,SystemId,SystemType,IsActualHrs)
		Select EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,@CsrSdate,@csrEdate,SUM(TLI.Hours),0,'0.0',null,SystemId,SystemType,0
		From Common.TimeLogItem as TLI
		Inner join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
		Inner Join Common.Employee As EMP On EMP.Id=TLID.EmployeeId
		INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON EMPDEPT.EMPLOYEEID = EMP.Id 
		--INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
		--INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
		--LEFT JOIN Common.MediaRepository as MR ON MR.Id=EMP.PhotoId
		Where TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate And Tli.CompanyId=@COMPANYID And TLI.SystemType = 'LeaveApplication'
		And EMPDEPT.DepartmentId=@DEPARTMENTID
		And @CsrSdate between EMPDEPT.EffectiveFrom And coalesce(EMPDEPT.EffectiveTo,@csrEdate)
		Group by EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SystemId,SystemType
	End
Else If @DEPARTMENTID Is not null And @DESIGNATIONID Is not null And @EMPLOYEEID Is Null

		Begin
	Insert Into @OUTPUT1		(EMPLOYEENAME,EMPLOYEEID,EMPLOYEEAUTONUMBER,STARTDATE,ENDDATE,TOATLHOURS,TOTALOVERRUNMINUTES,IsOverRunHours,PHOTOURL,SystemId,SystemType,IsActualHrs)
		Select EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,@CsrSdate,@csrEdate,SUM(TLI.Hours),0,'0.0',null,SystemId,SystemType,0
		From Common.TimeLogItem as TLI
		Inner join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
		Inner Join Common.Employee As EMP On EMP.Id=TLID.EmployeeId
		INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON EMPDEPT.EMPLOYEEID = EMP.Id 
		--INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
		--INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
		--LEFT JOIN Common.MediaRepository as MR ON MR.Id=EMP.PhotoId
		Where TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate And Tli.CompanyId=@COMPANYID And TLI.SystemType = 'LeaveApplication'
		And EMPDEPT.DepartmentId=@DEPARTMENTID And EMPDEPT.DepartmentDesignationId=@DESIGNATIONID
		And @CsrSdate between EMPDEPT.EffectiveFrom And coalesce(EMPDEPT.EffectiveTo,@csrEdate)
		Group by EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SystemId,SystemType
	End

Else If @DEPARTMENTID Is not null And @DESIGNATIONID Is not null And @EMPLOYEEID Is Not Null

		Begin
	Insert Into @OUTPUT1		(EMPLOYEENAME,EMPLOYEEID,EMPLOYEEAUTONUMBER,STARTDATE,ENDDATE,TOATLHOURS,TOTALOVERRUNMINUTES,IsOverRunHours,PHOTOURL,SystemId,SystemType,IsActualHrs)
		Select EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,@CsrSdate,@csrEdate,SUM(TLI.Hours),0,'0.0',null,null,SystemType,0
		From Common.TimeLogItem as TLI
		Inner join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
		Inner Join Common.Employee As EMP On EMP.Id=TLID.EmployeeId
		INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON EMPDEPT.EMPLOYEEID = EMP.Id 
		--INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
		--INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
		--LEFT JOIN Common.MediaRepository as MR ON MR.Id=EMP.PhotoId
		Where TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate And Tli.CompanyId=@COMPANYID And TLI.SystemType = 'LeaveApplication'
		And EMPDEPT.DepartmentId=@DEPARTMENTID And EMPDEPT.DepartmentDesignationId=@DESIGNATIONID And EMP.id=@EMPLOYEEID
		And @CsrSdate between EMPDEPT.EffectiveFrom And coalesce(EMPDEPT.EffectiveTo,@csrEdate)
		Group by EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SystemType
	End
Else If @DEPARTMENTID Is null And @DESIGNATIONID Is not null And @EMPLOYEEID Is Null

		Begin
	Insert Into @OUTPUT1		(EMPLOYEENAME,EMPLOYEEID,EMPLOYEEAUTONUMBER,STARTDATE,ENDDATE,TOATLHOURS,TOTALOVERRUNMINUTES,IsOverRunHours,PHOTOURL,SystemId,SystemType,IsActualHrs)
		Select EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,@CsrSdate,@csrEdate,SUM(TLI.Hours),0,'0.0',null,SystemId,SystemType,0
		From Common.TimeLogItem as TLI
		Inner join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
		Inner Join Common.Employee As EMP On EMP.Id=TLID.EmployeeId
		INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON EMPDEPT.EMPLOYEEID = EMP.Id 
		--INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
		INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
		--LEFT JOIN Common.MediaRepository as MR ON MR.Id=EMP.PhotoId
		Where TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate And Tli.CompanyId=@COMPANYID And TLI.SystemType = 'LeaveApplication'
		And EMPDEPT.DepartmentDesignationId=@DESIGNATIONID
		And @CsrSdate between EMPDEPT.EffectiveFrom And coalesce(EMPDEPT.EffectiveTo,@csrEdate)
		Group by EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SystemId,SystemType
	End

Else If @DEPARTMENTID Is null And @DESIGNATIONID Is not null And @EMPLOYEEID Is Not Null

		Begin
	Insert Into @OUTPUT1		(EMPLOYEENAME,EMPLOYEEID,EMPLOYEEAUTONUMBER,STARTDATE,ENDDATE,TOATLHOURS,TOTALOVERRUNMINUTES,IsOverRunHours,PHOTOURL,SystemId,SystemType,IsActualHrs)
		Select EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,@CsrSdate,@csrEdate,SUM(TLI.Hours),0,'0.0',null,null,SystemType,0
		From Common.TimeLogItem as TLI
		Inner join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
		Inner Join Common.Employee As EMP On EMP.Id=TLID.EmployeeId
		INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON EMPDEPT.EMPLOYEEID = EMP.Id 
		--INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
		--INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
		--LEFT JOIN Common.MediaRepository as MR ON MR.Id=EMP.PhotoId
		Where TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate And Tli.CompanyId=@COMPANYID And TLI.SystemType = 'LeaveApplication'
		And EMPDEPT.DepartmentDesignationId=@DESIGNATIONID And EMP.Id=@EMPLOYEEID
		And @CsrSdate between EMPDEPT.EffectiveFrom And coalesce(EMPDEPT.EffectiveTo,@csrEdate)
		Group by EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SystemType
	End

Else If @DEPARTMENTID Is null And @DESIGNATIONID Is null And @EMPLOYEEID Is Not Null

		Begin
	Insert Into @OUTPUT1		(EMPLOYEENAME,EMPLOYEEID,EMPLOYEEAUTONUMBER,STARTDATE,ENDDATE,TOATLHOURS,TOTALOVERRUNMINUTES,IsOverRunHours,PHOTOURL,SystemId,SystemType,IsActualHrs)
		Select EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,@CsrSdate,@csrEdate,SUM(TLI.Hours),0,'0.0',null,null,SystemType,0
		From Common.TimeLogItem as TLI
		Inner join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
		Inner Join Common.Employee As EMP On EMP.Id=TLID.EmployeeId
		--INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON EMPDEPT.EMPLOYEEID = EMP.Id 
		--INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
		--INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
		--LEFT JOIN Common.MediaRepository as MR ON MR.Id=EMP.PhotoId
		Where TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate And Tli.CompanyId=@COMPANYID And TLI.SystemType = 'LeaveApplication'
		And EMP.Id=@EMPLOYEEID
		Group by EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SystemType
	End
Fetch Next From Week_Csr into @CsrSdate,@csrEdate
End

close Week_Csr
Deallocate Week_Csr
  
  
  --Select EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SubType,Null,@FROMDATE,@TODATE,SUM(TLI.Hours),0,null,null,SystemId,SystemType,0
  --From Common.TimeLogItem as TLI
  --Inner join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
  --Inner Join Common.Employee As EMP On EMP.Id=TLID.EmployeeId
  --Where TLI.StartDate >= @FROMDATE And TLI.EndDate <= @TODATE And Tli.CompanyId=@COMPANYID And TLID.EmployeeId=@EMPLOYEEID And TLI.Hours <> '0.00'
  --Group by EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SystemId,SystemType 


  --Select EMPLOYEENAME ,EMPLOYEEID ,EMPLOYEENUMBER , CLIENTNAME ,CASENUMBER ,CASENAME , STARTDATE ,	ENDDATE ,TOATLHOURS ,IsOverRunHours ,CASEID ,PHOTOURL ,SCHEDULETYPEID , SCHEDULETYPE , IsActualHrs 
  --From @OUTPUT
 End


 Insert Into @OUTPUT1 (EMPLOYEENAME,EMPLOYEEID,EMPLOYEEAUTONUMBER,STARTDATE,ENDDATE,TOATLHOURS,IsOverRunHours,PHOTOURL,SystemId,SystemType,IsActualHrs)
 		Select EMPLOYEENAME,EMPLOYEEID,EMPLOYEEAUTONUMBER, STARTDATE,  ENDDATE, Isnull(TOATLHOURS,0) As TOATLHOURS, Isnull((TOTALOVERRUNMINUTES / 60 + (TOTALOVERRUNMINUTES % 60) / 100.0),0)  AS ISOVERRUNHOURS, PHOTOURL, SystemId, SystemType, Isnull(IsActualHrs,0) As IsActualHrs
		From @OUTPUT Where Coalesce(SystemType,'Null') <> 'LeaveApplication'
		Group By EMPLOYEENAME, STARTDATE,  ENDDATE, TOATLHOURS, (TOTALOVERRUNMINUTES / 60 + (TOTALOVERRUNMINUTES % 60) / 100.0),EMPLOYEEID,EMPLOYEEAUTONUMBER ,PHOTOURL, SystemId, SystemType, IsActualHrs 



	Select EMPLOYEENAME, STARTDATE,  ENDDATE, Isnull(TOATLHOURS,0) As TOATLHOURS, Isnull((Isnull(TOTALOVERRUNMINUTES,0) / 60 + (Isnull(TOTALOVERRUNMINUTES,0) % 60) / 100.0),0)  AS ISOVERRUNHOURS,EMPLOYEEID,EMPLOYEEAUTONUMBER ,PHOTOURL, SystemId, SystemType, Isnull(IsActualHrs,0) As IsActualHrs
		From @OUTPUT1 
		Group By EMPLOYEENAME, STARTDATE,  ENDDATE, TOATLHOURS, (isnull(TOTALOVERRUNMINUTES,0) / 60 + (isnull(TOTALOVERRUNMINUTES,0) % 60) / 100.0),EMPLOYEEID,EMPLOYEEAUTONUMBER ,PHOTOURL, SystemId, SystemType, IsActualHrs



END
GO
