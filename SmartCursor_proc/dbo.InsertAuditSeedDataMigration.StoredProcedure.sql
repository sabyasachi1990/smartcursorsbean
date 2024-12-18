USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[InsertAuditSeedDataMigration]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[InsertAuditSeedDataMigration] (@companyId bigint,@engagementId uniqueidentifier)
As begin
exec [dbo].[Sp_Audit_EngagementSeedDataWorkProgram]  @companyId,@engagementId
print 'EngagementSeedDataWorkProgram'
exec [dbo].[Sp_Audit_ReportingSetUp] @companyId,@engagementId
print 'Reporting Set Up'
exec [dbo].[Sp_Audit_Disclosure] @CompanyId,@engagementId
print 'Disclosure'
exec [dbo].[Sp_Audit_EngagementSeedData] @CompanyId,@engagementId
print 'Engagement Seed data Sp'
exec IncomeStatementSubTotals @engagementId,@CompanyId
print 'Incomestatement Sp'
exec [Proc_AuditBalanceSheetSubTotal] @engagementId
print 'BalanceSheet Sp'
print @engagementId
End
 


 
 
GO
