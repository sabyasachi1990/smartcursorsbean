USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Currency_Insertion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create   proc [dbo].[Bean_Currency_Insertion]
@companyId bigint, --new company id
@CurrencyId bigint, --Zero Company currencyId
@UserCreated varchar(100)
as
begin
--Local Variables
Declare @CurrencyCode varchar(20) -- Current Currency Code
Declare @Id bigint
Declare @RecOrder bigint	
Declare @NewStatus int
Declare @ErrorMessage Nvarchar(4000)

	Begin Try
	Begin Transaction
		--Currency Code based on CurrencyId
		Select @CurrencyCode = Code from bean.Currency(nolock) where Id = @CurrencyId
		--Checking Currency Code exists for new company or not
		if not exists(select Code from bean.Currency(NoLock) where CompanyId = @companyId and Code = @CurrencyCode)
			Begin
				set @RecOrder = (select max(RecOrder)+1 from Bean.Currency(nolock) where companyId = @companyId)
				set @Id = (select max(Id)+1 from bean.Currency(NoLock))
				set @NewStatus = 1 
			  --Inserting Currency record for new company
				insert into bean.currency
					select @id,Code,@companyId,Name,@RecOrder,@NewStatus,@UserCreated,GetUTCDate(),ModifiedBy,ModifiedDate,DefaultValue
						from Bean.Currency where CompanyId = 0 and Code = @CurrencyCode	
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
