USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SEEDDATA_COCKPIT_BC]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  Procedure [dbo].[SP_SEEDDATA_COCKPIT_BC]

@CompanyId BigInt

As
Begin

-- Report Names

Declare @ReceivablesAgingReportID UNIQUEIDENTIFIER;
Declare @PayablesAgingReportID UNIQUEIDENTIFIER;
Declare @GeneralLedgerReportID UNIQUEIDENTIFIER;
Declare @JournalListingReportID UNIQUEIDENTIFIER;
Declare @IncomeStatementReportID UNIQUEIDENTIFIER;
Declare @BalanceSheetReportID UNIQUEIDENTIFIER;
Declare @TrialBalanceReportID UNIQUEIDENTIFIER;
Declare @GSTAnalysisReportID UNIQUEIDENTIFIER;


--DashBoard Names
Declare @CustomerDashBoardID  UNIQUEIDENTIFIER;
Declare @VendorDashBoardID   UNIQUEIDENTIFIER;
Declare @BankDashBoardID  UNIQUEIDENTIFIER;
Declare @FinancialDashBoardID  UNIQUEIDENTIFIER;
Declare @BillDashBoardID UNIQUEIDENTIFIER;

-- Tab Names
Declare @CustomersID UNIQUEIDENTIFIER;
Declare @VendorsID UNIQUEIDENTIFIER;
Declare @GeneralLedgerID UNIQUEIDENTIFIER;
Declare @FinancialsID UNIQUEIDENTIFIER;
 

----------------------------- Customers  ----------------------

SET @CustomersID = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Customers' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName]) 
VALUES (@CustomersID, @CompanyId,'Customers', 'Customers', 1, 'System', GETUTCDATE(), '', '', 1,'Customers' ,'BC' )

End

--Select * from [Report].[ReportCategory] Where ModuleName='cc' and CompanyId=19

-- 1.0 -- 

-- HTML Report

SET @ReceivablesAgingReportID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Receivables Aging' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@ReceivablesAgingReportID, @CompanyId, 'Receivables Aging',  'ReceivablesAging','reports1-icons journal-report-icon','bean.customer.aging',1, 'System',GETUTCDATE(), Null, Null, 1,'HTML','NULL')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @CustomersID, @ReceivablesAgingReportID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End
----------------------customer Dashboard---------------------------------------------------
SET @CustomerDashBoardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Customer' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@CustomerDashBoardID, @CompanyId, 'Customer','Customer','reports1-icons journal-report-icon','bean.customer.aging',1, 'System',GETUTCDATE(), Null, Null, 1,'DASHBOARD','POWERBI')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @CustomersID,@CustomerDashBoardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End


----------------------------- Vendors  ----------------------

SET @VendorsID = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Vendors' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName]) 
VALUES (@VendorsID, @CompanyId,'Vendors', 'Vendors', 1, 'System', GETUTCDATE(), '', '', 1,'Vendors' ,'BC' )

End

--Select * from [Report].[ReportCategory] Where ModuleName='cc' and CompanyId=19

-- 1.0 -- 

-- HTML Report

SET @PayablesAgingReportID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Payables Aging' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@PayablesAgingReportID, @CompanyId, 'Payables Aging','PayablesAging','reports1-icons journal-report-icon','bean.vendor.aging',1, 'System',GETUTCDATE(), Null, Null, 1,'HTML','NULL')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @VendorsID, @PayablesAgingReportID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End
----------------------- Vendor Dashboard----------------------------------------------------------------------
SET @VendorDashBoardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Vendor' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@VendorDashBoardID, @CompanyId, 'Vendor','Vendor','reports1-icons journal-report-icon','bean.vendor.aging',1, 'System',GETUTCDATE(), Null, Null, 1,'DASHBOARD','POWERBI')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @VendorsID,@VendorDashBoardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End

----------------------- Bill Dashboard----------------------------------------------------------------------
SET @BillDashBoardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Bill' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@BillDashBoardID, @CompanyId, 'Bill','Bill','reports1-icons journal-report-icon','bean.vendor.aging',1, 'System',GETUTCDATE(), Null, Null, 1,'DASHBOARD','POWERBI')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @VendorsID,@BillDashBoardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End

----------------------------- General Ledger  ----------------------

SET @GeneralLedgerID = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'General Ledger' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName]) 
VALUES (@GeneralLedgerID, @CompanyId,'General Ledger', 'General Ledger', 1, 'System', GETUTCDATE(), '', '', 1,'General Ledger' ,'BC' )

End

--Select * from [Report].[ReportCategory] Where ModuleName='cc' and CompanyId=19

-- 1.0 -- 

-- HTML Report

SET @GeneralLedgerReportID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'General Ledger' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@GeneralLedgerReportID, @CompanyId, 'General Ledger',  'General Ledger','reports1-icons GenaralLedger-report-icon','bean.gl.generalledger',1, 'System',GETUTCDATE(), Null, Null, 1,'HTML','NULL')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @GeneralLedgerID, @GeneralLedgerReportID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End


SET @JournalListingReportID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Journal Listing' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@JournalListingReportID , @CompanyId, 'Journal Listing','Journal Listing','reports1-icons GenaralLedger-report-icon','bean.gl.journallisting',1, 'System',GETUTCDATE(), Null, Null, 1,'HTML','NULL')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @GeneralLedgerID, @JournalListingReportID, 1, 'System', GETUTCDATE(), NULL, NULL, 1)
End 



-------------------------------------Financials--------------------------------------------------------------------

SET @FinancialsID = newid();
---- SET @CompanyId = 0;
IF Not EXISTS ( SELECT * FROM [Report].[ReportCategory] WHERE  [Name] = 'Financials' and CompanyId=@CompanyId)-- Report Exists
BEGIN

INSERT [Report].[ReportCategory] ([Id], [CompanyId], [Name], [SpriteName], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status], [TabNames], [ModuleName]) 
VALUES (@FinancialsID, @CompanyId,'Financials', 'Financials', 1, 'System', GETUTCDATE(), '', '', 1,'Financials' ,'BC' )

End

--Select * from [Report].[ReportCategory] Where ModuleName='cc' and CompanyId=19

-- 1.0 -- 

-- HTML Repor

SET @IncomeStatementReportID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Income Statement' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@IncomeStatementReportID, @CompanyId, 'Income Statement',  'Income Statement','reports1-icons GenaralLedger-report-icon','bean.financials.incomestatement',1, 'System',GETUTCDATE(), Null, Null, 1,'HTML','NULL')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @FinancialsID, @IncomeStatementReportID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End


SET @BalanceSheetReportID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Balance Sheet' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@BalanceSheetReportID, @CompanyId, 'Balance Sheet',  'Balance Sheet','reports1-icons GenaralLedger-report-icon','bean.financials.balancesheet',1, 'System',GETUTCDATE(), Null, Null, 1,'HTML','NULL')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @FinancialsID, @BalanceSheetReportID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End


SET @TrialBalanceReportID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Trial Balance' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@TrialBalanceReportID, @CompanyId, 'Trial Balance',  'Trial Balance','reports1-icons GenaralLedger-report-icon','bean.financials.trialbalance',1, 'System',GETUTCDATE(), Null, Null, 1,'HTML','NULL')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @FinancialsID, @TrialBalanceReportID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End

SET @GSTAnalysisReportID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'GST Analysis' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@GSTAnalysisReportID, @CompanyId, 'GST Analysis',  'GST Analysis','reports1-icons GenaralLedger-report-icon','bean.customer.gstreport',1, 'System',GETUTCDATE(), Null, Null, 1,'HTML','NULL')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @FinancialsID, @GSTAnalysisReportID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End
--------------------------------------------------------Financial Dashboard--------------------------------------------------------------------------------------
SET @FinancialDashBoardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Financials' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@FinancialDashBoardID, @CompanyId, 'Financials','Financials','reports1-icons GenaralLedger-report-icon','bean.customer.gstreport',1, 'System',GETUTCDATE(), Null, Null, 1,'DASHBOARD','POWERBI')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @FinancialsID, @FinancialDashBoardID , 1, 'System', GETUTCDATE(), NULL, NULL, 1)

End
---------------Bank DashBoard-------------------------------------------------------------------------------
SET @BankDashBoardID = newid();

IF Not EXISTS ( SELECT * FROM [Report].[Report] WHERE  [Name] = 'Cash and Bank Balances' and CompanyId=@CompanyId)--Report Exists
BEGIN

INSERT [Report].[Report] ([Id], [CompanyId], [Name], [Description], [ThumbNail], [ReportPath], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status],[Type],[PathType]) 
VALUES (@BankDashBoardID, @CompanyId, 'Cash and Bank Balances','Cash and Bank Balances','reports1-icons GenaralLedger-report-icon','bean.gl.journallisting',1, 'System',GETUTCDATE(), Null, Null, 1,'DASHBOARD','POWERBI')

INSERT [Report].[ReportCategoryReport] ([Id], [ReportCategoryId], [ReportId], [RecOrder], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Status]) 
VALUES (NEWID(), @GeneralLedgerID, @BankDashBoardID,1, 'System', GETUTCDATE(), NULL, NULL, 1)
End 

End
GO
