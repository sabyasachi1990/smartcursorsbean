USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_AUDIT_RESETTEMPLATE]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_AUDIT_RESETTEMPLATE] (@TemplateId NVARCHAR(50),@DeleteType NVARCHAR(20) )
AS
BEGIN
DECLARE @ID UNIQUEIDENTIFIER,
@AnnotationTypeId UNIQUEIDENTIFIER,
@AnnotationType NVARCHAR(50);

     BEGIN TRANSACTION
     BEGIN TRY
              DECLARE DELETE_CSR CURSOR FOR SELECT ID,AnnotationType,AnnotationTypeId from Audit.AccountAnnotation where templateId=@TemplateId
              OPEN DELETE_CSR
              FETCH NEXT FROM DELETE_CSR INTO @ID,@AnnotationType,@AnnotationTypeId
              WHILE(@@FETCH_STATUS=0)
              BEGIN

		             IF (@AnnotationType='Note' and @DeleteType='Full')
			         BEGIN
			               Delete Audit.NOTE where ParentId=@AnnotationTypeId
			               Delete Audit.NOTE where Id=@AnnotationTypeId
			               Delete Audit.AccountAnnotation where AnnotationTypeId=@AnnotationTypeId
			         END

		             ELSE IF(@AnnotationType='Attachment')
		             BEGIN
			               Delete Common.DocRepository where id=@AnnotationTypeId 
			        	   Delete Audit.AccountAnnotation where AnnotationTypeId=@AnnotationTypeId
                     END

		             ELSE IF(@AnnotationType='Adjustment' and @DeleteType='Full')
		             BEGIN
		                  Delete Audit.AdjustmentAccount where AdjustmentID=@AnnotationTypeId
			        	  Delete Audit.Adjustment where Id=@AnnotationTypeId
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
