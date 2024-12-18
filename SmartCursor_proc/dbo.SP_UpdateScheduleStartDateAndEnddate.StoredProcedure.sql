USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_UpdateScheduleStartDateAndEnddate]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_UpdateScheduleStartDateAndEnddate](@CaseId uniqueidentifier)
AS BEGIN 
DECLARE @TempTable TABLE (EmployeeId uniqueidentifier,caseid uniqueidentifier, STARTDATE DATE,  ENDDATE DATE, TOTAL_HOURS MONEY)
	 
	 INSERT INTO @TempTable (EmployeeId,caseid, STARTDATE, ENDDATE, TOTAL_HOURS)

	 select EmployeeId,CaseId,MIN(StartDate) as StartDate, MAX(EndDate) as EndDate, SUM(DATEDIFF(MINUTE,0,HOURS))/60.0 AS TOTAL_HOURS
from WorkFlow.ScheduleTask where caseid=@CaseId group by EmployeeId,caseid

	 update WorkFlow.ScheduleDetail set StartDate=T.STARTDATE, EndDate=T.ENDDATE, IsLocked=1 from  @TempTable T JOIN WorkFlow.Schedule S ON T.caseid=S.CaseId join WorkFlow.ScheduleDetail SD ON SD.MasterId=S.Id where SD.MasterId=s.Id and SD.EmployeeId=t.EmployeeId and s.CaseId=T.caseid AND T.TOTAL_HOURS >  0

END








GO
