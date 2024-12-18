USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[AllEmpPayComponentCalculations]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [dbo].[AllEmpPayComponentCalculations] 'dec5a924-82f4-44db-84d3-edf496d2a096',2058,'2022-12-01','2022-12-30'


CREATE PROCEDURE [dbo].[AllEmpPayComponentCalculations] (@PayrollId UNIQUEIDENTIFIER, @CompanyId INT, 
@PayrollStartDate DATETIME2(7) ,@PayrollEndDate DATETIME2(7))
AS  
BEGIN TRY -- 1  
 BEGIN TRANSACTION --2  
  
 DECLARE @earnings MONEY = 0, @reembursement MONEY = 0, @deductions MONEY = 0, @ExcludeFromGrossWageEarningAmt MONEY = 0, @ExcludeFromGrossWageDeductionAmt MONEY = 0, @EffectiveFrom DATE, @PayMethod NVARCHAR(100), @Amount MONEY = 0, @MasterId UNIQUEIDENTIFIER, @PayAmount MONEY = 0, @Percentage MONEY = 0, @PercentageAmount MONEY, @PayComponentName NVARCHAR(20), @PercentageComponent NVARCHAR(100), @payrollsplitAmount MONEY = 0, @payValue MONEY = 0, @GrossWage MONEY = 0, @EndDate DATETIME2(7), @IsExceedEmploymentEndDate BIT, @DeductionAmount MONEY = 0, @EarningsAmount MONEY = 0, @EmployeeId UNIQUEIDENTIFIER, @Count INT, @Count1 INT, @TotalCount INT, @TotalCount1 INT, @basicPay MONEY = 0, @juridiction NVARCHAR(100), @PayrollDetailId UNIQUEIDENTIFIER, @OneDayPay MONEY, @AnnualPTDBalance MONEY, @Type NVARCHAR(50), @Name NVARCHAR(50), @IsExcludeFromGrossWage BIT, @MaxCap MONEY = 0, @RecOrder int  
  
  declare @Nopayleavedays int 
  set @Nopayleavedays = null
 SET @Count = 1     
  -- select * from hr.paycomponentdetail  
      
  
 CREATE TABLE #PayComponent (S_No INT Identity(1, 1), Id UNIQUEIDENTIFIER, Name NVARCHAR(100), Type NVARCHAR(100), MaxCap MONEY, IsExcludeFromGrossWage BIT, RecOrder INT)  
  
 CREATE TABLE #PayComponentDetails (S_No INT Identity(1, 1), Id UNIQUEIDENTIFIER, MasterId UNIQUEIDENTIFIER, EmployeeId UNIQUEIDENTIFIER, Amount MONEY NULL, PayMethod NVARCHAR(50), Percentage MONEY, PercentageComponent NVARCHAR(50), EffectiveFrom DATETIME2(7), EffectiveTo DATETIME2(7))  
  
 --CREATE TABLE #PayComponentDetails1 (S_No INT Identity(1, 1), Id UNIQUEIDENTIFIER, MasterId UNIQUEIDENTIFIER, Amount MONEY NULL, PayMethod NVARCHAR(50), Percentage MONEY, PercentageComponent NVARCHAR(50), EffectiveFrom DATETIME2(7))  
  
 INSERT INTO #PayComponent SELECT Id, Name, Type, MaxCap, IsExcludeFromGrossWage, RecOrder FROM hr.paycomponent (NOLOCK) WHERE companyid = @CompanyId  
  
 CREATE TABLE #EmployeeData (S_No INT Identity(1, 1), PayrollMasterId UNIQUEIDENTIFIER, Employeeid UNIQUEIDENTIFIER, Id UNIQUEIDENTIFIER, BasicPay MONEY, OneDayPay MONEY, AnnualPTDBalance MONEY)  
  
 INSERT INTO #EmployeeData SELECT MasterId, pd.EmployeeId, pd.Id, BasicPay, OneDaySalary, e.AnnualPTDBalance FROM HR.PayrollDetails AS pd (NOLOCK) JOIN common.employee AS e (NOLOCK) ON pd.EmployeeId = e.Id WHERE MasterId = @PayrollId  
  
 SET @TotalCount = ( SELECT COUNT(S_No) FROM #EmployeeData)  
  
 WHILE (@TotalCount >= @Count)  
 BEGIN--3  
  print 'Entered into emp loop '   
  set @earnings  = 0  
   set @reembursement = 0  
   set @deductions  = 0  
   set @ExcludeFromGrossWageDeductionAmt=0  
   set @ExcludeFromGrossWageEarningAmt=0  
  SELECT @EmployeeId = EmployeeId, @basicPay = BasicPay, @PayrollDetailId = Id, @OneDayPay = OneDayPay, @AnnualPTDBalance = AnnualPTDBalance FROM #EmployeeData WHERE S_No = @Count  
    
  --DELETE FROM #PayComponentDetails  
  SET @PayComponentName = 'Basic Pay'  
  
  INSERT INTO #PayComponentDetails SELECT Id, masterid, employeeid, amount, PayMethod, Percentage, PercentageComponent, EffectiveFrom, EffectiveTo FROM hr.PayComponentDetail (NOLOCK) 
  WHERE EmployeeId = @EmployeeId and effectivefrom<=@PayrollStartDate and (effectiveTo is null or effectiveTo>=@PayrollStartDate) and Status =1 AND MasterId NOT IN (  
    SELECT id FROM #PayComponent WHERE Name = @PayComponentName)  
  
  --print '#PayComponentDetails'  
  --select * from #PayComponentDetails  
  
  --INSERT INTO #PayComponentDetails1 SELECT Id, MasterId, amount, PayMethod, Percentage, PercentageComponent, EffectiveFrom FROM #PayComponentDetails WHERE EmployeeId = @EmployeeId AND MasterId NOT IN (  
  --  SELECT id FROM #PayComponent WHERE Name = @PayComponentName)  
  
      --select * from #PayComponentDetails1  
  SET @Count1 = 1     
  SET @TotalCount1 = (SELECT COUNT(S_No) FROM #PayComponentDetails)  
  
  print @Count1  
  print @TotalCount1  
  
  WHILE (@TotalCount1 >= @Count1)  
  BEGIN --4  
  print 'entered into paycomponent loop '  
     
   SELECT @EffectiveFrom = EffectiveFrom, @PayMethod = PayMethod, @Amount = Amount, @MasterId = MasterId, @Percentage = Percentage, @PercentageComponent = PercentageComponent FROM #PayComponentDetails  where S_No=@Count1  
   select @Type = Type, @Name = Name, @IsExcludeFromGrossWage = IsExcludeFromGrossWage, @MaxCap = maxcap,@RecOrder=RecOrder FROM #paycomponent WHERE  id=@MasterId  
   print @MasterId  
   print @PayMethod  
   print @Type  
   print @Name  
   IF (@EffectiveFrom <= @PayrollStartDate)  
   BEGIN --5  
    IF (@PayMethod = 'Amount')  
    BEGIN --6  
     SET @PayAmount = @Amount  
  
     IF (@Name = 'Professional Tax')  
     BEGIN --7  
      IF (@basicPay * 12 > 200000)  
      BEGIN --8  
       SET @PayAmount = 200  
      END --8  
      ELSE  
      BEGIN --9  
       SET @PayAmount = 0;  
      END --9  
     END --7  
     print @PayAmount  
     IF (@Name = 'Leave Encashment')  
     BEGIN --10  
      IF (@AnnualPTDBalance <> NULL OR @AnnualPTDBalance > 0)  
      BEGIN --11  
       SET @PayAmount = @AnnualPTDBalance * @OneDayPay  
  
       UPDATE HR.PayrollDetails SET EnacashmentDays = @AnnualPTDBalance*-1 WHERE id = @PayrollDetailId  
      END --11  
      ELSE   
      BEGIN --12  
       SET @PayAmount = 0;  
      END --12  
      print @PayAmount  
     END --10  
     set @Amount=@PayAmount 
	 print 'Entered No Pay Leave'
	 if(@Name='No Pay Leave')
	 begin
	 print 'No Pay Leave'
	 declare @nopayleavecount int
	 set @nopayleavecount = (select sum(LA.Days) as Nopayleavecount from hr.LeaveApplication as lA (NOLOCK) where  LeaveStatus='Approved' and LeaveTypeId in (select Id from HR.LeaveType (NOLOCK) where Name='No Pay Leave' and CompanyId=@companyId) and CompanyId=@companyId  and la.EmployeeId=@employeeId and la.StartDateTime>=@PayrollStartDate and la.StartDateTime<=@PayrollEndDate and la.EndDateTime>=@PayrollStartDate and la.EndDateTime<=@PayrollEndDate and (select cast(ModifiedDate as date))<=@PayrollEndDate)
	 print @nopayleavecount
	 set @PayAmount = @nopayleavecount*@OneDayPay 
	 print @PayAmount
	 set @Nopayleavedays = @nopayleavecount
	 print @Nopayleavedays
	 UPDATE HR.PayrollDetails SET NopayLeaveFee = @PayAmount*-1 WHERE id = @PayrollDetailId  
	 end
   print 'End No Pay Leave'
     IF (@Name = 'Claim Reimbursements')  
     BEGIN --10  
     --set @ClaimIds=''  
       SET @PayAmount = (SELECT SUM(TotalApprovedAmount) FROM HR.EmployeeClaim1 (NOLOCK) WHERE EmployeId = @employeeId and ClaimStatus = 'Approved')  
       --Declare @payrollstatus nvarchar(max) = (select PayrollStatus from HR.Payroll where Id = @PayrollId)   
       --Declare @yearMonth nvarchar(max) = (select Convert(nvarchar(50),[Year])+'-'+Convert(nvarchar(50),[Month]) from HR.Payroll where Id = @PayrollId)  
       --UPDATE HR.EmployeeClaim1 SET PayrollId = @PayrollId, PayrollStatus = @payrollstatus,PayrollYearMonth = @yearMonth  WHERE EmployeId = @EmployeeId  
       Declare @ClaimIds NVARCHAR(MAX)  
         
       SELECT @ClaimIds = COALESCE(@claimIds + ',', '') + CAST(Id AS VARCHAR(MAX)) FROM HR.EmployeeClaim1 (NOLOCK) Where EmployeId = @EmployeeId and ClaimStatus = 'Approved' AND ParentCompanyId = @companyId  
       UPDATE HR.PayrollDetails SET ClaimIds = @ClaimIds,Reimbursement = @PayAmount where MasterId = @PayrollId and EmployeeId = @EmployeeId  
       UPDATE HR.PayrollSplit SET Amount = @PayAmount Where PayComponentId in (Select Id from HR.PayComponent (NOLOCK) Where [Name] = 'Claim Reimbursements' and companyId = @companyId)  
       IF(@PayAmount is Null)   
      BEGIN --12  
       SET @PayAmount = 0;  
      END --12  
      print @PayAmount  
     END --10  
     set @Amount=@PayAmount  
  
     IF (@Type = 'Earning')       
     BEGIN --13  
      print 'Entered into Earnings'  
      IF (@IsExcludeFromGrossWage = 1)  
      BEGIN --14  
       SET @ExcludeFromGrossWageEarningAmt = @ExcludeFromGrossWageEarningAmt + @Amount  
      END --14  
      ELSE  
      BEGIN --15  
       SET @earnings = @earnings + @Amount  
      END --15  
     END --13  
     print 'Ear:' print @earnings  
     IF (@Type = 'Deduction')  
     BEGIN --16  
      print 'Entered into Deduction'  
  
      IF @Amount > 0  
      BEGIN --17  
       SET @Amount = @Amount * - 1  
      END --17  
  
      IF (@IsExcludeFromGrossWage = 1)  
      BEGIN --18  
       SET @ExcludeFromGrossWageDeductionAmt = @ExcludeFromGrossWageDeductionAmt + @Amount;  
      END --18  
      ELSE  
      BEGIN --19  
       SET @deductions = (@deductions) + @Amount;  
      END --19  
      print 'print ded amt'   
      print @deductions  
     END --16  
  
     IF (@Type = 'Reimbursement')  
     BEGIN  
      print 'Entered into Reimbursement'  
      SET @reembursement = @reembursement + @Amount  
     END  
    END  
    ELSE IF (@PayMethod = 'Percentage')  
    BEGIN  
     print 'Entered into percentage'  
     IF ((SELECT PercentageComponent FROM #PayComponentDetails WHERE MasterId = @MasterId) = 'Basic Pay' OR ( SELECT PercentageComponent FROM #PayComponentDetails WHERE MasterId = @MasterId ) = 'Monthly CTC' )  
     BEGIN  
     print 'BP' print @basicPay print 'per' print @Percentage  
      IF (@basicPay > 0 AND @Percentage > 0)  
      BEGIN  
       SET @PercentageAmount = (@Percentage * @basicPay) / 100  
       print 'PA' print @PercentageAmount  
       print @MasterId  
       IF EXISTS (SELECT * FROM #PayComponent WHERE id = @MasterId AND MaxCap IS NOT NULL)         
       BEGIN  
        IF (@PercentageAmount > @MaxCap)  
        BEGIN  
         SET @PayAmount = @MaxCap  
        END  
        ELSE  
        BEGIN  
         SET @PayAmount = @PercentageAmount  
        END  
       END  
       ELSE  
       BEGIN  
        SET @PayAmount = @PercentageAmount  
       END  
       print @PayAmount print 'payamount'  
       IF (@Type = 'Earning')  
       BEGIN  
        print 'Entered into Earnings'  
        IF (@IsExcludeFromGrossWage = 1)  
        BEGIN  
         SET @ExcludeFromGrossWageEarningAmt = @ExcludeFromGrossWageEarningAmt + @PercentageAmount  
        END  
        ELSE  
        BEGIN  
         SET @earnings = @earnings + @PercentageAmount  
        END  
       END  
  
       IF (@Type = 'Deduction')  
       BEGIN  
        print 'Entered into Deductions'  
        IF @PercentageAmount > 0  
        BEGIN  
         SET @PercentageAmount = @PercentageAmount * - 1  
        END  
  
        IF (@IsExcludeFromGrossWage = 1)  
        BEGIN  
         SET @ExcludeFromGrossWageDeductionAmt = @ExcludeFromGrossWageDeductionAmt + @PercentageAmount;  
        END  
        ELSE  
        BEGIN  
         SET @deductions = (@deductions) + @PercentageAmount;  
        END  
       END  
  
       IF (@Type = 'Reimbursement')  
       BEGIN  
        print 'Entered into Reimbursment'  
        SET @reembursement = @reembursement + @PercentageAmount  
       END  
      END  
     END  
     ELSE  
     BEGIN  
      print @PercentageComponent   
      IF EXISTS ( SELECT * FROM #PayComponentDetails WHERE masterid IN ( SELECT id FROM #PayComponent WHERE name = @PercentageComponent ) )  
      BEGIN  
       IF EXISTS ( SELECT * FROM hr.PayrollSplit (NOLOCK) WHERE PayComponentId = ( SELECT MasterId FROM #PayComponentDetails WHERE masterid IN ( SELECT id FROM #PayComponent WHERE name =  @PercentageComponent ) ) )  
       BEGIN  
        SET @payrollsplitAmount = ( SELECT Amount FROM hr.PayrollSplit (NOLOCK) WHERE PayComponentId = ( SELECT MasterId FROM #PayComponentDetails WHERE masterid IN ( SELECT id FROM #PayComponent WHERE name = @PercentageComponent ) ) )  
  
        IF (@Percentage > 0 AND @payrollsplitAmount > 0)  
        BEGIN  
         SET @payValue = (@Percentage * @payrollsplitAmount) / 100  
  
         IF EXISTS (SELECT * FROM #PayComponent WHERE id = @MasterId AND MaxCap IS NOT NULL)  
         BEGIN  
          IF (@payValue > @MaxCap)  
          BEGIN  
           SET @payrollsplitAmount = @MaxCap  
          END  
          ELSE  
          BEGIN  
           SET @payrollsplitAmount = @payValue  
          END  
         END  
         ELSE  
         BEGIN  
          SET @payrollsplitAmount = @payValue  
         END  
  
         IF (@Type = 'Earning')  
         BEGIN  
          print 'Entered into Earnings'  
          IF (@IsExcludeFromGrossWage = 1)  
          BEGIN  
           SET @ExcludeFromGrossWageEarningAmt = @ExcludeFromGrossWageEarningAmt + @payValue  
          END  
          ELSE  
          BEGIN  
           SET @earnings = @earnings + @payValue  
          END  
         END  
  
         IF (@Type = 'Deduction')  
         BEGIN  
          print 'Entered into Deductions'  
          IF @payValue > 0  
          BEGIN  
           SET @payValue = @payValue * - 1  
          END  
  
          IF (@IsExcludeFromGrossWage = 1)  
          BEGIN  
           SET @ExcludeFromGrossWageDeductionAmt = @ExcludeFromGrossWageDeductionAmt + @payValue;  
          END  
          ELSE  
          BEGIN  
           SET @deductions = (@deductions) + @payValue;  
          END  
         END  
  
         IF (@Type = 'Reimbursement')  
         BEGIN  
          print 'Entered into Reimbusment'  
          SET @reembursement = @reembursement + @payValue  
         END  
        END  
       END  
      END  
     END  
    END  
    print 'payroll split insert started '  
    print @PayAmount print @Type  
    if(@Type='Deduction')  
    Begin  
     set @PayAmount=@PayAmount*-1  
     print @PayAmount  
     print @deductions  
    End  
      
  
    INSERT INTO hr.PayrollSplit (id, PayType, PayComponentId, PayrollDetailId, Amount, Recorder, IsTemporary,NoOfDays)  
    VALUES (newid(), @Type, @MasterId, @PayrollDetailId, @PayAmount, @RecOrder, 1,@Nopayleavedays)  
    print 'payroll split insert compaleted '  
    print 'pay component loop completed'  
   --TRUNCATE Table #PayComponentDetails1  
   SET @Count1 = @Count1 + 1  
   END  
     
  END --4  
  set @deductions=Isnull(@ExcludeFromGrossWageDeductionAmt ,0)+ @deductions  
  set @earnings=Isnull(@ExcludeFromGrossWageEarningAmt ,0)+ @earnings  
  PRINT @employeeid  
  PRINT 'earnings'  
  PRINT @earnings  
  PRINT 'deductions'  
  PRINT @deductions  
  PRINT @reembursement  
  
  UPDATE hr.PayrollDetails  
  SET Earnings = Isnull(@earnings,0), Deduction = ISNULL(@deductions,0), Reimbursement = @reembursement, ExcludeGrosswageEarningAmount = @ExcludeFromGrossWageEarningAmt, ExcludeGrosswageDeductionAmount = @ExcludeFromGrossWageDeductionAmt  
  WHERE EmployeeId = @EmployeeId AND MasterId = @PayrollId       
  TRUNCATE Table #PayComponentDetails  
  
  SET @Count = @Count + 1       
  --CONTINUE;  
 END--3  
  
 IF OBJECT_ID(N'tempdb..#EmployeeData') IS NOT NULL  
 BEGIN  
  DROP TABLE #EmployeeData  
 END  
  
 IF OBJECT_ID(N'tempdb..#PayComponent') IS NOT NULL  
 BEGIN  
  DROP TABLE #PayComponent  
 END  
  
 IF OBJECT_ID(N'tempdb..#PayComponentDetails') IS NOT NULL  
 BEGIN  
  DROP TABLE #PayComponentDetails  
 END  
  
 --IF OBJECT_ID(N'tempdb..#PayComponentDetails1') IS NOT NULL  
 --BEGIN  
 -- DROP TABLE #PayComponentDetails1  
 --END  
  
 COMMIT TRANSACTION--2  
END TRY--1  
  
BEGIN CATCH  
 ROLLBACK TRANSACTION  
  
 DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;  
  
 SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();  
  
 RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);  
END CATCH
GO
