USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_UpdateLicenseCount]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_UpdateLicenseCount] -- EXEC SP_UpdateLicenseCount
AS
BEGIN

-------================================================ UPDATE PMS COUNT ========================================

UPDATE 
	License.Subscription 
SET 
	LicensesUsed=(SELECT CASE WHEN [Client Cursor License] >= [Workflow Cursor License] THEN [Client Cursor License] ELSE [Workflow Cursor License] END PMS FROM dbo.VW_LicenseCountCalculator WHERE CompanyId = 2058)  
WHERE 
	SubscriptionName='Scm_Practice Management (>100) (1)' AND CompanyId = 2058

-------================================================ UPDATE CC COUNT ========================================

UPDATE 
	License.CompanyPackageModule 
SET 
	LicensesUsed = (SELECT [Client Cursor License] FROM dbo.VW_LicenseCountCalculator WHERE CompanyId = 2058)
WHERE 
	CompanyId=2058 and ModuleMasterId = 1

-------================================================ UPDATE WF COUNT ========================================

UPDATE 
	License.CompanyPackageModule 
SET 
	LicensesUsed = (SELECT [Workflow Cursor License] FROM dbo.VW_LicenseCountCalculator WHERE CompanyId = 2058)
WHERE 
	CompanyId = 2058 and ModuleMasterId = 2


-------================================================ UPDATE HRMS COUNT ========================================

UPDATE 
	License.Subscription 
SET 
	LicensesUsed = (SELECT [HR Cursor License] FROM dbo.VW_LicenseCountCalculator WHERE CompanyId = 2058)  
WHERE 
	SubscriptionName = 'Scm_HRMS - Platinum (1)' AND CompanyId=2058

-------================================================ UPDATE HR COUNT ========================================

UPDATE 
	License.CompanyPackageModule 
SET 
	LicensesUsed = (SELECT [HR Cursor License] FROM dbo.VW_LicenseCountCalculator WHERE CompanyId = 2058)
WHERE 
	CompanyId = 2058 and ModuleMasterId = 8

END
GO
