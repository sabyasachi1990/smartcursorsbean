USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RptWF_CasesStory_Recovey]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[RptWF_CasesStory_Recovey]
As
Begin
  SELECT C.id as sourceCaseId,C.CaseNumber,FF.Name,Percentage,Amount,C.CompanyId AS TenantId  
  from WorkFlow.CaseGroup  C
INNER JOIN 
 (

select distinct  sourceCaseId,CaseNumber,Name,

 CASE WHEN  Value<40 then '<40%'
 WHEN  Value between 40 and 59 then '40% to 59%'
 WHEN  Value >50 then 'Above 59%'
 END as 'Percentage',
Value as 'Amount' from
(

select id as sourceCaseId,CaseNumber, 

 ISNULL(TargettedRecovery,0) as Value,case when ISNULL(TargettedRecovery,0)=ISNULL(TargettedRecovery,0) then 'Tgt Rec' end as Name

 from WorkFlow.CaseGroup 

 )DD

 UNION ALL

select distinct  sourceCaseId,CaseNumber,Name,

 CASE WHEN  Value<40 then '<40%'
 WHEN  Value between 40 and 59 then '40% to 59%'
 WHEN  Value >50 then 'Above 59%'
 END as 'Percentage',
Value as 'Amount' from
(
select sourceCaseId,CaseNumber,
ISNULL(planRecovery,0) AS Value,case when ISNULL(planRecovery,0)=ISNULL(planRecovery,0) then 'Pln Rec' end as Name from 
(
select sourceCaseId,CaseNumber,cast(Isnull(Round(FeeAllocationDollor / Nullif(PlanedCost,0)*100,4),0)AS DECIMAL(18,2)) as planRecovery from 
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

 from WorkFlow.CaseGroup  c
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

 from WorkFlow.CaseGroup  c
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
)dd
union all
select distinct  sourceCaseId,CaseNumber,Name,

 CASE WHEN  Value<40 then '<40%'
 WHEN  Value between 40 and 59 then '40% to 59%'
 WHEN  Value >50 then 'Above 59%'
 END as 'Percentage',
Value as 'Amount' from
(
select sourceCaseId,CaseNumber, actRecovery AS Value,case when actRecovery=actRecovery then 'Act Rec' end as Name from (select sourceCaseId,CaseNumber,Isnull(Round(FeeAllocationDollor / Nullif(PlanedCost,0)*100,4),0) as actRecovery from (select SourceCaseId,CaseNumber,sum(FeeAllocationPer) as FeeAllocationPer, sum(FeeAllocationDollor) as  FeeAllocationDollor, sum(PlanedCost) as PlanedCost from (select SourceCaseId,CaseNumber,FeeAllocationPer,Isnull(Round((FeeAllocationPer*CaseFee) / 100,4),0) as FeeAllocationDollor,PlanedCost from (select SourceCaseId,CaseNumber,Isnull(Round(PlanedCost / Nullif(Hourscost,0)*100,4),0) as FeeAllocationPer,PlanedCost,CaseFee  from (select  SourceCaseId,CaseNumber,(PlanedHours*isnull(ChargeoutRate,0)) as PlanedCost,Hourscost,isnull(Fee,0) AS CaseFee from (select  rank() over(partition by E.Id/*ed.departmentId*/ order by ( case when Ed.[EffectiveTo] is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else Ed.[EffectiveTo] end  ) desc) as rank ,C.id as SourceCaseId,C.CaseNumber,C.FEE,---case( cast(ISNULL(CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', Td.Duration ))/60)+'.'+RIGHT('0'+CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', Td.Duration ))%60),2),0) as decimal(10,2))) as PlanedHours,Hourscost,CAST(Ed.ChargeOutRate AS DECIMAL(20,2)) as ChargeoutRate from [WorkFlow].[CaseGroup] Cleft join [Common].[TimeLogItem] st on st.systemid=c.id left join [Common].[TimeLog] s on s.TimeLogItemId=st.Id left join [Common].[TimeLogDetail] td on  td.MasterId=s.Idleft  join Common.employee E  on E.Id=s.EmployeeIdleft JOIN HR.EmployeeDepartment Ed ON Ed.EmployeeId=E.Idinner join(select  SourceCaseId,CaseNumber,SUM(PlanedHours*isnull(ChargeoutRate,0)) as Hourscost from (select rank() over(partition by E.Id/*ed.departmentId*/ order by ( case when Ed.[EffectiveTo] is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else Ed.[EffectiveTo] end  ) desc) as rank ,e.firstname, C.id as SourceCaseId,C.CaseNumber,---case( cast(ISNULL(CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', Td.Duration ))/60)+'.'+RIGHT('0'+CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', Td.Duration ))%60),2),0) as decimal(10,2))) as PlanedHours,CAST(Ed.ChargeOutRate AS DECIMAL(20,2)) as ChargeoutRate from [WorkFlow].[CaseGroup] Cleft join [Common].[TimeLogItem] st on st.systemid=c.id left join [Common].[TimeLog] s on s.TimeLogItemId=st.Id left join [Common].[TimeLogDetail] td on  td.MasterId=s.Idleft  join Common.employee E  on E.Id=s.EmployeeIdleft JOIN HR.EmployeeDepartment Ed ON Ed.EmployeeId=E.Id)sswhere ss.rank=1 group by SourceCaseId,CaseNumber)ff on ff.SourceCaseId=c.Id and ff.CaseNumber=c.CaseNumber)ddwhere dd.rank=1)hh)kk)jjgroup by SourceCaseId,CaseNumber)nn)MM 
)DD
)FF ON FF.SourceCaseId=C.Id AND FF.CaseNumber=C.CaseNumber

end 


GO
