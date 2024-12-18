USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_ROLE_AND_PERMISSIONS_INSERTION]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [dbo].[FW_ROLE_AND_PERMISSIONS_INSERTION](@NEW_COMPANY_ID bigint, @UNIQUE_COMPANY_ID bigint)
AS
BEGIN
BEGIN TRY
--BEGIN TRANSACTION

--========== Role Permissions update baed on Cursor wise ===============================

	update Auth.RolePermissionsNew set Status=1 where ModuleDetailId 
	in (
	select Distinct(MD.Id) from Common.CompanyModule CM (NOLOCK)
	Join Common.ModuleDetail MD (NOLOCK) on CM.ModuleId = MD.SecondryModuleId
	where CM.Status=1 and CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID)
	and RoleId in (select Id from Auth.RoleNew where CompanyId = @NEW_COMPANY_ID)

	update Auth.RolePermissionsNew set Status=2 where ModuleDetailId 
	in (
	select Distinct(MD.Id) from Common.CompanyModule CM (NOLOCK)
	Join Common.ModuleDetail MD (NOLOCK) on CM.ModuleId = MD.SecondryModuleId
	where CM.Status=2 and CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID)
	and RoleId in (select Id from Auth.RoleNew (NOLOCK) where CompanyId = @NEW_COMPANY_ID)

	--========== User Permissions update baed on Cursor wise ===============================

	update Auth.userpermissionNew set Status=1 where ModuleDetailId 
	in (
	select Distinct(MD.Id) from Common.CompanyModule CM (NOLOCK)
	Join Common.ModuleDetail MD (NOLOCK) on CM.ModuleId = MD.SecondryModuleId
	where CM.Status=1 and CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID)
	and CompanyUserId in (select Id from Common.CompanyUser (NOLOCK) where CompanyId = @NEW_COMPANY_ID)

	update Auth.userpermissionNew set Status=2 where ModuleDetailId 
	in (
	select Distinct(MD.Id) from Common.CompanyModule CM (NOLOCK)
	Join Common.ModuleDetail MD (NOLOCK) on CM.ModuleId = MD.SecondryModuleId
	where CM.Status=2 and CM.CompanyId=@NEW_COMPANY_ID and MD.CompanyId=@NEW_COMPANY_ID)
	and CompanyUserId in (select Id from Common.CompanyUser (NOLOCK) where CompanyId = @NEW_COMPANY_ID)

	--============== Feature wise ModuleDetail & Initial CursorSetup status change ==================

	IF EXISTS (select * from Common.CompanyModule (NOLOCK) where CompanyId=@NEW_COMPANY_ID and ModuleId=(select Id from Common.ModuleMaster (NOLOCK) where Name='Hr Cursor') and Status=1)
	BEGIN					

		--update MD set status=2 from Common.ModuleDetail MD
		--where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		--left join Common.Feature F on cf.FeatureId = F.Id 
		--where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)

		--update MD set status=1 from Common.ModuleDetail MD
		--where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		--left join Common.Feature F on cf.FeatureId = F.Id 
		--where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)
		
		--update ICS set Status=2 from Common.InitialCursorSetup ICS
		--join Common.ModuleDetail MD on ICS.ModuleDetailId = MD.Id
		--where ICS.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		--left join Common.Feature F on cf.FeatureId = F.Id 
		--where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)

		--update ICS set Status=1 from Common.InitialCursorSetup ICS
		--join Common.ModuleDetail MD on ICS.ModuleDetailId = MD.Id
		--where ICS.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		--left join Common.Feature F on cf.FeatureId = F.Id 
		--where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)

		--============== Feature wise Role Permision status updation ===
	
		update auth.rolepermissionsnew set status=2 where moduledetailId in
		(
		select Id from Common.ModuleDetail MD (NOLOCK)
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF (NOLOCK)
		left join Common.Feature F (NOLOCK) on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster (NOLOCK) where Name='Hr Cursor') and cf.Status = 2)) and roleid in (select Id from auth.rolenew (NOLOCK) where companyId=@NEW_COMPANY_ID)

		update auth.rolepermissionsnew set status=1 where moduledetailId in
		(
		select Id from Common.ModuleDetail MD (NOLOCK)
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF (NOLOCK)
		left join Common.Feature F (NOLOCK) on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster (NOLOCK) where Name='Hr Cursor') and cf.Status = 1)) and roleid in (select Id from auth.rolenew (NOLOCK) where companyId=@NEW_COMPANY_ID)

		--============== Feature wise User Permision status updation ===

		update auth.userpermissionnew set status=2 where moduledetailId in
		(
		select Id from Common.ModuleDetail MD (NOLOCK)
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF (NOLOCK)
		left join Common.Feature F (NOLOCK) on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster (NOLOCK) where Name='Hr Cursor') and cf.Status = 2)) and CompanyUserId in (select Id from Common.CompanyUser (NOLOCK) where companyId=@NEW_COMPANY_ID)

		update auth.userpermissionnew set status=1 where moduledetailId in
		(
		select Id from Common.ModuleDetail MD (NOLOCK)
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF (NOLOCK)
		left join Common.Feature F (NOLOCK) on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster (NOLOCK) where Name='Hr Cursor') and cf.Status = 1)) and CompanyUserId in (select Id from Common.CompanyUser (NOLOCK) where companyId=@NEW_COMPANY_ID)
					
END
    
	update CM set CM.SetUpDone=1 from Common.CompanyModule CM (NOLOCK)
	join Common.ModuleMaster (NOLOCK) MM on CM.ModuleId = MM.Id
	where MM.Name='Super Admin' and CM.CompanyId=@NEW_COMPANY_ID 
  
	-- Roles Insertion --=================================================================

	if exists(select * from License.Subscription (NOLOCK) where CompanyId= @NEW_COMPANY_ID)
	Begin
	if exists(select * from License.Subscription (NOLOCK) where CompanyId= @NEW_COMPANY_ID and SubscriptionName like '%HRMS - Silver%')
	Begin
	insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate,  IsSystem, Backgroundcolor, CursorIcon,Remarks, SubscriptionId, Status)
		select  Id, CompanyId, [Name], ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate, IsSystem, Backgroundcolor, cursoricon, Remarks, SubscriptionId, 1 from
		(select NEWID() as Id, @NEW_COMPANY_ID as CompanyId, 'HRMS Silver Admin' as [Name], PM.ModuleMasterId as ModuleMasterId, null as ModifiedBy, NULL as ModifiedDate,'System' as usercreated, GETUTCDATE() as CreatedDate, 1 as IsSystem, NUll as Backgroundcolor, Null as cursoricon, null as Remarks, s.Id as SubscriptionId, ROW_NUMBER() over (partition by R.Name, PM.ModuleMasterId  order by R.ModuleMasterId) as num from License.Subscription S (NOLOCK)
		join License.Package P (NOLOCK) on S.PackageId = P.Id
		Join License.PackageModule PM (NOLOCK) on PM.PackageId = P.Id
		join Auth.RoleNew R (NOLOCK) on R.ModuleMasterId = PM.ModuleMasterId
		where R.CompanyId=@UNIQUE_COMPANY_ID and s.CompanyId=@NEW_COMPANY_ID and s.Status != 4 and (s.LicensesReserved - s.LicensesUsed) != 0 and R.Name='HRMS Silver Admin' and S.SubscriptionName like '%HRMS - Silver%' and R.ModuleMasterId in (
		select ModuleId from Common.CompanyModule CM (NOLOCK)
		join Common.Company C (NOLOCK) on c.Id = CM.CompanyId
		where c.Id= @NEW_COMPANY_ID and CM.Status=1) and R.Name  not in (select Name from Auth.RoleNew (NOLOCK) where CompanyId=@NEW_COMPANY_ID and r.Name='HRMS Silver Admin')) as SUB
		where num = 1
	End
	if exists(select * from License.Subscription (NOLOCK) where CompanyId= @NEW_COMPANY_ID and SubscriptionName like '%HRMS - Gold%')
	Begin
	insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate,  IsSystem, Backgroundcolor, CursorIcon,Remarks, SubscriptionId, Status)
		select  Id, CompanyId, [Name], ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate, IsSystem, Backgroundcolor, cursoricon, Remarks, SubscriptionId, 1 from
		(select NEWID() as Id, @NEW_COMPANY_ID as CompanyId, 'HRMS Gold Admin' as [Name], PM.ModuleMasterId as ModuleMasterId, null as ModifiedBy, NULL as ModifiedDate,'System' as usercreated, GETUTCDATE() as CreatedDate, 1 as IsSystem, NUll as Backgroundcolor, Null as cursoricon, null as Remarks, s.Id as SubscriptionId, ROW_NUMBER() over (partition by R.Name, PM.ModuleMasterId  order by R.ModuleMasterId) as num from License.Subscription S (NOLOCK)
		join License.Package P (NOLOCK) on S.PackageId = P.Id
		Join License.PackageModule PM (NOLOCK) on PM.PackageId = P.Id
		join Auth.RoleNew R (NOLOCK) on R.ModuleMasterId = PM.ModuleMasterId
		where R.CompanyId=@UNIQUE_COMPANY_ID and s.CompanyId=@NEW_COMPANY_ID and s.Status != 4 and (s.LicensesReserved - s.LicensesUsed) != 0 and R.Name='HRMS Gold Admin' and S.SubscriptionName like '%HRMS - Gold%' and R.ModuleMasterId in (
		select ModuleId from Common.CompanyModule CM (NOLOCK)
		join Common.Company C (NOLOCK) on c.Id = CM.CompanyId
		where c.Id= @NEW_COMPANY_ID and CM.Status=1) and R.Name  not in (select Name from Auth.RoleNew (NOLOCK) where CompanyId=@NEW_COMPANY_ID and r.Name='HRMS Gold Admin')) as SUB
		where num = 1
	End
	if exists(select * from License.Subscription where CompanyId= @NEW_COMPANY_ID and SubscriptionName like '%HRMS - Platinum%')
	Begin
	insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate,  IsSystem, Backgroundcolor, CursorIcon,Remarks, SubscriptionId, Status)
		select  Id, CompanyId, [Name], ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate, IsSystem, Backgroundcolor, cursoricon, Remarks, SubscriptionId, 1 from
		(select NEWID() as Id, @NEW_COMPANY_ID as CompanyId, 'HR Admin' as [Name], PM.ModuleMasterId as ModuleMasterId, null as ModifiedBy, NULL as ModifiedDate,'System' as usercreated, GETUTCDATE() as CreatedDate, 1 as IsSystem, NUll as Backgroundcolor, Null as cursoricon, null as Remarks, s.Id as SubscriptionId, ROW_NUMBER() over (partition by R.Name, PM.ModuleMasterId  order by R.ModuleMasterId) as num from License.Subscription S (NOLOCK)
		join License.Package P (NOLOCK) on S.PackageId = P.Id
		Join License.PackageModule PM (NOLOCK) on PM.PackageId = P.Id
		join Auth.RoleNew R (NOLOCK) on R.ModuleMasterId = PM.ModuleMasterId
		where R.CompanyId=@UNIQUE_COMPANY_ID and s.CompanyId=@NEW_COMPANY_ID and s.Status != 4 and (s.LicensesReserved - s.LicensesUsed) != 0 and  R.Name='HR Admin' and S.SubscriptionName like '%HRMS - Platinum%' and R.ModuleMasterId in (
		select ModuleId from Common.CompanyModule CM (NOLOCK)
		join Common.Company C (NOLOCK) on c.Id = CM.CompanyId
		where c.Id= @NEW_COMPANY_ID and CM.Status=1) and R.Name  not in (select Name from Auth.RoleNew (NOLOCK) where CompanyId=@NEW_COMPANY_ID and r.Name='HR Admin')) as SUB
		where num = 1
	End
	if exists(select * from License.Subscription where CompanyId= @NEW_COMPANY_ID and SubscriptionName like '%HRMS Platinum%')
	Begin
	insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate,  IsSystem, Backgroundcolor, CursorIcon,Remarks, SubscriptionId, Status)
		select  Id, CompanyId, [Name], ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate, IsSystem, Backgroundcolor, cursoricon, Remarks, SubscriptionId, 1 from
		(select NEWID() as Id, @NEW_COMPANY_ID as CompanyId, 'HR Admin' as [Name], PM.ModuleMasterId as ModuleMasterId, null as ModifiedBy, NULL as ModifiedDate,'System' as usercreated, GETUTCDATE() as CreatedDate, 1 as IsSystem, NUll as Backgroundcolor, Null as cursoricon, null as Remarks, s.Id as SubscriptionId, ROW_NUMBER() over (partition by R.Name, PM.ModuleMasterId  order by R.ModuleMasterId) as num from License.Subscription S (NOLOCK)
		join License.Package P (NOLOCK) on S.PackageId = P.Id
		Join License.PackageModule PM (NOLOCK) on PM.PackageId = P.Id
		join Auth.RoleNew R (NOLOCK) on R.ModuleMasterId = PM.ModuleMasterId
		where R.CompanyId=@UNIQUE_COMPANY_ID and s.CompanyId=@NEW_COMPANY_ID and s.Status != 4 and (s.LicensesReserved - s.LicensesUsed) != 0 and  R.Name='HR Admin' and S.SubscriptionName like '%HRMS Platinum%' and R.ModuleMasterId in (
		select ModuleId from Common.CompanyModule CM (NOLOCK)
		join Common.Company C (NOLOCK) on c.Id = CM.CompanyId
		where c.Id= @NEW_COMPANY_ID and CM.Status=1) and R.Name  not in (select Name from Auth.RoleNew (NOLOCK) where CompanyId=@NEW_COMPANY_ID and r.Name='HR Admin')) as SUB
		where num = 1
	End
	if exists(select * from License.Subscription where CompanyId= @NEW_COMPANY_ID and SubscriptionName like '%Accounting with Single Entity (Add on for PMS)%')
	Begin
	insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate,  IsSystem, Backgroundcolor, CursorIcon,Remarks, SubscriptionId, Status)
		select  Id, CompanyId, [Name], ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate, IsSystem, Backgroundcolor, cursoricon, Remarks, SubscriptionId, 1 from
		(select NEWID() as Id, @NEW_COMPANY_ID as CompanyId, 'Bean Admin' as [Name], PM.ModuleMasterId as ModuleMasterId, null as ModifiedBy, NULL as ModifiedDate,'System' as usercreated, GETUTCDATE() as CreatedDate, 1 as IsSystem, NUll as Backgroundcolor, Null as cursoricon, null as Remarks, s.Id as SubscriptionId, ROW_NUMBER() over (partition by R.Name, PM.ModuleMasterId  order by R.ModuleMasterId) as num from License.Subscription S (NOLOCK)
		join License.Package P (NOLOCK) on S.PackageId = P.Id
		Join License.PackageModule PM (NOLOCK) on PM.PackageId = P.Id
		join Auth.RoleNew R (NOLOCK) on R.ModuleMasterId = PM.ModuleMasterId
		where R.CompanyId=@UNIQUE_COMPANY_ID and s.CompanyId=@NEW_COMPANY_ID and s.Status != 4 /*and (s.LicensesReserved - s.LicensesUsed) != 0*/and  R.Name='Bean Admin' and S.SubscriptionName like '%Accounting with Single Entity (Add on for PMS)%' and R.ModuleMasterId in (
		select ModuleId from Common.CompanyModule CM (NOLOCK)
		join Common.Company C (NOLOCK) on c.Id = CM.CompanyId
		where c.Id= @NEW_COMPANY_ID and CM.Status=1) and R.Name  not in (select Name from Auth.RoleNew  (NOLOCK) where CompanyId=@NEW_COMPANY_ID and r.Name='Bean Admin')) as SUB
		where num = 1
	End
	if exists(select * from License.Subscription where CompanyId= @NEW_COMPANY_ID and SubscriptionName like '%Accounting with Multi Entity (Add on for PMS)%')
	Begin
	insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate,  IsSystem, Backgroundcolor, CursorIcon,Remarks, SubscriptionId, Status)
		select  Id, CompanyId, [Name], ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate, IsSystem, Backgroundcolor, cursoricon, Remarks, SubscriptionId, 1 from
		(select NEWID() as Id, @NEW_COMPANY_ID as CompanyId, 'Bean Admin' as [Name], PM.ModuleMasterId as ModuleMasterId, null as ModifiedBy, NULL as ModifiedDate,'System' as usercreated, GETUTCDATE() as CreatedDate, 1 as IsSystem, NUll as Backgroundcolor, Null as cursoricon, null as Remarks, s.Id as SubscriptionId, ROW_NUMBER() over (partition by R.Name, PM.ModuleMasterId  order by R.ModuleMasterId) as num from License.Subscription S (NOLOCK)
		join License.Package P (NOLOCK) on S.PackageId = P.Id
		Join License.PackageModule PM (NOLOCK) on PM.PackageId = P.Id
		join Auth.RoleNew R (NOLOCK) on R.ModuleMasterId = PM.ModuleMasterId
		where R.CompanyId=@UNIQUE_COMPANY_ID and s.CompanyId=@NEW_COMPANY_ID and s.Status != 4 /*and (s.LicensesReserved - s.LicensesUsed) != 0*/and  R.Name='Bean Admin' and S.SubscriptionName like '%Accounting with Multi Entity (Add on for PMS)%' and R.ModuleMasterId in (
		select ModuleId from Common.CompanyModule CM (NOLOCK)
		join Common.Company C (NOLOCK) on c.Id = CM.CompanyId
		where c.Id= @NEW_COMPANY_ID and CM.Status=1) and R.Name  not in (select Name from Auth.RoleNew (NOLOCK) where CompanyId=@NEW_COMPANY_ID and r.Name='Bean Admin')) as SUB
		where num = 1
	End
	if exists(select * from License.Subscription where CompanyId= @NEW_COMPANY_ID and (SubscriptionName like '%Audit%' or SubscriptionName like '%Audit%'))
	Begin
	Declare @partnerId bigint = (select AccountingFirmId from Common.Company where Id=@NEW_COMPANY_ID)
	if(@partnerId is  not null)
	Begin
	insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate,  IsSystem, Backgroundcolor, CursorIcon,Remarks, SubscriptionId, Status)
		select  Id, CompanyId, [Name], ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate, IsSystem, Backgroundcolor, cursoricon, Remarks, SubscriptionId, 1 from
		(select NEWID() as Id, @NEW_COMPANY_ID as CompanyId, R.Name as [Name], PM.ModuleMasterId as ModuleMasterId, null as ModifiedBy, NULL as ModifiedDate,'System' as usercreated, GETUTCDATE() as CreatedDate, 1 as IsSystem, NUll as Backgroundcolor, Null as cursoricon, null as Remarks, s.Id as SubscriptionId, ROW_NUMBER() over (partition by R.Name, PM.ModuleMasterId  order by R.ModuleMasterId) as num from License.Subscription S (NOLOCK)
		join License.Package P (NOLOCK) on S.PackageId = P.Id
		Join License.PackageModule PM (NOLOCK) on PM.PackageId = P.Id
		join Auth.RoleNew R (NOLOCK) on R.ModuleMasterId = PM.ModuleMasterId
		where R.CompanyId=@UNIQUE_COMPANY_ID and s.CompanyId=@NEW_COMPANY_ID and s.Status != 4 /*and (s.LicensesReserved - s.LicensesUsed) != 0*/ and R.ModuleMasterId in (
		select ModuleId from Common.CompanyModule CM (NOLOCK)
		join Common.Company C (NOLOCK) on c.Id = CM.CompanyId
		where c.Id= @NEW_COMPANY_ID and CM.Status=1) and R.ModuleMasterId  not in (select ModuleMasterId from Auth.RoleNew (NOLOCK) where CompanyId=@NEW_COMPANY_ID) and R.ModuleMasterId != 8) as SUB
		where num = 1
		End
	END
	if exists(select * from License.Subscription where CompanyId= @NEW_COMPANY_ID and SubscriptionName like '%Tax%')
	Begin
	Declare @AccountFirmId bigint = (select AccountingFirmId from Common.Company where Id=@NEW_COMPANY_ID)
	if(@AccountFirmId is  not null)
	Begin
	insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate,  IsSystem, Backgroundcolor, CursorIcon,Remarks, SubscriptionId, Status)
		select  Id, CompanyId, [Name], ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate, IsSystem, Backgroundcolor, cursoricon, Remarks, SubscriptionId, 1 from
		(select NEWID() as Id, @NEW_COMPANY_ID as CompanyId, R.Name as [Name], PM.ModuleMasterId as ModuleMasterId, null as ModifiedBy, NULL as ModifiedDate,'System' as usercreated, GETUTCDATE() as CreatedDate, 1 as IsSystem, NUll as Backgroundcolor, Null as cursoricon, null as Remarks, s.Id as SubscriptionId, ROW_NUMBER() over (partition by R.Name, PM.ModuleMasterId  order by R.ModuleMasterId) as num from License.Subscription S (NOLOCK)
		join License.Package P (NOLOCK) on S.PackageId = P.Id
		Join License.PackageModule PM (NOLOCK) on PM.PackageId = P.Id
		join Auth.RoleNew R (NOLOCK) on R.ModuleMasterId = PM.ModuleMasterId
		where R.CompanyId=@UNIQUE_COMPANY_ID and s.CompanyId=@NEW_COMPANY_ID and s.Status != 4 /*and (s.LicensesReserved - s.LicensesUsed) != 0*/ and R.ModuleMasterId in (
		select ModuleId from Common.CompanyModule CM (NOLOCK)
		join Common.Company C (NOLOCK) on c.Id = CM.CompanyId
		where c.Id= @NEW_COMPANY_ID and CM.Status=1) and R.ModuleMasterId  not in (select ModuleMasterId from Auth.RoleNew (NOLOCK) where CompanyId=@NEW_COMPANY_ID) and R.ModuleMasterId != 8) as SUB
		where num = 1
		End
	End
		insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate,  IsSystem, Backgroundcolor, CursorIcon,Remarks, SubscriptionId, Status)
		select  Id, CompanyId, [Name], ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate, IsSystem, Backgroundcolor, cursoricon, Remarks, SubscriptionId, 1 from
		(select NEWID() as Id, @NEW_COMPANY_ID as CompanyId, R.Name as [Name], PM.ModuleMasterId as ModuleMasterId, null as ModifiedBy, NULL as ModifiedDate,'System' as usercreated, GETUTCDATE() as CreatedDate, 1 as IsSystem, NUll as Backgroundcolor, Null as cursoricon, null as Remarks, s.Id as SubscriptionId, ROW_NUMBER() over (partition by R.Name, PM.ModuleMasterId  order by R.ModuleMasterId) as num from License.Subscription S (NOLOCK)
		join License.Package P (NOLOCK) on S.PackageId = P.Id
		Join License.PackageModule PM (NOLOCK) on PM.PackageId = P.Id
		join Auth.RoleNew R (NOLOCK) on R.ModuleMasterId = PM.ModuleMasterId
		where R.CompanyId=@UNIQUE_COMPANY_ID and s.CompanyId=@NEW_COMPANY_ID and s.Status != 4 and (s.LicensesReserved - s.LicensesUsed) != 0 and R.ModuleMasterId in (
		select ModuleId from Common.CompanyModule CM (NOLOCK)
		join Common.Company C (NOLOCK) on c.Id = CM.CompanyId
		where c.Id= @NEW_COMPANY_ID and CM.Status=1) and R.ModuleMasterId  not in (select ModuleMasterId from Auth.RoleNew (NOLOCK) where CompanyId=@NEW_COMPANY_ID) and R.ModuleMasterId != 8) as SUB
		where num = 1

		insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate,  IsSystem, Backgroundcolor, CursorIcon,Remarks, SubscriptionId, Status)
		select NEWID() as Id, @NEW_COMPANY_ID as CompanyId, Name as [Name], ModuleMasterId as ModuleMasterId, null as ModifiedBy, NULL as ModifiedDate,'System' as usercreated, GETUTCDATE() as CreatedDate, 1 as IsSystem, NUll as Backgroundcolor, Null as cursoricon, null as Remarks, null as SubscriptionId, 1 from Auth.RoleNew (NOLOCK) where CompanyId=0 and ModuleMasterId in ((select Id from Common.ModuleMaster (NOLOCK) where Name = 'Admin Cursor')) and Name not in (select Name from Auth.RoleNew (NOLOCK) where CompanyId=@NEW_COMPANY_ID and ModuleMasterId in ((select Id from Common.ModuleMaster (NOLOCK) where Name = 'Admin Cursor')))

		if exists(select * from Common.CompanyModule where CompanyId=@NEW_COMPANY_ID and ModuleId=(select Id from Common.ModuleMaster where Name='Partner Cursor') and Status=1)
		begin
			insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, ModifiedBy, ModifiedDate, usercreated, CreatedDate,  IsSystem, Backgroundcolor, CursorIcon,Remarks, SubscriptionId, Status)
			select NEWID() as Id, @NEW_COMPANY_ID as CompanyId, Name as [Name], ModuleMasterId as ModuleMasterId, null as ModifiedBy, NULL as ModifiedDate,'System' as usercreated, GETUTCDATE() as CreatedDate, 1 as IsSystem, NUll as Backgroundcolor, Null as cursoricon, null as Remarks, null as SubscriptionId, 1 from Auth.RoleNew (NOLOCK) where CompanyId=0 and ModuleMasterId in ((select Id from Common.ModuleMaster (NOLOCK) where Name = 'Partner Cursor')) and Name not in (select Name from Auth.RoleNew (NOLOCK) where CompanyId=@NEW_COMPANY_ID and ModuleMasterId in ((select Id from Common.ModuleMaster (NOLOCK) where Name = 'Partner Cursor')))
		end
		----Update  License.Subscription set LicensesUsed=1 where CompanyId=@NEW_COMPANY_ID and SubscriptionName like '%Accounting with Single Entity%' and Status=1
	End
	else
	begin	
		insert into Auth.rolenew (Id, CompanyId, Name, ModuleMasterId, Status, IsSystem,CreatedDate, UserCreated, BackgroundColor, CursorIcon, SubscriptionId) 
		select NEWID(), @NEW_COMPANY_ID, Name, ModuleMasterId, 1, 1, GETUTCDATE(), 'System',null,null, 
		(select top 1 s.Id from License.Subscription S (NOLOCK)
		join License.Package P (NOLOCK) on S.PackageId = P.Id
		join License.PackageModule PM (NOLOCK) on PM.PackageId = P.Id 
		where CompanyId=@NEW_COMPANY_ID and PM.ModuleMasterId=ModuleMasterId) as SubscriptionId
		from Auth.RoleNew (NOLOCK) where ModuleMasterId in (
		select ModuleId from Common.CompanyModule CM (NOLOCK)
		join Common.Company C (NOLOCK) on c.Id = CM.CompanyId
		where c.Id= @NEW_COMPANY_ID and CM.Status=1) and ModuleMasterId  not in (select ModuleMasterId from Auth.RoleNew (NOLOCK) where CompanyId=@NEW_COMPANY_ID) and CompanyId=@UNIQUE_COMPANY_ID
	end

	IF NOT EXISTS(Select Id from Auth.RoleNew (NOLOCK) where CompanyId = @NEW_COMPANY_ID and Name = 'Admin Security')
	BEGIN
	INSERT INTO AUTH.ROLENEW (Id, CompanyId, Name, ModuleMasterId, Status, ModifiedBy, ModifiedDate, UserCreated, CreatedDate, IsSystem, BackgroundColor, CursorIcon, Remarks) values
	(NEWID(), @NEW_COMPANY_ID, 'Admin Security',(Select Id from Common.ModuleMaster where Name = 'Admin Cursor') , 1, NULL, NULL, 'System', GETUTCDATE(), 1, NULL, NULL, NULL)
	END


    -- User Roles Insertion ================================================================

	DECLARE @COMPANY_USER_ID bigint
	DECLARE USER_ROLE_CURSOR CURSOR FOR (SELECT ID FROM Common.CompanyUser WHERE CompanyId=@NEW_COMPANY_ID and IsAdmin=1)
	OPEN USER_ROLE_CURSOR
	FETCH NEXT FROM USER_ROLE_CURSOR INTO @COMPANY_USER_ID
	WHILE (@@FETCH_STATUS > -1)
	BEGIN
		IF NOT EXISTS (SELECT * FROM Auth.UserRoleNew WHERE CompanyUserId=@COMPANY_USER_ID)
		BEGIN
			INSERT INTO AUTH.USERROLENEW (ID, COMPANYUSERID, ROLEID, ROLENAME, USERNAME, USERCREATED, CREATEDDATE,STATUS)
			SELECT NEWID(), @COMPANY_USER_ID, ID, NAME,(SELECT FIRSTNAME FROM COMMON.COMPANYUSER WHERE ID=@COMPANY_USER_ID),'SYSTEM',GETUTCDATE(),1 FROM AUTH.ROLENEW WHERE [NAME] = 'Admin Security' AND COMPANYID=@NEW_COMPANY_ID AND ISSYSTEM=1 AND ID NOT IN (SELECT ROLEID FROM AUTH.USERROLENEW WHERE COMPANYUSERID=@COMPANY_USER_ID)
		END
	FETCH NEXT FROM USER_ROLE_CURSOR INTO @COMPANY_USER_ID
	END
	CLOSE USER_ROLE_CURSOR
	DEALLOCATE USER_ROLE_CURSOR
	--=============================================

END TRY
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
END CATCH
--COMMIT TRANSACTION
END
GO
