USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[TempPayrollDataDumpImportPayroll]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create   PROCEDURE [dbo].[TempPayrollDataDumpImportPayroll] (@PayrollId UNIQUEIDENTIFIER, @CompanyId BIGINT, @PayrollStartDate DATETIME2(7), @SubCompanyId BIGINT, @PayrollEndDate DATETIME2(7))
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
	
	

print 'Employee Contribution update Started'
	set @StartTime= getdate()
	exec [dbo].[AllEmployeeContributionUpdate] @PayrollStartDate,  @PayrollId , @SubCompanyId 
	set @EndTime=getdate()
print  'Employee Contribution update   Ended'
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
		update HP set HP.AgencyFund=HAFD.Contribution from HR.PayrollDetails HP join HR.AgencyFund HAF on HP.AgencyFundId=HAF.Id join HR.AgencyFundDetail HAFD on HAF.Id=HAFD.AgencyFundId WHERE HP.MasterId=@PayrollId and convert(date,HAFD.EffectiveFrom) <= @PayrollStartDate AND (Convert(date,HAFD.EffectiveTo) >= @PayrollStartDate OR HAFD.EffectiveTo IS NULL) AND HAFD.STATUS = 1 and WageFrom<=(case when isnull(HP.SPROWWage,0)>0 then (ISNULL(HP.SPROWWage,0)+ISNULL(HP.AdditionalWage,0)) else (ISNULL(HP.OrdinaryWage,0)+ISNULL(HP.AdditionalWage,0)) end) and WageTo>=(case when isnull(HP.SPROWWage,0)>0 then (ISNULL(HP.SPROWWage,0)+ISNULL(HP.AdditionalWage,0)) else (ISNULL(HP.OrdinaryWage,0)+ISNULL(HP.AdditionalWage,0)) end) 
		
		select @PayComponentId=Id,@PayType=Type,@recorder=RecOrder from HR.PayComponent where CompanyId=@CompanyId and Name='Agency Fund & Other Tax-Exempt Donations'
		--insert into HR.PayrollSplit select NEWID(),Id,@PayComponentId,@PayType,AgencyFund,@recorder,1  from HR.PayrollDetails where MasterId=@PayrollId /*and AgencyFundId is not null */
	update PS set PS.Amount=pd.AgencyFund   from HR.PayrollSplit PS join HR.PayrollDetails PD on PS.PayrollDetailId=PD.Id where PD.MasterId=@PayrollId and PS.PayrollDetailId=@PayComponentId

set @EndTime=getdate()
print 'Employee AgencyFund Calculation Ended'
 set @diff=  DATEDIFF(ms , @StartTime, @EndTime)
 print @diff

print 'Employee CPF Calculation  Started'
	set @StartTime= getdate()
		EXEC [dbo].[AllEmployeeCPFCalculationsImport] 'SG', 0, @PayrollStartDate , @PayrollId ,@CompanyId ,@PayrollEndDate 
		set @EndTime=getdate()
print 'Employee CPF Calculation  Ended'

 set @diff=  DATEDIFF(ms , @StartTime, @EndTime)
 print @diff
print 'Employee AW CPF Calculation  Started'
	set @StartTime= getdate()
		EXEC [dbo].[AllEMPAWCPFCalculationsImport] 'SG', @SubCompanyId, @PayrollStartDate, @PayrollId,@CompanyId
		set @EndTime=getdate()
print 'Employee AW CPF Calculation  Ended'

 set @diff=  DATEDIFF(ms , @StartTime, @EndTime)
 print @diff
print 'Employee  SDL Calculation  Started'
	set @StartTime= getdate()
		EXEC [dbo].[AllEMPSDLCalculationImport] @PayrollId ,@PayrollStartDate ,@CompanyId 
		set @EndTime=getdate()
print 'Employee  SDL Calculation  Ended'

 set @diff=  DATEDIFF(ms , @StartTime, @EndTime)
 print @diff
	print 'Employee gross wage & net wage calc  started'
	set @StartTime= getdate()
		update [HR].[PayrollDetails] set GrossWage=(((ISNULL(BasicPay,0)+ISNULL(Earnings,0)+ISNULL(Deduction,0))-(ISNULL(ExcludeGrosswageEarningAmount,0)))-(isnull(ExcludeGrosswageDeductionAmount,0))),NetWage=((ISNULL(BasicPay,0)+isnull(Reimbursement,0)+ISNULL(Earnings,0)+ISNULL(Deduction,0))-(ISNULL(EmployeeCPF,0)+ISNULL(AgencyFund,0))) where MasterId = @PayrollId
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
