USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Payroll_Basic_Pay_Calculation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[HR_Payroll_Basic_Pay_Calculation]
@payrollId UNIQUEIDENTIFIER,@PayrollStartDate DATETIME2,@PayrollEndDate DATETIME2,@CompanyId BIGINT
AS
BEGIN
--Local Variables
--Declare @tempTable table(EmpNo Uniqueidentifier,Oneday money,BasicPay money)
DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @Count INT =1
DECLARE @RecCount INT
DECLARE @Count1 INT =1
DECLARE @RecCount1 INT
DECLARE @EmployeeId UNIQUEIDENTIFIER
DECLARE @empDeptId UNIQUEIDENTIFIER
DECLARE @EmployementEndDate DATETIME2
DECLARE @IsExceedEmploymentEndDate BIT
--DECLARE @CompanyId BIGINT
DECLARE @totalDays DECIMAL(18,2) = 0
DECLARE @periodStartDate DATETIME2
DECLARE @periodEndDate DATETIME2
DECLARE @workingdays DECIMAL(18,2)
DECLARE @month NVARCHAR(100)
DECLARE @totalBasicPay DECIMAL(28,10) = 0
DECLARE @basicPayComponentId UNIQUEIDENTIFIER
DECLARE @basicPay DECIMAL(28,10)
DECLARE @payComponentType VARCHAR(250)
DECLARE @oneDayPay MONEY =0
DECLARE @PayrollDetailId UNIQUEIDENTIFIER
DECLARE @EffectiveFrom DATETIME2
DECLARE @EffectiveTo DATETIME2
DECLARE @WorkProfileId UNIQUEIDENTIFIER
DECLARE @OldEffectiveFrom DATETIME2
DECLARE @SPRGranted DATETIME2
DECLARE @DiffDays DECIMAL(18,2)
DECLARE @SPRBasicPay DECIMAL(28,10)
DECLARE @leavepay DECIMAL(28,10)
DECLARE @EnacshmentonedayPay DECIMAL(28,10)
CREATE TABLE #TempEmpDeptDtl (S_No INT identity(1, 1), EmpDeptId UNIQUEIDENTIFIER)
CREATE TABLE #TempEmployeeDepartment (Id UNIQUEIDENTIFIER, EmployeeId UNIQUEIDENTIFIER, DepartmentId UNIQUEIDENTIFIER, DepartmentDesignationId UNIQUEIDENTIFIER, Comments VARCHAR(100), EffectiveFrom DATETIME2, BasicPay DECIMAL(18,2), EndDate DATETIME2, [Level] VARCHAR(50), EffectiveTo DATETIME2, CompanyId BIGINT, IsPayrollRun BIT)
CREATE TABLE #tempPayrollTable(S_No INT IDENTITY(1,1),EmployeeId UNIQUEIDENTIFIER, PayrollDetailId UNIQUEIDENTIFIER)
--DECLARE @TempWorkProfile TABLE (Id UNIQUEIDENTIFIER, CompanyId BIGINT, WorkProfileName VARCHAR(50), WorkingHoursPerDay DECIMAL, Monday VARCHAR(100), Tuesday VARCHAR(100), Wednenday VARCHAR(100), Thursday VARCHAR(100), Friday VARCHAR(100), Saturday VARCHAR(100), Sunday VARCHAR(100), TotalWorkingDaysPerWeek DECIMAL, TotalWorkingHoursPerWeek DECIMAL, IsSuperUserRec BIT, Remarks VARCHAR(100), RecOrder INT, [Status] BIT, [Version] INT, IsDefaultProfile BIT)
	CREATE TABLE #TempWorkProfileDetail (Id UNIQUEIDENTIFIER, MasterId UNIQUEIDENTIFIER, [Year] INT, JanuaryDays DECIMAL(18,2), FebruaryDays DECIMAL(18,2), MarchDays DECIMAL(18,2), AprilDays DECIMAL(18,2), MayDays DECIMAL(18,2), JuneDays DECIMAL(18,2), JulyDays DECIMAL(18,2), AugustDays DECIMAL(18,2), SeptemberDays DECIMAL(18,2), OctoberDays DECIMAL(18,2), NovemberDays DECIMAL(18,2), DecemberDays DECIMAL(18,2), TotalWorkingHoursPerYear DECIMAL(18,2), TotalWorkingDaysPerYear DECIMAL(18,2), IsDefaultProfile BIT, Remarks VARCHAR(100), [Status] BIT,EmployeeId UNIQUEIDENTIFIER)
	BEGIN TRY
	BEGIN TRANSACTION
		--SET @CompanyId = (Select ParentId From Common.Company Where Id = (SELECT Distinct CompanyId FROM HR.Payroll WHERE ID = @payrollId))
		SELECT @basicPayComponentId= Id,@payComponentType=[TYPE] FROM HR.PayComponent (NOLOCK) WHERE CompanyId = @CompanyId AND NAME = 'Basic Pay'
		SET @month = (SELECT Distinct Month FROM HR.Payroll (NOLOCK) WHERE ID = @payrollId)
		--declare @tmp varchar(MAX)
		INSERT INTO #TempEmployeeDepartment
			EXEC HR_Payroll_Get_Department_BasicPay @payrollId,@PayrollStartDate,@PayrollEndDate

		IF((SELECT COUNT(ID) FROM #TempEmployeeDepartment) > 0) 
		BEGIN--001
			INSERT INTO #tempPayrollTable
				SELECT EmployeeId,Id FROM HR.PayrollDetails (NOLOCK) WHERE MasterId = @payrollId
			
			SET @RecCount = (SELECT COUNT(EmployeeId) FROM #tempPayrollTable)
			WHILE(@RecCount >= @Count)
			BEGIN--060
				SET @totalBasicPay =0
				SET @EmployeeId = (SELECT EmployeeId FROM #tempPayrollTable WHERE S_No = @Count)
				
				SET @OldEffectiveFrom = (SELECT TOP(1)EffectiveFrom FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId ORDER BY EffectiveFrom ASC)
				
				SET @SPRGranted = (SELECT SPRGranted FROM HR.PayrollDetails (NOLOCK) WHERE EmployeeId = @EmployeeId AND MasterId = @payrollId)
				IF(@PayrollStartDate >= @OldEffectiveFrom)
				BEGIN
					SET @OldEffectiveFrom = @PayrollStartDate
				END
				--ELSE IF(@PayrollStartDate <= @OldEffectiveFrom) 
				--BEGIN
				--	SET @OldEffectiveFrom = @OldEffectiveFrom
				--END
				SELECT @PayrollDetailId = Id,@WorkProfileId = WorkProfileId FROM HR.PayrollDetails (NOLOCK) WHERE MasterId = @payrollId AND EmployeeId = @EmployeeId
				IF ((SELECT Count(Id) FROM HR.EmployeePayrollSetting (NOLOCK) WHERE EmployeeId = @EmployeeId)>0) --002
				BEGIN--059
					--INSERT INTO @TempWorkProfile
					--	SELECT Id, CompanyId, WorkProfileName, WorkingHoursPerDay, Monday, Tuesday, Wednenday, Thursday, Friday, Saturday, Sunday, TotalWorkingDaysPerWeek, TotalWorkingHoursPerWeek, IsSuperUserRec, Remarks, RecOrder, [Status], [Version], IsDefaultProfile
					--	FROM HR.WorkProfile WHERE Id IN (SELECT WorkProfileId FROM HR.EmployeePayrollSetting WHERE EmployeeId = @EmployeeId )

					INSERT INTO #TempWorkProfileDetail
						SELECT Id, MasterId, [Year], JanuaryDays, FebruaryDays, MarchDays, AprilDays, MayDays, JuneDays, JulyDays, AugustDays, SeptemberDays, OctoberDays, NovemberDays, DecemberDays, TotalWorkingHoursPerYear, TotalWorkingDaysPerYear, IsDefaultProfile, Remarks, [Status],@EmployeeId
						FROM HR.WorkProfileDetails (NOLOCK) WHERE masterId = (SELECT WorkProfileId FROM HR.PayrollDetails (NOLOCK) WHERE MasterId = @payrollId AND EmployeeId = @EmployeeId ) AND [Year] = (SELECT YEAR(@payrollStartDate))
					IF ((SELECT COUNT(Id) FROM #TempWorkProfileDetail WHERE EmployeeId =@EmployeeId)>0)
						BEGIN--058
						
						SET @EmployementEndDate = (SELECT EmploymentEndDate FROM hr.PayrollDetails (NOLOCK) WHERE MasterId = @payrollId AND EmployeeId = @EmployeeId)
						--Select * From #TempEmployeeDepartment Where EmployeeId = @EmployeeId
							IF (((SELECT COUNT(Id) FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId) > 1) OR ((SELECT COUNT(Id)FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId AND EffectiveTo IS NOT NULL) > 0) OR ((SELECT COUNT(Id)FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId AND (CONVERT(DATE, EffectiveFrom) > CONVERT(DATE, @PayrollStartDate))) > 0))
							BEGIN--015
							--Print 1
								INSERT INTO #TempEmpDeptDtl
								SELECT Id
								FROM #TempEmployeeDepartment Where EmployeeId = @EmployeeId
								SET @RecCount1 = (SELECT COUNT(*) FROM #TempEmpDeptDtl)
								WHILE(@RecCount1 >=@Count1)
								BEGIN--016
									SET @empDeptId = (SELECT EmpDeptId FROM #TempEmpDeptDtl WHERE S_No = @Count1)
									IF(@EmployementEndDate IS NOT NULL)
									BEGIN
									IF(@PayrollStartDate>@EmployementEndDate)
									BEGIN
										SET @IsExceedEmploymentEndDate = 1
									END
									ELSE
										SET @IsExceedEmploymentEndDate = 0
									END
									ELSE
									BEGIN
										SET @IsExceedEmploymentEndDate = 0
									END
									

									IF (@EmployementEndDate IS NOT NULL)
									BEGIN--014
										IF (@payrollStartDate > @EmployementEndDate)
										BEGIN--057
											SET @IsExceedEmploymentEndDate = 1
										END--057
										ELSE
											SET @IsExceedEmploymentEndDate = 0
									END--014

									IF (@EmployementEndDate IS NOT NULL AND @IsExceedEmploymentEndDate = 0)
									BEGIN--013
										IF ((CONVERT(DATE, @payrollStartDate) <= CONVERT(DATE, @EmployementEndDate)) AND (CONVERT(DATE, @payrollEnddate) >= CONVERT(DATE, @EmployementEndDate)))
										BEGIN--012
											IF (@EmployementEndDate IS NOT NULL)
											BEGIN--056
												SET @payrollEnddate = @EmployementEndDate
											END--056
											ELSE
											BEGIN--055
												SET @payrollEnddate = @payrollEnddate
											END--055
										END--012
									END--013
									IF ((SELECT EffectiveTo FROM #TempEmployeeDepartment WHERE Id = @empDeptId AND EmployeeId = @EmployeeId ) IS NULL)
									BEGIN--054
										UPDATE #TempEmployeeDepartment
										SET EffectiveTo = @payrollEnddate
										WHERE Id = @empDeptId
									END--054

									IF EXISTS (SELECT ID FROM #TempWorkProfileDetail WHERE EmployeeId = @EmployeeId)
									BEGIN--011
										SET @EffectiveFrom = (SELECT EffectiveFrom FROM #TempEmployeeDepartment WHERE Id = @empDeptId)
										SET @EffectiveTo = (SELECT EffectiveTo FROM #TempEmployeeDepartment WHERE Id = @empDeptId )
										
										IF (@IsExceedEmploymentEndDate = 0)
										BEGIN--053	
										
											IF (((@payrollStartDate >= @EffectiveFrom) AND (@payrollStartDate <= @EffectiveTo)) AND (@payrollEnddate > = @EffectiveFrom AND @payrollEnddate <= @EffectiveTo))
											BEGIN--052
												SET @totalDays = (SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@payrollStartDate,@payrollEnddate,@WorkProfileId))
												
											END--052

											ELSE IF ((@payrollStartDate <= @EffectiveFrom) AND (@payrollEnddate <= @EffectiveTo))
										BEGIN--051
											SET @periodStartDate = (SELECT EffectiveFrom FROM #TempEmployeeDepartment WHERE Id = @empDeptId)
											SET @totalDays = (SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@periodStartDate,@payrollEnddate,@WorkProfileId))
										END--051

										ELSE IF ((@payrollStartDate <= @EffectiveFrom) AND (@payrollEnddate >= @EffectiveTo))
											BEGIN--050
												SET @periodStartDate = (SELECT EffectiveFrom FROM #TempEmployeeDepartment WHERE Id = @empDeptId)
												SET @periodEndDate = (SELECT EffectiveTo FROM #TempEmployeeDepartment WHERE Id = @empDeptId)
												SET @totalDays = (SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@periodStartDate,@periodEndDate,@WorkProfileId))
											END--050

										ELSE IF (@payrollStartDate > = @EffectiveFrom AND @payrollEnddate >= @EffectiveTo)
											BEGIN--049
												SET @periodEndDate = (SELECT EffectiveTo FROM #TempEmployeeDepartment WHERE Id = @empDeptId)
												SET @totalDays = (SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@payrollStartDate,@periodEndDate,@WorkProfileId))
											END--049

										ELSE IF (@payrollStartDate >= @EffectiveFrom AND @payrollEnddate <= @EffectiveTo)
											BEGIN--048
												SET @totalDays = (SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@payrollStartDate,@payrollEnddate,@WorkProfileId))
											END--048
										END--053

										IF ((SELECT basicPay FROM #TempEmployeeDepartment WHERE Id = @empDeptId AND EmployeeId = @EmployeeId) IS NOT NULL)
										BEGIN--047
											SET @workingdays = (SELECT dbo.HR_GetWorkingDays_Payroll(@month,@EmployeeId,@payrollStartDate,@WorkProfileId))
											
										IF (@workingdays <> 0)
										BEGIN--046
											SET @basicPay = ((SELECT BasicPay FROM #TempEmployeeDepartment Where Id = @empDeptId AND EmployeeId = @EmployeeId) / @workingdays)
											SET @oneDayPay = @oneDayPay+@basicPay
											SET @totalBasicPay = @totalBasicPay + (@basicPay * @totalDays)

											set @SPRGranted= (case when @SPRGranted <=@EffectiveFrom then @EffectiveFrom else @SPRGranted end)
											set @DiffDays=(SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@SPRGranted,@PayrollEndDate,@WorkProfileId))
											--set @SPRBasicPay=convert(decimal(28,10), (CONVERT(float, @oneDayPay)*@DiffDays))
											set @SPRBasicPay=(@oneDayPay*@DiffDays)
											--SELECT @SPRBasicPay
											--Select ROUND(@totalBasicPay,2) as total,(SELECT BasicPay FROM #TempEmployeeDepartment Where Id = @empDeptId) as basicP,@totalDays as TDays,@workingdays as WorkD,@empDeptId,@EmployeeId
											Select @totalBasicPay,@workingdays,@SPRBasicPay,@SPRGranted
											UPDATE HR.PayrollDetails SET OneDaySalary = ROUND(@oneDayPay,2,1),BasicPay = ROUND(@totalBasicPay,2,1),EffectiveFrom = @OldEffectiveFrom,SPRBasicPay =ROUND(@SPRBasicPay,2,1),EncashmentOneDaySalary=(((ROUND(@basicPay,2,1))*12)/260 )  WHERE MasterId = @payrollId AND EmployeeId = @EmployeeId
										END--046
										ELSE
										BEGIN--045
											SET @totalBasicPay = 0
										END--045
										END--047

									END--011

									SET @Count1 = @Count1+1
								END--016
							END--015

					IF (((SELECT COUNT(*) FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId) = 1) AND (SELECT COUNT(*) FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId AND EffectiveTo IS NULL) = 1)
					BEGIN--010
						IF ((SELECT BasicPay FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId) IS NOT NULL)
						BEGIN--044
							SET  @workingdays = (SELECT dbo.HR_GetWorkingDays_Payroll(@month,@EmployeeId,@payrollStartDate,@WorkProfileId))
							SET @totalDays = (SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@payrollStartDate,@payrollEnddate,@WorkProfileId))
							IF (@workingdays <> 0)
							BEGIN--043
								SET @basicPay = ((SELECT BasicPay FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId) / @workingdays)
								SET @oneDayPay = @basicPay
								SET @totalBasicPay = (@totalBasicPay + (@basicPay * @workingdays))
								--select @totalBasicPay,@oneDayPay
								
								set @SPRGranted= (case when @SPRGranted <=@EffectiveFrom then @EffectiveFrom else @SPRGranted end)
											set @DiffDays=(SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@SPRGranted,@PayrollEndDate,@WorkProfileId))
											--set @SPRBasicPay=convert(decimal(28,10), (CONVERT(float, @oneDayPay)*@DiffDays))
											set @SPRBasicPay=(@oneDayPay*@DiffDays)

								UPDATE HR.PayrollDetails SET OneDaySalary = ROUND(@oneDayPay,2,1),BasicPay = ROUND(@totalBasicPay,2,1),EffectiveFrom = @OldEffectiveFrom,SPRBasicPay =ROUND(@SPRBasicPay,2,1),EncashmentOneDaySalary=(((ROUND(@basicPay,2,1))*12)/260 )  WHERE MasterId = @payrollId AND EmployeeId = @EmployeeId
							END--043
							ELSE
							BEGIN--042
								SET @totalBasicPay = 0
							END--042
						END--044
					END--010

					IF((SELECT COUNT(*) FROM #TempEmployeeDepartment)>0)
					BEGIN
						IF(@EmployementEndDate IS NOT NULL)
						BEGIN
							SET @leavepay = (SELECT TOP 1 BasicPay FROM #TempEmployeeDepartment ORDER BY EffectiveFrom DESC)
						END
						ELSE
						BEGIN
							SET @leavepay = @totalBasicPay
						END
					END
					ELSE
					BEGIN
						SET @leavepay = 0
					END

					IF(@leavePay IS NOT NULL)
					BEGIN
						SET @EnacshmentonedayPay = (((ROUND(@leavepay,2,1))*12)/260 )
					UPDATE HR.PayrollDetails SET EncashmentOneDaySalary= @EnacshmentonedayPay WHERE MasterId = @payrollId AND EmployeeId = @EmployeeId
					END
					ELSE
					BEGIN
						SET @EnacshmentonedayPay = 0
						UPDATE HR.PayrollDetails SET EncashmentOneDaySalary= @EnacshmentonedayPay WHERE MasterId = @payrollId AND EmployeeId = @EmployeeId
					END


					IF EXISTS (SELECT Id FROM HR.PayComponentDetail (NOLOCK) WHERE EmployeeId = @EmployeeId AND MasterId = @basicPayComponentId)
							BEGIN--041
							--Select @totalBasicPay as b,@PayrollDetailId
								INSERT INTO HR.PayrollSplit (Id, PayrollDetailId, PayComponentId, PayType, Amount)
									SELECT NEWID(), @PayrollDetailId, @basicPayComponentId, @payComponentType, ROUND(@totalBasicPay,2,1)
							END--041

					END--058
					ELSE
						BEGIN--040
							UPDATE HR.PayrollDetails
							SET PaySlipRemarks = 'Workprofile is not Available for this Year'
							WHERE Id = (SELECT ID FROM HR.PayrollDetails (NOLOCK) WHERE EmployeeId = @employeeId AND MasterId = @payrollId)
						END--040

				END--059

				ELSE
				BEGIN--009
					IF NOT EXISTS (SELECT WorkProfileId FROM hr.PayrollDetails (NOLOCK) WHERE EmployeeId = @EmployeeId AND MasterId = @payrollId)
					BEGIN--039
						RAISERROR ('Default workprofile is not set for your company.', 16, 1)
					END--039
					ELSE
					BEGIN--008
					
						INSERT INTO #TempWorkProfileDetail
							SELECT Id, MasterId, [Year], JanuaryDays, FebruaryDays, MarchDays, AprilDays, MayDays, JuneDays, JulyDays, AugustDays, SeptemberDays, OctoberDays, NovemberDays, DecemberDays, TotalWorkingHoursPerYear, TotalWorkingDaysPerYear, IsDefaultProfile, Remarks, [Status],@EmployeeId
							FROM HR.WorkProfileDetails (NOLOCK)
							WHERE masterId = (SELECT WorkProfileId FROM hr.PayrollDetails (NOLOCK) WHERE EmployeeId = @EmployeeId) AND [Year] = (SELECT YEAR(@payrollStartDate))

						IF NOT EXISTS (SELECT ID FROM #TempWorkProfileDetail WHERE EmployeeId =@EmployeeId)
						BEGIN --007
							IF ((SELECT COUNT(Id) FROM #TempEmployeeDepartment WHERE EmployeeId =@EmployeeId ) > 1 OR ( SELECT COUNT(Id) FROM #TempEmployeeDepartment WHERE EmployeeId =@EmployeeId AND EffectiveTo != NULL) > 0 OR (SELECT COUNT(Id) FROM #TempEmployeeDepartment WHERE EmployeeId =@EmployeeId AND CONVERT(DATE, EffectiveFrom) > CONVERT(DATE, @payrollEnddate)) > 0)
							BEGIN --006
								INSERT INTO #TempEmpDeptDtl
									SELECT Id FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId
								SET @Count1 = 1
								SET @RecCount1 = (SELECT COUNT(*) FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId)
								WHILE   @RecCount1 >= @Count1
								BEGIN--038
									SET @empDeptId = (SELECT EmpDeptId FROM #TempEmpDeptDtl WHERE S_No = @Count1)
									IF(@EmployementEndDate IS NOT NULL)
									BEGIN
									IF(@PayrollStartDate>@EmployementEndDate)
									BEGIN
										SET @IsExceedEmploymentEndDate = 1
									END
									ELSE
										SET @IsExceedEmploymentEndDate = 0
									END
									ELSE
									BEGIN
										SET @IsExceedEmploymentEndDate = 0
									END
									IF (@EmployementEndDate IS NOT NULL) 
									BEGIN--005
											IF (@payrollStartDate > @EmployementEndDate)
											BEGIN--037
												SET @IsExceedEmploymentEndDate = 1
											END--037
											ELSE
											BEGIN--036
												SET @IsExceedEmploymentEndDate = 0
											END--036
									END --005

									IF (@EmployementEndDate IS NOT NULL AND @IsExceedEmploymentEndDate = 0)
										BEGIN --004
										IF ((CONVERT(DATE, @payrollStartDate) <= CONVERT(DATE, @EmployementEndDate)) AND (CONVERT(DATE, @payrollEnddate) >= CONVERT(DATE, @EmployementEndDate)))
										BEGIN--035
											IF (@EmployementEndDate IS NOT NULL)
											BEGIN--034
												SET @payrollEnddate = @EmployementEndDate
											END--034
											ELSE
											BEGIN--033
												SET @payrollEnddate = @payrollEnddate
											END--033
										END--035
									END--004

									IF ((SELECT EffectiveTo FROM #TempEmployeeDepartment WHERE Id = @empDeptId AND EmployeeId =@EmployeeId) IS NULL)
										BEGIN--032
											UPDATE #TempEmployeeDepartment SET EffectiveTo = @payrollEnddate WHERE Id = @empDeptId AND EmployeeId = @EmployeeId
										END--032

									IF EXISTS (SELECT ID FROM #TempWorkProfileDetail WHERE EmployeeId = @EmployeeId)
										BEGIN --003
											IF (@IsExceedEmploymentEndDate = 0)
											BEGIN--031
												SET @EffectiveFrom = (SELECT EffectiveFrom FROM #TempEmployeeDepartment WHERE Id = @empDeptId AND EmployeeId =@EmployeeId)
												SET @EffectiveTo = (SELECT EffectiveTo FROM #TempEmployeeDepartment WHERE Id = @empDeptId AND EmployeeId = @EmployeeId)

												IF (((@payrollStartDate >= @EffectiveFrom) AND (@payrollStartDate <= @EffectiveTo)) AND (@payrollEnddate > = @EffectiveFrom AND @payrollEnddate <= @EffectiveTo))
												BEGIN--030
													SET @totalDays = (SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@payrollStartDate,@payrollEnddate,@WorkProfileId))
												END--030
												ELSE IF ((@payrollStartDate <= @EffectiveFrom) AND (@payrollEnddate <= @EffectiveTo))
												BEGIN--029
													SET @periodStartDate = @EffectiveFrom
													SET @totalDays = (SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@periodStartDate,@payrollEnddate,@WorkProfileId))
												END--029
												ELSE IF (@PayrollStartDate <= @EffectiveFrom AND @PayrollEndDate >= @EffectiveTo)
												BEGIN--028
													SET @periodStartDate = @EffectiveFrom
													SET @periodEndDate = @EffectiveTo
													SET @totalDays = (SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@periodStartDate,@periodEndDate,@WorkProfileId))
												END--028
												ELSE IF (@payrollStartDate > = @EffectiveFrom AND @payrollEnddate >= @EffectiveTo)
												BEGIN--027
													SET @periodEndDate = @EffectiveTo
													SET @totalDays = (SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@payrollStartDate,@periodEndDate,@WorkProfileId))
												END--027

												ELSE IF (@payrollStartDate >= @EffectiveFrom AND @payrollEnddate <= @EffectiveTo)
												BEGIN--026
													SET @totalDays = (SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@payrollStartDate,@payrollEnddate,@WorkProfileId))
												END--026
												IF ((SELECT basicPay FROM #TempEmployeeDepartment WHERE Id = @empDeptId AND EmployeeId = @EmployeeId) IS NOT NULL)
												BEGIN--025
													SET @workingdays = (SELECT dbo.HR_GetWorkingDays_Payroll(@month,@EmployeeId,@payrollStartDate,@WorkProfileId))
													IF (@workingdays <> 0)
													BEGIN--024
														SET @basicPay = ((SELECT BasicPay FROM #TempEmployeeDepartment WHERE Id = @empDeptId AND EmployeeId = @EmployeeId) / @workingdays)
														SET @oneDayPay = @oneDayPay+@basicPay
														SET @totalBasicPay = @totalBasicPay + (@basicPay * @totalDays)
														
														UPDATE HR.PayrollDetails SET OneDaySalary = ROUND(@oneDayPay,2,1),BasicPay = ROUND(@totalBasicPay,2,1),EffectiveFrom = @OldEffectiveFrom,SPRBasicPay =ROUND(@SPRBasicPay,2,1),EncashmentOneDaySalary=(((ROUND(@basicPay,2,1))*12)/260 )  WHERE MasterId = @payrollId AND EmployeeId = @EmployeeId
													END--024
													ELSE
													BEGIN--023
														SET @totalBasicPay = 0
													END--023
												END--025
											END--031
										END --003
									SET @Count1 = @Count1+1
								END--038
								
							END --006

							IF (((SELECT COUNT(*) FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId) = 1) AND (SELECT COUNT(*)FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId AND EffectiveTo IS NULL) = 1)
							BEGIN --002
								IF ((SELECT BasicPay FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId) IS NOT NULL)
								BEGIN--022
									SET @workingdays = (SELECT dbo.HR_GetWorkingDays_Payroll(@month,@EmployeeId,@payrollStartDate,@WorkProfileId))
									SET @totalDays = (SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@payrollStartDate,@payrollEnddate,@WorkProfileId))
									IF (@workingdays <> 0)
									BEGIN--020
										SET @basicPay = ((SELECT BasicPay FROM #TempEmployeeDepartment WHERE EmployeeId = @EmployeeId) / @workingdays)
										SET @oneDayPay = @basicPay
										SET @totalBasicPay = @totalBasicPay + (@basicPay * @totalDays)
										

										UPDATE HR.PayrollDetails SET OneDaySalary = ROUND(@oneDayPay,2,1),BasicPay = ROUND(@totalBasicPay,2,1),EffectiveFrom = @OldEffectiveFrom,SPRBasicPay =ROUND(@SPRBasicPay,2,1),EncashmentOneDaySalary=(((ROUND(@basicPay,2,1))*12)/260 )  WHERE MasterId = @payrollId AND EmployeeId = @EmployeeId
									END--020
									ELSE
									BEGIN--021
										SET @totalBasicPay = 0
									END--021
								END--022
							END--002

												IF((SELECT COUNT(*) FROM #TempEmployeeDepartment)>0)
					BEGIN
						IF(@EmployementEndDate IS NOT NULL)
						BEGIN
							SET @leavepay = (SELECT TOP 1 BasicPay FROM #TempEmployeeDepartment ORDER BY EffectiveFrom DESC)
						END
						ELSE
						BEGIN
							SET @leavepay = @totalBasicPay
						END
					END
					ELSE
					BEGIN
						SET @leavepay = 0
					END

					IF(@leavePay IS NOT NULL)
					BEGIN
						SET @EnacshmentonedayPay = (((ROUND(@leavepay,2,1))*12)/260 )
					UPDATE HR.PayrollDetails SET EncashmentOneDaySalary= @EnacshmentonedayPay WHERE MasterId = @payrollId AND EmployeeId = @EmployeeId
					END
					ELSE
					BEGIN
						SET @EnacshmentonedayPay = 0
						UPDATE HR.PayrollDetails SET EncashmentOneDaySalary= @EnacshmentonedayPay WHERE MasterId = @payrollId AND EmployeeId = @EmployeeId
					END

							IF EXISTS (SELECT Id FROM HR.PayComponentDetail (NOLOCK) WHERE EmployeeId = @EmployeeId AND MasterId = @basicPayComponentId)
							BEGIN--019
								INSERT INTO HR.PayrollSplit (Id, PayrollDetailId, PayComponentId, PayType, Amount)
									SELECT NEWID(), @PayrollDetailId, @basicPayComponentId, @payComponentType, ROUND(@totalBasicPay,2,1)
							END--019

						END --007
					END--008
				END--009
				SET @Count = @Count+1
			END--060
		END --001
		DROP TABLE #TempEmpDeptDtl
		DROP TABLE #TempEmployeeDepartment
		DROP TABLE #tempPayrollTable
		DROP TABLE #TempWorkProfileDetail
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
	END CATCH
END

GO
