USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [License].[UserActiveOrInActivate]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE 
procedure [License].[UserActiveOrInActivate](@companyId bigint, @username nvarchar(500), @status nvarchar(50))
AS
BEGIN
--Declare @companyId bigint = 2615
--Declare @username nvarchar(500) = 'ravi55@yopmail.com'
--Declare @status nvarchar(50) = 'Active'
    declare @status_int int = (case when @status='active' then 1 else 2 end)
	declare @CompanyUserId bigint = (select Id from Common.CompanyUser where CompanyId=@companyId and Username=@username)
	--if(@status='active')
	--BEGIN
	--	--If((select LicensesReserved-LicensesUsed from License.CompanyPackageModule where ModuleMasterId = (select Id from Common.ModuleMaster where Name='workflow cursor') and CompanyId=@companyId) = 0)
	--	BEGIN 		
	--    update Common.Companyuser set Status=2 where CompanyId=@companyId and Username=@username
	--	BEGIN try
	--		THROW 50001, 'Your custom error message.', 1;
	--	END try
	--	BEGIN Catch
	--		THROW 50001, 'Insufficient licenses. Please contact administrator.', 1;
	--	END Catch
	--	END
	--	--If((select LicensesReserved-LicensesUsed from License.CompanyPackageModule where ModuleMasterId = (select Id from Common.ModuleMaster where Name='Client cursor') and CompanyId=@companyId) = 0)
	--	
	--	BEGIN 		
	--    update Common.Companyuser set Status=2 where CompanyId=@companyId and Username=@username
	--	BEGIN try
	--		THROW 50001, 'Your custom error message.', 1;
	--	END try
	--	BEGIN Catch
	--		THROW 50001, 'Insufficient licenses. Please contact administrator.', 1;
	--	END Catch
	--	END
	--END
	--update Common.CompanyUserSubscription set Status=@status_int where CompanyUserId=@CompanyUserId
	----update Auth.UserRoleNew set status=@status_int where CompanyUserId=@companyUserId
	--exec [Common].[UpdateLicensesUsed] @companyId, 'Workflow Cursor', @status, 'user'
	--exec [Common].[UpdateLicensesUsed] @companyId, 'Client Cursor', @status, 'user'
	--update Auth.UserPermissionNew set isview= (case when @status='active' then 1 else 0 end)  where CompanyUserId=@CompanyUserId

	 IF (@status = 'active')
    BEGIN
			IF ((
			SELECT SUM(LicensesReserved - LicensesUsed)
        FROM License.Subscription AS s
        JOIN License.Package AS p ON s.PackageId = p.id
        JOIN Common.CompanyUserSubscription AS cus ON cus.SubscriptionId = s.Id
        WHERE cus.CompanyUserId = @CompanyUserId 
       -- AND cus.STATUS = 2
        AND p.ChargeUnit = 'User'
        AND s.CompanyId = @companyId
        AND s.STATUS = 1
			) = 0)
        BEGIN 
            UPDATE Common.CompanyUser SET Status = 2 WHERE CompanyId = @companyId AND Username = @username;
            BEGIN TRY
                THROW 50001, 'Insufficient licenses. Please contact administrator.', 1;
            END TRY
            BEGIN CATCH
                THROW 50001, 'Insufficient licenses. Please contact administrator.', 1;
            END CATCH
        END
    END
    UPDATE Common.CompanyUserSubscription SET Status = @status_int WHERE CompanyUserId = @CompanyUserId;
    -- UPDATE Auth.UserRoleNew SET status = @status_int WHERE CompanyUserId = @CompanyUserId;
    EXEC [Common].[UpdateLicensesUsed] @companyId, 'Workflow Cursor', @status, 'user';
    EXEC [Common].[UpdateLicensesUsed] @companyId, 'Client Cursor', @status, 'user';
    UPDATE Auth.UserPermissionNew SET isview = (CASE WHEN @status = 'active' THEN 1 ELSE 0 END) WHERE CompanyUserId = @CompanyUserId;
END;
----24th --------------GetAvailableLicenses SP changes-------
GO
