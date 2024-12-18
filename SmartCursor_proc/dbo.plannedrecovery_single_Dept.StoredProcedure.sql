USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[plannedrecovery_single_Dept]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[plannedrecovery_single_Dept]AS Begin select SourceCaseId,CaseNumber, (sum(FeeAllocationDoller)/ nullif(sum(Hourscost),0))*100 AS 'PlannedRecovery' from (  SELECT SourceCaseId,CaseNumber ,FirstName, FeeAllocationPercentage ,(FeeAllocationPercentage*FEE)/100 as 'FeeAllocationDoller', Hourscost FROM  (  SELECT SourceCaseId,CaseNumber,FEE,FirstName,(((PlanedHours)*(ChargeoutRate))/Totalcost)*100 AS FeeAllocationPercentage,Hourscost FROM  ( SELECT SourceCaseId,CaseNumber,FirstName ,(Hourscost)/ (PlanedHours) AS ChargeoutRate ,PlanedHours,Hourscost,FEE,Totalcost FROM  ( select SourceCaseId,FEE,CaseNumber,FirstName,sum(Hourscost) Hourscost,sum(PlanedHours) PlanedHours,Totalcost ---,(sum(Hourscost)/nullif(sum(PlanedHours),0)) ChargeoutRate   from  (  select  SourceCaseId,CaseNumber,FirstName,DepartmentId,DepartmentDesignationId,LevelRank, CAST(PlanedHours AS DECIMAL(20,2))PlanedHours,--- HOURS, ChargeoutRate,  --PlanedHours,ChargeoutRate,  (PlanedHours*ChargeoutRate) Hourscost,FEE,Totalcost--COST ---(sum(Hourscost)/nullif(sum(PlanedHours),0))---CHAR   from (select rank() over(partition by E.Id/*ed.departmentId*/ order by ( case when Ed.[EffectiveTo] is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else Ed.[EffectiveTo] end  ) desc) as rank ,Totalcost, C.Id SourceCaseId,C.CaseNumber,C.FEE,---case CASE WHEN Cast(ISnull(st.PlanedHours,0)/600000000 As int) >= 60 THEN
     Cast(Cast(ISnull(st.PlanedHours,0)/600000000 As int) / 60 As Varchar) + '.' +
     Case When (Cast(ISnull(st.PlanedHours,0)/600000000 As int) % 60) < 10 Then
       '0'+Cast (Cast (ISnull(st.PlanedHours,0)/600000000 As int) % 60 As varchar) 
   Else
     Cast(Cast(ISnull(st.PlanedHours,0)/600000000 As int) % 60 As varchar)
   End

    Else
    Cast( Cast (st.PlanedHours/600000000 As int) % 60  As varchar) End as PlanedHours,CAST(st.ChargeOutRate AS DECIMAL(20,2)) as ChargeoutRate,e.FirstName,d.id as Departmentid,dd.Id as DepartmentDesignationId,dd.LevelRank	  from WorkFlow.CaseGroup c
inner join WorkFlow.Schedule s on s.CaseId=C.Id
inner join WorkFlow.ScheduleDetail st on st.MasterId=s.Id
inner join WorkFlow.ScheduleTask tsk on tsk.ScheduleDetailId=st.Id
inner Join Common.employee E  on E.Id=st.EmployeeId
    Inner Join [HR].[EmployeeDepartment] as ed on ED.EmployeeId = E.Id and ed.DepartmentId=st.DepartmentId
   Inner Join Common.Department D on D.id= ED.DepartmentId
Inner Join Common.DepartmentDesignation DD on DD.Id= ED.DepartmentDesignationId--where  C.CompanyId=147 and c.CaseNumber='CASE-2018-00188'inner join(select SourceCaseId,FEE,CaseNumber,sum(Hourscost) Totalcost ---,(sum(Hourscost)/nullif(sum(PlanedHours),0)) ChargeoutRate   from  (  select  SourceCaseId,CaseNumber,FirstName,DepartmentId,DepartmentDesignationId,LevelRank, PlanedHours,--- HOURS, ChargeoutRate,  --PlanedHours,ChargeoutRate,  (PlanedHours*ChargeoutRate) Hourscost,FEE--COST ---(sum(Hourscost)/nullif(sum(PlanedHours),0))---CHAR   from (select  C.id SourceCaseId,C.CaseNumber,C.FEE,---case CASE WHEN Cast(ISnull(st.PlanedHours,0)/600000000 As int) >= 60 THEN
     Cast(Cast(ISnull(st.PlanedHours,0)/600000000 As int) / 60 As Varchar) + '.' +
     Case When (Cast(ISnull(st.PlanedHours,0)/600000000 As int) % 60) < 10 Then
       '0'+Cast (Cast (ISnull(st.PlanedHours,0)/600000000 As int) % 60 As varchar) 
   Else
     Cast(Cast(ISnull(st.PlanedHours,0)/600000000 As int) % 60 As varchar)
   End

    Else
    Cast( Cast (st.PlanedHours/600000000 As int) % 60  As varchar) End as PlanedHours,CAST(st.ChargeOutRate AS DECIMAL(20,2)) as ChargeoutRate,e.FirstName,d.id as Departmentid,dd.Id as DepartmentDesignationId,dd.LevelRank	  from WorkFlow.CaseGroup c
inner join WorkFlow.Schedule s on s.CaseId=C.Id
inner join WorkFlow.ScheduleDetail st on st.MasterId=s.Id
inner join WorkFlow.ScheduleTask tsk on tsk.ScheduleDetailId=st.Id
inner Join Common.employee E  on E.Id=st.EmployeeId
   Inner Join [HR].[EmployeeDepartment] as ed on ED.EmployeeId = E.Id and ed.DepartmentId=st.DepartmentId
   Inner Join Common.Department D on D.id= ED.DepartmentId
Inner Join Common.DepartmentDesignation DD on DD.Id= ED.DepartmentDesignationIdwhere  C.CompanyId=147 and c.CaseNumber='CASE-2018-00188')ss--where rank=1--group by SourceCaseId,CaseNumber,FirstName,DepartmentId,DepartmentDesignationId,LevelRank,FEE---,PlanedHours,ChargeoutRate) ddgroup by SourceCaseId,CaseNumber,FEE)ff on ff.SourceCaseId=c.Id and ff.CaseNumber=c.CaseNumberwhere  C.CompanyId=147 and c.CaseNumber='CASE-2018-00188')ss--where rank=1--group by SourceCaseId,CaseNumber,FirstName,DepartmentId,DepartmentDesignationId,LevelRank,FEE---,PlanedHours,ChargeoutRate) ddgroup by SourceCaseId,CaseNumber,FirstName,FEE,Totalcost) DD) SS) GG)ffgroup by SourceCaseId,CaseNumberend 
GO
