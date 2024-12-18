USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_UAT_CREATE_SEED_DATA_1]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_UAT_CREATE_SEED_DATA_1](@UNIQUE_COMPANY_ID BIGINT,@NEW_COMPANY_ID BIGINT,@DOC_STATUS INT,@TAX_STATUS INT,@CS_STATUS INT,@KNOWLEDGE_STATUS INT,@BEAN_STATUS INT, @AUDIT_STATUS INT,@WORKFLOW_STATUS INT,@CLIENT_STATUS INT,@HR_STATUS INT,@ISADD BIT)
AS
BEGIN    
	--------------PARA METERS ---------------------------------------------        
	DECLARE @STATUS   INT
	DECLARE @CREATED_DATE DATETIME	
	DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT
	DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT
	DECLARE @ACCOUNTYPE_ID_ID_TYPE_ID BIGINT
	DECLARE @ID_TYPE_ACCOUNTYPE_ID_ID BIGINT	
	SET @STATUS = 1    
	SET @CREATED_DATE =GETUTCDATE()   	
	BEGIN TRANSACTION
	BEGIN TRY
	


-----------------------------------------CONTROL CODE--------------------------------------------------
        --@@@CONTROL CODE
	--	DECLARE @CONTROL_ID BIGINT,@NEW_CONTROL_ID BIGINT
	--	DECLARE @ControlCodeCategory_CNT BIGINT
	--	SELECT @ControlCodeCategory_CNT=COUNT(*) FROM [Common].[ControlCodeCategory] WHERE COMPANYID=@NEW_COMPANY_ID
	--	IF @ControlCodeCategory_CNT=0 
	--	BEGIN
	--	DECLARE CONTROL_CURSOR CURSOR FOR 
	--	SELECT  Id FROM [Common].[ControlCodeCategory] where companyid=0 
	--	OPEN CONTROL_CURSOR
	--	FETCH NEXT FROM CONTROL_CURSOR INTO @CONTROL_ID
	--	WHILE @@FETCH_STATUS=0
	--	BEGIN   
	--		SET @NEW_CONTROL_ID = (SELECT MAX(ID) +1 FROM [Common].[ControlCodeCategory])
	--		INSERT INTO [Common].[ControlCodeCategory] (Id, CompanyId, ControlCodeCategoryCode, ControlCodeCategoryDescription, DataType,
	--		Format, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, ModuleNamesUsing, DefaultValue)
	--		SELECT @NEW_CONTROL_ID, @NEW_COMPANY_ID, ControlCodeCategoryCode, ControlCodeCategoryDescription, DataType, Format, RecOrder, Remarks, UserCreated,
	--			GETUTCDATE(), ModifiedBy, ModifiedDate, Version, status, ModuleNamesUsing, DefaultValue FROM [Common].[ControlCodeCategory] WHERE ID=@CONTROL_ID 
	--		INSERT INTO [Common].[ControlCode] (Id, ControlCategoryId, CodeKey, CodeValue, IsSystem, RecOrder, Remarks, UserCreated, CreatedDate, 
	--			ModifiedBy, ModifiedDate, Version, Status, IsDefault)
	--		SELECT ROW_NUMBER() OVER(ORDER BY a.ID) + (SELECT MAX(Id) + 1 FROM [Common].[ControlCode]) AS Id,@NEW_CONTROL_ID, a.CodeKey, a.CodeValue,
	--			a.IsSystem, a.RecOrder, a.Remarks, a.UserCreated, GETUTCDATE(), a.ModifiedBy,a.ModifiedDate, a.Version, a.Status, a.IsDefault 
	--			from  [Common].[ControlCode] a join [Common].[ControlCodeCategory] b on a.controlcategoryid=b.id where b.companyid=0 
	--			and a.controlcategoryid=@CONTROL_ID
							  			
	--		FETCH NEXT FROM CONTROL_CURSOR INTO @CONTROL_ID      
	--	END	
	--END
	--@@@CONTROL CODE

		/*STARTING POINT FOR CONTROL CODE CATEGORY AND CONTROL CODE */
		
DECLARE @WHERE_CONDITION NVARCHAR(MAX)='OR ModuleNamesUsing LIKE'+'('''+'%Admin Cursor%'+''''+')'
DECLARE @WHERE_CONDITION1 NVARCHAR(MAX)
DECLARE @WHERE_CONDITION_RESULT NVARCHAR(MAX)
  
--IF @ADM_STATUS=1
--BEGIN
--   SELECT @WHERE_CONDITION=@WHERE_CONDITION+'OR ModuleNamesUsing LIKE'+'('''+'%Admin Cursor%'+''''+')'
--END
IF @AUDIT_STATUS=1
BEGIN
   SELECT @WHERE_CONDITION=@WHERE_CONDITION+'OR ModuleNamesUsing LIKE'+'('''+'%Audit Cursor%'+''''+')'
END
IF @BEAN_STATUS=1
BEGIN
   SELECT @WHERE_CONDITION=@WHERE_CONDITION+'OR ModuleNamesUsing LIKE'+'('''+'%Bean Cursor%'+''''+')'
END
IF @CS_STATUS=1--BR Cursor
BEGIN
  SELECT @WHERE_CONDITION=@WHERE_CONDITION+'OR ModuleNamesUsing LIKE'+'('''+'%BR Cursor%'+''''+')'
END
IF @CLIENT_STATUS=1
BEGIN
   SELECT @WHERE_CONDITION=@WHERE_CONDITION+'OR ModuleNamesUsing LIKE'+'('''+'%Client Cursor%'+''''+')'
END
IF @DOC_STATUS=1
BEGIN
  SELECT @WHERE_CONDITION=@WHERE_CONDITION+'OR ModuleNamesUsing LIKE'+'('''+'%Doc Cursor%'+''''+')'
END
IF @HR_STATUS=1
BEGIN
   SELECT @WHERE_CONDITION=@WHERE_CONDITION+'OR ModuleNamesUsing LIKE'+'('''+'%HR Cursor%'+''''+')'
END
IF @KNOWLEDGE_STATUS=1
BEGIN
   SELECT @WHERE_CONDITION=@WHERE_CONDITION+'OR ModuleNamesUsing LIKE'+'('''+'%Knowledge Cursor%'+''''+')'
END
IF @TAX_STATUS=1
BEGIN
   SELECT @WHERE_CONDITION=@WHERE_CONDITION+'OR ModuleNamesUsing LIKE'+'('''+'%Tax Cursor%'+''''+')'
END
IF @WORKFLOW_STATUS=1
BEGIN
  SELECT @WHERE_CONDITION=@WHERE_CONDITION+'OR ModuleNamesUsing LIKE'+'('''+'%Workflow Cursor%'+''''+')'
END
--IF @ANALYTICS_STATUS=1
--BEGIN
--  SELECT @WHERE_CONDITION=@WHERE_CONDITION+'OR ModuleNamesUsing LIKE'+'('''+'%Analytics Cursor%'+''''+')'
--END
  
PRINT @WHERE_CONDITION
 
SELECT @WHERE_CONDITION1=SUBSTRING(@WHERE_CONDITION,25,LEN(@WHERE_CONDITION))
  
PRINT @WHERE_CONDITION1
  
/*
  --FOR UNIQUE COMPANYID
DECLARE @SQL_QUERY_UNIQUE_COMPANY_ID_COUNT VARCHAR(MAX)='SELECT count(*) FROM Common.ControlCodeCategory WHERE CompanyId='+CONVERT(VARCHAR,@UNIQUE_COMPANY_ID)+' AND (ModuleNamesUsing LIKE'
--PRINT @SQL_QUERY_UNIQUE_COMPANY_ID_COUNT
SELECT @SQL_QUERY_UNIQUE_COMPANY_ID_COUNT=@SQL_QUERY_UNIQUE_COMPANY_ID_COUNT+@WHERE_CONDITION1+')'
PRINT @SQL_QUERY_UNIQUE_COMPANY_ID_COUNT

--exec sp_sqlexec @SQL_QUERY_UNIQUE_COMPANY_ID
*/

--FOR NEW COMPANYID
DECLARE @NEW_COMPANY_ID_COUNT TABLE( COUNT BIGINT)
DECLARE @CNT BIGINT
DECLARE @SQL_QUERY_NEW_COMPANY_ID VARCHAR(MAX)='SELECT count(*)  FROM Common.ControlCodeCategory WHERE CompanyId='+CONVERT(VARCHAR,@NEW_COMPANY_ID)+' AND (ModuleNamesUsing LIKE'
--PRINT @SQL_QUERY_NEW_COMPANY_ID
SET @SQL_QUERY_NEW_COMPANY_ID=@SQL_QUERY_NEW_COMPANY_ID+@WHERE_CONDITION1+')'

PRINT @SQL_QUERY_NEW_COMPANY_ID

INSERT INTO @NEW_COMPANY_ID_COUNT EXEC  sp_sqlexec @SQL_QUERY_NEW_COMPANY_ID
--SELECT * FROM @NEW_COMPANY_ID_COUNT
SELECT @CNT= COUNT FROM @NEW_COMPANY_ID_COUNT
PRINT @CNT


---EXEC @NEW_COMPANY_ID_COUNT= sp_sqlexec @SQL_QUERY_NEW_COMPANY_ID

--PRINT 'NEW_COMPANY_ID_COUNT:'+CONVERT(VARCHAR,@NEW_COMPANY_ID_COUNT)



--DECLARE @NEW_COMPANY_DATA TABLE(ID BIGINT,COMPANYID BIGINT,ControlCodeCategoryCode NVARCHAR(200),ControlCodeCategoryDescription NVARCHAR(200),DataType NVARCHAR(20),[Format] NVARCHAR(40),RecOrder INT,Remarks NVARCHAR(508)) 
DECLARE @UNQ_COMPANY_DATA TABLE(ID BIGINT,COMPANYID BIGINT,ControlCodeCategoryCode NVARCHAR(200),ControlCodeCategoryDescription NVARCHAR(200),DataType NVARCHAR(20),[Format] NVARCHAR(40),RecOrder INT,Remarks NVARCHAR(508),UserCreated NVARCHAR(508),CreatedDate DATETIME2,ModifiedBy NVARCHAR(508),ModifiedDate DATETIME2,[VERSION] SMALLINT,[Status] INT,ModuleNamesUsing NVARCHAR(2000),DefaultValue NVARCHAR(200)) 

DECLARE @UNQ_COMPANY_DATA_FOR_CONTROLCODE TABLE(Id BIGINT,ControlCategoryId BIGINT,CodeKey NVARCHAR(MAX),CodeValue NVARCHAR(MAX),IsSystem NVARCHAR(20),RecOrder INT,Remarks NVARCHAR(508),UserCreated NVARCHAR(508),CreatedDate DATETIME2,ModifiedBy NVARCHAR(508),ModifiedDate DATETIME2,Version SMALLINT,Status INT,IsDefault BIT,ModuleNamesUsing NVARCHAR(2000))

DECLARE @SQL_QUERY1_UNIQUE_COMPANY_ID VARCHAR(MAX)=' SELECT *  FROM Common.ControlCodeCategory WHERE CompanyId='+CONVERT(VARCHAR,@UNIQUE_COMPANY_ID)+' AND (ModuleNamesUsing LIKE'
--PRINT @SQL_QUERY1_UNIQUE_COMPANY_ID
SET @SQL_QUERY1_UNIQUE_COMPANY_ID=@SQL_QUERY1_UNIQUE_COMPANY_ID+@WHERE_CONDITION1+')'

PRINT @SQL_QUERY1_UNIQUE_COMPANY_ID

INSERT INTO @UNQ_COMPANY_DATA
EXEC sp_sqlexec  @SQL_QUERY1_UNIQUE_COMPANY_ID

-- SELECT * FROM @UNQ_COMPANY_DATA

/**** HERE WE INSERT NEW COMPANY EXISTING DATA LIKE CompanyId,ControlCodeCategoryCode,ModuleNamesUsing INTO @NEW_COMPANY_EXIST_COLUMNS****/

DECLARE @NEW_COMPANY_EXIST_COLUMNS TABLE (Id BIGINT,CompanyId BIGINT,ControlCodeCategoryCode NVARCHAR(200),ModuleNamesUsing NVARCHAR(200))
INSERT INTO @NEW_COMPANY_EXIST_COLUMNS
SELECT Id,CompanyId,ControlCodeCategoryCode,ModuleNamesUsing FROM Common.ControlCodeCategory WHERE CompanyId= @NEW_COMPANY_ID
--SELECT * FROM @NEW_COMPANY_EXIST_COLUMNS

DECLARE @NEW_COMPANY_NEW_COLUMNS TABLE (Id BIGINT,CompanyId BIGINT,ControlCodeCategoryCode NVARCHAR(200),ModuleNamesUsing NVARCHAR(200))
INSERT INTO @NEW_COMPANY_NEW_COLUMNS
SELECT Id,CompanyId,ControlCodeCategoryCode,ModuleNamesUsing FROM @UNQ_COMPANY_DATA
/** BUT,HERE WE TAKIND DATA FOR UNIQUE COMPANY ID FOR THE USAGE OF UNIQUE COMPANYID IN CURSOR CODE ***/ 
--SELECT * FROM @NEW_COMPANY_NEW_COLUMNS

 
IF @CNT=0
BEGIN

	DECLARE @CONTROL_ID BIGINT
	DECLARE @NEW_CONTROL_ID BIGINT
	DECLARE @ID_IN_CONTROLCODE BIGINT
	DECLARE @NEWID_IN_CONTROLCODE BIGINT
	DECLARE CONTROLCODE_CURSOR CURSOR FOR SELECT ID FROM @UNQ_COMPANY_DATA
	OPEN CONTROLCODE_CURSOR
	        FETCH NEXT FROM CONTROLCODE_CURSOR INTO @CONTROL_ID
			WHILE (@@FETCH_STATUS=0)
			BEGIN
				SET @NEW_CONTROL_ID = (SELECT MAX(ID) +1 FROM [Common].[ControlCodeCategory])

				INSERT INTO [Common].[ControlCodeCategory] (Id, CompanyId, ControlCodeCategoryCode, ControlCodeCategoryDescription, DataType,
				Format, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, ModuleNamesUsing, DefaultValue)

				SELECT @NEW_CONTROL_ID, @NEW_COMPANY_ID, ControlCodeCategoryCode, ControlCodeCategoryDescription, DataType, Format, RecOrder, Remarks, UserCreated,
					   GETUTCDATE(), null, null, Version, status, ModuleNamesUsing, DefaultValue FROM @UNQ_COMPANY_DATA WHERE ID=@CONTROL_ID 
				 
				IF EXISTS (SELECT * FROM @UNQ_COMPANY_DATA_FOR_CONTROLCODE)
				BEGIN
				  DELETE FROM @UNQ_COMPANY_DATA_FOR_CONTROLCODE
				 END

				INSERT INTO @UNQ_COMPANY_DATA_FOR_CONTROLCODE
				SELECT * FROM Common.ControlCode WHERE ControlCategoryId=@CONTROL_ID

				-- DECLARING A NEW CURSOR INSIDE FOR INSERTION OF RECORDS IN CONTROLCODE TABLE

					DECLARE CONTROLCODE1_CURSOR CURSOR FOR SELECT ID FROM @UNQ_COMPANY_DATA_FOR_CONTROLCODE
					OPEN CONTROLCODE1_CURSOR
					  FETCH NEXT FROM CONTROLCODE1_CURSOR INTO @ID_IN_CONTROLCODE
					  WHILE (@@FETCH_STATUS=0)
					  BEGIN
						SET @NEWID_IN_CONTROLCODE=(SELECT MAX(ID)+1 FROM Common.ControlCode)
						INSERT INTO Common.ControlCode
						SELECT @NEWID_IN_CONTROLCODE,@NEW_CONTROL_ID,CodeKey,CodeValue,IsSystem,RecOrder,Remarks,UserCreated,GETUTCDATE(),null,null,Version,Status,IsDefault,ModuleNamesUsing 
						FROM @UNQ_COMPANY_DATA_FOR_CONTROLCODE WHERE Id=@ID_IN_CONTROLCODE
						FETCH NEXT FROM CONTROLCODE1_CURSOR INTO @ID_IN_CONTROLCODE
						
                      END
					 -- WHILE @@FETCH_STATUS=0
					  
					CLOSE CONTROLCODE1_CURSOR
			        DEALLOCATE CONTROLCODE1_CURSOR
					 --ENDING POINT OF INSIDE CURSOR

				FETCH NEXT FROM CONTROLCODE_CURSOR INTO @CONTROL_ID
			End
			-- WHILE @@FETCH_STATUS=0
			  
	CLOSE CONTROLCODE_CURSOR
	DEALLOCATE CONTROLCODE_CURSOR
END
ELSE IF @CNT<>0
BEGIN
    DECLARE @CONTROL_ID1 BIGINT
	DECLARE @CCCC NVARCHAR(200)
	DECLARE @MNU NVARCHAR(MAX)
	DECLARE @CCCC1 NVARCHAR(200)
	DECLARE @MNU1 NVARCHAR(MAX)
	DECLARE @NEW_CONTROL_ID1 BIGINT
	DECLARE @ID_IN_CONTROLCODE1 BIGINT
	DECLARE @NEWID_IN_CONTROLCODE1 BIGINT
	DECLARE CONTROLCODE_CURSOR1 CURSOR FOR SELECT Id,ControlCodeCategoryCode,ModuleNamesUsing FROM @NEW_COMPANY_NEW_COLUMNS
	OPEN CONTROLCODE_CURSOR1
	        FETCH NEXT FROM CONTROLCODE_CURSOR1 INTO @CONTROL_ID1,@CCCC,@MNU
			WHILE (@@FETCH_STATUS=0)
			BEGIN
				SET @NEW_CONTROL_ID1 = (SELECT MAX(ID) +1 FROM [Common].[ControlCodeCategory])
				
				SELECT @CCCC1=ControlCodeCategoryCode FROM @NEW_COMPANY_EXIST_COLUMNS WHERE ControlCodeCategoryCode=@CCCC AND ModuleNamesUsing=@MNU
				SELECT @MNU1=ModuleNamesUsing FROM @NEW_COMPANY_EXIST_COLUMNS WHERE ControlCodeCategoryCode=@CCCC AND ModuleNamesUsing=@MNU
				IF(@CCCC=@CCCC1 AND @MNU=@MNU1)
				BEGIN
				 PRINT 1
				END
				ELSE
				BEGIN

					INSERT INTO [Common].[ControlCodeCategory] (Id, CompanyId, ControlCodeCategoryCode, ControlCodeCategoryDescription, DataType,
					Format, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, ModuleNamesUsing, DefaultValue)

					SELECT @NEW_CONTROL_ID1, @NEW_COMPANY_ID, ControlCodeCategoryCode, ControlCodeCategoryDescription, DataType, Format, RecOrder, Remarks, UserCreated,
						   GETUTCDATE(), null, null, Version, status, ModuleNamesUsing, DefaultValue 
					FROM   @UNQ_COMPANY_DATA WHERE ID=@CONTROL_ID1 AND ControlCodeCategoryCode=@CCCC AND ModuleNamesUsing=@MNU
					 
					IF EXISTS (SELECT * FROM @UNQ_COMPANY_DATA_FOR_CONTROLCODE)
					BEGIN
					  DELETE FROM @UNQ_COMPANY_DATA_FOR_CONTROLCODE
					END

					INSERT INTO @UNQ_COMPANY_DATA_FOR_CONTROLCODE
					SELECT * FROM Common.ControlCode WHERE ControlCategoryId=@CONTROL_ID1

					-- DECLARING A NEW CURSOR INSIDE FOR INSERTION OF RECORDS IN CONTROLCODE TABLE

						DECLARE CONTROLCODE1_CURSOR1 CURSOR FOR SELECT ID FROM @UNQ_COMPANY_DATA_FOR_CONTROLCODE
						OPEN CONTROLCODE1_CURSOR1
						  FETCH NEXT FROM CONTROLCODE1_CURSOR1 INTO @ID_IN_CONTROLCODE1
						  WHILE (@@FETCH_STATUS=0)
						  BEGIN
							SET @NEWID_IN_CONTROLCODE1=(SELECT MAX(ID)+1 FROM Common.ControlCode)
							INSERT INTO Common.ControlCode
							SELECT @NEWID_IN_CONTROLCODE1,@NEW_CONTROL_ID1,CodeKey,CodeValue,IsSystem,RecOrder,Remarks,UserCreated,GETUTCDATE(),null,null,Version,Status,IsDefault,ModuleNamesUsing 
							FROM @UNQ_COMPANY_DATA_FOR_CONTROLCODE WHERE Id=@ID_IN_CONTROLCODE1
							FETCH NEXT FROM CONTROLCODE1_CURSOR1 INTO @ID_IN_CONTROLCODE1
							
						  END
						 -- WHILE @@FETCH_STATUS=0
						  
						CLOSE CONTROLCODE1_CURSOR1
						DEALLOCATE CONTROLCODE1_CURSOR1
					--ENDING POINT OF INSIDE CURSOR
                END
				FETCH NEXT FROM CONTROLCODE_CURSOR1 INTO @CONTROL_ID1,@CCCC,@MNU
			  End
			 -- WHILE @@FETCH_STATUS=0
			  
	CLOSE CONTROLCODE_CURSOR1
	DEALLOCATE CONTROLCODE_CURSOR1
END

/*	ENDING POINT FOR CONTROL CODE CATEGORY AND CONTROL CODE */
	---- ***/// ###Single   **SP's** ///***

	----@@@DRFinance
	if EXISTS (Select * From  Common.CompanyModule  Where ModuleId=(Select Id From Common.ModuleMaster Where Name='Dr Finance') and Status=1 and CompanyId=@NEW_COMPANY_ID)
	BEGIN
		EXEC   [dbo].[Proc_SeedDataFor_DrFinance] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID
	END

	--@@@AUDIT
		IF(@AUDIT_STATUS=1)
	BEGIN
		EXEC   [dbo].[Proc_SeedDataFor_Audit] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@isAudit=@AUDIT_STATUS
	END;

	--@@@BEAN
	IF(@BEAN_STATUS =1)
	BEGIN
	EXEC   [dbo].[Proc_SeedDataFor_Bean]
	@NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID
	END;

	--@@@BRC(BOARDROOM==CS)
	IF(@CS_STATUS =1)
	BEGIN
	EXEC   [dbo].[Proc_SeedDataFor_BRC]
	@NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID
	END;

	--@@@Client
	IF(@CLIENT_STATUS =1)
	BEGIN
	EXEC [dbo].[Proc_SeedDataFor_CC] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@isAudit=@AUDIT_STATUS
	END;

	--@@@HR 
	IF(@HR_STATUS =1)
	BEGIN
	EXEC  [dbo].[Proc_SeedDataFor_HR] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID
	END;

	--@@@TAX
	IF(@TAX_STATUS =1)
	BEGIN
	EXEC  [dbo].[Proc_SeedDataFor_Tax]  @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID
	END;

	--@@@WF
	IF(@WORKFLOW_STATUS =1)
	BEGIN
	EXEC   [dbo].[Sp_WF_SeedData]
	@NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@STATUS=1
	END;

	--@@@KB
	IF(@KNOWLEDGE_STATUS=1)
	Begin
	Exec [dbo].[ControlCodeCategoryModule_SP_New] @NEW_COMPANY_ID,5
	End

	---- ***///###Combination    **SP's**///***

	--@@HR || @@CC
	IF(@HR_STATUS =1 or @CLIENT_STATUS=1)
	BEGIN
	EXEC  [dbo].[Sp_HR_CC__SeedData]  @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@STATUS=1--Need To Clarify 
	END;

	--@@WF || @@Audit || @@Bean || @@Tax || @@Client
	IF(@WORKFLOW_STATUS=1 or @AUDIT_STATUS =1 or @BEAN_STATUS=1 or @TAX_STATUS=1 or @CLIENT_STATUS=1 )
	BEGIN
	EXEC  [dbo].[Sp_WF_Audit_Bean_Tax_Client_SeedData]  @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@STATUS=1
	END;

	--@@WF || @@Audit || @@BR || @@Bean
    IF(@WORKFLOW_STATUS=1 or @AUDIT_STATUS =1 or @BEAN_STATUS=1 or @CS_STATUS=1)
	BEGIN
	
	EXEC  [dbo].[Sp_WF_Audit_BR_Bean_SeedData]  @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID
	END;

	--@@WF || @@Audit || @@BRC
	IF(@WORKFLOW_STATUS=1 or @AUDIT_STATUS =1 or @CS_STATUS=1 )
	BEGIN
		EXEC   [dbo].[Sp_WF_Audit_BRC_SeedData] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID
	END;

	--@@WF || @@AUDIT
	--IF(@WORKFLOW_STATUS=1 or @AUDIT_STATUS =1)
	--BEGIN
	----EXEC  [dbo].[Sp_WF_Audit_SeedData]  @NEW_COMPANY_ID=@NEW_COMPANY_ID
	--END;

	--@@WF || @@Audit || @@Tax || @@Client
	IF(@WORKFLOW_STATUS=1 or @AUDIT_STATUS =1  or @TAX_STATUS=1 or   @CLIENT_STATUS=1 )
	BEGIN
	EXEC   [dbo].[Sp_WF_Audit_Tax_CC_SeedData] 
	@NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@STATUS=1

	END;

	--@@WF || @@Bean || @@BRC || @@Client
	IF(@WORKFLOW_STATUS=1 or @BEAN_STATUS =1  or @CS_STATUS=1 or   @CLIENT_STATUS=1 )
	BEGIN
	EXEC   [dbo].[Sp_WF_Bean_BR_CC_SeedData]
	@NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID,@STATUS=1
	END;

	--@@WF || @@Bean
	IF(@WORKFLOW_STATUS=1 or @BEAN_STATUS =1  )
	BEGIN
	EXEC   [dbo].[Sp_WF_Bean_SeedData]	
	@NEW_COMPANY_ID=@NEW_COMPANY_ID
	END;

		IF(@ISADD=1 )
		BEGIN
	--@@ Common For All Cursors Seed Data
	EXEC [dbo].[SP_Common_Seeddata] @NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID
	END 

	
Declare @GridMetaData_Cnt int
select 	@GridMetaData_Cnt=Count(*) from [Auth].[GridMetaData] where companyid=@NEW_COMPANY_ID	
 If @GridMetaData_Cnt =0
Begin

		-----------------------------------------GRID META DATA------------------------------------------------------------------------------------------
		INSERT INTO [Auth].[GridMetaData] (Id,ModuleDetailId, UserName, Url, GridMetaData, CompanyId, APIMethod, ActionURL, TableName, Class, Title, Params, Options, StreamName, ViewModelName,PopupOptions,ActionType)
			SELECT (NEWID()), ModuleDetailId, UserName, Url, GridMetaData, @NEW_COMPANY_ID, APIMethod, ActionURL, TableName, Class, Title, Params, Options, StreamName, ViewModelName,PopupOptions,ActionType  FROM 
			[Auth].[GridMetaData]  WHERE COMPANYID=@UNIQUE_COMPANY_ID;

			End


			------------------------------------------------AUTO NUMBER------------------------------------------------------
  Declare @AutoNumber_Cnt BIGINT;
	   select 	@AutoNumber_Cnt=Count(*) from 	[Common].[AutoNumber] where companyid=@NEW_COMPANY_ID	
	   IF @AutoNumber_Cnt=0
   Begin
            INSERT INTO [Common].[AutoNumber] (Id, CompanyId, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength,
			MaxLength, StartNumber, Reset, Preview, IsResetbySubsidary, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Variables,IsEditable,IsEditableDisable)
			SELECT (NEWID()), @NEW_COMPANY_ID, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, 
			MaxLength, StartNumber, Reset, Preview, IsResetbySubsidary, status, UserCreated, @CREATED_DATE, null, null, Variables, IsEditable,IsEditableDisable
			FROM [Common].[AutoNumber] WHERE COMPANYID=@UNIQUE_COMPANY_ID;
			
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
		
--===================== Calendar Setup migration

 if(@HR_STATUS =1 OR @WORKFLOW_STATUS=1)
 BEGIN
	--declare @NEW_COMPANY_ID bigint
	declare @Year int = 2020
	--declare @UNIQUE_COMPANY_ID bigint = 0
	BEGIN
		DECLARE Calender_Csr Cursor for SELECT Distinct a.Id from Common.Company a where ParentId is null and Jurisdiction='Singapore' and a.Id != 0 and Id=@NEW_COMPANY_ID
		Open Calender_Csr
		Fetch Next From Calender_Csr into @NEW_COMPANY_ID
		While @@FETCH_STATUS=0
		BEGIN
			Print @NEW_COMPANY_ID
			INSERT INTO Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status)
			SELECT(NEWID()),@NEW_COMPANY_ID,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status FROM Common.Calender WHERE COMPANYID=@UNIQUE_COMPANY_ID AND Name not in (select name from Common.Calender where CompanyId=@NEW_COMPANY_ID AND (convert(int,Datepart(Year,FromDateTime)) = @Year OR convert(int,Datepart(Year,ToDateTime)) = @Year)) AND Convert(Date,fromdatetime) not in (select Convert(date,FromDateTime) from Common.Calender where CompanyId=@NEW_COMPANY_ID) AND Convert(date,ToDateTime) not in (select Convert(date,ToDateTime) from Common.Calender where CompanyId=@NEW_COMPANY_ID)
  
			Fetch Next From Calender_Csr into @NEW_COMPANY_ID
		End
	END
END

  -- For InitialCursorSetup updation

 exec [dbo].[SP_InitialCursorSetup_Updation] @NEW_COMPANY_ID
	
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
