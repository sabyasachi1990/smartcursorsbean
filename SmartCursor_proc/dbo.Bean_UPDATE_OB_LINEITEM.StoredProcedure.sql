USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_UPDATE_OB_LINEITEM]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Bean_UPDATE_OB_LINEITEM]  
@ServiceEntityID BIGINT,  
@OBDetailId uniqueIdentifier  
AS  
BEGIN  
   
 Declare @DocDebit money,  
   @DocCredit money,  
   @BaseDebit money,  
   @BaseCredit money,  
   @ErrorMessage varchar(500)  
  
 BEGIN TRAN  
      
    BEGIN TRY  
  BEGIN  
   IF EXISTS(Select 1 from Bean.OpeningBalanceDetailLineItem OBD where OBD.OpeningBalanceDetailId=@OBDetailId and OBD.ServiceCompanyId=@ServiceEntityID)  
   BEGIN  
    SELECT @DocCredit=ISNULL(SUM(OBD.DocCredit),NULL), @DocDebit=ISNULL(SUM(OBD.DoCDebit),NULL), @BaseCredit=ISNULL(SUM(OBD.BaseCredit),NULL), @BaseDebit=ISNULL(SUM(OBD.BaseDebit),NULL) from Bean.OpeningBalanceDetailLineItem OBD where OBD.OpeningBalanceDetailId=@OBDetailId and OBD.ServiceCompanyId=@ServiceEntityID  
  
    Update OBD1 set OBD1.DocCredit=@DocCredit,OBD1.DocDebit=@DocDebit,OBD1.BaseCredit=@BaseCredit,OBD1.BaseDebit=@BaseDebit from Bean.OpeningBalanceDetail OBD1 where Id=@OBDetailId  
   END  
  END  
  
     COMMIT TRAN  
    END TRY  
     
   BEGIN CATCH  
     SET @ErrorMessage=(Select ERROR_MESSAGE());  
     RAISERROR(@ErrorMessage,16,1);  
   END CATCH  
  
END
GO
