USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[AllEmployeeWageCalculations]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AllEmployeeWageCalculations] (@PayrollStartDate DATETIME2(7), @PayrollId UNIQUEIDENTIFIER, @CompanyId BIGINT,@PayrollEndDate DATETIME2(7))
AS
BEGIN
	BEGIN TRANSACTION --1

	BEGIN TRY --2
		Declare
		@Count INT, 
		@TotalCount INT,
		@EmployeeId UNIQUEIDENTIFIER, 
		@OrdinaryWage MONEY =0 ,
		@AdditionalWage MONEY =0 ,
		@SDlWage MONEY =0,
		@SPRGranted datetime2(7),
		@DiffDays decimal (18,2),
		@BasicPay Money =0,
		@OneDaySalary Money =0,
		@SPROWWage money =0,
		@PaycomponentId Uniqueidentifier,
		@WorkProfileId Uniqueidentifier,
		@EffectiveFrom datetime2(7),
		@SPRBasicPay money
		SET @Count = 1  
		CREATE TABLE #EmployeeData (S_No INT Identity(1, 1),EmployeeId UniqueIdentifier,Name nvarchar(250),Type nvarchar(250),WageType nvarchar(250),IsCPF bit,IsSDL bit, Amount Money)

		INSERT INTO #EmployeeData select pd.EmployeeId,pc.name,pc.Type,pc.WageType,pc.IsCPF,pc.IsSDL,ISNULL(ps.Amount,0) from hr.PayrollDetails as pd (NOLOCK) join hr.PayrollSplit as ps (NOLOCK) on pd.id=ps.PayrollDetailId join hr.PayComponent as pc (NOLOCK) on ps.PayComponentId = pc.id where  pd.masterid=@PayrollId and  (PC.IsStatutoryComponent  is null or pc.IsStatutoryComponent = 0)

		CREATE TABLE #Employees (S_No INT Identity(1, 1),EmployeeId UniqueIdentifier,BasicPay Money,OneDaySalary Money,SPRGranted datetime2(7),WorkProfileId uniqueidentifier,EmploymentStartDate datetime2(7),EffectiveFrom datetime2(7),SPRBasicPay money)

		INSERT INTO #Employees select PD.EmployeeId,ISNULL(PD.BasicPay,0),ISNULL(PD.OneDaySalary,0),PD.SPRGranted,PD.WorkProfileId,PD.EmploymentStartDate,PD.EffectiveFrom,PD.SPRBasicPay from hr.PayrollDetails PD (NOLOCK) where  masterid=@PayrollId 

		SET @TotalCount = (	SELECT COUNT(S_No)	FROM #Employees)

		WHILE (@TotalCount >=@Count )
		BEGIN	--3		
			print 'Entered into loop'
			Set @OrdinaryWage=0
			Set @AdditionalWage=0
			set @SDlWage=0
			set @SPROWWage=0
			set @SPRBasicPay=0
			select @EmployeeId= EmployeeId,@BasicPay= BasicPay,@OneDaySalary=OneDaySalary,@SPRGranted=SPRGranted,@WorkProfileId=WorkProfileId ,@EffectiveFrom=EffectiveFrom,@SPRBasicPay=SPRBasicPay from #Employees where S_No=@Count 
    		set @OrdinaryWage= ( select sum( ISNULL( amount,0)) from #EmployeeData where EmployeeId=@EmployeeId and WageType = 'Ordinary (OW)' and IsCPF = 1 )
    		select @AdditionalWage= sum( ISNULL( amount,0)) from #EmployeeData where EmployeeId=@EmployeeId and  WageType = 'Additional (AW)' and IsCPF = 1  
    		set @SDlWage= ( select sum(ISNULL( amount,0)) from #EmployeeData where EmployeeId=@EmployeeId and IsSDL = 1 )
			if(@SPRGranted is not null and MONTH(@SPRGranted)=MONTH(@PayrollStartDate) and YEAR(@SPRGranted) = YEAR(@PayrollStartDate))
			Begin
				set @SPROWWage=@ordinaryWage-@BasicPay
				--set @SPRGranted= (case when @SPRGranted <=@EffectiveFrom then @EffectiveFrom else @SPRGranted end)
				--set @DiffDays=(SELECT dbo.HR_GetTotalDays_Payroll(@CompanyId,@EmployeeId,@SPRGranted,@PayrollEndDate,@WorkProfileId))
				--set @SPRBasicPay=convert(decimal, (CONVERT(float, @OneDaySalary)*@DiffDays))
				--set @SPRBasicPay=(@OneDaySalary*@DiffDays)
				--set @SPROWWage =(@SPROWWage+convert(decimal, (CONVERT(float, @OneDaySalary)*@DiffDays)))
				set @SPROWWage =(@SPROWWage+ @SPRBasicPay)
			End
			print 'Employeeid :' print @EmployeeId
			print 'OrdinaryWage :' print @OrdinaryWage
			print 'AdditionalWage :' print @AdditionalWage
			print 'SDLWage :' print @SDlWage
			print 'SPROWWage :' print @SPROWWage

			update hr.PayrollDetails set OrdinaryWage=ISNULL(@OrdinaryWage,0),AdditionalWage=ISNULL(@AdditionalWage,0),SDLWage=ISNULL(@SDlWage,0),SPROWWage=ISNULL(@SPROWWage,0),SPRBasicPay=@SPRBasicPay where EmployeeId=@EmployeeId and MasterId=@PayrollId
			 SET @Count = @Count + 1
			print 'Data updated'
		END --3

	IF OBJECT_ID(N'tempdb..#EmployeeData') IS NOT NULL
	BEGIN
		DROP TABLE #EmployeeData
	END
	IF OBJECT_ID(N'tempdb..#Employees') IS NOT NULL
	BEGIN
		DROP TABLE #Employees
	END


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
