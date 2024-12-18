USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_AutoNumber_Monaraate]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--Exec [dbo].[Common_AutoNumber_Monaraate]

CREATE Procedure [dbo].[Common_AutoNumber_Monaraate]
AS
BEGIN 
    --select * from Common.AutoNumber a where a.CompanyId=1 and a.ModuleMasterId=1
    --================================================ CC=================================================
    --SELECT Distinct id,AccountId AS 'Auto Number',CompanyId,'ClientCursor.Account' as 'Table Name','CC' AS CursorName FROM 
    --(
    --SELECT CompanyId,AccountId,RANK () OVER ( PARTITION BY AccountId,CompanyId ORDER BY Id  DESC ) as Rank FROM ClientCursor.Account 
    --WHERE AccountId IS NOT NULL 
    --)GG WHERE RANK<>1
    
    --UNION ALL 

	select CompanyId,CompanyName,'Client Cursor' AS ModuleName , 'Opportunity' AS ScreenName ,AutoNumber,[Count],'ClientCursor.Opportunity' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.OpportunityNumber AS AutoNumber,count(A.Id) as 'Count'FROM ClientCursor.Opportunity A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE OpportunityNumber IS NOT NULL ---and CompanyId=1077
	group by CompanyId,OpportunityNumber,C.Name
	
	)gg 
	where [Count]<>1
    
    
    UNION ALL 
	select CompanyId,CompanyName,'Client Cursor' AS ModuleName , 'Quotation' AS ScreenName ,AutoNumber,[Count],'ClientCursor.Quotation' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.QuoteNumber AS AutoNumber,count(A.Id) as 'Count'FROM ClientCursor.Quotation A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE QuoteNumber IS NOT NULL ---and CompanyId=1077
	group by CompanyId,QuoteNumber,C.Name
	
	)gg 
	where [Count]<>1
    
    --UNION ALL 
    
    --SELECT Distinct id, QuoteNumber  AS 'Auto Number',CompanyId,'CC_ClientCursor.Provision' as 'Table Name','CC' AS CursorName FROM 
    --(
    --SELECT ID,CompanyId,Provision,RANK () OVER ( PARTITION BY QuoteNumber,CompanyId ORDER BY Id  DESC ) as Rank FROM ClientCursor.Quotation 
    --WHERE Provision IS NOT NULL 
    --)GG WHERE RANK<>1
    --UNION ALL 
    --===================================================WF============================================
	select CompanyId,CompanyName,'Workflow Cursor' AS ModuleName , 'Invoice' AS ScreenName ,AutoNumber,[Count],'workflow.Invoice' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.TempNumber AS AutoNumber,count(A.Id) as 'Count'FROM workflow.Invoice A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE TempNumber IS NOT NULL ---and CompanyId=107
	group by CompanyId,TempNumber,C.Name 
	
	)gg 
	where [Count]<>1
    
    
    UNION ALL 
    
	select CompanyId,CompanyName,'Workflow Cursor' AS ModuleName , 'Invoice' AS ScreenName ,AutoNumber,[Count],'workflow.Invoice' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.Number AS AutoNumber,count(A.Id) as 'Count'FROM workflow.Invoice A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE Number IS NOT NULL ---and CompanyId=1077
	group by CompanyId,Number,C.Name
	
	)gg 
	where [Count]<>1
    
    UNION ALL 

	select CompanyId,CompanyName,'Workflow Cursor' AS ModuleName , 'Client' AS ScreenName ,AutoNumber,[Count],'workflow.Client' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.SystemRefNo AS AutoNumber,count(A.Id) as 'Count'FROM workflow.Client A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE SystemRefNo IS NOT NULL ---and CompanyId=1077
	group by CompanyId,SystemRefNo,C.Name
	
	)gg 
	where [Count]<>1
    
    UNION ALL 
    
	select CompanyId,CompanyName,'Workflow Cursor' AS ModuleName , 'Cases' AS ScreenName ,AutoNumber,[Count],'workflow.CaseGroup' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.CaseNumber AS AutoNumber,count(A.Id) as 'Count'FROM workflow.CaseGroup A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE CaseNumber IS NOT NULL ---and CompanyId=1077
	group by CompanyId,CaseNumber,C.Name
	
	)gg 
	where [Count]<>1
    --===================================================HR============================================
	--UNION ALL 
	select CompanyId,CompanyName,'HR Cursor' AS ModuleName , 'Employee' AS ScreenName ,AutoNumber,[Count],'Common.Employee' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.EmployeeId AS AutoNumber,count(A.Id) as 'Count'FROM Common.Employee A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE EmployeeId IS NOT NULL ---and CompanyId=1077
	group by CompanyId,EmployeeId,C.Name
	
	)gg 
	where [Count]<>1
    
    
    UNION ALL 
    
	select CompanyId,CompanyName,'HR Cursor' AS ModuleName , 'JobPosting' AS ScreenName ,AutoNumber,[Count],'HR.JobPosting' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.JobId AS AutoNumber,count(A.Id) as 'Count'FROM HR.JobPosting A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE JobId IS NOT NULL ---and CompanyId=1077
	group by CompanyId,JobId,C.Name
	
	)gg 
	where [Count]<>1
    
    UNION ALL 
    
	select CompanyId,CompanyName,'HR Cursor' AS ModuleName , 'JobApplication' AS ScreenName ,AutoNumber,[Count],'HR.JobApplication' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.JobApplicationId AS AutoNumber,count(A.Id) as 'Count'FROM HR.JobApplication A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE JobApplicationId IS NOT NULL ---and CompanyId=1077
	group by CompanyId,JobApplicationId,C.Name
	
	)gg 
	where [Count]<>1
    
    UNION ALL 
    
    select CompanyId,CompanyName,'HR Cursor' AS ModuleName , 'Training' AS ScreenName ,AutoNumber,[Count],'HR.Training' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.TrainingNumber AS AutoNumber,count(A.Id) as 'Count'FROM HR.Training A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE TrainingNumber IS NOT NULL ---and CompanyId=1077
	group by CompanyId,TrainingNumber,C.Name
	
	)gg 
	where [Count]<>1
    
    UNION ALL 
    
	select CompanyId,CompanyName,'HR Cursor' AS ModuleName , 'EmployeeClaim1' AS ScreenName ,AutoNumber,[Count],'HR.EmployeeClaim1' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.ClaimNumber AS AutoNumber,count(A.Id) as 'Count'FROM HR.EmployeeClaim1 A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE ClaimNumber IS NOT NULL ---and CompanyId=1077
	group by CompanyId,ClaimNumber,C.Name
	
	)gg 
	where [Count]<>1

	---=================================================================== BR ==================================
	--UNION ALL 
	select CompanyId,CompanyName,'BR Cursor' AS ModuleName , 'Employee' AS ScreenName ,AutoNumber,[Count],'Common.Employee' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.WFMemberId AS AutoNumber,count(A.Id) as 'Count'FROM Common.Employee A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE WFMemberId IS NOT NULL ---and CompanyId=1077
	group by CompanyId,WFMemberId,C.Name
	
	)gg 
	where [Count]<>1

	 --UNION ALL 
	--=================================================================== Bean ========================================
	select CompanyId,CompanyName,'Bean Cursor' AS ModuleName , 'Receipt' AS ScreenName ,AutoNumber,[Count],'Bean.Receipt' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.SystemRefNo AS AutoNumber,count(A.Id) as 'Count'FROM Bean.Receipt A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE SystemRefNo IS NOT NULL ---and CompanyId=1077
	group by CompanyId,SystemRefNo,C.Name
	
	)gg 
	where [Count]<>1

	 UNION ALL 

	select CompanyId,CompanyName,'Bean Cursor' AS ModuleName , 'CashSale' AS ScreenName ,AutoNumber,[Count],'Bean.CashSale' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.CashSaleNumber AS AutoNumber,count(A.Id) as 'Count'FROM Bean.CashSale A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE CashSaleNumber IS NOT NULL ---and CompanyId=1077
	group by CompanyId,CashSaleNumber,C.Name
	
	)gg 
	where [Count]<>1

	UNION ALL 

	select CompanyId,CompanyName,'Bean Cursor' AS ModuleName , 'WithDrawal' AS ScreenName ,AutoNumber,[Count],'Bean.WithDrawal' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.SystemRefNo AS AutoNumber,count(A.Id) as 'Count'FROM Bean.WithDrawal A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE SystemRefNo IS NOT NULL  and doctype in ('Withdrawal','Cash Payment','Deposit')  ---and CompanyId=1077
	group by CompanyId,SystemRefNo,C.Name
	
	)gg 
	where [Count]<>1

	UNION ALL 


	select CompanyId,CompanyName,'Bean Cursor' AS ModuleName , 'Payment' AS ScreenName ,AutoNumber,[Count],'Bean.Payment' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.SystemRefNo AS AutoNumber,count(A.Id) as 'Count'FROM Bean.Payment A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE SystemRefNo IS NOT NULL   ---and CompanyId=1077
	group by CompanyId,SystemRefNo,C.Name
	
	)gg 
	where [Count]<>1

	UNION ALL 

	select CompanyId,CompanyName,'Bean Cursor' AS ModuleName , 'Invoice' AS ScreenName ,AutoNumber,[Count],'Bean.Invoice' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.InvoiceNumber AS AutoNumber,count(A.Id) as 'Count'FROM Bean.Invoice A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE InvoiceNumber IS NOT NULL and doctype in ('Invoice','Debt Provision','Credit Note')  ---and CompanyId=1077
	group by CompanyId,InvoiceNumber,C.Name
	
	)gg 
	where [Count]<>1


	 UNION ALL 

	select CompanyId,CompanyName,'Bean Cursor' AS ModuleName , 'CreditMemo' AS ScreenName ,AutoNumber,[Count],'Bean.CreditMemo' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.CreditMemoNumber AS AutoNumber,count(A.Id) as 'Count'FROM Bean.CreditMemo A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE CreditMemoNumber IS NOT NULL  ---and CompanyId=1077
	group by CompanyId,CreditMemoNumber,C.Name
	
	)gg 
	where [Count]<>1


	 UNION ALL 

	select CompanyId,CompanyName,'Bean Cursor' AS ModuleName , 'DebitNote' AS ScreenName ,AutoNumber,[Count],'Bean.DebitNote' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.DebitNoteNumber AS AutoNumber,count(A.Id) as 'Count'FROM Bean.DebitNote A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE DebitNoteNumber IS NOT NULL  ---and CompanyId=1077
	group by CompanyId,DebitNoteNumber,C.Name
	)gg 
	where [Count]<>1

	UNION ALL 
	select CompanyId,CompanyName,'Bean Cursor' AS ModuleName , 'BankTransfer' AS ScreenName ,AutoNumber,[Count],'Bean.BankTransfer' AS TableName from 
	(
	SELECT A.CompanyId,C.Name AS CompanyName,A.SystemRefNo AS AutoNumber,count(A.Id) as 'Count'FROM Bean.BankTransfer A
	INNER JOIN Common.Company C ON C.ID=A.CompanyId
    WHERE SystemRefNo IS NOT NULL  ---and CompanyId=1077
	group by CompanyId,SystemRefNo,C.Name
	
	)gg 
	where [Count]<>1

END  
    
GO
