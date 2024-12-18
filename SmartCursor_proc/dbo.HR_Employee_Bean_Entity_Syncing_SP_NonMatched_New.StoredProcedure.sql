USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Employee_Bean_Entity_Syncing_SP_NonMatched_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[HR_Employee_Bean_Entity_Syncing_SP_NonMatched_New]
-- Exec [dbo].[HR_Employee_Bean_Entity_Syncing_SP_NonMatched_New] 1
	@CompanyId Bigint
As
Begin

	SELECT Id 'Non_Matching_HR_Employee in Bean Entity',FirstName, LastName
	FROM Common.Employee Where CompanyId=@CompanyId AND IsWorkflowOnly=0 and id NOT IN 
	(SELECT Documentid FROM bean.entity Where CompanyId=@CompanyId and ExternalEntityType='Employee')

	SELECT E.Documentid 'Employee Duplicate Id in Bean Entity', Count(E.Documentid)'Duplicate_Count'  
	From Bean.entity E
	Inner Join Common.Employee C on C.Id=E.Documentid
	Where E.CompanyId=@CompanyId 
	Group By E.Documentid Having Count(E.Documentid)>1

END

GO
