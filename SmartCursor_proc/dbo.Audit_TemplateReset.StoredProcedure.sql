USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_TemplateReset]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Audit_TemplateReset](@TemplateId NVARCHAR(50),@DeleteType NVARCHAR(20),@EngagementId uniqueidentifier)
AS
BEGIN
DECLARE @ID UNIQUEIDENTIFIER,
@AnnotationTypeId UNIQUEIDENTIFIER,
@AnnotationType NVARCHAR(50);

     BEGIN TRANSACTION
     BEGIN TRY
	           ---Delete templates with out annotaions (attchment icon)
	           Insert into Audit.AuditTemplateReset(Id,TemplateId,EngagementId,FilePath,FileName)
			   select NewID(),@TemplateId,@EngagementId,FilePath,DisplayFileName from  Common.DocRepository where MongoFilesId=@TemplateId 
			   Delete Common.DocRepository where MongoFilesId=@TemplateId

	          DECLARE DELETE_CSR CURSOR FOR SELECT ID,AnnotationType,AnnotationTypeId from Audit.AccountAnnotation where templateId=@TemplateId and EngagementId=@EngagementId
              OPEN DELETE_CSR
              FETCH NEXT FROM DELETE_CSR INTO @ID,@AnnotationType,@AnnotationTypeId
              WHILE(@@FETCH_STATUS=0)
              BEGIN
			   --IF (@AnnotationType='Note' and @DeleteType='Full')
			   ---delete attchment icons attachments
			
			   IF (@AnnotationType='Note')
			         BEGIN

				           
						   ---Note Attchments
						   if(@DeleteType='Full')
						   Begin 
				               Insert into Audit.AuditTemplateReset(Id,TemplateId,EngagementId,FilePath,FileName)
						       select NewID(),@TemplateId,@EngagementId,FilePath,DisplayFileName from  Common.DocRepository where TypeId=@AnnotationTypeId 
						       Delete Common.DocRepository where TypeId=@AnnotationTypeId  
						   End

						   ---Note Adjustments
						   if(@DeleteType='Full')
						   Begin
						      --Note Adjustments Attachments
						      Insert into Audit.AuditTemplateReset(Id,TemplateId,EngagementId,FilePath,FileName)
						      select NEWID(),@TemplateId,@EngagementId,FilePath,DisplayFileName from  Common.DocRepository where TypeId in (select AdjustmentId  from   Audit.NoteAdjustment where NoteId=@AnnotationTypeId) 
						      Delete Common.DocRepository where TypeId in (select AdjustmentId from Audit.NoteAdjustment where NoteId=@AnnotationTypeId) 
						   
						     Delete Audit.AdjustmentAccount where AdjustmentID in (select AdjustmentId from Audit.NoteAdjustment where NoteId=@AnnotationTypeId) 
						   End
						   if(@DeleteType='Full')
						     Begin
							     Declare @temp table(id uniqueidentifier)
								 Insert into @temp
								 select AdjustmentId from Audit.NoteAdjustment where NoteId=@AnnotationTypeId

								 Delete Audit.NoteAdjustment where NoteId=@AnnotationTypeId
			        	         --Delete Audit.Adjustment where Id in (select AdjustmentId from Audit.NoteAdjustment where NoteId=@AnnotationTypeId)
								 Delete Audit.Adjustment where Id in (select id from  @temp)
						     End
						  --else if(@DeleteType='Partial')
						  --   Begin
        --            	         Update Audit.Adjustment set IsProposed=0,IsMake=0,IsWaive=0,IsDisable=1,Reference=null,Explanation=null where Id in (select AdjustmentId from Audit.NoteAdjustment where NoteId=@AnnotationTypeId)
						  --   End 


                        if(@DeleteType='Full')
						Begin
						   ----GridTemplate Attachment
						   Insert into Audit.AuditTemplateReset(Id,TemplateId,EngagementId,FilePath,FileName)
						   select NEWID(),@TemplateId,@EngagementId,FilePath,DisplayFileName from  Common.DocRepository where Id in (select AnnotationTypeId from Audit.AccountAnnotation where ParentId=@AnnotationTypeId and AnnotationType='Attachment') 
						   Delete Common.DocRepository where Id in (select AnnotationTypeId from Audit.AccountAnnotation where ParentId=@AnnotationTypeId and AnnotationType='Attachment') 

						   ---Note--- Grid--Note--Attachments

						   Insert into Audit.AuditTemplateReset(Id,TemplateId,EngagementId,FilePath,FileName)
						   select NEWID(),@TemplateId,@EngagementId,FilePath,DisplayFileName from  Common.DocRepository where TypeId in (select AnnotationTypeId from Audit.AccountAnnotation where ParentId=@AnnotationTypeId and AnnotationType='Note') 
						   Delete Common.DocRepository where TypeId in (select AnnotationTypeId from Audit.AccountAnnotation where ParentId= @AnnotationTypeId and AnnotationType='Note') 
							  
                            ----Note --Grid --Comments
							Delete Common.Comment where TypeId in (select AnnotationTypeId from Audit.AccountAnnotation where ParentId= @AnnotationTypeId and AnnotationType='Comment') 
							  ---Note --Grid--Adjustment---attachment

						   Insert into Audit.AuditTemplateReset(Id,TemplateId,EngagementId,FilePath,FileName)
						     select NEWID(),@TemplateId,@EngagementId,FilePath,DisplayFileName from  Common.DocRepository where TypeId in (select AnnotationTypeId from Audit.AccountAnnotation where ParentId=@AnnotationTypeId and AnnotationType='Adjustment') 
						   Delete Common.DocRepository where TypeId in (select AnnotationTypeId from Audit.AccountAnnotation where ParentId=@AnnotationTypeId and AnnotationType='Adjustment')

						   Delete Audit.AdjustmentAccount where AdjustmentID in (select AnnotationTypeId from Audit.AccountAnnotation where ParentId=@AnnotationTypeId and AnnotationType='Adjustment') 
                        End
						   if(@DeleteType='Full')
						     Begin
			        	         Delete Audit.Adjustment where Id in (select AnnotationTypeId from Audit.AccountAnnotation where ParentId=@AnnotationTypeId and AnnotationType='Adjustment') 
						     
						  --else if(@DeleteType='Partial')
						  --   Begin
        --            	        Update Audit.Adjustment set IsProposed=0,IsMake=0,IsWaive=0,IsDisable=1,Reference=null,Explanation=null where Id in (select AnnotationTypeId from Audit.AccountAnnotation where ParentId=@AnnotationTypeId and AnnotationType='Adjustment') 
						  -- End
						   ---Note Comments--
						      Delete  Common.Comment where Id in (select AnnotationTypeId from Audit.AccountAnnotation where ParentId=@AnnotationTypeId and AnnotationType='Comment') 
                           ---Note Comments newly added---
						      Delete  Common.Comment where TypeId =@AnnotationTypeId

						      Delete Audit.AccountAnnotation where ParentId=@AnnotationTypeId
						      Delete Audit.Note where ParentId=@AnnotationTypeId
						      Delete Audit.NoteAdjustment where NoteId=@AnnotationTypeId
						   End
						   if(@DeleteType='Full')
						     Begin
							             Insert into Audit.AuditTemplateReset(Id,EngagementId,FeatureName,NoteCode,DynamicGridTemplateName,Issection)
										Select NEWID(),@EngagementId,FeatureName,Code,DynamicGridTemplate,IsSection  from audit.Note where Id=@AnnotationTypeId
						                Delete Audit.NOTE where Id=@AnnotationTypeId
						     End
						   else if(@DeleteType='Partial')
						     Begin
							 --Declare @parentId uniqueidentifier;
							 --     Select @parentId=parentId from Audit.Note where ID=@AnnotationTypeId
								--  if(@parentId is null)
								--    begin
						  --              update Audit.NOTE set Description='',LinkTo='',Status=3 where Id=@AnnotationTypeId 
								--		Insert into Audit.AuditTemplateReset(Id,EngagementId,FeatureName,NoteCode,DynamicGridTemplateName)
								--		Select NEWID(),@EngagementId,FeatureName,Code,DynamicGridTemplate  from audit.Note where Id=@AnnotationTypeId
								--	end
								-- else
								--    begin
								        update Audit.NOTE set IsExclamatory=1 where Id=@AnnotationTypeId
                                   -- end 
						     End 
						   
			               Delete Audit.AccountAnnotation where AnnotationTypeId=@AnnotationTypeId
						   

			         END

		       ELSE IF(@AnnotationType='Attachment')
		             BEGIN
					      if(@DeleteType='Full')
						  Begin
					         Insert into Audit.AuditTemplateReset(Id,TemplateId,EngagementId,FilePath,FileName)
						     select NEWID(),@TemplateId,@EngagementId,FilePath,DisplayFileName from  Common.DocRepository where id=@AnnotationTypeId 
			                 Delete Common.DocRepository where id=@AnnotationTypeId 
                          END
						  Delete Audit.AccountAnnotation where AnnotationTypeId=@AnnotationTypeId
                     END

		             --ELSE IF(@AnnotationType='Adjustment' and @DeleteType='Full')
			   ELSE IF(@AnnotationType='Adjustment')
		             BEGIN
		                  Delete Audit.AdjustmentAccount where AdjustmentID=@AnnotationTypeId
						   Insert into Audit.AuditTemplateReset(Id,TemplateId,EngagementId,FilePath,FileName)
						   select NEWID(),@TemplateId,@EngagementId,FilePath,DisplayFileName from  Common.DocRepository where TypeId=@AnnotationTypeId 

						  delete from Common.DocRepository where TypeId=@AnnotationTypeId 
						  if(@DeleteType='Full')
						     Begin
			        	         Delete Audit.Adjustment where Id=@AnnotationTypeId
						     End
						  else if(@DeleteType='Partial')
						     Begin
						         Update Audit.Adjustment set IsProposed=0,IsMake=0,IsWaive=0,IsDisable=1,Reference=null,Explanation=null where Id=@AnnotationTypeId
						     End
			        	  Delete Audit.AccountAnnotation where AnnotationTypeId=@AnnotationTypeId
		             END

		       ELSE IF(@AnnotationType='Comment')
		             BEGIN
		               	  Delete R from Common.Reply as R JOIN Common.Comment as C on C.Id=R.CommentId WHERE C.Id=@AnnotationTypeId
		                  Delete from Common.Comment where Id =@AnnotationTypeId
			              Delete Audit.AccountAnnotation where AnnotationTypeId=@AnnotationTypeId
		             END

		       ELSE IF(@AnnotationType='Tickmark')
		             BEGIN
		                  Delete Audit.AccountAnnotation where AnnotationTypeId=@AnnotationTypeId 
		             END
		   
              FETCH NEXT FROM DELETE_CSR INTO  @ID,@AnnotationType,@AnnotationTypeId
              END
              CLOSE DELETE_CSR
              DEALLOCATE DELETE_CSR

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

END
GO
