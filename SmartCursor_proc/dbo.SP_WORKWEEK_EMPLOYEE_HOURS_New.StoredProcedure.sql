USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_New]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_New]
(
	@FROMDATE DATE,
	@TODATE DATE,
	@COMPANYID BIGINT,
	@TYPE INT,
	@DESIGNATIONID UNIQUEIDENTIFIER,
	@DEPARTMENTID UNIQUEIDENTIFIER,
	@EMPLOYEEID UNIQUEIDENTIFIER)

AS BEGIN 
  /******  AUTHOR : Sreenivasulu   ******/
  DECLARE  @Puja  Table (id uniqueidentifier, Employeeid uniqueidentifier,FromDate datetime,ToDate Datetime,hours decimal(10,2))
  DECLARE  @TBL   Table (EMPLOYEENAME varchar(100),StartDate datetime,Enddate datetime,TotalHours decimal(10,2),
						 Employeeid uniqueidentifier,Employeeautonumber varchar(50),PHOTOURL nvarchar(2000))
  DECLARE @A  uniqueidentifier,@B uniqueidentifier,@C Datetime,@D Datetime,@P decimal(10,2)

		
		INSERT INTO @Puja
		SELECT DISTINCT TI.Id,TD.EmployeeId,CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',
			   CASE WHEN @ToDate < EndDate THEN @ToDate ELSE EndDate END  AS 'EndingDate',
			   '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'hoursdays'
		FROM Common.TimeLogItem as TI
			 INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id
			 INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId and E.IsHROnly=1
			 LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id 
		WHERE ApplyToAll <>1 and
			  E.CompanyId=@CompanyId and
					  --TI.id in ('78CC6BCA-4FD1-4768-9B40-FC46495550F1') and
			  StartDate >=@FromDate and StartDate <=@ToDate and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
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
					where E.CompanyId=@CompanyId and  E.IsHROnly=1
				  ) as A
		WHERE ApplyToAll =1 and  
			  TI.CompanyId=@CompanyId and  
			--TI.id in ('78CC6BCA-4FD1-4768-9B40-FC46495550F1') and  
			  StartDate >=@FromDate and StartDate <=@ToDate
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')  
			  and SystemType not in ('CaseGroup','WorkWeekSetup')
	


IF @TYPE=0 --ALL DEPARTMENTS  ALL DESIGNATIONS ALL EMPLOYEES       
BEGIN 

		DECLARE @START_DATE DATE
	DECLARE @Id UNIQUEIDENTIFIER,@NAMES NVARCHAR(1000),@FIRSTNAMES NVARCHAR(100),@PhotoId UNIQUEIDENTIFIER 
	DECLARE @OUTPUT TABLE (EMPLOYEENAME NVARCHAR (1000), STARTDATE DATE,  ENDDATE DATE,TOATLHOURS MONEY,IsOverRunHours Money,EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(2000),PHOTOURL NVARCHAR(1000))
	DECLARE WORKWEEK_EMPLOYEE_HOURS_CURSOR CURSOR FOR 		 
		 SELECT * FROM FC_WORKWEEK(@FROMDATE,@TODATE)  --FUNCTION
		 OPEN WORKWEEK_EMPLOYEE_HOURS_CURSOR
		 FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_CURSOR INTO @START_DATE
		 WHILE @@FETCH_STATUS=0		  
		 BEGIN      --EMPLOYEE LOOP BEGIN	 
			   
					DECLARE WORKWEEK_EMPLOYEE_HOURS_CURSORS CURSOR FOR 
					SELECT E.ID,E.FIRSTNAME,E.EMPLOYEEID,E.PhotoId	FROM COMMON.EMPLOYEE E	
					JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID
					 JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID 
					 JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID 
						WHERE 	E.COMPANYID=@COMPANYID AND E.STATUS=1  and e.IsHROnly=1
						 AND (EMPDEPT.EndDate IS NULL OR EMPDEPT.EndDate>=GETDATE())--change 		EMPDEPT.EndDate<=GETDATE() as EMPDEPT.EndDate>=GETDATE() for all			
					OPEN WORKWEEK_EMPLOYEE_HOURS_CURSORS
					FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_CURSORS INTO @Id,@NAMES,@FIRSTNAMES,@PhotoId
					WHILE @@FETCH_STATUS=0		  
						BEGIN  
							IF  EXISTS 	(SELECT @NAMES,@START_DATE,DATEADD(D, 6, @START_DATE) AS END_DATE, SUM(DATEDIFF(MINUTE,0,HOURS))/60.0 AS HOURS,
										        SUM(DATEDIFF(MINUTE,0,IsOverRunHours))/60.0 As IsOverRunHours,@Id,@FIRSTNAMES,(SELECT TOP 1 Small FROM Common.MediaRepository WHERE ID=@PhotoId)
										FROM WORKFLOW.SCHEDULETASK WHERE EMPLOYEEID=@Id 
													AND STARTDATE <= DATEADD(D, 6, @START_DATE) 
													AND ENDDATE >= @START_DATE													
													)
									BEGIN 
										INSERT INTO @OUTPUT (EMPLOYEENAME, STARTDATE, ENDDATE, TOATLHOURS,IsOverRunHours, EMPLOYEEID, EMPLOYEEAUTONUMBER, PHOTOURL)
											SELECT @NAMES,@START_DATE,DATEADD(D, 6, @START_DATE) AS END_DATE, SUM(DATEDIFF(MINUTE,0,HOURS))/60.0 AS HOURS,
											       SUM(DATEDIFF(MINUTE,0,IsOverRunHours))/60.0 As IsOverRunHours,@Id,@FIRSTNAMES,(SELECT TOP 1 Small  FROM Common.MediaRepository WHERE ID=@PhotoId)
																				
											 FROM WORKFLOW.SCHEDULETASK WHERE EMPLOYEEID=@Id 
												AND STARTDATE <= DATEADD(D, 6, @START_DATE) 
												AND ENDDATE >= @START_DATE												
									END 
										ELSE
									BEGIN 
									INSERT INTO @OUTPUT (EMPLOYEENAME, STARTDATE, ENDDATE, TOATLHOURS,IsOverRunHours, EMPLOYEEID, EMPLOYEEAUTONUMBER, PHOTOURL)
										SELECT @NAMES,@START_DATE,DATEADD(D, 6, @START_DATE) AS END_DATE, 0 AS HOURS,0 As IsOverRunHours,@Id,@FIRSTNAMES,
										       (SELECT TOP 1 Small  FROM Common.MediaRepository WHERE ID=@PhotoId)
										FROM COMMON.EMPLOYEE WHERE Id=@Id 
									END						
						FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_CURSORS INTO @Id,@NAMES,@FIRSTNAMES,@PhotoId
						END 
					CLOSE WORKWEEK_EMPLOYEE_HOURS_CURSORS
					DEALLOCATE WORKWEEK_EMPLOYEE_HOURS_CURSORS				    
		  FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_CURSOR INTO @START_DATE
		  END 
		  CLOSE WORKWEEK_EMPLOYEE_HOURS_CURSOR
		  DEALLOCATE WORKWEEK_EMPLOYEE_HOURS_CURSOR
	    DECLARE Year_Count cursor for SELECT * FROM @Puja --where hours <> '0.00'
		OPEN Year_Count
		FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P
		WHILE @@FETCH_STATUS = 0
		BEGIN
IF @P ='0.00'
BEGIN
	 INSERT INTO  @OUTPUT
	 Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		    Employeeid,Employeeautonumber,PHOTOURL 
		From 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
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
					Employeeid,Employeeautonumber,Null As PHOTOURL
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
			Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		           Employeeid,Employeeautonumber,PHOTOURL 
		    From 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
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
					Employeeid,Employeeautonumber,PHOTOURL
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
		ELSE
			BEGIN
			
			INSERT INTO  @OUTPUT	
			Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		           Employeeid,Employeeautonumber,PHOTOURL 
		    From 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
		 FROM 
			(
			SELECT distinct  startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',
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
				DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,PHOTOURL
				FROM  
					(
					 SELECT distinct E.FirstName,E.Id as 'Employeeid',
					  E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL',
					 case when @FromDate > StartDate then @FromDate ELSE StartDate END 
						    as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'
						    ,Ti.EndDate,TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',
						    '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'
					 FROM Common.TimeLogItem as TI
					  INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id
					  INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId and E.IsHROnly=1
					  INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID
					  INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID 
				      INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID 
					  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
					  LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
					 where ApplyToAll <>1 and
						 E.CompanyId=@CompanyId 
						 and
						  TI.id= @A and
						  E.Id= @B 
						  --and
						  --EMPDEPT.DEPARTMENTID=@DEPARTMENTID 
						and StartDate >=@FromDate and StartDate <=@ToDate
						and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
					) AS P
				CROSS JOIN
						 (
							SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE) 
						 ) AS PP
				) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL
			-- order by FirstName,StartDate
			UNION ALL
			Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		           Employeeid,Employeeautonumber,PHOTOURL 
		From 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,Null As PHOTOURL
		 FROM 
			(
			SELECT distinct  startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',
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
			  END as 'TotalHours',DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,PHOTOURL
				FROM  
					(
					 SELECT DISTINCT case when @FromDate > StartDate then @FromDate ELSE StartDate END   
							as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'  
							,Ti.EndDate,TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',  
							'0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'  
					FROM Common.TimeLogItem as TI 
					LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id 
				    WHERE ApplyToAll = 1 and  
						   SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')  
						   and  
						    TI.id= @A
						   -- and  
						   -- E.Id= @B   
							--and  
							--EMPDEPT.DEPARTMENTID=@DEPARTMENTID   
						  and StartDate >=@FromDate and StartDate <=@ToDate  
					 ) AS P  
					CROSS JOIN  
					   (  
					   SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
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
						    and  
						    E.Id= @B  
						) as A
				) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL

			END

			 FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P
		  END
		  CLOSE Year_Count
		  DEALLOCATE Year_Count

SELECT EMPLOYEENAME,STARTDATE,ENDDATE,sum(TOATLHOURS) as 'TOATLHOURS', sum(IsOverRunHours) As IsOverRunHours,EMPLOYEEID , EMPLOYEEAUTONUMBER,PHOTOURL 
FROM 
		(
		 SELECT EMPLOYEENAME,STARTDATE,ENDDATE,CASE WHEN TOATLHOURS IS NULL THEN 0.00 ELSE TOATLHOURS END AS TOATLHOURS ,
		        CASE WHEN IsOverRunHours IS NULL THEN 0.00 ELSE IsOverRunHours END AS IsOverRunHours, 
		        OP.EMPLOYEEID , EMPLOYEEAUTONUMBER,OP.PHOTOURL 
		 FROM @OUTPUT As OP
		 --Inner Join
		 --(Select E.Id As EmployeeId,MR.Small As PHOTOURL 
		 -- From Common.employee As E
		 -- Left Join Common.MediaRepository As MR On MR.Id=E.PhotoId) As PU0 On PU0.EmployeeId=OP.EMPLOYEEID
		) AS P
   GROUP BY EMPLOYEENAME,STARTDATE,ENDDATE,EMPLOYEEID, EMPLOYEEAUTONUMBER,PHOTOURL
   ORDER BY EMPLOYEENAME , STARTDATE
  END  
           
  ELSE IF @TYPE=1   -- ONLY DEPARTMENT_ID PASSING
  BEGIN

 DECLARE @START_DATE_DEPARTMENT DATE
		DECLARE @Id_DEPARTMENT UNIQUEIDENTIFIER,@NAMES_DEPARTMENT NVARCHAR(1000),@FIRSTNAMES_DEPARTMENT NVARCHAR(100),@PhotoId_DEPARTMENT UNIQUEIDENTIFIER 
		DECLARE @OUTPUT_DEPARTMENT TABLE (EMPLOYEENAME NVARCHAR (1000), STARTDATE DATE,  ENDDATE DATE,TOATLHOURS MONEY,IsOverRunHours Money,EMPLOYEEID UNIQUEIDENTIFIER,	EMPLOYEEAUTONUMBER NVARCHAR(2000),PHOTOURL NVARCHAR(1000)  )
		DECLARE WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_CURSOR CURSOR FOR 
			
			SELECT * FROM FC_WORKWEEK(@FROMDATE,@TODATE) 
			OPEN WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_CURSOR
			FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_CURSOR INTO @START_DATE_DEPARTMENT
			WHILE @@FETCH_STATUS=0
			 BEGIN		 
						DECLARE WORKWEEK_EMPLOYEE_HOURS_CURSORhOURS CURSOR FOR 
						SELECT E.ID,E.FIRSTNAME,E.EMPLOYEEID,E.PhotoId	FROM COMMON.EMPLOYEE E	JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID WHERE 	E.COMPANYID=@COMPANYID AND E.STATUS=1  AND (EMPDEPT.EndDate IS NULL OR EMPDEPT.EndDate>=GETDATE())   and e.IsHROnly=1 AND 	
						EMPDEPT.DEPARTMENTID=@DEPARTMENTID	-- for < >
						OPEN WORKWEEK_EMPLOYEE_HOURS_CURSORhOURS
						FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_CURSORhOURS INTO @Id_DEPARTMENT,@NAMES_DEPARTMENT,@FIRSTNAMES_DEPARTMENT,@PhotoId_DEPARTMENT
						WHILE @@FETCH_STATUS=0		  
								BEGIN  
								if exists(SELECT @NAMES_DEPARTMENT,@START_DATE_DEPARTMENT,DATEADD(D, 6, @START_DATE_DEPARTMENT) AS END_DATE, SUM(DATEDIFF(MINUTE,0,HOURS))/60.0 AS HOURS,SUM(DATEDIFF(MINUTE,0,IsOverRunHours))/60.0 AS IsOverRunHours,@Id_DEPARTMENT,@FIRSTNAMES_DEPARTMENT ,(SELECT TOP 1 Small  FROM Common.MediaRepository WHERE ID=@PhotoId_DEPARTMENT) FROM 
									WORKFLOW.SCHEDULETASK  WHERE EMPLOYEEID=@Id_DEPARTMENT 
									AND STARTDATE <= DATEADD(D, 6, @START_DATE_DEPARTMENT) 
									AND ENDDATE >= @START_DATE_DEPARTMENT							)
							   BEGIN								     
									INSERT INTO @OUTPUT_DEPARTMENT (EMPLOYEENAME, STARTDATE, ENDDATE, TOATLHOURS,IsOverRunHours, EMPLOYEEID, EMPLOYEEAUTONUMBER,PHOTOURL)
									SELECT @NAMES_DEPARTMENT,@START_DATE_DEPARTMENT,DATEADD(D, 6, @START_DATE_DEPARTMENT) AS END_DATE, SUM(DATEDIFF(MINUTE,0,HOURS))/60.0 AS HOURS,
									       SUM(DATEDIFF(MINUTE,0,IsOverRunHours))/60.0 AS IsOverRunHours,@Id_DEPARTMENT,@FIRSTNAMES_DEPARTMENT ,(SELECT TOP 1 Small  FROM Common.MediaRepository WHERE ID=@PhotoId_DEPARTMENT) 
								    FROM WORKFLOW.SCHEDULETASK  
									WHERE EMPLOYEEID=@Id_DEPARTMENT 
									      AND STARTDATE <= DATEADD(D, 6, @START_DATE_DEPARTMENT) 
									      AND ENDDATE >= @START_DATE_DEPARTMENT
																	
									END 
										ELSE
									BEGIN 
									INSERT INTO @OUTPUT_DEPARTMENT (EMPLOYEENAME, STARTDATE, ENDDATE, TOATLHOURS,IsOverRunHours ,EMPLOYEEID, EMPLOYEEAUTONUMBER,PHOTOURL)
										SELECT @NAMES_DEPARTMENT,@START_DATE_DEPARTMENT,DATEADD(D, 6, @START_DATE_DEPARTMENT) AS END_DATE, 0 AS HOURS,0 As IsOverRunHours,@Id_DEPARTMENT,@FIRSTNAMES_DEPARTMENT,
										(SELECT TOP 1 Small  FROM Common.MediaRepository WHERE ID=@PhotoId_DEPARTMENT)
										FROM COMMON.EMPLOYEE WHERE Id=@Id_DEPARTMENT 
									END		

								FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_CURSORhOURS INTO  @Id_DEPARTMENT,@NAMES_DEPARTMENT,@FIRSTNAMES_DEPARTMENT,@PhotoId_DEPARTMENT
								END 
						CLOSE WORKWEEK_EMPLOYEE_HOURS_CURSORhOURS
						DEALLOCATE WORKWEEK_EMPLOYEE_HOURS_CURSORhOURS	
			FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_CURSOR INTO @START_DATE_DEPARTMENT
			END 
			CLOSE WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_CURSOR
			DEALLOCATE WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_CURSOR
 DECLARE Year_Count cursor for SELECT * FROM @Puja --where hours <> '0.00'
		OPEN Year_Count
		FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P
		WHILE @@FETCH_STATUS = 0
		BEGIN
IF @P ='0.00'
BEGIN
	 INSERT INTO  @OUTPUT_DEPARTMENT
	 Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		    Employeeid,Employeeautonumber,PHOTOURL 
		From 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
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
					Employeeid,Employeeautonumber,Null As PHOTOURL
			 FROM  
				 (
				  SELECT distinct E.FirstName,E.Id as 'Employeeid',
					     E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL',
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
						  EMPDEPT.DEPARTMENTID=@DEPARTMENTID and
						  StartDate >=@FromDate and StartDate <=@ToDate
						  and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
				) AS P
			CROSS JOIN
					 (
					  SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate 
					  FROM FC_WORKWEEK(@FROMDATE,@TODATE) 
					 ) AS PP
					) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL
		UNION ALL
		Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		       Employeeid,Employeeautonumber,PHOTOURL 
		From 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
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
					Employeeid,Employeeautonumber,Null As PHOTOURL
			 FROM  
				 (
				  SELECT distinct  
          CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',  
          CASE WHEN @ToDate < TI.EndDate THEN @ToDate ELSE TI.EndDate END  AS 'EndingDate',  
          TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay' from  
      Common.TimeLogItem as TI  
	  LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
      WHERE  ApplyToAll=1 and
        TI.CompanyId=@CompanyId and  
        TI.id= @A and  
        StartDate >=@FromDate and StartDate <=@ToDate 
		and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled') 
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
	and E.Id= @B and  
        EMPDEPT.DEPARTMENTID=@DEPARTMENTID   
	) as A
					) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL

			END
		ELSE
			BEGIN
			INSERT INTO  @OUTPUT_DEPARTMENT	
			Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		Employeeid,Employeeautonumber,PHOTOURL 
		From 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
		 FROM 
			(
			SELECT distinct  startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',
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
  END as 'TotalHours',DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,null As PHOTOURL
				FROM  
					(
					 SELECT distinct E.FirstName,E.Id as 'Employeeid',
					  E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL',
					 case when @FromDate > StartDate then @FromDate ELSE StartDate END 
						    as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'
						    ,Ti.EndDate,TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',
						    '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'
					 FROM Common.TimeLogItem as TI
					  INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id
					  INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId and E.IsHROnly=1
					  INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID
					  INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID 
				      INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID 
					  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
					  LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
					 where ApplyToAll <>1 and
						 E.CompanyId=@CompanyId 
						 and
						  TI.id= @A and
						  E.Id= @B 
						  and
						  EMPDEPT.DEPARTMENTID=@DEPARTMENTID 
						and StartDate >=@FromDate and StartDate <=@ToDate
						and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
					) AS P
				CROSS JOIN
						 (
							SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE) 
						 ) AS PP
				) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL
		UNION ALL
			Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		Employeeid,Employeeautonumber,PHOTOURL 
		From 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
		 FROM 
			(
			SELECT distinct  startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',
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
  END as 'TotalHours',DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,Null As PHOTOURL
				FROM  
					(
					 SELECT DISTINCT case when @FromDate > StartDate then @FromDate ELSE StartDate END   
							as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'  
							,Ti.EndDate,TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(Ti.Days,0),0) as 'HoursPerDay',  
							'0.'+SUBSTRING(CAST(Ti.Days AS VARCHAR(20)), CHARINDEX('.', CAST(Ti.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'  
					FROM Common.TimeLogItem as TI  
					LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
				    WHERE ApplyToAll = 1 and  
						  TI.CompanyId=@CompanyId   
						   and  
						    TI.id= @A
						   -- and  
						   -- E.Id= @B   
							--and  
							--EMPDEPT.DEPARTMENTID=@DEPARTMENTID   
						  and StartDate >=@FromDate and StartDate <=@ToDate 
						  and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled') 
					 ) AS P  
					CROSS JOIN  
					   (  
					   SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
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
						    and  
						    E.Id= @B 
							and
						  EMPDEPT.DEPARTMENTID=@DEPARTMENTID  
						) as A
				) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL

			END

			 FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P
		  END
		  CLOSE Year_Count
		  DEALLOCATE Year_Count
				
		SELECT EMPLOYEENAME,STARTDATE,ENDDATE,sum(TOATLHOURS) as 'TOATLHOURS',Sum(IsOverRunHours) As IsOverRunHours,EMPLOYEEID , EMPLOYEEAUTONUMBER,PHOTOURL FROM 
		(
		SELECT EMPLOYEENAME,STARTDATE,ENDDATE,
		       CASE WHEN TOATLHOURS IS NULL THEN 0.00 ELSE TOATLHOURS END AS TOATLHOURS , 
			   CASE WHEN IsOverRunHours IS NULL THEN 0.00 ELSE IsOverRunHours END AS IsOverRunHours,
			   OPTBL.EMPLOYEEID ,EMPLOYEEAUTONUMBER,OPTBL.PHOTOURL 
	    FROM @OUTPUT_DEPARTMENT As OPTBL
		--Inner Join 
		--(Select E.Id As EmployeeId,MR.Small as PHOTOURL 
		-- From Common.Employee As E 
		--      Left Join Common.MediaRepository As MR on Mr.Id=E.PhotoId) As PU1 on PU1.EmployeeId=OPTBL.EMPLOYEEID
		) AS P
		GROUP BY EMPLOYEENAME,STARTDATE,ENDDATE,EMPLOYEEID, EMPLOYEEAUTONUMBER,PHOTOURL
		ORDER BY EMPLOYEENAME , STARTDATE
  END

  ELSE IF @TYPE=2   -- ONLY DESIGNATIONiD
  BEGIN

						DECLARE @START_DATE_DEPARTMENT_DESIGNATION DATE
						DECLARE @Id_DEPARTMENTS UNIQUEIDENTIFIER,@NAMES_DEPARTMENTS NVARCHAR(1000),@FIRSTNAMES_DEPARTMENTS NVARCHAR(100),@Photo_Depertment_Designation UNIQUEIDENTIFIER 
						DECLARE @OUTPUT_DEPARTMENT_DESIGNATION TABLE (EMPLOYEENAME NVARCHAR (1000), STARTDATE DATE,  ENDDATE DATE,TOATLHOURS MONEY,IsOverRunHours Money,EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(2000),PHOTOURL nvarchar(1000))
						DECLARE WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_DESIGNATION_CURSOR CURSOR FOR 
			
						SELECT * FROM FC_WORKWEEK(@FROMDATE,@TODATE)  -- FUNCTION
						OPEN WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_DESIGNATION_CURSOR
						FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_DESIGNATION_CURSOR INTO @START_DATE_DEPARTMENT_DESIGNATION
						WHILE @@FETCH_STATUS=0
						BEGIN       
								DECLARE START_DATE_DEPARTMENT_DESIGNATIONS CURSOR FOR 

								SELECT E.ID,E.FIRSTNAME,E.EMPLOYEEID,e.PhotoId	FROM COMMON.EMPLOYEE E	
								JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID
								 JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID 
								 JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID 
								WHERE 	E.COMPANYID=@COMPANYID AND E.STATUS=1  and e.IsHROnly=1  AND (EMPDEPT.EndDate IS NULL OR EMPDEPT.EndDate>=GETDATE()) 
								AND    DEPTDESIG.ID = @DESIGNATIONID --change 		EMPDEPT.EndDate<=GETDATE() as EMPDEPT.EndDate>=GETDATE()  for single						
								OPEN START_DATE_DEPARTMENT_DESIGNATIONS
								FETCH NEXT FROM START_DATE_DEPARTMENT_DESIGNATIONS INTO @Id_DEPARTMENTS,@NAMES_DEPARTMENTS,@FIRSTNAMES_DEPARTMENTS,@Photo_Depertment_Designation
								WHILE @@FETCH_STATUS=0		  
								BEGIN     
								IF EXISTS(	SELECT @NAMES_DEPARTMENTS,@START_DATE_DEPARTMENT_DESIGNATION,DATEADD(D, 6, @START_DATE_DEPARTMENT_DESIGNATION) AS END_DATE, SUM(DATEDIFF(MINUTE,0,HOURS))/60.0 AS HOURS,
								                   SUM(DATEDIFF(MINUTE,0,IsOverRunHours))/60.0 AS IsOverRunHours,@Id_DEPARTMENTS,@FIRSTNAMES_DEPARTMENTS ,(SELECT TOP 1 Small  FROM Common.MediaRepository WHERE ID=@Photo_Depertment_Designation)  
										    FROM WORKFLOW.SCHEDULETASK WHERE EMPLOYEEID=@Id_DEPARTMENTS 
									             AND STARTDATE <= DATEADD(D, 6, @START_DATE_DEPARTMENT_DESIGNATION) 
									             AND ENDDATE >= @START_DATE_DEPARTMENT_DESIGNATION
									      )
										BEGIN

								  
									INSERT INTO @OUTPUT_DEPARTMENT_DESIGNATION (EMPLOYEENAME, STARTDATE, ENDDATE, TOATLHOURS, IsOverRunHours,EMPLOYEEID, EMPLOYEEAUTONUMBER,PHOTOURL)
									SELECT @NAMES_DEPARTMENTS,@START_DATE_DEPARTMENT_DESIGNATION,DATEADD(D, 6, @START_DATE_DEPARTMENT_DESIGNATION) AS END_DATE, SUM(DATEDIFF(MINUTE,0,HOURS))/60.0 AS HOURS,
									       SUM(DATEDIFF(MINUTE,0,IsOverRunHours))/60.0 AS IsOverRunHours,@Id_DEPARTMENTS,@FIRSTNAMES_DEPARTMENTS ,(SELECT TOP 1 Small  FROM Common.MediaRepository WHERE ID=@Photo_Depertment_Designation)  
								    FROM WORKFLOW.SCHEDULETASK WHERE EMPLOYEEID=@Id_DEPARTMENTS 
									AND STARTDATE <= DATEADD(D, 6, @START_DATE_DEPARTMENT_DESIGNATION) 
									AND ENDDATE >= @START_DATE_DEPARTMENT_DESIGNATION
									
										END 

										ELSE

										BEGIN 
										INSERT INTO @OUTPUT_DEPARTMENT_DESIGNATION (EMPLOYEENAME, STARTDATE, ENDDATE, TOATLHOURS, IsOverRunHours,EMPLOYEEID, EMPLOYEEAUTONUMBER,PHOTOURL)
									SELECT @NAMES_DEPARTMENTS,@START_DATE_DEPARTMENT_DESIGNATION,DATEADD(D, 6, @START_DATE_DEPARTMENT_DESIGNATION) AS END_DATE, 0 AS HOURS,0 As IsOverRunHours,@Id_DEPARTMENTS,@FIRSTNAMES_DEPARTMENTS ,(SELECT TOP 1 Small  FROM Common.MediaRepository WHERE ID=@Photo_Depertment_Designation)  FROM 
									COMMON.Employee WHERE id=@Id_DEPARTMENTS 
										END
								FETCH NEXT FROM START_DATE_DEPARTMENT_DESIGNATIONS INTO  @Id_DEPARTMENTS,@NAMES_DEPARTMENTS,@FIRSTNAMES_DEPARTMENTS,@Photo_Depertment_Designation
								END 
								CLOSE START_DATE_DEPARTMENT_DESIGNATIONS
								DEALLOCATE START_DATE_DEPARTMENT_DESIGNATIONS	
						FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_DESIGNATION_CURSOR INTO @START_DATE_DEPARTMENT_DESIGNATION
						END 
						CLOSE WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_DESIGNATION_CURSOR
						DEALLOCATE WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_DESIGNATION_CURSOR
						 DECLARE Year_Count cursor for SELECT * FROM @Puja --where hours <> '0.00'
		OPEN Year_Count
		FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P
		WHILE @@FETCH_STATUS = 0
		BEGIN
IF @P ='0.00'
BEGIN
	 INSERT INTO  @OUTPUT_DEPARTMENT_DESIGNATION
	 Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		    Employeeid,Employeeautonumber,PHOTOURL 
	 From 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
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
					Employeeid,Employeeautonumber,Null As PHOTOURL
			 FROM  
				 (
				  SELECT distinct E.FirstName,E.Id as 'Employeeid',
					     E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL',
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
						      DEPTDESIG.ID = @DESIGNATIONID AND
						 -- EMPDEPT.DEPARTMENTID=@DEPARTMENTID and
						  StartDate >=@FromDate and StartDate <=@ToDate
						  and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
				) AS P
			CROSS JOIN
					 (
					  SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate 
					  FROM FC_WORKWEEK(@FROMDATE,@TODATE) 
					 ) AS PP
					) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL
		UNION ALL
		Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		       Employeeid,Employeeautonumber,PHOTOURL 
	    From 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
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
					Employeeid,Employeeautonumber,Null As PHOTOURL
			 FROM  
				 (
				  SELECT distinct  
          CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',  
          CASE WHEN @ToDate < TI.EndDate THEN @ToDate ELSE TI.EndDate END  AS 'EndingDate',  
          TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay' from  
      Common.TimeLogItem as TI  
	  LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
      WHERE  ApplyToAll=1 and
        TI.CompanyId=@CompanyId and  
        TI.id= @A and  
        StartDate >=@FromDate and StartDate <=@ToDate  
		and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
    ) AS P  
   CROSS JOIN  
      (  
       SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate   
       FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
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
	and E.Id= @B and E.IsHROnly=1 and 
         DEPTDESIG.ID = @DESIGNATIONID   
	) as A
					) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL



			END
		ELSE
			BEGIN
			INSERT INTO  @OUTPUT_DEPARTMENT_DESIGNATION	
			Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		Employeeid,Employeeautonumber,PHOTOURL from 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
		 FROM 
			(
			SELECT distinct  startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',
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
  END as 'TotalHours',DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,Null As PHOTOURL
				FROM  
					(
					 SELECT distinct E.FirstName,E.Id as 'Employeeid',
					  E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL',
					 case when @FromDate > StartDate then @FromDate ELSE StartDate END 
						    as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'
						    ,Ti.EndDate,TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',
						    '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(Ti.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'
					 FROM Common.TimeLogItem as TI
					  INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id
					  INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId and E.IsHROnly=1
					  INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID
					  INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID 
				      INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID 
					  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
					  LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
					 where ApplyToAll <>1 and
						 E.CompanyId=@CompanyId 
						 and
						  TI.id= @A and
						  E.Id= @B AND
						 DEPTDESIG.ID = @DESIGNATIONID 
						and StartDate >=@FromDate and StartDate <=@ToDate
						and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
					) AS P
				CROSS JOIN
						 (
							SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE) 
						 ) AS PP
				) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL
			UNION ALL
			Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		Employeeid,Employeeautonumber,PHOTOURL from 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
		 FROM 
			(
			SELECT distinct  startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',
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
  END as 'TotalHours',DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,Null As PHOTOURL
				FROM  
					(
					 SELECT DISTINCT case when @FromDate > StartDate then @FromDate ELSE StartDate END   
							as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'  
							,Ti.EndDate,TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(Ti.Days,0),0) as 'HoursPerDay',  
							'0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'  
					FROM Common.TimeLogItem as TI 
					LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id 
				    WHERE ApplyToAll = 1 and  
						  TI.CompanyId=@CompanyId   
						   and  
						    TI.id= @A
						   -- and  
						   -- E.Id= @B   
							--and  
							--EMPDEPT.DEPARTMENTID=@DEPARTMENTID   
						  and StartDate >=@FromDate and StartDate <=@ToDate  
						  and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
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
						where E.CompanyId=@CompanyId and E.IsHROnly=1
						    and  
						    E.Id= @B 
							and
						   DEPTDESIG.ID = @DESIGNATIONID
						) as A
				) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL

			END

			 FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P
		  END
		  CLOSE Year_Count
		  DEALLOCATE Year_Count
		
		SELECT EMPLOYEENAME,STARTDATE,ENDDATE,sum(TOATLHOURS) as 'TOATLHOURS',sum(IsOverRunHours) As IsOverRunHours,EMPLOYEEID , EMPLOYEEAUTONUMBER,PHOTOURL FROM 
		(
			SELECT EMPLOYEENAME,STARTDATE,ENDDATE,
			       CASE WHEN TOATLHOURS IS NULL THEN 0.00 ELSE TOATLHOURS END AS TOATLHOURS ,
				   CASE WHEN IsOverRunHours IS NULL THEN 0.00 ELSE IsOverRunHours END AS IsOverRunHours,
				   OPUL.EMPLOYEEID , EMPLOYEEAUTONUMBER,OPUL.PHOTOURL 
			FROM @OUTPUT_DEPARTMENT_DESIGNATION As OPUL
			--Inner Join 
			--(Select E.id As EmployeeId,small As PHOTOURL
			-- From Common.employee As E 
			--      Inner Join Common.MediaRepository AS MR on Mr.Id=E.PhotoId) As PU2 on PU2.EmployeeId=OPUL.EMPLOYEEID
		) AS P
		GROUP BY EMPLOYEENAME,STARTDATE,ENDDATE,EMPLOYEEID, EMPLOYEEAUTONUMBER,PHOTOURL
		ORDER BY EMPLOYEENAME , STARTDATE
  END


   ELSE IF @TYPE=3   --  ONLY  EMPLOYEEID
  BEGIN  
						DECLARE @START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID DATE
						DECLARE @Id_DEPARTMENTS_EMPLOYEE UNIQUEIDENTIFIER,@NAMES_DEPARTMENTS_EMPLOYEE NVARCHAR(1000),@FIRSTNAMES_DEPARTMENTS_EMPLOYEE NVARCHAR(1000),@PhotoIdS UNIQUEIDENTIFIER 
						DECLARE @OUTPUT_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID TABLE (EMPLOYEENAME NVARCHAR (1000), STARTDATE DATE,  ENDDATE DATE,TOATLHOURS MONEY,IsOverRunHours Money,EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(2000),PHOTOURL NVARCHAR(1000))
						DECLARE WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_DESIGNATION_EMPLOYEEID_CURSOR CURSOR FOR 
						SELECT * FROM FC_WORKWEEK(@FROMDATE,@TODATE)  --FUNCTION
						OPEN WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_DESIGNATION_EMPLOYEEID_CURSOR
						FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_DESIGNATION_EMPLOYEEID_CURSOR INTO @START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID
						WHILE @@FETCH_STATUS=0
			 
							BEGIN       

							DECLARE START_DATE_DEPARTMENT_DESIGNATIONS_EMPLOYEESS CURSOR FOR 
								SELECT E.ID,E.FIRSTNAME,E.EMPLOYEEID,e.PhotoId	FROM COMMON.EMPLOYEE E	WHERE ID=@EMPLOYEEID AND STATUS=1  and e.IsHROnly=1									
								OPEN START_DATE_DEPARTMENT_DESIGNATIONS_EMPLOYEESS
								FETCH NEXT FROM START_DATE_DEPARTMENT_DESIGNATIONS_EMPLOYEESS INTO @Id_DEPARTMENTS_EMPLOYEE,@NAMES_DEPARTMENTS_EMPLOYEE,@FIRSTNAMES_DEPARTMENTS_EMPLOYEE,@PhotoIdS
								WHILE @@FETCH_STATUS=0		  
								BEGIN  
								
								IF EXISTS (SELECT @NAMES_DEPARTMENTS_EMPLOYEE,@START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID,DATEADD(D, 6, @START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID) AS END_DATE,
								                  SUM(DATEDIFF(MINUTE,0,HOURS))/60.0 AS HOURS,SUM(DATEDIFF(MINUTE,0,IsOverRunHours))/60.0 AS IsOverRunHours,@Id_DEPARTMENTS_EMPLOYEE,@FIRSTNAMES_DEPARTMENTS_EMPLOYEE 
										   FROM WORKFLOW.SCHEDULETASK WHERE EMPLOYEEID=@Id_DEPARTMENTS_EMPLOYEE 
									            AND STARTDATE <= DATEADD(D, 6, @START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID) 
									            AND ENDDATE >= @START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID
								)

										BEGIN 

								     
									INSERT INTO @OUTPUT_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID (EMPLOYEENAME, STARTDATE, ENDDATE, TOATLHOURS, IsOverRunHours,EMPLOYEEID, EMPLOYEEAUTONUMBER)
									SELECT @NAMES_DEPARTMENTS_EMPLOYEE,@START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID,DATEADD(D, 6, @START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID) AS END_DATE, SUM(DATEDIFF(MINUTE,0,HOURS))/60.0 AS HOURS,
									       SUM(DATEDIFF(MINUTE,0,IsOverRunHours))/60.0 AS IsOverRunHours,@Id_DEPARTMENTS_EMPLOYEE,@FIRSTNAMES_DEPARTMENTS_EMPLOYEE 
									FROM WORKFLOW.SCHEDULETASK WHERE EMPLOYEEID=@Id_DEPARTMENTS_EMPLOYEE 
									     AND STARTDATE <= DATEADD(D, 6, @START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID) 
									     AND ENDDATE >= @START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID
									
										END

										ELSE

										BEGIN 
											INSERT INTO @OUTPUT_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID (EMPLOYEENAME, STARTDATE, ENDDATE, TOATLHOURS,IsOverRunHours, EMPLOYEEID, EMPLOYEEAUTONUMBER)
									SELECT @NAMES_DEPARTMENTS_EMPLOYEE,@START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID,DATEADD(D, 6, @START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID) AS END_DATE, 0 AS HOURS,0 As IsOverRunHours,@Id_DEPARTMENTS_EMPLOYEE,@FIRSTNAMES_DEPARTMENTS_EMPLOYEE FROM 
									COMMON.EMPLOYEE WHERE id=@Id_DEPARTMENTS_EMPLOYEE
										END

								FETCH NEXT FROM START_DATE_DEPARTMENT_DESIGNATIONS_EMPLOYEESS INTO  @Id_DEPARTMENTS_EMPLOYEE,@NAMES_DEPARTMENTS_EMPLOYEE,@FIRSTNAMES_DEPARTMENTS_EMPLOYEE,@PhotoIdS
								END 
								CLOSE START_DATE_DEPARTMENT_DESIGNATIONS_EMPLOYEESS
								DEALLOCATE START_DATE_DEPARTMENT_DESIGNATIONS_EMPLOYEESS			

							FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_DESIGNATION_EMPLOYEEID_CURSOR INTO @START_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID
							END 
						CLOSE WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_DESIGNATION_EMPLOYEEID_CURSOR
						DEALLOCATE WORKWEEK_EMPLOYEE_HOURS_DEPARTMENT_DESIGNATION_EMPLOYEEID_CURSOR
						 DECLARE Year_Count cursor for SELECT * FROM @Puja --where hours <> '0.00'
		OPEN Year_Count
		FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P
		WHILE @@FETCH_STATUS = 0
		BEGIN
IF @P ='0.00'
BEGIN
	 INSERT INTO  @OUTPUT_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID
	 Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		Employeeid,Employeeautonumber,PHOTOURL from 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
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
					Employeeid,Employeeautonumber,PHOTOURL
			 FROM  
				 (
				  SELECT distinct E.FirstName,E.Id as 'Employeeid',
					     E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL',
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
						E.ID=@EMPLOYEEID AND
						  StartDate >=@FromDate and StartDate <=@ToDate
						  and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
				) AS P
			CROSS JOIN
					 (
					  SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate 
					  FROM FC_WORKWEEK(@FROMDATE,@TODATE) 
					 ) AS PP
					) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL
			UNION ALL
				
		Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		Employeeid,Employeeautonumber,PHOTOURL from 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
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
					Employeeid,Employeeautonumber,PHOTOURL
			 FROM  
				 (
				  SELECT distinct  
          CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',  
          CASE WHEN @ToDate < TI.EndDate THEN @ToDate ELSE TI.EndDate END  AS 'EndingDate',  
          TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay' from  
      Common.TimeLogItem as TI 
	  LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id 
      WHERE  ApplyToAll=1 and
        TI.CompanyId=@CompanyId and  
        TI.id= @A and  
        StartDate >=@FromDate and StartDate <=@ToDate  
		and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
    ) AS P  
   CROSS JOIN  
      (  
       SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate   
       FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
      ) AS PP 
	CROSS JOIN
	(
	select E.FirstName,E.Id as 'Employeeid',  
          E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL'  from Common.Employee as E
	 INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
      INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
      INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
      LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
	where E.CompanyId=@CompanyId and E.IsHROnly=1
	and E.Id= @B and  
        E.ID=@EMPLOYEEID  
	) as A
					) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL
			END
		ELSE
			BEGIN
			INSERT INTO  @OUTPUT_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID	
			Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		Employeeid,Employeeautonumber,PHOTOURL from 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
		 FROM 
			(
			SELECT distinct  startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',
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
  END as 'TotalHours',DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,PHOTOURL
				FROM  
					(
					 SELECT distinct E.FirstName,E.Id as 'Employeeid',
					  E.EmployeeId as 'Employeeautonumber',MR.Small as 'PHOTOURL',
					 case when @FromDate > StartDate then @FromDate ELSE StartDate END 
						    as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'
						    ,Ti.EndDate,Ti.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',
						    '0.'+SUBSTRING(CAST(Ti.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'
					 FROM Common.TimeLogItem as TI
					  INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id
					  INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId and E.IsHROnly=1
					  INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID
					  INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID 
				      INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID 
					  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
					  LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
					 where ApplyToAll <>1 and
						 E.CompanyId=@CompanyId 
						 and
						  TI.id= @A and
						  E.Id= @B AND
						 E.ID=@EMPLOYEEID
						and StartDate >=@FromDate and StartDate <=@ToDate
						and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
					) AS P
				CROSS JOIN
						 (
							SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE) 
						 ) AS PP
				) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL
			UNION ALL
			Select FirstName as 'EMPLOYEENAME',StartDate,Enddate,sum(TotalHours) as 'TotalHours',0 As IsOverRunHours,
		Employeeid,Employeeautonumber,PHOTOURL from 
		(
		 Select FirstName,StartDate,Enddate,case when EndingDate < StartDate then '0.00'
			    else coalesce(TotalHours,0) END as 'TotalHours',
				Employeeid,Employeeautonumber,PHOTOURL
		 FROM 
			(
			SELECT distinct  startingdate,EndingDate,FirstName,FromDate as 'StartDate',Todate as 'ENDDATE',
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
				END as 'TotalHours',DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,PHOTOURL
				FROM  
					(
					 SELECT DISTINCT case when @FromDate > StartDate then @FromDate ELSE StartDate END   
							as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'  
							,Ti.EndDate,TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',  
							'0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(Ti.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'  
					FROM Common.TimeLogItem as TI 
					LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id 
				    WHERE ApplyToAll = 1 and  
						  TI.CompanyId=@CompanyId   
						   and  
						    TI.id= @A
						   -- and  
						   -- E.Id= @B   
							--and  
							--EMPDEPT.DEPARTMENTID=@DEPARTMENTID   
						  and StartDate >=@FromDate and StartDate <=@ToDate 
						  and SystemType not in ('CaseGroup','WorkWeekSetup')
			  and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled') 
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
						where E.CompanyId=@CompanyId and E.IsHROnly=1
						    and  
						    E.Id= @B 
							and
						   E.ID=@EMPLOYEEID
						) as A
				) AS P
					) AS P
			Group by FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL


			END

			 FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P
		  END
		  CLOSE Year_Count
		  DEALLOCATE Year_Count
	SELECT EMPLOYEENAME,STARTDATE,ENDDATE,sum(TOATLHOURS) as 'TOATLHOURS',Sum(IsOverRunHours) As IsOverRunHours,EMPLOYEEID , EMPLOYEEAUTONUMBER,PHOTOURL FROM 
		(
SELECT EMPLOYEENAME,STARTDATE,ENDDATE,CASE WHEN TOATLHOURS IS NULL THEN 0.00 ELSE TOATLHOURS END AS TOATLHOURS ,
        CASE WHEN IsOverRunHours IS NULL THEN 0.00 ELSE IsOverRunHours END AS IsOverRunHours,
		OPURLPT.EMPLOYEEID , EMPLOYEEAUTONUMBER,OPURLPT.PHOTOURL 
FROM @OUTPUT_DATE_DEPARTMENT_DESIGNATION_EMPLOYEEID As OPURLPT
--Inner Join
--(Select E.Id As EmployeeId,Small As PHOTOURL
-- From Common.Employee As E
--      Left Join Common.MediaRepository As MR On Mr.Id=E.PhotoId) As PU3 on PU3.EmployeeId=OPURLPT.EMPLOYEEID

) AS P
		GROUP BY EMPLOYEENAME,STARTDATE,ENDDATE,EMPLOYEEID, EMPLOYEEAUTONUMBER,PHOTOURL
		ORDER BY EMPLOYEENAME , STARTDATE


  END
  END
GO
