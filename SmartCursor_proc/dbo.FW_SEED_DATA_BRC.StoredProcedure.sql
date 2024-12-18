USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_SEED_DATA_BRC]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROC [dbo].[FW_SEED_DATA_BRC] (@UNIQUE_COMPANY_ID BIGINT, @NEW_COMPANY_ID BIGINT, @UNIQUE_ID uniqueidentifier)
AS
BEGIN
DECLARE @IN_PROGRESS nvarchar(20) = 'In-Progress'
DECLARE @COMPLETED nvarchar(20) = 'Completed'
DECLARE @MODULE_NAME varchar(20) = 'BR Cursor' 
DECLARE @MODULE_ID bigint =  (select Id from Common.ModuleMaster where Name = @MODULE_NAME)
Begin Try
Begin Transaction
--================================================================
   --ControlCodeCategory, ControlCode and ControlCodeCategoryModule  Insertion
    DECLARE @ControlCode_Unique_Identifier uniqueidentifier = NEWID()
    INSERT INTO Common.DetailLog values(@ControlCode_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BRC - ControlCodes Execution Started', GETUTCDATE() , '4.1' , NULL , @IN_PROGRESS )

    EXEC [dbo].[FW_CONTROL_CODE_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_NAME

    Update Common.DetailLog set Status = @COMPLETED where Id = @ControlCode_Unique_Identifier
 --===============================================================
   --ModuleDetail Insertion
   DECLARE @ModuleDetail_Unique_Identifier uniqueidentifier = NEWID()
   INSERT INTO Common.DetailLog values(@ModuleDetail_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BRC - ModuleDetail Execution Started', GETUTCDATE() , '4.2' , NULL , @IN_PROGRESS )

   EXEC [dbo].[FW_MODULE_DETAIL_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

   Update Common.DetailLog set Status = @COMPLETED where Id = @ModuleDetail_Unique_Identifier
 --================================================================
   --InitialCursor Setup Insertion
   DECLARE @InitialCursorSetup_Unique_Identifier uniqueidentifier = NEWID()
   INSERT INTO Common.DetailLog values(@InitialCursorSetup_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BRC - InitialCursorSetup Execution Started', GETUTCDATE() , '4.3' , NULL , @IN_PROGRESS )

   EXEC [dbo].[FW_INITIAL_CURSOR_SETUP_SEED] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

   Update Common.DetailLog set Status = @COMPLETED where Id = @InitialCursorSetup_Unique_Identifier
 --============ Auto number insertion===============================================================
   DECLARE @autoNumber_Unique_Identifier uniqueidentifier = NEWID()
   INSERT INTO Common.DetailLog values(@autoNumber_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BRC - Autonumber Execution Started', GETUTCDATE() , '4.4' , NULL , @IN_PROGRESS )

   EXEC [dbo].[FW_AUTO_NUMBER_SEED_DATA] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

   Update Common.DetailLog set Status = @COMPLETED where Id = @autoNumber_Unique_Identifier
--========================== GridMetaData ===========================================
   DECLARE @gridmetadata_Unique_Identifier uniqueidentifier = NEWID()
   INSERT INTO Common.DetailLog values(@gridmetadata_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BRC - GridMetaData Execution Started', GETUTCDATE() , '4.5' , NULL , @IN_PROGRESS )

   EXEC [dbo].[FW_GRIDMETADATA_SEED_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

   Update Common.DetailLog set Status = @COMPLETED where Id = @gridmetadata_Unique_Identifier

--============================ exec dbo.BR_DynamicTemplate_SeedData =======================================
   DECLARE @dynamictemplates_Unique_Identifier uniqueidentifier = NEWID()
   INSERT INTO Common.DetailLog values(@dynamictemplates_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BRC - DynamicTemplates Execution Started', GETUTCDATE() , '4.6' , NULL , @IN_PROGRESS )

   Exec dbo.BR_DynamicTemplate_SeedData @NEW_COMPANY_ID

   Update Common.DetailLog set Status = @COMPLETED where Id = @dynamictemplates_Unique_Identifier

--================================ exec dbo.BR_GenericTemplate_SeedData ============================================ 
   DECLARE @generictemplates_Unique_Identifier uniqueidentifier = NEWID()
   INSERT INTO Common.DetailLog values(@generictemplates_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BRC - GenericTemplates Execution Started', GETUTCDATE() , '4.7' , NULL , @IN_PROGRESS )

   Exec dbo.BR_GenericTemplate_SeedData @NEW_COMPANY_ID

   Update Common.DetailLog set Status = @COMPLETED where Id = @generictemplates_Unique_Identifier

--================================================= insert companytypendsuffix===============================================
   DECLARE @suffix_Unique_Identifier uniqueidentifier = NEWID()
   INSERT INTO Common.DetailLog values(@suffix_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BRC - Suffix Execution Started', GETUTCDATE() , '4.8' , NULL , @IN_PROGRESS )
   
   Declare @GetDate DateTime=GETUTCDATE()
	  --Select Id,Name,RecOrder From Boardroom.Suffix where CompanyId=679

--=================================================insert into Boardroom.Suffix =============================
   If Not exists (	Select Id From Boardroom.Suffix Where  CompanyId=@NEW_COMPANY_ID )
   Begin
	Declare @SuffixId bigint Set @SuffixId=(select Max(Id) from Boardroom.Suffix)
	Declare @SuffixTemp Table (OldId Int,Id bigint,Name nvarchar(524),CompanyId bigint,RecOrder int,Remarks nvarchar(256),UserCreated nvarchar(254),CreatedDate datetime2,ModifiedBy nvarchar(524),ModifiedDate datetime2,Version smallint,TempSuffixId bigint,Status int) 
	
	Insert Into @SuffixTemp 
	Select Id As OldId,@SuffixId+Row_Number() Over (Order By Name) Id,Name As Name,@NEW_COMPANY_ID,RecOrder,NULL,'System',@GetDate,null,null,null,null,1 From Boardroom.Suffix where CompanyId=@UNIQUE_COMPANY_ID 
	
	insert into Boardroom.Suffix 
	select Id ,Name ,CompanyId ,RecOrder ,Remarks ,UserCreated ,CreatedDate ,ModifiedBy ,ModifiedDate ,Version ,TempSuffixId ,Status from @SuffixTemp
    Update Common.DetailLog set Status = @COMPLETED where Id = @suffix_Unique_Identifier

--==================================== insert into Boardroom.CompanyType =============================
 
     DECLARE @companytype_Unique_Identifier uniqueidentifier = NEWID()
     INSERT INTO Common.DetailLog values(@companytype_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BRC - CompanyType Execution Started', GETUTCDATE() , '4.9' , NULL , @IN_PROGRESS )
	 
	 Declare @CompanyTypeId Bigint
	 Set @CompanyTypeId =(select Max(Id) from Boardroom.CompanyType)
	 Declare @CompTypTemp Table (OldCompTypId Int,Id bigint,Name nvarchar(524),CompanyId bigint,RecOrder int,Remarks nvarchar(256),UserCreated nvarchar(254),CreatedDate datetime2,ModifiedBy nvarchar(254),ModifiedDate datetime2,Version smallint,TempCompanyTypeId bigint,Status int) 
	 
	 Insert Into @CompTypTemp 
	 Select Id As OldId,@CompanyTypeId+Row_Number() Over (Order By Name) Id,Name As Name,@NEW_COMPANY_ID,RecOrder,NULL,'System',@GetDate,null,null,null,null,1 From Boardroom.CompanyType where CompanyId=@UNIQUE_COMPANY_ID
	 
	 Insert Into Boardroom.CompanyType 
	 select Id ,Name ,CompanyId ,RecOrder ,Remarks ,UserCreated ,CreatedDate ,ModifiedBy ,ModifiedDate ,Version ,TempCompanyTypeId ,Status from  @CompTypTemp 
     Update Common.DetailLog set Status = @COMPLETED where Id = @companytype_Unique_Identifier

 --==================================== insert into Boardroom.CompanyTypeSuffix =============================
     DECLARE @companytypendsuffix_Unique_Identifier uniqueidentifier = NEWID()
     INSERT INTO Common.DetailLog values(@companytypendsuffix_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BRC - CompanyTypeAndSuffix Execution Started', GETUTCDATE() , '4.10' , NULL , @IN_PROGRESS )
	 
     Declare @CompanyTypeSuffixId bigint Set @CompanyTypeSuffixId=(select Max(Id) from Boardroom.CompanyTypeSuffix )

	 Declare @CompanyTypeSuffixOrder bigint 
	 Set @CompanyTypeSuffixOrder=(select Max(RecOrder) from Boardroom.CompanyTypeSuffix )
	 
	 insert into Boardroom.CompanyTypeSuffix
	 Select @CompanyTypeSuffixId+Row_Number() Over (Order By suffixId) Id,C.Id companytypeId, B.Id As SuffixId, @CompanyTypeSuffixOrder+Row_Number() Over (Order By suffixId) Recorder From Boardroom.CompanyTypeSuffix As A Join @SuffixTemp As B On B.OldId=A.SuffixId Join @CompTypTemp As C On C.OldCompTypId=A.CompanyTypeId

     Update Common.DetailLog set Status = @COMPLETED where Id = @companytypendsuffix_Unique_Identifier

	 	--Notification seed data
	DECLARE @notificationSettings_Unique_Identifier uniqueidentifier = NEWID()


		INSERT INTO Common.DetailLog values(@notificationSettings_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_BR - Notifications Execution Started', GETUTCDATE() , '6.10' , NULL , @IN_PROGRESS )
	Begin

		If Not Exists (Select * From Notification.NotificationSettings WHere CompanyId=@NEW_COMPANY_ID And CursorName= 'BR Cursor')
		Begin
			Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,	NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

			Select NEWID(),@NEW_COMPANY_ID,Null as CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,null,null,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate
			From Notification.NotificationSettings Where CompanyId=@UNIQUE_COMPANY_ID And CursorName= 'BR Cursor'
		End
	END
	Update Common.DetailLog set Status = @COMPLETED where Id = @notificationSettings_Unique_Identifier
	END
Declare @ErrorMessage Nvarchar(1000), @ErrorServirity Int, @ErrorState Int
 
	Commit Transaction
	End Try
	Begin Catch
	RollBack Transaction 
	Select @ErrorMessage=ERROR_MESSAGE(),
	@ErrorServirity=ERROR_SEVERITY(),
	@ErrorState=ERROR_STATE()
	RAISERROR(@ErrorMessage,@ErrorServirity,@ErrorState)
	End Catch
	BEGIN
    Print 'BRC SP Completed'


    END
END
GO
