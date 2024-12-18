USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[UpdateAuditSyncing]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create   PROCEDURE [dbo].[UpdateAuditSyncing]
    @SourceId nvarchar(max),
    @DestinationId nvarchar(max),
    @SyncingStatus nvarchar(max),
    @Action nvarchar(max),
    @Priority nvarchar(max),
    @SystemRemarks nvarchar(max),
    @DeveloperRemarks nvarchar(max),
    @ErrorMessage nvarchar(max),
    @PayLoad nvarchar(max),
	@FromScreen nvarchar(100),
	@ToScreen nvarchar(100)
AS
BEGIN
    BEGIN TRY
        DECLARE @Error_Message NVARCHAR(MAX),
                @Error_Severity INT,
                @Error_State INT;

        UPDATE Common.AuditLog
        SET DestinationId = @DestinationId,
            SyncingStatus = @SyncingStatus,
            [Action] = @Action,
            [Priority] = @Priority,
            SystemRemarks = @SystemRemarks,
            DeveloperRemarks = @DeveloperRemarks,
            ErrorMessage = @ErrorMessage,
            PayLoad = @PayLoad
        WHERE SourceId in ( SELECT TRIM(Value)
						FROM STRING_SPLIT(@SourceId, ',')
						WHERE LTRIM(RTRIM(value)) <> '') AND FromScreen = @FromScreen AND ToScreen = @ToScreen;

    

    END TRY
    BEGIN CATCH
        SELECT @Error_Message = ERROR_MESSAGE(),
               @Error_Severity = ERROR_SEVERITY(),
               @Error_State = ERROR_STATE();

        RAISERROR (@Error_Message, @Error_Severity, @Error_State);
    END CATCH
END;
GO
