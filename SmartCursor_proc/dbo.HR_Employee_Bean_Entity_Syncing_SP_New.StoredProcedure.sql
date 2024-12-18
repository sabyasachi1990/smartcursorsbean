USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Employee_Bean_Entity_Syncing_SP_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[HR_Employee_Bean_Entity_Syncing_SP_New]

-- Exec [dbo].[HR_Employee_Bean_Entity_Syncing_SP_New]  1
 
	@CompanyId Bigint

   AS
   BEGIN

SELECT 'HR_Employee' Source,'Bean_Entity' Destination,[Source_EmployeeCount], [Destination_EmployeeCount], [Matching_Count], [Non_Matching_Count],isnull([Duplicate_Count],0)[Duplicate_Count]
 FROM 
(
SELECT * FROM 
(
SELECT 'Source_EmployeeCount' AS [HR_Employee] ,Count(Id) [SourceEmployee_Count]FROM Common.Employee Where IsWorkflowOnly=0 and CompanyId=@CompanyId

UNION ALL

SELECT 'Destination_EmployeeCount' AS [HR_Employee] ,Count(Documentid) [DestinationEmployee_Count]FROM bean.entity Where CompanyId=@CompanyId and externalEntityType='Employee'UNION ALLSELECT 'Matching_Count' AS [Matching_EmployeeCount] ,Count(Id) [SourceEmployee_Count]FROM Common.Employee Where CompanyId=@CompanyId AND IsWorkflowOnly=0 and id in(SELECT Documentid FROM bean.entity Where CompanyId=@CompanyId and externalEntityType='Employee')UNION ALLSELECT 'Non_Matching_Count' AS [NonMatching_EmployeeCount] ,Count(Id) [DestinationEmployee_Count]FROM Common.Employee Where CompanyId=@CompanyId AND IsWorkflowOnly=0 and id NOT IN (SELECT Documentid FROM bean.entity Where CompanyId=@CompanyId and externalEntityType='Employee')UNION ALLselect 'Duplicate_Count' [Duplicate_Claim],Count(E.Id) 'Duplicate_Claim' from common.employee eInner join Bean.Entity B On e.id=B.Documentidwhere e.companyid=@CompanyId AND IsWorkflowOnly=0Group by E.IdHaving Count(E.id)>1) as AA) Books
PIVOT (
  SUM(SourceEmployee_Count) FOR HR_Employee IN ([Source_EmployeeCount], [Destination_EmployeeCount], [Matching_Count], [Non_Matching_Count],[Duplicate_Count])
) Result;
END
GO
