USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Payroll_Summary_New_SP]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Payroll_Summary_New_SP]


-- Exec [dbo].[Payroll_Summary_New_SP]

AS
BEGIN

Select id,[Employee No],Entity,Convert(nvarchar(10),years)+'-'+Convert(nvarchar(10),months) as [Year-Month],[Total],count([Count]) as [Count] ,
[Left],[State],[Created Date],[Created By],[Modified Date],[Modified By],[Employee Name],Department,TenantId,[PayRoll Date],Designation
From
(
select p. id,p.year as years,p.Month as months,C.ParentId,P.CompanyId SubCompany,P.PayrollStatus,c.Name SubCompanyName,c.name as 'Entity',p.TotalEmployeesCount as 'Total',c.TenantId,
	PD.EmployeeId as Count,PD.EmployeeId,p.RemainingEmployeesCount AS 'Left',P.PayrollStatus as 'State', convert (date ,p.CreateDate) as 'Created Date' ,p.UserCreated as 'Created By' , 
	 convert(date, p.ModifiedDate) as 'Modified Date' ,p.ModifiedBy as 'Modified By',convert(date,Dateadd(d,-1,dateadd(month,1,PD.CreatedDate))) [PayRoll Date] From    HR.Payroll P
			Join    HR.PayrollDetails PD on PD.MasterId=P.Id
			Join    Common.Company C on C.Id=P.CompanyId
			where --c.Name='Gusto Pte. Ltd' and 
			P.PayrollStatus is not null --and P.PayrollStatus='Approved'
			--group by c.name,PD.EmployeeId,P.PayrollStatus,p.TotalEmployeesCount,p.RemainingEmployeesCount,p.CreateDate , pd.createddate, p.ModifiedDate ,p.ModifiedBy,p.UserCreated
			
) PD
inner Join
(   
	--Step 7: Getting Employee department and designation,effectiveFrom and effectiveTo wrt to SubCompany
	Select rank() over(partition by ed.employeeid/*ed.departmentId*/ order by ( case when Ed.[EffectiveTo] is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else Ed.[EffectiveTo] end  ) desc) as rank  ,E.FirstName [Employee Name],E.EmployeeId [Employee No], D.Code Department,DD.Code Designation,Ed.EmployeeId,
Ed.DepartmentId,Ed.DepartmentDesignationId,convert(date,Ed.EffectiveFrom) EffectiveFrom,Case when Ed.EffectiveTo is null then 
Convert(date,dateadd(d,-datepart(day,dateadd(m,1,GETDATE())),dateadd(m,1,GETDATE()))) else CONVERT(date,Ed.EffectiveTo) end EffectiveTo,Ed.RecOrder,Ed.CompanyId Subcompany,E.companyid--,ed.* 
	From   hr.EmployeeDepartment Ed 
	Join   hr.Employment emp on emp.employeeid=ed.employeeid
	Join   Common.Employee E on E.Id=Ed.EmployeeId
	Join   Common.Department D on D.Id=Ed.DepartmentId
	Join   Common.DepartmentDesignation DD on DD.Id=Ed.DepartmentDesignationId
	--where E.CompanyId=@CompanyValue 
	 --AND D.Code IN  (select items from dbo.SplitToTable(@Department,','))
	-- AND E.FirstName IN  (select items from dbo.SplitToTable(@Employee,','))
	--End of Step 7
) EDD on EDD.CompanyId=PD.ParentId and EDD.Subcompany=PD.SubCompany and EDD.EmployeeId=PD.EmployeeId ---and PD.[PayRoll Date] between EDD.EffectiveFrom and EDD.EffectiveTo

Where --ParentId=@CompanyValue and PD.SubCompanyName=@SubCompany and
 EDD.rank=1 --and PayrollStatus=@PayrollStatus
 --and Year([PayRoll Date])=@Year and substring(datename(MONTH,[PayRoll Date]),1,3)=@Month
group by id,Entity,PayrollStatus,[Total],[Left],[State],[Created Date],[Created By],[Modified Date],[Modified By],years,Months,[Employee Name],Department,[Employee No],TenantId,[PayRoll Date],Designation

END
GO
