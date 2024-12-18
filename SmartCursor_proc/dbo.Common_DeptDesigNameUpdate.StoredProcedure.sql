USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_DeptDesigNameUpdate]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Common_DeptDesigNameUpdate] (@Id UNIQUEIDENTIFIER)
AS
BEGIN --m1
	BEGIN TRANSACTION --m2

	BEGIN TRY --m3
		UPDATE CE
		SET CE.[DepartmentCode] = Dept.[Code]
		FROM [Common].[Employee] CE
		JOIN [Common].[Department] Dept ON CE.[DepartmentId] = Dept.Id
		WHERE Dept.Id = @Id

		UPDATE CE
		SET CE.[DesignationCode] = Desig.[Code]
		FROM [Common].[Employee] CE
		JOIN [Common].[DepartmentDesignation] Desig ON CE.[DesignationId] = Desig.Id
		WHERE desig.[DepartmentId] = @Id

		UPDATE claim
		SET claim.[DesignationName] = desig.[Name]
		FROM [HR].[EmployeeClaim1] claim
		JOIN [Common].[DepartmentDesignation] desig ON claim.[DesignationId] = desig.Id
		WHERE desig.[DepartmentId] = @Id

		UPDATE claim
		SET claim.[DepartmentName] = Dept.[Name]
		FROM [HR].[EmployeeClaim1] claim
		JOIN [Common].[Department] Dept ON claim.[DepartmentId] = Dept.Id
		WHERE Dept.Id = @Id

		UPDATE LA
		SET LA.[DepartmentName] = Dept.[Name]
		FROM [HR].[LeaveApplication] LA
		JOIN [Common].[Department] Dept ON LA.[DepartmentId] = Dept.Id
		WHERE Dept.Id = @Id

		UPDATE LA
		SET LA.[DepartmentName] = desig.[Name]
		FROM [HR].[LeaveApplication] LA
		JOIN [Common].[DepartmentDesignation] desig ON LA.[DesignationId] = desig.Id
		WHERE desig.[DepartmentId] = @Id

		COMMIT TRANSACTION --m2
	END TRY --m3

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = 16, @ErrorState = 1;		

		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH
END --m1
GO
