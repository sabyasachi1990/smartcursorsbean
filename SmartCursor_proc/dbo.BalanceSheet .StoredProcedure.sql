USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BalanceSheet ]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [dbo].[BalanceSheet ]
 as 
 begin 
 
	  select CompanyId,LeadsheetId,LeadSheetCategoriesId,LeadsheetType,LeadSheetName,Category,AccountName,
 case when LeadsheetType in ('Equity','Liabilities')   then (-1)*([Prior Year]) else ([Prior Year]) end [Prior Year],
 case when LeadsheetType in ('Equity','Liabilities')   then (-1)*([Current Year]) else ([Current Year]) end as [Current Year] ,Ajes,
 case when LeadsheetType in ('Equity','Liabilities')   then (-1)*(Final) else (Final) end as Final,
 --[Prior Year],[Current Year],Ajes,Final,
EngagementId

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
 where L.LeadsheetType not in ('Income','Expenses') 
)as A on T.LeadSheetId=A.LeadsheetId and T.CategoryId=A.LeadSheetCategoriesId 
 union all 
select L.CompanyId,t.id as TrialBalanceImportId ,t.LeadsheetId,null as LeadSheetCategoriesId,L.LeadsheetType,L.LeadSheetName,ws.Code ,'Not categorized' as Category ,AccountName,(t.PreviousYearBalance) as 'Prior Year',(t.PBCBalance )as 'Current Year' ,
t.AJEs as Ajes,(t.Final) AS Final ,T.Status,t.EngagementId,l.EngagementId as LeadsheetEngagementId,T.RecOrder
from Audit.TrialBalanceImport T
inner join Audit.LeadSheet L on l.id=t.LeadSheetId
Inner join audit.WPSetup Ws on Ws.Id=l.WorkProgramId and ws.EngagementId=l.EngagementId
 where L.LeadsheetType not in ('Income','Expenses')   and CategoryId is null
 )hh
 left join 
 (
 	 select Distinct c.Name,sc.name as LeadSheetNameOrder,TypeId,sc.Recorder,c.Recorder as CategoryRecorder ,c.EngagementId as CategoryEngagementId  from Audit.Category c
	 inner join Audit.SubCategory sc on c.id=sc.ParentId
	 )gg on gg.CategoryEngagementId=hh.EngagementId and gg.TypeId=hh.LeadSheetId



	 union all

	  select  L.CompanyId,l.id LeadsheetId,ls.id as LeadSheetCategoriesId,l.LeadsheetType,l.LeadSheetName ,Ls.Name AS Category, 'NetIncome' as AccountName ,
	  [Prior Year],  [Current Year],Ajes, Final,l.EngagementId from Audit.LeadSheet L
      Inner join Audit.LeadSheetCategories  Ls on Ls.LeadsheetId=l.Id
   inner join 
 (
  select CompanyId,EngagementId,sum([Prior Year]) as [Prior Year], sum([Current Year]) as [Current Year],
  sum(Ajes) as Ajes,sum(Final) as Final from 
 (
 select CompanyId,EngagementId,Name,
 case when LeadsheetType='Income' then (-1)*([Prior Year]) when LeadsheetType='Expenses' then (-1)*([Prior Year]) end [Prior Year],
 case when LeadsheetType='Income' then (-1)*([Current Year]) when LeadsheetType='Expenses' then (-1)*([Current Year]) end as [Current Year] ,Ajes,
 case when LeadsheetType='Income' then (-1)*(Final) when LeadsheetType='Expenses' then (-1)*(Final) end as Final
 ,convert (nvarchar(100),isnull(gg.Recorder,0)) as Recorder ,convert (nvarchar(100),isnull(CategoryRecorder,0)) as CategoryRecorder 
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
	 )gg
	 --where EngagementId='0d657e37-3ab3-4223-a5f8-7dbbf9e45345'
	 group by CompanyId,EngagementId
	 )  gg on  gg.CompanyId=L.CompanyId and   gg.EngagementId=l.EngagementId
    where   ls.name='Net income' and LeadSheetName='Retained earnings' 


end
GO
