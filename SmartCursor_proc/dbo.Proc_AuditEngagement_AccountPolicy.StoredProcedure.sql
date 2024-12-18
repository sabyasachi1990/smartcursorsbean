USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AuditEngagement_AccountPolicy]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Proc_AuditEngagement_AccountPolicy] (@engagementId uniqueidentifier,@companyId bigint)

As Begin
Declare @PolicyId uniqueidentifier;
Declare @NewPolicyId uniqueidentifier;
Declare @PolicyDetailId uniqueidentifier;


Begin Transaction
BEGIN TRY

    DECLARE AccountpolicyCSR cursor for select id from Audit.AccountPolicy where CompanyId=0
    OPEN AccountpolicyCSR
    FETCH NEXT FROM   AccountpolicyCSR into @PolicyId
    WHILE (@@FETCH_STATUS=0)
    BEGIN
	    set @NewPolicyId=NEWID();
		 Insert Into Audit.AccountPolicy (Id,CompanyId,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Section,PolicyNameId,IsRollForward)
		 Select @NewPolicyId,@companyId,@engagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,GETDATE(),ModifiedBy,ModifiedDate,Version,Status,Section,@PolicyId,IsRollForward  from Audit.AccountPolicy where Id=@PolicyId
		    
			  DECLARE AccountpolicyDetailCSR cursor for select id from Audit.AccountPolicyDetail where MasterId=@PolicyId
              OPEN AccountpolicyDetailCSR
              FETCH NEXT FROM   AccountpolicyDetailCSR into @PolicydetailId
              WHILE (@@FETCH_STATUS=0)
              BEGIN
			      Insert Into Audit.AccountPolicyDetail (Id,MasterId,PolicyName,PolicyTemplate,IsChecked,IsSytem,RecOrder,Status,PolicyNameId)
				  select NEWID(),@NewPolicyId,PolicyName,PolicyTemplate,IsChecked,IsSytem,RecOrder,Status,@PolicyDetailId  from Audit.AccountPolicyDetail where id=@PolicyDetailId
			  FETCH NEXT FROM   AccountpolicyDetailCSR into @PolicydetailId
			  END
              CLOSE AccountpolicyDetailCSR
              DEALLOCATE AccountpolicyDetailCSR
    FETCH NEXT FROM   AccountpolicyCSR into @PolicyId
	END
    CLOSE AccountpolicyCSR
    DEALLOCATE AccountpolicyCSR
	Commit Transaction;
END TRY


BEGIN CATCH
	RollBack Transaction;
	DECLARE
	   @ErrorMessage NVARCHAR(4000),
	   @ErrorSeverity INT,
	   @ErrorState INT;
	   SELECT
	   @ErrorMessage = ERROR_MESSAGE(),
	   @ErrorSeverity = ERROR_SEVERITY(),
	   @ErrorState = ERROR_STATE();
	  RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH
End
GO
