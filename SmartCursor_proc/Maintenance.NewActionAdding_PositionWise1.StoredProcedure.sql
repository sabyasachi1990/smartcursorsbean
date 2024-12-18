USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Maintenance].[NewActionAdding_PositionWise1]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec [Maintenance].NewActionAdding_PositionWise '$.Tabs[0].Actions[12]','workflow_cases_analytics','Workflow Cursor Analytics',17,17,
--'{"Name":"CaseMembersReport","Heading":"Case Members Report","IsApplicable":true,"Chk":true,"Grp":"Action","Typ":"Top"}'


Create procedure [Maintenance].[NewActionAdding_PositionWise1]  
(
@companyId Bigint,
@position nvarchar(2000), -- = '$.Tabs[0].Actions[4]',  
@permissionKey nvarchar(500), -- = 'bean_invoices',   
@moduleName nvarchar(100), -- = 'Bean Cursor', -> To get ModuleMasterId for Common.ModuleDetail  
@ModuleMasterId nvarchar(10), -- = 4,  
@SecondayModuleId nvarchar(10), -- = 4,  
@JsonObj nvarchar(2000) -- ='{"Name":"Delete","Heading":"Delete","IsApplicable":true,"Chk":true,"Grp":"Action","Typ":"Top"}'  
)  
As   
Begin  

declare @json_st nvarchar(max), @json_end nvarchar(max) 
set @json_st ='['+@JsonObj
set @json_end = @JsonObj + ']'

-- Admin Roles  
  --declare @companyId int=689
  print 1

update RPN set Permissions=  
--select 
replace(Replace(Replace(Replace(Replace(JSON_MODIFY(JSON_MODIFY(Permissions, 'append $', JSON_VALUE(Permissions, @position)), @position, JSON_QUERY('['+@JsonObj+','+JSON_QUERY(Permissions, @position)+']')),'},[{','},{'),'}],{','},{'),@json_st,@JsonObj),@json_end,JSON_QUERY(Permissions, @position)),'}]]','}]')
from   
Auth.RolePermissionsNew As RPN   
   Join Auth.RoleNew RN on RN.Id = RPN.RoleId
   Join Common.ModuleDetail As MD On RPN.ModuleDetailId=MD.Id  
   Join Common.ModuleMaster As MM On MM.Id=MD.ModuleMasterId  
   Where MD.PermissionKey=@permissionKey And RN.IsSystem = 1 And MM.Name=@moduleName  
   and MD.SecondryModuleId = @SecondayModuleId and MD.ModuleMasterId=@ModuleMasterId and MD.CompanyId  in(@companyId)
   And JSON_VALUE(PERMISSIONS,@position+'.Heading') != JSON_VALUE(@JsonObj, '$.Heading')  


-- Admin users  

print 2
update UPN set Permissions=  
--select   
replace(Replace(Replace(Replace(Replace(JSON_MODIFY(JSON_MODIFY(Permissions, 'append $', JSON_VALUE(Permissions, @position)), @position, JSON_QUERY('['+@JsonObj+','+JSON_QUERY(Permissions, @position)+']')),'},[{','},{'),'}],{','},{'),@json_st,@JsonObj),@json_end,JSON_QUERY(Permissions, @position)),'}]]','}]')
from  
Auth.UserPermissionNew UPN  
   Join Auth.UserRoleNew UR on UPN.CompanyUserId = UR.CompanyUserId  
   Join Auth.RoleNew RN on RN.Id = UR.RoleId  
   Join Common.ModuleDetail As MD On UPN.ModuleDetailId=MD.Id  
   Join Common.ModuleMaster As MM On MM.Id=MD.ModuleMasterId  
  where MD.PermissionKey=@permissionKey and RN.IsSystem = 1 And MM.Name=@moduleName  
   and MD.SecondryModuleId = @SecondayModuleId and MD.ModuleMasterId=@ModuleMasterId and MD.CompanyId  in(@companyId)
  And JSON_VALUE(PERMISSIONS,@position+'.Name') != JSON_VALUE(@JsonObj, '$.Name')  
  
-- Non Admin Roles  
print 3

--set @JsonObj = Replace(REPLACE(REPLACE(REPLACE(@JsonObj,'  ',' '),' : ',':'),' :',':'),': ',':')
declare @nonAdminJSONObj nvarchar(2000) = Replace(@JsonObj,'"Chk":true','"Chk":false')  
declare @nonAdmin_st nvarchar(max), @nonAdmin_end nvarchar(max)
set @nonAdmin_st = '['+@nonAdminJSONObj
set @nonAdmin_end =@nonAdminJSONObj+']'

update RPN set Permissions=  
--select   
replace(Replace(Replace(Replace(Replace(JSON_MODIFY(JSON_MODIFY(Permissions, 'append $', JSON_VALUE(Permissions, @position)), @position, JSON_QUERY('['+@nonAdminJSONObj+','+JSON_QUERY(Permissions, @position)+']')),'},[{','},{'),'}],{','},{'),@nonAdmin_st,@nonAdminJSONObj),@nonAdmin_end,@nonAdminJSONObj),'}]]','}]')
from  
Auth.RolePermissionsNew As RPN  
   Join Auth.RoleNew RN on RN.Id = RPN.RoleId
   Join Common.ModuleDetail As MD On RPN.ModuleDetailId=MD.Id  
   Join Common.ModuleMaster As MM On MM.Id=MD.ModuleMasterId  
   Where MD.PermissionKey=@permissionKey And (RN.IsSystem != 1 OR RN.IsSystem IS NULL) And MM.Name=@moduleName  
   and MD.SecondryModuleId = @SecondayModuleId and MD.ModuleMasterId=@ModuleMasterId and MD.CompanyId  in(@companyId)
   And JSON_VALUE(PERMISSIONS,@position+'.Name') != JSON_VALUE(@nonAdminJSONObj, '$.Name')  
  
---- Non Admin Users  
  
update UPN set Permissions=  
--select   
replace(Replace(Replace(Replace(Replace(JSON_MODIFY(JSON_MODIFY(Permissions, 'append $', JSON_VALUE(Permissions, @position)), @position, JSON_QUERY('['+@nonAdminJSONObj+','+JSON_QUERY(Permissions, @position)+']')),'},[{','},{'),'}],{','},{'),@nonAdmin_st,@nonAdminJSONObj),@nonAdmin_end,@nonAdminJSONObj),'}]]','}]')
from   
Auth.UserPermissionNew UPN  
   Join Auth.UserRoleNew UR on UPN.CompanyUserId = UR.CompanyUserId  
   Join Auth.RoleNew RN on RN.Id = UR.RoleId  
   Join Common.ModuleDetail As MD On UPN.ModuleDetailId=MD.Id  
   Join Common.ModuleMaster As MM On MM.Id=MD.ModuleMasterId  
  where MD.PermissionKey=@permissionKey and (RN.IsSystem != 1 OR RN.IsSystem IS NULL) And MM.Name=@moduleName  
  and MD.SecondryModuleId = @SecondayModuleId and MD.ModuleMasterId=@ModuleMasterId and MD.CompanyId  in(@companyId)
  And JSON_VALUE(PERMISSIONS,@position+'.Name') != JSON_VALUE(@nonAdminJSONObj, '$.Name')  

print @nonAdminJSONObj

END 






GO
