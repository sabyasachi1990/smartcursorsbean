USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Claim_Bean_BillClaim_Syncing_SP_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[HR_Claim_Bean_BillClaim_Syncing_SP_New]

-- Exec [dbo].[HR_Claim_Bean_BillClaim_Syncing_SP_New]  20
 
	@CompanyId Bigint

   AS
   BEGIN

SELECT 'HR_Claim' Source,'Bean_BillClaim' Destination,[Source_ClaimCount], [Destination_BillClaimCount], [Matching_Count], [Non_Matching_Count],isnull([Duplicate_Count],0)[Duplicate_Count]
 FROM 
(
SELECT * FROM 
(SELECT 'Source_ClaimCount' AS [HR_Claim] , Count(Id) [SourceClaim_Count]FROM hr.EmployeeClaim1 Where CompanyId=@CompanyId UNION AllSELECT 'Destination_BillClaimCount' AS [Bean_BillClaim] , Count(PayrollId) [DestinationClaim_Count]FROM Bean.Bill Where ServiceCompanyId=@CompanyId and DocSubType='Claim' UNION AllSELECT 'Matching_Count' AS [Matching_ClaimCount] , Count(Id) 'Matching_Count'FROM hr.EmployeeClaim1 Where CompanyId=@CompanyId AND id in(SELECT  PayrollId FROM Bean.Bill Where ServiceCompanyId=@CompanyId and DocSubType='Claim') UNION AllSELECT 'Non_Matching_Count' AS [NonMatching_ClaimCount],Count(Id) 'Non_Matching_Count'FROM hr.EmployeeClaim1 Where CompanyId=@CompanyId AND id NOT IN(SELECT  PayrollId FROM Bean.Bill Where ServiceCompanyId=@CompanyId and DocSubType='Claim') UNION AllSELECT 'Duplicate_Count' [Duplicate_Claim],Count(EC.Id) 'Duplicate_Claim'FROM hr.EmployeeClaim1 ECInner Join Bean.Bill B ON B.PayrollId=Ec.IdWhere EC.CompanyId=@CompanyId and EC.ParentCompanyId=@CompanyId and DocSubType='Claim'Group by EC.idHaving Count(EC.Id)>1) as AA) Books
PIVOT (
  SUM(SourceClaim_Count) FOR HR_Claim IN ([Source_ClaimCount], [Destination_BillClaimCount], [Matching_Count], [Non_Matching_Count],[Duplicate_Count])
) Result;
END
GO
