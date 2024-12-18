USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CompanyWise_Auth_DataDeletion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[CompanyWise_Auth_DataDeletion]
@CompanyId Int

AS
BEGIN

DECLARE @CompanyInfo TABLE (Id Int, RegistrationNo Nvarchar(150), Name Nvarchar(500))

INSERT INTO @CompanyInfo
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE Id = @CompanyId
UNION ALL
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE ParentId = @CompanyId

------------------==================================================================================================================================================================================================
-----------------/////////////////////////////////////////////////////////////////////////////// AUTH \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-----------------==================================================================================================================================================================================================

------------------//////////////////////////////////////////////////////////////////////// Auth.GridMetaData \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Auth.GridMetaData WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

---------------//////////////////////////////////////////////////////////////////////// Auth.Permission \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


DELETE FROM Auth.RolePermission WHERE ModuleDetailPermissionId IN
(
SELECT Id FROM Auth.ModuleDetailPermission WHERE PermissionId IN
(SELECT Id FROM Auth.Permission WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Auth.UserPermission WHERE ModuleDetailPermissionId IN
(
SELECT Id FROM Auth.ModuleDetailPermission WHERE PermissionId IN
(SELECT Id FROM Auth.Permission WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Auth.ModuleDetailPermission WHERE PermissionId IN
(SELECT Id FROM Auth.Permission WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Common.ViewPermission_ToBeDeleted WHERE PermissionId IN ----> No Data in Table
(
SELECT Id FROM Auth.Permission WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Auth.Permission WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

-----------------//////////////////////////////////////////////////////////////////////// Auth.PermissionsMapping \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Auth.PermissionsMapping WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------//////////////////////////////////////////////////////////////////////// Auth.Role \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


DELETE FROM Auth.RolePermission WHERE RoleId IN
(SELECT Id FROM Auth.Role WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Auth.UserPermission WHERE RoleId IN
(SELECT Id FROM Auth.Role WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Auth.UserRole WHERE RoleId IN
(SELECT Id FROM Auth.Role WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))

--------------SELECT * FROM Common.UserAccountCursors_ToBeDeleted ---> No Data in Table

DELETE FROM Auth.Role WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

------//////////////////////////////////////////////////////////////////////// Auth.RoleNew \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


DELETE FROM Auth.RolePermissionsNew WHERE RoleId IN
(SELECT Id FROM Auth.RoleNew WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Auth.UserPermissionNew WHERE UserRoleId IN
(
SELECT Id FROM Auth.UserRoleNew WHERE RoleId IN
(SELECT Id FROM Auth.RoleNew WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))
)

DELETE FROM Auth.UserRoleNew WHERE RoleId IN
(SELECT Id FROM Auth.RoleNew WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo))

DELETE FROM Auth.RoleNew WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)


END
GO
