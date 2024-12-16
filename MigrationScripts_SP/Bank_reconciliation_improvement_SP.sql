USE SmartCursorSTG
GO

IF EXISTS ( Select 1 from sys.objects where name='GetAllBankReconciliationData_proc'AND type='P')
BEGIN
 Drop Proc GetAllBankReconciliationData_proc
END
GO
          
CREATE PROCEDURE [dbo].[GetAllBankReconciliationData_proc] (                
@CompanyId INT,      
@SubCompanyId INT,      
@LastReconDate VARCHAR(100),      
@COAId BIGINT,
@ReconciliationDate VARCHAR(100),
@IsLastRecon bit,
@IsClearedTab bit
 )                
AS                
BEGIN   
 BEGIN TRY                
     IF @IsLastRecon=1
	 BEGIN
			IF @IsClearedTab=0
			BEGIN
			Select  JD.Id as JournalId,jD.PostingDate as DocumentDate,JD.DocType as DocumentType,JD.DocSubType,
			JD.DocNo as DocRefNo,JD.EntityId,ENT.Name as EntityName,ISNULL(JD.DocDebit,0) DocDebit,ISNULL(JD.DocCredit,0) DocCredit,
			JD.DocumentId,JD.COAID as COAId,JD.ServiceCompanyId as ServiceEntityId,J.ModeOfReceipt as Mode,J.TransferRefNo as RefNo,Jd.Type,JD.ClearingDate,
			(
				Case When Jd.DocType in ('Bill Payment','Withdrawal','Cash Payment') 
				OR (JD.DocType='Transfer' AND JD.Type='Withdrawal')
				OR (JD.DocType='Journal' AND (JD.DocCredit IS Not NULL OR JD.DocCredit<>0))
				THEN 1 
				ELSE 0
				END ) 
			AS isWithdrawl,
			(
				Case when ((JD.DocCredit IS NOT NULL OR JD.DocCredit<>0) AND (
				Case When Jd.DocType in ('Bill Payment','Withdrawal','Cash Payment') 
				OR (JD.DocType='Transfer' AND JD.Type='Withdrawal')
				OR (JD.DocType='Journal' AND (JD.DocCredit IS Not NULL OR JD.DocCredit<>0))
				THEN 1 
				ELSE 0
				END )=1)
				THEN -JD.DocCredit
				WHEN (
				Case When Jd.DocType in ('Bill Payment','Withdrawal','Cash Payment') 
				OR (JD.DocType='Transfer' AND JD.Type='Withdrawal')
				OR (JD.DocType='Journal' AND (JD.DocCredit IS Not NULL OR JD.DocCredit<>0))
				THEN 1 
				ELSE 0
				END )=1
				THEN -JD.DocDebit
				ELSE JD.DocDebit
				END
			) AS Ammount,
			(
				Case WHEN JD.ClearingDate IS NULL OR JD.ClearingDate > @ReconciliationDate
				THEN 1
				ELSE 0
				END
			) AS IsUncleared,
			(
				Case WHEN JD.ClearingDate IS Not NULL
				THEN 1
				ELSE 0
				END
			) AS IsChecked,
			JD.Id AS JournalDetailId
			from Bean.Journal J with (nolock) Join Bean.JournalDetail JD with (nolock) on J.Id = Jd.JournalId join Bean.ChartOfAccount COA with (nolock) on JD.COAId = COA.Id 
			Left Join Bean.Entity Ent with (nolock) on Ent.Id = JD.EntityId 
			where J.CompanyId = @CompanyId and J.DocumentState Not In('Void', 'Recurring', 'Deleted', 'Reset', 'Parked') and JD.COAId = @COAId and JD.ServiceCompanyId = @SubCompanyId 
			and (JD.PostingDate <= @ReconciliationDate) and JD.ClearingDate is null and COA.IsBank = 1
			END
			--Union ALL
			ELSE
			BEGIN
			Select JD.Id as JournalId,jD.PostingDate as DocumentDate,JD.DocType as DocumentType,JD.DocSubType,
			JD.DocNo as DocRefNo,JD.EntityId,ENT.Name as EntityName,ISNULL(JD.DocDebit,0) DocDebit,ISNULL(JD.DocCredit,0) DocCredit,
			JD.DocumentId,JD.COAID as COAId,JD.ServiceCompanyId as ServiceEntityId,J.ModeOfReceipt as Mode,J.TransferRefNo as RefNo,Jd.Type,JD.ClearingDate,
			(
				Case When Jd.DocType in ('Bill Payment','Withdrawal','Cash Payment') 
				OR (JD.DocType='Transfer' AND JD.Type='Withdrawal')
				OR (JD.DocType='Journal' AND (JD.DocCredit IS Not NULL OR JD.DocCredit<>0))
				THEN 1 
				ELSE 0
				END ) 
			AS isWithdrawl,
			(
				Case when ((JD.DocCredit Is NOT NULL OR JD.DocCredit<>0) AND (
				Case When Jd.DocType in ('Bill Payment','Withdrawal','Cash Payment') 
				OR (JD.DocType='Transfer' AND JD.Type='Withdrawal')
				OR (JD.DocType='Journal' AND (JD.DocCredit IS Not NULL OR JD.DocCredit<>0))
				THEN 1 
				ELSE 0
				END )=1)
				THEN -JD.DocCredit
				WHEN (
				Case When Jd.DocType in ('Bill Payment','Withdrawal','Cash Payment') 
				OR (JD.DocType='Transfer' AND JD.Type='Withdrawal')
				OR (JD.DocType='Journal' AND (JD.DocCredit IS Not NULL OR JD.DocCredit<>0))
				THEN 1 
				ELSE 0
				END )=1
				THEN -JD.DocDebit
				ELSE JD.DocDebit
				END
			) AS Ammount,
			(
				Case WHEN JD.ClearingDate IS NULL OR JD.ClearingDate > @ReconciliationDate
				THEN 1
				ELSE 0
				END
			) AS IsUncleared,
			(
				Case WHEN JD.ClearingDate IS Not NULL
				THEN 1
				ELSE 0
				END
			) AS IsChecked,
			JD.Id AS JournalDetailId
			from Bean.Journal J with (nolock)
			Join Bean.JournalDetail JD with (nolock) on J.Id = Jd.JournalId join Bean.ChartOfAccount COA with (nolock) on JD.COAId = COA.Id 
			Left Join Bean.Entity Ent with (nolock) on Ent.Id = JD.EntityId where J.CompanyId = @CompanyId and J.DocumentState Not In('Void', 'Recurring', 'Deleted', 'Reset', 'Parked') 
			and JD.COAId = @COAId and JD.ServiceCompanyId = @SubCompanyId and(JD.PostingDate <= @ReconciliationDate) and (JD.ClearingDate is not null  AND(JD.ClearingDate > @ReconciliationDate or JD.ClearingDate > @LastReconDate))
			and COA.IsBank = 1 
			END
	 END
	 ELSE
	 BEGIN
		IF(@IsClearedTab=0)
		BEGIN
		Select  JD.Id as JournalId,jD.PostingDate as DocumentDate,JD.DocType as DocumentType,JD.DocSubType,
			JD.DocNo as DocRefNo,JD.EntityId,ENT.Name as EntityName,ISNULL(JD.DocDebit,0) DocDebit,ISNULL(JD.DocCredit,0) DocCredit,
			JD.DocumentId,JD.COAID as COAId,JD.ServiceCompanyId as ServiceEntityId,J.ModeOfReceipt as Mode,J.TransferRefNo as RefNo,Jd.Type,JD.ClearingDate,
			(
				Case When Jd.DocType in ('Bill Payment','Withdrawal','Cash Payment') 
				OR (JD.DocType='Transfer' AND JD.Type='Withdrawal')
				OR (JD.DocType='Journal' AND (JD.DocCredit IS Not NULL OR JD.DocCredit<>0))
				THEN 1 
				ELSE 0
				END ) 
			AS isWithdrawl,
			(
				Case when ((JD.DocCredit Is NOT NULL OR JD.DocCredit<>0) AND (
				Case When Jd.DocType in ('Bill Payment','Withdrawal','Cash Payment') 
				OR (JD.DocType='Transfer' AND JD.Type='Withdrawal')
				OR (JD.DocType='Journal' AND (JD.DocCredit IS Not NULL OR JD.DocCredit<>0))
				THEN 1 
				ELSE 0
				END )=1)
				THEN -JD.DocCredit
				WHEN (
				Case When Jd.DocType in ('Bill Payment','Withdrawal','Cash Payment') 
				OR (JD.DocType='Transfer' AND JD.Type='Withdrawal')
				OR (JD.DocType='Journal' AND (JD.DocCredit IS Not NULL OR JD.DocCredit<>0))
				THEN 1 
				ELSE 0
				END )=1
				THEN -JD.DocDebit
				ELSE JD.DocDebit
				END
			) AS Ammount,
			(
				Case WHEN JD.ClearingDate IS NULL OR JD.ClearingDate > @ReconciliationDate
				THEN 1
				ELSE 0
				END
			) AS IsUncleared,
			(
				Case WHEN JD.ClearingDate IS Not NULL
				THEN 1
				ELSE 0
				END
			) AS IsChecked,
			JD.Id AS JournalDetailId
		from Bean.Journal J Join Bean.JournalDetail JD on J.Id = Jd.JournalId 
		join Bean.ChartOfAccount COA on JD.COAId = COA.Id and COA.IsBank = 1 
		Left Join Bean.Entity Ent on Ent.Id = JD.EntityId where J.CompanyId = @CompanyId 
		and J.DocumentState Not In('Void', 'Recurring', 'Deleted', 'Reset', 'Parked') 
		and JD.COAId = @COAId and JD.ServiceCompanyId = @SubCompanyId 
		and(JD.PostingDate <= @ReconciliationDate) and JD.ClearingDate is null
		END
		ELSE
		BEGIN
		Select  JD.Id as JournalId,jD.PostingDate as DocumentDate,JD.DocType as DocumentType,JD.DocSubType,
			JD.DocNo as DocRefNo,JD.EntityId,ENT.Name as EntityName,ISNULL(JD.DocDebit,0) DocDebit,ISNULL(JD.DocCredit,0) DocCredit,
			JD.DocumentId,JD.COAID as COAId,JD.ServiceCompanyId as ServiceEntityId,J.ModeOfReceipt as Mode,J.TransferRefNo as RefNo,Jd.Type,JD.ClearingDate,
			(
				Case When Jd.DocType in ('Bill Payment','Withdrawal','Cash Payment') 
				OR (JD.DocType='Transfer' AND JD.Type='Withdrawal')
				OR (JD.DocType='Journal' AND (JD.DocCredit IS Not NULL OR JD.DocCredit<>0))
				THEN 1 
				ELSE 0
				END ) 
			AS isWithdrawl,
			(
				Case when ((JD.DocCredit Is NOT NULL OR JD.DocCredit<>0) AND (
				Case When Jd.DocType in ('Bill Payment','Withdrawal','Cash Payment') 
				OR (JD.DocType='Transfer' AND JD.Type='Withdrawal')
				OR (JD.DocType='Journal' AND (JD.DocCredit IS Not NULL OR JD.DocCredit<>0))
				THEN 1 
				ELSE 0
				END )=1)
				THEN -JD.DocCredit
				WHEN (
				Case When Jd.DocType in ('Bill Payment','Withdrawal','Cash Payment') 
				OR (JD.DocType='Transfer' AND JD.Type='Withdrawal')
				OR (JD.DocType='Journal' AND (JD.DocCredit IS Not NULL OR JD.DocCredit<>0))
				THEN 1 
				ELSE 0
				END )=1
				THEN -JD.DocDebit
				ELSE JD.DocDebit
				END
			) AS Ammount,
			(
				Case WHEN JD.ClearingDate IS NULL OR JD.ClearingDate > @ReconciliationDate
				THEN 1
				ELSE 0
				END
			) AS IsUncleared,
			(
				Case WHEN JD.ClearingDate IS Not NULL
				THEN 1
				ELSE 0
				END
			) AS IsChecked,
			JD.Id AS JournalDetailId
		from Bean.Journal J Join Bean.JournalDetail JD on J.Id = Jd.JournalId 
		join Bean.ChartOfAccount COA on JD.COAId = COA.Id and COA.IsBank = 1 
		Left Join Bean.Entity Ent on Ent.Id = JD.EntityId where J.CompanyId = @CompanyId 
		and J.DocumentState Not In('Void', 'Recurring', 'Deleted', 'Reset', 'Parked') 
		and JD.COAId = @COAId and JD.ServiceCompanyId = @SubCompanyId 
		and(JD.PostingDate <= @ReconciliationDate) and (JD.ClearingDate is not null  AND JD.ClearingDate > @ReconciliationDate)
		END
	 END
 END TRY              
              
 BEGIN CATCH              
  SELECT ERROR_NUMBER() AS ErrorNumber              
   ,ERROR_SEVERITY() AS ErrorSeverity              
   ,ERROR_STATE() AS ErrorState              
   ,ERROR_PROCEDURE() AS ErrorProcedure              
   ,ERROR_LINE() AS ErrorLine              
   ,ERROR_MESSAGE() AS ErrorMessage;              
  ROLLBACK TRAN;              
 END CATCH;              
END