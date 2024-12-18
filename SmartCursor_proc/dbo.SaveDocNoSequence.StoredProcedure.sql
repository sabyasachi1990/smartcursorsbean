USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SaveDocNoSequence]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[SaveDocNoSequence]
    @CompanyId BIGINT,
    @DocType NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        DECLARE @GeneratedNumber NVARCHAR(100);
        DECLARE @ModuleMasterId INT;

        SELECT @GeneratedNumber = GeneratedNumber 
        FROM HR.AutoNumber 
        WHERE CompanyId = @CompanyId 
            AND ModuleMasterId = 8 
            AND EntityType = @DocType;


        SELECT @ModuleMasterId = m.Id 
        FROM Common.ModuleMaster AS m 
        WHERE m.Name = 'HR Cursor' 
            AND m.CompanyId = 0;

 
        UPDATE HR.AutoNumber 
        SET GeneratedNumber = @GeneratedNumber - 1
        WHERE CompanyId = @CompanyId 
            AND ModuleMasterId = @ModuleMasterId 
            AND EntityType = @DocType;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
