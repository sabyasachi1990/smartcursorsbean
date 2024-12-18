USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_REMOVE_ROLES_AND_PERMISSIONS]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_REMOVE_ROLES_AND_PERMISSIONS]
@ID UNIQUEIDENTIFIER
AS
BEGIN
DELETE FROM [Auth].[RolePermission] WHERE [RoleId] = @ID
DELETE FROM [Auth].[UserRole] WHERE [RoleId] =@ID
DELETE FROM [Auth].[UserPermission] WHERE [RoleId]=@ID
DELETE  FROM [Auth].[Role] WHERE [Id]=@ID
END
GO
