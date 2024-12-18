USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_REPORT_PAYROLL_DETAIL]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	--SP:
	
CREATE procedure [dbo].[HR_REPORT_PAYROLL_DETAIL]
(
@parentCompanyId nvarchar(10), @companyId nvarchar(10), @months nvarchar(200), @employeeIds nvarchar(2000), @year nvarchar(10), 
@states nvarchar(500), @departmentIds nvarchar(2000)
)
AS
BEGIN

	-- exec [HR_REPORT_PAYROLL_DETAIL] 19,20,'Jan','AC4107C2-044A-693A-88C4-2C317AF3605F','2019','Processed','9DE14DD5-12F9-430D-80D5-56663C51B7B2'
	-- exec [HR_REPORT_PAYROLL_DETAIL] 19,20,null,null,2019,'Processed',null
	
	
	
	--exec [HR_REPORT_PAYROLL_DETAIL] 1,6,'Jan','ff33eb9b-4e37-4220-960a-389ff5faddf8',2019,'',null

--DECLARE @parentCompanyId nvarchar(10) = 689,
--@companyId nvarchar(10) = 690,
--@months nvarchar(200) = null,
--@employeeIds nvarchar(2000) = '1b18d553-a77f-4016-8b8e-9837e732839c,50c905ee-7feb-4272-8419-5f918c6fc0d6,
--64011369-6506-4d41-9ee5-bc588d6a75b4,16d105a0-a660-4a6b-ac22-2196a2318a16,96515e0a-1e32-2138-a155-d1119eade20d,e6aa4167-2c7b-3da0-2aaf-34d7b451119e,
--9c978ba4-7345-7860-691f-c234c6b80dd7,c5ed1bc7-b392-4e49-adc0-b3362ead4fe9,7b1e1b1a-a685-4546-8e8b-44f2c7804fd7',
--@year nvarchar(10) = 2023,
--@states nvarchar(500) = 'Draft,Generated,Reviewed,Approved,Processed,Saved As Draft',
--@departmentIds nvarchar(2000) = null
		
	DECLARE @PayrollMonths NVARCHAR(2000)
	DECLARE @Sql varchar(8000),@Sql1 varchar(8000),@Sql2 varchar(8000)
	DECLARE @PayrollEmployeeIds NVARCHAR(2000)
	DECLARE @EmpDepartmentIds NVARCHAR(2000)
	DECLARE @States_New NVARCHAR(2000)
	DECLARE @EmployeeIds_New NVARCHAR(2000)
			
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
	WHEN @employeeIds is not null THEN  'CAST(PD.EmployeeId as Nvarchar(100)) in (select distinct items from SplitToTable('+@employeeIds+','',''))' else 'P.CompanyId='+@companyId+''
	END
			
	SELECT @EmployeeIds_New = CASE 
	WHEN @employeeIds is not null THEN  'CAST(P.EmployeeId as Nvarchar(100)) in (select distinct items from SplitToTable('+@employeeIds+','',''))' else 'P.EmployeeId = P.EmployeeId'
	END
			
	SELECT @EmpDepartmentIds = CASE 
	WHEN @departmentIds is not null THEN  'ED.DepartmentId in (select distinct items from SplitToTable('+@departmentIds+','',''))' else 'ED.CompanyId in (select Id from common.company (NOLOCK) where parentId='+@parentCompanyId+')'
	END
	print @EmpDepartmentIds
	set @States_New = CASE 
	WHEN @states is not null THEN  'P.PayrollStatus in (select distinct items from SplitToTable('+@states+','',''))' else 'P.CompanyId='+@companyId
	END
			
	set @Sql1 = 'select P.EmployeeId, P.Year, P.Month, P.EmployeeNumber, P.EmployeeName, P.Department DeptName, P.DepartmentId DeptId, p.PaycomponentName, p.PayComponentCategory, p.PayComponentType, p.Amount, p.PayComponentId, p.AgencyFundCode, p.GrossWage, p.NetWage, p.EmployeeCPF, p.EmployerCPF, OrdinaryWage, AdditionalWage from 
	(
	select pd.EmployeeId,  Year,  Month,  EmployeeNumber, EmployeeName, PaycomponentName, PayComponentCategory,
	 PayComponentType,  Amount,  PayComponentId, AgencyFundCode,  GrossWage,
	 NetWage, EmployeeCPF, EmployerCPF,pd.SubCompany, edd.Department, edd.DepartmentId, OrdinaryWage, AdditionalWage from 
	(
	    select  E.Id as EmployeeId, P.Year as Year, P.Month as Month, E.EmployeeId as EmployeeNumber, E.FirstName as EmployeeName, PC.Name as PaycomponentName, PC.Category as PayComponentCategory,
	    PC.Type as PayComponentType, PS.Amount as Amount, PC.Id as PayComponentId, AF.Code as AgencyFundCode, PD.GrossWage as GrossWage,
	    PD.NetWage as NetWage, PD.EmployeeCPF as EmployeeCPF, PD.EmployerCPF as EmployerCPF,P.CompanyId SubCompany,c.ParentId, PD.OrdinaryWage  as OrdinaryWage, PD.AdditionalWage as AdditionalWage
	    from hr.Payroll P (NOLOCK)
	    join hr.PayrollDetails PD (NOLOCK) on p.Id = PD.MasterId
	    join hr.EmployeePayrollSetting eps (NOLOCK) on eps.EmployeeId = pd.EmployeeId
	    left join hr.AgencyFund AF (NOLOCK) on AF.Id = eps.AgencyFundId 
	    join Common.Employee E (NOLOCK) on E.Id = PD.EmployeeId
	    join hr.PayrollSplit PS (NOLOCK) on PS.PayrollDetailId = PD.Id
	    join hr.PayComponent PC (NOLOCK) on PC.Id = PS.PayComponentId
	    join common.company c (NOLOCK) on c.id=p.CompanyId
	    where p.CompanyId='+@companyId+' and p.IsTemporary = 0 and p.Year='+@year+' and ('+@PayrollMonths+') and ('+@States_New+') and ('+@PayrollEmployeeIds+') 	    
	)as PD '

	set @sql2 = 
	'inner Join
	(   
	    Select distinct rank() over(partition by ed.employeeid order by ( case when Ed.[EffectiveTo] is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
	Year(GETDATE())+1)+''-''+''01''+''-''+''01'')) else Ed.[EffectiveTo] end  ) desc) as rank  ,
	     E.FirstName [Employee Name],E.EmployeeId [Employee No],  D.Name Department, D.Id,DD.Code Designation,Ed.EmployeeId as EmployeeId,Ed.DepartmentId,Ed.DepartmentDesignationId,
	     convert(date,Ed.EffectiveFrom) EffectiveFrom,Case when Ed.EffectiveTo is null then Convert(date,dateadd(d,-datepart(day,dateadd(m,1,GETDATE())),dateadd(m,1,GETDATE()))) else 
	     CONVERT(date,Ed.EffectiveTo) end EffectiveTo,Ed.RecOrder,Ed.CompanyId Subcompany,E.companyid,d.Id DeptId 
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
	
	Set @Sql = @Sql1+@Sql2
	
	print @sql
	exec(@sql);
	
END
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

GO
