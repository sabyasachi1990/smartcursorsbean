USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RptPayrollDetailReport_New_1stlevel]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  Procedure  [dbo].[RptPayrollDetailReport_New_1stlevel]
@CompanyValue int,
@SubCompany Varchar(max),
@PayrollStatus varchar(max),
@Year Bigint,
@Month Varchar(50)

As
Begin

select c.name as 'Entity',Right(year(p.CreateDate),4)+'-'+ Left(DateName(Month,p.CreateDate),3) as 'Year-Month',p.TotalEmployeesCount as 'Total',
	count(PD.EmployeeId) as Count,p.RemainingEmployeesCount AS 'Left',P.PayrollStatus as 'State', convert (date ,p.CreateDate) as 'Created Date' ,p.UserCreated as 'Created By' , 
	 convert(date, p.ModifiedDate) as 'Modified Date' ,p.ModifiedBy as 'Modified By' From    HR.Payroll P
			Join    HR.PayrollDetails PD on PD.MasterId=P.Id
			Join    Common.Company C on C.Id=P.CompanyId
			where C.ParentId=@CompanyValue and c.name=@SubCompany and  P.PayrollStatus is not null and payrollStatus 
			in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @PayrollStatus FOR XML PATH('')), 1),','))
			AND Year(p.CreateDate)=@Year and substring(datename(MONTH,p.CreateDate),1,3)=@Month
			group by c.name,P.PayrollStatus,p.TotalEmployeesCount,p.RemainingEmployeesCount,p.CreateDate  , p.ModifiedDate ,p.ModifiedBy,p.UserCreated
			order by p.CreateDate desc

			end 


GO
