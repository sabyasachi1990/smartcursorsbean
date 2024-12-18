USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Audit_Partner]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_Audit_Partner] (@State nvarchar(20),@TypeId Uniqueidentifier,@type nvarchar(50),@companyId bigint)
AS BEGIN 
declare @id uniqueidentifier,
@code nvarchar(50),
@description nvarchar(600),
@status bit,
@Isplanning bit,
@IsCompletion bit,
@Referenceid uniqueidentifier,
@ShortCode nvarchar(50),
@WpsetupId uniqueidentifier,
@tichmarksetupId uniqueidentifier
Declare @Reference table (id uniqueidentifier,tichmarksetupId uniqueidentifier,status bit) 

  BEGIN TRANSACTION
  BEGIN TRY 
   
     IF(@TYPE='Tickmark Setup')--wf
      BEGIN  
          DECLARE @CID bigint
          SELECT @ID=ID,@CODE=CODE,@DESCRIPTION=[DESCRIPTION],@STATUS=[STATUS],@ISPLANNING=ISPLANNING,@ISCOMPLETION=ISCOMPLETION,@REFERENCEID=REFERENCEID
		  FROM AUDIT.TICKMARKSETUP  WHERE ID=@TYPEID
          If(@State='Insert')
          BEGIN

              DECLARE TICKCSR CURSOR FOR SELECT ID FROM COMMON.COMPANY where id in (select  companyid from Common.CompanyModule where ModuleId=3 and Status=1 and companyid in (select id from Common.company where accountingfirmid=@companyId))
              OPEN TICKCSR 
              FETCH NEXT FROM TICKCSR INTO @CID
              WHILE (@@FETCH_STATUS=0)
			  Begin
			   If Exists( select  Id from Common.CompanyModule where ModuleId=3 and Status=1 and CompanyId=@CID)
				   Begin
					   If Not Exists (Select Id from AUDIT.TickMarkSetup WHERE ReferenceId=@TYPEID and CompanyId=@CID)
						   Begin
								INSERT INTO AUDIT.TICKMARKSETUP(Id,CompanyId,Code,Description,IsSystem,Remarks,Recorder,CreatedDate,ModifiedBy,ModifiedDate,Status,IsPlanning,IsCompletion,ReferenceId)
								select NewId(),@CID,code,Description,IsSystem,Remarks,Recorder,Getdate(),ModifiedBy,ModifiedDate,Status,IsPlanning,IsCompletion,@TypeId 
								from AUDIT.TICKMARKSETUP  where ID=@TYPEID
						   End
				   End

              FETCH NEXT FROM TICKCSR INTO @CID
              End
              CLOSE TICKCSR
              DEALLOCATE TICKCSR
         End 
          If(@State='Update')
          UPDATE AUDIT.TICKMARKSETUP SET CODE=@CODE,DESCRIPTION=@DESCRIPTION,STATUS=@STATUS,ISPLANNING=@ISPLANNING,ISCOMPLETION=@ISCOMPLETION,REFERENCEID=@TYPEID WHERE REFERENCEID=@TYPEID
          If(@State='Delete')
          Delete AUDIT.TICKMARKSETUP where ReferenceId=@TypeId
      END

     IF(@TYPE='Suggestion Setup')
     BEGIN 
			Declare @ScreenName Nvarchar(100),@Section Nvarchar(100)
			select @id=Id,@ScreenName=ScreenName,@Section=Section,@description=Description,@Status=Status from common.[Suggestion ] where companyid=@companyId and id=@TypeId
			IF(@state='Insert')
			Begin
				 DECLARE SUSETUPCSR CURSOR FOR SELECT ID FROM COMMON.COMPANY where id in (select  companyid from Common.CompanyModule where ModuleId=3 and Status=1 and companyid in (select id from Common.company where accountingfirmid=@companyId))
				 OPEN SUSETUPCSR 
				 FETCH NEXT FROM SUSETUPCSR INTO @CID
				 WHILE (@@FETCH_STATUS=0)
				 BEGIN
					If Exists( select Id from Common.CompanyModule where ModuleId=3 and Status=1 and CompanyId=@CID)
					Begin
					   INSERT INTO Common.[Suggestion ](ID,companyid,screenName,Section,Title,Description,Remarks,Recorder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,STATUS,ReferenceId)
						 SELECT NEWID(),@CID,screenName,Section,Title,Description,Remarks,Recorder,UserCreated,GetDate(),ModifiedBy,ModifiedDate,Version,STATUS,ID  FROM 
						  Common.[Suggestion ] WHERE companyid=@companyId and id=@TypeId
					End
				 FETCH NEXT FROM SUSETUPCSR INTO @CID
				 END
				 CLOSE SUSETUPCSR
				 DEALLOCATE SUSETUPCSR
			  End
			IF(@state='Update')
				Update Common.[Suggestion] set ScreenName=@ScreenName,Section=@Section,Description=@description,Status= @status where ReferenceId=@id
			IF(@state='Delete')
			  Delete Common.[Suggestion]  where ReferenceId=@id
	End

     IF(@TYPE='WorkProgram Setup')
     BEGIN
			DECLARE @WPID UNIQUEIDENTIFIER
			DECLARE @New_ID UNIQUEIDENTIFIER
			Declare @TickMark_Id UNIQUEIDENTIFIER
			SELECT @ID=ID,@CODE=CODE,@DESCRIPTION=[DESCRIPTION],@STATUS=[STATUS],@SHORTCODE=SHORTCODE,@REFERENCEID=REFERENCEID FROM AUDIT.WPSETUP  WHERE ID=@TYPEID

			IF(@State='Insert')
			BEGIN
			  DECLARE WPCSR CURSOR FOR SELECT ID FROM COMMON.COMPANY where Id in (select  companyid from Common.CompanyModule where ModuleId=3 and Status=1 and companyid in (select id from Common.company where AccountingFirmId=@companyId))
			  OPEN WPCSR 
			  FETCH NEXT FROM WPCSR INTO @CID
			  WHILE (@@FETCH_STATUS=0)
			  Begin
				If Exists( select Id from Common.CompanyModule where ModuleId=3 and Status=1 and CompanyId=@CID)
					Begin
					 IF NOT Exists(Select Id from audit.wpsetup where ReferenceId=@typeid and CompanyId=@CID)
						 Begin 
							  Select @New_ID= newid() 
							   Insert into audit.WPSetup (Id,CompanyId,Code,Description,Remarks,RecOrder,CreatedDate,Version,Status,ShortCode,ReferenceId)
							   select @New_ID,@CID,Code,Description,Remarks,RecOrder,GETDATE(),Version,Status,ShortCode,Id from audit.WPSetup where Id=@TypeId
								 Begin

										DECLARE WPSETUPCSR CURSOR FOR SELECT ID FROM AUDIT.WPSETUPTICKMARK WHERE WPSetupId=@TypeId 
										OPEN WPSETUPCSR;
										FETCH NEXT FROM WPSETUPCSR INTO @TickMark_Id
										WHILE (@@FETCH_STATUS=0)
										BEGIN
											 INSERT INTO AUDIT.WPSETUPTICKMARK (ID,WPSETUPID,TICKMARKID,STATUS)
											  SELECT NEWID(),@New_ID,(select Id from audit.TickMarkSetup where companyid=@CID and referenceid=(select Tickmarkid from audit.WPSETUPTICKMARK where id=@TickMark_Id)),STATUS FROM  AUDIT.WPSETUPTICKMARK WHERE Id=@TickMark_Id
	                   
										FETCH NEXT FROM WPSETUPCSR INTO @TickMark_Id
										END
										CLOSE WPSETUPCSR
										DEALLOCATE WPSETUPCSR
								 End
						 End
					End

			  FETCH NEXT FROM WPCSR INTO @CID
			  END
			  CLOSE WPCSR
			  DEALLOCATE WPCSR

		  END
			If(@State='Update')
			Begin
 			   UPDATE AUDIT.WPSETUP SET CODE=@CODE,DESCRIPTION=@DESCRIPTION,STATUS=@STATUS,SHORTCODE=@SHORTCODE,REFERENCEID=@TYPEID WHERE REFERENCEID=@TYPEID
			 BEGIN
           
				DECLARE WPCSR CURSOR FOR SELECT ID FROM COMMON.COMPANY WHERE Accountingfirmid=@companyId
				OPEN WPCSR 
				FETCH NEXT FROM WPCSR INTO @CID
				WHILE (@@FETCH_STATUS=0)
				Begin
					
					Delete Audit.WPSetupTickmark where WPSetupId=(select Id from Audit.WPSetup where CompanyId=@CID and ReferenceId=@TypeId)
					--insert into audit.WPSetupTickmark(Id,WPSetupId,TickMarkId,Status)
					--SELECT NEWID(),(select Id from Audit.WPSetup where CompanyId=@CID and ReferenceId=@TypeId),(select Id from audit.TickMarkSetup where companyid=@CID and referenceid=(select Tickmarkid from audit.WPSETUPTICKMARK where wpsetupid=@TypeId)),STATUS FROM  AUDIT.WPSETUPTICKMARK WHERE WPSETUPID=@TypeId

						 DECLARE WPSETUPCSR CURSOR FOR SELECT ID FROM AUDIT.WPSETUPTICKMARK WHERE WPSetupId=@TypeId 
						 OPEN WPSETUPCSR;
						 FETCH NEXT FROM WPSETUPCSR INTO @TickMark_Id
						 WHILE (@@FETCH_STATUS=0)
						 BEGIN

							 INSERT INTO AUDIT.WPSETUPTICKMARK (ID,WPSETUPID,TICKMARKID,STATUS)
							 SELECT NEWID(),(select Id from Audit.WPSetup where CompanyId=@CID and ReferenceId=@TypeId),(select Id from audit.TickMarkSetup where companyid=@CID and referenceid=(select Tickmarkid from audit.WPSETUPTICKMARK where id=@TickMark_Id)),STATUS FROM  AUDIT.WPSETUPTICKMARK WHERE Id=@TickMark_Id

						 FETCH NEXT FROM WPSETUPCSR INTO @TickMark_Id
						 END
						 CLOSE WPSETUPCSR
						 DEALLOCATE WPSETUPCSR
	                 

				FETCH NEXT FROM WPCSR INTO @CID
				END
				CLOSE WPCSR
				DEALLOCATE WPCSR
			END	 
		 END
			If(@State='Delete')
			Begin
			   Delete Audit.WPSetupTickmark Where WPSetupId in(select id from AUDIT.WPSETUP where Id=@Typeid)   
			   Delete AUDIT.WPSETUP where Id=@Typeid
		   END
     END  

     IF(@TYPE='Leadsheet SetUp')
		BEGIN 
			declare @workprogramId uniqueidentifier,@workprogram nvarchar(50),@Index nvarchar(100),@leadsheettype nvarchar(100),
			@accountclass nvarchar(100),@leadsheetName nvarchar(100),@financialtemplate nvarchar(100),@leadsheetcategoryname nvarchar(100),@disclosure nvarchar(max);
			Declare @LeadsheetCategories_Name Nvarchar(100);

			If(@State='Insert')
			Begin
				 Declare LSCSR cursor for SELECT ID FROM COMMON.COMPANY where Id in (select  companyid from Common.CompanyModule where ModuleId=3 and Status=1 and companyid in (select id from Common.company where AccountingFirmId=@companyId))
				 Open LSCSR
				 Fetch next from  LSCSR into @CID
				 WHILE (@@FETCH_STATUS=0)
					Begin
						If Exists( select Id from Common.CompanyModule where ModuleId=3 and Status=1 and CompanyId=@CID)
						  Begin
							IF NOT Exists (select id from audit.LeadSheet where ReferenceId=@TypeId and CompanyId=@CID)
							BEGIN 
								Select @New_ID= newid() 

								INSERT INTO Audit.Leadsheet (ID,CompanyId,WorkProgramId,[Index],LeadsheetType,AccountClass,IsSystem,LeadSheetName,FinancialStatementTemplate,Remarks,RecOrder,Status, UserCreated,CreatedDate,ReferenceId,Disclosure)
								SELECT @New_ID,@CID,WorkProgramId,[Index],LeadsheetType,AccountClass,IsSystem,LeadSheetName,FinancialStatementTemplate,Remarks,RecOrder,Status,UserCreated,GetDate(),ID ,Disclosure 
								FROM  Audit.Leadsheet WHERE id=@TypeId

								Begin
										DECLARE LSCCSR CURSOR FOR SELECT ID,Name FROM AUDIT.LeadSheetCategories WHERE LeadsheetId=@TypeId
										OPEN LSCCSR 
										FETCH NEXT FROM LSCCSR INTO @ID,@LeadsheetCategories_Name
										WHILE (@@FETCH_STATUS=0)
											BEGIN
											INSERT INTO AUDIT.LeadSheetCategories (id,LeadsheetId,Name,RecOrder,Status,IsHide)
											SELECT NEWID(),@New_ID,@LeadsheetCategories_Name,RecOrder,STATUS,IsHide FROM  AUDIT.LeadSheetCategories WHERE Id=@ID

											FETCH NEXT FROM LSCCSR INTO @ID,@LeadsheetCategories_Name
											END
										CLOSE LSCCSR
										DEALLOCATE LSCCSR
								End

							END
						  END
						FETCH NEXT FROM LSCSR INTO @CID
					END
				 CLOSE LSCSR
				 DEALLOCATE LSCSR
				 End
  
			IF(@State='Update')
			Begin 
					SELECT @workprogramId=WorkProgramId,@index=[Index],@leadsheettype=LeadsheetType,@leadsheetName=LeadSheetName,@accountclass=AccountClass
					,@financialtemplate=FinancialStatementTemplate,@disclosure=Disclosure  from audit.LeadSheet where Id=@TypeId
					Declare LSCSR cursor for SELECT companyid FROM Audit.Leadsheet WHERE ReferenceId=@TypeId
					Open LSCSR
					Fetch next from  LSCSR into @CID
					while @@FETCH_STATUS=0
					Begin 

						Select @WPsetupid =(select id from audit.WPSetup where companyid=@CID and ReferenceId=(Select WorkProgramId from audit.leadsheet where id=@typeid))
						
						UPDATE AUDIT.LeadSheet set 
						[Index]=@Index,LeadsheetType=@leadsheettype,LeadSheetName=@leadsheetName,AccountClass=@accountclass,FinancialStatementTemplate=@financialtemplate
						,WorkProgramId=@WpsetupId,Disclosure=@disclosure WHERE ReferenceId=@TypeId and CompanyId=@CID

						DECLARE LeadsheetCSR CURSOR FOR SELECT id FROM AUDIT.Leadsheet WHERE ReferenceId=@TYPEID
						OPEN LeadsheetCSR 
						FETCH NEXT FROM LeadsheetCSR INTO @ID
						WHILE (@@FETCH_STATUS=0)
							BEGIN
								Delete AUDIT.LeadSheetCategories where LeadsheetId=@ID
								INSERT INTO AUDIT.LeadSheetCategories(ID,LeadsheetId,Name,RecOrder,Status,IsHide)
								SELECT NEWID(),@ID,Name,RecOrder,STATUS,IsHide FROM  AUDIT.LeadSheetCategories WHERE LeadsheetId=@TYPEID
								
								FETCH NEXT FROM LeadsheetCSR INTO @ID
							END
						CLOSE LeadsheetCSR
						DEALLOCATE LeadsheetCSR

					Fetch next from  LSCSR into @CID
					END
					Close LSCSR
					DEALLOCATE LSCSR
		   End
		END

     IF(@TYPE='Materiality Planning Setup')
		BEGIN 
			 Declare @UpdatecompanyId bigint,  @NewPlanningMaterialitySetupId uniqueidentifier,@NewPlanningMaterialitySetupDetailId uniqueidentifier,@secondId  uniqueidentifier,
			 @thirdId uniqueidentifier,@LeadSheetId uniqueidentifier;
		   IF(@STATE='Insert')
		   Begin

			   DECLARE @RATIONALE NVARCHAR(400),@RECORDER INT
			   DECLARE @NEW_ID1 UNIQUEIDENTIFIER;
    	  
				select @ShortCode=shortcode,@Rationale=Rationale,@description=Decsription,@RECORDER=RecOrder,@status=Status from audit.PlanningMaterialitySetup where Id=@TypeId							

					DECLARE  UpdatePlanningMaterialitySetup CURSOR FOR select Id from common.company where Id in (select  companyid from Common.CompanyModule where ModuleId=3 and Status=1 and companyid in (select id from Common.company where AccountingFirmId=@companyId))
					OPEN UpdatePlanningMaterialitySetup
					FETCH NEXT FROM UpdatePlanningMaterialitySetup INTO @UpdatecompanyId
					WHILE @@FETCH_STATUS = 0
					BEGIN			
						If Exists( select  Id from Common.CompanyModule where ModuleId=3 and Status=1 and CompanyId=@UpdatecompanyId)
						   Begin
							 If Exists( select  Id from Audit.LeadSheet where CompanyId=@UpdatecompanyId)
							   Begin
									INSERT INTO AUDIT.PLANNINGMATERIALITYSETUP(ID,COMPANYID,SHORTCODE,[DECSRIPTION],RATIONALE,RECORDER,USERCREATED,CREATEDDATE,STATUS,REFERENCEID)
									SELECT NEwID(),@UpdatecompanyId,SHORTCODE,[DECSRIPTION],RATIONALE,RECORDER,USERCREATED,GETDATE(),STATUS,@TYPEID  FROM AUDIT.PLANNINGMATERIALITYSETUP WHERE ID=@TYPEID
									--inner cursor for update detail								
									DECLARE  SavePlanningMaterialitySetupDetail CURSOR FOR select Id from Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId=@TypeId
									OPEN SavePlanningMaterialitySetupDetail
									FETCH NEXT FROM SavePlanningMaterialitySetupDetail INTO @secondId
									WHILE @@FETCH_STATUS = 0
									BEGIN																										
											   
										  select @NewPlanningMaterialitySetupDetailId = newid();

										  Insert into  AUDIT.[PlanningMaterialitySetupDetail] (Id,PlanningMaterialitySetupId,SystemType,IsNA,Type,Amount,LeadSheetShortCode,LeadSheeType,TypeName,Lowrange,HighRange,IsIncrementedByApplicable,IncrementedBy,IsAllowExceed,RecOrder)
										  Select @NewPlanningMaterialitySetupDetailId as Id,(select id from audit.PlanningMaterialitySetup where CompanyId=@UpdatecompanyId and referenceid=@typeid),SystemType,IsNA,Type,Amount,LeadSheetShortCode,LeadSheeType,TypeName,Lowrange,HighRange,IsIncrementedByApplicable,IncrementedBy,IsAllowExceed,RecOrder from Audit.[PlanningMaterialitySetupDetail] where Id=@secondId

																	--inner cursor for detail child detail							
													DECLARE  PlanningMaterialityLeadSheet CURSOR FOR select Id,LeadSheetId from Audit.PlanningMaterialityLeadSheet
													 where PlanningMaterialitySetupDetailId=@secondId

														OPEN PlanningMaterialityLeadSheet
														FETCH NEXT FROM PlanningMaterialityLeadSheet INTO @thirdId,@LeadSheetId
														WHILE @@FETCH_STATUS = 0
														BEGIN				
															  print @LeadSheetId;
															  Print @UpdatecompanyId;																				
															  INSERT INTO AUDIT.[PlanningMaterialityLeadSheet] (Id,PlanningMaterialitySetupDetailId,LeadSheetId,Recorder)
															  Select NewId(),@NewPlanningMaterialitySetupDetailId,
															  (select Id from Audit.LeadSheet where CompanyId=@UpdatecompanyId and ReferenceId=@LeadSheetId),
															  RecOrder from Audit.PlanningMaterialityLeadSheet where Id=@thirdId												
														
														FETCH NEXT FROM PlanningMaterialityLeadSheet INTO @thirdId,@LeadSheetId	
														END														
														CLOSE PlanningMaterialityLeadSheet
														DEALLOCATE PlanningMaterialityLeadSheet
												
									FETCH NEXT FROM SavePlanningMaterialitySetupDetail INTO @secondId
									END
									CLOSE SavePlanningMaterialitySetupDetail
									DEALLOCATE SavePlanningMaterialitySetupDetail
								End
							End
					
					FETCH NEXT FROM UpdatePlanningMaterialitySetup INTO @UpdatecompanyId
					END
					CLOSE UpdatePlanningMaterialitySetup
					DEALLOCATE UpdatePlanningMaterialitySetup
			END 
		
   
		  IF(@STATE='Update')
			  Begin

				select @ShortCode=shortcode,@Rationale=Rationale,@description=Decsription,@RECORDER=RecOrder,@status=Status from audit.PlanningMaterialitySetup where Id=@TypeId							

				DECLARE  UpdatePlanningMaterialitySetup CURSOR FOR select CompanyId,Id from Audit.PlanningMaterialitySetup where ReferenceId=@TypeId
				OPEN UpdatePlanningMaterialitySetup
				FETCH NEXT FROM UpdatePlanningMaterialitySetup INTO @UpdatecompanyId,@Id
				WHILE @@FETCH_STATUS = 0
				BEGIN																										
					If Exists(select  Id from audit.leadsheet where companyid=@UpdatecompanyId)
						Begin
							Update audit.PlanningMaterialitySetup set ShortCode=@ShortCode,Rationale=@Rationale,decsription=@description,RecOrder=@RECORDER,Status=@status,ReferenceId=@TypeId 
							where ReferenceId=@TypeId and CompanyId=@UpdatecompanyId

							--need to delete detail and child detail
							delete Audit.PlanningMaterialityLeadSheet where PlanningMaterialitySetupDetailId in (select Id from  Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId=@Id)
							delete Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId=@Id

							--inner cursor for update detail								
							DECLARE  SavePlanningMaterialitySetupDetail CURSOR FOR select Id from Audit.PlanningMaterialitySetupDetail where PlanningMaterialitySetupId=@TypeId
							OPEN SavePlanningMaterialitySetupDetail
							FETCH NEXT FROM SavePlanningMaterialitySetupDetail INTO @secondId
							WHILE @@FETCH_STATUS = 0
							BEGIN																										
						    
									select @NewPlanningMaterialitySetupDetailId = newid();

									insert into  AUDIT.[PlanningMaterialitySetupDetail] (Id,PlanningMaterialitySetupId,SystemType,IsNA,Type,Amount,LeadSheetShortCode,LeadSheeType,TypeName,Lowrange,HighRange,IsIncrementedByApplicable,IncrementedBy,IsAllowExceed,RecOrder)
									Select @NewPlanningMaterialitySetupDetailId as Id,@Id,SystemType,IsNA,Type,Amount,LeadSheetShortCode,LeadSheeType,TypeName,Lowrange,HighRange,IsIncrementedByApplicable,IncrementedBy,
									IsAllowExceed,RecOrder from Audit.[PlanningMaterialitySetupDetail] where Id=@secondId

											--inner cursor for detail child detail							
											DECLARE  PlanningMaterialityLeadSheet CURSOR FOR select Id,LeadSheetId from Audit.PlanningMaterialityLeadSheet
												where PlanningMaterialitySetupDetailId=@secondId
													OPEN PlanningMaterialityLeadSheet
													FETCH NEXT FROM PlanningMaterialityLeadSheet INTO @thirdId,@LeadSheetId
													WHILE @@FETCH_STATUS = 0
													BEGIN																								
														INSERT INTO AUDIT.[PlanningMaterialityLeadSheet] (Id,PlanningMaterialitySetupDetailId,LeadSheetId,Recorder)
														Select NewId(),@NewPlanningMaterialitySetupDetailId,
														(select Id from Audit.LeadSheet where CompanyId=@UpdatecompanyId and ReferenceId=@LeadSheetId),
														RecOrder from Audit.PlanningMaterialityLeadSheet where Id=@thirdId												
														
												FETCH NEXT FROM PlanningMaterialityLeadSheet INTO @thirdId,@LeadSheetId	
												END														
												CLOSE PlanningMaterialityLeadSheet
												DEALLOCATE PlanningMaterialityLeadSheet
							
							FETCH NEXT FROM SavePlanningMaterialitySetupDetail INTO @secondId
							END
							CLOSE SavePlanningMaterialitySetupDetail
							DEALLOCATE SavePlanningMaterialitySetupDetail
						End
				FETCH NEXT FROM UpdatePlanningMaterialitySetup INTO @UpdatecompanyId,@Id
				END
				CLOSE UpdatePlanningMaterialitySetup
				DEALLOCATE UpdatePlanningMaterialitySetup
			  END 
	  END
 
    COMMIT TRANSACTION
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
End
GO
