USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Delete_Transaction_History]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [dbo].[Bean_Delete_Transaction_History]

@Listofids nvarchar(MAX)/*uniqueidentifier*/, --> 1,2,3
@Companyid bigint,
@Doctype nvarchar(100),
@DocSubType nvarchar(100),
@Deletedby nvarchar(250)

AS
Begin
DECLARE  @ErrorMessage  NVARCHAR(4000), 
			 @ErrorSeverity INT, 
			 @ErrorState    INT;
Begin Try
Begin Transaction ---Begin the Transaction


--Declare @Void INT
--Declare @Count INT
--Declare @RecCount INT
--Declare @Id uniqueidentifier
Declare @Deleteddate DateTime2(7)=GetUTCDate()
--Declare @SaveTable Table (Id uniqueidentifier,LeastOfId uniqueidentifier,DocNo nvarchar(50),Companyid BigInt,Doctype nvarchar(100),Deletedby nvarchar(200),Deleteddate DateTime)
Declare @Temp Table (SNo Int Identity(1,1),Id uniqueidentifier)
Insert Into @Temp
Select Distinct items from dbo.SplitToTable(@Listofids,',')


	IF(@Doctype IN ('Invoice','Credit Note','Debt Provision') AND @DocSubType NOT IN ('Application','Allocation'))
	Begin
			IF NOT Exists (Select Id From Bean.Invoice (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void' )
			Begin
				--SET @Void=0
					IF Exists ( Select Id From Bean.Invoice (NOLOCK) Where ID IN (Select Id From @Temp) AND Nature='Interco' AND DocType='Invoice' AND DocumentState = 'Void')
					 Begin

						 Insert InTo Common.DeleteLog
						 Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.Bill (NOLOCK) Where PayrollId IN (Select Id From @Temp) AND DocumentState = 'Void'


						Delete DH From Bean.DocumentHistory DH 
								  Inner Join Bean.Bill B (NOLOCK) On B.Id=DH.DocumentId Where B.PayrollId IN (Select Id from @Temp )
						Delete JD From Bean.JournalDetail JD 
								  Inner Join Bean.Bill B (NOLOCK) On B.Id=JD.DocumentId Where B.PayrollId IN (Select Id from @Temp )
						Delete J From Bean.Journal J
								  Inner Join Bean.Bill B (NOLOCK) On B.Id=J.DocumentId Where B.PayrollId IN (Select Id from @Temp )
						Delete BD From Bean.BillDetail BD
								  Inner Join Bean.Bill B (NOLOCK) On B.Id=BD.BillId Where B.PayrollId IN (Select Id from @Temp )
						Delete From Bean.Bill Where PayrollId IN (Select Id from @Temp )


					 END
					 if(@Doctype ='Credit Note')
					 Begin
						If Exists(Select Id from Bean.CreditNoteApplication (NOLOCK) where InvoiceId in (Select Id From @Temp))
						Begin
							
							-- return the error inside the CATCH block
							RAISERROR ('Please proceed to delete the application before deletion of the Credit Note',16,1);
						End
					 End
					 if(@Doctype = 'Debt Provision')
					 Begin
						If Exists(Select Id from Bean.DoubtfulDebtAllocation (NOLOCK) where InvoiceId in (Select Id From @Temp))
						Begin
							
							-- return the error inside the CATCH block
							RAISERROR ('Please proceed to delete the allocation before deletion of the Debt Provision',16,1);
						End
					 End

					  IF Exists (Select Id From Bean.Invoice (NOLOCK) Where ID IN (Select Id From @Temp) AND Nature='Interco' AND DocType='Credit Note' AND DocumentState = 'Void')
					   Begin
						   Insert InTo Common.DeleteLog
						   Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.CreditMemo (NOLOCK) Where ParentInvoiceID IN (Select Id From @Temp) AND DocumentState = 'Void'

						   Delete DH From Bean.DocumentHistory DH 
								  Inner Join Bean.CreditMemo C (NOLOCK) On C.Id=DH.DocumentId Where C.ParentInvoiceID IN (Select Id from @Temp )
						   Delete JD From Bean.JournalDetail JD 
								  Inner Join Bean.CreditMemo C (NOLOCK) On C.Id=JD.DocumentId Where C.ParentInvoiceID IN (Select Id from @Temp )
						   Delete J From Bean.Journal J
								  Inner Join Bean.CreditMemo C (NOLOCK) On C.Id=J.DocumentId Where C.ParentInvoiceID IN (Select Id from @Temp )
						   Delete CD From Bean.CreditMemoDetail CD
								  Inner Join Bean.CreditMemo C (NOLOCK) On C.Id=CD.CreditMemoId Where C.ParentInvoiceID IN (Select Id from @Temp )
						   Delete From Bean.CreditMemo Where ParentInvoiceID IN (Select Id from @Temp )
					
                       END
				
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.Invoice (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState = 'Void'

				If (@Doctype ='Invoice')
				Begin
					Delete from Bean.InvoiceNote where InvoiceId In (Select Id from @Temp )
				End
				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.InvoiceDetail Where InvoiceId IN (Select Id from @Temp )
				Delete From Bean.Invoice Where Id IN (Select Id from @Temp )
				
				

			END

	END

	

	

	IF(@Doctype IN ('Debit Note'))
	Begin
			IF NOT Exists (Select Id From Bean.DebitNote (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void')
			Begin
				--SET @Void=0
					IF Exists ( Select Id From Bean.DebitNote (NOLOCK) Where ID IN (Select Id From @Temp) AND Nature='Interco'  AND DocumentState = 'Void')
						 Begin

						 Insert InTo Common.DeleteLog
						 Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.Bill (NOLOCK) Where PayrollId IN (Select Id From @Temp) AND DocumentState = 'Void'

						 
						 Delete DH From Bean.DocumentHistory DH 
								   Inner Join Bean.Bill B (NOLOCK) On B.Id=DH.DocumentId Where B.PayrollId IN (Select Id from @Temp )
						 Delete JD From Bean.JournalDetail JD 
								   Inner Join Bean.Bill B (NOLOCK) On B.Id=JD.DocumentId Where B.PayrollId IN (Select Id from @Temp )
						 Delete J From Bean.Journal J
								   Inner Join Bean.Bill B (NOLOCK) On B.Id=J.DocumentId Where B.PayrollId IN (Select Id from @Temp )
						 Delete BD From Bean.BillDetail BD
								   Inner Join Bean.Bill B (NOLOCK) On B.Id=BD.BillId Where B.PayrollId IN (Select Id from @Temp )
						 Delete From Bean.Bill Where PayrollId IN (Select Id from @Temp )

						
					 END


				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.DebitNote (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState = 'Void'

				Delete from Bean.DebitNoteNote where DebitNoteId In (Select Id from @Temp )
				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.DebitNoteDetail Where DebitNoteId IN (Select Id from @Temp )
				Delete From Bean.DebitNote Where Id IN (Select Id from @Temp )
			END
	END


	IF(@Doctype IN ('Cash Sale'))
	Begin
			IF NOT Exists (Select Id From Bean.CashSale (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void')
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.CashSale (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState = 'Void'

				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.CashSaleDetail Where CashSaleId IN (Select Id from @Temp )
				Delete From Bean.CashSale Where Id IN (Select Id from @Temp )
			END
	END

	IF(@Doctype IN ('Receipt'))
	Begin
			IF NOT Exists (Select Id From Bean.Receipt (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void')
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.Receipt (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState = 'Void'

				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.ReceiptBalancingItem Where ReceiptId IN (Select Id from @Temp )
				Delete From Bean.ReceiptDetail Where ReceiptId IN (Select Id from @Temp )
				Delete From Bean.Receipt Where Id IN (Select Id from @Temp )
			END
	END

	IF(@Doctype IN ('Credit Note') AND @DocSubType IN ('Application'))
	Begin
			IF NOT Exists (Select Id From Bean.CreditNoteApplication (NOLOCK) Where ID IN (Select Id From @Temp) AND Status <> 2)
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,CreditNoteApplicationNumber,@Deletedby,@Deleteddate From Bean.CreditNoteApplication (NOLOCK) Where ID IN (Select Id From @Temp) AND Status = 2

				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.ReceiptBalancingItem Where ReceiptId IN (Select Id from @Temp )
				Delete From Bean.CreditNoteApplicationDetail Where CreditNoteApplicationId IN (Select Id from @Temp )
				Delete From Bean.CreditNoteApplication Where Id IN (Select Id from @Temp )
			END
	END

	IF(@Doctype IN ('Debt Provision') AND @DocSubType IN ('Allocation'))
	Begin
			IF NOT Exists (Select Id From Bean.DoubtfulDebtAllocation (NOLOCK) Where ID IN (Select Id From @Temp) AND Status <> 2)
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,DoubtfulDebtAllocationNumber,@Deletedby,@Deleteddate From Bean.DoubtfulDebtAllocation (NOLOCK) Where ID IN (Select Id From @Temp) AND Status = 2

				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.ReceiptBalancingItem Where ReceiptId IN (Select Id from @Temp )
				Delete From Bean.DoubtfulDebtAllocationDetail Where DoubtfulDebtAllocationId IN (Select Id from @Temp )
				Delete From Bean.DoubtfulDebtAllocation Where Id IN (Select Id from @Temp )
			END
	END

	IF(@Doctype IN ('Bill'))
	Begin
			IF NOT Exists (Select Id From Bean.Bill (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void')
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.Bill (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState = 'Void'

				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.BillDetail Where BillId IN (Select Id from @Temp )
				Delete From Bean.Bill Where Id IN (Select Id from @Temp )
			END
	END

	IF(@Doctype IN ('Bill Payment'))
	Begin
			IF NOT Exists (Select Id From Bean.Payment (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void')
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.Payment (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState = 'Void'

				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.PaymentDetail Where PaymentId IN (Select Id from @Temp )
				Delete From Bean.Payment Where Id IN (Select Id from @Temp )
			END
	END

	IF(@Doctype IN ('Credit Memo') AND @DocSubType NOT IN ('Application','Allocation'))
	Begin
			IF NOT Exists (Select Id From Bean.CreditMemo (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void')
			Begin

				if(@Doctype ='Credit Memo')
				Begin
					If Exists(Select Id from Bean.CreditMemoApplication (NOLOCK) where CreditMemoId in (Select Id From @Temp))
					Begin
							
								-- return the error inside the CATCH block
						RAISERROR ('Please proceed to delete the application before deletion of the Credit Memo',16,1);
					End
				End
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.CreditMemo (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState = 'Void'

				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.CreditMemoDetail Where CreditMemoId IN (Select Id from @Temp )
				Delete From Bean.CreditMemo Where Id IN (Select Id from @Temp )
			END
	END

	IF(@Doctype IN ('Credit Memo') AND @DocSubType  IN ('Application'))
	Begin
			IF NOT Exists (Select Id From Bean.CreditMemoApplication (NOLOCK) Where ID IN (Select Id From @Temp) AND Status <> 2)
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,CreditMemoApplicationNumber,@Deletedby,@Deleteddate From Bean.CreditMemoApplication (NOLOCK) Where ID IN (Select Id From @Temp) AND Status = 2

				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.CreditMemoApplicationDetail Where CreditMemoApplicationId IN (Select Id from @Temp )
				Delete From Bean.CreditMemoApplication Where Id IN (Select Id from @Temp )
			END
	END	

	IF(@Doctype IN ('Cash Payment','Deposit','Withdrawal'))
	Begin
			IF NOT Exists (Select Id From Bean.WithDrawal (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void')
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.WithDrawal (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState = 'Void'

				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.WithDrawalDetail Where WithdrawalId IN (Select Id from @Temp )
				Delete From Bean.WithDrawal Where Id IN (Select Id from @Temp )
			END
	END	


	IF(@Doctype IN ('Transfer'))
	Begin
			IF NOT Exists (Select Id From Bean.BankTransfer (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void')
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.BankTransfer (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState = 'Void'

				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.SettlementDetail Where BankTransferId IN (Select Id from @Temp )
				Delete From Bean.BankTransferDetail Where BankTransferId IN (Select Id from @Temp )
				Delete From Bean.BankTransfer Where Id IN (Select Id from @Temp )
			END
	END	

	IF(@Doctype IN ('Bank Reconciliation'))
	Begin
			IF NOT Exists (Select Id From Bean.BankReconciliation (NOLOCK) Where ID IN (Select Id From @Temp) AND State <> 'Void')
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,null,@Deletedby,@Deleteddate From Bean.BankReconciliation (NOLOCK) Where ID IN (Select Id From @Temp) AND State = 'Void'

				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.BankReconciliationDetail Where BankReconciliationId IN (Select Id from @Temp )
				Delete From Bean.BankReconciliation Where Id IN (Select Id from @Temp )
			END
	END	

	IF(@Doctype IN ('Journal'))
	Begin
			IF NOT Exists (Select Id From Bean.Journal (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void')
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.Journal (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState = 'Void'	
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
			END
	END	

	IF(@Doctype IN ('Clearing'))
	Begin
			IF NOT Exists (Select Id From Bean.GLClearing (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void')
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,DocNo,@Deletedby,@Deleteddate From Bean.GLClearing (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState = 'Void'

				
				Delete From Bean.GLClearingDetail Where GLClearingId IN (Select Id from @Temp )
				Delete From Bean.GLClearing Where Id IN (Select Id from @Temp )
			END
	END	
	IF(@Doctype IN ('Revaluation'))
	Begin
			IF NOT Exists (Select Id From Bean.BankTransfer (NOLOCK) Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void')
			Begin
				--SET @Void=0
				Insert InTo Common.DeleteLog
				Select NewId(),@Companyid,@Doctype,Id,SystemRefNo,@Deletedby,@Deleteddate From Bean.Revalution (NOLOCK) Where ID IN (Select Id From @Temp) AND DocState = 'Void'

				Delete From Bean.DocumentHistory Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.JournalDetail Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.Journal Where DocumentId IN (Select Id from @Temp )
				Delete From Bean.RevalutionDetail Where RevalutionId IN (Select Id from @Temp )
				Delete From Bean.Revalution Where Id IN (Select Id from @Temp )
			END
	END
 Commit Transaction 		
 End Try
 Begin Catch
	Rollback Transaction
		SELECT 
        @ErrorMessage = ERROR_MESSAGE(), 
        @ErrorSeverity = ERROR_SEVERITY(), 
        @ErrorState = ERROR_STATE();
 
		-- return the error inside the CATCH block
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
 End Catch
END

--Select * from Bean.CreditMemoApplication Where CompanyId=1 and Status<>'2'

--Select * from Bean.GLClearing Where CompanyId=1

--Select * from Bean.DocumentHistory Where CompanyId=1 AND DocType='Bank Reconciliation'
--Select * from Bean.BankReconciliationDetail

--IF(@Doctype IN ('Debit Note'))
--	Begin
--	IF Exists (Select Id From Bean.DebitNote Where ID IN (Select Id From @Temp) AND DocumentState <> 'Void')
--	Begin
--		SET @Void=0
--	END
--	END
--	------------------------------
--	IF (@Void=1)
--	Begin

--		SET @Count=(Select Count(*) From @Temp )
--		SET @RecCount=1

--			While @Count>=@RecCount

--				Begin 
--					SET @Id= (Select Id From @Temp Where SNo=@RecCount)

--						IF(@Doctype IN ('Invoice','Credit Note','Debt Provision'))
--							Begin
							
		

--							END




--	SET @RecCount=@RecCount+1
--END

--	END






--IF(@Doctype IN ('Invoice','Credit Note','Debt Provision'))

--If ( 


--@LinstOfIds  DocumentStatus  is 'Void' )

-----then
----Delete
--Select * from Bean.DocumentHistory--Documentid
--Select * from Bean.JournalDetail--Documentid
--Select * from Bean.Journal--DocumentId
--Select * from Bean.InvoiceDetail --InvoiceId
--Select * from Bean.Invoice --ID---Id In (select Distinct items from dbo.SplitToTable(@Listofids,','))

----Insert Deleted records in New table

----NewId,@Listofids,DocNo,Companyid,@Doctype,@Deletedby,@Deleteddate

--Else 

----Through Validation


--select Distinct items from dbo.SplitToTable(@Listofids,',')


--======================================================================================================


--Permission scripts need to execute
GO
