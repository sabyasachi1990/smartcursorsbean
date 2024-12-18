USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Payroll_Details_Summary_New_SP]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[Payroll_Details_Summary_New_SP]

-- exec  [dbo].[Payroll_Details_Summary_New_SP]

AS
BEGIN



select id,ParentId,SubCompany,SubCompanyName,PayrollStatus,[PayRoll Date],EmployeeId,[Employee Name],[Employee No],Department,Designation,PayComponent,
AgencyFund,BasicPay,[CPF Wages],Deduction,Earning,EmployeeCPF,EmployerCPF,GrossWage,NetWage,Reimbursement,SDL,[Total CPF],TenantId
 from 
(
--Step 8: Joing step6 with step7 to get Employee Details, Department and designation information from step7 along with existing infromation from step6
Select id,ParentId,PD.SubCompany,SubCompanyName,PayrollStatus,[PayRoll Date],EDD.EmployeeId,[Employee Name],[Employee No],Department,Designation,PayType,PayComponent,Amount,Ordering,SubOrdering,TenantId
From
(
	--Step 6:Getting all records from step5 and adding Ordering and subOrdering columns based on requirement
	Select id,ParentId,SubCompany,SubCompanyName,PayrollStatus,EmployeeId,PayType,PayComponent,Amount,[PayRoll Date],TenantId,
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
		Select id,ParentId,SubCompany,SubCompanyName,PayrollStatus,EmployeeId,PayType,Amount,PayType PayComponent,[PayRoll Date],TenantId
		From
		(
			--Step1:
			Select  PD.MasterId as  id,C.ParentId,P.CompanyId SubCompany,c.Name SubCompanyName,P.PayrollStatus,PD.EmployeeId,PD.BasicPay BasicPay,PD.EmployeeCPF,PD.EmployerCPF,PD.SDL,PD.AgencyFund,/*PD.Earnings EarningsTotal,PD.Deduction DeductionTotal,PD.Reimbursement ReimbursementTotal,*/PD.GrossWage,PD.NetWage,(PD.EmployeeCPF+PD.EmployerCPF) [Total CPF],
					convert(date,Dateadd(d,-1,dateadd(month,1,PD.CreatedDate))) [PayRoll Date],c.TenantId
			From    HR.Payroll P
			Join    HR.PayrollDetails PD on PD.MasterId=P.Id
			Join    Common.Company C on C.Id=P.CompanyId
			--where   C.ParentId=@CompanyValue
			--End of Step1
		) DT1
		unpivot
		(
			Amount for PayType in (BasicPay,EmployeeCPF,EmployerCPF,SDL,AgencyFund,/*EarningsTotal,DeductionTotal,ReimbursementTotal,*/GrossWage,NetWage,[Total CPF])
		)UPVT
		--End of Step2

		Union All
		--Step3:Taking Paycomponents Records from Payrollsplit.Here Basic Pay Component is excluded due to it is used as BasicPay column of Payroll Details Table
		Select  PD.MasterId as id,C.ParentId,P.CompanyId SubCompany,c.Name SubCompanyName,P.PayrollStatus,PD.EmployeeId,PS.PayType,/*isnull(PS.Amount,0.00)*/ PS.Amount,
		        Case when PS.PayType='Earning' then PC.Name+' (E)'
				     when PS.PayType='Deduction' then PC.Name+' (D)'   
					 when PS.PayType='Reimbursement' then PC.Name+' (R)'
				end PayComponent,
				convert(date,Dateadd(d,-1,dateadd(month,1,PD.CreatedDate))) [PayRoll Date],c.TenantId
		From    HR.Payroll P
		Join    HR.PayrollDetails PD on PD.MasterId=P.Id
		Join    Common.Company C on C.Id=P.CompanyId
		Join    HR.PayrollSplit PS on PS.PayrollDetailId=PD.Id
		Join    HR.PayComponent PC on PC.Id=PS.PayComponentId
		where    PC.Name <>'Basic Pay' and PS.PayType<>'N/A'
		--End of Step3

		Union All
		--Step 4:Getting CPF Wages Column Records
		--Step 4.2:Getting CPF Wages Aggregate amount WRT ParentId,SubCompany,PayrollStatus,EmployeeId,PayType,PayComponent,[PayRoll Date]
		Select id,ParentId,SubCompany,SubCompanyName,PayrollStatus,EmployeeId,PayType,sum(Amount) Amount,PayComponent,[PayRoll Date],TenantId
		From
		( 
			--Step 4.1: Here We are taking records where ComponentType in Earning/Deduction with wagetype AW/OW.
			--Here we setPayType and PayComponent as CPF Wages  
			Select PD.MasterId as id,C.ParentId,P.CompanyId SubCompany,c.Name SubCompanyName,P.PayrollStatus,PD.EmployeeId,'CPF Wages' PayType,/*PS.PayType,*/isnull(PS.Amount,0.00) Amount,'CPF Wages' PayComponent,/*PC.Name PayComponent,*/convert(date,Dateadd(d,-1,dateadd(month,1,PD.CreatedDate))) [PayRoll Date],c.TenantId
			From    HR.Payroll P
			Join    HR.PayrollDetails PD on PD.MasterId=P.Id
			Join    Common.Company C on C.Id=P.CompanyId
			Join    HR.PayrollSplit PS on PS.PayrollDetailId=PD.Id
			Join    HR.PayComponent PC on PC.Id=PS.PayComponentId
			where    --and PC.Name <>'Basic Pay' 
			   PC.Type in ('Earning','Deduction') 
			and     WageType in ('Additional (AW)','Ordinary (OW)') 
		)CPF
		Group By ParentId,SubCompany,SubCompanyName,PayrollStatus,EmployeeId,PayType,PayComponent,[PayRoll Date],CPF.id,TenantId
		--End of Step4

		--End of Step5
	)DT2
	--Order By ParentId,SubCompany,PayrollStatus,EmployeeId,[PayRoll Date],Ordering,SubOrdering,PayComponent
	--Step 6 Ending
) PD
inner Join
(   
	--Step 7: Getting Employee department and designation,effectiveFrom and effectiveTo wrt to SubCompany
	Select distinct rank() over(partition by ed.employeeid/*ed.departmentId*/ order by ( case when Ed.[EffectiveTo] is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else Ed.[EffectiveTo] end  ) desc) as rank  ,
	 E.FirstName [Employee Name],E.EmployeeId [Employee No], D.Code Department,DD.Code Designation,Ed.EmployeeId as EmployeeId,Ed.DepartmentId,Ed.DepartmentDesignationId,
	 convert(date,Ed.EffectiveFrom) EffectiveFrom,Case when Ed.EffectiveTo is null then Convert(date,dateadd(d,-datepart(day,dateadd(m,1,GETDATE())),dateadd(m,1,GETDATE()))) else 
	 CONVERT(date,Ed.EffectiveTo) end EffectiveTo,Ed.RecOrder,Ed.CompanyId Subcompany,E.companyid--,ed.* 
	From   hr.EmployeeDepartment Ed 
	Join   hr.Employment emp on emp.employeeid=ed.employeeid
	Join   Common.Employee E on E.Id=Ed.EmployeeId
	Join   Common.Department D on D.Id=Ed.DepartmentId
	Join   Common.DepartmentDesignation DD on DD.Id=Ed.DepartmentDesignationId
	--where  E.CompanyId=@CompanyValue 
	-- AND D.Code IN  (select items from dbo.SplitToTable(@Department,','))
	-- AND E.FirstName IN  (select items from dbo.SplitToTable(@Employee,','))
	--End of Step 7
) EDD on EDD.CompanyId=PD.ParentId and EDD.Subcompany=PD.SubCompany and EDD.EmployeeId=PD.EmployeeId ---and PD.[PayRoll Date] between EDD.EffectiveFrom and EDD.EffectiveTo

Where  EDD.rank=1  
--and payrollStatus 
		--	in(select items from dbo.SplitToTable(CONVERT(nvarchar(max), (SELECT @PayrollStatus FOR XML PATH('')), 1),',')) and Year([PayRoll Date])=@Year and substring(datename(MONTH,[PayRoll Date]),1,3)=@Month

group by id,ParentId,PD.SubCompany,SubCompanyName,PayrollStatus,[PayRoll Date],EDD.EmployeeId,[Employee Name],[Employee No],Department,Designation,PayType,PayComponent,Amount,Ordering,SubOrdering,TenantId
--Order By ParentId,SubCompany,PayrollStatus,[Employee No],[PayRoll Date],Ordering,SubOrdering,PayComponent
--End of Step8
)as AA
pivot
(
sum(Amount) for paytype in (AgencyFund
,BasicPay
,[CPF Wages]
,Deduction
,Earning
,EmployeeCPF
,EmployerCPF
,GrossWage
,NetWage
,Reimbursement
,SDL
,[Total CPF])
)as Pivt

--where SubCompanyName='Gusto Tax Services Pte. Ltd.' and PayrollStatus='Cancelled' and [Employee Name]='Steve Pan'
END
GO
