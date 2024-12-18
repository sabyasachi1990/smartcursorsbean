USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_FSTemplatesSeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--for copy permissions SP in FS Templates



CREATE  Procedure [dbo].[SP_FSTemplatesSeedData]  
@MasterId uniqueidentifier,
@CompanyId bigInt,
@FromId uniqueidentifier
As
Begin 

--Declare @PARTNER_COMPANYID bigint;
DECLARE @OldDisclosureId uniqueidentifier,
		@OldSectionId Uniqueidentifier,
		@OldDetailId uniqueidentifier,
        @NewDisclosureId uniqueidentifier,
		@NewSectionId Uniqueidentifier,
        @LeadsheetId Uniqueidentifier,
		@NewdDisclosureDetailId Uniqueidentifier,
		@NewParentId  Uniqueidentifier,
		@OldParentId  Uniqueidentifier,
		@FirstParentId  Uniqueidentifier,
		@NewPolicyId Uniqueidentifier,
		@PolicyId Uniqueidentifier,
		@PolicyDetailId Uniqueidentifier;



-------------------------------Auditors,directors,Reporting Templates-----------------------

 If ((Select count(*) from Audit.Template where  CompanyId=@CompanyId and (EngagementId is null or EngagementId='00000000-0000-0000-0000-000000000000') and FSTemplateId=@MasterId)=0)
			Begin
				Insert Into Audit.Template (id,Name,Code,CompanyId,EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,EngagementType,EngagementName,EffectiveFrom,EffectiveTo,SectionName,ReferenceId,IsFinancialsTemplate,FSTemplateId)
				Select  NEWID(),Name,Code,@CompanyId,EngagementId,FromEmailId,CcEmailIds,BccEmailIds,ToEmailId,Subject,TempletContent,Remarks,UserCreated,
				GETDATE(),ModifiedBy,ModifiedDate,RecOrder,Version,Status,ScreenName,GenericTemplateId,IsTemplate,IsMaster,IsRollForward,AuditCompanyId,
				EngagementType,EngagementName,GETDATE(),EffectiveTo,SectionName,ReferenceId,IsFinancialsTemplate,@MasterId 
				--from Audit.Template where CompanyId=@CompanyId and (EngagementId is null or EngagementId='00000000-0000-0000-0000-000000000000') and Status=1 and FSTemplateId is null
				from Audit.Template where  status=1 and  CompanyId=@CompanyId and (EngagementId is null or EngagementId='00000000-0000-0000-0000-000000000000') and Status=1 and FSTemplateId=@FromId
			End


		-----------Account Policy--------------------------------------
		 If ((Select count(*) from Audit.AccountPolicy where CompanyId=@CompanyId and 
				(EngagementId is null or EngagementId='00000000-0000-0000-0000-000000000000') and FSTemplateId=@MasterId)=0)
			Begin
				DECLARE AccountpolicyCSR cursor for 
				--select id from Audit.AccountPolicy where CompanyId=@CompanyId and 
				--(EngagementId is null or EngagementId='00000000-0000-0000-0000-000000000000') and Status=1 and FSTemplateId is null
				select id from Audit.AccountPolicy where CompanyId=@CompanyId and 
				(EngagementId is null or EngagementId='00000000-0000-0000-0000-000000000000') and Status=1 and FSTemplateId=@FromId
				OPEN AccountpolicyCSR
				FETCH NEXT FROM   AccountpolicyCSR into @PolicyId
				WHILE (@@FETCH_STATUS=0)
					BEGIN
						set @NewPolicyId=NEWID();
							Insert Into Audit.AccountPolicy (Id,CompanyId,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Section,PolicyNameId,IsRollForward,SectionName,FSTemplateId)
							Select @NewPolicyId,@companyId,EngagementId,PolicyName,PolicyTemplate,IsChecked,IsSytem,Remarks,RecOrder,UserCreated,
							GETDATE(),ModifiedBy,ModifiedDate,Version,Status,Section,PolicyNameId,IsRollForward,SectionName,@MasterId 
							 from Audit.AccountPolicy where Id=@PolicyId and Status=1
		    
								DECLARE AccountpolicyDetailCSR cursor for
								 select id from Audit.AccountPolicyDetail where MasterId=@PolicyId and IsChecked=1
								OPEN AccountpolicyDetailCSR
								FETCH NEXT FROM   AccountpolicyDetailCSR into @PolicydetailId
								WHILE (@@FETCH_STATUS=0)
									BEGIN
										Insert Into Audit.AccountPolicyDetail (Id,MasterId,PolicyName,PolicyTemplate,IsChecked,IsSytem,RecOrder,Status,PolicyNameId,EffectiveFrom,EffectiveTo)
										select NEWID(),@NewPolicyId,PolicyName,PolicyTemplate,IsChecked,IsSytem,RecOrder,Status,@PolicyDetailId,EffectiveFrom,
										EffectiveTo  from Audit.AccountPolicyDetail where id=@PolicyDetailId and Status=1
									FETCH NEXT FROM   AccountpolicyDetailCSR into @PolicydetailId
									END
								CLOSE AccountpolicyDetailCSR
								DEALLOCATE AccountpolicyDetailCSR
					FETCH NEXT FROM   AccountpolicyCSR into @PolicyId
					END
				CLOSE AccountpolicyCSR
				DEALLOCATE AccountpolicyCSR
			END




-------------------------------------Notes--------------------------

 DECLARE LEADSHEETCSR CURSOR FOR 
   --SELECT DisclosureId FROM Audit.ReportingTemplates WHERE PartnerCompanyId=@CompanyId and EngagementId is null and FSTemplateId is null
    SELECT DisclosureId FROM Audit.ReportingTemplates WHERE PartnerCompanyId=@CompanyId and EngagementId is null and FSTemplateId=@FromId
	  OPEN LEADSHEETCSR 
      FETCH NEXT FROM LEADSHEETCSR INTO @LeadsheetId
	  WHILE (@@FETCH_STATUS=0)
	  BEGIN

	-- DisClosure Cursor
		DECLARE DISCLOSURECSR CURSOR FOR 
		SELECT ID FROM Audit.Disclosure WHERE CompanyId=@CompanyId and Id=@LeadsheetId
		OPEN DISCLOSURECSR 
		FETCH NEXT FROM DISCLOSURECSR INTO @OldDisclosureId
		WHILE (@@FETCH_STATUS=0)
		BEGIN
           SET @NewDisclosureId =NEWID();
           INSERT INTO AUDIT.Disclosure(Id,CompanyId,EngagementId,LeadSheetId,IsDisclosure,IsPublish,YearDates,NAME,RecOrder,TemplateName,BaseCurrency,IsChanged,ScreenName)
		   SELECT @NewDisclosureId,@CompanyId,EngagementId,LeadSheetId,IsDisclosure,IsPublish,YearDates,NAME,RecOrder,TemplateName,BaseCurrency,IsChanged,
		   ScreenName from AUDIT.Disclosure  where Id=@OldDisclosureId  

		    INSERT INTO AUDIT.[ReportingTemplates] (Id,PartnerCompanyId,EngagementId,TemplateName,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,EffectiveFrom,EffectiveTo,DisclosureId,
			typeId,FSTemplateId)
		   SELECT NEWID(),@CompanyId,EngagementId,TemplateName,'System',GetDate(),ModifiedBy,Null,Status,EffectiveFrom,EffectiveTo,@NewDisclosureId,Id,@MasterId
		    from AUDIT.[ReportingTemplates] where Status=1 and PartnerCompanyId=@CompanyId and EngagementId is null AND DisclosureId=@OldDisclosureId
		   -- DisclosureSections Cursor
		   DECLARE DISCLOSURESECTIONCSR CURSOR FOR 
		   SELECT ID FROM Audit.DisclosureSections WHERE DisclosureId=@OldDisclosureId
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
		             SELECT @NewdDisclosureDetailId,@NewDisclosureId,CategoryId,Type,Name,FinalAmount,PriorYearAmount,IsSystem,IsModified,Recorder,@NewSectionId,ColumnsData,IsLable,CategoryName,IspriorYear,SubTypeName,Status,CommonId,GroupTypeId from AUDIT.DisclosureDetails where  DisclosureId=@OldDisclosureId and Id=@OldDetailId  and Status=1
					
					 Set @OldParentId=(select ParentId from Audit.SubCategory where TypeId=@OldDetailId) 
					
					If(@FirstParentId <> ISNULL(@OldParentId,NEWID()))
					   Begin
					     Set @NewParentId=NEWID();
					   End
					
					 set @FirstParentId=@OldParentId;
				
					 Insert Into Audit.SubCategory (Id,Name,CategoryId,Recorder,Type,EngagementId,TypeId,LeadsheetGroup,SubCategoryOrder,ParentId,IsIncomeStatement,ColorCode,AccountClass,IsCollapse)
					 select NEWID(),Name,CategoryId,Recorder,Type,EngagementId,@NewdDisclosureDetailId,LeadsheetGroup,SubCategoryOrder,@NewParentId,IsIncomeStatement,
					 ColorCode,AccountClass,IsCollapse from  Audit.SubCategory where TypeId=@OldDetailId  
				
					 if not exists (select id from Audit.Category where  EngagementId is null and  ISNULL(Updateid,NEWID())=@OldParentId)
					    Begin
						 Insert Into Audit.Category (Id,EngagementId,Name,Type,Recorder,IsIncomeStatement,LeadsheetId,ColorCode,AccountClass,IsCollapse,SectionId,UpdateId)
							Select @NewParentId,EngagementId,Name,Type,Recorder,IsIncomeStatement,LeadsheetId,ColorCode,AccountClass,IsCollapse,@NewSectionId,
							@OldParentId from Audit.Category where id=@OldParentId  
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
End


 

















GO
