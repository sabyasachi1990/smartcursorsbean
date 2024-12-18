USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SharePoint_Migration_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create   Procedure [dbo].[SharePoint_Migration_SP] 
@CompanyId BigInt,
@UserEmail Nvarchar(1024) -- If null All esle passed values (Single or comma seperated)
As
Begin
	Declare @CreditMemos Nvarchar(250)='Credit Memos'
	Declare @BillPayment Nvarchar(250)='Bill Payment'
	Declare @Bills Nvarchar(250)='Bills'
	Declare @BeanCursor Nvarchar(250)='Bean cursor'
	IF @UserEmail Is Not Null
	Begin
		--IF Exists (Select UPN.Id
		--			From Auth.UserPermissionNew As UPN
		--			Inner Join Common.CompanyUser As CU On CU.Id=UPN.CompanyUserId
		--			Inner Join Common.ModuleDetail As MD On Md.Id=UPN.ModuleDetailId
		--			Inner Join Common.ModuleMaster As MM On Mm.Id=MD.ModuleMasterId
		--			Where CU.CompanyId=@CompanyId And CU.Email=@UserEmail And MM.Name=@BeanCursor
		--				And JSON_VALUE(PERMISSIONS,'$.ScreenName')=@CreditMemos
		--				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
		--				--And JSon_Value(JSON_QUERY(Permissions,'$.Tabs[0].Actions[0]'),'$.Heading')='View'
		--				--And JSon_Value(JSON_QUERY(Permissions,'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
		--				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		--			)
		--Begin
			Select E.Name As EntityName,CU.Email,UPN.ModuleDetailId,MM.ShortCode As ModuleShortCode,MM.Name As ModuleName,UPN.Permissions,CU.CompanyId --Pading 3
			From Auth.UserPermissionNew As UPN
			Inner Join Common.CompanyUser As CU On CU.Id=UPN.CompanyUserId
			Inner Join Common.ModuleDetail As MD On Md.Id=UPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM On Mm.Id=MD.ModuleMasterId
			Inner Join Bean.Entity As E On E.CompanyId=CU.CompanyId
			Where CU.CompanyId=@CompanyId And CU.Email=@UserEmail And MM.Name=@BeanCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@CreditMemos,@BillPayment,@Bills)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				--And JSon_Value(JSON_QUERY(Permissions,'$.Tabs[0].Actions[0]'),'$.Heading')='View'
				--And JSon_Value(JSON_QUERY(Permissions,'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		--End
	End
	Else
	Begin
		--IF Exists (Select UPN.Id
		--			From Auth.UserPermissionNew As UPN
		--			Inner Join Common.CompanyUser As CU On CU.Id=UPN.CompanyUserId
		--			Inner Join Common.ModuleDetail As MD On Md.Id=UPN.ModuleDetailId
		--			Inner Join Common.ModuleMaster As MM On Mm.Id=MD.ModuleMasterId
		--			Where CU.CompanyId=@CompanyId And MM.Name=@BeanCursor
		--				And JSON_VALUE(PERMISSIONS,'$.ScreenName')=@CreditMemos
		--				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
		--				--And JSon_Value(JSON_QUERY(Permissions,'$.Tabs[0].Actions[0]'),'$.Heading')='View'
		--				--And JSon_Value(JSON_QUERY(Permissions,'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
		--				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		--			)
		--Begin
			Select E.Name As EntityName,CU.Email,UPN.ModuleDetailId,MM.ShortCode As ModuleShortCode,MM.Name As ModuleName,UPN.Permissions,CU.CompanyId --Pading 3
			From Auth.UserPermissionNew As UPN
			Inner Join Common.CompanyUser As CU On CU.Id=UPN.CompanyUserId
			Inner Join Common.ModuleDetail As MD On Md.Id=UPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM On Mm.Id=MD.ModuleMasterId
			Inner Join Bean.Entity As E On E.CompanyId=CU.CompanyId
			Where CU.CompanyId=@CompanyId And MM.Name=@BeanCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@CreditMemos,@BillPayment,@Bills)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				--And JSon_Value(JSON_QUERY(Permissions,'$.Tabs[0].Actions[0]'),'$.Heading')='View'
				--And JSon_Value(JSON_QUERY(Permissions,'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		--End
	End
End
GO
