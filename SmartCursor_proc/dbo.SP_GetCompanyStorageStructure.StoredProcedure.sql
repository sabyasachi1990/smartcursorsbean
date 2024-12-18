USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_GetCompanyStorageStructure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SP_GetCompanyStorageStructure] @CompanyId INT
As
BEGIN
   Select * From
(
    --Partner Company with Entity (Parent), Audit Cursor and their Subsidory Companies

 

    Select Partner.Id PartnerId, Partner.Name Partner, Parent.Id EntityId, Parent.Name Entity, 'AUC' [Cursor], 'Audit Cursor' ModuleName, Subsidory.Id ServiceEntityId, Subsidory.Name ServiceEntity
    From Common.Company Partner
    Inner Join Common.Company Parent On Parent.AccountingFirmId = Partner.id
    Inner Join Common.Company Subsidory On Subsidory.ParentId = Parent.Id
    Inner Join Audit.AuditCompany AuditCompany On AuditCompany.ServiceCompanyId = Subsidory.Id
    Where Partner.IsAccountingFirm = 1 and Partner.Id = @CompanyId

 

    ------Union All -- Partner's Entities with Other Cursors (except Audit)
    
    ------Select Partner.Id PartnerId, Partner.Name Partner, Parent.Id EntityId, Parent.Name Entity, MM.ShortCode [Cursor], MM.Heading ModuleName, Null ServiceEntityId, '' ServiceEntity
    ------From Common.Company Partner
    ------Inner Join Common.Company Parent On Parent.AccountingFirmId = Partner.id
    ------Inner Join Common.CompanyModule CM on CM.CompanyId =Parent.Id
    ------Inner Join Common.ModuleMaster MM on CM.ModuleId=MM.id 
    ------Where Partner.IsAccountingFirm = 1 and Partner.Id = @CompanyId and MM.IsMainCursor=1 and CM.Status=1 and MM.ShortCode <> 'AUC'

 

    Union ALL    -- Partner Company with Other Cursors (except Audit)

 

    Select Partner.Id PartnerId, Partner.Name Partner, null EntityId, '' Entity, MM.Shortcode [Cursor], MM.Heading ModuleName, Null ServiceEntityId,'' ServiceEntity
    From Common.Company Partner
    Inner Join Common.CompanyModule CM on CM.CompanyId =Partner.Id
    Inner Join Common.ModuleMaster MM on CM.ModuleId=MM.id 
    Where Partner.IsAccountingFirm = 1 and Partner.Id = @CompanyId and MM.Shortcode <> 'AUC' and MM.IsMainCursor=1 and CM.Status=1

 

    Union ALL    -- Partner Company with Audit Cursor & its Subsidory Companies    

 

    Select Partner.Id PartnerId, Partner.Name Partner, null EntityId, '' Entity, MM.Shortcode [Cursor], MM.Heading ModuleName, Subsidory.Id ServiceEntityId, Subsidory.Name ServiceEntity
    From Common.Company Partner
    Inner Join Common.CompanyModule CM on CM.CompanyId =Partner.Id
    Inner Join Common.ModuleMaster MM on CM.ModuleId=MM.id 
    Inner Join Common.Company Subsidory On Subsidory.ParentId = Partner.Id
    Inner Join Audit.AuditCompany AuditCompany On AuditCompany.ServiceCompanyId = Subsidory.Id
    Where Partner.IsAccountingFirm = 1 and Partner.Id = @CompanyId and MM.Shortcode = 'AUC' and MM.IsMainCursor=1 and CM.Status=1

 

    Union ALL    -- Parent Company with Other Cursors (except Audit)

 

    Select null PartnerId, ''  Partner, Parent.Id EntityId, Parent.Name Entity, MM.Shortcode [Cursor], MM.Heading ModuleName, Null ServiceEntityId,'' ServiceEntity
    From Common.Company Parent
    Inner Join Common.CompanyModule CM on CM.CompanyId =Parent.Id
    Inner Join Common.ModuleMaster MM on CM.ModuleId=MM.id 
    Where COALESCE(Parent.IsAccountingFirm,0) = 0 and Coalesce(Parent.AccountingFirmId,0)=0  and Parent.Id = @CompanyId and MM.Shortcode <> 'AUC' and MM.IsMainCursor=1 and CM.Status=1

 

    Union ALL    -- Parent Company with Audit Cursor & Subsidory Companies list

 

    Select null PartnerId, ''  Partner, Parent.Id EntityId, Parent.Name Entity, MM.Shortcode [Cursor], MM.Heading ModuleName, Subsidory.Id ServiceEntityId, Subsidory.Name ServiceEntity
    From Common.Company Parent
    Inner Join Common.CompanyModule CM on CM.CompanyId =Parent.Id
    Inner Join Common.ModuleMaster MM on CM.ModuleId=MM.id 
    Inner Join Common.Company Subsidory On Subsidory.ParentId = Parent.Id
    Inner Join Audit.AuditCompany AuditCompany On AuditCompany.ServiceCompanyId = Subsidory.Id
    Where COALESCE(Parent.IsAccountingFirm,0) = 0  And Coalesce(Parent.AccountingFirmId,0)=0 and Parent.Id = @CompanyId and MM.Shortcode = 'AUC' and MM.IsMainCursor=1 and CM.Status=1 and Parent.AccountingFirmId is null

 

 ----   Union ALL    -- Only Entity Company with Audit Cursor & Subsidory Companies list
    
 --   --Select Partner.Id PartnerId, Partner.Name Partner, Parent.Id EntityId, Parent.Name Entity, 'AUC' [Cursor], 'Audit Cursor' ModuleName, Subsidory.Id ServiceEntityId, Subsidory.Name ServiceEntity
 --   --From Common.Company Partner
 --   --Inner Join Common.Company Parent On Parent.AccountingFirmId = Partner.id
 --   --Inner Join Common.Company Subsidory On Subsidory.ParentId = Parent.Id
 --   --Inner Join Audit.AuditCompany AuditCompany On AuditCompany.ServiceCompanyId = Subsidory.Id
 --   --Where Partner.IsAccountingFirm = 1 and Parent.Id = @CompanyId

 

    Union ALL    -- Only Entity Company with Other Cursors
    
    Select Partner.Id PartnerId, Partner.Name Partner, Parent.Id EntityId, Parent.Name Entity, MM.Shortcode [Cursor], MM.Heading ModuleName, Null ServiceEntityId, '' ServiceEntity
    From Common.Company Partner
    Inner Join Common.Company Parent On Parent.AccountingFirmId = Partner.id
    Inner Join Common.CompanyModule CM on CM.CompanyId =Parent.Id
    Inner Join Common.ModuleMaster MM on CM.ModuleId=MM.id
    Where Partner.IsAccountingFirm = 1 and Parent.Id = @CompanyId and  MM.IsMainCursor=1 and CM.Status=1

 

) Structure

 

Order by Structure.Partner, Structure.Entity, Structure.[Cursor], Structure.ServiceEntity 
End


GO
