USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[AuditLSBlades]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec AuditLSBlades @CompanyId=1726,@EngagementId='547A28B9-36A4-4A7D-A411-10185C6C0F4A'
CREATE Procedure [dbo].[AuditLSBlades] 
@CompanyId Bigint,
@EngagementId Uniqueidentifier
As

--1.Account Receivables Turnover In Days
Select 'PY Account Receivables Turnover In Days' as Name1,PYARTO as Value1,'CY Account Receivables Turnover In Days' as Name2,CYARTO as Value2
From
( 
	Select PYARTO/365 PYARTO,CYARTO/365 CYARTO
	From
	(
		--Step 7
		Select PYTRadeReceivableAmount/nullif(PYrevenueAmount,0.00) PYARTO,CYTradeReceivableAmount/nullif(CYRevenueAmount,0.00) CYARTO
		From
		(
			--Step 6
			Select sum(PYrevenueAmount) PYrevenueAmount,sum(PYTRadeReceivableAmount) PYTRadeReceivableAmount,sum(CYRevenueAmount) CYRevenueAmount,sum(CYTradeReceivableAmount) CYTradeReceivableAmount
			From
			(
				--Step 5
				select LeadSheetName,sum(isnull(PYrevenueAmount,0)) PYrevenueAmount,sum(isnull(PYTRadeReceivableAmount,0)) PYTRadeReceivableAmount,sum(isnull(CYRevenueAmount,0)) CYRevenueAmount,sum(isnull(CYTradeReceivableAmount,0)) CYTradeReceivableAmount
				From
				(
					--Step 4
					select LeadSheetName,case when LeadSheetName='Revenue' then PYAmount end PYrevenueAmount,
						   case when LeadSheetName='Trade receivables' then PYAmount end PYTRadeReceivableAmount,
						   case when LeadSheetName='Revenue' then Final end CYRevenueAmount,
						   case when LeadSheetName='Trade receivables' then Final end CYTradeReceivableAmount
					From
					(
						--Step3
						select LeadSheetName,sum(PYAmount) PYAmount,sum(Final)Final
						From
						(
							--Step 2
							select LeadSheetName,case when PYCredit is null then PYDebit when PYCredit=0.00 then PYDebit when PYDebit is null then PYCredit when PYDebit=0.00 then PYCredit end PYAmount,Final,CYcredit,CYDebit
							From
							(   --step 1
								Select L.LeadsheetType,L.AccountClass,L.LeadSheetName,L.CreatedDate,
								TBI.AccountNumber,TBI.AccountName,TBI.AccountType,TBI.CYCredit,CYDebit,PYCredit,PYDebit,Final

								from audit.LeadSheet L
								Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id

								where LeadSheetId <> '00000000-0000-0000-0000-000000000000' and L.LeadsheetType in ('Assets','Income') and LeadSheetName in ('Trade receivables','Revenue')--and AccountClass='Current'
								and L.CompanyId=@CompanyId and TBI.EngagementId=@EngagementId
								--End of Step1
							) dt1
							--End of Step 2
						)dt2
						group by LeadSheetName
						--End of Step 3
					)dt3
					--End of Step4
				)dt4
				group by LeadSheetName,PYrevenueAmount,PYTRadeReceivableAmount,CYRevenueAmount,CYTradeReceivableAmount
				--End of Step 5
			)dt5
			--End of Step 6
		)dt6
		--Step 7
	)dt7
)dt8 

--2.Current Ratio
--DECLARE @COMPANYID INT =1726
Select 'PY Current Ratio' as Name1,[PY Current Ratio] as Value1,'CY Current Ratio' as Name2,[CY Current Ratio] Value2
From
(
	SELECT  (AssetsPYDebit/nullif(LiabilitiesPYCredit,0.00)) AS 'PY Current Ratio' ,(AssetsFinal/nullif(LiabilitiesFinal,0.00)) AS 'CY Current Ratio' FROM 
	(
	SELECT  SUM(AssetsPYDebit) AS AssetsPYDebit , SUM(LiabilitiesPYCredit) AS LiabilitiesPYCredit,
	SUM(AssetsFinal) AS AssetsFinal,SUM(LiabilitiesFinal) AS LiabilitiesFinal FROM 
	(
	select isnull(AssetsPYDebit,0) as AssetsPYDebit,isnull(LiabilitiesPYCredit,0) as LiabilitiesPYCredit,
	isnull(AssetsFinal,0) as AssetsFinal,isnull(LiabilitiesFinal,0) as LiabilitiesFinal  from 
	(
	SELECT case  when LeadsheetType='Assets' then PY end as 'AssetsPYDebit' ,
	 case  when LeadsheetType='Liabilities' then PY end as 'LiabilitiesPYCredit' ,
	  case  when LeadsheetType='Assets' then Final end as 'AssetsFinal', 
	   case  when LeadsheetType='Liabilities' then Final end as 'LiabilitiesFinal' 



	from 
	(
	SELECT LeadsheetType, PY,Final FROM 
	(
	SELECT LeadsheetType, SUM(PYDebit) AS 'PY',sum(Final)  as 'Final' FROM 
	(
	select LeadSheetId,Id, LeadsheetType as LeadsheetType,PYDebit , Final  FROM 
	(
	Select L.LeadsheetType,L.AccountClass,L.LeadSheetName,L.CreatedDate,TBI.LeadSheetId,L.Id,
	TBI.AccountNumber,TBI.AccountName,TBI.AccountType,TBI.CYCredit,CYDebit,PYCredit,PYDebit,Final

	from audit.LeadSheet L
	Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id

	where LeadSheetId <> '00000000-0000-0000-0000-000000000000' and L.LeadsheetType='Assets'
	and AccountClass='Current'
	and L.CompanyId=@CompanyId and TBI.EngagementId=@EngagementId
	) SS
	)MM
	GROUP BY LeadsheetType
	--GROUP BY LeadsheetType,LeadSheetId,Id
	--)JJ


	UNION ALL

	--LEFT JOIN
	--(
	---- Liabilities


	--SELECT LeadSheetId,Id,  ISNULL([Total Liabilities],0) AS 'Total Liabilities' FROM 
	--(
	SELECT  LeadsheetType,SUM(PYCredit) AS 'PY',sum(Final) as 'Final'  FROM 
	(
	 SELECT LeadSheetId,Id,LeadsheetType as LeadsheetType,PYCredit,Final FROM 
	 (
	Select L.LeadsheetType,L.AccountClass,L.LeadSheetName,L.CreatedDate,TBI.LeadSheetId,L.Id,
	TBI.AccountNumber,TBI.AccountName,TBI.AccountType,TBI.CYCredit,CYDebit,PYCredit,PYDebit,Final

	from audit.LeadSheet L
	Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id

	where LeadSheetId <> '00000000-0000-0000-0000-000000000000' and L.LeadsheetType='Liabilities' 
	and AccountClass='Current'
	and L.CompanyId=@CompanyId and TBI.EngagementId=@EngagementId
	) SS

	) DD
	GROUP BY LeadsheetType

	)LL

	   )SS
	   ) AA
	   ) ZZ
	   )TT
)dt1


--3.Financial Leverage Ratio
  --DECLARE @CompanyId INT =1726

Select 'PY Financial Leverage Ratio' as Name1,[PY Financial Leverage Ratio] Value1,'CY Financial Leverage Ratio' as Name2,[CY Financial Leverage Ratio] Value2
From
(

	SELECT  (LiabilitiesPYCredit/nullif(AssetsPYDebit,0.00)) AS 'PY Financial Leverage Ratio' ,(LiabilitiesFinal/nullif(AssetsFinal,0.00)) AS 'CY Financial Leverage Ratio' FROM 
	(
	SELECT  SUM(AssetsPYDebit) AS AssetsPYDebit , SUM(LiabilitiesPYCredit) AS LiabilitiesPYCredit,
	SUM(AssetsFinal) AS AssetsFinal,SUM(LiabilitiesFinal) AS LiabilitiesFinal FROM 
	(
	select isnull(AssetsPYDebit,0) as AssetsPYDebit,isnull(LiabilitiesPYCredit,0) as LiabilitiesPYCredit,
	isnull(AssetsFinal,0) as AssetsFinal,isnull(LiabilitiesFinal,0) as LiabilitiesFinal  from 
	(
	SELECT case  when LeadsheetType='Assets' then PY end as 'AssetsPYDebit' ,
	 case  when LeadsheetType='Liabilities' then PY end as 'LiabilitiesPYCredit' ,
	  case  when LeadsheetType='Assets' then Final end as 'AssetsFinal', 
	   case  when LeadsheetType='Liabilities' then Final end as 'LiabilitiesFinal' 



	from 
	(
	SELECT LeadsheetType, PY,Final FROM 
	(
	SELECT LeadsheetType, SUM(PYDebit) AS 'PY',sum(Final)  as 'Final' FROM 
	(
	select LeadSheetId,Id, LeadsheetType as LeadsheetType,PYDebit , Final  FROM 
	(
	Select L.LeadsheetType,L.AccountClass,L.LeadSheetName,L.CreatedDate,TBI.LeadSheetId,L.Id,
	TBI.AccountNumber,TBI.AccountName,TBI.AccountType,TBI.CYCredit,CYDebit,PYCredit,PYDebit,Final

	from audit.LeadSheet L
	Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id

	where LeadSheetId <> '00000000-0000-0000-0000-000000000000' and L.LeadsheetType='Assets'
	-- and AccountClass='Current'
	and L.CompanyId=@CompanyId and TBI.EngagementId=@EngagementId
	) SS
	)MM
	GROUP BY LeadsheetType
	--GROUP BY LeadsheetType,LeadSheetId,Id
	--)JJ


	UNION ALL

	--LEFT JOIN
	--(
	---- Liabilities


	--SELECT LeadSheetId,Id,  ISNULL([Total Liabilities],0) AS 'Total Liabilities' FROM 
	--(
	SELECT  LeadsheetType,SUM(PYCredit) AS 'PY',sum(Final) as 'Final'  FROM 
	(
	 SELECT LeadSheetId,Id,LeadsheetType as LeadsheetType,PYCredit,Final FROM 
	 (
	Select L.LeadsheetType,L.AccountClass,L.LeadSheetName,L.CreatedDate,TBI.LeadSheetId,L.Id,
	TBI.AccountNumber,TBI.AccountName,TBI.AccountType,TBI.CYCredit,CYDebit,PYCredit,PYDebit,Final

	from audit.LeadSheet L
	Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id

	where LeadSheetId <> '00000000-0000-0000-0000-000000000000' and L.LeadsheetType='Liabilities' 
	--and AccountClass='Current'
	and L.CompanyId=@CompanyId and TBI.EngagementId=@EngagementId
	) SS

	) DD
	GROUP BY LeadsheetType

	)LL
	 --pivot  
	 --  (  
	 --    sum(PY) for LeadsheetType in (Assets, Liabilities) 
	 --sum(Final) for LeadsheetType in (Assets, Liabilities) 
	 --  )pvt  
	   )SS
	   ) AA
	   ) ZZ
	   )TT
)dt1


--4.Working Capital
  --DECLARE @CompanyId INT =1726
Select 'PY Working Capital' as Name1,[PY Working Capital ] as Value1,'CY Working Capital' as Name2,[CY Working Capital ] as Value2
From
(
	SELECT  (AssetsPYDebit-LiabilitiesPYCredit) AS 'PY Working Capital ' ,(AssetsFinal-LiabilitiesFinal) AS 'CY Working Capital ' FROM 
	(
	SELECT  SUM(AssetsPYDebit) AS AssetsPYDebit , SUM(LiabilitiesPYCredit) AS LiabilitiesPYCredit,
	SUM(AssetsFinal) AS AssetsFinal,SUM(LiabilitiesFinal) AS LiabilitiesFinal FROM 
	(
	select isnull(AssetsPYDebit,0) as AssetsPYDebit,isnull(LiabilitiesPYCredit,0) as LiabilitiesPYCredit,
	isnull(AssetsFinal,0) as AssetsFinal,isnull(LiabilitiesFinal,0) as LiabilitiesFinal  from 
	(
	SELECT case  when LeadsheetType='Assets' then PY end as 'AssetsPYDebit' ,
	 case  when LeadsheetType='Liabilities' then PY end as 'LiabilitiesPYCredit' ,
	  case  when LeadsheetType='Assets' then Final end as 'AssetsFinal', 
	   case  when LeadsheetType='Liabilities' then Final end as 'LiabilitiesFinal' 



	from 
	(
	SELECT LeadsheetType, PY,Final FROM 
	(
	SELECT LeadsheetType, SUM(PYDebit) AS 'PY',sum(Final)  as 'Final' FROM 
	(
	select LeadSheetId,Id, LeadsheetType as LeadsheetType,PYDebit , Final  FROM 
	(
	Select L.LeadsheetType,L.AccountClass,L.LeadSheetName,L.CreatedDate,TBI.LeadSheetId,L.Id,
	TBI.AccountNumber,TBI.AccountName,TBI.AccountType,TBI.CYCredit,CYDebit,PYCredit,PYDebit,Final

	from audit.LeadSheet L
	Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id

	where LeadSheetId <> '00000000-0000-0000-0000-000000000000' and L.LeadsheetType='Assets'
	and AccountClass='Current'
	and L.CompanyId=@CompanyId and TBI.EngagementId=@EngagementId
	) SS
	)MM
	GROUP BY LeadsheetType
	--GROUP BY LeadsheetType,LeadSheetId,Id
	--)JJ


	UNION ALL

	--LEFT JOIN
	--(
	---- Liabilities


	--SELECT LeadSheetId,Id,  ISNULL([Total Liabilities],0) AS 'Total Liabilities' FROM 
	--(
	SELECT  LeadsheetType,SUM(PYCredit) AS 'PY',sum(Final) as 'Final'  FROM 
	(
	 SELECT LeadSheetId,Id,LeadsheetType as LeadsheetType,PYCredit,Final FROM 
	 (
	Select L.LeadsheetType,L.AccountClass,L.LeadSheetName,L.CreatedDate,TBI.LeadSheetId,L.Id,
	TBI.AccountNumber,TBI.AccountName,TBI.AccountType,TBI.CYCredit,CYDebit,PYCredit,PYDebit,Final

	from audit.LeadSheet L
	Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id

	where LeadSheetId <> '00000000-0000-0000-0000-000000000000' and L.LeadsheetType='Liabilities' 
	and AccountClass='Current'
	and L.CompanyId=@CompanyId and TBI.EngagementId=@EngagementId
	) SS

	) DD
	GROUP BY LeadsheetType

	)LL
	 --pivot  
	 --  (  
	 --    sum(PY) for LeadsheetType in (Assets, Liabilities) 
	 --sum(Final) for LeadsheetType in (Assets, Liabilities) 
	 --  )pvt  
	   )SS
	   ) AA
	   ) ZZ
	   )TT
)dt1

--5.Inventory Turnover
--Declare @CompanyId Int=1726

Select 'PY Inventory Turnover' as Name1,PYInventoryTurnover as Value1,'CY Inventory Turnover' as Name2,CYInventoryTurnover as Value2
From
( 
    --Step 7
 Select PYDirectcostsAmount/(nullif(PYInventoryAmount,0.00)) PYInventoryTurnover,CYDirectcostsAmount/nullif(CYInventoryAmount,0.00) CYInventoryTurnover
 From
 (
  --Step 6
  Select sum(PYDirectcostsAmount) PYDirectcostsAmount,sum(PYInventoryAmount) PYInventoryAmount,sum(CYDirectcostsAmount) CYDirectcostsAmount,sum(CYInventoryAmount) CYInventoryAmount
  From
  (
   --Step 5
   select LeadSheetName,sum(isnull(PYDirectcostsAmount,0)) PYDirectcostsAmount,sum(isnull(PYInventoryAmount,0)) PYInventoryAmount,sum(isnull(CYDirectcostsAmount,0)) CYDirectcostsAmount,sum(isnull(CYInventoryAmount,0)) CYInventoryAmount
   From
   (
    --Step 4
    select LeadSheetName,case when LeadSheetName='Direct costs' then PYAmount end PYDirectcostsAmount,
        case when LeadSheetName='Inventories' then PYAmount end PYInventoryAmount,
        case when LeadSheetName='Direct costs' then Final end CYDirectcostsAmount,
        case when LeadSheetName='Inventories' then Final end CYInventoryAmount
    From
    (
     --Step3
     select LeadSheetName,sum(PYAmount) PYAmount,sum(Final)Final
     From
     (
      --Step 2
      select LeadSheetName,case when PYCredit is null then PYDebit when PYCredit=0.00 then PYDebit when PYDebit is null then PYCredit when PYDebit=0.00 then PYCredit end PYAmount,Final,CYcredit,CYDebit
      From
      (   --step 1
       Select L.LeadsheetType,L.AccountClass,L.LeadSheetName,L.CreatedDate,
       TBI.AccountNumber,TBI.AccountName,TBI.AccountType,TBI.CYCredit,CYDebit,PYCredit,PYDebit,Final

       from audit.LeadSheet L
       Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id

       where LeadSheetId <> '00000000-0000-0000-0000-000000000000' --and L.LeadsheetType in ('Assets','Income') 
    and LeadSheetName in ('Direct costs','Inventories')--and AccountClass='Current'
       and L.CompanyId=@CompanyId and TBI.EngagementId=@EngagementId
       --End of Step1
      ) dt1
      --End of Step 2
     )dt2
     group by LeadSheetName
     --End of Step 3
    )dt3
    --End of Step4
   )dt4
   group by LeadSheetName,PYDirectcostsAmount,PYInventoryAmount,CYDirectcostsAmount,CYInventoryAmount
   --End of Step 5
 )dt5
  --End of Step 6
 )dt6
 --Step 7
)dt7

--6. Top 10 LeadSheets

Declare @top10Leadsheets table (leadsheet varchar(max),Rank int)
Insert Into @top10Leadsheets
--Step 3
Select top 10 LeadSheetName,Rank
From
(
	Select LeadSheetName,Final,DENSE_RANK() over (order by final desc) Rank
	From
	(  
		 --Step2
		Select LeadSheetName,sum(Final) Final
		From
		(
		--step 1
				Select L.LeadsheetType,L.AccountClass,L.LeadSheetName,--L.CreatedDate,
				TBI.AccountNumber,TBI.AccountName,TBI.AccountType,TBI.CYCredit,CYDebit,PYCredit,PYDebit,isnull(Final,0) Final

				from audit.LeadSheet L
				Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id
				--Inner join Audit.LeadSheetCategories LSC on LSC.LeadSheetId=L.Id
				where TBI.LeadSheetId <> '00000000-0000-0000-0000-000000000000' --and L.LeadsheetType in ('Assets','Income') and LeadSheetName in ('Trade receivables','Revenue')--and AccountClass='Current'
				and L.CompanyId=@CompanyId and TBI.EngagementId=@EngagementId
		--End of Step1
		)st1
		group by LeadSheetName
		--End of Step2 
	)st2
	--end of Step 3
)st3
order by Rank

--Select * from @top10Leadsheets

--End of Top 10 lead Sheets

/*Main Query*/
--Final Starting
Select LeadSheetName,AccountName,Period,Amount
From
(
	--Step 4
	Select dt3.*,t10.Rank
	From
	(
		--Step 3
		Select /*LeadsheetType,*/LeadSheetName,AccountName,[Period],[Amount]
		From
		(
			--Step 2
			Select LeadsheetType,LeadSheetName,AccountName,Final CYAmount,
				   isnull(Case when PYCredit is null then PYDebit when PYCredit=0.00 then PYDebit
						when PYDebit is null then PYCredit when PYDebit=0.00 then PYCredit else PYCredit
					end,0) PYAmount
			From
			(
				--step 1
				Select L.LeadsheetType,L.AccountClass,L.LeadSheetName,--L.CreatedDate,
				TBI.AccountNumber,TBI.AccountName,TBI.AccountType,TBI.CYCredit,CYDebit,PYCredit,PYDebit,Final

				from audit.LeadSheet L
				Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id
				--Inner join Audit.LeadSheetCategories LSC on LSC.LeadSheetId=L.Id
				where TBI.LeadSheetId <> '00000000-0000-0000-0000-000000000000' --and L.LeadsheetType in ('Assets','Income') and LeadSheetName in ('Trade receivables','Revenue')--and AccountClass='Current'
				and L.CompanyId=@CompanyId and TBI.EngagementId=@EngagementId
				--and LeadSheetName in (select * from @top10Leadsheets)
				--End of Step1
			) dt1
			--End of Step 2
		) dt2
		unpivot
		(
			Amount for [Period] in ([CYAmount],[PYAmount])
		) upvt
		--order by LeadSheetName,AccountName
		-- End of step3
	) dt3
	join @top10Leadsheets t10 on t10.leadsheet=dt3.LeadSheetName
	--End of Step 4
) Final
order by Rank,LeadSheetName
--End of Final

--7. least 10 Leadsheets 

Declare @Least10Leadsheets table (leadsheet varchar(max),Rank int)
Insert Into @Least10Leadsheets
--Step 3
Select top 10 LeadSheetName,Rank
From
(
	Select LeadSheetName,Final,DENSE_RANK() over (order by final asc) Rank
	From
	(  
		 --Step2
		Select LeadSheetName,sum(Final) Final
		From
		(
		--step 1
				Select L.LeadsheetType,L.AccountClass,L.LeadSheetName,--L.CreatedDate,
				TBI.AccountNumber,TBI.AccountName,TBI.AccountType,TBI.CYCredit,CYDebit,PYCredit,PYDebit,isnull(Final,0) Final

				from audit.LeadSheet L
				Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id
				--Inner join Audit.LeadSheetCategories LSC on LSC.LeadSheetId=L.Id
				where TBI.LeadSheetId <> '00000000-0000-0000-0000-000000000000' --and L.LeadsheetType in ('Assets','Income') and LeadSheetName in ('Trade receivables','Revenue')--and AccountClass='Current'
				and L.CompanyId=@CompanyId and TBI.EngagementId=@EngagementId
		--End of Step1
		)st1
		group by LeadSheetName
		--End of Step2 
	)st2
	--end of Step 3
)st3
order by Rank

--Select * from @Least10Leadsheets

--End of Laeast 10 lead Sheets

/*Main Query*/
--Final Starting
Select LeadSheetName,AccountName,Period,Amount
From
(
	--Step 4
	Select dt3.*,L10.Rank
	From
	(
		--Step 3
		Select /*LeadsheetType,*/LeadSheetName,AccountName,[Period],[Amount]
		From
		(
			--Step 2
			Select LeadsheetType,LeadSheetName,AccountName,Final CYAmount,
				   isnull(Case when PYCredit is null then PYDebit when PYCredit=0.00 then PYDebit
						when PYDebit is null then PYCredit when PYDebit=0.00 then PYCredit else PYCredit
					end,0) PYAmount
			From
			(
				--step 1
				Select L.LeadsheetType,L.AccountClass,L.LeadSheetName,--L.CreatedDate,
				TBI.AccountNumber,TBI.AccountName,TBI.AccountType,TBI.CYCredit,CYDebit,PYCredit,PYDebit,Final

				from audit.LeadSheet L
				Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id
				--Inner join Audit.LeadSheetCategories LSC on LSC.LeadSheetId=L.Id
				where TBI.LeadSheetId <> '00000000-0000-0000-0000-000000000000' --and L.LeadsheetType in ('Assets','Income') and LeadSheetName in ('Trade receivables','Revenue')--and AccountClass='Current'
				and L.CompanyId=@CompanyId and TBI.EngagementId=@EngagementId
				--and LeadSheetName in (select * from @top10Leadsheets)
				--End of Step1
			) dt1
			--End of Step 2
		) dt2
		unpivot
		(
			Amount for [Period] in ([CYAmount],[PYAmount])
		) upvt
		--order by LeadSheetName,AccountName
		-- End of step3
	) dt3
	join @Least10Leadsheets L10 on L10.leadsheet=dt3.LeadSheetName
	--End of Step 4
) Final
order by Rank,LeadSheetName
--End of Final

--8. LeadSheet Type
Select LeadsheetType,LeadSheetName,Period,Amount from 
(
	select LeadsheetType,LeadSheetName,ISNULL(CYAmount,0) AS CYAmount,ISNULL(PYAmount,0) AS PYAmount  From
	(
		Select L.LeadsheetType,--TBI.EngagementId,--L.AccountClass,
		L.LeadSheetName,--L.CreatedDate,
		--TBI.AccountNumber,TBI.AccountName,TBI.AccountType,
		--TBI.CYCredit CYCredit,CYDebit CYDebit,PYCredit PYCredit,PYDebit PYDebit,
		Final CYAmount,
		case when PYCredit=0 then PYDebit
		when PYCredit is null then  PYDebit 
		When PYDebit=0 then PYCredit
		When PYDebit is Null then PYCredit
		 End AS PYAmount 
  

		from audit.LeadSheet L
		Inner Join Audit.TrialBalanceImport TBI on TBI.LeadSheetId=L.Id

		where LeadSheetId <> '00000000-0000-0000-0000-000000000000' --and L.LeadsheetType='Assets' and AccountClass='Current'
		and L.CompanyId=@CompanyId AND TBI.EngagementId=@EngagementId
	)SK
)KK
Unpivot
(
Amount For Period IN (CYAmount,PYAmount)
)UPVT
GO
