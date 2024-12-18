USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_Blade2]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Audit_Blade2](@accountName Nvarchar(200),@engagementId uniqueidentifier)
AS BEGIN 
 
 Declare @accountNames TABLE ( items VARCHAR(MAX))

 --insert into  @accountNames  select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @accountName FOR XML PATH('')), 1),',')

 Select Name, Value, MonthYear, AccountName 
 From 
 (
 Select (Cydebit-Cycredit) as CyBalance,Cycredit,Cydebit,(Pydebit-Pycredit) as PyBalance,Pycredit,Pydebit,Month,Year,MonthYear,AccountName,GLDate from   
  (
   Select gl.AccountName,

     case when Gltype='PY' then isnull (gld.Debit,0) else 0 end as Pydebit,
   case when Gltype='PY' then isnull (gld.Credit,0) else 0 end as Pycredit,
   case when Gltype='CY' then isnull (gld.Debit,0) else 0 end as Cydebit,
   case when Gltype='CY' then isnull (gld.Credit,0) else 0 end as Cycredit ,  
   --case when Gltype='CY' then isnull (gl.CYorPYBalance,0) else 0 end as CyBalance ,
   --case when Gltype='PY' then isnull (gl.CYorPYBalance,0) else 0 end as PyBalance,
   
    gld.GLDate, 
   Left(datename(MONTH, gld.GLDate),3)+'-'+Right(Year(gld.GLDate),2) as MonthYear,Year( gld.GLDate) as 'Year' ,Month( gld.GLDate) as 'Month'
   From Audit.GeneralLedgerImport as gl 
   Join Audit.GeneralLedgerDetail as gld on gl.Id = gld.GeneralLedgerId 
   Where gl.EngagementId='64b667d6-8fed-4c9e-9b9d-fad5c5169324' and 
   gl.AccountName in
   (
    'Bank Charges'
   )
  )  as ssk
 ) as d
 UNPIVOT
 (  
  Value for Name in (CyBalance, PyBalance)
 ) PVT
 Order By Year, Month
END
GO
