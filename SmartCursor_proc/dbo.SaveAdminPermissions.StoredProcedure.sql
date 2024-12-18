USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SaveAdminPermissions]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SaveAdminPermissions](@companyId bigint,@MainCursorname Nvarchar(50),@SecondaryCursorname Nvarchar(50))
AS BEGIN
 declare @mdpId  BIGINT;
 declare @userName  Nvarchar(100);
 declare @moduleDetailPermissionId table (id BIGINT);--@MainCursorname      = Bean Cursor , Bean Cursor
 declare @AdminUsers table (userName Nvarchar(100)); --@SecondaryCursorname = Admin Cursor , Bean Cursor
 BEGIN TRANSACTION
  BEGIN TRY 
   --here all permission related curser admin user
   INSERT into @moduleDetailPermissionId
   select amd.Id from Common.ModuleDetail cm 
   join  Auth.ModuleDetailPermission amd  on cm.Id= amd.ModuleDetailId
   where cm.Status=1 and cm.ModuleMasterId= (select Id from Common.ModuleMaster where Name=@MainCursorname) and 
   cm.SecondryModuleId= (select Id from Common.ModuleMaster where Name=@SecondaryCursorname) 
   order by Id;

   --admin users in company
   INSERT into @AdminUsers select Username from Common.CompanyUser where CompanyId=@companyId and IsAdmin=1

   --outer cursor for loop users
   DECLARE  SaveUserAdmin CURSOR FOR SELECT * FROM @AdminUsers
   OPEN SaveUserAdmin
   FETCH NEXT FROM SaveUserAdmin INTO @userName
   WHILE @@FETCH_STATUS >= 0
   BEGIN
    --inner cursor for one user
    DECLARE  SaveAdmin CURSOR FOR SELECT * FROM @moduleDetailPermissionId
    OPEN SaveAdmin
    FETCH NEXT FROM SaveAdmin INTO @mdpId
    WHILE @@FETCH_STATUS >= 0
    BEGIN
      IF NOT EXISTS (SELECT * FROM [Auth].[UserPermission] WHERE ModuleDetailPermissionId=@mdpId and Username=@userName and CompanyUserId=(select Id from Common.CompanyUser where CompanyId=@companyId and Username=@userName ) and RoleId= (select Id from Auth.Role where IsSystem=1 and CompanyId=@companyId and   ModuleMasterId=(select Id from Common.ModuleMaster  where Name=@MainCursorname and IsPartner is null)))
      Begin
       INSERT INTO Auth.UserPermission  values(NEWID(),(select Id from Common.CompanyUser where CompanyId=@companyId and Username=@userName ),@userName,@mdpId, (select Id from Auth.Role where IsSystem=1 and CompanyId=@companyId and   ModuleMasterId=(select Id from Common.ModuleMaster  where Name=@MainCursorname and IsPartner is null) and  CompanyId=@companyId),NULL,NULL,NULL,NULL,1)
      End
     FETCH NEXT FROM SaveAdmin INTO @mdpId
    END
    CLOSE SaveAdmin
    DEALLOCATE SaveAdmin

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
