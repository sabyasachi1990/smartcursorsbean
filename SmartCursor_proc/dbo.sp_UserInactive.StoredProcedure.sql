USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[sp_UserInactive]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[sp_UserInactive]
AS
BEGIN

 -- #region oldone 
 --ALTER PROCEDURE [dbo].[sp_UserInactive] 
 --AS
 --BEGIN

 --   --UPDATE cu
 --   select cu.Status ,
 --       cu.ModifiedDate ,
 --       cu.ModifiedBy 
 --   FROM Common.CompanyUser AS cu
 --   INNER JOIN Common.Employee AS e ON cu.Username = e.Username
 --   WHERE cu.Status = 1
 --       AND cu.DeactivationDate IS NOT NULL
 --       AND cu.DeactivationDate < GETDATE()
        --AND cu.Id = (SELECT TOP 1 cu2.Id
        --             FROM Common.CompanyUser AS cu2
        --             WHERE cu2.Username = e.Username);

 --END
-- #endregion oldone
    -- Declare variables for cursor
    DECLARE @CompanyId BIGINT;
    DECLARE @Username NVARCHAR(500);
    DECLARE user_cursor CURSOR FOR
    SELECT CompanyId, Username
    FROM Common.CompanyUser
    WHERE DeactivationDate <= GETDATE()  AND Status = 1;

    UPDATE Common.CompanyUser
    SET Status = 2 
    WHERE DeactivationDate <= GETDATE() AND Status = 1;
    OPEN user_cursor;
    FETCH NEXT FROM user_cursor INTO @CompanyId, @Username;
    WHILE @@FETCH_STATUS = 0
    BEGIN  
        EXEC [License].[UserActiveOrInActivate] @CompanyId, @Username, 'inactive';
        FETCH NEXT FROM user_cursor INTO @CompanyId, @Username;
    END;
    CLOSE user_cursor;
    DEALLOCATE user_cursor;
END;

GO
