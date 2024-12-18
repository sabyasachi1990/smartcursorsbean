USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SmartCursors_Syncing_Process]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SmartCursors_Syncing_Process]  
(  
	@CompanyId int,  
	@Cursor nvarchar(100),  
	@DocType nvarchar(100),  
	@SourceId uniqueidentifier,  
	@TargetId uniqueidentifier,  
	@Status nvarchar(200),  
	@Remarks nvarchar(max)  
)  
AS  
Begin  
    Declare @payrollId nvarchar(500)
    If (@Cursor='Workflow Cursor' AND @DocType='Invoice')  
    BEGIN  
      	If exists (Select Id from WorkFlow.Invoice where Id=@SourceId and Status=1)  
        BEGIN  
        	BEGIN TRY  
          		Update WorkFlow.Invoice set SyncBCInvoiceId=@TargetId,SyncBCInvoiceStatus=@Status,SyncBCInvoiceDate=GETUTCDATE    (),SyncBCInvoiceRemarks=@Remarks where Id=@SourceId and CompanyId=@CompanyId  
          	END TRY  
          	BEGIN CATCH  
          		Update WorkFlow.Invoice set SyncBCInvoiceId=@TargetId,SyncBCInvoiceStatus=@Status,SyncBCInvoiceDate=GETDATE    (),SyncBCInvoiceRemarks=ERROR_MESSAGE() where Id=@SourceId  
          	END CATCH  
         END  
    END  
    Else If (@Cursor='HR Cursor' AND @DocType='Claim')
    BEGIN
        If exists (Select Id from Hr.EmployeeClaim1 where Id=@SourceId and Status=1)
        BEGIN
            BEGIN TRY  
                Update Hr.EmployeeClaim1 set SyncBCClaimId=@TargetId, SyncBCClaimStatus=@Status,
                SyncBCClaimDate=GETDATE(), SyncBCClaimRemarks=@Remarks Where Id=@SourceId
            END TRY  
            BEGIN CATCH  
                Update Hr.EmployeeClaim1 set SyncBCClaimId=@TargetId, SyncBCClaimStatus=@Status,
                SyncBCClaimDate=GETDATE(), SyncBCClaimRemarks=ERROR_MESSAGE() Where Id=@SourceId
            END CATCH  
        END
    END
    Else IF(@Cursor='HR Cursor' AND @DocType='Payroll')
    BEGIN
        If Exists(Select Id from Hr.Payroll where id=@SourceId)
        BEGIN
            Select  @payrollId = Coalesce(@payrollId + ',','') + Cast(b.Id as nvarchar(MAX)) from Bean.Bill b
            Where b.payrollid=@SourceId and b.CompanyId=@CompanyId
            IF(@payrollId is not null)
            BEGIN
                BEGIN TRY
                    Update Hr.Payroll set SyncPayBillId=@payrollId,SyncPayBillStatus=@Status,SyncPayBillDate=GETUTCDATE(),SyncPayBillRemarks=@Remarks where id=@SourceId
                END TRY
                BEGIN CATCH
                    Update Hr.Payroll set SyncPayBillId=null,SyncPayBillStatus=@Status,SyncPayBillDate=GETUTCDATE(),SyncPayBillRemarks=ERROR_MESSAGE() where id=@SourceId
                END CATCH
            END
            Else
            Begin
				BEGIN TRY
	                Update Hr.Payroll set SyncPayBillId=null,SyncPayBillStatus=@Status,SyncPayBillDate=GETUTCDATE(),SyncPayBillRemarks=@Remarks where id=@SourceId
                END TRY
                BEGIN CATCH
                    Update Hr.Payroll set SyncPayBillId=null,SyncPayBillStatus=@Status,SyncPayBillDate=GETUTCDATE(),SyncPayBillRemarks=ERROR_MESSAGE() where id=@SourceId
                END CATCH
            End
        END
    END
END  
GO
