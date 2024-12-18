USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteUserRoles]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-------------********************* SP *******************
Create PROCEDURE [dbo].[SP_DeleteUserRoles](@CompanyUserId BIGINT,@UserAccountId UNIQUEIDENTIFIER,@RoleId UNIQUEIDENTIFIER null,@UserName Nvarchar(50),@Delete BIT) 
AS
BEGIN
 Declare @MDPID BIGINT  -- module detail permission Id
 Declare @g uniqueidentifier = cast(cast(0 as binary) as uniqueidentifier)
IF(@Delete = 1)
 BEGIN
  -- Deleting User Account Cursors
  Delete Common.UserAccountCursors where UserAccountId=@UserAccountId
  -- Deleting Deleting User Permissions
  Delete Auth.UserPermission where RoleId=@RoleId
  -- Deleting user roles
  Delete Auth.UserRole where RoleId=@RoleId
    END

IF(@RoleId != NULL and @RoleId != @g)
    BEGIN
    DECLARE SAVE_PERMISSIONS_CURSOR CURSOR FOR   
  select rp.ModuleDetailPermissionId from Common.ModuleDetail as md join Auth.ModuleDetailPermission as mdp on md.Id =mdp.ModuleDetailId join          Auth.RolePermission as rp on mdp.Id = rp.ModuleDetailPermissionId where md.IsPartner = 1 and rp.RoleId= @RoleId
  OPEN SAVE_PERMISSIONS_CURSOR
  FETCH NEXT FROM SAVE_PERMISSIONS_CURSOR INTO @MDPID
  WHILE (@@FETCH_STATUS = 0)
   BEGIN
    INSERT INTO AUTH.USERPERMISSION VALUES  (NEWID(),@CompanyUserId,@UserName,@MDPID ,@RoleId,@UserName,GETDATE(),null,null)
   END
  FETCH NEXT FROM SAVE_PERMISSIONS_CURSOR INTO @MDPID
    END 
END

GO
