USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RptPayrollDetail_API]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec RptPayrollDetail_API @CompanyValue=615, @SubCompany ='APM', @PayrollStatus='Approved',
--@Department='Adm',@Employee='Mulyana Binte Musa', @Year=2018, @Month='Jan'
CREATE Procedure [dbo].[RptPayrollDetail_API]
@CompanyValue int,
@SubCompany Varchar(max),
@PayrollStatus varchar(100),
@Department varchar(MAX),
@Employee varchar(MAX),
@Year Bigint,
@Month Varchar(50)

As
Begin

--Step 8: Joing step6 with step7 to get Employee Details, Department and designation information from step7 along with existing infromation from step6
Select ParentId,PD.SubCompany,SubCompanyName,PayrollStatus,[PayRoll Date],EDD.EmployeeId,[Employee Name],[Employee No],Department,Designation,PayType,PayComponent,Amount,Ordering,SubOrdering
From
(
	--Step 6:Getting all records from step5 and adding Ordering and subOrdering columns based on requirement
	Select ParentId,SubCompany,SubCompanyName,PayrollStatus,EmployeeId,PayType,PayComponent,Amount,[PayRoll Date],
		   Case When PayType='BasicPay' Then 1  
				When PayType in ('Earning','EarningsTotal') Then 2  
				When PayType in ('Deduction','DeductionTotal') Then 3 
				When PayType='GrossWage' Then 4 
				When PayType in ('Reimbursement','ReimbursementTotal') Then 5
				When PayType='AgencyFund' Then 6
				When PayType='EmployeeCPF' Then 7
				When PayType='NetWage' Then 8
				When PayType='EmployerCPF' Then 9
				When PayType='Total CPF' Then 10
				When PayType='CPF Wages' Then 11
				When PayType='SDL' Then 12
		   end as Ordering,
		   Case When PayType='BasicPay' Then 1  
				When PayType ='Earning' Then 2.1 
				When PayType ='EarningsTotal' Then 2.2 
				When PayType ='Deduction' Then 3.1 
				When PayType ='DeductionTotal' Then 3.2
				When PayType='GrossWage' Then 4 
				When PayType ='Reimbursement' Then 5.1 
				When PayType ='ReimbursementTotal' Then 5.2
				When PayType='AgencyFund' Then 6
				When PayType='EmployeeCPF' Then 7
				When PayType='NetWage' Then 8
				When PayType='EmployerCPF' Then 9
				When PayType='Total CPF' Then 10
				When PayType='CPF Wages' Then 11
				When PayType='SDL' Then 12
		   end as SubOrdering
	From 
	(
		--Step5:Result set After Union all done
		--Step2:Unpivot done  and PayComponent is Derived from PayType
		Select ParentId,SubCompany,SubCompanyName,PayrollStatus,EmployeeId,PayType,Amount,PayType PayComponent,[PayRoll Date]
		From
		(
			--Step1:
			Select  C.ParentId,P.CompanyId SubCompany,c.Name SubCompanyName,P.PayrollStatus,PD.EmployeeId,PD.BasicPay BasicPay,PD.EmployeeCPF,PD.EmployerCPF,PD.SDL,PD.AgencyFund,/*PD.Earnings EarningsTotal,PD.Deduction DeductionTotal,PD.Reimbursement ReimbursementTotal,*/PD.GrossWage,PD.NetWage,(PD.EmployeeCPF+PD.EmployerCPF) [Total CPF],
					convert(date,Dateadd(d,-1,dateadd(month,1,PD.CreatedDate))) [PayRoll Date]
			From    HR.Payroll P
			Join    HR.PayrollDetails PD on PD.MasterId=P.Id
			Join    Common.Company C on C.Id=P.CompanyId
			where   C.ParentId=@CompanyValue
			--End of Step1
		) DT1
		unpivot
		(
			Amount for PayType in (BasicPay,EmployeeCPF,EmployerCPF,SDL,AgencyFund,/*EarningsTotal,DeductionTotal,ReimbursementTotal,*/GrossWage,NetWage,[Total CPF])
		)UPVT
		--End of Step2

		Union All
		--Step3:Taking Paycomponents Records from Payrollsplit.Here Basic Pay Component is excluded due to it is used as BasicPay column of Payroll Details Table
		Select  C.ParentId,P.CompanyId SubCompany,c.Name SubCompanyName,P.PayrollStatus,PD.EmployeeId,PS.PayType,/*isnull(PS.Amount,0.00)*/ PS.Amount,
		        Case when PS.PayType='Earning' then PC.Name+' (E)'
				     when PS.PayType='Deduction' then PC.Name+' (D)'   
					 when PS.PayType='Reimbursement' then PC.Name+' (R)'
				end PayComponent,
				convert(date,Dateadd(d,-1,dateadd(month,1,PD.CreatedDate))) [PayRoll Date]
		From    HR.Payroll P
		Join    HR.PayrollDetails PD on PD.MasterId=P.Id
		Join    Common.Company C on C.Id=P.CompanyId
		Join    HR.PayrollSplit PS on PS.PayrollDetailId=PD.Id
		Join    HR.PayComponent PC on PC.Id=PS.PayComponentId
		where   C.ParentId=@CompanyValue and PC.Name <>'Basic Pay' and PS.PayType<>'N/A'
		--End of Step3

		Union All
		--Step 4:Getting CPF Wages Column Records
		--Step 4.2:Getting CPF Wages Aggregate amount WRT ParentId,SubCompany,PayrollStatus,EmployeeId,PayType,PayComponent,[PayRoll Date]
		Select ParentId,SubCompany,SubCompanyName,PayrollStatus,EmployeeId,PayType,sum(Amount) Amount,PayComponent,[PayRoll Date]
		From
		( 
			--Step 4.1: Here We are taking records where ComponentType in Earning/Deduction with wagetype AW/OW.
			--Here we setPayType and PayComponent as CPF Wages  
			Select  C.ParentId,P.CompanyId SubCompany,c.Name SubCompanyName,P.PayrollStatus,PD.EmployeeId,'CPF Wages' PayType,/*PS.PayType,*/isnull(PS.Amount,0.00) Amount,'CPF Wages' PayComponent,/*PC.Name PayComponent,*/convert(date,Dateadd(d,-1,dateadd(month,1,PD.CreatedDate))) [PayRoll Date]
			From    HR.Payroll P
			Join    HR.PayrollDetails PD on PD.MasterId=P.Id
			Join    Common.Company C on C.Id=P.CompanyId
			Join    HR.PayrollSplit PS on PS.PayrollDetailId=PD.Id
			Join    HR.PayComponent PC on PC.Id=PS.PayComponentId
			where   C.ParentId=@CompanyValue --and PC.Name <>'Basic Pay' 
			and     PC.Type in ('Earning','Deduction') 
			and     WageType in ('Additional (AW)','Ordinary (OW)') 
		)CPF
		Group By ParentId,SubCompany,SubCompanyName,PayrollStatus,EmployeeId,PayType,PayComponent,[PayRoll Date]
		--End of Step4

		--End of Step5
	)DT2
	--Order By ParentId,SubCompany,PayrollStatus,EmployeeId,[PayRoll Date],Ordering,SubOrdering,PayComponent
	--Step 6 Ending
) PD
Inner Join
(   
	--Step 7: Getting Employee department and designation,effectiveFrom and effectiveTo wrt to SubCompany
	Select E.FirstName [Employee Name],E.EmployeeId [Employee No], D.code Department,DD.Code Designation,Ed.EmployeeId,Ed.DepartmentId,Ed.DepartmentDesignationId,convert(date,Ed.EffectiveFrom) EffectiveFrom,Case when Ed.EffectiveTo is null then Convert(date,dateadd(d,-datepart(day,dateadd(m,1,GETDATE())),dateadd(m,1,GETDATE()))) else CONVERT(date,Ed.EffectiveTo) end EffectiveTo,Ed.RecOrder,Ed.CompanyId Subcompany,emp.companyid--,ed.* 
	From   hr.EmployeeDepartment Ed 
	Join   hr.Employment emp on emp.employeeid=ed.employeeid
	Join   Common.Employee E on E.Id=Ed.EmployeeId
	Join   Common.Department D on D.Id=Ed.DepartmentId
	Join   Common.DepartmentDesignation DD on DD.Id=Ed.DepartmentDesignationId
	where  E.CompanyId=@CompanyValue 
	 AND D.Code IN  (select items from dbo.SplitToTable(@Department,','))
	 AND E.FirstName IN  (select items from dbo.SplitToTable(@Employee,','))
	--End of Step 7
) EDD on EDD.CompanyId=PD.ParentId and EDD.Subcompany=PD.SubCompany and EDD.EmployeeId=PD.EmployeeId and PD.[PayRoll Date] between EDD.EffectiveFrom and EDD.EffectiveTo

Where ParentId=@CompanyValue and PD.SubCompanyName=@SubCompany and PayrollStatus=@PayrollStatus and Year([PayRoll Date])=@Year and substring(datename(MONTH,[PayRoll Date]),1,3)=@Month
Order By ParentId,SubCompany,PayrollStatus,[Employee No],[PayRoll Date],Ordering,SubOrdering,PayComponent
--End of Step8


End
GO
