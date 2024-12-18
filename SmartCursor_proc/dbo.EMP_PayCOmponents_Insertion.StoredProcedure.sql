USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[EMP_PayCOmponents_Insertion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EMP_PayCOmponents_Insertion] (@CompanyId BIGINT, @EmployeeId UNIQUEIDENTIFIER, @ModifiedBy NVARCHAR(50))
AS
BEGIN
	BEGIN TRANSACTION

	BEGIN TRY
		DECLARE @DesignationId UNIQUEIDENTIFIER
		DECLARE @DepartmentId UNIQUEIDENTIFIER
		DECLARE @Basicpay NVARCHAR(50)
		DECLARE @EffectiveFrom DATETIME2(7)
		DECLARE @Level NVARCHAR(30)
		DECLARE @Juridiction NVARCHAR(50)
		DECLARE @Basicpay1 MONEY
		DECLARE @professionaltaxId UNIQUEIDENTIFIER
		DECLARE @EmploymentStartDate DATETIME2(7)

		SELECT @DesignationId = ED.[DepartmentDesignationId], @DepartmentId = ED.[DepartmentId], @Basicpay = ED.[BasicPay], @Basicpay1 = ED.[BasicPay], @EffectiveFrom = ED.[EffectiveFrom], @Level = ED.[Level], @Juridiction = cc.[Jurisdiction], @EmploymentStartDate = emp.startdate
		FROM Common.employee ce (NOLOCK)
		JOIN hr.EmployeeDepartment ED (NOLOCK) ON CE.Id = ED.EmployeeId
		JOIN Common.company cc (NOLOCK) ON cc.id = ce.Companyid
		JOIN HR.Employment emp (NOLOCK) ON emp.employeeid = ce.id
		WHERE ED.EmployeeId = @EmployeeId AND (Convert(DATE, EffectiveFrom) <= Convert(DATE, GetDate()) AND (Convert(DATE, EffectiveTo) >= Convert(DATE, GetDate()) OR EffectiveTo IS NULL)) AND CE.CompanyId = @CompanyId

		PRINT 'yes'

		IF (@Juridiction IS NULL)
		BEGIN
			SELECT @EmploymentStartDate = emp.startdate, @Juridiction = cc.[Jurisdiction], @EffectiveFrom = emp.startdate, @Basicpay = ED.[BasicPay], @Basicpay1 = ED.[BasicPay]
			FROM Common.employee ce (NOLOCK)
			JOIN Common.company cc (NOLOCK) ON cc.id = ce.Companyid
			JOIN HR.Employment emp (NOLOCK) ON emp.employeeid = ce.id
			JOIN hr.EmployeeDepartment ED (NOLOCK) ON CE.Id = ED.EmployeeId
			WHERE ED.EmployeeId = @EmployeeId
		END

		PRINT @Juridiction

		DECLARE @PayComponentId UNIQUEIDENTIFIER

		--print 'yes'
		IF (@Juridiction = 'Singapore')
		BEGIN
			PRINT 'Singapore'

			SET @PayComponentId = (
					SELECT Id
					FROM HR.PayComponent (NOLOCK)
					WHERE CompanyId = @CompanyId AND Name = 'Basic Pay'
					)
		END

		IF (@Juridiction = 'India')
		BEGIN
			PRINT 'India'

			SET @PayComponentId = (
					SELECT Id
					FROM HR.PayComponent (NOLOCK)
					WHERE CompanyId = @CompanyId AND Name = 'Monthly CTC'
					)
			SET @professionaltaxId = (
					SELECT Id
					FROM HR.PayComponent (NOLOCK)
					WHERE CompanyId = @CompanyId AND Name = 'Professional Tax'
					)
		END

		IF EXISTS (
				SELECT *
				FROM HR.PayComponentDetail (NOLOCK)
				WHERE EmployeeId = @EmployeeId AND MasterId = @PayComponentId
				)
		BEGIN
			IF (@PayComponentId IS NOT NULL)
			BEGIN
				UPDATE HR.PayComponentDetail
				SET Amount = @Basicpay, ComponentAmount = @Basicpay, EffectiveFrom = @EffectiveFrom, ModifiedBy = @ModifiedBy, ModifiedDate = GETUTCDATE(), IsSystem = 1
				WHERE Id = (
						SELECT Id
						FROM HR.PayComponentDetail (NOLOCK)
						WHERE EmployeeId = @EmployeeId AND MasterId = @PayComponentId
						)

				UPDATE HR.PayComponentDetail
				SET EffectiveFrom = @EmploymentStartDate
				WHERE EmployeeId = @EmployeeId AND IsSystem = 1

				IF (@Juridiction = 'India' AND @Basicpay1 * 12.0 > 200000)
				BEGIN --1
					PRINT '> 200000'

					IF (
							@professionaltaxId IS NOT NULL OR @professionaltaxId != (
								SELECT CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
								)
							)
					BEGIN --2
						IF EXISTS (
								SELECT id
								FROM HR.PayComponentDetail (NOLOCK)
								WHERE EmployeeId = @EmployeeId AND MasterId = @professionaltaxId
								)
						BEGIN --3
							PRINT 'yes'

							UPDATE HR.PayComponentDetail
							SET Amount = 200, ComponentAmount = 200
							WHERE EmployeeId = @EmployeeId AND MasterId = @professionaltaxId
						END --3
						ELSE
						BEGIN --4
							INSERT INTO HR.PayComponentDetail (Id, MasterId, DepartmentId, DesignationId, LEVEL, EmployeeId, Formula, PercentageComponent, PayMethod, Amount, Percentage, ComponentAmount, EffectiveFrom, IsSystem, Recorder, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, STATUS)
							VALUES (NEWID(), @professionaltaxId, @DepartmentId, @DesignationId, @Level, @EmployeeId, NULL, NULL, 'N/A', 200, NULL, 200, @EffectiveFrom, 1, 1, NULL, GETUTCDATE(), NULL, NULL, 1)
						END --4
					END --2
				END --1
				ELSE IF (@Juridiction = 'India' AND @Basicpay1 * 12.0 < = 200000)
				BEGIN --1
					PRINT '<=200000'

					IF (
							@professionaltaxId IS NOT NULL OR @professionaltaxId != (
								SELECT CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
								)
							)
					BEGIN --2
						IF EXISTS (
								SELECT *
								FROM HR.PayComponentDetail (NOLOCK)
								WHERE EmployeeId = @EmployeeId AND MasterId = @professionaltaxId
								)
						BEGIN --3
							UPDATE HR.PayComponentDetail
							SET Amount = 0, ComponentAmount = 0
							WHERE EmployeeId = @EmployeeId AND MasterId = @professionaltaxId
						END --3
					END --2
				END --1
			END
		END
		ELSE
		BEGIN
			DECLARE @PayComponentId1 UNIQUEIDENTIFIER
			DECLARE @CompanyId1 BIGINT
			DECLARE @Type NVARCHAR(50)
			DECLARE @PayMecthod NVARCHAR(50)
			DECLARE @Amount MONEY
			DECLARE @Percentage MONEY
			DECLARE @PercentageComponent NVARCHAR(200)
			DECLARE @Name NVARCHAR(200)
			DECLARE @RecOrder INT

			DECLARE PaycomponentCursor CURSOR
			FOR
			SELECT [Id], [CompanyId], [Type], [PayMethod], [Amount], [Percentage], [PercentageComponent], [Name], [RecOrder]
			FROM [HR].[PayComponent] (NOLOCK)
			WHERE companyid = @CompanyId AND Juridication = @Juridiction AND [IsDefault] = 1

			OPEN PaycomponentCursor

			FETCH NEXT
			FROM PaycomponentCursor
			INTO @PayComponentId1, @CompanyId1, @Type, @PayMecthod, @Amount, @Percentage, @PercentageComponent, @Name, @RecOrder

			PRINT @Juridiction

			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF (@Name = 'Monthly CTC' OR @Name = 'Basic Pay')
				BEGIN
					SET @Amount = @Basicpay
				END

				IF (@Name = 'Professional Tax' AND @Basicpay1 * 12.0 <= 200000)
				BEGIN
					PRINT '<= 200000'

					SET @Amount = 0
				END

				PRINT @Name

				INSERT INTO HR.PayComponentDetail (Id, MasterId, DepartmentId, DesignationId, LEVEL, EmployeeId, Formula, PercentageComponent, PayMethod, Amount, Percentage, ComponentAmount, EffectiveFrom, IsSystem, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, STATUS, [Recorder])
				VALUES (NEWID(), @PayComponentId1, @DepartmentId, @DesignationId, @Level, @EmployeeId, NULL, @PercentageComponent, @PayMecthod, @Amount, @Percentage, @Amount, @EffectiveFrom, 1, 'System', GETUTCDATE(), NULL, NULL, 1, @RecOrder)

				FETCH NEXT
				FROM PaycomponentCursor
				INTO @PayComponentId1, @CompanyId1, @Type, @PayMecthod, @Amount, @Percentage, @PercentageComponent, @Name, @RecOrder
			END

			CLOSE PaycomponentCursor

			DEALLOCATE PaycomponentCursor
		END
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		ROLLBACK TRANSACTION

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH

	COMMIT TRANSACTION
END
GO
