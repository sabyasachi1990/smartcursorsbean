USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[IncomeandExpenses]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[IncomeandExpenses]
 as 
 begin 
 
 select CompanyId,Name,TrialBalanceImportId,LeadsheetId,LeadSheetCategoriesId,LeadsheetType,LeadSheetName,Code,Category,AccountName,
 case when LeadsheetType='Income' then (-1)*([Prior Year]) when LeadsheetType='Expenses' then (-1)*([Prior Year]) end [Prior Year],
 case when LeadsheetType='Income' then (-1)*([Current Year]) when LeadsheetType='Expenses' then (-1)*([Current Year]) end as [Current Year] ,Ajes,
 case when LeadsheetType='Income' then (-1)*(Final) when LeadsheetType='Expenses' then (-1)*(Final) end as Final,
 Status,EngagementId,LeadsheetEngagementId,convert (nvarchar(100),isnull(gg.Recorder,0)) as Recorder ,convert (nvarchar(100),isnull(CategoryRecorder,0)) as CategoryRecorder ,
   (isnull(case when LeadsheetType='Income' then (-1)*([Final]) when LeadsheetType='Expenses' then (-1)*([Final]) end,0) )-(isnull(case when LeadsheetType='Income' then (-1)*([Prior Year]) when LeadsheetType='Expenses' then (-1)*([Prior Year])end,0))  as 'Change Amount',
      case when isnull(case when LeadsheetType='Income' then (-1)*([Prior Year]) when LeadsheetType='Expenses' then (-1)*([Prior Year])end,0)<>0 then 
	  ((isnull(case when LeadsheetType='Income' then (-1)*([Final]) when LeadsheetType='Expenses' then (-1)*([Final]) end,0) )-(isnull(case when LeadsheetType='Income' then (-1)*([Prior Year]) when LeadsheetType='Expenses' then (-1)*([Prior Year])end,0))
	  /(isnull(case when LeadsheetType='Income' then (-1)*([Prior Year]) when LeadsheetType='Expenses' then (-1)*([Prior Year])end,0)))*100 end as 'Change %',
	  (isnull(case when LeadsheetType='Income' then (-1)*([Prior Year]) when LeadsheetType='Expenses' then (-1)*([Prior Year])end,0))*100 as 'Change %1'

 from 
(
select A.CompanyId,t.id as TrialBalanceImportId ,t.LeadsheetId,A.LeadSheetCategoriesId,A.LeadsheetType,A.LeadSheetName,A.Code ,[Account Category] as Category ,AccountName,(t.PreviousYearBalance) as 'Prior Year',(t.PBCBalance )as 'Current Year' ,
t.AJEs as Ajes,(t.Final) AS Final ,T.Status,t.EngagementId,A.LeadsheetEngagementId,T.RecOrder
from Audit.TrialBalanceImport T
inner join
(
Select  l.[Index],L.CompanyId,l.LeadSheetName,l.LeadsheetType,ws.Code,ws.ShortCode,l.Status,l.AccountClass,l.EngagementId AS LeadsheetEngagementId,l.id LeadsheetId,ls.id as LeadSheetCategoriesId,Ls.Name AS [Account Category]
from Audit.LeadSheet L
Inner join Audit.LeadSheetCategories  Ls on Ls.LeadsheetId=l.Id
Inner join audit.WPSetup Ws on Ws.Id=l.WorkProgramId and ws.EngagementId=l.EngagementId
 where L.LeadsheetType in ('Income','Expenses') 
)as A on T.LeadSheetId=A.LeadsheetId and T.CategoryId=A.LeadSheetCategoriesId 
 union all 
select L.CompanyId,t.id as TrialBalanceImportId ,t.LeadsheetId,null as LeadSheetCategoriesId,L.LeadsheetType,L.LeadSheetName,ws.Code ,'Not categorized' as Category ,AccountName,(t.PreviousYearBalance) as 'Prior Year',(t.PBCBalance )as 'Current Year' ,
t.AJEs as Ajes,(t.Final) AS Final ,T.Status,t.EngagementId,l.EngagementId as LeadsheetEngagementId,T.RecOrder
from Audit.TrialBalanceImport T
inner join Audit.LeadSheet L on l.id=t.LeadSheetId
Inner join audit.WPSetup Ws on Ws.Id=l.WorkProgramId and ws.EngagementId=l.EngagementId
 where L.LeadsheetType in ('Income','Expenses')  and CategoryId is null
 )hh
 inner join 
 (
 	 select Distinct c.Name,sc.name as LeadSheetNameOrder,TypeId,sc.Recorder,c.Recorder as CategoryRecorder ,c.EngagementId as CategoryEngagementId  from Audit.Category c
	 inner join Audit.SubCategory sc on c.id=sc.ParentId
	 )gg on gg.CategoryEngagementId=hh.EngagementId and gg.TypeId=hh.LeadSheetId
	 order by CategoryRecorder desc,gg.Recorder asc
end
GO
