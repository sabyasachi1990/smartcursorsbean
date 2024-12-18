USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_Both_PendingOpportunity]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_Both_PendingOpportunity]
(
    @FROMDATE DATE,
    @TODATE DATE, 
	@COMPANYID BIGINT, 
	@EMPLOYEEID UNIQUEIDENTIFIER )
AS BEGIN
     /***  AUTHER  :   Sreenivasulu G     20-10-2016***/
		DECLARE @START_DATE DATE
		 DECLARE  @Puja  TABLE (id uniqueidentifier, Employeeid uniqueidentifier,FromDate datetime,ToDate Datetime,hours decimal(10,2))  
  DECLARE @A  uniqueidentifier,@B uniqueidentifier,@C Datetime,@D Datetime,@P decimal(10,2)  
   
  INSERT INTO @Puja  
  SELECT DISTINCT TI.Id,TD.EmployeeId,  
      CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',  
      CASE WHEN @ToDate < EndDate THEN @ToDate ELSE EndDate END  AS 'EndingDate',  
      '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'hoursdays'  
  FROM Common.TimeLogItem as TI  
    INNER JOIN Common.TimeLogItemDetail as TD ON  TD.TimelogitemId=TI.Id  
	Inner join WorkFlow.CaseGroup as Cg on cg.id=Ti.SystemId
    INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId  
	inner join ClientCursor.Opportunity As Opp on Opp.Id=Cg.OpportunityId
	--LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id  
  WHERE ApplyToAll <>1 and  
     E.CompanyId=@CompanyId and  
	 Opp.Stage='Pending' and
        E.Id=@EMPLOYEEID and
     StartDate >=@FromDate and StartDate <=@ToDate --and SystemType not in ('CaseGroup','WorkWeekSetup') 
	  --and case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')
   UNION ALL  
     SELECT distinct TI.Id, A.Employeeid,   
      CASE WHEN @FromDate > StartDate THEN @FromDate ELSE StartDate END as 'StartingDate',    
         CASE WHEN @ToDate < EndDate THEN @ToDate ELSE EndDate END  AS 'EndingDate',    
            '0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'hoursdays'    
     FROM Common.TimeLogItem as TI   
		Inner Join WorkFlow.CaseGroup As CG on CG.Id=TI.SystemId
		Inner Join ClientCursor.Opportunity As Opp on Opp.Id=CG.OpportunityId 
	 --LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id  
  CROSS JOIN  
      (  
     select E.Id as 'Employeeid'   from Common.Employee as E  
     where E.CompanyId=@CompanyId  
	 and E.Id=@EMPLOYEEID
      ) as A  
  WHERE ApplyToAll =1 and    
     TI.CompanyId=@CompanyId and  
	 opp.Stage='Pending' and
	    --case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled')  and
		 --SystemType not in ('CaseGroup','WorkWeekSetup') and
   --TI.id in ('78CC6BCA-4FD1-4768-9B40-FC46495550F1') and    
     StartDate >=@FromDate and StartDate <=@ToDate  

		DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),CASENAME NVARCHAR(1000), STARTDATE DATE,  ENDDATE DATE,TOATLHOURS MONEY,ISOVERRUNHOURS Money,CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000), SCHEDULETYPEID UNIQUEIDENTIFIER NULL, SCHEDULETYPE NVARCHAR(100), IsActualHrs bit)   -- ScheduleTypeid means Calender / LeaveApplication Id - Added by SSK)
		--DECLARE WORKWEEK_EMPLOYEE_HOURS_CURSOR CURSOR FOR 

		--	SELECT * FROM FC_WORKWEEK(@FROMDATE,@TODATE)  
		--		OPEN WORKWEEK_EMPLOYEE_HOURS_CURSOR
		--		FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_CURSOR INTO @START_DATE
		--		WHILE @@FETCH_STATUS=0
		--		BEGIN  
				     
		--			INSERT INTO @OUTPUT (EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,STARTDATE,ENDDATE,TOATLHOURS,ISOVERRUNHOURS,CASEID,PHOTOURL)										    
		--				SELECT E.FIRSTNAME AS EMPLOYEENAME, E.ID AS EMPLOYEENO, E.EMPLOYEEID AS EMPLOYEENUMBER,C.NAME AS CLIENTNAME ,CG.SYSTEMREFNO AS CASENUMBER, 
		--				       C.NAME AS CASENAME,@START_DATE AS START_DATE,DATEADD(D, 6, @START_DATE) AS END_DATE,SUM(DATEDIFF(MINUTE,0,HOURS))/60.0 AS TOTALHOURS,
		--				       SUM(DATEDIFF(MINUTE,0,IsOverRunHours))/60.0 AS ISOVERRUNHOURS,CG.Id AS CASEID,
		--				       E.PhotoId AS PHOTOURL  
		--			    FROM COMMON.EMPLOYEE E 
		--				     LEFT JOIN WORKFLOW.SCHEDULETASK SCH ON E.ID=SCH.EMPLOYEEID 
		--				     JOIN WORKFLOW.CASEGROUP CG ON CG.ID=SCH.CASEID
		--				     JOIN WORKFLOW.CLIENT C ON C.ID=CG.CLIENTID
		--				WHERE SCH.STARTDATE <= DATEADD(D, 6, @START_DATE) 
		--				      AND SCH.ENDDATE >= @START_DATE 
		--				      AND SCH.COMPANYID = @COMPANYID
		--				      AND E.ID=@EMPLOYEEID 
		--				      --AND SCH.ISOVERRUN is null--ISOVERRUN
		--				GROUP BY SCH.CASEID, E.FIRSTNAME, E.EMPLOYEEID, E.ID, C.NAME, CG.SYSTEMREFNO,CG.Id,E.PhotoId
	
		--		FETCH NEXT FROM WORKWEEK_EMPLOYEE_HOURS_CURSOR INTO @START_DATE
		--		END 
		--CLOSE WORKWEEK_EMPLOYEE_HOURS_CURSOR
		--DEALLOCATE WORKWEEK_EMPLOYEE_HOURS_CURSOR
	
 DECLARE Year_Count cursor for SELECT * FROM @Puja --where hours <> '0.00'  
  OPEN Year_Count  
  FETCH NEXT FROM Year_Count INTO @A,@B,@C,@D,@P  
  WHILE @@FETCH_STATUS = 0  
  BEGIN  
IF @P ='0.00'  
BEGIN  
INSERT INTO @OUTPUT (EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,STARTDATE,ENDDATE,TOATLHOURS,CASEID,PHOTOURL,SCHEDULETYPEID, SCHEDULETYPE)	
SELECT FirstName as 'EMPLOYEENAME',Employeeid,Employeeautonumber,Subtype,Subtype,null,StartDate,Enddate,
		sum(TotalHours) as 'TotalHours','00000000-0000-0000-0000-000000000000', PHOTOURL, SystemId, SystemType 
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
					Inner Join WorkFlow.CaseGroup As CG on CG.Id=TI.SystemId
					Inner Join ClientCursor.Opportunity As Opp on Opp.Id=CG.OpportunityId 
				   INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId  
				   INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
				   INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
				   INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
				   LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId 
				   --LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id  
			WHERE  --case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END not in ('Approve Cancelled','Rejected','Cancelled') and
					--SystemType not in ('CaseGroup','WorkWeekSetup') and
				    ApplyToAll <>1 AND  
				    E.CompanyId=@CompanyId AND  
					Opp.Stage='Pending' and
				    TI.id= @A and  
				    E.Id= @B and  
				    E.ID=@EMPLOYEEID AND  
				    StartDate >=@FromDate and StartDate <=@ToDate  
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
 SELECT FirstName as 'EMPLOYEENAME',Employeeid,Employeeautonumber,Subtype,Subtype,null,StartDate,Enddate,
		SUM(TotalHours) as 'TotalHours','00000000-0000-0000-0000-000000000000', PHOTOURL, SystemId, SystemType from 
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
					   		Inner Join WorkFlow.CaseGroup As CG on CG.Id=TI.SystemId
							Inner Join ClientCursor.Opportunity As Opp on Opp.Id=CG.OpportunityId
					   --LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id  
		
				       WHERE ApplyToAll = 1 and 
					      --case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
						  --not in ('Approve Cancelled','Rejected','Cancelled')  and 
						  --SystemType not in ('CaseGroup','WorkWeekSetup') and
						     TI.CompanyId=@CompanyId 
						   and  
						    TI.id= @A 
							and opp.Stage='Pending'
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
			INSERT INTO @OUTPUT (EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,STARTDATE,ENDDATE,TOATLHOURS,
			CASEID,
			PHOTOURL, SCHEDULETYPEID, SCHEDULETYPE)	
			 Select FirstName as 'EMPLOYEENAME',Employeeid,Employeeautonumber,Subtype,Subtype,null,StartDate,Enddate,
		SUM(TotalHours) as 'TotalHours','00000000-0000-0000-0000-000000000000', PHOTOURL, SystemId, SystemType as IsActualHrs  from   
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
    ----CASE WHEN EndingDate <= Todate then (datediff(DAY,FromDate,EndingDate))   
    ----WHEN  startingdate <= Todate  then (datediff(DAY,StartingDate,Todate)+1) END as Date,  
    --CASE WHEN EndDate > @ToDate Then   
    --CASE WHEN   EndingDate < Fromdate   then '0.00'  
    --WHEN EndingDate <= Todate  then (datediff(DAY,StartingDate,EndingDate)) *HoursPerDay   
    --WHEN startingdate < Todate  then (datediff(DAY,StartingDate,EndingDate)+1) * HoursPerDay  
    --END   
    --WHEN  EndDate < @ToDate and DaysPoints='0.00'  
    --THEN CASE WHEN   EndingDate < Fromdate   then '0.00'  
    --WHEN EndingDate <= Todate  then (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay   
    --WHEN startingdate < Todate  then (datediff(DAY,StartingDate,EndingDate)+1) * HoursPerDay  
    --END  
    --ELSE  
    --CASE WHEN   EndingDate < Fromdate   then '0.00'  
    -- WHEN EndingDate <= Todate  then (datediff(DAY,StartingDate,EndingDate)) *HoursPerDay + DaysPoints * HoursPerDay  
    --WHEN startingdate < Todate  then (datediff(DAY,StartingDate,EndingDate)+1) * HoursPerDay  
    --END END as TotalHours,
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
	   		Inner Join WorkFlow.CaseGroup As CG on CG.Id=TI.SystemId
		Inner Join ClientCursor.Opportunity As Opp on Opp.Id=CG.OpportunityId 
       INNER JOIN Common.Employee as E ON E.Id=TD.EmployeeId  
       INNER JOIN HR.EMPLOYEEDEPARTMENT EMPDEPT ON E.ID=EMPDEPT.EMPLOYEEID  
       INNER JOIN COMMON.DEPARTMENT DEPT ON DEPT.ID=EMPDEPT.DEPARTMENTID   
          INNER JOIN COMMON.DEPARTMENTDESIGNATION DEPTDESIG ON DEPTDESIG.ID=EMPDEPT.DEPARTMENTDESIGNATIONID   
       LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
      --  and SystemType not in ('LeaveApplication') 
	   --LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
      where ApplyToAll <>1  and --case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
	  --not in ('Approve Cancelled','Rejected','Cancelled')  and
	  --SystemType not in ('CaseGroup','WorkWeekSetup') and
       E.CompanyId=@CompanyId
	   and opp.Stage='Pending'   
       and  
        TI.id= @A and  
        E.Id= @B   
        and  E.Id=@EMPLOYEEID
        --EMPDEPT.DEPARTMENTID=@DEPARTMENTID   
      and StartDate >=@FromDate and StartDate <=@ToDate    
     ) AS P  
    CROSS JOIN  
       (  
       SELECT STARTDATE as FromDate,DATEADD(D, 6, STARTDATE) as Todate FROM FC_WORKWEEK(@FROMDATE,@TODATE)   
       ) AS PP  
    ) AS P  
     ) AS P  
   Group by Subtype,FirstName,StartDate,Enddate,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType 
   UNION ALL
   Select FirstName as 'EMPLOYEENAME',Employeeid,Employeeautonumber,Subtype,Subtype,null,StartDate,Enddate,
		SUM(TotalHours) as 'TotalHours','00000000-0000-0000-0000-000000000000', PHOTOURL, SystemId, SystemType from    -- SystemId added SSK
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
				----CASE WHEN EndingDate <= Todate then (datediff(DAY,FromDate,EndingDate)) 
				----WHEN  startingdate <= Todate  then (datediff(DAY,StartingDate,Todate)+1) END as Date,
				--CASE WHEN EndDate > @ToDate Then 
				--CASE WHEN   EndingDate < Fromdate   then '0.00'
				--WHEN EndingDate <= Todate  then (datediff(DAY,StartingDate,EndingDate)) *HoursPerDay 
				--WHEN startingdate < Todate  then (datediff(DAY,StartingDate,EndingDate)+1) * HoursPerDay
				--END 
				--WHEN  EndDate < @ToDate and DaysPoints='0.00'
				--THEN CASE WHEN   EndingDate < Fromdate   then '0.00'
				--WHEN EndingDate <= Todate  then (datediff(DAY,StartingDate,EndingDate)+1) *HoursPerDay 
				--WHEN startingdate < Todate  then (datediff(DAY,StartingDate,EndingDate)+1) * HoursPerDay
				--END
				--ELSE
				--CASE WHEN   EndingDate < Fromdate   then '0.00'
				-- WHEN EndingDate <= Todate  then (datediff(DAY,StartingDate,EndingDate)) *HoursPerDay + DaysPoints * HoursPerDay
				--WHEN startingdate < Todate  then (datediff(DAY,StartingDate,EndingDate)+1) * HoursPerDay
				--END END as TotalHours,
				DaysPoints,HoursPerDay,Employeeid,Employeeautonumber,PHOTOURL, SystemId, SystemType -- SystemId added SSK
				FROM  
					(
					 SELECT DISTINCT Subtype, SystemId, SystemType,case when @FromDate > StartDate then @FromDate ELSE StartDate END   
							as 'StartingDate',case when @ToDate < TI.EndDate then @ToDate ELSE Ti.EndDate END  AS 'EndingDate'  
							,Ti.EndDate,TI.Hours,TI.Days,isnull(nullif(TI.Hours,0)/nullif(TI.Days,0),0) as 'HoursPerDay',  
							'0.'+SUBSTRING(CAST(TI.Days AS VARCHAR(20)), CHARINDEX('.', CAST(TI.Days AS VARCHAR(20))) + 1, 2) as 'DaysPoints'  
					FROM Common.TimeLogItem as TI 
							Inner Join WorkFlow.CaseGroup As CG on CG.Id=TI.SystemId
		Inner Join ClientCursor.Opportunity As Opp on Opp.Id=CG.OpportunityId
					 --LEFT JOIN  hr.LeaveApplication la on ti.SystemId = la.Id
					 WHERE     --case when LeaveStatus is null then 'NULL' ELSE LeaveStatus END 
					 --not in ('Approve Cancelled','Rejected','Cancelled')   and 
					 --SystemType not in ('CaseGroup','WorkWeekSetup') and
				     ApplyToAll = 1 and  
						  TI.CompanyId=@CompanyId 
						  and opp.Stage='Pending'
						   and  TI.id= @A  
						   and StartDate >=@FromDate and StartDate <=@ToDate  
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

		SELECT EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,STARTDATE,ENDDATE,SUm(TOATLHOURS) as TOATLHOURS,Sum(Isnull(IsOverRunHours,0)) As ISOVERRUNHOURS ,CASEID,PHOTOURL,SCHEDULETYPEID, SCHEDULETYPE , 0 as IsActualHrs
		FROM @OUTPUT Where CASEID <> '00000000-0000-0000-0000-000000000000'
		GROUP BY EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,STARTDATE,ENDDATE,CASEID,PHOTOURL,SCHEDULETYPEID,SCHEDULETYPE
		ORDER BY CASENUMBER  -- Old condition

		--SELECT EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,STARTDATE,ENDDATE,SUm(TOATLHOURS) as TOATLHOURS,Sum(Isnull(IsOverRunHours,0)) As ISOVERRUNHOURS ,CASEID,PHOTOURL,SCHEDULETYPEID, SCHEDULETYPE 
		----FROM @OUTPUT where (((SCHEDULETYPE ='Calender' or SCHEDULETYPE IS NULL) and (TOATLHOURS NOT IN ('0.00') or TOATLHOURS IS NULL)
		--FROM @OUTPUT where ((SCHEDULETYPE ='Calender' AND TOATLHOURS !='0.00') OR (SCHEDULETYPE ='Calender' AND TOATLHOURS IS NULL) OR (SCHEDULETYPE !='Calender' OR SCHEDULETYPE IS NULL)) 
		--GROUP BY EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,CASENAME,STARTDATE,ENDDATE,CASEID,PHOTOURL,SCHEDULETYPEID,SCHEDULETYPE
		--ORDER BY CASENUMBER   -- New condition added by SSK


END
GO
