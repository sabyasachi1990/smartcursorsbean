USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Document_History]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 Create PROCEDURE [dbo].[Bean_Document_History]
(
@Id uniqueidentifier,
@CompanyId int,
@DocType nvarchar(50)
)
As
Begin
Declare @ErrorMessage nvarchar(2000)
 Begin Try
  Select * from Bean.DocumentHistory where DocumentId=@Id and DocType=@DocType and CompanyId=@CompanyId
 End Try
 
 Begin Catch
 Set @ErrorMessage=(Select ERROR_MESSAGE())
 End Catch
End

GO
