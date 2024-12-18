USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_select_Staments]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[HR_select_Staments]
AS
BEGIN

-- Exec HR_select_Staments

select count(*),'HR.AdditionalFormMetadata' from HR.AdditionalFormMetadata 
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.AgencyFund' from HR.AgencyFund 
where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.AgencyFundDetail' from HR.AgencyFundDetail AFD inner join HR.AgencyFund AF on AFD.AgencyFundId=AF.Id 
where AF.companyid in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Appraisal' from HR.Appraisal  
where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.AppraisalAppraiseeDetails'  from HR.AppraisalAppraiseeDetails  AAD 
Inner join HR.Appraisal A on  AAD.AppraisalId=A.Id
where A.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.AppraisalAppraiserDetails' from HR.AppraisalAppraiserDetails AAD
Inner Join HR.Appraisal A on AAD.AppraisalId=A.Id 
where A.CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.AppraisalDetail' from HR.AppraisalDetail AD 
Inner Join HR.Appraisal A on AD.AppraisalId=A.Id
where A.CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.AppraisalDevelopmentPlan' from HR.AppraisalDevelopmentPlan ADP 
Inner Join HR.Appraisal A on ADP.AppraisalId=A.Id 
where A.CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.AppraisalResult' from HR.AppraisalResult AR 
Inner Join HR.Appraisal A on AR.AppraisalId=A.Id
where A.CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.AppraisalSummary' from HR.AppraisalSummary APS
Inner Join HR.Appraisal A on APS.AppraisalId=A.Id
where A.CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)



select count(*),'HR.Asset' from HR.Asset 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.ClaimItem' from HR.ClaimItem
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.ClaimsEntitlement' from HR.ClaimsEntitlement
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.ClaimSetup' from HR.ClaimSetup 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.ClaimSetupDetail' from HR.ClaimSetupDetail CSD
Inner Join HR.ClaimItem CI on CSD.ClaimItemId=CI.Id
Where CI.companyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.CompanyPayrollSettings' from HR.CompanyPayrollSettings 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.CompanyPayrollSettingsDetail' from HR.CompanyPayrollSettingsDetail CPSD
Inner Join HR.CompanyPayrollSettings CPS on CPSD.MasterId=CPS.Id
where CPS.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Competence' from HR.Competence 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.CompetenceDetail' from HR.CompetenceDetail CD
Inner Join HR.Competence C On CD.MasterId=C.Id
where C.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.CourseLibrary' from HR.CourseLibrary
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.CPFSettings' from HR.CPFSettings 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.DevelopmentPlan' from HR.DevelopmentPlan
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Education' from HR.Education E
Inner Join HR.JobApplication JA on E.ApplicationId=JA.Id
where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.EmployeeBankDetails' from HR.EmployeeBankDetails
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)


select count(*),'HR.EmployeeClaim1' from HR.EmployeeClaim1
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.EmployeeClaimDetail' from HR.EmployeeClaimDetail ECD
Inner Join HR.ClaimItem CI on ECD.ClaimItemId=CI.Id 
where CI.CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.EmployeeClaimsEntitlement' from HR.EmployeeClaimsEntitlement 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.EmployeeClaimsEntitlementDetail' from HR.EmployeeClaimsEntitlementDetail ECE
inner join HR.ClaimItem CI on ECE.ClaimItemId=CI.Id
where CI.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


select count(*),'HR.EmployeeDepartment' from HR.EmployeeDepartment
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.EmployeePayrollSetting' from HR.EmployeePayrollSetting
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.EmployeeProjects' from HR.EmployeeProjects 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Employment' from HR.Employment 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.EmploymentHistory' from HR.EmploymentHistory EH
Inner JOin HR.JobApplication JA on EH.ApplicationId=JA.Id
where JA.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Evaluation'  from HR.Evaluation E
Inner join HR.JobApplication JA on E.ApplicationId=JA.Id
where JA.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.EvaluationDetails' from HR.EvaluationDetails 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)
 
select count(*),'HR.FamilyDetails' from HR.FamilyDetails FD
Inner Join Common.Employee E on FD.EmployeeId=E.Id
where E.CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.FamilyPerticulars' from HR.FamilyPerticulars FP
Inner Join HR.JobApplication JA on FP.ApplicationId =JA.Id
where JA.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


--NO Relation
select count(*),'HR.HrAuditTrails' from HR.HrAuditTrails

select count(*),'HR.Interview' from HR.Interview I
Inner Join HR.JobApplication JA On I.ApplicationId=JA.Id
Where JA.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.JobApplication' from HR.JobApplication 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.JobPosting' from HR.JobPosting 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.LeaveApplication' from HR.LeaveApplication
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.LeaveApplicationHistory' from HR.LeaveApplicationHistory LAH
Inner Join HR.LeaveApplication LA on LAH.LeaveApplicationId=LA.Id
where LA.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.LeaveEntitlement' from HR.LeaveEntitlement LE
Inner Join HR.LeaveType LT on LE.LeaveTypeId=LT.Id
Where LT.CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.LeaveEntitlementAdjustment' from HR.LeaveEntitlementAdjustment LEA
Inner join  HR.LeaveEntitlement LE on LEA.LeaveEntitlementId=LE.Id inner Join HR.LeaveType LT on LE.LeaveTypeId=LT.Id
where LT.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.LeaveRequest' from HR.LeaveRequest
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.LeaveRequestHistory' from HR.LeaveRequestHistory LRH
Inner Join HR.LeaveRequest LR on LRH.LeaveRequestId=LR.Id 
where LR.CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.LeaveSetup' from HR.LeaveSetup 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.LeaveSetupEmployees' from HR.LeaveSetupEmployees LSE
Inner Join Common.Employee E on LSE.LeaveStatusChangedEmployeeId=E.Id
where E.CompanyId in(0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.LeavesReport' from HR.LeavesReport 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.LeaveType' from HR.LeaveType 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.LeaveTypeDetails' from HR.LeaveTypeDetails LTD
Inner Join HR.LeaveType LT on LTD.LeaveTypeId=LT.Id
where LT.CompanyId in(0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Objective' from HR.Objective
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.PayComponent' from HR.PayComponent
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.PayComponentDetail' from HR.PayComponentDetail PCD
Inner Join HR.PayComponent PC On PCD.MasterId=PC.Id
Where PC.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Payroll' from HR.Payroll 
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.PayrollDetails' from HR.PayrollDetails PD
Inner Join HR.Payroll P On PD.MasterId=P.Id
where P.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.PayrollSplit' from HR.PayrollSplit PS
Inner Join HR.PayComponent PC On PS.PayComponentId=PC.Id
where PC.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Project' from HR.Project
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Qualification' from HR.Qualification Q
Inner Join Common.Employee E on Q.EmployeeId=E.Id
where E.CompanyId in(0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Question' from HR.Question
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.QuestionCompetence' from HR.QuestionCompetence QC
Inner Join HR.Question Q on QC.QuestionId=Q.Id
where Q.CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Questionnaire' from HR.Questionnaire
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.QuestionnaireDetail' from HR.QuestionnaireDetail QD
Inner Join HR.Question Q on QD.QuestionId=Q.Id
where Q.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.QuestionnaireObjective' from HR.QuestionnaireObjective QO
Inner Join HR.Questionnaire Q on QO.QuestionnaireId=Q.Id
where Q.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Requisition' from HR.Requisition
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.SDL' from HR.SDL
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Trainer' from HR.Trainer
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.TrainerCourse' from HR.TrainerCourse TC
inner join HR.Trainer T on TC.TrainerId=T.Id
where T.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.Training' from HR.Training
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.TrainingAttendance' from HR.TrainingAttendance TA
Inner Join HR.Training T on TA.TrainingId=T.Id
where T.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.TrainingAttendee' from HR.TrainingAttendee TA
Inner Join HR.Training T on TA.TrainingId=T.Id
where T.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.TrainingSchedule' from HR.TrainingSchedule TS
Inner Join HR.Training T On TS.TrainingId=T.Id
where T.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.WorkProfile' from HR.WorkProfile
where CompanyId in  (0,1,10,12,19,136,138,172,239,242,256,258,261)

select count(*),'HR.WorkProfileDetails' from HR.WorkProfileDetails WPD
Inner Join HR.WorkProfile WP on WPD.MasterId=WP.Id
where WP.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

END







GO
