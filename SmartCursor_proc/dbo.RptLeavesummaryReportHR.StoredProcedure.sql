USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RptLeavesummaryReportHR]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Jevan	Dev	Associate
--Jayadeepika Jagarapu	Dev	Associate
--Sudhakiran Kallagunta	Dev	Manager
--Emp3	Dev	Manager
--Hari	Dev	Associate
--kondaiah	Dev	Manager
--Uday	Dev	Manager
--balaji	QA	Associate
--Suman	Dev	Associate

--  Declare @CompanyValue int=311,
-- @FromDate datetime='2018-01-01',
-- @Todate datetime='2018-06-19',
-- @Employee nvarchar(max)='Jayadeepika Jagarapu',
-- @Department Nvarchar(max)='dev',
--@Designation Nvarchar(max)='Associate'
----@Year varchar(max)='2018'

CREATE  Procedure [dbo].[RptLeavesummaryReportHR]
@CompanyValue Int,
@Department Nvarchar(max),
@Designation Nvarchar(max),
@Employee nvarchar(max),
@Year int

 -- Exec [dbo].[RptLeavesummaryReportHR] 311,'Dev','Associate','Jayadeepika Jagarapu',2018

AS
BEGIN

Declare @FromDate date
Declare @ToDate   date

Set @FromDate=convert(date,convert(varchar(100),@Year)+'-'+'01'+'-'+'01')
--Print @FromDate
Set @ToDate=convert(date,convert(varchar(100),@Year)+'-'+'12'+'-'+'31')
--Print @ToDate

select p.CompanyId,p.EmployeeId,ED.Name,Ed.[Dept Code] [Dept],ed.Designation,ed.eid [Emp No],ed.StartDate [Emp StartDate],LeaveType [Type],isnull((Entitlement),0)Entitlement,isnull((BroughtForward),0)BroughtForward,isnull((Adjustment),0)Adjustment,isnull((Total),0)Total,isnull((p.Prorated),0)Prorated,
isnull((Currentvalue),0)Currentvalue,isnull((ApprovedAndTaken),0)Taken,isnull((ApprovedAndNotTaken),0)[Not Taken],isnull(( Balances),0)Balances
,isnull(kk.Submitted,0)Submitted,@FromDate as FromDate,@ToDate as ToDate

from
(
select Id,employeeid,CompanyId,LeaveType,Entitlement,BroughtForward,Adjustment,Total,d.Prorated,
Currentvalue,ApprovedAndTaken,ApprovedAndNotTaken,Taken,(Currentvalue-Taken)as Balances
--,isnull((Entitlement+BroughtForward),0) as Toa

--,DeptName,DesignationName
--,firstname
from
(
select CompanyId,employeeid,Name as LeaveType,isnull(Entitlement,0)Entitlement,isnull(BroughtForward,0)BroughtForward,isnull(Adjustment,0)Adjustment,isnull((dd.Entitlement+dd.BroughtForward+dd.Adjustment),0) as Total,dd.Prorated,
isnull(dd.Prorated+dd.Adjustment+BroughtForward,0) as Currentvalue,ApprovedAndTaken,ApprovedAndNotTaken,isnull(ApprovedAndTaken+ApprovedAndNotTaken,0) as Taken,
id
--,DeptName,DesignationName
--,firstname
From 
(
select   RANK() over(partition by le.employeeid order by le.leavetypeid Asc) as Rank,lt.id,le.employeeid,lt.CompanyId,lt.name,isnull(sum(le.AnnualLeaveEntitlement),0) Entitlement,
isnull(sum(le.ApprovedAndNotTaken),0) ApprovedAndNotTaken,isnull(sum(le.ApprovedAndTaken),0) as ApprovedAndTaken,
isnull(sum(le.Prorated),0)as Prorated,isnull(sum(le.Adjustment),0) as Adjustment,isnull(sum(le.BroughtForward),0) BroughtForward
--firstname,EffectiveFrom,EffectiveTo,,DeptName as DeptName,DesignationName as DesignationName

 from hr.LeaveType lt 
 --on lt.Id=la.LeaveTypeId
Inner join hr.LeaveEntitlement le on le.LeaveTypeId=lt.Id
where lt.CompanyId=@CompanyValue  --and le.StartDate between @FromDate and @ToDate 
--and EmployeeId='C5FDC2AF-5C11-3A37-769B-15F5A33CB30D'
group by EmployeeId,lt.Id,LeaveTypeId,lt.CompanyId,lt.Name,StartDate
--order by Name
)dd
)as d

)as p
--order by EmployeeId
inner join
		(
		select CompanyId,Id,EmployeeId,DepartmentId,FirstName Name,DeptName as DeptName,Designation,code as[Dept Code],EffectiveFrom,EffectiveTo,Currency,SubCompany,StartDate,rank,eid
		from
		(
		select rank() over(partition by ed.employeeid/*ed.departmentId*/ order by Ed.Recorder desc,EffectiveTo desc) as rank  ,e.employeeid,e.FirstName as FirstName,ed.EmployeeId as Id,D.Code as DeptName,DD.Name as Designation,cast(EffectiveFrom as Date) EffectiveFrom,cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date) as EffectiveTo, 
			Ed.DepartmentId,ED.DepartmentDesignationId,D.code,ED.CompanyId SubCompany,E.companyId,ED.Currency,convert(date,emp.StartDate)StartDate,e.EmployeeId as eid
		from   hr.Employment emp
		join   hr.EmployeeDepartment ED on ED.EmployeeId=emp.EmployeeId
		join   Common.Department as D on D.Id=ED.DepartmentId 
		join   Common.DepartmentDesignation as DD on DD.ID=ED.DepartmentDesignationId
		join   Common.Employee as E on E.Id=ED.EmployeeId 
		join   Common.Company c on c.id=ED.CompanyId
		where  E.CompanyId=@CompanyValue  and c.ParentId=@CompanyValue 
		--and  ED.employeeid in('C5FDC2AF-5C11-3A37-769B-15F5A33CB30D','A66726F0-57F3-603D-0657-5A604F8939BA')
			   and   ((@FromDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)) or (@ToDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
			   and    D.Code in (select items from dbo.SplitToTable(@Department,','))
			   and    DD.Name in (select items from dbo.SplitToTable(@Designation,','))
			   and    e.FirstName in (select items from dbo.SplitToTable(@Employee,','))
			  
			   --and    e.CompanyId=@SubComp
		

		--order by ED.EmployeeId
		) as E 
		where rank=1 
		)AS ED ON ED.id=p.EmployeeId and ed.CompanyId=p.CompanyId
		
		left join
		(
		select dd.CompanyId,dd.EmployeeId,dd.LeaveTypeId,isnull(dd.Submitted,0) as Submitted,dd.Year
			from

            (
			select  distinct count(la.Id) Submitted,EmployeeId,la.CompanyId,LeaveTypeId,YEAR(la.startdatetime) As Year
			From   hr.LeaveApplication la
			--Join   hr.LeaveType LT on LT.Id=la.LeaveTypeId
			Where  la.CompanyId=@CompanyValue  and la.LeaveStatus='Submitted' and StartDateTime between @FromDate and @Todate
			Group By EmployeeId,la.CompanyId,la.LeaveTypeId,la.StartDateTime
			)as dd 
			where  Year=@Year
            )as kk on kk.EmployeeId=p.EmployeeId and kk.CompanyId=p.CompanyId and kk.LeaveTypeId=p.Id
			--where Name='Jayadeepika Jagarapu'
			
			order by type

			END
GO
