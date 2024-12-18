USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Update_Posting_date]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE Procedure [dbo].[Bean_Update_Posting_date]
(
@CompanyId BigInt,
@OpeningBalanceId Uniqueidentifier,
@ServiceCompanyId BigInt
)
As 
Begin
DECLARE  @ErrorMessage  NVARCHAR(4000), 
			 @ErrorSeverity INT, 
			 @ErrorState    INT;
Begin Try
Begin Transaction

	----Opening Balance Invoice and Credit Note Posting date updation Before that if any Inv and Cn is exist on the Opening Bal in 	
	If Exists(Select id from Bean.OpeningBalanceDetailLineItem where COAId in (select Id from Bean.chartofaccount where companyid=@CompanyId and name in ('Trade receivables','Other receivables')) and ServiceCompanyId=@ServiceCompanyId and IsProcressed=1)
	Begin
		If Exists(Select Id from Bean.Invoice where CompanyId=@CompanyId and OpeningBalanceId=@OpeningBalanceId and  DocumentState='Not Paid' and DocType='Invoice' and DocSubType='Opening Bal')
		Begin
			Update Doc Set Doc.PostingDate=OB.Date from Bean.OpeningBalance OB 
			Join Bean.Invoice Inv on OB.Id=Inv.OpeningBalanceId
			Join Bean.DocumentHistory Doc on Inv.Id=Doc.DocumentId and Doc.CompanyId=@CompanyId
			where Ob.CompanyId=@CompanyId and OB.Id=@OpeningBalanceId and Inv.DocumentState='Not Paid' and Doc.TransactionId=@OpeningBalanceId and Doc.AgingState is null and Inv.DocSubType='Opening Bal' and Inv.DocType='Invoice'
		End
		If Exists(Select Id from Bean.Invoice where CompanyId=@CompanyId and OpeningBalanceId=@OpeningBalanceId and  DocumentState='Not Applied' and DocType='Creidt Note' and DocSubType='Opening Bal')
		Begin
			Update Doc Set Doc.PostingDate=OB.Date from Bean.OpeningBalance OB 
			Join Bean.Invoice Inv on OB.Id=Inv.OpeningBalanceId
			Join Bean.DocumentHistory Doc on Inv.Id=Doc.DocumentId and Doc.CompanyId=@CompanyId
			where Ob.CompanyId=@CompanyId and OB.Id=@OpeningBalanceId and Inv.DocumentState='Not Applied' and Doc.TransactionId=@OpeningBalanceId and Doc.AgingState is null and Inv.DocSubType='Opening Bal' and Inv.DocType='Credit Note'
		End
	End



	
	If Exists(select Id from Bean.OpeningBalanceDetailLineItem where COAId in (select Id from Bean.chartofaccount where companyid=@CompanyId and name in ('Trade payables','Other payables')) and ServiceCompanyId=@ServiceCompanyId and IsProcressed=1)
	Begin
		If Exists(Select Id from Bean.Bill where CompanyId=@CompanyId and OpeningBalanceId=@OpeningBalanceId and  DocumentState='Not Paid')
		Begin
			Update B Set B.PostingDate=OB.Date from Bean.OpeningBalance OB 
			Join Bean.Bill B on OB.Id=B.OpeningBalanceId
			where Ob.CompanyId=@CompanyId and OB.Id=@OpeningBalanceId and B.DocumentState='Not Paid' and B.DocSubType='Opening Bal'


			Update Doc Set Doc.PostingDate=OB.Date from Bean.OpeningBalance OB 
			Join Bean.Bill B on OB.Id=B.OpeningBalanceId
			Join Bean.DocumentHistory Doc on B.Id=Doc.DocumentId and Doc.CompanyId=@CompanyId
			where Ob.CompanyId=@CompanyId and OB.Id=@OpeningBalanceId and B.DocumentState='Not Paid' and Doc.TransactionId=@OpeningBalanceId and Doc.AgingState is null and B.DocSubType='Opening Bal'

		End
		If Exists(Select Id from Bean.CreditMemo where CompanyId=@CompanyId and OpeningBalanceId=@OpeningBalanceId and  DocumentState='Not Applied')
		Begin
			 Update CM Set CM.PostingDate=OB.Date from Bean.OpeningBalance OB 
			Join Bean.CreditMemo CM on OB.Id=CM.OpeningBalanceId 
			where Ob.CompanyId=@CompanyId and OB.Id=@OpeningBalanceId and CM.DocumentState='Not Applied' and CM.DocSubType='Opening Bal'

			Update Doc Set Doc.PostingDate=OB.Date from Bean.OpeningBalance OB 
			Join Bean.CreditMemo CM on OB.Id=CM.OpeningBalanceId
			Join Bean.DocumentHistory Doc on CM.Id=Doc.DocumentId and Doc.CompanyId=@CompanyId
			where Ob.CompanyId=@CompanyId and OB.Id=@OpeningBalanceId and CM.DocumentState='Not Applied' and Doc.TransactionId=OpeningBalanceId and Doc.AgingState is null and CM.DocSubType='Opening Bal'
		End
	End
Commit Transaction		
End Try
Begin Catch
RollBack Transaction
SELECT 
        @ErrorMessage = ERROR_MESSAGE(), 
        @ErrorSeverity = ERROR_SEVERITY(), 
        @ErrorState = ERROR_STATE();
 
		-- return the error inside the CATCH block
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);	
End Catch
End


GO
