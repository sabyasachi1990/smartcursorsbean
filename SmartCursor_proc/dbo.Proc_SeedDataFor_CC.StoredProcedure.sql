USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SeedDataFor_CC]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  CREATE PROCEDURE [dbo].[Proc_SeedDataFor_CC](@NEW_COMPANY_ID bigint,@UNIQUE_COMPANY_ID bigint,@isAudit bit)
 AS 
 begin
         DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT
	     DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT
	    DECLARE @ACCOUNTYPE_ID_ID_TYPE_ID BIGINT
	    DECLARE @ID_TYPE_ACCOUNTYPE_ID_ID BIGINT	
        DECLARE @CREATED_DATE DATETIME	
        SET @CREATED_DATE =GETUTCDATE()


------------------EMPLOYEE RANK------------------------------------------------------
--    Declare @EmployeeRank_Cnt bigint;
--    select 	@EmployeeRank_Cnt=Count (*)
--    from [ClientCursor].[EmployeeRank] where companyid=@NEW_COMPANY_ID	
--	IF @EmployeeRank_Cnt=0
--	Begin

--INSERT INTO [ClientCursor].[EmployeeRank](Id, Rank, Category, RatePerHour, Designation, DefaultCategory, CompanyId,
--UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Status)
--SELECT (NEWID()), Rank, Category, RatePerHour, Designation, DefaultCategory, @NEW_COMPANY_ID, UserCreated,
--@CREATED_DATE, null, null, status FROM [ClientCursor].[EmployeeRank]  WHERE COMPANYID=@UNIQUE_COMPANY_ID;
--end


------------------JOB TYPE-----------------------------------------------------------------------------------------

--    Declare @JobType_Cnt bigint;
--    select @JobType_Cnt = count(*) from [ClientCursor].[JobType] where companyid=@NEW_COMPANY_ID	
--	IF @JobType_Cnt=0
--	BEGIN

--INSERT INTO [ClientCursor].[JobType]  (Id, JobType, Description, CompanyId, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Status)
--SELECT (NEWID()), JobType, Description, @NEW_COMPANY_ID, UserCreated, GETUTCDate(), null, null, status FROM [ClientCursor].[JobType] 
--WHERE CompanyId=@UNIQUE_COMPANY_ID;	 
--End
 
------------------JOB HOURS LEVEL -------------------------------------------------------------------

--INSERT INTO [ClientCursor].[JobRisk]  (Id, JobTypeId, Risk, RiskPartner, RiskManager, RiskSenior, RiskSeniorAssociate, RiskJuniorAssociate, VolPartner, 
--VolManager, VolSenior, VolSeniorAssociate, VolJuniorAssociate, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Status)
--SELECT (NEWID()), JobTypeId, Risk, RiskPartner, RiskManager, RiskSenior, RiskSeniorAssociate, RiskJuniorAssociate, VolPartner, 
--VolManager, VolSenior, VolSeniorAssociate, VolJuniorAssociate, UserCreated, GETUTCDATE(), null, null,status FROM UAT_JobRisk_Temp; 
--TRUNCATE TABLE UAT_JobRisk_Temp


------------------JOB RISK -------------------------------------------------------------------


--INSERT INTO [ClientCursor].[JobHoursLevel] (Id, JobTypeId, Hours, Level, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Status)
--SELECT (NEWID()), JobTypeId, Hours, Level, UserCreated, GETUTCDATE(), null, null, status FROM UAT_JobHoursLevel__Temp ;
--TRUNCATE TABLE UAT_JobHoursLevel__Temp;


--FeeType


-- Declare @ControlCodeCategory_FeeType_Cnt bigint
-- select @ControlCodeCategory_FeeType_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Fee Type') 
         
-- IF @ControlCodeCategory_FeeType_Cnt=0
-- Begin

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Fee Type')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
 
-- End

----'CommunicationType'

-- Declare @ControlCodeCategory_CommunicationType_Cnt bigint
-- select @ControlCodeCategory_CommunicationType_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CommunicationType') 
         
-- IF @ControlCodeCategory_CommunicationType_Cnt=0
-- Begin

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CommunicationType')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End


----'Matters'
-- Declare @ControlCodeCategory_Matters_Cnt bigint
-- select @ControlCodeCategory_Matters_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Matters') 
         
-- IF @ControlCodeCategory_Matters_Cnt=0
-- Begin

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Matters')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT top 1  Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End


----'Source'
-- Declare @ControlCodeCategory_Source_Cnt bigint
-- select @ControlCodeCategory_Source_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Source') 
         
-- IF @ControlCodeCategory_Source_Cnt=0
-- Begin

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Source')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT top 1 Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End
		
----'Lead Status'
-- Declare @ControlCodeCategory_LeadStatus_Cnt bigint
-- select @ControlCodeCategory_LeadStatus_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Lead Status') 
         
-- IF @ControlCodeCategory_LeadStatus_Cnt=0
-- Begin


--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Lead Status')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT top 1 Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--End

----'Salutation'
-- Declare @ControlCodeCategory_Salutation_Cnt bigint
-- select @ControlCodeCategory_Salutation_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Salutation') 
         
-- IF @ControlCodeCategory_Salutation_Cnt=0
-- Begin

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Salutation')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT top 1 Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End

----'Campaign Type'
-- Declare @ControlCodeCategory_CampaignType_Cnt bigint
-- select @ControlCodeCategory_CampaignType_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Campaign Type') 
         
-- IF @ControlCodeCategory_CampaignType_Cnt=0
-- Begin


--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Campaign Type')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT top 1 Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End

----'Campaign Status'	
-- Declare @ControlCodeCategory_CampaignStatus_Cnt bigint
-- select @ControlCodeCategory_CampaignStatus_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Campaign Status') 
         
-- IF @ControlCodeCategory_CampaignStatus_Cnt=0
-- Begin
	
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Campaign Status')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT top 1 Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End

----'Opportunity Type'


-- Declare @ControlCodeCategory_OpportunityType_Cnt bigint
-- select @ControlCodeCategory_OpportunityType_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Opportunity Type') 
         
-- IF @ControlCodeCategory_OpportunityType_Cnt=0
-- Begin
		
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Opportunity Type')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End

----'Service Nature'
-- Declare @ControlCodeCategory_ServiceNature_Cnt bigint
-- select @ControlCodeCategory_ServiceNature_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Service Nature') 
         
-- IF @ControlCodeCategory_ServiceNature_Cnt=0
-- Begin


--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Service Nature')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End

---- Declare @ControlCodeCategory_ReasonForCancel_Cnt bigint
---- select @ControlCodeCategory_ReasonForCancel_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
----and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ReasonForCancel') 
         
---- IF @ControlCodeCategory_ReasonForCancel_Cnt=0
---- Begin
		
----		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ReasonForCancel')
----  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
----  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
----  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
----  End

----'Frequency'
-- Declare @ControlCodeCategory_Frequency_Cnt bigint
-- select @ControlCodeCategory_Frequency_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Frequency') 
         
-- IF @ControlCodeCategory_Frequency_Cnt=0
-- Begin


--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Frequency')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End
		
----'Designation'	
-- Declare @ControlCodeCategory_Designation_Cnt bigint
-- select @ControlCodeCategory_Designation_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation') 
         
-- IF @ControlCodeCategory_Designation_Cnt=0
-- Begin
	
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Designation')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End

----'Relationship'


--Declare @ControlCodeCategory_Relationship_Cnt bigint
-- select @ControlCodeCategory_Relationship_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Relationship') 
         
-- IF @ControlCodeCategory_Relationship_Cnt=0
-- Begin

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Relationship')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End

----'LeadCategory'

-- Declare @ControlCodeCategory_LeadCategory_Cnt bigint
-- select @ControlCodeCategory_LeadCategory_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='LeadCategory') 

--IF @ControlCodeCategory_LeadCategory_Cnt=0
-- Begin

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='LeadCategory')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End

----'ActivitySubject'
-- Declare @ControlCodeCategory_ActivitySubject_Cnt bigint
-- select @ControlCodeCategory_ActivitySubject_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ActivitySubject') 

--IF @ControlCodeCategory_ActivitySubject_Cnt=0
-- Begin


--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ActivitySubject')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End

----'Task Subject'
-- Declare @ControlCodeCategory_TaskSubject_Cnt bigint
-- select @ControlCodeCategory_TaskSubject_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Task Subject') 

--IF @ControlCodeCategory_TaskSubject_Cnt=0
-- Begin

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Task Subject')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End
----'Event Subject'
-- Declare @ControlCodeCategory_EventSubject_Cnt bigint
-- select @ControlCodeCategory_EventSubject_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Event Subject') 

--IF @ControlCodeCategory_EventSubject_Cnt=0
-- Begin

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Event Subject')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End

----'Note Subject'
-- Declare @ControlCodeCategory_NoteSubject_Cnt bigint
-- select @ControlCodeCategory_NoteSubject_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Note Subject') 

--IF @ControlCodeCategory_NoteSubject_Cnt=0
-- Begin

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Note Subject')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	

--End

----'EntityAddress'

--Declare @ControlCodeCategory_EntityAddress_Cnt bigint
-- select @ControlCodeCategory_EntityAddress_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EntityAddress') 

--IF @ControlCodeCategory_EntityAddress_Cnt=0
-- Begin

--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='EntityAddress')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Client Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);

--End
End

Exec [dbo].[ControlCodeCategoryModule_SP_New] @NEW_COMPANY_ID,1



--- Templates

Declare @GenericTemplate_Cnt int
select 	@GenericTemplate_Cnt=Count(*) from Common.GenericTemplate where companyid=@NEW_COMPANY_ID and CursorName='Client Cursor'	
If @GenericTemplate_Cnt =0
Begin
	--------------------------------Generic Template--------------------------------------

--	INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status])
--       SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1
--FROM Common.GenericTemplate WHERE CompanyId=@UNIQUE_COMPANY_ID
	
	declare @AuditFirmId bigint= (select AccountingFirmId from Common.Company where Id=@NEW_COMPANY_ID);
 if @AuditFirmId is null
  BEGIN
 INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsPartnerTemplate],[CursorName],[TemplateType])
       SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1,[IsPartnerTemplate],[CursorName],[TemplateType]
  FROM Common.GenericTemplate WHERE CompanyId=@UNIQUE_COMPANY_ID and CursorName='Client Cursor'
  END
else
  BEGIN
       INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsPartnerTemplate],[CursorName],[TemplateType])
            SELECT  NEWID(),@NEW_COMPANY_ID,[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],GETUTCDATE(),null,null,[Version],1,[IsPartnerTemplate],[CursorName],[TemplateType]
       FROM Common.GenericTemplate WHERE CompanyId=@AuditFirmId and CursorName='Client Cursor'
 END
 End


 --Notification seed data

Begin
	If Not Exists (Select Id From Notification.NotificationSettings WHere CompanyId=@NEW_COMPANY_ID And CursorName= 'Client Cursor')
	Begin
		Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,
														Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
														NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

		Select NEWID(),@NEW_COMPANY_ID,Null as CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,
				IsOn,CreatedDate,null,null,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate 
		From Notification.NotificationSettings Where CompanyId=@UNIQUE_COMPANY_ID And CursorName= 'Client Cursor'
	End
	End
GO
