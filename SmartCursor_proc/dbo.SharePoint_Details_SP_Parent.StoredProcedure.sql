USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SharePoint_Details_SP_Parent]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--Exec [dbo].[SharePoint_Details_SP_Parent] 1371,'tst'

CREATE Procedure [dbo].[SharePoint_Details_SP_Parent]
@CompanyId Bigint,
@Environment Nvarchar(64)
As
Begin
    If @Environment IS Null
    Begin
        Set @Environment='TST'
    End
    ELSE IF @Environment = 'PRD'
    BEGIN
      SET @Environment=''
    END
	
    Declare @dummyCompanyId bigint;
	Select @dummyCompanyId=CompanyId from Common.ExternalConfiguration where CompanyId=@CompanyId and ExternalType='Office 365'
	if(@dummyCompanyId is null or @dummyCompanyId='') 
	begin 
	    select @CompanyId=AccountingFirmId from Common.Company where id=@CompanyId
		Select Case When Len(EX.CompanyId)<3 Then RIGHT('00'+Cast(EX.CompanyId As varchar(50)),3) Else Cast(EX.CompanyId As varchar(50)) End As CompanyId,EX.TenantId, EX.ClientId, EX.Secret, EX.AdminEmail, EX.DomainName,
            EXD.SPOAdminUrl, EXD.ParentSiteUrl, EXD.CertUrl, EXD.CertPassword, EXD.CertValidity, EXD.AdminEmailId, Concat('SmartCursors',@Environment) As SmartCursorsSite
    From Common.Externalconfigurationdetail EXD With (NOlock)
    Inner Join Common.Externalconfiguration EX With (NOlock) On Ex.Id = EXD.ExternalconfigurationId   Where EX.CompanyId=@CompanyId and Ex.ExternalType='Office 365' and EXD.Type='SharePoint'
  
	end
	else
	begin
    Select Case When Len(EX.CompanyId)<3 Then RIGHT('00'+Cast(EX.CompanyId As varchar(50)),3) Else Cast(EX.CompanyId As varchar(50)) End As CompanyId,EX.TenantId, EX.ClientId, EX.Secret, EX.AdminEmail, EX.DomainName,
            EXD.SPOAdminUrl, EXD.ParentSiteUrl, EXD.CertUrl, EXD.CertPassword, EXD.CertValidity, EXD.AdminEmailId, Concat('SmartCursors',@Environment) As SmartCursorsSite
    From Common.Externalconfigurationdetail EXD With (NOlock)
    Inner Join Common.Externalconfiguration EX With (NOlock) On Ex.Id = EXD.ExternalconfigurationId
    Where EX.CompanyId=@CompanyId and Ex.ExternalType='Office 365' and EXD.Type='SharePoint'
  
	end
End
GO
