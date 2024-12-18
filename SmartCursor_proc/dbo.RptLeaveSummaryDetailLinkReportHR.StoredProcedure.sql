USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RptLeaveSummaryDetailLinkReportHR]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE  Procedure [dbo].[RptLeaveSummaryDetailLinkReportHR]
@CompanyValue Int,
@Department varchar(max),
@Designation varchar(max),
@Employee varchar(max),
@Leavetype varchar(max),
@Year int

  --Exec [dbo].[RptLeavesummaryReportHR] 311,'Dev','Associate','Jayadeepika Jagarapu',2018

AS
BEGIN

Declare @FromDate date
Declare @ToDate   date

Set @FromDate=convert(date,convert(varchar(100),@Year)+'-'+'01'+'-'+'01')
Print @FromDate
Set @ToDate=convert(date,convert(varchar(100),@Year)+'-'+'12'+'-'+'31')



select [Employee Name] as Name,[Dept] as Dept,Designation  ,EmployeeNo as 'Emp No',
Type,[Start Date],[End Date], convert(varchar(100),days)+ ':(' +hours+')' as Days,[YTD Days],State,[Leave Submit Date],[Leave Approval Date],
 @FromDate as FromDate,@ToDate as ToDate  from 

(
select [Leave type] AS Type, [From Date] as 'Start Date',
  [To Date] as 'End Date',isnull((Days),0) as Days,isnull((hours),0) as Hours, 
   isnull((al)+(ad)+(bf),0) as 'YTD Days',LeaveStatus as State,
  [Application Submit Date] as 'Leave Submit Date',[Approved Date] as 'Leave Approval Date',
 laid,CompanyId
   from
---step-3
(
--Step2
Select la.[Leave type],[Approved Date],[Application Submit Date],[To Date],[From Date],LeaveStatus,CompanyId,
ISNULL(gg.AnnualLeaveEntitlement,0) as AL,ISNULL(gg.Adjustment,0) as ad,isnull(BroughtForward,0) as bf
,Days,(CONVERT(VARCHAR(MAX),Hours)+'Hr'+'s') as hours,laid
--,EDD.[Employee Name],EDD.EmployeeNo,EDD.Dept,EDD.[Dept Name],EDD.Designation
From
(  --step1
	select  la.CompanyId,/*la.employeeid,*/lt.name[Leave type],YEAR(la.startdatetime) As Year,
	convert(date,la.StartDateTime) [From Date],convert(date,la.EndDateTime) [To Date],la.id,la.EmployeeId as laid,la.LeaveTypeId as ltid,
		   la.LeaveStatus,convert(date,la.CreatedDate) [Application Submit Date],
		   convert(date,Historydate) [Approved Date],la.days ,la.hours--,EDD.[Employee Name],EDD.EmployeeNo,EDD.Dept,EDD.[Dept Name],EDD.Designation
	
	from   hr.LeaveApplication la 
	--join   hr.LeaveApplicationHistory lah on lah.LeaveApplicationId=la.Id
	join   hr.LeaveType lt on lt.id=la.LeaveTypeId

	 left join
	 (
		 Select Historydate,lahid,apid,LeaveTypeId
		 From
		 (
			 select RANK() over (partition by leaveApplicationId,LeaveTypeId,StatusChangedEmployeeId order by CreatedDate desc) rank, 
			  createddate as Historydate,leavestatus as leavestate,
			StatusChangedEmployeeId as lahid,LeaveTypeId,LeaveApplicationId as apid   from hr.LeaveApplicationHistory
			where LeaveStatus='Approved'
		)dt1
		where rank=1
	  --order by EmployeeId
	  ) ll on ll.lahid=la.EmployeeId and ll.LeaveTypeId=la.LeaveTypeId and ll.apid=la.Id
	   Where la.CompanyId=@CompanyValue
	   --step1 ending
)la
inner join
 (
	 select  le.AnnualLeaveEntitlement,le.BroughtForward, Le.Adjustment,
	 le.EmployeeId as leid,le.LeaveTypeId  from hr.LeaveEntitlement as le

  --order by EmployeeId
  ) gg on gg.leid=la.laid and gg.LeaveTypeId=la.ltid
--Step2 ending

) ss
  group by [Leave type], [From Date],[To Date],LeaveStatus,
  [Application Submit Date],[Approved Date],Days,Hours,al,ad,bf,laid,CompanyId

  )ff

inner Join
(   
select CompanyId,Id,EmployeeId as EmployeeNo,DepartmentId,[Employee Name],StartDate,EndDate,Dept as [Dept Name],code as[Dept],EffectiveFrom,EffectiveTo,BasicPay AS Salary,Designation,subsidiarycompanyId
    from
    (
     select rank() over(partition by ed.employeeid/*ed.departmentId*/ order by Ed.Recorder desc,EffectiveTo desc) as rank  ,e.employeeid,e.firstname as [Employee Name],emp.StartDate,emp.EndDate,ed.EmployeeId as Id,D.Name as Dept,DD.Name as Designation,cast(EffectiveFrom as Date) EffectiveFrom,cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01'))
 else EffectiveTo end  as Date) as EffectiveTo, 
         Ed.DepartmentId,ED.DepartmentDesignationId,D.code,ED.CompanyId AS subsidiarycompanyId,E.companyId,ED.BasicPay
     from   hr.EmployeeDepartment as ED
	 Join   hr.Employment emp on emp.employeeid=ed.employeeid
     join   Common.Department as D on D.Id=ED.DepartmentId 
     join   Common.DepartmentDesignation as DD on DD.ID=ED.DepartmentDesignationId
     join   Common.Employee as E on E.Id=ED.EmployeeId 
	 join   common.company c on C.id=Ed.companyid

     where  E.CompanyId=@CompanyValue --and  ED.employeeid in('C5FDC2AF-5C11-3A37-769B-15F5A33CB30D','A66726F0-57F3-603D-0657-5A604F8939BA')
     and   ((@FromDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01'))
 else EffectiveTo end  as Date)) or (@Todate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01'))
 else EffectiveTo end  as Date)))

      and    D.Code in (select items from dbo.SplitToTable(@Department,','))
			   and    DD.Name in (select items from dbo.SplitToTable(@Designation,','))

			
	  --And  C.name in  (select items from dbo.SplitToTable(@SubsidiaryCompany,','))

     --order by ED.EmployeeId
    ) as E
     where E.rank=1
) EDD on EDD.CompanyId=ff.CompanyId and EDD.ID=ff.laid and convert(date,ff.[Leave Submit Date]) between EDD.EffectiveFrom and EDD.EffectiveTo 

where 
  [Employee Name] in (select items from dbo.SplitToTable(@Employee,','))
 and  Type in (select items from dbo.SplitToTable(@Leavetype,','))
order by [Employee Name]

end
GO
