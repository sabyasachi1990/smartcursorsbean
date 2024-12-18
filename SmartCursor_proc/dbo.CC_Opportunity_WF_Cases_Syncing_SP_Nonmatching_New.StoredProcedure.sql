USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CC_Opportunity_WF_Cases_Syncing_SP_Nonmatching_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[CC_Opportunity_WF_Cases_Syncing_SP_Nonmatching_New]
-- Exec [dbo].[CC_Opportunity_WF_Cases_Syncing_SP_Nonmatching_New]  1
	@CompanyId Bigint
As
Begin

--Declare @CompanyId int=1

	SELECT o.Id 'NonMatching_CC_OpportunityId in WF Cases',o.Name 
	FROM ClientCursor.opportunity o Where Status=1 AND CompanyId=@CompanyId AND (IsTemp=0 OR IsTemp IS NULL) 
	AND Id  NOT IN (SELECT Opportunityid FROM WorkFlow.CaseGroup where CompanyId=@CompanyId)
     
	SELECT E.Opportunityid 'CC Opportunities Duplicate Id in WF Cases', Count(E.Opportunityid)'Duplicate_Count'  
	From WorkFlow.CaseGroup E
	Inner Join ClientCursor.Opportunity C on C.Id=E.Opportunityid
	Where E.CompanyId=@CompanyId AND (IsTemp=0 OR IsTemp IS NULL)
	Group By E.Opportunityid Having Count(E.Opportunityid)>1
END


GO
