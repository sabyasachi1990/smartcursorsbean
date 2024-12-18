USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_ROLE_PERMISSIONS_NEW_INSERTION]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ROLE_PERMISSIONS_NEW_INSERTION](@NEW_COMPANY_ID BIGINT, @COMPANY_USER_ID BIGINT)
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

		-- Insert Common.ModuleDetail for Parent Id Is NULL --==============================

		--insert into Common.ModuleDetail ([Id], [ModuleMasterId], [GroupName], [Heading], [Description], [LogoId], [CssSprite], [FontAwesome], [Url], [RecOrder], [Remarks], [Status], [PageUrl], [GroupUrl], [CompanyId], [MasterUrl],[ParentId],[PermissionKey],[ModuleName],[IsDisable],[IsPartner],[IsMandatory],[HelpLink],[SetupOrder],[SecondryModuleId],[TabLevel],[GroupKey])
		
		insert into Common.ModuleDetail ([Id], [ModuleMasterId], [GroupName], [Heading], [Description], [LogoId], [CssSprite], [FontAwesome], [Url], [RecOrder], [Remarks], [Status], [PageUrl], [GroupUrl], [CompanyId], [MasterUrl],[ParentId],[PermissionKey],[ModuleName],[IsDisable],[IsPartner],[IsMandatory],[HelpLink],[SetupOrder],[SecondryModuleId],[TabLevel],[GroupKey], IsPermissionInherited, IsHideTab, Cachekeys, CursorName, IsAnalytics, IsBot, DashboardURL, SubGroupName,  ModuleDetailId)

		select ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) FROM Common.ModuleDetail) AS Id, B.[ModuleMasterId], B.[GroupName], B.[Heading], B.[Description], B.[LogoId], B.[CssSprite], B.[FontAwesome],B.[Url], B.[RecOrder], B.[Remarks], B.[Status], B.[PageUrl], B.[GroupUrl], @NEW_COMPANY_ID, B.[MasterUrl], B.ParentId As ParentId, B.[PermissionKey],B.[ModuleName],B.[IsDisable],B.[IsPartner],B.[IsMandatory],B.[HelpLink],B.[SetupOrder],B.[SecondryModuleId],B.[TabLevel], B.[GroupKey], B.IsPermissionInherited, B.IsHideTab, B.Cachekeys, B.CursorName, B.IsAnalytics, B.IsBot, B.DashboardURL, B.SubGroupName, B.ModuleDetailId
		from Common.ModuleDetail As B  where B.CompanyId=@UNIQUE_COMPANY_ID and B.ParentId is null and B.Status=1
		--and  ISNULL(B.GroupName, 'NULL') in (
		--select  ISNULL(GroupName, 'NULL') from Common.ModuleDetail where CompanyId=@UNIQUE_COMPANY_ID and Heading not in (select distinct Heading from Common.ModuleDetail where CompanyId=@NEW_COMPANY_ID)) and B.Heading not in (select distinct Heading from Common.ModuleDetail where CompanyId=@NEW_COMPANY_ID)

		-- Insert Common.ModuleDetail for Parent Id Is NOT NULL --======= Tabs = Level 1 ==================

		insert into Common.ModuleDetail ([Id], [ModuleMasterId], [GroupName], [Heading], [Description], [LogoId], [CssSprite], [FontAwesome], [Url], [RecOrder], [Remarks], [Status], [PageUrl], [GroupUrl], [CompanyId], [MasterUrl],[ParentId],[PermissionKey],[ModuleName],[IsDisable],[IsPartner],[IsMandatory],[HelpLink],[SetupOrder],[SecondryModuleId],[TabLevel],[GroupKey], IsPermissionInherited, IsHideTab, Cachekeys, CursorName, IsAnalytics, IsBot, DashboardURL, SubGroupName,  ModuleDetailId)

		select ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) FROM Common.ModuleDetail) AS Id, B.[ModuleMasterId], B.[GroupName], B.[Heading], B.[Description], B.[LogoId], B.[CssSprite], B.[FontAwesome],
		B.[Url], B.[RecOrder], B.[Remarks], B.[Status], B.[PageUrl], B.[GroupUrl], @NEW_COMPANY_ID, B.[MasterUrl],
		(select top 1 Id from Common.ModuleDetail where 
		ISNULL(GroupName,'NULL')=(select ISNULL(GroupName,'NULL') from Common.ModuleDetail where id=B.ParentId and Status=1) and 
		ISNULL(Heading,'NULL')=(select ISNULL(Heading,'NULL') from Common.ModuleDetail where id=B.ParentId and Status=1) and 
		ISNULL(PermissionKey,'NULL')=(select ISNULL(PermissionKey,'NULL') from Common.ModuleDetail where Id=B.ParentId and Status=1) and 
		ModuleMasterId = (select ModuleMasterId from Common.ModuleDetail where id=B.ParentId and Status = 1) and 
		ISNULL(SecondryModuleId,0) = (select ISNULL(SecondryModuleId,0) from Common.ModuleDetail where Id=B.ParentId and Status=1) and  CompanyId=@NEW_COMPANY_ID) As ParentId,
		B.[PermissionKey],B.[ModuleName],B.[IsDisable],B.[IsPartner],B.[IsMandatory],B.[HelpLink],B.[SetupOrder],B.[SecondryModuleId], B.[TabLevel], B.GroupKey , B.IsPermissionInherited, B.IsHideTab, B.Cachekeys, B.CursorName, B.IsAnalytics, B.IsBot, B.DashboardURL, B.SubGroupName, B.ModuleDetailId
		from Common.ModuleDetail As B  where B.CompanyId=@UNIQUE_COMPANY_ID and B.TabLevel=1 and B.ParentId is not null  and B.Status=1
		--and ISNULL(B.GroupName, 'NULL') in (
		--select  ISNULL(GroupName, 'NULL') from Common.ModuleDetail where CompanyId=@UNIQUE_COMPANY_ID and Heading not in (select distinct Heading from Common.ModuleDetail where CompanyId=@NEW_COMPANY_ID)) and B.Heading not in (select distinct Heading from Common.ModuleDetail where CompanyId=@NEW_COMPANY_ID)

		-- Insert Common.ModuleDetail for Parent Id Is NOT NULL --======= Tabs = Level 2 ==================

		insert into Common.ModuleDetail ([Id], [ModuleMasterId], [GroupName], [Heading], [Description], [LogoId], [CssSprite], [FontAwesome], [Url], [RecOrder], [Remarks], [Status], [PageUrl], [GroupUrl], [CompanyId], [MasterUrl],[ParentId],[PermissionKey],[ModuleName],[IsDisable],[IsPartner],[IsMandatory],[HelpLink],[SetupOrder],[SecondryModuleId],[TabLevel],[GroupKey], IsPermissionInherited, IsHideTab, Cachekeys, CursorName, IsAnalytics, IsBot, DashboardURL, SubGroupName,  ModuleDetailId)

		select ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) FROM Common.ModuleDetail) AS Id, B.[ModuleMasterId], B.[GroupName], B.[Heading], B.[Description], B.[LogoId], B.[CssSprite], B.[FontAwesome],
		B.[Url], B.[RecOrder], B.[Remarks], B.[Status], B.[PageUrl], B.[GroupUrl], @NEW_COMPANY_ID, B.[MasterUrl],
		(select top 1 Id from Common.ModuleDetail where 
		ISNULL(GroupName,'NULL')=(select ISNULL(GroupName,'NULL') from Common.ModuleDetail where id=B.ParentId and Status=1) and 
		ISNULL(Heading,'NULL')=(select ISNULL(Heading,'NULL') from Common.ModuleDetail where id=B.ParentId and Status=1) and 
		ISNULL(PermissionKey,'NULL')=(select ISNULL(PermissionKey,'NULL') from Common.ModuleDetail where Id=B.ParentId and Status=1) and 
		ModuleMasterId = (select ModuleMasterId from Common.ModuleDetail where id=B.ParentId and Status = 1) and 
		ISNULL(SecondryModuleId,0) = (select ISNULL(SecondryModuleId,0) from Common.ModuleDetail where Id=B.ParentId and Status=1) and CompanyId=@NEW_COMPANY_ID) As ParentId,
		B.[PermissionKey],B.[ModuleName],B.[IsDisable],B.[IsPartner],B.[IsMandatory],B.[HelpLink],B.[SetupOrder],B.[SecondryModuleId], B.[TabLevel], B.GroupKey , B.IsPermissionInherited, B.IsHideTab, B.Cachekeys, B.CursorName, B.IsAnalytics, B.IsBot, B.DashboardURL, B.SubGroupName, B.ModuleDetailId
		from Common.ModuleDetail As B  where B.CompanyId=@UNIQUE_COMPANY_ID and B.TabLevel=2 and B.ParentId is not null and ISNULL(B.GroupName, 'NULL') in (
		select  ISNULL(GroupName, 'NULL') from Common.ModuleDetail where CompanyId=@UNIQUE_COMPANY_ID and Heading not in (select distinct Heading from Common.ModuleDetail where CompanyId=@NEW_COMPANY_ID)) and B.Heading not in (select distinct Heading from Common.ModuleDetail where CompanyId=@NEW_COMPANY_ID)


		------------Doc Cursor ----------


		Exec dbo.DcCsr_MdlDtlId @NEW_COMPANY_ID,@COMPANY_USER_ID

			--------- BR Initial Setup --------

			IF EXISTS (select * from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and ModuleId=(select Id from Common.ModuleMaster where Name='BR Cursor') and Status=1)
	        BEGIN
			   update Common.CompanyModule  set SetupDone=1 where CompanyId=@NEW_COMPANY_ID and ModuleId=9
		       update Common.InitialCursorSetup  set IsSetupDone=1 where CompanyId=@NEW_COMPANY_ID and ModuleId=9
		    END


		-- Permission Mapping insertion ===========================================

		if((select modulemasterId from auth.rolenew where id=@ROLE_ID) = 4)
		begin
			delete from auth.permissionsmapping where companyId=1 and modulemasterid=4
		end

		insert into Auth.PermissionsMapping (Id,ModuleMasterId,CompanyId,FromModuleDetailId,ToModuleDetailId,FromPermissionName,ToPermissionName,Status) 

		select NewId(),ModuleMasterId,@NEW_COMPANY_ID, (select Id from Common.ModuleDetail where ISNULL(GroupName,'NULL')=(select ISNULL(GroupName,'NULL') from Common.ModuleDetail where Id=FromModuleDetailId) and ISNULL(Heading,'NULL')=(select ISNULL(Heading,'NULL') from Common.ModuleDetail where Id=FromModuleDetailId) and ISNULL(PermissionKey,0)=(select ISNULL(PermissionKey,0) from Common.ModuleDetail where Id=FromModuleDetailId) and ISNULL(SecondryModuleId,0)=(select ISNULL(SecondryModuleId,0) from Common.ModuleDetail where Id=FromModuleDetailId) and ModuleMasterId=(select ModuleMasterId from Common.ModuleDetail where Id=FromModuleDetailId) and CompanyId=@NEW_COMPANY_ID) as FromModuleDetailId, (select Id from Common.ModuleDetail where ISNULL(GroupName,'NULL')=(select ISNULL(GroupName,'NULL') from Common.ModuleDetail where Id=ToModuleDetailId) and Heading=(select Heading from Common.ModuleDetail where Id=ToModuleDetailId) and ISNULL(PermissionKey,0)=(select ISNULL(PermissionKey,0) from Common.ModuleDetail where Id=ToModuleDetailId) and ISNULL(SecondryModuleId,0)=(select ISNULL(SecondryModuleId,0) from Common.ModuleDetail where Id=ToModuleDetailId)  and ModuleMasterId=(select ModuleMasterId from Common.ModuleDetail where Id=ToModuleDetailId) and CompanyId=@NEW_COMPANY_ID) as ToModuleDetailId,FromPermissionName,ToPermissionName,Status 
		from  Auth.PermissionsMapping where CompanyId=@UNIQUE_COMPANY_ID


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
		where MD.Status = 1 and ICS.CompanyId=@UNIQUE_COMPANY_ID --and ICS.MainModuleId not in (select MainModuleId from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID)


	End

	--============== Initial Setup Creation =========================================================

	--INSERT INTO [Common].[InitialCursorSetup] ([Id], [CompanyId], [ModuleId], [ModuleDetailId], [IsSetUpDone],[MainModuleId],[Status],[MasterModuleId],[IsCommonModule])

	--SELECT ROW_NUMBER() OVER(ORDER BY ICS.ID) + (SELECT MAX(IC.ID)  FROM [Common].[InitialCursorSetup] as IC), @NEW_COMPANY_ID, ICS.[ModuleId], (select top 1 Id from Common.ModuleDetail where ISNULL(GroupName,'NULL')=(select ISNULL(GroupName,'NULL') from Common.ModuleDetail where Id=ICS.ModuleDetailId) and ISNULL(Heading,'NULL')=(select ISNULL(Heading,'NULL') from Common.ModuleDetail where Id=ICS.ModuleDetailId)  and ModuleMasterId=(select ModuleMasterId from Common.ModuleDetail where Id=ICS.ModuleDetailId) and ISNULL(PermissionKey,0)=(select ISNULL(PermissionKey,0) from Common.ModuleDetail where Id=ICS.ModuleDetailId) and ISNULL(SecondryModuleId,0)=(select ISNULL(SecondryModuleId,0) from Common.ModuleDetail where Id=ICS.ModuleDetailId) and CompanyId=@NEW_COMPANY_ID) as ModuleDetailid, ICS.[IsSetUpDone] as IsSetUpDone,ICS.[MainModuleId],1,ICS.[MasterModuleId],ICS.[IsCommonModule] 
	--FROM Common.InitialCursorSetup ICS
	--join Common.ModuleDetail MD on Md.Id = ICS.ModuleDetailId
	--join Common.CompanyModule CM on CM.ModuleId = ICS.MainModuleId
	--where MD.Status = 1 and CM.Status=1 and CM.CompanyId=@NEW_COMPANY_ID and ICS.CompanyId=@UNIQUE_COMPANY_ID and ICS.MainModuleId not in (select MainModuleId from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID)


	--============== Initial Setup status Update based on Company Module Status =========================================================

	--update ICS set ICS.Status=1 from Common.InitialCursorSetup ICS
	--join Common.CompanyModule CM on ICS.MainModuleId = CM.ModuleId
	--where CM.Status=1 and CM.CompanyId=@NEW_COMPANY_ID and ICS.CompanyId=@NEW_COMPANY_ID and ICS.Status<>0

	--update ICS set ICS.Status=2 from Common.InitialCursorSetup ICS
	--join Common.CompanyModule CM on ICS.MainModuleId = CM.ModuleId
	--where CM.Status=2 and CM.CompanyId=@NEW_COMPANY_ID and ICS.CompanyId=@NEW_COMPANY_ID and ICS.Status<>0
	
	--///////////-- Modified Query --///////----
	
	update ICS set ICS.Status=CM.Status from Common.InitialCursorSetup ICS
	join Common.CompanyModule CM on ICS.MainModuleId = CM.ModuleId
	where CM.CompanyId=@NEW_COMPANY_ID and ICS.CompanyId=@NEW_COMPANY_ID and ICS.Status<>0

	--select * from Common.InitialCursorSetup where MainModuleId in (select ModuleId from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and Status=2) and Status<>0 and CompanyId=@NEW_COMPANY_ID

	IF EXISTS (select * from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and Status=1)
	BEGIN

		-- updating the initialSetup status = 1 for the @NewCompany based on feature

		--Update ICS set ICS.Status = 1 from Common.InitialCursorSetup ICS    
		--join Common.ModuleDetail MD on MD.Id = ICS.ModuleDetailId
		--join Common.Feature F on F.GroupKey = MD.GroupKey
		--join Common.CompanyFeatures CF on F.Id = CF.FeatureId
		--where CF.CompanyId=@NEW_COMPANY_ID and ICS.CompanyId=@NEW_COMPANY_ID and CF.Status=1 and ICS.Status <> 0
		
		-- updating the initialSetup status = 2 for the @NewCompany based on feature
		
		--Update ICS set ICS.Status = 2 from Common.InitialCursorSetup ICS    
		--join Common.ModuleDetail MD on MD.Id = ICS.ModuleDetailId
		--join Common.Feature F on F.GroupKey = MD.GroupKey
		--join Common.CompanyFeatures CF on F.Id = CF.FeatureId
		--where CF.CompanyId=@NEW_COMPANY_ID and ICS.CompanyId=@NEW_COMPANY_ID and CF.Status=2 and ICS.Status <> 0
		
		--///////////-- Modified Query --///////----
		Update ICS set ICS.Status = CF.Status from Common.InitialCursorSetup ICS    
		join Common.ModuleDetail MD on MD.Id = ICS.ModuleDetailId
		join Common.Feature F on F.GroupKey = MD.GroupKey
		join Common.CompanyFeatures CF on F.Id = CF.FeatureId
		where CF.CompanyId=@NEW_COMPANY_ID and ICS.CompanyId=@NEW_COMPANY_ID and ICS.Status <> 0

		update Common.GenericTemplate set ispartnerTemplate = 0 where companyId=@NEW_COMPANY_ID and code in ('PaySlip','EmailBody')
		update Common.GenericTemplate set TemplateType='PaySlip' where code ='PaySlip'  and companyId=@NEW_COMPANY_ID
		update Common.GenericTemplate set TemplateType='EmailBody' where code ='EmailBody' and companyId=@NEW_COMPANY_ID

	END

	update CM set CM.SetUpDone=1 from Common.companyModule CM where CM.companyId=@NEW_COMPANY_ID and CM.moduleId in
	(select distinct ModuleId from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and IsSetUpDone=1 and Status=1)

	update CM set CM.SetUpDone=0 from Common.companyModule CM where CM.companyId=@NEW_COMPANY_ID and CM.moduleId in
	(select distinct ModuleId from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and IsSetUpDone=0 and Status=1)

	-- ModuleDetail Status update based on Cursor Activation ============================

	
	--update MD set MD.Status=2 from Common.ModuleDetail MD
	--join Common.CompanyModule CM on MD.SecondryModuleId = CM.ModuleId
	--where CM.Status=2 and CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID --and MD.Status=1

	--update MD set MD.Status=1 from Common.ModuleDetail MD
	--join Common.CompanyModule CM on MD.SecondryModuleId = CM.ModuleId
	--where CM.Status=1 and CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID --and MD.Status=1

	--///////////-- Modified Query --///////----

	update MD set MD.Status=CM.Status from Common.ModuleDetail MD
	join Common.CompanyModule CM on MD.SecondryModuleId = CM.ModuleId
	where CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID

	--============== Feature wise ModuleDetail & Initial CursorSetup status change ==================

	IF EXISTS (select * from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and Status=1)
	BEGIN					
		
		--======================== EmailBody

		if not exists(select * from Common.TemplateType where name='EmailBody' and CompanyId=@NEW_COMPANY_ID)
		begin
			insert into Common.TemplateType (Id, CompanyId, ModuleMasterId, Name,Description, RecOrder, Remarks,Status, Actions) values
			(Newid(), @NEW_COMPANY_ID,(select Id from Common.ModuleMaster where name='HR Cursor'), 'EmailBody',NULL,22,NULL,1,NULL)
		end

		if not exists(select * from Common.GenericTemplate where name='EmailBody' and Code='EmailBody' and CompanyId=@NEW_COMPANY_ID)
		begin
			insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
			select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='EmailBody' and CompanyId=@NEW_COMPANY_ID), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=0 and Code='EmailBody'
		end

		--================== PaySlip

		if not exists(select * from Common.TemplateType where name='PaySlip' and CompanyId=@NEW_COMPANY_ID)
		begin
			insert into Common.TemplateType (Id, CompanyId, ModuleMasterId, Name,Description, RecOrder, Remarks,Status, Actions) values
			(Newid(), @NEW_COMPANY_ID,(select Id from Common.ModuleMaster where name='HR Cursor'), 'PaySlip',NULL,22,NULL,1,NULL)
		end

		if not exists(select * from Common.GenericTemplate where name='PaySlip' and Code='PaySlip' and CompanyId=@NEW_COMPANY_ID)
		begin
			insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate) 
			select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='PaySlip' and CompanyId=@NEW_COMPANY_ID), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=0 and Code='PaySlip'
		end

		update MD set status=2 from Common.ModuleDetail MD
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)

		update MD set status=1 from Common.ModuleDetail MD
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)
		
		--///////////-- Modified Query --///////----
		--update MD Set Md.Status =A.status from Common.ModuleDetail MD
		--Inner Join
		--(select f.GroupKey,Cf.Status from Common.CompanyFeatures CF
		--left join Common.Feature F on cf.FeatureId = F.Id 
		--Where CF.CompanyId=@NEW_COMPANY_ID and 
		--F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') ) As A on A.GroupKey=MD.GroupKey 
		--where MD.CompanyId=@NEW_COMPANY_ID 

		---//////////----
		--Update ICS Set ICS.Status=A.status From Common.InitialCursorSetup ICS
		--Inner Join Common.ModuleDetail MD on ICS.ModuleDetailId = MD.Id
		--inner join (select f.GroupKey,Cf.Status from Common.CompanyFeatures CF
		--left join Common.Feature F on cf.FeatureId = F.Id 
		--where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor')) As A On A.GroupKey=MD.GroupKey
		--where ICS.CompanyId=@NEW_COMPANY_ID

		-----///////////////-----------
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
					
	END

	-- Roles Insertion --=================================================================

	insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, Status, IsSystem,CreatedDate, UserCreated, BackgroundColor, CursorIcon) 
	select NEWID(), @NEW_COMPANY_ID, Name, ModuleMasterId, 1, 1, GETDATE(), 'System',null,null 
	from Auth.RoleNew where ModuleMasterId in (
	select ModuleId from Common.CompanyModule CM
	join Common.Company C on c.Id = CM.CompanyId
	where c.Id= @NEW_COMPANY_ID and CM.Status=1) and ModuleMasterId  not in (select ModuleMasterId from Auth.RoleNew where CompanyId=@NEW_COMPANY_ID) and CompanyId=@UNIQUE_COMPANY_ID

	Declare role_cursor cursor for 
		select Id,Name, ModuleMasterId from Auth.RoleNew where CompanyId=@NEW_COMPANY_ID and Status=1 --and name != 'Doc Admin' --and IsSystem=1 
	Open role_cursor
	FETCH NEXT FROM role_cursor into @ROLE_ID,@ROLE_NAME,@MODULE_MASTER_ID
	WHILE @@FETCH_STATUS = 0
		BEGIN
		     print @ROLE_NAME
			-- Role Permisssion Insertion --==========================================

			--insert into Auth.RolePermissionsNew (Id, RoleId, ModuleDetailId, Permissions, Status, IsSeedData)
			--select NEWID(), @ROLE_ID, ModuleDetailId, Permissions, Status, 1 from Auth.RolePermissionsNew where IsSeedData=1 and RoleId in 
			--(select Id from Auth.RoleNew where ModuleMasterId in (
			--select ModuleId from Common.CompanyModule CM
			--join Common.Company C on c.Id = CM.CompanyId
			--where c.Id= @NEW_COMPANY_ID and CM.Status=1) and ModuleMasterId  not in ((select distinct R.ModuleMasterId from Auth.RoleNew R Join Auth.RolePermissionsNew RP on R.Id = Rp.RoleId where R.CompanyId=@NEW_COMPANY_ID group by Rp.RoleId, R.ModuleMasterId)) and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=@MODULE_MASTER_ID and Name=@ROLE_NAME)

			if((select IsSystem from auth.rolenew where Id=@ROLE_ID) = 1)
			begin
				
				if Exists(select * from auth.RoleNew where Id=@ROLE_ID and IsSystem=1)
				BEGIN
					delete from auth.rolepermissionsnew where roleId = @ROLE_ID and moduledetailid in (select Id from common.moduledetail where (SecondryModuleId=@MODULE_MASTER_ID OR ModuleMasterId=@MODULE_MASTER_ID) and companyId=@NEW_COMPANY_ID)
				END

				--insert into Auth.RolePermissionsNew (Id, RoleId, ModuleDetailId, Permissions, Status, IsSeedData)
	
				--select NEWID(), @ROLE_ID, (select top 1 Id from Common.ModuleDetail where ISNULL(GroupName,'NULL')=(select ISNULL(GroupName,'NULL') from Common.ModuleDetail where Id=RPN.ModuleDetailId) and Heading=(select Heading from Common.ModuleDetail where Id=RPN.ModuleDetailId)  and ModuleMasterId=(select ModuleMasterId from Common.ModuleDetail where Id=RPN.ModuleDetailId) and ISNULL(PermissionKey,0)=(select ISNULL(PermissionKey,0) from Common.ModuleDetail where Id=RPN.ModuleDetailId) and ISNULL(SecondryModuleId,0)=(select ISNULL(SecondryModuleId,0) from Common.ModuleDetail where Id=RPN.ModuleDetailId) and CompanyId=@NEW_COMPANY_ID) as ModuleDetailid, RPN.Permissions, RPN.Status, RPN.IsSeedData 
				--from Auth.RolePermissionsNew RPN
				--join Common.ModuleDetail MD on MD.Id = RPN.ModuleDetailId
				--	where MD.Status = 1 and RPN.IsSeedData=1 and RPN.Status=1 and RPN.RoleId in 
				--(select Id from Auth.RoleNew where /*name like '%Admin%' and*/ Status=1 and ModuleMasterId in (
				--select ModuleId from Common.CompanyModule CM
				--join Common.Company C on c.Id = CM.CompanyId
				--where c.Id= @NEW_COMPANY_ID and CM.Status=1) and ModuleMasterId  not in ((select distinct R.ModuleMasterId from Auth.RoleNew R Join Auth.RolePermissionsNew RP on R.Id = Rp.RoleId where R.CompanyId=@NEW_COMPANY_ID group by Rp.RoleId, R.ModuleMasterId)) and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=@MODULE_MASTER_ID and Name=@ROLE_NAME)
			

				insert into Auth.RolePermissionsNew (Id, RoleId, ModuleDetailId, Permissions, Status, IsSeedData)
				Select Id,Id2,ModuleDetailid,Permissions,Status, IsSeedData  From
				(
				select NEWID() As Id, @ROLE_ID As Id2, 
				(select top 1 Id from Common.ModuleDetail where ISNULL(GroupName,'NULL')=(select ISNULL(GroupName,'NULL') from Common.ModuleDetail where Id=RPN.ModuleDetailId) and Heading=(select Heading from Common.ModuleDetail where Id=RPN.ModuleDetailId) and ModuleMasterId=(select ModuleMasterId from Common.ModuleDetail where Id=RPN.ModuleDetailId) and ISNULL(PermissionKey,0)=(select ISNULL(PermissionKey,0) 
				from Common.ModuleDetail 
				where Id=RPN.ModuleDetailId) and ISNULL(SecondryModuleId,0)=(select ISNULL(SecondryModuleId,0) from Common.ModuleDetail where Id=RPN.ModuleDetailId) and CompanyId=@NEW_COMPANY_ID) as ModuleDetailid, RPN.Permissions, RPN.Status, RPN.IsSeedData 
				from Auth.RolePermissionsNew RPN
				join Common.ModuleDetail MD on MD.Id = RPN.ModuleDetailId
				where MD.Status = 1 and RPN.IsSeedData=1 and RPN.Status=1 
				and RPN.RoleId in 
				(select Id from Auth.RoleNew where /*name like '%Admin%' and*/ Status=1 and ModuleMasterId in (
				select ModuleId from Common.CompanyModule CM
				join Common.Company C on c.Id = CM.CompanyId
				where c.Id= @NEW_COMPANY_ID and CM.Status=1) and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=@MODULE_MASTER_ID and Name=@ROLE_NAME)
				--and RPN.ModuleDetailId in (select ModuleDetailId from auth.rolepermissionsnew where roleId='8f520b36-3409-40dd-b636-39a03576ac5e')
				) As A
				Where A.ModuleDetailid not in (select ModuleDetailId from auth.rolepermissionsnew where roleId=@ROLE_ID)



				-- User Roles insertion --================================================

				insert into Auth.UserRoleNew (Id, CompanyUserId, RoleId, RoleName, Username, UserCreated, CreatedDate,Status)
				select NEWID(),@COMPANY_USER_ID,@ROLE_ID,@ROLE_NAME,(select Name from Common.CompanyUser where Id=@COMPANY_USER_ID) ,'System',GETDATE(),1 from Auth.RoleNew where CompanyId=@NEW_COMPANY_ID and name=@ROLE_NAME and Id not in (select RoleId from Auth.UserRoleNew where CompanyUserId=@COMPANY_USER_ID)
			
			end
			else --if(((select IsSystem from auth.rolenew where Id=@ROLE_ID) = 0) OR ((select IsSystem from auth.rolenew where Id=@ROLE_ID) IS NULL))
			begin

				--insert into Auth.RolePermissionsNew (Id, RoleId, ModuleDetailId, Permissions, Status, IsSeedData)	
				--select NEWID(), @ROLE_ID, RPN.ModuleDetailId as ModuleDetailid, Replace(RPN.Permissions, '"IsChecked":true', '"IsChecked":false') as permissions , RPN.Status, RPN.IsSeedData 
				--from Auth.RolePermissionsNew RPN
				----join Common.ModuleDetail MD on MD.Id = RPN.ModuleDetailId
				--where /*MD.Status = 1 and*/ RPN.IsSeedData=1 and RPN.Status=1 and RPN.RoleId in 
				--(select Id from Auth.RoleNew where /*name like '%Admin%' and*/ Status=1 and ModuleMasterId in (
				--select ModuleId from Common.CompanyModule CM
				--join Common.Company C on c.Id = CM.CompanyId
				--where c.Id= @NEW_COMPANY_ID and CM.Status=1) and CompanyId=@NEW_COMPANY_ID and ModuleMasterId=@MODULE_MASTER_ID and Id=(select Id from auth.rolenew where ModuleMasterId=@MODULE_MASTER_ID and CompanyId=@NEW_COMPANY_ID and IsSystem=1) and ModuleDetailId not in (select ModuleDetailId from Auth.RolePermissionsNew where roleId=@ROLE_ID))

				insert into Auth.RolePermissionsNew (Id, RoleId, ModuleDetailId, Permissions, Status, IsSeedData)
				Select Id,Id2,ModuleDetailid,Replace(Permissions, '"IsChecked":true', '"IsChecked":false') as permissions,Status, IsSeedData  From
				(
				select NEWID() As Id, @ROLE_ID As Id2, 
				(select top 1 Id from Common.ModuleDetail where ISNULL(GroupName,'NULL')=(select ISNULL(GroupName,'NULL') from Common.ModuleDetail where Id=RPN.ModuleDetailId) and Heading=(select Heading from Common.ModuleDetail where Id=RPN.ModuleDetailId) and ModuleMasterId=(select ModuleMasterId from Common.ModuleDetail where Id=RPN.ModuleDetailId) and ISNULL(PermissionKey,0)=(select ISNULL(PermissionKey,0) 
				from Common.ModuleDetail 
				where Id=RPN.ModuleDetailId) and ISNULL(SecondryModuleId,0)=(select ISNULL(SecondryModuleId,0) from Common.ModuleDetail where Id=RPN.ModuleDetailId) and CompanyId=@NEW_COMPANY_ID) as ModuleDetailid, RPN.Permissions, RPN.Status, RPN.IsSeedData 
				from Auth.RolePermissionsNew RPN
				join Common.ModuleDetail MD on MD.Id = RPN.ModuleDetailId
				where MD.Status = 1 and RPN.IsSeedData=1 and RPN.Status=1 
				and RPN.RoleId in 
				(select Id from Auth.RoleNew where /*name like '%Admin%' and*/ Status=1 and ModuleMasterId in (
				select ModuleId from Common.CompanyModule CM
				join Common.Company C on c.Id = CM.CompanyId
				where c.Id= @NEW_COMPANY_ID and CM.Status=1) and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=@MODULE_MASTER_ID and Name=(select top 1 name from Auth.RoleNew where companyId=@NEW_COMPANY_ID and ModuleMasterId=@MODULE_MASTER_ID and IsSystem=1))
				--and RPN.ModuleDetailId in (select ModuleDetailId from auth.rolepermissionsnew where roleId='8f520b36-3409-40dd-b636-39a03576ac5e')
				) As A
				Where A.ModuleDetailid not in (select ModuleDetailId from auth.rolepermissionsnew where roleId=@ROLE_ID)

			end
			FETCH NEXT FROM role_cursor INTO @ROLE_ID,@ROLE_NAME,@MODULE_MASTER_ID
		End
	Close role_cursor
	Deallocate role_cursor

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
