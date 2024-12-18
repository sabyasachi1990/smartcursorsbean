USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Invoice_Bean_Invoice_Syncing_SP_New]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[WF_Invoice_Bean_Invoice_Syncing_SP_New]
	-- Exec [dbo].[WF_Invoice_Bean_Invoice_Syncing_SP_New]  1
@CompanyId Bigint
AS
BEGIN
	SELECT 'WF_Invoice' Source,'Bean_Invoice' Destination ,[Source_InvoiceCount], [Destination_InvoiceCount], [Matching_Count], [Non_Matching_Count],isnull([Duplicate_Count],0)[Duplicate_Count]
	FROM 
	(
		SELECT * FROM 
		(
			SELECT 'Source_InvoiceCount' AS [WF_Invoice], Count(Id) [SourceInvoice_Count]
				FROM WorkFlow.Invoice  Where CompanyId=@CompanyId

			UNION All

			SELECT 'Destination_InvoiceCount' AS [Bean_Invoice], Count(DocumentId) [DestinationInvoice_Count]
				FROM Bean.invoice Where CompanyId=@CompanyId

			UNION All

			SELECT 'Matching_Count' [Matching_InvoiceCount], Count(Id) 'Matching_Count'
				FROM WorkFlow.Invoice  Where CompanyId=@CompanyId and Id in
				(SELECT DocumentId FROM Bean.invoice Where CompanyId=@CompanyId)

			UNION All

			SELECT 'Non_Matching_Count' [NonMatching_InvoiceCount], Count(Id) 'Non_Matching_Count'
				FROM WorkFlow.Invoice  Where CompanyId=@CompanyId and id NOT IN 
				(SELECT DocumentId FROM Bean.invoice Where CompanyId=@CompanyId)

			UNION All

			Select 'Duplicate_Count' [Duplicate_Account], (Duplicate_Count) 'Duplicate_Account'
			From
			(
				SELECT Count(E.ID) 'Duplicate_Count', E.DocumentId 'Duplicate_Account'  
				From Bean.Invoice E
				Inner join WorkFlow.Invoice C on C.Id=E.DocumentId
				Where E.CompanyId=@CompanyId 
				Group By E.Id, E.DocumentId Having Count(E.ID)>1
			) DupCount
		) as AA
	) Books
	PIVOT 
	(
		SUM(SourceInvoice_Count) FOR WF_Invoice IN ([Source_InvoiceCount],[Destination_InvoiceCount],[Matching_Count],[Non_Matching_Count],[Duplicate_Count])
	) Result;
END
GO
