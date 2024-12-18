USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Invoice_Bean_Invoice_Syncing_SP_NonMatched_New]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[WF_Invoice_Bean_Invoice_Syncing_SP_NonMatched_New]
-- Exec [dbo].[WF_Invoice_Bean_Invoice_Syncing_SP_NonMatched_New] 1
	@CompanyId Bigint
As
Begin
	------- Non_matching----

	SELECT i.id as 'NonMatching_WF_InvoiceId in Bean Invoice', i.Number AS Name
		FROM WorkFlow.Invoice i Where CompanyId=@CompanyId and documentid is not null and id NOT IN 
		(SELECT DocumentId FROM Bean.invoice Where CompanyId=@CompanyId and DocumentId is not null)

	SELECT E.DocumentId 'WF Invoicce Duplicate Id in Bean Invoice', Count(E.ID) 'Duplicate_Count'
	From Bean.Invoice E
	Inner join WorkFlow.Invoice C on C.Id=E.DocumentId
	Where E.CompanyId=@CompanyId 
	Group By E.Id, E.DocumentId Having Count(E.ID)>1

END
GO
