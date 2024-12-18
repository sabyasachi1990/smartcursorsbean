USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SharePoint_Roles_NewRecord_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec [SharePoint_Roles_NewRecord_SP] 10,Null,'E93685F8-89DA-8D6F-B592-3D2E1E9D0466','Account',null
CREATE Procedure [dbo].[SharePoint_Roles_NewRecord_SP]
@CompanyId BigInt,
@Roles Nvarchar(1024),--If null All esle passed values (Single or comma seperated)
@RecordId Uniqueidentifier,
@RecordType Nvarchar(50), -- Lead,Account,Client,Entity,Employee,Cases
@Sync Int 
As
Begin
	 
	Declare @CreditMemos Nvarchar(50)='Credit Memos'
	Declare @BillPayment Nvarchar(50)='Bill Payment'
	Declare @Bills Nvarchar(50)='Bills'
	Declare @Quotations Nvarchar(124)='Quotations'
	Declare @Qualification Nvarchar(124)='Qualification'
	Declare @Assets Nvarchar(50)='Assets'
	Declare @Opportunities Nvarchar(124)='Opportunities'
	Declare @Cases Nvarchar(50)='Cases'
	Declare @Invoices Nvarchar(50)='Invoices'
	Declare @Claims Nvarchar(50)='Claims'
	Declare @Leaves Nvarchar(124)='Leave Applications'
	Declare @Payroll Nvarchar(50)='Payrolls'
	Declare @Entities Nvarchar(50)='Entities'
	Declare @Employees Nvarchar(50)='Employees'
	Declare @Leads Nvarchar(50)='Leads'
	Declare @Accounts Nvarchar(50)='Accounts'
	Declare @Clients Nvarchar(50)='Clients'
	Declare @SyncEntityId Uniqueidentifier
	Declare @SyncClientId Uniqueidentifier
	Declare @SyncAccountId Uniqueidentifier

	Declare @BeanCursor Nvarchar(124)='Bean cursor'
	Declare @HRCursor Nvarchar(124)='HR Cursor'
	Declare @ClientCursor Nvarchar(124)='Client Cursor'
	Declare @WorkflowCursor Nvarchar(124)='Workflow Cursor'

	Declare @FolderPath_TBL Table (CompanyId Nvarchar(50),[Role] Nvarchar(520),[Cursor] Nvarchar(50),CursorShortCode Nvarchar(25),FolderPath Nvarchar(1024))
	Declare @SyncFolderPath_Tbl Table (CompanyId Nvarchar(50),[Role] Nvarchar(520),[Cursor] Nvarchar(50),CursorShortCode Nvarchar(25),FolderPath Nvarchar(1024))

	Declare @RoleTbl table (RoleName Nvarchar(250))
	IF @Roles Is Not Null And @Roles<>''
	Begin
		Insert Into @RoleTbl
		Select Ltrim(Rtrim(items)) From dbo.SplitToTable (@Roles,',')
	End
	Else
	Begin
		Insert Into @RoleTbl
		Select Distinct Name From Auth.RoleNew With (NOlock) Where CompanyId=@CompanyId
	End
	
	-- Bean Cursor
	IF @RecordType='Entity'
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(E.CompanyId As varchar(50))  As CompanyId,[Role],[Cursor],CursorShortCode,Concat('Entities/',[dbo].[SharePoint_Remove_SpecialCharecters](E.name),'/',Heading) As FolderPath
		From Bean.Entity As E With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,Case When JSON_VALUE(PERMISSIONS,'$.ScreenName')=@BillPayment Then 'Bill Payments' 
			 Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@BeanCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Bills,@CreditMemos,@BillPayment)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=E.CompanyId
		Where E.Id=@RecordId
		Group By Cast(E.CompanyId As varchar(50)),[Role],[Cursor],CursorShortCode,Concat('Entities/',[dbo].[SharePoint_Remove_SpecialCharecters](E.name),'/',Heading)
	End
	-- HR Cursor
	Else IF @RecordType='Employee'
	Begin
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
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Claims,@Payroll,@Leaves)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Where Emp.Id=@RecordId
		Group By Cast(Emp.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',Heading)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(Emp.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Qualification) As FolderPath
		From Common.Employee As Emp With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') = @Employees
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Where Emp.Id=@RecordId
		Group By Cast(Emp.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Qualification)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(Emp.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Assets) As FolderPath
		From Common.Employee As Emp With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') = @Employees
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Where Emp.Id=@RecordId
		Group By Cast(Emp.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Assets)

	End	
	-- Client Cursor
	Else IF @RecordType='Lead'
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
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@ClientCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Opportunities,@Quotations)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=AC.CompanyId
		Where AC.Id=@RecordId And IsAccount=0
		Group By Cast(AC.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Leads & Accounts/',[dbo].[SharePoint_Remove_SpecialCharecters](AC.name),'/',Heading)
	End	
	Else IF @RecordType='Account'
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
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@ClientCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Opportunities,@Quotations)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=AC.CompanyId
		Where AC.Id=@RecordId And Ac.IsAccount=1
		Group By Cast(AC.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Leads & Accounts/',[dbo].[SharePoint_Remove_SpecialCharecters](AC.name),'/',Heading)
	End
	-- WorkFlow Cursor	
	Else IF @RecordType='Client'
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
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@WorkflowCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName')=@Cases
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		) As CS On CS.CompanyId=C.CompanyId
		Where C.Id=@RecordId
		Group by Cast(C.CompanyId As varchar(50)),CS.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases)
	End
	Else IF @RecordType=@Cases
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
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@WorkflowCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName')=@Cases
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		) As CS On CS.CompanyId=C.CompanyId
		Where C.Id=@RecordId
		Group by Cast(C.CompanyId As varchar(50)),CS.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(C.CompanyId As varchar(50)) As CompanyId,CS.[Role],INVCLM.[Cursor],INVCLM.CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases,'/',CS.CaseNumber,'/',INVCLM.Heading) As FolderPath
		From WorkFlow.Client As C With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,CG.CaseNumber,CG.ClientId
				,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Inner Join WorkFlow.CaseGroup As CG With (NOlock) On CG.CompanyId=MD.CompanyId
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@WorkflowCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') = @Cases
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
			Group By RN.Name,RN.CompanyId,CG.ClientId,CG.CaseNumber,CG.ClientId,MM.ShortCode,MM.Name
		) As CS On CS.CompanyId=C.CompanyId
		Inner Join
			(
				Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
						,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
				From Auth.RolePermissionsNew As RPN With (NOlock)
				Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
				Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
				Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
				Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@WorkflowCursor
					And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Invoices)
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
			) As INVCLM On CS.CompanyId=INVCLM.CompanyId And CS.[Role]=INVCLM.[Role] And CS.CursorShortCode=INVCLM.CursorShortCode
			Where C.Id=@RecordId
		Group by Cast(C.CompanyId As varchar(50)),CS.[Role],INVCLM.[Cursor],INVCLM.CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases,'/',CS.CaseNumber,'/',INVCLM.Heading)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(C.CompanyId As varchar(50)) As CompanyId,CS.[Role],INVCLM.[Cursor],INVCLM.CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases,'/',CS.CaseNumber,'/',INVCLM.Heading) As FolderPath
		From WorkFlow.Client As C With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,CG.CaseNumber,CG.ClientId
				,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Inner Join WorkFlow.CaseGroup As CG With (NOlock) On CG.CompanyId=MD.CompanyId
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@WorkflowCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') = @Cases
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
			Group By RN.Name,RN.CompanyId,CG.ClientId,CG.CaseNumber,CG.ClientId,MM.ShortCode,MM.Name
		) As CS On CS.CompanyId=C.CompanyId
		Inner Join
			(
				Select RN.Name As [Role],RN.CompanyId,@Claims As Heading
						,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
				From Auth.RolePermissionsNew As RPN With (NOlock)
				Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
				Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
				Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
				Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@WorkflowCursor
					And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Invoices)
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
			) As INVCLM On CS.CompanyId=INVCLM.CompanyId And CS.[Role]=INVCLM.[Role] And CS.CursorShortCode=INVCLM.CursorShortCode
			Where C.Id=@RecordId
		Group by Cast(C.CompanyId As varchar(50)),CS.[Role],INVCLM.[Cursor],INVCLM.CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases,'/',CS.CaseNumber,'/',INVCLM.Heading)

	End
		
	IF @RecordType='Employee' And @Sync Is Null
	Begin
		Set @SyncEntityId=(Select SyncEntityId From Common.Employee Where Id=@RecordId)
		IF @SyncEntityId Is Not Null
		Begin
			Insert Into @SyncFolderPath_Tbl
			Exec [SharePoint_Roles_NewRecord_SP] @companyid,@Roles,@SyncEntityId,'Entity',1
		End
	End
	Else IF @RecordType='Client' And @Sync Is Null
	Begin
		Set @SyncEntityId=(Select SyncEntityId From WorkFlow.Client Where Id=@RecordId)
		IF @SyncEntityId Is Not Null
		Begin
			Insert Into @SyncFolderPath_Tbl
			Exec [SharePoint_Roles_NewRecord_SP] @CompanyId,@Roles,@SyncEntityId,'Entity',1
		End
	End
	Else IF @RecordType='Account' And @Sync Is Null
	Begin
		Set @SyncClientId=(Select SyncClientId From ClientCursor.Account Where Id=@RecordId)
		IF @SyncClientId Is Not Null
		Begin
			Insert Into @SyncFolderPath_Tbl
			Exec [SharePoint_Roles_NewRecord_SP] @CompanyId,@Roles,@SyncClientId,'Client',1
		End
		Set @SyncEntityId=(Select SyncEntityId From ClientCursor.Account Where Id=@RecordId)
		IF @SyncEntityId Is Not Null
		Begin
			Insert Into @SyncFolderPath_Tbl
			Exec [SharePoint_Roles_NewRecord_SP] @CompanyId,@Roles,@SyncEntityId,'Entity',1
		End
	End

	Select CompanyId,[Role],[Cursor],CursorShortCode,FolderPath From 
	(
		Select Case When Len(CompanyId)<3 Then RIGHT('00'+Cast(CompanyId As varchar(50)),3) Else Cast(CompanyId As varchar(50)) End As CompanyId,[Role],[Cursor],CursorShortCode,FolderPath 
		From @FolderPath_TBL 

		Union All

		Select CompanyId,[Role],[Cursor],CursorShortCode,FolderPath From @SyncFolderPath_Tbl
	) As A
	Order by [Cursor],FolderPath

End
	
	



GO
