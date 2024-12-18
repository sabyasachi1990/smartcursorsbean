USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[EmployeeBeanEntityChecking]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE  [dbo].[EmployeeBeanEntityChecking](@Ids NVARCHAR(max))
AS
BEGIN
	BEGIN TRY
		DECLARE @EmployeeId UNIQUEIDENTIFIER;
		declare @ErrorMessage NVARCHAR(500)

		DECLARE companpany_cursor CURSOR
		FOR
		SELECT EmployeId
		FROM HR.employeeclaim1
		WHERE id IN (
				SELECT items
				FROM dbo.SplitToTable(@Ids, ',')
				)

		OPEN companpany_cursor

		FETCH NEXT
		FROM companpany_cursor
		INTO @EmployeeId

		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF NOT EXISTS (
					SELECT id
					FROM Bean.Entity
					WHERE SyncEmployeeId = @EmployeeId
					)
			BEGIN
				DECLARE @empname NVARCHAR(50) = (
						SELECT FirstName
						FROM Common.Employee
						WHERE id = @EmployeeId
						)

				SET @empname = (@empname + ' does not exist in bean.')
				--print @empname
				RAISERROR (
						@empname, -- Message text.  
						16, -- Severity.  
						1 -- State.  
						);
			END

			FETCH NEXT
			FROM companpany_cursor
			INTO @EmployeeId
		END

		CLOSE companpany_cursor

		DEALLOCATE companpany_cursor
	END TRY

	BEGIN CATCH
		SELECT @ErrorMessage=ERROR_MESSAGE()
RAISERROR(@ErrorMessage,16,1);
	END CATCH
END
GO
