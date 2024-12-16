USE SmartCursorPRD
GO

IF EXISTS ( Select 1 from sys.objects where name='GetAllBankReconciliationData_proc_v1'AND type='P')
BEGIN
 Drop Proc GetAllBankReconciliationData_proc_v1
END
GO
          
CREATE PROCEDURE [dbo].[GetAllBankReconciliationData_proc_v1] (                
@CompanyId INT,      
@SubCompanyId INT,      
@LastReconDate VARCHAR(100),      
@COAId BIGINT,
@ReconciliationDate VARCHAR(100),
@IsLastRecon bit,
@IsClearedTab bit,
@PageIndex INT,
@PageSize INT,
@RecordCount INT OUTPUT
 )                
AS                
BEGIN   
 BEGIN TRY
 
     IF @IsLastRecon=1
	 BEGIN
			IF @IsClearedTab=0
			BEGIN
			Select  ROW_NUMBER() OVER (ORDER BY JD.Id ASC) AS RowNumber,JD.Id as JournalId,jD.PostingDate as DocumentDate,JD.DocType as DocumentType,JD.DocSubType,
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
			into #Results_1
			from Bean.Journal J with (nolock) Join Bean.JournalDetail JD with (nolock) on J.Id = Jd.JournalId join Bean.ChartOfAccount COA with (nolock) on JD.COAId = COA.Id 
			Left Join Bean.Entity Ent with (nolock) on Ent.Id = JD.EntityId 
			where J.CompanyId = @CompanyId and J.DocumentState Not In('Void', 'Recurring', 'Deleted', 'Reset', 'Parked') and JD.COAId = @COAId and JD.ServiceCompanyId = @SubCompanyId 
			and (JD.PostingDate <= @ReconciliationDate) and JD.ClearingDate is null and COA.IsBank = 1

			SELECT *
			FROM #Results_1
			--WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
			Select @RecordCount=COUNT(*) from #Results_1
			DROP TABLE #Results_1

			END
			--Union ALL
			ELSE
			BEGIN
			Select ROW_NUMBER() OVER (ORDER BY JD.Id ASC) AS RowNumber,JD.Id as JournalId,jD.PostingDate as DocumentDate,JD.DocType as DocumentType,JD.DocSubType,
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
			into #Results_2
			from Bean.Journal J with (nolock)
			Join Bean.JournalDetail JD with (nolock) on J.Id = Jd.JournalId join Bean.ChartOfAccount COA with (nolock) on JD.COAId = COA.Id 
			Left Join Bean.Entity Ent with (nolock) on Ent.Id = JD.EntityId where J.CompanyId = @CompanyId and J.DocumentState Not In('Void', 'Recurring', 'Deleted', 'Reset', 'Parked') 
			and JD.COAId = @COAId and JD.ServiceCompanyId = @SubCompanyId and(JD.PostingDate <= @ReconciliationDate) and (JD.ClearingDate is not null  AND(JD.ClearingDate > @ReconciliationDate or JD.ClearingDate > @LastReconDate))
			and COA.IsBank = 1 

			SELECT *
			FROM #Results_2
			WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
			Select @RecordCount=COUNT(*) from #Results_2
			DROP TABLE #Results_2

			END
	 END
	 ELSE
	 BEGIN
		IF(@IsClearedTab=0)
		BEGIN
		Select  ROW_NUMBER() OVER (ORDER BY JD.Id ASC) AS RowNumber,JD.Id as JournalId,jD.PostingDate as DocumentDate,JD.DocType as DocumentType,JD.DocSubType,
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
			into #Results_3
		from Bean.Journal J Join Bean.JournalDetail JD on J.Id = Jd.JournalId 
		join Bean.ChartOfAccount COA on JD.COAId = COA.Id and COA.IsBank = 1 
		Left Join Bean.Entity Ent on Ent.Id = JD.EntityId where J.CompanyId = @CompanyId 
		and J.DocumentState Not In('Void', 'Recurring', 'Deleted', 'Reset', 'Parked') 
		and JD.COAId = @COAId and JD.ServiceCompanyId = @SubCompanyId 
		and(JD.PostingDate <= @ReconciliationDate) and JD.ClearingDate is null

		SELECT *
		FROM #Results_3
		--WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
		Select @RecordCount=COUNT(*) from #Results_3
		DROP TABLE #Results_3

		END
		ELSE
		BEGIN
		Select  ROW_NUMBER() OVER (ORDER BY JD.Id ASC) AS RowNumber,JD.Id as JournalId,jD.PostingDate as DocumentDate,JD.DocType as DocumentType,JD.DocSubType,
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
			into #Results_4
		from Bean.Journal J Join Bean.JournalDetail JD on J.Id = Jd.JournalId 
		join Bean.ChartOfAccount COA on JD.COAId = COA.Id and COA.IsBank = 1 
		Left Join Bean.Entity Ent on Ent.Id = JD.EntityId where J.CompanyId = @CompanyId 
		and J.DocumentState Not In('Void', 'Recurring', 'Deleted', 'Reset', 'Parked') 
		and JD.COAId = @COAId and JD.ServiceCompanyId = @SubCompanyId 
		and(JD.PostingDate <= @ReconciliationDate) and JD.ClearingDate is not null 

		SELECT *
		FROM #Results_4
		WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
		Select @RecordCount=COUNT(*) from #Results_4
		DROP TABLE #Results_4

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