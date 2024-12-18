USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[MigratedToSharePoint]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create   Procedure [dbo].[MigratedToSharePoint] (@CompanyID Int, @AzureFileHostURL nvarchar(1000), @SharePointHostNameURL nvarchar(1000))
As
Begin
    Update common.DocRepository Set AzurePath= Replace(AzurePath, @AzureFileHostURL, @SharePointHostNameURL)
    Where CompanyId = @CompanyID
End
GO
