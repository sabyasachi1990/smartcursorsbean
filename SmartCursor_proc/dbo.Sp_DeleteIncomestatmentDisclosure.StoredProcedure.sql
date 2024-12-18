USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_DeleteIncomestatmentDisclosure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[Sp_DeleteIncomestatmentDisclosure] (@engagementId uniqueidentifier,@leadsheetId uniqueidentifier,@yeartype nvarchar(10))
 As
 Begin
     BEGIN TRANSACTION
     BEGIN TRY  

		
        Delete Audit.SubCategory where EngagementId =@engagementId and Type='Disclosure' and ParentId in (select id from Audit.Category where EngagementId=@engagementId and LeadsheetId=@leadsheetId and Type='Disclosure' and coalesce(YearType,'null')=coalesce(@yeartype,'null'))

        Delete Audit.Category where EngagementId=@engagementId and LeadsheetId=@leadsheetId and Type='Disclosure' and coalesce(YearType,'null')=coalesce(@yeartype,'null')

        Delete  Audit.DisclosureDetails  where DisclosureId in (select Id from Audit.Disclosure where EngagementId=@engagementId and LeadSheetId=@leadsheetId and coalesce(YearType,'null')=coalesce(@yeartype,'null'))
	   
        Delete  Audit.DisclosureSections where DisclosureId in (select Id from Audit.Disclosure where EngagementId=@engagementId and LeadSheetId=@leadsheetId and coalesce(YearType,'null')=coalesce(@yeartype,'null'))
	   
        Delete  Audit.Disclosure where EngagementId=@engagementId and LeadSheetId=@leadsheetId and coalesce(YearType,'null')=coalesce(@yeartype,'null')

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
