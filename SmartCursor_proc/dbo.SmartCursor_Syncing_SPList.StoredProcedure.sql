USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SmartCursor_Syncing_SPList]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[SmartCursor_Syncing_SPList]

-- EXEC [dbo].[SmartCursor_Syncing_SPList] 1
@Companyid Bigint

AS
BEGIN 

Begin
Exec [dbo].[CC_Account_WF_Client_Syncing_SP_New]  @Companyid
END

Begin
Exec CC_Opportunity_WF_Cases_Syncing_SP_New @Companyid
END

BEGIN
Exec CC_Service_WF_Service_Syncing_SP_New @Companyid
END

BEGIN
Exec HR_Claim_Bean_BillClaim_Syncing_SP_New @Companyid
END

BEGIN
Exec HR_Employee_Bean_Entity_Syncing_SP_New @Companyid
END

BEGIN
Exec HR_Payroll_Bean_BillPayroll_Syncing_SP_New @Companyid
END

BEGIN
Exec WF_Client_Bean_ENtity_Syncing_SP_New @Companyid
END

BEGIN
Exec WF_Employee_HR_Employee_Syncing_SP_New @Companyid
END

BEGIN
Exec WF_Invoice_Bean_Invoice_Syncing_SP_New @Companyid
END

BEGIN
Exec WF_Service_Bean_Item_Syncing_SP_New @Companyid
END

END
GO
