USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_COMPANY_CREATION_SEED_DATA]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[FW_COMPANY_CREATION_SEED_DATA](@UNIQUE_COMPANY_ID BIGINT,@NEW_COMPANY_ID BIGINT,@DOC_STATUS INT,@TAX_STATUS INT,@CS_STATUS INT,@KNOWLEDGE_STATUS INT,@BEAN_STATUS INT, @AUDIT_STATUS INT,@WORKFLOW_STATUS INT,@CLIENT_STATUS INT,@HR_STATUS INT,@CC_ANALYTICS_STATUS INT,@WF_ANALYTICS_STATUS INT,@HR_ANALYTICS_STATUS INT,@BEAN_ANALYTICS_STATUS INT,@ISADD BIT)
AS
DECLARE @IN_PROGRESS nvarchar(20) = 'In-Progress'
DECLARE @COMPLETED nvarchar(20) = 'Completed'
DECLARE @UNIQUE_ID uniqueidentifier
BEGIN
--BEGIN TRANSACTION
BEGIN TRY
IF EXISTS(Select * from Common.MasterLog where CompanyId = @NEW_COMPANY_ID)
BEGIN
Update Common.MasterLog set Status = @COMPLETED where CompanyId = @NEW_COMPANY_ID
END
--================== Common Seed Data SP =================
--DECLARE @Common_Unique_Id uniqueidentifier = NewId()
--BEGIN

--EXEC [dbo].[FW_COMMON_SEEDDATA] @UNIQUE_COMPANY_ID = @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID = @NEW_COMPANY_ID, @UNIQUE_ID = @Common_Unique_Id

--Update Common.MasterLog set Status= @COMPLETED where Id=@Common_Unique_Id
--END
--================== Cursor wise SPs =============================

--=== DRFinance
if EXISTS (Select * From  Common.CompanyModule  Where ModuleId=(Select Id From Common.ModuleMaster Where Name='Dr Finance') and Status=1 and CompanyId=@NEW_COMPANY_ID)
BEGIN
	EXEC   [dbo].[Proc_SeedDataFor_DrFinance] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID
END

--=== AUDIT ======================================================================
DECLARE @Audit_Unique_Id uniqueidentifier = NewId()
IF (@AUDIT_STATUS = 1)
BEGIN
INSERT INTO Common.MasterLog values(@Audit_Unique_Id, @NEW_COMPANY_ID , 'FW_SEED_DATA_AUDIT Execution Started', 2, NULL, GETUTCDATE(), @IN_PROGRESS )
	EXEC [dbo].[FW_SEED_DATA_AUDIT] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID, @UNIQUE_ID = @Audit_Unique_Id
Update Common.MasterLog set Status= @COMPLETED where Id=@Audit_Unique_Id
END
--=== BEAN ========================================================================
DECLARE @Bean_Unique_Id uniqueidentifier = NewId()
IF (@BEAN_STATUS = 1)
BEGIN
INSERT INTO Common.MasterLog values(@Bean_Unique_Id, @NEW_COMPANY_ID , 'FW_SEED_DATA_BEAN Execution Started', 3, NULL, GETUTCDATE(),  @IN_PROGRESS )
	EXEC [dbo].[FW_SEED_DATA_BEAN]	@NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID, @UNIQUE_ID = @Bean_Unique_Id
Update Common.MasterLog set Status= @COMPLETED where Id=@Bean_Unique_Id
END
--=== BRC(BOARDROOM==CS) =====================================================================
DECLARE @BRC_Unique_Id uniqueidentifier = NewId()
IF (@CS_STATUS = 1)
BEGIN
INSERT INTO Common.MasterLog values(@BRC_Unique_Id, @NEW_COMPANY_ID , 'FW_SEED_DATA_BRC Execution Started',  4, NULL, GETUTCDATE(), @IN_PROGRESS )
	EXEC [dbo].[FW_SEED_DATA_BRC] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID, @UNIQUE_ID = @BRC_Unique_Id
	Update Common.MasterLog set Status= @COMPLETED where Id=@BRC_Unique_Id
END
--=== Client =============================================================================
DECLARE @CC_Unique_Id uniqueidentifier = NewId()
IF (@CLIENT_STATUS = 1)
BEGIN
INSERT INTO Common.MasterLog values(@CC_Unique_Id, @NEW_COMPANY_ID , 'FW_SEED_DATA_CC Execution Started', 5, NULL, GETUTCDATE(),  @IN_PROGRESS )
	EXEC [dbo].[FW_SEED_DATA_CC] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID, @UNIQUE_ID = @CC_Unique_Id
Update Common.MasterLog set Status= @COMPLETED where Id=@CC_Unique_Id
END
--=== HR ==================================================================================
DECLARE @HR_Unique_Id uniqueidentifier = NewId()
IF (@HR_STATUS = 1) 
BEGIN
INSERT INTO Common.MasterLog values(@HR_Unique_Id, @NEW_COMPANY_ID , 'FW_SEED_DATA_HR Execution Started',  6, NULL, GETUTCDATE(), @IN_PROGRESS )
	EXEC  [dbo].[FW_SEED_DATA_HR] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID, @UNIQUE_ID = @HR_Unique_Id
Update Common.MasterLog set Status= @COMPLETED where Id=@HR_Unique_Id
END
--=== TAX =========================================================================
DECLARE @Tax_Unique_Id uniqueidentifier = NewId()
IF (@TAX_STATUS = 1)
BEGIN
INSERT INTO Common.MasterLog values(@Tax_Unique_Id, @NEW_COMPANY_ID , 'FW_SEED_DATA_TAX Execution Started', 7, NULL, GETUTCDATE(),  @IN_PROGRESS )
	EXEC  [dbo].[FW_SEED_DATA_TAX]  @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID, @UNIQUE_ID = @Tax_Unique_Id
Update Common.MasterLog set Status= @COMPLETED where Id=@Tax_Unique_Id
END
--=== WF =========================================================================
DECLARE @WF_Unique_Id uniqueidentifier = NewId()
IF (@WORKFLOW_STATUS = 1)
BEGIN
INSERT INTO Common.MasterLog values(@WF_Unique_Id, @NEW_COMPANY_ID , 'FW_SEED_DATA_WF Execution Started', 8, NULL, GETUTCDATE(), @IN_PROGRESS )
	EXEC [dbo].[FW_SEED_DATA_WF] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@UNIQUE_ID = @WF_Unique_Id
Update Common.MasterLog set Status= @COMPLETED where Id=@WF_Unique_Id
END
--=== KB =========================================================================
DECLARE @KB_Unique_Id uniqueidentifier = NewId()
IF(@KNOWLEDGE_STATUS = 1)
BEGIN
INSERT INTO Common.MasterLog values(@KB_Unique_Id, @NEW_COMPANY_ID , 'FW_SEED_DATA_KB Execution Started', 9, NULL, GETUTCDATE(), @IN_PROGRESS )
 EXEC [dbo].[FW_SEED_DATA_KB] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@UNIQUE_ID = @KB_Unique_Id
Update Common.MasterLog set Status= @COMPLETED where Id=@KB_Unique_Id
END
--=== CC Analytics =========================================================================
DECLARE @CC_Analytics_Unique_Id uniqueidentifier = NewId()
IF(@CC_ANALYTICS_STATUS = 1)
BEGIN
INSERT INTO Common.MasterLog values(@CC_Analytics_Unique_Id, @NEW_COMPANY_ID , 'FW_SEED_DATA_CC_ANALYTICS Execution Started', 10, NULL, GETUTCDATE(), @IN_PROGRESS )
 EXEC [dbo].[FW_SEED_DATA_CC_ANALYTICS] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@UNIQUE_ID = @CC_Analytics_Unique_Id
Update Common.MasterLog set Status= @COMPLETED where Id=@CC_Analytics_Unique_Id
END
--=== WF Analytics =========================================================================
DECLARE @WF_Analytics_Unique_Id uniqueidentifier = NewId()
IF(@WF_ANALYTICS_STATUS = 1)
BEGIN
INSERT INTO Common.MasterLog values(@WF_Analytics_Unique_Id, @NEW_COMPANY_ID , 'FW_SEED_DATA_WF_ANALYTICS Execution Started', 11, NULL, GETUTCDATE(), @IN_PROGRESS )
 EXEC [dbo].[FW_SEED_DATA_WF_ANALYTICS] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@UNIQUE_ID = @WF_Analytics_Unique_Id
Update Common.MasterLog set Status= @COMPLETED where Id=@WF_Analytics_Unique_Id
END
--=== HR Analytics =========================================================================
DECLARE @HR_Analytics_Unique_Id uniqueidentifier = NewId()
IF(@HR_ANALYTICS_STATUS = 1)
BEGIN
INSERT INTO Common.MasterLog values(@HR_Analytics_Unique_Id, @NEW_COMPANY_ID , 'FW_SEED_DATA_HR_ANALYTICS Execution Started', 12, NULL, GETUTCDATE(), @IN_PROGRESS )
 EXEC [dbo].[FW_SEED_DATA_HR_ANALYTICS] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@UNIQUE_ID = @HR_Analytics_Unique_Id
Update Common.MasterLog set Status= @COMPLETED where Id=@HR_Analytics_Unique_Id
END
--=== Bean Analytics =========================================================================
DECLARE @Bean_Analytics_Unique_Id uniqueidentifier = NewId()
IF(@BEAN_ANALYTICS_STATUS = 1)
BEGIN
INSERT INTO Common.MasterLog values(@Bean_Analytics_Unique_Id, @NEW_COMPANY_ID , 'FW_SEED_DATA_Bean_ANALYTICS Execution Started', 13, NULL, GETUTCDATE(), @IN_PROGRESS )
 EXEC [dbo].[FW_SEED_DATA_BEAN_ANALYTICS] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@UNIQUE_ID = @Bean_Analytics_Unique_Id
Update Common.MasterLog set Status= @COMPLETED where Id=@Bean_Analytics_Unique_Id
END
--======= DOC =====================================================================
IF(@DOC_STATUS = 1)
BEGIN
	Exec dbo.DcCsr_MdlDtlId @NEW_COMPANY_ID
	Print ''
END;

--====================== WF or HR =================================================

IF(@WORKFLOW_STATUS = 1 or @HR_STATUS = 1) -- WorkWeek Setup ony for WF and HR
BEGIN
 IF NOT EXISTS (select * from [Common].[WorkWeekSetUp] where companyId = @NEW_COMPANY_ID)
	BEGIN
		INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
		VALUES(NEWID(),@NEW_COMPANY_ID,'Monday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','System',GETUTCDATE(),null,null,null,1,1,1)

		INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
		VALUES(NEWID(),@NEW_COMPANY_ID,'Tuesday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','System',GETUTCDATE(),null,null,null,1,1,2)

		INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
		VALUES(NEWID(),@NEW_COMPANY_ID,'Wednesday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','System',GETUTCDATE(),null,null,null,1,1,3)

		INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
		VALUES(NEWID(),@NEW_COMPANY_ID,'Thursday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','System',GETUTCDATE(),null,null,null,1,1,4)

		INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
		VALUES(NEWID(),@NEW_COMPANY_ID,'Friday','09:00:00','13:00:00','14:00:00','18:00:00','08:00:00','System',GETUTCDATE(),null,null,null,1,1,5)

		DECLARE @IDs UNIQUEIDENTIFIER
		SET @IDs=NEWID()
		INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
		VALUES(@IDs,@NEW_COMPANY_ID,'Saturday','00:00:00','00:00:00','00:00:00','00:00:00','00:00:00','System',GETUTCDATE(),null,null,null,1,0,6)


		DECLARE @NewID UNIQUEIDENTIFIER
		SET  @NewID = NEWID()
		INSERT INTO [Common].[WorkWeekSetUp]([Id],[CompanyId],[WeekDay],[AMFromTime] ,[AMToTime],[PMFromTime],[PMToTime],[WorkingHours],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Remarks],[Status],[IsWorkingDay],[RecOrder])
		VALUES(@NewID,@NEW_COMPANY_ID,'Sunday','00:00:00','00:00:00','00:00:00','00:00:00','00:00:00','System',GETUTCDATE(),null,null,null,1,0,7)
	END

	--declare @NEW_COMPANY_ID bigint
	---declare @Year int = 2020
	--declare @UNIQUE_COMPANY_ID bigint = 0

	--BEGIN
	--insert into Common.AutoNumber (Id, CompanyId, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, MaxLength,StartNumber,[Reset],Preview, IsResetbySubsidary, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Variables,Sufix, Prefix, Entity, IsFormatChange, IsDisable, IsEditable, IsEditableDisable, EntityId)
	--select NEWID(),@NEW_COMPANY_ID, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, [MaxLength], StartNumber, [Reset], Preview, IsResetbySubsidary, Status, 'System', GETUTCDATE(),null,null,Variables, Sufix,Prefix,Entity,IsFormatChange,IsDisable,IsEditable,IsEditableDisable,EntityId from Common.AutoNumber where  CompanyId=@UNIQUE_COMPANY_ID and EntityType = 'Employee' and EntityType not in (select EntityType from Common.AutoNumber where CompanyId=@NEW_COMPANY_ID and EntityType = 'Employee')
	--END

	Declare @CountryName nvarchar(250) = (select Jurisdiction from common.Company where Id=@NEW_COMPANY_ID)
	--if(@CountryName='India')
	--Begin
	--	DECLARE Calender_Csr Cursor for SELECT Distinct a.Id from Common.Company a where ParentId is null and Jurisdiction='India' and a.Id != 0 and Id=@NEW_COMPANY_ID
	--	Open Calender_Csr
	--	Fetch Next From Calender_Csr into @NEW_COMPANY_ID
	--	While @@FETCH_STATUS=0
	--	BEGIN
	--		Print @NEW_COMPANY_ID
	--		INSERT INTO Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Jurisdiction)
	--		SELECT(NEWID()),@NEW_COMPANY_ID,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,GETUTCDATE(),null,null,Version,Status,Jurisdiction FROM Common.Calender WHERE COMPANYID=@UNIQUE_COMPANY_ID and Jurisdiction='India' AND Name not in (select name from Common.Calender where CompanyId=@NEW_COMPANY_ID AND (convert(int,Datepart(Year,FromDateTime)) = @Year OR convert(int,Datepart(Year,ToDateTime)) = @Year)) AND Convert(Date,fromdatetime) not in (select Convert(date,FromDateTime) from Common.Calender where CompanyId=@NEW_COMPANY_ID) AND Convert(date,ToDateTime) not in (select Convert(date,ToDateTime) from Common.Calender where CompanyId=@NEW_COMPANY_ID)
  
	--		Fetch Next From Calender_Csr into @NEW_COMPANY_ID
	--	End	
	--End
	--Else
	--Begin
	--	DECLARE Calender_Csr Cursor for SELECT Distinct a.Id from Common.Company a where ParentId is null and Jurisdiction='Singapore' and a.Id != 0 and Id=@NEW_COMPANY_ID
	--	Open Calender_Csr
	--	Fetch Next From Calender_Csr into @NEW_COMPANY_ID
	--	While @@FETCH_STATUS=0
	--	BEGIN
	--		Print @NEW_COMPANY_ID
	--		INSERT INTO Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Jurisdiction)
	--		SELECT(NEWID()),@NEW_COMPANY_ID,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,GETUTCDATE(),null,null,Version,Status,Jurisdiction FROM Common.Calender WHERE COMPANYID=@UNIQUE_COMPANY_ID and Jurisdiction is null AND Name not in (select name from Common.Calender where CompanyId=@NEW_COMPANY_ID AND (convert(int,Datepart(Year,FromDateTime)) = @Year OR convert(int,Datepart(Year,ToDateTime)) = @Year)) AND Convert(Date,fromdatetime) not in (select Convert(date,FromDateTime) from Common.Calender where CompanyId=@NEW_COMPANY_ID) AND Convert(date,ToDateTime) not in (select Convert(date,ToDateTime) from Common.Calender where CompanyId=@NEW_COMPANY_ID)
  
	--		Fetch Next From Calender_Csr into @NEW_COMPANY_ID
	--	End	
	--End
	if(@CountryName='India')
	begin
		exec [dbo].[CALENDAR_TO_TIMELOGITEM_INSETTION_INDIA] @NEW_COMPANY_ID
	end
	else if(@CountryName != 'India')
	begin
		exec [dbo].[CALENDAR_TO_TIMELOGITEM_INSETTION] @NEW_COMPANY_ID
	end
	--exec CALENDAR_TO_TIMELOGITEM_INSETTION  @NEW_COMPANY_ID
END

--===================================================== 
--Updating the InitialCursor Setup and CompanyModuleSetup Based on Cursor Activation
--EXEC [dbo].[FW_INITIAL_CURSOR_AND_COMPANY_MODULE_UPDATION] @NEW_COMPANY_ID

--Inserting/Updating the Role and UserRoles
	DECLARE @RoleAndPermissions_Unique_Id uniqueidentifier = NewId()
	INSERT INTO Common.MasterLog values(@RoleAndPermissions_Unique_Id, @NEW_COMPANY_ID , 'Role And Permissions Execution Started', 10, NULL, GETUTCDATE(), @IN_PROGRESS )

	EXEC [dbo].[FW_ROLE_AND_PERMISSIONS_INSERTION] @NEW_COMPANY_ID = @NEW_COMPANY_ID, @UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID

	Update Common.MasterLog set Status= @COMPLETED where Id=@RoleAndPermissions_Unique_Id

--== For InitialCursorSetup updation
--exec [dbo].[SP_InitialCursorSetup_Updation] @NEW_COMPANY_ID		

--Updating the InitialCursor Setup and CompanyModuleSetup Based on Cursor Activation
	DECLARE @initialCursorAndCompanyModuleupdation_Unique_Id uniqueidentifier = NewId()
	INSERT INTO Common.MasterLog values(@initialCursorAndCompanyModuleupdation_Unique_Id, @NEW_COMPANY_ID , 'Initial Cursor Setup and Company Module Updation Execution Started', 11, NULL, GETUTCDATE(), @IN_PROGRESS )
	EXEC [dbo].[FW_INITIAL_CURSOR_AND_COMPANY_MODULE_UPDATION] @NEW_COMPANY_ID
	Update Common.MasterLog set Status= @COMPLETED where Id=@initialCursorAndCompanyModuleupdation_Unique_Id
--COMMIT

	IF (@HR_STATUS = 1) 
	BEGIN
		DECLARE @Feature_Update_Unique_Id uniqueidentifier = NewId()
		INSERT INTO Common.MasterLog values(@Feature_Update_Unique_Id, @NEW_COMPANY_ID , 'HR - Feature wise Modulde detail Execution Started', 12, NULL, GETUTCDATE(), @IN_PROGRESS )
		EXEC [dbo].[FW_FEATURE_WISE_UPDATE_HR] @NEW_COMPANY_ID = @NEW_COMPANY_ID, @UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID, @UNIQUE_ID = @Feature_Update_Unique_Id
		Update Common.MasterLog set Status= @COMPLETED where Id=@Feature_Update_Unique_Id
	END

	---old templates migration All service entity

	if  exists (select * from common.GenericTemplate as GT join common.TemplateType as TT on GT.TemplateTypeId=TT.Id where (TT.Name='Invoice Email' or TT.Name='Invoice' or TT.Name='Quotation Email' or TT.Name='Quotation Summary' or TT.Name='EmailBody' or TT.Name='PaySlip') and (TT.ModuleMasterId=8 or TT.ModuleMasterId=1 or TT.ModuleMasterId=2) and GT.CompanyId=@NEW_COMPANY_ID and GT.ServiceCompanyIds!=null and GT.ServiceCompanyIds <> '')
	begin
	DECLARE @Table1 TABLE (Ids nvarchar(Max),Names nvarchar(max))
	delete @Table1
	declare @Ids1 nvarchar(100)
	declare @Names1 nvarchar(100)
	INSERT INTO @Table1
	select Distinct Id,ShortName FROM Common.Company where ParentId=@NEW_COMPANY_ID
	if((select count(*) from @Table1) >= 1)
	BEGIN
	    if exists(select * from common.GenericTemplate where companyId = @NEW_COMPANY_ID)
		BEGIN
			set @Ids1 = (SELECT  STRING_AGG([Ids], ', ') FROM @Table1)
			set @Names1 = (SELECT  STRING_AGG([Names], ', ') FROM @Table1)
			update  GT set GT.ServiceCompanyIds = @Ids1,ServiceCompanyNames=@Names1
			from common.GenericTemplate as GT join common.TemplateType as TT on GT.TemplateTypeId=TT.Id where (TT.Name='Invoice Email' or TT.Name='Invoice' or TT.Name='Quotation Email' or TT.Name='Quotation Summary' or TT.Name='EmailBody' or TT.Name='PaySlip') and (TT.ModuleMasterId=8 or TT.ModuleMasterId=1 or TT.ModuleMasterId=2) and GT.CompanyId=@NEW_COMPANY_ID
		END
	END
	end


END TRY
BEGIN CATCH
    PRINT 'FAILED..!'
	DECLARE      
     @ErrorMessage NVARCHAR(4000),      
     @ErrorSeverity INT,      
     @ErrorState INT;      
SELECT      
     @ErrorMessage = ERROR_MESSAGE(),      
     @ErrorSeverity = ERROR_SEVERITY(),      
     @ErrorState = ERROR_STATE();      
   RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState); 
	--ROLLBACK;
END CATCH
END
GO
