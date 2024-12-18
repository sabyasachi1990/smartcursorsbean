USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CompanyWise_Workflow_DataDeletion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[CompanyWise_Workflow_DataDeletion]
@CompanyId Int

AS
BEGIN

DECLARE @CompanyInfo TABLE (Id Int, RegistrationNo Nvarchar(150), Name Nvarchar(500))

INSERT INTO @CompanyInfo
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE Id = @CompanyId
UNION ALL
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE ParentId = @CompanyId

--------------------==================================================================================================================================================================================================
--------------------/////////////////////////////////////////////////////////////////////////////// WORKFLOW \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
---------------------==================================================================================================================================================================================================

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.CaseDoc \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM WorkFlow.CaseDoc WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) -----> No Data in table

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.CaseGroup \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM WorkFlow.CaseGroup WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.CaseStatusChange \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM WorkFlow.CaseStatusChange WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.Claim \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM WorkFlow.Claim WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.Client \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Common.TimeLogDetailSplit WHERE TimelogDetailId IN
(
SELECT Id FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM Common.TimeLogDetail WHERE TimeLogScheduleId IN
(
SELECT Id FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Common.TimeLogSchedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE CaseGroupId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseAmendDateOfCompletion WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

-------SELECT * FROM WorkFlow.CaseDoc ----> No Data in Table

DELETE FROM Common.TimeLogDetailSplit WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE CaseFeatureId IN
(
SELECT Id FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.CaseFeature WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseIncharge WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.CaseMileStone WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

----------SELECT * FROM WorkFlow.CasesAssigned ----> No Data in Table

DELETE FROM WorkFlow.CaseStatusChange WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.Claim WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.Incidental WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE InvoiceId IN
(
SELECT Id FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

-------SELECT * FROM WorkFlow.InvoiceState ----> No Data in Table

DELETE FROM WorkFlow.Invoice WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.InvoiceDesignation WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)
)

DELETE FROM WorkFlow.ScheduleTask WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetail WHERE MasterId IN
(
SELECT Id FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.Schedule WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE ScheduleDetailId IN
(
SELECT Id FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)
)

DELETE FROM WorkFlow.ScheduleDetailNew WHERE MasterId IN
(
SELECT Id FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM WorkFlow.ScheduleNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ScheduleTaskDetail WHERE ScheduleTaskId IN
(
SELECT Id FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)


DELETE FROM WorkFlow.ScheduleTask WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM WorkFlow.ScheduleTaskNew WHERE CaseId IN
(
SELECT Id FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)


DELETE FROM WorkFlow.CaseGroup WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM WorkFlow.ClientContact WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM WorkFlow.ClientStatusChange WHERE ClientId IN
(
SELECT Id FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM WorkFlow.Client WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.ClientStatusChange \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM WorkFlow.ClientStatusChange WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.Contact \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM WorkFlow.Contact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.IncidentalClaimItem \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM WorkFlow.IncidentalClaimItem WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.Invoice \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM WorkFlow.Invoice WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.Schedule \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM WorkFlow.Schedule WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.ScheduleNew \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM WorkFlow.ScheduleNew WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.ScheduleTask \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM WorkFlow.ScheduleTask WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

---------------------/////////////////////////////////////////////////////////////////////////////// WorkFlow.ScheduleTaskNew \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM WorkFlow.ScheduleTaskNew WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

END
GO
