USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PROC_UPDATE_JOURNALDETAIL_CLEARING_STATUS]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PROC_UPDATE_JOURNALDETAIL_CLEARING_STATUS](@companyId bigint,@documentId uniqueidentifier,@docState nvarchar(20),@balanceAmount Money)
AS
BEGIN
 if exists (Select * from Bean.Journal where CompanyId=@companyId and DocumentId=@documentId)
 Begin
 Update Bean.Journal set BalanceAmount=@balanceAmount,DocumentState=@docState where CompanyId=@companyId and DocumentId=@documentId
 Update Bean.JournalDetail set ClearingStatus= Null,ClearingDate=Null
 where JournalId in (Select J.Id from Bean.Journal J join Bean.JournalDetail JD on J.Id=JD.JournalId where J.CompanyId=@companyId and J.DocumentId=@documentId and j.DocumentState<>'Fully Paid')
 End
End
GO
