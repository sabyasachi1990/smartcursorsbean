USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SharePoint_RolesByScreen_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec [dbo].[SharePoint_RolesByScreen_SP] 2430,'Bean','Bill Payments,Bills'
CREATE Procedure [dbo].[SharePoint_RolesByScreen_SP]
@CompanyId BigInt,
@CursorShortCode Nvarchar(50),
@ScreenName Nvarchar(1024)
As
Begin
	Declare @Default_ScreenTbl table (ScreenName Nvarchar(250))
	Declare @ScreenTbl table (ScreenName Nvarchar(250))

	Insert Into @Default_ScreenTbl
		Values ('Credit Memos'),
				('Bill Payment'),
				('Bills'),
				('Quotations'),
				('Opportunities'),
				('Cases'),
				('Assets'),
				('Qualification '),
				('Leaves'),
				('Payrolls'),
				('Claims'),
				('Invoices')
	Insert Into @ScreenTbl
	Select Case When LTRIM(RTRIM(Items))='Bill Payments' Then 'Bill Payment'
				Else LTRIM(RTRIM(Items)) End From dbo.SplitToTable(@ScreenName,',')
	Delete From @ScreenTbl Where ScreenName Not In (Select ScreenName FRom @Default_ScreenTbl)

	Select RN.CompanyId,RN.Name As [Role],MM.Name As [Cursor],MM.ShortCode As CursorShortCode,
		Case When JSON_VALUE(PERMISSIONS,'$.ScreenName')='Bill Payment' Then 'Bill Payments'
			 When JSON_VALUE(PERMISSIONS,'$.ScreenName')='Payrolls' Then 'Payroll'	
			 Else JSON_VALUE(PERMISSIONS,'$.ScreenName') End As ScreenName
	From Auth.RolePermissionsNew As RPN With (NOlock)
	Inner Join Auth.RoleNew As RN With (NOlock) On RN.Id=RPN.RoleId
	Inner Join Common.ModuleDetail As MD With (NOlock) On Md.Id=RPN.ModuleDetailId
	Inner Join Common.ModuleMaster As MM With (NOlock) On Mm.Id=MD.ModuleMasterId
	Where RN.CompanyId=@CompanyId And MM.ShortCode=@CursorShortCode
		And JSON_VALUE(PERMISSIONS,'$.ScreenName') In (Select ScreenName From @ScreenTbl)
		And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Name')='View'
		And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.IsApplicable')='true'
		And JSon_Value(JSON_QUERY([Permissions],'$.Tabs[0].Actions[0]'),'$.Chk')='true'
	Group by RN.Name ,RN.CompanyId,MM.ShortCode,MM.Name,JSON_VALUE(PERMISSIONS,'$.ScreenName')
End
GO
