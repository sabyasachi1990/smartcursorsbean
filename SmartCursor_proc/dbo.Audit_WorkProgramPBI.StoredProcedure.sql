USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_WorkProgramPBI]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Audit_WorkProgramPBI]
AS
BEGIN	
	-- Exec [dbo].[Audit_WorkProgramPBI]

	SELECT BH.AccountID,BH.LeadSheetName,BH.AccountName,BH.GLType,BH.GLDate,BH.Description,BH.Balance,BH.EntityType,BH.EntityName,convert(nvarchar(50), BH.EngagementId) EngagementId,
		BH.DocNo,BH.Currency,BH.MonthYear,BH.CyBalance,BH.PyBalance,BH.CyCredit, BH.CyDebit,BH.PyCredit,BH.PyDebit,BH.Debit,BH.Credit,BH.MonthOrder
	FROM 
	(
		Select TB.ID as AccountID,LS.LeadSheetName, TB.AccountName,  GL.EngagementId,GLD.Debit,GLD.Credit,

		case when Gltype='CY' then gl.CYorPYBalance else 0 end as CyBalance ,
        case when Gltype='PY' then gl.CYorPYBalance else 0 end as PyBalance,

		case when Gltype='CY' then GLD.Debit else 0 end as CyDebit ,
        case when Gltype='CY' then GLD.Credit else 0 end as CyCredit,

		case when Gltype='PY' then GLD.Debit else 0 end as PyDebit ,
        case when Gltype='PY' then GLD.Credit else 0 end as PyCredit,

		GL.GLType,  GLD.GLDate, GLD.Description, GLD.Balance, GLD.EntityType, GLD.EntityName,
		GLD.DocNo, GLD.Currency, Left(datename(MONTH,GLD.GLDate),3)+'-'+Right(Year(GLD.GLDate),2) as MonthYear, 
		Year(GLD.GLDate) as 'Year' ,Month(GLD.GLDate) as 'Month',

		Case When Len(month(GLD.GLDate))=1 then Cast(Concat(YEAR(GLD.GLDate),'1',
		month(GLD.GLDate)) As Int) Else cast(Concat(YEAR(GLD.GLDate),month(GLD.GLDate)+10) As int) End As MonthOrder

		From Audit.GeneralLedgerDetail GLD
		Inner Join Audit.GeneralLedgerImport GL On GL.Id = GLD.GeneralLedgerId
		Inner Join Audit.TrialBalanceImport TB On TB.AccountName = GL.AccountName
		Inner Join Audit.LeadSheet LS On LS.Id = TB.LeadSheetId
	) AS BH
	ORDER BY BH.MonthOrder
END
GO
