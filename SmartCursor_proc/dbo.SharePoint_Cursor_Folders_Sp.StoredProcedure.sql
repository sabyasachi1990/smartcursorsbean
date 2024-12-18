USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SharePoint_Cursor_Folders_Sp]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec dbo.SharePoint_Cursor_Folders_Sp 2430
Create procedure [dbo].[SharePoint_Cursor_Folders_Sp]
@CompanyId Bigint
As
Begin
	Declare @Cursor_Tbl table (CursorShortCode Nvarchar(64),FolderName Nvarchar(124))
	Insert into @Cursor_Tbl 
		Values('CNC','Leads & Accounts'),
			  ('CNC','Vendors'),
			  ('WFC','Clients'),
			  ('Bean','Entities'),
			  ('Bean','Journals'),
			  ('Bean','Withdrawals'),
			  ('Bean','Deposits'),
			  ('Bean','Transfers'),
			  ('Bean','Cash Payments'),
			  ('HRC','Employees'),
			  ('HRC','Training Management'),
			  ('HRC','Recruitment'),
			  ('HRC','Attendance')

	Select Case When Len(@CompanyId)<3 Then RIGHT('00'+Cast(@CompanyId As varchar(50)),3) Else Cast(@CompanyId As varchar(50)) End As CompanyId,MM.[Name] As [Cursor],MM.ShortCode As CursorShortCode,CT.FolderName As Folder From Common.ModuleMaster As MM With (Nolock) 
	Inner Join @Cursor_Tbl As CT On MM.ShortCode=CT.CursorShortCode
	Where CompanyId=0 And IsMainCursor=1

End
GO
