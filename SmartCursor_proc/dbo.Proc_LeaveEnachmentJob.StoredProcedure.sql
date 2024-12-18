USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_LeaveEnachmentJob]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_LeaveEnachmentJob] (@LeaveEncashment LeaveEncashment readonly, @CompanyId BIGINT, @UserCreated NVARCHAR(100), @YearMonth NVARCHAR(30), @PayrollId UNIQUEIDENTIFIER,@PayrollStatus NVARCHAR(30))
AS
BEGIN --1
	BEGIN TRANSACTION --2

	DECLARE @HRSettingDeatilId UNIQUEIDENTIFIER
	DECLARE @LeaveTypeId UNIQUEIDENTIFIER
	DECLARE @Count INT
	DECLARE @Recount INT = 1
	DECLARE @Adjustment FLOAT --declare @Current float
	DECLARE @Prorated FLOAT
	DECLARE @BroughtForward FLOAT
	DECLARE @ApprovedAndTaken FLOAT
	DECLARE @ApprovedAndNotTaken FLOAT
	DECLARE @AnnualLeaveEntitlement FLOAT
	DECLARE @FutureProrated FLOAT
	DECLARE @LeaveEntitlementId UNIQUEIDENTIFIER
	DECLARE @Adjusted FLOAT
	DECLARE @Days FLOAT
	DECLARE @EmployeeId UNIQUEIDENTIFIER
	DECLARE @Comment NVARCHAR(50) = 'Deducted from ' + @YearMonth + ' Payroll as Leave Encashment'
	declare @NewAdjustmentValue float


	BEGIN TRY --3
		SELECT @HRSettingDeatilId = HRSD.Id
		FROM Common.HRSettings HRS (NOLOCK)
		JOIN Common.HRSettingdetails HRSD (NOLOCK) ON HRS.Id = HRSD.MasterId
		WHERE HRS.CompanyId = @CompanyId AND CONVERT(DATE, getdate()) BETWEEN CONVERT(DATE, HRSD.StartDate) AND CONVERT(DATE, HRSD.EndDate)


		print @HRSettingDeatilId

		SELECT @LeaveTypeId = Id
		FROM HR.LeaveType (NOLOCK)
		WHERE Name = 'Annual Leave' AND CompanyId = @CompanyId

		print @LeaveTypeId


		DECLARE @LeaveEntitlementTable TABLE (S_No INT Identity(1, 1), Id UNIQUEIDENTIFIER, Adjustment DECIMAL, Adjusted DECIMAL, Prorated FLOAT, BroughtForward FLOAT, ApprovedAndTaken FLOAT, ApprovedAndNotTaken FLOAT, AnnualLeaveEntitlement FLOAT, FutureProrated FLOAT, EmployeeId UNIQUEIDENTIFIER)

		INSERT INTO @LeaveEntitlementTable
		SELECT Id, convert(FLOAT, isnull(Adjustment, 0)), isnull(Adjusted,0), isnull(Prorated,0), isnull(BroughtForward,0), isnull(ApprovedAndTaken,0), isnull(ApprovedAndNotTaken,0), isnull(AnnualLeaveEntitlement,0), isnull(FutureProrated,0), EmployeeId
		FROM HR.LeaveEntitlement (NOLOCK)
		WHERE HrSettingDetaiId = @HRSettingDeatilId AND LeaveTypeId = @LeaveTypeId AND EmployeeId IN (
				SELECT EmployeeId
				FROM @LeaveEncashment
				)

		SET @Count = (
				SELECT COUNT(Id)
				FROM @LeaveEntitlementTable
				)
				print @Count
		WHILE @Count >= @Recount
		BEGIN --4
		print 'in while loop'
			SELECT @LeaveEntitlementId = Id, @Adjustment = Adjustment, @Prorated = Prorated, @BroughtForward = BroughtForward, @ApprovedAndTaken = ApprovedAndTaken, @ApprovedAndNotTaken = ApprovedAndNotTaken, @AnnualLeaveEntitlement = AnnualLeaveEntitlement, @FutureProrated = FutureProrated, @Adjusted = Adjusted, @EmployeeId = EmployeeId
			FROM @LeaveEntitlementTable
			WHERE S_No = @Recount

			SELECT @Days = (
					SELECT Days
					FROM @LeaveEncashment
					WHERE EmployeeId = @EmployeeId
					)

			SET @Adjustment = @Adjustment + (@Days*-1)

			print @Adjustment
			print (@Prorated )
			print @BroughtForward
			print @Adjustment
			print @Adjusted 
			UPDATE [HR].[LeaveEntitlement]
			SET [Current] = (@Prorated + @BroughtForward + @Adjustment), [LeaveBalance] = ((@Prorated + @BroughtForward + @Adjustment) - (@ApprovedAndNotTaken + @ApprovedAndTaken)), [Total] = (@AnnualLeaveEntitlement + @BroughtForward + @Adjustment), Adjusted = (@AnnualLeaveEntitlement + @Adjustment),Adjustment=@Adjustment,YTDLeaveBalance=((@FutureProrated+ @BroughtForward + @Adjustment)-(@ApprovedAndNotTaken + @ApprovedAndTaken))
			WHERE id = @LeaveEntitlementId

			INSERT INTO [HR].[LeaveEntitlementAdjustment] ([Id], [LeaveEntitlementId], [Adjustment], [Comment], [UserCreated], [CreatedDate], [IsSystem], PayrollId,PayrollStatus)
			VALUES (NEWID(), @LeaveEntitlementId, (@Days *-1), @Comment, @UserCreated, getdate(), 1, @PayrollId,@PayrollStatus)

			SET @Recount = @Recount + 1
		END --4

		COMMIT TRANSACTION --2
	END TRY --3

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = 16, @ErrorState = 1;		

		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH
END --1
GO
