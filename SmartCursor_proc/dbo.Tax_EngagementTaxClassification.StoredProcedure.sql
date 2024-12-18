USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Tax_EngagementTaxClassification]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-------------------------------------------


CREATE Procedure [dbo].[Tax_EngagementTaxClassification](@companyId bigint,@engagemenId uniqueidentifier,@taxManualId uniqueidentifier)
As begin 

  BEGIN TRANSACTION
  BEGIN TRY
          DECLARE @PARTNER_COMPANYID BIGINT      
          Set @PARTNER_COMPANYID=(select AccountingFirmId from Common.Company where Id=@CompanyId)
	IF @PARTNER_COMPANYID IS NULL 
	BEGIN 
			SET @PARTNER_COMPANYID=@CompanyId
	END

	
   
	   --------------Classification-------------------
   IF @PARTNER_COMPANYID IS not NULL      
       BEGIN       
          Declare @ClassificationID uniqueidentifier      
          Declare Leadsheet_CSR Cursor for Select Id From Tax.Classification Where companyid=@PARTNER_COMPANYID AND EngagementId IS NULL and TaxManualId=@taxManualId  
          Open Leadsheet_CSR      
          Fetch next from Leadsheet_CSR into @ClassificationID       
          while @@FETCH_STATUS=0      
              Begin      
                 Insert Into tax.Classification(Id, CompanyId,  [Index], ClassificationType, AccountClass, IsSystem, ClassificationName, FinancialStatementTemplate,  Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version,Status ,Disclosure,EngagementId,TypeId)      
                 select Newid() as leadsheetid, @companyId as newcompanyid, [Index], ClassificationType, AccountClass, IsSystem, ClassificationName,FinancialStatementTemplate,Remarks,RecOrder,UserCreated, GETUTCDATE(),NULL AS ModifiedBy,NULL AS ModifiedDate,Version,Status,Disclosure,@engagemenId,Id from tax.Classification        
                         where id=@ClassificationID AND Status=1       
          Fetch next from Leadsheet_CSR into @ClassificationID       
          End      
          Close Leadsheet_CSR      
          Deallocate Leadsheet_CSR      
             
       End      

	   --------------ClassificationCategories ------------------------
	    Declare @LeadSheetCategories_Cnt bigint;      
        select @LeadSheetCategories_Cnt=Count(*) from tax.ClassificationCategories where
		 ClassificationId in (select Id from Tax.Classification where CompanyId= @companyId and engagementid=@engagemenId )      
        If @LeadSheetCategories_Cnt=0      
          Begin      
             IF @PARTNER_COMPANYID IS not NULL      
             Begin       
             Insert Into Tax.ClassificationCategories([Id],[ClassificationId],[Name],[RecOrder],[Status])      
             SELECT newid() as Id, 
              (select ID FROM Tax.Classification where CompanyId = @companyId and engagementId=@engagemenId and ClassificationName = (select ClassificationName FROM Tax.Classification where Id =  cat. ClassificationId and CompanyId = @PARTNER_COMPANYID AND ENGAGEMENTID IS NULL))   as [ClassificationID] ,cat.[Name],cat.[RecOrder],cat.[Status] 
              FROM Tax.ClassificationCategories cat inner join Tax.Classification ld on ld.Id = cat.ClassificationId  where ld.CompanyId = @PARTNER_COMPANYID AND   LD.Status=1 AND LD.EngagementId IS NULL  and LD.TaxManualId=@taxManualId 
             End 
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
