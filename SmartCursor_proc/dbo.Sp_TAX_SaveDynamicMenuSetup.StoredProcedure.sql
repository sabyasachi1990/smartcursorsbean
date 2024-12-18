USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_TAX_SaveDynamicMenuSetup]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_TAX_SaveDynamicMenuSetup](@companyId bigint,@Heading nvarchar(100),@Action nvarchar(20),@ClassificationId uniqueidentifier)
 AS BEGIN
  BEGIN TRANSACTION
	  BEGIN TRY 


declare @taxMenuMasterId  UNIQUEIDENTIFIER;
declare @NEWENGAGEMENTID  UNIQUEIDENTIFIER;
declare @engagementId table (id UNIQUEIDENTIFIER);

insert into @engagementId
select distinct Id from Tax.TaxCompanyEngagement where TaxCompanyId in (select Id from  Tax.TaxCompany where CompanyId=@companyId);

DECLARE  SAVEMENUSETUP CURSOR FOR SELECT * FROM @engagementId
OPEN SAVEMENUSETUP
FETCH NEXT FROM SAVEMENUSETUP INTO @NEWENGAGEMENTID
WHILE @@FETCH_STATUS >= 0
BEGIN

IF(@Action='New')
	  BEGIN
			IF NOT EXISTS ( SELECT * FROM  [Tax].[TaxCompanyMenuMaster] WHERE CompanyId=@companyId and EngagementId=@NEWENGAGEMENTID  and Heading=@Heading and ClassificationId=@ClassificationId )
			BEGIN
				INSERT INTO [Tax].[TaxCompanyMenuMaster] (Id, CompanyId,EngagementId,TaxMenuMasterId,Code,Heading,IsHide,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,ClassificationId) VALUES 
				(NEWID(),@companyId,@NEWENGAGEMENTID,(select Id from [Tax].[TaxMenumaster] where GroupName='Work Program' And  PermissionKey='Tax_WorkprogramCopy'),'',@heading,0,(select  (MAX(RecOrder)+1)from Tax.TaxCompanyMenuMaster where EngagementId=@NEWENGAGEMENTID),
				'Dynamic','madhu@kgtan.com',GETDATE(),NULL,NULL,NULL,1,@ClassificationId)
			END
	   END
ELSE IF (@Action='UpDate')
	  BEGIN
			IF NOT EXISTS ( SELECT * FROM  [Tax].[TaxCompanyMenuMaster] WHERE CompanyId=@companyId and EngagementId=@NEWENGAGEMENTID  and Heading=@Heading and ClassificationId=@ClassificationId )
			BEGIN
				UpDate [Tax].[TaxCompanyMenuMaster] set Heading=@Heading where EngagementId=@NEWENGAGEMENTID and CompanyId=@companyId and ClassificationId =@ClassificationId
			END
	  END
FETCH NEXT FROM SAVEMENUSETUP INTO @NEWENGAGEMENTID
END
CLOSE SAVEMENUSETUP
DEALLOCATE SAVEMENUSETUP


 BEGIN 
      COMMIT TRANSACTION
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
 END

GO
