USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_TaxCode_Insertion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Bean_TaxCode_Insertion]  
@companyId bigint, --new company id  
@TaxId bigint, --Zero Company currencyId  
@UserCreated varchar(100)  
as  
begin  
--Local Variables  
Declare @TaxCode varchar(20) -- Current Tax Code  
Declare @Id bigint  
Declare @RecOrder bigint   
Declare @NewStatus int  
Declare @ModifiedBy varchar(100) = ''  
Declare @ModifiedDate datetime = NULL  
Declare @ErrorMessage Nvarchar(4000),
		@TaxRate float
  
 Begin Try  
 Begin Transaction  
  --Tax Code based on TaxId  
  Select @TaxCode = Code,@TaxRate=TaxRate from Bean.TaxCode(nolock) where Id = @TaxId  
  --Checking Tax Code exists for new company or not  
  if not exists(select Code from bean.TaxCode(NoLock) where CompanyId = @companyId and Code = @TaxCode AND TaxRate=@TaxRate)  
   Begin 
    set @RecOrder = (select max(RecOrder)+1 from bean.Taxcode(nolock) where companyId = @companyId)  
    set @Id = (select max(Id)+1 from bean.Taxcode(NoLock))  
    set @NewStatus = 1   
     --Inserting Taxcode record for new company  
    insert into bean.Taxcode  
     select @Id,@companyId,Code,Name,Description,AppliesTo,TaxType,TaxRate,EffectiveFrom,IsSystem,@RecOrder,  
     Remarks,@UserCreated,GETUTCDATE(),@ModifiedBy,@ModifiedDate,Version,@NewStatus,TaxRateFormula,IsApplicable,EffectiveTo,  
     XeroTaxName,XeroTaxType,XeroTaxComponentName,XeroTaxRate,IsFromXero,IsSeedData,Jurisdiction  
      from bean.Taxcode where CompanyId = 0 and Code = @TaxCode AND TaxRate=@TaxRate AND Id=@TaxId
   End  
 Commit Transaction  
 End Try  
 Begin Catch  
  RollBack  
  Select @ErrorMessage=ERROR_MESSAGE()  
   RAISERROR(@ErrorMessage,16,1);  
 End Catch  
end  
GO
