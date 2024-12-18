USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_WF_Bean_SeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Sp_WF_Bean_SeedData](@NEW_COMPANY_ID BIGINT)
As
Begin
	Declare @CompanyType Bit 
	Select @CompanyType=IsAccountingFirm from Common.Company  where  IsAccountingFirm=1 and  id=@NEW_COMPANY_ID
		IF(@CompanyType=1)
	BEGIN
	--UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Audit Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Knowledge Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Doc Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	--UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Tax Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	--UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='BR Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	END

	else
	Begin
	
		UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Audit Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Knowledge Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Doc Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Tax Cursor') AND [CompanyId] = @NEW_COMPANY_ID
	UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='BR Cursor') AND [CompanyId] = @NEW_COMPANY_ID
		END
	END
GO
