USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_UpdateScheduleDetailStartandendDate1]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create   PROCEDURE [dbo].[SP_UpdateScheduleDetailStartandendDate1]
    @CaseId NVARCHAR(MAX),
    @EmployeeId NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        DECLARE @TempTable TABLE (
            EmployeeId UNIQUEIDENTIFIER, 
            CaseId UNIQUEIDENTIFIER, 
            StartDate DATE, 
            EndDate DATE, 
            PlannedHours INT
        );

        DECLARE @EmpCaseWhileTable TABLE (
            S_No INT IDENTITY(1,1), 
            CaseId UNIQUEIDENTIFIER, 
            EmployeeId UNIQUEIDENTIFIER
        );

        
        IF (@CaseId IS NOT NULL AND @CaseId <> '00000000-0000-0000-0000-000000000000') AND 
           (@EmployeeId IS NOT NULL AND @EmployeeId <> '')
        BEGIN
            
            INSERT INTO @EmpCaseWhileTable (CaseId, EmployeeId)
            SELECT DISTINCT s.CaseId, sd.EmployeeId
            FROM WorkFlow.ScheduleNew s (NOLOCK)
            INNER JOIN WorkFlow.ScheduleDetailNew sd (NOLOCK) ON sd.MasterId = s.Id
            WHERE s.CaseId IN (SELECT LTRIM(value) FROM STRING_SPLIT(@CaseId, ',')) 
              AND sd.EmployeeId IN (SELECT LTRIM(value) FROM STRING_SPLIT(@EmployeeId, ','))
            ORDER BY s.CaseId;

            
            INSERT INTO @TempTable (EmployeeId, CaseId, StartDate, EndDate, PlannedHours)
            SELECT EmployeeId, CaseId, MIN(StartDate) AS StartDate, MAX(EndDate) AS EndDate, ISNULL(SUM(PlannedHours), 0) AS PlannedHours
            FROM WorkFlow.ScheduleTaskNew (NOLOCK)
            WHERE CaseId IN (SELECT DISTINCT CaseId FROM @EmpCaseWhileTable)
              AND EmployeeId IN (SELECT DISTINCT EmployeeId FROM @EmpCaseWhileTable)
            GROUP BY EmployeeId, CaseId;

         
            UPDATE sd
            SET sd.StartDate = t.StartDate, sd.EndDate = t.EndDate
            FROM WorkFlow.ScheduleDetailNew sd
            JOIN WorkFlow.ScheduleNew s ON sd.MasterId = s.Id
            JOIN @TempTable t ON s.CaseId = t.CaseId AND sd.EmployeeId = t.EmployeeId
            WHERE s.CaseId = t.CaseId AND t.PlannedHours >= 0;

          
            UPDATE sd
            SET sd.StartDate = NULL, sd.EndDate = NULL
            FROM WorkFlow.ScheduleDetailNew sd
            JOIN WorkFlow.ScheduleNew s ON sd.MasterId = s.Id
            LEFT JOIN WorkFlow.ScheduleTaskNew st ON s.CaseId = st.CaseId AND sd.EmployeeId = st.EmployeeId
            WHERE s.CaseId IN (SELECT DISTINCT CaseId FROM @EmpCaseWhileTable)
              AND sd.EmployeeId IN (SELECT DISTINCT EmployeeId FROM @EmpCaseWhileTable)
              AND st.CaseId IS NULL;

            EXEC sp_updateIslockFlagNew @CaseId;
            EXEC [dbo].[sp_updateEmployeedeptIsLockLogFlag] @EmployeeId;
        END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
				ROLLBACK
				SELECT @ErrorMessage
        THROW;
    END CATCH
END;

------------------------------------------------------------------------------------------------------------------------------
--create or alter procedure [dbo].[SP_UpdateScheduleDetailStartandendDate1] @CaseId nvarchar(max),@EmployeeId nvarchar(max)

--AS
--BEGIN--1
  
--DECLARE @TempTable TABLE (EmployeeId uniqueidentifier, caseid uniqueidentifier, STARTDATE date, ENDDATE date, PlannedHours int);
--DECLARE @EmpCaseWhileTable TABLE (S_No Int Identity(1,1), CaseId Uniqueidentifier, EmployeeId Uniqueidentifier);

--IF @CaseId <> '00000000-0000-0000-0000-000000000000' OR @EmployeeId <> '' OR @EmployeeId IS NOT NULL OR @CaseId IS NOT NULL
--BEGIN--3
--    IF (@EmployeeId <> 'null' AND @CaseId <> 'null')
--    BEGIN--4
--        -- Populate EmpCaseWhileTable with distinct CaseId and EmployeeId
--        INSERT INTO @EmpCaseWhileTable (CaseId, EmployeeId)
--        SELECT DISTINCT s.CaseId, sd.EmployeeId
--        FROM WorkFlow.ScheduleNew s (NOLOCK)
--        INNER JOIN WorkFlow.ScheduleDetailNew sd (NOLOCK) ON sd.MasterId = s.Id
--        WHERE s.CaseId IN (SELECT LTRIM(value) FROM STRING_SPLIT(@CaseId, ',')) 
--          AND sd.EmployeeId IN (SELECT LTRIM(value) FROM STRING_SPLIT(@EmployeeId, ','))
--        ORDER BY s.CaseId;

--        -- Insert data into TempTable for further updates
--        INSERT INTO @TempTable (EmployeeId, caseid, STARTDATE, ENDDATE, PlannedHours)
--        SELECT EmployeeId, CaseId, MIN(StartDate) AS StartDate, MAX(EndDate) AS EndDate, ISNULL(SUM(PlannedHours), 0) AS TOTAL_HOURS
--        FROM WorkFlow.ScheduleTaskNew (NOLOCK)
--        WHERE caseid IN (SELECT DISTINCT CaseId FROM @EmpCaseWhileTable)
--          AND EmployeeId IN (SELECT DISTINCT EmployeeId FROM @EmpCaseWhileTable)
--        GROUP BY EmployeeId, caseid;

--        -- Update ScheduleDetailNew with StartDate and EndDate from TempTable
--        UPDATE sd
--        SET sd.StartDate = t.STARTDATE, sd.EndDate = t.ENDDATE
--        FROM WorkFlow.ScheduleDetailNew sd
--        JOIN WorkFlow.ScheduleNew s ON sd.MasterId = s.Id
--        JOIN @TempTable t ON s.CaseId = t.caseid AND sd.EmployeeId = t.EmployeeId
--        WHERE s.CaseId = t.caseid AND t.PlannedHours >= 0;

--        -- Set StartDate and EndDate to NULL for records without corresponding tasks in ScheduleTaskNew
--        UPDATE sd
--        SET sd.StartDate = NULL, sd.EndDate = NULL
--        FROM WorkFlow.ScheduleDetailNew sd
--        JOIN WorkFlow.ScheduleNew s ON sd.MasterId = s.Id
--        LEFT JOIN WorkFlow.ScheduleTaskNew st ON s.CaseId = st.caseid AND sd.EmployeeId = st.EmployeeId
--        WHERE s.CaseId IN (SELECT DISTINCT CaseId FROM @EmpCaseWhileTable)
--          AND sd.EmployeeId IN (SELECT DISTINCT EmployeeId FROM @EmpCaseWhileTable)
--          AND st.caseid IS NULL;

--        -- Execute additional stored procedures
--        EXEC sp_updateIslockFlag @CaseId;
--        EXEC [dbo].[sp_updateEmployeedeptIsLockLogFlag] @EmployeeId;
--    END--4

--END--3

--END--1


GO
