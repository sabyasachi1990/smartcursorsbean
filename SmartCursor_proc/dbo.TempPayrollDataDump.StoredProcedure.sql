USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[TempPayrollDataDump]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec   [dbo].[TempPayrollDataDump] '7987c018-9efb-41e5-ac45-21280680a088',2058,'2022-11-01',2059,'2022-11-30'


CREATE PROCEDURE [dbo].[TempPayrollDataDump] (@PayrollId UNIQUEIDENTIFIER, @CompanyId BIGINT, @PayrollStartDate DATETIME2(7), @SubCompanyId BIGINT, @PayrollEndDate DATETIME2(7))  
AS  
BEGIN  
 BEGIN TRANSACTION --1  
  
 BEGIN TRY --2  
 --CREATE TABLE #PayComponents (L);  
 declare @StartTime datetime2(7)  
 declare @EndTime datetime2(7)  
 declare @diff decimal  
 declare @PayType NVARCHAR(20)  
 declare @recorder int   
 declare @PayComponentId uniqueidentifier  
 --Declare @EMPCPFId uniqueidentifier  
 --Declare @EMPrCPFId uniqueidentifier  
 print 'Employee Update started'  
 set @StartTime= getdate()  
  UPDATE HTPD  
  SET HTPD.SPRGranted = CE.DateOfSPRGranted, HTPD.SPRExpiry = CE.DateOfSPRExpiry, HTPD.IdType = CE.IdType, HTPD.EmploymentEndDate = EMP.EndDate, HTPD.AgencyFundId = (case when HEPS.AgencyFund='Not applicable'  then null when  HEPS.AgencyFund='Agency opt o
ut' and CONVERT(date,AgencyOptOutDate)<@PayrollStartDate then null else HEPS.AgencyFundIds end), HTPD.IsCPFContributionFull = HEPS.IsCPFContributionFull, HTPD.WorkProfileId = HEPS.WorkProfileId, HTPD.Age = (CASE WHEN ((Month(CE.DOB) < Month(@payrollStartDate)) OR (Month(CE.DOB) = Month(@payrollStartDate) AND Day(CE.DOB) < Day(@payrollStartDate))) THEN ((year(@payrollStartDate) - year(CE.DOB)) + 1) ELSE (year(@payrollStartDate) - year(CE.DOB)) END),HTPD.ContributionFor=(CASE WHEN CE.Idtype='NRIC(Pink)' then 'Singaporean' else null end ),HTPD.CPFExampted=HEPS.CPFExempted,HTPD.SDLExampted=HEPS.SDLExempted,HTPD.CreatedDate=@PayrollStartDate,HTPD.EmploymentStartDate=EMP.StartDate,HTPD.EffectiveFrom=(case when HTPD.IdType='NRIC(Blue)'and MONTH(SPRGranted) =MONTH(@PayrollStartDate) and year(SPRGranted) =year(@PayrollStartDate) and CONVERT(date,HTPD.EffectiveFrom)>=CONVERT(date,CE.DateOfSPRGranted) then CONVERT(date,HTPD.EffectiveFrom) else CONVERT(date,CE.DateOfSPRGranted) end )  
  FROM [HR].[PayrollDetails] HTPD (NOLOCK)
  JOIN Common.Employee CE (NOLOCK) ON HTPD.EmployeeId = CE.Id  
  JOIN HR.Employment EMP (NOLOCK) ON EMP.EmployeeId = CE.Id  
  JOIN HR.EmployeePayrollSetting HEPS (NOLOCK) ON HEPS.EmployeeId = CE.Id  
  WHERE CE.CompanyId = @CompanyId AND HTPD.MasterId = @PayrollId  
  set @EndTime=getdate()  
print 'Employee Update Ended'  
  
 set @diff=  DATEDIFF(ms , @StartTime, @EndTime)  
 print @diff  
  
print 'Employee Contribution update Started'  
 set @StartTime= getdate()  
 exec [dbo].[AllEmployeeContributionUpdate] @PayrollStartDate,  @PayrollId , @SubCompanyId   
 set @EndTime=getdate()  
print  'Employee Contribution update   Ended'  
  
set @diff=  DATEDIFF(ms , @StartTime, @EndTime)  
 print @diff  
  
print 'Employee Basic Pay update Started'  
 set @StartTime= getdate()  
 exec [HR_Payroll_Basic_Pay_Calculation] @PayrollId ,@PayrollStartDate ,@PayrollEndDate ,@CompanyId  
 set @EndTime=getdate()  
print 'Employee Basic Pay update   Ended'  
  
 set @diff=  DATEDIFF(ms , @StartTime, @EndTime)  
 print @diff  
  
print 'Employee PayComponent calculation Started'  
 set @StartTime= getdate()  
exec [dbo].[AllEmpPayComponentCalculations] @PayrollId , @CompanyId , @PayrollStartDate ,@PayrollEndDate  
set @EndTime=getdate()  
  
print 'Employee PayComponent calculation Ended'  
  
 set @diff=  DATEDIFF(ms , @StartTime, @EndTime)  
 print @diff  
  
print 'Employee Wage calculation Started'  
 set @StartTime= getdate()  
exec [dbo].[AllEmployeeWageCalculations] @PayrollStartDate , @PayrollId , @CompanyId ,@PayrollEndDate   
set @EndTime=getdate()  
  
print 'Employee Wage calculation Ended'  
  
 set @diff=  DATEDIFF(ms , @StartTime, @EndTime)  
 print @diff  
  
print 'Employee AgencyFund Started'  
 set @StartTime= getdate()  
  
  --EXEC [dbo].[HR_AllEMPAgencyFundcalculation]  @PayrollId, @PayrollStartDate,@CompanyId,@PayrollEndDate  
  --update HP set HP.AgencyFund=HAFD.Contribution from HR.PayrollDetails HP join HR.AgencyFund HAF on HP.AgencyFundId=HAF.Id join HR.AgencyFundDetail HAFD on HAF.Id=HAFD.AgencyFundId WHERE HP.MasterId=@PayrollId and convert(date,HAFD.EffectiveFrom) <= @PayrollStartDate AND (Convert(date,HAFD.EffectiveTo) >= @PayrollStartDate OR HAFD.EffectiveTo IS NULL) AND HAFD.STATUS = 1 and WageFrom<=(case when isnull(HP.SPROWWage,0)>0 then (ISNULL(HP.SPROWWage,0)+ISNULL(HP.AdditionalWage,0)) else (ISNULL(HP.OrdinaryWage,0)+ISNULL(HP.AdditionalWage,0)) end) and WageTo>=(case when isnull(HP.SPROWWage,0)>0 then (ISNULL(HP.SPROWWage,0)+ISNULL(HP.AdditionalWage,0)) else (ISNULL(HP.OrdinaryWage,0)+ISNULL(HP.AdditionalWage,0)) end)   
    exec [dbo].[HR_AgentFund_calculation] @PayrollId, @PayrollStartDate  
    
  select @PayComponentId=Id,@PayType=Type,@recorder=RecOrder from HR.PayComponent (NOLOCK) where CompanyId=@CompanyId and Name='Agency Fund & Other Tax-Exempt Donations'  
  insert into HR.PayrollSplit (Id,PayrollDetailId,PayComponentId,PayType,Amount,Recorder,IsTemporary) select NEWID(),Id,@PayComponentId,@PayType,AgencyFund,@recorder,1  from HR.PayrollDetails (NOLOCK) where MasterId=@PayrollId /*and AgencyFundId is not null */  
  
  
set @EndTime=getdate()  
print 'Employee AgencyFund Calculation Ended'  
 set @diff=  DATEDIFF(ms , @StartTime, @EndTime)  
 print @diff  
  
print 'Employee CPF Calculation  Started'  
 set @StartTime= getdate()  
  EXEC [dbo].[AllEmployeeCPFCalculations] 'SG', 0, @PayrollStartDate , @PayrollId ,@CompanyId ,@PayrollEndDate   
  set @EndTime=getdate()  
  
  select @PayComponentId=Id,@PayType=Type,@recorder=RecOrder from HR.PayComponent (NOLOCK) where CompanyId=@CompanyId and Name='Employer CPF'  
  insert into HR.PayrollSplit (Id,PayrollDetailId,PayComponentId,PayType,Amount,Recorder,IsTemporary) select NEWID(),Id,@PayComponentId,@PayType,0,@recorder,1  from HR.PayrollDetails (NOLOCK) where MasterId=@PayrollId and CPFExampted=1  
  
  
  select @PayComponentId=Id,@PayType=Type,@recorder=RecOrder from HR.PayComponent (NOLOCK) where CompanyId=@CompanyId and Name='Employee CPF'  
  insert into HR.PayrollSplit (Id,PayrollDetailId,PayComponentId,PayType,Amount,Recorder,IsTemporary) select NEWID(),Id,@PayComponentId,@PayType,0,@recorder,1  from HR.PayrollDetails (NOLOCK) where MasterId=@PayrollId and CPFExampted=1  
  
print 'Employee CPF Calculation  Ended'  
  
 set @diff=  DATEDIFF(ms , @StartTime, @EndTime)  
 print @diff  
print 'Employee AW CPF Calculation  Started'  
 set @StartTime= getdate()  
  EXEC [dbo].[AllEMPAWCPFCalculations] 'SG', @SubCompanyId, @PayrollStartDate, @PayrollId,@CompanyId  
  set @EndTime=getdate()  
print 'Employee AW CPF Calculation  Ended'  
  
 set @diff=  DATEDIFF(ms , @StartTime, @EndTime)  
 print @diff  
print 'Employee  SDL Calculation  Started'  
 set @StartTime= getdate()  
  EXEC [dbo].[AllEMPSDLCalculation] @PayrollId ,@PayrollStartDate ,@CompanyId   
  set @EndTime=getdate()  
print 'Employee  SDL Calculation  Ended'  
  
 set @diff=  DATEDIFF(ms , @StartTime, @EndTime)  
 print @diff  
 print 'Employee gross wage & net wage calc  started'  
 set @StartTime= getdate()  
  update [HR].[PayrollDetails] set GrossWage=(((ISNULL(BasicPay,0)+ISNULL(Earnings,0)+ISNULL(Deduction,0))-(ISNULL(ExcludeGrosswageEarningAmount,0)))-(isnull(ExcludeGrosswageDeductionAmount,0))),NetWage=((ISNULL(BasicPay,0)+isnull(Reimbursement,0)+ISNULL(
Earnings,0)+ISNULL(Deduction,0))-(ISNULL(EmployeeCPF,0)+ISNULL(AgencyFund,0))) where MasterId = @PayrollId  
  set @EndTime=getdate()  
  
 print 'Employee gross wage & net wage calc  Ended'  
     
    set @diff=  DATEDIFF(ms , @StartTime, @EndTime)  
 print @diff  
  
  COMMIT TRANSACTION --1  
 END TRY --2  
  
 BEGIN CATCH  
  ROLLBACK TRANSACTION  
  
  DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;  
  
  SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();  
  
  RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);  
 END CATCH  
END
GO
