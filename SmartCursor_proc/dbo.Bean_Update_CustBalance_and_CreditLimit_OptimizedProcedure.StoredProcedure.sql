USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Update_CustBalance_and_CreditLimit_OptimizedProcedure]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- EXEC [dbo].[Bean_Update_CustBalance_and_CreditLimit_OptimizedProcedure] 2058,'3D0D52DA-E823-47A3-9D68-178A4D59D12D'

CREATE   PROCEDURE [dbo].[Bean_Update_CustBalance_and_CreditLimit_OptimizedProcedure]
(@CompanyId bigint,@EntitIds nvarchar(MAX))

AS
BEGIN

DECLARE @ITime Nvarchar(100)
SET @ITime = (SELECT 'Bean_Update_CustBalance_and_CreditLimit StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @ITime;

DECLARE @Company Bigint = @companyId, @Entities  nvarchar(MAX) = @EntitIds 
--DECLARE @EntitIds nvarchar(MAX)  = '134D7629-2CAC-4B2B-AE8E-00FA9274B718,34CA7BC3-5D26-430D-9808-06583A9F8DAC', @CompanyId Bigint = 689
DECLARE @EntityId Uniqueidentifier
--DECLARE @Entity Table (Billing Money,PaidAmt Money,CreditAmount Money,GrossBalance money,DebtProvAmount money, NetBalance money)
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

			DECLARE @AsOfDate DATETIME = GETUTCDATE(),  @ReverseAmount MONEY, @GrossBalance money--->>> Added By Rambabu for Testing Performance
				SET @ReverseAmount = (
            							SELECT Cast(Round(Sum(Isnull(CAP.CreditAmount, 0) * CASE WHEN I.ExchangeRate IS NULL OR I.ExchangeRate = 0 THEN 1
                                        							 ELSE I.ExchangeRate 
                                      							  END
                          							  ), 2
                    							  ) AS DECIMAL(18, 2)
                  							  )
            							FROM Bean.CreditNoteApplication AS CAP(NOLOCK)
            							INNER JOIN Bean.Invoice AS I(NOLOCK) ON I.Id = CAP.InvoiceId
            							WHERE I.CompanyId = @Company AND I.EntityId = @EntityId AND CAP.IsRevExcess = 1 AND CAP.STATUS = 1
          							  )
				PRINT @AsOfDate
				PRINT @ReverseAmount

			------->>>> Bean_SoaSummaryForEntity part
				SET @ITime = (SELECT 'Bean_SoaSummaryForEntity_OptimizedFunction StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
				PRINT @ITime;
				
				--INSERT INTO @Entity 
				SELECT @GrossBalance = GrossBalance FROM dbo.Bean_SoaSummaryForEntity_OptimizedFunction (@company, @EntityId, @AsOfDate, @ReverseAmount)
				SET @ITime = (SELECT 'Bean_SoaSummaryForEntity_OptimizedFunction EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
				PRINT @ITime;
			------->>>> Bean_SoaSummaryForEntity part

				--IF EXISTS(select Id from Bean.Entity(Nolock) where CompanyId =@CompanyId AND Id=@entityId AND CustCreditLimit IS NOT NULL)
				--Begin

				SET @ITime = (SELECT 'Update StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
				PRINT @ITime;

					--SELECT CustBal, ISNULL((SELECT GrossBalance FROM @Entity),0), CreditLimitValue, CustCreditLimit-ISNULL(CustBal,0) FROM Bean.Entity
					--WHERE Id = @entityId AND CompanyId = @Company AND IsCustomer=1 AND CustCreditLimit IS NOT NULL

					UPDATE Bean.Entity SET CustBal=ISNULL(@GrossBalance,0),CreditLimitValue=CustCreditLimit-ISNULL(CustBal,0) 
					WHERE Id = @entityId AND CompanyId = @Company AND IsCustomer=1 AND CustCreditLimit IS NOT NULL
				--End
				--Else
				--Begin
					--SELECT CustBal, ISNULL((SELECT GrossBalance FROM @Entity),0) FROM Bean.Entity
					--WHERE Id = @entityId AND CompanyId = @Company AND IsCustomer = 1 AND  CustCreditLimit IS NULL

					UPDATE Bean.Entity SET CustBal=ISNULL(@GrossBalance,0) 
					WHERE Id = @entityId AND CompanyId = @Company AND IsCustomer = 1 AND  CustCreditLimit IS NULL
				
				SET @ITime = (SELECT 'Update EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
				PRINT @ITime;

				--End
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
