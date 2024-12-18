USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_TransactionData]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Common_Sync_TransactionData]
(
@CompanyId bigint,
@Cursor nvarchar(50),
@DocType nvarchar(50),
@SourceId uniqueidentifier,
@TargetId uniqueidentifier,
@Status nvarchar(50),
@Remarks nvarchar(max)
)
AS
Begin
If (@Cursor='Workflow Cursor' AND @DocType='Case')
BEGIN
If exists (Select Id from ClientCursor.Opportunity where Id=@SourceId and Status=1)
BEGIN
Update ClientCursor.Opportunity set SyncCaseId=@TargetId, SyncCaseStatus=@Status,
SyncCaseDate=GETDATE(), SyncCaseRemarks=@Remarks Where Id=@SourceId
END
END



If (@Cursor='Workflow Cursor' AND @DocType='Claim')
BEGIN
If exists (Select Id from HR.EmployeeClaimDetail where Id=@SourceId )
BEGIN
Update HR.EmployeeClaimDetail set SyncWFClaimId=@TargetId, SyncWFClaimStatus=@Status,
SyncWFClaimDate=GETDATE(), SyncWFClaimRemarks=@Remarks Where Id=@SourceId
END
END
End




GO
