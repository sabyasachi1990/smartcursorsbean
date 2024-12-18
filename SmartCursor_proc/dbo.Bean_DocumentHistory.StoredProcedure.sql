USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_DocumentHistory]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE      procedure [dbo].[Bean_DocumentHistory]
(@BCDocumentHistoryType DocumentHistoryTableType ReadOnly)
As
Begin
	Declare	@StateChangedDate Datetime
	Set @StateChangedDate=GETUTCDATE()
	Declare @ErrorMessage Nvarchar(4000)
	Declare @DocuemntId UniqueIdentifier
	Declare @TransactionId UniqueIdentifier
	Declare @DocumentState Nvarchar(50)
	Declare @OldDocumentState Nvarchar(50)
	Declare @DocType NVarchar(50)
	Declare @CompanyId BigInt
	Declare @toatalCount int
	Declare @count int=1
	Declare @DocAppAmount money, @BaseAppAmount money

	Declare @Temp table (sno int identity(1,1), companyId BigInt, docId uniqueidentifier, transcId uniqueidentifier, docType nvarchar(50), docSubType nvarchar(50),docState nvarchar(50), docCurrency nvarchar(10), docAmount money, docBalnce money, exchangeRate decimal(15,10), baseAmount money, BaseBalance money,stateChangeBy nvarchar(500), stateChangeDate datetime2(7), remarks nvarchar(500), postingDate datetime2(7), docAppliedAmount money,baseAppliedAmount money, agingState nvarchar(50))

	Insert Into @Temp (transcId,CompanyId,docId,DocType,DocSubType,DocState,DocCurrency,DocAmount,docBalnce,ExchangeRate,BaseAmount,BaseBalance,stateChangeBy,stateChangeDate,Remarks,PostingDate,docAppliedAmount,baseAppliedAmount,agingState)
	Select [TransactionId],[CompanyId],[DocumentId],[DocType],[DocSubType],[DocState],[DocCurrency],[DocAmount],[DocBalanaceAmount],[ExchangeRate],[BaseAmount],[BaseBalanaceAmount],[StateChangedBy],@StateChangedDate,Remarks,[PostingDate],DocAppliedAmount as docAppliedAmount,BaseAppliedAmount as baseAppliedAmount,null From @BCDocumentHistoryType

	--Set @DocAppAmount=(select docAppliedAmount  from @BCDocumentHistoryType)
	--Set @BaseAppAmount=(select baseAppliedAmount  from @BCDocumentHistoryType)

	--Declare doc_history Cursor for (select * from @BCDocumentHistoryType)
	--Open doc_history
	--FETCH NEXT FROM doc_history into @document
	SET @toatalCount= (select Count(*)  from @Temp)
	WHILE (@count<=@toatalCount) 
    BEGIN -- Cursor Loop Begin
		BEGIN TRY
			Select @CompanyId=CompanyId,@DocuemntId=docId,@TransactionId=transcId,@DocumentState=DocState,@DocType=DocType from @Temp where sno=@count
			--Set @DocAppAmount=(select docAppliedAmount  from @Temp where sno=@count)
			--Set @BaseAppAmount=(select baseAppliedAmount  from @Temp where sno=@count)

			IF(@DocType In ('Invoice','Credit Note','Debit Note','Bill','Credit Memo','Debt Provision'))
			BEGIN
				IF EXISTS(Select Id from Bean.DocumentHistory(nolock) where CompanyId=@CompanyId and DocumentId=@DocuemntId and TransactionId=@TransactionId)
				BEGIN
				    SET @OldDocumentState=(Select DocState from Bean.DocumentHistory(nolock) where CompanyId=@CompanyId and DocumentId=@DocuemntId and TransactionId=@TransactionId and (AgingState<>'Deleted' or AgingState is null) and DocState=@DocumentState)
					IF(@TransactionId=@DocuemntId)
					BEGIN
						IF(@OldDocumentState=@DocumentState)
						BEGIN
							Update Bean.DocumentHistory WITH (ROWLOCK) set AgingState='Deleted' where CompanyId=@CompanyId and DocumentId=@DocuemntId and TransactionId=@TransactionId and DocState=@DocumentState
							Insert Into Bean.DocumentHistory (Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,Remarks,PostingDate,DocAppliedAmount,BaseAppliedAmount,AgingState)
							Select Newid(),transcId,[CompanyId],docId,[DocType],[DocSubType],[DocState],[DocCurrency],[DocAmount],docBalnce,[ExchangeRate],[BaseAmount],BaseBalance,stateChangeBy,@StateChangedDate,Remarks,CASE WHEN docState='Void' THEN null ELSE [PostingDate] END,     CASE WHEN docState='Void' THEN 0 ELSE docAppliedAmount END as DocAppliedAmount,CASE WHEN docState='Void' THEN 0 ELSE baseAppliedAmount END as BaseAppliedAmount,[AgingState] From @Temp where sno=@count
						END
						ELSE
						BEGIN
							Insert Into Bean.DocumentHistory (Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,Remarks,PostingDate,DocAppliedAmount,BaseAppliedAmount,AgingState)
							Select Newid(),transcId,[CompanyId],docId,[DocType],[DocSubType],[DocState],[DocCurrency],[DocAmount],docBalnce,[ExchangeRate],[BaseAmount],BaseBalance,stateChangeBy,@StateChangedDate,Remarks,CASE WHEN docState='Void' THEN null ELSE [PostingDate] END,     CASE WHEN docState='Void' THEN 0 ELSE docAppliedAmount END as DocAppliedAmount,CASE WHEN docState='Void' THEN 0 ELSE baseAppliedAmount END as BaseAppliedAmount,[AgingState] From @Temp where sno=@count
						END
					END
					ELSE
					BEGIN
						--Set @OldDocumentState=(select DocState from Bean.DocumentHistory where CompanyId=@CompanyId and DocumentId=@DocuemntId and TransactionId=@TransactionId)
						IF(@DocType In ('Invoice','Debit Note','Debt Provision') and @DocumentState='Reset')
						Begin
							Insert Into Bean.DocumentHistory (Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,Remarks,PostingDate,DocAppliedAmount,BaseAppliedAmount,AgingState)
							Select Newid(),transcId,[CompanyId],docId,[DocType],[DocSubType], remarks As DocumentState,[DocCurrency],[DocAmount],docBalnce,[ExchangeRate],[BaseAmount],BaseBalance,stateChangeBy,@StateChangedDate,null,[PostingDate] As PostingDate, docAppliedAmount as DocAppliedAmount, baseAppliedAmount as BaseAppliedAmount,[AgingState] From @Temp where sno=@count
						End
						Else
						Begin
							IF(@OldDocumentState=@DocumentState)
							BEGIN
								Update Bean.DocumentHistory WITH (ROWLOCK) set AgingState='Deleted' where CompanyId=@CompanyId and DocumentId=@DocuemntId and TransactionId=@TransactionId --and DocState=@DocumentState
								Insert Into Bean.DocumentHistory (Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,Remarks,PostingDate,DocAppliedAmount,BaseAppliedAmount,AgingState)
								Select Newid(),transcId,[CompanyId],docId,[DocType],[DocSubType],[DocState],[DocCurrency],[DocAmount],docBalnce,[ExchangeRate],[BaseAmount],BaseBalance,stateChangeBy,@StateChangedDate,Remarks,CASE WHEN docState='Void' THEN null ELSE [PostingDate] END,     CASE WHEN docState='Void' THEN 0 ELSE docAppliedAmount END as DocAppliedAmount,CASE WHEN docState='Void' THEN 0 ELSE baseAppliedAmount END as BaseAppliedAmount,[AgingState] From @Temp where sno=@count
							END
							ELSE
							BEGIN
								Update Bean.DocumentHistory WITH (ROWLOCK) set AgingState='Deleted' where CompanyId=@CompanyId and DocumentId=@DocuemntId and TransactionId=@TransactionId --and DocState=@DocumentState
								Insert Into Bean.DocumentHistory (Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,Remarks,PostingDate,DocAppliedAmount,BaseAppliedAmount,AgingState)
								Select Newid(),transcId,[CompanyId],docId,[DocType],[DocSubType],[DocState],[DocCurrency],[DocAmount],docBalnce,[ExchangeRate],[BaseAmount],BaseBalance,stateChangeBy,@StateChangedDate,Remarks,CASE WHEN docState='Void' THEN null ELSE [PostingDate] END,     CASE WHEN docState='Void' THEN 0 ELSE docAppliedAmount END as DocAppliedAmount,CASE WHEN docState='Void' THEN 0 ELSE baseAppliedAmount END as BaseAppliedAmount,[AgingState] From @Temp where sno=@count
							END

						End
					END
				END
				ELSE
				BEGIN
					Insert Into Bean.DocumentHistory (Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,Remarks,PostingDate,DocAppliedAmount,BaseAppliedAmount,AgingState)
					Select Newid(),transcId,[CompanyId],docId,[DocType],[DocSubType],[DocState],[DocCurrency],[DocAmount],docBalnce,[ExchangeRate],[BaseAmount],BaseBalance,stateChangeBy,@StateChangedDate,Remarks,CASE WHEN docState='Void' THEN null ELSE [PostingDate] END,     CASE WHEN docState='Void' THEN 0 ELSE docAppliedAmount END as DocAppliedAmount,CASE WHEN docState='Void' THEN 0 ELSE baseAppliedAmount END as BaseAppliedAmount,[AgingState] From @Temp where sno=@count
				END
			END
			ELSE
			BEGIN
				Insert Into Bean.DocumentHistory (Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,Remarks,PostingDate,DocAppliedAmount,BaseAppliedAmount,AgingState)
				Select Newid(),transcId,[CompanyId],docId,[DocType],[DocSubType],[DocState],[DocCurrency],[DocAmount],docBalnce,[ExchangeRate],[BaseAmount],BaseBalance,stateChangeBy,@StateChangedDate,Remarks,CASE WHEN docState='Void' THEN null ELSE [PostingDate] END,     CASE WHEN docState='Void' THEN 0 ELSE docAppliedAmount END as DocAppliedAmount,CASE WHEN docState='Void' THEN 0 ELSE baseAppliedAmount END as BaseAppliedAmount,[AgingState] From @Temp where sno=@count
			END

									 
		END TRY
		BEGIN CATCH
			Set @ErrorMessage=(Select ERROR_MESSAGE())
			RaisError (@ErrorMessage,16,1)
		END CATCH
		SET @count +=1;
	END
	--CLOSE doc_history
	--DEALLOCATE doc_history
			   					
End	
GO
