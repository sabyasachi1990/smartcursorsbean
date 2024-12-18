USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Dashboard_Emp_Feature_Wise_Details]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [HR_Dashboard_Emp_Feature_Wise_Details] 'eb6fd947-f379-4af8-b1e7-29dd8f2d815c',1077  
CREATE procedure [dbo].[HR_Dashboard_Emp_Feature_Wise_Details]  
@Empid uniqueidentifier,  
@Companyid bigint  
As begin  
begin try  
   
declare @HRSettingDetailId uniqueidentifier = ( select HSD.Id from Common.HRSettings HS (NOLOCK)  
            Join Common.HRSettingdetails HSD (NOLOCK) on HS.Id = HSD.MasterId  
            where HS.CompanyId=@Companyid and HSD.EndDate = HS.ResetLeaveBalanceDate)  
  
declare @FromDate date = (SELECT DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0)),  
@ToDate date = (SELECT DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0)))  
  
declare @recentDate datetime2(7) = (select top 1 A.Date from Common.Attendance A (NOLOCK) join Common.AttendanceDetails AD (NOLOCK) on A.Id = AD.AttendenceId   
where A.CompanyId=@Companyid and AD.EmployeeId= @Empid and Ad.TimeFrom is not null /*and AD.timeto is not null*/ order by A.Date desc)  
  
declare @Att_FromDate_1 date = (SELECT DATEADD(mm, DATEDIFF(mm, 0, @recentDate), 0)),  
@Att_ToDate_1 date = (SELECT DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @recentDate) + 1, 0)))  
  
  
if(Convert(date,getutcdate()) > CONVERT(date,@recentDate))  
 set @Att_ToDate_1 = (SELECT DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @recentDate) + 1, 0)))  
else if(CONVERT(date,@recentDate) >= Convert(date,getutcdate()))  
    set @Att_ToDate_1 = Convert(date,getutcdate())  
  
declare @Att_FromDate date = (select top 1 A.Date from Common.Attendance A (NOLOCK) join Common.AttendanceDetails AD (NOLOCK) on A.Id = AD.AttendenceId   
where A.CompanyId=@Companyid and AD.EmployeeId= @Empid and AD.TimeFrom is not null/* and TimeTo is not null*/ and A.Date between Convert(date, @Att_FromDate_1) and Convert(date,@Att_ToDate_1) order by A.Date)  
--print @Att_FromDate  
  
declare @Att_ToDate date =(select top 1 A.Date from Common.Attendance A (NOLOCK) join Common.AttendanceDetails AD (NOLOCK) on A.Id = AD.AttendenceId   
where A.CompanyId=@Companyid and AD.EmployeeId= @Empid and Ad.TimeFrom is not null /*and TimeTo is not null*/ and A.Date between Convert(date,@Att_FromDate_1) and Convert(date,@Att_ToDate_1) order by A.Date desc)  
--print @Att_ToDate  
  
declare @T table (Dates DATETIME2(7))  
declare @from_date datetime2(7)  
declare @to_date datetime2(7)  
declare calendardatecursor cursor for ((select FromDateTime, ToDateTime from Common.Calender C (NOLOCK)  
left join Common.CalenderDetails CD (NOLOCK) on C.Id = CD.MasterId  
where C.Status=1 and CompanyId=@Companyid and (ApplyTo='All' OR CD.EmployeeId=@Empid)  and (DATEPART(month, fromdatetime) = DATEPART(MONTH, @Att_FromDate) OR  DATEPART(month, ToDateTime) = DATEPART(MONTH, @Att_ToDate)) and (DATEPART(YEAR, fromdatetime) = 
DATEPART(YEAR, @Att_FromDate) AND  DATEPART(YEAR, ToDateTime) = DATEPART(YEAR, @Att_ToDate)))  
union all  
(select LA.StartDateTime, LA.EndDateTime from hr.LeaveApplication LA (NOLOCK)  
join hr.LeaveType LT (NOLOCK) on LA.LeaveTypeId = LT.Id  
where LA.CompanyId=@Companyid and LT.CompanyId=@Companyid and LT.EntitlementType != 'Hours' and LA.LeaveStatus='Approved' and LA.EmployeeId=@Empid and DATEPART(YEAR, LA.StartDateTime) = DATEPART(YEAR, @Att_FromDate) AND  DATEPART(YEAR, LA.EndDateTime) = DATEPART(YEAR, @Att_ToDate) and DATEPART(MONTH, LA.StartDateTime) = DATEPART(MONTH, @Att_FromDate) AND  DATEPART(MONTH, LA.EndDateTime) = DATEPART(MONTH, @Att_ToDate)))  
open calendardatecursor  
 fetch next from calendardatecursor into @from_date, @to_date          --- inserting Leaves and Holidays in @T table  
while @@FETCH_STATUS > -1     
BEGIN    
 insert into @T  
 select Convert(date, DATEADD(DAY,number,@from_date)) [Date]  
 FROM master..spt_values  
 WHERE type = 'P'  
 AND DATEADD(DAY,number,@from_date) <= @to_date   
  
 fetch next from calendardatecursor into @from_date, @to_date  
end  
  
close calendardatecursor  
deallocate calendardatecursor  
  
declare @totalDays int = (select DATEDIFF(day, @Att_FromDate_1, @Att_ToDate_1)) +1     ---- Total Days in Months  
;WITH mycte AS  
(  
    SELECT CAST(@Att_FromDate_1 AS DATETIME) DateValue  
    UNION ALL  
    SELECT  DateValue + 1  
    FROM    mycte        
    WHERE   DateValue + 1 <= @Att_ToDate_1   
) insert into @T select Convert(date,DateValue) FROM mycte join Common.WorkWeekSetUp W (NOLOCK) on w.WeekDay =  DATENAME(WEEKDAY,CONVERT(date,DateValue)) AND W.CompanyId=@Companyid and W.EmployeeId is null and W.IsWorkingDay=0  
--insert into @T  
--select A.Date from Common.Attendance A join Common.AttendanceDetails AD on A.Id = AD.AttendenceId   
--where A.CompanyId=@Companyid and AD.EmployeeId= @Empid and AD.TimeFrom is not null and AD.TimeTo is not null  
--and A.Date between @Att_FromDate and @Att_ToDate   
--and (DATENAME(WEEKDAY,CONVERT(date,A.Date)) in (select WeekDay from Common.WorkWeekSetUp where CompanyId=@Companyid and EmployeeId is null and IsWorkingDay=0))                                                     ---- Insert non-working Days into @T table  
  
declare @Holiday_Leave_Dates_cnt bigint = (select count(distinct Dates) from @T where Dates between Convert(Date,@Att_FromDate_1) and Convert(Date,@Att_ToDate_1))   
  
set @totalDays = @totalDays - @Holiday_Leave_Dates_cnt  
  
--declare @LeaveTypeid uniqueidentifier =(select Id from hr.LeaveType where status=1 and  CompanyId=@Companyid and (Upper(Name)=Upper('Annual Leave') OR Upper(Name)=Upper('Annual')))  
declare @LeaveTypeid uniqueidentifier =(select Id from hr.LeaveType (NOLOCK) where status=1 and  CompanyId=@Companyid  and Upper(Name)=Upper('Annual'))  
  
if(@LeaveTypeid is null or @LeaveTypeid='00000000-0000-0000-0000-000000000000')  
begin  
set @LeaveTypeid  =(select Id from hr.LeaveType (NOLOCK) where status=1 and  CompanyId=@Companyid and Upper(Name)=Upper('Annual Leave'))  
end   
--Annual Leave   
  
   
  
--select NEWID() ID,gg.EmpName,gg.DeptName,gg.Designation,'AnnualLeave' Type,COnvert(Nvarchar(20),SUM(ApprovedAndTaken))Value1,COnvert(Nvarchar(20),Count(LeaveBalance))AS Value2, Null 'Item Name'  
--,Null as PhotoURL from   
--(  
--    select E.FirstName EmpName,d.name DeptName,dd.Name Designation,Days As ApprovedAndTaken,le.LeaveBalance ,'AnnualLeave' As Type,l.EmployeeId  
-- --,MR.Small  
--  from hr.LeaveApplication l  
--    Inner join HR.LeaveEntitlement le on le.LeaveTypeId=l.LeaveTypeId and l.EmployeeId=le.EmployeeId  
--    INNER join hr.EmployeeDepartment as ED on ED.EmployeeId=l.EmployeeId  
--    INNER Join hr.Employment emp on emp.employeeid=ed.employeeid  
--    INNER join Common.Department as D on D.id=ED.DepartmentId   
--    INNER join Common.DepartmentDesignation as DD on DD.Id=ED.DepartmentDesignationId  
--    INNER join Common.Employee as E on E.Id=ED.EmployeeId    
-- --Left join Common.MediaRepository MR on MR.Id = E.PhotoId  
--    and (Convert(Date,EffectiveFrom) <= Convert(date,GetDate()) and (Convert(Date,EffectiveTo) >= Convert(date,GetDate()) or EffectiveTo Is null))  
--    where l.CompanyId=@Companyid and e.Status=1 and l.EmployeeId=@Empid and l.LeaveTypeId=@LeaveTypeid  
--    AND LeaveStatus in ('Approved','For Cancellation') and le.EntitlementStatus=1  
--)as GG  
--Group by EmpName,DeptName,Designation  
  
--select NEWID() ID,Null as EmpName,Null as DeptName,Null as Designation,'AnnualLeave' Type,ApprovedAndTaken as Value1,LeaveBalance AS Value2, Null 'Item Name'  
--,Null as PhotoURL from   
--(  
--  select Null EmpName,Null DeptName,Null Designation,ApprovedAndTaken ,LeaveBalance ,'AnnualLeave' As Type, EmployeeId from  HR.LeaveEntitlement as le where status=1  
--  and EmployeeId=@Empid and LeaveTypeId=@LeaveTypeid  
--  and  EntitlementStatus=1     
  
--)as GG  
   
  
select NEWID() ID,Null as EmpName,Null as DeptName,Null as Designation,'AnnualLeave' Type,Convert(nvarchar(20),ApprovedAndTaken) as Value1,YTDLeaveBalance AS Value2, Null 'Item Name'  
,Null as PhotoURL from   
(  
  select Null EmpName,Null DeptName,Null Designation,ApprovedAndTaken ,YTDLeaveBalance ,'AnnualLeave' As Type, EmployeeId from  HR.LeaveEntitlement as le (NOLOCK) where status=1  
  and EmployeeId=@Empid and LeaveTypeId=@LeaveTypeid  
  and  EntitlementStatus=1 and le.HrSettingDetaiId=@HRSettingDetailId  
  
)as GG  
  
  
  
Union All ---Claims------  
  
   
  
select NEWID() ID,EmpName,DeptName,Designation,'Claims' Type,Convert(nvarchar(20),sum(Value1)) as Value1,Convert(nvarchar(20),sum(Value2)) as Value2,Null 'Item Name',PhotoURL from   
(  
    select  E.FirstName EmpName,d.name DeptName,dd.Name Designation,isnull (case  when ClaimStatus not in ('Rejected','Processed','Cancelled','Drafted') then COUNT(employeid) end,0) AS Value1, isnull(case  when ClaimStatus  in ('Rejected') then COUNT(EmployeId)  end,0) AS Value2,EmployeId   
    ,MR.Small as PhotoURL from HR.EmployeeClaim1 EC (NOLOCK)  
    INNER join hr.EmployeeDepartment as ED (NOLOCK) on ED.EmployeeId=EC.EmployeId  
    INNER Join hr.Employment emp (NOLOCK) on emp.employeeid=ed.employeeid  
    INNER join Common.Department as D (NOLOCK) on D.id=ED.DepartmentId   
    INNER join Common.DepartmentDesignation as DD (NOLOCK) on DD.Id=ED.DepartmentDesignationId  
    INNER join Common.Employee as E (NOLOCK) on E.Id=ED.EmployeeId -- and E.Id=@Empid  
  
 Left join Common.MediaRepository MR (NOLOCK) on MR.Id = E.PhotoId  
    
    and (Convert(Date,EffectiveFrom) <= Convert(date,GetDate()) and (Convert(Date,EffectiveTo) >= Convert(date,GetDate()) or EffectiveTo Is null))  
    where ClaimStatus  is not null /*and e.Status=1*/  
    and EmployeId=@Empid and MasterClaimDate between @FromDate and @ToDate  
    group by ClaimStatus,ec.EmployeId,E.FirstName,d.name,dd.Name,MR.Small   
)as AA  
group by EmpName,DeptName,Designation,AA.PhotoURL  
  
   
  
union all -----payslip-------  
       
--select NEWID() ID,KK.EmpName,KK.DeptName,KK.Designation,'Payslip' Type,Convert(Nvarchar(20),Month) As Value1,Convert(Nvarchar(20),Year) AS value2,Null 'Item Name',kk.PhotoURL  
select NEWID() ID,KK.EmpName,KK.DeptName,KK.Designation,'Payslip' Type, Datename(month,'2019-'+Month+'-01') As Value1,Convert(Nvarchar(20),Year) AS value2,Null 'Item Name',kk.PhotoURL  
from   
(  
    select top 1  p.Month as Month,p.Year as Year,pd.EmployeeId,pd.CreatedDate,PayrollStatus,E.FirstName EmpName,d.name DeptName,dd.Name Designation   
    ,mr.Small as PhotoURL from HR.PayrollDetails pd (NOLOCK)  
    inner join HR.Payroll p (NOLOCK) on p.Id=pd.MasterId  
    INNER join hr.EmployeeDepartment as ED (NOLOCK) on ED.EmployeeId=pd.EmployeeId  
    INNER Join hr.Employment emp (NOLOCK) on emp.employeeid=ed.employeeid  
    INNER join Common.Department as D (NOLOCK) on D.id=ED.DepartmentId   
    INNER join Common.DepartmentDesignation as DD (NOLOCK) on DD.Id=ED.DepartmentDesignationId  
    INNER join Common.Employee as E (NOLOCK) on E.Id=ED.EmployeeId  
 Left Join Common.MediaRepository as MR (NOLOCK) on MR.Id = e.PhotoId   
    and (Convert(Date,ED.EffectiveFrom) <= Convert(date,GetDate()) and (Convert(Date,EffectiveTo) >= Convert(date,GetDate()) or EffectiveTo Is null))  
    where p.PayrollStatus='Processed' and E.Id=@Empid /*and E.Status=1 */  
    order by pd.CreatedDate desc  
)as KK  
   
Union All ---Appraisal--------  
      
select ID,EmpName,DeptName,Designation,'Appraisal' Type,Value1,Value2,Null 'Item Name',AA.PhotoURL from  
(  
    select NEWID() ID,HH.EmpName,HH.DeptName,HH.Designation,hh.ApprisalStatus,hh.EmployeeId,Value1,Null Value2,hh.PhotoURL from   
    (  
        select top 1 a.AppraisalName as Value1,ApprisalStatus,ad.EmployeeId,E.FirstName EmpName,d.name DeptName,dd.Name Designation    
        ,MR.Small as PhotoURL from HR.AppraisalAppraiseeDetails ad (NOLOCK)  
        inner join HR.Appraisal a (NOLOCK) on a.Id=ad.AppraisalId  
        INNER join hr.EmployeeDepartment as ED (NOLOCK) on ED.EmployeeId=ad.EmployeeId  
        INNER Join hr.Employment emp (NOLOCK) on emp.employeeid=ed.employeeid  
        INNER join Common.Department as D (NOLOCK) on D.id=ED.DepartmentId   
        INNER join Common.DepartmentDesignation as DD (NOLOCK) on DD.Id=ED.DepartmentDesignationId  
        INNER join Common.Employee as E (NOLOCK) on E.Id=ED.EmployeeId  
  Left Join Common.MediaRepository as MR (NOLOCK) on MR.Id = e.PhotoId  
        where ApprisalStatus='Published' and ad.EmployeeId=@Empid and ad.IsSelected=1 order by case when AsAppraisalModifiedDate is null then a.CreatedDate else AsAppraisalModifiedDate end desc
    )as HH  
)as AA  
    
union All ----Training----  
         
select NEWID() ID,gg.EmpName,gg.DeptName,gg.Designation,'Training' AS Type,Convert(nvarchar(20),sum(Value1)) as Value1,Convert(nvarchar(20),sum(Value2)) as Value2,Null 'Item Name' ,gg.PhotoURL from   
(  
    select  E.FirstName EmpName,d.name DeptName,dd.Name Designation,isnull(case when EmployeeTrainigStatus='Registered' then count(TA.EmployeeId) end,0) AS Value2, isnull(case when EmployeeTrainigStatus='Invited' then count(TA.EmployeeId) end ,0) AS Value1,TA.EmployeeId   
     ,MR.Small as PhotoURL from HR.TrainingAttendee TA (NOLOCK)  
    INNER join hr.EmployeeDepartment as ED (NOLOCK) on ED.EmployeeId=TA.EmployeeId and (Convert(Date,EffectiveFrom) <= Convert(date,GetDate()) and (Convert(Date,EffectiveTo) >= Convert(date,GetDate()) or EffectiveTo Is null))  
    INNER Join hr.Employment emp (NOLOCK) on emp.employeeid=ed.employeeid  
    INNER join Common.Department as D (NOLOCK) on D.id=ED.DepartmentId   
    INNER join Common.DepartmentDesignation as DD (NOLOCK) on DD.Id=ED.DepartmentDesignationId  
    INNER join Common.Employee as E (NOLOCK) on E.Id=ED.EmployeeId    
  
 Left Join Common.MediaRepository as MR (NOLOCK) on MR.Id = e.PhotoId   
    
    --and (Convert(Date,EffectiveFrom) <= Convert(date,GetDate()) and (Convert(Date,EffectiveTo) >= Convert(date,GetDate()) or EffectiveTo Is null))  
    where EmployeeTrainigStatus in ('Registered' ,'Invited') and E.Id=@Empid /* and E.Status=1 */  
    group by  EmployeeTrainigStatus,TA.EmployeeId, E.FirstName,d.name,dd.Name,MR.Small  
)GG  
Group by gg.EmpName,gg.DeptName,gg.Designation,GG.PhotoURL  
  
   
  
Union All -- Attendance---  
      
select NEWID() ID,gg.EmpName,gg.DeptName,gg.Designation,'Attendance' Type,Convert(nvarchar(20),Value1) + ' ' + CONVERT(nvarchar(10), YEAR(@recentDate))  as   Value1, Convert(bigint,Value2)Value2,Null 'Item Name',AA.PhotoURL  
from   
(  
    --select (AD.EmployeeId), Datename(MONTH,@recentDate) As Value1, cast (COUNT (AD.EmployeeId)/cast (DAY(EOMONTH(@recentDate)) as decimal(28,3)) as decimal(28,3))*100 as Value2  
    --,Null as PhotoURL  from Common.AttendanceDetails ad  
    --inner join Common.Attendance A on A.Id=ad.AttendenceId  
    --where A.Date between @Att_FromDate and @Att_ToDate and (Ad.LateIn != 1 OR Ad.LateIn is null)  
    --and AD.EmployeeId = @Empid and Ad.TimeFrom is not null and AD.timeto is not null  
    --group by AD.EmployeeId  
  
 select (AD.EmployeeId), Datename(MONTH,@recentDate) As Value1, COnvert(bigint, cast (COUNT (AD.EmployeeId)/ convert ( decimal(28,2), @totalDays) as decimal(28,2))*100) as Value2  
 ,Null as PhotoURL  from Common.AttendanceDetails ad (NOLOCK)  
 inner join Common.Attendance A (NOLOCK) on A.Id=ad.AttendenceId  
 where A.Date between @Att_FromDate and @Att_ToDate and (Ad.LateIn != 1 OR Ad.LateIn is null)  
 and AD.EmployeeId = @Empid and Ad.TimeFrom is not null /*and AD.timeto is not null*/  
    and (A.Date not in (select distinct Dates from @T))  
 group by AD.EmployeeId  
  
) as AA  
Inner join  
(  
    select EmployeeId,EmpName,DeptName,Designation,ff.PhotoURL from   
    (  
        select rank() over(partition by ed.employeeid/*ed.departmentId*/ order by ( case when Ed.[EffectiveTo] is null then dateadd(d,-1,Convert(date,Convert(varchar(100),  
        Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else Ed.[EffectiveTo] end  ) desc) as rank,E.FirstName as EmpName,D.Name AS DeptName,DD.Name as Designation,e.Id as EmployeeId,E.CompanyId  
        ,MR.Small as PhotoURL from   hr.EmployeeDepartment as ED (NOLOCK)  
        Join   hr.Employment emp (NOLOCK) on emp.employeeid=ed.employeeid  
        join   Common.Department as D (NOLOCK) on D.id=ED.DepartmentId   
        join   Common.DepartmentDesignation as DD (NOLOCK) on DD.Id=ED.DepartmentDesignationId  
        join   Common.Employee as E (NOLOCK) on E.Id=ED.EmployeeId   
  
     Left join   Common.MediaRepository as MR (NOLOCK) on MR.Id = e.PhotoId   
  
        where E.Id = @Empid /* and e.Status=1 */  
    )ff  
    where rank=1  
)gg on gg.EmployeeId=AA.EmployeeId  
where AA.EmployeeId=@Empid  
   
Union All ---Recuriment   
  
select NEWID() ID,ee.FirstName As EmpName,d.Code DeptName,dd.Name DesgName,'New Joiner' AS Type,Convert(nvarchar(20),e.StartDate) Value1,Null Value2,Null 'Item Name'   
,MR.Small as PhotoURL   
from HR.employment e (NOLOCK)  
inner join HR.EmployeeDepartment ed (NOLOCK) on e.EmployeeId=ed.EmployeeId  
inner join Common.Department d (NOLOCK) on d.Id=ed.DepartmentId  
inner join Common.DepartmentDesignation dd (NOLOCK) on dd.Id=ed.DepartmentDesignationId  
inner join Common.Employee ee (NOLOCK) on ee.Id=e.EmployeeId  
Left Join Common.MediaRepository as MR (NOLOCK) on MR.Id = ee.PhotoId   
where e.CompanyId=@Companyid and ee.idtype is not null and e.Status=1 and e.StartDate between @FromDate and @ToDate   
and (Convert(Date,ED.EffectiveFrom) <= Convert(date,GetDate()) and ( EffectiveTo Is null or Convert(Date,ED.EffectiveTo) >= Convert(date,GetDate())))  
--and e.EndDate between @FromDate and @ToDate  
  
delete @T  
  
end try  
begin catch  
 Print 'Failed'  
 delete @T  
 SELECT     
    ERROR_NUMBER() AS ErrorNumber    
    ,ERROR_MESSAGE() AS ErrorMessage;    
end catch  
end  
  
  
GO
