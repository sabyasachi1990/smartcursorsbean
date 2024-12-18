USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Service_Bean_Item_Syncing_NonMatched_SP_New]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[WF_Service_Bean_Item_Syncing_NonMatched_SP_New]
-- Exec [dbo].[WF_Service_Bean_Item_Syncing_NonMatched_SP_New] 1
	@CompanyId Bigint
As
Begin

	Select S.Id 'Clinet_Manually_Not_Synched_WF_ServiceId into Bean Item', s.Name 
	From Common.Service S
	Where S.CompanyId=@CompanyId AND S.Status=1 And S.Id NOT IN
	(Select I.DocumentId from Bean.Item I where I.CompanyId=@CompanyId and DocumentId is not null)

	Select I.DocumentId 'WF Service Duplicate Id in Bean Item', Count(I.DocumentId) 'Duplicate_Count' 
	From Bean.Item I
	Inner join Common.Service S On I.DocumentId=S.Id
	where S.Companyid=@CompanyId
	Group by I.DocumentId
	Having Count(I.DocumentId)>1

END



GO
