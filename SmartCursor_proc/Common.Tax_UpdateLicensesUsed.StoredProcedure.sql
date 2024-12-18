USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[Tax_UpdateLicensesUsed]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Common].[Tax_UpdateLicensesUsed] (
    @companyId BIGINT,
    @status NVARCHAR(20),
    @chargeUnit NVARCHAR(20)
)
AS
BEGIN
    DECLARE @country NVARCHAR(50);
    SELECT @country = Jurisdiction FROM Common.Company (NOLOCK) WHERE Id = @companyId;
    UPDATE TOP (1) S SET S.LicensesUsed =CASE WHEN @status = 'active' THEN CASE
                        WHEN (ISNULL(s.LicensesUsed, 0) + 1) > s.LicensesReserved THEN s.LicensesReserved
                        ELSE ISNULL(s.LicensesUsed, 0) + 1
                    END
                ELSE
                    CASE
                        WHEN (ISNULL(s.LicensesUsed, 0) - 1) > 0 THEN ISNULL(s.LicensesUsed, 0) - 1
                        ELSE 0
                    END
            END
    FROM License.Subscription S (NOLOCK)
    INNER JOIN License.Package P (NOLOCK) ON S.PackageId = P.Id
    WHERE S.CompanyId = @companyId AND P.ChargeUnit = @chargeUnit AND P.Country = @country AND S.LicensesReserved >= S.LicensesUsed;
END;
GO
