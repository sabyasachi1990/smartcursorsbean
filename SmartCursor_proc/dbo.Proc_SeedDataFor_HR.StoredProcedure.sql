USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SeedDataFor_HR]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_SeedDataFor_HR](@UNIQUE_COMPANY_ID BIGINT,@NEW_COMPANY_ID BIGINT)
AS
BEGIN         
	DECLARE @STATUS   INT
	DECLARE @CREATED_DATE DATETIME	
	DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT
	DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT
	DECLARE @ACCOUNTYPE_ID_ID_TYPE_ID BIGINT
	DECLARE @ID_TYPE_ACCOUNTYPE_ID_ID BIGINT	
	SET @STATUS = 1    
	SET @CREATED_DATE = GETUTCDATE()   	
	BEGIN TRANSACTION
	BEGIN TRY
	 

		--Hr control codes
		-----------------------------------//Relation//----------------------------------
--Declare @ControlCodeCategory_Relation_Cnt bigint
--select @ControlCodeCategory_Relation_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Relation') 
-- IF @ControlCodeCategory_Relation_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Relation')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--   end
--   ---------------------------------------//Nationality//--------------------------------

--     Declare @ControlCodeCategory_Nationality_Cnt bigint
--select @ControlCodeCategory_Nationality_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Nationality') 
-- IF @ControlCodeCategory_Nationality_Cnt=0
--    Begin    
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Nationality')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID = @UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--end
---------------------------------//Country of origin//-------------------------------------
-- Declare @ControlCodeCategory_CountryOfOrigin_Cnt bigint
--select @ControlCodeCategory_CountryOfOrigin_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CountryOfOrigin') 
-- IF @ControlCodeCategory_CountryOfOrigin_Cnt=0
--    Begin   
--	    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CountryOfOrigin')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
----------------------------------- // marital status//-------------------------------------
-- Declare @ControlCodeCategory_MaritalStatus_Cnt bigint
--select @ControlCodeCategory_MaritalStatus_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MaritalStatus') 
-- IF @ControlCodeCategory_MaritalStatus_Cnt=0
--    Begin  
--	    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MaritalStatus')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
-------------------------------------// Race//----------------------------------------------
--Declare @ControlCodeCategory_Race_Cnt bigint
--select @ControlCodeCategory_Race_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Race') 
-- IF @ControlCodeCategory_Race_Cnt=0
--    Begin  
--	    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Race')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--end
------------------------------------- // Religion//----------------------------------------
--Declare @ControlCodeCategory_Religion_Cnt bigint
--select @ControlCodeCategory_Religion_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Religion') 
-- IF @ControlCodeCategory_Religion_Cnt=0
--    Begin 
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Religion')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);		
--end
-------------------------------------- // membership//------------------------------------------
--Declare @ControlCodeCategory_MemberShip_Cnt bigint
--select @ControlCodeCategory_MemberShip_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MemberShip') 
-- IF @ControlCodeCategory_MemberShip_Cnt=0
--    Begin 
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='MemberShip')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
--end
---------------------------------------// IdType//----------------------------------------------
--Declare @ControlCodeCategory_IdType_Cnt bigint
--select @ControlCodeCategory_IdType_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IdType') 
-- IF @ControlCodeCategory_IdType_Cnt=0
--    Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='IdType')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
------------------------------- //Level//------------------------------------------------
--Declare @ControlCodeCategory_Level_Cnt bigint
--select @ControlCodeCategory_Level_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Level') 
-- IF @ControlCodeCategory_Level_Cnt=0
--    Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Level')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--end
--------------------------------- //Gender//------------------------------------------------
--		Declare @ControlCodeCategory_Gender_Cnt bigint
--select @ControlCodeCategory_Gender_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Gender') 
-- IF @ControlCodeCategory_Gender_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Gender')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--end
---------------------------------// Hire Reason//--------------------------------------------
--Declare @ControlCodeCategory_HireReason_Cnt bigint
--select @ControlCodeCategory_HireReason_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='HireReason') 
-- IF @ControlCodeCategory_HireReason_Cnt=0
--    Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='HireReason')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--end
----------------------------------// LeaveType//--------------------------------------------
--Declare @ControlCodeCategory_LeaveType_Cnt bigint
--select @ControlCodeCategory_LeaveType_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='LeaveType') 
-- IF @ControlCodeCategory_LeaveType_Cnt=0
--    Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='LeaveType')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--end
----------------------------------- // LeaveStatus//---------------------------------------
--Declare @ControlCodeCategory_LeaveStatus_Cnt bigint
--select @ControlCodeCategory_LeaveStatus_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='LeaveStatus') 
-- IF @ControlCodeCategory_LeaveStatus_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='LeaveStatus')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
------------------------------------- // bankNames//------------------------------------------
--Declare @ControlCodeCategory_BankNames_Cnt bigint
--select @ControlCodeCategory_BankNames_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='BankNames') 
-- IF @ControlCodeCategory_BankNames_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='BankNames')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--end
--------------------------------------- // workProfile//----------------------------------------------
--Declare @ControlCodeCategory_WorkProfile_Cnt bigint
--select @ControlCodeCategory_WorkProfile_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkProfile') 
-- IF @ControlCodeCategory_WorkProfile_Cnt=0
--    Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkProfile')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--end
------------------------------------------- // Period//-------------------------------------------------
--Declare @ControlCodeCategory_Period_Cnt bigint
--select @ControlCodeCategory_Period_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Period') 
-- IF @ControlCodeCategory_Period_Cnt=0
--    Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Period')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--end
------------------------------------------ // Rsason for leaving//----------------------------------------
--Declare @ControlCodeCategory_ReasonForLeaving_Cnt bigint
--select @ControlCodeCategory_ReasonForLeaving_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Reason For Leaving') 
-- IF @ControlCodeCategory_ReasonForLeaving_Cnt=0
--    Begin
--		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Reason For Leaving')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
--end
----------------------------------------------- // application status//--------------------------------------
--Declare @ControlCodeCategory_ApplicationStatus_Cnt bigint
--select @ControlCodeCategory_ApplicationStatus_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ApplicationStatus') 
-- IF @ControlCodeCategory_ApplicationStatus_Cnt=0
--    Begin
--		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ApplicationStatus')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
--end
------------------------------------------------- // source//--------------------------------------------------
--Declare @ControlCodeCategory_Source_Cnt bigint
--select @ControlCodeCategory_Source_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Source' and ModuleNamesUsing like '%HR Cursor%') 
-- IF @ControlCodeCategory_Source_Cnt=0
--    Begin
--		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Source' and ModuleNamesUsing like '%HR Cursor%')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor' )
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
--end
--------------------------------------------------- // job posting status//----------------------------------
--Declare @ControlCodeCategory_JobPostingStatus_Cnt bigint
--select @ControlCodeCategory_JobPostingStatus_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='JobPostingStatus') 
-- IF @ControlCodeCategory_JobPostingStatus_Cnt=0
--    Begin
--		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='JobPostingStatus')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
--end
------------------------------------------------- // calender detup types//-----------------------------------
--Declare @ControlCodeCategory_CalenderSetUpTypes_Cnt bigint
--select @ControlCodeCategory_CalenderSetUpTypes_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CalendarSetUpTypes') 
-- IF @ControlCodeCategory_CalenderSetUpTypes_Cnt=0
--    Begin
--		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='CalendarSetUpTypes')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
--end
------------------------------------------------ //leave accural//--------------------------------------------
--Declare @ControlCodeCategory_LeaveAccural_Cnt bigint
--select @ControlCodeCategory_LeaveAccural_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='LeaveAccural') 
-- IF @ControlCodeCategory_LeaveAccural_Cnt=0
--    Begin
--		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='LeaveAccural')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
--end
------------------------------------------------- //reset leave balance//--------------------------------------
--Declare @ControlCodeCategory_ResetLeaveBalance_Cnt bigint
--select @ControlCodeCategory_ResetLeaveBalance_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ResetLeaveBalance') 
-- IF @ControlCodeCategory_LeaveAccural_Cnt=0
--    Begin
--		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ResetLeaveBalance')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
--end
------------------------------------------------------// attendance type//---------------------------------------
--Declare @ControlCodeCategory_AttendenceType_Cnt bigint
--select @ControlCodeCategory_AttendenceType_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AttendanceType') 
-- IF @ControlCodeCategory_AttendenceType_Cnt=0
--    Begin
--		   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='AttendanceType')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--end
---------------------------------------------------------- // working type//----------------------------------------
--Declare @ControlCodeCategory_WorkingType_Cnt bigint
--select @ControlCodeCategory_WorkingType_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkingType') 
-- IF @ControlCodeCategory_WorkingType_Cnt=0
--    Begin
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkingType')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
----------------------------------------------------// working hours//-----------------------------------------------
--Declare @ControlCodeCategory_WorkingHours_Cnt bigint
--select @ControlCodeCategory_WorkingHours_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkingHours') 
-- IF @ControlCodeCategory_WorkingHours_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkingHours')
-- SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--end
----------------------------------------// contributionfor//--------------------------------------------
--Declare @ControlCodeCategory_ContributionFor_Cnt bigint
--select @ControlCodeCategory_ContributionFor_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ContributionFor') 
-- IF @ControlCodeCategory_ContributionFor_Cnt=0
--    Begin
--       SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='ContributionFor')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
----------------------------------------// pay method//-----------------------------------------------------
--Declare @ControlCodeCategory_PayMethod_Cnt bigint
--select @ControlCodeCategory_PayMethod_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='PayMethod') 
-- IF @ControlCodeCategory_PayMethod_Cnt=0
--    Begin
--       SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='PayMethod')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
----------------------------------------// paycomponenttype//------------------------------------------------
--Declare @ControlCodeCategory_PayComponentType_Cnt bigint
--select @ControlCodeCategory_PayComponentType_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='PayComponentType') 
-- IF @ControlCodeCategory_PayComponentType_Cnt=0
--    Begin
--       SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='PayComponentType')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
--------------------------------------------- // tax clarification//-----------------------------------------
--Declare @ControlCodeCategory_TaxClassification_Cnt bigint
--select @ControlCodeCategory_TaxClassification_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Tax Classification') 
-- IF @ControlCodeCategory_TaxClassification_Cnt=0
--    Begin
--       SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Tax Classification')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
---------------------------------------------- //PayrollStatus//-----------------------------------------------
--Declare @ControlCodeCategory_PayrollStatus_Cnt bigint
--select @ControlCodeCategory_PayrollStatus_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='PayrollStatus') 
-- IF @ControlCodeCategory_PayrollStatus_Cnt=0
--    Begin
--		 SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='PayrollStatus')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
---------------------------------------------------- // course category//------------------------------------------
 
--Declare @ControlCodeCategory_CourseCategory_Cnt bigint
--select @ControlCodeCategory_CourseCategory_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Course Category') 
-- IF @ControlCodeCategory_CourseCategory_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Course Category')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
--------------------------------------------------- // funding//----------------------------------------------
--Declare @ControlCodeCategory_Funding_Cnt bigint
--select @ControlCodeCategory_Funding_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Funding') 
-- IF @ControlCodeCategory_Funding_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Funding')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
--------------------------------------------------//venue//---------------------------------------------------
--  Declare @ControlCodeCategory_Venue_Cnt bigint
--select @ControlCodeCategory_Venue_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Venue') 
-- IF @ControlCodeCategory_Venue_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Venue')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
----------------------------------------------------// tax clarification (Earning)//--------------------------------
-- Declare @ControlCodeCategory_TaxClassificationEarning_Cnt bigint
--select @ControlCodeCategory_TaxClassificationEarning_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Tax Classification (Earning)') 
-- IF @ControlCodeCategory_TaxClassificationEarning_Cnt=0
--    Begin
--         SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Tax Classification (Earning)')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
--------------------------------------------------------------// tax clarification(Deduction)//------------------------
-- Declare @ControlCodeCategory_TaxClassificationDeduction_Cnt bigint
--select @ControlCodeCategory_TaxClassificationDeduction_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Tax Classification (Deduction)') 
-- IF @ControlCodeCategory_TaxClassificationDeduction_Cnt=0
--    Begin
--    SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Tax Classification (Deduction)')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
---------------------------------------------------------// Appraisal cycle//-------------------------------------------
-- Declare @ControlCodeCategory_AppraisalCycle_Cnt bigint
--select @ControlCodeCategory_AppraisalCycle_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appraisal Cycle') 
-- IF @ControlCodeCategory_AppraisalCycle_Cnt=0
--    Begin
--     	  SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Appraisal Cycle')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end

----admin control codes used in hr cursor

-------------------------------------------------// employee designation//----------------------------------------------
-- Declare @ControlCodeCategory_EmployeeDesignation_Cnt bigint
--select @ControlCodeCategory_EmployeeDesignation_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Employee Designation') 
-- IF @ControlCodeCategory_EmployeeDesignation_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Employee Designation')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
------------------------------------------------// source type//---------------------------------------------------------

-- Declare @ControlCodeCategory_SourceType_Cnt bigint
--select @ControlCodeCategory_SourceType_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Source Type') 
-- IF @ControlCodeCategory_SourceType_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Source Type')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);	
--end
---------------------------------------------------- // claims category//---------------------------------------------------
-- Declare @ControlCodeCategory_ClaimsCategory_Cnt bigint
--select @ControlCodeCategory_ClaimsCategory_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Claims Category') 
-- IF @ControlCodeCategory_ClaimsCategory_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Claims Category')
-- SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
-- INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
-- @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
-- end
-- ---------------------------------------------------// country//------------------------------------------------------
--  Declare @ControlCodeCategory_Country_Cnt bigint
--select @ControlCodeCategory_Country_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Country') 
-- IF @ControlCodeCategory_Country_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Country')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
------------------------------------------------------// Question category//---------------------------------------------
-- Declare @ControlCodeCategory_QuestionCategory_Cnt bigint
--select @ControlCodeCategory_QuestionCategory_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Question Category') 
-- IF @ControlCodeCategory_QuestionCategory_Cnt=0
--    Begin
-- SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Question Category')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--end
------------------------------------------------------// WorkType//---------------------------------------------
--	Declare @ControlCodeCategoryModule_WorkType_Cnt bigint
--			Select @ControlCodeCategoryModule_WorkType_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--			AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkType')
--			If @ControlCodeCategoryModule_WorkType_Cnt =0
--		  Begin
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='WorkType')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='Admin Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End


Exec [dbo].[ControlCodeCategoryModule_SP_New] @NEW_COMPANY_ID,8


  --seed data querys
       Declare @EvaluationDetails_Cnt BIGINT;
	   select 	@EvaluationDetails_Cnt=Count(*)
       from 	[HR].[EvaluationDetails] where companyid=@NEW_COMPANY_ID	
	   IF @EvaluationDetails_Cnt=0
   Begin
      INSERT INTO  [HR].[EvaluationDetails] (Id, CompanyId, Name, Type, Value, Status,RecOrder)  
      SELECT (NEWID()), @NEW_COMPANY_ID,Name, Type, Value, Status,RecOrder FROM [HR].[EvaluationDetails] WHERE COMPANYID=0
   End
	   ----------[HR].[WorkProfile]-----------------------------------------------
       Declare @WorkProfile_Cnt BIGINT;
	   select 	@WorkProfile_Cnt=Count(*) from 	[HR].[WorkProfile] where companyid=@NEW_COMPANY_ID	
	   IF @WorkProfile_Cnt=0
   Begin
      INSERT INTO HR.WorkProfile (Id, CompanyId, WorkProfileName, WorkingHoursPerDay, Monday, Tuesday, Wednenday, Thursday, Friday, Saturday, Sunday, TotalWorkingDaysPerWeek, TotalWorkingHoursPerWeek, IsDefaultProfile, IsSuperUserRec, Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, Status, Version)
      SELECT NEWID(), @NEW_COMPANY_ID, WorkProfileName, WorkingHoursPerDay, Monday, Tuesday, Wednenday, Thursday, Friday, Saturday, Sunday, TotalWorkingDaysPerWeek, TotalWorkingHoursPerWeek, IsDefaultProfile, 1, Remarks, UserCreated, CreatedDate, null, null, RecOrder, Status, Version FROM HR.WorkProfile WHERE CompanyId=@UNIQUE_COMPANY_ID
  
--    ----------Assets--------

--  Declare @ControlCodeCategorys_ClaimsCategory_Cnt bigint
--select @ControlCodeCategorys_ClaimsCategory_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Assets' AND ModuleNamesUsing='HR Cursor') 
-- IF @ControlCodeCategorys_ClaimsCategory_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Assets'and  ModuleNamesUsing='HR Cursor')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
-- @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
-- end



   ------------- [Common].[AttendanceRules] ---------------------

     INSERT [Common].[AttendanceRules] ([Id], [CompanyId], [LateInTime], [LateInType], [LateInTimeType], [LateInStatus], [LateOutTime], [LateOutType], [LateOutTimeType], [LateOutStatus], [PreviousTime], [PreviousType], [PreviousTimeType], [PreviousStatus] ,[UserCreated]      ,[CreatedDate]      ,[ModifiedBy]      ,[ModifiedDate]      ,[Version]      ,[Status]) VALUES (NEWID(), @NEW_COMPANY_ID , 10, N'After', N'FromTime', 1, 240, N'After', N'ToTime', 1, 300, N'Before', N'FromTime', 0,'System',GETUTCDATE(),NULL,NULL,NULL,1)


	 ------------------------------------- // Asset -- ControlCode //----------------------------------------------
Declare @ControlCodeCategory_Asset_Cnt bigint
select @ControlCodeCategory_Asset_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Asset') 
 IF @ControlCodeCategory_Asset_Cnt=0
    Begin
		SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Asset')
SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
end



---------[HR].[WorkProfileDetails]---------------------------------------

     INSERT INTO [HR].[WorkProfileDetails]  (Id, MasterId, Year, JanuaryDays, FebruaryDays, MarchDays, AprilDays, MayDays, JuneDays, JulyDays, AugustDays, SeptemberDays, OctoberDays, NovemberDays, DecemberDays, TotalWorkingHoursPerYear, TotalWorkingDaysPerYear,IsDefaultProfile,Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, Status, Version)
     SELECT NEWID(), (SELECT Id FROM HR.WorkProfile WHERE CompanyId=@NEW_COMPANY_ID AND WorkProfileName = (select WorkProfileName FROM [HR].[WorkProfile] where Id = WD.MasterId and CompanyId = @UNIQUE_COMPANY_ID)) as [MasterId], WD.Year, WD.JanuaryDays, WD.FebruaryDays, WD.MarchDays, WD.AprilDays, WD.MayDays, WD.JuneDays, WD.JulyDays, WD.AugustDays, WD.SeptemberDays, WD.OctoberDays, WD.NovemberDays, WD.DecemberDays, WD.TotalWorkingHoursPerYear, WD.TotalWorkingDaysPerYear,WD.IsDefaultProfile, WD.Remarks, WD.UserCreated, GETUTCDATE() as [CreatedDate], null, null, WD.RecOrder, WD.Status, WD.Version 
     FROM [HR].[WorkProfileDetails] WD INNER JOIN [HR].[WorkProfile] W
     ON W.Id = WD.MasterId
     WHERE W.COMPANYID = @UNIQUE_COMPANY_ID
  End
    ------------WorkProfile---
 update hr.WorkProfile set IsDefaultProfile=1 where WorkProfileName='5 Days/Week' and CompanyId=@NEW_COMPANY_ID

 update hr.WorkProfileDetails set IsDefaultProfile=1 where  MasterId in(select id from hr.WorkProfile where WorkProfileName='5 Days/Week' and CompanyId=@NEW_COMPANY_ID) and  [Year]=YEAR(getdate())

--====================== Pay Component Category =========================================

Declare @ControlCodeCategoryModule_PayComponentCategory_Cnt bigint
Select @ControlCodeCategoryModule_PayComponentCategory_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Pay component Category')
If @ControlCodeCategoryModule_PayComponentCategory_Cnt =0
Begin
	SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Pay component Category')
	SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='HR Cursor')
	INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
	@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
End


--====================== HR - Generic Templates Seed data ================================

declare @cnt bigint = (select Count(GT.Id) from Common.GenericTemplate GT
						Join Common.TemplateType TT on TT.Id = GT.TemplateTypeId
						where TT.ModuleMasterId = (select Id from Common.ModuleMaster where Name='HR Cursor') and GT.CompanyId=@NEW_COMPANY_ID)
If(@cnt = 0)
BEGIN
	INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsPartnerTemplate],[CursorName],[TemplateType])

	SELECT NEWID(),@NEW_COMPANY_ID,GT.[TemplateTypeId],GT.[Name],GT.[Code],GT.[TempletContent],GT.[IsSystem],GT.[IsFooterExist],GT.[IsHeaderExist],GT.[RecOrder],GT.[Remarks],GT.[UserCreated],GETUTCDATE(),null,null,GT.[Version],1,GT.[IsPartnerTemplate],GT.[CursorName],GT.[TemplateType]
	FROM Common.GenericTemplate GT
	Join Common.TemplateType TT on TT.Id = GT.TemplateTypeId 
	WHERE GT.CompanyId=@UNIQUE_COMPANY_ID and TT.ModuleMasterId = (select Id from Common.ModuleMaster where Name='HR Cursor') and TemplateType not in (select ISNULL(TemplateType,' ') from Common.GenericTemplate where CompanyId=@NEW_COMPANY_ID)
END

----------hr seed data sp-------	
	
	
	
	   Declare @PayComponent_Cnt BIGINT;
   select 	@PayComponent_Cnt=Count(*) from 	[Hr].[PayComponent]  where companyid=@NEW_COMPANY_ID	
   IF @PayComponent_Cnt=0
  Begin
   BEGIN
   IF NOT EXISTS (SELECT * FROM [Hr].[PayComponent] 
                   WHERE  [CompanyId] = @NEW_COMPANY_ID)
   BEGIN   
   INSERT INTO  [Hr].[PayComponent]  ( [Id],[CompanyId],[Name],[ShortCode],[Type],[WageType],[IsCPF],[IsNsPay],[IsTAX],[IsSDL],[IR8AItemSection],[PayMethod],[Amount],[PercentageComponent],[Percentage],[Formula],[IsAdjustable],[MaxCap],[ApplyTo],[IsExcludeFromGrossWage],[TaxClassification],[Reamrks],[UserCreated],[CreatedDate],[ModifiedDate],[ModifiedBy],[RecOrder],[Status],[IsSystem],[DefaultCOA],[COAId],[DefaultVendor],[Category])  
       SELECT (NEWID()),@NEW_COMPANY_ID,[Name],[ShortCode],[Type],[WageType],[IsCPF],[IsNsPay],[IsTAX],[IsSDL],[IR8AItemSection],[PayMethod],[Amount],[PercentageComponent],[Percentage],[Formula],[IsAdjustable],[MaxCap],[ApplyTo],[IsExcludeFromGrossWage],[TaxClassification],[Reamrks],[UserCreated],[CreatedDate],null,null,[RecOrder],[Status],[IsSystem],[DefaultCOA],(select id from Bean.ChartOfAccount where CompanyId=@NEW_COMPANY_ID and [Name] = [DefaultCOA]),[DefaultVendor],[Category] FROM [Hr].[PayComponent]  WHERE COMPANYID=0	     
   END
   END;
  end

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

		BEGIN
			COMMIT TRANSACTION
		END



		--Notification seed data

Begin
If Not Exists (Select Id From Notification.NotificationSettings WHere CompanyId=@NEW_COMPANY_ID And CursorName= 'HR Cursor')
Begin
Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,
Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

Select NEWID(),@NEW_COMPANY_ID,Null as CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,
IsOn,CreatedDate,null,null,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate
From Notification.NotificationSettings Where CompanyId=@UNIQUE_COMPANY_ID And CursorName= 'HR Cursor'
End
End

END
GO
