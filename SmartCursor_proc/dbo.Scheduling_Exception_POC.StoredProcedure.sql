USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Scheduling_Exception_POC]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    --CREATE TYPE [dbo].[TempschedulingException] AS TABLE(
    --[FromEmpId] uniqueIdentifier NOT NULL,
    --[ToEmpId] uniqueIdentifier NOT NULL,
    --[ToEmployeeStartDate] Datetime NOT NULL)  
  
---->> EXEC [dbo].[Scheduling_Exception_POC] 1,'4cd52251-421a-5f94-ba66-3f81e1ae33b4','cc51ac0e-6226-4965-a22f-40ffc6f43d43','2023-05-12','01c1a0db-cb14-4869-aa40-bef15a129d3a'    
  
CREATE PROCEDURE [dbo].[Scheduling_Exception_POC]     
    (@CompanyId Int,@FromCaseId Uniqueidentifier,@TempschedulingException TempschedulingException ReadOnly)   
  
AS    
BEGIN  
  
--DECLARE  
--@CompanyId Int = null,  
--@FromemployeeId Uniqueidentifier = 'c7ad9756-ce7c-40ec-a34c-47c5b9c22ea2',  
--@ToemployeeId Uniqueidentifier = '6543829e-350d-40fb-9fce-f26287939542',    
--@FromDate Date = '2023-04-05',  
--@FromCaseId Uniqueidentifier ='055106a8-61ae-4a19-9d11-cc67e1d23f56'    


CREATE TABLE #DateTempTable   
(  
CompanyId Int,  
FromemployeeId Uniqueidentifier,  
FromCaseId Uniqueidentifier,  
FromStartDate datetime2,  
FromEndDate datetime2,  
[WeekOrder] int  
)  
  
DECLARE  @ToEmployee TABLE (ToStartDate datetime2,ToEndDate datetime2,weekText varchar(25),[WeekOrder] INT)  
  
DECLARE @ScheduleStartDate Date,@ScheduleEndDate Date , @24hrsStatus Nvarchar(20),@WeeklyWorkHours BigInt,                
    @ErrorMsg Nvarchar(500),@fromEmployeePlannedhours bigint, @toEmployeePlannedhours Bigint, @workweekdays int,    
    @Exception_Count int   ,@FromDate Datetime,@FromemployeeId uniqueIdentifier,@ToemployeeId uniqueIdentifier
  
DECLARE @EmpName Nvarchar(200),@StartDate DateTime2, @EndDate DateTime2,  @TotalHours BigInt   
  
SET @Exception_Count=0    
SET @CompanyId  = (SELECT CASE WHEN @CompanyId IS NULL THEN (SELECT CompanyId FROM WorkFlow.CaseGroup WHERE Id = @FromCaseId )  
     ELSE @CompanyId  
     END AS CompanyId)
	 

Declare copyEmployeesCursor Cursor For          
                   
    SELECT FromEmpId,ToEmpId,  ToEmployeeStartDate            
    FROM @TempschedulingException                   
                      
        Open copyEmployeesCursor          
         Fetch Next From copyEmployeesCursor Into    @FromemployeeId, @ToemployeeId , @FromDate  
      While @@FETCH_STATUS=0          
   Begin  


SET @ScheduleStartDate = @FromDate          
SET @24hrsStatus = (SELECT IsAllowTwentyFourHours FROM common.FeeRecoverySetting WHERE CompanyId = @CompanyId)     
SET @workweekdays=(Select COUNT(Id) from Common.WorkWeekSetUp where CompanyId=@CompanyId and IsWorkingDay=1 and EmployeeId is null)    
SET @WeeklyWorkHours =          
                      (          
                       SELECT              
                        SUM(WorkingHoursMinutes) as WeeklyWorkingHours          
                       FROM          
                       (          
                       SELECT  Id,(DATEPART(HOUR, WorkingHours)*60) + (DATEPART(MINUTE, WorkingHours)) as WorkingHoursMinutes           
                       FROM           
                        Common.WorkWeekSetUp         
                       WHERE CompanyId = @CompanyId and IsWorkingDay=1   and EmployeeId is null    
                       ) A   )   
  
  
SET @ScheduleStartDate = (SELECT MIN(StartDate) FROM WorkFlow.ScheduleTaskNew WHERE CaseId = @FromCaseId)  
  
SET @ScheduleEndDate =     
                        (    
                            SELECT          
                                MAX(ST.StartDate) AS StartDate         
                            FROM WorkFlow.ScheduleTaskNew  as ST      
                            JOIN WorkFlow.CaseGroup as cg      
                                ON st.CaseId=cg.Id      
                            WHERE  cg.CompanyId = @CompanyId and ST.EmployeeId = @FromemployeeId       
                                AND cg.Id = @FromCaseId    
                        )   
  
;WITH cte AS          
    (          
      SELECT DATEADD(WEEK, DATEDIFF(WEEK, 0, @ScheduleStartDate), 0) AS FromStartDate,     
             DATEADD(wk, DATEDIFF(wk, 0, @ScheduleStartDate), @workweekdays) FromEndDate          
      UNION ALL         
      SELECT     
             DATEADD(ww, 1, FromStartDate),DATEADD(ww, 1, FromEndDate)          
      FROM cte WHERE DATEADD(ww, 1, FromStartDate) <=  @ScheduleEndDate      
    )   
  
  
INSERT INTO #DateTempTable  
SELECT @CompanyId,@FromemployeeId AS FromemployeeId, @FromCaseId AS FromCaseId,FromStartDate,FromEndDate,  
ROW_NUMBER() OVER (ORDER BY FromStartDate) AS [WeekOrder]  
FROM CTE OPTION(MAXRECURSION 0)  
  
  
DECLARE @RowNumber INT = (SELECT MAX([WeekOrder]) FROM #DateTempTable)  
-----=========================== CALLING SP FOR TO EMPLOYEE DATES ===========================-----  
INSERT INTO @ToEmployee  
EXEC Dbo.WeekStartEndDates @FromDate,@workweekdays,@RowNumber  
-----========================================================================================-----  
  
--SELECT * FROM #DateTempTable AS A  
--INNER JOIN  @ToEmployee AS B  
--ON B.[WeekOrder] = A.WeekOrder  
  
SET @ToemployeeId  = (SELECT CASE WHEN @ToemployeeId IS NULL  OR  @ToemployeeId = '00000000-0000-0000-0000-000000000000'   
     THEN @FromemployeeId  
       ELSE @ToemployeeId  
     END )  
  
        DECLARE Scheduling_Cursor Cursor    
        FOR   
  
    SELECT Emp.EmpName,B.ToStartDate,B.ToEndDate,SUM(PlannedHours)  AS TotalHours  
    FROM WorkFlow.ScheduleTaskNew AS ST  
    JOIN WorkFlow.CaseGroup AS cg  ON st.CaseId=cg.Id  
    INNER JOIN (SELECT Id,FirstName AS EmpName FROM Common.Employee WHERE Id = @FromemployeeId) AS Emp   
    ON EMP.Id = ST.EmployeeId  
    INNER JOIN #DateTempTable AS T  
    ON T.CompanyId = ST.CompanyId AND T.FromCaseId = ST.CaseId AND T.FromemployeeId = ST.EmployeeId  
    INNER JOIN  @ToEmployee AS B  
    ON B.[WeekOrder] = T.WeekOrder  
    WHERE ST.StartDate BETWEEN T.FromStartDate AND T.FromEndDate  
    AND EmployeeId = @FromemployeeId AND ST.CaseId = @FromCaseId  
    GROUP BY Emp.EmpName,B.ToStartDate,B.ToEndDate  
  
        OPEN Scheduling_Cursor    
        FETCH NEXT FROM Scheduling_Cursor INTO @EmpName,@StartDate, @EndDate, @TotalHours  
  
  WHILE @@FETCH_STATUS = 0 and @Exception_Count =0    
        BEGIN     
  
  DECLARE @PlannedHours decimal(10,2)  
  SET @PlannedHours= (SELECT                  
         SUM(PlannedHours)               
          FROM              
          (SELECT PlannedHours from WorkFlow.ScheduleNew as sch join WorkFlow.ScheduleDetailNew as schd on sch.Id=schd.MasterId     
     join WorkFlow.ScheduleTaskNew as scht on schd.Id=scht.ScheduleDetailId  
     where scht.StartDate >= @StartDate and     
     scht.EndDate <= @EndDate and scht.EmployeeId = @ToemployeeId and sch.companyId = @CompanyId)A   
     )      
  
  SET @TotalHours = isnull(@PlannedHours,0) + @TotalHours  
  SET @EmpName =(SELECT FirstName FROM Common.Employee WHERE Id = @ToemployeeId)  
  
--SELECT  @EmpName AS EmpName,@StartDate AS StartDate, @EndDate AS EndDate,@TotalHours AS TotalHours,     
--@WeeklyWorkHours AS WeeklyWorkHours,@ScheduleStartDate AS ScheduleStartDate,@workweekdays AS workweekdays                             
  
-----=============================================== EXCEPTION THROWING ===============================================-----                       
     IF  (@24hrsStatus = 1 AND  @TotalHours > @WeeklyWorkHours)     
          BEGIN                         
             SET @ErrorMsg = CONCAT('Planned weekly hours are greater than ' ,CAST(@WeeklyWorkHours/60 AS Decimal(8,2)), ' hours (',@EmpName,'). Do you want to continue?')          
             RAISERROR(@ErrorMsg,16,1);          
             SET @Exception_Count = 1          
       END      
     ELSE IF (@24hrsStatus != 1 AND @TotalHours > 1439)          
          BEGIN          
               SET @ErrorMsg = CONCAT('Invalid time records as daily hours (',@EmpName, ') have exceeded 24 hours ')          
               RAISERROR(@ErrorMsg,16,1);          
             SET @Exception_Count = 1     
          END                                     
-----==================================================================================================================-----         
FETCH NEXT FROM Scheduling_Cursor INTO  @EmpName,@StartDate, @EndDate, @TotalHours     
END     
  
CLOSE Scheduling_Cursor;    
DEALLOCATE Scheduling_Cursor;

DELETE FROM  #DateTempTable
DELETE FROM  @ToEmployee

Fetch Next From copyEmployeesCursor Into    @FromemployeeId, @ToemployeeId , @FromDate 
END
Close copyEmployeesCursor        
Deallocate copyEmployeesCursor
DROP TABLE #DateTempTable    
  
END  
  
  
  
  
  
------==========================================================================================================================----  
  
--------USE [SmartCursorSTG]  
--------GO  
--------/****** Object:  StoredProcedure [dbo].[Scheduling_Exception_POC]    Script Date: 24-04-2023 12:34:18 ******/  
--------SET ANSI_NULLS ON  
--------GO  
--------SET QUOTED_IDENTIFIER ON  
--------GO  
  
  
------------>> EXEC [dbo].[Scheduling_Exception_POC] 1,'4cd52251-421a-5f94-ba66-3f81e1ae33b4','cc51ac0e-6226-4965-a22f-40ffc6f43d43','2023-05-12','01c1a0db-cb14-4869-aa40-bef15a129d3a'    
  
--------ALTER PROCEDURE [dbo].[Scheduling_Exception_POC]     
--------    (@CompanyId Int,@FromemployeeId Uniqueidentifier,@ToemployeeId Uniqueidentifier,    
--------     @FromDate Date,@FromCaseId Uniqueidentifier)   
  
--------AS    
--------BEGIN  
  
--------CREATE TABLE #DateTempTable   
--------(  
--------CompanyId Int,  
--------FromemployeeId Uniqueidentifier,  
--------FromCaseId Uniqueidentifier,  
--------StartDate datetime2,  
--------EndDate datetime2  
--------)  
  
--------DECLARE           
--------    @ScheduleStartDate Date,          
--------    @ScheduleEndDate Date ,          
--------    @24hrsStatus Nvarchar(20),          
--------    @WeeklyWorkHours BigInt,                
--------    @ErrorMsg Nvarchar(500),           
--------    @fromEmployeePlannedhours bigint,      
--------    @toEmployeePlannedhours Bigint,      
--------    @workweekdays int,    
--------    @Exception_Count int   
  
--------DECLARE @EmpName Nvarchar(200),@StartDate DateTime2, @EndDate DateTime2,  @TotalHours BigInt SET @Exception_Count=0    
--------SET @ScheduleStartDate = @FromDate          
--------SET @24hrsStatus = (SELECT IsAllowTwentyFourHours FROM common.FeeRecoverySetting WHERE CompanyId = @CompanyId)     
--------SET @workweekdays=(Select COUNT(Id) from Common.WorkWeekSetUp where CompanyId=@CompanyId and IsWorkingDay=1 and EmployeeId is null)    
--------SET @WeeklyWorkHours =          
--------                      (          
--------                       SELECT              
--------                        SUM(WorkingHoursMinutes) as WeeklyWorkingHours          
--------                       FROM          
--------                       (          
--------                       SELECT  Id,(DATEPART(HOUR, WorkingHours)*60) + (DATEPART(MINUTE, WorkingHours)) as WorkingHoursMinutes           
--------                       FROM           
--------                        Common.WorkWeekSetUp         
--------                       WHERE CompanyId = @CompanyId and IsWorkingDay=1   and EmployeeId is null    
--------                       ) A   )   
  
--------SET @ScheduleEndDate =     
--------                        (    
--------                            SELECT          
--------                                MAX(ST.StartDate) AS StartDate         
--------                            FROM WorkFlow.ScheduleTaskNew  as ST      
--------                            JOIN WorkFlow.CaseGroup as cg      
--------                                ON st.CaseId=cg.Id      
--------                            WHERE  cg.CompanyId = @CompanyId and ST.EmployeeId = @FromemployeeId       
--------                                AND cg.Id=@FromCaseId    
--------                        )   
  
--------;WITH cte AS          
--------    (          
--------      SELECT DATEADD(WEEK, DATEDIFF(WEEK, 0, @ScheduleStartDate), 0) AS StartDate,     
--------             DATEADD(wk, DATEDIFF(wk, 0, @ScheduleStartDate), @workweekdays) EndDate          
--------      UNION ALL         
--------      SELECT     
--------             DATEADD(ww, 1, StartDate),DATEADD(ww, 1, EndDate)          
--------      FROM cte WHERE DATEADD(ww, 1, StartDate) <=  @ScheduleEndDate -- @ScheduleStartDate      
--------    )   
  
  
--------INSERT INTO #DateTempTable  
--------SELECT @CompanyId AS CompanyId, @FromemployeeId AS FromemployeeId, @FromCaseId AS FromCaseId,StartDate,EndDate   
--------FROM CTE OPTION(MAXRECURSION 0)  
   
  
--------        DECLARE Scheduling_Cursor Cursor    
--------        FOR   
  
--------    SELECT Emp.EmpName,T.StartDate,T.EndDate,SUM(PlannedHours)  AS TotalHours FROM WorkFlow.ScheduleTaskNew AS ST  
--------    JOIN WorkFlow.CaseGroup AS cg  ON st.CaseId=cg.Id  
--------    INNER JOIN (SELECT Id,FirstName AS EmpName FROM Common.Employee WHERE Id = @FromemployeeId) AS Emp   
--------    ON EMP.Id = ST.EmployeeId  
--------    INNER JOIN #DateTempTable AS T  
--------    ON T.CompanyId = ST.CompanyId AND T.FromCaseId = ST.CaseId AND T.FromemployeeId = ST.EmployeeId  
--------    WHERE ST.StartDate BETWEEN T.StartDate AND T.EndDate  
--------    AND EmployeeId = @FromemployeeId AND ST.CaseId = @FromCaseId  
--------    GROUP BY Emp.EmpName,T.StartDate,T.EndDate  
  
--------       --SELECT          
--------       --         Emp.EmpName,Temp.StartDate,Temp.EndDate  ,SUM(PlannedHours)  AS TotalHours        
--------       --     FROM WorkFlow.ScheduleTaskNew  as ST      
--------       --     JOIN WorkFlow.CaseGroup as cg      
--------       --         ON st.CaseId=cg.Id     
--------       --     LEFT JOIN #DateTempTable AS Temp    
--------       --         ON Temp.CompanyId = cg.CompanyId AND ST.EmployeeId = Temp.FromemployeeId AND ST.EmployeeId = Temp.FromemployeeId     
--------       --         AND ST.StartDate BETWEEN Temp.StartDate AND Temp.EndDate       
--------       --         AND cg.Id = Temp.FromCaseId      
--------       --     INNER JOIN (SELECT Id,FirstName AS EmpName FROM Common.Employee WHERE Id = @ToemployeeId) AS Emp    
--------       --         ON Emp.Id = @ToemployeeId    
--------       --     GROUP BY Emp.EmpName,Temp.StartDate,Temp.EndDate  
  
--------        OPEN Scheduling_Cursor    
--------        FETCH NEXT FROM Scheduling_Cursor INTO @EmpName,@StartDate, @EndDate, @TotalHours  
  
--------  WHILE @@FETCH_STATUS = 0 and @Exception_Count =0    
--------        BEGIN     
  
--------  DECLARE @PlannedHours decimal(10,2)  
  
--------  SET @PlannedHours= (SELECT                  
--------         SUM(PlannedHours)               
--------          FROM              
--------          (SELECT PlannedHours from WorkFlow.ScheduleNew as sch join WorkFlow.ScheduleDetailNew as schd on sch.Id=schd.MasterId     
--------     join WorkFlow.ScheduleTaskNew as scht on schd.Id=scht.ScheduleDetailId where scht.StartDate>=@StartDate and     
--------     scht.EndDate<=@EndDate and scht.EmployeeId=@ToemployeeId and sch.companyId=@CompanyId)A   
--------     )      
  
--------  SET @TotalHours = isnull(@PlannedHours,0) + @TotalHours  
--------  SET @EmpName =(SELECT FirstName FROM Common.Employee WHERE Id = @ToemployeeId)  
  
----------SELECT  @EmpName AS EmpName,@StartDate AS StartDate, @EndDate AS EndDate,@TotalHours AS TotalHours,     
----------@WeeklyWorkHours AS WeeklyWorkHours,@ScheduleStartDate AS ScheduleStartDate,@workweekdays AS workweekdays                             
  
-------------=============================================== EXCEPTION THROWING ===============================================-----                       
--------     IF  (@24hrsStatus = 1 AND  @TotalHours > @WeeklyWorkHours)     
--------          BEGIN                         
--------             SET @ErrorMsg = CONCAT('Planned weekly hours are greater than ' ,CAST(@WeeklyWorkHours/60 AS Decimal(8,2)), ' hours (',@EmpName,'). Do you want to continue?')          
--------             RAISERROR(@ErrorMsg,16,1);          
--------             SET @Exception_Count = 1          
--------       END      
--------     ELSE IF (@24hrsStatus != 1 AND @TotalHours > 1439)          
--------          BEGIN          
--------               SET @ErrorMsg = CONCAT('Invalid time records as daily hours (',@EmpName, ') have exceeded 24 hours ')          
--------               RAISERROR(@ErrorMsg,16,1);          
--------             SET @Exception_Count = 1     
--------          END                                     
-------------==================================================================================================================-----         
--------FETCH NEXT FROM Scheduling_Cursor INTO  @EmpName,@StartDate, @EndDate, @TotalHours     
--------END     
  
--------CLOSE Scheduling_Cursor;    
--------DEALLOCATE Scheduling_Cursor;     
  
--------DROP TABLE #DateTempTable    
  
--------END  
GO
