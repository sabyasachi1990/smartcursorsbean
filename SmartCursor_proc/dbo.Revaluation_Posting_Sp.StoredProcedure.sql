USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Revaluation_Posting_Sp]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Revaluation_Posting_Sp]
@CompanyId Bigint,
@RevalId Uniqueidentifier,
@Type Nvarchar(100)
AS 
Begin	
	
	--Declare @CompanyId Bigint
	--Declare @RevalId Uniqueidentifier
	Declare @RevalType Nvarchar(100)
	Declare @JournalId Uniqueidentifier
	Declare @RevJournalId Uniqueidentifier
	Declare @DocType Nvarchar(100)='Journal'
	Declare @DocSubType Nvarchar(50)='Reval'
	Declare @BaseCurrency Varchar(50)
	Declare @Count Int
	Declare @RecCount Int=1
	Declare @Reval_COAID BigInt
	Declare @Journal_COAID BigInt
	Declare @AccType_Id BigInt
	Declare @Nature Varchar(25)
	Declare @NetAmt Money
	Declare @CB_Amount Money
	Declare @RevRevaldocNo Nvarchar(200)
	Declare @Error_Msg Nvarchar(Max)
	-- declare temp table to store group by COAID details
	Declare @COAID Table(S_No Int Identity(1,1),COAID BigInt,NetAmount Money)
	-- Getting Basecurrency
	Select @BaseCurrency=BaseCurrency From Common.Localization Where CompanyId=@CompanyId

	Begin Transaction
	Begin Try
		Set @JournalId=NEWID()
		-- Inserting Master record into Journal table
		Insert Into Bean.Journal 
		(Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,IsSegmentReporting,ExchangeRate,ExCurrency,GSTTotalAmount /* 0.00*/
		,DocumentState,IsNoSupportingDocument /* 0 */,IsGstSettings /*-- 0*/,IsMultiCurrency,IsAllowableNonAllowable,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription/*,IsAutoReversalJournal,ReversalDate,ReverseParentRefId,
		ReverseChildRefId*/,CreationType /*-- System*/,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,DueDate,EntityId /*-- 00000000-0000-0000-0000-000000000000*/
		,PostingDate,COAId /*-- 0*/,BankReceiptAmmount /*--0.00*/,BankCharges /*--0.00*/,ExcessPaidByClientAmmount /*-- 0.00*/,BalancingItemReciveCRAmount /*0.00*/,BalancingItemPayDRAmount /*- --0.00*/
		,ReceiptApplicationAmmount /*--0.00*/,DocumentId,IsShow,ActualSysRefNo)
		
		Select @JournalId,@CompanyId,RevalutionDate,@DocType,@DocSubType,SystemRefNo,ServiceCompanyId,SystemRefNo,IsNoSupportingDocument,0 As IsSegmentReporting,ExchangeRate,@BaseCurrency as BaseCurrency,0.00 As GSTTotalAmount
				,DocState,0 As IsNoSupportingDocument,0 As IsGstSettings,1 As IsMultiCurrency,IsAllowableDisAllowable,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,CONCAT('Reval-',Convert(Varchar,RevalutionDate,103)),
				'System',ABS(NetAmount) As GrandDocDebitTotal,ABS(NetAmount) As GrandDocCreditTotal,ABS(NetAmount) As GrandBaseDebitTotal,ABS(NetAmount) As GrandBaseCreditTotal,Null As DueDate,'00000000-0000-0000-0000-000000000000' As EntityId,
				RevalutionDate,0 As COAID,0.00 As BankReceiptAmmount,0.00 As BankCharges,0.00 As ExcessPaidByClientAmmount,0.00 As BalancingItemReciveCRAmount,0.00 As BalancingItemPayDRAmount, 
				0.00 As ReceiptApplicationAmmount,Id,1 As IsShow,SystemRefNo From Bean.Revalution Where Id=@RevalId

		-- Getting COAID and Nature of Exchange gain/loss - Unrealised
		Select @Journal_COAID=Id,@Nature=Nature From Bean.ChartOfAccount Where Name='Exchange gain/loss - Unrealised' And CompanyId=@CompanyId
		-- Getting netamount 
		Select @NetAmt=NetAmount From Bean.Revalution Where CompanyId=@CompanyId And Id=@RevalId

		-- Inserting master record into journaldetail table 
		Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal/*0.00*/,DocCreditTotal/*0.00*/,DocumentId,DocumentDetailId/*00000000-0000-0000-0000-000000000000*/,
									ItemId/*00000000-0000-0000-0000-000000000000*/,BaseCurrency,ExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax /*0*/,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)

		Select NEWID(),@JournalId,@Journal_COAID,CONCAT('Reval-',Convert(Varchar,R.RevalutionDate,103)) As AccDesc,
				Case When @Nature='Credit' And @NetAmt<0 Then ABS(@NetAmt)
					 When @Nature='Debit' And @NetAmt>=0 Then @NetAmt Else Null End As DocDebit,
				Case When @Nature='Credit' And @NetAmt>=0 Then @NetAmt 
					 When @Nature='Debit' And @NetAmt<0 Then ABS(@NetAmt) Else Null End As DocCredit,
				Case When @Nature='Credit' And @NetAmt<0 Then ABS(@NetAmt)
					 When @Nature='Debit' And @NetAmt>=0 Then @NetAmt Else Null End As BaseDebit,
				Case When @Nature='Credit' And @NetAmt>=0 Then @NetAmt 
					 When @Nature='Debit' And @NetAmt<0 Then ABS(@NetAmt) Else Null End As BaseCredit,0.00,0.00,@RevalId,'00000000-0000-0000-0000-000000000000' As DocDtlId,'00000000-0000-0000-0000-000000000000' As ItemId,@BaseCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,SystemRefNo,
						0 As IsTax,'00000000-0000-0000-0000-000000000000' As EntityId,SystemRefNo,Null As DocCurrency,RevalutionDate,RevalutionDate,1 As RecOrder
		From Bean.Revalution As R 
		Where R.CompanyId=@CompanyId And Id=@RevalId

		-- Getting total amount for Cash and bank balances revaluation
		Select @CB_Amount=Sum(UnrealisedExchangegainorlose) From Bean.RevalutionDetail As RD 
		Inner Join Bean.Revalution As R On R.Id=RD.RevalutionId 
		Where RD.IsChecked=1 And IsBankData=1 And CompanyId=@CompanyId And R.Id=@RevalId
		-- Getting COAID of Cash and bank balances revaluation
		Set @Journal_COAID=(Select Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And name='Cash and bank balances revaluation')

		-- Inserting Cash and bank balances revaluation details into journal detail table

		If(@CB_Amount<>0 and @CB_Amount is not Null)
		Begin
			Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
		
		Select NEWID(),@JournalId,@Journal_COAID,CONCAT('Reval-',Convert(Varchar,RevalutionDate,103)) As AccDesc,
				Case When @CB_Amount>=0 Then @CB_Amount Else Null End As DocDebit,
				Case When @CB_Amount<0 Then ABS(@CB_Amount) Else Null End As DocCredit,
				Case When @CB_Amount>=0 Then @CB_Amount Else Null End As BaseDebit,
				Case When @CB_Amount<0 Then ABS(@CB_Amount) Else Null End As BaseCredit,0.00 As DocDebitTotal,0.00 As DocCreditTotal,@RevalId,'00000000-0000-0000-0000-000000000000' As DocumentDetailId,
				'00000000-0000-0000-0000-000000000000' As ItemId,@BaseCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,SystemRefNo,0 As IsTax,'00000000-0000-0000-0000-000000000000' As EntityId,SystemRefNo,Null As DocCurrency,
				RevalutionDate As DocDate,RevalutionDate,2 As RecOrder From Bean.Revalution Where Id=@RevalId and (@CB_Amount<>0 and @CB_Amount is not Null)
		End
		

		-- inserting IsChecked Record group by COAID into temp table
		Insert Into @COAID
		Select COAId,Sum(UnrealisedExchangegainorlose) As NetAmount From Bean.RevalutionDetail As RD 
		Inner Join Bean.Revalution As R On R.Id=RD.RevalutionId
		Where RevalutionId=@RevalId And RD.IsChecked=1 And IsBankData=0
		Group By COAId
		-- Getting count of temp table records
		Select @Count=Count(*) From @COAID
		
		While @Count>=@RecCount
		Begin
			
			Select @Reval_COAID=COAID,@NetAmt=NetAmount From @COAID Where S_No=@RecCount
			Select @AccType_Id=AccountTypeId From Bean.ChartOfAccount As COA Where Id=@Reval_COAID
			Select @Journal_COAID=Id From Bean.ChartOfAccount Where CompanyId=@CompanyId And AccountTypeId=@AccType_Id And IsRevaluation=1
		
			Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal/*0.00*/,DocCreditTotal/*0.00*/,DocumentId,DocumentDetailId/*00000000-0000-0000-0000-000000000000*/,
											ItemId/*00000000-0000-0000-0000-000000000000*/,BaseCurrency,ExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax /*0*/,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
		
			Select NEWID(),@JournalId,@Journal_COAID,CONCAT('Reval-',Convert(Varchar,R.RevalutionDate,103)) As AccDesc,
				Case When @NetAmt>0 Then @NetAmt Else Null End As DocDebit,
				Case When @NetAmt<0 Then ABS(@NetAmt) Else Null End As DocCredit,
				Case When @NetAmt>0 Then @NetAmt Else Null End As BaseDebit,
				Case When @NetAmt<0 Then ABS(@NetAmt) Else Null End BaseCredit,0.00,0.00,@RevalId,'00000000-0000-0000-0000-000000000000' As DocDtlId,'00000000-0000-0000-0000-000000000000' As ItemId,@BaseCurrency,ExchangeRate,@DocType,@DocSubType,ServiceCompanyId,SystemRefNo,
						0 As IsTax,'00000000-0000-0000-0000-000000000000' As EntityId,SystemRefNo,Null As DocCurrency,RevalutionDate,RevalutionDate,(Select MAX(RecOrder) From bean.JournalDetail Where DocumentId=@RevalId) As RecOrder
			From Bean.Revalution As R 
			Where R.CompanyId=@CompanyId And Id=@RevalId

			Set @RecCount=@RecCount+1

		End

		Exec Common_GenerateDocNo @companyId,'Bean Cursor','Journal',0,@RevRevaldocNo out
		Begin
			Set @RevJournalId=NEWID()

			Insert Into Bean.Journal 
			(Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,IsSegmentReporting,ExchangeRate,ExCurrency,GSTTotalAmount /* 0.00*/
			,DocumentState,IsNoSupportingDocument /* 0 */,IsGstSettings /*-- 0*/,IsMultiCurrency,IsAllowableNonAllowable,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,IsAutoReversalJournal,ReversalDate/*,ReverseParentRefId,
			ReverseChildRefId*/,CreationType /*-- System*/,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,DueDate,EntityId /*-- 00000000-0000-0000-0000-000000000000*/
			,PostingDate,COAId /*-- 0*/,BankReceiptAmmount /*--0.00*/,BankCharges /*--0.00*/,ExcessPaidByClientAmmount /*-- 0.00*/,BalancingItemReciveCRAmount /*0.00*/,BalancingItemPayDRAmount /*- --0.00*/
			,ReceiptApplicationAmmount /*--0.00*/,DocumentId,IsShow,ActualSysRefNo)

			Select @RevJournalId,@CompanyId,DATEADD(DD,1,DocDate),DocType,DocSubType,@RevRevaldocNo,ServiceCompanyId,@RevRevaldocNo,IsNoSupportingDocs,IsSegmentReporting,ExchangeRate,ExCurrency,GSTTotalAmount,
					'Reversed' As DocumentState,IsNoSupportingDocument,IsGstSettings,IsMultiCurrency,IsAllowableNonAllowable,UserCreated,GETUTCDATE(),Null,Null,Status,DocumentDescription,1 As IsAutoReversalJournal,DATEADD(DD,1,DocDate),
					CreationType,GrandDocDebitTotal,GrandDocCreditTotal,GrandBaseDebitTotal,GrandBaseCreditTotal,DueDate,EntityId,DATEADD(DD,1,PostingDate),COAId,BankReceiptAmmount,BankCharges,ExcessPaidByClientAmmount,
					BalancingItemReciveCRAmount,BalancingItemPayDRAmount,ReceiptApplicationAmmount,DocumentId,IsShow,@RevRevaldocNo
			From Bean.Journal Where DocumentId=@RevalId And Id=@JournalId



			Insert Into Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,DocCredit,BaseDebit,BaseCredit,DocDebitTotal/*0.00*/,DocCreditTotal/*0.00*/,DocumentId,DocumentDetailId/*00000000-0000-0000-0000-000000000000*/,
										ItemId/*00000000-0000-0000-0000-000000000000*/,BaseCurrency,ExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,IsTax /*0*/,EntityId,SystemRefNo,DocCurrency,DocDate,PostingDate,RecOrder)
			
			Select NEWID(),@RevJournalId,COAId,AccountDescription,DocCredit As DocDebit,DocDebit As DocCredit,BaseCredit As BaseDebit,BaseDebit As Basecredit,DocCreditTotal As DocDebitTotal,DocDebitTotal As DocCreditTotal,DocumentId,DocumentDetailId,
					ItemId,BaseCurrency,ExchangeRate,DocType,DocSubType,ServiceCompanyId,@RevRevaldocNo,IsTax,EntityId,@RevRevaldocNo,DocCurrency,DATEADD(DD,1,DocDate),DATEADD(DD,1,DocDate),RecOrder From Bean.JournalDetail Where DocumentId=@RevalId And JournalId=@JournalId

		End

		Commit Transaction
	End Try
	Begin Catch
		Rollback
		Set @Error_Msg=(Select ERROR_MESSAGE())
		RaisError(@Error_Msg,16,1)

	End Catch

End
GO
