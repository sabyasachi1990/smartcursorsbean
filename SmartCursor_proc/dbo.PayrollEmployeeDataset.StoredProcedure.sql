USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PayrollEmployeeDataset]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Declare -----PRDLIVEDB
--@Year int=2018,
--@Month Varchar(100)='Jan',
--@SubCompany Varchar(100)='APM',
--@Department varchar(Max)='ADM,BPO,MBS,PR,PRG,PSG,RC',
----@Designation varchar(Max)='Assistant Store Manager',
--@CompanyValue Int=894



CREATE  procedure [dbo].[PayrollEmployeeDataset]

@CompanyValue int,
@SubCompany Varchar(max),

@Department varchar(MAX),
--@Employee varchar(MAX),
@Year Bigint,
@Month Varchar(50)
as
begin


Declare @FromDate Date
Declare @ToDate Date
Select @FromDate=Convert(date,Convert(varchar(max),@Year)+'-'+@Month+'-'+'01')
--Print @FromDate

Select @ToDate=dateadd(d,-1,dateadd(m,1,@FromDate))
--Print @ToDate
--Select @FromDate=Convert(date,Convert(varchar(100),@Year)+'-'+'01'+'-'+'01')
----print @FromDate

--Select @ToDate=convert(date,dateadd(day,-1,dateadd(YEAR,1,@FromDate)))
----Print @ToDate
 Select Distinct FirstName,[Employee No]
 From
 (
 Select E.FirstName ,E.EmployeeId [Employee No], D.Code ,D.Code Department,DD.Code Designation,Ed.EmployeeId,Ed.DepartmentId,Ed.DepartmentDesignationId,convert(date,Ed.EffectiveFrom) EffectiveFrom,Case when Ed.EffectiveTo is null then Convert(date,dateadd(d,-datepart(day,dateadd(m,1,GETDATE())),dateadd(m,1,GETDATE()))) else CONVERT(date,Ed.EffectiveTo) end EffectiveTo,Ed.RecOrder,Ed.CompanyId Subcompany,emp.companyid,C.name SubComp--,ed.* 
 From   hr.EmployeeDepartment Ed 
 Join   hr.Employment emp on emp.employeeid=ed.employeeid
 Join   Common.Employee E on E.Id=Ed.EmployeeId
 LEFT Join   Common.Department D on D.Id=Ed.DepartmentId
 LEFT Join    Common.DepartmentDesignation DD on DD.Id=Ed.DepartmentDesignationId
 Join   Common.Company C on C.Id=Ed.CompanyId
 where  C.Name=@SubCompany AND E.CompanyId=@CompanyValue
     --AND D.Code IN  (select items from dbo.SplitToTable(@Department,','))
	 And d.Code in (@Department)
  -- AND convert(date,Dateadd(d,-1,dateadd(month,1,PD.CreatedDate)))=@Month 
  --AND DD.Name IN (@Designation)
     and ((convert(date,EffectiveFrom) between @FromDate and @ToDate)
         or (convert(date,case when EffectiveTo is null then 
      dateadd(d,-1,dateadd(m,1,Convert(date,Convert(varchar(max),@Year)+'-'+@Month+'-'+'01')))
      --dateadd(d,-1,Convert(datetime2,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
      else EffectiveTo end) between @FromDate and @ToDate)
      )
  
  ) dt1
  order by [Employee No]
  end 
GO
