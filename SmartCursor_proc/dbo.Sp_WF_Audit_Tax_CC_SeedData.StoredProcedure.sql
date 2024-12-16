USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_WF_Audit_Tax_CC_SeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--[Common].[IdType]  WF ,Audit,Tax,CC
CREATE Procedure [dbo].[Sp_WF_Audit_Tax_CC_SeedData](@NEW_COMPANY_ID BIGINT,@UNIQUE_COMPANY_ID BIGINT,@STATUS BIGINT)
As
Begin
DECLARE @CREATED_DATE DATETIME	
SET @CREATED_DATE =GETUTCDATE()


	-------------------------------------------ID TYPE------------------------------------------------------------------------------------------
	--	UPDATE [Common].[IdType] SET[TempIdTypeId] = NULL;
	    	
		
	--	--ALTER TABLE [Common].[IdType] ADD [TempIdTypeId] BIGINT NULL;

	--Declare @IdType_Cnt bigint;
	--select 	@IdType_Cnt=Count (*)from 	[Common].[IdType] where companyid=@NEW_COMPANY_ID	
	--IF @IdType_Cnt=0
	--Begin
		
 --       INSERT INTO [Common].[IdType] (Id, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,TempIdTypeId) 
	--		SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Common].[IdType]), Name, @NEW_COMPANY_ID, RecOrder, Remarks,
	--		UserCreated, @CREATED_DATE, ModifiedBy, ModifiedDate, Version, status, Id FROM [Common].[IdType] WHERE COMPANYID=@UNIQUE_COMPANY_ID;
	--		UPDATE [Common].[IdType] SET[TempIdTypeId] = NULL WHERE COMPANYID = @NEW_COMPANY_ID
	--		END
	--		------------------------------------------------------------------------
	--	UPDATE [Common].[AccountType] SET [TempAccountTypeId] = NULL;
	--	--ALTER TABLE [Common].[AccountType] ADD [TempAccountTypeId] BIGINT NULL;
	--Declare @AccountType_Cnt bigint;
	--select 	@AccountType_Cnt=Count (*)from 	[Common].[AccountType] where companyid=@NEW_COMPANY_ID	
	--IF @AccountType_Cnt=0
	--Begin

	--	INSERT INTO [Common].[AccountType] (Id, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,TempAccountTypeId)
	--		SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) + @STATUS FROM [Common].[AccountType]), Name, @NEW_COMPANY_ID, RecOrder, Remarks, UserCreated,
	--		@CREATED_DATE, ModifiedBy, ModifiedDate, Version, status,Id FROM [Common].[AccountType]  WHERE COMPANYID=@UNIQUE_COMPANY_ID;

	--		UPDATE [Common].[AccountType] SET [TempAccountTypeId] = NULL WHERE COMPANYID = @NEW_COMPANY_ID--Need Clarification 
	--		End
    END
			
GO
