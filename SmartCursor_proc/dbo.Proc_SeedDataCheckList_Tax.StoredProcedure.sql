USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SeedDataCheckList_Tax]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------
--Check list SP
CREATE PROCEDURE [dbo].[Proc_SeedDataCheckList_Tax](@companyId BIGINT,@engagementId UNIQUEIDENTIFIER,@taxManualId UNIQUEIDENTIFIER)

AS

  Declare @UNIQUE_COMPANY_ID BIGINT,@NEW_COMPANY_ID BIGINT
  Declare @PartnerCompany_Cnt int;
  Declare @partnerparent int;
  Declare @partnerparentusercreated nvarchar(256);
  Declare @partnerparentcompany int;
  Declare @taxManual nvarchar(100);
  select @PartnerCompany_Cnt=COUNT(*)  from [Common].[Company] where id=@companyId and ParentId is null and IsAccountingFirm=1
  select @partnerparent = COUNT(*) from [Common].[Company] where Id=@companyId and AccountingFirmId is not null
  select @partnerparentcompany = (select AccountingFirmId  from Common.Company where Id=@companyId)
  select @partnerparentusercreated = (select Top 1 UserCreated from Tax.TaxCompany where CompanyId=@companyId)
  select @taxManual = (select name from Tax.TaxManual where id=@taxManualId)
   IF @PartnerCompany_Cnt!=0
  BEGIN
 
  IF NOT EXISTS(select * from Tax.AccountPolicy where EngagementId=@engagementId)
  BEGIN

  INSERT into [Tax].[AccountPolicy](Id,CompanyId,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Section,PolicyTemplateOriginal,PolicyId)
  select NEWID(),@companyId,@engagementId,PolicyName,PolicyTemplate,IsChecked,1,Remarks,RecOrder,@partnerparentusercreated,GETUTCDate(),null,null,Version,Status,Section,PolicyTemplate,Id from [Tax].[AccountPolicy] where CompanyId=@companyId and EngagementId is null and TaxManual=@taxManual
  END
  
  END

     ELSE if @partnerparentcompany ! = 0
   BEGIN
   IF NOT EXISTS(select * from Tax.AccountPolicy where EngagementId=@engagementId)
  BEGIN
    insert into [Tax].[AccountPolicy](Id,CompanyId,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Section,PolicyTemplateOriginal,PolicyId)
   select NEWID(),@companyId,@engagementId,PolicyName,PolicyTemplate,IsChecked,1,Remarks,RecOrder,@partnerparentusercreated,GETUTCDate(),null,null,Version,Status,Section,PolicyTemplate,Id from [Tax].[AccountPolicy] where CompanyId=@partnerparentcompany and EngagementId is null and TaxManual=@taxManual
  END
  END


 ELSE IF @partnerparent=0

    BEGIN
     IF NOT EXISTS(select * from Tax.AccountPolicy where EngagementId=@engagementId)
	 BEGIN
	  insert into [Tax].[AccountPolicy](Id,CompanyId,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Section,PolicyId)
     select NEWID(),@companyId,@engagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,GETUTCDate(),null,null,Version,Status,Section,Id from [Tax].[AccountPolicy] where CompanyId=0
    END

 END

GO
