USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SeedDataFor_Audit]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE  PROCEDURE [dbo].[Proc_SeedDataFor_Audit](@NEW_COMPANY_ID bigint,@UNIQUE_COMPANY_ID bigint,@isAudit bit)      
 AS       
 BEGIN      
  DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT      
 DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT      
 DECLARE @STATUS   INT      
 DECLARE @CREATED_DATE DATETIME       
 SET @STATUS = 1          
 SET @CREATED_DATE =GETUTCDATE()         
 DECLARE @IS_ACCOUNTING_FIRM bit      
 SET @IS_ACCOUNTING_FIRM = (select IsAccountingFirm  from Common.Company where Id=@NEW_COMPANY_ID)      
 DECLARE @PARTNER_COMPANYID BIGINT      
 SET @PARTNER_COMPANYID = (select AccountingFirmId  from Common.Company where Id=@NEW_COMPANY_ID)      
  BEGIN TRANSACTION      
   BEGIN TRY       
      
       
------------------------------------------------Suggestion Set up-----------------      
      
 IF @IS_ACCOUNTING_FIRM=1  
 Begin       
       
    -------EngagementType-----

  declare @EngagementType_Cnt bigint;
  select  @EngagementType_Cnt=Count(*) from  [Audit].EngagementType where companyid=@NEW_COMPANY_ID 
  IF @EngagementType_Cnt=0
  Begin
		 Insert into Audit.EngagementType(Id,CompanyId,Name,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Issystem) 
			  Select NewId(),@NEW_COMPANY_ID,[Name],'System',GETDATE(),NULL,NULL,1,1 from Audit.EngagementType where CompanyId=@UNIQUE_COMPANY_ID
  END

 -------------Suggestion Set Up------------------
Declare @SuggestionSetUp_Cnt bigint;
select @SuggestionSetUp_Cnt=Count(*) from common.[Suggestion ] where CompanyId=@NEW_COMPANY_ID
IF @SuggestionSetUp_Cnt=0
	BEGIN       
		Insert into common.[Suggestion ] (id,CompanyId,ScreenName,Section,Title,Description,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,ReferenceId)      
		select Newid(),@NEW_COMPANY_ID,ScreenName,Section,Title,Description,Remarks,RecOrder,UserCreated,GetDate(), null, Null, Version, Status, ReferenceId from common.[Suggestion ] where CompanyId=@UNIQUE_COMPANY_ID      
	END    
      
      
	                  ------TickMarksetup--------      
      
 Declare @TickMarkSetup_Cnt bigint;      
 select  @TickMarkSetup_Cnt=Count(*) from  [Audit].[TickMarkSetup] where companyid=@NEW_COMPANY_ID       
   IF @TickMarkSetup_Cnt=0      
   Begin      
      --IF @IS_ACCOUNTING_FIRM=1      
      --  Begin      
           INSERT INTO [Audit].[TickMarkSetup] (Id,CompanyId,Code,[Description],IsSystem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,    [Version],   [Status],IsPlanning,IsCompletion,IsPartner,ReferenceId)      
           select NewId(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[IsSystem],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL AS        [ModifiedBy],NULL AS [ModifiedDate],[Version],[Status],[IsPlanning],[IsCompletion],1,[ReferenceId]    
           From [Audit].[TickMarkSetup] Where CompanyId = @UNIQUE_COMPANY_ID;      
        --End      
      --Else      
       --IF @PARTNER_COMPANYID IS NOT NULL      
       --   Begin       
       --      INSERT INTO [Audit].[TickMarkSetup] (Id,CompanyId,Code,[Description],IsSystem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,[Version],[Status],IsPlanning,IsCompletion,IsPartner,ReferenceId)      
       --      select NEWID(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[IsSystem],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL AS [ModifiedBy],NULL AS [ModifiedDate],[Version],[Status],[IsPlanning],[IsCompletion],0,Id      
       --   From [Audit].[TickMarkSetup] Where CompanyId = @PARTNER_COMPANYID AND Status=1;      
       --   End      
       --Else
	   --IF @PARTNER_COMPANYID IS  NULL       
    --    Begin      
    --       INSERT INTO [Audit].[TickMarkSetup] (Id,CompanyId,Code,[Description],IsSystem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate, [Version],[Status],IsPlanning,IsCompletion,IsPartner)      
    --       select NEWID(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[IsSystem],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL AS   [ModifiedBy],NULL AS [ModifiedDate],[Version],[Status],[IsPlanning],[IsCompletion],0      
    --       From [Audit].[TickMarkSetup] Where CompanyId = @UNIQUE_COMPANY_ID;      
    --    End      
         
 End      
      
       
                  --------WorkProgram setup-----------      
      
  Declare @WPSetup_Cnt int;      
  select @WPSetup_Cnt=Count(*) from [Audit].[WPSetup] where companyid=@NEW_COMPANY_ID       
  IF @WPSetup_Cnt=0      
    Begin      
       --IF @IS_ACCOUNTING_FIRM=1      
       --  Begin      
            INSERT INTO [Audit].[WPSetup] (Id,CompanyId,Code,[Description],Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,[Version],      [Status],ShortCode,IsPartner,ReferenceId)      
            select NewID(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL as       [ModifiedBy],NULL as [ModifiedDate],[Version],[Status],[ShortCode],1,[Id]      
            From [Audit].[WPSetup] Where CompanyId = @UNIQUE_COMPANY_ID;      
         --End       
       --Else      
       --  Begin       
       --     IF @PARTNER_COMPANYID IS not NULL      
       --       Begin       
       --          INSERT INTO [Audit].[WPSetup] (Id,CompanyId,Code,[Description],Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,[Version],[Status],ShortCode,IsPartner,ReferenceId)      
       --           select NewID(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL as [ModifiedBy],NULL as [ModifiedDate],[Version],[Status],[ShortCode],0,Id      
       --           From [Audit].[WPSetup] Where CompanyId = @PARTNER_COMPANYID AND Status=1;      
          
       --               declare @ID uniqueidentifier,@WPSetupId uniqueidentifier,@TickMark_Id uniqueidentifier;      
       --               DECLARE WPSETUPCSR CURSOR FOR SELECT ID,WPSetupId,TickMarkId FROM AUDIT.WPSETUPTICKMARK WHERE WPSetupId in(select Id from Audit.WPSetup    where  CompanyId=@PARTNER_COMPANYID )      
       --               OPEN WPSETUPCSR;      
       --               FETCH NEXT FROM WPSETUPCSR INTO @ID,@WPSetupId,@TickMark_Id      
       --               WHILE (@@FETCH_STATUS=0)      
       --               BEGIN      
       --                  INSERT INTO AUDIT.WPSETUPTICKMARK (ID,WPSETUPID,TICKMARKID,STATUS)      
       --                  SELECT NEWID(),(select id from Audit.WPSetup where ReferenceId=@WPSetupId and CompanyId=@NEW_COMPANY_ID),(select Id from    audit.TickMarkSetup where companyid=@NEW_COMPANY_ID and referenceid=@TickMark_Id),STATUS FROM  AUDIT.WPSETUPTICKMARK WHERE Id=@ID 
     				     
       --                  FETCH NEXT FROM WPSETUPCSR INTO @ID,@WPSetupId,@TickMark_Id      
       --               END      
       --               CLOSE WPSETUPCSR      
       --               DEALLOCATE WPSETUPCSR      
      
       --       End      
            --Else  
			--IF @PARTNER_COMPANYID IS  NULL    
   --           Begin       
   --              INSERT INTO [Audit].[WPSetup] (Id,CompanyId,Code,[Description],Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,[Version],       [Status],ShortCode,IsPartner,[ReferenceId])      
   --              select NewId(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL as        [ModifiedBy],NULL as [ModifiedDate],[Version],[Status],[ShortCode],0,Id   
   --              From [Audit].[WPSetup] Where CompanyId = @UNIQUE_COMPANY_ID;      
   --           End      
         --End       
    END      
      
--       -----------------------Leadsheet Setup------------------      
   Declare @Leadsheet_Cnt bigint; 
   Declare @LeadsheetID uniqueidentifier,@WorkprogramId uniqueidentifier     
   select @Leadsheet_Cnt=Count(*) from [Audit].[Leadsheet] where companyid=@NEW_COMPANY_ID       
    If @Leadsheet_Cnt=0      
    Begin      
      --IF @IS_ACCOUNTING_FIRM=1      
      --      Begin      
                Insert Into [Audit].[Leadsheet] (Id, CompanyId, WorkProgramId, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,IsPartner,ReferenceId,Disclosure )      
                select Newid() as leadsheetid, @NEW_COMPANY_ID as newcompanyid,pp.Newcompanyid, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, GETUTCDATE(),NULL AS ModifiedBy,NULL AS ModifiedDate, Version, Status ,1,   
                  [ReferenceId],Disclosure from  [Audit].[LeadSheet]  as L      
                  INNER JOIN      
                  (      
                  select P.Id as 'Newcompanyid',w.Id as 'Oldcompanyid' from audit.WPSetup as w      
                  INNER JOIN       
                  (      
                        
                  select id,code,Description from audit.WPSetup where companyid =@NEW_COMPANY_ID      
                        
                  ) as p ON P.Code=w.Code and P.Description=w.Description      
                        
                  where companyid in (@UNIQUE_COMPANY_ID)      
                  ) as PP On PP.Oldcompanyid=WorkProgramId      
                        
                  where CompanyId=@UNIQUE_COMPANY_ID      
            --End      
      
     --Else      
        --Begin       
           --IF @PARTNER_COMPANYID IS not NULL      
           --     BEGIN       
           --         Declare @LeadsheetID uniqueidentifier,@WorkprogramId uniqueidentifier      
           --         Declare Leadsheet_CSR Cursor for Select Id,WorkProgramId From Audit.leadsheet Where companyid=@PARTNER_COMPANYID      
           --         Open Leadsheet_CSR      
           --         Fetch next from Leadsheet_CSR into @LeadsheetID ,@WorkprogramId      
           --         while @@FETCH_STATUS=0      
           --               Begin      
           --                    Insert Into [Audit].[Leadsheet] (Id, CompanyId, WorkProgramId, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status ,IsPartner,ReferenceId,Disclosure )      
           --                     select Newid() as leadsheetid, @NEW_COMPANY_ID as newcompanyid,(Select id from audit.WPSetup where companyid=@NEW_COMPANY_ID  and         ReferenceId=@WorkprogramId), [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName,   FinancialStatementTemplate,    Remarks,     RecOrder, UserCreated, GETUTCDATE(),NULL AS ModifiedBy,NULL AS ModifiedDate,   Version, Status,0,Id,Disclosure from  [Audit].   [LeadSheet]  where id=@LeadsheetID AND Status=1       
           --         Fetch next from Leadsheet_CSR into @LeadsheetID ,@WorkprogramId      
           --         End      
           --         Close Leadsheet_CSR      
           --         Deallocate Leadsheet_CSR      
      
           --    End   
		  --IF @PARTNER_COMPANYID IS  NULL 	      
    --      --ELSE      
    --           BEGIN      
    --              Insert Into [Audit].[Leadsheet] (Id, CompanyId, WorkProgramId, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,Disclosure )      
    --             select Newid() as leadsheetid, @NEW_COMPANY_ID as newcompanyid,pp.Newcompanyid, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName,  FinancialStatementTemplate, Remarks, RecOrder, UserCreated, GETUTCDATE(),NULL AS ModifiedBy,NULL AS ModifiedDate, Version, Status,Disclosure from  [Audit].[LeadSheet]  as L      
    --               INNER JOIN      
    --               (      
    --               select P.Id as 'Newcompanyid',w.Id as 'Oldcompanyid' from audit.WPSetup as w      
    --               INNER JOIN       
    --               (      
                         
    --               select id,code,Description from audit.WPSetup where companyid =@NEW_COMPANY_ID      
                         
    --               ) as p ON P.Code=w.Code and P.Description=w.Description      
                         
    --               where companyid in (@UNIQUE_COMPANY_ID)      
    --               ) as PP On PP.Oldcompanyid=WorkProgramId      
                         
    --               where CompanyId=@UNIQUE_COMPANY_ID      
    --               --end       
    --          END      
     END      
  ------------------------------LeadSheetCategories---------------------------------      
    Declare @LeadSheetCategories_Cnt bigint;      
    select @LeadSheetCategories_Cnt=Count(*) from [Audit].[LeadSheetCategories] where LeadsheetId in (select Id from audit.leadsheet where CompanyId= @NEW_COMPANY_ID)      
    If @LeadSheetCategories_Cnt=0      
    --Begin      
       --IF @PARTNER_COMPANYID IS not NULL      
       --  begin       
       --    Insert Into [Audit].[LeadSheetCategories] ([Id],[LeadsheetID],[Name],[RecOrder],[Status])  SELECT newid() as Id ,(select ID FROM [Audit].[LeadSheet] where CompanyId = @NEW_COMPANY_ID and LeadSheetName = (select LeadSheetName FROM [Audit].[LeadSheet] where Id = cat.[LeadsheetID] and CompanyId = @PARTNER_COMPANYID))   as [LeadsheetID]  ,cat.[Name]  ,cat.[RecOrder] ,cat.[Status]   FROM [Audit].[LeadSheetCategories] cat inner join [Audit].[LeadSheet] ld  on ld.Id = cat.LeadsheetID  where ld.CompanyId = @PARTNER_COMPANYID AND LD.Status=1      
       --  end       
       --ELSE 
	   --IF (@PARTNER_COMPANYID IS  NULL) or (@IS_ACCOUNTING_FIRM=1)    
    --     BEGIN      
          
          Insert Into [Audit].[LeadSheetCategories] ([Id],[LeadsheetID],[Name],[RecOrder],[Status])   SELECT newid() as Id ,(select ID FROM [Audit].[LeadSheet] where CompanyId = @NEW_COMPANY_ID and LeadSheetName = (select LeadSheetName FROM [Audit].[LeadSheet] where Id = cat.[LeadsheetID] and CompanyId = @UNIQUE_COMPANY_ID))   as [LeadsheetID]  ,cat.[Name] ,cat.[RecOrder]  ,cat.[Status]  FROM [Audit].[LeadSheetCategories] cat inner join [Audit].[LeadSheet] ld  on ld.Id = cat.LeadsheetID  where ld.CompanyId = @UNIQUE_COMPANY_ID      
        -- End      
      
    
    End     

      -----------------------------------------Reporting Templates Only of it is Partner Company then create under new Company---------

Declare @ReportingTemplates_Cnt bigint;
Select @ReportingTemplates_Cnt=COUNT(*) from Audit.ReportingTemplates where PartnerCompanyId=@NEW_COMPANY_ID
IF @ReportingTemplates_Cnt=0
Begin
 declare @companyCreationdate datetime2(7)=(select CreatedDate  from Common.Company where id=@NEW_COMPANY_ID);
 IF @PARTNER_COMPANYID IS NOT NULL
 Begin 
 Insert into Audit.ReportingTemplates (Id,PartnerCompanyId,EngagementId,TemplateName,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,EffectiveFrom,EffectiveTo,DisclosureId)
 Select Newid(),@NEW_COMPANY_ID,EngagementId,TemplateName,'Sysytem',GetDate(),null,Null,Status,@companyCreationdate,EffectiveTo,DisclosureId from Audit.ReportingTemplates where PartnerCompanyId=@PARTNER_COMPANYID and EngagementId Is Null
 end 
 ELSE 
  Begin 
  Insert into Audit.ReportingTemplates (Id,PartnerCompanyId,EngagementId,TemplateName,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,EffectiveFrom)
 Select Newid(),@NEW_COMPANY_ID,EngagementId,TemplateName,'Sysytem',GetDate(),null,Null,Status,@companyCreationdate from Audit.ReportingTemplates where PartnerCompanyId=@UNIQUE_COMPANY_ID and EngagementId Is Null
 
 end 
      
END     
      
      
      
      
----------------------------------------------------------------------------------------------------     
--for new AU user role      
      
--role--      
      
IF NOT EXISTS (SELECT * FROM [Auth].[Role] where Name='AU User' and [ModuleMasterId]=(select Id from Common.ModuleMaster where CompanyId=0 and Heading='Audit Cursor') and CompanyId=@NEW_COMPANY_ID)       
   BEGIN      
       INSERT [Auth].[Role] ([Id], [CompanyId], [Name], [Remarks], [ModuleMasterId], [Status], [ModifiedBy], [ModifiedDate], [UserCreated], [CreatedDate],[IsSystem],[BackgroundColor],[CursorIcon],[IsPartner])      
       VALUES (newid(),@NEW_COMPANY_ID, N'AU User', NULL,(select Id from Common.ModuleMaster where CompanyId=0 and Heading='Audit Cursor'), 1, NULL, NULL, NULL, GETdate(),1,N'#67acda',N'role-auuser',0)      
   END      
      
--role permission--      
      
IF NOT EXISTS (SELECT * FROM Auth.RolePermission where RoleId=(select Id from Auth.Role where CompanyId=@NEW_COMPANY_ID and Name='AU User'))       
   BEGIN      
   Insert into Auth.RolePermission (ID, RoleID, ModuleDetailPermissionID)      
   Select NEWID(), R.ID as RoleID,  MDP.ID ModulePermissionDetailID      
   From Auth.Role R Inner Join Common.ModuleMaster MM on MM.ID = R.ModuleMasterId       
   Inner Join Common.ModuleDetail MD on MD.ModuleMasterId = MM.ID Inner Join AUTH.ModuleDetailPermission MDP on MDP.ModuleDetailId = MD.ID      
   Where R.Name = 'AU User' And R.CompanyId=@NEW_COMPANY_ID and MD.IsPartner=0 and MD.GroupName in ('Client','Summary') and  MD.ModuleMasterId=(select Id from Common.ModuleMaster where Name='Audit Cursor' and CompanyId=0) and MDP.PermissionName='View'   
   
   END      
      
      
  
      
      
 -----------------------------PlannigAndCompletionSetUp-----------------------      
  Declare @PartnerCompany_Cnt int;      
  select @PartnerCompany_Cnt=COUNT(*)  from [Common].[Company] where id=@NEW_COMPANY_ID and ParentId is null and IsAccountingFirm=1      
  IF @PartnerCompany_Cnt!=0      
  BEGIN      
 Declare @PandCSetup_Cnt int;      
 select @PandCSetup_Cnt=Count(*) from [Audit].[PlanningAndCompletionSetUp] where companyid=@NEW_COMPANY_ID       
 IF @PandCSetup_Cnt=0      
 Begin      
--1 Audit.PlanningAndCompletionSetUp      
 DECLARE @PAC_UNQC TABLE(ID UNIQUEIDENTIFIER,COMPANYID BIGINT,CODE NVARCHAR(MAX))      
 DECLARE @PAC_ID_FOR_UNQC UNIQUEIDENTIFIER      
 DECLARE @PAC_UNQCID BIGINT      
 DECLARE @PAC_MCODE NVARCHAR(MAX)      
 DECLARE @PAC_NEWID UNIQUEIDENTIFIER      
      
 INSERT INTO @PAC_UNQC       
 SELECT ID,COMPANYID,MenuCode FROM Audit.PlanningAndCompletionSetUp WHERE COMPANYID=@UNIQUE_COMPANY_ID       
      
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
  INSERT INTO Audit.PlanningAndCompletionSetUp(Id,CompanyId,AuditCompanyId,EngagementId,ModuleDetailId,Type,MenuCode,MenuName,Description,FormType,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder,EngagementType,Conclusion,IsMigrated
  
    
,ConclusionLable,TypeId)      
  SELECT @PAC_NEWID,@NEW_COMPANY_ID,AuditCompanyId,EngagementId,ModuleDetailId,Type,MenuCode,MenuName,Description,FormType,Remarks,UserCreated,GETDATE(),NULL,NULL,Status,Recorder,EngagementType,Conclusion,IsMigrated,ConclusionLable ,Id     
  FROM Audit.PlanningAndCompletionSetUp WHERE ID=@PAC_ID_FOR_UNQC --AND COMPANYID=@PAC_UNQCID AND MenuCode=@PAC_MCODE      
      
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
   SELECT @SEC_NEWID,@PAC_NEWID,Heading,DESCRIPTION,CommentLable,CommentDescription,Remarks,UserCreated,GETDATE(),NULL,NULL,Status,Recorder      
   FROM Audit.PAndCSections WHERE ID=@SEC_ID --AND PlanningAndCompletionSetUpId=@SEC_PAC_ID AND Heading=@SECTION AND DESCRIPTION=@DESCRIPTION      
      
         
   INSERT INTO Audit.PAndCSectionQuestions (Id,PAndCSectionId,Question,QuestionOptions,Answer,IsComment,Comment,IsAttachement,AttachmentsCount,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder,AttachmentName,PreviousQuestionId)      
   SELECT NEWID(),@SEC_NEWID,Question,QuestionOptions,Answer,IsComment,Comment,IsAttachement,AttachmentsCount,Remarks,UserCreated,GETDATE(),NULL,NULL,Status,Recorder,AttachmentName,PreviousQuestionId      
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
   SELECT @SEC_NEWID1,@PAC_NEWID,AuditCompanyContactId,EngagementId,UserCreated,GETDATE(),NULL,NULL,Status,Recorder,[Description],Conclusion      
   FROM Audit.DirectorRemuneration WHERE ID=@SEC_ID1 --AND PlanningAndCompletionSetUpId=@SEC_PAC_ID AND Heading=@SECTION AND DESCRIPTION=@DESCRIPTION      
   INSERT INTO Audit.DirectorRemunerationDetails (Id,DirectorRemunerationId,Heading,HeadingRecorder,LineItemName,LineItemAmount,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,Recorder)      
   SELECT NEWID(),@SEC_NEWID1,Heading,HeadingRecorder,LineItemName,LineItemAmount,UserCreated,GETDATE(),NULL,NULL,Status,Recorder      
   FROM Audit.DirectorRemunerationDetails WHERE DirectorRemunerationId=@SEC_ID1      
      
   FETCH NEXT FROM SECTION1 INTO @SEC_ID1,@SEC_PAC_ID1      
     END      
  CLOSE SECTION1      
  DEALLOCATE SECTION1      
      
  FETCH NEXT FROM PAC INTO @PAC_ID_FOR_UNQC,@PAC_UNQCID,@PAC_MCODE       
   END      
 CLOSE PAC      
 DEALLOCATE PAC      
 end      
 END      
       
      
      
      
        ---------- Assets -------------      
      
--Declare @ControlCodeCategoryModuleAssets_Cnt bigint      
-- select @ControlCodeCategoryModuleAssets_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Assets')       
               
-- IF @ControlCodeCategoryModuleAssets_Cnt=0      
-- Begin      
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Assets')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end          
           ----------- Liabilities -----------------      
--Declare @ControlCodeCategoryModuleLiabilities_Cnt bigint      
-- select @ControlCodeCategoryModuleLiabilities_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Liabilities')       
               
-- IF @ControlCodeCategoryModuleLiabilities_Cnt=0      
-- Begin      
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Liabilities')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--         ------------- Income -----------      
--Declare @ControlCodeCategoryModuleIncome_Cnt bigint      
-- select @ControlCodeCategoryModuleIncome_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Income')       
               
-- IF @ControlCodeCategoryModuleIncome_Cnt=0      
-- Begin      
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Income')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--        ---------------- Expenses -------------      
--Declare @ControlCodeCategoryModuleExpenses_Cnt bigint      
-- select @ControlCodeCategoryModuleExpenses_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Expenses')       
               
-- IF @ControlCodeCategoryModuleExpenses_Cnt=0      
-- Begin      
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Expenses')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--        --------------- Equity -------------      
--Declare @ControlCodeCategoryModuleEquity_Cnt bigint      
-- select @ControlCodeCategoryModuleEquity_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Equity')       
               
-- IF @ControlCodeCategoryModuleEquity_Cnt=0      
-- Begin      
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Equity')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
          --------EngagementType      
--Declare @ControlCodeCategoryModuleEngagementType_Cnt bigint      
-- select @ControlCodeCategoryModuleEngagementType_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EngagementType')       
               
-- IF @ControlCodeCategoryModuleEngagementType_Cnt=0      
-- Begin      
--     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EngagementType')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--           --------EngagementReview      
--Declare @ControlCodeCategoryModuleEngagementReview_Cnt bigint      
-- select @ControlCodeCategoryModuleEngagementReview_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EngagementReview')       
               
-- IF @ControlCodeCategoryModuleEngagementReview_Cnt=0      
-- Begin      
--    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EngagementReview')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--           --------TrialBalance Columns      
--Declare @ControlCodeCategoryModuleTrialBalancColumns_Cnt bigint      
-- select @ControlCodeCategoryModuleTrialBalancColumns_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TrialBalance Columns')       
               
-- IF @ControlCodeCategoryModuleTrialBalancColumns_Cnt=0      
-- Begin      
--    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TrialBalance Columns')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--            ------------EntityAddress      
--Declare @ControlCodeCategoryModuleEntityAddress_Cnt bigint      
-- select @ControlCodeCategoryModuleEntityAddress_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EntityAddress')       
               
-- IF @ControlCodeCategoryModuleEntityAddress_Cnt=0      
-- Begin      
--    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EntityAddress')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--           --------IndividualAddress       
--Declare @ControlCodeCategoryModuleIndividualAddress_Cnt bigint      
-- select @ControlCodeCategoryModuleIndividualAddress_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IndividualAddress')       
               
-- IF @ControlCodeCategoryModuleIndividualAddress_Cnt=0      
-- Begin                  
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IndividualAddress')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--            --------Address Type      
--Declare @ControlCodeCategoryModuleAddressType_Cnt bigint      
-- select @ControlCodeCategoryModuleAddressType_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Address Type')       
               
-- IF @ControlCodeCategoryModuleAddressType_Cnt=0      
-- Begin      
--      SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Address Type')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--            ----------Additionallevels      
--Declare @ControlCodeCategoryModuleAdditionallevels_Cnt bigint      
-- select @ControlCodeCategoryModuleAdditionallevels_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Additionallevels')       
               
-- IF @ControlCodeCategoryModuleAdditionallevels_Cnt=0      
-- Begin      
--      SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Additionallevels')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--           ------------AuditPrimaryRole      
--Declare @ControlCodeCategoryModuleAuditPrimaryRole_Cnt bigint      
-- select @ControlCodeCategoryModuleAuditPrimaryRole_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AuditPrimaryRole')       
               
-- IF @ControlCodeCategoryModuleAuditPrimaryRole_Cnt=0      
-- Begin      
--      SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AuditPrimaryRole')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--           ----------Leadsheet Type      
--Declare @ControlCodeCategoryModuleLeadsheetType_Cnt bigint      
-- select @ControlCodeCategoryModuleLeadsheetType_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Leadsheet Type')       
               
-- IF @ControlCodeCategoryModuleLeadsheetType_Cnt=0      
-- Begin      
--      SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Leadsheet Type')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--             ------------Account Class      
--Declare @ControlCodeCategoryModuleAccountClass_Cnt bigint      
-- select @ControlCodeCategoryModuleAccountClass_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Account Class')       
               
-- IF @ControlCodeCategoryModuleAccountClass_Cnt=0      
-- Begin      
--     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Account Class')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--         ------------GeneralLedgerColumns      
--Declare @ControlCodeCategoryModuleGeneralLedgerColumns_Cnt bigint      
-- select @ControlCodeCategoryModuleGeneralLedgerColumns_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='GeneralLedgerColumns')       
               
-- IF @ControlCodeCategoryModuleGeneralLedgerColumns_Cnt=0      
-- Begin      
--       SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='GeneralLedgerColumns')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--          ------------FEPrimaryParticulars      
--Declare @ControlCodeCategoryModuleFEPrimaryParticulars_Cnt bigint      
-- select @ControlCodeCategoryModuleFEPrimaryParticulars_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='FEPrimaryParticulars')       
               
-- IF @ControlCodeCategoryModuleFEPrimaryParticulars_Cnt=0      
-- Begin      
--       SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='FEPrimaryParticulars')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--           --------FESecondParticulars      
--Declare @ControlCodeCategoryModuleFESecondParticulars_Cnt bigint      
-- select @ControlCodeCategoryModuleFESecondParticulars_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='FESecondParticulars')       
               
-- IF @ControlCodeCategoryModuleFESecondParticulars_Cnt=0      
-- Begin      
--     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='FESecondParticulars')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--         ------------MPNameSuggestion      
--Declare @ControlCodeCategoryModuleMPNameSuggestion_Cnt bigint      
-- select @ControlCodeCategoryModuleMPNameSuggestion_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MPNameSuggestion')       
               
-- IF @ControlCodeCategoryModuleMPNameSuggestion_Cnt=0      
-- Begin      
--       SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MPNameSuggestion')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--         --------MPSuggestion      
--Declare @ControlCodeCategoryModuleMPSuggestion_Cnt bigint      
--select @ControlCodeCategoryModuleMPSuggestion_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MPSuggestion')       
               
-- IF @ControlCodeCategoryModuleMPSuggestion_Cnt=0      
-- Begin      
--         SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MPSuggestion')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--         --------TErrorSuggestion      
--Declare @ControlCodeCategoryModuleTErrorSuggestion_Cnt bigint      
-- select @ControlCodeCategoryModuleTErrorSuggestion_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TErrorSuggestion')       
               
-- IF @ControlCodeCategoryModuleTErrorSuggestion_Cnt=0      
-- Begin      
--         SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='TErrorSuggestion')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--         ----------FEConSuggestionend      
      
--Declare @ControlCodeCategoryModuleFEConSuggestion_Cnt bigint      
-- select @ControlCodeCategoryModuleFEConSuggestion_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='FEConSuggestion')       
               
-- IF @ControlCodeCategoryModuleFEConSuggestion_Cnt=0      
-- Begin      
--           SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='FEConSuggestion')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--         --------------Assets      
--Declare @ControlCodeCategoryModuleAssets_Cnt bigint      
-- select @ControlCodeCategoryModuleAssets_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Assets')       
               
-- IF @ControlCodeCategoryModuleAssets_Cnt=0      
-- Begin      
--             SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Assets')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--         ------------Liabilities      
--Declare @ControlCodeCategoryModuleLiabilities_Cnt bigint      
-- select @ControlCodeCategoryModuleLiabilities_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Liabilities')       
               
-- IF @ControlCodeCategoryModuleLiabilities_Cnt=0      
-- Begin      
      
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Liabilities')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--         ----------Income      
      
--Declare @ControlCodeCategoryModuleIncome_Cnt bigint      
-- select @ControlCodeCategoryModuleIncome_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Income')       
               
-- IF @ControlCodeCategoryModuleIncome_Cnt=0      
-- Begin      
--     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Income')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--         ------------Expenses      
--Declare @ControlCodeCategoryModuleExpenses_Cnt bigint      
-- select @ControlCodeCategoryModuleExpenses_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Expenses')       
               
-- IF @ControlCodeCategoryModuleExpenses_Cnt=0      
-- Begin      
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Expenses')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--         ----------Equity      
--Declare @ControlCodeCategoryModuleEquity_Cnt bigint      
-- select @ControlCodeCategoryModuleEquity_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Equity')       
               
-- IF @ControlCodeCategoryModuleEquity_Cnt=0      
-- Begin      
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Equity')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--       ----Materiality Type      
--Declare @ControlCodeCategoryModuleMaterialityType_Cnt bigint      
-- select @ControlCodeCategoryModuleMaterialityType_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Materiality Type')       
               
-- IF @ControlCodeCategoryModuleMaterialityType_Cnt=0      
-- Begin      
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Materiality Type')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--        ------Predefined Type      
--Declare @ControlCodeCategoryModulePredefinedType_Cnt bigint      
-- select @ControlCodeCategoryModulePredefinedType_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Predefined Type')       
               
-- IF @ControlCodeCategoryModulePredefinedType_Cnt=0      
-- Begin      
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Predefined Type')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--    ----------------Suggestion Screenname--------      
--Declare @ControlCodeCategoryModuleSuggestionScreenname_Cnt bigint      
-- select @ControlCodeCategoryModuleSuggestionScreenname_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Suggestion Screenname')       
               
-- IF @ControlCodeCategoryModuleSuggestionScreenname_Cnt=0      
-- Begin      
--        SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Suggestion Screenname')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--     -------------------Foreign Exchange Analysis--------------      
--Declare @ControlCodeCategoryModuleForeignExchangeAnalysis_Cnt bigint      
-- select @ControlCodeCategoryModuleForeignExchangeAnalysis_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Foreign Exchange Analysis')       
               
-- IF @ControlCodeCategoryModuleForeignExchangeAnalysis_Cnt=0      
-- Begin      
--        SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Foreign Exchange Analysis')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--    -------------------'Functional Currency Analysis--------------      
--Declare @ControlCodeCategoryModuleFunctionalCurrencyAnalysis_Cnt bigint      
-- select @ControlCodeCategoryModuleFunctionalCurrencyAnalysis_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Functional Currency Analysis')       
               
-- IF @ControlCodeCategoryModuleFunctionalCurrencyAnalysis_Cnt=0      
-- Begin      
--        SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Functional Currency Analysis')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
----     ----------------Salutation--------------------      
--Declare @ControlCodeCategoryModuleSalutation_Cnt bigint      
-- select @ControlCodeCategoryModuleSalutation_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Salutation')       
               
-- IF @ControlCodeCategoryModuleSalutation_Cnt=0      
-- Begin      
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Salutation')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end      
--      --------Designation      
--Declare @ControlCodeCategoryModuleDesignation_Cnt bigint      
-- select @ControlCodeCategoryModuleDesignation_Cnt=Count(*) from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID       
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation')       
               
-- IF @ControlCodeCategoryModuleDesignation_Cnt=0      
-- Begin      
--     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Audit Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  end   


   
     ------------TERMS OF PAYMENT  --------------------      
Declare @TermsOfPayment_Cnt int;      
 select @TermsOfPayment_Cnt=Count(*) from [Common].[TermsOfPayment] where companyid=@NEW_COMPANY_ID       
 IF @TermsOfPayment_Cnt=0      
 Begin      
  INSERT INTO [Common].[TermsOfPayment] (Id, Name, CompanyId, TermsType, TOPValue, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy,       
   ModifiedDate, Version, Status, IsVendor, IsCustomer)      
   SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Common].[TermsOfPayment] ), Name, @NEW_COMPANY_ID, TermsType, TOPValue,       
   RecOrder, Remarks, UserCreated, @CREATED_DATE, null, null, Version, status, IsVendor, IsCustomer FROM [Common].[TermsOfPayment]       
   WHERE COMPANYID=@UNIQUE_COMPANY_ID;      
   end     
   
     	-----------------------------------------ID TYPE------------------------------------
	DECLARE @IDTYPE_CNT INT;
	SELECT @IDTYPE_CNT=COUNT(*) FROM [COMMON].[IDTYPE] WHERE COMPANYID=@NEW_COMPANY_ID 
	IF @IDTYPE_CNT=0
	BEGIN
	
		UPDATE [Common].[IdType] SET[TempIdTypeId] = NULL;
		--ALTER TABLE [Common].[IdType] ADD [TempIdTypeId] BIGINT NULL;
		INSERT INTO [Common].[IdType] (Id, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,TempIdTypeId) 
		SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + 1 FROM [Common].[IdType]), Name, @NEW_COMPANY_ID, RecOrder, Remarks,
		UserCreated, @CREATED_DATE, null, null, Version, status, Id FROM [Common].[IdType] WHERE COMPANYID=@UNIQUE_COMPANY_ID	
	END
   
   
   
   
   
       ---------------ACCOUNT TYPE ----------------------      
Declare @AccountType_Cnt int;      
 select @AccountType_Cnt=Count(*) from [Common].[AccountType] where companyid=@NEW_COMPANY_ID       
 IF @AccountType_Cnt=0      
 Begin      
  UPDATE [Common].[AccountType] SET [TempAccountTypeId] = NULL;      
  INSERT INTO [Common].[AccountType] (Id, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,TempAccountTypeId)      
   SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) + @STATUS FROM [Common].[AccountType]), Name, @NEW_COMPANY_ID, RecOrder, Remarks, UserCreated,      
   @CREATED_DATE, null, null, Version, status,Id FROM [Common].[AccountType]  WHERE COMPANYID=@UNIQUE_COMPANY_ID;     
        
   --Added by Nagendra      
   INSERT INTO  [Common].[AccountTypeIdType] (Id, AccountTypeId, IdTypeId, RecOrder)        
   SELECT ROW_NUMBER() OVER(ORDER BY A.ID) + (SELECT MAX(ID) + 1 FROM [Common].[AccountTypeIdType]) ,B.Id AS ACCOUNTTYPEID,C.Id AS IDTYPEID,      
   A.RecOrder FROM [Common].[AccountTypeIdType] A JOIN [Common].[AccountType] B ON A.AccountTypeId = B.TempAccountTypeId JOIN [Common].[IdType] C       
   ON C.TempIdTypeId = A.IdTypeId WHERE B.CompanyId=@NEW_COMPANY_ID AND C.CompanyId=@NEW_COMPANY_ID;      
  End   
    -----------CURRENCY --------------------      
Declare @Currency_Cnt int;      
 select @Currency_Cnt=Count(*) from [Bean].[Currency] where companyid=@NEW_COMPANY_ID       
 IF @Currency_Cnt=0      
 Begin      
        INSERT INTO  [Bean].[Currency] (Id, Code, CompanyId, Name, RecOrder, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, DefaultValue)      
   SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Bean].[Currency]), Code, @NEW_COMPANY_ID, Name, RecOrder, STATUS,      
   UserCreated, @CREATED_DATE, null, null, DefaultValue FROM [Bean].[Currency] WHERE COMPANYID=@UNIQUE_COMPANY_ID;      
   end      
--   ------------------ID TYPE------------------------      
--Declare @IdType_Cnt int;      
-- select @IdType_Cnt=Count(*) from [Common].[IdType] where companyid=@NEW_COMPANY_ID       
-- IF @IdType_Cnt=0      
-- Begin      
--  UPDATE [Common].[IdType] SET[TempIdTypeId] = NULL;      
--        INSERT INTO [Common].[IdType] (Id, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,TempIdTypeId)       
--   SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Common].[IdType]), Name, @NEW_COMPANY_ID, RecOrder, Remarks,      
--   UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, Version, status, Id FROM [Common].[IdType] WHERE COMPANYID=@UNIQUE_COMPANY_ID;      
--   end      
      -------------------Assets--------------------      
      
         
--  Declare @ControlCodeCategoryModule_Assets_Cnt bigint      
--   Select @ControlCodeCategoryModule_Assets_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID      
--   AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Assets')      
--   If @ControlCodeCategoryModule_Assets_Cnt =0      
--    Begin      
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Assets')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  End      
      
         
--    --Liabilities      
--  Declare @ControlCodeCategoryModule_Liabilities_Cnt bigint      
--   Select @ControlCodeCategoryModule_Liabilities_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID      
--   AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Liabilities')      
--   If @ControlCodeCategoryModule_Liabilities_Cnt =0      
--    Begin      
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Liabilities')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  End      
      
--   --Income      
--  Declare @ControlCodeCategoryModule_Income_Cnt bigint      
--   Select @ControlCodeCategoryModule_Income_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID      
--   AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Income')      
--   If @ControlCodeCategoryModule_Income_Cnt =0      
--    Begin      
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Income')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  End      
      
         
--   --Expenses      
--   Declare @ControlCodeCategoryModule_Expenses_Cnt bigint      
--   Select @ControlCodeCategoryModule_Expenses_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID      
--   AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Expenses')      
--   If @ControlCodeCategoryModule_Expenses_Cnt =0      
--    Begin      
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Expenses')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  End      
      
      
        
---------------------------- Equity ---------------------------------------------      
----Equity      
--            Declare @ControlCodeCategoryModule_Equity_Cnt bigint      
--   Select @ControlCodeCategoryModule_Equity_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID      
--   AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Equity')      
--   If @ControlCodeCategoryModule_Equity_Cnt =0      
--    Begin      
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Equity')      
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')      
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),      
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);      
--  End      
      

	  Exec [dbo].[ControlCodeCategoryModule_SP_New] @NEW_COMPANY_ID,3

      
        
--------------------------------------Materiality Planning Control-----------------------------      
      
      
      
 --   declare @firstId  uniqueidentifier;      
 --declare @secondId  uniqueidentifier;      
 --declare @thirdId uniqueidentifier;      
 --declare @NewPlanningMaterialitySetupId uniqueidentifier;      
 --declare @NewPlanningMaterialitySetupDetailId uniqueidentifier;      
 --BEGIN TRANSACTION      
 ---- BEGIN TRY       
 --  --outer cursor for loop users      
 --  DECLARE  SavePlanningMaterialitySetup CURSOR FOR  select Id from Audit.PlanningMaterialitySetup where CompanyId=@PARTNER_COMPANYID      
 --  OPEN SavePlanningMaterialitySetup      
 --  FETCH NEXT FROM SavePlanningMaterialitySetup INTO @firstId      
 --  WHILE @@FETCH_STATUS >= 0      
 --  BEGIN      
 --   select @NewPlanningMaterialitySetupId = newid();      
 --   Insert Into Audit.PlanningMaterialitySetup(Id,CompanyId,ShortCode,[Decsription],Rationale,Recorder,Usercreated,createddate,status,referenceid)      
 --   select @NewPlanningMaterialitySetupId as Id,@NEW_COMPANY_ID,PM.ShortCode,PM.Decsription,PM.Rationale,PM.Recorder,PM.Usercreated,GetDate(),PM.status,@firstId  from Audit.PlanningMaterialitySetup  as PM where id=@firstId                 
 --         --inner cursor for one user               
                
 --         DECLARE  SavePlanningMaterialitySetupDetail CURSOR FOR select Id from Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId=@firstId      
 --         OPEN SavePlanningMaterialitySetupDetail      
 --         FETCH NEXT FROM SavePlanningMaterialitySetupDetail INTO @secondId      
 --         WHILE @@FETCH_STATUS = 0      
 --         BEGIN                                
 --                Begin      
 --               select @NewPlanningMaterialitySetupDetailId = newid();      
 --               insert into  AUDIT.[PlanningMaterialitySetupDetail] (Id,PlanningMaterialitySetupId,SystemType,IsNA,Type,Amount,LeadSheetShortCode,LeadSheeType,TypeName,Lowrange,HighRange,IsIncrementedByApplicable,IncrementedBy,IsAllowExceed,RecOrder)    
  
 --               Select @NewPlanningMaterialitySetupDetailId as Id,@NewPlanningMaterialitySetupId,SystemType,IsNA,Type,Amount,LeadSheetShortCode,LeadSheeType,TypeName,Lowrange,HighRange,IsIncrementedByApplicable,IncrementedBy,IsAllowExceed,RecOrder       
 --               from Audit.[PlanningMaterialitySetupDetail] where Id=@secondId      
      
 --               --INSERT INTO AUDIT.[PlanningMaterialityLeadSheet] (Id,PlanningMaterialitySetupDetailId,LeadSheetId,Recorder)      
 --               --Select NewId(),@NewPlanningMaterialitySetupDetailId,(select Id from Audit.LeadSheet where CompanyId=@NEW_COMPANY_ID and ReferenceId=@LeadSheetId),RecOrder from Audit.PlanningMaterialityLeadSheet      
 --               --where PlanningMaterialitySetupDetailId=@secondId      
      
 --               --newly added      
 --               DECLARE  PlanningMaterialityLeadSheet CURSOR FOR select Id,LeadSheetId from Audit.PlanningMaterialityLeadSheet where PlanningMaterialitySetupDetailId=@secondId      
 --              OPEN PlanningMaterialityLeadSheet      
 --              FETCH NEXT FROM PlanningMaterialityLeadSheet INTO @thirdId,@LeadSheetId      
 --              WHILE @@FETCH_STATUS = 0      
 --               BEGIN                              
 --                INSERT INTO AUDIT.[PlanningMaterialityLeadSheet] (Id,PlanningMaterialitySetupDetailId,LeadSheetId,Recorder)      
 --                Select NewId(),@NewPlanningMaterialitySetupDetailId,      
 --                (select Id from Audit.LeadSheet where CompanyId=@NEW_COMPANY_ID and ReferenceId=@LeadSheetId),      
 --                RecOrder from Audit.PlanningMaterialityLeadSheet where Id=@thirdId                  
                    
 --              FETCH NEXT FROM PlanningMaterialityLeadSheet INTO @thirdId,@LeadSheetId       
 --                     END                    
 --              CLOSE PlanningMaterialityLeadSheet      
 --              DEALLOCATE PlanningMaterialityLeadSheet      
 --              -------------------------      
 --              End      
 --     FETCH NEXT FROM SavePlanningMaterialitySetupDetail INTO @secondId      
 --         END      
 --         CLOSE SavePlanningMaterialitySetupDetail      
 --         DEALLOCATE SavePlanningMaterialitySetupDetail      
      
 --   FETCH NEXT FROM SavePlanningMaterialitySetup INTO @firstId      
 --  END      
 --  CLOSE SavePlanningMaterialitySetup      
 --  DEALLOCATE SavePlanningMaterialitySetup      
 --  COMMIT TRANSACTION      
      
---------------------------CompanyModule -- for Initial Setup      
BEGIN       
 IF EXISTS (select * from  [Common].[CompanyModule]   WHERE [ModuleId] = (select Id from common.modulemaster where Name='Audit Cursor') AND [CompanyId] = @NEW_COMPANY_ID and SetUpDone=0)      
 BEGIN      
 UPDATE [Common].[CompanyModule] SET [SetupDone]= 1 WHERE [ModuleId] = (select Id from common.modulemaster where Name='Audit Cursor') AND [CompanyId] =@NEW_COMPANY_ID      
 END      
END      
---------------

update audit.PlanningAndCompletionSetUp set EngagementTypeId=(select id from Audit.EngagementType where CompanyId=@NEW_COMPANY_ID and Name='Statutory Audit') where CompanyId=@NEW_COMPANY_ID and EngagementId is null and EngagementType='Statutory Audit'

update audit.PlanningAndCompletionSetUp set EngagementTypeId=(select id from Audit.EngagementType where CompanyId=@NEW_COMPANY_ID and Name='Compilation') where CompanyId=@NEW_COMPANY_ID and EngagementId is null and EngagementType='Compilation'

      
      
----------------------------------------------------Auditors--------------------------      
if not exists(select Id from Common.GenericTemplate where name='Auditors' and Code='Auditors' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Audit Cursor') and Name='Auditors'))      
begin      
insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate)   
  
    
select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Auditors' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Audit Cursor')), Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, null, null, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Auditors' and TemplateTypeId=(select id from
  
    
 Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Audit Cursor') and Name='Auditors')      
end      
      
--------------------------------------------------Directors Statement      
      
if not exists(select Id from Common.GenericTemplate where name='Directors Statement' and Code='Directors Statement' and CompanyId=@NEW_COMPANY_ID and TemplateTypeId=(select id from Common.TemplateType where CompanyId=0 and ModuleMasterId=(select Id from Common.ModuleMaster where name='Audit Cursor') and Name='Directors Statement'))      
begin      
insert into Common.GenericTemplate (Id, CompanyId, TemplateTypeId, Name, Code, TempletContent,IsSystem,IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, TemplateType, IsPartnerTemplate)   
  
    
select NEWID(), @NEW_COMPANY_ID, (select Id from Common.TemplateType where Name='Directors Statement' and CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Audit Cursor')), Name, Code, TempletContent,IsSystem,
  
    
IsFooterExist,IsHeaderExist, RecOrder, Remarks, UserCreated, CreatedDate, null, null, Version, Status, TemplateType, IsPartnerTemplate from Common.GenericTemplate where CompanyId=@UNIQUE_COMPANY_ID and Code='Directors Statement' and TemplateTypeId=(select id from Common.TemplateType where CompanyId=@UNIQUE_COMPANY_ID and ModuleMasterId=(select Id from Common.ModuleMaster where name='Audit Cursor') and Name='Directors Statement')      
end      
     
-----------------------------------   Directors Statement-,Auditors------------
	     
 IF @IS_ACCOUNTING_FIRM=1
   begin 
 Declare @Template_Cnt bigint;
 Select @Template_Cnt=Count(*) from Audit.Template where CompanyId =@NEW_COMPANY_ID
 If @Template_Cnt=0
  Begin
Insert Into Audit.Template (id,Name,Code,CompanyId,EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName)
Select  NEWID(),Name,Code,@NEW_COMPANY_ID,EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,GETDATE(),null,null,RecOrder,Version,Status,SectionName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName from Audit.Template where CompanyId=@UNIQUE_COMPANY_ID
 END
----------------------------------------------- Account Policy ----------------------------------
Declare @AccountPolicy_Cnt bigint;
	Select @AccountPolicy_Cnt=Count(*) from Audit.AccountPolicy where CompanyId =@NEW_COMPANY_ID
	 If @AccountPolicy_Cnt=0
		Begin
    Declare @PolicyId uniqueidentifier;
    Declare @NewPolicyId uniqueidentifier;
    Declare @PolicyDetailId uniqueidentifier;




    DECLARE AccountpolicyCSR cursor for select id from Audit.AccountPolicy where CompanyId=0
    OPEN AccountpolicyCSR
    FETCH NEXT FROM   AccountpolicyCSR into @PolicyId
    WHILE (@@FETCH_STATUS=0)
    BEGIN
	    set @NewPolicyId=NEWID();
		 Insert Into Audit.AccountPolicy (Id,CompanyId,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Section,PolicyNameId,IsRollForward,SectionName,EffectiveFrom,EffectiveTo)
		 Select @NewPolicyId,@NEW_COMPANY_ID,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,GETDATE(),null,null,Version,Status,Section,@PolicyId,IsRollForward,SectionName,EffectiveFrom,EffectiveTo  from Audit.AccountPolicy where Id=@PolicyId
		    
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

End



      COMMIT TRANSACTION      
          
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
  ROLLBACK TRANSACTION      
 END CATCH      
 END
GO
