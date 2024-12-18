USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Claim_Bean_BillClaim_Syncing_SP_NonMatched_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[HR_Claim_Bean_BillClaim_Syncing_SP_NonMatched_New]
-- Exec [dbo].[HR_Claim_Bean_BillClaim_Syncing_SP_NonMatched_New] 1
	@CompanyId Bigint
As
Begin

	SELECT Id 'NonMatching_HR_ClaimId in Bean Bill', ClaimNumber
	FROM hr.EmployeeClaim1 Where ParentCompanyId=@CompanyId AND ClaimStatus = 'Processed' And Year(ModifiedDate)>2018 And  Id NOT IN 
	(SELECT PayrollId FROM Bean.Bill Where CompanyId=@CompanyId and DocSubType='Claim')

	SELECT E.PayrollId 'Claim Duplicate Id in Bean Bill', Count(E.PayrollId)'Duplicate_Count'  
	From Bean.Bill E
	Inner Join HR.EmployeeClaim1 C on C.Id=E.PayrollId
	Where E.CompanyId=@CompanyId and E.DocSubType='Claim'
	Group By E.PayrollId Having Count(E.PayrollId)>1
END


GO
