USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AuditPartnerCompanyIdForRoles]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




Create   Procedure [dbo].[Proc_AuditPartnerCompanyIdForRoles](@NEW_COMPANY_ID bigint)
AS Begin
    Declare @Partnervalue bigint,@PartnerCompanyId bigint,@ActiveId bigint;


  
		set @ActiveId=(select top 1 CompanyId from Common.CompanyModule where companyId=@NEW_COMPANY_ID and ModuleId In (3,7) and Status=1)
		If @ActiveId Is not null OR @ActiveId !=''
			Begin
			   Set @PartnerCompanyId=(select AccountingFirmId from Common.Company where Id=@ActiveId)
				If @PartnerCompanyId IS NULL 
					Begin 
						set @Partnervalue =(select Id from Common.Company where IsAccountingFirm=1 and Id=@NEW_COMPANY_ID)
						IF @Partnervalue Is not Null OR @Partnervalue!=''
							Begin
								set @PartnerCompanyId =@Partnervalue;
							End 
						Else
							Begin
								set @PartnerCompanyId =@NEW_COMPANY_ID;
							End
					 END
				 ELSE
					 Begin
							set @PartnerCompanyId =@PartnerCompanyId;
					 END 
			END
   
    select @PartnerCompanyId
End
 
 exec [dbo].[Proc_AuditPartnerCompanyIdForRoles] 2550
GO
