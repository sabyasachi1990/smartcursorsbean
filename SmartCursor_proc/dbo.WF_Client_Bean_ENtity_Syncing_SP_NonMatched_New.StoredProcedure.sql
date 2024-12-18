USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Client_Bean_ENtity_Syncing_SP_NonMatched_New]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[WF_Client_Bean_ENtity_Syncing_SP_NonMatched_New]
-- Exec [dbo].[WF_Client_Bean_ENtity_Syncing_SP_NonMatched_New] 1
	@CompanyId Bigint
AS
BEGIN

	SELECT c.Id as 'NonMatching_WF_ClientId in Bean Entity',c.Name FROM  WorkFlow.Client c where 
	CompanyId=@CompanyId AND Id  NOT IN (
	SELECT DocumentId FROM bean.Entity where CompanyId=@CompanyId and ExternalEntityType='Client')

	SELECT  E.DocumentId 'Client Duplicate Id in Bean Entity',  Count(E.ID)'Duplicate_Count'  
	From Bean.Entity E
	Inner join WorkFlow.Client C on C.Id=E.DocumentId
	Where E.CompanyId=@CompanyId 
	Group By E.Id, E.DocumentId Having Count(E.DocumentId)>1

END




GO
