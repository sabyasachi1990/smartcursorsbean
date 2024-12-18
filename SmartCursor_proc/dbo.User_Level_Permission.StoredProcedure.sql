USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[User_Level_Permission]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  Procedure [dbo].[User_Level_Permission]
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
 --@DrFin_Admin int,
 --@Analytics int,
 @CompanyUserId Bigint,
 @Username Nvarchar(max),

 @IS_Partner INT
AS
Begin
--exec User_Level_Permission_Updated @NEW_COMPANY_ID=101,@Admin=1,@Au_Admin=0,@BC_Admin=0,@BR_Admin=0,@CC_Admin=0,@DC_Admin=0,@HR_Admin=0,@KB_Admin=0,/*@SUPER_Admin=0,*/@TX_Admin=0,@WF_Admin=0,/*@Analytics=0,*/@CompanyUserId=556,@Username='Classmate@yopmail.com',@IS_Partner=0


Declare @UNIQUE_COMPANY_ID bigint=0;
Declare @CNT int

--select * from auth.Role where CompanyId=0  and name   like '%Admin'order by Name /* for 0 company */
select @CNT= count(*) from auth.Role where CompanyId= @NEW_COMPANY_ID --and name   like '%Admin' and IsPartner is null--order by Name
Print 'No of cursors :'+' '+Convert(varchar(10),@CNT)



Declare @Input_Cursors_For_One table(Name Nvarchar(200),CompanyId Bigint)


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
--If @DrFin_Admin=1 
--begin
--Insert Into @Input_Cursors_For_One select 'DrFin Admin',@NEW_COMPANY_ID
--End
--If @Analytics=1 
--begin
--Insert Into @Input_Cursors_For_One select 'Analytics Admin',@NEW_COMPANY_ID
--End
If @IS_Partner=1 
begin
Insert Into @Input_Cursors_For_One select 'Partner Admin',@NEW_COMPANY_ID
End

--select * from @Input_Cursors_For_One-----------One



Declare @var_for_UserRole_Add table(RoleId uniqueidentifier,RoleName Nvarchar(200),CompanyId Bigint,CUId bigint,Uname Nvarchar(max))
Insert Into @var_for_UserRole_Add
select Id,Name,CompanyId,@CompanyUserId as CompanyUserId,@Username as Username from auth.Role where CompanyId=@NEW_COMPANY_ID and Name in (select Name from @Input_Cursors_For_One)
--Select * from @var_for_UserRole_Add

Declare @RId uniqueidentifier--used for adding in role table
Declare @RName Nvarchar(200)
Declare @CUId bigint
Declare @Uname nvarchar(max)
Declare @RoleCnt int
Declare Add_Cursor_For_UserRole cursor for select RoleId,RoleName,CUId,Uname from @var_for_UserRole_Add
Open Add_Cursor_For_UserRole
          FETCH NEXT FROM Add_Cursor_For_UserRole into @RId,@RName,@CUId,@Uname
          WHILE @@FETCH_STATUS = 0
		  BEGIN
		  --Print(1)
		  select @RoleCnt=count(*) from Auth.UserRole where Username=@Uname and CompanyUserId=@CUId and RoleId=@RId and RoleName=@RName
          print @RoleCnt
		  If @RoleCnt = 0
		  Begin
		       IF NOT EXISTS(select * from Auth.UserRole where CompanyUserId=@CompanyUserId and CompanyUserId in (select id from Common.CompanyUser where CompanyId = @NEW_COMPANY_ID and IsAdmin=1) and RoleName=@RName)   -- If condition Added Newly
			   BEGIN
				   Insert Into Auth.UserRole
				   select NEWID(),@CUId,@RId,@RName,@Uname,null,GETUTCDATE(),null,null,null,null,1
			   END
			   IF NOT EXISTS(SELECT * FROM Auth.UserPermission WHERE CompanyUserId=@CompanyUserId and ROLEID=(SELECT ID FROM Auth.Role WHERE CompanyId=@NEW_COMPANY_ID AND Name=@RName))
			   BEGIN  -- If Condiiton added newly
			   --select * from Auth.UserPermission
				   Insert Into Auth.UserPermission
				   Select NEWID(),@CUId,@Uname,ModuleDetailPermissionId,@RId,(select firstname from Common.CompanyUser where CompanyId=@UNIQUE_COMPANY_ID),GETUTCDATE(),null,null,1
				   from Auth.RolePermission where RoleId in(select Id from auth.Role where CompanyId=@UNIQUE_COMPANY_ID  and name=@RName)
               END
		  End
		  FETCH NEXT FROM Add_Cursor_For_UserRole INTO @RId,@RName,@CUId,@Uname
		  End
Close Add_Cursor_For_UserRole
Deallocate Add_Cursor_For_UserRole

End






















GO
