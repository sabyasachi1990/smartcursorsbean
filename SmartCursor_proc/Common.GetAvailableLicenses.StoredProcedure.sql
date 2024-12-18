USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[GetAvailableLicenses]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Common].[GetAvailableLicenses] 
(
    @moduleName NVARCHAR(100),
    @companyId NVARCHAR(100),
    @chargeUnit NVARCHAR(100)
)
AS 
BEGIN
    DECLARE @country NVARCHAR(50) = (SELECT Jurisdiction FROM Common.Company (NOLOCK) WHERE Id = @companyId);
    DECLARE @temp TABLE (CompanyName NVARCHAR(500) NULL,ModuleName NVARCHAR(100) NULL, ChargeUnit NVARCHAR(100) NULL, AvailableLicenses NVARCHAR(100) NULL, HRMSPlatinumAvailableLicenses NVARCHAR(100) NULL, HRMSilverAvailableLicenses NVARCHAR(100) NULL,
        HRMSGoldAvailableLicenses NVARCHAR(100) NULL,CompanyCreatedDate DATETIME2(7) NULL,CompanyStatus NVARCHAR(20) NULL);
 
    DECLARE @HRMSPlatinumAvailableLicenses NVARCHAR(100) = (SELECT SUM(LicensesReserved - LicensesUsed)  FROM License.Subscription 
         WHERE CompanyId = @companyId AND SubscriptionName LIKE '%HRMS - Platinum%' AND Status = 1);
 
    DECLARE @HRMSilverAvailableLicenses NVARCHAR(100) = (SELECT SUM(LicensesReserved - LicensesUsed) FROM License.Subscription 
         WHERE CompanyId = @companyId AND SubscriptionName LIKE '%HRMS - Silver%' AND Status = 1);
 
    DECLARE @HRMSGoldAvailableLicenses NVARCHAR(100) = (SELECT SUM(LicensesReserved - LicensesUsed) FROM License.Subscription 
	     WHERE CompanyId = @companyId AND SubscriptionName LIKE '%HRMS - Gold%' AND Status = 1);
 
    INSERT INTO @temp
    SELECT c.Name AS CompanyName,   @moduleName AS ModuleName, p.ChargeUnit AS ChargeUnit,
         SUM(s.LicensesReserved - s.LicensesUsed) AS AvailableLicenses, CONVERT(NVARCHAR(100), @HRMSPlatinumAvailableLicenses) AS HRMSPlatinumAvailableLicenses,CONVERT(NVARCHAR(100), @HRMSilverAvailableLicenses) AS HRMSilverAvailableLicenses,CONVERT(NVARCHAR(100), @HRMSGoldAvailableLicenses) AS HRMSGoldAvailableLicenses, c.CreatedDate AS CompanyCreatedDate,CASE WHEN c.Status = 2 THEN 'Inactive' ELSE 'Active' END AS CompanyStatus
    FROM  License.Subscription AS s 
	JOIN License.Package AS p ON p.Id = s.PackageId 
	JOIN Common.Company AS c ON c.Id = s.CompanyId
    WHERE  
        s.CompanyId = @companyId AND  
        s.Status = 1 AND 
        p.ChargeUnit = @chargeUnit
    GROUP BY 
        c.Name, p.ChargeUnit, c.CreatedDate, c.Status;
if not exists(select * from @temp)
	begin
    INSERT INTO @temp 
    SELECT  c.Name,@moduleName, @chargeUnit, '0',@HRMSPlatinumAvailableLicenses,  @HRMSilverAvailableLicenses, @HRMSGoldAvailableLicenses, c.CreatedDate,CASE WHEN c.Status = 2 THEN 'Inactive' ELSE 'Active' END AS CompanyStatus FROM  Common.Company c (NOLOCK)
    WHERE  Id = @companyId;
  End
 
    SELECT * FROM @temp;
END
-----------------------------------------------------------------------------------------------------------------------------------------------
GO
