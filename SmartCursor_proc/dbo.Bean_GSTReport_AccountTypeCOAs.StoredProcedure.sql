USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_GSTReport_AccountTypeCOAs]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Bean_GSTReport_AccountTypeCOAs] 
@CompanyId Bigint,
@AccountType Varchar(MAX)
AS
Begin
--Declare @CompanyId Bigint=1,@AccountType Varchar(MAX)='Revenue'
Select Distinct C.Name COAName,C.Id COAId from Bean.ChartOfAccount C
Inner Join Bean.AccountType A ON A.Id=C.AccountTypeId AND A.CompanyId=C.CompanyId
Where C.CompanyId=@CompanyId AND A.Name=@AccountType
END
GO
