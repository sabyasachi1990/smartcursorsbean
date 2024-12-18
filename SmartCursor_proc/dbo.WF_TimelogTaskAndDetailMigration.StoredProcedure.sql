USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_TimelogTaskAndDetailMigration]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WF_TimelogTaskAndDetailMigration] (@CompanyId BIGINT, @Month INT, @year INT)
AS
BEGIN --m1
	BEGIN TRANSACTION --m2

	BEGIN TRY --m3
		--DECLARE @CompanyId BIGINT = 1
		--DECLARE @Month INT = 8
		--DECLARE @year INT = 2020
		DECLARE @timelogCount INT
		DECLARE @RecCount INT = 1
		DECLARE @Timelogid UNIQUEIDENTIFIER
		DECLARE @TimelogTaskId UNIQUEIDENTIFIER
		DECLARE @DetailTotalCount INT
		DECLARE @DetailRecount INT = 1
		DECLARE @TimelogDetailDate DATETIME2(7)
		DECLARE @timelogDuration TIME(7)
		DECLARE @timelogDetailId UNIQUEIDENTIFIER

		CREATE TABLE #TimelogTable (S_No INT Identity(1, 1), CompanyId BIGINT, Id UNIQUEIDENTIFIER, EmployeeId UNIQUEIDENTIFIER, StartDate DATETIME2(7), EndDate DATETIME2(7))

		CREATE TABLE #TimelogDetailTable (S_No INT Identity(1, 1), Id UNIQUEIDENTIFIER, TimelogId UNIQUEIDENTIFIER, DATE1 DATETIME2(7), Duration TIME(7))

		INSERT INTO #TimelogTable
		SELECT CompanyId, Id, EmployeeId, Startdate, Enddate
		FROM Common.TimeLog
		WHERE CompanyId = @CompanyId AND MONTH(Startdate) = @Month AND YEAR(Startdate) = @year

		SET @timelogCount = (
				SELECT COUNT(S_No)
				FROM #TimelogTable
				)

		PRINT @timelogCount

		WHILE @timelogCount >= @RecCount
		BEGIN --1
			SELECT @Timelogid = Id
			FROM #TimelogTable
			WHERE S_No = @RecCount

			SET @TimelogTaskId = NEWID()

			INSERT INTO Workflow.TimeLogTasks
			VALUES (@TimelogTaskId, @CompanyId, @Timelogid, 'Default Task')

			--select @TimelogTaskId, @CompanyId, @Timelogid, 'Default Task'
			PRINT @RecCount

			INSERT INTO #TimelogDetailTable
			SELECT Id, MasterId, DATE, Duration
			FROM Common.TimeLogDetail
			WHERE MasterId = @Timelogid

			--SELECT Id, MasterId, DATE, Duration
			--FROM Common.TimeLogDetail
			--WHERE MasterId = @Timelogid
			SET @DetailTotalCount = (
					SELECT COUNT(S_no)
					FROM #TimelogDetailTable
					)
			SET @DetailRecount = 1

			PRINT @DetailTotalCount

			WHILE @DetailTotalCount >= @DetailRecount
			BEGIN --2
				SELECT @TimelogDetailDate = DATE1, @timelogDuration = Duration, @timelogDetailId = Id
				FROM #TimelogDetailTable
				WHERE S_No = @DetailRecount

				INSERT INTO Workflow.TimeLogTaskDetails
				VALUES (NewId(), @TimelogTaskId, @TimelogDetailDate, @timelogDuration, '00:00', NULL)

				--select NewId(), @TimelogTaskId, @TimelogDetailDate, @timelogDuration, NULL
				PRINT @DetailRecount

				SET @DetailRecount = @DetailRecount + 1
			END --2

			TRUNCATE TABLE #TimelogDetailTable

			SET @RecCount = @RecCount + 1
		END --1

		IF OBJECT_ID(N'tempdb..#TimelogTable') IS NOT NULL
		BEGIN
			DROP TABLE #TimelogTable
		END

		IF OBJECT_ID(N'tempdb..#TimelogDetailTable') IS NOT NULL
		BEGIN
			DROP TABLE #TimelogDetailTable
		END

		COMMIT TRANSACTION --m2
	END TRY --m3

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END --m1
GO
