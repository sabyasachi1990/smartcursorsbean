USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_REPORT_PAYROLL_YTD_WithoutDept]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[HR_REPORT_PAYROLL_YTD_WithoutDept](@parentCompanyId nvarchar(10), @companyId nvarchar(10), @months nvarchar(200), @employeeIds nvarchar(2000), @year nvarchar(10), @states nvarchar(500), @departmentIds nvarchar(2000))
AS
BEGIN

-- exec [HR_REPORT_PAYROLL_YTD] 19,20,'Jan,Feb','AC4107C2-044A-693A-88C4-2C317AF3605F,79A1F0B3-70F5-0DD2-BF57-F725E8D60237','2020','Processed',null
-- exec [HR_REPORT_PAYROLL_YTD] 19,'20',null,null,'2019','Processed',null

DECLARE @PayrollMonths NVARCHAR(2000)
DECLARE @Sql NVARCHAR(max)
DECLARE @PayrollEmployeeIds NVARCHAR(2000)
DECLARE @EmpDepartmentIds NVARCHAR(2000)
DECLARE @States_New NVARCHAR(2000)
DECLARE @EmployeeIds_New NVARCHAR(2000)

--DECLARE @parentCompanyId nvarchar(10) =1
--DECLARE @companyId nvarchar(10) =6
--DECLARE @months nvarchar(200) = null
--declare @employeeIds nvarchar(2000) = '9E2222F6-0028-4FF3-9F84-35006EFBEAEE'
--declare @year nvarchar(100)=2021
--declare @states nvarchar(500)='Processed'
--declare @departmentIds nvarchar(2000) = null


------==============================================TEMPTABLE==============================--------------
SELECT * INTO #YTDDEPTTEMP
FROM (
select id,masterid,STRING_AGG(AgencyFundCode,',') as AgencyFundCode
,STRING_AGG(value,',') as value
from
(
select  masterid,id,
AgencyFundCode,
case when cast(value1 as float) is null then 
cast(value2 as float) else cast(value1 as float) end as value
from
(
select
PS.id,
PS.masterid,
--JSON_VALUE(x.value,'$.AgencyFundName') as AgencyFundName,
JSON_VALUE(x.value,'$.AgencyFundCode') as AgencyFundCode,
JSON_VALUE(x.value,'$.AgencyFundId') as AgencyFundId,
JSON_VALUE(x.value,'$.value') as value1,
JSON_VALUE(x.value,'$.Value') as value2
from hr.payroll p (NOLOCK)
join hr.PayrollDetails PS (NOLOCK) on p.Id = PS.MasterId
cross apply openjson(agencyFundmodel) as x
--WHERE MasterId='3460be24-1dee-4a14-827d-3be6b66cf3f8'
) as P
) as D 
group by masterid, id

) AS YTDDEPT

--------==================================TEMPTABLE========================================---------------


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
WHEN @departmentIds is not null THEN  'ED.DepartmentId in (select distinct items from SplitToTable('+@departmentIds+','',''))' else 'ED.CompanyId in (select Id from common.company (NOLOCK) where parentId='+@parentCompanyId+')'
END

SELECT @EmployeeIds_New = CASE 
WHEN @employeeIds is not null THEN  'P.EmployeeId in (select distinct items from SplitToTable('+@employeeIds+','',''))' else 'P.EmployeeId = P.EmployeeId'
END

set @States_New = CASE 
WHEN @states is not null THEN  'P.PayrollStatus in (select distinct items from SplitToTable('+@states+','',''))' else 'P.CompanyId='+@companyId
END
set @sql = 'SELECT P.EmployeeId, P.Year, P.Month, P.EmployeeNumber, P.EmployeeName, P.DepartmentName DeptName, P.DepartmentId DeptId, p.PaycomponentName, p.PayComponentType, p.Amount, p.PayComponentId, p.AgencyFundCode,p.value, p.GrossWage, p.NetWage, p.EmployeeCPF, p.EmployerCPF
from
(
select pd.EmployeeId,  Year,  Month,  EmployeeNumber, EmployeeName, PaycomponentName, PayComponentCategory,
 PayComponentType,  Amount,  PayComponentId, --AgencyFundCode, 
 AgencyFundCode, PD.value, 
 GrossWage,
 NetWage, EmployeeCPF, EmployerCPF,pd.SubCompany,DepartmentName,DepartmentId from 
(
	select  E.Id as EmployeeId, P.Year as Year, P.Month as Month, E.EmployeeId as EmployeeNumber, E.FirstName as EmployeeName,E.DepartmentName,E.DepartmentId, PC.Name as PaycomponentName, PC.Category as PayComponentCategory,
	PC.Type as PayComponentType, PS.Amount as Amount, PC.Id as PayComponentId, --AF.Code as AgencyFundCode, 
	PD.GrossWage as GrossWage,
	PD.NetWage as NetWage, PD.EmployeeCPF as EmployeeCPF, PD.EmployerCPF as EmployerCPF,P.CompanyId SubCompany,c.ParentId,
	R.AgencyFundCode as AgencyFundCode  ,R.value as value
	from hr.Payroll P (NOLOCK)
	join hr.PayrollDetails PD (NOLOCK) on p.Id = PD.MasterId
	join hr.EmployeePayrollSetting eps (NOLOCK) on eps.EmployeeId = pd.EmployeeId
	left join hr.AgencyFund AF (NOLOCK) on AF.Id = eps.AgencyFundId 
	join Common.Employee E (NOLOCK) on E.Id = PD.EmployeeId
	join hr.PayrollSplit PS (NOLOCK) on PS.PayrollDetailId = PD.Id
	join hr.PayComponent PC (NOLOCK) on PC.Id = PS.PayComponentId
	join common.company c (NOLOCK) on c.id=p.CompanyId
	Left join #YTDDEPTTEMP  R on R.id =PD.Id
	where p.CompanyId='+@companyId+' and p.IsTemporary = 0 and p.Year='+@year+' and ('+@PayrollMonths+') and ('+@States_New+') and ('+@PayrollEmployeeIds+') 
	--and ('+@EmpDepartmentIds+')
)as PD

)as p
where '+@EmployeeIds_New+''

--and (Convert(Date,ED.EffectiveFrom) <= Convert(date,GETUTCDATE()) and (Convert(Date,EffectiveTo) >= Convert(date,GETUTCDATE()) or EffectiveTo Is null))'
--and (Convert(Date,ED.EffectiveFrom) <= Convert(date,'''+@year+'-'+'''+P.Month+'+'''-01'') and (Convert(Date,EffectiveTo) >= Convert(date,'''+@year+'-'+'''+P.Month+'+'''-01'') or EffectiveTo Is null))'



--print @sql
exec(@sql);

DROP TABLE #YTDDEPTTEMP
END
GO
