USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_BeanSyncing_NotSaving]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec WF_BeanSyncing_NotSaving 1

CREATE Procedure [dbo].[WF_BeanSyncing_NotSaving] 
	@CompanyId Bigint
As
Begin


Declare @Bean_Sync Table (Id int Identity(1,1),SourceId Nvarchar(250),IdType Nvarchar(50),SubSourceId Nvarchar(250),SubIdType Nvarchar(50),Destination Nvarchar(250))

Declare	@WFInvoiceId Uniqueidentifier,
		@BNInvoiceId Uniqueidentifier
--// Checking Bean is activated or not for the perticular company if bean is activated check employee table data with entity table data
IF Exists (Select CM.Id From Common.CompanyModule As CM
			Inner Join Common.ModuleMaster As MM On MM.Id=CM.ModuleId
			Where MM.Name='Bean Cursor' And CM.Status=1 And Cm.CompanyId=@CompanyId)
Begin

Insert Into @Bean_Sync (SourceId,IdType,Destination)

		Select Id,'Employee','Bean.Entity' From common.Employee Where CompanyId=@CompanyId 
				And Status=1 And Id Not In (Select DocumentId From Bean.Entity Where CompanyId=@CompanyId And Status=1 And ExternalEntityType='Employee')

End
-- // Checking Client table data with entity table data
Insert Into @Bean_Sync (SourceId,IdType,Destination)
	
		Select Id,'Client','Bean.Entity' From WorkFlow.Client Where CompanyId=@CompanyId 
				And Id Not In  (Select DocumentId From Bean.Entity Where CompanyId=@CompanyId And ExternalEntityType='Client')

-- // Checking Workflow invoice table data with Bean invoice table data
Begin

	Declare InvoiceId_CSR Cursor For
				Select Id,DocumentId From WorkFlow.Invoice As INC
				Where INC.CompanyId=@CompanyId And INC.DocumentId Is Not null
		Open InvoiceId_CSR
		Fetch Next From InvoiceId_CSR Into @WFInvoiceId,@BNInvoiceId
		While @@FETCH_STATUS=0
		Begin
			If Not Exists (Select Id From Bean.Invoice Where Id=@BNInvoiceId And DocumentId=@WFInvoiceId And CompanyId=@CompanyId And DocSubType in ('Interim','Final'))
			Begin
				Insert Into @Bean_Sync (SourceId,SubSourceId,IdType,SubIdType,Destination)
							Values(@WFInvoiceId,@BNInvoiceId,'WF Invoice','Bean Invoice','Bean.Invoice')
			End
		Fetch Next From InvoiceId_CSR Into @WFInvoiceId,@BNInvoiceId
		End

		Close InvoiceId_CSR
		Deallocate InvoiceId_CSR

End

-- // Checking Payroll table data with bill table data
Insert Into @Bean_Sync (SourceId,IdType,Destination)
		
		Select Id,'Paroll','Bean.Bill' From HR.Payroll where CompanyId=@CompanyId And PayrollStatus='Processed'
				And Id Not In (select PayrollId From Bean.Bill Where CompanyId=@CompanyId And DocSubType='Payroll Bill')

-- // Checking Claim table data with bill table data	 


Insert Into @Bean_Sync (SourceId,IdType,Destination)
		
		Select Id,'Claim','Bean.Bill' From HR.EmployeeClaim1 where CompanyId=@CompanyId And ClaimStatus='Processed'
				And Id Not In (select PayrollId From Bean.Bill Where CompanyId=@CompanyId And DocSubType='Claim')

-- // Checking Service table data with Item table data

If Exists (Select CM.Id From Common.CompanyModule As CM 
			Inner Join Common.ModuleMaster As MM On MM.Id=CM.ModuleId
			where CM.CompanyId=@CompanyId And MM.Heading='Bean Cursor' And CM.Status=1 And CM.SetUpDone=1)
Begin

Insert Into @Bean_Sync (SourceId,IdType,Destination)
		
		Select Svc.Id,'Service','Bean.Item' From Common.Service As Svc
		Inner Join Common.ServiceGroup As SG On SG.Id=Svc.ServiceGroupId
		Where SG.CompanyId=@CompanyId And Svc.Status=1 And Svc.Id Not In (select DocumentId From Bean.Item Where CompanyId=@CompanyId And DocumentId Is Null)
	
End
		
Select * From @Bean_Sync Order By Id

End
GO
