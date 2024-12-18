USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[Disconnect_Xero]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Common].[Disconnect_Xero](@connectionId uniqueidentifier, @subCompanyId bigint, @parentCompanyId bigint,@organisationId uniqueIdentifier)
As
Begin
	delete from Common.XeroConnection where ConnectionId=@connectionId
	delete from Common.XeroAuthTokenStore where SubCompanyId=@subCompanyId
	delete from Common.XeroOrganisation where SubCompanyId=@subCompanyId
	delete from common.XeroCOADetail where id in (select coad.Id from common.XeroCOADetail as coad join common.XeroCOA as coa on coad.XeroCOAId=coa.Id where coa.CompanyId=@subCompanyId and coa.OrganisationId=@organisationId)
	delete from common.XeroTaxCodeDetail where id in (select coad.Id from common.XeroTaxCodeDetail as coad join common.XeroTaxCodes as coa on coad.XeroTaxCodeId=coa.Id where coa.CompanyId=@subCompanyId and coa.OrganisationId=@organisationId)

	if not exists(select * from Common.XeroAuthTokenStore where CompanyId=@subCompanyId)
	BEGIN
		delete from Common.XeroAuthTokenStore where CompanyId=@subCompanyId
	END
	update Common.CompanyFeatures set IsConfigured= case when (select COUNT(*) from Common.XeroOrganisation where CompanyId=@parentCompanyId)>= 1 then 1 else 0 end, IsChecked = case when (select COUNT(*) from Common.XeroOrganisation where CompanyId =@parentCompanyId)>= 1 then 1 else 0 end where CompanyId=@parentCompanyId and FeatureId = (select Id from Common.Feature where Name='Xero')
END
GO
