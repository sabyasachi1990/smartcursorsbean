USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Payroll_Bean_BillPayroll_Syncing_SP_NonMatched_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[HR_Payroll_Bean_BillPayroll_Syncing_SP_NonMatched_New]
-- Exec [dbo].[HR_Payroll_Bean_BillPayroll_Syncing_SP_NonMatched_New] 20
	@CompanyId Bigint
As
Begin

	SELECT Id 'NonMatching_HR_PayrollId in Bean Payroll Bill', PayrollStatus
	FROM hr.Payroll Where CompanyId=@CompanyId and id NOT IN  
	(SELECT PayrollId FROM Bean.Bill Where CompanyId=@CompanyId and DocSubType='Payroll')

	SELECT E.PayrollId 'Paroll Duplicate Id in Bean Payroll Bill', Count(E.PayrollId)'Duplicate_Count'  
	From Bean.Bill E
	Inner Join HR.Payroll C on C.Id=E.PayrollId
	Where E.CompanyId=@CompanyId  and DocSubType='Payroll'
	Group By E.PayrollId Having Count(E.PayrollId)>1

END


GO
