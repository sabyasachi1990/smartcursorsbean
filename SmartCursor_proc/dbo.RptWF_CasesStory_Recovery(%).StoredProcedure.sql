USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RptWF_CasesStory_Recovery(%)]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[RptWF_CasesStory_Recovery(%)]
As
Begin
Select  [Entity Name],[Clients Count] AS ClientId,[Cases Count] AS SourceCaseId,CompanyId as TenantId, CaseNumber 'Case Ref No',State,
Case when TurnR>0 then TurnR  end as TurnR,
Case when OverD>0 then OverD end as OverD,
Case when OverR>0 then OverR  end as OverR,
 ISNULL([Tgt Rec],0.00) 'Tgt Rec',ISNULL([Pln Rec],0.00) 'Pln Rec',ISNULL([Act Rec],0.00) 'Act Rec' ,
  CASE WHEN  isnull([Act Rec],0) <40 then '<40%'
 WHEN  isnull([Act Rec],0) between 40 and 59 then '40% to 59%'
 WHEN  isnull([Act Rec],0) >50 then '>59%' else 'NA'
 END AS ActRecovery, CASE WHEN isnull( [Pln Rec],0) <40 then '<40%'
 WHEN  isnull( [Pln Rec],0) between 40 and 59 then '40% to 59%'
 WHEN  isnull( [Pln Rec],0) >50 then '>59%' else 'NA'
 END AS PlnRecovery,
  CASE WHEN  ISNULL([Tgt Rec],0) <40 then '<40%'
 WHEN  ISNULL([Tgt Rec],0) between 40 and 59 then '40% to 59%'
 WHEN  ISNULL([Tgt Rec],0) >50 then '>59%' else 'NA'
 END AS TgtRecovery,
 
 [Cases Fee] Fee

from

(

Select CG.id as  'Cases Count',CG.ClientId 'Clients Count',
Sum(CG.Fee) 'Cases Fee',C.Name 'Entity Name',CG.CaseNumber,
Case When CG.Stage='Assigned' then 'Assigned'
When CG.Stage='Cancelled' then 'Cancelled'
When CG.Stage='Approve' then 'Approved'
When CG.Stage='For Approval' then 'For Approval'
When CG.Stage='Complete' then 'Completed'
When CG.Stage='Unassigned' then 'Unassigned'
When CG.Stage='On hold' then 'On hold'
When CG.Stage='In-Progress' AND CG.Likelihood='Low' then 'In-Progress – Low'
When CG.Stage='In-Progress' AND CG.Likelihood='Med' then 'In-Progress – Med'
When CG.Stage='In-Progress' AND CG.Likelihood='High' then 'In-Progress – High'
When CG.Stage='In-Progress' AND CG.Likelihood is null then 'In-Progress – NA' Else 'NA' END AS State,
CONVERT(varchar(max),CG.CompanyId) as CompanyId, 
SC.StartDate,
-----------------SC.EndDate,
CG.ApprovedDate,
Convert(varchar(100),DATEDIFF(DD,SC.startdate,CG.Approveddate))as 'TurnR',
Convert(varchar(100),DateDiff(DD,CG.DueDateForCompletion,isnull(cg.ActualDateOfCompletion,GETDATE()))) as 'OverD',
Convert(Varchar(100),DateDiff(DD,sc.EndDate,isnull([Approved Date],getdate()))) as 'OverR',
CG.DueDateForCompletion,CG.ActualDateOfCompletion,
Case when CG.ApprovedDate is null then GETDATE() else CG.ApprovedDate end as 'Approved Date',
[Pln Rec] ,[Act Rec], cg.TargettedRecovery as [Tgt Rec]  
from Workflow.CaseGroup CG 
Left Join WorkFlow.Client C on C.Id=CG.ClientId
Left Join Common.Service S on S.Id=CG.ServiceId
Left JOIN Common.Company E ON E.Id=CG.ServiceCompanyId

left join 
(
select SourceCaseId,CaseNumber,TenantId as CompanyId,CaseValue ,[Pln Rec],[Act Rec],[Tgt Rec] 
from 
(
SELECT C.CaseNumber,C.id as SourceCaseId,C.CompanyId as TenantId,dd.Name,dd.Value,c.Fee as CaseValue

FROM WorkFlow.CaseGroup C 

left join
(
select   sourceCaseId,CaseNumber,Name,Value from 
(

select id as sourceCaseId,CaseNumber, 

 TargettedRecovery as Value,case when TargettedRecovery=TargettedRecovery then 'Tgt Rec' end as Name
 from WorkFlow.CaseGroup c --where c.TenantId=1
union all
select sourceCaseId,CaseNumber,
planRecovery AS Value,case when planRecovery=planRecovery then 'Pln Rec' end as Name from 
(
select sourceCaseId,CaseNumber,Isnull(Round(FeeAllocationDollor / Nullif(PlanedCost,0)*100,2),0) as planRecovery from 
(
select SourceCaseId,CaseNumber,sum(FeeAllocationPer) as FeeAllocationPer, sum(FeeAllocationDollor) as  FeeAllocationDollor, sum(PlanedCost) as PlanedCost  from 
(
select SourceCaseId,CaseNumber,FeeAllocationPer,Isnull(Round((FeeAllocationPer*CaseFee) / 100,4),0) as FeeAllocationDollor,PlanedCost from 
(
select SourceCaseId,CaseNumber,Isnull(Round(PlanedCost / Nullif(Hourscost,0)*100,4),0) as FeeAllocationPer,PlanedCost,CaseFee  from 
(
select  SourceCaseId,CaseNumber,(PlanedHours*isnull(ChargeoutRate,0)) as PlanedCost,Hourscost,isnull(Fee,0) AS CaseFee from
 (
select  C.id as SourceCaseId,C.CaseNumber,C.FEE,---case
 CASE WHEN Cast(ISnull(st.PlanedHours,0)/600000000 As int) >= 60 THEN
     Cast(Cast(ISnull(st.PlanedHours,0)/600000000 As int) / 60 As Varchar) + '.' +
     Case When (Cast(ISnull(st.PlanedHours,0)/600000000 As int) % 60) < 10 Then
       '0'+Cast (Cast (ISnull(st.PlanedHours,0)/600000000 As int) % 60 As varchar) 
   Else
     Cast(Cast(ISnull(st.PlanedHours,0)/600000000 As int) % 60 As varchar)
   End

    Else
    Cast( Cast (st.PlanedHours/600000000 As int) % 60  As varchar) End As PlanedHours,
st.ChargeoutRate,Hourscost

 from WorkFlow.CaseGroup c
inner join WorkFlow.Schedule s on s.CaseId=C.Id
inner join WorkFlow.ScheduleDetail st on st.MasterId=s.Id
inner join
(
select  SourceCaseId,CaseNumber,SUM(PlanedHours*isnull(ChargeoutRate,0)) as Hourscost from
 (
select  C.id as SourceCaseId,C.CaseNumber,---case
 CASE WHEN Cast(ISnull(st.PlanedHours,0)/600000000 As int) >= 60 THEN
     Cast(Cast(ISnull(st.PlanedHours,0)/600000000 As int) / 60 As Varchar) + '.' +
     Case When (Cast(ISnull(st.PlanedHours,0)/600000000 As int) % 60) < 10 Then
       '0'+Cast (Cast (ISnull(st.PlanedHours,0)/600000000 As int) % 60 As varchar) 
   Else
     Cast(Cast(ISnull(st.PlanedHours,0)/600000000 As int) % 60 As varchar)
   End

    Else
    Cast( Cast (st.PlanedHours/600000000 As int) % 60  As varchar) End As PlanedHours,
st.ChargeoutRate

 from WorkFlow.CaseGroup c
inner join WorkFlow.Schedule s on s.CaseId=C.Id
inner join WorkFlow.ScheduleDetail st on st.MasterId=s.Id
)ss
group by SourceCaseId,CaseNumber
)ff on ff.SourceCaseId=c.Id and ff.CaseNumber=c.CaseNumber
)dd
)hh
)kk
)jj
group by SourceCaseId,CaseNumber
)nn
)ww 
union all
select sourceCaseId,CaseNumber, actRecovery AS Value,case when actRecovery=actRecovery then 'Act Rec' end as Name from (select sourceCaseId,CaseNumber,Isnull(Round(FeeAllocationDollor / Nullif(PlanedCost,0)*100,4),0) as actRecovery from (select SourceCaseId,CaseNumber,sum(FeeAllocationPer) as FeeAllocationPer, sum(FeeAllocationDollor) as  FeeAllocationDollor, sum(PlanedCost) as PlanedCost from (select SourceCaseId,CaseNumber,FeeAllocationPer,Isnull(Round((FeeAllocationPer*CaseFee) / 100,4),0) as FeeAllocationDollor,PlanedCost from (select SourceCaseId,CaseNumber,Isnull(Round(PlanedCost / Nullif(Hourscost,0)*100,4),0) as FeeAllocationPer,PlanedCost,CaseFee  from (select  SourceCaseId,CaseNumber,(PlanedHours*isnull(ChargeoutRate,0)) as PlanedCost,Hourscost,isnull(Fee,0) AS CaseFee from (select  rank() over(partition by E.Id/*ed.departmentId*/ order by ( case when Ed.[EffectiveTo] is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else Ed.[EffectiveTo] end  ) desc) as rank ,C.id as SourceCaseId,C.CaseNumber,C.FEE,---case( cast(ISNULL(CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', Td.Duration ))/60)+'.'+RIGHT('0'+CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', Td.Duration ))%60),2),0) as decimal(10,2))) as PlanedHours,Hourscost,CAST(Ed.ChargeOutRate AS DECIMAL(20,2)) as ChargeoutRate from [WorkFlow].[CaseGroup] Cleft join [Common].[TimeLogItem] st on st.systemid=c.id left join [Common].[TimeLog] s on s.TimeLogItemId=st.Id left join [Common].[TimeLogDetail] td on  td.MasterId=s.Idleft  join Common.employee E  on E.Id=s.EmployeeIdleft JOIN HR.EmployeeDepartment Ed  ON Ed.EmployeeId=E.Idinner join(select  SourceCaseId,CaseNumber,SUM(PlanedHours*isnull(ChargeoutRate,0)) as Hourscost from (select rank() over(partition by E.Id/*ed.departmentId*/ order by ( case when Ed.[EffectiveTo] is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else Ed.[EffectiveTo] end  ) desc) as rank ,e.firstname, C.id as SourceCaseId,C.CaseNumber,---case( cast(ISNULL(CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', Td.Duration ))/60)+'.'+RIGHT('0'+CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', Td.Duration ))%60),2),0) as decimal(10,2))) as PlanedHours,CAST(Ed.ChargeOutRate AS DECIMAL(20,2)) as ChargeoutRate from [WorkFlow].[CaseGroup] Cleft join [Common].[TimeLogItem] st on st.systemid=c.id left join [Common].[TimeLog] s on s.TimeLogItemId=st.Id left join [Common].[TimeLogDetail] td on  td.MasterId=s.Idleft  join Common.employee E  on E.Id=s.EmployeeIdleft JOIN HR.EmployeeDepartment Ed  ON Ed.EmployeeId=E.Id)sswhere ss.rank=1 group by SourceCaseId,CaseNumber)ff on ff.SourceCaseId=c.Id and ff.CaseNumber=c.CaseNumber)ddwhere dd.rank=1)hh)kk)jjgroup by SourceCaseId,CaseNumber)nn)MM 
)ss
) dd on dd.SourceCaseId=c.Id and dd.CaseNumber=c.CaseNumber
)as ff
PIVOT  
(  
SUM(Value) FOR Name IN ([Pln Rec],[Act Rec],[Tgt Rec])) 
AS Tab2  
)as dd on dd.SourceCaseId=cg.Id and dd.CompanyId=cg.CompanyId

Left Join (

Select  Distinct S.StartDate,S.CaseId,
Case when ADOC.ADOCDate is null then  S.CompletionDate else  ADOCDate end EndDate,
Case when C.ApprovedDate is null then GETDATE() else C.ApprovedDate end as 'Approved Date'
from Workflow.CaseGroup C

Left Join WorkFlow.Schedule S on S.CaseId=C.Id

 Left Join
   ( 
     select * from (SELECT RANK() OVER (PARTITION BY CaseId ORDER BY CAD.CreatedDate) AS RankId,CaseId,
  AmendDate as ADOCDate,CAD.EmployeeId,CAD.Reason
     FROM [WorkFlow].[CaseAmendDateOfCompletion]  CAD
  Left Join Workflow.CaseGroup CG on CG.Id=CAD.CaseId ) as mm   where RankId=1 
  
   ) as ADOC on ADOC.CaseId = C.Id

Where   s.StartDate is not null and s.CompletionDate is not null --and C.TenantId=1

) as SC on SC.CaseId=CG.Id

Group By C.Name,CG.CaseNumber,CG.Stage,CG.DueDateForCompletion,
CG.ActualDateOfCompletion,CG.Id,CG.ClientId,SC.[Approved Date],cg.TargettedRecovery,
SC.StartDate,--SC.EndDate,
CG.CompanyId,CG.ApprovedDate,CG.TargettedRecovery,dd.[Pln Rec],dd.[Act Rec],dd.[Tgt Rec]
,CG.Likelihood,SC.EndDate

) as AYV
end 
---Where CompanyId=1
--and CaseNumber='CASE-2018-00184'
GO
