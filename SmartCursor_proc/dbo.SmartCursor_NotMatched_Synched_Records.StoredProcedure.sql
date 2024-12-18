USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SmartCursor_NotMatched_Synched_Records]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SmartCursor_NotMatched_Synched_Records]
-- EXEC [dbo].[SmartCursor_NotMatched_Synched_Records] 1
@Companyid Bigint

AS
BEGIN 
	Exec CC_Account_WF_Client_Syncing_SP_Non_Matched_New  @Companyid

	
	Exec WF_Client_Bean_ENtity_Syncing_SP_NonMatched_New @Companyid

	Exec WF_Service_Bean_Item_Syncing_NonMatched_SP_New @Companyid

	Exec WF_Invoice_Bean_Invoice_Syncing_SP_NonMatched_New @Companyid


	Exec HR_Employee_Bean_Entity_Syncing_SP_NonMatched_New @Companyid

	Exec HR_Claim_Bean_BillClaim_Syncing_SP_NonMatched_New @Companyid

	Exec HR_Payroll_Bean_BillPayroll_Syncing_SP_NonMatched_New @Companyid

	
	--Exec CC_Service_WF_Service_Syncing_SP_Non_Matching_New @Companyid

	--Exec WF_Employee_HR_Employee_Syncing_NonMatched_SP_New @Companyid
	
	--Exec CC_Opportunity_WF_Cases_Syncing_SP_Nonmatching_New @Companyid

END
GO
