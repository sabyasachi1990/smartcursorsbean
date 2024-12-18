USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_UpdateJDetailIfBrcVoid]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[Bean_UpdateJDetailIfBrcVoid]

(

 @CompanyId BigInt,

 @serviceCompanyId BigInt,

 @CoaId BigInt,

 @BankRecId Uniqueidentifier

)

As

Begin

    BEGIN TRY

    IF Exists( Select id from Bean.BankReconciliation where CompanyId=@CompanyId and ServiceCompanyId=@serviceCompanyId and COAId=@CoaId and Id=@BankRecId)

    Begin

     Update Bean.JournalDetail SET ReconciliationId=Null,ReconciliationDate=Null,IsBankReconcile=Null where ServiceCompanyId=@serviceCompanyId and COAId=@CoaId and ReconciliationId=ReconciliationId

      If Exists(Select Id from Bean.OpeningBalanceDetail where COAId=@CoaId and ReconciliationId=@BankRecId)

      BEGIN

        Update Bean.OpeningBalanceDetail SET ReconciliationId=Null, ReconciliationDate=Null,ClearingState='Cleared' where COAId=@CoaId and ReconciliationId=@BankRecId

      END

    END

    END TRY

    BEGIN CATCH

        

    END CATCH

End
GO
