USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_CreateCashFlow]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CreateCashFlow] (@engagementId UNIQUEIDENTIFIER,@CompanyId BIGINT,@AuditCompanyId UNIQUEIDENTIFIER)
AS 
  BEGIN
Begin Transaction
BEGIN TRY
        DECLARE @CashflowId UNIQUEIDENTIFIER
		DECLARE Cashflow_Cursor CURSOR FOR 
		   SELECT ID FROM AUDIT.CASHFLOW where CompanyId=0			
		OPEN Cashflow_Cursor
		FETCH NEXT FROM Cashflow_Cursor INTO @CashflowId
		WHILE @@FETCH_STATUS=0
		BEGIN  
		 
		 declare @CashFlowNewId uniqueidentifier= newId(); 
				INSERT INTO  AUDIT.CASHFLOW (Id, CompanyId, AuditCompanyId, EngagementId, Heading, Footer, Remarks,
					 UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Status, Recorder,EditableHeading,EditableFooter,FixIndex,FixFooterIndex,IsEdit)
					   SELECT @CashFlowNewId, @CompanyId, @AuditCompanyId, @engagementId, Heading, Footer, Remarks, UserCreated, GETUTCDATE(),
						  ModifiedBy, ModifiedDate, 1, Recorder ,EditableHeading,EditableFooter,FixIndex,FixFooterIndex,IsEdit
					   FROM AUDIT.CASHFLOW where CompanyId=0 and Id=@CashflowId


			  ------------------------------CashflowItem Insertion ------			   
			   
			    INSERT INTO AUDIT.CASHFLOWITEM (Id, CashFlowId, Name, Recorder,EditableName,IsHeader,IsFooter,ParentId)
		         	SELECT  NEWID(), @CashFlowNewId, Name, Recorder,EditableName,IsHeader,IsFooter,ParentId FROM AUDIT.CASHFLOWITEM WHERE  CashFlowId=@CashflowId
			
			FETCH NEXT FROM Cashflow_Cursor INTO @CashflowId
		END	
		CLOSE Cashflow_Cursor
		Deallocate Cashflow_Cursor				
			
     --update parent id for 2 sections
		UPDATE  AUDIT.CASHFLOWITEM SET ParentId=(select Id from Audit.CashFlowItem where Name='Adjustment for non cash items' and  
		CashFlowId =(SELECT Id from Audit.CashFlow where Heading='Cash flows from operating activities' and EngagementId=@engagementId)) where Id in 
		(select Id from Audit.CashFlowItem where  ParentId='04F59BA6-FE26-4ED5-B544-DEF01FAD1202' and 
		CashFlowId =(SELECT Id from Audit.CashFlow where Heading='Cash flows from operating activities' and EngagementId=@engagementId))

		UPDATE  AUDIT.CASHFLOWITEM SET ParentId=(select Id from Audit.CashFlowItem where Name='Adjustment for changes in operating assets and liabilities:' and  
		CashFlowId =(SELECT Id from Audit.CashFlow where Heading='Cash flows from operating activities' and EngagementId=@engagementId)) where Id in 
		(select Id from Audit.CashFlowItem where  ParentId='9AACF635-B1AF-4476-9D69-48308BFBB84B' and 
		CashFlowId =(SELECT Id from Audit.CashFlow where Heading='Cash flows from operating activities' and EngagementId=@engagementId))

 
    
     Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@engagementId,'CashflowInserted','Success',10)

		Commit Transaction;
END TRY

BEGIN CATCH
	RollBack Transaction;
	DECLARE
	   @ErrorMessage NVARCHAR(4000),
	   @ErrorSeverity INT,
	   @ErrorState INT;
	   SELECT
	   @ErrorMessage = ERROR_MESSAGE(),
	   @ErrorSeverity = ERROR_SEVERITY(),
	   @ErrorState = ERROR_STATE();
	  RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH
   END
GO
