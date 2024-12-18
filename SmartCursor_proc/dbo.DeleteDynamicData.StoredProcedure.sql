USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[DeleteDynamicData]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DeleteDynamicData](@engagementId uniqueidentifier, @lstdynamicids Nvarchar(1000))
AS BEGIN
	declare @dynamicid  UNIQUEIDENTIFIER;
	DECLARE  DeleteDynamicgridAnnotations CURSOR FOR SELECT items FROM [dbo].[SplitToTable](@lstdynamicids , ',')
				OPEN DeleteDynamicgridAnnotations
					FETCH NEXT FROM DeleteDynamicgridAnnotations INTO @dynamicid
					WHILE @@FETCH_STATUS = 0
								BEGIN
									 print @dynamicid
									--delete accountannotations if reference or direct
									delete Audit.AccountAnnotation where EngagementId=@engagementId and AnnotationType='Note' and AnnotationTypeId in  (select Id from Audit.Note where EngagementId = @engagementId and DynamicGridId=@dynamicid)	
									delete Audit.Note where EngagementId = @engagementId and DynamicGridId=@dynamicid

									--**doc repo
									delete Common.DocRepository where id in(select AnnotationTypeId from Audit.AccountAnnotation where AnnotationType='Attachment' and EngagementId=@engagementId and DynamicGridId=@dynamicid)
									delete Audit.AccountAnnotation where EngagementId=@engagementId and AnnotationType='Attachment' and  EngagementId=@engagementId and DynamicGridId=@dynamicid

									--**comment
									delete Common.Comment where id in(select AnnotationTypeId from Audit.AccountAnnotation where EngagementId=@engagementId  and DynamicGridId=@dynamicid)
									delete Audit.AccountAnnotation where EngagementId=@engagementId  and DynamicGridId=@dynamicid and AnnotationType='Comment'

									--**adj account
									delete Audit.AdjustmentAccount where AdjustmentID in (select Id from audit.Adjustment where id in(select AnnotationTypeId from Audit.AccountAnnotation where AnnotationType='Adjustment' and  EngagementId=@engagementId and DynamicGridId=@dynamicid))
									delete audit.Adjustment where id in(select AnnotationTypeId from Audit.AccountAnnotation where  AnnotationType='Adjustment' and  EngagementId=@engagementId and DynamicGridId=@dynamicid)
									delete Audit.AccountAnnotation where EngagementId=@engagementId  and DynamicGridId=@dynamicid and AnnotationType='Adjustment'

									--** tickmark delete in olny account annotaion
									delete Audit.AccountAnnotation where EngagementId=@engagementId  and DynamicGridId=@dynamicid and AnnotationType='Tickmark'
								
								FETCH NEXT FROM DeleteDynamicgridAnnotations INTO @dynamicid
								End
				CLOSE deleteDynamicgridAnnotations
	DEALLOCATE deleteDynamicgridAnnotations

	END

GO
