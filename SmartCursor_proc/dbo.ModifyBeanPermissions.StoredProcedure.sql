USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ModifyBeanPermissions]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create     Procedure [dbo].[ModifyBeanPermissions]
@ModuleMasterId Int,
@ScreenName Nvarchar(254),
@ArrayName Nvarchar(254),
@ArrayNumber Nvarchar(25),
@PermissionKey Nvarchar(254)
As
Begin


--Declare @ModuleMasterId Int = 4,
--@ScreenName Nvarchar(254) = 'Payroll Bills',
--@ArrayName Nvarchar(254)='Add',
--@ArrayNumber Nvarchar(25)=1,
--@PermissionKey Nvarchar(254)='bean_payrollbills'
--,@CompanyId Bigint=563

	----===============================For Role permission new no need check whether BCAdmin or normal Bean permission

	--Select [Permissions],JSON_MODIFY(Permissions,'$.Tabs[0].Actions['+@ArrayNumber+'].IsApplicable','true') 
	--From Auth.RolePermissionsNew As RPN
	--Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	--Join Common.Company As CMP On MD.CompanyId=CMP.Id
	--Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	--And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0 
	

	Update RPN Set RPN.Permissions = JSON_MODIFY(Permissions,'$.Tabs[0].Actions['+@ArrayNumber+'].IsApplicable','true') 
	From Auth.RolePermissionsNew As RPN
	Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	Join Common.Company As CMP On MD.CompanyId=CMP.Id
	Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0 



	--Select [Permissions],JSON_MODIFY(Permissions,'$.Tabs[0].Actions['+@ArrayNumber+'].Chk','true') 
	--From Auth.RolePermissionsNew As RPN
	--Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	--Join Common.Company As CMP On MD.CompanyId=CMP.Id
	--Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	--And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0
	--and RPN.IsSeedData = 1

	Update RPN Set RPN.Permissions = JSON_MODIFY(Permissions,'$.Tabs[0].Actions['+@ArrayNumber+'].Chk','true') 
	From Auth.RolePermissionsNew As RPN
	Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	Join Common.Company As CMP On MD.CompanyId=CMP.Id
	Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0 And  RPN.IsSeedData = 1

	---==============================Form Level

	--Select [Permissions],JSON_MODIFY(Permissions,'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+'].IsApplicable','true') 
	--From Auth.RolePermissionsNew As RPN
	--Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	--Join Common.Company As CMP On MD.CompanyId=CMP.Id
	--Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	--And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0
	

	Update RPN Set RPN.Permissions = JSON_MODIFY(Permissions,'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+'].IsApplicable','true') 
	From Auth.RolePermissionsNew As RPN
	Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	Join Common.Company As CMP On MD.CompanyId=CMP.Id
	Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0
	



	--Select [Permissions],JSON_MODIFY(Permissions,'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+'].Chk','true') 
	--From Auth.RolePermissionsNew As RPN
	--Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	--Join Common.Company As CMP On MD.CompanyId=CMP.Id
	--Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	--And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0 and RPN.IsSeedData = 1
	

	Update RPN Set RPN.Permissions = JSON_MODIFY(Permissions,'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+'].Chk','true') 
	From Auth.RolePermissionsNew As RPN
	Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	Join Common.Company As CMP On MD.CompanyId=CMP.Id
	Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0 and RPN.IsSeedData = 1




	
	---=====================User Permission we need to add isapplicable and ischecked true for the user who is having BCAdmin permission, for other isapplicable is true and ischecked should be false

	--Select [Permissions],JSON_MODIFY(Permissions,'$.Tabs[0].Actions['+@ArrayNumber+'].IsApplicable','true') 
	--From Auth.UserPermissionNew As RPN
	--Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	--Join Common.Company As CMP On MD.CompanyId=CMP.Id
	--Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	--And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0
	

	Update RPN Set RPN.Permissions =JSON_MODIFY(Permissions,'$.Tabs[0].Actions['+@ArrayNumber+'].IsApplicable','true') 
	From Auth.UserPermissionNew As RPN
	Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	Join Common.Company As CMP On MD.CompanyId=CMP.Id
	Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0


		-----================================Form Level

	--Select [Permissions],JSON_MODIFY(Permissions,'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+'].IsApplicable','true') 
	--From Auth.UserPermissionNew As RPN
	--Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	--Join Common.Company As CMP On MD.CompanyId=CMP.Id
	--Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	--And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0
	

	Update RPN Set RPN.Permissions = JSON_MODIFY(Permissions,'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+'].IsApplicable','true') 
	From Auth.UserPermissionNew As RPN
	Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	Join Common.Company As CMP On MD.CompanyId=CMP.Id
	Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0



	-----------------------------Normal user Tab and form level


	--Select [Permissions],JSON_MODIFY(Permissions,'$.Tabs[0].Actions['+@ArrayNumber+'].Chk','true') 
	--From Auth.UserPermissionNew As RPN
	--Join Auth.UserRoleNew URN on RPN.companyuserId = URN.CompanyUserId
	--Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	--Join Common.Company As CMP On MD.CompanyId=CMP.Id
	--Join Auth.RoleNew RN on RN.Id=URN.RoleId
	--Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	--And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0
	--and RN.Name  in ('BC Admin') and RN.ModuleMasterId  in (4)
	

	Update RPN Set RPN.Permissions = JSON_MODIFY(Permissions,'$.Tabs[0].Actions['+@ArrayNumber+'].Chk','true') 
	From Auth.UserPermissionNew As RPN
	Join Auth.UserRoleNew URN on RPN.companyuserId = URN.CompanyUserId
	Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	Join Common.Company As CMP On MD.CompanyId=CMP.Id
	Join Auth.RoleNew RN on RN.Id=URN.RoleId
	Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0
	and RN.Name  in ('BC Admin') and RN.ModuleMasterId  in (4)

	

	--Select [Permissions],JSON_MODIFY(Permissions,'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+'].Chk','true') 
	--From Auth.UserPermissionNew As RPN
	--Join Auth.UserRoleNew URN on RPN.companyuserId = URN.CompanyUserId
	--Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	--Join Common.Company As CMP On MD.CompanyId=CMP.Id
	--Join Auth.RoleNew RN on RN.Id=URN.RoleId
	--Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	--And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0
	--and RN.Name  in ('BC Admin') and RN.ModuleMasterId  in (4)
	

	Update RPN Set RPN.Permissions = JSON_MODIFY(Permissions,'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+'].Chk','true') 
	From Auth.UserPermissionNew As RPN
	Join Auth.UserRoleNew URN on RPN.companyuserId = URN.CompanyUserId
	Join Common.ModuleDetail As MD On MD.Id=RPN.ModuleDetailId
	Join Common.Company As CMP On MD.CompanyId=CMP.Id
	Join Auth.RoleNew RN on RN.Id=URN.RoleId
	Where MD.PermissionKey=@PermissionKey And MD.Heading=@ScreenName
	And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Form.Tabs[0].Actions['+@ArrayNumber+']'),'$.Name')=@ArrayName And Cmp.Id<>0
	and RN.Name  in ('BC Admin') and RN.ModuleMasterId  in (4)

	
End
GO
