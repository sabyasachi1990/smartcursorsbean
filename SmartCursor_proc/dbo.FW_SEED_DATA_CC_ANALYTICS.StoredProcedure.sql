USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_SEED_DATA_CC_ANALYTICS]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[FW_SEED_DATA_CC_ANALYTICS](@UNIQUE_COMPANY_ID bigint, @NEW_COMPANY_ID bigint, @UNIQUE_Id uniqueidentifier)
AS
BEGIN
DECLARE @IN_PROGRESS nvarchar(20) = 'In-Progress'
DECLARE @COMPLETED nvarchar(20) = 'Completed'
DECLARE @MODULE_NAME varchar(50) = 'Client Cursor Analytics' 
DECLARE @MODULE_ID bigint =  (select Id from Common.ModuleMaster where Name = @MODULE_NAME)
BEGIN TRY

DECLARE @ModuleDetail_Unique_Identifier uniqueidentifier = NEWID()
 INSERT INTO Common.DetailLog values(@ModuleDetail_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_CC_ANALYTICS - ModuleDetail Execution Started', GETUTCDATE() , '10.1' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_MODULE_DETAIL_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

  Update Common.DetailLog set Status = @COMPLETED where Id = @ModuleDetail_Unique_Identifier

  END TRY
 BEGIN CATCH
 PRINT 'CC Analytics Seed Data FAILED..!'
	DECLARE      
     @ErrorMessage NVARCHAR(4000),      
     @ErrorSeverity INT,      
     @ErrorState INT;      
SELECT      
     @ErrorMessage = ERROR_MESSAGE(),      
     @ErrorSeverity = ERROR_SEVERITY(),      
     @ErrorState = ERROR_STATE();      
   RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState); 
 END CATCH
END
GO
