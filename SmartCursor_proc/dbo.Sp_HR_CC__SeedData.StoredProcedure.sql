USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_HR_CC__SeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Sp_HR_CC__SeedData](@NEW_COMPANY_ID BIGINT,@UNIQUE_COMPANY_ID BIGINT,@STATUS BIGINT)
As
Begin
  
  Declare @Template_Cnt bigint;
  select 	@Template_Cnt=Count(*) 
  from 	[Common].[Template] where companyid=@NEW_COMPANY_ID	
	IF @Template_Cnt=0
	Begin


           INSERT INTO [Common].[Template] (Id, Name, Code, CompanyId, FromEmailId, CCEmailIds, BCCEmailIds, TemplateType, TempletContent, RecOrder,
			Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, Subject, TemplateMenu, ToEmailId, IsUnique,CursorName)		    
			SELECT (NEWID()), Name, Code, @NEW_COMPANY_ID, FromEmailId, CCEmailIds, BCCEmailIds, TemplateType, TempletContent, RecOrder,
			Remarks, UserCreated, GETUTCDATE(), null, null, Version, status, Subject, TemplateMenu, ToEmailId, IsUnique,CursorName
			FROM [Common].[Template] WHERE COMPANYID=@UNIQUE_COMPANY_ID AND IsUnique=@STATUS;

			End
			End
GO
