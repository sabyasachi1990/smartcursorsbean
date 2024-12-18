USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_WF_Audit_BR_Bean_SeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 CREATE Procedure [dbo].[Sp_WF_Audit_BR_Bean_SeedData](@NEW_COMPANY_ID BIGINT,@UNIQUE_COMPANY_ID BIGINT)
As
Declare @GridMetaData_Cnt int
select 	@GridMetaData_Cnt=Count(*) from [Auth].[GridMetaData] where companyid=@NEW_COMPANY_ID	
 If @GridMetaData_Cnt =0
Begin

		-----------------------------------------GRID META DATA------------------------------------------------------------------------------------------
		INSERT INTO [Auth].[GridMetaData] (Id,ModuleDetailId, UserName, Url, GridMetaData, CompanyId, APIMethod, ActionURL, TableName, Class, Title, Params, Options, StreamName, ViewModelName,PopupOptions,ActionType)
			SELECT (NEWID()), ModuleDetailId, UserName, Url, GridMetaData, @NEW_COMPANY_ID, APIMethod, ActionURL, TableName, Class, Title, Params, Options, StreamName, ViewModelName,PopupOptions,ActionType  FROM 
			[Auth].[GridMetaData]  WHERE COMPANYID=@UNIQUE_COMPANY_ID;

			End
GO
