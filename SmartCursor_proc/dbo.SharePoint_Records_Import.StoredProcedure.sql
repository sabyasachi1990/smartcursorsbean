USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SharePoint_Records_Import]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec dbo.[SharePoint_Records_Import] 2430,'Entity,Client,Employee,Lead & Account'
CREATE Procedure [dbo].[SharePoint_Records_Import]
@CompanyId Bigint,
@RecordType Nvarchar(256)--Entity,Client,Employee,Lead & Account
As 
Begin
	Declare @CreditMemos Nvarchar(250)='Credit Memos'
	Declare @BillPayment Nvarchar(250)='Bill Payment'
	Declare @Bills Nvarchar(250)='Bills'
	Declare @Quotations Nvarchar(250)='Quotations'
	Declare @Opportunities Nvarchar(250)='Opportunities'
	Declare @Communication Nvarchar(250)='Communication'
	Declare @Templates Nvarchar(250)='Templates'
	Declare @Cases Nvarchar(250)='Cases'
	Declare @Qualification Nvarchar(250)='Qualification'
	Declare @Leaves Nvarchar(250)='Leave Applications'
	Declare @Payroll Nvarchar(250)='Payrolls'
	Declare @Assets Nvarchar(250)='Assets'
	Declare @Claims Nvarchar(50)='Claims'

	--Declare @Entities Nvarchar(50)='Entities'
	--Declare @Leads Nvarchar(50)='Leads'
	--Declare @Accounts Nvarchar(50)='Accounts'
	Declare @Employees Nvarchar(50)='Employees'
	Declare @Clients Nvarchar(50)='Clients'
	Declare @BeanCursor Nvarchar(250)='Bean cursor'
	Declare @HRCursor Nvarchar(250)='HR Cursor'
	Declare @ClientCursor Nvarchar(250)='Client Cursor'
	Declare @WorkflowCursor Nvarchar(250)='Workflow Cursor'	

	Declare @FolderPath_TBL Table (CompanyId Nvarchar(50),[Role] Nvarchar(520),[Cursor] Nvarchar(50),CursorShortCode Nvarchar(25),FolderPath Nvarchar(1024))
	Declare @RecordType_Tbl table (RecordType Nvarchar(250))

	Insert Into @RecordType_Tbl
	Select Ltrim(Rtrim(items)) From dbo.SplitToTable (@RecordType,',')
	
	IF Exists (Select RecordType From @RecordType_Tbl Where RecordType='Entity')
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(E.CompanyId As varchar(50))  As CompanyId,[Role],[Cursor],CursorShortCode,Concat('Entities/',[dbo].[SharePoint_Remove_SpecialCharecters](E.name),'/',Heading) As FolderPath
		From Bean.Entity As E With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,Case When JSON_VALUE(PERMISSIONS,'$.ScreenName')=@BillPayment Then 'Bill Payments' Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And MM.Name=@BeanCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Bills,@CreditMemos,@BillPayment)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=E.CompanyId
		Group By Cast(E.CompanyId As varchar(50)),[Role],[Cursor],CursorShortCode,Concat('Entities/',[dbo].[SharePoint_Remove_SpecialCharecters](E.name),'/',Heading)
	End
	IF Exists (Select RecordType From @RecordType_Tbl Where RecordType='Lead & Account')
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(AC.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Leads & Accounts/',[dbo].[SharePoint_Remove_SpecialCharecters](AC.name),'/',Heading) As FolderPath
		From ClientCursor.Account As AC With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And MM.Name=@ClientCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Opportunities,@Quotations)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=AC.CompanyId
		Group By Cast(AC.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Leads & Accounts/',[dbo].[SharePoint_Remove_SpecialCharecters](AC.name),'/',Heading)
	End
	IF Exists (Select RecordType From @RecordType_Tbl Where RecordType='Client')
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(C.CompanyId As varchar(50)) As CompanyId,CS.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases) As FolderPath
		From WorkFlow.Client As C With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And MM.Name=@WorkflowCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName')=@Cases
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		) As CS On CS.CompanyId=C.CompanyId
		Group by Cast(C.CompanyId As varchar(50)),CS.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases)
	End
	IF Exists (Select RecordType From @RecordType_Tbl Where RecordType='Employee')
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(Emp.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Assets) As FolderPath
		From Common.Employee As Emp With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') =@Employees
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Group By Cast(Emp.CompanyId As varchar(50)) ,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Assets)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(Emp.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Qualification) As FolderPath
		From Common.Employee As Emp With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') =@Employees
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Group By Cast(Emp.CompanyId As varchar(50)) ,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Qualification)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(Emp.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',Heading) As FolderPath
		From Common.Employee As Emp With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,Case When JSON_VALUE(PERMISSIONS,'$.ScreenName')=@Leaves Then 'Leaves'
														When JSON_VALUE(PERMISSIONS,'$.ScreenName')=@Payroll Then 'Payroll'
														Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Claims,@Payroll,@Leaves)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Group By Cast(Emp.CompanyId As varchar(50)) ,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',Heading)
	End
	Select Case When Len(CompanyId)<3 Then RIGHT('00'+Cast(CompanyId As varchar(50)),3) Else Cast(CompanyId As varchar(50)) End As CompanyId,[Role],[Cursor],CursorShortCode,FolderPath 
	From @FolderPath_TBL 
	Order by [Cursor],FolderPath
End

GO
