USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Maintenance].[NewScreenTabAdding_PositionWise]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




-- If you want to add permission in middle, please run below for Admin roles / users.
-- Pass the JSON obj with 

--exec [Maintenance].[NewScreenTabAdding_PositionWise] '$.Tabs[0].Form.Tabs[4]','bean_cockpit','Bean Cursor',4,4,'bean_cockpit_entities',
--'{"Name":"Entities","ModuleDetailId":248550,"PermissionKey":"bean_cockpit_entities","IsStaticTabs":false,"IsDynamicTabs":false,"DTabs":null,"Tabs":[],"Actions":[{"Name":"View","Heading":"View","IsApplicable":true,"Chk":true,"Grp":"View","Typ":"Top"},{"Name":"Add","Heading":"Add","IsApplicable":false,"Chk":false,"Grp":"Add","Typ":"Top"},{"Name":"Edit","Heading":"Edit","IsApplicable":false,"Chk":false,"Grp":"Edit","Typ":"Top"},{"Name":"Disable","Heading":"Disable","IsApplicable":false,"Chk":false,"Grp":"Disable","Typ":"Top"}],"Form":{"DTabs":null,"Tabs":[{"Name":"Entities","ModuleDetailId":248550,"PermissionKey":"bean_cockpit_entities","IsStaticTabs":false,"IsDynamicTabs":false,"DTabs":null,"Tabs":[],"Actions":[{"Name":"View","Heading":"View","IsApplicable":true,"Chk":true,"Grp":"View","Typ":"Top"},{"Name":"Add","Heading":"Add","IsApplicable":false,"Chk":false,"Grp":"Add","Typ":"Top"},{"Name":"Edit","Heading":"Edit","IsApplicable":false,"Chk":false,"Grp":"Edit","Typ":"Top"},{"Name":"Disable","Heading":"Disable","IsApplicable":false,"Chk":false,"Grp":"Disable","Typ":"Top"}],"Form":null,"States":[],"AvailableStates":null}]},"States":[],"AvailableStates":null}'

CREATE procedure [Maintenance].[NewScreenTabAdding_PositionWise]
(@position nvarchar(max), -- = '$.Tabs[0].Form.Tabs[3]',
@permissionKey nvarchar(500), -- = 'client_reports', 
@moduleName nvarchar(100), -- = 'Client Cursor', -> To get ModuleMasterId for Common.ModuleDetail
@ModuleMasterId nvarchar(10), -- = 1,
@SecondayModuleId nvarchar(10),
@TabPermissionKey nvarchar(100), -- = 1,
@JsonObj nvarchar(max) -- ='{"Name":"Opportunities","ModuleDetailId":219832,"PermissionKey":"client_cockpit_opportunities","IsStaticTabs":false,"IsDynamicTabs":false,"DTabs":null,"Tabs":[],"Actions":[{"Name":"View","Heading":"View","IsApplicable":true,"Chk":true,"Grp":"View","Typ":"Top"},{"Name":"Add","Heading":"Add","IsApplicable":false,"Chk":false,"Grp":"Add","Typ":"Top"},{"Name":"Edit","Heading":"Edit","IsApplicable":false,"Chk":false,"Grp":"Edit","Typ":"Top"},{"Name":"Disable","Heading":"Disable","IsApplicable":false,"Chk":false,"Grp":"Disable","Typ":"Top"}],"Form":{"DTabs":null,"Tabs":[{"Name":"Opportunities","ModuleDetailId":219832,"PermissionKey":"client_cockpit_opportunities","IsStaticTabs":false,"IsDynamicTabs":false,"DTabs":null,"Tabs":[],"Actions":[{"Name":"View","Heading":"View","IsApplicable":true,"Chk":true,"Grp":"View","Typ":"Top"},{"Name":"Add","Heading":"Add","IsApplicable":false,"Chk":false,"Grp":"Add","Typ":"Top"},{"Name":"Edit","Heading":"Edit","IsApplicable":false,"Chk":false,"Grp":"Edit","Typ":"Top"},{"Name":"Disable","Heading":"Disable","IsApplicable":false,"Chk":false,"Grp":"Disable","Typ":"Top"}],"Form":null,"States":[],"AvailableStates":null}]},"States":[],"AvailableStates":null}'
)
As 
Begin

declare @moduleDetailStr nvarchar(100) = '"ModuleDetailId":'
declare @MDVal nvarchar(100) = (select JSON_VALUE(@JsonObj, '$.ModuleDetailId'))

-- Admin Roles

update RPN set Permissions=
--select 
Replace(Replace(Replace(JSON_MODIFY(JSON_MODIFY(Permissions, 'append $', JSON_VALUE(Permissions, @position)), @position, JSON_QUERY('['+REPLACE(@JsonObj,@moduleDetailStr+@MDVal,@moduleDetailStr+cast((select Id from Common.ModuleDetail where PermissionKey=@TabPermissionKey and CompanyId=MD.CompanyId) as nvarchar(100)))+','+JSON_QUERY(Permissions, @position)+']')),'},[{','},{'),'}],{','},{'),'}]]','}]')
from 
Auth.RolePermissionsNew As RPN 
			Join Common.ModuleDetail As MD On RPN.ModuleDetailId=MD.Id
			Join Common.ModuleMaster As MM On MM.Id=MD.ModuleMasterId
			Where MD.PermissionKey=@permissionKey And RPN.IsSeedData = 1 And MM.Name=@moduleName
			and MD.SecondryModuleId = @SecondayModuleId and MD.ModuleMasterId=@ModuleMasterId and MD.CompanyId<>689
			And JSON_VALUE(PERMISSIONS,@position+'.Name') != JSON_VALUE(@JsonObj, '$.Name')

-- Admin users

update UPN set Permissions=
--select 
Replace(Replace(Replace(JSON_MODIFY(JSON_MODIFY(Permissions, 'append $', JSON_VALUE(Permissions, @position)), @position, JSON_QUERY('['+REPLACE(@JsonObj,@moduleDetailStr+@MDVal,@moduleDetailStr+cast((select Id from Common.ModuleDetail where PermissionKey=@TabPermissionKey and CompanyId=MD.CompanyId) as nvarchar(100)))+','+JSON_QUERY(Permissions, @position)+']')),'},[{','},{'),'}],{','},{'),'}]]','}]')
from
Auth.UserPermissionNew UPN
			Join Auth.UserRoleNew UR on UPN.CompanyUserId = UR.CompanyUserId
			Join Auth.RoleNew RN on RN.Id = UR.RoleId
			Join Common.ModuleDetail As MD On UPN.ModuleDetailId=MD.Id
			Join Common.ModuleMaster As MM On MM.Id=MD.ModuleMasterId
		where MD.PermissionKey=@permissionKey and RN.IsSystem = 1 And MM.Name=@moduleName
			and MD.SecondryModuleId = @SecondayModuleId and MD.ModuleMasterId=@ModuleMasterId and MD.CompanyId<>689
		And JSON_VALUE(PERMISSIONS,@position+'.Name') != JSON_VALUE(@JsonObj, '$.Name')

-- Non Admin Roles

declare @nonAdminJSONObj nvarchar(1000) = Replace(@JsonObj,'"Chk":true','"Chk":false')

update RPN set Permissions=
--select 
Replace(Replace(Replace(JSON_MODIFY(JSON_MODIFY(Permissions, 'append $', JSON_VALUE(Permissions, @position)), @position, JSON_QUERY('['+REPLACE(@JsonObj,@moduleDetailStr+@MDVal,@moduleDetailStr+cast((select Id from Common.ModuleDetail where PermissionKey=@TabPermissionKey and CompanyId=MD.CompanyId) as nvarchar(100)))+','+JSON_QUERY(Permissions, @position)+']')),'},[{','},{'),'}],{','},{'),'}]]','}]')
from
Auth.RolePermissionsNew As RPN 
			Join Common.ModuleDetail As MD On RPN.ModuleDetailId=MD.Id
			Join Common.ModuleMaster As MM On MM.Id=MD.ModuleMasterId
			Where MD.PermissionKey=@permissionKey And (RPN.IsSeedData != 1 OR RPN.IsSeedData IS NULL) And MM.Name=@moduleName
			and MD.SecondryModuleId = @SecondayModuleId and MD.ModuleMasterId=@ModuleMasterId and MD.CompanyId<>689
			And JSON_VALUE(PERMISSIONS,@position+'.Name') != JSON_VALUE(@nonAdminJSONObj, '$.Name')

-- Non Admin Users

update UPN set Permissions=
--select 
Replace(Replace(Replace(JSON_MODIFY(JSON_MODIFY(Permissions, 'append $', JSON_VALUE(Permissions, @position)), @position, JSON_QUERY('['+REPLACE(@JsonObj,@moduleDetailStr+@MDVal,@moduleDetailStr+cast((select Id from Common.ModuleDetail where PermissionKey=@TabPermissionKey and CompanyId=MD.CompanyId) as nvarchar(100)))+','+JSON_QUERY(Permissions, @position)+']')),'},[{','},{'),'}],{','},{'),'}]]','}]')
from 
Auth.UserPermissionNew UPN
			Join Auth.UserRoleNew UR on UPN.CompanyUserId = UR.CompanyUserId
			Join Auth.RoleNew RN on RN.Id = UR.RoleId
			Join Common.ModuleDetail As MD On UPN.ModuleDetailId=MD.Id
			Join Common.ModuleMaster As MM On MM.Id=MD.ModuleMasterId
		where MD.PermissionKey=@permissionKey and (RN.IsSystem != 1 OR RN.IsSystem IS NULL) And MM.Name=@moduleName
		and MD.SecondryModuleId = @SecondayModuleId and MD.ModuleMasterId=@ModuleMasterId and MD.CompanyId<>689
		And JSON_VALUE(PERMISSIONS,@position+'.Name') != JSON_VALUE(@nonAdminJSONObj, '$.Name')

END




GO
