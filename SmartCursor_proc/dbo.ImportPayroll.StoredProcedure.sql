USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ImportPayroll]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Exec [ImportPayroll] 'A09AE264-BC37-4B17-839A-DC870675C3F0','SmartCursorPRD.Import.HRPayroll_19e663fa_2e2f_43d1_996c_7093f7e47bd6'
Create   PROCEDURE [dbo].[ImportPayroll] (@transactionId UNIQUEIDENTIFIER,@tableName NVARCHAR(500))
AS
BEGIN
	BEGIN TRANSACTION --1

	BEGIN TRY --2
		CREATE TABLE #PaycomponentsImport (S_No INT Identity(1, 1), Id UNIQUEIDENTIFIER, PaycomponentName NVARCHAR(150), Amount MONEY, EmployeeId UNIQUEIDENTIFIER, Type1 NVARCHAR(40), WageType NVARCHAR(40), IsSDL BIT, IsCPF BIT, IsExcludeFromGrossWage BIT NULL);

		CREATE TABLE #EmployeeTable (S_No INT Identity(1, 1), EmployeeId UNIQUEIDENTIFIER,  PayrollDetailId UNIQUEIDENTIFIER)

		--Create table #PayrollDetails(S_No INT Identity(1, 1),Id uniqueidentifier ,EmployeeId uniqueidentifier)
		CREATE TABLE #PayrollSplit (S_No INT Identity(1, 1), Id UNIQUEIDENTIFIER, PayrollDetailId UNIQUEIDENTIFIER, PaycomponentId UNIQUEIDENTIFIER, Amount MONEY)

		--CREATE TABLE #Paycomponents (S_No INT Identity(1, 1), Id UNIQUEIDENTIFIER, Name NVARCHAR(100))
		--Create table #SDL (Id uniqueidentifier ,TotalWageFrom money ,TotalWageTo money ,EffectiveFrom datetime2 ,EffectiveTo datetime2 ,SDlRate money ,SDLMin money ,SDLMax money ,Status int) 
		--CREATE TABLE #CPFSettings ([Id] [uniqueidentifier] NOT NULL, [CompanyId] [bigint] NOT NULL, [ContributionFor] [nvarchar](256) NULL, [AgeFrom] [int] NULL, [AgeTo] [int] NULL, [TotalWageFrom] [money] NULL, [TotalWageTo] [money] NULL, [EmprTotalWageRate] [money] NULL, [EmpDifferentialsWageAmt] [money] NULL, [EmprDifferentialsWageAmt] [money] NULL, [EmpDifferentialsWageRate] [money] NULL, [EmprDifferentialsWageRate] [money] NULL, [EmpOrdinaryWageRate] [money] NULL, [EmprOrdinaryWageRate] [money] NULL, [OrdinaryWageCap] [money] NULL, [OrdinaryWageCapInMonths] [int] NULL, [EmpAdditionalWageRate] [money] NULL, [EmprAdditionalWageRate] [money] NULL, [EffectiveFrom] [datetime2](7) NULL, [EffectiveTo] [datetime2](7) NULL, [CountryCode] [nvarchar](10) NULL);
		--CREATE TABLE #AgencyFundDetails(AgencyFundId uniqueidentifier,CompanyId bigint,AgencyFundDetailId uniqueidentifier ,WageFrom money ,WageTo money ,Contribution money ,EffectiveFrom datetime2(7) ,EffectiveTo datetime2(7) ,Status int )
		DECLARE @Recount INT = 1
		DECLARE @TotalCount INT
		DECLARE @ComponentRecount INT
		DECLARE @CompoenentTotalCount INT
		DECLARE @PayrollId UNIQUEIDENTIFIER
		DECLARE @CompanyId BIGINT
		DECLARE @EmployeeId UNIQUEIDENTIFIER
		DECLARE @PayrollDetailId UNIQUEIDENTIFIER
		DECLARE @PaycomponentName NVARCHAR(150)
		DECLARE @PaycomponentId NVARCHAR(150)
		DECLARE @Amount MONEY
		DECLARE @PayType1 NVARCHAR(40)
		--DECLARE @WageType NVARCHAR(40)
		--DECLARE @IsSDL BIT
		--DECLARE @IsCPF BIT
		DECLARE @IsExcludeFromGrossWage BIT
		DECLARE @earnings MONEY
		DECLARE @deductions MONEY
		DECLARE @reembursement MONEY
		DECLARE @ExcludeFromGrossWageEarningAmt MONEY
		DECLARE @ExcludeFromGrossWageDeductionAmt MONEY
		--declare @PayCOmponentId uniqueidentifier
		--DECLARE @GrossWage MONEY
		DECLARE @BasicpayId UNIQUEIDENTIFIER
		DECLARE @Basicpay MONEY
		DECLARE @TotalEarnings MONEY
		DECLARE @TotalDeductions MONEY
		--Declare @TotalReimbrsement money 
		--DECLARE @AW MONEY
		--DECLARE @OW MONEY
		--DECLARE @SDLWage MONEY
		DECLARE @Country NVARCHAR(10)
		--DECLARE @IdType NVARCHAR(50)
		DECLARE @ParentCompanyId BIGINT
		--DECLARE @Age INT
		--DECLARE @EmployeeCPF MONEY
		--DECLARE @EmployerCPF MONEY
		--DECLARE @OrdinaryWageCap MONEY
		--DECLARE @Contribution NVARCHAR(50)
		--DECLARE @IsAWCalc BIT
		--DECLARE @AgencyFundId UNIQUEIDENTIFIER
		--DECLARE @EmployeeDOB DATETIME2(7)
		DECLARE @year1 INT
		DECLARE @month1 NVARCHAR(10)
		DECLARE @CompanyName NVARCHAR(50)
		--DECLARE @EmployemntEnddate DATETIME2(7)
		--DECLARE @SDLAmount MONEY
		--DECLARE @NetWage MONEY
		--DECLARE @AgencyFund MONEY
		--DECLARE @SPRGranted DATETIME2(7)
		--DECLARE @SPRExpiry DATETIME2(7)

		--declare @year1 int =(select year1 from #EmployeeTable where S_No=1)
		--declare @month1 NVARCHAR(10)=(select MONTH1 from #EmployeeTable where S_No=1)
		--declare @CompanyName NVARCHAR(50)=(select CompanyName from #EmployeeTable where S_No=1)
		SELECT TOP 1 @month1 = Month, @year1 = Year, @CompanyName = CompanyName
		FROM MigrationDBPRD.Import.HRSuccessPayroll where TransactionId=@transactionId

		PRINT @CompanyName

		DECLARE @PayrollStartDate DATETIME2(7) = convert(DATETIME, ('1 ' + @month1 + CONVERT(NVARCHAR, @year1)), 106)
		DECLARE @PayrollEndDate DATETIME2(7) = EOMONTH(@PayrollStartDate)

		PRINT @PayrollStartDate
		PRINT @PayrollEndDate

		SELECT @CompanyId = CC.Id, @ParentCompanyId = CC.ParentId, @Country = CC1.Country
		FROM SmartCursorPRD.Common.Company CC
		JOIN SmartCursorPRD.Common.Company CC1 ON CC.ParentId = CC1.Id
		WHERE CC.Name = @CompanyName AND CC.ParentId IS NOT NULL

		--print @CompanyId
		PRINT 'Binding Companyid and COuntry'
		PRINT @CompanyId
		PRINT @ParentCompanyId
		PRINT @country

		SET @PayrollId = (
				SELECT Id
				FROM SmartCursorPRD.HR.Payroll
				WHERE Year = @year1 AND Month = @month1 AND CompanyId = @CompanyId AND (IsTemporary = 0 OR IsTemporary IS NULL) AND (PayrollStatus = 'Draft' OR PayrollStatus = 'Saved As Draft')
				);
				print 'PayrollId'
		PRINT @PayrollId
		UPDATE HTPD
		SET HTPD.SPRGranted = CE.DateOfSPRGranted, HTPD.SPRExpiry = CE.DateOfSPRExpiry, HTPD.IdType = CE.IdType, HTPD.EmploymentEndDate = EMP.EndDate, HTPD.AgencyFundId = (case when HEPS.AgencyFund='Not applicable'  then null when  HEPS.AgencyFund='Agency opt out' and CONVERT(date,AgencyOptOutDate)<@PayrollStartDate then null else HEPS.AgencyFundId end), HTPD.IsCPFContributionFull = HEPS.IsCPFContributionFull, HTPD.WorkProfileId = HEPS.WorkProfileId, HTPD.Age = (CASE WHEN ((Month(CE.DOB) < Month(@payrollStartDate)) OR (Month(CE.DOB) = Month(@payrollStartDate) AND Day(CE.DOB) < Day(@payrollStartDate))) THEN ((year(@payrollStartDate) - year(CE.DOB)) + 1) ELSE (year(@payrollStartDate) - year(CE.DOB)) END),HTPD.ContributionFor=(CASE WHEN CE.Idtype='NRIC(Pink)' then 'Singaporean' else null end ),HTPD.CPFExampted=HEPS.CPFExempted,HTPD.SDLExampted=HEPS.SDLExempted,HTPD.CreatedDate=@PayrollStartDate,HTPD.EmploymentStartDate=EMP.StartDate,HTPD.EffectiveFrom=(case when HTPD.IdType='NRIC(Blue)'and MONTH(SPRGranted) =MONTH(@PayrollStartDate) and year(SPRGranted) =year(@PayrollStartDate) and CONVERT(date,HTPD.EffectiveFrom)>=CONVERT(date,CE.DateOfSPRGranted) then CONVERT(date,HTPD.EffectiveFrom) else CONVERT(date,CE.DateOfSPRGranted) end )
		FROM [HR].[PayrollDetails] HTPD
		JOIN Common.Employee CE ON HTPD.EmployeeId = CE.Id
		JOIN HR.Employment EMP ON EMP.EmployeeId = CE.Id
		JOIN HR.EmployeePayrollSetting HEPS ON HEPS.EmployeeId = CE.Id
		WHERE CE.CompanyId = @ParentCompanyId AND HTPD.MasterId = @PayrollId




		INSERT INTO #EmployeeTable
		SELECT DISTINCT HPD.EmployeeId,  HPD.Id
		FROM MigrationDBPRD.Import.HRSuccessPayroll IHP
		JOIN SmartCursorPRD.Common.Employee CE ON IHP.FirstName = CE.FirstName
		--JOIN SmartCursorPRD.HR.EmployeePayrollSetting HEP ON CE.Id = HEP.EmployeeId
		JOIN SmartCursorPRD.HR.PayrollDetails HPD ON CE.Id = HPD.EmployeeId
		--JOIN SmartCursorPRD.hr.Employment HE ON CE.Id = HE.EmployeeId
		WHERE IHP.TransactionId = @transactionId AND CE.EmployeeId = IHP.EmployeeId AND HPD.MasterId = @PayrollId

		PRINT 'EmployeeData inserted'

		--select * from #EmployeeTable
		INSERT INTO #PayrollSplit
		SELECT DISTINCT Id, PayrollDetailId, PayComponentId, Amount
		FROM SmartCursorPRD.HR.PayrollSplit
		WHERE PayrollDetailId IN (
				SELECT PayrollDetailId
				FROM #EmployeeTable
				)

		PRINT 'PayrolSplit data  inserted'

		
		

		SET @TotalCount = (
				SELECT COUNT(EmployeeId)
				FROM #EmployeeTable
				)

				print @TotalCount
		WHILE @TotalCount >= @Recount
		BEGIN --4
			PRINT 'Employee loop Started'
			PRINT @Recount

			SET @earnings = 0;
			SET @deductions = 0
			SET @ExcludeFromGrossWageEarningAmt = 0
			SET @ExcludeFromGrossWageDeductionAmt = 0
			SET @reembursement = 0
			SET @TotalEarnings = 0
			SET @TotalDeductions = 0
			

			SELECT @EmployeeId = EmployeeId, @PayrollDetailId = PayrollDetailId
			FROM #EmployeeTable
			WHERE S_No = @Recount
			print 'EmployeeId'
			print @EmployeeId
			
			INSERT INTO #PaycomponentsImport
			SELECT DISTINCT pc.Id, pc.Name, IHP.Amount, CE.Id, pc.Type, pc.WageType, pc.IsSDL, Pc.IsCPF, pc.IsExcludeFromGrossWage
			FROM MigrationDBPRD.Import.HRSuccessPayroll IHP
			JOIN SmartCursorPRD.HR.PayComponent Pc ON IHP.PayComponentName = pc.Name
			JOIN SmartCursorPRD.Common.Employee CE ON CE.FirstName = IHP.FirstName
			WHERE pc.CompanyId = @ParentCompanyId AND CE.EmployeeId = IHP.EmployeeId AND CE.Id = @EmployeeId and IHP.TransactionId=@transactionId

			PRINT 'Paycomponent inserted'

			SET @CompoenentTotalCount = (
					SELECT COUNT(S_No)
					FROM #PaycomponentsImport
					)
			SET @ComponentRecount = 1;

			PRINT 'Count updated'

			SET @BasicpayId = (
					SELECT id
					FROM #PaycomponentsImport
					WHERE PaycomponentName = 'Basic Pay'
					)

			PRINT @BasicpayId

			SET @Basicpay = (
					SELECT Amount
					FROM #PaycomponentsImport
					WHERE Id = @BasicpayId AND Amount IS NOT NULL
					)

			PRINT @Basicpay

			WHILE @CompoenentTotalCount >= @ComponentRecount
			BEGIN --5
				PRINT 'PayComponent  loop Started'
				PRINT @ComponentRecount
				PRINT @CompoenentTotalCount

				SELECT @Amount = Amount, @IsExcludeFromGrossWage = IsExcludeFromGrossWage, @PayType1 = Type1, @PaycomponentId = Id, @PaycomponentName = PaycomponentName
				FROM #PaycomponentsImport
				WHERE S_No = @ComponentRecount AND Amount IS NOT NULL

				IF EXISTS (
						SELECT id
						FROM #PayrollSplit
						WHERE PayrollDetailId = @PayrollDetailId AND PaycomponentId = @PaycomponentId
						)
				BEGIN --6
					PRINT 'Update payroll Split'
					PRINT @PaycomponentName
					PRINT @Amount

					UPDATE SmartCursorPRD.HR.PayrollSplit
					SET Amount = @Amount, PayType = @PayType1
					WHERE PayrollDetailId = @PayrollDetailId AND PayComponentId = @PaycomponentId
				END --6
				ELSE
				BEGIN --7
					PRINT 'Insert payroll Split'
					PRINT @PaycomponentName
					PRINT @Amount

					INSERT INTO SmartCursorPRD.HR.PayrollSplit (Id, PayComponentId, PayrollDetailId, PayType,Amount,IsTemporary)
					VALUES (NEWID(), @PaycomponentId, @PayrollDetailId, @PayType1,@Amount,0)
				END --7

				IF (@PayType1 = 'Earning')
				BEGIN --10
					PRINT 'Entered into Earning'
					if(@PaycomponentName!='Basic Pay')
					begin--mm
					IF (@IsExcludeFromGrossWage = 1)
					BEGIN --11
						SET @ExcludeFromGrossWageEarningAmt = @ExcludeFromGrossWageEarningAmt + @Amount
					END --11
					ELSE
					BEGIN --12
						SET @earnings = @earnings + @Amount
					END --12
					end--mm
				END --10

				IF (@PayType1 = 'Deduction')
				BEGIN --13
					PRINT 'Entered into Deduction'

					IF @Amount < 0
					BEGIN --14
						SET @Amount = @Amount * - 1
					END --14

					IF (@IsExcludeFromGrossWage = 1)
					BEGIN --15
						SET @ExcludeFromGrossWageDeductionAmt = @ExcludeFromGrossWageDeductionAmt + @Amount;
					END --15
					ELSE
					BEGIN --16
						SET @deductions = (@deductions) + @Amount;
					END --16
				END --13

				IF (@PayType1 = 'Reimbursement')
				BEGIN --14
					PRINT 'Entered into Reimbursement'

					SET @reembursement = @reembursement + @Amount
				END --14

				SET @ComponentRecount = @ComponentRecount + 1
			END --5

			--SET @GrossWage = (@Basicpay + @earnings + @deductions)

			--PRINT 'Grosswage '
			--PRINT @GrossWage

			SET @TotalEarnings = @earnings + @ExcludeFromGrossWageEarningAmt

			PRINT 'Earnings '
			PRINT @TotalEarnings

			SET @TotalDeductions = @deductions + @ExcludeFromGrossWageDeductionAmt

			PRINT 'Deductions '
			PRINT @TotalDeductions

			SET @reembursement = @reembursement

			PRINT 'reembursement '
			PRINT @reembursement

			
			update SmartCursorPRD.HR.PayrollDetails set Earnings=@earnings,Deduction=@deductions,Reimbursement=@reembursement,BasicPay=@Basicpay where id=@PayrollDetailId
			--SELECT @AW, @OW, @OrdinaryWageCap, @earnings, @deductions, @reembursement, @SDLAmount, @EmployeeCPF, @EmployeeCPF, @AgencyFund, @AgencyFundId, @GrossWage, @NetWage

			TRUNCATE TABLE #PaycomponentsImport

			SET @Recount = @Recount + 1
		END --4
		exec SmartCursorPRD.[dbo].[TempPayrollDataDumpImportPayroll] @PayrollId , @ParentCompanyId, @PayrollStartDate , @CompanyId , @PayrollEndDate 


		IF OBJECT_ID(N'tempdb..#PaycomponentsImport') IS NOT NULL
		BEGIN
			DROP TABLE #PaycomponentsImport
		END

		IF OBJECT_ID(N'tempdb..#EmployeeTable') IS NOT NULL
		BEGIN
			DROP TABLE #EmployeeTable
		END

		IF OBJECT_ID(N'tempdb..#PayrollSplit') IS NOT NULL
		BEGIN
			DROP TABLE #PayrollSplit
		END

		IF((SELECT COUNT(*) FROM MigrationDBPRD.Import.HRPayroll WHERE TransactionId = @transactionId) = (SELECT COUNT(*) FROM MigrationDBPRD.Import.HRSuccessPayroll WHERE TransactionId = @transactionId))
		BEGIN
			DECLARE @query NVARCHAR(MAX)
			SET @QUERY = 'DROP TABLE '+@tableName
			EXEC sp_executesql @query;
		END

		COMMIT TRANSACTION --1
	END TRY --2

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END
GO
