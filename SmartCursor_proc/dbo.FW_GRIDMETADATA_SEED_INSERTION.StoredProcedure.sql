USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_GRIDMETADATA_SEED_INSERTION]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[FW_GRIDMETADATA_SEED_INSERTION] (@UNIQUE_COMPANY_ID bigint, @NEW_COMPANY_ID bigint, @ModuleId bigint )
AS
BEGIN
BEGIN TRY
	INSERT INTO [Auth].[GridMetaData] (Id,ModuleDetailId, UserName, Url, GridMetaData, CompanyId, APIMethod, ActionURL, TableName, Class, Title, Params, Options, StreamName, ViewModelName,PopupOptions,ActionType, ModuleMasterId)
	SELECT (NEWID()), ModuleDetailId, UserName, Url, GridMetaData, @NEW_COMPANY_ID, APIMethod, ActionURL, TableName, Class, Title, Params, Options, StreamName, ViewModelName,PopupOptions,ActionType, ModuleMasterId  FROM 
	[Auth].[GridMetaData]  WHERE COMPANYID=@UNIQUE_COMPANY_ID and ModuleMasterId = @ModuleId and Url not in (Select Url from Auth.GridMetaData where CompanyId = @NEW_COMPANY_ID and ModuleMasterId = @ModuleId)
 END TRY
 BEGIN CATCH
    PRINT 'FAILED..!'
	DECLARE      
     @ErrorMessage NVARCHAR(4000),      
     @ErrorSeverity INT,      
     @ErrorState INT;      
SELECT      
     @ErrorMessage = ERROR_MESSAGE(),      
     @ErrorSeverity = ERROR_SEVERITY(),      
     @ErrorState = ERROR_STATE();      
   RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	--ROLLBACK;
END CATCH
END
GO
