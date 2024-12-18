USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[DELETE_POSTING_JOURNAL]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 Create PROCEDURE [dbo].[DELETE_POSTING_JOURNAL]
(
@CompanyId int,
@DocumentId uniqueidentifier,
@DocType nvarchar(50)
)
As
Begin
    If exists (Select * from Bean.Journal where DocumentId=@DocumentId)
    Begin
        Delete from Bean.JournalDetail where JournalId in (Select Id from Bean.Journal where DocumentId=@DocumentId)
        Delete from Bean.Journal where DocumentId=@DocumentId
        if(@DocType='Application')
        Begin
        Delete from Bean.CreditNoteApplicationDetail where CreditNoteApplicationId in (Select Id from Bean.CreditNoteApplication where Id=@DocumentId)
        Delete from Bean.CreditNoteApplication where Id=@DocumentId
        End
        if(@DocType='CM Application')
        Begin
        Delete from Bean.CreditMemoApplicationDetail where CreditMemoApplicationId in (Select Id from Bean.CreditMemoApplication where Id=@DocumentId)
        Delete from Bean.CreditMemoApplication where Id=@DocumentId
        End
    End
End
GO
