USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CC_Account_WF_Client_Syncing_SP_Non_Matched_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[CC_Account_WF_Client_Syncing_SP_Non_Matched_New]
-- Exec [dbo].[CC_Account_WF_Client_Syncing_SP_Non_Matched_New] 1
	@CompanyId Bigint
As
Begin
	------- Non_matching----

	SELECT id as 'NonMatching_CC_AccountId in WF Client',Name AccountName 
	FROM ClientCursor.Account where Status=1 AND IsAccount=1 AND CompanyId=@CompanyId AND Id  NOT IN 
	(SELECT AccountId FROM WorkFlow.Client where CompanyId=@CompanyId and AccountId is not null)


	SELECT E.AccountId 'CC Account Duplicate Id in WF Client', Count(E.AccountId)'Duplicate_Count'  
	From WorkFlow.Client E
	Inner Join ClientCursor.Account C on C.Id=E.AccountId
	Where E.CompanyId=@CompanyId AND C.IsAccount=1
	Group By E.AccountId Having Count(E.AccountId)>1

END
GO
