USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[JournalListingparameters]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[JournalListingparameters]
	@CompanyId INT, @UserName Nvarchar(500)
AS 
Begin 
-----Service Entity
 --declare @CompanyValue varchar(100)=65

 ---Commented on 11-05-2020 to get the Short name
	-- select distinct SC.Name,SC.Id
	--	From Bean.JournalDetail as JD
	--	Inner Join Bean.Journal as J on J.Id=JD.JournalId
	--	Inner Join Common.Company as SC on SC.Id=J.ServiceCompanyId
	--	Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
	--where COA.CompanyId=@CompanyId 
	--order by SC.Name

	select distinct SC.ShortName as Name,SC.Id
		From Bean.JournalDetail(nolock) as JD
		Inner Join Bean.Journal(nolock) as J on J.Id=JD.JournalId
		Inner Join Common.Company(nolock) as SC on SC.Id=J.ServiceCompanyId
		Inner Join Common.CompanyUser(nolock) as CU on SC.parentId = CU.CompanyId
		Inner Join Common.CompanyUserDetail(nolock) as CUD on (CUD.ServiceEntityId = SC.Id and CU.Id = CUD.CompanyUserId)
		--Inner Join Bean.ChartOfAccount COA on COA.Id=JD.COAId
	where J.CompanyId=@CompanyId and CU.Username = @UserName
	order by SC.ShortName

	Select * into #Journal From ( 
--DocType
	select distinct JD.DocType, JD.DocSubType--,SC.Id
		From Bean.JournalDetail(nolock) as JD
		Inner Join Bean.Journal(nolock) as J on J.Id=JD.JournalId
		Inner Join Bean.ChartOfAccount(nolock) COA on COA.Id=JD.COAId
	where COA.CompanyId=@CompanyId 
	)as A

	Select Distinct docType from #Journal Where DocType Is Not Null Order By DocType
	Select Distinct DocSubType from #Journal Where DocSubType Is Not Null Order By DocSubType
	Drop table #Journal
--SubType
	--select distinct JD.DocSubType--,SC.Id
	--	From Bean.JournalDetail(nolock) as JD
	--	Inner Join Bean.Journal(nolock) as J on J.Id=JD.JournalId
	--	Inner Join Bean.ChartOfAccount(nolock) COA on COA.Id=JD.COAId
	--where COA.CompanyId=@CompanyId AND JD.DocSubType IS NOT NULL
	--Order By JD.DocSubType
END
GO
