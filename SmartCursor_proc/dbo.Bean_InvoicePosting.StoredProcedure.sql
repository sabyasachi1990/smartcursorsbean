USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_InvoicePosting]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[Bean_InvoicePosting] 
	@SourceId Uniqueidentifier, @Type Nvarchar(20), @CompanyId Int
AS
BEGIN
	--DECLARE @SourceId UNIQUEIDENTIFIER =  'A6C6CDF8-C8D3-4E91-B7A2-00112A78B281', @Type NVARCHAR(20) = 'Invoice', @CompanyId INT = 2058

	DECLARE @CreationTypeSystem VARCHAR(20) = 'System';

	-- For Customer Balance Updation
	DECLARE @EntityId UNIQUEIDENTIFIER

	-- Document Constants
	DECLARE @InvoiceDocument VARCHAR(20) = 'Invoice'

	-- Nature
	DECLARE @NatureTrade VARCHAR(20) = 'Trade'
	DECLARE @NatureOthers VARCHAR(20) = 'Others'
	DECLARE @NatureInterco VARCHAR(20) = 'Interco'
	-- COA Names
	DECLARE @COATradeReceivables VARCHAR(50) = 'Trade receivables'
	DECLARE @COAotherReceivables VARCHAR(50) = 'Other receivables'
	DECLARE @COATaxPaybleGST VARCHAR(50) = 'Tax payable (GST)'
	DECLARE @Rounding VARCHAR(50) = 'Rounding'

	-- ZeroGUID
	DECLARE @GUIDZero UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'

	-- Local Variables
	DECLARE @JournalId UNIQUEIDENTIFIER, @ErrorMessage NVARCHAR(4000), @Count INT, @RecCount INT, @DetailId UNIQUEIDENTIFIER, @IsAddNote BIT = 0

	--Declare @RecOrder Int
	DECLARE @TaxRate FLOAT, @DocumentId UNIQUEIDENTIFIER, @TaxRecCount INT, @NA CHAR(2) = 'NA'/*, @TaxRecOrder INT = 1, @TypeNumber INT = 0*/
	DECLARE @BCDocumentHistoryType DocumentHistoryTableType

	---------For Interco
	DECLARE @ServiceEntityId BIGINT, @Nature NVARCHAR(20), @ServiceEntityShortName NVARCHAR(100)

	------For Base Debit and Base Credit Mis match
	DECLARE @BaseDebit MONEY, @BaseCredit MONEY, @DiffAmount MONEY, @MasterBaseAmount MONEY, @ExchangeRate DECIMAL(15, 10), @DocSubType NVARCHAR(30)

	------For DocSub Type
	DECLARE @DocSubTypeGeneral NVARCHAR(25) = 'General', @NotAppliedState NVARCHAR(30) = 'Not Applied', @NotPaidState NVARCHAR(50) = 'Not Paid', 
	@NotAllocatedState NVARCHAR(30) = 'Not Allocated'

	-------For Brc Rerun
	DECLARE @OldServEntityId BIGINT,@NewServEntityId BIGINT,@OldCoaId BIGINT,@NewCoaId BIGINT,@OldDocdate DATETIME,@NewDocDate DATETIME,
		@OldDocAmount MONEY,@NewDocAmount MONEY,@IsAdd BIT,@IsBankAccountExists BIT

	------Common Error Message
	DECLARE @InvalidDocumentError NVARCHAR(200) = 'Invalid Document'
	
	---For Customer Balance updation
	DECLARE @OldEntityId UNIQUEIDENTIFIER, @OldCustCreditLimit MONEY
	DECLARE @CustEntId NVARCHAR(max)

	IF (@Type = @InvoiceDocument)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

		DECLARE @Time Nvarchar(100)
		SET @Time = (SELECT 'Invoice Part StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
		PRINT @Time;

		SELECT 
			Id,DocumentId, Nature, CompanyId,DocDate,DocSubType,DocNo,ServiceCompanyId,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency, 
			GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsGstSETtings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,DocType,
			UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocDescription,GrandTotal,IsSegmentReporting,DueDate,EntityId,EntityType,PONo,IsGSTApplied,
			CreditTermsId,BalanceAmount	, BaseGrandTotal, BaseBalanceAmount
		INTO #Invoice 
		FROM Bean.Invoice AS Inv (NOLOCK)
		WHERE CompanyId = @CompanyId AND (Id = @SourceId OR DocumentId = @SourceId /*OR Id = @DocumentId OR IsGstSETtings = 1*/)
	
		SET @Time = (SELECT 'Assigning Data To Variables StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
		PRINT @Time;

		------>>> For Interco posting -- Get Service CompanyId by entityid
		SELECT @DocumentId =  Id FROM #Invoice WHERE DocumentId = @SourceId  
		SELECT @Nature = Nature FROM #Invoice WHERE Id = @SourceId 

			IF(@Nature=@NatureInterco)
			BEGIN
				------>>> For Customer Balance updation we are getting EntityID 
				SET @EntityId=(SELECT EntityId FROM #Invoice WHERE Id=@SourceId)
				SET @ServiceEntityId=(SELECT ServiceEntityId FROM Bean.Entity (NOLOCK) WHERE id=@EntityId AND CompanyId=@CompanyId)
				SET @DocumentId =@SourceId
				SET @ServiceEntityShortName= (SELECT ShortName FROM Common.Company (NOLOCK) WHERE Id=@ServiceEntityId)
			END
			ELSE
			BEGIN
				IF (@DocumentId Is NULL Or @DocumentId='00000000-0000-0000-0000-000000000000')
				BEGIN
					SET @DocumentId=@SourceId
					------>>> For Customer Balance updation we are getting EntityID 
					SET @EntityId = (SELECT EntityId FROM #Invoice WHERE Id=@SourceId)
				END
				ELSE
				BEGIN
					SET @EntityId = (SELECT EntityId FROM #Invoice WHERE DocumentId=@SourceId)
				END
			END

		SET @Time = (SELECT 'Assigning Data To Variables EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
		PRINT @Time;
		-------->>>> ChartOfAccount
		SELECT Id,CompanyId,Name,SubsidaryCompanyId INTO #ChartOfAccount FROM Bean.ChartOfAccount (NOLOCK) 
		WHERE CompanyId = @CompanyId AND (Name = @COATradeReceivables OR Name=@COAotherReceivables OR Name = @COATaxPaybleGST  OR Name = @Rounding OR  
							(SubsidaryCompanyId = @ServiceEntityId AND Name = Concat('I/B - ',@ServiceEntityShortName)))

		IF EXISTS(SELECT TOP 1 Id FROM Bean.Journal (NOLOCK) WHERE CompanyId=@CompanyId AND DocumentId=@DocumentId)
		BEGIN
		
		SET @Time = (SELECT 'Delete From Journal and Journal Detail StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
		PRINT @Time;

			SELECT @OldEntityId = EntityId,@IsAddNote=IsAddNote FROM Bean.Journal (NOLOCK) WHERE CompanyId=@CompanyId AND DocumentId=@DocumentId
					
			DELETE FROM Bean.JournalDetail WHERE DocumentId=@DocumentId AND DocType=@Type
			DELETE FROM Bean.Journal WHERE DocumentId=@DocumentId AND CompanyId=@CompanyId AND DocType=@Type
		SET @Time = (SELECT 'Delete From Journal and Journal Detail EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
		PRINT @Time;
		END
		ELSE
		BEGIN
			-------->>>> For Customer Balance updation we are getting EntityID 
			SET @OldEntityId = @EntityId 
		END

		SET @Time = (SELECT 'Insert Into Journal and Journal Detail StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
		PRINT @Time;				
		-------->>>> Inserting Records Into Journal FROM Invoce 
		SET @JournalId = NEWID()

		INSERT INTO Bean.Journal (Id,CompanyId,DocDate,DocType,DocSubType,DocNo,ServiceCompanyId,SystemReferenceNo,IsNoSupportingDocs,NoSupportingDocument,DocCurrency,ExchangeRate,ExCurrency,GSTExchangeRate,GSTExCurrency,GSTTotalAmount,DocumentState,IsNoSupportingDocument,IsGstSETtings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocumentDescription,CreationType,GrANDDocDebitTotal,GrANDBaseDebitTotal,DueDate,EntityId,EntityType,PoNo,PostingDate,IsGSTApplied,COAId,DocumentId,CreditTermsId,Nature,BalanceAmount,ActualSysRefNo,RefNo,IsSegmentReporting,IsAddNote)
		SELECT @JournalId,CompanyId,DocDate,@Type,DocSubType,DocNo,ServiceCompanyId,DocNo As SystemRefNo,IsNoSupportingDocument,NoSupportingDocs,DocCurrency,ExchangeRate,ExCurrency, GSTExchangeRate,GSTExCurrency,IsNULL(GSTTotalAmount,0),DocumentState,/**/[IsNoSupportingDocument],IsGstSETtings,IsMultiCurrency,IsAllowableNonAllowable,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,DocDescription,@CreationTypeSystem,Round(GrANDTotal,2) As GrANDDocDebitTotal,Round((GrANDTotal*IsNULL(ExchangeRate,1)),2) As GrANDBaseDebitTotal,
				DueDate,EntityId,EntityType,PONo,DocDate As PostingDate,IsGSTApplied,
				CASE WHEN Nature=@NatureTrade THEN (SELECT Id FROM #ChartOfAccount WHERE CompanyId=@CompanyId AND Name=@COATradeReceivables)
						WHEN Nature=@NatureOthers THEN (SELECT Id FROM #ChartOfAccount WHERE CompanyId=@CompanyId AND Name=@COAotherReceivables)
					WHEN Nature=@NatureInterco THEN (SELECT Id FROM #ChartOfAccount WHERE CompanyId=@CompanyId AND SubsidaryCompanyId=@ServiceEntityId AND Name=Concat('I/B - ',@ServiceEntityShortName)) END As COAId,
					Id As Documentid,CreditTermsId,Nature,BalanceAmount,DocNo As ActualSysRefNo,NULL,ISNULL(IsSegmentReporting,0),@IsAddNote as IsAddNote
			FROM #Invoice WHERE Id=@DocumentId

		------>>> CREATE NONCLUSTERED INDEX InvoiceId_InvoiceDetail ON Bean.InvoiceDetail(InvoiceId)
		-------->>>> Invoice Detail
		SELECT 
			Id,InvoiceId, COAId , ItemDescription ,TaxId,TaxRate,DocAmount,DocTaxAmount,BaseAmount, DocTotalAmount,ItemId,ItemCode,RecOrder,BaSETaxAmount,
			TaxIdCode,AllowDisAllow
		INTO #InvoiceDetail  FROM Bean.InvoiceDetail(NOLOCK) 
		WHERE InvoiceId = @DocumentId
		ORDER BY RecOrder

		-------->>>> Inserting Records Into JournalDetail FROM InvoceDetail
		INSERT INTO Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,TaxId,TaxRate,DocDebit,DocCredit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal, DocumentId, DocumentDetailId, ItemId,ItemCode,ItemDescription,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffSETDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaSETaxAmount,BaSETaxCredit,GSTCredit,GSTTaxCredit)
		SELECT 
			NEWID(),@JournalId, InvID.COAId As COAId, InvID.ItemDescription As AccountDescription,InvID.TaxId,InvID.TaxRate,NULL As DocDebit, 
			InvID.DocAmount As DocCredit,InvID.DocTaxAmount,NULL As BaseDebit,InvID.BaseAmount as BaseCredit,'0.00',InvID.DocTotalAmount,NULL,
			NULL,@DocumentId, InvID.Id,InvID.ItemId,InvID.ItemCode,InvID.ItemDescription,Inv.ExCurrency,Inv.ExchangeRate,Inv.GSTExCurrency,
			Inv.GSTExchangeRate,@Type,Inv.DocSubType,Inv.ServiceCompanyId,Inv.DocNo,Inv.Nature,NULL As OffSETDocument,0 As IsTax,Inv.EntityId,
			Inv.DocNo As SystemRefNo,Inv.Remarks,Inv.PONo,0 As CreditTermsId,Inv.DocCurrency,Inv.DocDate,NULL As DocDescription,Inv.DocDate As PostingDate,
			InvID.RecOrder As RecOrder,InvID.DocTaxAmount,InvID.BaSETaxAmount,InvID.BaSETaxAmount,
			ROUND(ISNULL(InvID.DocTaxAmount,0)*IsNULL(Inv.GSTExchangeRate,1),2) as GSTCredit,
			ROUND(ISNULL(InvID.DocAmount,0)*IsNULL(Inv.GSTExchangeRate,1),2) as GSTTaxCredit
		FROM #InvoiceDetail AS InvID
		INNER JOIN #Invoice AS Inv ON Inv.Id = InvID.InvoiceId

		-------->>>> SET @TaxRecCount=@RecCount+@TaxRecOrder ---->>> Do not uncomment the line
		SET @TaxRecCount = (SELECT COUNT(Id) FROM #InvoiceDetail)

		--SELECT @TaxRecCount

		;WITH InvoiceCTE AS (
			SELECT 
				NEWID() AS IdNew,@JournalId as JournalId, (SELECT Id FROM #ChartOfAccount WHERE Name = @COATaxPaybleGST) As COAId,Inv.DocDescription As AccountDescription,InvID.AllowDisAllow,
				InvID.TaxId,InvID.TaxRate,NULL As DocDebit,InvID.DocTaxAmount As DocCredit,'0.00' As DocTaxDebit,'0.00' As DocTaxCredit,NULL As BaseDebit,
				Round(InvID.DocTaxAmount*IsNULL(inv.ExchangeRate,1),2) As BaseCredit,'0.00' As DocDebitTotal,'0.00' As DocCreditTotal,NULL As BaseDebitTotal,
				NULL As BaseCreditTotal,@DocumentId as DocumentId,InvID.Id,@GUIDZero as GUIDZero, Inv.ExCurrency,Inv.ExchangeRate,Inv.GSTExCurrency,Inv.GSTExchangeRate,
				@Type as Type, Inv.DocSubType, Inv.ServiceCompanyId,Inv.DocNo,Inv.Nature,NULL As OffSETDocument,1 As IsTax,Inv.EntityId,Inv.DocNo As SystemRefNo,
				Inv.Remarks,Inv.PONo,NULL As CreditTermsId,Inv.NoSupportingDocs,NULL As BaseAmount,Inv.DocCurrency,Inv.DocDate,NULL As DocDescription,Inv.DocDate as PostingDate,
				ROW_NUMBER() OVER (ORDER BY InvID.ID) + @TaxRecCount AS RecOrder,InvID.DocTaxAmount,
				InvID.BaSETaxAmount
			FROM #InvoiceDetail AS InvID
			INNER JOIN #Invoice AS Inv ON Inv.Id = InvID.InvoiceId
			WHERE Inv.IsGstSETtings = 1 AND InvId.TaxRate IS NOT NULL AND Convert(NVARCHAR(20), InvId.TaxIdCode) <> @NA
		)

		INSERT INTO Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,AllowDisAllow,TaxId,TaxRate,DocDebit,DocCredit,DocTaxDebit,DocTaxCredit,BaseDebit,BaseCredit,DocDebitTotal,DocCreditTotal,BaseDebitTotal,BaseCreditTotal,DocumentId,DocumentDetailId,ItemId,BaseCurrency,ExchangeRate,GSTExCurrency,GSTExchangeRate,DocType,DocSubType,ServiceCompanyId,DocNo,Nature,OffSETDocument,IsTax,EntityId,SystemRefNo,Remarks,PONo,CreditTermsId,NoSupportingDocs,BaseAmount,DocCurrency,DocDate,DocDescription,PostingDate,RecOrder,DocTaxAmount,BaSETaxAmount)
		SELECT * FROM InvoiceCTE

		SELECT @ExchangeRate=ExchangeRate FROM #Invoice WHERE CompanyId=@CompanyId AND Id = @DocumentId
		SELECT @MasterBaseAmount=Cast(Sum(ROUND(ABS(DocAmount)*ISNULL(@ExchangeRate,1),2)+(Round(ABS(IsNULL(DocTaxAmount,0))*ISNULL(@ExchangeRate,1),2)))as money) 
		FROM #InvoiceDetail WHERE InvoiceId=@DocumentId

		SELECT MAX(RecOrder) AS RecOrder, SUM(BaseDebit) as BaseDebit, SUM(BaseCredit) as BaseCredit, ABS(SUM(BaseDebit) - SUM(BaseCredit)) AS Diff  
		INTO #JournalDetail  FROM Bean.JournalDetail--(NOLOCK) 
		WHERE DocumentId = @DocumentId

		------->>>> Inserting Master Records Into JournalDetail FROM Invoce 
		INSERT INTO Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,DocDebit,BaseDebit,DocDebitTotal,BaseDebitTotal,DocumentId,DocumentDetailId,ItemId,DueDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId,CreditTermsId,DocNo,PostingDate,RecOrder,DocumentAmount,Currency,BaseCurrency,IsTax,EntityId,SystemRefNo,Remarks,PONo,BaseAmount,DocCurrency,DocDate,DocDescription,DocCreditTotal)
		SELECT NewId(),@JournalId,
			CASE 
				WHEN Nature=@NatureTrade THEN (SELECT Id FROM #ChartOfAccount WHERE Name=@COATradeReceivables)
				WHEN Nature=@NatureOthers THEN (SELECT Id FROM #ChartOfAccount WHERE Name=@COAotherReceivables) 
				WHEN Nature=@NatureInterco THEN (SELECT Id FROM #ChartOfAccount WHERE SubsidaryCompanyId = @ServiceEntityId AND Name=Concat('I/B - ',@ServiceEntityShortName)) 
			END AS COAId,
			DocDescription,Round(GrANDTotal,2),@MasterBaseAmount,Round(GrANDTotal,2),@MasterBaseAmount As BaseDebitTotal,@DocumentId,@GUIDZero,@GUIDZero,DueDate,
			ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,@Type,DocSubType,ServiceCompanyId,CreditTermsId, DocNo, DocDate,
			(SELECT Recorder+1 FROM #JournalDetail),Round(GrANDTotal,2),
			DocCurrency,ExCurrency,0,EntityId,DocNo,Remarks,PONo,@MasterBaseAmount,DocCurrency,DocDate,DocDescription,'0.00'
		FROM #Invoice
		WHERE Id = @DocumentId

		--DECLARE @InvoiceJournalDetailDiff Money = (SELECT Diff FROM #JournalDetail)

		IF ((SELECT Diff FROM #JournalDetail) >=0.01)
		BEGIN
		
			SELECT @BaseDebit = BaseDebit, @BaseCredit = BaseCredit, @DiffAmount = Diff FROM #JournalDetail --WHERE Diff >= 0.01
			
			INSERT INTO Bean.JournalDetail (Id,JournalId,COAId,AccountDescription,BaseDebit,BaseCredit,DocumentId,DocumentDetailId,ItemId,DocDate,DueDate,PostingDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,ServiceCompanyId, CreditTermsId, DocNo, Currency, BaseCurrency, IsTax, EntityId, SystemRefNo,  DocCurrency, RecOrder,DocDebitTotal,DocCreditTotal)
			SELECT 
				NEWID(), @JournalId, (SELECT Id FROM #ChartOfAccount WHERE CompanyId=@CompanyId AND Name=@Rounding), DocDescription, 
				CASE WHEN @BaseDebit > @BaseCredit THEN NULL ELSE @DiffAmount END as BaseDebit, 
				CASE WHEN @BaseCredit > @BaseDebit THEN NULL ELSE @DiffAmount END as BaseCredit,
				@DocumentId,NEWID(),@GUIDZero,DocDate,DueDate,DocDate,ExchangeRate,GSTExchangeRate,GSTExCurrency,Nature,DocType,DocSubType,
				ServiceCompanyId,CreditTermsId,DocNo, DocCurrency, ExCurrency, 0, EntityId,DocNo, DocCurrency, 
				(SELECT Recorder+1 FROM #JournalDetail ),0,0
			FROM #Invoice
			WHERE CompanyId = @CompanyId AND Id = @DocumentId --AND @InvoiceJournalDetailDiff >= 0.01
		
		END
		SET @Time = (SELECT 'Insert Into Journal and Journal Detail EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
		PRINT @Time;

		SET @Time = (SELECT 'Update Invoice StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
		PRINT @Time;

		------>>>0.01 BaseGrANDTotal AND BaseBalanceAmount updation for Invoice 
		UPDATE Bean.Invoice SET BaseGrandTotal = @MasterBaseAmount ,BaseBalanceAmount = @MasterBaseAmount
		WHERE Id = @DocumentId 	AND CompanyId = @CompanyId  AND @MasterBaseAmount  IS NOT NULL

		SET @Time = (SELECT 'Update InvoiceEndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
		PRINT @Time;

		-- Inserting Records into DocumentHistory Table
		INSERT INTO @BCDocumentHistoryType(TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,PostingDate,DocAppliedAmount,BaseAppliedAmount)
		SELECT 
			@DocumentId,CompanyId,@DocumentId,DocType,DocSubType,DocumentState,DocCurrency,Round(GrANDTotal,2) As DocAmount,
			Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,
			CASE WHEN DocumentState='Not Paid' THEN  @MasterBaseAmount ELSE 0 END As BaseAmount,
			Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,
			CASE WHEN ModifiedBy IS NULL THEN UserCreated ELSE ModifiedBy END,
			CASE WHEN DocumentState='Not Paid' THEN  DocDate ELSE NULL END,
			CASE WHEN DocumentState='Not Paid' THEN  Round(GrANDTotal,2) ELSE 0 END As DocAppliedAmount,
			CASE WHEN DocumentState='Not Paid' THEN  @MasterBaseAmount ELSE 0 END As BaseAppliedAmount 
		FROM #Invoice 
		WHERE Id=@DocumentId
				
		EXEC [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType -------->> Another SP   -------->> Another SP

		SET @CustEntId=@EntityId

		SET @CustEntId = (SELECT CASE 
					WHEN @OldEntityId <> @EntityId THEN Cast(CONCAT ( @OldEntityId ,+ ',' + Cast(@EntityId AS NVARCHAR(200)) ) AS NVARCHAR(200))
					ELSE @EntityId
					END
			)

		EXEC [dbo].[Bean_InvoicePosting_Update_CustBalance_and_CreditLimit] @CompanyId ,@CustEntId  -------->> Another SP

		DROP TABLE  #Invoice
		DROP TABLE  #InvoiceDetail
		DROP TABLE  #ChartOfAccount
		DROP TABLE  #JournalDetail
			
		COMMIT TRANSACTION
		END TRY          
		BEGIN CATCH     
			ROLLBACK;           
			PRINT 'In Catch Block';            
			SELECT ERROR_MESSAGE() AS ErrorMessage, ERROR_NUMBER() AS ErrorNumber;   
			THROW:            
		END CATCH 


		SET @Time = (SELECT 'Invoice Part EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
		PRINT @Time;
	END
END
GO
