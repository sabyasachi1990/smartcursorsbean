USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[UpdateAdminRolePermissions]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UpdateAdminRolePermissions](@companyId bigint,@Cursorname Nvarchar(50))
AS BEGIN 
    declare @mdpId  BIGINT;
 declare @moduleDetailPermissionId table (id BIGINT); 
 BEGIN TRANSACTION
 BEGIN TRY 
  --here all moduledetailpermission related cursor
  INSERT into @moduleDetailPermissionId
  select amd.Id from Common.ModuleDetail cm 
  join  Auth.ModuleDetailPermission amd  on cm.Id= amd.ModuleDetailId
  where cm.Status=1 and cm.ModuleMasterId= (select Id from Common.ModuleMaster where Name=@Cursorname);
  --here cursor starting for insertion for roleprmissions based on company and cursorname
  DECLARE  SaveRolePermissions CURSOR FOR SELECT * FROM @moduleDetailPermissionId
  OPEN SaveRolePermissions
  FETCH NEXT FROM SaveRolePermissions INTO @mdpId
  WHILE @@FETCH_STATUS >= 0
  BEGIN
   IF NOT EXISTS (SELECT * FROM [Auth].[RolePermission] WHERE RoleId= (select Id from Auth.Role where IsSystem=1 and CompanyId=@companyId and   ModuleMasterId=(select Id from Common.ModuleMaster  where Name=@Cursorname and IsPartner is null)) and MODULEDETAILPERMISSIONID=@mdpId)
   BEGIN
    INSERT INTO [Auth].[RolePermission] ([Id],[RoleId],[ModuleDetailpermissionId], status) values (NEWID(),(select Id from Auth.Role where IsSystem=1 and CompanyId=@companyId and ModuleMasterId=(select Id from Common.ModuleMaster  where Name=@Cursorname and IsPartner is null)),@mdpId, 1)
            END 
   FETCH NEXT FROM SaveRolePermissions INTO @mdpId    
  END
  CLOSE SaveRolePermissions
  DEALLOCATE SaveRolePermissions    
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
