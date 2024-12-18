USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_BCInvoice_State_To_WFInvoice]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Bean_BCInvoice_State_To_WFInvoice]
@DocumentId Uniqueidentifier,
@State Varchar(50),
@Amount Money,
@CompanyId Bigint,
@BaseBalanceAmount Money
As
Begin
	If @State='Partial Paid'
		Begin
			Set @State='Partially paid'
		End
	Declare @ModifiedBy Nvarchar(20)='System'	
	Declare @Currentdate Datetime2=GetUtcDate()
	Declare @ERROR_MESSAGE Nvarchar(4000)
	Begin Transaction
	Begin try
		If Exists (Select ID From WorkFlow.Invoice Where Id= @DocumentId)
		Begin

			Update WorkFlow.Invoice Set OutStandingBalanceFee=@Amount,BalanceFee=@Amount,
			[State]=@State,ModifiedBy=@ModifiedBy,ModifiedDate=@Currentdate,BaseOutStandingBalanceFee=@BaseBalanceAmount Where CompanyId=@CompanyId And Id=@DocumentId
			
			Insert Into WorkFlow.InvoiceStatusChange (Id,CompanyId,InvoiceId,State,ModifiedBy,ModifiedDate)
				Values(Newid(),@CompanyId,@DocumentId,@State,@ModifiedBy,@Currentdate)
		End
		Commit Transaction;
		
	End Try
	Begin Catch
		Rollback;
		Select @ERROR_MESSAGE=ERROR_MESSAGE();
		RAISERROR (@ERROR_MESSAGE,16,1);

	End Catch
End
GO
