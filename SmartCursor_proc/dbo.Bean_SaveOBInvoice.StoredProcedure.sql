USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_SaveOBInvoice]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [Bean_SaveOBInvoice] 1077,'dd7ba6ce-505d-4955-a122-4bc93ef6579f',1080,1,1

CREATE procedure [dbo].[Bean_SaveOBInvoice]
(@companyId BigInt,
 @openingBalanceId uniqueidentifier,
 @serviceCompanyId bigint,
 @isGstActivated bit,
 @isMultiCurrency bit
)
As 
Begin 


-- Declaring Table Variable To Store OpeningLineItem Id Data
 Declare @temp table (Id uniqueidentifier,DocDate datetime2, ServiceCompanyId BigInt, Description nvarchar(320),BaseCurrency nvarchar(20),
						ExchangeRate decimal, DocDebit money, DocCredit money, BaseDebit money, BaseCredit money,
						DocCurrency nvarchar(20), EntityId uniqueidentifier, CDate datetime2, UserCreated nvarchar(150), 
						ModifiedBy nvarchar(150), ModifiedDate datetime2, ChartId bigint, DocumentRefernceNo nvarchar(100),
						DueDate datetime2)
-- Declaring Table Variable To Store ChartOfAccounts
 Declare @CTemp Table(COAId Bigint,COAName Nvarchar(200))
	Insert Into @CTemp (COAId,COAName)
		Select Id,Name from Bean.ChartOfAccount where CompanyId=@companyId and Name in ('Trade receivables','Other receivables')
 -- Declaring Variables
 Declare @obCoaId bigInt,
		 @obItemId uniqueidentifier,
		 @items uniqueidentifier,
		 @isPossetive bit,
		 @docDebit money,
		 @Count int,
		 @desc nvarchar(320),
		 @taxId bigInt,
		 @Nature varchar(20),
		 @exchRate decimal(15, 10),
		 @postingDate DateTime2(7) 

--Declare @BCDocumentHistoryType DocumentHistoryTableType

 select @obCoaId=c.Id from Bean.ChartOfAccount as c where CompanyId=@companyId and Name='Opening balance'
 
 select @taxId=tax.Id from Bean.TaxCode as tax where Code='NA' AND CompanyId = @CompanyId
 
 --creating
 IF Not Exists(select Id from Bean.Item where CompanyId=@companyId and Code='Opening Balance')
 BEGIN
	Insert into Bean.Item(Id,CompanyId,Code,Description,COAId,CreatedDate,UserCreated,IsExternalData, DefaultTaxcodeId)
	values
	(NEWID(),@companyId,'Opening Balance','Opening Balance-',@obCoaId,GETUTCDATE(),
	(select ob.UserCreated from Bean.OpeningBalance as ob where CompanyId=@companyId and Id=@openingBalanceId),1,
	case when @isGstActivated=1 then @taxId else null END)
 END

 select @obItemId=i.Id from Bean.Item as i where CompanyId=@companyId and Code='Opening Balance'

 SET @postingDate=(Select Date from Bean.OpeningBalance where CompanyId=@companyId and id=@openingBalanceId)

 -- Declare Cursor To Loop OpeningBalanceLineItem Id's
	Declare OBInvoiceSave Cursor For 
	Select LI.Id from Bean.OpeningBalance OB
	Join Bean.OpeningBalanceDetail OBD On OB.Id = OBD.OpeningBalanceId
	Join Bean.OpeningBalanceDetailLineItem LI on OBD.Id = LI.OpeningBalanceDetailId
	Where CompanyId = @companyId AND LI.COAId IN (Select Id From Bean.ChartOfAccount Where CompanyId = @companyId AND Name In ('Trade receivables','Other receivables')) AND LI.ServiceCompanyId = @serviceCompanyId ANd LI.IsProcressed = 0 AND LI.IsEditable = 1 AND OB.IsTemporary = 0
	Open OBInvoiceSave 
	Fetch Next From  OBInvoiceSave Into @Items
	While @@FETCH_STATUS=0
    Begin -- Cursor Loop Begin
	-- Checking Wether Line Item Is Exist Or Not
		Begin Try

		If Exists(Select * from Bean.OpeningBalanceDetailLineItem where Id=@items and IsProcressed=0 and
		ServiceCompanyId=(select op.ServiceCompanyId from Bean.OpeningBalance as op where Id=@openingBalanceId and IsTemporary = 0))
		BEGIN -- Line Item Exist
			Insert into @temp select @items,Date,ServiceCompanyId,Description,BaseCurrency,ExchangeRate,DoCDebit,DocCredit, 
									BaseDebit, BaseCredit, DocumentCurrency, EntityId,CreatedDate,UserCreated,ModifiedBy,ModifiedDate,COAId, DocumentReference,DueDate from Bean.OpeningBalanceDetailLineItem where Id=@items

			SET @exchRate=(select line.ExchangeRate from Bean.OpeningBalanceDetailLineItem as line where Id=@Items)

			SET @desc=(select Case When Description IS not null Then Description Else 
					Concat('Opening balance-',cast (Convert (varchar,DocDate,103 )As varchar) ) End from @temp)

			SET @Nature=(select Case When B.COAName='Trade receivables' Then 'Trade' Else 'Others' End 
						From @temp As A
						Inner Join @CTemp As B On B.COAId=A.ChartId)
			-- Checking Invoice Data Is Exist Or Not
			IF EXISTS (Select Id from Bean.Invoice where Id=@items and CompanyId=@companyId and OpeningBalanceId=@openingBalanceId and DocSubType='Opening Bal')			
			BEGIN -- Invoice Data Exist
					
				Select @docDebit=t.docDebit from @temp as t
				Set @Count=CHARINDEX('-',@docDebit)
				-- Checking Wether Negative Or Possitive
				If @Count=0  
				Begin -- If Possitive
					If Exists(select Id from Bean.Invoice where CompanyId=@companyId and DocType='Credit Note' and Id=@items and DocSubType='Opening Bal' and OpeningBalanceId=@openingBalanceId and DocumentState='Not Applied')
					BEGIN -- CreditNote Is Exist Or Not
						
						Delete from Bean.InvoiceDetail where InvoiceId=@items
						Delete from Bean.Invoice where CompanyId=@companyId and Id=@items and OpeningBalanceId=@openingBalanceId

						

						Insert Into Bean.Invoice(Id,CompanyId,ServiceCompanyId,IsOBInvoice,OpeningBalanceId,DocType,DocSubType,DocDate,UserCreated,DocNo,DocDescription,DocumentState,GrandTotal,BalanceAmount,IsGstSettings,IsMultiCurrency,Nature,IsRepeatingInvoice,Status,DueDate,EntityType,EntityId,DocCurrency,ExchangeRate,GSTExchangeRate,ExCurrency,GSTExCurrency,InternalState,IsAllowableNonAllowable,CreatedDate,InvoiceNumber,BaseGrandTotal,BaseBalanceAmount)
						Select @items,@companyId,ServiceCompanyId,1,@openingBalanceId,'Invoice','Opening Bal',DocDate,'System',DocumentRefernceNo,@desc,
						'Not Paid',DocDebit,DocDebit,@isGstActivated,@isMultiCurrency,@Nature,0,1, 
						DueDate,'Customer',EntityId,DocCurrency,@exchRate,
						Case When DocCurrency=BaseCurrency Then 1.0000000000 Else @exchRate END,
						BaseCurrency,'SGD','Posted',0,GETUTCDATE(),DocumentRefernceNo,BaseDebit,BaseDebit from @temp as t
													 

						 Insert Into Bean.InvoiceDetail (Id,InvoiceId,ItemId,ItemDescription,Qty,Unit,UnitPrice,COAId,TaxId,TaxRate,TaxIdCode,DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder,AmtCurrency)
						 select NEWID(),@items, @obItemId,@desc,1,1,DocDebit,@obCoaId,
						 Case When @isGstActivated=1 then @taxId else null End, null,
						 Case When @isGstActivated=1 then 'NA' else null End,DocDebit,null,DocDebit,BaseDebit,null,BaseDebit,1,DocCurrency
						 from @temp

						 --Delete from DocumentHistoryTable
						Delete from Bean.DocumentHistory where DocumentId=@items

						-- Inserting Records into DocumentHistory Table
						Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) AS DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Invoice Where Id=@items
						--Exec [dbo].[Bean_DocumentHistory] @BCDocumentHistoryType

					END -- CreditNote Is Exist Or Not
					Else 
					Begin -- CreditNote Is Not Exist Or Not
							Update Inv Set Inv.DocDate=Tmp.DocDate,Inv.DueDate=Tmp.DueDate,Inv.DocCurrency=Tmp.DocCurrency,Inv.EntityId=Tmp.EntityId,
							Inv.ExchangeRate=@exchRate,Inv.GSTExchangeRate=Case When Tmp.DocCurrency='SGD' THEN 1.0000000000  ELSE @exchRate END,Inv.GrandTotal=Tmp.DocDebit,Inv.DocNo=Tmp.DocumentRefernceNo,
							Inv.DocDescription=@desc, Inv.IsGstSettings=@isGstActivated,Inv.IsMultiCurrency=@isMultiCurrency,
							Inv.ModifiedBy='System',Inv.ModifiedDate=GETUTCDATE(),Inv.Status=1,Inv.InvoiceNumber=Tmp.DocumentRefernceNo,Inv.Nature=@Nature,Inv.BalanceAmount=Tmp.DocDebit,Inv.BaseGrandTotal=ABS(TMP.BaseDebit),inv.BaseBalanceAmount=ABS(TMP.BaseDebit)								
							From Bean.Invoice As Inv
							Inner Join @temp AS Tmp On Tmp.Id=Inv.Id where OpeningBalanceId=@openingBalanceId and Inv.Id=@items and Inv.CompanyId=@companyId
					
							UPDATE InvDetail set
							InvDetail.DocAmount=ABS(Tmp.DocDebit),InvDetail.UnitPrice=ABS(Tmp.DocDebit),InvDetail.AmtCurrency=Tmp.DocCurrency,
							InvDetail.BaseAmount=ABS(Tmp.BaseDebit),InvDetail.BaseTotalAmount=ABS(Tmp.BaseDebit),InvDetail.DocTotalAmount=ABS(Tmp.DocDebit),InvDetail.ItemDescription=@desc
							from Bean.InvoiceDetail InvDetail inner join @temp as Tmp on Tmp.id=InvDetail.InvoiceId

							-- Inserting Records into DocumentHistory Table
							IF Exists(Select Id from Bean.DocumentHistory where DocumentId=@items AND TransactionId=@openingBalanceId and CompanyId=@companyId)
							BEGIN---If Eidt mode if we are modifying the record
								Update Bean.DocumentHistory set AgingState='Deleted' where CompanyId=@companyId and DocumentId=@items and TransactionId=@openingBalanceId
								Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
								Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) AS DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Invoice Where Id=@items
							END
							ELSE
							BEGIN
								Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
								Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) AS DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Invoice Where Id=@items
							END
					End -- CreditNote Is Exists Or Not
					
				End-- If Possitive
				Else
				Begin -- If Nagative
					If Exists(select Id from Bean.Invoice where CompanyId=@companyId and DocType='Invoice' and Id=@items and DocSubType='Opening Bal' and OpeningBalanceId=@openingBalanceId and DocumentState='Not Paid')
					BEGIN  --If Invoice Exists
						Delete from Bean.InvoiceDetail where InvoiceId=@items
						Delete from Bean.Invoice where CompanyId=@companyId and Id=@items and OpeningBalanceId=@openingBalanceId

						Insert Into Bean.Invoice(Id,CompanyId,ServiceCompanyId,IsOBInvoice,OpeningBalanceId,DocType,DocSubType,DocDate,UserCreated,DocNo,DocDescription,DocumentState,GrandTotal,BalanceAmount,IsGstSettings,IsMultiCurrency,Nature,IsRepeatingInvoice,Status,DueDate,EntityType,EntityId,DocCurrency,ExchangeRate,GSTExchangeRate,ExCurrency,GSTExCurrency,ExtensionType,IsAllowableNonAllowable,InvoiceNumber,CreatedDate,BaseGrandTotal,BaseBalanceAmount)
						Select @items,@companyId,ServiceCompanyId,1,@openingBalanceId,'Credit Note','Opening Bal',DocDate,'System',DocumentRefernceNo,@desc,
						'Not Applied',ABS(DocDebit),ABS(DocDebit),@isGstActivated,@isMultiCurrency,@Nature,0,1, 
						DueDate,'Customer',EntityId,DocCurrency,@exchRate,
						Case When DocCurrency=BaseCurrency Then '1.0000000000' Else @exchRate End,
						BaseCurrency,'SGD','OBCN',0,DocumentRefernceNo,GETUTCDATE(),ABS(BaseDebit),ABS(BaseDebit) from @temp as t

						 Insert Into Bean.InvoiceDetail	(Id,InvoiceId,ItemDescription,Qty,Unit,UnitPrice,COAId,TaxId,TaxRate,TaxIdCode,DocAmount,
						 DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder,AmtCurrency)
						 select NEWID(),@items,@desc,1,1,ABS(DocDebit),@obCoaId,
						 Case When @isGstActivated=1 then @taxId else null End, null,
						 Case When @isGstActivated=1 then 'NA' else null End,ABS(DocDebit),null,ABS(DocDebit),ABS(BaseDebit) ,null,ABS(BaseDebit),1,DocCurrency
						 from @temp

						  --Delete from DocumentHistoryTable
						Delete from Bean.DocumentHistory where DocumentId=@items

						-- Inserting Records into DocumentHistory Table
						Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
						Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) AS DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Invoice Where Id=@items

					END--End of if invoice exists
					ELSE
					BEGIN  --If Invoice Doesn't Exists
						Update Inv Set Inv.DocDate=Tmp.DocDate,Inv.DueDate=Tmp.DueDate,Inv.DocCurrency=Tmp.DocCurrency,Inv.EntityId=Tmp.EntityId,
						Inv.ExchangeRate=@exchRate,Inv.GSTExchangeRate=Case When Tmp.DocCurrency='SGD' THEN 1.0000000000  ELSE @exchRate END,
						Inv.GrandTotal=ABS(Tmp.DocDebit),Inv.DocNo=Tmp.DocumentRefernceNo,
						Inv.DocDescription=@desc, Inv.IsGstSettings=@isGstActivated,Inv.IsMultiCurrency=@isMultiCurrency,
						Inv.ModifiedBy='System',Inv.ModifiedDate=GETUTCDATE(),
						Inv.Status=1,Inv.InvoiceNumber=Tmp.DocumentRefernceNo,Inv.Nature=@Nature,Inv.BalanceAmount=ABS(Tmp.DocDebit),Inv.BaseGrandTotal=ABS(TMP.BaseDebit),inv.BaseBalanceAmount=ABS(TMP.BaseDebit)								
						From Bean.Invoice As Inv
						Inner Join @temp AS Tmp On Tmp.Id=Inv.Id where OpeningBalanceId=@openingBalanceId and Inv.Id=@items and Inv.CompanyId=@companyId
					
						UPDATE InvDetail set
						InvDetail.DocAmount=ABS(Tmp.DocDebit),InvDetail.UnitPrice=ABS(Tmp.DocDebit),InvDetail.AmtCurrency=Tmp.DocCurrency,
						InvDetail.BaseAmount=ABS(Tmp.BaseDebit),InvDetail.BaseTotalAmount=ABS(Tmp.BaseDebit),InvDetail.DocTotalAmount=ABS(Tmp.DocDebit),InvDetail.ItemDescription=@desc
						from Bean.InvoiceDetail InvDetail inner join @temp as Tmp on Tmp.id=InvDetail.InvoiceId

						-- Inserting Records into DocumentHistory Table
							IF Exists(Select Id from Bean.DocumentHistory where DocumentId=@items AND TransactionId=@openingBalanceId and CompanyId=@companyId)
							BEGIN---If Eidt mode if we are modifying the record
								Update Bean.DocumentHistory set AgingState='Deleted' where CompanyId=@companyId and DocumentId=@items and TransactionId=@openingBalanceId
								Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
								Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) AS DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Invoice Where Id=@items
							END
							ELSE
							BEGIN
								Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
								Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) AS DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Invoice Where Id=@items
							END

					END --If Invoice Doesn't Exists
				END -- If Nagative
			--End -- If Nagative
			END -- Invoice Data Exist
			ELSE -- Invoice Data Doesn't Exist
			BEGIN -- Invoice Data Doesn't Exist
				Select @docDebit=t.docDebit from @temp as t
				Set @Count=CHARINDEX('-',@docDebit)
				-- Checking Wether Negative Or Possitive
				If(@Count=0)
				BEGIN-- If Possetive
					Insert Into Bean.Invoice(Id,CompanyId,ServiceCompanyId,IsOBInvoice,OpeningBalanceId,DocType,DocSubType,DocDate,UserCreated,DocNo,DocDescription,DocumentState,GrandTotal,BalanceAmount,IsGstSettings,IsMultiCurrency,Nature,IsRepeatingInvoice,Status,DueDate,EntityType,EntityId,DocCurrency,ExchangeRate,GSTExchangeRate,ExCurrency,GSTExCurrency,InternalState,IsAllowableNonAllowable,CreatedDate,InvoiceNumber,BaseGrandTotal,BaseBalanceAmount)
					Select @items,@companyId,ServiceCompanyId,1,@openingBalanceId,'Invoice','Opening Bal',DocDate,'System',DocumentRefernceNo,@desc,
					'Not Paid',DocDebit,DocDebit,@isGstActivated,@isMultiCurrency,@Nature,0,1, 
					DueDate,'Customer',EntityId,DocCurrency,@exchRate,
					Case When DocCurrency=BaseCurrency Then 1.0000000000 Else @exchRate End,
					BaseCurrency,'SGD','Posted',0,GETUTCDATE(),DocumentRefernceNo,BaseDebit,BaseDebit from @temp as t

					 Insert Into Bean.InvoiceDetail(Id,InvoiceId,ItemId,ItemDescription,Qty,Unit,UnitPrice,COAId,TaxId,TaxRate,TaxIdCode,
					 DocAmount,DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder,AmtCurrency)
					 select NEWID(),@items, @obItemId,@desc,1,1,DocDebit,@obCoaId,
					 Case When @isGstActivated=1 then @taxId else null End, null,
					 Case When @isGstActivated=1 then 'NA' else null End,DocDebit,null,DocDebit,BaseDebit,null,BaseDebit,1,DocCurrency
					 from @temp

					-- Inserting Records into DocumentHistory Table
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) AS DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Invoice Where Id=@items

				END--IF Posetive
				ELSE
				BEGIN --FOR negative Amount
					Insert Into Bean.Invoice(Id,CompanyId,ServiceCompanyId,IsOBInvoice,OpeningBalanceId,DocType,DocSubType,DocDate,UserCreated,DocNo,DocDescription,DocumentState,GrandTotal,BalanceAmount,IsGstSettings,IsMultiCurrency,Nature,IsRepeatingInvoice,Status,DueDate,EntityType,EntityId,DocCurrency,ExchangeRate,GSTExchangeRate,ExCurrency,GSTExCurrency,ExtensionType,CreatedDate,InvoiceNumber,BaseGrandTotal,BaseBalanceAmount)
					Select @items,@companyId,ServiceCompanyId,1,@openingBalanceId,'Credit Note','Opening Bal',DocDate,'System',DocumentRefernceNo,@desc,
					'Not Applied',ABS(DocDebit),ABS(DocDebit),@isGstActivated,@isMultiCurrency,@Nature,0,1, 
					DueDate,'Customer',EntityId,DocCurrency,@exchRate,
					Case When DocCurrency=BaseCurrency Then 1.0000000000 Else @exchRate End,
					BaseCurrency,'SGD','OBCN',GETUTCDATE(),DocumentRefernceNo,ABS(BaseDebit),ABS(BaseDebit) from @temp as t

					Insert Into Bean.InvoiceDetail(Id,InvoiceId,ItemDescription,Qty,Unit,UnitPrice,COAId,TaxId,TaxRate,TaxIdCode,DocAmount,
					DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder,AmtCurrency)
					select (NEWID()),@items,@desc,1,1,DocDebit,@obCoaId,
					Case When @isGstActivated=1 then @taxId else null End, null,
					Case When @isGstActivated=1 then 'NA' else null End,ABS(DocDebit),null,ABS(DocDebit),ABS(BaseDebit),null,ABS(BaseDebit),1,
					DocCurrency
					from @temp

					-- Inserting Records into DocumentHistory Table
					Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
					Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) AS DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Invoice Where Id=@items

				END --FOR negative Amount
			END -- Invoice Data Doesn't Exist
			update Bean.OpeningBalanceDetailLineItem set IsProcressed=1,ProcressedRemarks=null where Id=@items
			--END -- Invoice Data Doesn't Exist
	END -- Line Item Exist

		End Try
		Begin Catch
		update Bean.OpeningBalanceDetailLineItem set IsProcressed=0,ProcressedRemarks= ERROR_MESSAGE() where Id=@items
		End Catch
	delete from  @temp --for deleting Temp Data
	Fetch Next From  OBInvoiceSave Into @Items
	END -- Cursor Loop End
	Close OBInvoiceSave
	Deallocate OBInvoiceSave 
END;

GO
