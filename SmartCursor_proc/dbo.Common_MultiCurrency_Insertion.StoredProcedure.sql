USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_MultiCurrency_Insertion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec Common_MultiCurrency_Insertion 2980,'SGD',''
Create   procedure [dbo].[Common_MultiCurrency_Insertion]

@CompanyId int,
@BaseCurrency nvarchar(20),
@UserCreated nvarchar(100)
As 
Begin
Declare @ErrorMessage nvarchar(3000)
Declare @MaxId bigint
Declare @CreatedDate datetime=GetUtcDate()
Declare @Revaluation bit =0
Declare @Status int=1
Declare @BeanStatus int 

	Begin try
		Begin transaction
		If Not Exists (Select Id from Bean.MultiCurrencySetting where CompanyId=@CompanyId)
		Begin
			SET @MaxId= (Select MAX(ID)+1 from Bean.MultiCurrencySetting MC(nolock))
			Select @MaxId
			Insert into Bean.MultiCurrencySetting values
			( @MaxId,@CompanyId,@BaseCurrency,@Revaluation,@Status,@UserCreated,@CreatedDate,NULL,NULL)

			--Select @MaxId as Id,@CompanyId as CompanyId,@BaseCurrency as BaseCurrency,@Revaluation as Revaluation,@Status as Status,@UserCreated as UserCreated,@CreatedDate as CreatedDate,Null as ModifiedDate,Null as ModifiedBy from Bean.MultiCurrencySetting

			SET @BeanStatus=(Select Status from Common.CompanyModule where ModuleId=(Select Id from Common.ModuleMaster where Name='Bean Cursor') and CompanyId=@CompanyId)
			Select @BeanStatus
			IF @BeanStatus=1
			Begin
				EXEC Bean_MultiCurrency_COA_Add @CompanyId
			END
		END
		commit transaction
	End try
	Begin Catch
		Rollback
		Select @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1)
	End Catch

End


--Select * from Bean.MultiCurrencySetting where CompanyId=1
GO
