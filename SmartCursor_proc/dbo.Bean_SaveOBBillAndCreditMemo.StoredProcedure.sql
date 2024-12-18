USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_SaveOBBillAndCreditMemo]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [Bean_SaveOBBillAndCreditMemo] 1077,'332a8133-b0b8-4f6b-a6de-890cb42a3273',''

CREATE procedure [dbo].[Bean_SaveOBBillAndCreditMemo]
(@companyId BigInt,
 @openingBalanceId uniqueidentifier,
 @serviceCompanyId nvarchar(MAX),
 @isGstActivated bit,
 @isMultiCurrency bit
)
As 
Begin 
--Begin Transaction
--Begin Try
-- Declaring Table Variable To Store OpeningLineItem Id Data
 Declare @temp table (Id uniqueidentifier,DocDate datetime2, ServiceCompanyId BigInt, Description nvarchar(320),BaseCurrency nvarchar(20),
						ExchangeRate decimal, DocDebit money, DocCredit money, BaseDebit money, BaseCredit money,
						DocCurrency nvarchar(20), EntityId uniqueidentifier, CDate datetime2, UserCreated nvarchar(150), 
						ModifiedBy nvarchar(150), ModifiedDate datetime2, ChartId bigint, DocumentRefernceNo nvarchar(150),
						DueDate datetime2)
-- Declaring Table Variable To Store ChartOfAccounts
 Declare @CTemp Table(COAId Bigint,COAName Nvarchar(200))
	Insert Into @CTemp (COAId,COAName)
		Select Id,Name from Bean.ChartOfAccount where CompanyId=@companyId and Name in('Trade payables','Other payables')
 -- Declaring Variables
 Declare @obCoaId bigInt,
		 @obItemId uniqueidentifier,
		 @items uniqueidentifier,
		 @isPossetive bit,
		 @docCredit money,
		 @Count int,
		 @desc nvarchar(320),
		 @taxId bigInt,
		 @Nature varchar(20),
		 @exchRate decimal(15,10),
		 @postingDate DateTime2(7)

 select @obCoaId=c.Id from Bean.ChartOfAccount as c where CompanyId=@companyId and Name='Opening balance'
 select @taxId=tax.Id from Bean.TaxCode as tax where Code='NA' AND CompanyId=@companyId
 SET @postingDate=(Select Date from Bean.OpeningBalance where CompanyId=@companyId and id=@openingBalanceId)
 
 -- Declare Cursor To Loop OpeningBalanceLineItem Id's
	Declare OBBillCMSave Cursor For 
	Select LI.Id from Bean.OpeningBalance OB
	Join Bean.OpeningBalanceDetail OBD On OB.Id = OBD.OpeningBalanceId
	Join Bean.OpeningBalanceDetailLineItem LI on OBD.Id = LI.OpeningBalanceDetailId
	Where CompanyId = @companyId AND LI.COAId IN (Select Id From Bean.ChartOfAccount Where CompanyId = @companyId AND Name In ('Trade payables','Other payables')) AND LI.ServiceCompanyId = @serviceCompanyId ANd LI.IsProcressed = 0 AND LI.IsEditable = 1 AND OB.IsTemporary = 0
	Open OBBillCMSave 
	Fetch Next From  OBBillCMSave Into @Items
	While @@FETCH_STATUS=0	
    Begin -- Cursor Loop Begin

		Begin Try
			-- Checking Wether Line Item Is Exist Or Not
			If Exists(Select * from Bean.OpeningBalanceDetailLineItem where Id=@items and IsProcressed=0 and
			ServiceCompanyId=(select op.ServiceCompanyId from Bean.OpeningBalance as op where Id=@openingBalanceId))
			BEGIN -- Line Item Exist

				Insert into @temp select @items,Date,ServiceCompanyId,Description,BaseCurrency,ExchangeRate,DoCDebit,DocCredit,BaseDebit,BaseCredit,DocumentCurrency,EntityId,CreatedDate,UserCreated,ModifiedBy,ModifiedDate,COAId,DocumentReference,DueDate
				from Bean.OpeningBalanceDetailLineItem where Id=@items

				SET @exchRate=(select line.ExchangeRate from Bean.OpeningBalanceDetailLineItem as line where Id=@items)

				SET @desc=(select Case When Description IS not null Then Description Else 
						Concat('Opening balance-',cast (Convert (varchar,DocDate,103 )As varchar) ) End from @temp)

				SET @Nature=(select Case When B.COAName='Trade payables' Then 'Trade' Else 'Others' End 
							From @temp As A
							Inner Join @CTemp As B On B.COAId=A.ChartId)

				--SET @postingDate=(Select Date from Bean.OpeningBalance where CompanyId=@companyId and id=@openingBalanceId)
				-- Checking Bill Data Is Exist Or Not

				select @docCredit=t.DocCredit from @temp as t
				Set @Count=CHARINDEX('-',@docCredit)
				-- Checking Wether Negative Or Possitive
				If @Count=0  
				BEGIN -- If possetive check wheather that Present in BIll or Not
					IF EXISTS(select Id from Bean.Bill where Id=@items and CompanyId=@companyId and DocSubType='Opening Bal' and IsExternal=1 
					and DocumentState='Not Paid')
					BEGIN -- If Exists update the bill and BillDetail

						UPDATE obBill
						SET obBill.DocCurrency=Temp.DocCurrency,obBill.DocDescription=@desc,obBill.DocumentDate=Temp.DocDate,
						obBill.PostingDate=@postingDate,obBill.DueDate=Temp.DueDate,obBill.ModifiedBy='System',
						obBill.ModifiedDate=GETUTCDATE(),obBill.ExchangeRate=@exchRate,
						obBill.GSTExchangeRate=Case When Temp.DocCurrency='SGD' Then '1.0000000000' Else @exchRate END,
						obBill.GrandTotal=Temp.DocCredit,obBill.BalanceAmount=Temp.DocCredit,obBill.EntityId=Temp.EntityId,
						obBill.DocNo=Temp.DocumentRefernceNo,obBill.SystemReferenceNumber=Temp.DocumentRefernceNo,
						obBill.Nature=@Nature,obBill.BaseGrandTotal=ABS(Temp.BaseCredit),Obbill.BaseBalanceAmount=ABS(Temp.BaseCredit)
						from Bean.Bill as obBill join @temp as Temp on obBill.Id=Temp.Id and obBill.CompanyId=@companyId
						and obBill.OpeningBalanceId=@openingBalanceId

						UPDATE obBillDetail
						SET obBillDetail.Description=@desc,obBillDetail.DocAmount=TMP.DocCredit,obBillDetail.DocTotalAmount=TMP.DocCredit,
						obBillDetail.BaseAmount=TMP.BaseCredit,obBillDetail.BaseTotalAmount=TMP.BaseCredit
						from Bean.BillDetail as obBillDetail join @temp as TMP on obBillDetail.BillId=TMP.Id

						--update Bean.OpeningBalanceDetailLineItem set IsProcressed=1 where Id=@items


						-- Inserting Records into DocumentHistory Table
						IF EXISTS(Select Id from Bean.DocumentHistory where CompanyId=@companyId and TransactionId=@openingBalanceId and DocumentId=@items)
						BEGIN
							Update Bean.DocumentHistory set AgingState='Deleted' where CompanyId=@CompanyId and DocumentId=@items and TransactionId=@openingBalanceId
							Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
							Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) As DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Bill Where Id=@items
						END
						ELSE
						BEGIN
							Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
							Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) As DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Bill Where Id=@items
						END
						

					END---End of Bill Update
					ELSE						
					BEGIN----If Bill is Not Exists check 
						IF EXISTS(select Id from Bean.CreditMemo where Id=@items and CompanyId=@companyId
						and DocSubType='Opening Bal' and OpeningBalanceId=@openingBalanceId and DocumentState='Not Applied')
						BEGIN --- If Cm is exist Delete that one and Insert the Bill
							Delete From  cd From Bean.CreditMemoDetail As cd
							Inner Join Bean.CreditMemo As cm On cm.Id=cd.CreditMemoId							
							Where cm.CompanyId=@CompanyId And cm.Id=@items and cm.DocSubType='Opening Bal' and
							cm.OpeningBalanceId=@openingBalanceId

							Delete From Bean.CreditMemo  						
							Where CompanyId=@CompanyId And Id=@items and DocSubType='Opening Bal' and
							OpeningBalanceId=@openingBalanceId

							Insert Into Bean.Bill(Id,CompanyId,ServiceCompanyId,DocumentDate,DueDate,PostingDate,DocType,DocSubType, DocCurrency,BaseCurrency,GSTExCurrency,ExchangeRate,GSTExchangeRate,DocNo,SystemReferenceNumber,DocumentState,EntityType,EntityId,CreditTermsId,CreditTermValue,Nature,GrandTotal,GSTTotalAmount,UserCreated,CreatedDate,Status,Vendortype,BalanceAmount,DocDescription,IsExternal,OpeningBalanceId,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,IsSegmentReporting,IsNoSupportingDocument,BaseGrandTotal,BaseBalanceAmount)
							select @items,@companyId,ServiceCompanyId,DocDate,DueDate,@postingDate,'Bill','Opening Bal',DocCurrency,BaseCurrency,
							'SGD',@exchRate,Case When DocCurrency='SGD' Then '1.0000000000' Else @exchRate END, DocumentRefernceNo,
							DocumentRefernceNo,'Not Paid','Vendor',EntityId,null,0,@Nature,DocCredit,0,'System',GETUTCDATE(),1,'Employee',DocCredit,
							@desc,1,@openingBalanceId,@isGstActivated,@isMultiCurrency,0,0,0,0,ABS(BaseCredit),ABS(BaseCredit)
							from @temp

							Insert Into Bean.BillDetail(Id,BillId,Description,COAId,IsDisallow,TaxId,TaxCode,TaxIdCode,TaxRate,DocAmount,
							DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder)
							Select NEWID(),@items,@desc,@obCoaId,0, Case When @isGstActivated=1 Then @taxId END,null,
							Case When @isGstActivated=1 Then 'NA' ELSE null End,null,DocCredit,0,DocCredit,BaseCredit,0,BaseCredit,1 from @temp

							 --Delete from DocumentHistoryTable
							Delete from Bean.DocumentHistory where DocumentId=@items

							-- Inserting Records into DocumentHistory Table
							Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
							Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) As DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Bill Where Id=@items
							
						END--End of Bill Save
						ELSE
						BEGIN--If First Time it will save as a Bill
							Insert Into Bean.Bill(Id,CompanyId,ServiceCompanyId,DocumentDate,DueDate,PostingDate,DocType,DocSubType, DocCurrency,BaseCurrency,GSTExCurrency,ExchangeRate,GSTExchangeRate,DocNo,SystemReferenceNumber,DocumentState,EntityType,EntityId,CreditTermsId,CreditTermValue,Nature,GrandTotal,GSTTotalAmount,UserCreated,CreatedDate,Status,Vendortype,BalanceAmount,DocDescription,IsExternal,OpeningBalanceId,IsGstSettings,IsMultiCurrency,IsAllowableDisallowable,IsGSTCurrencyRateChanged,IsSegmentReporting,IsNoSupportingDocument,BaseGrandTotal,BaseBalanceAmount)
							select @items,@companyId,ServiceCompanyId,DocDate,DueDate,@postingDate,'Bill','Opening Bal',DocCurrency,BaseCurrency,
							'SGD',@exchRate,Case When t.DocCurrency='SGD' Then '1.0000000000' Else @exchRate END, DocumentRefernceNo,
							DocumentRefernceNo,'Not Paid','Vendor',EntityId,null,0,@Nature,DocCredit,0,'System',GETUTCDATE(),1,'Employee',DocCredit,
							@desc,1,@openingBalanceId,@isGstActivated,@isMultiCurrency,0,0,0,0,ABS(BaseCredit),ABS(BaseCredit)
							from @temp as t

							Insert Into Bean.BillDetail(Id,BillId,Description,COAId,IsDisallow,TaxId,TaxCode,TaxIdCode,TaxRate,DocAmount,
							DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder)
							Select NEWID(),@items,@desc,@obCoaId,0, Case When @isGstActivated=1 Then @taxId Else null END,null,
							Case When @isGstActivated=1 Then 'NA' ELSE null End,null,DocCredit,0,DocCredit,BaseCredit,0,BaseCredit,1 from @temp

							-- Inserting Records into DocumentHistory Table
							Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
							Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) As DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.Bill Where Id=@items

						END--End of Bill Save
					END----END of Bill is Not Exists 
				END --End of posetive amount checking
				Else --- if negative Amount need to check in CM 
				BEGIN
					IF EXISTS(select Id from Bean.CreditMemo where Id=@items and CompanyId=@companyId and DocSubType='Opening Bal' and
					OpeningBalanceId=@openingBalanceId and DocumentState='Not Applied')
					BEGIN ---If Credit Memo Exists then Update The CM
						UPDATE cm
						SET cm.ServiceCompanyId=Temp.ServiceCompanyId,cm.DocCurrency=Temp.DocCurrency,cm.DocNo=Temp.DocumentRefernceNo,
						cm.CreditMemoNumber=Temp.DocumentRefernceNo, cm.EntityId=Temp.EntityId,cm.ExchangeRate=@exchRate,
						cm.GSTExchangeRate=Case When Temp.DocCurrency='SGD' Then '1.0000000000' Else @exchRate End,
						cm.GrandTotal=ABS(Temp.DocCredit),cm.BalanceAmount=ABS(Temp.DocCredit),cm.ModifiedBy='System',
						cm.ModifiedDate=GETUTCDATE(),cm.Nature=@Nature,cm.DocDescription=Temp.Description,cm.DocDate=Temp.DocDate,
						cm.DueDate=Temp.DueDate,cm.CreditTermsId=null,cm.PostingDate=@postingDate,cm.BaseGrandTotal=ABS(Temp.BaseCredit),cm.BaseBalanceAmount=ABS(Temp.BaseCredit)

						from Bean.CreditMemo as cm inner join @temp as Temp on cm.Id=Temp.Id and cm.CompanyId=@companyId
						and OpeningBalanceId=@openingBalanceId and cm.DocSubType='Opening Bal'
						Update cmd
						SET cmd.DocAmount=ABS(Tmp.DocCredit),cmd.DocTotalAmount=ABS(Tmp.DocCredit),cmd.BaseAmount=ABS(Tmp.BaseCredit),
						cmd.BaseTotalAmount=ABS(Tmp.BaseCredit),cmd.Description=Tmp.Description
						from Bean.CreditMemoDetail as cmd inner join @temp as Tmp on cmd.CreditMemoId=Tmp.Id

						-- Inserting Records into DocumentHistory Table
						IF EXISTS(Select Id from Bean.DocumentHistory where CompanyId=@companyId and TransactionId=@openingBalanceId and DocumentId=@items)
						BEGIN
							Update Bean.DocumentHistory set AgingState='Deleted' where CompanyId=@CompanyId and DocumentId=@items and TransactionId=@openingBalanceId
							Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
							Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) As DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.CreditMemo Where Id=@items
						END
						ELSE
						BEGIN
							Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
							Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) As DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.CreditMemo Where Id=@items
						END
						
						
					END---End Credit Memo Exists then Update The CM
					ELSE
					BEGIN
						IF EXISTS(select Id from Bean.Bill where Id=@items and CompanyId=@companyId and DocSubType='Opening Bal' and IsExternal=1
						and DocumentState='Not Paid' and DocSubType='Opening Bal')
						BEGIN
							Delete From bd From Bean.BillDetail As bd
							Inner Join Bean.Bill As b On b.Id=bd.BillId							
							Where b.CompanyId=@CompanyId And b.Id=@items and b.DocSubType='Opening Bal' and
							b.OpeningBalanceId=@openingBalanceId 


							Delete From  Bean.Bill 					
							Where CompanyId=@CompanyId And Id=@items and DocSubType='Opening Bal' and
							OpeningBalanceId=@openingBalanceId

							INSERT INTO Bean.CreditMemo(Id,CompanyId,ServiceCompanyId,DocDate,DueDate,PostingDate,DocType,DocSubType,DocCurrency,ExCurrency,GSTExCurrency,ExchangeRate,GSTExchangeRate,DocNo,CreditMemoNumber,DocumentState,EntityType,EntityId,CreditTermsId,Nature,GrandTotal,GSTTotalAmount,UserCreated,CreatedDate,Status,BalanceAmount,DocDescription,OpeningBalanceId,IsGstSettings,IsMultiCurrency,IsGSTCurrencyRateChanged,IsSegmentReporting,IsNoSupportingDocument,ExtensionType,IsAllowableNonAllowable,BaseGrandTotal,BaseBalanceAmount)
							select @items,@companyId,ServiceCompanyId,DocDate,DueDate,@postingDate,'Credit Memo','Opening Bal',DocCurrency,
							BaseCurrency,'SGD',@exchRate,Case When DocCurrency='SGD' Then '1.0000000000' Else @exchRate End,
							DocumentRefernceNo,DocumentRefernceNo,'Not Applied','Vendor',EntityId,Null,@Nature,ABS(DocCredit),0,'System',GETUTCDATE(),1,ABS(DocCredit),
							@desc,@openingBalanceId,@isGstActivated,@isMultiCurrency,0,0,0,'OBCM',0,ABS(BaseCredit),ABS(BaseCredit) from @temp as t

							INSERT INTO Bean.CreditMemoDetail (Id,CreditMemoId,Description,COAId,TaxId,TaxIdCode,TaxRate,DocAmount,
							DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder)
							Select NEWID(),@items,@desc,@obCoaId,Case When @isGstActivated=1 Then @taxId Else null END,
							Case When @isGstActivated=1 Then 'NA' Else Null END,null,ABS(DocCredit),0,ABS(DocCredit),ABS(BaseCredit),0,
							ABS(BaseCredit),1 from @temp

							 --Delete from DocumentHistoryTable
							Delete from Bean.DocumentHistory where DocumentId=@items

							-- Inserting Records into DocumentHistory Table
							Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
							Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) As DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.CreditMemo Where Id=@items
							
						END
						ELSE-----If CM not Exists then Insert CM
						BEGIN
							INSERT INTO Bean.CreditMemo(Id,CompanyId,ServiceCompanyId,DocDate,DueDate,PostingDate,DocType,DocSubType,DocCurrency,ExCurrency,GSTExCurrency,ExchangeRate,GSTExchangeRate,DocNo,CreditMemoNumber,DocumentState,EntityType,EntityId,CreditTermsId,Nature,GrandTotal,GSTTotalAmount,UserCreated,CreatedDate,Status,BalanceAmount,DocDescription,OpeningBalanceId,IsGstSettings,IsMultiCurrency,IsGSTCurrencyRateChanged,IsSegmentReporting,IsNoSupportingDocument,ExtensionType,IsAllowableNonAllowable,BaseGrandTotal,BaseBalanceAmount)
							select @items,@companyId,ServiceCompanyId,DocDate,DueDate,@postingDate,'Credit Memo','Opening Bal',DocCurrency,
							BaseCurrency,'SGD',@exchRate,Case When t.DocCurrency='SGD' Then '1.0000000000' Else @exchRate End,
							DocumentRefernceNo,DocumentRefernceNo,'Not Applied','Vendor',EntityId,Null,@Nature,ABS(DocCredit),0,'System',GETUTCDATE(),1,ABS(DocCredit),
							@desc,@openingBalanceId,@isGstActivated,@isMultiCurrency,0,0,0,'OBCM',0,ABS(BaseCredit),ABS(BaseCredit) from @temp as t

							INSERT INTO Bean.CreditMemoDetail (Id,CreditMemoId,Description,COAId,TaxId,TaxIdCode,TaxRate,DocAmount,
							DocTaxAmount,DocTotalAmount,BaseAmount,BaseTaxAmount,BaseTotalAmount,RecOrder)
							Select NEWID(),@items,@desc,@obCoaId,Case When @isGstActivated=1 Then @taxId Else null END,
							Case When @isGstActivated=1 Then 'NA' Else Null END,null,ABS(DocCredit),0,ABS(DocCredit),ABS(BaseCredit),0,
							ABS(BaseCredit),1 from @temp

							-- Inserting Records into DocumentHistory Table
							Insert Into Bean.DocumentHistory(Id,TransactionId,CompanyId,DocumentId,DocType,DocSubType,DocState,DocCurrency,DocAmount,DocBalanaceAmount,ExchangeRate,BaseAmount,BaseBalanaceAmount,StateChangedBy,StateChangedDate,PostingDate,DocAppliedAmount,BaseAppliedAmount)
							Select NEWID(),@openingBalanceId,CompanyId,@items,DocType,DocSubType,DocumentState,DocCurrency,Round(GrandTotal,2) As DocAmount,Round(BalanceAmount,2) As DocBalanceAmount,ExchangeRate,Round(GrandTotal*ExchangeRate,2) As BaseAmount,Round(BalanceAmount*ExchangeRate,2) As BaseBalanceAmount,UserCreated,GETUTCDATE(),@postingDate,Round(GrandTotal,2) As DocAppliedAmount,Round(GrandTotal*ExchangeRate,2) As BaseAppliedAmount From Bean.CreditMemo Where Id=@items
							
						END ---End of CM Insertion
					END
				END
			
			END -- Line Item Exist
			update Bean.OpeningBalanceDetailLineItem set IsProcressed=1,ProcressedRemarks=null where Id=@items
		End Try
		Begin Catch
			update Bean.OpeningBalanceDetailLineItem set IsProcressed=0,ProcressedRemarks= ERROR_MESSAGE() where Id=@items
		End Catch
		delete from  @temp --for deleting Temp Data
		Fetch Next From  OBBillCMSave Into @Items

	END -- Cursor Loop End
	Close OBBillCMSave
	Deallocate OBBillCMSave 
	
--	Commit Transaction

--End Try
--Begin Catch
--	----Rollback;
--	--Print 'In Catch Block';
--	--Throw;
--End Catch
END;
GO
