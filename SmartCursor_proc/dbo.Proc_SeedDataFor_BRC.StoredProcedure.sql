USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SeedDataFor_BRC]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[Proc_SeedDataFor_BRC](@NEW_COMPANY_ID BIGINT,@UNIQUE_COMPANY_ID BIGINT)
AS
BEGIN 
   
   DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT
   DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT
   DECLARE @STATUS   INT
	DECLARE @CREATED_DATE DATETIME	
	SET @STATUS = 1    
	SET @CREATED_DATE =GETUTCDATE()  
  	BEGIN TRANSACTION
	BEGIN TRY
   Declare @AGMSetting_Cnt int;
   select @AGMSetting_Cnt = count(*) from Common.AGMSetting where companyid=@NEW_COMPANY_ID	
   If @AGMSetting_Cnt =0
   Begin
 INSERT INTO Common.AGMSetting
 Select Newid(),@NEW_COMPANY_ID,Name,BasedOn,Year,Formula,CreatedDate,UserCreated,null,null,Version,
 Status,RecOrder, Newid(),Period,NoOfDays,Duration From Common.AGMSetting where CompanyId=0
 End



update Common.AGMSetting set DocId=(
select Id from  Common.AGMSetting where name='Next FYE' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent' ) where name='Next FYE' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year'  
update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Next FYE' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year' ) where name='Next FYE' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent'

update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 175' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent') where name='Section 175' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year'
update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 175' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year' ) where name='Section 175' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent'

update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 201 (Private)' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent') where name='Section 201 (Private)' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year'
update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 201 (Private)' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year' ) where name='Section 201 (Private)' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent'

update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 201 (Public)' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent') where name='Section 201 (Public)' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year'
update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 201 (Public)' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year' ) where name='Section 201 (Public)' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent'

update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 197' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent') where name='Section 197' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year'
update Common.AGMSetting set DocId=(select Id from  Common.AGMSetting where name='Section 197' and  CompanyId=@NEW_COMPANY_ID and Year='1st Year' ) where name='Section 197' and  CompanyId=@NEW_COMPANY_ID and Year='Subsequent'



--Declare @ControlCodeCategoryModule_Register_Cnt bigint
--Select @ControlCodeCategoryModule_Register_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Register')
--If @ControlCodeCategoryModule_Register_Cnt =0
--Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Register')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='BR Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End

--  Declare @ControlCodeCategoryModule_NoofHours_Cnt bigint
--Select @ControlCodeCategoryModule_NoofHours_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='No. of Hours')
--If @ControlCodeCategoryModule_NoofHours_Cnt =0
--Begin
--     SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='No. of Hours')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='BR Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End

--  Declare @ControlCodeCategoryModule_ApprovalAuthority_Cnt bigint
--Select @ControlCodeCategoryModule_ApprovalAuthority_Cnt =count(*) from [Common].[ControlCodeCategoryModule] WHERE COMPANYID=@NEW_COMPANY_ID
--AND controlcategoryId  in (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Approval Authority')
--If @ControlCodeCategoryModule_ApprovalAuthority_Cnt =0
--Begin
--   SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT top 1 ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Approval Authority')
--  SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='BR Cursor')
--  INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--  @NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID);
--  End
--  				-----------CURRENCY --------------------
--Declare @Currency_Cnt int;
-- select @Currency_Cnt=Count(*) from [Bean].[Currency] where companyid=@NEW_COMPANY_ID 
-- IF @Currency_Cnt=0
-- Begin
--        INSERT INTO  [Bean].[Currency] (Id, Code, CompanyId, Name, RecOrder, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, DefaultValue)
--   SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Bean].[Currency]), Code, @NEW_COMPANY_ID, Name, RecOrder, STATUS,
--   UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, DefaultValue FROM [Bean].[Currency] WHERE COMPANYID=@UNIQUE_COMPANY_ID;
--   end
	---------------------------Gender------------------------
	
--		Declare @ControlCodeCategory_Gender_Cnt bigint
--select @ControlCodeCategory_Gender_Cnt=Count(*)  from [Common].[ControlCodeCategoryModule] where companyid=@NEW_COMPANY_ID 
--and controlcategoryId in(SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Gender') 
-- IF @ControlCodeCategory_Gender_Cnt=0
--    Begin
--SET @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID = (SELECT  ID FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID AND CONTROLCODECATEGORYCODE='Gender')
--SET @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID = (SELECT Id FROM [Common].[ModuleMaster]  WHERE COMPANYID=@UNIQUE_COMPANY_ID AND NAME='BR Cursor')
--INSERT INTO [Common].[ControlCodeCategoryModule] (Id, CompanyId, ControlCategoryId, ModuleMasterId) VALUES ((SELECT MAX(Id) + 1 FROM [Common].[ControlCodeCategoryModule]),
--@NEW_COMPANY_ID,@CONTROLCODECATEGORY_ID_MODULE_MASTER_ID,@MODULE_MASTER_ID_CONTROLCODECATEGORY_ID); 
--end	
  
  Exec [dbo].[ControlCodeCategoryModule_SP_New] @NEW_COMPANY_ID,9

 
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
END
GO
