USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Audit].[GetCompanyId]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     Procedure [Audit].[GetCompanyId]  ( @CompanyId Bigint )  
AS Begin 
Begin Transaction
BEGIN TRY 		


		 declare @ParentCompanyId BigInt;
		 -----------------------------PlannigAndCompletionSetUp-----------------------      
		 
		 Set @ParentCompanyId=(select AccountingFirmId from Common.Company where Id=@CompanyId)
	     IF @ParentCompanyId IS NULL 
			BEGIN 
				if((select IsAccountingFirm from Common.Company where Id=@CompanyId) = 1)
				begin
					select @CompanyId;
				End
				else
				Begin 
					select 0;
				End
			END
		 else
			Begin
		       select @ParentCompanyId;
			End

	

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	RollBack Transaction;
	DECLARE	@ErrorMessage NVARCHAR(4000), @ErrorSeverity INT,  @ErrorState INT;
	SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH     
End
GO
