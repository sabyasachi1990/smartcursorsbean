USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_REPORT_PAYROLL_YTD_MAIN]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[HR_REPORT_PAYROLL_YTD_MAIN](@parentCompanyId nvarchar(10), @companyId nvarchar(10), @months nvarchar(200), @employeeIds nvarchar(2000), @year nvarchar(10), @states nvarchar(500), @departmentIds nvarchar(2000))
AS
BEGIN

-- exec [HR_REPORT_PAYROLL_YTD_MAIN] 19,20,'Jan,Feb','AC4107C2-044A-693A-88C4-2C317AF3605F,79A1F0B3-70F5-0DD2-BF57-F725E8D60237','2019','Processed',null
-- exec [HR_REPORT_PAYROLL_YTD_MAIN] 19,'20',null,null,'2019','Processed',null

DECLARE @PayrollMonths NVARCHAR(2000)
DECLARE @Sql NVARCHAR(max)
DECLARE @PayrollEmployeeIds NVARCHAR(2000)
DECLARE @EmpDepartmentIds NVARCHAR(2000)
DECLARE @States_New NVARCHAR(2000)

--DECLARE @parentCompanyId nvarchar(10) =19
--DECLARE @companyId nvarchar(10) =20
--DECLARE @months nvarchar(200) = null
--declare @employeeIds nvarchar(2000) = null
--declare @year nvarchar(100)=2019
--declare @states nvarchar(500)='Processed'
--declare @departmentIds nvarchar(2000) = null

set @employeeIds = case when @employeeIds is not null and @employeeIds != '' then ''''+@employeeIds+'''' else  null end
set @departmentIds = case when @departmentIds is not null and @departmentIds != '' then ''''+@departmentIds+'''' else  null end

set @months = case when @months is not null and @months != '' then ''''+@months+''''  else  null end
set @states = case when @states is not null and @states != '' then ''''+@states+''''  else  null end

set @PayrollMonths = CASE 
WHEN @months is not null THEN  'p.Month in (select distinct items from SplitToTable('+@months+','',''))' else 'P.CompanyId='+@companyId
END

SELECT @PayrollEmployeeIds = CASE 
WHEN @employeeIds is not null THEN  'PD.EmployeeId in (select distinct items from SplitToTable('+@employeeIds+','',''))' else 'P.CompanyId='+@companyId+''
END

SELECT @EmpDepartmentIds = CASE 
WHEN @departmentIds is not null THEN  'ED.DepartmentId in (select distinct items from SplitToTable('+@departmentIds+','',''))' else 'ED.CompanyId in (select Id from common.company where parentId='+@parentCompanyId+')'
END

set @States_New = CASE 
WHEN @states is not null THEN  'P.PayrollStatus in (select distinct items from SplitToTable('+@states+','',''))' else 'P.CompanyId='+@companyId
END

set @sql = 'select C.Name as CompanyName, E.Id as EmployeeId, P.Year as Year, P.Month as Month, E.EmployeeId as EmployeeNumber, E.FirstName as EmployeeName, D.Name as DeptName , D.Id as DeptId
from hr.Payroll P
join hr.PayrollDetails PD on p.Id = PD.MasterId
join Common.Employee E on E.Id = PD.EmployeeId
join hr.EmployeeDepartment ED on E.Id = ED.EmployeeId
join Common.Department D on D.Id = ED.DepartmentId
join Common.Company C on C.Id = '+@companyId+'
where p.CompanyId='+@companyId+' and p.IsTemporary = 0 and p.Year='+@year+' and ('+@PayrollMonths+') and ('+@States_New+') and ('+@PayrollEmployeeIds+') and ('+@EmpDepartmentIds+')' -- and (Convert(Date,ED.EffectiveFrom) <= Convert(date,'''+@year+'-'+'''+P.Month+'+'''-01'') and (Convert(Date,EffectiveTo) >= Convert(date,'''+@year+'-'+'''+P.Month+'+'''-01'') or EffectiveTo Is null))'

print @sql
exec(@sql);

END



















GO
