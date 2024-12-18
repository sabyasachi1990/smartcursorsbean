USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_DocumentHistory_OptimizedProcedure]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[Bean_DocumentHistory_OptimizedProcedure] (@BCDocumentHistoryType DocumentHistoryTableType ReadOnly)
AS
BEGIN
DECLARE @DHTime Nvarchar(100)
SET @DHTime = (SELECT 'Bean_DocumentHistory StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @DHTime;

	DECLARE @StateChangedDate DATETIME

	SET @StateChangedDate = GETUTCDATE()

	DECLARE @ErrorMessage NVARCHAR(4000)
	DECLARE @DocuemntId UNIQUEIDENTIFIER
	DECLARE @TransactionId UNIQUEIDENTIFIER
	DECLARE @DocumentState NVARCHAR(50)
	DECLARE @OldDocumentState NVARCHAR(50)
	DECLARE @DocType NVARCHAR(50)
	DECLARE @CompanyId BIGINT
	DECLARE @toatalCount INT
	DECLARE @count INT = 1
	DECLARE @DocAppAmount MONEY, @BaseAppAmount MONEY
	
	CREATE TABLE #Temp  
		(	sno INT identity(1, 1), companyId BIGINT, docId UNIQUEIDENTIFIER, transcId UNIQUEIDENTIFIER, docType NVARCHAR(50), docSubType NVARCHAR(50), 
			docState NVARCHAR(50), docCurrency NVARCHAR(10), docAmount MONEY, docBalnce MONEY, exchangeRate DECIMAL(15, 10), baseAmount MONEY, BaseBalance MONEY, 
			stateChangeBy NVARCHAR(500), stateChangeDate DATETIME2(7), remarks NVARCHAR(500), postingDate DATETIME2(7), docAppliedAmount MONEY, baseAppliedAmount MONEY,
			agingState NVARCHAR(50)
		)

	CREATE TABLE #InsertTable 
	(
		Id uniqueidentifier,TransactionId uniqueidentifier,CompanyId bigint,DocumentId uniqueidentifier,DocType nvarchar(50),DocSubType nvarchar(20),
		DocState nvarchar(20),DocCurrency nvarchar(10),DocAmount money,DocBalanaceAmount money,ExchangeRate decimal(15,10),BaseAmount money,
		BaseBalanaceAmount money,StateChangedBy nvarchar(50),StateChangedDate datetime2,Remarks nvarchar(508),PostingDate datetime2,
		DocAppliedAmount money,BaseAppliedAmount money,AgingState nvarchar(50)
	)

	CREATE TABLE #UpdateTable (Id Uniqueidentifier)

	INSERT INTO #Temp (transcId, CompanyId, docId, DocType, DocSubType, DocState, DocCurrency, DocAmount, docBalnce, ExchangeRate, BaseAmount, BaseBalance, stateChangeBy, stateChangeDate, Remarks, PostingDate, docAppliedAmount, baseAppliedAmount, agingState)
	SELECT [TransactionId], [CompanyId], [DocumentId], [DocType], [DocSubType], [DocState], [DocCurrency], [DocAmount], [DocBalanaceAmount], [ExchangeRate], [BaseAmount], [BaseBalanaceAmount], [StateChangedBy], @StateChangedDate, Remarks, [PostingDate], DocAppliedAmount AS docAppliedAmount, BaseAppliedAmount AS baseAppliedAmount, NULL
	FROM @BCDocumentHistoryType
	
	SET @toatalCount = ( SELECT COUNT(*) FROM #Temp )

	DECLARE @DocumentHistory TABLE (Id Uniqueidentifier, AgingState Nvarchar(100), DocState Nvarchar(50))
	SET @DHTime = (SELECT 'While Loop StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
	PRINT @DHTime;
	
	WHILE (@count <= @toatalCount)
	BEGIN -- Cursor Loop Begin
		
			SELECT @CompanyId = CompanyId, @DocuemntId = docId, @TransactionId = transcId, @DocumentState = DocState, @DocType = DocType
			FROM #Temp
			WHERE sno = @count

			INSERT INTO @DocumentHistory (Id,AgingState,DocState)
			SELECT Id,AgingState,DocState FROM Bean.DocumentHistory (NOLOCK)
			WHERE CompanyId = @CompanyId AND DocumentId = @DocuemntId AND TransactionId = @TransactionId

			IF (@DocType IN ('Invoice', 'Credit Note', 'Debit Note', 'Bill', 'Credit Memo', 'Debt Provision'))
			BEGIN
				IF EXISTS (SELECT Id FROM @DocumentHistory)
				BEGIN
					SET @OldDocumentState = (SELECT DocState FROM @DocumentHistory WHERE (AgingState <> 'Deleted' OR AgingState IS NULL) AND DocState = @DocumentState)

					IF (@TransactionId = @DocuemntId)
					BEGIN
						--IF(@OldDocumentState = @DocumentState)
						--BEGIN
						INSERT INTO #UpdateTable
						SELECT Id FROM @DocumentHistory 
						WHERE DocState = @DocumentState  AND @OldDocumentState = @DocumentState
							--AND @TransactionId = @DocuemntId

						INSERT INTO #InsertTable (Id, TransactionId, CompanyId, DocumentId, DocType, DocSubType, DocState, DocCurrency, DocAmount, DocBalanaceAmount, ExchangeRate, BaseAmount, BaseBalanaceAmount, StateChangedBy, StateChangedDate, Remarks, PostingDate, DocAppliedAmount, BaseAppliedAmount, AgingState)
						SELECT Newid(), transcId, [CompanyId], docId, [DocType], [DocSubType], [DocState], [DocCurrency], [DocAmount], docBalnce, [ExchangeRate], [BaseAmount], BaseBalance, stateChangeBy, @StateChangedDate, Remarks, CASE WHEN docState = 'Void' THEN NULL ELSE [PostingDate] END, CASE WHEN docState = 'Void' THEN 0 ELSE docAppliedAmount END AS DocAppliedAmount, CASE WHEN docState = 'Void' THEN 0 ELSE baseAppliedAmount END AS BaseAppliedAmount, [AgingState]
						FROM #Temp
						WHERE sno = @count  AND @OldDocumentState = @DocumentState
							--AND @TransactionId = @DocuemntId

						--END
						--ELSE
						--BEGIN
						INSERT INTO #InsertTable (Id, TransactionId, CompanyId, DocumentId, DocType, DocSubType, DocState, DocCurrency, DocAmount, DocBalanaceAmount, ExchangeRate, BaseAmount, BaseBalanaceAmount, StateChangedBy, StateChangedDate, Remarks, PostingDate, DocAppliedAmount, BaseAppliedAmount, AgingState)
						SELECT Newid(), transcId, [CompanyId], docId, [DocType], [DocSubType], [DocState], [DocCurrency], [DocAmount], docBalnce, [ExchangeRate], [BaseAmount], BaseBalance, stateChangeBy, @StateChangedDate, Remarks, CASE WHEN docState = 'Void' THEN NULL ELSE [PostingDate] END, CASE WHEN docState = 'Void' THEN 0 ELSE docAppliedAmount END AS DocAppliedAmount, CASE WHEN docState = 'Void' THEN 0 ELSE baseAppliedAmount END AS BaseAppliedAmount, [AgingState]
						FROM #Temp
						WHERE sno = @count
							AND @OldDocumentState != @DocumentState
							--AND @TransactionId = @DocuemntId
						--END
					END
					ELSE
					BEGIN
						IF (@DocType IN ('Invoice', 'Debit Note', 'Debt Provision') AND @DocumentState = 'Reset')
						BEGIN
							INSERT INTO #InsertTable (Id, TransactionId, CompanyId, DocumentId, DocType, DocSubType, DocState, DocCurrency, DocAmount, DocBalanaceAmount, ExchangeRate, BaseAmount, BaseBalanaceAmount, StateChangedBy, StateChangedDate, Remarks, PostingDate, DocAppliedAmount, BaseAppliedAmount, AgingState)
							SELECT Newid(), transcId, [CompanyId], docId, [DocType], [DocSubType], remarks AS DocumentState, [DocCurrency], [DocAmount], docBalnce, [ExchangeRate], [BaseAmount], BaseBalance, stateChangeBy, @StateChangedDate, NULL, [PostingDate] AS PostingDate, docAppliedAmount AS DocAppliedAmount, baseAppliedAmount AS BaseAppliedAmount, [AgingState]
							FROM #Temp
							WHERE sno = @count
								--AND @DocType IN ('Invoice', 'Debit Note', 'Debt Provision') AND @DocumentState = 'Reset'
						END
						ELSE
						BEGIN
						 
							--IF(@OldDocumentState = @DocumentState)
							--BEGIN
							INSERT INTO #UpdateTable
							SELECT Id FROM @DocumentHistory
							WHERE @OldDocumentState = @DocumentState

							INSERT INTO #InsertTable (Id, TransactionId, CompanyId, DocumentId, DocType, DocSubType, DocState, DocCurrency, DocAmount, DocBalanaceAmount, ExchangeRate, BaseAmount, BaseBalanaceAmount, StateChangedBy, StateChangedDate, Remarks, PostingDate, DocAppliedAmount, BaseAppliedAmount, AgingState)
							SELECT Newid(), transcId, [CompanyId], docId, [DocType], [DocSubType], [DocState], [DocCurrency], [DocAmount], docBalnce, [ExchangeRate], [BaseAmount], BaseBalance, stateChangeBy, @StateChangedDate, Remarks, CASE WHEN docState = 'Void' THEN NULL ELSE [PostingDate] END, CASE WHEN docState = 'Void' THEN 0 ELSE docAppliedAmount END AS DocAppliedAmount, CASE WHEN docState = 'Void' THEN 0 ELSE baseAppliedAmount END AS BaseAppliedAmount, [AgingState]
							FROM #Temp
							WHERE sno = @count AND @OldDocumentState = @DocumentState

							--END
							--ELSE
							--BEGIN
							INSERT INTO #UpdateTable
							SELECT Id FROM @DocumentHistory 
							--WHERE CompanyId = @CompanyId AND DocumentId = @DocuemntId AND TransactionId = @TransactionId 

							INSERT INTO #InsertTable (Id, TransactionId, CompanyId, DocumentId, DocType, DocSubType, DocState, DocCurrency, DocAmount, DocBalanaceAmount, ExchangeRate, BaseAmount, BaseBalanaceAmount, StateChangedBy, StateChangedDate, Remarks, PostingDate, DocAppliedAmount, BaseAppliedAmount, AgingState)
							SELECT Newid(), transcId, [CompanyId], docId, [DocType], [DocSubType], [DocState], [DocCurrency], [DocAmount], docBalnce, [ExchangeRate], [BaseAmount], BaseBalance, stateChangeBy, @StateChangedDate, Remarks, CASE WHEN docState = 'Void' THEN NULL ELSE [PostingDate] END, CASE WHEN docState = 'Void' THEN 0 ELSE docAppliedAmount END AS DocAppliedAmount, CASE WHEN docState = 'Void' THEN 0 ELSE baseAppliedAmount END AS BaseAppliedAmount, [AgingState]
							FROM #Temp
							WHERE sno = @count AND @OldDocumentState != @DocumentState
								--END
						END
					END
				END
				ELSE
				BEGIN
					INSERT INTO #InsertTable (Id, TransactionId, CompanyId, DocumentId, DocType, DocSubType, DocState, DocCurrency, DocAmount, DocBalanaceAmount, ExchangeRate, BaseAmount, BaseBalanaceAmount, StateChangedBy, StateChangedDate, Remarks, PostingDate, DocAppliedAmount, BaseAppliedAmount, AgingState)
					SELECT Newid(), transcId, [CompanyId], docId, [DocType], [DocSubType], [DocState], [DocCurrency], [DocAmount], docBalnce, [ExchangeRate], [BaseAmount], BaseBalance, stateChangeBy, @StateChangedDate, Remarks, CASE WHEN docState = 'Void' THEN NULL ELSE [PostingDate] END, CASE WHEN docState = 'Void' THEN 0 ELSE docAppliedAmount END AS DocAppliedAmount, CASE WHEN docState = 'Void' THEN 0 ELSE baseAppliedAmount END AS BaseAppliedAmount, [AgingState]
					FROM #Temp
					WHERE sno = @count
				END
			END
			ELSE
			BEGIN
				INSERT INTO #InsertTable (Id, TransactionId, CompanyId, DocumentId, DocType, DocSubType, DocState, DocCurrency, DocAmount, DocBalanaceAmount, ExchangeRate, BaseAmount, BaseBalanaceAmount, StateChangedBy, StateChangedDate, Remarks, PostingDate, DocAppliedAmount, BaseAppliedAmount, AgingState)
				SELECT Newid(), transcId, [CompanyId], docId, [DocType], [DocSubType], [DocState], [DocCurrency], [DocAmount], docBalnce, [ExchangeRate], [BaseAmount], BaseBalance, stateChangeBy, @StateChangedDate, Remarks, CASE WHEN docState = 'Void' THEN NULL ELSE [PostingDate] END, CASE WHEN docState = 'Void' THEN 0 ELSE docAppliedAmount END AS DocAppliedAmount, CASE WHEN docState = 'Void' THEN 0 ELSE baseAppliedAmount END AS BaseAppliedAmount, [AgingState]
				FROM #Temp
				WHERE sno = @count
			END
			
			DELETE FROM @DocumentHistory

		SET @count += 1;
	END
	SET @DHTime = (SELECT 'While Loop EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
	PRINT @DHTime;

	BEGIN TRANSACTION
	BEGIN TRY
	SET @DHTime = (SELECT 'Update and Insert StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
	PRINT @DHTime;
	--SELECT * FROM #UpdateTable
	UPDATE A SET AgingState = 'Deleted'
	FROM Bean.DocumentHistory AS A
	INNER JOIN #UpdateTable AS B ON B.Id = A.Id
	
	SET @DHTime = (SELECT CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
	PRINT @DHTime;

	INSERT INTO Bean.DocumentHistory (Id, TransactionId, CompanyId, DocumentId, DocType, DocSubType, DocState, DocCurrency, DocAmount, DocBalanaceAmount, ExchangeRate, BaseAmount, BaseBalanaceAmount, StateChangedBy, StateChangedDate, Remarks, PostingDate, DocAppliedAmount, BaseAppliedAmount, AgingState)
	SELECT Id, TransactionId, CompanyId, DocumentId, DocType, DocSubType, DocState, DocCurrency, DocAmount, DocBalanaceAmount, ExchangeRate, BaseAmount, BaseBalanaceAmount, StateChangedBy, StateChangedDate, Remarks, PostingDate, DocAppliedAmount, BaseAppliedAmount, AgingState
	FROM #InsertTable

	SET @DHTime = (SELECT 'Update and Insert EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
	PRINT @DHTime;
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK;
		SET @ErrorMessage = ( SELECT ERROR_MESSAGE())
		RAISERROR (@ErrorMessage, 16, 1)
	END CATCH

	DROP TABLE #Temp
	DROP TABLE #InsertTable
	DROP TABLE #UpdateTable
	

SET @DHTime = (SELECT 'Bean_DocumentHistory EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @DHTime;	

END
GO
