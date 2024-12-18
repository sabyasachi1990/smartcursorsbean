USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_LeaveCarryForwardJob1]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 
--Exec [dbo].[Proc_LeaveCarryForwardJob1] 2058,1
 
 
CREATE  PROCEDURE [dbo].[Proc_LeaveCarryForwardJob1] @newcompanyId Bigint,@days Bigint

AS

BEGIN --s1	

	DECLARE @CompanyCount INT

	DECLARE @RecCount INT

	Declare @StartTime Datetime2(7)=(getdate())
 
 
	DECLARE @HrSettingtable TABLE (S_No INT Identity(1, 1), HRSettingid UNIQUEIDENTIFIER, CompanyId BIGINT, HRSettingDetailId UNIQUEIDENTIFIER, CarryforwardResetDate DATETIME, IsResetCompleted BIT)
		DECLARE @AllPreviousPeriodEmployeeEntitlement_Tbl TABLE (S_No INT Identity(1, 1), EmpId UNIQUEIDENTIFIER, LTypeId UNIQUEIDENTIFIER, LeaveBalance FLOAT)
  	CREATE TABLE #AllPresentPeriodEmp_Tbl (S_No INT Identity(1, 1), Id UNIQUEIDENTIFIER, EmployeeId UNIQUEIDENTIFIER, LeaveTypeId UNIQUEIDENTIFIER, Prorated FLOAT, AnnualLeaveEntitlement FLOAT, ApprovedAndTaken FLOAT, ApprovedAndNotTaken FLOAT, FutureProrated FLOAT, CarryForwardDays FLOAT)
 
	BEGIN TRANSACTION --s2
 	BEGIN TRY --s3
			INSERT INTO @HrSettingtable
				SELECT HRS.Id, HRS.CompanyId, HRSD.Id, HRSD.[CarryforwardResetDate], HRSD.[IsResetCompleted]
						FROM [Common].[HRSettings] HRS (NOLOCK)
								JOIN [Common].[HRSettingdetails] HRSD (NOLOCK) ON HRS.Id = HRSD.MasterId
										WHERE Convert(DATE, HRSD.[CarryforwardResetDate]) = dateadd(day, datediff(day, 1, GETDATE()), 0)
												and MasterId in (Select Id from Common.HRSettings where CompanyId=2058)


		INSERT INTO @AllPreviousPeriodEmployeeEntitlement_Tbl

		SELECT [EmployeeId], [LeaveTypeId], ISNULL([LeaveBalance], 0)

		FROM [HR].[LeaveEntitlement] (NOLOCK)

		WHERE [HrSettingDetaiId] IN (

				SELECT id

				FROM [Common].[HRSettingdetails] (NOLOCK)

				WHERE Convert(DATE, [CarryforwardResetDate]) = dateadd(day, datediff(day, 1, GETDATE()), 0)

				and MasterId in (Select Id from Common.HRSettings where CompanyId=2058)

				--and LeaveTypeId='bb788303-ac72-431c-a9cb-7e1867e40699' and EmployeeId='4f497651-9516-4e93-8947-9a284c17f833'

				)
 
 
				--Select * from HR.LeaveEntitlement where HRSettingDetaiId='E8B62A60-5141-4F3B-BC69-1979084E639F' and Bro
 
 
		PRINT 'all previous perios employees loaded'
 
 
		SET @CompanyCount = (

				SELECT Count(*)

				FROM @HrSettingtable

				)

		SET @RecCount = 1
 
 
		WHILE @CompanyCount >= @RecCount

		BEGIN --1

			DECLARE @CompanyId BIGINT

			DECLARE @HRSettingDetailId UNIQUEIDENTIFIER

			DECLARE @IsResetCompleted BIT

			DECLARE @HRSettingId UNIQUEIDENTIFIER
 
 
			SELECT @HRSettingDetailId = HRSettingDetailId, @CompanyId = CompanyId, @IsResetCompleted = IsResetCompleted, @HRSettingId = HRSettingid

			FROM @HrSettingtable

			WHERE S_No = @RecCount
 
 
			PRINT @HRSettingId

			PRINT @HRSettingDetailId
 
 
			--InsertLeaveEntitlements.BroughtForward = InsertLeaveEntitlements.BroughtForward == null ? 0 : InsertLeaveEntitlements.BroughtForward;

			--           //for leave balance grid we calculating here

			--           InsertLeaveEntitlements.Current = InsertLeaveEntitlements.Prorated + InsertLeaveEntitlements.BroughtForward;

			--           InsertLeaveEntitlements.LeaveBalance = InsertLeaveEntitlements.Current - (InsertLeaveEntitlements.ApprovedAndTaken + InsertLeaveEntitlements.ApprovedAndNotTaken);

			--           InsertLeaveEntitlements.Total = InsertLeaveEntitlements.AnnualLeaveEntitlement + InsertLeaveEntitlements.BroughtForward;

			--           InsertLeaveEntitlements.YTDLeaveBalance = InsertLeaveEntitlements.FutureProrated + InsertLeaveEntitlements.BroughtForward;


			--Select * from HR.LeaveEntitlement where HRSettingDetaiId='A8AE1372-A199-4597-83E1-3425EF56C2E8'
			INSERT INTO #AllPresentPeriodEmp_Tbl

			SELECT LT.Id, LT.EmployeeId, LT.LeaveTypeId, ISNULL(LT.Prorated, 0), ISNULL(LT.AnnualLeaveEntitlement, 0), ISNULL(LT.ApprovedAndTaken, 0), 

			ISNULL(LT.ApprovedAndNotTaken, 0), ISNULL(LT.FutureProrated, 0), ISNULL(LT.CarryForwardDays, 0)

			FROM [HR].[LeaveEntitlement] LT (NOLOCK)

			Join [HR].[LeaveType] L (NOLOCK) on LT.[LeaveTypeId]=L.ID

			WHERE (L.[ApplyToAll]='Selected' or L.[ApplyToAll]='All') and (l.IsMOM is null or l.IsMOM=0) and [HrSettingDetaiId] = (

					SELECT TOP 1 Id

					FROM [Common].[HRSettingdetails] (NOLOCK)

					WHERE masterid ='D08C408E-A910-48EB-86F4-588B654F44A1'

					and Year(StartDate)=2024

					ORDER BY recorder DESC

					)
 
 
			PRINT 'present period employees inserted'
 
 
			DECLARE @TotalEmployeeCount INT = (

					SELECT count(*)

					FROM #AllPresentPeriodEmp_Tbl

					)
 
 SELECT count(*)

					FROM #AllPresentPeriodEmp_Tbl
			PRINT @TotalEmployeeCount
 
 
			DECLARE @EmployeeCount INT = 1
 
 
			WHILE @TotalEmployeeCount >= @EmployeeCount

			BEGIN --2

				DECLARE @LeaveEntitlemntId UNIQUEIDENTIFIER

				DECLARE @NewEmployeeId UNIQUEIDENTIFIER

				DECLARE @LeaveTypeId_1 UNIQUEIDENTIFIER

				DECLARE @Prorated_1 FLOAT

				DECLARE @AnnualLeaveEntitlement_1 FLOAT

				DECLARE @ApprovedAndTaken_1 FLOAT

				DECLARE @ApprovedAndNotTaken_1 FLOAT

				DECLARE @FutureProrated_1 FLOAT

				DECLARE @CarryForwardDays_1 FLOAT

				DECLARE @BroughtForward FLOAT=0
 
 
				SELECT @LeaveEntitlemntId = Id, @NewEmployeeId = EmployeeId, @LeaveTypeId_1 = LeaveTypeId, @Prorated_1 = Prorated,

				@AnnualLeaveEntitlement_1 = AnnualLeaveEntitlement, @ApprovedAndTaken_1 = ApprovedAndTaken,

				@ApprovedAndNotTaken_1 = ApprovedAndNotTaken, @FutureProrated_1 = FutureProrated, @CarryForwardDays_1 = CarryForwardDays

				FROM #AllPresentPeriodEmp_Tbl

				WHERE S_No = @EmployeeCount
 
 
				

				IF EXISTS (

						SELECT S_No

						FROM @AllPreviousPeriodEmployeeEntitlement_Tbl

						WHERE LTypeId = @LeaveTypeId_1 AND EmpId = @NewEmployeeId

						)

				BEGIN --3

					IF (@CarryForwardDays_1 IS NOT NULL)


					BEGIN --x
					Print '1'

					--Select * 

					--			FROM @AllPreviousPeriodEmployeeEntitlement_Tbl

					--			WHERE LTypeId = @LeaveTypeId_1 AND EmpId = @NewEmployeeId

						DECLARE @PreviousYearLeaveBaance FLOAT = (

								SELECT ISnULL(LeaveBalance, 0)

								FROM @AllPreviousPeriodEmployeeEntitlement_Tbl

								WHERE LTypeId = @LeaveTypeId_1 AND EmpId = @NewEmployeeId

								)
 
 
								--Select @PreviousYearLeaveBaance

								--Select @BroughtForward

								--Select * from #AllPresentPeriodEmp_Tbl

						IF (@PreviousYearLeaveBaance IS NOT NULL AND @PreviousYearLeaveBaance != 0 AND @PreviousYearLeaveBaance >= @CarryForwardDays_1 and @PreviousYearLeaveBaance>0)

						BEGIN --4

						Select @CarryForwardDays_1

							SET @BroughtForward = @CarryForwardDays_1

						END --4
 
 
						IF (@PreviousYearLeaveBaance IS NOT NULL AND @PreviousYearLeaveBaance != 0 AND @PreviousYearLeaveBaance < @CarryForwardDays_1 and @PreviousYearLeaveBaance>0)

						BEGIN --5

						Select @CarryForwardDays_1

							SET @BroughtForward = @PreviousYearLeaveBaance

						END --5

						if(@BroughtForward is not null and @BroughtForward!=0 and @BroughtForward>0)

						begin--y

						--Print '1'

						--Select @LeaveEntitlemntId

						UPDATE [HR].[LeaveEntitlement]

						SET [BroughtForward] = @BroughtForward, [Current] = (@Prorated_1 + @BroughtForward), [LeaveBalance] = ((@Prorated_1 + @BroughtForward) - (@ApprovedAndTaken_1 + @ApprovedAndNotTaken_1)), [Total] = (@AnnualLeaveEntitlement_1 + @BroughtForward), [YTDLeaveBalance] = (@FutureProrated_1 + @BroughtForward)

						WHERE id = @LeaveEntitlemntId
 
 
						--if(@LeaveEntitlemntId='A444E252-7DB0-4429-85CF-805FFC38EEFA')

						--Begin

						--Select @BroughtForward

						--SELECT *

						--FROM @AllPreviousPeriodEmployeeEntitlement_Tbl

						--WHERE LTypeId = 'bbcfc8a5-b027-4ff2-b708-9aea5fc09f58' AND EmpId = 'dda2cd6e-0e3a-3ead-6ec7-748264e86c55'

						--End

						end--y

					END --x

				END --3
 
 
				SET @EmployeeCount = @EmployeeCount + 1

			END --2
 
 
			PRINT @HRSettingDetailId
 
 Print @EmployeeCount
			UPDATE [Common].[HRSettingdetails]

			SET [IsResetCompleted] = 1

			WHERE id = @HRSettingDetailId
 
 
			TRUNCATE TABLE #AllPresentPeriodEmp_Tbl
 
 
			SET @RecCount = @RecCount + 1

		END --1
 
 
		IF OBJECT_ID(N'tempdb..#AllPresentPeriodEmp_Tbl') IS NOT NULL

		BEGIN

			DROP TABLE #AllPresentPeriodEmp_Tbl

		END

		Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )

values (newid(),'HRCursor','Leave CarryForward job','Job','Leave CarryForward job',@StartTime,getdate(),null,null,'Completed')

		COMMIT TRANSACTION --s2

	END TRY --s3
 
 
	BEGIN CATCH

		ROLLBACK TRANSACTION
 
 
		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;
 
 
		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
 
 
		RAISERROR (@ErrorMessage, 16, 1);

	END CATCH

END

GO
