USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Client_Bean_ENtity_Syncing_SP_New]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[WF_Client_Bean_ENtity_Syncing_SP_New]
	-- Exec [dbo].[WF_Client_Bean_ENtity_Syncing_SP_New]  1
	@CompanyId Bigint
As
Begin
	SELECT 'ClientCursor_Client' Source,'Bean_Entity' Destination,[Source_ClientCount], [Destination_EntityCount], [Matching_Count], [Non_Matching_Count],isnull([Duplicate_Count],0)[Duplicate_Count]
	FROM 
	(
		SELECT * FROM 
		(
			SELECT 'Source_ClientCount' AS [WF_Client], Count(Id) [SourceClient_Count]
			FROM WorkFlow.Client  Where CompanyId=@CompanyId and Status=1

			UNION All

			SELECT 'Destination_EntityCount' AS [Bean_Entity], Count(DocumentId) [DestinationEntity_Count]
			FROM Bean.Entity Where CompanyId=@CompanyId and ExternalEntityType='Client'

			UNION All

			SELECT 'Matching_Count' [Matching_ClientCount] ,Count(id) as 'Matching_Count' 
			FROM WorkFlow.Client where CompanyId=@CompanyId AND Id IN 
			(SELECT DocumentId FROM bean.Entity where CompanyId=@CompanyId and ExternalEntityType='Client')

			UNION All
	 
			SELECT 'Non_Matching_Count' [NonMatching_ClientCount], Count(id) as 'Non_Matching_Count' 
			FROM WorkFlow.Client where CompanyId=@CompanyId AND Id NOT IN 
			(SELECT DocumentId FROM bean.Entity where CompanyId=@CompanyId and ExternalEntityType='Client')

			UNION All

			Select 'Duplicate_Count' [Duplicate_Account], (Duplicate_Count) 'Duplicate_Account'
			From
			(
				SELECT Count(E.ID) 'Duplicate_Count', E.DocumentId 'Duplicate_Account'  
				From Bean.Entity E
				Inner join WorkFlow.Client C on C.Id=E.DocumentId
				Where E.CompanyId=@CompanyId 
				Group By E.Id, E.DocumentId Having Count(E.ID)>1
			) DupCount
		) as AA
	) Books
	PIVOT 
	(
		SUM(SourceClient_Count) FOR WF_Client IN ([Source_ClientCount], [Destination_EntityCount], [Matching_Count], [Non_Matching_Count],[Duplicate_Count])
	) Result;

END
GO
