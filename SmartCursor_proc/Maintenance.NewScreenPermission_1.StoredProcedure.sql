USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Maintenance].[NewScreenPermission_1]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec Maintenance.NewScreenPermission 'admin_taxcodes',10,'Admin'
Create   Procedure [Maintenance].[NewScreenPermission_1]
@PermissionKey Nvarchar(124),
@ModuleMasterId Int,
@FromRoleName Nvarchar(524)
As
Begin
	IF OBJECT_ID('tempdb..#CompTbl') Is Not Null
	Begin
		Drop Table #CompTbl
	End
	IF OBJECT_ID('tempdb..#ModuleDtlId') Is Not Null
	Begin
		Drop Table #ModuleDtlId
	End
	IF OBJECT_ID('tempdb..#RoleTbl') Is Not Null
	Begin
		Drop Table #RoleTbl
	End
	IF OBJECT_ID('tempdb..#UserRole') Is Not Null
	Begin
		Drop Table #UserRole
	End
	Create Table #CompTbl (S_no Int Identity(1,1),CompanyId int)
	Create Table #RoleTbl (S_no Int Identity(1,1),RoleId Uniqueidentifier,Name Varchar(524),IsSystem Int)
	Create Table #ModuleDtlId (S_no Int Identity(1,1),ModuleDetailId Int)
	Create Table #UserRole (S_no Int Identity(1,1),CompanyUserId Int,RoleName Varchar(524))

	Declare @Count Int
	Declare @RecCount Int
	Declare @RoleCount Int
	Declare @RoleRecCount Int
	Declare @CompanyId Bigint
	Declare @ModuleDetailId Int
	Declare @NewModuleDetailId Int
	Declare @IsSystem Int
	Declare @RoleId Uniqueidentifier
	Declare @RoleName Nvarchar(524)
	Declare @Json Nvarchar(Max)
	Declare @Tabs Nvarchar(Max)
	Declare @columnames varchar(800)
	declare @sql varchar(max)
	Declare @OldPermission Nvarchar(max)
	Declare @SubStr Nvarchar(Max)
	Declare @ChrIdxVal Int
	Declare @SubStrVal Int
	Declare @OldModuleDetailId Int
	Declare @OldLoopMdlDtlId Varchar(54)
	Declare @NewLoopMdlDtlId Varchar(54)
	Declare @MdlDtlCnt Int
	Declare @MdlDtlRecCnt Int
	Declare @String Varchar(524)
	Declare @ModuleDetailIdStr Varchar(124)
	Declare @OldModuleName Nvarchar(524)
	Declare @NewModuleName Nvarchar(524)
	Declare @DynSQL Nvarchar(Max)
	Declare @UsrCount Int
	Declare @UsrRecCount Int
	Declare @CompUsrId Int
	Declare @UsrRoleName Varchar(524)
	Declare @UserCreated Varchar(124)
	Declare @CreatedDate Datetime2

	Set @UserCreated='System'
	Set @CreatedDate=GETDATE()

	Set @ModuleDetailIdStr='"ModuleDetailId":'
	Set @OldModuleDetailId=(Select Id From Common.ModuleDetail Where CompanyId=0 And PermissionKey=@PermissionKey And ModuleMasterId=@ModuleMasterId)
	Set @OldPermission=(Select Top 1 RPN.Permissions From Auth.RolePermissionsNew As RPN
						Join Auth.RoleNew As RN On RN.Id=RPN.RoleId
						Where ModuleDetailId=@OldModuleDetailId And RN.Name=@FromRoleName And RN.IsSystem=1)
	Insert Into #CompTbl
	Select Id from
	(Select A.Id From Common.Company As A
	Join Common.CompanyModule As B On A.Id=B.CompanyId
	Where B.ModuleId in (Select Id from Common.ModuleMaster Where Id=@ModuleMasterId) And 
	B.Status=1 And A.Id<>0 and A.ParentId is null) as D
	 join
	 (select b.CompanyId,b.FeatureId from [Common].[Feature] a join [Common].[CompanyFeatures] b 
	on a.Id=b.FeatureId where a.Name='GST' and
	a.VisibleStyle ='SuperUser-CheckBox' and a.ModuleId is null  and b.Status=1)
	as F on D.Id=F.CompanyId-- join Common.COmpanyModuel & get only that cursor related companies.

	Set @Count=(Select Count(*) From #CompTbl)
	Set @RecCount=1
	While @Count>=@RecCount
	Begin
		Set @CompanyId=(Select CompanyId From #CompTbl Where S_no=@RecCount)
		Set @NewModuleDetailId=(Select Id From Common.ModuleDetail Where CompanyId=@CompanyId And PermissionKey=@PermissionKey And ModuleMasterId=@ModuleMasterId)
		Truncate Table #RoleTbl
		Insert Into #RoleTbl
		Select Id,Name,IsSystem From Auth.RoleNew Where CompanyId=@CompanyId And ModuleMasterId=@ModuleMasterId
		Set @RoleCount=(Select Count(*) From #RoleTbl)
		Set @RoleRecCount=1
		While @RoleCount>=@RoleRecCount
		Begin
			Select @RoleId=RoleId,@RoleName=Name,@IsSystem=IsSystem From #RoleTbl Where S_no=@RoleRecCount
			Set @Json=@OldPermission
			Set @ChrIdxVal=CHARINDEX('ModuleDetailId',@Json)+16
			Set @SubStrVal=CHARINDEX(',',SUBSTRING(@Json,@ChrIdxVal,LEN(@Json)))-1
			Set @SubStr=@Json
			Set @MdlDtlCnt=0
			IF @ChrIdxVal Is Not Null
			Begin
				Set @MdlDtlCnt=1
			End
			Truncate Table #ModuleDtlId
			While @MdlDtlCnt=1
			Begin
				Set @SubStrVal=CHARINDEX(',',SUBSTRING(@SubStr,@ChrIdxVal,LEN(@SubStr)))-1
				IF Not Exists (Select ModuleDetailId From #ModuleDtlId Where ModuleDetailId=(Select SUBSTRING(@SubStr,@ChrIdxVal,@SubStrVal)))
				Begin
					Insert Into #ModuleDtlId
					Select SUBSTRING(@SubStr,@ChrIdxVal,@SubStrVal)
				End
				Set @SubStr=SUBSTRING(@SubStr,@ChrIdxVal+@SubStrVal,LEN(@SubStr))
				Print @Substr
				Set @ChrIdxVal=CHARINDEX('ModuleDetailId',@SubStr)
				IF @ChrIdxVal Is Not Null And @ChrIdxVal <>0
				Begin
					Set @ChrIdxVal=@ChrIdxVal+16
					Set @MdlDtlCnt=1
				End
				Else 
				Begin
					Set @MdlDtlCnt=0
				End
			End
			Set @MdlDtlCnt=(Select Count(*) From #ModuleDtlId)
			Set @MdlDtlRecCnt=1
			While @MdlDtlCnt>=@MdlDtlRecCnt
			Begin
				Set @OldLoopMdlDtlId=(Select ModuleDetailId From #ModuleDtlId Where S_no=@MdlDtlRecCnt)
				Set @NewLoopMdlDtlId=(Select Top 1 A.Id From Common.ModuleDetail As A
				Join (Select * From Common.ModuleDetail Where Id=@OldLoopMdlDtlId) As B 
				On A.PermissionKey=B.PermissionKey 		
				Where A.CompanyId=@CompanyId
				And A.Heading=B.Heading And A.SecondryModuleId=B.SecondryModuleId 
				And A.ModuleMasterId=B.ModuleMasterId
				)
				IF @OldLoopMdlDtlId Is Not Null And @NewLoopMdlDtlId Is Not Null
				Begin
					Set @OldModuleName=CONCAT(@ModuleDetailIdStr,@OldLoopMdlDtlId,',')
					Set @NewModuleName=CONCAT(@ModuleDetailIdStr,@NewLoopMdlDtlId,',')
					Set @Json=REPLACE(@Json,@OldModuleName,@NewModuleName) 
				End
				Set @MdlDtlRecCnt=@MdlDtlRecCnt+1
			End
			If @IsSystem=1
			Begin
				Set @Json=REPLACE(@Json,'"IsApplicable": true,"Chk":false','"IsApplicable": true,"Chk":true') -- verify the spaces
			End
			ELse
			Begin
				Set @Json=REPLACE(@Json,'"Chk":true','"Chk":false')
			End
			Insert Into Auth.RolePermissionsNew (Id,RoleId,ModuleDetailId,Permissions,Status,IsSeedData)
			Select NEWID(),@RoleId,@NewModuleDetailId,@Json,1,@IsSystem 
			
			IF @IsSystem=1
			Begin
				Truncate table #UserRole
				Insert Into #UserRole
				Select CompanyUserId,RoleName From Auth.UserRoleNew Where RoleId=@RoleId
				Set @UsrCount=(Select Count(*) From #UserRole)
				Set @UsrRecCount=1
				While @UsrCount>=@UsrRecCount
				Begin
					Set @CompUsrId=(Select CompanyUserId From #UserRole Where S_no=@UsrRecCount)
					Set @UsrRoleName=(Select RoleName From #UserRole Where S_no=@UsrRecCount)
					Insert Into Auth.UserPermissionNew(Id,UserRoleId,CompanyUserId,ModuleDetailId,Permissions,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,IsView)
					Select NEWID(),Null,@CompUsrId,@NewModuleDetailId,@Json,@UserCreated,@CreatedDate,Null,Null,1,1 
					Set @UsrRecCount=@UsrRecCount+1
				End
			End
			Set @RoleRecCount=@RoleRecCount+1
		End
		Set @RecCount=@RecCount+1
	End
	IF OBJECT_ID('tempdb..#CompTbl') Is Not Null
	Begin
		Drop Table #CompTbl
	End
	IF OBJECT_ID('tempdb..#ModuleDtlId') Is Not Null
	Begin
		Drop Table #ModuleDtlId
	End
	IF OBJECT_ID('tempdb..#RoleTbl') Is Not Null
	Begin
		Drop Table #RoleTbl
	End
	IF OBJECT_ID('tempdb..#UserRole') Is Not Null
	Begin
		Drop Table #UserRole
	End

End
GO
