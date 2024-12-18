USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CPFCalculations]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CPFCalculations] (@OW MONEY, @AW MONEY, @Country NVARCHAR(50), @SubCompanyId BIGINT, @Age INT, @IdType NVARCHAR(20),@EmployeeCPF MONEY output,@EmployerCPF MONEY output,@OrdinaryWageCap MONEY output,@Contribution NVARCHAR(50) output,@IsAWCalc bit,@CPFSettings CPFSettings readonly,@PayrollStartDate DATETIME2(7),@SPRGranted DATETIME2(7),@SPRExpiry DATETIME2(7),@EmployeeCompanyContribution NVARCHAR(50))
AS
BEGIN
BEGIN TRANSACTION --1

	BEGIN TRY --2
print 'Entered into CPF Calculations'
--exec [dbo].[CPFCalculations] 5500, 5500, 'SG', 1, 32 , 'NRIC(Blue)'
--exec [dbo].[CPFCalculations] 5500, 5500, 'SG', 1, 32 , 'NRIC(Pink)'
	DECLARE @CPFExampted BIT =0
	--DECLARE @PayrollStartDate DATETIME2(7)='2021-04-01 00:00:00.0000000'
	--DECLARE @SPRGranted DATETIME2(7)='2020-04-01 00:00:00.0000000'
	--DECLARE @SPRExpiry DATETIME2(7)
	DECLARE @IsCPFContributionFull BIT=0
	--DECLARE @Contribution NVARCHAR(50)
	DECLARE @CompanyContribution NVARCHAR(20)
	DECLARE @TotalWage MONEY
	--DECLARE @OrdinaryWageCap MONEY
	DECLARE @EmpOrdinaryWageRate MONEY
	DECLARE @EmprOrdinaryWageRate MONEY
	DECLARE @EmpDifferentialsWageAmt MONEY
	DECLARE @EmprDifferentialsWageAmt MONEY
	DECLARE @EmpDifferentialsWageRate MONEY
	DECLARE @EmprDifferentialsWageRate MONEY
	--DECLARE @EmployeeCPF MONEY
	--DECLARE @EmployerCPF MONEY
	DECLARE @TotalCPFContributionRate MONEY
	DECLARE @TotalDifferentialWageAmount MONEY
	DECLARE @TotalDifferentialWageRate MONEY
	DECLARE @TotalCPFContribution MONEY
	DECLARE @EmprTotalWageRate MONEY
	
	--print @IsCPFContributionFull

	--CREATE TABLE #CPFSettings ([Id] [uniqueidentifier] NOT NULL, [CompanyId] [bigint] NOT NULL, [ContributionFor] [nvarchar](256) NULL, [AgeFrom] [int] NULL, [AgeTo] [int] NULL, [TotalWageFrom] [money] NULL, [TotalWageTo] [money] NULL, [EmprTotalWageRate] [money] NULL, [EmpDifferentialsWageAmt] [money] NULL, [EmprDifferentialsWageAmt] [money] NULL, [EmpDifferentialsWageRate] [money] NULL, [EmprDifferentialsWageRate] [money] NULL, [EmpOrdinaryWageRate] [money] NULL, [EmprOrdinaryWageRate] [money] NULL, [OrdinaryWageCap] [money] NULL, [OrdinaryWageCapInMonths] [int] NULL, [EmpAdditionalWageRate] [money] NULL, [EmprAdditionalWageRate] [money] NULL, [EffectiveFrom] [datetime2](7) NULL, [EffectiveTo] [datetime2](7) NULL, [CountryCode] [nvarchar](10) NULL);

	--INSERT INTO #CPFSettings
	--SELECT id, CompanyId, ContributionFor, AgeFrom, AgeTo, TotalWageFrom, TotalWageTo, EmprTotalWageRate, EmpDifferentialsWageAmt, EmprDifferentialsWageAmt, EmpDifferentialsWageRate, EmprDifferentialsWageRate, EmpOrdinaryWageRate, EmprOrdinaryWageRate, OrdinaryWageCap, OrdinaryWageCapInMonths, EmpAdditionalWageRate, EmprAdditionalWageRate, EffectiveFrom, EffectiveTo, CountryCode
	--FROM hr.CPFSettings
	--WHERE STATUS = 1 AND CONVERT(DATE, EffectiveFrom) <= @PayrollStartDate AND CONVERT(DATE, EffectiveTo) > @PayrollStartDate

	
	if (@IsAWCalc!=1)
	begin
	print 'no AW calculations'
		SET @TotalWage = @OW + @AW
		print @TotalWage
		end
		else
		begin
		print ' AW calculations'
		SET @TotalWage =@AW
		print @TotalWage
		end
		--print @TotalWage
		SELECT @CompanyContribution = EmployeeCPFContribution
		FROM hr.CompanyPayrollSettings (NOLOCK)
		WHERE CompanyId = @SubCompanyId AND STATUS = 1
		print @CompanyContribution

		IF (@CPFExampted = 0 or @CPFExampted is null)
		BEGIN --16
		print 'No CPF exemption'
		if(@Contribution is  null or @Contribution='')
		begin --mm
		print 'Entered into COntribution'
			IF (@IdType = 'NRIC(Blue)')
			BEGIN --3 
			--print 'blue'
				IF (@PayrollStartDate <= DATEADD(year, 1, @SPRGranted))
				BEGIN --4
					IF (@IsCPFContributionFull is not null)
					BEGIN --7
					--print 'First year'
						IF (@IsCPFContributionFull = 1)
						BEGIN --8
							SET @Contribution = 'SPR 1st year-Full'
						END --8
						ELSE
						BEGIN --9
							SET @Contribution = 'SPR 1st year-Graduated'
						END --9		
					END --7
					ELSE
					BEGIN --10
						SET @Contribution = ('SPR 1st year-' + @CompanyContribution)
					END --10
				END --4
				ELSE IF (@PayrollStartDate <= DATEADD(year, 2, @SPRGranted) AND @PayrollStartDate > DATEADD(year, 1, @SPRGranted))
				BEGIN --5
				--print 'second year'
					IF (@IsCPFContributionFull is not  NULL)
					BEGIN --11
						IF (@IsCPFContributionFull = 1)
						BEGIN --12
							SET @Contribution = 'SPR 2nd year-Full'
						END --12
						ELSE
						BEGIN --13
							SET @Contribution = 'SPR 2nd year-Graduated'
						END --13		
					END --11
					ELSE
					BEGIN --14
						SET @Contribution = ('SPR 2nd year-' + @CompanyContribution)
					END --14
				END --5
				ELSE IF (@PayrollStartDate > DATEADD(year, 2, @SPRGranted))
				BEGIN --6
					SET @Contribution = 'Singaporean'
				END --6
			END --3
			ELSE IF (@IdType = 'NRIC(Pink)')
			BEGIN --15
			--print 'pink'
				SET @Contribution = 'Singaporean'
			END --15
			end--mm
		END --16
		--select  @Contribution
		print @Contribution
		if(@Contribution is not null and @Contribution!='')
		begin --20
		print 'Contribution is present'
		SELECT @OrdinaryWageCap = isnull(OrdinaryWageCap,0), @EmpOrdinaryWageRate = isnull(EmpOrdinaryWageRate,0), @EmprOrdinaryWageRate = isnull(EmprOrdinaryWageRate,0), @EmpDifferentialsWageAmt =isnull( EmpDifferentialsWageAmt,0), @EmprDifferentialsWageAmt = isnull(EmprDifferentialsWageAmt,0), @EmpDifferentialsWageRate = isnull(EmpDifferentialsWageRate,0), @EmprDifferentialsWageRate = isnull(EmprDifferentialsWageRate,0), @EmprTotalWageRate = isnull(EmprTotalWageRate,0)
		FROM @CPFSettings
		WHERE TotalWageFrom <= @TotalWage AND TotalWageTo >= @TotalWage AND CountryCode = @Country and AgeFrom<=@Age and AgeTo>=@Age and ContributionFor=@Contribution
		print 'CPF rates selected'
		print @EmpDifferentialsWageAmt
		-----*********************
		--select * FROM #CPFSettings
		--WHERE TotalWageFrom <= @TotalWage AND TotalWageTo >= @TotalWage AND CountryCode = @Country and AgeFrom<@Age and AgeTo>=@Age
		-----*********************

		SET @TotalDifferentialWageAmount = isnull(@EmpDifferentialsWageAmt, 0) + isnull(@EmprDifferentialsWageAmt, 0)
		SET @TotalDifferentialWageRate = isnull(@EmpDifferentialsWageRate, 0) + ISNULL(@EmprDifferentialsWageRate, 0)
		
		if(@IdType = 'NRIC(Blue)' and @EmployeeCompanyContribution is not null and @EmployeeCompanyContribution!='' and @EmployeeCompanyContribution!=@Contribution)
		begin 
		SELECT @EmprOrdinaryWageRate = isnull(EmprOrdinaryWageRate,0)
		FROM @CPFSettings
		WHERE TotalWageFrom <= @TotalWage AND TotalWageTo >= @TotalWage AND CountryCode = @Country and AgeFrom<=@Age and AgeTo>=@Age and ContributionFor=@EmployeeCompanyContribution
		SET @TotalCPFContributionRate = isnull(@EmpOrdinaryWageRate, 0) + isnull(@EmprOrdinaryWageRate, 0)
		end
		else 
		begin 
		SET @TotalCPFContributionRate = isnull(@EmpOrdinaryWageRate, 0) + isnull(@EmprOrdinaryWageRate, 0)
		end
		print 'if'
		IF (@TotalDifferentialWageAmount > 0 AND @TotalDifferentialWageRate > 0)
		BEGIN --17
		print'@TotalDifferentialWageAmount > 0 AND @TotalDifferentialWageRate > 0'
		--print '>0'
		print 'Total CPF COntribution'
			SET @TotalCPFContribution = (@TotalCPFContributionRate * @TotalWage) + ((@TotalWage - @TotalDifferentialWageAmount) * (@TotalDifferentialWageRate));
			print @TotalCPFContribution
			SET @EmployeeCPF =( @EmpDifferentialsWageRate) * (@TotalWage - @TotalDifferentialWageAmount);
			set @EmployeeCPF=round(@EmployeeCPF,0,1)
			print 'Employee CPF'
			print @EmployeeCPF
		END ---17
		ELSE
		BEGIN --18
		print 'else'
		--print '=0'
		--print @EmpOrdinaryWageRate
			SET @TotalCPFContribution = @TotalCPFContributionRate * @TotalWage;
			SET @EmployeeCPF = ((@EmpOrdinaryWageRate) * @TotalWage);
			set @EmployeeCPF=round(@EmployeeCPF,0,1)
			print 'Employee CPF'
			print @EmployeeCPF
		END --18 

		IF (@EmprTotalWageRate > 0)
		BEGIN --19
		print 'if @EmprTotalWageRate > 0'
			SET @TotalCPFContribution = (@TotalWage * @EmprTotalWageRate) + ((@TotalWage - @TotalDifferentialWageAmount) * @TotalDifferentialWageRate);
			print @TotalCPFContribution
		END --19
		
		--SET @EmployerCPF = @TotalCPFContribution - @EmployeeCPF
		print @TotalCPFContribution
		print @EmployeeCPF
		--SET @EmployerCPF = (case when (@TotalCPFContribution-(round(@TotalCPFContribution,2,0))) >=0.5 then CEILING( @TotalCPFContribution) else Floor(@TotalCPFContribution) end) -  @EmployeeCPF
		SET @EmployerCPF = (case when (@TotalCPFContribution-(round(@TotalCPFContribution,0,1))) >0.5 then CEILING( @TotalCPFContribution) else Floor(@TotalCPFContribution) end) - @EmployeeCPF

		end--20
		--((@TotalCPFContribution - decimal.Truncate(TotalCPFContribution)) >= 0.5M ? decimal.Ceiling(TotalCPFContribution) : decimal.Round(TotalCPFContribution)) - employeecpf_new;
		

		--SELECT @EmployeeCPF, @EmployerCPF, @OrdinaryWageCap,@Contribution
		print 'exit from CPF Calculations'
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
