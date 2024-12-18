USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ADMIN_MODULE_SEED_DATA_CREATION]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ADMIN_MODULE_SEED_DATA_CREATION]
    @UNIQUE_COMPANY_ID BIGINT,
    @NEW_COMPANY_ID BIGINT

AS
BEGIN
    -- Variable Declarations
    DECLARE @IN_PROGRESS NVARCHAR(20) = 'In-Progress'
    DECLARE @COMPLETED NVARCHAR(20) = 'Completed'
    DECLARE @UNIQUE_ID UNIQUEIDENTIFIER

    -- Common Seed Data Insertion
    DECLARE @Common_Unique_Id UNIQUEIDENTIFIER = NEWID()

    EXEC [dbo].[FW_COMMON_SEEDDATA]  @UNIQUE_COMPANY_ID = @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID = @NEW_COMPANY_ID,  @UNIQUE_ID = @Common_Unique_Id

    UPDATE Common.MasterLog SET Status = @COMPLETED WHERE Id = @Common_Unique_Id

    -- Role and Permissions Insertion
    DECLARE @RoleAndPermissions_Unique_Id UNIQUEIDENTIFIER = NEWID()

    INSERT INTO Common.MasterLog 
    VALUES (@RoleAndPermissions_Unique_Id,  @NEW_COMPANY_ID, 'Role And Permissions Execution Started', 10, NULL,  GETUTCDATE(), @IN_PROGRESS )

    EXEC [dbo].[FW_ROLE_AND_PERMISSIONS_INSERTION]  @NEW_COMPANY_ID = @NEW_COMPANY_ID, @UNIQUE_COMPANY_ID =@UNIQUE_COMPANY_ID

    UPDATE Common.MasterLog  SET Status = @COMPLETED  WHERE Id = @RoleAndPermissions_Unique_Id

    -- Initial Cursor and Company Module Setup Updation
    DECLARE @initialCursorAndCompanyModuleupdation_Unique_Id UNIQUEIDENTIFIER = NEWID()

    INSERT INTO Common.MasterLog 
    VALUES (
        @initialCursorAndCompanyModuleupdation_Unique_Id,  @NEW_COMPANY_ID, 'Initial Cursor Setup and Company Module Updation Execution Started',  11, NULL,  GETUTCDATE(),  @IN_PROGRESS)

    EXEC [dbo].[FW_INITIAL_CURSOR_AND_COMPANY_MODULE_UPDATION] @NEW_COMPANY_ID

	insert into Common.AutoNumber (Id, CompanyId, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, MaxLength,StartNumber,[Reset],Preview, IsResetbySubsidary, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Variables,Sufix, Prefix, Entity, IsFormatChange, IsDisable, IsEditable, IsEditableDisable, EntityId)
	select NEWID(),@NEW_COMPANY_ID, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, [MaxLength], StartNumber, [Reset], Preview, IsResetbySubsidary, Status, 'System', GETUTCDATE(),null,null,Variables, Sufix,Prefix,Entity,IsFormatChange,IsDisable,IsEditable,IsEditableDisable,EntityId from Common.AutoNumber where  CompanyId=@UNIQUE_COMPANY_ID and EntityType = 'Employee' and EntityType not in (select EntityType from Common.AutoNumber where CompanyId=@NEW_COMPANY_ID and EntityType = 'Employee')


---------------------------------------- Common.Calender ----------------------------------


	--declare @Year int = 2020 --(select year(getdate()))

	--Declare @CountryName nvarchar(250) = (select Jurisdiction from common.Company where Id=@NEW_COMPANY_ID)
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

	 UPDATE Common.MasterLog SET Status = @COMPLETED 
    WHERE Id = @initialCursorAndCompanyModuleupdation_Unique_Id

END
GO
