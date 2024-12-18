USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Service_Bean_Item_Syncing_SP_New]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[WF_Service_Bean_Item_Syncing_SP_New]
-- Exec [dbo].[WF_Service_Bean_Item_Syncing_SP_New]  1
	@CompanyId Bigint
AS
BEGIN
	SELECT 'WF_Service' Source,'Bean_Item' Destination,[Source_Service], [Destination_Service], [Matching_Count], [Non_Matching_Count],
	isnull([Duplicate_Count],0)[Duplicate_Count] FROM 
	(
		SELECT * FROM 
		(
			Select 'Source_Service' AS [WF_Service] ,Count(Distinct cg.ServiceId) [SourceService_Count] from Common.Service s
			Inner join WorkFlow.CaseGroup CG on s.id=CG.serviceid
			where s.CompanyId=@CompanyId

			UNION ALL

			Select 'Destination_Service' AS [WF_Service] ,Count(Distinct I.DocumentId) [DestinationService_Count] 
			from Bean.Item I
			where I.CompanyId=@CompanyId

			UNION ALL

			select 'Matching_Count' AS [Matching_ServiceCount] ,Count(Distinct cg.ServiceId) [SourceService_Count] 
			from Common.Service s
			Inner join WorkFlow.CaseGroup CG on s.id=CG.serviceid
			where s.CompanyId=@CompanyId AND cg.ServiceId in
			(select Distinct I.DocumentId from Bean.Item I where I.CompanyId=@CompanyId)

			UNION ALL

			select 'Non_Matching_Count' AS [NonMatching_ServiceCount] ,Count(Distinct cg.ServiceId) [SourceService_Count]
			from Common.Service s
			Inner join WorkFlow.CaseGroup CG on s.id=CG.serviceid
			where s.CompanyId=@CompanyId AND cg.ServiceId NOT IN
			(select Distinct I.DocumentId from Bean.Item I where I.CompanyId=@CompanyId)

			UNION ALL

			select 'DuplicateCount_Count' [Duplicate_Service],Count(Distinct cg.ServiceId) 'Duplicate_Service' 			from Common.Service s			Inner Join WorkFlow.CaseGroup CG on s.id=cg.ServiceId			Inner join Bean.Item I On I.DocumentId=s.Id			where s.companyid=@CompanyId			Group by cg.ServiceId			Having Count(Distinct cg.ServiceId)>1		) as AA	) Books
	PIVOT 
	(
		SUM(SourceService_Count) FOR WF_Service IN ([Source_Service], [Destination_Service], [Matching_Count], [Non_Matching_Count],[Duplicate_Count])
	) Result;
END
GO
