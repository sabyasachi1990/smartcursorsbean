USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_ExchangeRate_Insertion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create proc [dbo].[Bean_ExchangeRate_Insertion]
@FromCurrency Nvarchar(40),
@ToCurrency Nvarchar(40)
as
begin
--Local Variables
Declare @ErrorMessage Nvarchar(4000)

	Begin Try
	Begin Transaction
		Declare @Date as table(alldates datetime2(7))

;WITH dates AS (SELECT {d N'2020-01-01'} AS [Date] 
UNION ALL 
SELECT DATEADD(day, 1, [Date]) AS [Date] FROM dates WHERE [Date] < {d N'2020-12-31'}) 
INSERT INTO @Date (alldates) SELECT [Date] FROM dates OPTION (MAXRECURSION 366);
 
Select * from @Date where alldates not in (Select DateFrom from Common.Forex where DateFrom >= '2020-01-01 00:00:00.0000000' and Dateto<= '2020-12-31 00:00:00.0000000' and FromCurrency=@FromCurrency and ToCurrency=@ToCurrency and CompanyId=0 
)
	Commit Transaction
	End Try
	Begin Catch
		RollBack
		Select @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
	End Catch
end
GO
