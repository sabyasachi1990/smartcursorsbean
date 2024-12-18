USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Changes_State]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[BR_Changes_State] @userName nvarchar(200),@permissionkey nvarchar(200),@companyId Bigint
as
Begin
    If (@permissionkey='br_alltasks')
	Begin
	  select Json_Query(PERMISSIONS,'$.Tabs[0].Actions' ) as UserPermissions from Auth.UserPermissionNew as upn 
      join Common.CompanyUser as cu on upn.CompanyUserId=cu.Id
      join Common.ModuleDetail as md on upn.ModuleDetailId=md.Id 
      where  cu.Username=@userName and md.PermissionKey=@permissionkey and md.CompanyId=@companyId
     
	  End
    Else if(@permissionkey='br_incorporationDocs')
	Begin
	   select Json_Query(PERMISSIONS,'$.Tabs[0].Form.Tabs[5].Actions' ) as UserPermissions from Auth.UserPermissionNew as upn 
       join Common.CompanyUser as cu on upn.CompanyUserId=cu.Id
       join Common.ModuleDetail as md on upn.ModuleDetailId=md.Id 
       where  cu.Username=@userName and md.PermissionKey='br_entityprofile' and md.CompanyId=@companyId 
	End
  Else
   Begin
       select Json_Query(PERMISSIONS,'$.Tabs[0].Form.Tabs[0].Actions' ) as UserPermissions from Auth.UserPermissionNew as upn 
      join Common.CompanyUser as cu on upn.CompanyUserId=cu.Id
      join Common.ModuleDetail as md on upn.ModuleDetailId=md.Id 
      where  cu.Username=@userName and md.PermissionKey=@permissionkey and md.CompanyId=@companyId 

   End
 End




GO
