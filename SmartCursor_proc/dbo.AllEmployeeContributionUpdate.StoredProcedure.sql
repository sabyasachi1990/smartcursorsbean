USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[AllEmployeeContributionUpdate]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AllEmployeeContributionUpdate] (@PayrollStartDate DATETIME2(7), @PayrollId UNIQUEIDENTIFIER, @SubCompanyId BIGINT)
AS
BEGIN
	BEGIN TRANSACTION --1

	BEGIN TRY --2
	--print 'Entered into '
		CREATE TABLE #EmployeeData (S_No INT Identity(1, 1), TempPayrollMasterId UNIQUEIDENTIFIER, Employeeid UNIQUEIDENTIFIER,  DetailId UNIQUEIDENTIFIER, IdType NVARCHAR(20), Contribution NVARCHAR(50), IsCPFContributionFull BIT, SPRGranted DATETIME2(7), SPRExpiry DATETIME2(7))

		INSERT INTO #EmployeeData
		SELECT MasterId, EmployeeId,Id,IdType,ContributionFor,IsCPFContributionFull,SPRGranted,SPRExpiry
		FROM [HR].[PayrollDetails] (NOLOCK)
		WHERE MasterId = @PayrollId and (CPFExampted is null or CPFExampted =0) and IdType ='NRIC(Blue)'		
		DECLARE @CompanyContribution NVARCHAR(50)
		DECLARE @CPFExampted BIT
		DECLARE @Contribution NVARCHAR(50)
		DECLARE @IdType NVARCHAR(20)
		DECLARE @SPRGranted DATETIME2(7)
		DECLARE @IsCPFContributionFull BIT
		declare @TotalCount int 
		declare @ReCount int=1
		declare @PayrollDetailId uniqueidentifier
		declare @EmployeeId uniqueidentifier 
		declare @EmployerContribution NVARCHAR(50)

		SELECT @CompanyContribution = EmployeeCPFContribution
		FROM hr.CompanyPayrollSettings (NOLOCK)
		WHERE CompanyId = @SubCompanyId AND STATUS = 1

		PRINT @CompanyContribution

		SET @TotalCount = (
				SELECT COUNT(S_No)
				FROM #EmployeeData
				)

		WHILE @TotalCount >= @ReCount
	begin --mm
	select @Contribution=Contribution,@PayrollDetailId=DetailId,@IsCPFContributionFull=IsCPFContributionFull,@IdType=IdType,@SPRGranted=SPRGranted,@EmployeeId=Employeeid    from  #EmployeeData where S_No=@ReCount 

		
			PRINT 'Entered into Employee loop'

			IF (@IdType = 'NRIC(Blue)')
			BEGIN --3 
				print 'blue'
				IF (@PayrollStartDate <= DATEADD(year, 1, @SPRGranted))
				BEGIN --4
				print '@PayrollStartDate <= DATEADD(year, 1, @SPRGranted)'
				print @IsCPFContributionFull
					IF (@IsCPFContributionFull IS NOT NULL)
					BEGIN --5
						print 'First year'
						IF (@IsCPFContributionFull = 1)
						BEGIN --6
							SET @Contribution = 'SPR 1st year-Full'
							set @EmployerContribution='SPR 1st year-' + @CompanyContribution
							print @Contribution
						END --6
						ELSE
						BEGIN --7
							SET @Contribution = 'SPR 1st year-Graduated'
							set @EmployerContribution='SPR 1st year-' + @CompanyContribution
							print @Contribution
						END --7
					END --5
					ELSE
					BEGIN --8
						SET @Contribution = ('SPR 1st year-' + @CompanyContribution)
						set @EmployerContribution='SPR 1st year-' + @CompanyContribution
						print @Contribution
					END --8
				END --4
				ELSE IF (@PayrollStartDate <= DATEADD(year, 2, @SPRGranted) AND @PayrollStartDate > DATEADD(year, 1, @SPRGranted))
				BEGIN --9
					--print 'second year'
					IF (@IsCPFContributionFull IS NOT NULL)
					BEGIN ---10-
						IF (@IsCPFContributionFull = 1)
						BEGIN --11-
							SET @Contribution = 'SPR 2nd year-Full'
							SET @EmployerContribution = ('SPR 2nd year-' + @CompanyContribution)
							print @Contribution
						END --11
						ELSE
						BEGIN --12
							SET @Contribution = 'SPR 2nd year-Graduated'
							SET @EmployerContribution = ('SPR 2nd year-' + @CompanyContribution)
							print @Contribution
						END --12	
					END --10
					ELSE
					BEGIN --13
						SET @Contribution = ('SPR 2nd year-' + @CompanyContribution)
						print @Contribution
					END --13
				END --9
				ELSE IF (@PayrollStartDate > DATEADD(year, 2, @SPRGranted))
				BEGIN --14
					SET @Contribution = 'Singaporean'
					print @Contribution
				END --14
				--else if 
				
			END ---3
			--ELSE IF (@IdType = 'NRIC(Pink)')
			--BEGIN --15
			--	SET @Contribution = 'Singaporean'
			--END --15
			update [HR].[PayrollDetails] set Contributionfor=@Contribution,CompanyContribution=@EmployerContribution where Id=@PayrollDetailId
			set @ReCount=@ReCount+1
	end--mm	
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
