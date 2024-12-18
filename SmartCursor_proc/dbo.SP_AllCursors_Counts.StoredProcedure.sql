USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_AllCursors_Counts]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Exec SP_AllCursors_Counts
CREATE Procedure [dbo].[SP_AllCursors_Counts]
As
Begin

--Leads Generated count
--Total opportunities count
--Cases in all states count
--Invoices all state count
--Total payroll counts
--Leaves applications count
--Journal table where all transactions count
--All entities count
--Doc Repository documents count 


SELECT COUNT(*) AS Leads FROM ClientCursor.Account (NOLOCK)
--Where IsAccount=0

SELECT COUNT(Id) AS Opportunities FROM ClientCursor.Opportunity (NOLOCK)

SELECT COUNT(Id) AS Cases FROM WorkFlow.CaseGroup (NOLOCK)

SELECT COUNT(Id) AS Invoices FROM WorkFlow.Invoice (NOLOCK)

--Select sum(Payrolls) Payrolls from
--(
--SELECT COUNT(Id) AS Payrolls FROM HR.Payroll (NOLOCK)
--Union all
SELECT COUNT(Id) AS Payslips FROM HR.PayrollDetails (NOLOCK)
--) A

SELECT COUNT(Id) AS LeaveApplications FROM HR.LeaveApplication (NOLOCK)

Select COUNT(Id) AS Transactions FROM Bean.Journal (NOLOCK)

Select COUNT(Id) AS Entities FROM Common.Company (NOLOCK)

Select COUNT(Id) AS Documents FROM Common.DocRepository (NOLOCK)
Where FilePath is not null

END




GO
