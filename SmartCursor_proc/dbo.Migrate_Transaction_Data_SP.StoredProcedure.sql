USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Migrate_Transaction_Data_SP]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Exec [dbo].[Migrate_Transaction_Data_SP]
CREATE Procedure [dbo].[Migrate_Transaction_Data_SP]
As
Begin
	Begin Transaction
	Begin Try
		Declare @Status Varchar(20)
		Declare @Date datetime
		Declare @PayrollId Uniqueidentifier
		DECLARE @listStr VARCHAR(MAX)
			Set @Status='Completed'
		--Bean.Invoce & Workflow.Invoice
		Update WFI Set WFI.SyncBCInvoiceId=BCI.Id,WFI.SyncBCInvoiceStatus=@Status,WFI.SyncBCInvoiceDate=BCI.CreatedDate,WFI.SyncBCInvoiceRemarks=Null 
		From [WorkFlow].[Invoice] As WFI
		Inner Join Bean.Invoice As BCI On BCI.Id=WFI.DocumentId
		Where WFI.DocumentId Is Not Null And WFI.SyncBCInvoiceId Is Null
		Update BCI Set BCI.SyncWFInvoiceId=WFI.Id,BCI.SyncWFInvoiceDate=WFI.CreatedDate,BCI.SyncWFInvoiceStatus=@Status,BCI.SyncWFInvoiceRemarks=Null 
		From Bean.Invoice As BCI
		Inner Join WorkFlow.Invoice As WFI On WFI.Id=BCI.DocumentId
		Where BCI.DocumentId Is Not Null And BCI.SyncWFInvoiceId Is NUll

		--Bean.Bill & Hr.EmployeeClaim1
		Update EC Set EC.SyncBCClaimId=B.Id,EC.SyncBCClaimDate=B.CreatedDate,EC.SyncBCClaimStatus=@Status,EC.SyncBCClaimRemarks=Null From HR.EmployeeClaim1 As EC
		Inner Join Bean.Bill As B On B.Id=EC.DocumentId
		Where EC.DocumentId Is Not Null And SyncBCClaimId Is Null
		Update B Set B.SyncHRPayrollId=EC.Id,B.SyncHRPayrollStatus=@Status,B.SyncHRPayrollDate=EC.CreatedDate,B.SyncHRPayrollRemarks=Null From Bean.Bill As B
		Inner Join HR.EmployeeClaim1 As EC On EC.Id=B.PayrollId
		Where B.PayrollId Is Not Null And B.SyncHRPayrollId Is null And B.DocSubType='Claim'

		--Bean.Bill & HR.Payroll
		Declare PayBillId_Csr Cursor For
		Select Id From Hr.Payroll  Where SyncPayBillId Is Null
		Open PayBillId_Csr
		fetch next from PayBillId_Csr into @PayrollId
		While @@FETCH_STATUS=0
		Begin
			Set @Date=(Select max(CreatedDate) From Bean.Bill Where PayrollId=@PayrollId)
			Set @listStr=null
			SELECT @listStr = COALESCE(@listStr+',' , '') + Cast(Id As Varchar(Max))
			FROM Bean.Bill Where Payrollid=@PayrollId
			Update Hr.Payroll set SyncPayBillId=@listStr,SyncPayBillDate=@Date,SyncPayBillStatus=@Status,SyncPayBillRemarks=null Where Id=@PayrollId
	 
			Fetch next from PayBillId_Csr into @PayrollId
		End
		Close PayBillId_Csr
		Deallocate PayBillId_Csr

		Update B Set B.SyncHRPayrollId=P.Id,B.SyncHRPayrollStatus=@Status,B.SyncHRPayrollDate=P.CreateDate,B.SyncHRPayrollRemarks=Null From Bean.Bill As B
		Inner Join HR.Payroll As P On P.Id=B.PayrollId
		Where B.PayrollId Is Not Null And B.SyncHRPayrollId Is null And B.DocSubType='Payroll'

		--Clientcursor.Opportunity & Workflow.Claim
		Update Op Set Op.SyncCaseId=CG.Id,Op.SyncCaseStatus=@Status,Op.SyncCaseDate=CG.CreatedDate,Op.SyncCaseRemarks=Null From ClientCursor.Opportunity As Op
		Inner Join Workflow.Casegroup As CG On CG.Id=Op.caseid
		Where Op.Caseid Is NOt Null And Op.SyncCaseId is Null
		Update CG Set CG.SyncOppId=Op.Id,CG.SyncOppStatus=@Status,CG.SyncOppDate=Op.CreatedDate,Cg.SyncOppRemarks=Null From WorkFlow.CaseGroup As CG 
		Inner Join ClientCursor.Opportunity As Op On Op.Id=CG.OpportunityId
		Where CG.OpportunityId Is Not Null And CG.SyncOppId Is null

		Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Print Error_Message()
	End catch
End

GO
