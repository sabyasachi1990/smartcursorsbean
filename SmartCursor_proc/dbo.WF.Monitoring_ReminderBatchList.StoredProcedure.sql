USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF.Monitoring_ReminderBatchList]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[WF.Monitoring_ReminderBatchList]
AS
BEGIN 

select gg.CaseNumber,gg.CaseId,gg.BAL as OutStandingBalanceFee ,gg.Fee as CaseFee,ff.casefee as [Reminder CaseFee],Date,'CaseID Not in Reminder' Remarks from 
(
SELECT CaseNumber,CaseId,BAL,Fee,Date FROM 
(
select b.CaseId,sum(ISNULL(OutStandingBalanceFee,0)) as BAL,A.Fee,A.CaseNumber,CAST(A.CreatedDate  AS DATE) Date from WorkFlow.CaseGroup a
inner join WorkFlow.Invoice b on b.CaseId=a.Id where a.Status=1  GROUP BY b.CaseId,A.Fee,A.CaseNumber,A.CreatedDate 
)F WHERE BAL<>0.00
)gg
left join
(
select CaseId,sum(casefee) as casefee from 
(
select b.CaseId,b.casefee  from common.SOAReminderBatchListDetails b
inner join common.SOAReminderBatchList c on c.id=b.MasterId group by b.CaseId,b.casefee
)kk
group by CaseId
)ff on ff.CaseId=gg.CaseId
where ff.CaseId is null 

union all 
 select gg.CaseNumber,gg.CaseId,gg.BAL as OutStandingBalanceFee ,gg.Fee as CaseFee,ff.casefee as [Reminder CaseFee],Date,'CaseFee  Not Matched in Reminder CaseFee' Remarks from 
(
SELECT CaseNumber,CaseId,BAL,Fee,Date FROM 
(
select b.CaseId,sum(ISNULL(OutStandingBalanceFee,0)) as BAL,A.Fee,A.CaseNumber,CAST(A.CreatedDate  AS DATE) Date from WorkFlow.CaseGroup a
inner join WorkFlow.Invoice b on b.CaseId=a.Id where a.Status=1  GROUP BY b.CaseId,A.Fee,A.CaseNumber,A.CreatedDate 
)F WHERE BAL<>0.00
)gg
left join
(
select CaseId,sum(casefee) as casefee from 
(
select b.CaseId,b.casefee  from common.SOAReminderBatchListDetails b
inner join common.SOAReminderBatchList c on c.id=b.MasterId group by b.CaseId,b.casefee
)kk
group by CaseId
)ff on ff.CaseId=gg.CaseId
where ff.CaseId is not null  and ff.casefee<>gg.Fee
END 
GO
