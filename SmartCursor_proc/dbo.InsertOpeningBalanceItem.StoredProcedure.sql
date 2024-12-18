USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[InsertOpeningBalanceItem]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Procedure [dbo].[InsertOpeningBalanceItem]
 (@id uniqueidentifier,@companyId bigint,@COAId Bigint,@userCreated nvarchar(20), @isGstActivated bit, @desc nvarchar(50), @taxId bigint output )
 as 
 Begin
  declare @tId bigint=null
 if (@isGstActivated=1)
	BEGIN
      select @tId=t.Id from Bean.TaxCode as t where t.Code='NA'
	END

--Declare @Date datetime=convert(Nvarchar(20), Getdate(),103)
Insert into Bean.Item(Id,CompanyId,Code,Description,COAId,CreatedDate,UserCreated,IsExternalData, DefaultTaxcodeId)values(@id,@companyId,'Opening Balance',@desc,@COAId,GETDATE(),@userCreated,1, @tId)
set @taxId=@tId
--select Id from Bean.Item Where CompanyId=9 and Code='Opening Balance'
End
GO
