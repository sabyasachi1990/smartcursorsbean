USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_BC_PAYROLL_TRACKING_SP]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[HR_BC_PAYROLL_TRACKING_SP]
-- EXEC HR_BC_PAYROLL_TRACKING_SP
AS 
BEGIN
--=========== Processed But in Posted in Bean ==============================

declare @HRModuleId bigint = (select Id from common.ModuleMaster where Name='HR Cursor')
declare @BCModuleId bigint = (select Id from common.ModuleMaster where Name='Bean Cursor')

select 'Not Posted in BC' as QueryState, C.ParentId as CompanyId, C.Name as CompanyName, P.Id, P.CompanyId as SubCompanyId, P.Month,P.Year,P.ProcessedDate,P.ProcessedBy,P.PayrollStatus, B.* from hr.Payroll P 
left join bean.Bill B on P.Id = B.PayrollId
join Common.Company C on C.Id = P.CompanyId
where P.PayrollStatus='Processed' and B.Id is null and C.ParentId  in (select CompanyId from Common.CompanyModule where (ModuleId = @HRModuleId and Status=1) and CompanyId in (select CompanyId from Common.CompanyModule where (ModuleId = @BCModuleId and Status=1)))
order by C.Name

--============ Cancel but not void on BC ====================================

select 'HR=Cancel && BC!=Void' as QueryState, C.ParentId as CompanyId, C.Name as CompanyName, P.Id, P.CompanyId as SubCompanyId, P.Month,P.Year,P.ProcessedDate,P.ProcessedBy,P.PayrollStatus, B.* from hr.Payroll P 
left join bean.Bill B on P.Id = B.PayrollId
join Common.Company C on C.Id = P.CompanyId
where P.PayrollStatus='Cancelled' and B.Id is null and C.ParentId  in (select CompanyId from Common.CompanyModule where (ModuleId = @HRModuleId and Status=1) and CompanyId in (select CompanyId from Common.CompanyModule where (ModuleId = @BCModuleId and Status=1))) and B.DocumentState != 'Void'
order by C.Name

--============= Void in BC but not Cancel in HR =============================

select 'BC=Void && HR!=Cancel' as QueryState, C.ParentId as CompanyId, C.Name as CompanyName, P.Id, P.CompanyId as SubCompanyId, P.Month,P.Year,P.ProcessedDate,P.ProcessedBy,P.PayrollStatus, B.* from hr.Payroll P 
left join bean.Bill B on P.Id = B.PayrollId
join Common.Company C on C.Id = P.CompanyId
where P.PayrollStatus!='Cancelled' and B.Id is null and C.ParentId  in (select CompanyId from Common.CompanyModule where (ModuleId = @HRModuleId and Status=1) and CompanyId in (select CompanyId from Common.CompanyModule where (ModuleId = @BCModuleId and Status=1))) and B.DocumentState = 'Void'
order by C.Name

END

























GO
