USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[JournalListingDocSubTypeparameters]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[JournalListingDocSubTypeparameters]
--Declare	
--@CompanyId INT=243,
--	@DocType Varchar(MAX)='Credit Memo,Debit Note'
@CompanyId INT,
@DocType NVarchar(MAX)
AS 
Begin 
IF @DocType IS NOT NULL
Begin
--SubType
	select distinct JD.DocType,JD.DocSubType--,SC.Id
		From Bean.JournalDetail as JD
		Inner Join Bean.Journal as J on J.Id=JD.JournalId
		Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
	where COA.CompanyId=@CompanyId AND JD.DocSubType IS NOT NULL
	        AND JD.DocType IN (select items from dbo.SplitToTable(@DocType,','))
	Order By JD.DocSubType

	END
	ELSE
IF @DocType IS NULL
BEGIN
 --SubType
	select distinct JD.DocType,JD.DocSubType--,SC.Id
		From Bean.JournalDetail as JD
		Inner Join Bean.Journal as J on J.Id=JD.JournalId
		Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
	where COA.CompanyId=@CompanyId AND JD.DocSubType IS NOT NULL AND JD.DocType IS NOT NULL
	Order By JD.DocSubType
	END 
	 END
GO
