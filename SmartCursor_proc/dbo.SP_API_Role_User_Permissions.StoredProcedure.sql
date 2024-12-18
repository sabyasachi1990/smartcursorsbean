USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_API_Role_User_Permissions]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[SP_API_Role_User_Permissions]

        @PrimaryCursor         NVarchar(max),
        @GroupName             NVarchar(max),
        @Heading               NVarchar(max),
        @Dscription            NVarchar(max)='Default',
        @LogoId                Uniqueidentifier,
        @CSSSprite             NVarchar(max),
        @FontAwesome           NVarchar(max),
        @URL                   NVarchar(max),
        @RecOrder              Int,
        @Remarks			   NVarchar(max),
        @Status				   int,
        @PageURL			   NVarchar(max)='Default',
        @GroupURL			   NVarchar(max),
        @CompanyId			   BigInt,
        @MasterURL			   NVarchar(max),
        @ParentNames		   NVarchar(max),
        @PermissionKey		   NVarchar(max),
        @ModuleName			   NVarchar(max),
        @IsPermissionINherited Bit,
        @IsHideTab             Bit,
        @SeconderyCursor       NVarchar(max),
        @GroupKey              NVarchar(max),
        @IsDisable             Bit,
        @IsPartner             Bit,
        @IsMandatory           Int,
        @HelpLink              NVarchar(max),
        @SetupOrder            Int,
        @CacheKeys             NVarchar(max),
        @cursorName            NVarchar(max),
        @PermissionName        NVarchar(Max),
        @ISApplicable          NVarchar(Max),
        @IsMainAction          NVarchar(Max),
        @RecOrderMdlPmsn       NVarchar(Max) 
   As
   Begin 
  Begin
   IF @CompanyId=0
   Begin 
--Declare variables for ModuledetailId , ModuleMasterid , ParentId
  Declare @ModuleDtlId    BigInt,
          @ModuleMasterId Bigint,
          @ParentId       BigInt,
          @Count          Int
  --Id =Max(Id) from Common.ModuleDetailDPC 
  Select @ModuleDtlId=Max(id)+1 from Common.ModuleDetail
  
  --Print 'ModuledtlId Is'
  --Print @ModuleDtlId
  
  --ModuleMasterId = Id from Common.ModuleMaster Passing @PrimaryCursor As Name
  Select @ModuleMasterId=Id from Common.ModuleMaster where Name=@PrimaryCursor

  --Print 'ModuleMasterId Is'
  --Print @ModuleMasterId

  --To get the parentid from Common.ModuleDetailDPC by passing heading and groupname
  --Using Substring and Charindex functions to split the comma delimated values  
  Declare @PHeading    NVarchar(max) = Substring(@ParentNames,0 ,CHARINDEX(',',@ParentNames))
  Declare @PGroupName  NVarchar(Max) = Substring(@ParentNames,CHARINDEX(',',@ParentNames)+1
                                           ,Datalength(@ParentNames)-CHARINDEX(',',@ParentNames))
  --Select parentid from Common.ModuleDetailDPC Where heading='Role' And Groupname='Security'
  Select @ParentId=parentid from Common.ModuleDetail Where heading=@PHeading And Groupname=@PGroupName
  --To get secondarymoduleid
  Declare @SecondaryModuleId BigInt=(Select id from Common.ModuleMaster where Name=@SeconderyCursor)
  --To Avoid Insertion of repeated Values Use Count function 
  Select @Count=Count(*) from Common.ModuleDetail Where  GroupName=@GroupName And Heading=@Heading And CompanyId=@CompanyId
  --Print Concat('MdltblCount Is  ', @Count)
  If @Count=0 

  Begin 
  --Insert Records into Common.ModuleDetailDPC
  Insert into Common.ModuleDetail ([Id], [ModuleMasterId], [GroupName], [Heading], [Description], [LogoId], [CssSprite], [FontAwesome], [Url], [RecOrder],[Remarks],[Status],[PageUrl],[GroupUrl],[CompanyId],[MasterUrl],[ParentId],[PermissionKey],[ModuleName],[IsPermissionInherited],[IsHideTab],[SecondryModuleId],[GroupKey],[IsDisable],[IsPartner],[IsMandatory],[HelpLink],[SetupOrder],[Cachekeys],[CursorName])
-- [Remarks], [UserCreated], [CreatedDate], [ModifiedBy], [ModifiedDate], [Version], [Status], [Subject], [TemplateMenu], [ToEmailId], [IsUnique])
  values(@ModuleDtlId,@ModuleMasterId,@GroupName,@Heading,@Dscription,@LogoId,@CSSSprite,@FontAwesome,@URL,@RecOrder,@Remarks,@Status,                                        
         @PageURL,@GroupURL,@CompanyId,@MasterURL,@ParentId,@PermissionKey,@ModuleName,@IsPermissionINherited,
		 @IsHideTab,@SecondaryModuleId,@GroupKey,@IsDisable,@IsPartner,@IsMandatory,@HelpLink,@SetupOrder,@CacheKeys,@cursorName
         )
        
              --[Id],[ModuleMasterId],[GroupName],[Heading],[Description],[LogoId],[CssSprite],[FontAwesome],[Url],[RecOrder],
              --[Remarks],[Status],[PageUrl],[GroupUrl],[CompanyId],[MasterUrl],[ParentId],[PermissionKey],[ModuleName],
              --[IsPermissionInherited],[IsHideTab],[SecondryModuleId],[GroupKey],[IsDisable],[IsPartner],[IsMandatory],[HelpLink],
              --[SetupOrder],[Cachekeys],[CursorName]

    --Split the values of @PermissionName delimated with comma
    Declare @PermissionNameTbl Table (Pno Int Identity(1,1),PermissionName NVarchar(max))
    Insert Into @PermissionNameTbl
    Select value from  string_split (@PermissionName,',')
    --Split the values of @ISApplicable delimated with comma
    Declare @ISApplicableTbl Table (Pno Int Identity(1,1),ISApplicable bit)
    Insert Into @ISApplicableTbl
    Select convert(bit,value) from  string_split (@ISApplicable,',')
    --Split the values of @IsMainAction delimated with comma
    Declare @IsMainActionTbl Table (Pno Int Identity(1,1),IsMainAction bit)
    Insert Into @IsMainActionTbl
    Select convert(bit,value) from  string_split (@IsMainAction,',')
    --Split the values of @@RecOrderMdlPmsn delimated with comma
    Declare  @RecOrderMdlPmsntbl table (Pno Int Identity(1,1),RecOrder int)
    Insert Into @RecOrderMdlPmsntbl
    Select convert(int,value) from  string_split (@RecOrderMdlPmsn,',')
	-----Declare Table Variable to Join 4 Table Variables 
	Declare @ModuleDtlPmn Table(PermissionName NVarchar(max),ISApplicable bit,IsMainAction bit,RecOrder int)
	---Joining table variables into one Table variable @PermissionNameTbl,@ISApplicableTbl,@IsMainActionTbl,@IsMainActionTbl
	Insert Into @ModuleDtlPmn
	Select PermissionName,ISApplicable,IsMainAction,RecOrder 
	From
	@PermissionNameTbl As P
	Inner Join @ISApplicableTbl As A    On A.Pno=P.Pno
	Inner Join @IsMainActionTbl As M    On M.Pno=P.Pno
	Inner Join @RecOrderMdlPmsntbl As R On R.Pno=P.Pno

    ------Declaring Cursor 
   	-- Declare Variables to hold Cursor  Values
    Declare @PermissionId BigInt,
            @FontAwesomeClass NVarchar(Max),
			@PermissionNameClm NVarchar(Max),
			@IsApplicableClm bit,
		    @IsMainActionClm Bit,
			@RecOrderMdlPmsnClm Int
			
	--Declaring Cursor
	Declare MdlDtlPmsnCsr Cursor For
	Select 	PermissionName,ISApplicable,IsMainAction,RecOrder From @ModuleDtlPmn
	--Open Cursor
	Open MdlDtlPmsnCsr;
	-- Fetch Data From Cursor
	Fetch Next From MdlDtlPmsnCsr into @PermissionNameClm,@IsApplicableClm,@IsMainActionClm,@RecOrderMdlPmsnClm;   
	While @@FETCH_STATUS=0
    Begin 
	-- Getting Id,FontAwesomeClass Data from Auth.Permission Using @PermissionNameClm
	select @PermissionId=Id,@FontAwesomeClass=FontAwesomeClass from Auth.Permission Where Name=@PermissionNameClm
	--Getting ModuleDetailPermissionId using Max(Id)
    Declare @MdlDtlPsnId Int = (Select MAX(id)+1 from Auth.ModuleDetailPermission)
	--Insert Values Into Auth.ModuleDetailPermission 
	--Print @MdlDtlId 
	--Print @Id
	--Declare ModuledetailpermissionId count to avoid repeated values
	Declare @MDPIDCNT int
	--If The count is 0 then tha data is ready for inserted otherwise it can't inserted
	select @MDPIDCNT=count(*) From Auth.ModuleDetailPermission Where ModuleDetailId=@ModuleDtlId And Heading=@Heading And PermissionId=@PermissionId
	
	--print Concat('MDlPmsncnt  ',@MDPIDCNT)
	
	If @MDPIDCNT=0
	--Begin
	Insert Into Auth.ModuleDetailPermission 
	--Insert Into @TBL 
	Values (@MdlDtlPsnId,@ModuleDtlId,@Heading,@URL,@PermissionId,@PermissionNameClm,
	        @FontAwesomeClass,@IsApplicableClm,@IsMainActionClm,@RecOrderMdlPmsnClm)
    --END

    --Set @MdlDtlId =(Select max(MDPId) from @TBL)
    Fetch Next From MdlDtlPmsnCsr into @PermissionNameClm,@IsApplicableClm,@IsMainActionClm,@RecOrderMdlPmsnClm;
	END 

	--Close Cursor
	Close MdlDtlPmsnCsr;
	--Deallocate Cursor
	Deallocate MdlDtlPmsnCsr;
   --End
   
    --Inserting Role Permission When CompanyId Is 0
	
	--Print Concat('Enter Into Rolepmsn  ', @CompanyId)
	Begin --4
	--Declaring Variables
	Declare @MODULEDETAILPRMSNID Int,
	        @MODULEDETAILID  Int,
	        --@Role uniqueidentifier,
	        @ROLEID uniqueidentifier,
			@RoleCount Int
    -- Declare table variable For ModuledetailId And ModuleDetailPermissionId
	DECLARE @MDP TABLE (MDPID INT,MDID INT)
    INSERT INTO @MDP
    SELECT Id,ModuleDetailId FROM Auth.ModuleDetailPermission WHERE ModuleDetailId=@ModuleDtlId
	--Getting RoleId 
   	SELECT @ROLEID=Id FROM Auth.Role WHERE ModuleMasterId=@MODULEMASTERID AND IsPartner IS NULL AND CompanyId=@CompanyId
	--Print @ROLEID
	
    --Declare Cursor 
    DECLARE ROLEPRMSNCSR CURSOR FOR SELECT  MDPID,MDID FROM @MDP
    --Open Cursor
	OPEN ROLEPRMSNCSR;
    FETCH NEXT FROM ROLEPRMSNCSR INTO @MODULEDETAILPRMSNID,@ModuleDtlId
    WHILE @@FETCH_STATUS=0
    BEGIN  
	-- If RoleId is Not There For ModuledetailPermissionId then Insert RoleId into Role Permission Table
    SELECT @RoleCount=COUNT(*) FROM [Auth].[RolePermission] WHERE ROLEID=@ROLEID AND MODULEDETAILPERMISSIONID=@MODULEDETAILPRMSNID
    --Print Concat('Role Count for RolePmsn Is  ',@RoleCount)
	IF @RoleCount=0
    --BEGIN
	-- Inserting Data
    INSERT INTO [Auth].[RolePermission] VALUES (NEWID(),@ROLEID,@MODULEDETAILPRMSNID,NULL,GETDATE(),NULL,NULL)
    --END
    FETCH NEXT FROM ROLEPRMSNCSR INTO @MODULEDETAILPRMSNID,@MODULEDETAILID
    END  --6
	--Close Cursor
    CLOSE ROLEPRMSNCSR;
	--Deallocate Cursor
    DEALLOCATE ROLEPRMSNCSR;
	END 
	END
    End
	 --Print @CompanyId

	 IF @CompanyId<>0
	Begin
	--Declare @ModuleDetailId int
	Declare @MdlDtlId Int,
	        @MdlDtlPmnId Int,
			@Role UniqueIdentifier,
			@CompanyUserId Int,
			@UserName Nvarchar(Max)
    -- Geeting ModuleMaster Id
	Select @ModuleMasterId=Id from Common.ModuleMaster where Name=@PrimaryCursor
	--Print concat('Modulemasterid is  ',@ModuleMasterId)
    --Getting RoleId
    Select @Role=Id from Auth.Role Where ModuleMasterId=@ModuleMasterId And CompanyId=@CompanyId And IsPartner Is null
	--Print concat('Roleid is  ',@Role) 
	--If RoleId Is In Auth.Role Then We Can Insert into RolePermission After Checking In that table 
	
	If @Role Is not null

	Begin 
    -- Declare First Cursor
	Declare ModuleDtlIdCsr cursor For
	select Id from common.ModuleDetail where GroupName=@GroupName and Heading=@Heading And ModuleMasterId=@ModuleMasterId
	--Print concat('Group name is  ',@GroupName)
	--Print concat('Heading is  ',@Heading)
	--Open first cursor
	Open ModuleDtlIdCsr;
	Fetch Next From ModuleDtlIdCsr into @MdlDtlId
	While @@FETCH_STATUS=0
	Begin
	---Declare Second Cursor
	Print Concat('Moduledetailid is ',@MdlDtlId)
	Declare MdlDtlPmnCsr Cursor For
	Select Id from Auth.ModuleDetailPermission Where ModuleDetailId=@MdlDtlId
	-- Open Second Cursor
	Open MdlDtlPmnCsr;
	Fetch Next From MdlDtlPmnCsr into @MdlDtlPmnId;
	While @@FETCH_STATUS=0
	
	Begin
	--Print concat('MdlPmsn ID Is  ',@MdlDtlPmnId)
	--Check The Records Those We Have to Insert into RolePermission table If the Records Not Available Then insert
	Select @Count=count(*) from Auth.RolePermission Where ModuleDetailPermissionId=@MdlDtlPmnId And RoleId=@Role
	--Print concat('count Is ',@Count )
	If @Count=0
	-- Inserting records Into RolePermission table
	Insert Into Auth.RolePermission
	Values(NEWID(),@Role,@MdlDtlPmnId,Null,GETDATE(),Null,Null)
	Fetch Next From MdlDtlPmnCsr into @MdlDtlPmnId;
	End
	--Close Second Cursor
	Close MdlDtlPmnCsr;
	--Print concat('MdlDtlPmnCsr','Is Closed')
	--Dealocate Second Cursor
	Deallocate MdlDtlPmnCsr;
	--Print concat('MdlDtlPmnCsr','Is Deallocate')

    Fetch Next From ModuleDtlIdCsr into @MdlDtlId
	End
	--Close First Cursor
	Close ModuleDtlIdCsr;
	--Print concat('ModuleDtlIdCsr','Is Closed')
	--Deallocate First Cursor
	Deallocate ModuleDtlIdCsr;
	--Print concat('ModuleDtlIdCsr','Is Deallocated')
	
	

	--Declare First cursor For Inserting Records into User Permission Table
	Declare CompanyuserCsr Cursor For
	Select Id,Username from Common.CompanyUser where CompanyId = @CompanyId
	--Open Cursor
	Open CompanyuserCsr;
	Fetch Next From CompanyuserCsr into @CompanyUserId,@UserName;
	--Print concat('Cmpusrid is',@CompanyUserId)
	--Print concat('User Id Is',@UserName)
	While @@FETCH_STATUS=0
	Begin
	Select @Count=count(*) from Auth.UserRole Where CompanyUserId=@CompanyUserId  And RoleId=@Role And Username=@UserName
	--Print concat('Roleid is ',@Role)
	--Print concat('Count Is',@Count) 

	If @Count<>0
	begin
	--Declare Second Cursor
	Declare MdlDtlPmnCsr02 Cursor For
	Select Id from Auth.ModuleDetailPermission Where ModuleDetailId=@MdlDtlId
	--Open Second Cursor
	Open MdlDtlPmnCsr02;
	Fetch Next From MdlDtlPmnCsr02 Into @MdlDtlPmnId;
	While @@FETCH_STATUS=0 
	Begin
	Select @count=Count(*) from Auth.UserPermission Where  CompanyUserId=@CompanyUserId And UserName=@UserName And ModuleDetailPermissionId=@MdlDtlPmnId And RoleId=@Role
	If @count=0
	--Print concat('MdlPmsn ID Is  ',@MdlDtlPmnId)
	Insert Into Auth.UserPermission 
	Select NEWID(),@CompanyUserId,@UserName,@MdlDtlPmnId,@Role,null,GETDATE(),Null,Null 
	From  Auth.RolePermission Where RoleId=@Role And ModuleDetailPermissionId=@MdlDtlPmnId
	Fetch Next From MdlDtlPmnCsr02 Into @MdlDtlPmnId;
	End
	--Close Second Cursor
	close MdlDtlPmnCsr02;
	--Print Concat('MdlDtlPmnCsr02',' Is closed')
	--Deallocate Second Cursor
	Deallocate MdlDtlPmnCsr02;
	--Print Concat('MdlDtlPmnCsr02',' DeAllocated')
	End
	Fetch Next From CompanyuserCsr into @CompanyUserId,@UserName;
	End
	--Close First Cursor
	Close CompanyuserCsr;
	--Print Concat('CompanyuserCsr',' Is closed')
	--Deallocate First Cursor
	Deallocate CompanyuserCsr;
	--Print Concat('CompanyuserCsr',' DeAllocated')
	End
	End
	End
	END 





GO
