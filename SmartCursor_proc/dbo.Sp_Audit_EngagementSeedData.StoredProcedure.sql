USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Audit_EngagementSeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE Procedure [dbo].[Sp_Audit_EngagementSeedData](@companyId bigint,@engagemenId uniqueidentifier,@auditManualId uniqueidentifier)
As begin 

  BEGIN TRANSACTION
  BEGIN TRY
          DECLARE @AuditManual Nvarchar(100);
          DECLARE @EngagementType Nvarchar(100);
          DECLARE @PARTNER_COMPANYID BIGINT      
          Set @PARTNER_COMPANYID=(select AccountingFirmId from Common.Company where Id=@CompanyId)
	IF @PARTNER_COMPANYID IS NULL 
	BEGIN 
			SET @PARTNER_COMPANYID=@CompanyId
	END

	 Set @AuditManual=(select Name from Audit.AuditManual where Id=@auditManualId);
	 Set @EngagementType=(select EngagementType from Audit.Auditcompanyengagement where Id=@engagemenId);
    ---------- Suggestion SetUp--------------
    IF @PARTNER_COMPANYID IS NOT NULL      
    Begin       
       Insert into common.[Suggestion ] (id,CompanyId,ScreenName,Section,Title,Description,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,ReferenceId,
	      EngagementId)       
       select Newid(),@companyId,ScreenName,Section,Title,Description,Remarks,RecOrder,UserCreated,GetDate(),ModifiedBy,Null,Version,Status,Id,@engagemenId from       common.[Suggestion ] where CompanyId=@PARTNER_COMPANYID AND Status=1 AND EngagementId IS NULL   and AuditManualId=@auditManualId   
     End  
    
     Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@engagemenId,'SuggestionSetupInserted','Success',11) 
	 
	 
	 
	 
	  
   If @EngagementType ='Compilation'
   Begin
		   --------------Lead Sheet-------------------
	   IF @PARTNER_COMPANYID IS not NULL      
		   BEGIN       
		    Declare @LeadSheets1_Cnt bigint;      
			select @LeadSheets1_Cnt=Count(*)  from audit.leadsheet where CompanyId= @companyId and engagementid=@engagemenId and AuditManualId=@auditManualId      
			If @LeadSheets1_Cnt=0    
			Begin
			  Declare @LeadsheetMaterID uniqueidentifier
			  Declare Leadsheet_CSR Cursor for Select Id From Audit.leadsheet Where companyid=@PARTNER_COMPANYID AND EngagementId IS NULL  and  MasterId in (Select id From Audit.LeadSheetSetupMaster Where AuditManualId=@auditManualId)
			  Open Leadsheet_CSR      
			  Fetch next from Leadsheet_CSR into @LeadsheetMaterID
			  while @@FETCH_STATUS=0      
				  Begin      
					 Insert Into [Audit].[Leadsheet] (Id, CompanyId, WorkProgramId, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate,  Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version,Status ,IsPartner,ReferenceId,Disclosure,EngagementId,WorkProgramName,AuditManual,AuditManualId)      
					 select Newid() as leadsheetid, @companyId as newcompanyid,null, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName,FinancialStatementTemplate,Remarks,RecOrder,UserCreated, GETUTCDATE(),NULL AS ModifiedBy,NULL AS ModifiedDate,Version,Status,0,Id,Disclosure,@engagemenId,WorkProgramName,@AuditManual,@auditManualId from [Audit].[LeadSheet]        
							 where id=@LeadsheetMaterID AND Status=1       
			  Fetch next from Leadsheet_CSR into @LeadsheetMaterID 
			  End      
			  Close Leadsheet_CSR      
			  Deallocate Leadsheet_CSR    
			  end
             
		   End      

		   --------------Lead Sheet Categories ------------------------
			Declare @LeadSheetCategories_TCnt bigint;      
			select @LeadSheetCategories_TCnt=Count(*) from [Audit].[LeadSheetCategories] where
			 LeadsheetId in (select Id from audit.leadsheet where CompanyId= @companyId and engagementid=@engagemenId and AuditManualId=@auditManualId)      
			If @LeadSheetCategories_TCnt=0      
			  Begin      
				 IF @PARTNER_COMPANYID IS not NULL      
				 Begin       
				 Insert Into [Audit].[LeadSheetCategories]  ([Id],[LeadsheetID],[Name],[RecOrder],[Status],IsSystem)      
				 SELECT newid() as Id, 
				  (select ID FROM [Audit].[LeadSheet] where CompanyId = @companyId and engagementId=@engagemenId and LeadSheetName = (select LeadSheetName FROM [Audit].[LeadSheet] where Id =  cat. [LeadsheetID] and CompanyId = @PARTNER_COMPANYID AND ENGAGEMENTID IS NULL and AuditManualId=@auditManualId))   as [LeadsheetID] ,cat.[Name],cat.[RecOrder],cat.[Status] ,cat.IsSystem
				  FROM [Audit].[LeadSheetCategories] cat inner join [Audit].[LeadSheet] ld on ld.Id = cat.LeadsheetID  where ld.CompanyId = @PARTNER_COMPANYID AND   LD.Status=1 AND LD.EngagementId IS NULL and LD.AuditManualId=@auditManualId    
				 End 
			 END     
	
	Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@engagemenId,'WPLeadSheetsInserted','Success',12) 

   End
   Else
   Begin

   	   --------------Lead Sheet-------------------
	   IF @PARTNER_COMPANYID IS not NULL      
		   BEGIN    
		   Declare @LeadSheets_Cnt bigint;      
			select @LeadSheets_Cnt=Count(*)  from audit.leadsheet where CompanyId= @companyId and engagementid=@engagemenId and AuditManualId=@auditManualId      
			If @LeadSheets_Cnt=0    
			Begin
				  Declare @LeadsheetID uniqueidentifier,@WorkprogramId uniqueidentifier      
				  Declare Leadsheet_CSR Cursor for Select Id,WorkProgramId From Audit.leadsheet Where companyid=@PARTNER_COMPANYID AND EngagementId IS NULL  and  MasterId in (Select id From Audit.LeadSheetSetupMaster Where AuditManualId=@auditManualId)
				  Open Leadsheet_CSR      
				  Fetch next from Leadsheet_CSR into @LeadsheetID ,@WorkprogramId      
				  while @@FETCH_STATUS=0      
					  Begin      
						 Insert Into [Audit].[Leadsheet] (Id, CompanyId, WorkProgramId, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate,  Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version,Status ,IsPartner,ReferenceId,Disclosure,EngagementId,WorkProgramName,AuditManual,AuditManualId)      
						 select Newid() as leadsheetid, @companyId as newcompanyid,(Select id from audit.WPSetup where companyid=@companyId  and ReferenceId=@WorkprogramId and EngagementId=@engagemenId), [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName,FinancialStatementTemplate,Remarks,RecOrder,UserCreated, GETUTCDATE(),NULL AS ModifiedBy,NULL AS ModifiedDate,Version,Status,0,Id,Disclosure,@engagemenId,(Select code from audit.WPSetup where companyid=@companyId  and ReferenceId=@WorkprogramId and EngagementId=@engagemenId),@AuditManual,@auditManualId from [Audit].[LeadSheet]        
								 where id=@LeadsheetID AND Status=1       
				  Fetch next from Leadsheet_CSR into @LeadsheetID ,@WorkprogramId      
				  End      
				  Close Leadsheet_CSR      
				  Deallocate Leadsheet_CSR      
             end
		   End      

		   --------------Lead Sheet Categories ------------------------
			Declare @LeadSheetCategories_Cnt bigint;      
			select @LeadSheetCategories_Cnt=Count(*) from [Audit].[LeadSheetCategories] where
			 LeadsheetId in (select Id from audit.leadsheet where CompanyId= @companyId and engagementid=@engagemenId and AuditManualId=@auditManualId)      
			If @LeadSheetCategories_Cnt=0      
			  Begin      
				 IF @PARTNER_COMPANYID IS not NULL      
				 Begin       
				 Insert Into [Audit].[LeadSheetCategories]  ([Id],[LeadsheetID],[Name],[RecOrder],[Status],IsSystem)      
				 SELECT newid() as Id, 
				  (select ID FROM [Audit].[LeadSheet] where CompanyId = @companyId and engagementId=@engagemenId and LeadSheetName = (select LeadSheetName FROM [Audit].[LeadSheet] where Id =  cat. [LeadsheetID] and CompanyId = @PARTNER_COMPANYID AND ENGAGEMENTID IS NULL and AuditManualId=@auditManualId))   as [LeadsheetID] ,cat.[Name],cat.[RecOrder],cat.[Status] ,cat.IsSystem
				  FROM [Audit].[LeadSheetCategories] cat inner join [Audit].[LeadSheet] ld on ld.Id = cat.LeadsheetID  where ld.CompanyId = @PARTNER_COMPANYID AND   LD.Status=1 AND LD.EngagementId IS NULL and LD.AuditManualId=@auditManualId    
				 End 
			 END     
	
	Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@engagemenId,'LeadSheetsInserted','Success',12) 

	End







	-------------- Materiality Planning ------------------------	 
 
    declare @firstId  uniqueidentifier;      
    declare @secondId  uniqueidentifier;      
    declare @thirdId uniqueidentifier;      
    declare @NewPlanningMaterialitySetupId uniqueidentifier;      
    declare @NewPlanningMaterialitySetupDetailId uniqueidentifier;      
   -- BEGIN TRANSACTION      
    -- BEGIN TRY       
      --outer cursor for loop users      
      DECLARE  SavePlanningMaterialitySetup CURSOR FOR  select Id from Audit.PlanningMaterialitySetup where CompanyId=@PARTNER_COMPANYID and engagementid is null and Status=1 and AuditManual=@AuditManual
      OPEN SavePlanningMaterialitySetup      
      FETCH NEXT FROM SavePlanningMaterialitySetup INTO @firstId      
      WHILE @@FETCH_STATUS >= 0      
      BEGIN      
       select @NewPlanningMaterialitySetupId = newid();      
       Insert Into Audit.PlanningMaterialitySetup(Id,CompanyId,ShortCode,  [Decsription],Rationale,Recorder,Usercreated,createddate,status,referenceid,EngagementId)       
       select @NewPlanningMaterialitySetupId as Id,@companyId,PM.ShortCode,PM.Decsription,PM.Rationale,PM.Recorder,PM.Usercreated,GetDate   (),PM.status,@firstId,@engagemenId from Audit.PlanningMaterialitySetup  as PM where id=@firstId                 
             --inner cursor for one user               
                   
             DECLARE  SavePlanningMaterialitySetupDetail CURSOR FOR select Id from Audit.PlanningMaterialitySetupDetail where  PlanningMaterialitySetupId=@firstId        
             OPEN SavePlanningMaterialitySetupDetail      
             FETCH NEXT FROM SavePlanningMaterialitySetupDetail INTO @secondId      
             WHILE @@FETCH_STATUS = 0      
             BEGIN                                
                    Begin      
                   select @NewPlanningMaterialitySetupDetailId = newid();      
                   insert into  AUDIT.[PlanningMaterialitySetupDetail]    (Id,PlanningMaterialitySetupId,SystemType,IsNA,Type,Amount,LeadSheetShortCode,LeadSheeType,TypeName,Lowrange,HighRange,
				   IsIncrementedByApplicable,IncrementedBy,IsAllowExceed,RecOrder)    
     
                   Select @NewPlanningMaterialitySetupDetailId as    Id,@NewPlanningMaterialitySetupId,SystemType,IsNA,Type,Amount,LeadSheetShortCode,LeadSheeType,TypeName,Lowrange,HighRange,
				   IsIncrementedByApplicable,IncrementedBy,IsAllowExceed,RecOrder       
                   from Audit.[PlanningMaterialitySetupDetail] where Id=@secondId      
         
                   --newly added      
                   DECLARE  PlanningMaterialityLeadSheet CURSOR FOR select Id,LeadSheetId from Audit.PlanningMaterialityLeadSheet where    PlanningMaterialitySetupDetailId=@secondId      
                  OPEN PlanningMaterialityLeadSheet      
                  FETCH NEXT FROM PlanningMaterialityLeadSheet INTO @thirdId,@LeadSheetId      
                  WHILE @@FETCH_STATUS = 0      
                   BEGIN                              
                    INSERT INTO AUDIT.[PlanningMaterialityLeadSheet] (Id,PlanningMaterialitySetupDetailId,LeadSheetId,Recorder)      
                    Select NewId(),@NewPlanningMaterialitySetupDetailId,      
                    (select Id from Audit.LeadSheet where CompanyId=@companyId and ReferenceId=@LeadSheetId and EngagementId=@engagemenId),      
                    RecOrder from Audit.PlanningMaterialityLeadSheet where Id=@thirdId                  
                       
                  FETCH NEXT FROM PlanningMaterialityLeadSheet INTO @thirdId,@LeadSheetId       
                         END                    
                  CLOSE PlanningMaterialityLeadSheet      
                  DEALLOCATE PlanningMaterialityLeadSheet      
                  -------------------------      
                  End      
             FETCH NEXT FROM SavePlanningMaterialitySetupDetail INTO @secondId      
             END      
             CLOSE SavePlanningMaterialitySetupDetail      
             DEALLOCATE SavePlanningMaterialitySetupDetail      
         
       FETCH NEXT FROM SavePlanningMaterialitySetup INTO @firstId      
      END      
      CLOSE SavePlanningMaterialitySetup      
      DEALLOCATE SavePlanningMaterialitySetup      
      --COMMIT TRANSACTION    
	
Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@engagemenId,'PlanningMaterialityInserted','Success',12) 
    
  
   
          
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
			       Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@engagemenId,'SuggestionSetupInserted',@ErrorMessage,11) 

     ROLLBACK TRANSACTION
     END CATCH	   
End
GO
