USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CompanyWise_HR_DataDeletion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[CompanyWise_HR_DataDeletion]
@CompanyId Int

AS
BEGIN

DECLARE @CompanyInfo TABLE (Id Int, RegistrationNo Nvarchar(150), Name Nvarchar(500))

INSERT INTO @CompanyInfo
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE Id = @CompanyId
UNION ALL
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE ParentId = @CompanyId

----------------------==================================================================================================================================================================================================
----------------------/////////////////////////////////////////////////////////////////////////////// HR \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-----------------------==================================================================================================================================================================================================

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.AdditionalFormMetadata_ToBeDeleted \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM HR.AdditionalFormMetadata_ToBeDeleted -----> No Data in Table

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.AgencyFund \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------------SELECT * FROM HR.AgencyFund WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) -----> Seed data only in table

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.Appendix8A \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.Appendix8A WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.Appraisal \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.AppraiseAppraisers WHERE AppraisalDetailId IN
(
SELECT Id FROM HR.AppraisalAppraiseeDetails WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraiserIncharge WHERE AppraisalDetailId IN
(
SELECT Id FROM HR.AppraisalAppraiseeDetails WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraisalAppraiseeDetails WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.AppraisalAppraiseeWeightage WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.AppraisalAppraiserDetails WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.AppraisalDetail WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.AppraisalDevelopmentPlan WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.AppraisalAppraiseeWeightage WHERE AppraisalMappingId IN
(
SELECT Id FROM HR.AppraisalMapping WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.AppraisalMapping WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.AppraisalResult WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.AppraisalSummary WHERE AppraisalId IN
(
SELECT Id FROM HR.Appraisal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Appraisal WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.BankFile \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.BankFileDetail WHERE BankFileId IN
(
SELECT Id FROM HR.BankFile WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.BankFile WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.ClaimItem \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.ClaimSetupDetail WHERE ClaimItemId IN
(
SELECT Id FROM HR.ClaimItem WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeeClaimDetail WHERE ClaimItemId IN
(
SELECT Id FROM HR.ClaimItem WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeeClaimsEntitlementDetail WHERE ClaimItemId IN
(
SELECT Id FROM HR.ClaimItem WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.ClaimItem WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.ClaimSetup \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.ClaimSetupDetail WHERE ClaimSetupId IN
(
SELECT Id FROM HR.ClaimSetup WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.ClaimSetup WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.CompanyPayrollSettings \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.CompanyPayrollSettingsDetail WHERE MasterId IN
(
SELECT Id FROM HR.CompanyPayrollSettings WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.CompanyPayrollSettings WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.Competence \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.CompetenceDetail WHERE MasterId IN
(
SELECT Id FROM HR.Competence WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.QuestionCompetence WHERE CompetenceId IN
(
SELECT Id FROM HR.Competence WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.QuestionnaireDetail WHERE CompetenceId IN
(
SELECT Id FROM HR.Competence WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Competence WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.CourseLibrary \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.TrainerCourse WHERE CourseLibraryId IN
(
SELECT Id FROM HR.CourseLibrary WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.TrainingAttendance WHERE TrainingId IN
(
SELECT Id FROM HR.Training WHERE CourseLibraryId  IN
(
SELECT Id FROM HR.CourseLibrary WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.TrainingAttendee WHERE TrainingId  IN
(
SELECT Id FROM HR.Training WHERE CourseLibraryId  IN
(
SELECT Id FROM HR.CourseLibrary WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.TrainingAttendance WHERE TrainingScheduleId IN
(
SELECT Id FROM HR.TrainingSchedule WHERE TrainingId IN
(
SELECT Id FROM HR.Training WHERE CourseLibraryId  IN
(
SELECT Id FROM HR.CourseLibrary WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.TrainingSchedule WHERE TrainingId IN
(
SELECT Id FROM HR.Training WHERE CourseLibraryId  IN
(
SELECT Id FROM HR.CourseLibrary WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.TrainingTrainers WHERE TrainingId IN
(
SELECT Id FROM HR.Training WHERE CourseLibraryId  IN
(
SELECT Id FROM HR.CourseLibrary WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.Training WHERE CourseLibraryId  IN
(
SELECT Id FROM HR.CourseLibrary WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.CourseLibrary WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.CPFSettings \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------SELECT * FROM HR.CPFSettings WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) -----> Only seed data in table
 
-----------------------/////////////////////////////////////////////////////////////////////////////// HR.DevelopmentPlan \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.DevelopmentPlan WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.EmployeeBankDetails \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.EmployeeBankDetails WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.EmployeeClaim1 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeeClaim1 WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.EmployeeClaimsEntitlement \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.BankFileDetail WHERE TypeId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE ClaimEntitlementId IN
(
SELECT Id FROM HR.EmployeeClaimsEntitlement WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.EmployeeClaimDetail WHERE EmployeeClaimId IN
(
SELECT Id FROM HR.EmployeeClaim1 WHERE ClaimEntitlementId IN
(
SELECT Id FROM HR.EmployeeClaimsEntitlement WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.EmployeeClaim1 WHERE ClaimEntitlementId IN
(
SELECT Id FROM HR.EmployeeClaimsEntitlement WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeeClaimsEntitlementDetail WHERE EmployeeClaimsEntitlementId IN
(
SELECT Id FROM HR.EmployeeClaimsEntitlement WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeeClaimsEntitlement WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.EmployeeDepartment \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.EmployeeDepartmentHistory WHERE EmployeeDepartmentId IN
(
SELECT Id FROM HR.EmployeeDepartment WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmployeeDepartment WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.EmployeePayrollSetting \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.EmployeePayrollSetting WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.EmployeeProjects \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM HR.EmployeeProjects WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) -----> No Data in Table

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.Employment \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.Employment WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.EvaluationDetails \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.Evaluation WHERE EvalutionId IN
(
SELECT Id FROM HR.EvaluationDetails WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EvaluationDetails WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.FileHistory \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM HR.FileHistory WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) -----> No Data in Table

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.IR8ACompanySetUp \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.Appendix8A WHERE IR8AHRSetUpId IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE IR8ACompanySetUpId IN
(
SELECT Id FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.Appendix8BSectionA WHERE Appendix8BId IN
(
SELECT Id FROM HR.Appendix8B WHERE IR8AHRSetUpId  IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE IR8ACompanySetUpId IN
(
SELECT Id FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.Appendix8BSectionB WHERE Appendix8BId IN
(
SELECT Id FROM HR.Appendix8B WHERE IR8AHRSetUpId  IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE IR8ACompanySetUpId IN
(
SELECT Id FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.Appendix8BSectionC WHERE Appendix8BId IN
(
SELECT Id FROM HR.Appendix8B WHERE IR8AHRSetUpId  IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE IR8ACompanySetUpId IN
(
SELECT Id FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.Appendix8BSectionD WHERE Appendix8BId IN
(
SELECT Id FROM HR.Appendix8B WHERE IR8AHRSetUpId  IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE IR8ACompanySetUpId IN
(
SELECT Id FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.Appendix8B WHERE IR8AHRSetUpId  IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE IR8ACompanySetUpId IN
(
SELECT Id FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.FileHistory WHERE IR8AHRSetupId IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE IR8ACompanySetUpId IN
(
SELECT Id FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.IR21ChildSetUp WHERE Ir8aHrSetUpId IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE IR8ACompanySetUpId IN
(
SELECT Id FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.IR8SSectionA WHERE IR8SId IN
(
SELECT Id FROM HR.IR8S WHERE IR8AHRSetUpId IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE IR8ACompanySetUpId IN
(
SELECT Id FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.IR8SSectionC WHERE IR8SId IN
(
SELECT Id FROM HR.IR8S WHERE IR8AHRSetUpId IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE IR8ACompanySetUpId IN
(
SELECT Id FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM HR.IR8S WHERE IR8AHRSetUpId IN
(
SELECT Id FROM HR.IR8AHRSetUp WHERE IR8ACompanySetUpId IN
(
SELECT Id FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.IR8AHRSetUp WHERE IR8ACompanySetUpId IN
(
SELECT Id FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.IR8ACompanySetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.IR8ACompanySetUp \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.IR8AHRSetUp WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.JobApplication \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.ApplicantHistory WHERE JobApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.CompanyReferals WHERE JobApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Education WHERE ApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.EmploymentHistory WHERE ApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Evaluation WHERE ApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.FamilyPerticulars WHERE ApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Hobbies WHERE JobApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Evaluation WHERE InterviewId IN
(
SELECT Id FROM HR.Interview WHERE ApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.Interview WHERE ApplicationId IN
(
SELECT Id FROM HR.JobApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.JobApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.JobPosting \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.JobPosting WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.LeaveApplication \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.LeaveApplicationHistory WHERE LeaveApplicationId IN
(
SELECT Id FROM HR.LeaveApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.LeaveApplication WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.LeaveRequest \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM HR.LeaveRequest WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.LeaveSetup \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM HR.LeaveSetup WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.LeavesReport \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM HR.LeavesReport WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.LeaveType \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.LeaveTypeDetails WHERE LeaveTypeId IN
(
SELECT Id FROM HR.LeaveType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.LeaveRuleEngineEmployee WHERE LeaveRuleEngineId IN
(
SELECT Id FROM HR.LeaveRuleEngine WHERE LeaveTypeId IN
(
SELECT Id FROM HR.LeaveType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.LeaveRuleEngine WHERE LeaveTypeId IN
(
SELECT Id FROM HR.LeaveType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.LeaveType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.Objective \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.QuestionnaireObjective WHERE ObjectiveId IN
(
SELECT Id FROM HR.Objective WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Objective WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.PayComponent \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.PayComponentDetail WHERE MasterId IN
(
SELECT Id FROM HR.PayComponent WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.PayrollSplit WHERE PayComponentId IN
(
SELECT Id FROM HR.PayComponent WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
) 

DELETE FROM HR.PayComponent WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.Payroll \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.PayrollSplit WHERE PayrollDetailId IN
(
SELECT Id FROM HR.PayrollDetails WHERE MasterId IN
(
SELECT Id FROM HR.Payroll WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM HR.PayrollDetails WHERE MasterId IN
(
SELECT Id FROM HR.Payroll WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Payroll WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.Project \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

------------------------SELECT * FROM HR.Project WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) -----> No Data in Table

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.Question \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.QuestionCompetence WHERE QuestionId IN
(
SELECT Id FROM HR.Question WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.QuestionnaireDetail WHERE QuestionId IN
(
SELECT Id FROM HR.Question WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Question WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.Questionnaire \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.QuestionnaireDetail WHERE QuestionnaireId IN
(
SELECT Id FROM HR.Questionnaire WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.QuestionnaireObjective WHERE QuestionnaireId IN
(
SELECT Id FROM HR.Questionnaire WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Questionnaire WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.Requisition \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--------------------SELECT * FROM HR.Requisition WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) ------> No data in Table

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.SDL \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM HR.SDL WHERE CompanyId IN (SELECT Id FROM @CompanyInfo) -----> Only 1 record for 0 Company

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.TeamCalendar \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.TeamCalendarDetail WHERE MasterId IN
(
SELECT Id FROM HR.TeamCalendar WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.TeamCalendar WHERE CompanyId IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.Trainer \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.TrainerCourse WHERE TrainerId IN
(
SELECT Id FROM HR.Trainer WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.Trainer WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.Training \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.Training WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// HR.WorkProfile \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM HR.EmployeePayrollSetting WHERE WorkProfileId IN
(
SELECT Id FROM HR.WorkProfile WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.WorkProfileDetails WHERE MasterId IN 
(
SELECT Id FROM HR.WorkProfile WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM HR.WorkProfile WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// License.CompanyPackageModule \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM License.CompanyPackageModule WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// Master.VendorType \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------------SELECT * FROM Master.VendorType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

-----------------------/////////////////////////////////////////////////////////////////////////////// Report.Report \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Report.ReportCategoryReport WHERE ReportId IN
(
SELECT Id FROM Report.Report WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) 
)

DELETE FROM Report.Report WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) 

-----------------------/////////////////////////////////////////////////////////////////////////////// Report.ReportCategory \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Report.ReportCategoryReport WHERE ReportId IN
(
SELECT Id FROM Report.ReportCategory WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Report.ReportCategory WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// Support.Ticket \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Support.TicketHistory WHERE TicketId IN
(
SELECT Id FROM Support.Ticket WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Support.TicketReply WHERE TicketId  IN
(
SELECT Id FROM Support.Ticket WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Support.Ticket WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------------/////////////////////////////////////////////////////////////////////////////// Support.TicketReply \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Support.TicketReply WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)


END
GO
