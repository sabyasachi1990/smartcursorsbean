USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_WFInvoice_State_To_BCInvoice]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Bean_WFInvoice_State_To_BCInvoice]
@WFInvoiceId Uniqueidentifier,
@State Varchar(50),
@CompanyId Bigint
As
Begin
	
	Declare @Currentdate Datetime2=Getdate()
	Declare @ModifiedBy Nvarchar(20)='System'
	Declare @Void Varchar(10)='Void'
	Declare @NotPaid Varchar(10)='Not Paid'
	Declare @BCInvoiceId Uniqueidentifier
	Declare @ERROR_MESSAGE Nvarchar(4000)
	Declare @EntityId Uniqueidentifier
	Begin Transaction
		Begin try
			
			If Exists (Select Id From Bean.Invoice Where DocumentId=@WFInvoiceId And CompanyId=@CompanyId And DocumentState =@NotPaid ) And @State=@Void 
			Begin
				Set @BCInvoiceId=(Select id From Bean.Invoice Where DocumentId=@WFInvoiceId)
				Set @EntityId=(Select EntityId From Bean.Invoice Where DocumentId=@WFInvoiceId)
				Update Bean.Invoice Set DocumentState=@State,ModifiedBy=@ModifiedBy,ModifiedDate=@Currentdate,DocNo=CONCAT(DocNo,'-V') Where CompanyId=@CompanyId And DocumentId=@WFInvoiceId
				Update Bean.Journal Set DocumentState=@State,ModifiedBy=@ModifiedBy,ModifiedDate=@Currentdate,DocNo=CONCAT(DocNo,'-V') Where DocumentId=@BCInvoiceId And CompanyId=@CompanyId

				 If Not Exists(Select Id from Bean.DocumentHistory where DocumentId=(Select Id from Bean.Invoice where DocumentId=@WFInvoiceId) And CompanyId=@CompanyId And DocState=@Void )
				   Begin
                      Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate)
                       
					       Select NEWID(),Id,CompanyId,Id,DocType,DocSubType,@Void,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,@ModifiedBy,GETUTCDATE() From Bean.Invoice Where DocumentId=@WFInvoiceId
                     End

             Exec [dbo].[Bean_Update_CustBalance_and_CreditLimit] @CompanyId, @EntityId
			End
			Else
			Begin
				--Rollback;
				Set @ERROR_MESSAGE='Invalid State'
				RAISERROR(@ERROR_MESSAGE,16,1);
			End
			Commit Transaction
		End Try
		Begin Catch
			Rollback;
			If @ERROR_MESSAGE Is Null
			Begin
				Select @ERROR_MESSAGE=ERROR_MESSAGE()
			End
			RAISERROR(@ERROR_MESSAGE,16,1);
		End Catch
End

GO
