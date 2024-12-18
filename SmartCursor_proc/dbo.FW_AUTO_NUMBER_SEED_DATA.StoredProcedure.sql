USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_AUTO_NUMBER_SEED_DATA]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROC [dbo].[FW_AUTO_NUMBER_SEED_DATA] (@UNIQUE_COMPANY_ID bigint, @NEW_COMPANY_ID bigint, @ModuleId bigint)
AS
BEGIN
--BEGIN TRANSACTION
BEGIN TRY

  IF (@ModuleId = 4)
  BEGIN
  INSERT INTO Bean.AutoNumber (Id, CompanyId, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, MaxLength,StartNumber,[Reset],Preview, IsResetbySubsidary, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Variables,Sufix, Prefix, Entity, IsFormatChange, IsDisable, IsEditable, IsEditableDisable, EntityId)

	select NEWID(),@NEW_COMPANY_ID, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, [MaxLength], StartNumber, [Reset], Preview, IsResetbySubsidary, Status, 'System', GETUTCDATE(),null,null,Variables, Sufix,Prefix,Entity,IsFormatChange,IsDisable,IsEditable,IsEditableDisable,EntityId from Common.AutoNumber where  CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId = @ModuleId and EntityType not in (select EntityType from Common.AutoNumber where CompanyId=@NEW_COMPANY_ID and ModuleMasterId = @ModuleId)
  END

  IF (@ModuleId = 8)
  BEGIN
  INSERT INTO HR.AutoNumber (Id, CompanyId, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, MaxLength,StartNumber,[Reset],Preview, IsResetbySubsidary, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Variables,Sufix, Prefix, Entity, IsFormatChange, IsDisable, IsEditable, IsEditableDisable, EntityId)

	select NEWID(),@NEW_COMPANY_ID, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, [MaxLength], StartNumber, [Reset], Preview, IsResetbySubsidary, Status, 'System', GETUTCDATE(),null,null,Variables, Sufix,Prefix,Entity,IsFormatChange,IsDisable,IsEditable,IsEditableDisable,EntityId from Common.AutoNumber where  CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId = @ModuleId and EntityType not in (select EntityType from HR.AutoNumber where CompanyId=@NEW_COMPANY_ID and ModuleMasterId = @ModuleId)
  END

  ELSE
  BEGIN
    INSERT INTO Common.AutoNumber (Id, CompanyId, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, MaxLength,StartNumber,[Reset],Preview, IsResetbySubsidary, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Variables,Sufix, Prefix, Entity, IsFormatChange, IsDisable, IsEditable, IsEditableDisable, EntityId)

	select NEWID(),@NEW_COMPANY_ID, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, [MaxLength], StartNumber, [Reset], Preview, IsResetbySubsidary, Status, 'System', GETUTCDATE(),null,null,Variables, Sufix,Prefix,Entity,IsFormatChange,IsDisable,IsEditable,IsEditableDisable,EntityId from Common.AutoNumber where  CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId = @ModuleId and EntityType not in (select EntityType from Common.AutoNumber where CompanyId=@NEW_COMPANY_ID and ModuleMasterId = @ModuleId)
   END

--COMMIT TRANSACTION
END TRY
BEGIN CATCH
    DECLARE      
     @ErrorMessage NVARCHAR(4000),      
     @ErrorSeverity INT,      
     @ErrorState INT;      
SELECT      
     @ErrorMessage = ERROR_MESSAGE(),      
     @ErrorSeverity = ERROR_SEVERITY(),      
     @ErrorState = ERROR_STATE();      
   RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);      
  --ROLLBACK TRANSACTION 
END CATCH
END
GO
