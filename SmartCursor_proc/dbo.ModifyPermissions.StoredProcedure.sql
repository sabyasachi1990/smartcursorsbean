USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ModifyPermissions]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[ModifyPermissions]
@ModuleMasterId Int,
@ScreenName Nvarchar(254),
@ArrayName Nvarchar(254),
@ArrayNumber Nvarchar(25),
@PermissionKey Nvarchar(254)
As
Begin
	--Select [Permissions],JSON_MODIFY(Permissions,'$.Tabs[0].Actions['+@ArrayNumber+'].Typ','Form') 
	--From Auth.RolePermissionsNew As RPN
	--Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	--Join Common.Company As CMP On MD.CompanyId=CMP.Id
	--Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	--And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0

	Update RPN Set [Permissions]=JSON_MODIFY(Permissions,'$.Tabs[0].Actions['+@ArrayNumber+'].Typ','Form') 
	From Auth.RolePermissionsNew As RPN
	Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	Join Common.Company As CMP On MD.CompanyId=CMP.Id
	Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0


	--Select [Permissions],JSON_MODIFY(Permissions,'$.Tabs[0].Actions['+@ArrayNumber+'].Typ','Form') 
	--From Auth.UserPermissionNew As RPN
	--Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	--Join Common.Company As CMP On MD.CompanyId=CMP.Id
	--Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	--And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0


	Update RPN Set [Permissions]=JSON_MODIFY(Permissions,'$.Tabs[0].Actions['+@ArrayNumber+'].Typ','Form') 
	From Auth.UserPermissionNew As RPN
	Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	Join Common.Company As CMP On MD.CompanyId=CMP.Id
	Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0

End
GO
