USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SharePoint_Role_Change_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec [dbo].[SharePoint_Role_Change_SP] 2430,'Bean','Bean Pavan','Bills:Remove,Bill Payments:Remove,Cash Payments:Remove'
CREATE Procedure [dbo].[SharePoint_Role_Change_SP]
@CompanyId BigInt,
@CursorShortCode Nvarchar(64),
@Role Nvarchar(64),
@ScreenNames Nvarchar(1024)-- ('ScreenName:Action,ScreenName:Action,ScreenName:Action') Action=Add/Remove
As
Begin
	--Cursor Names
	Declare @BeanCursor Nvarchar(250)='Bean cursor'
	Declare @HRCursor Nvarchar(250)='HR Cursor'
	Declare @ClientCursor Nvarchar(250)='Client Cursor'
	Declare @WorkflowCursor Nvarchar(250)='Workflow Cursor'
	Declare @WFC Nvarchar(64)='WFC'
	Declare @Bean Nvarchar(64)='Bean'
	Declare @HRC Nvarchar(64)='HRC'
	Declare @CNC Nvarchar(64)='CNC'

	-- Variables
	--Declare @Entities Nvarchar(50)='Entities'
	Declare @Employees Nvarchar(50)='Employees'
	--Declare @Leads Nvarchar(50)='Leads'
	--Declare @Accounts Nvarchar(50)='Accounts'
	Declare @Clients Nvarchar(50)='Clients'
	Declare @Cases Nvarchar(25)='Cases'
	Declare @Assets Nvarchar(50)='Assets'

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
	Declare @Invoices Nvarchar(250)='Invoices'
	Declare @Claims Nvarchar(250)='Claims'
	Declare @Qualification Nvarchar(250)='Qualification'
	Declare @Leaves Nvarchar(250)='Leave Applications'
	Declare @Payroll Nvarchar(250)='Payroll'
	Declare @Attendance Nvarchar(250)='Attendance'
	Declare @UpldAttendance Nvarchar(250)='Upload Attendance'
	Declare @Recruitment Nvarchar(250)='Recruitment'
	Declare @JobApplications Nvarchar(250)='Job Applications'
	Declare @TrainingManagement Nvarchar(250)='Training Management'
	Declare @CourseLibrary Nvarchar(250)='Course Library'
	Declare @Trainings Nvarchar(250)='Trainings'
	Declare @Vendors Nvarchar(250)='Vendors'

	Declare @Count Int
	Declare @RecCount Int
	Declare @ScreenNameAction Nvarchar(250)
	Declare @ScreenName Nvarchar(250)
	Declare @Action Nvarchar(50)
	Declare @Split_CSRName Nvarchar(250)
	Declare @CSR_CNT Int
	Declare @Add Nvarchar(20)='Add'
	Declare @Remove Nvarchar(20)='Remove'
	-- Temp Tables
	Declare @FolderPath_TBL Table (CompanyId Nvarchar(50),[Role] Nvarchar(520),[Cursor] Nvarchar(50),CursorShortCode Nvarchar(25),FolderPath Nvarchar(1024),[Action] Nvarchar(50))
	Declare @ScreenNames_TBL1 Table (S_No Int Identity(1,1),ScreenNameAction Nvarchar(250))
	Declare @ScreenNames_TBL2 Table (ScreenName Nvarchar(250),[Action] Nvarchar(250))
	IF OBJECT_ID('tempdb..#SplitScreen_Action') IS NULL
	Begin
		Create Table #SplitScreen_Action (S_No Int Identity(1,1),ScreenName Nvarchar(250))
	End
	
	Insert Into @ScreenNames_TBL1
	Select Ltrim(Rtrim(items)) From dbo.SplitToTable (@ScreenNames,',')

	Set @Count=(Select Count(*) From @ScreenNames_TBL1)
	Set @RecCount=1
	While @Count>=@RecCount
	Begin
		Set @ScreenNameAction=(Select ScreenNameAction From @ScreenNames_TBL1 Where S_No=@RecCount)
		Truncate Table #SplitScreen_Action
		Insert Into #SplitScreen_Action
		Select Ltrim(Rtrim(items)) From dbo.SplitToTable(@ScreenNameAction,':')
		Set @ScreenName=(Select Case When ScreenName='Bill Payments' Then 'Bill Payment'
									 When ScreenName='Cash Payments' Then 'Cash Payment'
									 Else ScreenName End From #SplitScreen_Action Where S_No=1)
		Set @Action=(Select ScreenName From #SplitScreen_Action Where S_No=2)
		Insert Into @ScreenNames_TBL2
			Values(@ScreenName,@Action)
		Set @RecCount=@RecCount+1
	End
	-- Bean Cursor
	IF @CursorShortCode=@Bean
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(E.CompanyId As varchar(50))  As CompanyId,[Role],[Cursor],CursorShortCode,Concat('Entities/',[dbo].[SharePoint_Remove_SpecialCharecters](E.name),'/',Heading) As FolderPath,'Add' As Action
		From Bean.Entity As E With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,Case When JSON_VALUE(PERMISSIONS,'$.ScreenName')=@BillPayment Then 'Bill Payments' Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End  As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@BeanCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName In (@BillPayment,@Bills,@CreditMemos) And [Action]=@Add)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=E.CompanyId
		Group By Cast(E.CompanyId As varchar(50)),[Role],[Cursor],CursorShortCode,Concat('Entities/',[dbo].[SharePoint_Remove_SpecialCharecters](E.name),'/',Heading)
	
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,
		Case When JSON_VALUE(PERMISSIONS,'$.ScreenName')=@CashPayments Then 'Cash Payments'
			 When JSON_VALUE(PERMISSIONS,'$.ScreenName') ='Recurring Journals' Then 'Journals'  
			 Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End  As Heading,'Add' As [Action]
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@BeanCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName Not In (@BillPayment,@Bills,@CreditMemos) And [Action]=@Add)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		Group by Cast(RN.CompanyId As varchar(50)),RN.Name,MM.ShortCode,MM.Name,Case When JSON_VALUE(PERMISSIONS,'$.ScreenName')=@CashPayments Then 'Cash Payments'
			 When JSON_VALUE(PERMISSIONS,'$.ScreenName') ='Recurring Journals' Then 'Journals'  
			 Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End
	End
	-- HR Cursor
	Else IF @CursorShortCode=@HRC
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(Emp.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Qualification) As FolderPath,'Add' As [Action]
		From Common.Employee As Emp
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') =(Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName=@Employees And [Action]=@Add)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Group By Cast(Emp.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Qualification)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(Emp.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Assets) As FolderPath,'Add' As [Action]
		From Common.Employee As Emp With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') =(Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName=@Employees And [Action]=@Add)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Group By Cast(Emp.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Assets)
		
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(Emp.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',Heading) As FolderPath,'Add' As [Action]
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
			Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName In (@Claims,@Payroll,@Leaves)  And [Action]=@Add)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Group By Cast(Emp.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',Heading)
		
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,Case When JSON_VALUE(PERMISSIONS,'$.ScreenName') ='Job Applications' Then 'Recruitment' Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End As Heading,'Add'
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@HRCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName In (@Recruitment,@JobApplications)  And [Action]=@Add)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		Group by Cast(RN.CompanyId As varchar(50)),RN.Name,MM.ShortCode,MM.Name,Case When JSON_VALUE(PERMISSIONS,'$.ScreenName') ='Job Applications' Then 'Recruitment' Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,
				Concat(@TrainingManagement,'/',JSON_VALUE(PERMISSIONS,'$.ScreenName')) As FolderPath,'Add'
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name=@Role And MM.Name=@HRCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName In (@Trainings,@Claims)  And [Action]=@Add)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		Group By Cast(RN.CompanyId As varchar(50)),RN.Name,MM.Name,MM.ShortCode,Concat(@TrainingManagement,'/',JSON_VALUE(PERMISSIONS,'$.ScreenName'))

	End
	-- Client Cursor
	Else IF @CursorShortCode=@CNC
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(AC.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Leads & Accounts/',[dbo].[SharePoint_Remove_SpecialCharecters](AC.name),'/',Heading) As FolderPath,'Add' As [Action]
		From ClientCursor.Account As AC With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@ClientCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName In (@Opportunities,@Quotations) And [Action]=@Add)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=AC.CompanyId
		Group By Cast(AC.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Leads & Accounts/',[dbo].[SharePoint_Remove_SpecialCharecters](AC.name),'/',Heading)
		
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,
				 JSON_VALUE(PERMISSIONS,'$.ScreenName') As FolderPath,'Add'
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name=@Role And MM.Name=@ClientCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') = (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName =@Vendors And [Action]=@Add)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		Group By Cast(RN.CompanyId As varchar(50)),RN.Name,MM.Name,MM.ShortCode,
				JSON_VALUE(PERMISSIONS,'$.ScreenName')	
	End
	-- WorkFlow Cursor
	Else IF @CursorShortCode=@WFC
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(C.CompanyId As varchar(50)) As CompanyId,CS.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases) As FolderPath,'Add' [Action]
		From WorkFlow.Client As C With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@WorkflowCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') in (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName =@Cases And [Action]=@Add)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
		) As CS On CS.CompanyId=C.CompanyId
		Group by Cast(C.CompanyId As varchar(50)),CS.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(C.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases,'/',CaseNumber,'/',Heading) As FolderPath,'Add'
		From WorkFlow.Client As C
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
				Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@WorkflowCursor
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
				Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@WorkflowCursor
					And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName =@Invoices And [Action]=@Add)
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
			) As INVCLM On CS.CompanyId=INVCLM.CompanyId And CS.[Role]=INVCLM.[Role] And CS.CursorShortCode=INVCLM.CursorShortCode
				And CS.[Cursor]=INVCLM.[Cursor]
			GRoup By INVCLM.[Role],INVCLM.CompanyId,INVCLM.Heading,CS.CaseNumber,CS.ClientId,INVCLM.CursorShortCode,INVCLM.[Cursor]
		) As Roledata On Roledata.CompanyId=C.CompanyId And C.Id=Roledata.ClientId

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(C.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases,'/',CaseNumber,'/',@Claims) As FolderPath,'Add'
		From WorkFlow.Client As C
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
				Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@WorkflowCursor
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
				Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@WorkflowCursor
					And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName =@Invoices And [Action]=@Add)
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
			) As INVCLM On CS.CompanyId=INVCLM.CompanyId And CS.[Role]=INVCLM.[Role] And CS.CursorShortCode=INVCLM.CursorShortCode
				And CS.[Cursor]=INVCLM.[Cursor]
			GRoup By INVCLM.[Role],INVCLM.CompanyId,INVCLM.Heading,CS.CaseNumber,CS.ClientId,INVCLM.CursorShortCode,INVCLM.[Cursor]
		) As Roledata On Roledata.CompanyId=C.CompanyId And C.Id=Roledata.ClientId

	End
	-- Bean Cursor
	IF @CursorShortCode=@Bean
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(E.CompanyId As varchar(50))  As CompanyId,[Role],[Cursor],CursorShortCode,Concat('Entities/',[dbo].[SharePoint_Remove_SpecialCharecters](E.name),'/',Heading) As FolderPath,'Remove' As Action
		From Bean.Entity As E With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,Case When JSON_VALUE(PERMISSIONS,'$.ScreenName')=@BillPayment Then 'Bill Payments' Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End  As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@BeanCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select Distinct ScreenName From @ScreenNames_TBL2 Where ScreenName In(@Bills,@BillPayment,@CreditMemos) And [Action]=@Remove)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='False'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=E.CompanyId
		Group By Cast(E.CompanyId As varchar(50)),[Role],[Cursor],CursorShortCode,Concat('Entities/',[dbo].[SharePoint_Remove_SpecialCharecters](E.name),'/',Heading)
		
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,
		Case When JSON_VALUE(PERMISSIONS,'$.ScreenName')=@CashPayments Then 'Cash Payments'
			 When JSON_VALUE(PERMISSIONS,'$.ScreenName') ='Recurring Journals' Then 'Journals'  
			 Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End  As Heading,'Remove' As [Action]
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@BeanCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select Distinct ScreenName From @ScreenNames_TBL2 Where ScreenName Not In(@Bills,@BillPayment,@CreditMemos) And [Action]=@Remove)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='False'
		Group by Cast(RN.CompanyId As varchar(50)),RN.Name,MM.ShortCode,MM.Name,Case When JSON_VALUE(PERMISSIONS,'$.ScreenName')=@CashPayments Then 'Cash Payments'
			 When JSON_VALUE(PERMISSIONS,'$.ScreenName') ='Recurring Journals' Then 'Journals'  
			 Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End
	End
	-- HR Cursor
	Else IF @CursorShortCode=@HRC
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(Emp.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Qualification) As FolderPath,'Remove' As [Action]
		From Common.Employee As Emp With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') =(Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName=@Employees And [Action]=@Remove)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='false'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Group By Cast(Emp.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Qualification)

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(Emp.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Assets) As FolderPath,'Remove' As [Action]
		From Common.Employee As Emp With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On  RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') =(Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName=@Employees And [Action]=@Remove)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='false'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Group By Cast(Emp.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',@Assets)
		
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(Emp.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',Heading) As FolderPath,'Remove' As [Action]
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
			Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@HRCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName In (@Claims,@Payroll,@Leaves)  And [Action]=@Remove)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='false'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=Emp.CompanyId
		Group By Cast(Emp.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Employees/',[dbo].[SharePoint_Remove_SpecialCharecters](Emp.FirstName),'/',Heading)
		
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,Case When JSON_VALUE(PERMISSIONS,'$.ScreenName') ='Job Applications' Then 'Recruitment' Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End As Heading,'Remove'
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@HRCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName In (@Recruitment,@JobApplications)  And [Action]=@Remove)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='false'
		Group by Cast(RN.CompanyId As varchar(50)),RN.Name,MM.ShortCode,MM.Name,Case When JSON_VALUE(PERMISSIONS,'$.ScreenName') ='Job Applications' Then 'Recruitment' Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,
				Concat(@TrainingManagement,'/',JSON_VALUE(PERMISSIONS,'$.ScreenName')) As FolderPath,'Remove'
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name=@Role And MM.Name=@HRCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName In (@Trainings,@Claims)  And [Action]=@Remove)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='false'
		Group By Cast(RN.CompanyId As varchar(50)),RN.Name,MM.Name,MM.ShortCode,Concat(@TrainingManagement,'/',JSON_VALUE(PERMISSIONS,'$.ScreenName'))
	End
	-- Client Cursor
	Else IF @CursorShortCode=@CNC
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(AC.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Leads & Accounts/',[dbo].[SharePoint_Remove_SpecialCharecters](AC.name),'/',Heading) As FolderPath,'Remove' As [Action]
		From ClientCursor.Account As AC With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@ClientCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName In (@Opportunities,@Quotations) And [Action]=@Remove)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='false'
				Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
		) As Roledata On Roledata.CompanyId=AC.CompanyId
		Group By Cast(AC.CompanyId As varchar(50)),Roledata.[Role],[Cursor],CursorShortCode,Concat('Leads & Accounts/',[dbo].[SharePoint_Remove_SpecialCharecters](AC.name),'/',Heading)
		
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(RN.CompanyId As varchar(50)) As CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,
				 JSON_VALUE(PERMISSIONS,'$.ScreenName') As FolderPath,'Remove'
		From Auth.RolePermissionsNew As RPN With (NOlock)
		Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
		Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
		Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
		Where RN.CompanyId=@CompanyId And RN.Name=@Role And MM.Name=@ClientCursor
			And JSON_VALUE(PERMISSIONS,'$.ScreenName') = (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName =@Vendors And [Action]=@Remove)
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
			And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='false'
		Group By Cast(RN.CompanyId As varchar(50)),RN.Name,MM.Name,MM.ShortCode,
				JSON_VALUE(PERMISSIONS,'$.ScreenName')
	End
	-- WorkFlow Cursor
	Else IF @CursorShortCode=@WFC
	Begin
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(C.CompanyId As varchar(50)) As CompanyId,CS.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases) As FolderPath,'Remove' As [Action]
		From WorkFlow.Client As C With (NOlock)
		Inner Join
		(
			Select RN.Name As [Role],RN.CompanyId,JSON_VALUE(PERMISSIONS,'$.ScreenName') As Heading
					,MM.ShortCode As CursorShortCode,MM.Name As [Cursor]
			From Auth.RolePermissionsNew As RPN With (NOlock)
			Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
			Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
			Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
			Where RN.CompanyId=@CompanyId And RN.Name=@Role  And MM.Name=@WorkflowCursor
				And JSON_VALUE(PERMISSIONS,'$.ScreenName') in (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName=@Cases and [Action]=@Remove)
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
				And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='false'
		) As CS On CS.CompanyId=C.CompanyId
		Group by Cast(C.CompanyId As varchar(50)),CS.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases)
		
		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(C.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases,'/',CaseNumber,'/',Heading) As FolderPath,'Remove'
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
				Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@WorkflowCursor
					And JSON_VALUE(PERMISSIONS,'$.ScreenName') = @Cases
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='false'
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
				Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@WorkflowCursor
					And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName =@Invoices And [Action]=@Remove)
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='false'
			) As INVCLM On CS.CompanyId=INVCLM.CompanyId And CS.[Role]=INVCLM.[Role] And CS.CursorShortCode=INVCLM.CursorShortCode
				And CS.[Cursor]=INVCLM.[Cursor]
			GRoup By INVCLM.[Role],INVCLM.CompanyId,INVCLM.Heading,CS.CaseNumber,CS.ClientId,INVCLM.CursorShortCode,INVCLM.[Cursor]
		) As Roledata On Roledata.CompanyId=C.CompanyId And C.Id=Roledata.ClientId

		Insert Into @FolderPath_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action])
		Select Cast(C.CompanyId As varchar(50)) As CompanyId,Roledata.[Role],[Cursor],CursorShortCode,Concat('Clients/',[dbo].[SharePoint_Remove_SpecialCharecters](C.name),'/',@Cases,'/',CaseNumber,'/',@Claims) As FolderPath,'Remove'
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
				Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@WorkflowCursor
					And JSON_VALUE(PERMISSIONS,'$.ScreenName') = @Cases
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='false'
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
				Where RN.CompanyId=@CompanyId And RN.Name =@Role And MM.Name=@WorkflowCursor
					And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select distinct ScreenName From @ScreenNames_TBL2 Where ScreenName =@Invoices And [Action]=@Remove)
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
					And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='false'
			) As INVCLM On CS.CompanyId=INVCLM.CompanyId And CS.[Role]=INVCLM.[Role] And CS.CursorShortCode=INVCLM.CursorShortCode
				And CS.[Cursor]=INVCLM.[Cursor]
			GRoup By INVCLM.[Role],INVCLM.CompanyId,INVCLM.Heading,CS.CaseNumber,CS.ClientId,INVCLM.CursorShortCode,INVCLM.[Cursor]
		) As Roledata On Roledata.CompanyId=C.CompanyId And C.Id=Roledata.ClientId
	
	End
	Select Case When Len(CompanyId)<3 Then RIGHT('00'+Cast(CompanyId As varchar(50)),3) Else Cast(CompanyId As varchar(50)) End As CompanyId,[Role],[Cursor],CursorShortCode,FolderPath,[Action]
	From @FolderPath_TBL 
	Order by [Cursor],FolderPath
End
GO
