USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Claim_Entitlement_Insertion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[HR_Claim_Entitlement_Insertion] (@employeeId UNIQUEIDENTIFIER, @CompanyId BIGINT)
AS
BEGIN
	BEGIN TRANSACTION

	BEGIN TRY
		DECLARE @DeptId UNIQUEIDENTIFIER = (
				SELECT TOP 1 DepartmentId
				FROM hr.EmployeeDepartment (NOLOCK)
				WHERE EmployeeId = @employeeId AND (Convert(DATE, EffectiveFrom) <= CONVERT(DATE, GETDATE()) AND (EffectiveTo IS NULL OR CONVERT(DATE, EffectiveTo) >= CONVERT(DATE, GETDATE())))
				)

		PRINT @DeptId

		DECLARE @DesigId UNIQUEIDENTIFIER = (
				SELECT TOP 1 DepartmentDesignationId
				FROM hr.EmployeeDepartment (NOLOCK)
				WHERE EmployeeId = @employeeId AND (Convert(DATE, EffectiveFrom) <= CONVERT(DATE, GETDATE()) AND (EffectiveTo IS NULL OR CONVERT(DATE, EffectiveTo) >= CONVERT(DATE, GETDATE())))
				)
		--print @DesigId
		DECLARE @HRSETTING_DETAIL_ID UNIQUEIDENTIFIER = (
				SELECT TOP 1. iD
				FROM Common.HRSettingdetails (NOLOCK)
				WHERE MasterId = (
						SELECT ID
						FROM Common.HRSettings (NOLOCK)
						WHERE CompanyId = @CompanyId
						)
				ORDER BY StartDate DESC
				)
		--print @HRSETTING_DETAIL_ID
		DECLARE @EmptyGuid UNIQUEIDENTIFIER = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)

		IF NOT EXISTS (
				SELECT *
				FROM HR.EmployeeClaimsEntitlement (NOLOCK)
				WHERE CompanyId = @CompanyId AND EmployeeId = @EmployeeId
				)
		BEGIN
			INSERT INTO HR.EmployeeClaimsEntitlement (Id, CompanyId, EmployeeId, ClaimsVerifiers, IsNotRequiredVerifier, Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, STATUS, Version, BenefitsCreatedDate, BenefitsModifiedDate)
			SELECT NEWID(), @CompanyId, @EmployeeId, NULL AS ClaimVerifiers, NULL AS IsNotRequiredVerifier, NULL AS Remarks, NULL AS UserCreated, GETDATE() AS CreatedDate, NULL AS ModifiedDate, NULL AS ModifiedBy, NULL AS RecOrder, 1 AS STATUS, 1 AS Version, NULL AS BenefitsCreatedDate, NULL AS BenefitsModifiedDate
		END

		--print 'came to insert'
		INSERT INTO HR.EmployeeClaimsEntitlementDetail (Id, EmployeeClaimsEntitlementId, Year, ClaimType, ClaimItemId, CategoryLimit, TransactionLimit, AnnualLimit, UtilizedAmount, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, STATUS, IsCategoryDisable, HrSettingDetaiId)
		SELECT NEWID(), (
				SELECT Id
				FROM HR.EmployeeClaimsEntitlement (NOLOCK)
				WHERE CompanyId = @CompanyId AND EmployeeId = @EmployeeId
				), YEAR(GETUTCDATE()) AS Year, CS.Type AS ClaimType, CSD.ClaimItemId, CS.CategoryLimit, CSD.TransactionLimit, CSD.AnnualLimit, NULL AS UtilizedAmount, CS.UserCreated AS UserCreated, GETUTCDATE() AS CreatedDate, NULL AS ModifiedDate, NULL AS ModifiedBy, 1 AS STATUS, NULL IsCategoryDisable, @HRSETTING_DETAIL_ID
		FROM HR.ClaimSetupDetail CSD (NOLOCK)
		INNER JOIN HR.ClaimSetup CS (NOLOCK) ON CSD.ClaimSetupId = CS.Id
		inner join HR.ClaimItem as ci (NOLOCK) on CSD.ClaimItemId = ci.Id
		WHERE CS.CompanyId = @CompanyId and Ci.Status=1 and (ci.IsCategoryDisable is null or ci.IsCategoryDisable =0) and (
				CS.ApplyTo = 'All' OR (
					ISNULL(CS.DepartmentId, @EmptyGuid) = CASE 
						WHEN (cs.DepartmentId IS NOT NULL and CS.DepartmentId!= CAST(0x0 AS UNIQUEIDENTIFIER))
							THEN @DeptId
						ELSE @EmptyGuid
						END AND ISNULL(CS.DesignationId, @EmptyGuid) = CASE 
						WHEN cs.DesignationId IS NOT NULL AND (CS.DepartmentId IS NOT NULL and CS.DepartmentId!= CAST(0x0 AS UNIQUEIDENTIFIER))
							THEN @DesigId
						WHEN cs.DesignationId IS NOT NULL AND (CS.DepartmentId IS NULL or CS.DepartmentId =CAST(0x0 AS UNIQUEIDENTIFIER)) AND (
								SELECT code
								FROM [Common].[DepartmentDesignation] (NOLOCK)
								WHERE id = cs.DesignationId
								) = (
								SELECT code
								FROM [Common].[DepartmentDesignation] (NOLOCK)
								WHERE id = @DesigId
								)
							THEN cs.DesignationId
						ELSE @EmptyGuid
						END
					)
				) AND CSD.ClaimItemId NOT IN (
				SELECT ClaimItemId
				FROM HR.EmployeeClaimsEntitlementDetail (NOLOCK)
				WHERE EmployeeClaimsEntitlementId = (
						SELECT Id
						FROM HR.EmployeeClaimsEntitlement (NOLOCK)
						WHERE CompanyId = @CompanyId AND EmployeeId = @EmployeeId
						)
				)





	END TRY

	BEGIN CATCH
		ROLLBACK

		PRINT 'In Catch Block';

		THROW;
	END CATCH

	COMMIT TRANSACTION
END
GO
