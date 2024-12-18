USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[AllEmployeeCPFCalculationsImport]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[AllEmployeeCPFCalculationsImport] (@Country NVARCHAR(50), @IsAWCalc BIT, @PayrollStartDate DATETIME2(7), @PayrollId UNIQUEIDENTIFIER,@ParentCompanyId bigint,@PayrollEndDate DATETIME2(7))
AS
BEGIN
	BEGIN TRANSACTION --1

	BEGIN TRY --2
		PRINT 'Entered into CPF Calculations SP 1'

		DECLARE @CPFExampted BIT = 0
		--DECLARE @PayrollStartDate DATETIME2(7)='2021-04-01 00:00:00.0000000'
		--DECLARE @SPRGranted DATETIME2(7)='2020-04-01 00:00:00.0000000'
		--DECLARE @SPRExpiry DATETIME2(7)
		DECLARE @IsCPFContributionFull BIT = 0
		DECLARE @IdType NVARCHAR(50)
		DECLARE @CompanyContribution NVARCHAR(20)
		DECLARE @TotalWage MONEY
		DECLARE @OrdinaryWageCap MONEY
		DECLARE @EmpOrdinaryWageRate MONEY
		DECLARE @EmprOrdinaryWageRate MONEY
		DECLARE @EmpDifferentialsWageAmt MONEY
		DECLARE @EmprDifferentialsWageAmt MONEY
		DECLARE @EmpDifferentialsWageRate MONEY
		DECLARE @EmprDifferentialsWageRate MONEY
		DECLARE @EmployeeCPF MONEY
		DECLARE @EmployerCPF MONEY
		DECLARE @TotalCPFContributionRate MONEY
		DECLARE @TotalDifferentialWageAmount MONEY
		DECLARE @TotalDifferentialWageRate MONEY
		DECLARE @TotalCPFContribution MONEY
		DECLARE @EmprTotalWageRate MONEY
		DECLARE @OW MONEY
		DECLARE @AW MONEY
		DECLARE @Contribution NVARCHAR(50)
		DECLARE @TotalCount INT
		DECLARE @ReCount INT = 1
		DECLARE @EmployeeId UNIQUEIDENTIFIER
		DECLARE @TempPayrollMasterId UNIQUEIDENTIFIER
		DECLARE @PayrollDetailId UNIQUEIDENTIFIER
		DECLARE @Age INT
		declare @EMPCPFPayComponentId uniqueidentifier	
	declare @PayTypeEMPCPF NVARCHAR(30)
	declare @EMPRCPFPayComponentId uniqueidentifier	
	declare @PayTypeEMPRCPF NVARCHAR(30)
	--declare @BasicPay money 
	declare @SPRGranted datetime2(7)
	declare @DiffDays int
	--declare @OneDaySalary money
	declare @SPROWWage money
	declare @GrossWage money
	declare @EMPCPFRecorder int 
	declare @EMPRCPFRecorder int 
	declare @EmployeeCompanyContribution NVARCHAR(50)
	select @EMPCPFPayComponentId=Id,@PayTypeEMPCPF=Type,@EMPCPFRecorder=RecOrder from HR.PayComponent where CompanyId=@ParentCompanyId and Name='Employee CPF'
	select @EMPRCPFPayComponentId=Id,@PayTypeEMPRCPF=Type,@EMPRCPFRecorder=RecOrder from HR.PayComponent where CompanyId=@ParentCompanyId and Name='Employer CPF'

		--print @IsCPFContributionFull
		CREATE TABLE #CPFSettings ([Id] [uniqueidentifier] NOT NULL, [CompanyId] [bigint] NOT NULL, [ContributionFor] [nvarchar](256) NULL, [AgeFrom] [int] NULL, [AgeTo] [int] NULL, [TotalWageFrom] [money] NULL, [TotalWageTo] [money] NULL, [EmprTotalWageRate] [money] NULL, [EmpDifferentialsWageAmt] [money] NULL, [EmprDifferentialsWageAmt] [money] NULL, [EmpDifferentialsWageRate] [money] NULL, [EmprDifferentialsWageRate] [money] NULL, [EmpOrdinaryWageRate] [money] NULL, [EmprOrdinaryWageRate] [money] NULL, [OrdinaryWageCap] [money] NULL, [OrdinaryWageCapInMonths] [int] NULL, [EmpAdditionalWageRate] [money] NULL, [EmprAdditionalWageRate] [money] NULL, [EffectiveFrom] [datetime2](7) NULL, [EffectiveTo] [datetime2](7) NULL, [CountryCode] [nvarchar](10) NULL);

		INSERT INTO #CPFSettings
		SELECT id, CompanyId, ContributionFor, AgeFrom, AgeTo, TotalWageFrom, TotalWageTo, EmprTotalWageRate, EmpDifferentialsWageAmt, EmprDifferentialsWageAmt, EmpDifferentialsWageRate, EmprDifferentialsWageRate, EmpOrdinaryWageRate, EmprOrdinaryWageRate, OrdinaryWageCap, OrdinaryWageCapInMonths, EmpAdditionalWageRate, EmprAdditionalWageRate, EffectiveFrom, EffectiveTo, CountryCode
		FROM hr.CPFSettings
		WHERE STATUS = 1 AND CONVERT(DATE, EffectiveFrom) <= @PayrollStartDate AND CONVERT(DATE, EffectiveTo) >= @PayrollStartDate

		CREATE TABLE #EmployeeData (S_No INT Identity(1, 1), TempPayrollMasterId UNIQUEIDENTIFIER, Employeeid UNIQUEIDENTIFIER, OW MONEY, AW MONEY NULL, IdType NVARCHAR(50), Contributionfor NVARCHAR(50), DetailId UNIQUEIDENTIFIER,SPRGranted datetime2(7),SPROWWage money,Age int,CompanyContribution NVARCHAR(50) )

		INSERT INTO #EmployeeData
		SELECT MasterId, EmployeeId, OrdinaryWage, AdditionalWage, IdType, Contributionfor, Id ,SPRGranted ,SPROWWage,Age,CompanyContribution
		FROM HR.PayrollDetails
		WHERE MasterId = @PayrollId and (CPFExampted=0 or CPFExampted is null)

		SET @TotalCount = (
				SELECT COUNT(S_No)
				FROM #EmployeeData
				)

		WHILE @TotalCount >= @ReCount
		BEGIN --mm
		PRINT 'Entered into CPF Calculations SP 1 Employee loop'

		set @EmployeeCPF=0
		set @EmployerCPF=0
		set @OW=0
		
			SELECT @OW = OW, @AW = AW, @TempPayrollMasterId = TempPayrollMasterId, @EmployeeId = EmployeeId, @IdType = IdType, @Contribution = Contributionfor, @PayrollDetailId = DetailId , @SPRGranted=SPRGranted,@SPROWWage=SPROWWage,@Age=Age,@EmployeeCompanyContribution=CompanyContribution
			FROM #EmployeeData
			WHERE S_No = @ReCount
			print @EmployeeId
			--print @IdType
			--print @Contribution
			--print @Age
			if( @SPRGranted is not null and MONTH(@SPRGranted)=MONTH(@PayrollStartDate) and YEAR(@SPRGranted)=year(@PayrollStartDate))
			begin 
			print 'Into SPR'
			set @OW = @SPROWWage
			end 



			SET @GrossWage = @OW + @AW
			--IF (@IsAWCalc != 1)
			--BEGIN
			--	PRINT 'no AW calculations'

			--	SET @GrossWage = @OW + @AW

			--	PRINT @GrossWage
			--END
			--ELSE
			--BEGIN
			--	PRINT ' AW calculations'

			--	SET @GrossWage = @AW

			--	PRINT @GrossWage
			--END

			--select  @Contribution
			PRINT @Contribution

			IF (@Contribution IS NOT NULL AND @Contribution != '')
			BEGIN --20
				PRINT 'Contribution is present'

				SELECT @OrdinaryWageCap = isnull(OrdinaryWageCap, 0), @EmpOrdinaryWageRate = isnull(EmpOrdinaryWageRate, 0), @EmprOrdinaryWageRate = isnull(EmprOrdinaryWageRate, 0), @EmpDifferentialsWageAmt = isnull(EmpDifferentialsWageAmt, 0), @EmprDifferentialsWageAmt = isnull(EmprDifferentialsWageAmt, 0), @EmpDifferentialsWageRate = isnull(EmpDifferentialsWageRate, 0), @EmprDifferentialsWageRate = isnull(EmprDifferentialsWageRate, 0), @EmprTotalWageRate = isnull(EmprTotalWageRate, 0)
				FROM #CPFSettings
				WHERE TotalWageFrom <= @GrossWage AND TotalWageTo >= @GrossWage AND CountryCode = @Country AND AgeFrom <= @Age AND AgeTo >= @Age AND ContributionFor = @Contribution

				PRINT 'CPF rates selected'
				PRINT @OrdinaryWageCap
				set @OW=(CASE WHEN @OW <= @OrdinaryWageCap THEN @OW WHEN @OW > @OrdinaryWageCap THEN @OrdinaryWageCap ELSE @OW END)

				IF (@IsAWCalc != 1)
			BEGIN
				PRINT 'no AW calculations'
				--print @SPRGranted
			--	if( @SPRGranted is not null    and MONTH(@SPRGranted)=MONTH(@PayrollStartDate) and YEAR(@SPRGranted)=year(@PayrollStartDate))
			--begin 
			--print 'SPRGranted matching'
			--set @TotalWage = @SPROWWage + @AW
			--end 
			--else
			--begin
				SET @TotalWage = @OW + @AW
				--end

				PRINT @TotalWage
			END
			ELSE
			BEGIN
				PRINT ' AW calculations'
			--	if( @SPRGranted is not null and @SPRGranted !=null   and MONTH(@SPRGranted)=MONTH(@PayrollStartDate) and YEAR(@SPRGranted)=year(@PayrollStartDate))
			--begin 
			--print 'SPRGranted matching'
			--set @TotalWage = @SPROWWage + @AW
			--end 
			--else
			--begin
				SET @TotalWage = @AW
				--end

				PRINT @TotalWage
			END
			PRINT '@TotalWage'
			print  @TotalWage
				-----*********************
				--select * FROM #CPFSettings
				--WHERE TotalWageFrom <= @TotalWage AND TotalWageTo >= @TotalWage AND CountryCode = @Country and AgeFrom<@Age and AgeTo>=@Age
				-----*********************
				SET @TotalDifferentialWageAmount = isnull(@EmpDifferentialsWageAmt, 0) + isnull(@EmprDifferentialsWageAmt, 0)
				SET @TotalDifferentialWageRate = isnull(@EmpDifferentialsWageRate, 0) + ISNULL(@EmprDifferentialsWageRate, 0)
				if(@IdType='NRIC(Blue)' and @EmployeeCompanyContribution is not null and @EmployeeCompanyContribution!='' and @EmployeeCompanyContribution!=@Contribution)
				begin
				SELECT @EmprOrdinaryWageRate = isnull(EmprOrdinaryWageRate, 0)
				FROM #CPFSettings
				WHERE TotalWageFrom <= @GrossWage AND TotalWageTo >= @GrossWage AND CountryCode = @Country AND AgeFrom <= @Age AND AgeTo >= @Age AND ContributionFor = @EmployeeCompanyContribution
				SET @TotalCPFContributionRate = isnull(@EmpOrdinaryWageRate, 0) + isnull(@EmprOrdinaryWageRate, 0)
				end
				else
				begin
				SET @TotalCPFContributionRate = isnull(@EmpOrdinaryWageRate, 0) + isnull(@EmprOrdinaryWageRate, 0)
				end

				PRINT '@TotalDifferentialWageAmount '
				print @TotalCPFContributionRate

				IF (@TotalDifferentialWageAmount > 0 AND @TotalDifferentialWageRate > 0)
				BEGIN --17
					PRINT '@TotalDifferentialWageAmount > 0 AND @TotalDifferentialWageRate > 0'
					--print '>0'
					PRINT 'Total CPF COntribution'

					SET @TotalCPFContribution = (@TotalCPFContributionRate * @TotalWage) + ((@TotalWage - @TotalDifferentialWageAmount) * (@TotalDifferentialWageRate));

					PRINT @TotalCPFContribution
					print 'Emp diff wage rate '
					print @EmpDifferentialsWageRate

					SET @EmployeeCPF = (@EmpDifferentialsWageRate) * (@TotalWage - @TotalDifferentialWageAmount);
					set @EmployeeCPF=round(@EmployeeCPF,0,1)
					PRINT 'Employee CPF'
					PRINT @EmployeeCPF
				END ---17
				ELSE
				BEGIN --18
					PRINT 'else'

					--print '=0'
					--print @EmpOrdinaryWageRate
					SET @TotalCPFContribution = @TotalCPFContributionRate * @TotalWage;
					SET @EmployeeCPF = ((@EmpOrdinaryWageRate) * @TotalWage);
					set @EmployeeCPF=round(@EmployeeCPF,0,1)
					print 'Emp diff wage rate '
					print @EmpOrdinaryWageRate
					PRINT 'Employee CPF'
					PRINT @EmployeeCPF
				END --18 

				IF (@EmprTotalWageRate > 0)
				BEGIN --19
					PRINT 'if @EmprTotalWageRate > 0'

					SET @TotalCPFContribution = (@TotalWage * @EmprTotalWageRate) + ((@TotalWage - @TotalDifferentialWageAmount) * @TotalDifferentialWageRate);

					PRINT @TotalCPFContribution
				END --19
				--SET @EmployerCPF = @TotalCPFContribution - @EmployeeCPF
				print '@TotalCPFContribution'
				print @TotalCPFContribution
				print '@EmployeeCPF'
				print @EmployeeCPF
				SET @EmployerCPF = (case when (@TotalCPFContribution-(round(@TotalCPFContribution,0,1))) >0.5 then CEILING( @TotalCPFContribution) else Floor(@TotalCPFContribution) end) - @EmployeeCPF
			END --20
					--((@TotalCPFContribution - decimal.Truncate(TotalCPFContribution)) >= 0.5M ? decimal.Ceiling(TotalCPFContribution) : decimal.Round(TotalCPFContribution)) - employeecpf_new;

					print 'EMP CPF & EMPR CPF '
					print @EmployeeCPF
					print @EmployerCPF
			UPDATE HR.PayrollDetails
			SET EmployeeCPF = @EmployeeCPF, EmployerCPF = @EmployerCPF, OrdinaryWageCap = @OrdinaryWageCap
			WHERE Id = @PayrollDetailId
			Delete HR.PayrollSplit where PayrollDetailId=@PayrollDetailId and PayComponentId=@EMPCPFPayComponentId
			Delete HR.PayrollSplit where PayrollDetailId=@PayrollDetailId and PayComponentId=@EMPRCPFPayComponentId


			insert into HR.PayrollSplit (Id,PayrollDetailId,PayComponentId,PayType,Amount,Recorder,IsTemporary) select NEWID(),@PayrollDetailId,@EMPCPFPayComponentId,@PayTypeEMPCPF,@EmployeeCPF,@EMPCPFRecorder,1
			insert into HR.PayrollSplit (Id,PayrollDetailId,PayComponentId,PayType,Amount,Recorder,IsTemporary) select NEWID(),@PayrollDetailId,@EMPRCPFPayComponentId,@PayTypeEMPRCPF,@EmployerCPF,@EMPRCPFRecorder,1

			SET @ReCount = @ReCount + 1;
				--SELECT @EmployeeCPF, @EmployerCPF, @OrdinaryWageCap,@Contribution
		END --mm

		PRINT 'exit from CPF Calculations'

		IF OBJECT_ID(N'tempdb..#CPFSettings') IS NOT NULL
		BEGIN
			DROP TABLE #CPFSettings
		END

		IF OBJECT_ID(N'tempdb..#EmployeeData') IS NOT NULL
		BEGIN
			DROP TABLE #EmployeeData
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
