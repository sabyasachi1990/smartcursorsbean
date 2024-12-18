USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_TEAM_CALENDAR_1]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[HR_TEAM_CALENDAR_1](@companyId nvarchar(10), @companyUserId nvarchar(10), @startDate nvarchar(50), @endDate nvarchar(50),@employeId nvarchar(250),@userId uniqueIdentifier)
AS
BEGIN

declare @TeamCalendarId uniqueidentifier = (select Id from hr.TeamCalendar (NOLOCK) where CompanyUserId = @companyUserId)
declare @DynSQl Nvarchar(Max)
set @employeId = ISNULL(@employeId,'00000000-0000-0000-0000-000000000000')

declare @TeamCalendarDetailCount nvarchar(20) = (select count(TCD.EmployeeId) from hr.TeamCalendar TC (NOLOCK) join hr.TeamCalendarDetail  TCD (NOLOCK) on TC.Id = TCD.MasterId where TC.CompanyUserId=@CompanyUserId)
print @TeamCalendarDetailCount

Set @DynSQl=   'IF '+@TeamCalendarDetailCount+' <> 0
                    select TCD.EmployeeId from hr.TeamCalendar TC (NOLOCK)
                    join hr.TeamCalendarDetail  TCD (NOLOCK) on TC.Id = TCD.MasterId
                    where TC.CompanyUserId='+@CompanyUserId+'
                Else
                    select Id as Id from Common.Employee (NOLOCK) where Id='''+@employeId+'''
                  union all
                    select ED.ReportingManagerId as employeeId from Common.Employee E (NOLOCK)
                    Join hr.EmployeeDepartment ED (NOLOCK) on E.Id = ED.EmployeeId
                    where E.Id='''+@employeId+''' and E.Status=1 and (Convert(date,ED.EffectiveFrom) <= CONVERT(date,GETDATE()) AND (ED.EffectiveTo IS NULL or CONVERT(date,ED.EffectiveTo) >= CONVERT(date,GETDATE())))
				  union all
					select distinct ED.EmployeeId as employeeId from Common.Employee E (NOLOCK)
					Join hr.EmployeeDepartment ED (NOLOCK) on E.Id = ED.EmployeeId
					where ED.ReportingManagerId='''+@employeId+''' and E.Status=1 and (Convert(date,ED.EffectiveFrom) <= CONVERT(date,GETDATE()) AND (ED.EffectiveTo IS NULL or CONVERT(date,ED.EffectiveTo) >= CONVERT(date,GETDATE())))'
Print (@DynSQl)
--Exec(@DynSQl)

declare  @temp table (Id uniqueidentifier);
insert into @temp
Exec(@DynSQl)

--select * from @temp
print @TeamCalendarDetailCount
select  distinct id as EmployeeId, FirstName as EmployeeName,null as ItemName,null as Itemtype, null as StartDate, null as EndDate,null as ItemStatus , null as ColorOrder, null as TeamCalendarDetailId, null  as TeamCalendarId,
 null as CourseCode, null as CourseName, null as CourseCategory, null as FirstHalfFromTime, null as FirstHalfToTime, null as SecondHalfFromTime, null as SecondHalfToTime, null as FirstHalfTotalHours, null as SecondHalfTotalHours, null as EntitlementType,null  as StartDateType,null as EndDateType , null as LeaveHours  ,(select mr.Small from Common.MediaRepository as mr (NOLOCK) join common.Employee as e (NOLOCK) on mr.id=e.PhotoId where e.id=emp.Id) as PhotoURL
	from  common.Employee as emp (NOLOCK) where emp.id in (select Id from @temp)
	Union all
select  distinct ad.EmployeeId as EmployeeId, ad.EmployeeName as EmployeeName,'Holidays' as ItemName, c.Name as Itemtype, c.FromDateTime as StartDate, c.ToDateTime as EndDate,'Holiday' as ItemStatus , TCD.[Order] as ColorOrder, TCD.Id as TeamCalendarDetailId, TCD.MasterId as TeamCalendarId,
 null as CourseCode, null as CourseName, null as CourseCategory, null as FirstHalfFromTime, null as FirstHalfToTime, null as SecondHalfFromTime, null as SecondHalfToTime, null as FirstHalfTotalHours, null as SecondHalfTotalHours, null as EntitlementType,T2.TimeType as StartDateType,T2.TimeType as EndDateType , T2.Hours as LeaveHours  ,(select mr.Small from Common.MediaRepository as mr (NOLOCK) join common.Employee as e (NOLOCK) on mr.id=e.PhotoId where e.id= ad.EmployeeId) as PhotoURL
	from  Common.AttendanceDetails as ad (NOLOCK) join [Common].[Calender] as c (NOLOCK) on ad.CalanderId = c.Id	
	left Join hr.TeamCalendarDetail TCD (NOLOCK) on TCD.EmployeeId = ad.EmployeeId and TCD.MasterId = @TeamCalendarId
	left join common.TimelogItem T1 (NOLOCK) on T1.SystemId=C.Id 	
	left join common.TimeLogItem T2 (NOLOCK) on T2.SystemId =T1.Id where ad.AttendenceId in(Select id from Common.Attendance (NOLOCK) where CompanyId=@companyId and CONVERT(date, Date) >= Convert(date, @startDate) AND CONVERT(date, Date) <= CONVERT(date, @endDate))
and ad.EmployeeId IN (select Id from @temp) and CalanderId is not null 

union all

select distinct  ad.EmployeeId as EmployeeId, ad.EmployeeName as EmployeeName ,'Leaves' as ItemName,LT.Name as ItemType, LA.StartDateTime as StartDate, LA.EndDateTime as EndDate, LA.LeaveStatus as ItemStatus,TCD.[Order] as ColorOrder, TCD.Id as TeamCalendarDetailId, TCD.MasterId as TeamCalendarId, 
 null as CourseCode, null as CourseName, null as CourseCategory, null as FirstHalfFromTime, null as FirstHalfToTime, null as SecondHalfFromTime, null as SecondHalfToTime, null as FirstHalfTotalHours, null as SecondHalfTotalHours, EntitlementType as EntitlementType, StartDateType as StartDateType, EndDateType as EndDateType,   Convert(nvarchar(100),LA.Hours) as LeaveHours ,(select mr.Small from Common.MediaRepository as mr (NOLOCK) join common.Employee as e (NOLOCK) on mr.id=e.PhotoId where e.id= ad.EmployeeId) as PhotoURL
  from Common.AttendanceDetails as ad (NOLOCK)  left Join hr.TeamCalendarDetail TCD  (NOLOCK) on TCD.EmployeeId = ad.EmployeeId and TCD.MasterId = @TeamCalendarId 
	left Join Hr.LeaveApplication LA (NOLOCK) on ad.EmployeeId= LA.EmployeeId
	left Join hr.LeaveType LT (NOLOCK) on LT.Id = LA.LeaveTypeId
 where  ad.AttendenceId in(	select id from Common.Attendance (NOLOCK) where CompanyId=@companyId and CONVERT(date, Date) >= Convert(date, @startDate) AND CONVERT(date, Date) <= CONVERT(date, @endDate))
 	and (CONVERT(date, LA.StartDateTime) >= Convert(date, @startDate) AND CONVERT(date, LA.StartDateTime) <= CONVERT(date, @endDate) OR (LA.StartDateTime is null OR LA.EndDateTime is null) OR CONVERT(date, LA.EndDateTime) >= Convert(date, @startDate) AND CONVERT(date, LA.EndDateTime) <= CONVERT(date, @endDate))
and ad.EmployeeId IN (select Id from @temp) and LeaveApplicationId is not null and (LA.LeaveStatus='Submitted' or LA.LeaveStatus = 'Approved' OR LA.LeaveStatus='Recommended'  )

union all

select  distinct ad.EmployeeId as EmployeeId, ad.EmployeeName as EmployeeName ,'Training' as ItemName,CL.CourseName as Itemtype,TLI.StartDate,TLI.EndDate,TA.EmployeeTrainigStatus as ItemStatus ,TCD.[Order] as ColorOrder, TCD.Id as TeamCalendarDetailId, TCD.MasterId as TeamCalendarId,
CL.CourseCode as CourseCode, CL.CourseName as CourseName, CL.CourseCategory as CourseCategory, TS.FirstHalfFromTime, TS.FirstHalfToTime, TS.SecondHalfFromTime, TS.SecondHalfToTime, TS.FirstHalfTotalHours, TS.SecondHalfTotalHours, null as EntitlementType, null as StartDateType, null as EndDateType,null as LeaveHours,(select mr.Small from Common.MediaRepository as mr (NOLOCK) join common.Employee as e (NOLOCK) on mr.id=e.PhotoId where e.id= ad.EmployeeId) as PhotoURL
from Common.AttendanceDetails as ad (NOLOCK)
 left Join hr.TeamCalendarDetail TCD (NOLOCK) on TCD.EmployeeId = ad.EmployeeId and TCD.MasterId = @TeamCalendarId 
	left join hr.TrainingAttendee TA (NOLOCK) on ad.EmployeeId=TA.EmployeeId
	left join common.TimeLogItem as TLI (NOLOCK) on TLI.id=ad.TrainingId 
	left join common.timelogitemdetail as tlid (NOLOCK) on tlid.TimeLogItemId=TLI.Id
	left join  hr.Training T (NOLOCK) on t.id=TLI.SystemId and t.id=ta.TrainingId
left join   hr.CourseLibrary as CL (NOLOCK) on t.CourseLibraryId=cl.Id
	left join hr.TrainingSchedule TS (NOLOCK) on T.Id=TS.TrainingId
 where  ad.AttendenceId in(	select id from Common.Attendance (NOLOCK) where CompanyId=@companyId and CONVERT(date, Date) >= Convert(date, @startDate) AND CONVERT(date, Date) <= CONVERT(date, @endDate))
and ad.EmployeeId IN (select Id from @temp) and ad.trainingId is not null and (TA.EmployeeTrainigStatus='Registered' or TA.EmployeeTrainigStatus='Completed'  OR TA.EmployeeTrainigStatus='Absent' OR TA.EmployeeTrainigStatus='Incomplete') and CL.CourseName  is not null

end 
GO
