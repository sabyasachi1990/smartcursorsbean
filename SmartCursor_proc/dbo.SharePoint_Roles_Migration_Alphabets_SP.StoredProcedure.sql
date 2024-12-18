USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SharePoint_Roles_Migration_Alphabets_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec SharePoint_Roles_Migration_Alphabets_SP 1,'WFC',null,'C'
CREATE Proc [dbo].[SharePoint_Roles_Migration_Alphabets_SP]
@CompanyId BigInt,
@CursorshortCode Nvarchar(1024),-- Add Cursor Parameter If null All esle passed values (Single or comma seperated)
@Roles Nvarchar(1024),--If null All esle passed values (Single or comma seperated)
@OrderCharecters Nvarchar(128)
As
Begin
	Declare @Count Int
	Declare @RecCount Int
	Declare @Char_Split_Tbl table (S_No Int Identity(1,1),Charecters Nvarchar(250))
	Declare @Charecter_TBL Table (CompanyId Nvarchar(50),[Role] Nvarchar(520),[Cursor] Nvarchar(50),CursorShortCode Nvarchar(25),FolderPath Nvarchar(1024))
	Declare @Final_TBL Table (CompanyId Nvarchar(50),[Role] Nvarchar(520),[Cursor] Nvarchar(50),CursorShortCode Nvarchar(25),FolderPath Nvarchar(1024))

	IF @OrderCharecters Is Not Null And @OrderCharecters<>''
	Begin
		Insert Into @Char_Split_Tbl
		Select Ltrim(Rtrim(items)) From dbo.SplitToTable (@OrderCharecters,',')
	End
	Insert Into @Charecter_TBL
	Exec SharePoint_Roles_Migration_SP @CompanyId,@CursorshortCode,@Roles
	IF Exists (Select S_No From @Char_Split_Tbl)
	Begin
		Set @Count=(Select Count(*) From @Char_Split_Tbl)
		Set @RecCount=1
		While @Count>=@RecCount
		Begin
			Set @OrderCharecters=(Select Charecters From @Char_Split_Tbl Where S_No=@RecCount)
			Insert Into @Final_TBL (CompanyId,[Role],[Cursor],CursorShortCode,FolderPath)
			Select CompanyId ,[Role] ,[Cursor] ,CursorShortCode ,FolderPath  From @Charecter_TBL Where Substring(FolderPath,CharIndex('/',FolderPath)+1,LEN(Folderpath)) Like @OrderCharecters+'%' And CHARINDEX('/',FolderPath)<>0
			Order By [Cursor],FolderPath
			Set @RecCount=@RecCount+1
		End
		Select CompanyId,[Role],[Cursor],CursorShortCode,FolderPath From @Final_TBL Order By [Cursor],FolderPath
	End
	Else
	Begin
		Select CompanyId ,[Role] ,[Cursor] ,CursorShortCode ,FolderPath  From @Charecter_TBL Where FolderPath Not Like '%/%'
		Order By [Cursor],FolderPath
	End
End
GO
