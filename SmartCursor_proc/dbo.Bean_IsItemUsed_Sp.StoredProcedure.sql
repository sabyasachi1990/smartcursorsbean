USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_IsItemUsed_Sp]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Bean_IsItemUsed_Sp]
@CompanyId Bigint,
@ItemId Uniqueidentifier
As
Begin
	Declare @IsUsed Bit=0
	--If Exists (Select Id From Bean.Item Where DocumentId=@ItemId)
	--Begin
	--	Set @BCItemId=(Select Id From Bean.Item Where DocumentId=@ItemId)
	--	Set @IsUsed=1
	--End
	If Exists (Select ID.Id From Bean.InvoiceDetail As ID Inner Join Bean.Item As I On I.Id=ID.ItemId Where ID.ItemId=@ItemId And I.CompanyId=@CompanyId)
	Begin
		Set @IsUsed=1
	End
	If Exists (Select JD.Id From Bean.JournalDetail As JD Inner Join Bean.Item As I On I.Id=JD.ItemId Where JD.ItemId=@ItemId And I.CompanyId=@CompanyId)
	Begin
		Set @IsUsed=1
	End
	If Exists (Select CSD.Id From Bean.CashSaleDetail As CSD Inner Join Bean.Item As I On I.Id=CSD.ItemId Where CSD.ItemId=@ItemId And I.CompanyId=@CompanyId)
	Begin
		Set @IsUsed=1
	End
	
	If @IsUsed=0
	Begin
		Select @IsUsed
	End
	Else 
	Begin
		Raiserror ('This item already used in bean cursor',16,1);
	End

End
GO
