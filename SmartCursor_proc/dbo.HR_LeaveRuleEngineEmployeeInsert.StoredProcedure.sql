USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_LeaveRuleEngineEmployeeInsert]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[HR_LeaveRuleEngineEmployeeInsert] (@LeaveRuleengineId UNIQUEIDENTIFIER, @IsModified BIT, @EmployeeJsonData NVARCHAR(Max), @Condition NVARCHAR(30), @Value NVARCHAR(30), @NoOfDays FLOAT, @CompanyId BIGINT)
AS
BEGIN --m1
	BEGIN TRANSACTION --m2

	BEGIN TRY --m3
		DECLARE @DaysChangedEmplyeeTable TABLE (S_No INT Identity(1, 1), EmployeeId UNIQUEIDENTIFIER, NoofDays FLOAT)
		DECLARE @InserImployee TABLE (S_No INT Identity(1, 1), EmployeeId UNIQUEIDENTIFIER)
		DECLARE @count INT
		DECLARE @recount INT
		DECLARE @days FLOAT

		IF (@EmployeeJsonData IS NOT NULL AND @EmployeeJsonData != '')
		BEGIN --y
			INSERT INTO @DaysChangedEmplyeeTable
			SELECT *
			FROM OPENJSON(@EmployeeJsonData) WITH (EmployeeId UNIQUEIDENTIFIER 'strict $.EmployeeId', NoofDays FLOAT 'strict $.NoOfDays');
		END --y

		IF (@IsModified = 1)
		BEGIN --1
			DELETE
			FROM [HR].[LeaveRuleEngineEmployee]
			WHERE [LeaveRuleEngineId] = @LeaveRuleengineId
		END --1

		IF (@Condition = 'Date Of Birth' OR @Condition = 'Employment Start Date')
		BEGIN --2
			INSERT INTO @InserImployee
			SELECT id
			FROM [Common].[Employee] (NOLOCK)
			WHERE idtype IS NOT NULL AND isworkflowonly = 0 AND CompanyId = @CompanyId and status=1
		END --2
		ELSE
		BEGIN --3
			IF (@Value != 'All')
			BEGIN --xx
				INSERT INTO @InserImployee
				SELECT id
				FROM [Common].[Employee] (NOLOCK)
				WHERE idtype = @Condition AND gender = @value AND CompanyId = @CompanyId and status=1
			END --xx
			ELSE
			BEGIN --yy
				INSERT INTO @InserImployee
				SELECT id
				FROM [Common].[Employee] (NOLOCK)
				WHERE idtype = @Condition AND CompanyId = @CompanyId and status=1
			END --yy
		END --3

		SET @count = (
				SELECT count(*)
				FROM @InserImployee
				)
		SET @recount = 1

		WHILE @count >= @recount
		BEGIN --4
			DECLARE @EmpId UNIQUEIDENTIFIER = (
					SELECT EmployeeId
					FROM @InserImployee
					WHERE S_No = @recount
					)

			IF EXISTS (
					SELECT EmployeeId
					FROM @DaysChangedEmplyeeTable
					WHERE EmployeeId = @EmpId
					)
			BEGIN --5
				SET @days = (
						SELECT NoofDays
						FROM @DaysChangedEmplyeeTable
						WHERE EmployeeId = @EmpId
						)
			END --6
			ELSE
			BEGIN --7
				SET @days = @NoOfDays
			END --7

			INSERT INTO [HR].[LeaveRuleEngineEmployee] ([Id], [EmployeeId], [LeaveRuleEngineId], [NoOfDays])
			VALUES (newid(), @EmpId, @LeaveRuleengineId, @days)

			SET @recount = @recount + 1
		END --4

		COMMIT TRANSACTION --m2
	END TRY --m3

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = 16, @ErrorState = 1;		

		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH
END --m1
GO
