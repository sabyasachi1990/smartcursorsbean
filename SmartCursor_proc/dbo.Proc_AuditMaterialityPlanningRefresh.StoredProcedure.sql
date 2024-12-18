USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AuditMaterialityPlanningRefresh]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Proc_AuditMaterialityPlanningRefresh](@companyId bigint,@engagementId uniqueidentifier)
As Begin

 BEGIN TRANSACTION
  BEGIN TRY

          DECLARE @PARTNER_COMPANYID BIGINT      
          Set @PARTNER_COMPANYID=(select AccountingFirmId from Common.Company where Id=@CompanyId)
	IF @PARTNER_COMPANYID IS NULL 
	BEGIN 
			SET @PARTNER_COMPANYID=@CompanyId
	END
	Declare @LeadsheetID uniqueidentifier;
	declare @firstId  uniqueidentifier;      
    declare @secondId  uniqueidentifier;      
    declare @thirdId uniqueidentifier;      
    declare @NewPlanningMaterialitySetupId uniqueidentifier;      
    declare @NewPlanningMaterialitySetupDetailId uniqueidentifier;      
   -- BEGIN TRANSACTION      
    -- BEGIN TRY       
      --outer cursor for loop users      
      DECLARE  SavePlanningMaterialitySetup CURSOR FOR  select Id from Audit.PlanningMaterialitySetup where Id not in (select ReferenceId from Audit.PlanningMaterialitySetup where EngagementId=@engagementId) and CompanyId=@PARTNER_COMPANYID and EngagementId is null  and Status=1
														and AuditmanualId = (select Id from audit.auditmanual where id in (select AuditManualId from audit.auditcompanyengagement where id=@engagementId))   
      OPEN SavePlanningMaterialitySetup      
      FETCH NEXT FROM SavePlanningMaterialitySetup INTO @firstId      
      WHILE @@FETCH_STATUS >= 0      
      BEGIN      
       select @NewPlanningMaterialitySetupId = newid();      
       Insert Into Audit.PlanningMaterialitySetup(Id,CompanyId,ShortCode,  [Decsription],Rationale,Recorder,Usercreated,createddate,status,referenceid,EngagementId,TemplateStatus)       
       select @NewPlanningMaterialitySetupId as Id,@companyId,PM.ShortCode,PM.Decsription,PM.Rationale,PM.Recorder,PM.Usercreated,GetDate   (),PM.status,@firstId,@engagementId,'New' from Audit.PlanningMaterialitySetup  as PM where id=@firstId                 
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
				   
				   print @LeadSheetId;
				   print @thirdId;
				                       
                    INSERT INTO AUDIT.[PlanningMaterialityLeadSheet] (Id,PlanningMaterialitySetupDetailId,LeadSheetId,Recorder)      
                    Select NewId(),@NewPlanningMaterialitySetupDetailId,      
                    (select Id from Audit.LeadSheet where CompanyId=@companyId and ReferenceId=@LeadSheetId and EngagementId=@engagementId),      
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

End


GO
