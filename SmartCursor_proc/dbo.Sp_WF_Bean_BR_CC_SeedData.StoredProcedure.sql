USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_WF_Bean_BR_CC_SeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Sp_WF_Bean_BR_CC_SeedData](@NEW_COMPANY_ID BIGINT,@UNIQUE_COMPANY_ID BIGINT,@STATUS BIGINT)
As
Begin
DECLARE @CREATED_DATE DATETIME	
SET @CREATED_DATE =GETUTCDATE()
 ------------------------------------------------AUTO NUMBER------------------------------------------------------
  Declare @AutoNumber_Cnt BIGINT;
	   select 	@AutoNumber_Cnt=Count(*) from 	[Common].[AutoNumber] where companyid=@NEW_COMPANY_ID	
	   IF @AutoNumber_Cnt=0
   Begin
            INSERT INTO [Common].[AutoNumber] (Id, CompanyId, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength,
			MaxLength, StartNumber, Reset, Preview, IsResetbySubsidary, Status, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Variables,IsEditable,IsEditableDisable)
			SELECT (NEWID()), @NEW_COMPANY_ID, ModuleMasterId, EntityType, Description, Format, GeneratedNumber, CounterLength, 
			MaxLength, StartNumber, Reset, Preview, IsResetbySubsidary, status, UserCreated, @CREATED_DATE, null, null, Variables,IsEditable,IsEditableDisable 
			FROM [Common].[AutoNumber] WHERE COMPANYID=@UNIQUE_COMPANY_ID;
			end
			End
GO
