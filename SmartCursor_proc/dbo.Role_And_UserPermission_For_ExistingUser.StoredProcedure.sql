USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Role_And_UserPermission_For_ExistingUser]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Role_And_UserPermission_For_ExistingUser]
@CompanyId int,
@UserName varchar(max),
@UserId uniqueidentifier,
--@RoleName varchar(max),
@AddRoleId varchar(max),
@DeleteRoleId varchar(max),
@UserCreated varchar(max),
@PartnerId Bigint
As
Begin

--Step1:Insertion of user details in companyuser table if not exist.If User data exist we skip to next step
Declare @CompanyUserCount int

select @CompanyUserCount=  COUNT(*) from Common.CompanyUser where CompanyId=@CompanyId and Username=@UserName and UserId=@UserId --and ModuleId=@ModuleId
 --Print @CompanyUserCount
IF @CompanyUserCount=0 
begin

Insert into Common.CompanyUser(Id,CompanyId,Username,FirstName,LastName,IsPrimary,Status,Salutation,Remarks,DeactivationDate,PhoneNo,IsAdmin,IsFavourite,UserId,UserIntial,UserCreated,CreatedDate,ModifiedBy,ModifiedDate)
values
(
	( select MAX(Id+1) From Common.CompanyUser),--To get new Id
	@CompanyId,
	@UserName,
	(select FirstName from Auth.UserAccount where Username=@UserName and Id=@UserId),
	(select LastName from Auth.UserAccount where Username=@UserName and Id=@UserId),
	null,--Isprimary should be null
	1,--Status should be 1
	(select Title from Auth.UserAccount where Username=@UserName and Id=@UserId),
	(select Remarks from Auth.UserAccount where Username=@UserName and Id=@UserId),
	(select DeactivationDate from Auth.UserAccount where Username=@UserName and Id=@UserId),
	null,--Phone number should not required hence we put null
	0, --IsAdmin should be 0 here
	null,--IsFavourite should be null
	@UserId,
	(select substring(FirstName,1,4) from Auth.UserAccount where Username=@UserName and Id=@UserId),-- Here,we get first 4 letters of firstname as UserInitial
	@UserCreated,
	GETDATE(),--created Date should be GetDate()
	null,--Modified By should be null
	null --modified Date should be null
	--@ModuleId
)
End
--End of step 1 --

--Step2:Splitting AddroleId's, role names and DeleteRoleId's and insert into corresponding table variables
Declare @AddedRoles table (AddedRoles uniqueidentifier,number int identity(1,1))

Insert Into @AddedRoles
select value from string_split(@AddRoleId,',')
--select * from @AddedRoles

Declare @AddedRoleNames  table (AddedRoleNames varchar(max),number int identity(1,1))
Declare @RId uniqueidentifier
Declare rolename cursor for select AddedRoles from @AddedRoles
open rolename
Fetch next from rolename into @RId
WHILE @@FETCH_STATUS = 0
	Begin
		Insert Into @AddedRoleNames
		select Name from Auth.Role where Id=@RId
		Fetch next from rolename into @RId
	end
close rolename
Deallocate rolename
/*--Insert Into @AddedRoleNames
--select Name from Auth.Role where Id in (select AddedRoles from @AddedRoles)*/
--select * from @AddedRoleNames

Declare @RoleInfo table(RoleId uniqueidentifier,Rolename varchar(100))
Insert Into @RoleInfo
select AR.AddedRoles,ARN.AddedRoleNames 
From  @AddedRoles AR
join  @AddedRoleNames ARN on AR.number=ARN.number

--select * from @RoleInfo

Declare @DeletedRoles table (DeletedRoles uniqueidentifier)
Insert Into @DeletedRoles
select value from string_split(@DeleteRoleId,',')
--select * from @DeletedRoles

--End of step2:

--Step 3: Using cursors insertion of data for addroleId's if new company doesnot having records.
Declare @CompanyRoleId uniqueidentifier  
Declare @RoleName varchar(100)
Declare @NewCompanyRoleId uniqueidentifier 
Declare @CompanyUserId int --used to get companyuserId which is used in UserRole
select @CompanyUserId=Id from Common.CompanyUser where CompanyId=@CompanyId and  Username=@UserName and UserId=@UserId

Declare AddCursors cursor  for select * from @RoleInfo
open AddCursors
    Fetch next From AddCursors into @CompanyRoleId,@RoleName
	WHILE @@FETCH_STATUS = 0
	Begin
	--print 1
	--If there  role has not exist for new companyid, we use the below code.Here we insert a new record for that company with corresponding rolename 
	If not exists (select * from Auth.Role where Name=@RoleName and CompanyId=@CompanyId)
	Begin
		set @NewCompanyRoleId=NEWID()
		Insert Into Auth.Role
		Select  @NewCompanyRoleId,@CompanyId,Name,Remarks,ModuleMasterId,Status,ModifiedBy,ModifiedDate,@UserCreated,GETDATE(),IsSystem,BackgroundColor,CursorIcon,IsPartner,TempId, status 
		from    Auth.Role where Id=@CompanyRoleId --getting records from @CompanyRoleId and inserted to new companyid with same rolename with newid

		Insert Into Auth.RolePermission
		select NEWID(),@NewCompanyRoleId,ModuleDetailPermissionId,@UserCreated,GETDATE(),null,null,status 
		from   Auth.RolePermission where RoleId=@CompanyRoleId --Inserting records for new rolepermissions

	end
	select @NewCompanyRoleId= Id from Auth.Role where Name=@RoleName and CompanyId=@CompanyId
	--print 'NewCompanyRoleId is :'+ convert(varchar(max),@NewCompanyRoleId)

	--select @CompanyUserId=Id from Common.CompanyUser where CompanyId=@CompanyId and  Username=@UserName and UserId=@UserId
	--Print 'CompanyuserId :'+Convert(varchar(max),@CompanyUserId)

	If not exists(select * from Auth.UserRole where CompanyUserId=@CompanyUserId and Username=@UserName and RoleId=@NewCompanyRoleId and partnerId=@PartnerId)
	Begin
		Insert into Auth.UserRole values (NEWID(),@CompanyUserId,@NewCompanyRoleId,@RoleName,@UserName,@UserCreated,GETDATE(),null,null,null,@PartnerId, 1)

		Insert Into Auth.UserPermission
		select NEWID(),@CompanyUserId,@UserName,ModuleDetailPermissionId,@NewCompanyRoleId,@UserCreated,GETDATE(),null,null, Status 
		from  Auth.RolePermission where RoleId=@CompanyRoleId

	end

	FETCH NEXT FROM AddCursors INTO @CompanyRoleId,@RoleName
	End
Close AddCursors
Deallocate AddCursors
-- End of Step 3

-- Step 4 :Deletion of roleId's in userpermission and userrole table
IF @DeleteRoleId is not null
Begin
	Delete from Auth.UserPermission where CompanyUserId=@CompanyUserId and Username=@UserName and RoleId in (select DeletedRoles from @DeletedRoles)
	Delete From Auth.UserRole where CompanyUserId=@CompanyUserId and Username=@UserName and RoleId in (select DeletedRoles from @DeletedRoles) and partnerId=@PartnerId
End

--end of step 4

End --end of the procedure











GO
