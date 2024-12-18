USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_EMPLOYEE_REJOIN_JOB]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[HR_EMPLOYEE_REJOIN_JOB]
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @AllActiveEmployee_Tbl TABLE (S_No INT Identity(1, 1), CompanyId BIGINT, Id UNIQUEIDENTIFIER, EmpStartDate DATETIME2(7), IdType NVARCHAR(50), Gender NVARCHAR(50))

		INSERT INTO @AllActiveEmployee_Tbl
		SELECT Distinct CE.COMPANYID, CE.ID, E.StartDate, CE.IdType, CE.Gender
		FROM COMMON.EMPLOYEE CE
		INNER JOIN HR.EmployeeHistory E ON CE.ID = E.EMPLOYEEID
		WHERE ((CONVERT(DATE, E.StartDate) = CONVERT(DATE, Getutcdate())) ) AND CE.IDTYPE IS NOT NULL

		DECLARE @EmployeeId UNIQUEIDENTIFIER
		DECLARE @companyId1 BIGINT
		DECLARE @EMPSTARTDATE DATETIME2(7)
		DECLARE @IdType NVARCHAR(50)
		DECLARE @Gender NVARCHAR(50)

		DECLARE companpany_cursor CURSOR
		FOR
		SELECT CompanyId, Id, EmpStartDate, IdType, Gender
		FROM @AllActiveEmployee_Tbl

		OPEN companpany_cursor

		FETCH NEXT
		FROM companpany_cursor
		INTO @companyId1, @EmployeeId, @EMPSTARTDATE, @IdType, @Gender

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC [dbo].[HR_Claim_Entitlement_Insertion] @EmployeeId, @companyId1

			EXEC [dbo].[SP_HR_LeaveEntitlement_At_EmpSave] @companyId1, @EmployeeId, 'System', @EMPSTARTDATE, @IdType, @Gender

			FETCH NEXT
			FROM companpany_cursor
			INTO @companyId1, @EmployeeId, @EMPSTARTDATE, @IdType, @Gender
		END

		CLOSE companpany_cursor

		DEALLOCATE companpany_cursor

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = 16, @ErrorState = 1;		

		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH
END
GO
