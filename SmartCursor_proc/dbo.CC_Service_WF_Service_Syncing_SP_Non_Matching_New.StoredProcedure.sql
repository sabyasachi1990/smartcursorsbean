USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CC_Service_WF_Service_Syncing_SP_Non_Matching_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[CC_Service_WF_Service_Syncing_SP_Non_Matching_New]
-- Exec [dbo].[CC_Service_WF_Service_Syncing_SP_Non_Matching_New]  1
	@CompanyId Bigint
As
Begin

	SELECT  Distinct o.ServiceId 'CCNonMatchingServiceid in WF Service',s.Name
	FROM Common.Service s
	Inner Join ClientCursor.Opportunity o on o.serviceid=s.Id
	Where o.CompanyId=@CompanyId and o.ServiceId NOT IN
	(SELECT Distinct C.ServiceId FROM Common.Service s
	Inner Join WorkFlow.CaseGroup C on C.serviceid=s.Id Where C.CompanyId=@CompanyId)


	SELECT Distinct E.ServiceId 'CC Service Duplicate Id in WF service', Count(Distinct E.ServiceId)'Duplicate_Count'  
	From WorkFlow.CaseGroup E
	Inner Join Common.Service C on C.Id=E.ServiceId
	Where E.CompanyId=@CompanyId
	Group By E.ServiceId Having Count(Distinct E.ServiceId)>1

END

GO
