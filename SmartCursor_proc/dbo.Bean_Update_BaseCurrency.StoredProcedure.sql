USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Update_BaseCurrency]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[Bean_Update_BaseCurrency]
(
@CompanyId BigInt
)
As 
Begin
	If Exists(select jd.id from Bean.Journal as j
join Bean.JournalDetail as jd 
on j.Id=jd.JournalId
where (jd.BaseCurrency<>(Select BaseCurrency from Common.Localization Where CompanyId=@CompanyId) or jd.BaseCurrency is null) and j.CompanyId=@CompanyId)
	Begin
		Update JD Set JD.BaseCurrency=(Select BaseCurrency from Common.Localization Where CompanyId=@CompanyId) from Bean.Journal J
		Inner Join Bean.JournalDetail JD ON JD.JournalId=J.Id
		Where CompanyId=@CompanyId AND (JD.BaseCurrency NOT IN (Select BaseCurrency from Common.Localization Where CompanyId=@CompanyId)  Or		JD.BaseCurrency IS NULL)
	End
End

GO
