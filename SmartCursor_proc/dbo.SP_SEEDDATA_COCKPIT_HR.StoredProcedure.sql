USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SEEDDATA_COCKPIT_HR]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SP_SEEDDATA_COCKPIT_HR]

@CompanyId BigInt

As
Begin

-- Exec [dbo].[SP_SEEDDATA_COCKPIT_HR] 1716

---- [Report].[Report] -------- 

Declare @RecruitmentDashboardID UNIQUEIDENTIFIER;
Declare @EmployeesDashboardID UNIQUEIDENTIFIER;
Declare @AttendanceDashboardID UNIQUEIDENTIFIER;
Declare @LeavesDashboardID UNIQUEIDENTIFIER;
Declare @TrainingDashboardID UNIQUEIDENTIFIER;
Declare @ClaimsDashboardID UNIQUEIDENTIFIER;
Declare @PayrollDashboardID UNIQUEIDENTIFIER;

Declare @CPFSummaryReportId UNIQUEIDENTIFIER;
Declare @PayrollComponentReportId UNIQUEIDENTIFIER;
Declare @PayrollReportMonthlyReportId UNIQUEIDENTIFIER;
Declare @YTDReporEmployeetId UNIQUEIDENTIFIER;



----[Report].[ReportCategory]-------

Declare @RecruitmentId UNIQUEIDENTIFIER;
Declare @EmployeesId UNIQUEIDENTIFIER;
Declare @AttendanceId UNIQUEIDENTIFIER;
Declare @LeavesId UNIQUEIDENTIFIER;
Declare @TrainingsId UNIQUEIDENTIFIER;
Declare @ClaimsId UNIQUEIDENTIFIER;
Declare @PayrollId UNIQUEIDENTIFIER;


----------------------------- Recruitment  ----------------------

SET @RecruitmentId = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Recruitment' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@RecruitmentId, @CompanyId,'Recruitment', 'Recruitment', 1, 'System', GETUTCDATE(), '', '', 1,'Recruitment' ,'HR','hr_jobpostings_analytics,hr_jobapplications_analytics','' )

End

-- 1.0 Dashboard

SET @RecruitmentDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Recruitment' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@RecruitmentDashboardID, @CompanyId, 'Recruitment',  'RecruitmentDashboard','reports-icons leads-icon','/HR-PRD/RecruitmentDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','hr_recruitment_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @RecruitmentId, @RecruitmentDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End

----------------------------- Employees  ----------------------

SET @EmployeesId = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Employees' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@EmployeesId, @CompanyId,'Employees', 'Employees', 2, 'System', GETUTCDATE(), '', '', 1,'Employees' ,'HR','hr_em_employees_analytics,Hr_CockPit','hr_cockpit_Employees' )

End

-- Dashboard

SET @EmployeesDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Employee' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@EmployeesDashboardID, @CompanyId, 'Employee',  'EmployeeDashboard','reports-icons leads-icon','/HR-PRD/EmployeeDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','hr_cockpit_Employees')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @AttendanceId, @EmployeesDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End



----------------------------- Attendance  ----------------------

SET @AttendanceId = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Attendance' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@AttendanceId, @CompanyId,'Attendance', 'Attendance', 4, 'System', GETUTCDATE(), '', '', 1,'Attendance' ,'HR','hr_attendance_analytics','')

End



-- 4.0 -- 

-- Dashboard

SET @AttendanceDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Attendance' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@AttendanceDashboardID, @CompanyId, 'Attendance',  'AttendancesDashboard','reports-icons leads-icon','/HR-PRD/AttendancesDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','hr_attendance_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @AttendanceId, @AttendanceDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End


--SET @AttendanceId = newid();
------ SET @CompanyId = 0;
--IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Attendance' and CompanyId=@CompanyId)-- Report Exists
--BEGIN

--INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
--VALUES (@AttendanceId, @CompanyId,'Attendance', 'Attendance', 3, 'System', GETUTCDATE(), '', '', 1,'Attendance' ,'HR','hr_attendance_analytics','' )

--End


---- 3.0 -- 

---- Dashboard

--SET @AttendanceDashboardID = newid();

--IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Attendance' and CompanyId=@CompanyId)--Report Exists
--BEGIN

--INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
--VALUES (@AttendanceDashboardID, @CompanyId, 'Attendance',  'AttendanceDashboard','reports-icons leads-icon','/HR-PRD/AttendanceDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','hr_attendance_analytics')

--INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
--VALUES (NEWID(), @AttendanceId, @AttendanceDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

--End


----------------------------- Leaves  ----------------------

SET @LeavesId = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Leaves' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@LeavesId, @CompanyId,'Leaves', 'Leaves', 4, 'System', GETUTCDATE(), '', '', 1,'Leaves' ,'HR','hr_leaveapplications_analytics,hr_leavebalances_analytics','')

End



-- 4.0 -- 

-- Dashboard

SET @LeavesDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Leaves' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@LeavesDashboardID, @CompanyId, 'Leaves',  'LeavesDashboard','reports-icons leads-icon','/HR-PRD/LeavesDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','hr_leaves_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @LeavesId, @LeavesDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End


----------------------------- Trainings  ----------------------

SET @TrainingsId = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Trainings' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@TrainingsId, @CompanyId,'Trainings', 'Trainings', 5, 'System', GETUTCDATE(), '', '', 1,'Trainings' ,'HR','hr_trainings_analytics','' )

End



-- 5.0 -- 

-- Dashboard

SET @TrainingDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Trainings' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@TrainingDashboardID, @CompanyId, 'Trainings',  'TrainingsDashboard','reports-icons leads-icon','/HR-PRD/TrainingsDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','hr_trainings_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @TrainingsId, @TrainingDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End


----------------------------- Claims  ----------------------

SET @ClaimsId = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Claims' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@ClaimsId, @CompanyId,'Claims', 'Claims', 6, 'System', GETUTCDATE(), '', '', 1,'Claims' ,'HR','hr_claims_analytics','')

End



-- 6.0 -- 

-- Dashboard

SET @ClaimsDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Claims' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@ClaimsDashboardID, @CompanyId, 'Claims',  'ClaimsDashboard','reports-icons leads-icon','/HR-PRD/ClaimsDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','hr_claims_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @ClaimsId, @ClaimsDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End


----------------------------- Payroll  ----------------------

SET @PayrollId = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Payroll' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@PayrollId, @CompanyId,'Payroll', 'Payroll', 7, 'System', GETUTCDATE(), '', '', 1,'Payroll' ,'HR','hr_runpayroll_analytics,Hr_CockPit','hr_cockpit_payroll')

End



-- 7.0 -- 


-- Report


SET @PayrollComponentReportId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Pay Component Report - Custom' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@PayrollComponentReportId, @CompanyId, 'Pay Component Report - Custom',  'Pay Component Report - Custom','reports-icons leads-icon','hr.empmanagement.payrollreportscatg',1, 'System',GETUTCDATE(), Null, Null, 1,'HTML',Null,'hr_cockpit_payroll')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @PayrollId, @PayrollComponentReportId , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- Report

SET @PayrollReportMonthlyReportId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Payroll Report - Monthly' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@PayrollReportMonthlyReportId, @CompanyId, 'Payroll Report - Monthly',  'Payroll Report - Monthly','reports-icons leads-icon','hr.empmanagement.payrollreports',1, 'System',GETUTCDATE(), Null, Null, 1,'HTML',Null,'hr_cockpit_payroll')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @PayrollId, @PayrollReportMonthlyReportId , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- Report

SET @YTDReporEmployeetId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'YTD Report - Employee' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@YTDReporEmployeetId, @CompanyId, 'YTD Report - Employee',  'YTD Report - Employee','reports-icons leads-icon','hr.empmanagement.ytdpayrollreports',2, 'System',GETUTCDATE(), Null, Null, 1,'HTML','NULL','hr_cockpit_payroll')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @PayrollId, @YTDReporEmployeetId , 2, 'System', GETUTCDATE(), NULL, NULL, 1)

End


-- Report


SET @CPFSummaryReportId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'CPF Summary Report' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@CPFSummaryReportId, @CompanyId, 'CPF Summary Report',  'CPFSummaryReport','reports-icons leads-icon','hr.empmanagement.payrollcpesummaryreports',3, 'System',GETUTCDATE(), Null, Null, 1,'HTML','NULL','hr_cockpit_payroll')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @PayrollId, @CPFSummaryReportId , 3, 'System', GETUTCDATE(), NULL, NULL, 1)

End




-- Dashboard

SET @PayrollDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Payroll' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@PayrollDashboardID, @CompanyId, 'Payroll',  'PayrollDashboard','reports-icons leads-icon','/HR-PRD/PayrollDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','hr_runpayroll_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @PayrollId, @PayrollDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End


End
GO
