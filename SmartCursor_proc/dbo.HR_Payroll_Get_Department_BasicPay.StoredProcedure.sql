USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Payroll_Get_Department_BasicPay]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [HR_Payroll_Get_Department_BasicPay] '4995f07c-8bff-4c66-9248-ef6d56eca7b8','2021-01-01','2021-01-31'
CREATE proc [dbo].[HR_Payroll_Get_Department_BasicPay]
@payrollId UNIQUEIDENTIFIER,
@payrollStartDate DATETIME2,
@payrollEnddate DATETIME2
AS
BEGIN
--Local Variables
DECLARE @ErrorMessage NVARCHAR(4000)
CREATE TABLE #EmpDeptDtl (S_No INT identity(1, 1), EmpDeptId UNIQUEIDENTIFIER,EmployeeId Uniqueidentifier)
CREATE TABLE #TempEmployeeDepartment (Id UNIQUEIDENTIFIER, EmployeeId UNIQUEIDENTIFIER, DepartmentId UNIQUEIDENTIFIER, DepartmentDesignationId UNIQUEIDENTIFIER, Comments VARCHAR(100), EffectiveFrom DATETIME2, BasicPay MONEY, EndDate DATETIME2, [Level] VARCHAR(50), EffectiveTo DATETIME2, CompanyId BIGINT, IsPayrollRun BIT)
DECLARE @Count INT
DECLARE @RecCount INT
DECLARE @count1 int =1
Declare @recCount1 int
DECLARE @empDeptId UNIQUEIDENTIFIER
DECLARE @deptEffectiveTo DATETIME2
DECLARE @deptEffectiveFrom DATETIME2
DECLARE @employeeId UNIQUEIDENTIFIER
CREATE TABLE #GetEmployee (S_No int identity(1,1),EmployeeId UNIQUEIDENTIFIER)
	BEGIN TRY
	BEGIN TRANSACTION
	
	INSERT INTO #GetEmployee
		SELECT EmployeeId FROM HR.PAYROLLDETAILS (NOLOCK) WHERE MASTERID = @payrollId
		SET @RecCount1 = (Select Count(*) FROM #GetEmployee)
		
		While @RecCount1 >= @count1
		BEGIN
		SET @Count = 1
		SET @employeeId = (SELECT EmployeeId FROM #GetEmployee WHERE S_No = @count1)
		IF ((SELECT COUNT(Id) FROM HR.EmployeeDepartment (NOLOCK) WHERE EmployeeId = @EmployeeId ) > 0 )
				BEGIN
					
					INSERT INTO #EmpDeptDtl
					SELECT ID,@employeeId
					FROM HR.EmployeeDepartment (NOLOCK)
					WHERE EmployeeId = @EmployeeId
					
					SET @RecCount = (
							SELECT COUNT(*)
							FROM #EmpDeptDtl
							WHERE EmployeeId = @EmployeeId
							)
					--Insert into @empId
					--	Select @employeeId,@Count,@RecCount
					--Select * from @empId
					WHILE ( @RecCount >= @Count)
					BEGIN
						SET @empDeptId = (
								SELECT EmpdeptId
								FROM #EmpDeptDtl
								WHERE S_No = @Count
								)
						IF EXISTS (
								SELECT EffectiveTo
								FROM HR.EmployeeDepartment (NOLOCK)
								WHERE Id = @empDeptId
								)
						BEGIN

						Select @deptEffectiveFrom = EffectiveFrom, @deptEffectiveTo = EffectiveTo FROM HR.EmployeeDepartment (NOLOCK) WHERE Id = @empDeptId
						IF ((CONVERT(DATE, @payrollStartDate) < @deptEffectiveTo) AND (@deptEffectiveFrom < CONVERT(DATE, @payrollEnddate)))
							BEGIN
								INSERT INTO #TempEmployeeDepartment
								SELECT Id, EmployeeId, DepartmentId, DepartmentDesignationId, Comments, EffectiveFrom, BasicPay, EndDate, [Level], EffectiveTo, CompanyId, IsPayrollRun
								FROM HR.EmployeeDepartment (NOLOCK)
								WHERE Id = @empDeptId
							END
							ELSE
							BEGIN
								IF ((CONVERT(DATE, @payrollStartDate) < = @deptEffectiveFrom) AND (CONVERT(DATE, @payrollEnddate) >= @deptEffectiveTo))
								BEGIN
									INSERT INTO #TempEmployeeDepartment
									SELECT Id, EmployeeId, DepartmentId, DepartmentDesignationId, Comments, EffectiveFrom, BasicPay, EndDate, [Level], EffectiveTo, CompanyId, IsPayrollRun
									FROM HR.EmployeeDepartment (NOLOCK)
									WHERE Id = @empDeptId
								END
							END
						END
						IF (
								(SELECT EffectiveTo
								FROM HR.EmployeeDepartment (NOLOCK)
								WHERE Id = @empDeptId) IS NULL
								)
						BEGIN
							
							IF ((@deptEffectiveFrom >= CONVERT(DATE, @payrollStartDate)) AND (@deptEffectiveFrom <= CONVERT(DATE, @payrollEnddate)))
							BEGIN
								INSERT INTO #TempEmployeeDepartment
								SELECT Id, EmployeeId, DepartmentId, DepartmentDesignationId, Comments, EffectiveFrom, BasicPay, EndDate, [Level], EffectiveTo, CompanyId, IsPayrollRun
								FROM HR.EmployeeDepartment (NOLOCK)
								WHERE Id = @empDeptId
							END
							ELSE 
							BEGIN
								IF((@deptEffectiveFrom <= CONVERT(DATE, @payrollStartDate)))
							BEGIN
								INSERT INTO #TempEmployeeDepartment
								SELECT Id, EmployeeId, DepartmentId, DepartmentDesignationId, Comments, EffectiveFrom, BasicPay, EndDate, [Level], EffectiveTo, CompanyId, IsPayrollRun
								FROM HR.EmployeeDepartment (NOLOCK)
								WHERE Id = @empDeptId 
							END
							END
						END
						SET @Count = @Count + 1
					END
					TRUNCATE TABLE #EmpDeptDtl
				END

				Set @count1 = @count1+1
		END
		
	SELECT * FROM #TempEmployeeDepartment
	DROP TABLE #GetEmployee
	DROP TABLE #TempEmployeeDepartment
	DROP TABLE #EmpDeptDtl
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
	END CATCH
END
GO
