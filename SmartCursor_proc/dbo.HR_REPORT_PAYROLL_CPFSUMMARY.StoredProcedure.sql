USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_REPORT_PAYROLL_CPFSUMMARY]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[HR_REPORT_PAYROLL_CPFSUMMARY](@parentCompanyId nvarchar(10), @companyId nvarchar(10), @months nvarchar(200), @employeeIds nvarchar(2000), @year nvarchar(10), @states nvarchar(500), @departmentIds nvarchar(2000))
AS
BEGIN

--Declare
--@parentCompanyId nvarchar(10)=1,
--@companyId nvarchar(10)=6,
--@months nvarchar(200)=null,
--@employeeIds nvarchar(2000)='9E2222F6-0028-4FF3-9F84-35006EFBEAEE',
--@year nvarchar(10)=2021,
--@states nvarchar(500)=null,
--@departmentIds nvarchar(2000)=null


-- exec [HR_REPORT_PAYROLL_CPFSUMMARY] 19,20,'','79395698-3FBB-B116-6FE3-95AB8301436E','2019','Processed',''
-- exec [HR_REPORT_PAYROLL_CPFSUMMARY] 19,20,null,null,'2019','Processed',''

DECLARE @Str NVARCHAR(1000)
DECLARE @Sql NVARCHAR(max)
DECLARE @Str2 NVARCHAR(1000)
DECLARE @EmpDepartmentIds NVARCHAR(2000)
DECLARE @States_New NVARCHAR(2000)
DECLARE @EmployeeIds_New NVARCHAR(2000)

------===================================================================== TEMP TABLE =====================================================================--------

SELECT
*
INTO
#PayrollTemp
FROM
(
 	select PD.Id ,case when cast(value1 as float) is null then
	cast(value2 as float) else cast(value1 as float) end as value,
	AgencyFundName,AgencyFundCode,AgencyFundId
	 from
	(
	select PD.Id,
	JSON_VALUE(x.value,'$.AgencyFundName') as AgencyFundName,
	JSON_VALUE(x.value,'$.AgencyFundCode') as AgencyFundCode,
	JSON_VALUE(x.value,'$.AgencyFundId') as AgencyFundId,
	JSON_VALUE(x.value,'$.value') as value1,
	JSON_VALUE(x.value,'$.Value') as value2
	from hr.Payroll P (NOLOCK)
	join hr.PayrollDetails PD (NOLOCK) on p.Id = PD.MasterId
	cross apply openjson(agencyFundmodel) as x
	where  p.IsTemporary = 0 --and p.CompanyId='+@companyId+' and p.Year='+@year+' and ('+@Str+') and ('+@States_New+') and ('+@Str2+') 
	--and ('+@EmpDepartmentIds+') 
	)as PD
 ) AS ABC

------=====================================================================  =====================================================================--------

set @employeeIds = case when @employeeIds is not null and @employeeIds != '' then ''''+@employeeIds+'''' else  null end
set @departmentIds = case when @departmentIds is not null and @departmentIds != '' then ''''+@departmentIds+'''' else  null end

set @months = case when @months is not null and @months != '' then ''''+@months+''''  else  null end
set @states = case when @states is not null and @states != '' then ''''+@states+''''  else  null end


--DECLARE @companyId nvarchar(10) =20
--DECLARE @months nvarchar(200) = '''Jan,Feb'''
--declare @employeeIds nvarchar(2000) = '''AC4107C2-044A-693A-88C4-2C317AF3605F,79A1F0B3-70F5-0DD2-BF57-F725E8D60237'''
--declare @year nvarchar(100)=2019
--declare @states nvarchar(500)='''Processed'''

set @Str = CASE 
WHEN @months is not null THEN  'p.Month in (select distinct items from SplitToTable('+@months+','',''))' else 'P.CompanyId='+@companyId
END

SELECT @Str2 = CASE 
WHEN @employeeIds is not null THEN  'PD.EmployeeId in (select distinct items from SplitToTable('+@employeeIds+','',''))' else 'P.CompanyId='+@companyId+''
END

SELECT @EmpDepartmentIds = CASE 
WHEN @departmentIds is not null THEN  'ED.DepartmentId in (select distinct items from SplitToTable('+@departmentIds+','',''))' else 'ED.CompanyId in (select Id from common.company (NOLOCK) where parentId='+@parentCompanyId+')'
END

set @States_New = CASE 
WHEN @states is not null THEN  'P.PayrollStatus in (select distinct items from SplitToTable('+@states+','',''))' else 'P.CompanyId='+@companyId
END

SELECT @EmployeeIds_New = CASE 
WHEN @employeeIds is not null THEN  'P.EmployeeId in (select distinct items from SplitToTable('+@employeeIds+','',''))' else 'P.EmployeeId = P.EmployeeId'
END

set @sql = 'select P.EmployeeId,  P.Month,P.Year, P.EmployeeName EmployeeFirstName, p.EmployeeCPF, p.EmployerCPF,p.AgencyFundCode, AgencyFundAmount, SDL, AgencyFundId, P.Department DeptName, P.DepartmentId DeptId, P.AgencyFund,P.AgencyFundName,P.Value from 
(
select pd.EmployeeId,  Year,  Month,  EmployeeNumber, EmployeeName, AgencyFundCode, EmployeeCPF, EmployerCPF,pd.SubCompany,AgencyFundAmount, SDL, AgencyFundId, edd.Department, edd.DepartmentId, AgencyFund,PD.AgencyFundName,PD.Value  from 
(
	select  E.Id as EmployeeId, P.Year as Year, P.Month as Month, E.EmployeeId as EmployeeNumber, E.FirstName as EmployeeName,  
	PD.EmployeeCPF as EmployeeCPF, PD.EmployerCPF as EmployerCPF,P.CompanyId SubCompany,c.ParentId , PD.AgencyFund as AgencyFundAmount, 
	PD.SDL as SDL,  EPS.AgencyFund as AgencyFund, T.AgencyFundCode, T.AgencyFundName,T.AgencyFundId, T.Value
	from hr.Payroll P (NOLOCK)
	join hr.PayrollDetails PD (NOLOCK) on p.Id = PD.MasterId
	join hr.EmployeePayrollSetting eps (NOLOCK) on eps.EmployeeId = pd.EmployeeId
	left join hr.AgencyFund AF (NOLOCK) on AF.Id = eps.AgencyFundId 
	join Common.Employee E (NOLOCK) on E.Id = PD.EmployeeId
	join common.company c (NOLOCK) on c.id=p.CompanyId
	left JOIN #PayrollTemp AS T on T.Id = PD.Id
	where p.CompanyId='+@companyId+' and p.IsTemporary = 0 and p.Year='+@year+' and ('+@Str+') and ('+@States_New+') and ('+@Str2+') 
	--and ('+@EmpDepartmentIds+') 
)as PD
inner Join
(   
    Select distinct rank() over(partition by ed.employeeid order by ( case when Ed.[EffectiveTo] is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
Year(GETDATE())+1)+''-''+''01''+''-''+''01'')) else Ed.[EffectiveTo] end  ) desc) as rank,
     E.FirstName [Employee Name],E.EmployeeId [Employee No], D.Name Department, D.Id, D.Code Designation,Ed.EmployeeId as EmployeeId,Ed.DepartmentId,Ed.DepartmentDesignationId,
     convert(date,Ed.EffectiveFrom) EffectiveFrom,Case when Ed.EffectiveTo is null then Convert(date,dateadd(d,-datepart(day,dateadd(m,1,GETDATE())),dateadd(m,1,GETDATE()))) else 
     CONVERT(date,Ed.EffectiveTo) end EffectiveTo,Ed.RecOrder,Ed.CompanyId Subcompany,E.companyid,d.Id DeptId--,ed.* 
    From   hr.EmployeeDepartment Ed (NOLOCK)
    Join   hr.Employment emp (NOLOCK) on emp.employeeid=ed.employeeid
    Join   Common.Employee E (NOLOCK) on E.Id=Ed.EmployeeId
    Join   Common.Department D (NOLOCK) on D.Id=Ed.DepartmentId
    Join   Common.DepartmentDesignation DD (NOLOCK) on DD.Id=Ed.DepartmentDesignationId
	where ('+@EmpDepartmentIds+')
) EDD on EDD.CompanyId=PD.ParentId and EDD.Subcompany=PD.SubCompany and EDD.EmployeeId=PD.EmployeeId 
Where  EDD.rank=1  
)as p
where '+@EmployeeIds_New+''

--and (Convert(Date,ED.EffectiveFrom) <= Convert(date,GETUTCDATE()) and (Convert(Date,EffectiveTo) >= Convert(date,GETUTCDATE()) or EffectiveTo Is null))'
-- and (Convert(Date,ED.EffectiveFrom) <= Convert(date,'''+@year+'-'+'''+P.Month+'+'''-01'') and (Convert(Date,EffectiveTo) >= Convert(date,'''+@year+'-'+'''+P.Month+'+'''-01'') or EffectiveTo Is null))'
--order by e.FirstName
print @sql
exec(@sql);

DROP TABLE #PayrollTemp


END



--where p.CompanyId='+@companyId+' and p.IsTemporary = 0 and p.Year='+@year+' and ('+@Str+') and ('+@States_New+') and ('+@Str2+') and ('+@EmpDepartmentIds+') 





--Adding columns
-- AgencyFundName
-- AgencyFundCode
-- AgencyFundId
--value
GO
