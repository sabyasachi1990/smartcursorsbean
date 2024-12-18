USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SharePoint_Cursors_Roles_UserEmails_Migration_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec SharePoint_Cursors_Roles_UserEmails_Migration_SP 2570,null,Null
CREATE Procedure [dbo].[SharePoint_Cursors_Roles_UserEmails_Migration_SP]
@CompanyId Bigint,
@CursorShortCode Nvarchar(1024),  --if null take all and coma seperated
@Roles Nvarchar(1024)--if null take all and coma seperated
As
Begin
	Declare @ShortCode_Tbl table (CursorShortCode nvarchar(125))
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

	IF @CursorShortCode Is Not Null And @CursorShortCode<>''
	Begin
		Insert Into @ShortCode_Tbl 
		Select RTRIM(LTRIM(items)) From dbo.SplitToTable(@CursorShortCode,',')
	End
	Else
	Begin
		Insert Into @ShortCode_Tbl 
		Select Distinct ShortCode From Common.ModuleMaster With (NOlock) Where CompanyId=0 And IsMainCursor=1
	End

	Declare @DomainName Nvarchar(250)
	Set @DomainName=(Select EX.DomainName
					From Common.Externalconfigurationdetail EXD With (NOlock)
					Inner Join Common.Externalconfiguration EX With (NOlock) On Ex.Id = EXD.ExternalconfigurationId
					Where EX.CompanyId=@CompanyId)

	Select Case When Len(RLN.CompanyId)<3 Then RIGHT('00'+Cast(RLN.CompanyId As varchar(50)),3) Else Cast(RLN.CompanyId As varchar(50)) End As CompanyId,MM.ShortCode As CursorShortCode,MM.Name As [Cursor],RLN.Name As [Role],CU.Email 
	From Auth.RoleNew As RLN With (NOlock)
	Inner Join Auth.UserRoleNew As URN With (NOlock) On RLN.Id=URN.RoleId
	Inner Join Common.ModuleMaster As MM With (NOlock) On MM.Id=RLN.ModuleMasterId
	Inner Join Common.CompanyUser As CU With (NOlock) On CU.Id=URN.CompanyUserId
	Where RLN.CompanyId=@CompanyId And MM.ShortCode in (Select CursorShortCode From @ShortCode_Tbl)
		And RLN.Name In (Select RoleName From @RoleTbl)
		And Reverse(SubString(Reverse(CU.Username),1,LEN(@DomainName)))	=@DomainName
		AND URN.Status = 1 and CU.Status=1 --ACTIVE  
	Group By Case When Len(RLN.CompanyId)<3 Then RIGHT('00'+Cast(RLN.CompanyId As varchar(50)),3) Else Cast(RLN.CompanyId As varchar(50)) End ,MM.ShortCode ,MM.Name ,RLN.Name ,CU.Email
End
GO
