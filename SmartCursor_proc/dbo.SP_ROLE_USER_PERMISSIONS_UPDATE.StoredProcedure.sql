USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_ROLE_USER_PERMISSIONS_UPDATE]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[SP_ROLE_USER_PERMISSIONS_UPDATE](@NEW_COMPANY_ID bigint, @UNIQUE_COMPANY_ID bigint)
AS
BEGIN
    BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @ModuleId bigint
		DECLARE MOduleMasterCursor CURSOR FOR SELECT ID FROM Common.ModuleMaster where companyId=@UNIQUE_COMPANY_ID order by ID desc
		OPEN MOduleMasterCursor
		FETCH NEXT FROM MOduleMasterCursor INTO @ModuleId
		WHILE(@@FETCH_STATUS = 0)
		BEGIN
			IF EXISTS((SELECT * FROM common.companyMOdule where companyId=@NEW_COMPANY_ID AND ModuleId = @ModuleId and Status=1))
			BEGIN
				DECLARE @IsRoleInActive bit = 0
				IF (@ModuleId <> (select Id from Common.ModuleMaster where Name = 'HR Cursor'))    -- except HR
				BEGIN
					IF EXISTS (select * from auth.RolePermission where RoleId in (select Id from auth.Role where CompanyId=@NEW_COMPANY_ID 
								and ModuleMasterId=@moduleId))    -- If cursor / Module is activated now, adding the role permissions from 0 company
					BEGIN
					    SET @IsRoleInActive = 1
						--update Auth.Role set Status = 1 where CompanyId=@NEW_COMPANY_ID and ModuleMasterId=@moduleId

						update Auth.Role set CursorStatus = 1 where CompanyId=@NEW_COMPANY_ID and ModuleMasterId=@moduleId
					   
						update Auth.RolePermission set Status=1 where RoleId in  (select Id from auth.Role where CompanyId=@NEW_COMPANY_ID 
						and ModuleMasterId=@moduleId)

						--update Auth.UserRole set Status = 1 where RoleId in ((select Id from auth.Role where CompanyId=@NEW_COMPANY_ID and ModuleMasterId=@ModuleId)) and CompanyUserId in (select Id from Common.CompanyUser where CompanyId=@NEW_COMPANY_ID and IsAdmin = 1)

						update Auth.UserPermission set Status= 1 where RoleId in ((select Id from auth.Role where CompanyId=@NEW_COMPANY_ID and ModuleMasterId=@ModuleId)) and CompanyUserId in (select Id from Common.CompanyUser where CompanyId=@NEW_COMPANY_ID and IsAdmin = 1)
					END
				END
				ELSE  -- only for HR because of Features exist in HR only.
				BEGIN
					IF EXISTS (select rp.* from Auth.RolePermission rp
								join Auth.Role r on r.Id = rp.RoleId
								join Auth.ModuleDetailPermission mdp on mdp.Id = rp.ModuleDetailPermissionId
								join Common.ModuleDetail md on md.Id = mdp.ModuleDetailId
								where r.CompanyId=@NEW_COMPANY_ID and md.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
								left join Common.Feature F on cf.FeatureId = F.Id 
								where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=@moduleId and cf.Status = 1))    -- for Activated features in HR
					BEGIN
						SET @IsRoleInActive = 1
						
						--update Auth.Role set Status = 1 where CompanyId=@NEW_COMPANY_ID and ModuleMasterId=@moduleId

						update Auth.Role set CursorStatus = 1 where CompanyId=@NEW_COMPANY_ID and ModuleMasterId=@moduleId

						update Auth.RolePermission set Status=1 where RoleId in  (select Id from auth.Role where CompanyId=@NEW_COMPANY_ID 
						and ModuleMasterId=@moduleId)

						--update Auth.UserRole set Status = 1 where RoleId in ((select Id from auth.Role where CompanyId=@NEW_COMPANY_ID and ModuleMasterId=@ModuleId)) and CompanyUserId in (select Id from Common.CompanyUser where CompanyId=@NEW_COMPANY_ID and IsAdmin = 1)

						update Auth.UserPermission set Status= 1 where RoleId in ((select Id from auth.Role where CompanyId=@NEW_COMPANY_ID and ModuleMasterId=@ModuleId)) and CompanyUserId in (select Id from Common.CompanyUser where CompanyId=@NEW_COMPANY_ID and IsAdmin = 1)

						update rp set rp.Status = 1 from Auth.RolePermission rp
						join Auth.Role r on r.Id = rp.RoleId
						join Auth.ModuleDetailPermission mdp on mdp.Id = rp.ModuleDetailPermissionId
						join Common.ModuleDetail md on md.Id = mdp.ModuleDetailId
						where r.CompanyId=@NEW_COMPANY_ID and md.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
						left join Common.Feature F on cf.FeatureId = F.Id 
						where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=@moduleId and cf.Status = 1)
 
						update up set up.Status=1 from Auth.UserPermission up
						join Auth.Role r on r.Id = up.RoleId
						join Auth.ModuleDetailPermission mdp on mdp.Id = up.ModuleDetailPermissionId
						join Common.ModuleDetail md on md.Id = mdp.ModuleDetailId
						where r.CompanyId=@NEW_COMPANY_ID and up.CompanyUserId in (select Id from Common.CompanyUser where CompanyId=@NEW_COMPANY_ID and IsAdmin = 1) and md.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
						join Common.Feature F on cf.FeatureId = F.Id 
						where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=@ModuleId and cf.Status = 1)
						
					END
					IF exists(select rp.* from Auth.RolePermission rp
									join Auth.Role r on r.Id = rp.RoleId
									join Auth.ModuleDetailPermission mdp on mdp.Id = rp.ModuleDetailPermissionId
									join Common.ModuleDetail md on md.Id = mdp.ModuleDetailId
									where r.CompanyId=@NEW_COMPANY_ID and md.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
									left join Common.Feature F on cf.FeatureId = F.Id 
									where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=@moduleId and cf.Status <> 1))  -- for inActivated / unchecked features
					BEGIN
						IF(@IsRoleInActive = 0 AND ((select count(*) from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and Status=1 and ModuleId=@ModuleId) = 0))
						BEGIN
							update Auth.Role set Status=3 where id in (select Id from auth.Role where CompanyId=@NEW_COMPANY_ID 
							and ModuleMasterId=@moduleId)
						END
						update rp set rp.Status = 2 from Auth.RolePermission rp
						join Auth.Role r on r.Id = rp.RoleId
						join Auth.ModuleDetailPermission mdp on mdp.Id = rp.ModuleDetailPermissionId
						join Common.ModuleDetail md on md.Id = mdp.ModuleDetailId
						where r.CompanyId=@NEW_COMPANY_ID and md.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
						left join Common.Feature F on cf.FeatureId = F.Id 
						where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=@moduleId and cf.Status <> 1)

						update up set up.status=2 from Auth.UserPermission up
						join Auth.Role r on r.Id = up.RoleId
						join Auth.ModuleDetailPermission mdp on mdp.Id = up.ModuleDetailPermissionId
						join Common.ModuleDetail md on md.Id = mdp.ModuleDetailId
						where r.CompanyId=@NEW_COMPANY_ID and up.CompanyUserId in (select Id from Common.CompanyUser where CompanyId=@NEW_COMPANY_ID and IsAdmin = 1) and md.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
						join Common.Feature F on cf.FeatureId = F.Id 
						where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=@moduleId and cf.Status <> 1)
					END
				END
			END
			ELSE
			BEGIN   -- If module is previously activated now its inactivated then change the role permissions status = 2
				IF EXISTS (select rp.* from auth.rolepermission rp 
				join auth.Role r on r.id = rp.roleid 
				where r.companyId=@NEW_COMPANY_ID and r.Id in (select Id from auth.Role where CompanyId=@NEW_COMPANY_ID 
				and ModuleMasterId=@moduleId))
				BEGIN
				    
					--update Auth.Role set Status=3 where id in (select Id from auth.Role where CompanyId=@NEW_COMPANY_ID 
					--and ModuleMasterId=@moduleId)

					update Auth.Role set CursorStatus=0 where id in (select Id from auth.Role where CompanyId=@NEW_COMPANY_ID 
					and ModuleMasterId=@moduleId)
				   
				   	--update Auth.UserRole set status = 2 where RoleId in ((select Id from auth.Role where CompanyId=@NEW_COMPANY_ID and ModuleMasterId=@moduleId)) and CompanyUserId in (select Id from Common.CompanyUser where CompanyId=@NEW_COMPANY_ID and IsAdmin = 1)

					update rp set status = 2 from auth.rolepermission rp 
					join auth.Role r on r.id = rp.roleid 
					where r.companyId=@NEW_COMPANY_ID and r.Id in (select Id from auth.Role where CompanyId=@NEW_COMPANY_ID 
					and ModuleMasterId=@moduleId and Status=1)

					update Auth.UserPermission set Status=2 where RoleId in ((select Id from auth.Role where CompanyId=@NEW_COMPANY_ID and Status = 1 and ModuleMasterId=@moduleId)) and CompanyUserId in (select Id from Common.CompanyUser where CompanyId=@NEW_COMPANY_ID and IsAdmin = 1)
				
				END
				ELSE     -- for KNOWLEDGE and DOC cursors. for those 2 cursors ROLES are exist but there is no ROLEPERMISSIONS
				BEGIN    
					update Auth.Role set CursorStatus=0 where id in (select Id from auth.Role where CompanyId=@NEW_COMPANY_ID 
					and ModuleMasterId=@moduleId)
				END
			END
			FETCH NEXT FROM MOduleMasterCursor INTO @ModuleId
		END
		CLOSE MOduleMasterCursor
		DEALLOCATE MOduleMasterCursor

		IF EXISTS(SELECT * FROM Common.Company WHERE Id=@NEW_COMPANY_ID AND IsACCountingFirm=1)    -- for Partner purpose
		BEGIN

		    DECLARE @ModuleId_Partner bigint = (select Id from common.modulemaster where name='Partner Cursor')
			update Auth.Role set CursorStatus = 1 where CompanyId=@NEW_COMPANY_ID and ModuleMasterId=@ModuleId_Partner
			update Auth.RolePermission set Status=1 where RoleId in  (select Id from auth.Role where CompanyId=@NEW_COMPANY_ID 
						and ModuleMasterId=@ModuleId_Partner)			
			update Auth.UserPermission set Status= 1 where RoleId in ((select Id from auth.Role where CompanyId=@NEW_COMPANY_ID and ModuleMasterId=@ModuleId_Partner)) and CompanyUserId in (select Id from Common.CompanyUser where CompanyId=@NEW_COMPANY_ID and IsAdmin = 1)
		END
	END TRY
	BEGIN CATCH
		ROLLBACK
	END CATCH
	COMMIT TRANSACTION
END






GO
