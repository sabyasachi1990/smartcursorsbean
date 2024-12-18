USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[role_Level_Permission_WITHOUT_PARTNER]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[role_Level_Permission_WITHOUT_PARTNER]
 @NEW_COMPANY_ID bigint,
 @Admin int,
 @Au_Admin int,
 @BC_Admin int,
 @BR_Admin int,
 @CC_Admin int,
 @DC_Admin int,
 @HR_Admin int,
 @KB_Admin int,
 --@SUPER_Admin int,
 @TX_Admin int,
 @WF_Admin int,
 --@Analytics int,
 @IS_Partner INT
 As
 Begin
 --exec [role_Level_Permission_WITHOUT_PARTNER] @NEW_COMPANY_ID=101,@Admin=1,@Au_Admin=0,@BC_Admin=0,@BR_Admin=0,@CC_Admin=0,@DC_Admin=0,@HR_Admin=0,@KB_Admin=0,/*@SUPER_Admin=0,*/@TX_Admin=0,@WF_Admin=0,/*@Analytics=0,*/@IS_Partner=0
 Declare @UNIQUE_COMPANY_ID bigint=0;
 Declare @CNT int
 select @CNT= count(*) from auth.Role where CompanyId= @NEW_COMPANY_ID 
Print 'No of cursors :'+' '+Convert(varchar(10),@CNT)

Declare @Input_Cursors_For_One table(Name Nvarchar(200),CompanyId Bigint)
Declare @Input_Cursors_For_Zero table(Name Nvarchar(200),CompanyId Bigint)

If @Admin=1 
begin
Insert Into @Input_Cursors_For_One select 'Admin',@NEW_COMPANY_ID
End
If @Au_Admin=1 
begin
Insert Into @Input_Cursors_For_One select 'AU Admin',@NEW_COMPANY_ID
End
If @BC_Admin=1 
begin
Insert Into @Input_Cursors_For_One select 'BC Admin',@NEW_COMPANY_ID
End
If @BR_Admin=1 
begin
Insert Into @Input_Cursors_For_One select 'BR Admin',@NEW_COMPANY_ID
End
If @CC_Admin=1 
begin
Insert Into @Input_Cursors_For_One select 'CC Admin',@NEW_COMPANY_ID
End
If @DC_Admin=1 
begin
Insert Into @Input_Cursors_For_One select 'DC Admin',@NEW_COMPANY_ID
End
If @HR_Admin=1 
begin
Insert Into @Input_Cursors_For_One select 'HR Admin',@NEW_COMPANY_ID
End
If @KB_Admin=1 
begin
Insert Into @Input_Cursors_For_One select 'KB Admin',@NEW_COMPANY_ID
End
--If @SUPER_Admin=1 
--begin
--Insert Into @Input_Cursors_For_One select 'Super Admin',@NEW_COMPANY_ID
--End
If @TX_Admin=1 
begin
Insert Into @Input_Cursors_For_One select 'TX Admin',@NEW_COMPANY_ID
End
If @WF_Admin=1 
begin
Insert Into @Input_Cursors_For_One select 'WF Admin',@NEW_COMPANY_ID
End
--If @Analytics=1 
--begin
--Insert Into @Input_Cursors_For_One select 'Analytics Admin',@NEW_COMPANY_ID
--End


--select * from @Input_Cursors_For_One-----------One
------
If @Admin=0 
begin
Insert Into @Input_Cursors_For_Zero select 'Admin',@NEW_COMPANY_ID
End
If @Au_Admin=0 
begin
Insert Into @Input_Cursors_For_Zero select 'AU Admin',@NEW_COMPANY_ID
End
If @BC_Admin=0 
begin
Insert Into @Input_Cursors_For_Zero select 'BC Admin',@NEW_COMPANY_ID
End
If @BR_Admin=0 
begin
Insert Into @Input_Cursors_For_Zero select 'BR Admin',@NEW_COMPANY_ID
End
If @CC_Admin=0 
begin
Insert Into @Input_Cursors_For_Zero select 'CC Admin',@NEW_COMPANY_ID
End
If @DC_Admin=0 
begin
Insert Into @Input_Cursors_For_Zero select 'DC Admin',@NEW_COMPANY_ID
End
If @HR_Admin=0 
begin
Insert Into @Input_Cursors_For_Zero select 'HR Admin',@NEW_COMPANY_ID
End
If @KB_Admin=0 
begin
Insert Into @Input_Cursors_For_Zero select 'KB Admin',@NEW_COMPANY_ID
End
--If @SUPER_Admin=0 
--begin
--Insert Into @Input_Cursors_For_Zero select 'Super Admin',@NEW_COMPANY_ID
--End
If @TX_Admin=0 
begin
Insert Into @Input_Cursors_For_Zero select 'TX Admin',@NEW_COMPANY_ID
End
If @WF_Admin=0 
begin
Insert Into @Input_Cursors_For_Zero select 'WF Admin',@NEW_COMPANY_ID
End
--If @Analytics=0 
--begin
--Insert Into @Input_Cursors_For_One select 'Analytics Admin',@NEW_COMPANY_ID
--End

--select * from @Input_Cursors_For_Zero-------------zero
If @CNT=0 -- Count=0 
Begin
Declare @CId bigint--used for adding in role table
Declare @CName Nvarchar(200)
Declare Add_Cursor cursor for select * from @Input_Cursors_For_One --Used to add records if it is a new Cursor
Open Add_Cursor
          FETCH NEXT FROM Add_Cursor into @CName,@CId
          WHILE @@FETCH_STATUS = 0
		  BEGIN
		  --Print(1)
		  Insert Into auth.Role
          select NEWID(),@NEW_COMPANY_ID,@CName,null,ModuleMasterId,Status,null,null,null,GETDATE(),IsSystem,BackgroundColor,CursorIcon,IsPartner,TempId 
          from auth.Role where CompanyId=@UNIQUE_COMPANY_ID and Name=@CName
		  FETCH NEXT FROM Add_Cursor INTO @CName,@CId
		  End
Close Add_Cursor
Deallocate Add_Cursor--end for adding in role table
-- for adding in role permission table
--Starting point

Declare @var_for_RolePermission_Add table(RoleId uniqueidentifier,RoleName Nvarchar(200),CompanyId Bigint)
Insert Into @var_for_RolePermission_Add
select Id,Name,CompanyId from auth.Role where CompanyId=@NEW_COMPANY_ID
--Select * from @var_for_RolePermission_Add

Declare @RId uniqueidentifier--used for adding in role table
Declare @RName Nvarchar(200)
Declare Add_Cursor_For_Role_Permision cursor for select RoleId,RoleName from @var_for_RolePermission_Add --Used to add records if it is a new Cursor
Open Add_Cursor_For_Role_Permision
          FETCH NEXT FROM Add_Cursor_For_Role_Permision into @RId,@RName
          WHILE @@FETCH_STATUS = 0
		  BEGIN
		  --Print(1)
		Insert Into Auth.RolePermission
        Select NEWID(),@RId,ModuleDetailPermissionId,null,null,null,null
        from Auth.RolePermission where RoleId in(select Id from auth.Role where CompanyId=@UNIQUE_COMPANY_ID  and name=@RName)

		  FETCH NEXT FROM Add_Cursor_For_Role_Permision INTO @RId,@RName
		  End
Close Add_Cursor_For_Role_Permision
Deallocate Add_Cursor_For_Role_Permision
--end for adding in role table
-- end for adding in role permission table
--end for adding UserRole table
-- end for adding UserPermission table

--Ending point
End --For If @CNT=0

Else If @CNT<>0
Begin
--Print(1)
Declare @Dest_matching_cursors table(Matching_Name Nvarchar(200),CompanyId bigint)
Insert into @Dest_matching_cursors select Name,@NEW_COMPANY_ID from auth.Role where CompanyId=@NEW_COMPANY_ID
--select * from @Dest_matching_cursors
Declare @INo Nvarchar(200)
Declare @DNO varchar(200)
Declare @var_for_RolePermission_Add_IfThere table(RoleId uniqueidentifier,RoleName Nvarchar(200),CompanyId Bigint) --used to store new cursors when count <>0

Declare  Exes_Cursor cursor for select Name from @Input_Cursors_For_One --where companyid=@UNIQUE_COMPANY_ID
OPEN Exes_Cursor
		  FETCH NEXT FROM Exes_Cursor into @INo
		  WHILE @@FETCH_STATUS = 0
		  BEGIN
		  --print (1);
		   select @DNO= Matching_Name from @Dest_matching_cursors where Matching_Name=@INo
		  If @INo=@DNO
		  Begin
		 -- select @CNO=@CNO+1;
		   Print('1');
		   End
		   else
		   begin
		   Insert Into auth.Role
          select NEWID(),@NEW_COMPANY_ID,@INo,null,ModuleMasterId,Status,null,null,null,GETDATE(),IsSystem,BackgroundColor,CursorIcon,IsPartner,TempId 
          from auth.Role where CompanyId=@UNIQUE_COMPANY_ID and Name=@INo
		  
		  Insert Into @var_for_RolePermission_Add_IfThere
		  Select Id,Name,CompanyId From auth.Role where CompanyId=@NEW_COMPANY_ID and Name=@INo
		  End
		  FETCH NEXT FROM Exes_Cursor INTO @INO
		  End
		  
		   CLOSE Exes_Cursor
		  DEALLOCATE Exes_Cursor
--select * from @var_for_RolePermission_Add_IfThere


Declare @RId1 uniqueidentifier
Declare @RName1 Nvarchar(200)  
--Used to add records in rolepermision if it is a new Cursor
Declare Add_Cursor_For_Role_Permision_Add_IfThere cursor for select RoleId,RoleName from @var_for_RolePermission_Add_IfThere --Used to add records in rolepermision if it is a new Cursor
Open Add_Cursor_For_Role_Permision_Add_IfThere
          FETCH NEXT FROM Add_Cursor_For_Role_Permision_Add_IfThere into @RId1,@RName1
          WHILE @@FETCH_STATUS = 0
		  BEGIN
		  --Print(1)
		Insert Into Auth.RolePermission
        Select NEWID(),@RId1,ModuleDetailPermissionId,null,null,null,null
        from Auth.RolePermission where RoleId in(select Id from auth.Role where CompanyId=@UNIQUE_COMPANY_ID  and name=@RName1)
	
		  FETCH NEXT FROM Add_Cursor_For_Role_Permision_Add_IfThere INTO @RId1,@RName1
		  End
Close Add_Cursor_For_Role_Permision_Add_IfThere
Deallocate Add_Cursor_For_Role_Permision_Add_IfThere


End

--For deleting Records
Declare @var_for_RolePermission_Delete_IfThere table(RoleId uniqueidentifier,RoleName Nvarchar(200),CompanyId Bigint)

Insert Into @var_for_RolePermission_Delete_IfThere
Select Id,Name,CompanyId
from  Auth.Role where Name in (Select Name from @Input_Cursors_For_Zero) and CompanyId=@NEW_COMPANY_ID

--select * from @var_for_RolePermission_Delete_IfThere

Declare @DId1 uniqueidentifier--used for deleting in role table
Declare @DName1 Nvarchar(200)
Declare Delete_Cursor_For_Role_Permision_Delete_IfThere cursor for select RoleId,RoleName from @var_for_RolePermission_Delete_IfThere
--Declare  @RId_Count int 
Open Delete_Cursor_For_Role_Permision_Delete_IfThere
          FETCH NEXT FROM Delete_Cursor_For_Role_Permision_Delete_IfThere into @DId1,@DName1
          WHILE @@FETCH_STATUS = 0
		  BEGIN
		    Delete from Auth.UserPermission where RoleId=@DId1 --and CompanyUserId=@CompanyUserId and Username=@Username
		    Delete from Auth.UserRole where RoleId=@DId1 --and RoleName=@DName1 and Username=@Username
			Delete from Auth.RolePermission where RoleId=@DId1
			Delete from Auth.Role where Id=@DId1 and CompanyId=@NEW_COMPANY_ID
		  FETCH NEXT FROM Delete_Cursor_For_Role_Permision_Delete_IfThere INTO @DId1,@DName1
		  End
Close Delete_Cursor_For_Role_Permision_Delete_IfThere
Deallocate Delete_Cursor_For_Role_Permision_Delete_IfThere


End


GO
