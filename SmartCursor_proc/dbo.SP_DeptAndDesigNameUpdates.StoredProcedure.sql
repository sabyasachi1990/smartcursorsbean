USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_DeptAndDesigNameUpdates]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DeptAndDesigNameUpdates] (@Id UNIQUEIDENTIFIER, @IsLeave BIT, @DepartmentId UNIQUEIDENTIFIER, @DesignationId UNIQUEIDENTIFIER, @IsEmployee BIT, @IsCalculate BIT)
AS
BEGIN --s1	
	BEGIN TRANSACTION --s2

	BEGIN TRY --s3
		DECLARE @DeptName NVARCHAR(500)
		DECLARE @DesigName NVARCHAR(500)
		DECLARE @DeptCode NVARCHAR(500)
		DECLARE @DesigCode NVARCHAR(500)
		


		--Declare @ApprovedAmount Money 
		--Declare @TotalBaseAmount Money
		SELECT @DeptName = Dept.[Name], @DesigName = desig.[Name], @DeptCode = Dept.[Code], @DesigCode = desig.[Code]
		FROM [Common].[Department] Dept (NOLOCK)
		JOIN [Common].[DepartmentDesignation] Desig (NOLOCK) ON dept.id = Desig.[DepartmentId]
		WHERE dept.id = @DepartmentId AND Desig.id = @DesignationId

		IF (@IsLeave = 0 AND @IsEmployee = 0 AND @IsCalculate = 0)
		BEGIN
			UPDATE [HR].[EmployeeClaim1]
			SET [DepartmentName] = @DeptName, [DesignationName] = @DesigName
			WHERE id = @Id

			UPDATE emp
			SET emp.[TotalApprovedAmount] = a.TotalApprovedAmount, emp.[TotalBaseAmount] = a.TotalBaseAmount
			FROM [HR].[EmployeeClaim1] emp (NOLOCK)
			JOIN (
				SELECT sum([ApprovedAmount]) AS TotalApprovedAmount, sum([BaseAmount]) AS TotalBaseAmount, detail.[EmployeeClaimId] AS masterId
				FROM [HR].[EmployeeClaim1] claim (NOLOCK)
				INNER JOIN [HR].[EmployeeClaimDetail] detail (NOLOCK) ON claim.Id = detail.[EmployeeClaimId]
				WHERE detail.[ApprovedAmount] IS NOT NULL AND detail.[BaseAmount] IS NOT NULL AND (detail.[IsSplit] = 0 OR detail.[IsSplit] IS NULL) AND claim.Id = @Id
				GROUP BY detail.[EmployeeClaimId]
				) a ON a.masterId = emp.Id AND emp.Id = @Id
		END
		ELSE IF (@IsLeave = 1 AND @IsEmployee = 0)
		BEGIN
			UPDATE [HR].[LeaveApplication]
			SET [DepartmentName] = @DeptName, [DesignationName] = @DesigName
			WHERE id = @Id
		END
		ELSE IF (@IsEmployee = 1)
		BEGIN
			UPDATE [Common].[Employee]
			SET [DepartmentCode] = @DeptCode, [DesignationCode] = @DesigCode,[DepartmentName]=@DeptName,[DesignationName]=@DesigName
			WHERE id = @Id
		END
		ELSE IF (@IsCalculate = 1)
		BEGIN
			UPDATE emp
			SET emp.[TotalApprovedAmount] = a.TotalApprovedAmount, emp.[TotalBaseAmount] = a.TotalBaseAmount
			FROM [HR].[EmployeeClaim1] emp (NOLOCK)
			JOIN (
				SELECT sum([ApprovedAmount]) AS TotalApprovedAmount, sum([BaseAmount]) AS TotalBaseAmount, detail.[EmployeeClaimId] AS masterId
				FROM [HR].[EmployeeClaim1] claim (NOLOCK)
				INNER JOIN [HR].[EmployeeClaimDetail] detail (NOLOCK) ON claim.Id = detail.[EmployeeClaimId]
				WHERE detail.[ApprovedAmount] IS NOT NULL AND detail.[BaseAmount] IS NOT NULL AND (detail.[IsSplit] = 0 OR detail.[IsSplit] IS NULL) AND claim.Id = @Id
				GROUP BY detail.[EmployeeClaimId]
				) a ON a.masterId = emp.Id AND emp.Id = @Id
		END

		COMMIT TRANSACTION --s2
	END TRY --s3

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH
END
GO
