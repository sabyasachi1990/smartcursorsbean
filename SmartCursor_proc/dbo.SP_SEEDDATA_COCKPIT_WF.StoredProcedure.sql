USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SEEDDATA_COCKPIT_WF]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[SP_SEEDDATA_COCKPIT_WF]

@CompanyId BigInt

As
Begin


-- Exec [dbo].[SP_SEEDDATA_COCKPIT_WF] 1716

---- [Report].[Report] -------- 


-- Clients --

Declare @ClientsCreatedDashboardID UNIQUEIDENTIFIER;
Declare @ClientsInactiveDashboardID UNIQUEIDENTIFIER;
Declare @ClientsNowDashboardID UNIQUEIDENTIFIER;
Declare @ClientsReactiveDashboardID UNIQUEIDENTIFIER;

Declare @ClientsContactReportId UNIQUEIDENTIFIER;

-- Cases --

Declare @CasesCreatedDashboardID UNIQUEIDENTIFIER;
Declare @CasesUnassignedDashboardID UNIQUEIDENTIFIER;
Declare @CasesOnHoldDashboardID UNIQUEIDENTIFIER;
Declare @CasesForApprovalDashboardID UNIQUEIDENTIFIER;
Declare @CasesApprovedDashboardID UNIQUEIDENTIFIER;
Declare @CasesCompletedDashboardID UNIQUEIDENTIFIER;
Declare @CasesCancelledDashboardID UNIQUEIDENTIFIER;

Declare @CaseMembersReportID UNIQUEIDENTIFIER;


-- Invoices --

Declare @UnpaidAmountDashboardID UNIQUEIDENTIFIER;
Declare @InvoicesNotGeneratedDashboardID UNIQUEIDENTIFIER;
Declare @InvoicesGeneratedDashboardID UNIQUEIDENTIFIER;
Declare @IncidentalTrackerDashboardID UNIQUEIDENTIFIER;
Declare @ClaimsTrackerDashboardID UNIQUEIDENTIFIER;


-- Scheduling --

Declare @ActualContributionDashboardID UNIQUEIDENTIFIER;
Declare @PlannedContributionDashboardID UNIQUEIDENTIFIER;
Declare @RecoveryDashboardID UNIQUEIDENTIFIER;
Declare @ActualChargeabilityDashboardID UNIQUEIDENTIFIER;
Declare @PlannedChargeabilityDashboardID UNIQUEIDENTIFIER;



----[Report].[ReportCategory]-------

Declare @ClientsID UNIQUEIDENTIFIER;
Declare @CasesID UNIQUEIDENTIFIER;
Declare @InvoicesID UNIQUEIDENTIFIER;
Declare @SchedulingID UNIQUEIDENTIFIER;
Declare @TimeReportsID UNIQUEIDENTIFIER;



----------------------------- Clients  ----------------------

SET @ClientsID = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Clients' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@ClientsID, @CompanyId,'Clients', 'Clients', 1, 'System', GETUTCDATE(), '', '', 1,'Clients' ,'WF','workflow_clients_analytics,workflow_cockpit','workflow_cockpit_clients' )

End

-- 1.0 -- 


SET @ClientsCreatedDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Clients Created' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@ClientsCreatedDashboardID, @CompanyId, 'Clients Created',  'ClientsCreatedDashboard','reportworkflow-icons case-icon','/WF-PRD/ClientsCreatedDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_clients_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @ClientsID, @ClientsCreatedDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 1.1 -- 


SET @ClientsNowDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Clients Now' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@ClientsNowDashboardID, @CompanyId, 'Clients Now',  'ClientsNowDashboard','reportworkflow-icons case-icon','/WF-PRD/ClientsNowDashboard',2, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_clients_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @ClientsID, @ClientsNowDashboardID , 2, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 1.2 -- 


SET @ClientsInactiveDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Clients Inactive' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@ClientsInactiveDashboardID, @CompanyId, 'Clients Inactive',  'ClientsInactiveDashboard','reportworkflow-icons case-icon','/WF-PRD/ClientsInactiveDashboard',3, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_clients_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @ClientsID, @ClientsInactiveDashboardID , 3, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 1.3 -- 


SET @ClientsReactiveDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Clients Reactive' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@ClientsReactiveDashboardID, @CompanyId, 'Clients Reactive',  'ClientsReactiveDashboard','reportworkflow-icons case-icon','/WF-PRD/ClientsReactiveDashboard',4, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_clients_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @ClientsID, @ClientsReactiveDashboardID , 4, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 1.4 -- 

-- Report

SET @ClientsContactReportId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Clients Contact Report' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@ClientsContactReportId, @CompanyId, 'Clients Contact Report',  'ClientsContactReport','reportworkflow-icons case-icon','/WF-PRD/ClientsContactReport',5, 'System',GETUTCDATE(), Null, Null, 1,'Report','PowerBI','workflow_clients_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @ClientsID, @ClientsContactReportId , 5, 'System', GETUTCDATE(), NULL, NULL, 1)

End


----------------------------- Cases  ----------------------

SET @CasesID = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Cases' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@CasesID, @CompanyId,'Cases', 'Cases', 2, 'System', GETUTCDATE(), '', '', 1,'Cases' ,'WF','workflow_cases_analytics,workflow_cockpit','workflow_cockpit_cases')

End

-- 2.0 -- 


SET @CasesCreatedDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Cases Created' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@CasesCreatedDashboardID, @CompanyId, 'Cases Created',  'CasesCreatedDashboard','reportworkflow-icons case-icon','/WF-PRD/CasesCreatedDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_cases_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @CasesID, @CasesCreatedDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 2.1 -- 


SET @CasesUnassignedDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Cases Unassigned' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@CasesUnassignedDashboardID, @CompanyId, 'Cases Unassigned',  'CasesUnassignedDashboard','reportworkflow-icons case-icon','/WF-PRD/CasesUnassignedDashboard',2, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_cases_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @CasesID, @CasesUnassignedDashboardID , 2, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 2.2 -- 


SET @CasesOnHoldDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Cases On Hold' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@CasesOnHoldDashboardID, @CompanyId, 'Cases On Hold',  'CasesOnHoldDashboard','reportworkflow-icons case-icon','/WF-PRD/CasesOnHoldDashboard',3, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_cases_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @CasesID, @CasesOnHoldDashboardID , 3, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 2.3 -- 


SET @CasesForApprovalDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Cases For Approval' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@CasesForApprovalDashboardID, @CompanyId, 'Cases For Approval',  'CasesForApprovalDashboard','reportworkflow-icons case-icon','/WF-PRD/CasesForApprovalDashboard',4, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_cases_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @CasesID, @CasesForApprovalDashboardID , 4, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 2.4 -- 


SET @CasesApprovedDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Cases Approved' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@CasesApprovedDashboardID, @CompanyId, 'Cases Approved',  'CasesApprovedDashboard','reportworkflow-icons case-icon','/WF-PRD/CasesApprovedDashboard',5, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_cases_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @CasesID, @CasesApprovedDashboardID , 5, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 2.5 -- 


SET @CasesCompletedDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Cases Completed' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@CasesCompletedDashboardID, @CompanyId, 'Cases Completed',  'CasesCompletedDashboard','reportworkflow-icons case-icon','/WF-PRD/CasesCompletedDashboard',6, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_cases_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @CasesID, @CasesCompletedDashboardID , 6, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 2.6 -- 


SET @CasesCancelledDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Cases Cancelled' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@CasesCancelledDashboardID, @CompanyId, 'Cases Cancelled',  'CasesCancelledDashboard','reportworkflow-icons case-icon','/WF-PRD/CasesCancelledDashboard',7, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_cases_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @CasesID, @CasesCancelledDashboardID , 7, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 2.7 -- 

-- Report

SET @CaseMembersReportID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Cases Members Report' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@CaseMembersReportID, @CompanyId, 'Cases Members Report',  'CasesMembersReport','reportworkflow-icons case-icon','/WF-PRD/CasesMembersReport',8, 'System',GETUTCDATE(), Null, Null, 1,'Report','PowerBI','workflow_cases_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @CasesID, @CaseMembersReportID , 8, 'System', GETUTCDATE(), NULL, NULL, 1)

End


----------------------------- Invoices  ----------------------

SET @InvoicesID = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Invoices' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@InvoicesID, @CompanyId,'Invoices', 'Invoices', 3, 'System', GETUTCDATE(), '', '', 1,'Invoices' ,'WF','workflow_invoices_analytics','' )

End

-- 3.0 -- 


SET @UnpaidAmountDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Unpaid Amount' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@UnpaidAmountDashboardID, @CompanyId, 'Unpaid Amount',  'UnpaidAmountDashboard','reportworkflow-icons case-icon','/WF-PRD/UnpaidAmountDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_invoices_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @InvoicesID, @UnpaidAmountDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 3.1 -- 


SET @InvoicesNotGeneratedDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Invoices Not Generated' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@InvoicesNotGeneratedDashboardID, @CompanyId, 'Invoices Not Generated',  'InvoicesNotGeneratedDashboard','reportworkflow-icons case-icon','/WF-PRD/InvoicesNotGeneratedDashboard',2, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_invoices_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @InvoicesID, @InvoicesNotGeneratedDashboardID , 2, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 3.2 -- 


SET @InvoicesGeneratedDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Invoices Generated' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@InvoicesGeneratedDashboardID, @CompanyId, 'Invoices Generated',  'InvoicesGeneratedDashboard','reportworkflow-icons case-icon','/WF-PRD/InvoicesGeneratedDashboard',3, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_invoices_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @InvoicesID, @InvoicesGeneratedDashboardID , 3, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 3.3 -- 


SET @IncidentalTrackerDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Incidental Tracker' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@IncidentalTrackerDashboardID, @CompanyId, 'Incidental Tracker',  'Incidental Tracker Dashboard','reportworkflow-icons case-icon','/WF-PRD/Incidental Tracker Dashboard',4, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_invoices_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @InvoicesID, @IncidentalTrackerDashboardID , 4, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 3.4 -- 


SET @ClaimsTrackerDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Claims Tracker' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@ClaimsTrackerDashboardID, @CompanyId, 'Claims Tracker',  'ClaimsTrackerDashboard','reportworkflow-icons case-icon','/WF-PRD/Claims Tracker Dashboard',5, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_invoices_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @InvoicesID, @ClaimsTrackerDashboardID , 5, 'System', GETUTCDATE(), NULL, NULL, 1)

End

----------------------------- Scheduling  ----------------------

SET @SchedulingID = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Scheduling' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@SchedulingID, @CompanyId,'Scheduling', 'Scheduling', 4, 'System', GETUTCDATE(), '', '', 1,'Scheduling' ,'WF','workflow_scheduler_analytics','' )

End

-- 4.0 -- 


SET @ActualContributionDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Actual Contribution' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@ActualContributionDashboardID, @CompanyId, 'Actual Contribution',  'Actual Contribution Dashboard','reportworkflow-icons case-icon','/WF-PRD/ActualContributionDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_scheduler_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @SchedulingID, @ActualContributionDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 4.1 -- 


SET @PlannedContributionDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Planned Contribution' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@PlannedContributionDashboardID, @CompanyId, 'Planned Contribution',  'Planned Contribution Dashboard','reportworkflow-icons case-icon','/WF-PRD/PlannedContributionDashboard',2, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_scheduler_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @SchedulingID, @PlannedContributionDashboardID , 2, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 4.2 -- 

SET @RecoveryDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Recovery' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@RecoveryDashboardID, @CompanyId, 'Recovery',  'Recovery Dashboard','reportworkflow-icons case-icon','/WF-PRD/RecoveryDashboard',3, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_scheduler_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @SchedulingID, @RecoveryDashboardID , 3, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 4.3 -- 

SET @ActualChargeabilityDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Actual Chargeability' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@ActualChargeabilityDashboardID, @CompanyId, 'Actual Chargeability Dashboard',  'ActualChargeability Dashboard','reportworkflow-icons case-icon','/WF-PRD/ChargeabilityDashboard',4, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_scheduler_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @SchedulingID, @ActualChargeabilityDashboardID , 4, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 4.4 --

SET @PlannedChargeabilityDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Planned Chargeability' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
VALUES (@PlannedChargeabilityDashboardID, @CompanyId, 'Planned Chargeability',  'Planned Chargeability Dashboard','reportworkflow-icons case-icon','/WF-PRD/ChargeabilityDashboard',4, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','workflow_scheduler_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @SchedulingID, @PlannedChargeabilityDashboardID , 4, 'System', GETUTCDATE(), NULL, NULL, 1)

End


--------------------------------- Time Reports  ----------------------

----SET @TimeReportsID = newid();
-------- SET @CompanyId = 0;
----IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Time Reports' and CompanyId=@CompanyId)-- Report Exists
----BEGIN

----INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
----VALUES (@TimeReportsID, @CompanyId,'Time Reports', 'Time Reports', 5, 'System', GETUTCDATE(), '', '', 1,'Time Reports' ,'WF','workflow_cockpit','workflow_cockpit_timelog')

----End


----SET @PlannedChargeabilityDashboardID = newid();

----IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Planned Chargeability' and CompanyId=@CompanyId)--Report Exists
----BEGIN

----INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],[PermissionKeys]) 
----VALUES (@PlannedChargeabilityDashboardID, @CompanyId, 'Planned Chargeability',  'Planned Chargeability Dashboard','reportworkflow-icons case-icon','/WF-PRD/ChargeabilityDashboard',4, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI')

----INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
----VALUES (NEWID(), @SchedulingID, @PlannedChargeabilityDashboardID , 4, 'System', GETUTCDATE(), NULL, NULL, 1)

----End

End
GO
