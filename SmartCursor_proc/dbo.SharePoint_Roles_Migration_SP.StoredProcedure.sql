USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SharePoint_Roles_Migration_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec SharePoint_Roles_Migration_SP 2430,Null,Null
CREATE Procedure [dbo].[SharePoint_Roles_Migration_SP]
@CompanyId BigInt,
@CursorshortCode Nvarchar(1024),-- Add Cursor Parameter If null All esle passed values (Single or comma seperated)
@Roles Nvarchar(1024)--If null All esle passed values (Single or comma seperated)
As
Begin
	 
	Declare @Journals Nvarchar(250)='Journals'
	Declare @Transfers Nvarchar(250)='Transfers'
	Declare @Withdrawals Nvarchar(250)='Withdrawals'
	Declare @Deposits Nvarchar(250)='Deposits'
	Declare @CashPayments Nvarchar(250)='Cash Payment'
	Declare @CreditMemos Nvarchar(250)='Credit Memos'
	Declare @BillPayment Nvarchar(250)='Bill Payment'
	Declare @Bills Nvarchar(250)='Bills'
	Declare @RecJournal Nvarchar(250)='Recurring Journals'
	Declare @Quotations Nvarchar(250)='Quotations'
	Declare @Opportunities Nvarchar(250)='Opportunities'
	Declare @Communication Nvarchar(250)='Communication'
	Declare @Templates Nvarchar(250)='Templates'
	Declare @Cases Nvarchar(250)='Cases'
	Declare @Invoices Nvarchar(250)='Invoices'
	Declare @Claims Nvarchar(250)='Claims'
	Declare @Qualification Nvarchar(250)='Qualification'
	Declare @Leaves Nvarchar(250)='Leave Applications'
	Declare @Payroll Nvarchar(250)='Payrolls'
	Declare @Assets Nvarchar(250)='Assets'
	Declare @Attendance Nvarchar(250)='Attendance'
	Declare @UpldAttendance Nvarchar(250)='Upload Attendance'
	Declare @Recruitment Nvarchar(250)='Recruitment'
	Declare @JobApplications Nvarchar(250)='Job Applications'
	Declare @TrainingManagement Nvarchar(250)='Training Management'
	Declare @CourseLibrary Nvarchar(250)='Course Library'
	Declare @Trainings Nvarchar(250)='Trainings'
	Declare @Vendors Nvarchar(250)='Vendors'

	--Declare @Entities Nvarchar(50)='Entities'
	Declare @Employees Nvarchar(50)='Employees'
	--Declare @Leads Nvarchar(50)='Leads'
	--Declare @Accounts Nvarchar(50)='Accounts'
	Declare @Clients Nvarchar(50)='Clients'
	Declare @BeanCursor Nvarchar(250)='Bean cursor'
	Declare @HRCursor Nvarchar(250)='HR Cursor'
	Declare @ClientCursor Nvarchar(250)='Client Cursor'
	Declare @WorkflowCursor Nvarchar(250)='Workflow Cursor'

	Declare @Bean Nvarchar(250)='Bean'
	Declare @HRC Nvarchar(250)='HRC'
	Declare @CNC Nvarchar(250)='CNC'
	Declare @WFC Nvarchar(250)='WFC'

	Declare @FolderPath_TBL Table (CompanyId Nvarchar(50),[Role] Nvarchar(520),[Cursor] Nvarchar(50),CursorShortCode Nvarchar(25),FolderPath Nvarchar(1024))

	Declare @RoleTbl table (RoleName Nvarchar(250))
	Declare @Cursor_Tbl table (CursorName Nvarchar(250))

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
	IF @CursorshortCode Is Not Null And @CursorshortCode<>''
	Begin
		Insert Into @Cursor_Tbl
		Select Ltrim(Rtrim(items)) From dbo.SplitToTable (@CursorshortCode,',')
	End
	Else
	Begin
		Insert Into @Cursor_Tbl
		Select Distinct Shortcode From Common.ModuleMaster With (NOlock) Where CompanyId=0 And IsMainCursor=1
	End

	-- Bean Cursor
	If Exists (Select CursorName From @Cursor_Tbl Where CursorName=@Bean)
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
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@BeanCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Bills,@CreditMemos,@BillPayment)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=E.CompanyId
		Group By Cast(E.CompanyId As varchar(50)),[Role],[Cursor],CursorShortCode,Concat('Entities/',[dbo].[SharePoint_Remove_SpecialCharecters](E.name),'/',Heading)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,
				Case When JSON_VALUE(PERMISSIONS,'$.ScreenName') ='Recurring Journals' Then 'Journals' 
					 When JSON_VALUE(PERMISSIONS,'$.ScreenName')=@CashPayments Then 'Cash Payments'
					 Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End As FolderPath
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@BeanCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Journals,@Transfers,@Withdrawals,@Deposits,@CashPayments,@RecJournal)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		Group By Cast(RN.CompanyId As varchar(50)),RN.Name,MM.Name,MM.ShortCode,
		Case When JSON_VALUE(PERMISSIONS,'$.ScreenName') ='Recurring Journals' Then 'Journals' 
					 When JSON_VALUE(PERMISSIONS,'$.ScreenName')=@CashPayments Then 'Cash Payments'
					 Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End
	End
	-- HR Cursor
	If Exists (Select CursorName From @Cursor_Tbl Where CursorName=@HRC)
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
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@HRCursor
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
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@HRCursor
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
			Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Claims,@Payroll,@Leaves)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Group By Cast(Emp.CompanyId As varchar(50)) ,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',Heading)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,
				Case When JSON_VALUE(PERMISSIONS,'$.ScreenName') ='Job Applications' Then 'Recruitment' Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End As FolderPath
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@HRCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Recruitment,@JobApplications)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		Group By Cast(RN.CompanyId As varchar(50)),RN.Name,MM.Name,MM.ShortCode,
		Case When JSON_VALUE(PERMISSIONS,'$.ScreenName') ='Job Applications' Then 'Recruitment' Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End
	
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,
				Concat(@TrainingManagement,'/',JSON_VALUE(PERMISSIONS,'$.ScreenName')) As FolderPath
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@HRCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Trainings,@CourseLibrary)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		Group By Cast(RN.CompanyId As varchar(50)),RN.Name,MM.Name,MM.ShortCode,Concat(@TrainingManagement,'/',JSON_VALUE(PERMISSIONS,'$.ScreenName'))

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,
				@Attendance As FolderPath
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@HRCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@UpldAttendance,@Attendance)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		Group By Cast(RN.CompanyId As varchar(50)),RN.Name,MM.Name,MM.ShortCode
	End
	-- Client Cursor
	If Exists (Select CursorName From @Cursor_Tbl Where CursorName=@CNC)
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
		Group By Cast(AC.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Leads & Accounts/',[dbo].[SharePoint_Remove_SpecialCharecters](AC.name),'/',Heading)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)

		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,
				 JSON_VALUE(PERMISSIONS,'$.ScreenName') As FolderPath
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name in (Select RoleName From @RoleTbl) And MM.Name=@ClientCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (@Vendors)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		Group By Cast(RN.CompanyId As varchar(50)),RN.Name,MM.Name,MM.ShortCode,
				JSON_VALUE(PERMISSIONS,'$.ScreenName')	
	End
	-- WorkFlow Cursor	
	If Exists (Select CursorName From @Cursor_Tbl Where CursorName=@WFC)
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
		Group by Cast(C.CompanyId As varchar(50)),CS.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(C.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases,'/',CaseNumber,'/',Heading) As FolderPath
		From WorkFlow.Client As C With (NOlock)
		Inner Join
		(
			Select INVCLM.[Role],INVCLM.CompanyId,INVCLM.Heading,CS.CaseNumber,CS.ClientId,INVCLM.CursorShortCode,INVCLM.[Cursor] From
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
			) As CS 
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
				And CS.[Cursor]=INVCLM.[Cursor]
			GRoup By INVCLM.[Role],INVCLM.CompanyId,INVCLM.Heading,CS.CaseNumber,CS.ClientId,INVCLM.CursorShortCode,INVCLM.[Cursor]
		) As Roledata On Roledata.CompanyId=C.CompanyId And C.Id=Roledata.ClientId

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
		Select Cast(C.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases,'/',CaseNumber,'/',Heading) As FolderPath
		From WorkFlow.Client As C With (NOlock)
		Inner Join
		(
			Select INVCLM.[Role],INVCLM.CompanyId,INVCLM.Heading,CS.CaseNumber,CS.ClientId,INVCLM.CursorShortCode,INVCLM.[Cursor] From
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
			) As CS 
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
				And CS.[Cursor]=INVCLM.[Cursor]
			GRoup By INVCLM.[Role],INVCLM.CompanyId,INVCLM.Heading,CS.CaseNumber,CS.ClientId,INVCLM.CursorShortCode,INVCLM.[Cursor]
		) As Roledata On Roledata.CompanyId=C.CompanyId And C.Id=Roledata.ClientId
	End
	Select Case When Len(CompanyId)<3 Then RIGHT('00'+Cast(CompanyId As varchar(50)),3) Else Cast(CompanyId As varchar(50)) End As CompanyId,[Role],[Cursor],CursorShortCode,FolderPath 
	From @FolderPath_TBL 
	Order by [Cursor],FolderPath
End



GO
