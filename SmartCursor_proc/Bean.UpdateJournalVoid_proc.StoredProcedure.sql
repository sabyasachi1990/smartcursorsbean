USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Bean].[UpdateJournalVoid_proc]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create     PROCEDURE [Bean].[UpdateJournalVoid_proc] 
    @Id UNIQUEIDENTIFIER,          
    @DocumentState NVARCHAR(50),    
    @DocNo NVARCHAR(50),             
    @ModifiedBy NVARCHAR(50),      
    @ModifiedDate DATETIME2(7),
	@CompanyId Bigint
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        UPDATE [Bean].[Journal]
        SET
            DocumentState = @DocumentState,
            DocNo = @DocNo,
            ModifiedBy = @ModifiedBy,
            ModifiedDate = @ModifiedDate
        WHERE
            DocumentId = @Id and CompanyId= @CompanyId
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState,
            ERROR_PROCEDURE() AS ErrorProcedure,
            ERROR_LINE() AS ErrorLine,
            ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;
END;
GO
