USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[InsertAuditSyncing]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create   PROCEDURE [dbo].[InsertAuditSyncing]
    @SourceId nvarchar(max),
    @DestinationId nvarchar(max),
    @SyncingStatus nvarchar(max),
    @CompanyId bigint,
    @FromScreen nvarchar(max),
    @ToScreen nvarchar(max),
    @Action nvarchar(max),
    @Priority nvarchar(max),
    @SystemRemarks nvarchar(max),
    @DeveloperRemarks nvarchar(max),
    @ErrorMessage nvarchar(max),
    @PayLoad nvarchar(max)
AS
BEGIN
    BEGIN TRY
        DECLARE @Error_Severity INT,
                @Error_State INT,
				@Error_Message NVARCHAR(MAX)
     
        DECLARE @IdList TABLE (SourceId nvarchar(max))

        INSERT INTO @IdList (SourceId)
        SELECT value FROM STRING_SPLIT(@SourceId, ',') 

       
        INSERT INTO Common.AuditLog (Id, SourceId, DestinationId, SyncingStatus, CompanyId, FromScreen, ToScreen,
                                     CreatedDate, [Action], [Priority], SystemRemarks, DeveloperRemarks, ErrorMessage, PayLoad)
        SELECT NEWID(), il.SourceId, @DestinationId, @SyncingStatus, @CompanyId, @FromScreen, @ToScreen,
               GETDATE(), @Action, @Priority, @SystemRemarks, @DeveloperRemarks, @ErrorMessage, @PayLoad
        FROM @IdList il

    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @Error_Severity = ERROR_SEVERITY(),
               @Error_State = ERROR_STATE();

        RAISERROR (@ErrorMessage, @Error_Severity, @Error_State);
    END CATCH
END;
GO
