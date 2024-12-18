USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CC_Opportunity_WF_Cases_Syncing_SP_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[CC_Opportunity_WF_Cases_Syncing_SP_New]
-- Exec [dbo].[CC_Opportunity_WF_Cases_Syncing_SP_New]  1
 @CompanyId Bigint
AS
BEGIN
     SELECT 'ClientCursor_Opportunity' Source,'WorkFlow_Case' Destination,[Source_OpportunityCount], [Destination_CaseCount], [Matching_Count], [Non_Matching_Count],
       isnull([Duplicate_Count],0)[Duplicate_Count] FROM 
       (
      SELECT * FROM 
      (
        SELECT 'Source_OpportunityCount' AS [CC_Opportunity], Count(Id) [SourceOpportunity_Count]
		  FROM ClientCursor.opportunity  Where CompanyId=@CompanyId And Status=1 AND  (IsTemp=0 OR IsTemp IS NULL)-- 3354
		
        UNION All

	    SELECT 'Destination_CaseCount' AS [WF_Case], Count(Opportunityid) [Total Opportunity]
		  FROM WorkFlow.CaseGroup  Where CompanyId=@CompanyId   -- 3388

		UNION All

        SELECT 'Matching_Count' [Matching_OpportunityCount], Count(id) as 'Matching_Count' 
		  FROM ClientCursor.opportunity 
          where Status=1  AND CompanyId=@CompanyId AND (IsTemp=0 OR IsTemp IS NULL) 
	     AND Id  IN (SELECT opportunityid FROM WorkFlow.CaseGroup where CompanyId=@CompanyId) -- 3233

        UNION All

        SELECT 'Non_Matching_Count' [NonMatching_OpportunityCount], Count(id) as 'NonMatching_OpportunityCount'
        FROM ClientCursor.opportunity where Status=1 AND CompanyId=@CompanyId AND (IsTemp=0 OR IsTemp IS NULL) 
        AND Id  NOT IN (SELECT opportunityid FROM WorkFlow.CaseGroup where CompanyId=@CompanyId) -- 1617

        UNION All

        Select 'Duplicate_Count' [Duplicate_Account], (Duplicate_Count) 'Duplicate_Account'
			From
			(
        SELECT Count(C.Id) 'Duplicate_Count',c.OpportunityId 'Duplicate_Account' FROM  WorkFlow.CaseGroup C 
         Inner Join  ClientCursor.opportunity o  on o.Id=c.OpportunityId
         where o.CompanyId=@CompanyId AND (IsTemp=0 OR IsTemp IS NULL)
	      Group By C.Id,C.OpportunityId Having Count(C.Id)>1
	   	) DupCount
     ) as AA
   ) Books
 PIVOT
 (
  SUM(SourceOpportunity_Count) FOR CC_Opportunity IN ([Source_OpportunityCount], [Destination_CaseCount], [Matching_Count], [Non_Matching_Count],[Duplicate_Count])
   ) Result;

END
GO
