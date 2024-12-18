USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_RevertLeaveEnachmentJob]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Proc_RevertLeaveEnachmentJob] (@LeaveEncashment LeaveEncashment readonly, @CompanyId BIGINT, @PayrollId UNIQUEIDENTIFIER,@IsDelete bit,@PayrollStatus NVARCHAR(20))
AS
BEGIN --1
	BEGIN TRANSACTION --2
	BEGIN TRY --3
	if(@IsDelete=1 or @PayrollStatus='Cancelled')
	begin --5
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
	--DECLARE @Comment NVARCHAR(50) = 'Dedecuted from ' + @YearMonth + ' Payroll as Leave Encashment'
	declare @LeaveAdjustmentValue float


	
		SELECT @HRSettingDeatilId = HRSD.Id
		FROM Common.HRSettings HRS (NOLOCK)
		JOIN Common.HRSettingdetails HRSD (NOLOCK) ON HRS.Id = HRSD.MasterId
		WHERE HRS.CompanyId = @CompanyId AND CONVERT(DATE, getdate()) BETWEEN CONVERT(DATE, HRSD.StartDate) AND CONVERT(DATE, HRSD.EndDate)


		print @HRSettingDeatilId

		SELECT @LeaveTypeId = Id
		FROM HR.LeaveType (NOLOCK)
		WHERE Name = 'Annual Leave' AND CompanyId = @CompanyId

		print @LeaveTypeId


		DECLARE @LeaveEntitlementTable TABLE (S_No INT Identity(1, 1), Id UNIQUEIDENTIFIER, Adjustment float, Adjusted float, Prorated FLOAT, BroughtForward FLOAT, ApprovedAndTaken FLOAT, ApprovedAndNotTaken FLOAT, AnnualLeaveEntitlement FLOAT, FutureProrated FLOAT, EmployeeId UNIQUEIDENTIFIER,LeaveAdjustmentDays float null)
		if(@IsDelete=1)
		begin--6
		INSERT INTO @LeaveEntitlementTable
		SELECT Id, convert(FLOAT, isnull(Adjustment, 0)), isnull(Adjusted,0), isnull(Prorated,0), isnull(BroughtForward,0), isnull(ApprovedAndTaken,0), isnull(ApprovedAndNotTaken,0), isnull(AnnualLeaveEntitlement,0), isnull(FutureProrated,0), EmployeeId,0
		FROM HR.LeaveEntitlement (NOLOCK)
		WHERE HrSettingDetaiId = @HRSettingDeatilId AND LeaveTypeId = @LeaveTypeId AND EmployeeId IN (
				SELECT EmployeeId
				FROM @LeaveEncashment
				)
				end --6
      else
	  begin --7
	  INSERT INTO @LeaveEntitlementTable
	  select HLE.Id, convert(FLOAT, isnull(HLE.Adjustment, 0)), isnull(HLE.Adjusted,0), isnull(HLE.Prorated,0), isnull(HLE.BroughtForward,0), isnull(HLE.ApprovedAndTaken,0), isnull(HLE.ApprovedAndNotTaken,0), isnull(HLE.AnnualLeaveEntitlement,0), isnull(HLE.FutureProrated,0), HLE.EmployeeId,convert(FLOAT, isnull(HLEA.Adjustment, 0)) from [HR].[LeaveEntitlementAdjustment] HLEA (NOLOCK) join HR.LeaveEntitlement HLE (NOLOCK) on HLEA.LeaveEntitlementId =HLE.Id join HR.PayrollDetails PD (NOLOCK) on HLE.EmployeeId=PD.EmployeeId where HLEA.PayrollId=@PayrollId and PD.MasterId=@PayrollId and PD.EnacashmentDays is not null and PD.EnacashmentDays!=0

	  end--7


		SET @Count = (
				SELECT COUNT(Id)
				FROM @LeaveEntitlementTable
				)
				print @Count
		WHILE @Count >= @Recount
		BEGIN --4
		print 'in while loop'
			SELECT @LeaveEntitlementId = Id, @Adjustment = Adjustment, @Prorated = Prorated, @BroughtForward = BroughtForward, @ApprovedAndTaken = ApprovedAndTaken, @ApprovedAndNotTaken = ApprovedAndNotTaken, @AnnualLeaveEntitlement = AnnualLeaveEntitlement, @FutureProrated = FutureProrated, @Adjusted = Adjusted, @EmployeeId = EmployeeId,@LeaveAdjustmentValue=LeaveAdjustmentDays
			FROM @LeaveEntitlementTable
			WHERE S_No = @Recount

			SELECT @Days = (
					SELECT Days
					FROM @LeaveEncashment
					WHERE EmployeeId = @EmployeeId
					)

			SET @Adjustment = ( case when @IsDelete=1 then @Adjustment +( (@Days)) else @Adjustment+(-1*(@LeaveAdjustmentValue)) end)
			set @Adjusted=( case when @IsDelete=1 then @Adjusted +( (@Days)) else @Adjusted+(-1*(@LeaveAdjustmentValue)) end)

			print @Adjustment
			print (@Prorated )
			print @BroughtForward
			print @Adjustment
			print @Adjusted
			UPDATE [HR].[LeaveEntitlement]
			SET [Current] = (@Prorated + @BroughtForward + @Adjustment), [LeaveBalance] = ((@Prorated + @BroughtForward + @Adjustment) - (@ApprovedAndNotTaken + @ApprovedAndTaken)), [Total] = (@AnnualLeaveEntitlement + @BroughtForward + @Adjustment), Adjusted = @Adjusted,Adjustment=@Adjustment,YTDLeaveBalance=((@FutureProrated+ @BroughtForward + @Adjustment)-(@ApprovedAndNotTaken + @ApprovedAndTaken))
			WHERE id = @LeaveEntitlementId

			update hr.LeaveEntitlementAdjustment set IsDeleted=1 ,PayrollStatus= (case when @IsDelete=1 then 'PayComponentDeleted' else @PayrollStatus end) where LeaveEntitlementId=@LeaveEntitlementId and PayrollId=@PayrollId
			 
			 update Common.Employee set AnnualPTDBalance =((@Prorated + @BroughtForward + @Adjustment) - (@ApprovedAndNotTaken + @ApprovedAndTaken)),AnnualYTDBalance=((@FutureProrated+ @BroughtForward + @Adjustment)-(@ApprovedAndNotTaken + @ApprovedAndTaken)) where Id=@EmployeeId
			SET @Recount = @Recount + 1
		END --4
		end--5
		else
		begin
		
		update HLEA set HLEA.PayrollStatus=@PayrollStatus  from [HR].[LeaveEntitlementAdjustment] HLEA (NOLOCK) join HR.LeaveEntitlement HLE (NOLOCK) on HLEA.LeaveEntitlementId =HLE.Id where HLEA.PayrollId=@PayrollId and (IsDeleted=0 or IsDeleted is null)



		end 
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
