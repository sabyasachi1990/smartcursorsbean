USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[UpdateUserPermission_CompanyWise]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Procedure [Common].[UpdateUserPermission_CompanyWise] 
@Role Nvarchar(200),
@PermissionKey Nvarchar(100)
AS
Begin
  
   --================================== update UserPermission CompanyWise============================================
   update Urpn set Urpn.[Permissions]=Rpn.[Permissions]
  --select Urpn.id,Rn.id as RoleId,MD.Id AS ModuleDetailId,urn.CompanyUserId,Urpn.[Permissions],Rpn.[Permissions] as [PermissionsNew] ,Rn.CompanyId--,Rn.Name as RoleName,PermissionKey
  from Auth.RoleNew  Rn 
  inner join Auth.UserRoleNew Urn on Urn.RoleId=Rn.Id
  inner join Common.ModuleDetail MD on MD.CompanyId=Rn.CompanyId
  inner join Auth.RolePermissionsNew Rpn on Rpn.RoleId=Rn.Id
  inner join Auth.UserPermissionNew Urpn on Urpn.ModuleDetailId=Rpn.ModuleDetailId
  where Rpn.ModuleDetailId=MD.Id  AND  Urpn.CompanyUserId=Urn.CompanyUserId
  and Rn.name=@Role and MD.PermissionKey=@permissionkey
  --order by CompanyId,Rn.id,MD.Id 

End










GO
