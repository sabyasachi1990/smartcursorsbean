USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WPNameControlCodeMigration]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- WP Name  Migration for All Companies
--exec [dbo].[WPNameControlCodeMigration]
Create   
--Alter
Procedure [dbo].[WPNameControlCodeMigration]
AS Begin
    DECLARE @CompanyId Bigint;
    Begin
        
        DECLARE ControlCodes CURSOR FOR select CompanyId from common.companyModule where Moduleid=3 and status=1 and CompanyId !=0
          OPEN  ControlCodes       
             FETCH NEXT FROM ControlCodes INTO  @CompanyId
             WHILE (@@FETCH_STATUS=0)      
             BEGIN   

							IF NOT EXISTS (select * from [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId)
							Begin
							INSERT INTO [Common].[ControlCodeCategory]([Id],[CompanyId],[ControlCodeCategoryCode],[ControlCodeCategoryDescription],[DataType],[Format],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[ModuleNamesUsing],[DefaultValue])
								 VALUES((select max(Id) from [common].[ControlCodeCategory])+1,@CompanyId,'WorkPrograms','WorkPrograms','string','{0-D}',1,NULL,'System',GETDATE(),NULL,NULL,1,1,'Audit Cursor','PreCursor')
							End




							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Cash and cash equivalents' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Cash and cash equivalents','Cash and cash equivalents','System',1,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End



							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Trade receivables' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Trade receivables','Trade receivables','System',2,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End


							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Inventories' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Inventories','Inventories','System',3,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End


							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Other receivables, deposits and prepayments' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Other receivables, deposits and prepayments','Other receivables, deposits and prepayments','System',4,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End



							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Related parties balances' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Related parties balances','Related parties balances','System',5,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End



							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Contract assets and liabilities' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Contract assets and liabilities','Contract assets and liabilities','System',6,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End


							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Taxation' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Taxation','Taxation','System',7,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End



							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Lease receivables' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Lease receivables','Lease receivables','System',8,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End


							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Loan receivables' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Loan receivables','Loan receivables','System',9,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End


							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Property, plant and equipment' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Property, plant and equipment','Property, plant and equipment','System',10,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End


							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Investment in subsidiaries' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Investment in subsidiaries','Investment in subsidiaries','System',11,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End


							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Investment in associates' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Investment in associates','Investment in associates','System',12,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End


							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Investment in joint ventures' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Investment in joint ventures','Investment in joint ventures','System',13,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End


							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Intangible assets' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Intangible assets','Intangible assets','System',14,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End


							--15
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Investment properties' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Investment properties','Investment properties','System',15,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--16
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Other Investments' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Other Investments','Other Investments','System',16,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--17
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Trade payables' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Trade payables','Trade payables','System',17,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--18
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Other payables and accruals' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Other payables and accruals','Other payables and accruals','System',18,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--19
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Lease payables' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Lease payables','Lease payables','System',19,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--20
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Loan payables' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Loan payables','Loan payables','System',20,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--21
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Deferred revenue' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Deferred revenue','Deferred revenue','System',21,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--22
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Reserve' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Reserve','Reserve','System',22,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--23
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Share capital' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Share capital','Share capital','System',23,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--24
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Revenue' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Revenue','Revenue','System',24,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--25
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Direct costs' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Direct costs','Direct costs','System',25,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--26
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Expenses (with payroll)' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Expenses (with payroll)','Expenses (with payroll)','System',26,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--27
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Expenses (without payroll)' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Expenses (without payroll)','Expenses (without payroll)','System',27,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End
							--28
							if not Exists (select * From [Common].[ControlCode] where CodeKey ='Other income' and ControlCategoryId=(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId))
							Begin
							INSERT INTO [Common].[ControlCode]([Id],[ControlCategoryId],[CodeKey],[CodeValue],[IsSystem],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsDefault])
							VALUES((select max(Id) From [Common].[ControlCode])+1,(Select id from  [common].[ControlCodeCategory] where ControlCodeCategoryCode='WorkPrograms' and CompanyId=@CompanyId),'Other income','Other income','System',28,NULL,'System',GETDATE(),NULL,NULL,1,1,0)
							End







							BEGIN 
							 IF NOT EXISTS (select * from Common.ControlCodeCategoryModule where ControlCategoryId=(SELECT Id FROM [Common].[ControlCodeCategory] 
							  WHERE ControlCodeCategoryCode='WorkPrograms' AND CompanyId=@CompanyId AND ControlCodeCategoryDescription='WorkPrograms'))
							BEGIN 

							INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId)
							 VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),@CompanyId,(SELECT Id FROM [Common].[ControlCodeCategory] 
							  WHERE ControlCodeCategoryCode='WorkPrograms' AND CompanyId=@CompanyId AND ControlCodeCategoryDescription='WorkPrograms'),
							  (SELECT Id FROM [Common].[ModuleMaster]  WHERE Name='Audit Cursor'))
							END 
							END
 
         
             FETCH NEXT FROM ControlCodes INTO   @CompanyId
             END     
              
        CLOSE ControlCodes      
        DEALLOCATE ControlCodes 
    End
End
GO
