USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Tax_EngagementRolesSeedData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------------------------------
--Engagement Roles 

Create Procedure [dbo].[Tax_EngagementRolesSeedData](@companyId bigint,@engagemenId uniqueidentifier,@TaxManualId uniqueidentifier)
As begin 

  BEGIN TRANSACTION
  BEGIN TRY

          DECLARE @PARTNER_COMPANYID BIGINT      
          Set @PARTNER_COMPANYID=(select AccountingFirmId from Common.Company where Id=@CompanyId)
	IF @PARTNER_COMPANYID IS NULL 
	BEGIN 
			SET @PARTNER_COMPANYID=@CompanyId
	END
	
 --------------------------------------Roles -----------------------------
 
      Insert  Into Tax.Roles (Id,CompanyId,Role,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,IsSystem,EngagementId)
	  select NEWID(),@companyId,Role,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status,IsSystem,@engagemenId   from Tax.Roles where CompanyId =@PARTNER_COMPANYID and EngagementId is null and Status=1 and TaxManualId=@TaxManualId

-----------------------
    
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
