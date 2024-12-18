USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SharePoint_CursorShortCodeByRole_Sp]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec dbo.SharePoint_CursorShortCodeByRole_Sp 2430,'Admin'
Create Procedure [dbo].[SharePoint_CursorShortCodeByRole_Sp]
@CompanyId Bigint,
@Role Nvarchar(64)
As
Begin
	Select MM.ShortCode As CursorShortCode, Case When Len(RN.CompanyId)<3 Then RIGHT('00'+Cast(RN.CompanyId As varchar(50)),3) Else Cast(RN.CompanyId As varchar(50)) End As CompanyId,MM.Name As [Cursor],RN.Name As [Role]
	From Auth.RoleNew As RN
	Inner Join Common.ModuleMaster As MM On Mm.Id=RN.ModuleMasterId
	Where RN.CompanyId=@CompanyId And RN.Name =@Role 
End
GO
