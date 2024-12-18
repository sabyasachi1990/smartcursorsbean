USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_ROLE_PERMISSIONS_NEW_INSERTION_NEWJSON]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ROLE_PERMISSIONS_NEW_INSERTION_NEWJSON](@NEW_COMPANY_ID BIGINT, @COMPANY_USER_ID BIGINT)
As
begin transaction
begin
begin try

	Declare @UNIQUE_COMPANY_ID bigint=0;
	Declare @ROLE_NAME NVARCHAR(100)
	Declare @MODULE_MASTER_ID BIGINT
	Declare @ROLE_ID UNIQUEIDENTIFIER

	-- ModuleDetail and Initial CursorSetup Creation =======================================

	IF NOT EXISTS(SELECT * FROM Common.ModuleDetail WHERE CompanyId = @NEW_COMPANY_ID)
	BEGIN

		declare @temptable table ([Id] [bigint] NOT NULL,    [ModuleMasterId] [bigint] NOT NULL,    [GroupName] [nvarchar](100) NULL,    [Heading] [nvarchar](100) NOT NULL,    [Description] [nvarchar](1000) NULL,    [LogoId] [uniqueidentifier] NULL,    [CssSprite] [nvarchar](50) NULL,    [FontAwesome] [nvarchar](50) NULL,    [Url] [nvarchar](1000) NULL,    [RecOrder] [int] NULL,    [Remarks] [nvarchar](256) NULL,    [Status] [int] NULL,    [PageUrl] [nvarchar](1000) NOT NULL,    [GroupUrl] [nvarchar](100) NULL,    [CompanyId] [bigint] NOT NULL,    [MasterUrl] [nvarchar](50) NULL,    [ParentId] [bigint] NULL,    [PermissionKey] [nvarchar](50) NULL,    [ModuleName] [nvarchar](100) NULL,    [IsPermissionInherited] [bit] NOT NULL,    [IsHideTab] [bit] NOT NULL,    [SecondryModuleId] [bigint] NULL,    [GroupKey] [nvarchar](100) NULL,    [IsDisable] [bit] NOT NULL,    [IsPartner] [bit] NOT NULL,    [IsMandatory] [int] NULL,    [HelpLink] [nvarchar](256) NULL,    [SetupOrder] [int] NULL,    [Cachekeys] [nvarchar](max) NULL,    [CursorName] [nvarchar](500) NULL,    [IsAnalytics] [bit] NULL,    [IsBot] [bit] NULL,    [DashboardURL] [nvarchar](max) NULL,    [SubGroupName] [nvarchar](100) NULL,    [TabLevel] [int] NULL,    [ModuleDetailId] [nvarchar](100) NULL,    [IsHide] [bit] NULL,    [MongoGroupName] [nvarchar](200) NULL,    [IsTabHide] [bit] NULL,    [IsMenuHide] [bit] NULL,[IsHome] [bit] NULL)

		insert into @temptable  (Id,ModuleMasterId,GroupName,Heading,Description,LogoId,CssSprite,FontAwesome,Url,RecOrder,Remarks,Status,PageUrl,GroupUrl,CompanyId,MasterUrl,ParentId,PermissionKey,ModuleName,IsPermissionInherited,IsHideTab,SecondryModuleId,GroupKey,IsDisable,IsPartner,IsMandatory,HelpLink,SetupOrder,Cachekeys,CursorName,IsAnalytics,IsBot,DashboardURL,SubGroupName,TabLevel,ModuleDetailId,IsHide,MongoGroupName,IsTabHide,IsMenuHide,IsHome)
		select  (SELECT MAX(Id) FROM Common.ModuleDetail)+ROW_NUMBER() OVER(ORDER BY ID)  AS Id,cmd.ModuleMasterId,cmd.GroupName,cmd.Heading,cmd.Description,cmd.LogoId,cmd.CssSprite,cmd.FontAwesome,cmd.Url,cmd.RecOrder,cmd.Remarks,cmd.Status,cmd.PageUrl,cmd.GroupUrl,@NEW_COMPANY_ID,cmd.MasterUrl,cmd.ParentId,cmd.PermissionKey,cmd.ModuleName,cmd.IsPermissionInherited,cmd.IsHideTab,cmd.SecondryModuleId,cmd.GroupKey,cmd.IsDisable,cmd.IsPartner,cmd.IsMandatory,cmd.HelpLink,cmd.SetupOrder,cmd.Cachekeys,cmd.CursorName,cmd.IsAnalytics,cmd.IsBot,cmd.DashboardURL,cmd.SubGroupName,cmd.TabLevel,cmd.ModuleDetailId,cmd.IsHide,cmd.MongoGroupName,cmd.IsTabHide,cmd.IsMenuHide,cmd.IsHome from Common.ModuleDetail As cmd  where cmd.CompanyId=@UNIQUE_COMPANY_ID order by Id;

		insert into Common.ModuleDetail (Id,ModuleMasterId,GroupName,Heading,[Description],LogoId,CssSprite,FontAwesome,[Url],RecOrder,Remarks,[Status],PageUrl,GroupUrl,CompanyId,MasterUrl,ParentId,PermissionKey,ModuleName,IsPermissionInherited,IsHideTab,SecondryModuleId,GroupKey,IsDisable,IsPartner,IsMandatory,HelpLink,SetupOrder,Cachekeys,CursorName,IsAnalytics,IsBot,DashboardURL,SubGroupName,TabLevel,ModuleDetailId,IsHide,MongoGroupName,IsTabHide,IsMenuHide,IsHome)

		select temp.Id,temp.ModuleMasterId,temp.GroupName,temp.Heading,temp.Description,temp.LogoId,temp.CssSprite,temp.FontAwesome,temp.Url,temp.RecOrder,temp.Remarks,temp.Status,temp.PageUrl,temp.GroupUrl,temp.CompanyId,temp.MasterUrl,
		 (select Id from @temptable where 
		 modulemasterid = (select modulemasterid from Common.ModuleDetail where Id=temp.ParentId and companyid=@UNIQUE_COMPANY_ID) and 
		 coalesce(groupname,'ABCD') in (select coalesce(groupname,'ABCD') from Common.ModuleDetail where Id=temp.ParentId and companyid=@UNIQUE_COMPANY_ID) and 
		 PermissionKey=(select PermissionKey from Common.ModuleDetail where Id=temp.ParentId and companyid=@UNIQUE_COMPANY_ID) and 
		 heading in (select heading from Common.ModuleDetail where Id=temp.ParentId and companyid=@UNIQUE_COMPANY_ID)) as ParentId,  
		 		                                  temp.PermissionKey,temp.ModuleName,temp.IsPermissionInherited,temp.IsHideTab,temp.SecondryModuleId,temp.GroupKey,temp.IsDisable,temp.IsPartner,temp.IsMandatory,temp.HelpLink,temp.SetupOrder,temp.Cachekeys,temp.CursorName,temp.IsAnalytics,temp.IsBot,temp.DashboardURL,temp.SubGroupName,temp.TabLevel,temp.ModuleDetailId,temp.IsHide,temp.MongoGroupName,temp.IsTabHide,temp.IsMenuHide,temp.IsHome from @temptable As temp


		------------Doc Cursor ----------

		Exec dbo.DcCsr_MdlDtlId @NEW_COMPANY_ID,@COMPANY_USER_ID

		--------- BR Initial Setup --------

		IF EXISTS (select * from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and ModuleId=(select Id from Common.ModuleMaster where Name='BR Cursor') and Status=1)
		BEGIN
			update Common.CompanyModule  set SetupDone=1 where CompanyId=@NEW_COMPANY_ID and ModuleId=9
			update Common.InitialCursorSetup  set IsSetupDone=1 where CompanyId=@NEW_COMPANY_ID and ModuleId=9
		END


		-- Permission Mapping insertion ===========================================

		--if((select modulemasterId from auth.rolenew where id=@ROLE_ID) = 4)
		--begin
		--delete from auth.permissionsmapping where companyId=1 and modulemasterid=4
		--end

		--================ Permission Mapings =========================

		--insert into Auth.PermissionsMapping (Id,ModuleMasterId,CompanyId,FromModuleDetailId,ToModuleDetailId,FromPermissionName,ToPermissionName,Status) 

		--select NewId(),ModuleMasterId,@NEW_COMPANY_ID, (select Id from Common.ModuleDetail where ISNULL(GroupName,'NULL')=(select ISNULL(GroupName,'NULL') from Common.ModuleDetail where Id=FromModuleDetailId) and ISNULL(Heading,'NULL')=(select ISNULL(Heading,'NULL') from Common.ModuleDetail where Id=FromModuleDetailId) and ISNULL(PermissionKey,0)=(select ISNULL(PermissionKey,0) from Common.ModuleDetail where Id=FromModuleDetailId) and ISNULL(SecondryModuleId,0)=(select ISNULL(SecondryModuleId,0) from Common.ModuleDetail where Id=FromModuleDetailId) and ModuleMasterId=(select ModuleMasterId from Common.ModuleDetail where Id=FromModuleDetailId) and CompanyId=@NEW_COMPANY_ID) as FromModuleDetailId, (select Id from Common.ModuleDetail where ISNULL(GroupName,'NULL')=(select ISNULL(GroupName,'NULL') from Common.ModuleDetail where Id=ToModuleDetailId) and Heading=(select Heading from Common.ModuleDetail where Id=ToModuleDetailId) and ISNULL(PermissionKey,0)=(select ISNULL(PermissionKey,0) from Common.ModuleDetail where Id=ToModuleDetailId) and ISNULL(SecondryModuleId,0)=(select ISNULL(SecondryModuleId,0) from Common.ModuleDetail where Id=ToModuleDetailId)  and ModuleMasterId=(select ModuleMasterId from Common.ModuleDetail where Id=ToModuleDetailId) and CompanyId=@NEW_COMPANY_ID) as ToModuleDetailId,FromPermissionName,ToPermissionName,Status 
		--from  Auth.PermissionsMapping where CompanyId=@UNIQUE_COMPANY_ID


		-- Delete Initial CursorSetup Previously created if any ====================================================================

		IF EXISTS(select * from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID)
		BEGIN
			delete from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID
		END
		
		--============== Initial Setup Creation =========================================================

		INSERT INTO [Common].[InitialCursorSetup] ([Id], [CompanyId], [ModuleId], [ModuleDetailId], [IsSetUpDone],[MainModuleId],[Status],[MasterModuleId],[IsCommonModule])

		SELECT ROW_NUMBER() OVER(ORDER BY ICS.ID) + (SELECT MAX(IC.ID)  FROM [Common].[InitialCursorSetup] as IC), @NEW_COMPANY_ID, ICS.[ModuleId], (select top 1 Id from Common.ModuleDetail where ISNULL(GroupName,'NULL')=(select ISNULL(GroupName,'NULL') from Common.ModuleDetail where Id=ICS.ModuleDetailId) and ISNULL(Heading,'NULL')=(select ISNULL(Heading,'NULL') from Common.ModuleDetail where Id=ICS.ModuleDetailId)  and ModuleMasterId=(select ModuleMasterId from Common.ModuleDetail where Id=ICS.ModuleDetailId) and ISNULL(PermissionKey,0)=(select ISNULL(PermissionKey,0) from Common.ModuleDetail where Id=ICS.ModuleDetailId) and ISNULL(SecondryModuleId,0)=(select ISNULL(SecondryModuleId,0) from Common.ModuleDetail where Id=ICS.ModuleDetailId) and CompanyId=@NEW_COMPANY_ID) as ModuleDetailid, ICS.[IsSetUpDone] as IsSetUpDone,ICS.[MainModuleId],ICS.[Status],ICS.[MasterModuleId],ICS.[IsCommonModule] 
		FROM Common.InitialCursorSetup ICS
		join Common.ModuleDetail MD on Md.Id = ICS.ModuleDetailId		
		where MD.Status = 1 and ICS.CompanyId=@UNIQUE_COMPANY_ID --and ICS.moduledetailId not in (select moduledetailId from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID)
	End
	
	--update Common.CompanyModule  set SetupDone=1 where CompanyId=@NEW_COMPANY_ID and Status=1 and ModuleId in (select Id from Common.ModuleMaster where name in  ('Analytics','Partner Cursor','Dr Finance'))

	update ICS set ICS.Status=CM.Status from Common.InitialCursorSetup ICS
	join Common.CompanyModule CM on ICS.MainModuleId = CM.ModuleId
	where CM.CompanyId=@NEW_COMPANY_ID and ICS.CompanyId=@NEW_COMPANY_ID and ICS.Status<>0

    update MD set MD.Status=CM.Status from Common.ModuleDetail MD
	join Common.CompanyModule CM on MD.SecondryModuleId = CM.ModuleId
	where CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID

	IF EXISTS (select * from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and Status=1)
	BEGIN
			
		Update ICS set ICS.Status = CF.Status from Common.InitialCursorSetup ICS    
		join Common.ModuleDetail MD on MD.Id = ICS.ModuleDetailId
		join Common.Feature F on F.GroupKey = MD.GroupKey
		join Common.CompanyFeatures CF on F.Id = CF.FeatureId
		where CF.CompanyId=@NEW_COMPANY_ID and ICS.CompanyId=@NEW_COMPANY_ID and ICS.Status <> 0

		update Common.GenericTemplate set ispartnerTemplate = 0 where companyId=@NEW_COMPANY_ID and code in ('PaySlip','EmailBody')
		update Common.GenericTemplate set TemplateType='PaySlip' where code ='PaySlip'  and companyId=@NEW_COMPANY_ID
		update Common.GenericTemplate set TemplateType='Email Body' where code ='EmailBody' and companyId=@NEW_COMPANY_ID

	END

	update CM set CM.SetUpDone=1 from Common.companyModule CM where CM.companyId=@NEW_COMPANY_ID and CM.moduleId in
	(select distinct ModuleId from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and IsSetUpDone=1 and Status=1)

	update CM set CM.SetUpDone=0 from Common.companyModule CM where CM.companyId=@NEW_COMPANY_ID and CM.moduleId in
	(select distinct ModuleId from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and IsSetUpDone=0 and Status=1)
	
	IF EXISTS(select * from Common.CompanyModule where CompanyId = @NEW_COMPANY_ID and SetUpDone=0)   
	BEGIN
		update Common.CompanyModule set SetUpDone = 0 where CompanyId=@NEW_COMPANY_ID and ModuleId = (Select Id from Common.ModuleMaster where name ='Admin Cursor')
	END

	if not exists (select * from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and  MainModuleId in (select ModuleId from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and Status=1) and Status <> 0 and IsSetUpDone=0)
	begin
		update Common.CompanyModule set SetUpDone = 1 where CompanyId=@NEW_COMPANY_ID and ModuleId = (Select Id from Common.ModuleMaster where name ='Admin Cursor')
	end

	update Common.InitialCursorSetup set IsCommonModule = 1 where CompanyId=@NEW_COMPANY_ID and ModuleDetailId in (select ModuleDetailId from Common.InitialCursorSetup where CompanyId=0 and IsCommonModule=1)   -- common module update for new copany


	--========== Role Permissions update baed on Cursor wise ===============================

	update Auth.RolePermissionsNew set Status=1 where ModuleDetailId 
	in (
	select Distinct(MD.Id) from Common.CompanyModule CM
	Join Common.ModuleDetail MD on CM.ModuleId = MD.SecondryModuleId
	where CM.Status=1 and CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID)
	and RoleId in (select Id from Auth.RoleNew where CompanyId = @NEW_COMPANY_ID)

	update Auth.RolePermissionsNew set Status=2 where ModuleDetailId 
	in (
	select Distinct(MD.Id) from Common.CompanyModule CM
	Join Common.ModuleDetail MD on CM.ModuleId = MD.SecondryModuleId
	where CM.Status=2 and CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID)
	and RoleId in (select Id from Auth.RoleNew where CompanyId = @NEW_COMPANY_ID)

	--========== User Permissions update baed on Cursor wise ===============================

	update Auth.userpermissionNew set Status=1 where ModuleDetailId 
	in (
	select Distinct(MD.Id) from Common.CompanyModule CM
	Join Common.ModuleDetail MD on CM.ModuleId = MD.SecondryModuleId
	where CM.Status=1 and CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID)
	and CompanyUserId in (select Id from Common.CompanyUser where CompanyId = @NEW_COMPANY_ID)

	update Auth.userpermissionNew set Status=2 where ModuleDetailId 
	in (
	select Distinct(MD.Id) from Common.CompanyModule CM
	Join Common.ModuleDetail MD on CM.ModuleId = MD.SecondryModuleId
	where CM.Status=2 and CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID)
	and CompanyUserId in (select Id from Common.CompanyUser where CompanyId = @NEW_COMPANY_ID)

	--============== Feature wise ModuleDetail & Initial CursorSetup status change ==================

	IF EXISTS (select * from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and Status=1)
	BEGIN					
	
		--=================== Template Seed Data ============================

		--======================== EmailBody

		--if not exists(select * from Common.TemplateType where name='EmailBody' and CompanyId=@NEW_COMPANY_ID)
		--begin
		--	insert into Common.TemplateType (Id, CompanyId, ModuleMasterId, Name,Description, RecOrder, Remarks,Status, Actions) values
		--	(Newid(), @NEW_COMPANY_ID,(select Id from Common.ModuleMaster where name='HR Cursor'), 'EmailBody',NULL,22,NULL,1,NULL)
		--end

		--if not exists(select * from Common.GenericTemplate where /*name='EmailBody' and Code='EmailBody'*/ TemplateType='EmailBody' and CompanyId=@NEW_COMPANY_ID)
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='EmailBody' and CompanyId=@UNIQUE_COMPANY_ID), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, 'System', GETUTCDATE(), null, null, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=0 and Code='EmailBody'
		--end
		
		--================== Training Certificate

		--if not exists(select * from Common.GenericTemplate where /*name='Training Certificate' and Code='Training Certificate' and */  TemplateType='Training Certificate' and CompanyId=@NEW_COMPANY_ID)
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='TrainingCertificate' and CompanyId=@UNIQUE_COMPANY_ID), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, 'System', GETUTCDATE(), null, null, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=0 and Code='Training Certificate'
		--end
		--================== PaySlip

		--if not exists(select * from Common.TemplateType where name='PaySlip' and CompanyId=@NEW_COMPANY_ID)
		--begin
		--	insert into Common.TemplateType (Id, CompanyId, ModuleMasterId, Name,Description, RecOrder, Remarks,Status, Actions) values
		--	(Newid(), @NEW_COMPANY_ID,(select Id from Common.ModuleMaster where name='HR Cursor'), 'PaySlip',NULL,22,NULL,1,NULL)
		--end

		--if not exists(select * from Common.GenericTemplate where /*name='PaySlip' and Code='PaySlip'*/ TemplateType='PaySlip' and CompanyId=@NEW_COMPANY_ID)
		--begin
		--	insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
		--	select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='PaySlip' and CompanyId=@UNIQUE_COMPANY_ID), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, 'System', GETUTCDATE(), null, null, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=0 and Code='PaySlip'
		--end

		update MD set status=2 from Common.ModuleDetail MD
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)

		update MD set status=1 from Common.ModuleDetail MD
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)
		
		update ICS set Status=2 from Common.InitialCursorSetup ICS
		join Common.ModuleDetail MD on ICS.ModuleDetailId = MD.Id
		where ICS.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)

		update ICS set Status=1 from Common.InitialCursorSetup ICS
		join Common.ModuleDetail MD on ICS.ModuleDetailId = MD.Id
		where ICS.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)

		--============== Feature wise Role Permision status updation ===
	
		update auth.rolepermissionsnew set status=2 where moduledetailId in
		(
		select Id from Common.ModuleDetail MD
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)) and roleid in (select Id from auth.rolenew where companyId=@NEW_COMPANY_ID)

		update auth.rolepermissionsnew set status=1 where moduledetailId in
		(
		select Id from Common.ModuleDetail MD
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)) and roleid in (select Id from auth.rolenew where companyId=@NEW_COMPANY_ID)

		--============== Feature wise User Permision status updation ===

		update auth.userpermissionnew set status=2 where moduledetailId in
		(
		select Id from Common.ModuleDetail MD
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)) and CompanyUserId in (select Id from Common.CompanyUser where companyId=@NEW_COMPANY_ID)

		update auth.userpermissionnew set status=1 where moduledetailId in
		(
		select Id from Common.ModuleDetail MD
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)) and CompanyUserId in (select Id from Common.CompanyUser where companyId=@NEW_COMPANY_ID)
					
END
    
	update CM set CM.SetUpDone=1 from Common.CompanyModule CM
	join Common.ModuleMaster MM on CM.ModuleId = MM.Id
	where MM.Name='Super Admin' and CM.CompanyId=@NEW_COMPANY_ID 
  
	-- Roles Insertion --=================================================================

	insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, Status, IsSystem,CreatedDate, UserCreated, BackgroundColor, CursorIcon) 
	select NEWID(), @NEW_COMPANY_ID, Name, ModuleMasterId, 1, 1, GETDATE(), 'System',null,null 
	from Auth.RoleNew where ModuleMasterId in (
	select ModuleId from Common.CompanyModule CM
	join Common.Company C on c.Id = CM.CompanyId
	where c.Id= @NEW_COMPANY_ID and CM.Status=1) and ModuleMasterId  not in (select ModuleMasterId from Auth.RoleNew where CompanyId=@NEW_COMPANY_ID) and CompanyId=@UNIQUE_COMPANY_ID

    -- User Roles Insertion ================================================================

	insert into Auth.UserRoleNew (Id, CompanyUserId, RoleId, RoleName, Username, UserCreated, CreatedDate,Status)
	select NEWID(), @COMPANY_USER_ID, Id, Name,(select firstname from Common.CompanyUser where Id=@COMPANY_USER_ID),'System',GETDATE(),1 from Auth.RoleNew where CompanyId=@NEW_COMPANY_ID and IsSystem=1 and Id not in (select RoleId from Auth.UserRoleNew where CompanyUserId=@COMPANY_USER_ID)

	
end try

BEGIN CATCH
	
	DECLARE
			@ErrorMessage NVARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState INT;

	SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	--ROLLBACK TRANSACTION

end catch
commit transaction
end






















GO
