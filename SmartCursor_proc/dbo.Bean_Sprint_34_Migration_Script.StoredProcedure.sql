USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Sprint_34_Migration_Script]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

---EXEC Bean_Sprint_34_Migration_Script 244
CREATE PROCEDURE [dbo].[Bean_Sprint_34_Migration_Script]
(
@CompanyId int
)
As
Begin
 
--DECLARE @COAIdList varchar(max)

-----MDPermissionNew for 0 company and Existing company based on companyId
	update Auth.RolePermissionsNew set Permissions='{"Name":"Revaluation","GroupName":"GL","HasTabs":false,"IsPermissionInherited":false,"IsHideTab":false,"Recorder":6,"IsDisable":false,"IsLinkFirstTab":false,"ModuleDetailPermissions":[{"Name":"View","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Add","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Edit","IsApplicable":false,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Disable","IsApplicable":false,"IsMainActions":true,"IsFunctionality":false,"IsChecked":false,"IsReference":false},{"Name":"Void","IsApplicable":true,"IsChecked":true,"IsMainActions":true,"IsReference":false,"IsFunctionality":false}],"Tabs":[]}' where ModuleDetailId=(Select Id from Common.ModuleDetail where ModuleMasterId=(Select Id from Common.ModuleMaster where Name='Bean Cursor') and CompanyId=@CompanyId and Heading='Revaluation') and RoleId in (Select Id from Auth.RoleNew where Name='BC Admin')


-----UserPermission update for existing company
	update Auth.UserPermissionNew set Permissions='{"Name":"Revaluation","GroupName":"GL","ParentId":null,"ModuleDetailId":null,"HasTabs":false,"IsLinkFirstTab":false,"IsPermissionInherited":false,"IsHideTab":false,"Recorder":6,"IsDisable":false,"ModuleMasterId":0,"ModuleDetailPermissions":[{"Name":"View","IsApplicable":true,"IsChecked":true,"ModuleDetailPermissionId":0,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Add","IsApplicable":true,"IsChecked":true,"ModuleDetailPermissionId":0,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Edit","IsApplicable":false,"IsChecked":false,"ModuleDetailPermissionId":0,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Disable","IsApplicable":false,"IsChecked":false,"ModuleDetailPermissionId":0,"IsMainActions":true,"IsReference":false,"IsFunctionality":false},{"Name":"Void","IsApplicable":true,"IsChecked":true,"ModuleDetailPermissionId":0,"IsMainActions":true,"IsReference":false,"IsFunctionality":false}],"Tabs":[]}' where ModuleDetailId=(Select Id from Common.ModuleDetail where ModuleMasterId=(Select Id from Common.ModuleMaster where Name='Bean Cursor') and CompanyId=@CompanyId and Heading='Revaluation') and CompanyUserId in (Select Id from Common.CompanyUser where Username in (Select Username from Common.CompanyUser where CompanyId=@CompanyId and IsAdmin=1) and CompanyId=@CompanyId)

---------Revaluation GRID data

	update Auth.GridMetaData set GridMetaData='[{"template":"<div class=\"checkbox checkboxlable\"><input type=\"checkbox\" id=\"{{dataItem.Id}}\" ng-checked=\"vm.selection.indexOf(dataItem.Id) > -1\" ng-click=\"vm.toggleSelection(dataItem)\"><label for=\"\"></label></div>","width":"50px"},{"field":"DocNo","title":"Doc No","template":"<a href=\"\" ng-click=''vm.getViewMode(dataItem)''>${DocNo}</a>","width":"120px"},{"field":"RevaluationDate","title":"Date","width":"120px","type":"date","template":"<lable>{{dataItem.RevaluationDate | clientZoneDateFormat}}</lable>","filterable":"{ ui: function (element) {element.kendoDatePicker({format: config.dateFormat});}}"},{"field":"NetAmount","title":"Gain/Loss","dataType":"number","attributes":{"class":"text-right"},"template":"<lable title=\"{{dataItem.NetAmount | makeDecimalFormat}}\">{{dataItem.NetAmount | makeDecimalFormat}}</lable>","width":"142px"},{"field":"DocState","title":"State","width":"100px"},{"field":"ServiceCompanyName","title":"Svc Ent","template":"<lable title=\"{{dataItem.ServiceCompanyName}}\">{{dataItem.ServiceCompanyName}}</lable>","width":"100px"},{"field":"UserCreated","title":"Created By","template":"<lable title=\"{{dataItem.UserCreated}}\">{{dataItem.UserCreated}}</lable>","width":"130px"},{"field":"CreatedDate","title":"Created On","dataType":"date","template":"<lable>{{dataItem.CreatedDate | clientZoneDateFormat}}</lable>","width":"130px"}]',Options='{"Void":{"ActionUrl":"","ActionParams":"","Params":[{"key":"Id","DataField":"Id","IsTakeFromGrid":true,"IsTakeFromConfig":false,"value":null},{"key":"CompanyId","DataField":"companyId","IsTakeFromGrid":false,"IsTakeFromConfig":true,"value":null}],"IsAction":true,"IsNavigationSwitch":false,"ActionTitle":"Confirm Void?","ActionMessage":"Are you sure, do you want Void the Revaluation?","module":"bean","screenName":"revaluation","serviceType":"post"}}',APIMethod='{BEAN}/api/v2/revaluation/getallrevaluationk' where Url='/revaluations' and CompanyId=@CompanyId


	--Sprint _ 34
-----------------------
	Update Auth.RolePermissionsNew set Permissions='{"Name":"Chart of Accounts","GroupName":"Settings","HasTabs":false,"IsPermissionInherited":false,"IsHideTab":false,"Recorder":1,"IsDisable":false,"IsLinkFirstTab":false,"ModuleDetailPermissions":[{"Name":"View","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Add","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Edit","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Disable","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Delete","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false}],"Tabs":[]}' 
	Where ModuleDetailId=(select Id from Common.ModuleDetail where GroupName ='Settings' and Heading='Chart of Accounts' and ModuleMasterId in (Select Id from Common.ModuleMaster where Name='Bean Cursor') and CompanyId=@CompanyId)

	Update Auth.UserPermissionNew set Permissions='{"Name":"Chart of Accounts","GroupName":"Settings","HasTabs":false,"IsPermissionInherited":false,"IsHideTab":false,"Recorder":1,"IsDisable":false,"IsLinkFirstTab":false,"ModuleDetailPermissions":[{"Name":"View","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Add","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Edit","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Disable","IsApplicable":true,"IsMainActions":true,"IsFunctionality":false,"IsChecked":true,"IsReference":false},{"Name":"Delete","IsApplicable":true,"IsMainActions":false,"IsFunctionality":false,"IsChecked":true,"IsReference":false}],"Tabs":[]}' 
	Where ModuleDetailId=(select Id from Common.ModuleDetail where GroupName ='Settings' and Heading='Chart of Accounts' and ModuleMasterId in (Select Id from Common.ModuleMaster where Name='Bean Cursor') and CompanyId=@CompanyId)
 


 Update Bean.ChartOfAccount set IsLinkedAccount=1,IsSystem=0 where IsBank=1


 exec [dbo].[Bean_Upadte_LinkedAccounts] @CompanyId
	--SELECT @COAIdList = COALESCE(@COAIdList + ':','') +','+CAST(CI.COAId AS varchar(500))+','+CAST(CI.Id As Varchar(250))
	--from HR.ClaimItem CI
	--Inner Join Bean.ChartOfAccount COA on COA.id=CI.COAId
	--where CI.CompanyId=@CompanyId and COAId is not null and COA.IsLinkedAccount =0


	--IF EXISTS(Select @COAIdList)
	--BEGIN
	--	EXEC COALinkedAccounts_SP SELECT @COAIdList,'ClaimItem','HR Cursor',@CompanyId,(Select UserCreated from Common.Company where Id=@CompanyId and ParentId is Null) 
	--END

	--SELECT @COAIdList = COALESCE(@COAIdList + ':','') +','+CAST(PC.COAId AS varchar(500))+','+CAST(PC.Id As Varchar(250))
	--from HR.PayComponent PC
	--Inner Join Bean.ChartOfAccount COA on COA.id=PC.COAId
	--where PC.CompanyId=@CompanyId and COAId is not null and COA.IsLinkedAccount =0


	--IF EXISTS(Select @COAIdList)
	--BEGIN
	--	EXEC COALinkedAccounts_SP SELECT @COAIdList,'PayComponent','HR Cursor',@CompanyId,(Select UserCreated from Common.Company where Id=@CompanyId and ParentId is Null) 
	--END

	--SELECT @COAIdList = COALESCE(@COAIdList + ':','') +','+CAST(I.COAId AS varchar(500))+','+CAST(I.Id As Varchar(250))
	--from Bean.Item I
	--Inner Join Bean.ChartOfAccount COA on COA.id=I.COAId
	--where I.CompanyId=@CompanyId and I.IsIncidental=1 and COAId is not null and COA.IsLinkedAccount =0


	--IF EXISTS(Select @COAIdList)
	--BEGIN
	--	EXEC COALinkedAccounts_SP SELECT @COAIdList,'Item','Admin Cursor',@CompanyId,(Select UserCreated from Common.Company where Id=@CompanyId and ParentId is Null) 
	--END

	--SELECT @COAIdList = COALESCE(@COAIdList + ':','') +','+CAST(PC.COAId AS varchar(500))+','+CAST(PC.Id As Varchar(250))
	--from Common.Service PC
	--Inner Join Bean.ChartOfAccount COA on COA.id=PC.COAId
	--where PC.CompanyId=@CompanyId and COAId is not null and COA.IsLinkedAccount =0


	--IF EXISTS(Select @COAIdList)
	--BEGIN
	--	EXEC COALinkedAccounts_SP SELECT @COAIdList,'Service','Admin Cursor',@CompanyId,(Select UserCreated from Common.Company where Id=@CompanyId and ParentId is Null) 
	--END

	--SELECT @COAIdList = COALESCE(@COAIdList + ':','') +','+CAST(IT.COAId AS varchar(500))+','+CAST(IT.Id As Varchar(250))
	--from WorkFlow.IncidentalClaimItem IT
	--Inner Join Bean.ChartOfAccount COA on COA.id=IT.COAId
	--where IT.CompanyId=@CompanyId and COAId is not null and COA.IsLinkedAccount =0


	--IF EXISTS(Select @COAIdList)
	--BEGIN
	--	EXEC COALinkedAccounts_SP SELECT @COAIdList,'IncidentalClaimItem','WorkFlow Cursor',@CompanyId,(Select UserCreated from Common.Company where Id=@CompanyId and ParentId is Null) 
	--END


End
GO
