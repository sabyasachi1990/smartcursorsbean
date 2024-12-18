USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SEEDDATA_COCKPIT_CC]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SP_SEEDDATA_COCKPIT_CC]

@CompanyId BigInt

-- Exec [dbo].[SP_SEEDDATA_COCKPIT_CC] 1716

As
Begin

---- [Report].[Report] -------- 

-- Leads --

Declare @LeadsCreationDashboardID UNIQUEIDENTIFIER;
Declare @LeadsNowDashboardId UNIQUEIDENTIFIER;
Declare @LeadsWonDashboardId UNIQUEIDENTIFIER;
Declare @LeadsRenewDashboardId UNIQUEIDENTIFIER;
Declare @LeadsLostDashboardId UNIQUEIDENTIFIER;

-- Accounts --

Declare @AccountsNowDashboardID UNIQUEIDENTIFIER;
Declare @AccountsWonDashboardId UNIQUEIDENTIFIER;
Declare @AccountsInactiveDashboardId UNIQUEIDENTIFIER;
Declare @AccountsLostDashboardId UNIQUEIDENTIFIER;
Declare @AccountsReactiveDashboardId UNIQUEIDENTIFIER;

-- Opportunities --

Declare @OpportunitiesNowDashboardId UNIQUEIDENTIFIER;
Declare @OpportunityCreatedDashBoardID UNIQUEIDENTIFIER;
Declare @OpportunitiesWonDashboardId UNIQUEIDENTIFIER;
Declare @OpportunitiesCancelledDashboardId UNIQUEIDENTIFIER;
Declare @OpportunitiesCompleteDashboardId UNIQUEIDENTIFIER;
Declare @OpportunitiesLostDashboardId UNIQUEIDENTIFIER;
Declare @OpportunitiesPendingDashboardId UNIQUEIDENTIFIER;
Declare @OpportunitiesRecurringDashboardId UNIQUEIDENTIFIER;

-- Vendors -- 

Declare @VendorDashboardId UNIQUEIDENTIFIER;



----[Report].[ReportCategory]-------

Declare @LeadsID UNIQUEIDENTIFIER;
Declare @AccountsID UNIQUEIDENTIFIER;
Declare @OpportunitiesID UNIQUEIDENTIFIER;
Declare @VendorsID UNIQUEIDENTIFIER;


----------------------------- Leads  ----------------------

SET @LeadsID = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Leads' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@LeadsID, @CompanyId,'Leads', 'Leads', 1, 'System', GETUTCDATE(), '', '', 1,'Leads' ,'CC','client_leads_analytics','' )

End

--Select * from [Report].[ReportCategory] Where ModuleName='cc' and CompanyId=19

-- 1.0 -- 


SET @LeadsCreationDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Leads Created' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@LeadsCreationDashboardID, @CompanyId, 'Leads Created',  'LeadsCreationDashboard','reports-icons leads-icon','/CC-PRD/LeadsCreationDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_leads_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @LeadsID, @LeadsCreationDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End
-- 1.1 -- 


SET @LeadsNowDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Leads Now' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@LeadsNowDashboardId, @CompanyId, 'Leads Now',  'LeadsNowDashboard','reports-icons leads-icon','/CC-PRD/LeadsNowDashboard',2, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_leads_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @LeadsID, @LeadsNowDashboardId , 2, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 1.2 -- 


SET @LeadsWonDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Leads Won' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@LeadsWonDashboardId, @CompanyId, 'Leads Won',  'LeadsWonDashboard','reports-icons leads-icon','/CC-PRD/LeadsWonDashboard',3, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_leads_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @LeadsID, @LeadsWonDashboardId , 3, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 1.3 -- 


SET @LeadsRenewDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Leads Re-new' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@LeadsRenewDashboardId, @CompanyId, 'Leads Re-new',  'LeadsRe-newDashboard','reports-icons leads-icon','/CC-PRD/LeadsRe-newDashboard',4, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_leads_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @LeadsID, @LeadsRenewDashboardId , 4, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 1.4 -- 

SET @LeadsLostDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Leads Lost' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@LeadsLostDashboardId, @CompanyId, 'Leads Lost',  'LeadsLostDashboard','reports-icons leads-icon','/CC-PRD/LeadsLostDashboard',5, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_leads_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @LeadsID, @LeadsLostDashboardId , 5, 'System', GETUTCDATE(), NULL, NULL, 1)

End

----------------------------- Accounts  ----------------------

SET @AccountsID = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Accounts' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@AccountsID, @CompanyId,'Accounts', 'Accounts', 2, 'System', GETUTCDATE(), '', '', 1,'Accounts' ,'CC','client_accounts_analytics','' )

End
 
-- 2.0 -- 

SET @AccountsNowDashboardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Accounts Now' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@AccountsNowDashboardID, @CompanyId, 'Accounts Now',  'AccountsNowDashboard','reports-icons leads-icon','/CC-PRD/AccountsNowDashboard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_accounts_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @AccountsID, @AccountsNowDashboardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 2.1 -- 


SET @AccountsWonDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Accounts Won' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@AccountsWonDashboardId, @CompanyId, 'Accounts Won',  'AccountsWonDashboard','reports-icons leads-icon','/CC-PRD/AccountsWonDashboard',2, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_accounts_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @AccountsID, @AccountsWonDashboardId , 2, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 2.2 -- 


SET @AccountsInactiveDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Accounts Inactive' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@AccountsInactiveDashboardId, @CompanyId, 'Accounts Inactive',  'AccountsInactiveDashboard','reports-icons leads-icon','/CC-PRD/AccountsInactiveDashboard',3, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_accounts_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @AccountsID, @AccountsInactiveDashboardId , 3, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 2.3 -- 


SET @AccountsLostDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Accounts Lost' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@AccountsLostDashboardId, @CompanyId, 'Accounts Lost',  'AccountsLostDashboard','reports-icons leads-icon','/CC-PRD/AccountsLostDashboard',4, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_accounts_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @AccountsID, @AccountsLostDashboardId , 4, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 2.4 -- 

SET @AccountsReactiveDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Accounts Reactive' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@AccountsReactiveDashboardId, @CompanyId, 'Accounts Reactive',  'AccountsReactiveDashboard','reports-icons leads-icon','/CC-PRD/AccountsReactiveDashboard',5, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_accounts_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @AccountsID, @AccountsReactiveDashboardId , 5, 'System', GETUTCDATE(), NULL, NULL, 1)

End

----------------------------- Opportunities  ----------------------

SET @OpportunitiesID = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Opportunities' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@OpportunitiesID, @CompanyId,'Opportunities', 'Opportunities', 3, 'System', GETUTCDATE(), '', '', 1,'Opportunities' ,'CC','client_Opportunities_analytics','' )

End
 
-- 3.0 -- 


SET @OpportunitiesNowDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Opportunities Now' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@OpportunitiesNowDashboardId, @CompanyId, 'Opportunities Now',  'OpportunitiesNowDashBoard','reports-icons opportunities-icon','/CC-PRD/OpportunityNowDashBoard',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_Opportunities_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @OpportunitiesID, @OpportunitiesNowDashboardId , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 3.1 -- 


SET @OpportunityCreatedDashBoardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Opportunities Created' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@OpportunityCreatedDashBoardID, @CompanyId, 'Opportunities Created',  'OpportunitiesCreatedDashBoard','reports-icons opportunities-icon','/CC-PRD/OpportunityCreatedDashBoard',2, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_Opportunities_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @OpportunitiesID, @OpportunityCreatedDashBoardID , 2, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 3.2 -- 


SET @OpportunitiesWonDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Opportunities Won' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@OpportunitiesWonDashboardId, @CompanyId, 'Opportunities Won',  'OpportunitiesWonDashBoard','reports-icons opportunities-icon','/CC-PRD/OpportunityWonDashBoard',3, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_Opportunities_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @OpportunitiesID, @OpportunitiesWonDashboardId , 3, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 3.3 -- 

SET @OpportunitiesCancelledDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Opportunities Cancelled' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@OpportunitiesCancelledDashboardId, @CompanyId, 'Opportunities Cancelled',  'OpportunitiesCancelledDashBoard','reports-icons opportunities-icon','/CC-PRD/OpportunityCancelledDashBoard',4, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_Opportunities_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @OpportunitiesID, @OpportunitiesCancelledDashboardId , 4, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 3.4 -- 

SET @OpportunitiesCompleteDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Opportunities Complete' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@OpportunitiesCompleteDashboardId, @CompanyId, 'Opportunities Complete',  'OpportunitiesCompleteDashBoard','reports-icons opportunities-icon','/CC-PRD/OpportunityCompleteDashBoard',5, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_Opportunities_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @OpportunitiesID, @OpportunitiesCompleteDashboardId , 5, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 3.5 -- 

SET @OpportunitiesLostDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Opportunities Lost' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@OpportunitiesLostDashboardId, @CompanyId, 'Opportunities Lost',  'OpportunitiesLostDashBoard','reports-icons opportunities-icon','/CC-PRD/OpportunityLostDashBoard',6, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_Opportunities_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @OpportunitiesID, @OpportunitiesLostDashboardId , 6, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 3.6 -- 


SET @OpportunitiesPendingDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Opportunities Pending' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@OpportunitiesPendingDashboardId, @CompanyId, 'Opportunities Pending',  'OpportunitiesPendingDashBoard','reports-icons opportunities-icon','/CC-PRD/OpportunityPendingDashBoard',7, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_Opportunities_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @OpportunitiesID, @OpportunitiesPendingDashboardId , 7, 'System', GETUTCDATE(), NULL, NULL, 1)

End

-- 3.7 -- 

SET @OpportunitiesRecurringDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Opportunities Recurring' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@OpportunitiesRecurringDashboardId, @CompanyId, 'Opportunities Recurring',  'OpportunitiesRecurringDashBoard','reports-icons opportunities-icon','/CC-PRD/OpportunityRecurringDashBoard',8, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_Opportunities_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @OpportunitiesID, @OpportunitiesRecurringDashboardId , 8, 'System', GETUTCDATE(), NULL, NULL, 1)

End

 
 ----------------------------- Vendors  ----------------------

SET @VendorsID = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Vendors' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName],[PermissionKeys],[CockpitPermissionKeys]) 
VALUES (@VendorsID, @CompanyId,'Vendors', 'Vendors', 4, 'System', GETUTCDATE(), '', '', 1,'Vendors' ,'CC','client_vendors_analytics','' )

End
 
-- 3.0 -- 


SET @VendorDashboardId = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Vendors' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType],PermissionKeys) 
VALUES (@VendorDashboardId, @CompanyId, 'Vendors',  'VendorsDashBoard','reports-icons opportunities-icon','/CC-PRD/Vendors',1, 'System',GETUTCDATE(), Null, Null, 1,'Dashboard','PowerBI','client_vendors_analytics')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @VendorsID, @VendorDashboardId , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End


End
GO
