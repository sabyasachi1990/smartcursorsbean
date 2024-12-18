USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_DRFINANCE_GL_DELETE]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SP_DRFINANCE_GL_DELETE]
@COMPANYID NVARCHAR (100), @FROM_DB NVARCHAR (500), @TO_DB NVARCHAR (500), @YEAR NVARCHAR (10), @ENGAGEMENTID NVARCHAR (500)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @QUERY_0 AS NVARCHAR (MAX);
        DECLARE @QUERY_2 AS NVARCHAR (MAX);
        DECLARE @QUERY_3 AS NVARCHAR (MAX);
        DECLARE @DIMCOMPANYID AS NVARCHAR (MAX);
        SET @DIMCOMPANYID = '(SELECT CompanyId from ' + @TO_DB + ' .[dbo].[dimcompany] where SourceCompanyID = ' + @COMPANYID + ' And EngagementId=' + '''' + @ENGAGEMENTID + '''' + ')';
        SET @QUERY_0 = 'DELETE FROM ' + @TO_DB + '.[dbo].[DimAccount] where Year =' + @YEAR + ' and CompanyId=' + @DIMCOMPANYID + '';
        EXECUTE sp_executesql @QUERY_0;
        SET @QUERY_3 = 'DELETE FROM ' + @TO_DB + '.[dbo].[DimDocument] where Year =' + @YEAR + ' and CompanyId=' + @DIMCOMPANYID + '';
        EXECUTE sp_executesql @QUERY_3;
        SET @QUERY_2 = 'DELETE FROM ' + @TO_DB + '.dbo.FactGL where Year =' + @YEAR + ' and CompanyId=' + @DIMCOMPANYID + '';
        EXECUTE sp_executesql @QUERY_2;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage AS NVARCHAR (4000), @ErrorSeverity AS INT, @ErrorState AS INT;
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
