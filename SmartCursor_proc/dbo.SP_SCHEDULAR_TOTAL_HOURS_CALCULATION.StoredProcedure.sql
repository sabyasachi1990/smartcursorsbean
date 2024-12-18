USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SCHEDULAR_TOTAL_HOURS_CALCULATION]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_SCHEDULAR_TOTAL_HOURS_CALCULATION](@COMPANYID BIGINT, @W_FROMDATE DATE, @W_TODATE DATE, @EMPLOYEEID UNIQUEIDENTIFIER)
AS
BEGIN
BEGIN TRY

	DECLARE @OUTPUT TABLE (EMPLOYEENAME NVARCHAR (1000), STARTDATE DATE,  ENDDATE DATE, TOTALMINUTES BIGINT,TOATLHOURS MONEY, TOTALOVERRUNMINUTES BIGINT,IsOverRunHours Money,EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(2000),PHOTOURL NVARCHAR(1000), SystemId UNIQUEIDENTIFIER, SystemType nvarchar(100), IsActualHrs bit)


	--declare @EMPLOYEETABLE TABLE (EmpId UNIQUEIDENTIFIER, EmpName NVARCHAR(1000))
	--declare @TodayDate date = CONVERT(date, GETDATE())
	--declare @Employee_Id_New uniqueidentifier 

	--declare @CompanyId bigint = 59
	--declare @W_FromDate DateTime = '2018-09-16 12:00:00 AM'
	--declare @W_ToDate DateTime= '2018-09-22 12:00:00 AM'
	--declare @EmployeeId UNIQUEIDENTIFIER = '1651DCA0-D9E3-4934-8959-B83E350B685E' 

		--=============== Planned Hrs Calculation  -- (TOTALMINUTES / 60 + (TOTALMINUTES % 60) / 100.0) AS TOATLHOURS

		insert into @OUTPUT
		select E.FirstName as EMPLOYEENAME, @W_FromDate as STRARTDATE, @W_ToDate AS ENDDATE, SUM(DATEDIFF(MINUTE,0,ST.Hours)) AS TOTALMINUTES, SUM(DATEDIFF(MINUTE,0,ST.Hours))/60.0 As TOATLHOURS, SUM(DATEDIFF(MINUTE,0,ST.IsOverRunHours)) AS TOTALOVERRUNMINUTES, SUM(DATEDIFF(MINUTE,0,ST.IsOverRunHours))/60.0 As IsOverRunHours,
		E.Id AS EMPLOYEEID, e.EmployeeId AS Employeeautonumber, MR.Small AS PHOTOURL, ST.SystemId, ST.SystemType, 0  
		from WorkFlow.ScheduleTask ST
		join WorkFlow.CaseGroup CG on ST.CaseId = CG.Id
		join Common.Employee E on ST.EmployeeId = E.Id 
		LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId    
		where st.CompanyId = @COMPANYID AND ST.EmployeeId = @EMPLOYEEID and  ST.StartDate between @W_FROMDATE and @W_TODATE and CG.ServiceNatureType = 0
		Group by E.FirstName,StartDate,Enddate,E.Id,e.EmployeeId,MR.Small, ST.SystemId, ST.SystemType      --  SystemId AS leaveapplicationid,  SystemType AS LeaveApplication

		--================ Actual Hrs Calculation  -- (TOTALMINUTES / 60 + (TOTALMINUTES % 60) / 100.0) AS TOATLHOURS

		insert into @OUTPUT
		select DIstinct E.FirstName as EMPLOYEENAME, @W_FromDate as STRARTDATE, @W_ToDate AS ENDDATE,SUM(DATEDIFF(MINUTE,0,TLD.Duration)) AS TOTALMINUTES, SUM(DATEDIFF(MINUTE,0,TLD.Duration))/60.0 As TOATLHOURS, 0 As IsOverRunHours, 0 AS TOTALOVERRUNMINUTES,
		E.Id AS EMPLOYEEID, e.EmployeeId AS Employeeautonumber, MR.Small AS PHOTOURL, TLI.SystemId, TLI.SystemType, 1 
		from Common.TimeLog TL
		join Common.TimeLogDetail TLD on TL.Id = TLD.MasterId
		join Common.TimeLogItem TLI on Tl.TimeLogItemId = TLI.Id
		join Common.Employee E on E.Id = TL.EmployeeId
		LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId    
		where TL.CompanyId = @COMPANYID AND TL.EmployeeId = @EMPLOYEEID and  TL.StartDate between @W_FROMDATE and @W_TODATE 
		And TLI.SystemType <> 'LeaveApplication'
		Group by E.FirstName,TL.StartDate,TL.Enddate,E.Id,e.EmployeeId,MR.Small, TLI.SystemId, TLI.SystemType    -- SystemId AS leaveapplicationid,  SystemType AS LeaveApplication
	
		--fetch next from SchedularHours_Cursor into @Employee_Id_New
	
	--close SchedularHours_Cursor
	--deallocate SchedularHours_Cursor

	--update @OUTPUT set IsActualHrs=0 where SystemType='CaseGroup' and IsActualHrs=1

	-- (TOTALMINUTES / 60 + (TOTALMINUTES % 60) / 100.0) AS TOATLHOURS

	Select EMPLOYEENAME, STARTDATE,  ENDDATE, (TOTALMINUTES) as TOTALMINUTES, (TOTALMINUTES / 60 + (TOTALMINUTES % 60) / 100.0) AS TOATLHOURS,  (TOTALOVERRUNMINUTES) AS TOTALOVERRUNMINUTES, (TOTALOVERRUNMINUTES / 60 + (TOTALOVERRUNMINUTES % 60) / 100.0) AS ISOVERRUNHOURS,EMPLOYEEID,EMPLOYEEAUTONUMBER ,PHOTOURL, SystemId, SystemType, IsActualHrs
	From @OUTPUT
	
END TRY
BEGIN CATCH
	PRINT('FAILED..!')
END CATCH

END










GO
