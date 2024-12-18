USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[AllEMPAWCPFCalculationsImport]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[AllEMPAWCPFCalculationsImport] (@Country NVARCHAR(50), @SubCompanyId BIGINT, @PayrollStartDate DATETIME2(7), @PayrollId UNIQUEIDENTIFIER,@ParentCompanyId bigint)
AS
BEGIN --1
	BEGIN TRANSACTION --2

	BEGIN TRY --3
		DECLARE @CPFSettings CPFSettings

		INSERT INTO @CPFSettings
		SELECT id, CompanyId, ContributionFor, AgeFrom, AgeTo, TotalWageFrom, TotalWageTo, EmprTotalWageRate, EmpDifferentialsWageAmt, EmprDifferentialsWageAmt, EmpDifferentialsWageRate, EmprDifferentialsWageRate, EmpOrdinaryWageRate, EmprOrdinaryWageRate, OrdinaryWageCap, OrdinaryWageCapInMonths, EmpAdditionalWageRate, EmprAdditionalWageRate, EffectiveFrom, EffectiveTo, CountryCode
		FROM SmartCursorTST.hr.CPFSettings
		WHERE STATUS = 1 AND CONVERT(DATE, EffectiveFrom) <= @PayrollStartDate AND CONVERT(DATE, EffectiveTo) > =@PayrollStartDate

		--exec [dbo].[CPFCalculations] 5500, 5500, 'SG', 1, 32 , 'NRIC(Blue)'
		--exec [dbo].[CPFCalculations] 5500, 5500, 'SG', 1, 32 , 'NRIC(Pink)'
		--DECLARE @PayrollStartDate DATETIME2(7) = '2021-04-01 00:00:00.0000000'	
		DECLARE @TotalMoths INT
		DECLARE @PastmonthNumber INT
		DECLARE @FutureMonthAmount MONEY
		DECLARE @FutureExistMonthCount INT
		DECLARE @FutureNonExistMonthAmont MONEY
		DECLARE @TotaolOWSubjectToCPF MONEY
		DECLARE @EmploymentEndDate DATETIME2(7)
		DECLARE @OW MONEY
		DECLARE @AW MONEY
		DECLARE @OWCAP MONEY
		DECLARE @Age INT
		DECLARE @Contribution NVARCHAR(50)
		DECLARE @TotalCount INT = 12
		DECLARE @Recount INT = 1
		DECLARE @TotalAWSubjectToCPF MONEY = 0;
		DECLARE @OWSubjectToCPF MONEY = 0;
		DECLARE @AWSubjectToCPF MONEY = 0;
		--declare @OrdinaryWageCap MONEY 
		DECLARE @OrdinaryWageCapInMonths INT
		DECLARE @EmpAdditionalWageRate MONEY
		DECLARE @EmpOrdinaryWageRate MONEY
		DECLARE @isExceeeded BIT
		DECLARE @EmployeeOWCPF MONEY
		DECLARE @EmployerOWCPF MONEY
		DECLARE @EmployeeAWCPF MONEY
		DECLARE @EmployerAWCPF MONEY
		DECLARE @OrdinaryWageCap MONEY
		--declare @Contribution money
		DECLARE @OWCPFPayable MONEY
		DECLARE @AWCPFPayable MONEY
		--Declare @EmpAdditionalWageRate money
		DECLARE @DeductEmpCPF MONEY = 0
		DECLARE @DeductEmprCPF MONEY = 0
		DECLARE @OWmonth MONEY
		DECLARE @AWmonth MONEY
		DECLARE @TotalCount1 INT
		DECLARE @ReCount1 INT=1
		DECLARE @TotalWage MONEY
		DECLARE @EmployeeId UNIQUEIDENTIFIER
		DECLARE @EmployeeAWCalcCPF MONEY
		DECLARE @EmployerAWCalcCPF MONEY
		DECLARE @IdType NVARCHAR(50)
		DECLARE @PayrollDetailId UNIQUEIDENTIFIER
			declare @EMPCPFPayComponentId uniqueidentifier	
	declare @PayTypeEMPCPF NVARCHAR(30)
	declare @EMPRCPFPayComponentId uniqueidentifier	
	declare @PayTypeEMPRCPF NVARCHAR(30)
	declare @SPRGranted datetime2(7)
	declare @SPROWWage money
	declare @SPRGranted1 datetime2(7)
	declare @SPROWWage1 money
	declare @exceededAW money
	declare @EmployeeCompanyContribution NVARCHAR(50)
	select @EMPCPFPayComponentId=Id,@PayTypeEMPCPF=Type from HR.PayComponent where CompanyId=@ParentCompanyId and Name='Employee CPF'
	select @EMPRCPFPayComponentId=Id,@PayTypeEMPRCPF=Type from HR.PayComponent where CompanyId=@ParentCompanyId and Name='Employer CPF'




		--print @IsCPFContributionFull
		--CREATE TABLE #CPFSettings ([Id] [uniqueidentifier] NOT NULL, [CompanyId] [bigint] NOT NULL, [ContributionFor] [nvarchar](256) NULL, [AgeFrom] [int] NULL, [AgeTo] [int] NULL, [TotalWageFrom] [money] NULL, [TotalWageTo] [money] NULL, [EmprTotalWageRate] [money] NULL, [EmpDifferentialsWageAmt] [money] NULL, [EmprDifferentialsWageAmt] [money] NULL, [EmpDifferentialsWageRate] [money] NULL, [EmprDifferentialsWageRate] [money] NULL, [EmpOrdinaryWageRate] [money] NULL, [EmprOrdinaryWageRate] [money] NULL, [OrdinaryWageCap] [money] NULL, [OrdinaryWageCapInMonths] [int] NULL, [EmpAdditionalWageRate] [money] NULL, [EmprAdditionalWageRate] [money] NULL, [EffectiveFrom] [datetime2](7) NULL, [EffectiveTo] [datetime2](7) NULL, [CountryCode] [nvarchar](10) NULL);
		CREATE TABLE #PayrollDetail ([Id] [uniqueidentifier] NOT NULL, [MasterId] [uniqueidentifier] NOT NULL, [EmployeeId] [uniqueidentifier] NOT NULL, [BasicPay] [money] NULL, [OrdinaryWage] [money] NULL, [AdditionalWage] [money] NULL, [OrdinaryWageCap] [money] NULL, Month1 INT, Year1 INT, PayrollStatus NVARCHAR(100),SPRGranted datetime2(7),SPROWWage money)

		CREATE TABLE #EMPPF_Tb1 (S_No INT Identity(1, 1), Month1 INT, year1 INT, EmpOW MONEY, EmprOW MONEY, EmpAW MONEY, EmprAW MONEY, EmployeeId UNIQUEIDENTIFIER)

		CREATE TABLE #EmployeeData (S_No INT Identity(1, 1), TempPayrollMasterId UNIQUEIDENTIFIER, Employeeid UNIQUEIDENTIFIER, OW MONEY, AW MONEY NULL, IdType NVARCHAR(50), Contributionfor NVARCHAR(50), DetailId UNIQUEIDENTIFIER,EmploymentEndDate datetime2(7),SPRGranted1 datetime2(7),SPROWWage1 money,Age int,EmployeeCompanyContribution NVARCHAR(50))

		INSERT INTO #EmployeeData
		SELECT MasterId, EmployeeId, OrdinaryWage, AdditionalWage, IdType, ContributionFor, Id,EmploymentEndDate,SPRGranted,SPROWWage,Age,CompanyContribution
		FROM [HR].[PayrollDetails]
		WHERE MasterId = @PayrollId AND AdditionalWage > 0

		SET @TotalCount1 = (
				SELECT COUNT(S_No)
				FROM #EmployeeData
				)

		WHILE @TotalCount1 >= @ReCount1
		BEGIN --mm
		--print @ReCount1

		SELECT @OW = OW, @AW = AW, @PayrollId = TempPayrollMasterId, @EmployeeId = EmployeeId, @IdType = IdType, @Contribution = Contributionfor, @PayrollDetailId = DetailId,@EmploymentEndDate=EmploymentEndDate,@SPRGranted1=SPRGranted1,@SPROWWage1=SPROWWage1,@Age=Age,@EmployeeCompanyContribution=EmployeeCompanyContribution
			FROM #EmployeeData
			WHERE S_No = @ReCount1

			--print '@EmployeeId'
			--print @EmployeeId
			--print '@OW'
			--print @OW
			--print '@AW'
			--print @AW
			if(@SPROWWage1>0 and  @SPRGranted1 is not null  and MONTH(@SPRGranted1)=MONTH(@PayrollStartDate) and YEAR(@SPRGranted1)=year(@PayrollStartDate))
			begin 
			--print 'SPR granted matched'
			set @OW = @SPROWWage1
			SET @TotalWage = @OW + @AW
			end 
			else
			begin
			SET @TotalWage = @OW + @AW
            end
			--print '@TotalWage'
			--print @TotalWage
			IF (@EmploymentEndDate IS NOT NULL)
			BEGIN --4
				SET @TotalMoths = MONTH(@EmploymentEndDate)
			END --4
			ELSE
			BEGIN --5
				SET @TotalMoths = 12
			END --5

			--print '@PastmonthNumber'
			
			SET @PastmonthNumber = (MONTH(@PayrollStartDate) - 1)
			--print @PastmonthNumber
			

			--PRINT 'tables declared'


			INSERT INTO #PayrollDetail
			SELECT pd.Id, pd.MasterId, pd.EmployeeId, pd.BasicPay, (CASE WHEN pd.OrdinaryWage <= pd.OrdinaryWageCap and pd.SPROWWage<=0 THEN pd.OrdinaryWage WHEN pd.OrdinaryWage > pd.OrdinaryWageCap and pd.SPROWWage<=0  THEN pd.OrdinaryWageCap WHEN pd.OrdinaryWage <= pd.OrdinaryWageCap and pd.SPROWWage>0 THEN pd.SPROWWage WHEN pd.SPROWWage > pd.OrdinaryWageCap and pd.SPROWWage>0  THEN pd.OrdinaryWageCap ELSE pd.OrdinaryWage END) AS OrdinaryWage, PD.AdditionalWage, PD.OrdinaryWageCap, month(PD.CreatedDate), p.Year, p.PayrollStatus,PD.SPRGranted,pd.SPROWWage
			FROM hr.Payroll P
			JOIN HR.PayrollDetails PD ON p.Id = PD.MasterId
			WHERE (p.IsTemporary = 0 OR p.IsTemporary IS NULL or p.Id=@PayrollId) AND p.Year = year(@PayrollStartDate) AND pd.EmployeeId = @EmployeeId   AND (p.PayrollStatus != 'Cancelled' or p.PayrollStatus is null)

			--INSERT INTO #PayrollDetail
			--SELECT pd.Id, pd.MasterId, pd.EmployeeId, pd.BasicPay, (CASE WHEN pd.OrdinaryWage <= pd.OrdinaryWageCap THEN pd.OrdinaryWage WHEN pd.OrdinaryWage > pd.OrdinaryWageCap THEN pd.OrdinaryWageCap ELSE pd.OrdinaryWage END) AS OrdinaryWage, PD.AdditionalWage, PD.OrdinaryWageCap, month(PD.CreatedDate), p.Year, p.PayrollStatus,PD.SPRGranted,pd.SPROWWage
			--FROM hr.Payroll P
			--JOIN HR.PayrollDetails PD ON p.Id = PD.MasterId
			--WHERE p.Id=@PayrollId AND pd.EmployeeId = @EmployeeId 

			--select * from  #PayrollDetail
			--select * from #PayrollDetail
			--PRINT 'Payroll Detail table inserted declared'
			
			
			SET @FutureMonthAmount = (
					CASE WHEN @OWCAP >= (
								SELECT isnull([OrdinaryWage],0)
								FROM #PayrollDetail
								WHERE Month1 = Month(@PayrollStartDate)
								) THEN @OWCAP ELSE (
								SELECT isnull( [OrdinaryWage],0)
								FROM #PayrollDetail
								WHERE Month1 = Month(@PayrollStartDate)
								) END
					)
					--print '@FutureMonthAmount'
					--print @FutureMonthAmount
			SET @FutureExistMonthCount = (
					SELECT count(id)
					FROM #PayrollDetail
					WHERE Month1 >= Month(@PayrollStartDate)
					)
					--print '@FutureExistMonthCount'
					--print @FutureExistMonthCount
			SET @FutureNonExistMonthAmont = (isnull(@TotalMoths,0) - (isnull(@PastmonthNumber ,0)+ isnull(@FutureExistMonthCount,0))) * (isnull(@FutureMonthAmount,0))
			--print '@FutureNonExistMonthAmont'
			--print  @FutureNonExistMonthAmont
			SET @TotaolOWSubjectToCPF = (
					SELECT sum(isnull(OrdinaryWage, 0))
					FROM #PayrollDetail
					WHERE Month1 < Month(@PayrollStartDate)
					) + (
					SELECT sum(isnull(OrdinaryWage, 0))
					FROM #PayrollDetail
					WHERE Month1 >= Month(@PayrollStartDate)
					) + @FutureNonExistMonthAmont
					--print '@TotaolOWSubjectToCPF-Employee loop'
					--print @TotaolOWSubjectToCPF
			SET @TotalCount = 12
			SET @Recount = 1
			SET @TotalAWSubjectToCPF = 0;
			SET @OWSubjectToCPF = 0;
			SET @AWSubjectToCPF = 0;
			--declare @OrdinaryWageCap MONEY 
			SET @OrdinaryWageCapInMonths = 0;
			SET @EmpAdditionalWageRate = 0
			SET @EmpOrdinaryWageRate = 0
			SET @isExceeeded = 0
			SET @EmployeeOWCPF = 0
			SET @EmployerOWCPF = 0
			SET @EmployeeAWCPF = 0
			SET @EmployerAWCPF = 0
			SET @OrdinaryWageCap = 0
			--declare @Contribution money
			SET @OWCPFPayable = 0
			SET @AWCPFPayable = 0
			--Declare @EmpAdditionalWageRate money
			SET @DeductEmpCPF = 0
			SET @DeductEmprCPF = 0
			SET @OWmonth = 0
			SET @AWmonth = 0

			--Declare @DateString NVARCHAR(50)
			DECLARE @PayrollStartDateLoop DATETIME2(7)

			SELECT @OrdinaryWageCap = OrdinaryWageCap, @OrdinaryWageCapInMonths = OrdinaryWageCapInMonths, @EmpAdditionalWageRate = EmpAdditionalWageRate, @EmpOrdinaryWageRate = EmpOrdinaryWageRate
			FROM @CPFSettings
			WHERE TotalWageFrom <= @TotalWage AND TotalWageTo >= @TotalWage AND CountryCode = @Country AND AgeFrom <= @Age AND AgeTo >= @Age AND ContributionFor = @Contribution

			--print '@OrdinaryWageCapInMonths'
			--print @OrdinaryWageCapInMonths
			--print '@OrdinaryWageCap'
			--print @OrdinaryWageCap
			WHILE @TotalCount >= @Recount
			BEGIN --6
				--PRINT 'entered into loop'
				--PRINT @Recount

				SET @OWmonth = 0
				--SELECT CONVERT(DATETIME,'13/12/2019',103)
				SET @PayrollStartDateLoop = CONVERT(DATETIME, ('01/' + CAST(@Recount AS NVARCHAR(10)) + '/' + CAST((year(@PayrollStartDate)) AS NVARCHAR(10))), 105);
				
				--set @PayrollStartDateLoop=convert(datetime,@PayrollStartDateLoop,105) 
				--PRINT @PayrollStartDateLoop

				SELECT @OWmonth = OrdinaryWage, @AWmonth = AdditionalWage,@SPRGranted=SPRGranted,@SPROWWage=SPROWWage
				FROM #PayrollDetail
				WHERE Month1 = @Recount

				if(@SPROWWage>0 and @SPRGranted is not null and @SPRGranted !=null   and MONTH(@SPRGranted)=MONTH(@PayrollStartDateLoop) and YEAR(@SPRGranted)=year(@PayrollStartDateLoop))
			begin 
			
			set @OWmonth = @SPROWWage
			end 
			--print '@TotalAWSubjectToCPF'
			--print @TotalAWSubjectToCPF
				SET @TotalAWSubjectToCPF = (
						@TotalAWSubjectToCPF + (
							 isnull(@AWmonth,0)
							
							)
						)
			--			print '@TotalAWSubjectToCPF'
			--print @TotalAWSubjectToCPF
						
				SET @OWSubjectToCPF = isnull(@OWmonth, 0);

						--	print '@OWSubjectToCPF'
						--print @OWSubjectToCPF
				IF (@EmploymentEndDate IS NOT NULL)
				BEGIN --7
					--PRINT 'Employee End date is present'

					IF (@EmploymentEndDate >= @PayrollStartDateLoop)
					BEGIN --8
						--PRINT '@EmploymentEndDate >= @PayrollStartDateLoop'

						IF (month(@EmploymentEndDate) = month(@PayrollStartDateLoop) AND year(@EmploymentEndDate) = year(@PayrollStartDateLoop))
						BEGIN --9
							--PRINT 'payroll month and enddate is same '

							SET @AWSubjectToCPF = isnull((@AWmonth
										), 0) + (
									12 - @Recount * (@OWmonth
										)
									)

							--PRINT @AWSubjectToCPF
						END --9
					END --8
				END --7
				ELSE
				BEGIN --10
					--PRINT 'Employee End date is not present'

					--DECLARE @m MONEY = (@AWmonth
					--		)

					--PRINT @m

					SET @AWSubjectToCPF = isnull((@AWmonth
								), 0)

					--PRINT @AWSubjectToCPF
				END --10

				--print 'AW wxceed loop top'
				
				IF ((@TotalAWSubjectToCPF + @TotaolOWSubjectToCPF) >= (@OrdinaryWageCap * @OrdinaryWageCapInMonths) AND (@isExceeeded = 0 OR @isExceeeded IS NULL))
				BEGIN --11
					--PRINT 'AW binding if is exceeded first time'
					
					--print (@OrdinaryWageCap * @OrdinaryWageCapInMonths) 
					set @exceededAW =  (select sum( ISNULL(AdditionalWage,0)) from #PayrollDetail where Month1<MONTH(@PayrollStartDateLoop))
					
					--print (@TotaolOWSubjectToCPF + @exceededAW )
					SET @AWSubjectToCPF = CASE WHEN (select sum( ISNULL(AdditionalWage,0)) from #PayrollDetail where Month1=MONTH(@PayrollStartDateLoop)) > 0 THEN ((@OrdinaryWageCap * @OrdinaryWageCapInMonths) - (@TotaolOWSubjectToCPF + @exceededAW)) ELSE ((@OrdinaryWageCap * @OrdinaryWageCapInMonths) - @TotaolOWSubjectToCPF) END
					--print '@AWSubjectToCPF'
					--print @AWSubjectToCPF
					SET @isExceeeded = 1
				END --11
				ELSE IF (@isExceeeded = 0 OR @isExceeeded IS NULL)
				BEGIN --12
					--PRINT 'AW binding if is exceeded false'

					SET @AWSubjectToCPF = isnull((
								SELECT AdditionalWage
								FROM #PayrollDetail
								WHERE Month1 = @Recount
								), 0)

					--PRINT @AWSubjectToCPF
				END --12
				ELSE
				BEGIN --13
					--PRINT 'AW already Exceeded'

					SET @AWSubjectToCPF = 0
				END --13

				IF (@isExceeeded = 1)
				BEGIN --14
					--PRINT 'Additional wage exceeded'

					EXEC [dbo].[CPFCalculations] @OW = @OWmonth, @AW = 0, @Country = @Country, @SubCompanyId = @SubCompanyId, @Age = @Age, @IdType = @IdType, @EmployeeCPF = @EmployeeOWCPF OUTPUT, @EmployerCPF = @EmployerOWCPF OUTPUT, @OrdinaryWageCap = @OrdinaryWageCap OUTPUT, @Contribution = @Contribution OUTPUT, @IsAWCalc = 0, @CPFSettings = @CPFSettings, @PayrollStartDate = @PayrollStartDate, @SPRGranted = NULL, @SPRExpiry = NULL,@EmployeeCompanyContribution=@EmployeeCompanyContribution

					--print '@AWSubjectToCPF0'
					--print @AWSubjectToCPF
					--insert into #EMPPF_Tb1 select Month(@PayrollStartDate),year(@PayrollStartDate),@EmployeeCPF,@EmployerCPF,0,0,@EmployeeId	
					EXEC [dbo].[CPFCalculations] @OW = @OWmonth, @AW = @AWSubjectToCPF, @Country = @Country, @SubCompanyId = @SubCompanyId, @Age = @Age, @IdType = @IdType, @EmployeeCPF = @EmployeeAWCPF OUTPUT, @EmployerCPF = @EmployerAWCPF OUTPUT, @OrdinaryWageCap = @OrdinaryWageCap OUTPUT, @Contribution = @Contribution OUTPUT, @IsAWCalc = 1, @CPFSettings = @CPFSettings, @PayrollStartDate = @PayrollStartDate, @SPRGranted = NULL, @SPRExpiry = NULL,@EmployeeCompanyContribution=@EmployeeCompanyContribution
						--insert into #EMPPF_Tb1 select Month(@PayrollStartDate),year(@PayrollStartDate),0,0,@EmployeeCPF,@EmployerCPF,@EmployeeId	
				END --14
				ELSE
				BEGIN --15
					--PRINT 'AW not exceeded'
					--PRINT 'OW'
					--PRINT @OWmonth
					--PRINT 'AW'
					--PRINT @AWSubjectToCPF

					EXEC [dbo].[CPFCalculations] @OW = @OWmonth, @AW = @AWSubjectToCPF, @Country = @Country, @SubCompanyId = @SubCompanyId, @Age = @Age, @IdType = @IdType, @EmployeeCPF = @EmployeeOWCPF OUTPUT, @EmployerCPF = @EmployerOWCPF OUTPUT, @OrdinaryWageCap = @OrdinaryWageCap OUTPUT, @Contribution = @Contribution OUTPUT, @IsAWCalc = 0, @CPFSettings = @CPFSettings, @PayrollStartDate = @PayrollStartDate, @SPRGranted = NULL, @SPRExpiry = NULL,@EmployeeCompanyContribution=@EmployeeCompanyContribution
						--insert into #EMPPF_Tb1 select Month(@PayrollStartDate),year(@PayrollStartDate),@EmployeeCPF,@EmployerCPF,0,0,@EmployeeId
				END --15

				SET @OWCPFPayable = isnull(@EmployeeOWCPF, 0) + isnull(@EmployerOWCPF, 0)
				SET @AWCPFPayable = isnull(@EmployeeAWCPF, 0) + isnull(@EmployerAWCPF, 0)

				--PRINT 'OW monthly Employee CPF'
				--PRINT @OWCPFPayable
				--PRINT 'AW monthly Employee CPF'
				--PRINT @AWCPFPayable
				--PRINT 'Is exceeded'
				--PRINT @isExceeeded

				SET @EmployeeAWCPF = CASE WHEN @isExceeeded = 1 THEN @EmpAdditionalWageRate * @AWSubjectToCPF ELSE 0 END
				SET @EmployerAWCPF = CASE WHEN @isExceeeded = 1 THEN @AWCPFPayable - @EmployeeAWCPF ELSE 0 END
				SET @EmployeeOWCPF = CASE WHEN @isExceeeded = 1 THEN @OWmonth * @EmpOrdinaryWageRate ELSE @EmployeeOWCPF END
				SET @EmployerOWCPF = CASE WHEN @isExceeeded = 1 THEN @OWCPFPayable - @EmployeeOWCPF ELSE @EmployerOWCPF END

				--PRINT 'EmployeeAWCPF'
				--PRINT @EmployeeAWCPF
				--PRINT 'EmployerAWCPF'
				--PRINT @EmployerAWCPF
				--PRINT 'EmployeeOWCPF'
				--PRINT @EmployeeOWCPF
				--PRINT 'EmployerOWCPF'
				--PRINT @EmployerOWCPF

				INSERT INTO #EMPPF_Tb1
				SELECT Month(@PayrollStartDateLoop), year(@PayrollStartDateLoop), @EmployeeOWCPF, @EmployerOWCPF, @EmployeeAWCPF, @EmployerAWCPF, @EmployeeId

				SET @Recount = @Recount + 1
			END --6

			--PRINT 'Count in Main monthly CPF table '

			DECLARE @CheckCount INT = (
					SELECT count(S_No)
					FROM #EMPPF_Tb1
					)

			--PRINT @CheckCount

			--select * from  #EMPPF_Tb1
			--select * from #EMPPF_Tb1
			IF (@EmploymentEndDate IS NOT NULL)
			BEGIN --16
				IF (month(@EmploymentEndDate) = month(@PayrollStartDate) AND year(@EmploymentEndDate) = year(@PayrollStartDate))
				BEGIN --17
					SET @DeductEmpCPF = (
							SELECT isnull((EmpOW), 0)
							FROM #EMPPF_Tb1
							WHERE EmployeeId = @employeeId AND year1 = year(@PayrollStartDate) AND Month1 = month(@PayrollStartDate) AND Month1 > month(@EmploymentEndDate)
							) + (
							SELECT isnull((EmpAW), 0)
							FROM #EMPPF_Tb1
							WHERE EmployeeId = @employeeId AND year1 = year(@PayrollStartDate) AND Month1 = month(@PayrollStartDate) AND Month1 > month(@EmploymentEndDate)
							)
					SET @DeductEmprCPF = (
							SELECT isnull((EmprOW), 0)
							FROM #EMPPF_Tb1
							WHERE EmployeeId = @employeeId AND year1 = year(@PayrollStartDate) AND Month1 = month(@PayrollStartDate) AND Month1 > month(@EmploymentEndDate)
							) + (
							SELECT isnull((EmprAW), 0)
							FROM #EMPPF_Tb1
							WHERE EmployeeId = @employeeId AND year1 = year(@PayrollStartDate) AND Month1 = month(@PayrollStartDate) AND Month1 > month(@EmploymentEndDate)
							)
				END --17
			END --16

			--PRINT 'Final Calculation values'

			--DECLARE @i MONEY = (
			--		SELECT isnull((EmpOW), 0)
			--		FROM #EMPPF_Tb1
			--		WHERE EmployeeId = @employeeId AND year1 = year(@PayrollStartDate) AND Month1 = month(@PayrollStartDate)
			--		)

			--PRINT 'Employee OW for payroll month extracting from table'
			--PRINT @i
			--PRINT 'Employee AW for payroll month extracting from table'

			--DECLARE @j MONEY = (
			--		SELECT isnull((EmpAW), 0)
			--		FROM #EMPPF_Tb1
			--		WHERE EmployeeId = @employeeId AND year1 = year(@PayrollStartDate) AND Month1 = month(@PayrollStartDate)
			--		)

			--PRINT @j
			--PRINT 'Employer OW for payroll month extracting from table'

			--DECLARE @k MONEY = (
			--		SELECT isnull((EmprOW), 0)
			--		FROM #EMPPF_Tb1
			--		WHERE EmployeeId = @employeeId AND year1 = year(@PayrollStartDate) AND Month1 = month(@PayrollStartDate)
			--		)

			--PRINT @k
			--PRINT 'Employer AW for payroll month extracting from table'

			--DECLARE @l MONEY = (
			--		SELECT isnull((EmprAW), 0)
			--		FROM #EMPPF_Tb1
			--		WHERE EmployeeId = @employeeId AND year1 = year(@PayrollStartDate) AND Month1 = month(@PayrollStartDate)
			--		)

			--PRINT @l

			SET @EmployeeAWCalcCPF =( (
					SELECT isnull((EmpOW), 0)
					FROM #EMPPF_Tb1
					WHERE EmployeeId = @employeeId AND year1 = year(@PayrollStartDate) AND Month1 = month(@PayrollStartDate)
					) + (
					SELECT isnull((EmpAW), 0)
					FROM #EMPPF_Tb1
					WHERE EmployeeId = @employeeId AND year1 = year(@PayrollStartDate) AND Month1 = month(@PayrollStartDate)
					))
			SET @EmployerAWCalcCPF =( (
					SELECT isnull((EmprOW), 0)
					FROM #EMPPF_Tb1
					WHERE EmployeeId = @employeeId AND year1 = year(@PayrollStartDate) AND Month1 = month(@PayrollStartDate)
					) + (
					SELECT isnull((EmprAW), 0)
					FROM #EMPPF_Tb1
					WHERE EmployeeId = @employeeId AND year1 = year(@PayrollStartDate) AND Month1 = month(@PayrollStartDate)
					))
					--print @EmployeeAWCalcCPF
					--print @EmployerAWCalcCPF
					--print @DeductEmpCPF
					--print @DeductEmprCPF
			SET @EmployeeAWCalcCPF = @EmployeeAWCalcCPF - isnull(@DeductEmpCPF,0)
			SET @EmployerAWCalcCPF = @EmployerAWCalcCPF - isnull(@DeductEmprCPF,0)
			--print '@EmployeeAWCalcCPF'
			--print @EmployeeAWCalcCPF
			--print '@EmployerAWCalcCPF'
			--print @EmployerAWCalcCPF

			UPDATE [HR].[PayrollDetails]
			SET EmployeeCPF = @EmployeeAWCalcCPF, EmployerCPF = @EmployerAWCalcCPF
			WHERE Id = @PayrollDetailId
			delete  HR.PayrollSplit where PayrollDetailId=@PayrollDetailId and PayComponentId=@EMPCPFPayComponentId
			delete  HR.PayrollSplit where PayrollDetailId=@PayrollDetailId and PayComponentId=@EMPRCPFPayComponentId

			insert into HR.PayrollSplit (Id,PayrollDetailId,PayComponentId,PayType,Amount,Recorder,IsTemporary) select NEWID(),@PayrollDetailId,@EMPCPFPayComponentId,@PayTypeEMPCPF,@EmployeeAWCalcCPF,1,1
			insert into HR.PayrollSplit (Id,PayrollDetailId,PayComponentId,PayType,Amount,Recorder,IsTemporary) select NEWID(),@PayrollDetailId,@EMPRCPFPayComponentId,@PayTypeEMPRCPF,@EmployerAWCalcCPF,1,1

			SET @ReCount1 = @ReCount1 + 1

			TRUNCATE TABLE #PayrollDetail

			TRUNCATE TABLE #EMPPF_Tb1
		END --mm

		IF OBJECT_ID(N'tempdb..#EMPPF_Tb1') IS NOT NULL
		BEGIN
			DROP TABLE #EMPPF_Tb1
		END

		IF OBJECT_ID(N'tempdb..#PayrollDetail') IS NOT NULL
		BEGIN
			DROP TABLE #PayrollDetail
		END

		IF OBJECT_ID(N'tempdb..#EmployeeData') IS NOT NULL
		BEGIN
			DROP TABLE #EmployeeData
		END

		COMMIT TRANSACTION --3
	END TRY --2

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END --1
GO
