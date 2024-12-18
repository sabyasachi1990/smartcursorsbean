USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[sp_plan_Act_Recovery]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec [dbo].[sp_plan_Act_Recovery]

CREATE procedure [dbo].[sp_plan_Act_Recovery]
as
begin 
select  sourceCaseId,CaseNumber,TenantId,--EmployeeId,FirstName,
sum(FeeAllocation) as Contribution,SUM(PlannedCost) AS PlannedCost , CAST((sum(FeeAllocation)/nullif(sum(PlannedCost),0))*100 AS decimal(20,2) ) AS planRecovery
,SUM(ActualCost) AS ActualCost , cast((sum(FeeAllocation)/nullif(sum(ActualCost),0))*100 as decimal(20,2))  AS ActualRecovery
 from 
(
 select distinct c.ID AS SourceCaseId,c.CaseNumber,E. ID AS  EmployeeId,E.FirstName,C.CompanyId AS TenantId,
  CASE WHEN C.IsServiceNatureWOWF=1 THEN sum(C.Fee) 
 WHEN C.IsServiceNatureWOWF=0 THEN SUM(st.FeeAllocation) END  AS FeeAllocation,
  CASE WHEN C.IsServiceNatureWOWF=1 THEN (sum(C.Fee)/nullif(SUM(C.TargettedRecovery),0))*100
 WHEN C.IsServiceNatureWOWF=0 THEN sum(st.PlannedCost) END as PlannedCost,
 isnull(DD.ActualCost,0) AS ActualCost
 from WorkFlow.CaseGroup c
inner join WorkFlow.Schedule s on s.CaseId=C.Id
inner join WorkFlow.ScheduleDetail st on st.MasterId=s.Id
inner Join Common.employee E  on E.Id=st.EmployeeId
INNER JOIN Common.Company EE ON EE.Id=C.CompanyId
LEFT JOIN 
(
 select distinct c.ID AS SourceCaseId,c.CaseNumber,E. ID AS  EmployeeId,E.FirstName,C.CompanyId,
 
 CASE WHEN C.IsServiceNatureWOWF=1 THEN (sum(C.Fee)/nullif(SUM(C.TargettedRecovery),0))*100
 WHEN C.IsServiceNatureWOWF=0 THEN SUM(st.ActualCost) END  as ActualCost 
 from WorkFlow.CaseGroup c
inner join COMMON.TimeLogSchedule st on st.CaseId=c.Id
inner Join Common.employee E  on E.Id=st.EmployeeId
INNER JOIN Common.Company EE ON EE.Id=C.CompanyId
--where c.CompanyId=1 AND CaseNumber in('CE-AUDSTA-2018-02250','CE-AUDSTA-2018-00798',
--'CE-AUDSTA-2018-02265',
--'CE-FRSCFS-2018-00236')
group by c.CaseNumber,c.Id,E.Id,E.FirstName,C.CompanyId,C.IsServiceNatureWOWF
) DD ON DD.SourceCaseId=C.ID AND DD.EmployeeId=E.Id

--where c.CompanyId=1 AND C.CaseNumber in('CE-AUDSTA-2018-02250','CE-AUDSTA-2018-00798',
--'CE-AUDSTA-2018-02265',
--'CE-FRSCFS-2018-00236')
group by c.CaseNumber,c.Id,E.Id,E.FirstName,EE.TenantId,DD.ActualCost,C.CompanyId,C.IsServiceNatureWOWF

) dd 
group by sourceCaseId,CaseNumber,TenantId--,EmployeeId,FirstName
end
GO
