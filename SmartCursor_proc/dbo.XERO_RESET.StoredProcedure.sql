USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[XERO_RESET]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[XERO_RESET]
as
begin
delete from Common.XeroCOADetail
delete from Common.XeroTaxCodeDetail
delete from Common.XeroAccountTypeDetail

delete from Common.XeroCOA 
delete from Common.XeroTaxCodes
delete from Common.XeroAccountType where CompanyId != 0

delete from Common.XeroTokenStore
delete from Common.XeroAuthTokenStore
delete from Common.XeroConnection

delete from Common.XeroOrganisation
end
GO
