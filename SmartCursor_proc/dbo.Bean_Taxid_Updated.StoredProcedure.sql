USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Taxid_Updated]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--EXEC Bean_Taxid_Updated
CREATE Proc [dbo].[Bean_Taxid_Updated]
AS
BEGIN

Declare @id bigint--=707 
Declare Company_Id Cursor For
select Distinct Id from Common.Company where Id<>0 and id in (707,1077)  
		Open Company_Id
		fetch next from Company_Id Into @id
		While @@FETCH_STATUS=0
		Begin
--============Bean.InvoiceDetail====================
  -- select Distinct D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	 from Bean.InvoiceDetail D
	 Inner join bean.Invoice I on i.id=d.InvoiceId
	 Inner join Bean.TaxCode T on T.Id=d.TaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=I.CompanyId
	 where i.CompanyId=@id    --and  d.Id in ('6EBE7362-9E42-44CD-BFCD-0000948C60F7','CA266495-26BA-4332-83ED-0006A8FDAED3')

	--=========Data verify============--
	--select D.id,d.TaxId from Bean.InvoiceDetail D
	--Inner join bean.Invoice I on i.id=d.InvoiceId where companyid=1 --Taxid
	----21--CA266495-26BA-4332-83ED-0006A8FDAED3,1---6EBE7362-9E42-44CD-BFCD-0000948C60F7
	--and d.Id in ('B0532D99-75A0-40F6-A790-000D71981EFB','B07B1408-6CDF-4861-B347-001017BF1C10','0347B4BD-21EB-4FF7-AFA2-010C78560A15',
	--'C5D3C020-9839-440C-8C14-01CECE9F110F')

	--21--B0532D99-75A0-40F6-A790-000D71981EFB','B07B1408-6CDF-4861-B347-001017BF1C10
	---1--'0347B4BD-21EB-4FF7-AFA2-010C78560A15','C5D3C020-9839-440C-8C14-01CECE9F110F'

	--select * from  bean.InvoiceDetail D 
	--Inner join bean.Invoice I on i.id=d.InvoiceId where companyid=13 --8473

	--============Bean.DebitNoteDetail ====================
   --select  D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	 from Bean.DebitNoteDetail  D
	 Inner join bean.DebitNote I on i.id=d.DebitNoteId
	 Inner join Bean.TaxCode T on T.Id=d.TaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=I.CompanyId
	 where i.CompanyId=@id

  --============ Bean.CashsaleDetail  ====================
   --select  D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	 from  Bean.CashsaleDetail  D
	 Inner join bean.CashSale I on i.id=d.CashSaleId
	 Inner join Bean.TaxCode T on T.Id=d.TaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=I.CompanyId
	 where i.CompanyId=@id 
	----============ Bean.ReceiptBalancingItem   ====================
   --select  D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	from  Bean.ReceiptBalancingItem   D
	Inner join bean.Receipt I on i.id=d.ReceiptId
	Inner join Bean.TaxCode T on T.Id=d.TaxId
	Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=I.CompanyId
	where i.CompanyId=@id
	  --============  Bean.CreditnoteapplicationDetail   ====================
   --select  D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	 from   Bean.CreditnoteapplicationDetail D
	 Inner join bean.CreditNoteApplication I on i.id=d.CreditNoteApplicationId
	 Inner join Bean.TaxCode T on T.Id=d.TaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=I.CompanyId
	 where i.CompanyId=@id
	 --============  Bean.BillDetail    ====================
   --select  D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	 from   Bean.BillDetail  D
	 Inner join bean.Bill I on i.id=d.BillId
	 Inner join Bean.TaxCode T on T.Id=d.TaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=I.CompanyId
	 where i.CompanyId=@id
	--============  Bean.CreditmemoapplicationDetail    ====================
   --select  D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	 from   Bean.CreditmemoapplicationDetail D
	 Inner join bean.CreditMemoApplication I on i.id=d.CreditMemoApplicationId
	 Inner join Bean.TaxCode T on T.Id=d.TaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=I.CompanyId
	 where i.CompanyId=@id
	--============  Bean.CreditMemoDetail    ====================
   --select  D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	 from   Bean.CreditMemoDetail  D
	 Inner join bean.CreditMemo I on i.id=d.CreditMemoId
	 Inner join Bean.TaxCode T on T.Id=d.TaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=I.CompanyId
	 where i.CompanyId=@id
	--============ Bean.WithdrawalDetail     ====================
   --select  D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	 from   Bean.WithdrawalDetail   D
	 Inner join bean.WithDrawal I on i.id=d.WithdrawalId
	 Inner join Bean.TaxCode T on T.Id=d.TaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=I.CompanyId
	 where i.CompanyId=@id
	--============ Bean.JournalDetail      ====================
   --select  D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	 from   Bean.JournalDetail D
	 Inner join bean.Journal I on i.id=d.JournalId
	 Inner join Bean.TaxCode T on T.Id=d.TaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=I.CompanyId
	 where i.CompanyId=@id
	--============ Bean.Entity       ====================
   --select  D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	 from   Bean.Entity  D
	 Inner join Bean.TaxCode T on T.Id=d.TaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=D.CompanyId
	 where D.CompanyId=@id

	 	--============ Bean.Item  ====================
   --select  D.DefaultTaxcodeId,tt.Id,d.Id,t.Id 
	update d set D.DefaultTaxcodeId=tt.Id--,d.Id,t.Id 
	 from   Bean.Item  D
	 Inner join Bean.TaxCode T on T.Id=d.DefaultTaxcodeId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=D.CompanyId
	 where D.CompanyId=@id

	 	---============ Bean.TaxcodemappingDetail(CustTaxId)  ====================
   --select  D.CustTaxId,tt.Id,d.Id,t.Id 
	update d set D.CustTaxId=tt.Id--,d.Id,t.Id 
	 from   Bean.TaxcodemappingDetail  D
	 Inner join Bean.TaxCodeMapping I on i.Id=d.TaxCodeMappingId
	 Inner join Bean.TaxCode T on T.Id=d.CustTaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=i.CompanyId
	 --where i.CompanyId=@id
	 ---============ Bean.TaxcodemappingDetail(VenTaxId)  ====================
	   -- select  D.VenTaxId,tt.Id,d.Id,t.Id 
	update d set D.VenTaxId=tt.Id--,d.Id,t.Id 
	 from   Bean.TaxcodemappingDetail  D
	 Inner join Bean.TaxCodeMapping I on i.Id=d.TaxCodeMappingId
	 Inner join Bean.TaxCode T on T.Id=d.VenTaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=i.CompanyId
	 where i.CompanyId=@id

  -------=========================== HR ===============================================================
	 --============ HR.EmployeeClaimDetail ====================
   -- select  D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	 from   HR.EmployeeClaimDetail D
	 Inner join hr.EmployeeClaim1 I on i.id=d.EmployeeClaimId
	 Inner join Bean.TaxCode T on T.Id=d.TaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=I.ParentCompanyId
	 where i.ParentCompanyId=@id

	   -------=========================== WorkFlow ===============================================================
	 --============ Workflow.invoice ====================
   -- select  D.TaxCodeId,tt.Id,d.Id,t.Id 
	update d set D.TaxCodeId=tt.Id--,d.Id,t.Id 
	 from   Workflow.invoice D
	 Inner join Bean.TaxCode T on T.Id=d.TaxCodeId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=D.CompanyId
	 where D.CompanyId=@id

	 	 --============ WorkFlow.Incidental  ====================
   -- select  D.TaxId,tt.Id,d.Id,t.Id 
	update d set D.TaxId=tt.Id--,d.Id,t.Id 
	 from   WorkFlow.Incidental D
	 Inner join Workflow.invoice I on i.id=D.InvoiceId
	 Inner join Bean.TaxCode T on T.Id=d.TaxId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=i.CompanyId
	 where i.CompanyId=@id

	 --============ WorkFlow.IncidentalClaimItem  ====================
    --select  D.TaxCodeId,tt.Id,d.Id,t.Id 
	update d set D.TaxCodeId=tt.Id--,d.Id,t.Id 
	 from   WorkFlow.IncidentalClaimItem D
	 Inner join Bean.TaxCode T on T.Id=d.TaxCodeId
	 Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=D.CompanyId
	 where D.CompanyId=@id

	  --============ WorkFlow.Service  ====================
   --select  S.TaxCodeId,tt.Id,S.Id,t.Id
    update S set S.TaxCodeId=tt.Id--,d.Id,t.Id
     from   Common.Service S
     Inner join Bean.TaxCode T on T.Id=S.TaxCodeId
     Inner join Bean.TaxCode TT on TT.Code=T.Code and TT.CompanyId=S.CompanyId
     where S.CompanyId=@id
	
	Fetch Next From Company_Id Into @id
	END
	Close Company_Id
	Deallocate Company_Id
	
	END
GO
