USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SUPERADMINFOREIGNEXCHANGE]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SP_SUPERADMINFOREIGNEXCHANGE] (@COMPANYID BIGINT,@FOREIGNEXCHANGEID UNIQUEIDENTIFIER,@RECORDSTATUS VARCHAR(20))
AS 
 BEGIN 
 IF(@RECORDSTATUS ='New')
 BEGIN 
 IF EXISTS(SELECT ID FROM Tax.MonthlyForeignExchange where CompanyId=@COMPANYID AND Id=@FOREIGNEXCHANGEID)
  BEGIN 
      -- New record insertion [when create new at super user]
      DECLARE @DUMMY_COMPANYID BIGINT
      DECLARE FOREIGNEXCHANGE_CURSOR_FOR_COMPANY CURSOR FOR 
    SELECT DISTINCT ID FROM Common.Company where IsAccountingFirm=1 AND Id <> 0 AND ParentId IS NULL
            OPEN FOREIGNEXCHANGE_CURSOR_FOR_COMPANY
    FETCH NEXT FROM FOREIGNEXCHANGE_CURSOR_FOR_COMPANY INTO @DUMMY_COMPANYID
    while @@FETCH_STATUS > -1   
    BEGIN       
     INSERT INTO [Tax].[MonthlyForeignExchange]
     ([Id],[CompanyId] ,[Month],[Year],[BaseCurrency],[FunctionalCurrency],[BaseToFunctionalCurrency],[FunctionalToBaseCurrency],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status])
     select NEWID(),@DUMMY_COMPANYID ,[Month],[Year],[BaseCurrency],[FunctionalCurrency],[BaseToFunctionalCurrency],[FunctionalToBaseCurrency],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status] from Tax.MonthlyForeignExchange
     WHERE COMPANYID=0 AND Id=@FOREIGNEXCHANGEID
    FETCH NEXT FROM FOREIGNEXCHANGE_CURSOR_FOR_COMPANY INTO @DUMMY_COMPANYID
    END 
   CLOSE FOREIGNEXCHANGE_CURSOR_FOR_COMPANY
   DEALLOCATE FOREIGNEXCHANGE_CURSOR_FOR_COMPANY
  END
 END
END
GO
