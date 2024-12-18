USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_ClaimMultipleProcessing]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ClaimMultipleProcessing] (@TransactionId UNIQUEIDENTIFIER, @ClaimState NVARCHAR(50),@IsPayroll bit)
AS
BEGIN --s1	
	BEGIN TRANSACTION --s2

	BEGIN TRY --s3
		DECLARE @id UNIQUEIDENTIFIER
		DECLARE @claimId UNIQUEIDENTIFIER
		DECLARE @billid UNIQUEIDENTIFIER
		DECLARE @postingdate DATETIME2(2)
		DECLARE @isvoid BIT
		DECLARE @ispaycomponent BIT
		DECLARE @vendorid UNIQUEIDENTIFIER
		DECLARE @ExchangeRate decimal(15,10)
		DECLARE @GstExchangeRate decimal(15,10)
		DECLARE @isexchangerateeditable BIT
		DECLARE @companyid BIGINT

		DECLARE Claim_cursor CURSOR
		FOR
		SELECT Id, ClaimId, BillId, PostingDate, IsVoid, IsPayComponent, VendorId, ExchangeRate, GstExchangeRate, IsExchangeRateEditable, CompanyId
		FROM [HR].[TempMultipleCliamProcess]
		WHERE TransactionId = @TransactionId

		OPEN Claim_cursor

		FETCH NEXT
		FROM Claim_cursor
		INTO @id, @claimId, @billid, @postingdate, @isvoid, @ispaycomponent, @vendorid, @ExchangeRate, @GstExchangeRate, @isexchangerateeditable, @companyid

		WHILE @@FETCH_STATUS = 0
		BEGIN
		print '1'
			EXEC [dbo].[Bean_Claims_Sync] @companyid, @claimId, @billid, @postingdate, @isvoid, @ispaycomponent, @vendorid, @ExchangeRate, @GstExchangeRate, @isexchangerateeditable
			print '2'
			if(@ClaimState='Processed')
			begin
			print '3'
			update [HR].EmployeeClaim1 set [SyncBCClaimDate]=GETUTCDATE(),[SyncBCClaimId]=@billid,[SyncBCClaimRemarks]='The syncing process has been completed',[SyncBCClaimStatus]='Completed',[DocumentId]=@billid where id=@claimId
			end

			FETCH NEXT
			FROM Claim_cursor
			INTO @id, @claimId, @billid, @postingdate, @isvoid, @ispaycomponent, @vendorid, @ExchangeRate, @GstExchangeRate, @isexchangerateeditable, @companyid
		END		

		CLOSE Claim_cursor

		DEALLOCATE Claim_cursor
		if(@IsPayroll=1 and @ClaimState='Void')
		begin
		 update [HR].EmployeeClaim1 set ClaimStatus='Approved' where id in (SELECT  ClaimId
		FROM [HR].[TempMultipleCliamProcess]
		WHERE TransactionId = @TransactionId )
		end
		DELETE
		FROM [HR].[TempMultipleCliamProcess]
		WHERE TransactionId = @TransactionId

		COMMIT TRANSACTION --s2
	END TRY --s3

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH
END
GO
