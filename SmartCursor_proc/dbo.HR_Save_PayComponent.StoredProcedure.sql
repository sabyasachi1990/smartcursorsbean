USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Save_PayComponent]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   proc [dbo].[HR_Save_PayComponent]
@payrollId Uniqueidentifier, @payrollStatus nvarchar(200),@payrollYearMonth nvarchar(200),@companyId bigint
AS
BEGIN
--Local Variables
DECLARE @tempEmp TABLE(S_No int identity(1,1),EmployeeId Uniqueidentifier)
DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @recCount INT
DECLARE @payrollDetailId UNIQUEIDENTIFIER
DECLARE @count INT =1 
DECLARE @employeeId Uniqueidentifier
	BEGIN TRY
	BEGIN TRANSACTION
		Insert into @tempEmp
		Select PD.EmployeeId from HR.Payroll P (NOLOCK) 
		Inner Join HR.PayrollDetails PD (NOLOCK) ON P.Id = PD.MasterId
		Inner Join HR.PayrollSplit PS (NOLOCK) ON PD.Id = PS.PayrollDetailId
		Inner Join HR.PayComponent PC (NOLOCK) ON PS.PayComponentId = PC.Id where PC.[Name] = 'Claim Reimbursements' AND P.Id = @payrollId

		Set @recCount = (Select Count(*) From @tempEmp)
		While(@recCount >= @Count)
		Begin
		IF Exists(Select * from @tempEmp)
		BEGIN
		Declare @ClaimIdss NVARCHAR(MAX)
		SET @EmployeeId = (Select EmployeeId from @tempEmp where S_No = @count)
		
		set @payrollDetailId = (Select ID from HR.PayrollDetails (NOLOCK) where MasterId = @payrollId AND EmployeeId = @EmployeeId)
		Update HR.EmployeeClaim1 Set PayrollId = @payrollId, PayrollStatus = @payrollStatus, PayrollYearMonth = @PayrollYearMonth Where EmployeId = @EmployeeId and ClaimStatus = 'Approved' AND ParentCompanyId = @companyId

		SELECT @ClaimIdss = COALESCE(@claimIdss + ',', '') + CAST(Id AS VARCHAR(MAX)) FROM HR.EmployeeClaim1 (NOLOCK) Where EmployeId = @EmployeeId and ClaimStatus = 'Approved' AND ParentCompanyId = @companyId

		Update HR.PayrollDetails Set ClaimIds = @ClaimIdss Where Id = @payrollDetailId

		END
	
		Set @Count = @Count + 1
		End

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
	END CATCH
END
GO
