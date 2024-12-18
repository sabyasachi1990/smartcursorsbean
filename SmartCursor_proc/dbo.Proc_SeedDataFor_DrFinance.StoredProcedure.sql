USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SeedDataFor_DrFinance]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[Proc_SeedDataFor_DrFinance](@NEW_COMPANY_ID bigint,@UNIQUE_COMPANY_ID bigint)
 AS 
 BEGIN
	DECLARE @STATUS   INT
	DECLARE @CREATED_DATE DATETIME	
	SET @STATUS = 1    
	SET @CREATED_DATE =GETUTCDATE()   
  BEGIN TRANSACTION
	  BEGIN TRY 	  	
					------------TERMS OF PAYMENT  --------------------
Declare @TermsOfPayment_Cnt int;
 select @TermsOfPayment_Cnt=Count(*) from [Common].[TermsOfPayment] where companyid=@NEW_COMPANY_ID 
 IF @TermsOfPayment_Cnt=0
 Begin
  INSERT INTO [Common].[TermsOfPayment] (Id, Name, CompanyId, TermsType, TOPValue, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, 
   ModifiedDate, Version, Status, IsVendor, IsCustomer)
   SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + @STATUS FROM [Common].[TermsOfPayment] ), Name, @NEW_COMPANY_ID, TermsType, TOPValue, 
   RecOrder, Remarks, UserCreated, @CREATED_DATE, null, null, Version, status, IsVendor, IsCustomer FROM [Common].[TermsOfPayment] 
   WHERE COMPANYID=@UNIQUE_COMPANY_ID;
   end

   Exec [dbo].[ControlCodeCategoryModule_SP_New] @NEW_COMPANY_ID,15


   
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
