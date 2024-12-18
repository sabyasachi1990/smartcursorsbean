USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Audit_ReportingSetUp]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Audit_ReportingSetUp](@CompanyId bigint,@EngagementId uniqueidentifier)
AS BEGIN
Declare @PARTNER_COMPANYID bigint;
Declare @PolicyId uniqueidentifier;
Declare @NewPolicyId uniqueidentifier;
Declare @PolicyDetailId uniqueidentifier;
Declare @FsTemplateId uniqueidentifier;

Declare @StartDate datetime, @YearEndDate datetime,@EngagementType nvarchar(300);

    Select @StartDate=StartDate,@YearEndDate=YearEndDate,@EngagementType=EngagementType,@FsTemplateId=FSTemplateId from Audit.AuditCompanyEngagement where id=@EngagementId

 	Set @PARTNER_COMPANYID=(select AccountingFirmId from Common.Company where Id=@CompanyId)
	IF @PARTNER_COMPANYID IS NULL 
	BEGIN 
			SET @PARTNER_COMPANYID=@CompanyId
	END
Begin Transaction
	BEGIN TRY

		IF @PARTNER_COMPANYID IS NOT NULL
	 
		 ----------------Auditors ,Director Statement---------------
		 --If ((Select count(*) from Audit.Template where EngagementId=@EngagementId and CompanyId=@CompanyId)=0)
			--Begin
			--	Insert Into Audit.Template (id,Name,Code,CompanyId,EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName,ReferenceId)
			--	Select  NEWID(),Name,Code,@CompanyId,@EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,GETDATE(),ModifiedBy,ModifiedDate,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,@EngagementType,EngagementName,GETDATE(),EffectiveTo,SectionName,Id from Audit.Template where CompanyId=@PARTNER_COMPANYID and (EngagementId is null or EngagementId='00000000-0000-0000-0000-000000000000')  and ((EffectiveFrom <=@StartDate and (EffectiveTo is null  or EffectiveTo >= @StartDate ))) and Status=1
			--End
-----------------------------------FS Templates -----
			 If ((Select count(*) from Audit.Template where EngagementId=@EngagementId and CompanyId=@CompanyId)=0)
			Begin
				Insert Into Audit.Template (id,Name,Code,CompanyId,EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName,ReferenceId,IsFinancialsTemplate)
				Select  NEWID(),Name,Code,@CompanyId,@EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,GETDATE(),ModifiedBy,ModifiedDate,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,@EngagementType,EngagementName,GETDATE(),EffectiveTo,SectionName,Id,IsFinancialsTemplate from Audit.Template where CompanyId=@PARTNER_COMPANYID and (EngagementId is null or EngagementId='00000000-0000-0000-0000-000000000000')  and FSTemplateId=@FsTemplateId and Status=1 and IsFinancialsTemplate=1
			End
		
		-----------Account Policy---------------
		 If ((Select count(*) from Audit.AccountPolicy where EngagementId=@EngagementId and CompanyId=@CompanyId)=0)
			Begin
				DECLARE AccountpolicyCSR cursor for select id from Audit.AccountPolicy where CompanyId=@PARTNER_COMPANYID and (EngagementId is null or EngagementId='00000000-0000-0000-0000-000000000000') and Status=1 and IsChecked=1 and FSTemplateId=@FsTemplateId
				OPEN AccountpolicyCSR
				FETCH NEXT FROM   AccountpolicyCSR into @PolicyId
				WHILE (@@FETCH_STATUS=0)
					BEGIN
						set @NewPolicyId=NEWID();
							Insert Into Audit.AccountPolicy (Id,CompanyId,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Section,PolicyNameId,IsRollForward,SectionName)
							Select @NewPolicyId,@companyId,@engagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,GETDATE(),ModifiedBy,ModifiedDate,Version,Status,Section,@PolicyId,IsRollForward,SectionName  from Audit.AccountPolicy where Id=@PolicyId
		    
								DECLARE AccountpolicyDetailCSR cursor for select id from Audit.AccountPolicyDetail where MasterId=@PolicyId and IsChecked=1
								OPEN AccountpolicyDetailCSR
								FETCH NEXT FROM   AccountpolicyDetailCSR into @PolicydetailId
								WHILE (@@FETCH_STATUS=0)
									BEGIN
										Insert Into Audit.AccountPolicyDetail (Id,MasterId,PolicyName,PolicyTemplate,IsChecked,IsSytem,RecOrder,Status,PolicyNameId,EffectiveFrom,EffectiveTo)
										select NEWID(),@NewPolicyId,PolicyName,PolicyTemplate,IsChecked,IsSytem,RecOrder,Status,@PolicyDetailId,EffectiveFrom,EffectiveTo  from Audit.AccountPolicyDetail where id=@PolicyDetailId
									FETCH NEXT FROM   AccountpolicyDetailCSR into @PolicydetailId
									END
								CLOSE AccountpolicyDetailCSR
								DEALLOCATE AccountpolicyDetailCSR
					FETCH NEXT FROM   AccountpolicyCSR into @PolicyId
					END
				CLOSE AccountpolicyCSR
				DEALLOCATE AccountpolicyCSR
			END


    
     Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@EngagementId,'AccountpolicyInserted','Success',9)

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
