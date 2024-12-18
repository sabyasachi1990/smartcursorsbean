USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SiteCollectionVaidation]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Procedure [dbo].[Proc_SiteCollectionVaidation](@NEW_COMPANY_ID bigint)
AS Begin
    Declare @Partnervalue nvarchar(100),@PartnerCompanyName nvarchar(100),@ActiveId bigint,@PartnerCompanyId bigint;


    set @ActiveId=(select top 1 CompanyId from Common.CompanyModule where companyId=@NEW_COMPANY_ID and ModuleId In (3,7) and Status=1)
    If @ActiveId Is not null OR @ActiveId !=''
        Begin
           
           Set @PartnerCompanyId=(select AccountingFirmId from Common.Company where Id=@NEW_COMPANY_ID)
            If @PartnerCompanyId IS Not NULL 
                Begin 
                    set @Partnervalue =(select Name from Common.Company where IsAccountingFirm=1 and Id=@PartnerCompanyId)
                    IF @Partnervalue Is not Null OR @Partnervalue!=''
                    Begin
                        set @PartnerCompanyName =@Partnervalue;
                    End 
                    Else
                    Begin
                        set @PartnerCompanyName =Null;
                    End
                END
             else
                Begin
                        set @PartnerCompanyName =NULL;
                END 
        END
    else
        Begin        
              set @PartnerCompanyName =NULL;                
        END 
    select @PartnerCompanyName
End
GO
