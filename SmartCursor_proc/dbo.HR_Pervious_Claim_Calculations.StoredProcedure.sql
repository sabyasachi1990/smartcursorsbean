USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Pervious_Claim_Calculations]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec   [dbo].[HR_Pervious_Claim_Calculations] '5f3707ef-e9d1-41cf-8d83-685448faccd0',1,'4e103b3c-8c0b-4581-840a-58629ccd4923','56465f13-42fa-486d-8396-4b5983e96b80'

  
  
CREATE PROCEDURE [dbo].[HR_Pervious_Claim_Calculations] (@TransactionId UNIQUEIDENTIFIER, @CompanyId BIGINT, @EmployeeId UNIQUEIDENTIFIER, @HrSettingDetaiId UNIQUEIDENTIFIER)  
AS  
BEGIN  
 BEGIN TRANSACTION  
  
 BEGIN TRY  
  DECLARE @ClaimItem_Tbl TABLE (S_No INT Identity(1, 1), ClaimItemId UNIQUEIDENTIFIER, ClaimCategory NVARCHAR(50),AprovedAmount money)  
  DECLARE @ItemCount INT  
  DECLARE @RecCount INT  
  DECLARE @CategotyName NVARCHAR(50)  
  DECLARE @ApprovedAmount MONEY  
  DECLARE @ClaimStatus NVARCHAR(50)  
  DECLARE @ClaimItemIds UNIQUEIDENTIFIER  
  
  INSERT INTO @ClaimItem_Tbl  
  SELECT DISTINCT ECD.ItemId, CI.Category,detail.ApprovedAmount  
  FROM HR.EmployeeClaimDetailTemp ECD  
  INNER JOIN HR.ClaimItem CI ON ECD.ItemId = CI.Id  
  join HR.EmployeeClaimDetail detail on ECD.ClaimDetailId = detail.Id
  WHERE ECD.TransactionId = @TransactionId AND CI.Companyid = @CompanyId  
  
  SET @ItemCount = (  
    SELECT count(*)  
    FROM @ClaimItem_Tbl  
    )  
  SET @RecCount = 1  
  
  WHILE @ItemCount >= @RecCount  
  BEGIN --1  
   SELECT @ClaimItemIds = ClaimItemId, @CategotyName = ClaimCategory ,@ApprovedAmount=AprovedAmount 
   FROM @ClaimItem_Tbl  
   WHERE S_No = @RecCount  
  
   --SET @ApprovedAmount = (  
   --  SELECT CAST(sum(ApprovedAmount) AS MONEY)  
   --  FROM HR.EmployeeClaimDetailTemp  
   --  WHERE ItemId = @ClaimItemIds  
   --  )  
  
   UPDATE ECED  
   SET 
   --ECED.SubmittedAmount = (isnull(ECED.SubmittedAmount, 0) - isnull(@ApprovedAmount, 0)), 
   ECED.SubmittedAmount = isnull(@ApprovedAmount, 0),
   ECED.RemainingAmount = (CASE WHEN (ECED.AnnualLimit IS NOT NULL and ECED.AnnualLimit > 0) OR (ECED.TransactionLimit IS NOT NULL and ECED.TransactionLimit > 0) THEN (isnull(ECED.RemainingAmount, 0) + isnull(@ApprovedAmount, 0)) ELSE NULL END)  
   FROM HR.EmployeeClaimsEntitlementDetail AS ECED  
   INNER JOIN HR.EmployeeClaimsEntitlement AS ECE ON ECE.Id = ECED.EmployeeClaimsEntitlementId  
   WHERE ECE.EmployeeId = @EmployeeId AND ECE.CompanyId = @CompanyId AND ECED.ClaimItemId = @ClaimItemIds AND ECED.HrSettingDetaiId = @HrSettingDetaiId  
  
   --===============================Updating category amounts ---------===========================================  
   UPDATE E  
   SET E.CategoryUtilizedAmount = A.UtilizedAmount, E.CategoryPreApprovedAmount = A.SubmittedAmount, E.CategoryBalanceAmount = (CASE WHEN (E.CategoryLimit IS NULL) THEN NULL ELSE ISNULL(E.CategoryLimit, 0) - (ISNULL(A.UtilizedAmount, 0) + ISNULL(A.SubmittedAmount, 0)) END)  
   FROM hr.EmployeeClaimsEntitlementDetail E  
   INNER JOIN HR.ClaimItem CI ON E.ClaimItemId = CI.Id  
   INNER JOIN (  
    SELECT ECD.Id, CI.Category, SUM(ECED.UtilizedAmount) AS UtilizedAmount, SUM(ECED.SubmittedAmount) AS SubmittedAmount  
    FROM HR.EmployeeClaimsEntitlementDetail ECED  
    INNER JOIN HR.EmployeeClaimsEntitlement ECD ON ECED.EmployeeClaimsEntitlementId = ECD.Id  
    INNER JOIN HR.ClaimItem CI ON ECED.ClaimItemId = CI.Id  
    WHERE ECD.EmployeeId = @EmployeeId AND ECD.CompanyId = @CompanyId AND CI.CompanyId = @CompanyId AND ECED.HrSettingDetaiId = @HrSettingDetaiId AND CI.Category = @CategotyName  
    --and ECED.ClaimItemId in ((select ClaimItemId from hr.EmployeeClaimsEntitlementDetail where EmployeeClaimsEntitlementId = ECD.Id and HrSettingDetaiId = @HrSettingDetaiId ))   
    GROUP BY ECD.Id, CI.Category  
    ) A ON A.Id = E.EmployeeClaimsEntitlementId AND E.HrSettingDetaiId = @HrSettingDetaiId AND CI.Category = @CategotyName  
    --and  E.ClaimItemId in ((select ClaimItemId from hr.EmployeeClaimsEntitlementDetail where EmployeeClaimsEntitlementId = A.Id and HrSettingDetaiId = @HrSettingDetaiId ))    
    AND A.Category = CI.Category AND CI.CompanyId = @CompanyId  
  
   SET @RecCount = @RecCount + 1  
  END --1  
  
  DELETE HR.EmployeeClaimDetailTemp  
  WHERE TransactionId = @TransactionId  
  
  COMMIT TRANSACTION  
 END TRY  
  
 BEGIN CATCH  
  ROLLBACK TRANSACTION  
  
  DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;  
  
  SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();    
  
  RAISERROR (@ErrorMessage, 16, 1)  
 END CATCH  
END    
GO
