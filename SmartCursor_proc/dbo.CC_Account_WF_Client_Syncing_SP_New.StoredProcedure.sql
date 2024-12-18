USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CC_Account_WF_Client_Syncing_SP_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CC_Account_WF_Client_Syncing_SP_New]
-- Exec [dbo].[CC_Account_WF_Client_Syncing_SP_New]  1
	@CompanyId Bigint
As
Begin
	SELECT 'ClientCursor_Account' Source,'WorkFlow_Client' Destination, 
	[Source_AccountCount], [Destination_ClientCount], [Matching_Count], [Non_Matching_Count], isnull([Duplicate_Count],0)[Duplicate_Count]  FROM 
	(
		SELECT * FROM 
		(
			SELECT 'Source_AccountCount' AS [CC_Account], Count(Id) [SourceAccount_Count]
				FROM ClientCursor.Account  Where CompanyId=@CompanyId And Status=1 and IsAccount=1

			UNION All

			SELECT 'Destination_ClientCount' AS [WF_Client], Count(AccountId) [Total Client]
				FROM WorkFlow.Client  Where CompanyId=@CompanyId And Status=1 

			UNION All

			SELECT 'Matching_Count' [Matching_AccountCount], Count(id) as 'Matching_Count' 
				FROM ClientCursor.Account where Status=1 AND IsAccount=1 AND CompanyId=@CompanyId AND Id IN 
				(SELECT AccountId FROM WorkFlow.Client where CompanyId=@CompanyId)

			UNION All

			SELECT 'Non_Matching_Count' [NonMatching_AccountCount],Count(id) as 'NonMatching_AccountCount' 
				FROM ClientCursor.Account  where Status=1 AND IsAccount=1 AND CompanyId=@CompanyId AND Id NOT IN 
				(SELECT AccountId FROM WorkFlow.Client where CompanyId=@CompanyId)

			UNION All

			Select 'Duplicate_Count' [Duplicate_Account], (Duplicate_Count) 'Duplicate_Account'
			From
			(
				SELECT Count(C.ID) 'Duplicate_Count', C.AccountId 'Duplicate_Account'  From WorkFlow.Client C
				Inner join ClientCursor.Account A on A.Id=C.AccountId
				where A.CompanyId=@CompanyId 
				Group By C.Id,C.AccountId Having Count(C.ID)>1
			) DupCount

		) as AA
	) Books
	PIVOT 
	(
		SUM(SourceAccount_Count) FOR 
		CC_ACCount IN ([Source_AccountCount], [Destination_ClientCount], [Matching_Count], [Non_Matching_Count],[Duplicate_Count])
	) Result;
END

--------- Non_matching----

--SELECT id as 'NonMatching_AccountId',Name AccountName FROM ClientCursor.Account where Status=1 
--AND IsAccount=1 AND CompanyId=1 AND Id  NOT IN (
--SELECT AccountId FROM WorkFlow.Client where CompanyId=1)

GO
