USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Common_Update_InitialSetUp_UserandRole_Permissions]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_Common_Update_InitialSetUp_UserandRole_Permissions](@NEW_COMPANY_ID BIGINT, @Type nvarchar(20))
AS
BEGIN

	if exists (select * from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and Status=1)
	begin
		-- updating the initialSetup status = 1 for the @NewCompany based on feature
		Update ICS set ICS.Status = 1 from Common.InitialCursorSetup ICS    
		join Common.ModuleDetail MD on MD.Id = ICS.ModuleDetailId
		join Common.Feature F on F.GroupKey = MD.GroupKey
		join Common.CompanyFeatures CF on F.Id = CF.FeatureId
		where CF.CompanyId=@NEW_COMPANY_ID and ICS.CompanyId=@NEW_COMPANY_ID and CF.Status=1 and ICS.Status <> 0
	end
	-- If we activate the cursor after completion of company initial intial setup, its not asking initial setup at Company - Admin Level
	IF EXISTS(select * from Common.CompanyModule where CompanyId = @NEW_COMPANY_ID and SetUpDone=0)   
	BEGIN
		update Common.CompanyModule set SetUpDone = 0 where CompanyId=@NEW_COMPANY_ID and ModuleId = (Select Id from Common.ModuleMaster where name ='Admin Cursor')
	END

	if not exists (select * from Common.InitialCursorSetup where CompanyId=@NEW_COMPANY_ID and  MainModuleId in (select ModuleId from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and Status=1) and Status <> 0 and IsSetUpDone=0)
	begin
		update Common.CompanyModule set SetUpDone = 1 where CompanyId=@NEW_COMPANY_ID and ModuleId = (Select Id from Common.ModuleMaster where name ='Admin Cursor')
	end

	update Common.InitialCursorSetup set IsCommonModule = 1 where CompanyId=@NEW_COMPANY_ID and ModuleDetailId in (select ModuleDetailId from Common.InitialCursorSetup where CompanyId=0 and IsCommonModule=1)   -- common module update for new copany

	Declare @IntlCsr_ModuleId int,
			@IntlCsr_ModuleDtlId int,
			@Heading varchar(max),
			@ModuleId Int
		
	--Declare Cursor to store ModuleDetailID
	Declare ModuleDetailIdCsr Cursor For --First Cursor
			Select Distinct ModuleDetailId From [Common].[InitialCursorSetup] Where IsSetUpDone=1 and CompanyId = @NEW_COMPANY_ID
	Open ModuleDetailIdCsr;
	Fetch Next From ModuleDetailIdCsr into @IntlCsr_ModuleDtlId 
	While @@FETCH_STATUS=0
		Begin

		--Declare Cursor To Store Heading Names
			Declare HeadingNameCsr Cursor For  --Second Cursor
			--Getting Heading Name Through Moduledetailid From ModuleDetail Table
			Select Heading From Common.ModuleDetail Where Id=@IntlCsr_ModuleDtlId
			Open HeadingNameCsr;
			Fetch Next From HeadingNameCsr Into @Heading
			While @@FETCH_STATUS=0
			Begin
 
			--Dedclare Cursor To Store ModuleId Of Heading
				Declare Moduleid_HeadingCsr Cursor For --Third Cursor
				Select Id from Common.ModuleDetail Where Heading=@Heading
				Open Moduleid_HeadingCsr;
				Fetch Next From Moduleid_HeadingCsr into @ModuleId
					While @@FETCH_STATUS=0
					Begin

						--Update InitialCursorsetup Table
						Update Common.InitialCursorSetup set IsSetUpDone=1 Where ModuleDetailId=@ModuleId and CompanyId = @NEW_COMPANY_ID
						Fetch Next From Moduleid_HeadingCsr into @ModuleId
					End
				--Close Third Cursor
				Close Moduleid_HeadingCsr  --Third Cursor
				Deallocate Moduleid_HeadingCsr --Third Cursor

			Fetch Next From HeadingNameCsr Into @Heading
			End
			--Close Second Cursor
			Close HeadingNameCsr  --Second Cursor
			Deallocate HeadingNameCsr  --Second Cursor
		Fetch Next From ModuleDetailIdCsr into @IntlCsr_ModuleDtlId 
		End 
	--Close First Cursor
	Close ModuleDetailIdCsr  --First Cursor
	Deallocate ModuleDetailIdCsr  --First Cursor		

		-----------Update CompanyModuleSetUp Table   Nandu------------------------
	

	Declare @Initial_ModuleId Int,
	@Count_All Int,
	@Count_True Int
	--Declare Cursor to Store ModuleId From Common.InitialCursorSetup Table
	Declare Initial_ModuleIdCsr Cursor For 
	Select distinct ModuleId from Common.InitialCursorSetup Where CompanyId=@NEW_COMPANY_ID
	Open Initial_ModuleIdCsr;
	Fetch next from Initial_ModuleIdCsr Into @Initial_ModuleId
	While @@FETCH_STATUS=0
	Begin
		--Get Records Count from Common.InitialCursorSetup Table Based On ModuleId & CompanyId
		Select @Count_All=COUNT(*) From Common.InitialCursorSetup Where ModuleId=@Initial_ModuleId And CompanyId=@NEW_COMPANY_ID and Status=1
		--Get Records Count from Common.InitialCursorSetup Table Based On ModuleId & CompanyId And IsSetUpDone Is True
		Select @Count_True=COUNT(*) From Common.InitialCursorSetup Where ModuleId=@Initial_ModuleId And CompanyId=@NEW_COMPANY_ID And IsSetUpDone=1
		--Both Counts Are True
		If @Count_All=@Count_True
		Begin
			--Update Common.CompanyModuleSetUp Table With IsSetUpDone Is 1
			Update Common.CompanyModuleSetUp Set IsSetUpDone=1 Where CompanyId=@NEW_COMPANY_ID And ModuleId=@Initial_ModuleId
		End
		else   -- SSK
		begin
			Update Common.CompanyModuleSetUp Set IsSetUpDone=0 Where CompanyId=@NEW_COMPANY_ID And ModuleId=@Initial_ModuleId
		end
		Fetch next from Initial_ModuleIdCsr Into @Initial_ModuleId
	End

	Close Initial_ModuleIdCsr
	Deallocate Initial_ModuleIdCsr

	

		-----------Update Status in InitialCursorSetUp Table Based On Status in CompanyFeatures Table   Nandu------------
		--When Status InActive in CompantFeatures Referenced ModuleDetailId in InitialCursorSetUp Will Automatocally InActive

		Begin

		Declare @ModuleDtlId Int
		--Declare Cursor to store ModuleDetailID 
		Declare ModuleId_DetailidCSR Cursor For
		Select Distinct Md.Id As ModuleDetailId From Common.Feature As CF
		Inner Join Common.CompanyFeatures As CMPF On CMPF.FeatureId=CF.Id
		Inner Join Common.ModuleDetail As MD on MD.GroupKey=CF.GroupKey --And MD.ModuleMasterId=CF.ModuleId
		Where CMPF.Status<>1 And CMPF.CompanyId=@NEW_COMPANY_ID
		--We get ModuleDetailId of GroupKey Which is Inactive ModuleId in CompanyFeatures 
		Open ModuleId_DetailidCSR;
		Fetch Next From ModuleId_DetailidCSR Into @ModuleDtlId
		While @@FETCH_STATUS=0
		Begin
		--From Fetch Statement We Get ModuleDetailId 
		--Update InitialCuirsorSetUpTable Based On ModuleDetailId And CompanyId
		--Update Status with 0 When ModuleDetailId Is Match in InitialcursorSetUp Table For All cursors 
		 
		Update Common.InitialCursorSetup Set Status=2 Where Moduledetailid=@ModuleDtlId And CompanyId=@NEW_COMPANY_ID

		Fetch Next From ModuleId_DetailidCSR Into @ModuleDtlId
		End
		Close ModuleId_DetailidCSR;
		Deallocate ModuleId_DetailidCSR;

		END
	END

	------------------------------------------------------------
	-- ssk (deleting the role permissions which are not exist in CompanyFeature (means status =2))

	--if Exists(select rp.* from Auth.RolePermission rp
	--join Auth.Role r on r.Id = rp.RoleId
	--join Auth.ModuleDetailPermission mdp on mdp.Id = rp.ModuleDetailPermissionId
	--join Common.ModuleDetail md on md.Id = mdp.ModuleDetailId
	--where r.CompanyId=@NEW_COMPANY_ID and md.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
	--join Common.Feature F on cf.FeatureId = F.Id 
	--where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='HR Cursor') and cf.Status <> 1))
	--BEGIN
	--	update rp set rp.Status=2 from Auth.RolePermission rp
	--	join Auth.Role r on r.Id = rp.RoleId
	--	join Auth.ModuleDetailPermission mdp on mdp.Id = rp.ModuleDetailPermissionId
	--	join Common.ModuleDetail md on md.Id = mdp.ModuleDetailId
	--	where r.CompanyId=@NEW_COMPANY_ID and md.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
	--	join Common.Feature F on cf.FeatureId = F.Id 
	--	where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='HR Cursor') and cf.Status <> 1)  
	--END
	--------------------------------------- 
	---- ssk (deleting the USER permissions which features are not exist in CompanyFeature (means status =2))

	--if EXISTS(SELECT up.* from Auth.UserPermission up
	--join Auth.Role r on r.Id = up.RoleId
	--join Auth.ModuleDetailPermission mdp on mdp.Id = up.ModuleDetailPermissionId
	--join Common.ModuleDetail md on md.Id = mdp.ModuleDetailId
	--where r.CompanyId=@NEW_COMPANY_ID and up.CompanyUserId in (select Id from Common.CompanyUser where CompanyId=@NEW_COMPANY_ID and IsAdmin = 1) and md.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
	--join Common.Feature F on cf.FeatureId = F.Id 
	--where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='HR Cursor') and cf.Status <> 1))
	--BEGIN
	--	update up set up.Status=2 from Auth.UserPermission up
	--	join Auth.Role r on r.Id = up.RoleId
	--	join Auth.ModuleDetailPermission mdp on mdp.Id = up.ModuleDetailPermissionId
	--	join Common.ModuleDetail md on md.Id = mdp.ModuleDetailId
	--	where r.CompanyId=@NEW_COMPANY_ID and up.CompanyUserId in (select Id from Common.CompanyUser where CompanyId=@NEW_COMPANY_ID and IsAdmin = 1) and md.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
	--	join Common.Feature F on cf.FeatureId = F.Id 
	--	where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='HR Cursor') and cf.Status <> 1)
	--END

	---------------------------------------






















GO
