USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_NumberOfLeavesCount_Test]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  
 Procedure [dbo].[SP_NumberOfLeavesCount_Test]
--declare
 @StartDateTime datetime,--='2020-03-18',
@StartTimeHours time(7),--='14:00:00.0000000',
@EndTimeHours time(7),--='18:00:00.0000000',
@EmployeeId uniqueidentifier,--='86febd3e-3e15-4608-b9e9-ab89d341b935',
@value int,--=1,
@Comparevalue int,--=0,
@companyId bigint
AS 
BEGIN--E
IF EXISTS(select id from Common.WorkWeekSetUp (NOLOCK) where CompanyId=@companyId and EmployeeId is null and WeekDay=(SELECT datename(dw,@StartDateTime))and IsWorkingDay=0)
BEGIN--m4
	set @Comparevalue=1
END--m4
ELSE--m3
BEGIN 
	IF EXISTS(Select C.Id from Common.Calender C (NOLOCK)
			  left join Common.CalenderDetails CL (NOLOCK) on C.Id = CL.MasterId
			   Where (CL.EmployeeId = @EmployeeId or C.ApplyTo='All')and c.CalendarType='Holidays' and CompanyId=@companyId And ChargeType='Non-Working' And convert(Date,@StartDateTime) Between CONVERT(Date,FromDateTime)    And    Convert (Date,ToDateTime) and C.Status = 1)
	BEGIN--m1
		IF EXISTS(select tl2.Id from Common.Calender ca (NOLOCK) join Common.TimeLogItem tl1 (NOLOCK) on ca.Id=tl1.SystemId join Common.TimeLogItem tl2 (NOLOCK) on tl2.SystemId=tl1.Id where   convert(date,tl2.StartDate) =convert(date,@StartDateTime) and convert(date,tl2.EndDate) =convert(date,@StartDateTime) and tl1.CompanyId=@companyId and 
		@value=(case 
		--when (tl2.TimeType='AM' and (( (cast(@EndTimeHours as varchar)>=cast(tl2.FirstHalfFromTime as varchar)  and cast(@EndTimeHours as varchar)<cast(tl2.FirstHalfToTime as varchar))or (cast(tl2.FirstHalfFromTime as varchar)>=cast(@StartTimeHours as varchar) and cast(@StartTimeHours as varchar)<cast(tl2.FirstHalfToTime as varchar )) or(cast(tl2.FirstHalfFromTime as varchar)>=cast(@StartTimeHours as varchar)  and cast(@StartDateTime as varchar)<cast(tl2.FirstHalfToTime as varchar))  ) )) then 1

		when (tl2.TimeType='AM' and (( cast(@EndTimeHours as varchar)<cast(tl2.FirstHalfToTime as varchar))or (cast(@StartTimeHours as varchar)<cast(tl2.FirstHalfToTime as varchar)))) then 1  -- added newly

		when (tl2.TimeType='PM' and (( cast(@EndTimeHours as varchar)>cast(tl2.SecondHalfFromTime as varchar) and cast(@EndTimeHours as varchar)<=cast(tl2.SecondHalfToTime as varchar) ) or ( cast(@StartTimeHours as varchar) >cast(tl2.SecondHalfFromTime as varchar) and cast(@StartTimeHours as varchar)>cast(tl2.SecondHalfToTime as varchar )) or (cast(@EndTimeHours as varchar)>=cast(tl2.SecondHalfToTime as varchar) and cast(@StartTimeHours as varchar)<cast(tl2.SecondHalfToTime as varchar)))) then 1

		when (tl2.TimeType='Full' ) then 1
		else 0 end))
		BEGIN--m2
			SET @Comparevalue=1
		END--m2
	END --m1
END--m3
select @Comparevalue as Comparevalue
END --e
GO
