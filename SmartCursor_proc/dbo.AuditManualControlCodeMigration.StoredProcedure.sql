USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[AuditManualControlCodeMigration]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Audit Manual  Migration for All Partner Companies
--exec [dbo].[AuditManualControlCodeMigration]
Create   
--Alter
Procedure [dbo].[AuditManualControlCodeMigration]
AS Begin
    DECLARE @CompanyId Bigint;
    Begin
        
        DECLARE ControlCodes CURSOR FOR select CompanyId from common.companyModule where Moduleid=3 and status=1 and CompanyId !=0 and CompanyId in (select id from common.company where IsAccountingFirm=1 and status=1 and Id !=0);
          OPEN  ControlCodes       
             FETCH NEXT FROM ControlCodes INTO  @CompanyId
             WHILE (@@FETCH_STATUS=0)      
             BEGIN   
			 --Audit Manual
						IF NOT EXISTS (select * from [common].[ControlCodeCategory] where ControlCodeCategoryCode='Audit Manual' and CompanyId=@CompanyId)
						Begin
						INSERT INTO [Common].[ControlCodeCategory]([Id],[CompanyId],[ControlCodeCategoryCode],[ControlCodeCategoryDescription],[DataType],[Format],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[ModuleNamesUsing],[DefaultValue])
							 VALUES((select max(Id) from [common].[ControlCodeCategory])+1,@CompanyId,'Audit Manual','Audit Manual','string','{0-D}',1,NULL,'System',GETDATE(),NULL,NULL,1,1,'Audit Cursor','PreCursor')
						End

						if not Exists (select * From [Common].[ControlCode] where CodeKey ='Precursor' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='Audit Manual' and CompanyId=@CompanyId))
						Begin
						INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
						VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='Audit Manual' and CompanyId=@CompanyId),'Precursor','Precursor','System',1,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
						End

						if not Exists (select * From [Common].[ControlCode] where CodeKey ='ISCA' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='Audit Manual' and CompanyId=@CompanyId))
						Begin
						INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
						VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='Audit Manual' and CompanyId=@CompanyId),'ISCA','ISCA','System',2,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
						End

						if not Exists (select * From [Common].[ControlCode] where CodeKey ='Custom' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='Audit Manual' and CompanyId=@CompanyId))
						Begin
						INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
						VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='Audit Manual' and CompanyId=@CompanyId),'Custom','Custom','System',3,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
						End

						BEGIN 
						 IF NOT EXISTS (select * from Common.ControlCodeCategoryModule where ControlCategoryId=(SELECT Id FROM [Common].[ControlCodeCategory] 
						  WHERE ControlCodeCategoryCode='Audit Manual' AND CompanyId=@CompanyId AND ControlCodeCategoryDescription='Audit Manual'))
						BEGIN 
						INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId)
						 VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),@CompanyId,(SELECT Id FROM [Common].[ControlCodeCategory] 
						  WHERE ControlCodeCategoryCode='Audit Manual' AND CompanyId=@CompanyId AND ControlCodeCategoryDescription='Audit Manual'),
						  (SELECT Id FROM [Common].[ModuleMaster]  WHERE Name='Audit Cursor'))
						END 
						END;
			 ----------------
                
 
         
             FETCH NEXT FROM ControlCodes INTO   @CompanyId
             END     
              
        CLOSE ControlCodes      
        DEALLOCATE ControlCodes 
    End
End
GO
