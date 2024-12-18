USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_AuditAccountPolicyAndReportDelete]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 

CREATE PROCEDURE [dbo].[Sp_AuditAccountPolicyAndReportDelete] (@engagementId UNIQUEIDENTIFIER)
	As Begin
		Begin Transaction
		BEGIN TRY
			
				Delete Audit.ReportingTemplates where EngagementId=@engagementId

				Delete Audit.AccountPolicyDetail where MasterId in (select id from Audit.AccountPolicy where EngagementId =@engagementId)

				Delete Audit.AccountPolicy where EngagementId =@engagementId	 

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
END
GO
