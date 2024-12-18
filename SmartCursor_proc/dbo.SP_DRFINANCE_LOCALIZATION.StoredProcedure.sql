USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_DRFINANCE_LOCALIZATION]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SP_DRFINANCE_LOCALIZATION]
@COMPANYID NVARCHAR (100), @FROM_DB NVARCHAR (500), @TO_DB NVARCHAR (500)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @QUERY_1 AS NVARCHAR (MAX);
        DECLARE @QUERY_5 AS NVARCHAR (MAX);
        DECLARE @QUERY_11 AS NVARCHAR (MAX);
        DECLARE @QUERY_12 AS NVARCHAR (MAX);
        DECLARE @QUERY_13 AS NVARCHAR (MAX);
        DECLARE @QUERY_14 AS NVARCHAR (MAX);
        SET @QUERY_5 = 'select * from ' + @TO_DB + '.dbo.DimCompany where SourceCompanyID = ' + @COMPANYID + '';
        EXECUTE sp_executesql @QUERY_5;
        DECLARE @COUNT AS INT = @@ROWCOUNT;
        IF (@COUNT > 0)
            BEGIN
                SET @QUERY_1 = 'update DC set dc.SourceCompanyID=c.Id, dc.RegistrationNo = c.RegistrationNo, dc.CompanyName = c.Name, dc.LogoId=c.LogoId, dc.TenantID = c.TenantId, dc.TenantName=c.Name, dc.FinacialYearEnd=L.BusinessYearEnd, dc.RegistrationDate =  FC.IncorporationDate 
		from ' + @TO_DB + '.[dbo].DimCompany as DC 
		inner join ' + @FROM_DB + '.common.company as C on c.Id = dc.SourceCompanyID 
		inner join ' + @FROM_DB + '.DR.localization as L on C.Id = L.CompanyId
		inner join ' + @FROM_DB + '.Dr.FinanceCompany as FC on C.Id = FC.CompanyId
		where DC.SourceCompanyID=' + @COMPANYID + ' and ' + 'L.CompanyId=' + @COMPANYID;
                EXECUTE sp_executesql @QUERY_1;
            END
        ELSE
            BEGIN
                SET @QUERY_11 = 'insert into ' + @TO_DB + '.[dbo].DimCompany (SourceCompanyID, RegistrationNo, CompanyName, LogoId, TenantID, TenantName, FinacialYearEnd, RegistrationDate)
		select C.Id, C.RegistrationNo, C.Name, C.LogoId, C.TenantId,C.Name, L.BusinessYearEnd, FC.IncorporationDate 
		from ' + @FROM_DB + '.common.company C 
		inner join ' + @FROM_DB + '.DR.localization as L on C.Id = L.CompanyId
		inner join ' + @FROM_DB + '.Dr.FinanceCompany as FC on C.Id = FC.CompanyId
		where C.Id=' + @COMPANYID;
                EXECUTE sp_executesql @QUERY_11;
            END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage AS NVARCHAR (4000) = @@ROWCOUNT, @ErrorSeverity AS INT = @@ROWCOUNT, @ErrorState AS INT = @@ROWCOUNT;
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        ROLLBACK;
        PRINT ('FAILED');
    END CATCH
    BEGIN
        COMMIT TRANSACTION;
    END
END

GO
