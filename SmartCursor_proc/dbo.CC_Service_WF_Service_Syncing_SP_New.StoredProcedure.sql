USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CC_Service_WF_Service_Syncing_SP_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[CC_Service_WF_Service_Syncing_SP_New]
--- Exec [dbo].[CC_Service_WF_Service_Syncing_SP_New]  1
 @CompanyId Bigint
As
Begin


SELECT 'ClientCursor_Service' Source,'WorkFlow_Service' Destination,[Source_serviceCount], [Destination_CaseserviceCount], [Matching_Count], [Non_Matching_Count],
isnull([Duplicate_Count],0)[Duplicate_Count] FROM 
(
   SELECT * FROM 
    (
        SELECT 'Source_serviceCount' AS [CC_Service], Count(Distinct o.serviceid) [SourceService_Count]
		  FROM Common.Service s
		  Inner Join ClientCursor.Opportunity o on o.serviceid=s.Id
		  Where o.CompanyId=@CompanyId
		
		 UNION All

        SELECT 'Destination_CaseserviceCount' AS [WF_Service], Count(Distinct C.serviceid) [SourceService_Count]
		  FROM Common.Service s
		  Inner Join WorkFlow.CaseGroup C on C.serviceid=s.Id
          Where C.CompanyId=@CompanyId

		 UNION All

        SELECT 'Matching_Count' [Matching_ServiceCount], Count(Distinct o.serviceid) 'Matching_Count'
		  FROM Common.Service s Inner Join ClientCursor.Opportunity o on o.serviceid=s.Id
		  Where o.CompanyId=@CompanyId and o.ServiceId in
          (
           SELECT Distinct C.serviceid FROM Common.Service s
		     Inner Join WorkFlow.CaseGroup C on C.serviceid=s.Id Where C.CompanyId=@CompanyId )

		 UNION All

        SELECT 'Non_Matching_Count' [Matching_ServiceCount], Count(Distinct o.serviceid) 'NonMatching_Count'
		 FROM Common.Service s
		  Inner Join ClientCursor.Opportunity o on o.serviceid=s.Id
		  Where o.CompanyId=@CompanyId and o.ServiceId NOT IN
         (SELECT Distinct C.serviceid FROM Common.Service s
		    Inner Join WorkFlow.CaseGroup C on C.serviceid=s.Id Where C.CompanyId=@CompanyId )

		UNION All

		SELECT 'Duplicate_Count' AS [Duplicate_Service],[Duplicate_Service] AS [Duplicate_Count] 
		 FROM 
		(
		select Count(Distinct C.Id) 'Duplicate_Count',c.ServiceId [Duplicate_Service] From  WorkFlow.CaseGroup C 
		Inner Join Common.Service s on C.serviceid=s.Id
		Where C.CompanyId=@CompanyId
		 Group by  C.Id,c.ServiceId having count(C.ServiceId)>1
		  )as AA
    ) as AA

  ) Books
 PIVOT 
 (
  SUM(SourceService_Count) FOR CC_Service IN ([Source_serviceCount], [Destination_CaseserviceCount], [Matching_Count], [Non_Matching_Count],[Duplicate_Count])
 ) Result;

END


GO
