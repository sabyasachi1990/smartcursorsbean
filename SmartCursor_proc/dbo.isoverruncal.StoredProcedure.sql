USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[isoverruncal]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Procedure [dbo].[isoverruncal]  as  begin --(select distinct  ff.SourceCaseId,ff.CaseNumber,ff.FirstName,-- pl.PlanedHours,pl.PlanedCost,ff.Cost,ff.PlanedCost,ff.PlanedHours,pl.PlanedCost,oo.OverCost from  (select SourceCaseId,CaseNumber,FirstName,sum(PlanedHours) as PlanedHours,sum(PlanedCost)  as PlanedCost from  (  select  SourceCaseId,CaseNumber,FirstName,DepartmentId,DepartmentDesignationId,LevelRank,--- HOURS, (ChargeoutRate*PlanedHours) as PlanedCost,PlanedHours,Fee from (  select  SourceCaseId,CaseNumber,FirstName,DepartmentId,DepartmentDesignationId,LevelRank,--- HOURS, ChargeoutRate,CAST(PlanedHours AS DECIMAL(20,2)) as PlanedHours,  --PlanedHours,ChargeoutRate,FEE--COST ---(sum(Hourscost)/nullif(sum(PlanedHours),0))---CHAR   from (select  C.id SourceCaseId,C.CaseNumber,C.FEE,---case CASE WHEN Cast(ISnull(st.PlanedHours,0)/600000000 As int) >= 60 THEN
     Cast(Cast(ISnull(st.PlanedHours,0)/600000000 As int) / 60 As Varchar) + '.' +
     Case When (Cast(ISnull(st.PlanedHours,0)/600000000 As int) % 60) < 10 Then
       '0'+Cast (Cast (ISnull(st.PlanedHours,0)/600000000 As int) % 60 As varchar) 
   Else
     Cast(Cast(ISnull(st.PlanedHours,0)/600000000 As int) % 60 As varchar)
   End

    Else
    Cast( Cast (st.PlanedHours/600000000 As int) % 60  As varchar) End as PlanedHours,--	( cast(ISNULL(CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', tsk.IsOverRunHours ))/60)+'.'+
--RIGHT('0'+CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', tsk.IsOverRunHours ))*100/60),2),0) as decimal(10,2))) as  OverRunHours,CAST(st.ChargeOutRate AS DECIMAL(20,2)) as ChargeoutRate,e.FirstName,d.id as Departmentid,dd.Id as DepartmentDesignationId,dd.LevelRank	  from WorkFlow.CaseGroup c
inner join WorkFlow.Schedule s on s.CaseId=C.Id
inner join WorkFlow.ScheduleDetail st on st.MasterId=s.Id
--inner join WorkFlow.ScheduleTask tsk on tsk.ScheduleDetailId=st.Id 
inner Join Common.employee E  on E.Id=st.EmployeeId
   Inner Join [HR].[EmployeeDepartment] as ed on ED.EmployeeId = E.Id and ed.DepartmentId=st.DepartmentId and ed.DepartmentDesignationId = st.DesignationId
   Inner Join Common.Department D on D.id= ED.DepartmentId and d.id=st.DepartmentId
Inner Join Common.DepartmentDesignation DD on DD.Id= ED.DepartmentDesignationId and dd.id=st.DesignationIdwhere  C.CompanyId=147 and c.CaseNumber='CASE-2018-00187')ss)dd)ppgroup by SourceCaseId,CaseNumber,FirstName)plinner join (select SourceCaseId,CaseNumber,--FirstName,--- HOURS,   OverCost , OverRunHours from (select  SourceCaseId,CaseNumber,---FirstName,--- HOURS,  sum(OverCost) as OverCost ,sum(OverRunHours) as OverRunHours from (select  SourceCaseId,CaseNumber,FirstName,DepartmentId,DepartmentDesignationId,LevelRank,--- HOURS, (ChargeoutRate*OverRunHours) as OverCost,OverRunHours,Fee from (  select  SourceCaseId,CaseNumber,FirstName,DepartmentId,DepartmentDesignationId,LevelRank,--- HOURS, ChargeoutRate,OverRunHours,  --PlanedHours,ChargeoutRate,FEE--COST ---(sum(Hourscost)/nullif(sum(PlanedHours),0))---CHAR   from (select  C.id SourceCaseId,C.CaseNumber,C.FEE,---case	( cast(ISNULL(CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', tsk.IsOverRunHours ))/60)+'.'+
RIGHT('0'+CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', tsk.IsOverRunHours ))*100/60),2),0) as decimal(10,2))) as  OverRunHours,CAST(st.ChargeOutRate AS DECIMAL(20,2)) as ChargeoutRate,e.FirstName,d.id as Departmentid,dd.Id as DepartmentDesignationId,dd.LevelRank	  from WorkFlow.CaseGroup c
inner join WorkFlow.Schedule s on s.CaseId=C.Id
inner join WorkFlow.ScheduleDetail st on st.MasterId=s.Id
inner join WorkFlow.ScheduleTask tsk on tsk.ScheduleDetailId=st.Id 
inner Join Common.employee E  on E.Id=st.EmployeeId
   Inner Join [HR].[EmployeeDepartment] as ed on ED.EmployeeId = E.Id and ed.DepartmentId=st.DepartmentId and ed.DepartmentDesignationId = st.DesignationId
   Inner Join Common.Department D on D.id= ED.DepartmentId and d.id=st.DepartmentId
Inner Join Common.DepartmentDesignation DD on DD.Id= ED.DepartmentDesignationId and dd.id=st.DesignationIdwhere  C.CompanyId=147 and c.CaseNumber='CASE-2018-00187')ss) ff)iigroup by SourceCaseId,CaseNumber--,FirstName)kk)oo on oo.SourceCaseId=pl.SourceCaseId  and  oo.CaseNumber=pl.CaseNumberinner join (select SourceCaseId,CaseNumber,FirstName, Cost,PlanedCost,PlanedHours from(select SourceCaseId,CaseNumber,FirstName,(PlanedCost/PlanedHours) as Cost,PlanedCost,PlanedHours from  (select SourceCaseId,CaseNumber,FirstName,sum(PlanedHours) as PlanedHours,sum(PlanedCost)  as PlanedCost from  (  select  SourceCaseId,CaseNumber,FirstName,DepartmentId,DepartmentDesignationId,LevelRank,--- HOURS, (ChargeoutRate*PlanedHours) as PlanedCost,PlanedHours,Fee from (  select  SourceCaseId,CaseNumber,FirstName,DepartmentId,DepartmentDesignationId,LevelRank,--- HOURS, ChargeoutRate,PlanedHours,  --PlanedHours,ChargeoutRate,FEE--COST ---(sum(Hourscost)/nullif(sum(PlanedHours),0))---CHAR   from (select  C.id SourceCaseId,C.CaseNumber,C.FEE,---case CASE WHEN Cast(ISnull(st.PlanedHours,0)/600000000 As int) >= 60 THEN
     Cast(Cast(ISnull(st.PlanedHours,0)/600000000 As int) / 60 As Varchar) + '.' +
     Case When (Cast(ISnull(st.PlanedHours,0)/600000000 As int) % 60) < 10 Then
       '0'+Cast (Cast (ISnull(st.PlanedHours,0)/600000000 As int) % 60 As varchar) 
   Else
     Cast(Cast(ISnull(st.PlanedHours,0)/600000000 As int) % 60 As varchar)
   End

    Else
    Cast( Cast (st.PlanedHours/600000000 As int) % 60  As varchar) End as PlanedHours,--	( cast(ISNULL(CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', tsk.IsOverRunHours ))/60)+'.'+
--RIGHT('0'+CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', tsk.IsOverRunHours ))*100/60),2),0) as decimal(10,2))) as  OverRunHours,CAST(st.ChargeOutRate AS DECIMAL(20,2)) as ChargeoutRate,e.FirstName,d.id as Departmentid,dd.Id as DepartmentDesignationId,dd.LevelRank	  from WorkFlow.CaseGroup c
inner join WorkFlow.Schedule s on s.CaseId=C.Id
inner join WorkFlow.ScheduleDetail st on st.MasterId=s.Id
--inner join WorkFlow.ScheduleTask tsk on tsk.ScheduleDetailId=st.Id 
inner Join Common.employee E  on E.Id=st.EmployeeId
   Inner Join [HR].[EmployeeDepartment] as ed on ED.EmployeeId = E.Id and ed.DepartmentId=st.DepartmentId and ed.DepartmentDesignationId = st.DesignationId
   Inner Join Common.Department D on D.id= ED.DepartmentId and d.id=st.DepartmentId
Inner Join Common.DepartmentDesignation DD on DD.Id= ED.DepartmentDesignationId and dd.id=st.DesignationIdwhere  C.CompanyId=147 and c.CaseNumber='CASE-2018-00187')ss)ddunion all  select  SourceCaseId,CaseNumber,FirstName,DepartmentId,DepartmentDesignationId,LevelRank,--- HOURS, (ChargeoutRate*OverRunHours) as OverCost,OverRunHours,Fee from (  select  SourceCaseId,CaseNumber,FirstName,DepartmentId,DepartmentDesignationId,LevelRank,--- HOURS, ChargeoutRate,OverRunHours,  --PlanedHours,ChargeoutRate,FEE--COST ---(sum(Hourscost)/nullif(sum(PlanedHours),0))---CHAR   from (select  C.id SourceCaseId,C.CaseNumber,C.FEE,---case	( cast(ISNULL(CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', tsk.IsOverRunHours ))/60)+'.'+
RIGHT('0'+CONVERT(VARCHAR,CONVERT(INT,DATEDIFF(MINUTE, '0:00:00', tsk.IsOverRunHours ))*100/60),2),0) as decimal(10,2))) as  OverRunHours,CAST(st.ChargeOutRate AS DECIMAL(20,2)) as ChargeoutRate,e.FirstName,d.id as Departmentid,dd.Id as DepartmentDesignationId,dd.LevelRank	  from WorkFlow.CaseGroup c
inner join WorkFlow.Schedule s on s.CaseId=C.Id
inner join WorkFlow.ScheduleDetail st on st.MasterId=s.Id
inner join WorkFlow.ScheduleTask tsk on tsk.ScheduleDetailId=st.Id 
inner Join Common.employee E  on E.Id=st.EmployeeId
   Inner Join [HR].[EmployeeDepartment] as ed on ED.EmployeeId = E.Id and ed.DepartmentId=st.DepartmentId and ed.DepartmentDesignationId = st.DesignationId
   Inner Join Common.Department D on D.id= ED.DepartmentId and d.id=st.DepartmentId
Inner Join Common.DepartmentDesignation DD on DD.Id= ED.DepartmentDesignationId and dd.id=st.DesignationIdwhere  C.CompanyId=147 and c.CaseNumber='CASE-2018-00187')ss) ff)gggroup by SourceCaseId,CaseNumber,FirstName)dd)jj)ff on ff.SourceCaseId=pl.SourceCaseId  and  ff.CaseNumber=pl.CaseNumberend
GO
