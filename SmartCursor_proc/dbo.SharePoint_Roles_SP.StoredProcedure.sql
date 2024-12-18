USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SharePoint_Roles_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Exec [dbo].[SharePoint_Roles_SP] 2430,Null
Create Procedure [dbo].[SharePoint_Roles_SP]
@CompanyId Bigint,
@CursorShortCode Nvarchar(1024) -- If null all else comma separated
As
Begin
	Declare @CursorShortCodes_Tbl table (CursorShortCode Nvarchar(250))
	IF @CursorShortCode Is Not Null And @CursorShortCode<>''
	Begin
		Insert Into @CursorShortCodes_Tbl
		Select Ltrim(Rtrim(items)) From dbo.SplitToTable (@CursorShortCode,',')
	End
	Else
	Begin
		Insert Into @CursorShortCodes_Tbl
		Select Distinct ShortCode From Common.ModuleMaster With (NOlock) Where CompanyId=0 And IsMainCursor=1
	End

	Select Case When Len(RN.CompanyId)<3 Then RIGHT('00'+Cast(RN.CompanyId As varchar(50)),3) Else Cast(RN.CompanyId As varchar(50)) End As CompanyId,MM.Name As [Cursor],MM.ShortCode As CursorShortCode,RN.Name As [Role] From Auth.RoleNew As RN With (NOlock)
	Inner Join Common.ModuleMaster As MM With (NOlock) On MM.Id=RN.ModuleMasterId
	Where MM.ShortCode In (Select CursorShortCode From @CursorShortCodes_Tbl) And MM.IsMainCursor=1 And RN.CompanyId=@CompanyId
End
GO
