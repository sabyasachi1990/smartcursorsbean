USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Payroll_Bean_BillPayroll_Syncing_SP_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[HR_Payroll_Bean_BillPayroll_Syncing_SP_New]

-- Exec [dbo].[HR_Payroll_Bean_BillPayroll_Syncing_SP_New]  20
 
	@CompanyId Bigint

   AS
   BEGIN

--Declare @CompanyId int=1

SELECT 'HR_Payroll' Source,'Bean_Bill' Destination,[Source_PayrollCount], [Destination_BillPayrollCount], [Matching_Count], [Non_Matching_Count],isnull([Duplicate_Count],0)[Duplicate_Count]
 FROM 
(
SELECT * FROM 
(SELECT 'Source_PayrollCount' AS [HR_Payroll] , Count(Id) [SourcePayroll_Count]FROM hr.Payroll Where CompanyId=@CompanyId  UNION AllSELECT 'Destination_BillPayrollCount' AS [Bean_BillPayroll] , Count(PayrollId) [DestinationPayroll_Count]FROM Bean.Bill Where ServiceCompanyId=@CompanyId and DocSubType='payroll' UNION AllSELECT 'Matching_Count' AS [Matching_PayrollCount], Count(Id) 'Matching_Count'FROM hr.Payroll Where CompanyId=@CompanyId and id in (SELECT PayrollId FROM Bean.Bill Where ServiceCompanyId=@CompanyId and DocSubType='payroll') UNION AllSELECT 'Non_Matching_Count' AS [NonMatching_PayrollCount], Count(Id) 'Non_Matching_Count'FROM hr.Payroll Where CompanyId=@CompanyId and id NOT IN  (SELECT PayrollId FROM Bean.Bill Where ServiceCompanyId=@CompanyId and DocSubType='payroll') UNION AllSELECT 'Duplicate_Count' [Duplicate_Payroll] ,Count(P.Id) 'Duplicate_payroll' FROM hr.Payroll P
       Inner Join Bean.Bill B on P.Id=B.PayrollId
       where P.CompanyId=@CompanyId  AND b.DocSubType='payroll' Group By
       P.Id Having Count(P.Id)>1
) as AA

) Books
PIVOT (
  SUM(SourcePayroll_Count) FOR HR_Payroll IN ([Source_PayrollCount], [Destination_BillPayrollCount], [Matching_Count], [Non_Matching_Count],[Duplicate_Count])
) Result;
END
GO
