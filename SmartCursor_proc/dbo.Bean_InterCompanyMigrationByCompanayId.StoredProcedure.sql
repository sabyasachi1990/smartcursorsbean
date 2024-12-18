USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_InterCompanyMigrationByCompanayId]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   Procedure [dbo].[Bean_InterCompanyMigrationByCompanayId] 
(
@companyId BIGINT
)
AS
Begin
Declare @id uniqueidentifier

Set @id=NEWID()

IF((Select CF.Status from Common.Feature F
                    JOIN Common.CompanyFeatures CF on F.Id=CF.FeatureId
                    where CF.Companyid=@companyId and F.Name='Inter-Company' and F.ModuleId is null)=1)
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        Set @id=NEWID()

		If Not Exists(Select Id from Common.CompanyFeatures where CompanyId=@companyId and FeatureId=(Select ID from Common.Feature where Name='Inter-Company' and ModuleId=4))
		Begin
			Insert Common.CompanyFeatures (Id,CompanyId,FeatureId,Status,IsChecked,Remarks,CreatedDate,UserCreated,ModifiedDate,ModifiedBy)
			values (newid(),@companyId,(Select ID from Common.Feature where Name='Inter-Company' and ModuleId=4),1,1,null,GETDATE(), 'System',null,null)
		END

		If Not Exists(Select Id from Bean.InterCompanySetting where CompanyId=@companyId and InterCompanyType='Clearing')
		Begin
			Insert Into Bean.InterCompanySetting values(@id,@companyId,'Clearing',1,'System',GETUTCDATE(),null,null)
        
			Insert Into Bean.InterCompanySettingDetail (Id,InterCompanySettingId,RecOrder,Status,ServiceEntityId) 
			Select NEWID(),@id,1,1, id from Common.Company where ParentId=@companyId and Status=1
		End
		If Not Exists(Select Id from Bean.InterCompanySetting where CompanyId=@companyId and InterCompanyType='Billing')
		Begin
			Insert Into Bean.InterCompanySetting values(Newid(),@companyId,'Billing',Case When @companyId=1 Then 1 Else 0 End,'System',GETUTCDATE(),null,null)
		End
		update Bean.ChartOfAccount set IsSystem=0,IsLinkedAccount=1,UserCreated='System' where CompanyId=@companyId and (IsBank is null or IsBank=0) and SubsidaryCompanyId in (select id from Common.Company where ParentId =@companyId) and name like '%I/C - %'

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK 
    END CATCH
END
END
GO
