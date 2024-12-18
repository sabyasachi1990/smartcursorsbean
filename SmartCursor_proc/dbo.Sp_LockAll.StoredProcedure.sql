USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_LockAll]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_LockAll] (@engagementId UNIQUEIDENTIFIER,@UserCode nvarchar(100),@DateCode nvarchar(100),@UserCreated nvarchar(100))
	As Begin
		Begin Transaction
		BEGIN TRY	
			INSERT INTO audit.UserApproval(Id,Type,Screen,EngagementId,UserCode,DateCode,Remarks,Recorder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status) SELECT NEWID(),'Approved',Heading,@engagementId,@UserCode,@DateCode,null,null,@UserCreated,GETDATE(),NULL,NULL,null,1  from audit.auditcompanymenumaster WHERE engagementid=@engagementId and ishide=0 and AuditMenuMasterId in (select id from audit.AuditMenuMaster where GroupName not in ('SUMMARY')) and code not in ( 'R-3','R-4','R-5','R-6','R-9','R-8','T-9','AF-9') and heading not in ('DASHBOARD','APPROVAL','DOCUMENTS')and Heading not in (select Screen from audit.UserApproval where type='Approved' and engagementid=@engagementId )
    	Commit Transaction
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
