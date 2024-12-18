USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_InvoicePosting_Update_CustBalance_and_CreditLimit]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [dbo].[Bean_InvoicePosting_Update_CustBalance_and_CreditLimit] 2058,'3D0D52DA-E823-47A3-9D68-178A4D59D12D'

CREATE   PROCEDURE [dbo].[Bean_InvoicePosting_Update_CustBalance_and_CreditLimit]
(@CompanyId bigint,@EntitIds nvarchar(MAX))

AS
BEGIN

DECLARE @ITime Nvarchar(100)
SET @ITime = (SELECT 'Bean_Update_CustBalance_and_CreditLimit StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @ITime;

DECLARE @Company Bigint = @companyId, @Entities  nvarchar(MAX) = @EntitIds 
DECLARE @EntityId Uniqueidentifier

CREATE TABLE #EntityId (SNo Int Identity(1,1), EntityId UniqueIdentifier)

SELECT CAST(Value AS uniqueIdentifier) as Id INTO #SplitValue FROM STRING_SPLIT(@Entities, ',') 

INSERT INTO #EntityId
SELECT A.Id FROM Bean.Entity(NOLOCK) AS A
	INNER JOIN #SplitValue AS B ON B.Id = A.Id
WHERE CompanyId = @Company AND IsCustomer = 1

	DECLARE @Count BigInt, @Number BigInt = 1

	SELECT @Count = COUNT(SNo) FROM #EntityId 

	WHILE  @Count >= @Number 
	BEGIN 
		BEGIN TRY
			SELECT @EntityId = EntityId FROM #EntityId WHERE SNo = @Number
			PRINT @EntityId

			DECLARE  @GrossBalance money--->>> Added By Rambabu for Testing Performance			
			------->>>> Bean_SoaSummaryForEntity part
			SET @ITime = (SELECT 'Bean_Invoice_SoaSummaryForEntity StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
			PRINT @ITime;				
			------->>>> INSERT INTO @Entity 
			SET @GrossBalance = (SELECT [dbo].[Bean_InvoicePosting_SoaSummaryForEntity] (@company, @EntityId))
			SET @ITime = (SELECT 'Bean_Invoice_SoaSummaryForEntityn EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
			PRINT @ITime;
			------->>>> Bean_SoaSummaryForEntity part
			SET @ITime = (SELECT 'Update StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
			PRINT @ITime;

			IF EXISTS(SELECT TOP 1 Id FROM Bean.Entity(NOLOCK) WHERE CompanyId = @CompanyId AND Id = @EntityId AND CustCreditLimit IS NOT NULL)
			BEGIN
				UPDATE Bean.Entity SET CustBal = ISNULL(@GrossBalance,0),CreditLimitValue = CustCreditLimit-ISNULL(CustBal,0) 
				WHERE Id = @EntityId AND CompanyId = @CompanyId AND IsCustomer=1 
			END
			ELSE
			BEGIN
				UPDATE Bean.Entity SET CustBal = ISNULL(@GrossBalance,0) WHERE Id = @EntityId AND CompanyId = @CompanyId AND IsCustomer = 1
			END

			SET @ITime = (SELECT 'Update EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
			PRINT @ITime;

				
		END TRY          
		BEGIN CATCH     
			ROLLBACK;          
			PRINT 'In Catch Block';            
			SELECT ERROR_MESSAGE() AS ErrorMessage, ERROR_NUMBER() AS ErrorNumber;   
			THROW:            
		END CATCH 
		
		SET @GrossBalance = NULL
		SET @Number = @Number + 1	
	END

	DROP TABLE #EntityId
	DROP TABLE #SplitValue
SET @ITime = (SELECT 'Bean_Update_CustBalance_and_CreditLimit EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @ITime;

END
GO
