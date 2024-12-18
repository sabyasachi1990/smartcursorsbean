USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_MenuSetupUpdationforEngagement]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[Audit_MenuSetupUpdationforEngagement](@EngagementId uniqueidentifier,@Companyid bigint)
AS Begin	
		    
Begin Transaction
BEGIN TRY 		 
	BEGIN      
		Declare @PartnerCompanyid Bigint;
		Declare @AuditManualId Uniqueidentifier;
		Declare @EngagementTypeId Uniqueidentifier;
		Declare @acmmid Uniqueidentifier;
		Declare @auditmenumasterid Uniqueidentifier;
		Set @PartnerCompanyid=(select AccountingFirmId from Common.Company where Id=@CompanyId)
			IF @PartnerCompanyid IS NULL 
				BEGIN 
					set @PartnerCompanyid =@CompanyId;
				END
		Set @EngagementTypeId=(select EngagementTypeId from audit.AuditCompanyEngagement where id=@engagementId)
		Set @AuditManualId=(select AuditManualId from audit.AuditCompanyEngagement where id=@engagementId)

		DECLARE db_cursor CURSOR FOR 
			(select id,AuditMenuMasterId from audit.AuditCompanyMenuMaster where EngagementId is null and companyid=@PartnerCompanyid and AuditMenuMasterId  in (select id from audit.AuditMenuMaster where GroupName in ('Reporting','Summary','Financials')) and EngagementTypeId=@EngagementTypeId and AuditManualId=@AuditManualId ) 

		OPEN db_cursor  
		FETCH NEXT FROM db_cursor INTO @acmmid,@auditmenumasterid
			WHILE @@FETCH_STATUS = 0  
				Begin

					update audit.AuditCompanyMenuMaster set HelpLinkReferenceId=@acmmid where EngagementId=@EngagementId and AuditMenuMasterId=@auditmenumasterid

					FETCH NEXT FROM db_cursor INTO @acmmid,@auditmenumasterid

				END
		CLOSE db_cursor  
		DEALLOCATE db_cursor 
	END
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
