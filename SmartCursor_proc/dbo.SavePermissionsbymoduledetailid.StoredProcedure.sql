USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SavePermissionsbymoduledetailid]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SavePermissionsbymoduledetailid](@companyId bigint,@mdpId bigint,@MainCursorname Nvarchar(50),@SecondaryCursorname Nvarchar(50))
AS BEGIN
	--declare @mdpId  BIGINT;
	declare @userName  Nvarchar(100);
	declare @moduleDetailPermissionId table (id BIGINT);--@MainCursorname      = Bean Cursor , Bean Cursor
	declare @AdminUsers table (userName Nvarchar(100)); --@SecondaryCursorname = Admin Cursor , Bean Cursor
	BEGIN TRANSACTION
		BEGIN TRY 
	

			--admin users in company
			INSERT into @AdminUsers select Username from Common.CompanyUser where CompanyId=@companyId

			--outer cursor for loop users
			DECLARE  SaveUserAdmin CURSOR FOR SELECT * FROM @AdminUsers
			OPEN SaveUserAdmin
			FETCH NEXT FROM SaveUserAdmin INTO @userName
			WHILE @@FETCH_STATUS >= 0
			BEGIN

						IF NOT EXISTS (SELECT * FROM [Auth].[UserPermission] WHERE ModuleDetailPermissionId=@mdpId and Username=@userName and CompanyUserId=(select Id from Common.CompanyUser where CompanyId=@companyId and Username=@userName ) and RoleId= (select Id from Auth.Role where IsSystem=1 and CompanyId=@companyId and   ModuleMasterId=(select Id from Common.ModuleMaster  where Name=@MainCursorname and IsPartner is null)))
						Begin
							INSERT INTO Auth.UserPermission  values(NEWID(),(select Id from Common.CompanyUser where CompanyId=@companyId and Username=@userName ),@userName,@mdpId, (select Id from Auth.Role where IsSystem=1 and CompanyId=@companyId and   ModuleMasterId=(select Id from Common.ModuleMaster  where Name=@MainCursorname and IsPartner is null) and  CompanyId=@companyId),NULL,NULL,NULL,NULL,1)
						End

				FETCH NEXT FROM SaveUserAdmin INTO @userName
			END
			CLOSE SaveUserAdmin
			DEALLOCATE SaveUserAdmin
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			DECLARE
				@ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;
			SELECT
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
			ROLLBACK TRANSACTION
		END CATCH
	END

GO
