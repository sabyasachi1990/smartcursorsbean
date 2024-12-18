USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_SEED_DATA_AUDIT]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 
CREATE   PROC [dbo].[FW_SEED_DATA_AUDIT](@UNIQUE_COMPANY_ID bigint, @NEW_COMPANY_ID bigint, @UNIQUE_ID uniqueidentifier)
AS
BEGIN
DECLARE @STATUS INT = 1
DECLARE @CREATED_DATE DATETIME = GETUTCDATE()
DECLARE @IS_ACCOUNTING_FIRM bit = (select IsAccountingFirm  from Common.Company where Id=@NEW_COMPANY_ID)
DECLARE @PARTNER_COMPANYID bigint = (select AccountingFirmId  from Common.Company where Id=@NEW_COMPANY_ID)
DECLARE @MODULE_NAME varchar(20) = 'Audit Cursor'
DECLARE @MODULE_ID bigint =  (select Id from Common.ModuleMaster where Name = @MODULE_NAME)
DECLARE @IN_PROGRESS nvarchar(20) = 'In-Progress'
DECLARE @COMPLETED nvarchar(20) = 'Completed'
--BEGIN TRANSACTION
BEGIN TRY

--================================================================
--ControlCodeCategory, ControlCode and ControlCodeCategoryModule  Insertion
DECLARE @ControlCode_Unique_Identifier uniqueidentifier = NEWID()
INSERT INTO Common.DetailLog values(@ControlCode_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - ControlCodes Execution Started', GETUTCDATE() , '2.1' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_CONTROL_CODE_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_NAME

 Update Common.DetailLog set Status = @COMPLETED where Id = @ControlCode_Unique_Identifier
 --===============================================================
 --ModuleDetail Insertion
 DECLARE @ModuleDetail_Unique_Identifier uniqueidentifier = NEWID()
 INSERT INTO Common.DetailLog values(@ModuleDetail_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - ModuleDetail Execution Started', GETUTCDATE() , '2.2' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_MODULE_DETAIL_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

  Update Common.DetailLog set Status = @COMPLETED where Id = @ModuleDetail_Unique_Identifier
 --================================================================
 --InitialCursor Setup Insertion
  DECLARE @InitialCursorSetup_Unique_Identifier uniqueidentifier = NEWID()
 INSERT INTO Common.DetailLog values(@InitialCursorSetup_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - InitialCursorSetup Execution Started', GETUTCDATE() , '2.3' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_INITIAL_CURSOR_SETUP_SEED] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

  Update Common.DetailLog set Status = @COMPLETED where Id = @InitialCursorSetup_Unique_Identifier
 --============ Auto number insertion===============================================================
   DECLARE @autoNumber_Unique_Identifier uniqueidentifier = NEWID()
 INSERT INTO Common.DetailLog values(@autoNumber_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - AutoNumber Execution Started', GETUTCDATE() , '2.4' , NULL , @IN_PROGRESS )
 EXEC [dbo].[FW_AUTO_NUMBER_SEED_DATA] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

  Update Common.DetailLog set Status = @COMPLETED where Id = @autoNumber_Unique_Identifier

 --======================== GridMetaData ==========================
 DECLARE @gridmetadata_Unique_Identifier uniqueidentifier = NEWID()
 INSERT INTO Common.DetailLog values(@gridmetadata_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - GridMetaData Execution Started', GETUTCDATE() , '2.5' , NULL , @IN_PROGRESS )

 EXEC [dbo].[FW_GRIDMETADATA_SEED_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @MODULE_ID

   Update Common.DetailLog set Status = @COMPLETED where Id = @gridmetadata_Unique_Identifier
 --==================================================================

IF @IS_ACCOUNTING_FIRM=1  
 BEGIN       

  -------EngagementType-----

	DECLARE @engagement_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@engagement_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - Engagement Execution Entered', GETUTCDATE() , '2.6' , NULL , @IN_PROGRESS )
	DECLARE @EngagementType_Cnt bigint;
	select  @EngagementType_Cnt=Count(*) from  [Audit].EngagementType where companyid=@NEW_COMPANY_ID 
	IF @EngagementType_Cnt=0
	Begin
		Insert into Audit.EngagementType(Id,CompanyId,Name,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Issystem) 
			Select NewId(),@NEW_COMPANY_ID,[Name],'System',GETUTCDATE(),NULL,NULL,1,1 from Audit.EngagementType where CompanyId=@UNIQUE_COMPANY_ID
	END
	 Update Common.DetailLog set Status = @COMPLETED where Id = @engagement_Unique_Identifier


----------Audit Manual ------------

if not exists(select * from Audit.AuditManual where Name='Custom' and CompanyId=@NEW_COMPANY_ID)        
	begin
		insert into Audit.AuditManual(Id,Name,CompanyId,Version,Description,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate)
		values(NEWID(),'Custom',@NEW_COMPANY_ID,'V1','',1,'system',GETDATE(),NULL,NULL)
	end
	
IF NOT EXISTS(select * from Audit.LeadSheetSetupMaster where AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') and CompanyId=@NEW_COMPANY_ID)        
	Begin
		INSERT INTO Audit.LeadSheetSetupMaster(Id,CompanyId,AuditManual,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,AuditManualId)
		values(NEWID(),@NEW_COMPANY_ID,'Custom',1,'system',GETDATE(),NULL,NULL,(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom'))
	End

if not exists(select * from Audit.PlanningAndCompletionSetUpMaster where AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') and EngagementTypeId=(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID) and CompanyId=@NEW_COMPANY_ID)        
	begin
		insert into Audit.PlanningAndCompletionSetUpMaster(Id,CompanyId,AuditManualId,EngagementTypeId,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate)
		values(NEWID(),@NEW_COMPANY_ID,(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom'),(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID),1,'system',GETDATE(),NULL,NULL)
	end

	--if not exists(select * from Audit.PlanningAndCompletionSetUpMaster where AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') and EngagementTypeId=(select id from Audit.EngagementType where Name='Compilation' and CompanyId=@NEW_COMPANY_ID) and CompanyId=@NEW_COMPANY_ID)        
	--begin
	--	insert into Audit.PlanningAndCompletionSetUpMaster(Id,CompanyId,AuditManualId,EngagementTypeId,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate)
	--	values(NEWID(),@NEW_COMPANY_ID,(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom'),(select id from Audit.EngagementType where Name='Compilation' and CompanyId=@NEW_COMPANY_ID),1,'system',GETDATE(),NULL,NULL)
	--end

	
if not exists(select * from Audit.WPSetupMaster where AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') and EngagementTypeId=(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID) and CompanyId=@NEW_COMPANY_ID)        
	begin
		insert into Audit.WPSetupMaster(Id,CompanyId,AuditManualId,EngagementTypeId,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate)
		values(NEWID(),@NEW_COMPANY_ID,(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom'),(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID),1,'system',GETDATE(),NULL,NULL)
	end

if not exists(select * from Audit.FSTemplates where AuditManual='Custom' and Year=YEAR(GETDATE()) and CompanyId=@NEW_COMPANY_ID)        
	begin
		insert into Audit.FSTemplates(Id,CompanyId,AuditManual,Year,Status,UserCreated,CreatedDate,ModifiedBy,ModifiedDate)
		values(NEWID(),@NEW_COMPANY_ID,'Custom',YEAR(GETDATE()),1,'system',GETDATE(),NULL,NULL)
	end

If Not Exists(select * from Audit.SuggestionSetUpMaster where AuditManualid=(select id from audit.AuditManual where companyid=@NEW_COMPANY_ID and Name='Custom') and CompanyId=@NEW_COMPANY_ID)        
	Begin
		DECLARE @suggestion TABLE(screenname nvarchar(max),section NVARCHAR(MAX))  
			INSERT INTO @suggestion select  DISTINCT  screenname,section from common.[Suggestion ] where CompanyId=@UNIQUE_COMPANY_ID

		Insert Into Audit.SuggestionSetUpMaster (Id,companyid,auditmanualid,ScreenName,Section,UserCreated,CreatedDate,Status)
		select NEWID(),@NEW_COMPANY_ID,(select id from audit.AuditManual where companyid=@NEW_COMPANY_ID and name='Custom'),suggestion.screenname,suggestion.section,'System',GETUTCDATE(),1 from @suggestion as suggestion
	End 

-------------Suggestion Set Up------------------

DECLARE @suggestionSetup_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@suggestionSetup_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - Suggestion Setup Execution Entered', GETUTCDATE() , '2.7' , NULL , @IN_PROGRESS )
DECLARE @SuggestionSetUp_Cnt bigint;
select @SuggestionSetUp_Cnt=Count(*) from common.[Suggestion ] where CompanyId=@NEW_COMPANY_ID
IF @SuggestionSetUp_Cnt=0
BEGIN       
	Insert into common.[Suggestion ] (id,CompanyId,ScreenName,Section,Title,Description,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,ReferenceId,MasterId,AuditManualId)      
	select Newid(),@NEW_COMPANY_ID,ScreenName,Section,Title,Description,Remarks,RecOrder,UserCreated,GETUTCDATE(), null, Null, Version, Status, ReferenceId,(select id from Audit.SuggestionSetUpMaster where ScreenName=sug.ScreenName and Section=sug.Section and CompanyId=@NEW_COMPANY_ID),(select id from audit.AuditManual where Name='Custom' and CompanyId=@NEW_COMPANY_ID) from common.[Suggestion ] as sug where CompanyId=@UNIQUE_COMPANY_ID      
END
	Update Common.DetailLog set Status = @COMPLETED where Id = @suggestionSetup_Unique_Identifier
------TickMarksetup--------

DECLARE @tickMarkSetup_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@tickMarkSetup_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - TickMark Setup Execution Entered', GETUTCDATE() , '2.8' , NULL , @IN_PROGRESS )
Declare @TickMarkSetup_Cnt bigint;      
 select  @TickMarkSetup_Cnt=Count(*) from  [Audit].[TickMarkSetup] where companyid=@NEW_COMPANY_ID       
   IF @TickMarkSetup_Cnt=0      
   BEGIN
   INSERT INTO [Audit].[TickMarkSetup] (Id,CompanyId,Code,[Description],IsSystem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,    [Version],   [Status],IsPlanning,IsCompletion,IsPartner,ReferenceId)      
           select NewId(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[IsSystem],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL AS        [ModifiedBy],NULL AS [ModifiedDate],[Version],[Status],[IsPlanning],[IsCompletion],1,[ReferenceId]   From [Audit].[TickMarkSetup] Where CompanyId = @UNIQUE_COMPANY_ID;
	END
	Update Common.DetailLog set Status = @COMPLETED where Id = @tickMarkSetup_Unique_Identifier
--------WorkProgram setup-----------

DECLARE @workProgramSetup_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@workProgramSetup_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - WorkProgram Setup Execution Entered', GETUTCDATE() , '2.9' , NULL , @IN_PROGRESS )
Declare @WPSetup_Cnt int;      
  select @WPSetup_Cnt=Count(*) from [Audit].[WPSetup] where companyid=@NEW_COMPANY_ID       
  IF @WPSetup_Cnt=0      
    BEGIN
	INSERT INTO [Audit].[WPSetup] (Id,CompanyId,Code,[Description],Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,[Version],      [Status],ShortCode,IsPartner,ReferenceId,EngagementTypeId,AuditManualId,WpsetupMasterId)      
            select NewID(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL as       [ModifiedBy],NULL as [ModifiedDate],[Version],[Status],[ShortCode],1,[Id],(select id from Audit.EngagementType where CompanyId=@NEW_COMPANY_ID and Name='Statutory Audit'), (select id from audit.AuditManual where Name='Custom' and CompanyId=@NEW_COMPANY_ID) ,(select Id from Audit.WPSetupMaster where AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') and EngagementTypeId=(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID)and CompanyId=@NEW_COMPANY_ID)     
            From [Audit].[WPSetup] Where CompanyId = @UNIQUE_COMPANY_ID and Remarks='Precursor';
	END  
	Update Common.DetailLog set Status = @COMPLETED where Id = @workProgramSetup_Unique_Identifier

--------Leadsheet Setup------------

DECLARE @leadSheetSetup_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@leadSheetSetup_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - LeadSheet Setup Execution Entered', GETUTCDATE() , '2.10' , NULL , @IN_PROGRESS )	    
Declare @Leadsheet_Cnt bigint; 
   Declare @LeadsheetID uniqueidentifier,@WorkprogramId uniqueidentifier     
   select @Leadsheet_Cnt=Count(*) from [Audit].[Leadsheet] where companyid=@NEW_COMPANY_ID   and AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom')
    If @Leadsheet_Cnt=0      
    BEGIN
	Insert Into [Audit].[Leadsheet] (Id, CompanyId, WorkProgramId, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version,WorkProgramName, Status,IsPartner,ReferenceId,Disclosure ,AuditManual,AuditManualId,MasterId)      
							select Newid() as leadsheetid, @NEW_COMPANY_ID as newcompanyid,pp.Newcompanyid, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, GETUTCDATE(),NULL AS ModifiedBy,NULL AS ModifiedDate, Version,WorkProgramName ,Status ,1,   
								[ReferenceId],Disclosure,L.AuditManual,(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom'),(select Id from Audit.LeadSheetSetupMaster where AuditManual='Custom' and CompanyId=@NEW_COMPANY_ID)  from  [Audit].[LeadSheet]  as L      
								INNER JOIN      
								(      
								select P.Id as 'Newcompanyid',w.Id as 'Oldcompanyid' from audit.WPSetup as w      
								INNER JOIN       
								(      
								select id,code,Description from audit.WPSetup where companyid =@NEW_COMPANY_ID and Remarks='Precursor'     
								) as p ON P.Code=w.Code and P.Description=w.Description      
                        
								where companyid in (@UNIQUE_COMPANY_ID)      
								) as PP On PP.Oldcompanyid=WorkProgramId      
                        
								where CompanyId=@UNIQUE_COMPANY_ID and AuditManualId='BEB484C0-9CC4-43DC-BFE4-5557564DF4C8'  and Engagementid is null
	END
	Update Common.DetailLog set Status = @COMPLETED where Id = @leadSheetSetup_Unique_Identifier
--------LeadSheetCategories----------

DECLARE @leadSheetCategories_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@leadSheetCategories_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - LeadSheet Categories Execution Entered', GETUTCDATE() , '2.11' , NULL , @IN_PROGRESS )	
Declare @LeadSheetCategories_Cnt bigint;      
    select @LeadSheetCategories_Cnt=Count(*) from [Audit].[LeadSheetCategories] where LeadsheetId in (select Id from audit.leadsheet where CompanyId= @NEW_COMPANY_ID and AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') )      
    If @LeadSheetCategories_Cnt=0 
	
	Insert Into [Audit].[LeadSheetCategories] ([Id],[LeadsheetID],[Name],[RecOrder],[Status],IsSystem)
				  SELECT newid() as Id ,(select ID FROM [Audit].[LeadSheet] where CompanyId = @NEW_COMPANY_ID and 
				   AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') 
				   and Engagementid is null and 
				   LeadSheetName = (select LeadSheetName FROM [Audit].[LeadSheet] where Id = cat.[LeadsheetID] and 
				   CompanyId = @UNIQUE_COMPANY_ID and AuditManualId='BEB484C0-9CC4-43DC-BFE4-5557564DF4C8' and Engagementid is null))   as [LeadsheetID]  ,
				   cat.[Name] ,cat.[RecOrder]  ,cat.[Status],cat.IsSystem  FROM [Audit].[LeadSheetCategories] cat inner join 
				   [Audit].[LeadSheet] ld  on ld.Id = cat.LeadsheetID  where ld.CompanyId = @UNIQUE_COMPANY_ID 
				   and  ld.AuditManualId='BEB484C0-9CC4-43DC-BFE4-5557564DF4C8'  and ld.Engagementid is null


	END
	Update Common.DetailLog set Status = @COMPLETED where Id = @leadSheetCategories_Unique_Identifier
----------Reporting Templates Only of it is Partner Company then create under new Company---------

DECLARE @reportingTemplates_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@reportingTemplates_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - Reporting Templates Execution Entered', GETUTCDATE() , '2.12' , NULL , @IN_PROGRESS )
Declare @ReportingTemplates_Cnt bigint;
Select @ReportingTemplates_Cnt=COUNT(*) from Audit.ReportingTemplates where PartnerCompanyId=@NEW_COMPANY_ID
IF @ReportingTemplates_Cnt=0
Begin
	declare @companyCreationdate datetime2(7)=(select CreatedDate  from Common.Company where id=@NEW_COMPANY_ID);
	 BEGIN 
		  Insert into Audit.ReportingTemplates (Id,PartnerCompanyId,EngagementId,TemplateName,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,EffectiveFrom)
		 Select Newid(),@NEW_COMPANY_ID,EngagementId,TemplateName,'Sysytem',GETUTCDATE(),null,Null,Status,@companyCreationdate from Audit.ReportingTemplates where PartnerCompanyId=@UNIQUE_COMPANY_ID and EngagementId Is Null
	 END
END
Update Common.DetailLog set Status = @COMPLETED where Id = @reportingTemplates_Unique_Identifier
--=================================================================================================
 --for new AU user role 
 --role--

 DECLARE @AU_User_role_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@AU_User_role_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - AU User Role Execution Entered', GETUTCDATE() , '2.12' , NULL , @IN_PROGRESS )
 IF NOT EXISTS (SELECT * FROM [Auth].[Role] where Name='AU User' and [ModuleMasterId]=(select Id from Common.ModuleMaster where CompanyId=0 and Heading='Audit Cursor') and CompanyId=@NEW_COMPANY_ID)       
   BEGIN      
       INSERT [Auth].[Role] ([Id], [CompanyId], [Name], [Remarks], [ModuleMasterId], [Status], [ModifiedBy], [ModifiedDate], [UserCreated], [CreatedDate],[IsSystem],[BackgroundColor],[CursorIcon],[IsPartner])      
       VALUES (newid(),@NEW_COMPANY_ID, N'AU User', NULL,(select Id from Common.ModuleMaster where CompanyId=0 and Heading='Audit Cursor'), 1, NULL, NULL, NULL, GETUTCDATE(),1,N'#67acda',N'role-auuser',0)      
   END
   Update Common.DetailLog set Status = @COMPLETED where Id = @AU_User_role_Unique_Identifier

   --role permission--

    DECLARE @AU_User_rolepermission_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@AU_User_rolepermission_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - AU User Role Permission Execution Entered', GETUTCDATE() , '2.13' , NULL , @IN_PROGRESS )

   IF NOT EXISTS (SELECT * FROM Auth.RolePermission where RoleId=(select Id from Auth.Role where CompanyId=@NEW_COMPANY_ID and Name='AU User'))       
   BEGIN      
	   Insert into Auth.RolePermission (ID, RoleID, ModuleDetailPermissionID)      
	   Select NEWID(), R.ID as RoleID,  MDP.ID ModulePermissionDetailID      
	   From Auth.Role R Inner Join Common.ModuleMaster MM on MM.ID = R.ModuleMasterId       
	   Inner Join Common.ModuleDetail MD on MD.ModuleMasterId = MM.ID Inner Join AUTH.ModuleDetailPermission MDP on MDP.ModuleDetailId = MD.ID      
	   Where R.Name = 'AU User' And R.CompanyId=@NEW_COMPANY_ID and MD.IsPartner=0 and MD.GroupName in ('Client','Summary') and  MD.ModuleMasterId=(select Id from Common.ModuleMaster where Name='Audit Cursor' and CompanyId=0) and MDP.PermissionName='View'   
   END
   Update Common.DetailLog set Status = @COMPLETED where Id = @AU_User_rolepermission_Unique_Identifier
--------PlannigAndCompletionSetUp---------

DECLARE @planningAndCompletionSetup_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@planningAndCompletionSetup_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - Planning And Completion Setup Cursor Execution Entered', GETUTCDATE() , '2.14' , NULL , @IN_PROGRESS )

Declare @PartnerCompany_Cnt int;      
  select @PartnerCompany_Cnt=COUNT(*)  from [Common].[Company] where id=@NEW_COMPANY_ID and ParentId is null and IsAccountingFirm=1      
  IF @PartnerCompany_Cnt!=0      
  BEGIN      
 Declare @PandCSetup_Cnt int;      
 select @PandCSetup_Cnt=Count(*) from [Audit].[PlanningAndCompletionSetUp] where companyid=@NEW_COMPANY_ID  and Auditmanualid=(select id from audit.auditmanual where companyid=@NEW_COMPANY_ID and Name='Custom')      
 IF @PandCSetup_Cnt=0      
 BEGIN      
	--1 Audit.PlanningAndCompletionSetUp      
	 DECLARE @PAC_UNQC TABLE(ID UNIQUEIDENTIFIER,COMPANYID BIGINT,CODE NVARCHAR(MAX))      
	 DECLARE @PAC_ID_FOR_UNQC UNIQUEIDENTIFIER      
	 DECLARE @PAC_UNQCID BIGINT      
	 DECLARE @PAC_MCODE NVARCHAR(MAX)      
	 DECLARE @PAC_NEWID UNIQUEIDENTIFIER      
      
	 INSERT INTO @PAC_UNQC       
	 SELECT ID,COMPANYID,MenuCode FROM Audit.PlanningAndCompletionSetUp WHERE COMPANYID=@UNIQUE_COMPANY_ID AND AuditManualId is null and MasterId is null and Engagementtype!='Compilation'
      
	 --2 Audit.PAndCSections      
      
	 DECLARE @SEC_UNQC TABLE(ID UNIQUEIDENTIFIER,PAC_ID UNIQUEIDENTIFIER,SECTION NVARCHAR(MAX),DESCRIPTION NVARCHAR(MAX))      
      
	 DECLARE @SEC_ID UNIQUEIDENTIFIER      
	 DECLARE @SEC_PAC_ID UNIQUEIDENTIFIER      
	 DECLARE @SECTION NVARCHAR(MAX)      
	 DECLARE @DESCRIPTION NVARCHAR(MAX)      
	 DECLARE @SEC_NEWID UNIQUEIDENTIFIER      
      
	  --2 Audit.DirectorRemuneration       
      
	 DECLARE @SEC_UNQC1 TABLE(ID UNIQUEIDENTIFIER,PAC_ID UNIQUEIDENTIFIER)      
      
	 DECLARE @SEC_ID1 UNIQUEIDENTIFIER      
	 DECLARE @SEC_PAC_ID1 UNIQUEIDENTIFIER      
	 DECLARE @SEC_NEWID1 UNIQUEIDENTIFIER      
      
      
	 -- CURSOR FOR PAC TABLE      
	 DECLARE PAC CURSOR FOR SELECT * FROM @PAC_UNQC       
	 OPEN PAC      
	   FETCH NEXT FROM PAC INTO @PAC_ID_FOR_UNQC,@PAC_UNQCID,@PAC_MCODE       
	   WHILE (@@FETCH_STATUS=0)      
		   BEGIN      
		  SELECT @PAC_NEWID =NEWID()      
		  INSERT INTO Audit.PlanningAndCompletionSetUp(Id,CompanyId,AuditCompanyId,EngagementId,ModuleDetailId,Type,MenuCode,MenuName,Description,FormType,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder,EngagementType,Conclusion,IsMigrated,ConclusionLable,TypeId,IsSignPartner,AuditManualId,Title,EnableDescription,EngagementTypeId,MasterId)      
		  SELECT @PAC_NEWID,@NEW_COMPANY_ID,AuditCompanyId,EngagementId,ModuleDetailId,Type,MenuCode,MenuName,Description,FormType,Remarks,UserCreated,GETUTCDATE(),NULL,NULL,Status,Recorder,EngagementType,Conclusion,IsMigrated,ConclusionLable ,Id ,IsSignPartner,(select Id from audit.auditmanual where companyid=@NEW_COMPANY_ID and Name='Custom'),Title,EnableDescription ,(select id from Audit.EngagementType where CompanyId=@NEW_COMPANY_ID and Name='Statutory Audit'),(select Id from Audit.PlanningAndCompletionSetUpMaster where AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') and EngagementTypeId=(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID) and CompanyId=@NEW_COMPANY_ID)
		  FROM Audit.PlanningAndCompletionSetUp WHERE ID=@PAC_ID_FOR_UNQC 
      
		  IF EXISTS(SELECT * FROM @SEC_UNQC)      
		  BEGIN      
		   DELETE FROM @SEC_UNQC       
		  END      
      
		  INSERT INTO @SEC_UNQC       
		  SELECT ID,PlanningAndCompletionSetUpId,Heading,DESCRIPTION FROM Audit.PAndCSections WHERE PlanningAndCompletionSetUpId=@PAC_ID_FOR_UNQC      
      
		  -- CURSOR FOR PAndCSections TABLE and PAndCSectionQuestions      
		  DECLARE SECTION CURSOR FOR SELECT * FROM @SEC_UNQC       
		  OPEN SECTION      
			 FETCH NEXT FROM SECTION INTO @SEC_ID,@SEC_PAC_ID,@SECTION,@DESCRIPTION      
			 WHILE (@@FETCH_STATUS=0)      
			 BEGIN      
			   SELECT @SEC_NEWID =NEWID()      
      
			   INSERT INTO Audit.PAndCSections(Id,PlanningAndCompletionSetUpId,Heading,Description,CommentLable,CommentDescription,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder)      
			   SELECT @SEC_NEWID,@PAC_NEWID,Heading,DESCRIPTION,CommentLable,CommentDescription,Remarks,UserCreated,GETUTCDATE(),NULL,NULL,Status,Recorder      
			   FROM Audit.PAndCSections WHERE ID=@SEC_ID --AND PlanningAndCompletionSetUpId=@SEC_PAC_ID AND Heading=@SECTION AND DESCRIPTION=@DESCRIPTION      
      
         
			   INSERT INTO Audit.PAndCSectionQuestions (Id,PAndCSectionId,Question,QuestionOptions,Answer,IsComment,Comment,IsAttachement,AttachmentsCount,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder,AttachmentName,PreviousQuestionId)      
			   SELECT NEWID(),@SEC_NEWID,Question,QuestionOptions,Answer,IsComment,Comment,IsAttachement,AttachmentsCount,Remarks,UserCreated,GETUTCDATE(),NULL,NULL,Status,Recorder,AttachmentName,PreviousQuestionId      
			   FROM Audit.PAndCSectionQuestions WHERE PAndCSectionId=@SEC_ID      
      
      
      
   FETCH NEXT FROM SECTION INTO @SEC_ID,@SEC_PAC_ID,@SECTION,@DESCRIPTION      
     END      
  CLOSE SECTION      
  DEALLOCATE SECTION      
      
  --renumaration and renumaration details      
   IF EXISTS(SELECT * FROM @SEC_UNQC1)      
  BEGIN      
   DELETE FROM @SEC_UNQC1       
  END      
      
  INSERT INTO @SEC_UNQC1       
  SELECT ID,PlanningAndCompletionSetUpId FROM Audit.DirectorRemuneration WHERE PlanningAndCompletionSetUpId=@PAC_ID_FOR_UNQC      
      
  -- CURSOR FOR Audit.DirectorRemuneration TABLE and Audit.DirectorRemuneration      
  DECLARE SECTION1 CURSOR FOR SELECT * FROM @SEC_UNQC1       
  OPEN SECTION1      
     FETCH NEXT FROM SECTION1 INTO @SEC_ID1,@SEC_PAC_ID1      
     WHILE (@@FETCH_STATUS=0)      
     BEGIN      
   SELECT @SEC_NEWID1 =NEWID()      
      
   INSERT INTO Audit.DirectorRemuneration (Id,PlanningAndCompletionSetUpId,AuditCompanyContactId,EngagementId,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder,Description,Conclusion)      
   SELECT @SEC_NEWID1,@PAC_NEWID,AuditCompanyContactId,EngagementId,UserCreated,GETUTCDATE(),NULL,NULL,Status,Recorder,[Description],Conclusion      
   FROM Audit.DirectorRemuneration WHERE ID=@SEC_ID1 --AND PlanningAndCompletionSetUpId=@SEC_PAC_ID AND Heading=@SECTION AND DESCRIPTION=@DESCRIPTION      
   INSERT INTO Audit.DirectorRemunerationDetails (Id,DirectorRemunerationId,Heading,HeadingRecorder,LineItemName,LineItemAmount,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder)      
   SELECT NEWID(),@SEC_NEWID1,Heading,HeadingRecorder,LineItemName,LineItemAmount,UserCreated,GETUTCDATE(),NULL,NULL,Status,Recorder      
   FROM Audit.DirectorRemunerationDetails WHERE DirectorRemunerationId=@SEC_ID1      
      
   FETCH NEXT FROM SECTION1 INTO @SEC_ID1,@SEC_PAC_ID1      
     END      
  CLOSE SECTION1      
  DEALLOCATE SECTION1      
      
  FETCH NEXT FROM PAC INTO @PAC_ID_FOR_UNQC,@PAC_UNQCID,@PAC_MCODE       
   END      
 CLOSE PAC      
 DEALLOCATE PAC      
 END      
 END

 Update Common.DetailLog set Status = @COMPLETED where Id = @planningAndCompletionSetup_Unique_Identifier

-------------------------------
--update audit.PlanningAndCompletionSetUp set EngagementTypeId=(select id from Audit.EngagementType where CompanyId=@NEW_COMPANY_ID and Name='Statutory Audit'),AuditManualId=(select id from audit.AuditManual where Name='Custom' and CompanyId=@NEW_COMPANY_ID),MasterId=(select Id from Audit.PlanningAndCompletionSetUpMaster where AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') and EngagementTypeId=(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID) and CompanyId=@NEW_COMPANY_ID) where CompanyId=@NEW_COMPANY_ID and EngagementId is null and EngagementType='Statutory Audit'

--update audit.PlanningAndCompletionSetUp set EngagementTypeId=(select id from Audit.EngagementType where CompanyId=@NEW_COMPANY_ID and Name='Compilation'),AuditManualId=(select id from audit.AuditManual where Name='Custom' and CompanyId=@NEW_COMPANY_ID),MasterId=(select Id from Audit.PlanningAndCompletionSetUpMaster where AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') and EngagementTypeId=(select id from Audit.EngagementType where Name='Compilation' and CompanyId=@NEW_COMPANY_ID)and CompanyId=@NEW_COMPANY_ID) where CompanyId=@NEW_COMPANY_ID and EngagementId is null and EngagementType='Compilation'

--update audit.WPSetup set EngagementTypeId=(select id from Audit.EngagementType where CompanyId=@NEW_COMPANY_ID and Name='Statutory Audit'),AuditManualId=(select id from audit.AuditManual where Name='Custom' and CompanyId=@NEW_COMPANY_ID),WpsetupMasterId=(select Id from Audit.WPSetupMaster where AuditManualId=(select id from Audit.AuditManual where CompanyId=@NEW_COMPANY_ID and Name='Custom') and EngagementTypeId=(select id from Audit.EngagementType where Name='Statutory Audit' and CompanyId=@NEW_COMPANY_ID)and CompanyId=@NEW_COMPANY_ID) where CompanyId=@NEW_COMPANY_ID and EngagementId is null  and Remarks='Precursor'

--update Common.[Suggestion ] set AuditManualId=(select id from audit.AuditManual where Name='Custom' and CompanyId=@NEW_COMPANY_ID) where CompanyId=@NEW_COMPANY_ID and EngagementId is null 

--update Audit.LeadSheet set AuditManual='Custom',MasterId=(select Id from Audit.LeadSheetSetupMaster where AuditManual='Custom' and CompanyId=@NEW_COMPANY_ID)where CompanyId=@NEW_COMPANY_ID and EngagementId is null
---------Auditors--------

DECLARE @auditors_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@auditors_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - Auditors Execution Entered', GETUTCDATE() , '2.15' , NULL , @IN_PROGRESS )
if not exists(select Id from Common.GenericTemplate where name='Auditors' and Code='Auditors' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Audit Cursor') and Name='Auditors'))      
BEGIN      
insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate)   
    
select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Auditors' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Audit Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, null, null, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Auditors' and 
TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Audit Cursor') and Name='Auditors')      
END

 Update Common.DetailLog set Status = @COMPLETED where Id = @auditors_Unique_Identifier
--------Directors Statement ---------------

DECLARE @directorsStatement_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@directorsStatement_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - Directors Statement Execution Entered', GETUTCDATE() , '2.16' , NULL , @IN_PROGRESS )
IF NOT EXISTS (select Id from Common.GenericTemplate where name='Directors Statement' and Code='Directors Statement' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Audit Cursor') and Name='Directors Statement'))      
BEGIN      
INSERT into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate)   
  
    
select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Directors Statement' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Audit Cursor')), Name, Code, TempletContent,IsSystem,
  
    
IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, null, null, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Directors Statement' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Audit Cursor') and Name='Directors Statement')      
END

 Update Common.DetailLog set Status = @COMPLETED where Id = @directorsStatement_Unique_Identifier

---------Directors Statement-,Auditors---------

DECLARE @directorsStatement_Auditors_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@directorsStatement_Auditors_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - Directors Statement, Auditors Execution Entered', GETUTCDATE() , '2.17' , NULL , @IN_PROGRESS )
	     
 IF @IS_ACCOUNTING_FIRM=1
 BEGIN 
	 Declare @Template_Cnt bigint;
	 Select @Template_Cnt=Count(*) from Audit.Template where CompanyId =@NEW_COMPANY_ID
	 If @Template_Cnt=0
	   Begin
			Insert Into Audit.Template (id,Name,Code,CompanyId,EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName,IsFinancialsTemplate,ReferenceId,FSTemplateId)
			Select  NEWID(),Name,Code,@NEW_COMPANY_ID,EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,GETUTCDATE(),null,null,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName,IsFinancialsTemplate,ReferenceId,(select Id from Audit.FSTemplates where AuditManual='Custom' and Year=YEAR(GETDATE()) and CompanyId=@NEW_COMPANY_ID) from Audit.Template where CompanyId=@UNIQUE_COMPANY_ID and remarks='Custom'
	   END

	    Update Common.DetailLog set Status = @COMPLETED where Id = @directorsStatement_Auditors_Unique_Identifier

	-------- Account Policy ------------

	DECLARE @accountPolicy_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@accountPolicy_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_AUDIT - Account Policy Cursor Execution Entered', GETUTCDATE() , '2.18' , NULL , @IN_PROGRESS )

	Declare @AccountPolicy_Cnt bigint;
	Select @AccountPolicy_Cnt=Count(*) from Audit.AccountPolicy where CompanyId =@NEW_COMPANY_ID
	 If @AccountPolicy_Cnt=0
		Begin 
			Declare @PolicyId uniqueidentifier;
			Declare @NewPolicyId uniqueidentifier;
			Declare @PolicyDetailId uniqueidentifier;

				DECLARE AccountpolicyCSR cursor for select id from Audit.AccountPolicy where CompanyId=0   and Remarks='Precursor'
				OPEN AccountpolicyCSR
				FETCH NEXT FROM   AccountpolicyCSR into @PolicyId
				WHILE (@@FETCH_STATUS=0)
				BEGIN
					set @NewPolicyId=NEWID();
					 Insert Into Audit.AccountPolicy (Id,CompanyId,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Section,PolicyNameId,IsRollForward,SectionName,EffectiveFrom,EffectiveTo,FSTemplateId)
					 Select @NewPolicyId,@NEW_COMPANY_ID,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,GETUTCDATE(),null,null,Version,Status,Section,@PolicyId,IsRollForward,SectionName,EffectiveFrom,EffectiveTo,(select Id from Audit.FSTemplates where AuditManual='Custom' and Year=YEAR(GETDATE()) and CompanyId=@NEW_COMPANY_ID)  from Audit.AccountPolicy where Id=@PolicyId
		    
						  DECLARE AccountpolicyDetailCSR cursor for select id from Audit.AccountPolicyDetail where MasterId=@PolicyId
						  OPEN AccountpolicyDetailCSR
						  FETCH NEXT FROM   AccountpolicyDetailCSR into @PolicydetailId
						  WHILE (@@FETCH_STATUS=0)
						  BEGIN
							  Insert Into Audit.AccountPolicyDetail (Id,MasterId,PolicyName,PolicyTemplate,IsChecked,IsSytem,RecOrder,Status,PolicyNameId)
							  select NEWID(),@NewPolicyId,PolicyName,PolicyTemplate,IsChecked,IsSytem,RecOrder,Status,@PolicyDetailId  from Audit.AccountPolicyDetail where id=@PolicyDetailId
						  FETCH NEXT FROM   AccountpolicyDetailCSR into @PolicydetailId
						  END
						  CLOSE AccountpolicyDetailCSR
						  DEALLOCATE AccountpolicyDetailCSR
				FETCH NEXT FROM   AccountpolicyCSR into @PolicyId
				END
				CLOSE AccountpolicyCSR
				DEALLOCATE AccountpolicyCSR
		END

		 Update Common.DetailLog set Status = @COMPLETED where Id = @accountPolicy_Unique_Identifier
		 --------------FsTemplatesId updated for all Templates in related tables
		 
	--Update audit.Template  set FSTemplateId =(select Id from Audit.FSTemplates where AuditManual='Custom' and Year=YEAR(GETDATE()) and CompanyId=@NEW_COMPANY_ID)  where CompanyId=@NEW_COMPANY_ID 

	--Update Audit.AccountPolicy  set FSTemplateId =(select Id from Audit.FSTemplates where AuditManual='Custom' and Year=YEAR(GETDATE()) and CompanyId=@NEW_COMPANY_ID)  where CompanyId=@NEW_COMPANY_ID 
	Update Audit.ReportingTemplates  set FSTemplateId =(select Id from Audit.FSTemplates where AuditManual='Custom' and Year=YEAR(GETDATE()) and CompanyId=@NEW_COMPANY_ID)  where PartnerCompanyId=@NEW_COMPANY_ID 
	Update common.moduledetail set Status=2 where companyid=@NEW_COMPANY_ID and groupname='Audit Cursor' and Heading='Reporting Templates'



 -- Isca Manual
 exec [dbo].[ISCA_SEEDDATA] @NEW_COMPANY_ID ,@UNIQUE_COMPANY_ID

 -- for Help Links

exec [dbo].[Audit_HelpLinks] @NEW_COMPANY_ID
 
 print 'ISCA'

END
--COMMIT TRANSACTION
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
END




GO
