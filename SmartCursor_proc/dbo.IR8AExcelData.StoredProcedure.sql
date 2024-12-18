USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[IR8AExcelData]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec dbo.IR8AExcelData '2a7ca6a7-f0a8-4c1b-88a3-b57b61bb1abf',9,2022
--exec dbo.Ir8AExcelData 'bb5d6f76-388c-4b94-81f2-d70dbcf1bc67,5e6ee4d3-3247-44f9-ad40-6ee1c6dd7b4e,61513b99-35ef-41ca-999a-668d3e4c283a,9eec30f8-4f82-a043-36c0-e923533ba9e2,9e04c95a-9b32
--2bb3-3c4c-5c99b36c1379,ddd27e71-4091-400a-aede-19ca353245c3,40498ec0-9a05-3c21-668b-2ddc4d52de6c,726b2ef1-ced1-4e32-975b-3d3132b62065,5933bf77-d902-24d0-5c75-a07a79eb332d,5887be7f-d9a4-0c9e-7db5-9b60746481c6,acb9571c-aaf4-4dd9-8b92-67bca05c431e,3df76c27-900a-447e-94eb-590ac75bdd3c,bb2ed177-8081-90b9-31cd-bfde67ca39c6,c063ac14-7308-4898-ae05-90a94853301e,e60525a0-5638-47a7-9988-468783aad80c,4a66f7f6-3d5a-45ac-aa7a-4a7e562e408d,74a25558-da43-4699-847e-f408885744bd,cdb10a75-75d8-4884-9f52-aaeff05daaee,61b67715-d637-4826-970d-ffbda16126a8,67fd261f-445d-4f69-a0f1-280b72cbd9cf,63103f79-4ef4-4416-b4e0-84ab3356dd53,892dae2b-ebaf-4a3a-8bb3-a6c4a468c76f,4e3b9b86-237b-d290-8e84-dc832ab5e775,a1c1e879-0732-fe96-4f8a-4c9f484a2380,87e77b5e-4ccc-470b-9746-b85a4673c494,017d6529-8974-4d67-99d3-8332d924d810,3de9af44-d015-46ee-ab6d-705d3b9b8049,54493004-87a9-4b58-9c8f-3e98cf87a204,00394fb0-0848-443e-ba55-6d6249ed7b93,ce576a3c-c17b-682a-5424-18d0bb40b2f3,9bf960de-f888-4819-9700-b33725bb13ee,31b1e4a4-65e5-44c6-a83c-dd265e1b6f64,85059680-3429-3f6f-fc4a-50675582e25e,dda2cd6e-0e3a-3ead-6ec7-748264e86c55,1aa28e5f-3ab1-4251-af2c-0c4bf7c41123,8cbe2c67-92e8-9ed2-def4-f39c179371de,56d25b4f-5a28-2b0c-d6ba-e92f34ca5312,eed78a1a-47fa-4ff2-92fb-564164b954c5,fe1b1172-cd21-43be-b9c9-e97c0ed816d1,bb6771ff-9720-fb70-58fe-bfc343150c10,c9185101-326d-4e57-bc3d-ed051117d33f,b818ac0c-fbde-42d7-a40c-aeafa95a00ab,a21ddd1f-8a96-4917-b4e3-5693942a0074,997bdee5-27f8-8d40-c445-6198fef0be4f,0f31c331-6550-0fe2-d9dd-64d5ef027cfd,1396d0c2-acee-4ea4-b4db-bcaf94f77b19,3e3c939a-e0e6-4675-aa0b-c0479b03a96c',1518,2022
CREATE procedure [dbo].[IR8AExcelData]
@EmployeeIds nvarchar(max),
@subCompanyId bigint,
@year int
As
Begin



DECLARE  @IR8A TABLE (RecordNo int,IDType nvarchar(250),IDNo nvarchar(250),FullNameofEmployeeasperNRIC nvarchar(max),Citizenship nvarchar(250),Sex nvarchar(250),DateOfBirth Datetime2(7),Designation nvarchar(250),ResidentalAdress nvarchar(max),Adress nvarchar(max),PostalCode nvarchar(250),Country nvarchar(250),DateOfCommencement DateTime2(7),DateOfCessation Datetime2(7),OverSeas Datetime2(7),BankSalaryisCreditedTo nvarchar(250),GrossSalary money,DateOfBonusPaid Datetime2(7),Bonus money,DateOfDirectorFeeApproved Datetime2(7),DirectorFee money,TotalItems money,Allowance money,Transport money,Entertrainment money,OtherAllowances money,GrossComissionDateFrom Datetime2(7),GrosscomissionDateto datetime2(7),GrossComission money,GrossComissionIndicator nvarchar(250),pension money,Gratuty money,Noticepay money,others money,CompensationLossOfOfiiceIndicator nvarchar(250),CompensationLossOrOffice money,ApprovalObtainedFromIrAs nvarchar(250),DateOfApproval Datetime2(7),RetirementBenifits nvarchar(250),AmountAccuredupto money,AmountOccurdFrom money,Contribution nvarchar(250),Contributionofcpf nvarchar(250),IR8sIndicator nvarchar(250),GainandProfits1 nvarchar(250),GainandProfits2 nvarchar(250),Valueofbenificts nvarchar(250),Appendix8AIndicator nvarchar(250),Remission money,AmountOfIncome money,EmployeeIncome nvarchar(250),AmountOfIncomeTax money,FixedAmount money,section45 nvarchar(250),EmployeesCompulsory money,DesignationsPension money,Donations money,contributions money,LifeInsurance money)



Declare @RecordNumber int,@IdType nvarchar(250),@IdNo nvarchar(250),@FullNameOfEmployee nvarchar(max),@Citizenship nvarchar(250),@Sex nvarchar(250),@DateOfBirth Datetime2(7),@Designation nvarchar(250),@ResidentalAdress nvarchar(max),@Adress nvarchar(max),@PostalCode nvarchar(250),@Country nvarchar(250),@DateOfCommencement DateTime2(7),@DateOfCessation Datetime2(7),@BankSalaryisCreditedTo nvarchar(250),@GrossSalary money,@DateOfBonusPaid Datetime2(7),@Bonus money,@DateOfDirectorFeeApproved Datetime2(7),@DirectorFee money,@TotalItems money,@Allowance money,@Transport money,@Entertrainment money,@OtherAllowances money,@GrossComissionDateFrom Datetime2(7),@GrosscomissionDateto datetime2(7),@GrossComission money,@GrossComissionIndicator nvarchar(250),@pension money,@Gratuty money,@Noticepay money,@others money,@CompensationLossOfOfiiceIndicator nvarchar(250),@CompensationLossOrOffice money,@ApprovalObtainedFromIrAs nvarchar(250),@DateOfApproval Datetime2(7),@RetirementBenifits nvarchar(250),@AmountAccuredupto money,@AmountOccurdFrom money,@Contribution nvarchar(250),@Contributionofcpf nvarchar(250),@IR8sIndicator nvarchar(250),@GainandProfits1 nvarchar(250),@GainandProfits2 nvarchar(250),@Valueofbenificts nvarchar(250),@Appendix8AIndicator nvarchar(250),@Remission money,@AmountOfIncome money,@EmployeeIncome nvarchar(250),@AmountOfIncomeTax money,@FixedAmount money,@section45 nvarchar(250),@EmployeesCompulsory money,@DesignationsPension money,@Donations money,@contributions money,@LifeInsurance money


 create table #Employee(S_No INT Identity(1, 1), Id uniqueIdentifier)

	  insert into #Employee 
	  select Id from common.Employee (NOLOCK) where (CAST (Id  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@EmployeeIds,',')))

	  Declare @Employeecount int
	  Declare @Recount int
	  set @Employeecount = (select count(*) from #Employee)
	  set @Recount=1
	  while @Employeecount>=@Recount
	  begin

set @IdType = (select IdType from common.Employee (NOLOCK) where id =(select Id from #Employee where S_No=@Recount))

set @IdNo = (select IdNo from common.Employee (NOLOCK) where id =(select Id from #Employee where S_No=@Recount))

set @FullNameOfEmployee = (select FirstName from common.Employee (NOLOCK) where id =(select Id from #Employee where S_No=@Recount))

set @Citizenship = (select Nationality from common.Employee (NOLOCK) where id =(select Id from #Employee where S_No=@Recount))

set @Sex = (select Gender from common.Employee (NOLOCK) where id =(select Id from #Employee where S_No=@Recount))

set @DateOfBirth = (select DOB from common.Employee (NOLOCK) where id =(select Id from #Employee where S_No=@Recount))

set @Designation = (select Designation from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)

set @ResidentalAdress = (select (ab.BlockHouseNo+' '+ab.Street +' '+ab.UnitNo + ' '+ab.Country) from common.Addresses as ad (NOLOCK) join common.AddressBook as ab (NOLOCK) on ad.AddressBookId = ab.Id where AddTypeId = (select Id from #Employee where S_No=@Recount) and ad.AddSectionType='Residential Address')

set @Adress = (select AddressOfTheEmployeer from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)

set @BankSalaryisCreditedTo = (select Top 1 BankName  from Hr.EmployeeBankDetails (NOLOCK) where employeeId=(select Id from #Employee where S_No=@Recount))

set @DateOfCessation = (select EndDate from Hr.Employment (NOLOCK) where EmployeeId=(select Id from #Employee where S_No=@Recount))


set @DateOfCommencement = (select StartDate from Hr.Employment (NOLOCK) where EmployeeId=(select Id from #Employee where S_No=@Recount))

set @PostalCode = (select ab.PostalCode from common.Addresses as ad (NOLOCK) join common.AddressBook as ab (NOLOCK) on ad.AddressBookId = ab.Id where AddTypeId = (select Id from #Employee where S_No=@Recount) and ad.AddSectionType='Residential Address')

set @Country = (select Nationality from common.Employee (NOLOCK) where id =(select Id from #Employee where S_No=@Recount))
if(@Country='Singapore Citizen')
begin
set @Country = 'Singapore'
end

set @GrossSalary = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Income (a): Gross Salary','Income (a): Fees','Income (a): Leave Pay','Income (a): Overtime Pay') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)

set @Bonus = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Income (b): Bonus') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)
set @DirectorFee = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Income (c): Directors Fee') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)

set @DateOfBonusPaid = (select BonusDate from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)

set @TotalItems = isnull(@GrossSalary,0)+isnull(@Bonus,0)

set @DateOfDirectorFeeApproved = (select ApprovedatTheCompanyAgmEgm from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)


set @Transport = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Income (d1i): Transport') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)

set @Entertrainment = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Income (d1ii): Entertainment') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)

set @OtherAllowances = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Income (d1iii): Other Allowance') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)

set @GrossComissionDateFrom = (select GrossCommissionPeriodFrom from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)

set @GrosscomissionDateto = (select GrossCommissionPeriodTo from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)

set @GrossComission = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Income (d2): Commission') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)

set @GrossComissionIndicator = (select GrossCommissionIndicator from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)

set @pension = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Income (d3): Pension') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)

set @Gratuty = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Income (d4): Gratuity') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)

set @Noticepay = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Income (d4): Notice Pay') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)

set @others = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Income (d4): Lump Sum Payment (Others)') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)

set @CompensationLossOrOffice = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Income (d4): Compensation') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)
 if(@CompensationLossOrOffice!=0)
begin
set @CompensationLossOfOfiiceIndicator ='Yes'
end

set @DateOfApproval = (select DateOfApproval from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)

set @AmountAccuredupto = (select RBIAmountAccuredTo from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)

set @AmountOccurdFrom = (select RBIAmountAccuredFrom from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)

set @Contribution = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Deduction: MBF Contribution') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)

set @Donations = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Deduction: Agency Fund & Other Tax-Exempt Donations') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)


set @IR8sIndicator = (select ApprovalObtainedForIRAS from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)


set @Valueofbenificts = (select ValuesOfBenifits from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)


set @FixedAmount = (select IncomeOthersPaidbyemployee from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)

set @EmployeesCompulsory = (select sum(ps.Amount) from hr.Payroll as p (NOLOCK) join hr.PayrollDetails as pd (NOLOCK) on p.id=pd.MasterId join hr.PayrollSplit as ps (NOLOCK) on pd.Id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId=pc.Id where pc.TaxClassification in ('Deduction: Employee CPF') and pd.employeeId=(select Id from #Employee where S_No=@Recount) and p.PayrollStatus='Processed' and p.year=@year and p.CompanyId=@subCompanyId)


set @LifeInsurance = (select LifeInsurence from HR.IR8AHRSetUp (NOLOCK) where type='IR8A' and EmployeeId=(select Id from #Employee where S_No=@Recount) and CompanyId=@subCompanyId and Year = @year)


--Deduction: Employee CPF
set @EmployeeIncome='No, tax is NOT borne by employer'
set @section45 = 'No'

if(@Valueofbenificts is not null and @Valueofbenificts!='' )
begin
set @Appendix8AIndicator ='Yes'
end


insert into @IR8A values(@Recount,@IdType,@IdNo ,@FullNameOfEmployee ,@Citizenship ,@Sex,@DateOfBirth,@Designation,@ResidentalAdress ,@Adress ,@PostalCode ,@Country ,@DateOfCommencement ,@DateOfCessation,null ,@BankSalaryisCreditedTo ,@GrossSalary ,@DateOfBonusPaid ,@Bonus ,@DateOfDirectorFeeApproved ,@DirectorFee ,@TotalItems ,@Allowance ,@Transport ,@Entertrainment ,@OtherAllowances ,@GrossComissionDateFrom ,@GrosscomissionDateto ,@GrossComission ,@GrossComissionIndicator ,@pension ,@Gratuty ,@Noticepay ,@others ,@CompensationLossOfOfiiceIndicator ,@CompensationLossOrOffice,@ApprovalObtainedFromIrAs ,@DateOfApproval ,@RetirementBenifits,@AmountAccuredupto ,@AmountOccurdFrom ,@Contribution ,@Contributionofcpf ,@IR8sIndicator ,@GainandProfits1 ,@GainandProfits2 ,@Valueofbenificts ,@Appendix8AIndicator ,@Remission ,@AmountOfIncome ,@EmployeeIncome ,@AmountOfIncomeTax ,@FixedAmount,@section45 ,@EmployeesCompulsory ,@DesignationsPension ,@Donations ,@contributions ,@LifeInsurance)
set @Recount  = @Recount+1
end

select RecordNo as 'Record No.',IDType as '*ID Type <Select>',IDNo as '*ID No.',FullNameofEmployeeasperNRIC as '*Full Name of Employee as per NRIC/FIN' ,Citizenship as '*Citizenship <Select>',Sex as '*Sex <Select>',DateOfBirth as '*Date of Birth
(DD/MM/YYYY)',Designation,ResidentalAdress,Adress as 'Adress Details',PostalCode ,Country as 'Country/Region',DateOfCommencement,DateOfCessation,OverSeas as 'DateOfCessation/posted overseas',BankSalaryisCreditedTo,Grosssalary as 'a) Gross Salary',DateOfBonusPaid as 'b(i) Date of bonus paid
(DD/MM/YYYY)',Bonus as 'b(ii) Bonus',DateOfDirectorFeeApproved as 'c(i) Date of directors fee approved
(DD/MM/YYYY)',DirectorFee as 'c(ii) Directors fee',TotalItems as 'Total of items d1 to d9 (excluding 4ii & 8ii)',Allowance as 'd1) Allowances
<Amount is automatically computed after record import to online application>',Transport as 'd1(i) Transport',Entertrainment as 'd1(ii) Entertainment',OtherAllowances as 'd1(iii) Other Allowances',GrossComissionDateFrom as 'd2(i) Gross Commission date from 
(DD/MM/YYYY)',GrosscomissionDateto as 'd2(ii) Gross Commission date to
(DD/MM/YYYY)',GrossComission as 'd2(iii) Gross Commission',GrossComissionIndicator as 'd2(iv) Gross Commission Indicator <Select>',pension as 'd3) Pension',Gratuty as 'd4.1(i) Gratuity/ Notice Pay/ Ex-gratia payment/ Others indicator',Noticepay as 'd4.1(ii) Gratuity/ Notice Pay/ Ex-gratia payment/ Others',CompensationLossOfOfiiceIndicator as 'd4.2(i) Compensation for loss of office indicator',CompensationLossOrOffice as 'd4.2(ii) Compensation for loss of office', ApprovalObtainedFromIrAs as 'd4.2(iii) Approval obtained from IRAS <Select>',DateOfApproval as 'd4.2(iv) Date of approval (DD/MM/YYYY)',RetirementBenifits as 'd5(i) Retirement benefits including gratuities/pension/commutation of pension/ lump sum payments',AmountAccuredupto as 'd5(ii) Amount accrued up to 31/12/1992',AmountOccurdFrom as 'd5(iii) Amount accrued from 01/01/1993',Contribution as '6) Contributions made by employer to any Pension/Provident Fund constituted outside Singapore without tax concession',Contributionofcpf as 'd7(i) Excess / voluntary contribution to CPF by employer<This item to be entered after record import into online form>',IR8sIndicator as 'd7(ii) Form IR8S indicator<This item to be entered after record import into online form>',GainandProfits1 as 'd8(i) Gains and profits from share options for Sec.10(1)(b)<This item to be entered after record import into online form>',GainandProfits2 as 'd8(ii) Gains and profits from share options for Sec.10(1)(g)<This item to be entered after record import into online form>',Valueofbenificts as 'd9(i) Value of benefits-in-kind<This item to be entered after record import into online form>',Appendix8AIndicator as 'd9(ii) Appendix 8A indicator<This item to be entered after record import into online form>',Remission as 'e(i) Remission/ Overseas Posting/ Exempt Indicator<Select from dropdown>',AmountOfIncome as 'e(ii) Amount of income for the Remission/ Overseas Posting/ Exempt Indicator selected',EmployeeIncome as 'f) Employees income tax borne by employer?<Select>',AmountOfIncomeTax as 'f(i) Amount of income for which tax is borne by employer',FixedAmount as 'f(ii) Fixed amount of tax for which tax is borne by employee',section45 as 'g) Section 45 (applicable to non-resident director) <Select>', EmployeesCompulsory as 'Employees compulsory contribution',DesignationsPension as 'Designated Pension or Provident Fund Name e.g. Central Provident Fund',Donations as 'DONATIONS deducted from salaries for Yayasan MendakiFund/Community Chest of Singapore/SINDA/CDAC/ECF/Other tax exempt donations',contributions as 'CONTRIBUTIONS deducted from salaries toMosque Building Fund',LifeInsurance as 'LIFE INSURANCE PREMIUMS deducted from salaries' from @IR8A

end

   
GO
