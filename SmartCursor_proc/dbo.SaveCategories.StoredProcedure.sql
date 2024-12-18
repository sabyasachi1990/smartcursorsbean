USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SaveCategories]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SaveCategories](@companyId BIGINT,@leadsheetId UNIQUEIDENTIFIER,@categoryId UNIQUEIDENTIFIER)
AS BEGIN     
    declare @engagementId UNIQUEIDENTIFIER;
    declare @engagementtable table (id UNIQUEIDENTIFIER);

    BEGIN TRANSACTION
    BEGIN TRY    

       INSERT INTO @engagementtable  
       SELECT Id FROM AUDIT.AuditCompanyEngagement WHERE AuditCompanyId in(SELECT id FROM AUDIT.AuditCompany WHERE  companyid=@companyId);   
       DECLARE  SaveCategory CURSOR FOR SELECT * FROM @engagementtable
       OPEN SaveCategory
       FETCH NEXT FROM SaveCategory INTO @engagementId
       WHILE @@FETCH_STATUS >= 0
       BEGIN
            IF EXISTS (SELECT * FROM AUDIT.DISCLOSURE WHERE EngagementId=@engagementId AND LeadSheetId=@leadsheetId AND IsDisclosure=1)
            BEGIN                     
                IF NOT EXISTS (SELECT * FROM AUDIT.DISCLOSUREDETAILS WHERE DisclosureId=(SELECT id FROM AUDIT.DISCLOSURE  WHERE EngagementId=@engagementId AND LeadSheetId=@leadsheetId )AND CategoryId=@categoryID AND IsSystem=1)
                  BEGIN  
                       IF EXISTS(SELECT * FROM audit.TrialBalanceImport WHERE EngagementId=@engagementId AND LeadSheetId=@leadsheetId AND CategoryId=@categoryId)
                       BEGIN                   
                             INSERT INTO  AUDIT.DISCLOSUREDETAILS (ID,DisclosureId,CategoryId,Name,RecOrder) VALUES (NEWID(),(Select Id from AUDIT.DISCLOSURE WHERE EngagementId=@engagementId AND LeadSheetId=@leadsheetId AND IsDisclosure=1),@categoryId,(SELECT NAME FROM AUDIT.LeadSheetCategories where Id=@categoryId),(SELECT MAX(RecOrder)+1 from AUDIT.DisclosureDetails))   
                         END
                    END
              END
   FETCH NEXT FROM SaveCategory INTO @engagementId    
   END
       CLOSE SaveCategory
       DEALLOCATE SaveCategory    

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
