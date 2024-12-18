USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_EmployeeClaims_Calculations]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[HR_EmployeeClaims_Calculations] (@EmployeeId UNIQUEIDENTIFIER, @CompanyId BIGINT, @HrSettingDetaiId UNIQUEIDENTIFIER, @EmployeClaimId UNIQUEIDENTIFIER, @IsAdd BIT, @IsEdit BIT, @IsStatusChanged BIT, @IsClaimVerifierNA BIT,@IsAmountChanged bit)
	--Alter procedure [dbo].[HR_EmployeeClaims_Calculations] ( @EmployeeId uniqueidentifier,@CompanyId BIGINT,@HrSettingDetaiId uniqueidentifier , @StartDate datetime2,@Enddate datetime2,@OldClaimsCarryforwardResetDate datetime2,@IsperviousYear bit , @EmployeClaimId uniqueidentifier)
AS
BEGIN --m1
	BEGIN TRANSACTION --m2

	BEGIN TRY --m3
		--DECLARE @ClaimItemId UNIQUEIDENTIFIER		
		DECLARE @ClaimItemIds UNIQUEIDENTIFIER
		DECLARE @ClaimItem_Tbl TABLE (S_No INT Identity(1, 1), ClaimItemId UNIQUEIDENTIFIER, ClaimCategory NVARCHAR(50), ClaimStatus NVARCHAR(50))
		DECLARE @ItemCount INT
		DECLARE @RecCount INT
		DECLARE @CategotyName NVARCHAR(50)
		DECLARE @ApprovedAmount MONEY
		DECLARE @ClaimStatus NVARCHAR(50)
		DECLARE @PreviousApprovedAmount MONEY
		INSERT INTO @ClaimItem_Tbl
		SELECT DISTINCT ECD.ClaimItemId, CI.Category, EC.ClaimStatus
		FROM HR.EmployeeClaimDetail ECD
		INNER JOIN HR.EmployeeClaim1 EC ON EC.Id = ECD.EmployeeClaimId
		INNER JOIN HR.ClaimItem CI ON ECD.ClaimItemId = CI.Id
		WHERE EC.ParentCompanyId = @CompanyId AND EC.EmployeId = @EmployeeId AND EC.Id = @EmployeClaimId AND CI.Companyid = @CompanyId

		SET @ItemCount = (
				SELECT count(*)
				FROM @ClaimItem_Tbl
				)
		SET @RecCount = 1

		WHILE @ItemCount >= @RecCount
		BEGIN --1
			SELECT @ClaimItemIds = ClaimItemId, @CategotyName = ClaimCategory, @ClaimStatus = ClaimStatus
			FROM @ClaimItem_Tbl
			WHERE S_No = @RecCount

			SET @ApprovedAmount = (
					SELECT CAST(sum(ECD.ApprovedAmount) AS MONEY)
					FROM HR.EmployeeClaim1 AS EC
					INNER JOIN HR.EmployeeClaimDetail AS ECD ON EC.Id = ECD.EmployeeClaimId
					WHERE EC.EmployeId = @EmployeeId AND EC.ParentCompanyId = @CompanyId AND EC.Id = @EmployeClaimId AND (ECD.IsSplit IS NULL OR ECD.IsSplit != 1) AND EC.CaseGroupId IS NULL AND EC.ClientId IS NULL AND ECD.ClaimItemId = @ClaimItemIds
					)

			IF ((@IsAdd = 1 AND @ClaimStatus = 'Submitted') OR (@IsClaimVerifierNA = 1 AND @IsAdd = 1))
			BEGIN --2
			print(1)
				UPDATE ECED
				SET ECED.SubmittedAmount = isnull(ECED.SubmittedAmount, 0) + isnull(@ApprovedAmount, 0), ECED.RemainingAmount = (CASE WHEN (ECED.AnnualLimit IS NULL OR ECED.AnnualLimit = 0) AND (ECED.TransactionLimit IS NULL OR ECED.TransactionLimit = 0) THEN NULL WHEN (ECED.AnnualLimit IS NOT NULL and ECED.AnnualLimit>0) THEN (isnull(ECED.AnnualLimit, 0) - (isnull(ECED.UtilizedAmount, 0)+ isnull(ECED.SubmittedAmount, 0)+ ISNULL(@ApprovedAmount, 0))) ELSE (isnull(ECED.TransactionLimit, 0) - (isnull(ECED.UtilizedAmount, 0)+ isnull(ECED.SubmittedAmount, 0) + ISNULL(@ApprovedAmount, 0))) END)
				FROM HR.EmployeeClaimsEntitlementDetail AS ECED
				INNER JOIN HR.EmployeeClaimsEntitlement AS ECE ON ECE.Id = ECED.EmployeeClaimsEntitlementId
				WHERE ECE.EmployeeId = @EmployeeId AND ECE.CompanyId = @CompanyId AND ECED.ClaimItemId = @ClaimItemIds AND ECED.HrSettingDetaiId = @HrSettingDetaiId
			END --2

			--	--				SET @json =   
			-- --'[{"ItemId":"BC29B13B-9320-4F23-B98C-E325EF6136D0","DetailId":"DD069B14-D49E-6ECC-55AD-003DEBD21CB3","Amount":100},{"ItemId":"7EB19D23-AAD4-4BBE-99D6-2464CA78F201","DetailId":"62F689CE-0843-4188-8180-0089999FA666","Amount":150.2345}]';
			-- INSERT INTO     @PreviousClaimItem_Tbl
			--SELECT * FROM  
			-- OPENJSON ( @json )  
			--WITH (   
			--              ItemId   uniqueidentifier '$.ItemId' ,  
			--              DetailId uniqueidentifier  '$.DetailId',  
			--              Amount   money             '$.Amount'  ,
			--              RecordStatus NVARCHAR(20)  '$.RecordStatus'  
			-- )
			--set @PreviousApprovedAmount=	SELECT CAST(sum(ApprovedAmount) AS MONEY) FROM @PreviousClaimItem_Tbl where ClaimItemId=@ClaimItemIds and  RecordStatus!='Deleted'
			--if(@IsEdit=1 and @IsAdd=0 and (@IsAmountChanged=1 or @IsStatusChanged=1))
			IF (@IsEdit = 1 AND @IsAdd = 0)
			BEGIN --3
				IF (@IsStatusChanged = 1 AND (@ClaimStatus = 'Rejected' OR @ClaimStatus = 'Cancelled')) --Doubt
				BEGIN --4
				print(2)
					UPDATE ECED
					SET ECED.SubmittedAmount = isnull(ECED.SubmittedAmount, 0) - isnull(@ApprovedAmount, 0), ECED.RemainingAmount = (CASE WHEN (ECED.AnnualLimit IS NOT NULL and ECED.AnnualLimit > 0) OR (ECED.TransactionLimit IS NOT NULL and ECED.TransactionLimit > 0) THEN isnull(ECED.RemainingAmount, 0) + isnull(@ApprovedAmount, 0) ELSE NULL END)
					FROM HR.EmployeeClaimsEntitlementDetail AS ECED
					INNER JOIN HR.EmployeeClaimsEntitlement AS ECE ON ECE.Id = ECED.EmployeeClaimsEntitlementId
					WHERE ECE.EmployeeId = @EmployeeId AND ECE.CompanyId = @CompanyId AND ECED.ClaimItemId = @ClaimItemIds AND ECED.HrSettingDetaiId = @HrSettingDetaiId
				END --4
				ELSE IF (@IsStatusChanged = 1 AND @ClaimStatus = 'Void') --Doubt
				BEGIN --5
				print(3)
					UPDATE ECED
					SET ECED.UtilizedAmount = isnull(ECED.UtilizedAmount, 0) - isnull(@ApprovedAmount, 0), ECED.RemainingAmount = (CASE WHEN (ECED.AnnualLimit IS NOT NULL and ECED.AnnualLimit >0) OR (ECED.TransactionLimit IS NOT NULL and ECED.TransactionLimit > 0) THEN isnull(ECED.RemainingAmount, 0) + isnull(@ApprovedAmount, 0) ELSE NULL END)
					FROM HR.EmployeeClaimsEntitlementDetail AS ECED
					INNER JOIN HR.EmployeeClaimsEntitlement AS ECE ON ECE.Id = ECED.EmployeeClaimsEntitlementId
					WHERE ECE.EmployeeId = @EmployeeId AND ECE.CompanyId = @CompanyId AND ECED.ClaimItemId = @ClaimItemIds AND ECED.HrSettingDetaiId = @HrSettingDetaiId
				END --5 
				ELSE IF (@IsStatusChanged = 1 AND @ClaimStatus = 'Processed' ) --Doubt
				BEGIN --6
				print(4)
					UPDATE ECED
					SET ECED.UtilizedAmount = isnull(ECED.UtilizedAmount, 0) + isnull(@ApprovedAmount, 0), ECED.SubmittedAmount = isnull(ECED.SubmittedAmount, 0) - isnull(@ApprovedAmount, 0)
					FROM HR.EmployeeClaimsEntitlementDetail AS ECED
					INNER JOIN HR.EmployeeClaimsEntitlement AS ECE ON ECE.Id = ECED.EmployeeClaimsEntitlementId
					WHERE ECE.EmployeeId = @EmployeeId AND ECE.CompanyId = @CompanyId AND ECED.ClaimItemId = @ClaimItemIds AND ECED.HrSettingDetaiId = @HrSettingDetaiId
				END --6
				--ELSE IF (@ClaimStatus = 'Reviewed') --Doubt
				--BEGIN --6
				--print(4)
				--	UPDATE ECED
				--	SET  ECED.SubmittedAmount =  isnull(@ApprovedAmount, 0),@Test=concat('Reviewed',@ApprovedAmount)
				--	FROM HR.EmployeeClaimsEntitlementDetail AS ECED
				--	INNER JOIN HR.EmployeeClaimsEntitlement AS ECE ON ECE.Id = ECED.EmployeeClaimsEntitlementId
				--	WHERE ECE.EmployeeId = @EmployeeId AND ECE.CompanyId = @CompanyId AND ECED.ClaimItemId = @ClaimItemIds AND ECED.HrSettingDetaiId = @HrSettingDetaiId
				--END --6
				ELSE IF ((@IsStatusChanged = 1 AND @ClaimStatus = 'Submitted') OR (@IsClaimVerifierNA = 1 AND @IsStatusChanged = 1))
				BEGIN --2
				print(5)
					UPDATE ECED
					SET ECED.SubmittedAmount = isnull(ECED.SubmittedAmount, 0) + isnull(@ApprovedAmount, 0), ECED.RemainingAmount = (CASE WHEN (ECED.AnnualLimit IS NULL OR ECED.AnnualLimit = 0) AND (ECED.TransactionLimit IS NULL OR ECED.TransactionLimit = 0) THEN NULL WHEN (ECED.AnnualLimit IS NOT NULL and ECED.AnnualLimit>0) THEN isnull(ECED.AnnualLimit, 0) - (isnull(ECED.UtilizedAmount, 0)+ isnull(ECED.SubmittedAmount, 0) + ISNULL(@ApprovedAmount, 0)) ELSE isnull(ECED.TransactionLimit, 0) - (isnull(ECED.UtilizedAmount, 0)+ isnull(ECED.SubmittedAmount, 0) + ISNULL(@ApprovedAmount, 0)) END)
					FROM HR.EmployeeClaimsEntitlementDetail AS ECED
					INNER JOIN HR.EmployeeClaimsEntitlement AS ECE ON ECE.Id = ECED.EmployeeClaimsEntitlementId
					WHERE ECE.EmployeeId = @EmployeeId AND ECE.CompanyId = @CompanyId AND ECED.ClaimItemId = @ClaimItemIds AND ECED.HrSettingDetaiId = @HrSettingDetaiId
				END --2
				
				--if(@IsStatusChanged=0 and @IsAmountChanged=1)
				ELSE IF ((@IsStatusChanged = 0 and @ClaimStatus != 'Rejected') or @IsAmountChanged=1)
				BEGIN --7
				print(7)
					UPDATE ECED
					SET ECED.SubmittedAmount = isnull(ECED.SubmittedAmount, 0) + isnull(@ApprovedAmount, 0), ECED.RemainingAmount = (CASE WHEN (ECED.AnnualLimit IS NULL OR ECED.AnnualLimit = 0) AND (ECED.TransactionLimit IS NULL OR ECED.TransactionLimit = 0) THEN NULL WHEN (ECED.AnnualLimit IS NOT NULL and ECED.AnnualLimit>0) THEN isnull(ECED.AnnualLimit, 0) - (isnull(ECED.UtilizedAmount, 0)+ isnull(ECED.SubmittedAmount, 0) + ISNULL(@ApprovedAmount, 0)) ELSE isnull(ECED.TransactionLimit, 0) - (isnull(ECED.UtilizedAmount, 0)+ isnull(ECED.SubmittedAmount, 0) + ISNULL(@ApprovedAmount, 0)) END)
					FROM HR.EmployeeClaimsEntitlementDetail AS ECED
					INNER JOIN HR.EmployeeClaimsEntitlement AS ECE ON ECE.Id = ECED.EmployeeClaimsEntitlementId
					WHERE ECE.EmployeeId = @EmployeeId AND ECE.CompanyId = @CompanyId AND ECED.ClaimItemId = @ClaimItemIds AND ECED.HrSettingDetaiId = @HrSettingDetaiId

					
				END --7
			END --3
			
			-----Category amount update
			print(8)
			UPDATE E
			SET E.CategoryUtilizedAmount = A.UtilizedAmount, E.CategoryPreApprovedAmount = A.SubmittedAmount, E.CategoryBalanceAmount = (CASE WHEN (E.CategoryLimit IS NULL) THEN NULL ELSE ISNULL(E.CategoryLimit, 0) - (ISNULL(A.UtilizedAmount, 0) + ISNULL(A.SubmittedAmount, 0)) END)
			FROM hr.EmployeeClaimsEntitlementDetail E
			INNER JOIN HR.ClaimItem CI ON E.ClaimItemId = CI.Id
			INNER JOIN (
				SELECT ECD.Id, CI.Category, SUM(ECED.UtilizedAmount) AS UtilizedAmount, SUM(ECED.SubmittedAmount) AS SubmittedAmount
				FROM HR.EmployeeClaimsEntitlementDetail ECED
				INNER JOIN HR.EmployeeClaimsEntitlement ECD ON ECED.EmployeeClaimsEntitlementId = ECD.Id
				INNER JOIN HR.ClaimItem CI ON ECED.ClaimItemId = CI.Id
				WHERE ECD.EmployeeId = @EmployeeId AND ECD.CompanyId = @CompanyId AND CI.CompanyId = @CompanyId AND ECED.HrSettingDetaiId = @HrSettingDetaiId AND CI.Category = @CategotyName
				--and ECED.ClaimItemId in ((select ClaimItemId from hr.EmployeeClaimsEntitlementDetail where EmployeeClaimsEntitlementId = ECD.Id and HrSettingDetaiId = @HrSettingDetaiId )) 
				GROUP BY ECD.Id, CI.Category
				) A ON A.Id = E.EmployeeClaimsEntitlementId AND E.HrSettingDetaiId = @HrSettingDetaiId AND CI.Category = @CategotyName
				--and  E.ClaimItemId in ((select ClaimItemId from hr.EmployeeClaimsEntitlementDetail where EmployeeClaimsEntitlementId = A.Id and HrSettingDetaiId = @HrSettingDetaiId ))  
				AND A.Category = CI.Category AND CI.CompanyId = @CompanyId

			SET @RecCount = @RecCount + 1
		END --1

		COMMIT TRANSACTION --m2
	END TRY --m3

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = 16, @ErrorState = 1;		

		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH
END --m1

GO
