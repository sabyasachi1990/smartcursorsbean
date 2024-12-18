USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Dashboard_Emp_Details]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[HR_Dashboard_Emp_Details] @Empid UNIQUEIDENTIFIER, @Companyid BIGINT
AS
BEGIN --1
	BEGIN TRY --2
		DECLARE @STATUS INT

		SET @STATUS = (
				SELECT STATUS
				FROM Common.Employee (NOLOCK)
				WHERE id = @Empid
				)

		IF (@STATUS = 1)
		BEGIN --3
			SELECT NEWID() ID, Id EmployeeId, FirstName EmpName, DeptName, DesgName, 'Employee' Type, NULL AS Value1, NULL Value2, NULL AS 'Item Name', EmpImage, STATUS, CompanyName
			FROM (
				SELECT e.Id, e.FirstName, d.Name AS DeptName, dd.Name AS DesgName, ed.CreatedDate, M.Small AS EmpImage, e.STATUS, c.Name AS CompanyName
				FROM HR.EmployeeDepartment ed (NOLOCK)
				INNER JOIN Common.Employee e (NOLOCK) ON e.Id = ed.EmployeeId
				INNER JOIN Common.Department d (NOLOCK) ON d.Id = ed.DepartmentId
				INNER JOIN Common.DepartmentDesignation dd (NOLOCK) ON dd.Id = ed.DepartmentDesignationId
				LEFT JOIN Common.MediaRepository M (NOLOCK) ON M.Id = E.PhotoId
				LEFT JOIN Common.Company C (NOLOCK) ON C.Id = e.CompanyId
				WHERE /* e.Status=1 and */ e.Id = @Empid AND (Convert(DATE, EffectiveFrom) <= Convert(DATE, GETUTCDATE()) AND (Convert(DATE, EffectiveTo) >= Convert(DATE, GETUTCDATE()) OR EffectiveTo IS NULL))
				) AS AA
		END --3
		ELSE
		BEGIN --4
			SELECT NEWID() ID, Id EmployeeId, FirstName EmpName,null AS DeptName, null AS DesgName, 'Employee' Type, NULL AS Value1, NULL Value2, NULL AS 'Item Name', EmpImage, STATUS, CompanyName
			FROM (
				SELECT e.Id, e.FirstName, M.Small AS EmpImage, e.STATUS, c.Name AS CompanyName
				FROM Common.Employee e (NOLOCK)			
				LEFT JOIN Common.MediaRepository M (NOLOCK) ON M.Id = E.PhotoId
				LEFT JOIN Common.Company C (NOLOCK) ON C.Id = e.CompanyId
				WHERE /* e.Status=1 and */ e.Id = @Empid 
				) AS AA
		END --4
	END TRY --2

	BEGIN CATCH
		PRINT 'Failed'

		SELECT ERROR_NUMBER() AS ErrorNumber, ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END --1


GO
