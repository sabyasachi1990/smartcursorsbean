USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_SEED_DATA_KB]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[FW_SEED_DATA_KB](@UNIQUE_COMPANY_ID bigint, @NEW_COMPANY_ID bigint, @UNIQUE_Id uniqueidentifier)
AS
BEGIN
DECLARE @IN_PROGRESS nvarchar(20) = 'In-Progress'
DECLARE @COMPLETED nvarchar(20) = 'Completed'
DECLARE @MODULE_NAME varchar(20) = 'Knowledge Cursor' 
DECLARE @MODULE_ID bigint =  (select Id from Common.ModuleMaster where Name = @MODULE_NAME)
BEGIN TRY
--================ ControlCodeCategory, ControlCodes, ControlCodeCategoryModule =============================
DECLARE @ControlCode_Unique_Identifier uniqueidentifier = NEWID()
INSERT INTO Common.DetailLog values(@ControlCode_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_KB - ControlCodes Execution Started', GETUTCDATE() , '9.1' , NULL , @IN_PROGRESS )
 
 EXEC [dbo].[FW_CONTROL_CODE_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_NAME

 Update Common.DetailLog set Status = @COMPLETED where Id = @ControlCode_Unique_Identifier
 --=============================================================================================================

  --ModuleDetail Insertion
DECLARE @ModuleDetail_Unique_Identifier uniqueidentifier = NEWID()
 INSERT INTO Common.DetailLog values(@ModuleDetail_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_KB - ModuleDetail Execution Started', GETUTCDATE() , '9.2' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_MODULE_DETAIL_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

  Update Common.DetailLog set Status = @COMPLETED where Id = @ModuleDetail_Unique_Identifier
 --================================================================
 --InitialCursor Setup Insertion
 
 -- 24-02-2020 As of Now KB doesn't have Initial Cursor Setup
 --=================================================================
 DECLARE @gridmetadata_Unique_Identifier uniqueidentifier = NEWID()
 INSERT INTO Common.DetailLog values(@gridmetadata_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_KB - GridMetaData Execution Started', GETUTCDATE() , '9.3' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_GRIDMETADATA_SEED_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

 Update Common.DetailLog set Status = @COMPLETED where Id = @gridmetadata_Unique_Identifier
 --==================================================================
 END TRY
 BEGIN CATCH
 PRINT 'Knowledge Base Seed Data FAILED..!'
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
