USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_WorkProgram_DescriptiveStatistics]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Audit_WorkProgram_DescriptiveStatistics] 
	
AS
BEGIN
	
Select DISTINCT  TB.ID,tb.AccountName,
		case when Gltype='CY' then GLD.Debit else 0 end as CyDebit ,
        case when Gltype='CY' then GLD.Credit else 0 end as CyCredit,

		case when Gltype='PY' then GLD.Debit else 0 end as PyDebit ,
        case when Gltype='PY' then GLD.Credit else 0 end as PyCredit
into #Temp_Consolidate
		From Audit.GeneralLedgerDetail GLD
		Inner Join Audit.GeneralLedgerImport GL On GL.Id = GLD.GeneralLedgerId
		Inner Join Audit.TrialBalanceImport TB On TB.AccountName = GL.AccountName
		Inner Join Audit.LeadSheet LS On LS.Id = TB.LeadSheetId
		
Select ID,AccountName,'Sum' as Name, SUM(CyDebit) as CYDebit,
									 SUM(CyCredit) as CyCredit,
									 SUM(PyDebit) as PyDebit,
									 SUM(PyCredit) as PyCredit
from #Temp_Consolidate group by AccountName,ID 

union all

Select ID,AccountName,'Count' as Name,Count(ID) as CYDebit, 
									  Count(ID) as CyCredit ,
									  Count(ID) as PyDebit, 
									  Count(ID) as PyCredit 
from #Temp_Consolidate  group by AccountName,ID

union all

Select ID,AccountName,'Min' as Name,MIN(CyDebit) as CYDebit, 
									MIN(CyCredit) as CyCredit,
									MIN(PyDebit) as PyDebit,
									MIN(PyCredit) as PyCredit from #Temp_Consolidate group by AccountName,ID

union all

Select ID,AccountName,'Max' as Name,Max(CyDebit) as CYDebit, 
									Max(CyCredit) as CyCredit,
									MAX(PyDebit) as PyDebit,
									MAX(PyCredit) as PyCredit from #Temp_Consolidate group by AccountName,ID

union all

Select ID,AccountName,'Range' as Name, Max(CyDebit)-MIn(CyDebit) as CYDebit, 
									   Max(CyCredit)-MIN(CyCredit) as CYCredit,
									   Max(PyDebit)-MIn(PyDebit) as PyDebit, 
									   Max(PyCredit)-MIN(PyCredit) as PYCredit
from #Temp_Consolidate group by AccountName,ID

union all

Select ID,AccountName,'StdDev' as Name, isnull(Cast(STDEV(Isnull(CyDebit,0)) As int),0) As CyDebit, 
										isnull(Cast(STDEV(Isnull(CyCredit,0)) As int),0) As CyCredit,
										isnull(Cast(STDEV(Isnull(PyDebit,0)) As int),0) As PyDebit, 
										isnull(Cast(STDEV(Isnull(PyCredit,0)) As int),0) As PyCredit
from #Temp_Consolidate group by AccountName,ID

Union all

 Select ID,AccountName,'StdDev' as Name, isnull(Cast(Var(Isnull(CyDebit,0)) As decimal(38,2)),0) As CyDebit,
										 isnull(Cast(Var(Isnull(CyCredit,0)) As decimal(38,2)),0) As CyCredit,
										 isnull(Cast(Var(Isnull(PyDebit,0)) As decimal(38,2)),0) As PyDebit, 
										 isnull(Cast(Var(Isnull(PyCredit,0)) As decimal(38,2)),0) As PyCredit
 from #Temp_Consolidate group by AccountName,ID

 Union all

 Select ID,AccountName,'StdError' as Name, isnull(Cast(STDEV(Isnull(CyDebit,0))/SQRT(Count(id)) As int),0) CyDebit,
										 isnull(Cast(STDEV(Isnull(CyCredit,0))/SQRT(Count(id)) As int),0) CyCredit,
										 isnull(Cast(STDEV(Isnull(PyDebit,0))/SQRT(Count(id)) As int),0) PyDebit,
										 isnull(Cast(STDEV(Isnull(PyCredit,0))/SQRT(Count(id)) As int),0) PyCredit
 from #Temp_Consolidate group by AccountName,ID

 END
GO
