USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AuditNotesRefresh]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[Proc_AuditNotesRefresh](@CompanyId bigint,@EngagementId uniqueidentifier)
AS BEGIN
Declare @PARTNER_COMPANYID bigint;
DECLARE @OldDisclosureId uniqueidentifier,
		@OldSectionId Uniqueidentifier,
		@OldDetailId uniqueidentifier; 
DECLARE @NewDisclosureId uniqueidentifier,
		@NewSectionId Uniqueidentifier,
        @LeadsheetId Uniqueidentifier,
		@NewdDisclosureDetailId Uniqueidentifier,
		@NewParentId  Uniqueidentifier,
		@OldParentId  Uniqueidentifier,
		@FirstParentId  Uniqueidentifier;

declare @StartDate datetime,
        @YearEndDate datetime;

    Select @StartDate=StartDate,@YearEndDate=YearEndDate from Audit.AuditCompanyEngagement where id=@EngagementId

 	Set @PARTNER_COMPANYID=(select AccountingFirmId from Common.Company where Id=@CompanyId)
	IF @PARTNER_COMPANYID IS NULL 
	BEGIN 
			SET @PARTNER_COMPANYID=@CompanyId
	END
Begin Transaction
BEGIN TRY

	IF @PARTNER_COMPANYID IS NOT NULL
	  DECLARE LEADSHEETCSR CURSOR FOR  SELECT DisclosureId FROM Audit.ReportingTemplates WHERE id not in (select TypeId FROM Audit.ReportingTemplates where EngagementId=@engagementId) and  PartnerCompanyId=@PARTNER_COMPANYID and EngagementId is null  
	  OPEN LEADSHEETCSR 
      FETCH NEXT FROM LEADSHEETCSR INTO @LeadsheetId
	  WHILE (@@FETCH_STATUS=0)
	  BEGIN

	-- DisClosure Cursor
		DECLARE DISCLOSURECSR CURSOR FOR SELECT ID FROM Audit.Disclosure WHERE CompanyId=@PARTNER_COMPANYID and Id=@LeadsheetId
		OPEN DISCLOSURECSR 
		FETCH NEXT FROM DISCLOSURECSR INTO @OldDisclosureId
		WHILE (@@FETCH_STATUS=0)
		BEGIN
           SET @NewDisclosureId =NEWID();
           INSERT INTO AUDIT.Disclosure(Id,CompanyId,EngagementId,LeadSheetId,IsDisclosure,IsPublish,YearDates,NAME,RecOrder,TemplateName,BaseCurrency,IsChanged,ScreenName)
		   SELECT @NewDisclosureId,@CompanyId,@EngagementId,LeadSheetId,IsDisclosure,IsPublish,YearDates,NAME,RecOrder,TemplateName,BaseCurrency,IsChanged,
		   ScreenName from AUDIT.Disclosure  where Id=@OldDisclosureId

		    INSERT INTO AUDIT.[ReportingTemplates] (Id,PartnerCompanyId,EngagementId,TemplateName,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,EffectiveFrom,EffectiveTo,DisclosureId,TypeId,TemplateStatus)
		   SELECT NEWID(),@CompanyId,@EngagementId,TemplateName,'System',GetDate(),ModifiedBy,Null,Status,EffectiveFrom,EffectiveTo,@NewDisclosureId,Id,'New' from AUDIT.[ReportingTemplates] where PartnerCompanyId=@PARTNER_COMPANYID and EngagementId is null and ((EffectiveFrom <=@StartDate and (EffectiveTo is null  or EffectiveTo >= @StartDate ))) AND DisclosureId=@OldDisclosureId
		   -- DisclosureSections Cursor
		   DECLARE DISCLOSURESECTIONCSR CURSOR FOR SELECT ID FROM Audit.DisclosureSections WHERE DisclosureId=@OldDisclosureId
	       OPEN DISCLOSURESECTIONCSR 
	       FETCH NEXT FROM DISCLOSURESECTIONCSR INTO @OldSectionId
	       WHILE (@@FETCH_STATUS=0)
		   BEGIN 
				Set @NewSectionId =NEWID();
				Set @NewParentId=NEWID();
				set @FirstParentId=NEWID();
				
				INSERT INTO AUDIT.DisclosureSections (Id,DisclosureId,IsGrandTotal,IsContainColumns,ColumnNames,GrandTotalName,Type,PriorYear,CurrentYear,IsChanged,ScreenName,PriorYearTotalName,CurrentYearTotalName,Recorder,PriorYearCurrency,CurrentYearCurrency)
		         SELECT    @NewSectionId,@NewDisclosureId,IsGrandTotal,IsContainColumns,ColumnNames,GrandTotalName,Type,PriorYear,CurrentYear,IsChanged,ScreenName,PriorYearTotalName,CurrentYearTotalName,Recorder,PriorYearCurrency,CurrentYearCurrency from AUDIT.DisclosureSections  where ID=@OldSectionId 
				 -- DisclosureDetails Cursor---
				 DECLARE DISCLOSUREDETAILCSR CURSOR FOR SELECT ads.ID FROM 
				 Audit.DisclosureDetails ads left join 
				 Audit.SubCategory as subc on subc.TypeId = ads.id
			     WHERE ads.DisclosureId=@OldDisclosureId and ads.SectionId=@OldSectionId  order by subc.ParentId
	             OPEN DISCLOSUREDETAILCSR 
	             FETCH NEXT FROM DISCLOSUREDETAILCSR INTO @OldDetailId
	             WHILE (@@FETCH_STATUS=0)
			     BEGIN 
				 Set @NewdDisclosureDetailId=NEWID();
					
					INSERT INTO AUDIT.DisclosureDetails(Id,DisclosureId,CategoryId,Type,Name,FinalAmount,PriorYearAmount,IsSystem,IsModified,Recorder,SectionId,ColumnsData,IsLable,CategoryName,IspriorYear,SubTypeName,Status,CommonId,GroupTypeId)
		             SELECT @NewdDisclosureDetailId,@NewDisclosureId,CategoryId,Type,Name,FinalAmount,PriorYearAmount,IsSystem,IsModified,Recorder,@NewSectionId,ColumnsData,IsLable,CategoryName,IspriorYear,SubTypeName,Status,CommonId,GroupTypeId from AUDIT.DisclosureDetails where  DisclosureId=@OldDisclosureId and Id=@OldDetailId  
					
					 Set @OldParentId=(select ParentId from Audit.SubCategory where TypeId=@OldDetailId) 
					
					If(@FirstParentId <> ISNULL(@OldParentId,NEWID()))
					   Begin
					     Set @NewParentId=NEWID();
					   End
					
					 set @FirstParentId=@OldParentId;
				
					 Insert Into Audit.SubCategory (Id,Name,CategoryId,Recorder,Type,EngagementId,TypeId,LeadsheetGroup,SubCategoryOrder,ParentId,IsIncomeStatement,ColorCode,AccountClass,IsCollapse)
					 select NEWID(),Name,CategoryId,Recorder,Type,@EngagementId,@NewdDisclosureDetailId,LeadsheetGroup,SubCategoryOrder,@NewParentId,IsIncomeStatement,ColorCode,AccountClass,IsCollapse from  Audit.SubCategory where TypeId=@OldDetailId
				
					 if not exists (select id from Audit.Category where  EngagementId= @EngagementId and  ISNULL(Updateid,NEWID())=@OldParentId)
					    Begin
						 Insert Into Audit.Category (Id,EngagementId,Name,Type,Recorder,IsIncomeStatement,LeadsheetId,ColorCode,AccountClass,IsCollapse,SectionId,UpdateId)
							Select @NewParentId,@EngagementId,Name,Type,Recorder,IsIncomeStatement,LeadsheetId,ColorCode,AccountClass,IsCollapse,@NewSectionId,@OldParentId from Audit.Category where id=@OldParentId
						End
				
				
					 FETCH NEXT FROM DISCLOSUREDETAILCSR INTO @OldDetailId
		         END
		         CLOSE DISCLOSUREDETAILCSR
                 DEALLOCATE DISCLOSUREDETAILCSR
				 
		         FETCH NEXT FROM DISCLOSURESECTIONCSR INTO @OldSectionId
		   END
		   CLOSE DISCLOSURESECTIONCSR
           DEALLOCATE DISCLOSURESECTIONCSR
		   
		   FETCH NEXT FROM DISCLOSURECSR INTO @OldDisclosureId
		END
		CLOSE DISCLOSURECSR
		DEALLOCATE DISCLOSURECSR
	 FETCH NEXT FROM LEADSHEETCSR INTO @LeadsheetId
	 END
	 CLOSE LEADSHEETCSR
	 DEALLOCATE LEADSHEETCSR
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
