USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Delete_TemplateAnnotationsData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [dbo].[SP_Delete_TemplateAnnotationsData](@engagementId UNIQUEIDENTIFIER,@parentId UNIQUEIDENTIFIER)
AS BEGIN
      BEGIN TRANSACTION
      BEGIN TRY 
			--Note
			Delete Audit.Note WHERE EngagementId=@engagementId and ParentId=@parentId
			--DocumentRepository
			Delete Common.DocRepository where Id in(select AnnotationTypeId from Audit.AccountAnnotation where EngagementId=@engagementId and ParentId=@parentId)
			--Comment,Reply
			Delete r from Common.Reply as r JOIN Common.Comment as c on c.Id=r.CommentId WHERE c.Id in(SELECT Id from Common.Comment where Id in(select AnnotationTypeId from Audit.AccountAnnotation where EngagementId=@engagementId and ParentId=@parentId))
			Delete from Common.Comment where Id in(select AnnotationTypeId from Audit.AccountAnnotation where EngagementId=@engagementId and ParentId=@parentId)
			---Adjustment
			Delete from Audit.AdjustmentAccount where AdjustmentID in (select Id from audit.Adjustment where ID in(select AnnotationTypeId from Audit.AccountAnnotation where EngagementId=@engagementId and ParentId=@parentId))
			Delete from audit.Adjustment where ID in(select AnnotationTypeId from Audit.AccountAnnotation where EngagementId=@engagementId and ParentId=@parentId)
			--AccountAnnotation
			Delete Audit.AccountAnnotation WHERE EngagementId=@engagementId and ParentId=@parentId
   
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
