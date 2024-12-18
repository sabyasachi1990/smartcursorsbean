USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_RollForward_Tax]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[Proc_RollForward_Tax](@Old_Engagement_ID UNIQUEIDENTIFIER,@NEW_Engagement_ID UNIQUEIDENTIFIER,@FD_IsChecked BIT,@RI_IsChecked BIT,@NI_IsChecked BIT,@CA_IsChecked BIT,@S14Q_IsChecked BIT,@CF_IsChecked BIT)
AS

BEGIN  

--Note
DECLARE @STATUS  INT,@CREATED_DATE DATETIME,@NoteId UNIQUEIDENTIFIER,@Code NVARCHAR(max),@Description NVARCHAR(max),@LinkTo nvarchar(max),@RecOrder int,@Remarks nvarchar(256),@WPShortCode nvarchar(50),@FeatureName NVARCHAR(100),@FeatureSection nvarchar(100),@NOTE_STATUS INT

--Capital Allowance --old
   --DECLARE  @Old_SectionAId UNIQUEIDENTIFIER,@OutStandingTaxLife int,@TaxCompanyId uniqueidentifier,@CompanyId int,@TWDVCarryForward decimal,@TypeOfClaim NVARCHAR(100),@TypeOfPurchase NVARCHAR(100),@YearOfPurchase INT,@IsPartialdisposal BIT,@AssetClassification NVARCHAR(100),@AssetDecription NVARCHAR(256),@ClaimFormat NVARCHAR(20),@

   ---new 27th Jun---
   --Capital Allowance
   DECLARE  @Old_SectionAId UNIQUEIDENTIFIER,@OutStandingTaxLife int,@TaxCompanyId uniqueidentifier,@CompanyId int,@TWDVCarryForward decimal,@TypeOfClaim NVARCHAR(100),@TypeOfPurchase NVARCHAR(100),@YearOfPurchase INT,@IsPartialdisposal BIT,@AssetClassification NVARCHAR(100),@AssetDecription NVARCHAR(256),@DateOfPurchase datetime2 ,@NetCostofAsset decimal ,@GrantAmount decimal,@EnhancedNetCostofAsset decimal,@Enhancedpercentage INT,@CapitalAllowanceId UNIQUEIDENTIFIER,@CostOfAsset decimal,@AutoComputeBySystem BIT,@IsExist BIT,@IsPICQualified BIT,@PICCashPayout NVARCHAR(20),@ClaimFormat NVARCHAR(20),@PICUnder NVARCHAR(100),@PICId UNIQUEIDENTIFIER,@CreatedDate datetime2

--AccountAnnotation 
DECLARE @AccountId UNIQUEIDENTIFIER,@AccountAnnotation_STATUS INT

DECLARE @AnnotationTypeId UNIQUEIDENTIFIER,@AccountName nvarchar(256)
SET @STATUS = 1    
SET @CREATED_DATE = GETUTCDATE() 
--SET @Old_Engagement_ID ='FF633ED9-6215-438A-8600-D3AB27E0D0E3'
--SET @NEW_Engagement_ID   =  '5C95A09A-C0CD-41A3-BE17-BD007699E1FB'
DECLARE @Annotation_Type  nvarchar(50)
DECLARE @Section14Q_ID UNIQUEIDENTIFIER = (SELECT Id  FROM [TAX].[SECTION14Q] WHERE ENGAGEMENTID=@Old_Engagement_ID)
DECLARE @Fd_ID UNIQUEIDENTIFIER = (SELECT Id  FROM [TAX].[FurtherDeduction] WHERE ENGAGEMENTID=@Old_Engagement_ID)
DECLARE @NTI_ID UNIQUEIDENTIFIER = (SELECT Id  FROM [TAX].[NonTradeIncome] WHERE ENGAGEMENTID=@Old_Engagement_ID)
DECLARE @RI_ID UNIQUEIDENTIFIER = (SELECT Id  FROM [TAX].[RentalIncome] WHERE ENGAGEMENTID=@Old_Engagement_ID)
DECLARE @NEW_FDID UNIQUEIDENTIFIER = NEWID()
DECLARE @NEW_NTIID UNIQUEIDENTIFIER = NEWID()
DECLARE @NEW_RIID UNIQUEIDENTIFIER = NEWID()
DECLARE @NEW_SECTION14QID UNIQUEIDENTIFIER = NEWID()
--DECLARE @SectionA_ID UNIQUEIDENTIFIER = (SELECT Id  FROM [TAX].[SectionA] WHERE ENGAGEMENTID=@Old_Engagement_ID)
 DECLARE @FD_FeatureName NVARCHAR(100) ='Appendix-3-FurtherDeductions'
--SET @Section14Q_ID = (SELECT Id  FROM [TAX].[SECTION14Q] WHERE ENGAGEMENTID=@Old_Engagement_ID)
SET @Annotation_Type = 'Attachment'
BEGIN TRANSACTION
	BEGIN TRY


		--========= ROLLFORWARD ====================

		INSERT INTO Tax.RollForward(Id,OldEngagementId,NewEngagementId,CreatedDate)
		VALUES(NEWID(),@Old_Engagement_ID,@NEW_Engagement_ID,@CREATED_DATE)

		DECLARE notecursor CURSOR FOR SELECT Id,code,Description,LinkTo,RecOrder,Remarks,FeatureName,FeatureSection,WPShortCode,Status FROM Tax.Note WHERE EngagementId=@Old_Engagement_ID AND Status <> 4  --AND FeatureName <> @FD_FeatureName

		--=========== NOTES ==========================

		OPEN notecursor FETCH NEXT FROM notecursor INTO @NoteId,@Code,@Description,@LinkTo,@RecOrder,@Remarks,@FeatureName,@FeatureSection,@WPShortCode,@NOTE_STATUS
			WHILE @@FETCH_STATUS >= 0
			BEGIN 
				 DECLARE @New_Id  UNIQUEIDENTIFIER  = NEWID()
				 DECLARE @NEW_FD_ID UNIQUEIDENTIFIER = NEWID()				
 
				IF(@FD_IsChecked = 1 AND @FeatureName = 'Appendix-3-FurtherDeductions')
				BEGIN
					--INSERT INTO Tax.Note (Id,Code,Description,LinkTo,RecOrder,Remarks,FeatureName,FeatureSection,EngagementId,CreatedDate,Status,WPShortCode,IsRollForward)
					--VALUES(@New_Id,@Code,@Description,@LinkTo,@RecOrder,@Remarks,@FeatureName,@FeatureSection,@NEW_Engagement_ID,@CREATED_DATE,@NOTE_STATUS,@WPShortCode,1)

					---For Doc repository table---
					--INSERT INTO Common.DocRepository (Id,CompanyId,TypeId,[Type],ModuleName,FilePath,DisplayFileName,Description,FileSize,CreatedDate,FileExt,ShortName,ReferenceId,MongoFilesId)
					-- SELECT NEWID(),CompanyId,@New_Id,[Type],ModuleName,FilePath,DisplayFileName,Description,FileSize,GETDATE(),FileExt,ShortName,@NEW_Engagement_ID,MongoFilesId From [Common].[DocRepository] where ReferenceId=@Old_Engagement_ID and TypeId=@NoteId  

					INSERT INTO [Tax].[AccountAnnotation] (Id, AnnotationTypeId,Status, EngagementId,AnnotationType,FeatureName) 
					 --values(NEWID(), @New_Id,@AccountName,@STATUS,@NEW_Engagement_ID [Tax].[AccountAnnotation] where EngagementId=@Old_Engagement_ID and AnnotationTypeId=@NoteId
					SELECT NEWID(), @New_Id,Status,@NEW_Engagement_ID,AnnotationType,FeatureName From [Tax].[AccountAnnotation] where EngagementId=@Old_Engagement_ID and AnnotationTypeId=@NoteId
					

				END
				ELSE IF(@FeatureName != 'Appendix-3-FurtherDeductions')
				BEGIN
					--INSERT INTO Tax.Note (Id,Code,Description,LinkTo,RecOrder,Remarks,FeatureName,FeatureSection,EngagementId,CreatedDate,Status,WPShortCode,IsRollForward)
					--VALUES(@New_Id,@Code,@Description,@LinkTo,@RecOrder,@Remarks,@FeatureName,@FeatureSection,@NEW_Engagement_ID,@CREATED_DATE,@NOTE_STATUS,@WPShortCode,1)

					---For Doc repository table---
					--INSERT INTO Common.DocRepository (Id,CompanyId,TypeId,[Type],ModuleName,FilePath,DisplayFileName,Description,FileSize,CreatedDate,FileExt,ShortName,ReferenceId,MongoFilesId)
					-- SELECT NEWID(),CompanyId,@New_Id,[Type],ModuleName,FilePath,DisplayFileName,Description,FileSize,GETDATE(),FileExt,ShortName,@NEW_Engagement_ID,MongoFilesId From [Common].[DocRepository] where ReferenceId=@Old_Engagement_ID and TypeId=@NoteId  

					INSERT INTO [Tax].[AccountAnnotation] (Id, AnnotationTypeId,Status, EngagementId,AnnotationType,FeatureName) 
					--values(NEWID(), @New_Id,@AccountName,@STATUS,@NEW_Engagement_ID [Tax].[AccountAnnotation] where EngagementId=@Old_Engagement_ID and AnnotationTypeId=@NoteId
					SELECT NEWID(), @New_Id,Status,@NEW_Engagement_ID,AnnotationType,FeatureName From [Tax].[AccountAnnotation] where EngagementId=@Old_Engagement_ID and AnnotationTypeId=@NoteId
				END
			FETCH NEXT FROM notecursor INTO @NoteId,@Code,@Description,@LinkTo,@RecOrder,@Remarks,@FeatureName,@FeatureSection,@WPShortCode,@NOTE_STATUS
			END
		CLOSE notecursor
		DEALLOCATE notecursor

		-----Cursor for AccountAnnotation Attachments ----------2nd june---New
			DECLARE AccountAnnotationCursor CURSOR FOR SELECT  AnnotationTypeId,Status,AnnotationType,FeatureName FROM Tax.AccountAnnotation where EngagementId=@Old_Engagement_ID AND AnnotationType=@Annotation_Type and status <> 4

			
		    OPEN AccountAnnotationCursor FETCH NEXT FROM AccountAnnotationCursor INTO @AnnotationTypeId,@AccountAnnotation_STATUS,@Annotation_Type,@FeatureName
			WHILE @@FETCH_STATUS >= 0
			BEGIN 
				 DECLARE @Doc_Id  UNIQUEIDENTIFIER  = NEWID();
				IF(@FD_IsChecked = 1 AND @FeatureName = 'Appendix-3-FurtherDeductions')
			    BEGIN	
				    --(Id, AnnotationTypeId,Status, EngagementId,AccountName,AnnotationType,FeatureName) 			
					INSERT INTO Tax.AccountAnnotation(Id,AnnotationTypeId,[Status],CreatedDate,AnnotationType,FeatureName,EngagementId,FeatureId)
					VALUES(NEWID(),@Doc_Id,@AccountAnnotation_STATUS,@CREATED_DATE,@Annotation_Type,@FeatureName,@NEW_Engagement_ID,@NEW_Engagement_ID)

					---accounts docs ---
					---For Doc repository table---
					INSERT INTO Common.DocRepository (Id,CompanyId,TypeId,[Type],ModuleName,FilePath,DisplayFileName,Description,FileSize,CreatedDate,FileExt,ShortName,ReferenceId,MongoFilesId)
					 SELECT @Doc_Id,CompanyId,NEWID(),[Type],ModuleName,FilePath,DisplayFileName,Description,FileSize,GETDATE(),FileExt,ShortName,@NEW_Engagement_ID,MongoFilesId From [Common].[DocRepository] where ReferenceId=@Old_Engagement_ID AND id=@AnnotationTypeId AND  Status <> 4    

			   END
			   ELSE IF(@FeatureName != 'Appendix-3-FurtherDeductions')
			    BEGIN	
				    --(Id, AnnotationTypeId,Status, EngagementId,AccountName,AnnotationType,FeatureName) 			
					INSERT INTO Tax.AccountAnnotation(Id,AnnotationTypeId,[Status],CreatedDate,AnnotationType,FeatureName,EngagementId,FeatureId)
					VALUES(NEWID(),@Doc_Id,@AccountAnnotation_STATUS,@CREATED_DATE,@Annotation_Type,@FeatureName,@NEW_Engagement_ID,@NEW_Engagement_ID)

					---accounts docs ---
					---For Doc repository table---
					INSERT INTO Common.DocRepository (Id,CompanyId,TypeId,[Type],ModuleName,FilePath,DisplayFileName,Description,FileSize,CreatedDate,FileExt,ShortName,ReferenceId,MongoFilesId)
					 SELECT @Doc_Id,CompanyId,NEWID(),[Type],ModuleName,FilePath,DisplayFileName,Description,FileSize,GETDATE(),FileExt,ShortName,@NEW_Engagement_ID,MongoFilesId From [Common].[DocRepository] where ReferenceId=@Old_Engagement_ID AND id=@AnnotationTypeId AND  Status <> 4    

			   END

                FETCH NEXT FROM AccountAnnotationCursor INTO @AnnotationTypeId,@AccountAnnotation_STATUS,@Annotation_Type,@FeatureName
	            END
				CLOSE AccountAnnotationCursor
		       DEALLOCATE AccountAnnotationCursor

	 --  ----------Cursor for CapitalAllowance------------
		--DECLARE capitalallowancecursor CURSOR FOR SELECT Id,OutStandingTaxLife,TaxCompanyId,TWDVCarryForward,TypeOfClaim,TypeOfPurchase,YearOfPurchase,IsPartialdisposal,AssetClassification,AssetDecription,ClaimFormat FROM Tax.SectionA where EngagementId=@Old_Engagement_ID AND (TWDVCARRYFORWARD > 0  OR OUTSTANDINGTAXLIFE >= 0) AND (ISPARTIALDISPOSAL IS NULL OR ISPARTIALDISPOSAL=1)

		----============ CAPITAL ALLOWANCE ==============
		--OPEN capitalallowancecursor FETCH NEXT FROM capitalallowancecursor INTO @Old_SectionAId,@OutStandingTaxLife,@TaxCompanyId,@TWDVCarryForward,@TypeOfClaim,@TypeOfPurchase,@YearOfPurchase,@IsPartialdisposal,@AssetClassification,@AssetDecription,@ClaimFormat
	
	
		----============FOR GETTING COMPANYID ============
		--DECLARE @TAX_COMPANYID UNIQUEIDENTIFIER = (SELECT TAXCOMPANYID FROM TAX.TAXCOMPANYENGAGEMENT WHERE ID= @NEW_ENGAGEMENT_ID) 
		--DECLARE @COMPANY_ID INT = (SELECT COMPANYID FROM TAX.TAXCOMPANY WHERE ID = @TAX_COMPANYID) 

		--WHILE @@FETCH_STATUS >= 0
		--BEGIN 
		-- DECLARE @NEW_SECTIONAID UNIQUEIDENTIFIER = NEWID()
		--	IF(@CA_IsChecked = 1)
		--	BEGIN
		--		 --INSERT INTO [Tax].[SectionA] (Id,EngagementId,CompanyId,OutStandingTaxLife,Status,TaxCompanyId,TWDVBroughtForward,TypeOfClaim,TypeOfPurchase,YearOfPurchase,IsExist)
		--		 --VALUES(@NEW_SECTIONAID,@NEW_Engagement_ID,@CompanyId,@OutStandingTaxLife,@STATUS,@TaxCompanyId,@TWDVCarryForward,@TypeOfClaim,@TypeOfPurchase,@YearOfPurchase,1)

  --             ---27th Jun Newly Added NetCostofAsset,EnhancedNetCostofAsset
		--     IF(@OutStandingTaxLife=0)	
		--	 BEGIN		 
		--		  INSERT INTO [Tax].[SectionA] (Id,EngagementId,CompanyId,OutStandingTaxLife,Status,TaxCompanyId,TWDVBroughtForward,TypeOfClaim,TypeOfPurchase,YearOfPurchase,IsRollForward,IsPartialdisposal,AssetClassification,AssetDecription,ClaimFormat,NetCostofAsset,EnhancedNetCostofAsset)
		--			 VALUES(@NEW_SECTIONAID,@NEW_Engagement_ID,@Company_Id,@OutStandingTaxLife,@STATUS,@TaxCompanyId,@TWDVCarryForward,@TypeOfClaim,@TypeOfPurchase,@YearOfPurchase,1,@IsPartialdisposal,@AssetClassification,@AssetDecription,@ClaimFormat)
		--	 END
		--	 ELSE
		--	 BEGIN
		--		 INSERT INTO [Tax].[SectionA] (Id,EngagementId,CompanyId,OutStandingTaxLife,Status,TaxCompanyId,TWDVBroughtForward,TypeOfClaim,TypeOfPurchase,YearOfPurchase,IsRollForward,IsPartialdisposal,AssetClassification,AssetDecription,ClaimFormat,NetCostofAsset,EnhancedNetCostofAsset)
		--		 VALUES(@NEW_SECTIONAID,@NEW_Engagement_ID,@Company_Id,@OutStandingTaxLife-1,@STATUS,@TaxCompanyId,@TWDVCarryForward,@TypeOfClaim,@TypeOfPurchase,@YearOfPurchase,1,@IsPartialdisposal,@AssetClassification,@AssetDecription,@ClaimFormat)
		--	 END

		--		 INSERT INTO [Tax].[SectionADetail] (Id,SECTIONAId,YearOfAccessment,PrincipalPaid,Recorder) 
		--		 SELECT NEWID(),@NEW_SECTIONAID,YearOfAccessment,PrincipalPaid,Recorder from [Tax].[SectionADetail] where SECTIONAId = @Old_SectionAId
 
		--		 INSERT INTO [Tax].[SectionB] (Id,SECTIONAId,YearOfAccessment,Amount,AnnualAllowance,DeferAnnualAllowance,DisposalAmount,InitialAllowence,Recorder,Remarks,TotalAnnualAllowance,TWDV,TWDVBroughtForward,Year) SELECT NEWID (),@NEW_SECTIONAID,YearOfAccessment,Amount,AnnualAllowance,DeferAnnualAllowance,DisposalAmount,InitialAllowence,Recorder,Remarks,TotalAnnualAllowance,TWDV,TWDVBroughtForward,Year from[Tax].[SectionB] where SECTIONAId = @Old_SectionAId

		--		 --Disposal 
		--		 INSERT INTO [TAX].[DISPOSAL] (ID,SECTIONAID,DATEOFDISPOSAL,COST,TAXWDV,BALALLOWANCE,RECORDER,ASSETDESCRIPTION,IsRollForward,SALESPROCEEDS)SELECT NEWID(),@NEW_SECTIONAID,DATEOFDISPOSAL,COST,TAXWDV,BALALLOWANCE,RECORDER,ASSETDESCRIPTION,1,SALESPROCEEDS FROM [TAX].[DISPOSAL] WHERE SECTIONAID=@Old_SectionAId 
		--	END
		--FETCH NEXT FROM capitalallowancecursor into @Old_SectionAId,@OutStandingTaxLife,@TaxCompanyId,@TWDVCarryForward,@TypeOfClaim,@TypeOfPurchase,@YearOfPurchase,@IsPartialdisposal,@AssetClassification,@AssetDecription,@ClaimFormat
		--END

		--CLOSE capitalallowancecursor
		--DEALLOCATE capitalallowancecursor

		------------**NEW**-27th Jun---------

				DECLARE capitalallowancecursor CURSOR FOR SELECT Id,OutStandingTaxLife,TaxCompanyId,TWDVCarryForward,TypeOfClaim,TypeOfPurchase,YearOfPurchase,IsPartialdisposal,AssetClassification,AssetDecription,DateOfPurchase,NetCostofAsset,GrantAmount,EnhancedNetCostofAsset,Enhancedpercentage,CapitalAllowanceId,CostOfAsset,AutoComputeBySystem,IsExist,IsPICQualified,PICCashPayout,ClaimFormat,PICUnder,PICId,RecOrder,CreatedDate  FROM Tax.SectionA where EngagementId=@Old_Engagement_ID AND (TWDVCARRYFORWARD > 0  OR OUTSTANDINGTAXLIFE >= 0) AND (ISPARTIALDISPOSAL IS NULL OR ISPARTIALDISPOSAL=1)

		--============ CAPITAL ALLOWANCE ==============
		OPEN capitalallowancecursor FETCH NEXT FROM capitalallowancecursor INTO @Old_SectionAId,@OutStandingTaxLife,@TaxCompanyId,@TWDVCarryForward,@TypeOfClaim,@TypeOfPurchase,@YearOfPurchase,@IsPartialdisposal,@AssetClassification,@AssetDecription,@DateOfPurchase,@NetCostofAsset,@GrantAmount,@EnhancedNetCostofAsset,@Enhancedpercentage,@CapitalAllowanceId,@CostOfAsset,@AutoComputeBySystem,@IsExist,@IsPICQualified,@PICCashPayout,@ClaimFormat,@PICUnder,@PICId,@RecOrder,@CreatedDate
		--============FOR GETTING COMPANYID ============
		DECLARE @TAX_COMPANYID UNIQUEIDENTIFIER = (SELECT TAXCOMPANYID FROM TAX.TAXCOMPANYENGAGEMENT WHERE ID= @NEW_ENGAGEMENT_ID) 
		DECLARE @COMPANY_ID INT = (SELECT COMPANYID FROM TAX.TAXCOMPANY WHERE ID = @TAX_COMPANYID) 

		DECLARE @year_Of_Assessment INT = (SELECT yearOfAssessment FROM TAX.TAXCOMPANYENGAGEMENT WHERE ID= @NEW_ENGAGEMENT_ID) 
		
		DECLARE @TWDV_CarryForward  DECIMAL;

		WHILE @@FETCH_STATUS >= 0
		BEGIN 
		 DECLARE @NEW_SECTIONAID UNIQUEIDENTIFIER = NEWID()
			IF(@CA_IsChecked = 1)
			BEGIN
	           		
				 --INSERT INTO [Tax].[SectionA] (Id,EngagementId,CompanyId,OutStandingTaxLife,Status,TaxCompanyId,TWDVBroughtForward,TypeOfClaim,TypeOfPurchase,YearOfPurchase,IsExist)
				 --VALUES(@NEW_SECTIONAID,@NEW_Engagement_ID,@CompanyId,@OutStandingTaxLife,@STATUS,@TaxCompanyId,@TWDVCarryForward,@TypeOfClaim,@TypeOfPurchase,@YearOfPurchase,1)
				 IF(@ClaimFormat='FMT-1')
				 BEGIN
				   SET @TWDV_CarryForward = (SELECT TWDV FROM TAX.SECTIONB WHERE SECTIONAID=@Old_SectionAId AND YEAROFACCESSMENT=@YEAR_OF_ASSESSMENT)   
				 END
				 ELSE
				 BEGIN
				   SET @TWDV_CarryForward   = (SELECT TWDV FROM TAX.SECTIONB WHERE SECTIONAID=@Old_SectionAId AND Year=@YEAR_OF_ASSESSMENT)  
				 END  
		     --IF(@OutStandingTaxLife=0)	
			 BEGIN		 
				  INSERT INTO [Tax].[SectionA] (Id,EngagementId,CompanyId,OutStandingTaxLife,Status,TaxCompanyId,TWDVBroughtForward,TypeOfClaim,TypeOfPurchase,YearOfPurchase,IsRollForward,IsPartialdisposal,AssetClassification,AssetDecription,DateOfPurchase,NetCostofAsset,GrantAmount,EnhancedNetCostofAsset,Enhancedpercentage,CapitalAllowanceId,CostOfAsset,AutoComputeBySystem,IsExist,IsPICQualified,PICCashPayout,ClaimFormat,PICUnder,PICId,Recorder,TWDVCarryForward,CreatedDate)
					 VALUES(@NEW_SECTIONAID,@NEW_Engagement_ID,@Company_Id,@OutStandingTaxLife,@STATUS,@TaxCompanyId,@TWDVCarryForward,@TypeOfClaim,@TypeOfPurchase,@YearOfPurchase,1,@IsPartialdisposal,@AssetClassification,@AssetDecription,@DateOfPurchase,@NetCostofAsset,@GrantAmount,@EnhancedNetCostofAsset,@Enhancedpercentage,@CapitalAllowanceId,@CostOfAsset,@AutoComputeBySystem,1,@IsPICQualified,@PICCashPayout,@ClaimFormat,@PICUnder,@PICId,@RecOrder,@TWDV_CarryForward,@CreatedDate)
			 END
			 --ELSE
			 --BEGIN
				-- INSERT INTO [Tax].[SectionA] (Id,EngagementId,CompanyId,OutStandingTaxLife,Status,TaxCompanyId,TWDVBroughtForward,TypeOfClaim,TypeOfPurchase,YearOfPurchase,IsRollForward,IsPartialdisposal,AssetClassification,AssetDecription,DateOfPurchase,NetCostofAsset,GrantAmount,EnhancedNetCostofAsset,Enhancedpercentage,CapitalAllowanceId,CostOfAsset,AutoComputeBySystem,IsExist,IsPICQualified,PICCashPayout,ClaimFormat,PICUnder,PICId,Recorder,TWDVCarryForward)
				-- VALUES(@NEW_SECTIONAID,@NEW_Engagement_ID,@Company_Id,@OutStandingTaxLife-1,@STATUS,@TaxCompanyId,@TWDVCarryForward,@TypeOfClaim,@TypeOfPurchase,@YearOfPurchase,1,@IsPartialdisposal,@AssetClassification,@AssetDecription,@DateOfPurchase,@NetCostofAsset,@GrantAmount,@EnhancedNetCostofAsset,@Enhancedpercentage,@CapitalAllowanceId,@CostOfAsset,@AutoComputeBySystem,1,@IsPICQualified,@PICCashPayout,@ClaimFormat,@PICUnder,@PICId,@RecOrder,@TWDV_CarryForward)
			 --END

				 INSERT INTO [Tax].[SectionADetail] (Id,SECTIONAId,YearOfAccessment,PrincipalPaid,Recorder) 
				 SELECT NEWID(),@NEW_SECTIONAID,YearOfAccessment,PrincipalPaid,Recorder from [Tax].[SectionADetail] where SECTIONAId = @Old_SectionAId
 

				 INSERT INTO [Tax].[SectionB] (Id,SECTIONAId,YearOfAccessment,Amount,AnnualAllowance,DeferAnnualAllowance,DisposalAmount,InitialAllowence,Recorder,Remarks,TotalAnnualAllowance,TWDV,TWDVBroughtForward,Year) SELECT NEWID (),@NEW_SECTIONAID,YearOfAccessment,Amount,AnnualAllowance,DeferAnnualAllowance,DisposalAmount,InitialAllowence,Recorder,Remarks,TotalAnnualAllowance,TWDV,TWDVBroughtForward,Year from[Tax].[SectionB] where SECTIONAId = @Old_SectionAId


				 

				 --Disposal 
				 INSERT INTO [TAX].[DISPOSAL] (ID,SECTIONAID,DATEOFDISPOSAL,COST,TAXWDV,BALALLOWANCE,RECORDER,ASSETDESCRIPTION,IsRollForward,SALESPROCEEDS)SELECT NEWID(),@NEW_SECTIONAID,DATEOFDISPOSAL,0,TAXWDV,BALALLOWANCE,RECORDER,ASSETDESCRIPTION,1,SALESPROCEEDS FROM [TAX].[DISPOSAL] WHERE SECTIONAID=@Old_SectionAId 
			END
		FETCH NEXT FROM capitalallowancecursor into @Old_SectionAId,@OutStandingTaxLife,@TaxCompanyId,@TWDVCarryForward,@TypeOfClaim,@TypeOfPurchase,@YearOfPurchase,@IsPartialdisposal,@AssetClassification,@AssetDecription,@DateOfPurchase,@NetCostofAsset,@GrantAmount,@EnhancedNetCostofAsset,@Enhancedpercentage,@CapitalAllowanceId,@CostOfAsset,@AutoComputeBySystem,@IsExist,@IsPICQualified,@PICCashPayout,@ClaimFormat,@PICUnder,@PICId,@RecOrder,@CreatedDate 
		END

		CLOSE capitalallowancecursor
		DEALLOCATE capitalallowancecursor


		 ----============== WORKPROGRAM ATTACHMENTS  ================= commented  30th may 		 

		 --INSERT INTO [Tax].[AccountAnnotation] (Id, AnnotationTypeId,Status, EngagementId,AnnotationType) 
		 --SELECT NEWID(), AnnotationTypeId,@STATUS,@NEW_Engagement_ID,AnnotationType From [Tax].[AccountAnnotation] where EngagementId=@Old_Engagement_ID and AnnotationType=@Annotation_Type AND FeatureName != @FD_FeatureName AND Status=1


		 ----newly Added 30th may 		 	 

		---For Further Deductions General Doc repository table---

		---AND [Type] != N'AP-1 Acceptance of Client and Engagement Checklist' AND [Type] != N'AP-2 Continuance of Client and Engagement Checklist'  AND [Type] != N'AP-3 Client Engagement Independence Confirmation'

		 INSERT INTO Common.DocRepository (Id,CompanyId,TypeId,[Type],ModuleName,FilePath,DisplayFileName,Description,FileSize,CreatedDate,FileExt,ShortName,ReferenceId,MongoFilesId)
					 SELECT NEWID(),CompanyId,@NEW_Engagement_ID,[Type],ModuleName,FilePath,DisplayFileName,Description,FileSize,GETDATE(),FileExt,ShortName,@NEW_Engagement_ID,MongoFilesId From [Common].[DocRepository] where ReferenceId=@Old_Engagement_ID AND [status] != 4 AND [Type] != N'Appendix-3-FurtherDeductions' AND [Type] != N'Note Attachments' AND [Type] != N'Revenue' AND  [Type] != N'Question Attachments' AND [Type] != N'Other comprehensive income'
					 AND [Type] != N'Tax expense'
					 AND [Type] != N'Finance income'
					  AND [Type] != N'Finance costs'
					 AND [Type] != N'Other income'
					  AND [Type] != N'Other expenses'
					 AND [Type] != N'Direct costs'

		 --=============== RENTALINCOME =============================

		 IF(@RI_IsChecked=1)
		 BEGIN
			 INSERT INTO [Tax].[RentalIncome] (Id,Status,EngagementId,LinkTo) 
			 SELECT @NEW_RIID,@STATUS,@NEW_Engagement_ID,LinkTo From [Tax].[RentalIncome] where EngagementId=@Old_Engagement_ID and id=@RI_ID
			
			 insert into tax.RentalIncomeDetail(Id,RentalIncomeId,ItemDescription,Amount,Type,ProfitAndLossImportId,SplitId,Recorder,IsManual)
			 select NEWID(),@NEW_RIID,ItemDescription,Amount,Type,ProfitAndLossImportId,SplitId,Recorder,IsManual From [Tax].[RentalIncomeDetail] where RentalIncomeId=@RI_ID
		 END

		 --================= NONTRADEINCOME ===========================

		 IF(@NI_IsChecked=1)
		 BEGIN
			 INSERT INTO [Tax].[NonTradeIncome] (Id,EngagementId,LinkTo) 
			 SELECT @NEW_NTIID,@NEW_Engagement_ID,LinkTo From [Tax].[NonTradeIncome] where EngagementId=@Old_Engagement_ID  and id=@NTI_ID

			 Insert into Tax.NonTradeIncomeDetail(Id,NonTradeIncomeId,NatureId,ItemDescription,Amount,NatureOfIncome,ProfitAndLossImportId,SplitId,Recorder,IsManual,AnnotationName)
			 SELECT NEWID(),@NEW_NTIID,NatureId,ItemDescription,Amount,NatureOfIncome,ProfitAndLossImportId,SplitId,Recorder,IsManual,AnnotationName from Tax.NonTradeIncomeDetail where NonTradeIncomeId=@NTI_ID

		 END

		 --================== FURTHER DEDUCTION SPREADSHEET ============

		 IF(@FD_IsChecked=1)
		 BEGIN
			INSERT INTO [Tax].[FurtherDeduction] (Id,EngagementId,LinkTo) 
			SELECT @NEW_FDID,@NEW_Engagement_ID,LinkTo From [Tax].[FurtherDeduction] where EngagementId=@Old_Engagement_ID and id=@Fd_ID

			Insert into Tax.FurtherDeductionDetail(Id,FurtherDeductionId,NatureId,AccountName,Amount,NatureofDeduction,ProfitAndLossImportId,SplitId,Recorder,EnhancedAmount,EnhancedPercentage,Annotation,IsManual)
			SELECT NEWID(),@NEW_FDID,NatureId,AccountName,Amount,NatureofDeduction,ProfitAndLossImportId,SplitId,recorder,EnhancedAmount,EnhancedPercentage,Annotation,IsManual from Tax.FurtherDeductionDetail where FurtherDeductionId=@Fd_ID

		 END

		 --=================== SECTION14Q ===============================

		 IF(@S14Q_IsChecked=1)
		 BEGIN
			INSERT INTO [Tax].[Section14Q] (Id,EngagementId,MaximumClaimForBlock,RemainingClaim,FirstYAStart,NumberOfYAForBlock,IsRollForward) 
			SELECT @NEW_SECTION14QID,@NEW_Engagement_ID,MaximumClaimForBlock,RemainingClaim,FirstYAStart,NumberOfYAForBlock,1 From [Tax].[Section14Q] where EngagementId=@Old_Engagement_ID and Id=@Section14Q_ID

			INSERT INTO [Tax].[Section14QDetails] (Id,Section14QId,YAOfPurchase,OutStandingTaxLife,OpeningBalance,Recorder) 
			SELECT NEWID(),@NEW_SECTION14QID,YAOfPurchase,OutStandingTaxLife-1,ClosingBalance,Recorder From [Tax].[Section14QDetails] where Section14QId=@Section14Q_ID AND ClosingBalance >0 AND OutStandingTaxLife > 0
		
			INSERT INTO [Tax].[Section14QEligibleExp] (Id,Section14QId,YearOfAssesment,AllowableAmount,DisAllowableAmount,RemainingClaim) 
			SELECT NEWID(),@NEW_SECTION14QID,YearOfAssesment,AllowableAmount,DisAllowableAmount,RemainingClaim From [Tax].[Section14QEligibleExp] where Section14QId=@Section14Q_ID
		 END

		 --=================== FURTHER DEDUCTION ========================

		 ----[ATTACHMENTS]--
		 IF(@FD_IsChecked = 1)
		 BEGIN
	 		INSERT INTO [Tax].[AccountAnnotation] (Id, AnnotationTypeId,Status, EngagementId,AccountName,AnnotationType,FeatureName) 
	 		SELECT NEWID(), AnnotationTypeId,@STATUS,@NEW_Engagement_ID,AccountName,AnnotationType,FeatureName From [Tax].[AccountAnnotation] where EngagementId=@Old_Engagement_ID and AnnotationType=@Annotation_Type AND FeatureName = @FD_FeatureName AND Status=1
		 END

		 --==================== CARRY FORWARD ============================

		 IF(@CF_IsChecked = 1) 
		 BEGIN
	 		INSERT INTO [Tax].[CarryForward] (Id,BalanceBroughtFwd,YearOfAssesment,EngagementId,Type) 
	 		SELECT NEWID(), BalanceCarryFwd,YearOfAssesment,@NEW_Engagement_ID,Type from [Tax].[CarryForward] where EngagementId=@Old_Engagement_ID AND  BalanceCarryFwd >0
		 END

	END TRY
	BEGIN CATCH
		DECLARE
				@ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;

		SELECT
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

		ROLLBACK TRANSACTION
	END CATCH

BEGIN
	COMMIT TRANSACTION
END

END   -- SP END
GO
