USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_WF_Audit_BRC_SeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Sp_WF_Audit_BRC_SeedData](@NEW_COMPANY_ID BIGINT,@UNIQUE_COMPANY_ID BIGINT)
As
Declare @GenericTemplate_Cnt int
select 	@GenericTemplate_Cnt=Count(*) from Common.GenericTemplate where companyid=@NEW_COMPANY_ID	
If @GenericTemplate_Cnt =0
Begin
	--------------------------------Generic Template--------------------------------------

--	INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status])
--       SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1
--FROM Common.GenericTemplate WHERE CompanyId=@UNIQUE_COMPANY_ID
	
	declare @AuditFirmId bigint= (select AccountingFirmId from Common.Company where Id=@NEW_COMPANY_ID);
 if @AuditFirmId is null
  BEGIN
 INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsPartnerTemplate],[CursorName],[TemplateType])
       SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1,[IsPartnerTemplate],[CursorName],[TemplateType]
  FROM Common.GenericTemplate WHERE CompanyId=@UNIQUE_COMPANY_ID
  END
else
  BEGIN
       INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsPartnerTemplate],[CursorName],[TemplateType])
            SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1,[IsPartnerTemplate],[CursorName],[TemplateType]
       FROM Common.GenericTemplate WHERE CompanyId=@AuditFirmId
 END
 End
GO
