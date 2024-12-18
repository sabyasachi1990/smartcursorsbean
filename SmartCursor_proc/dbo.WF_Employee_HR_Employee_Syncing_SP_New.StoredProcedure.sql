USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Employee_HR_Employee_Syncing_SP_New]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[WF_Employee_HR_Employee_Syncing_SP_New]

---- Exec [dbo].[WF_Employee_HR_Employee_Syncing_SP_New]  1
 
	@CompanyId Bigint=1

   AS
   BEGIN

SELECT 'WF_Employee' Source,'HR_Employee' Destination,[Source_Employee], [Destination_Employee], [Matching_Count], [Non_Matching_Count],
isnull([Duplicate_Count],0)[Duplicate_Count] FROM 
(
SELECT * FROM 
(
select 'Source_Employee' AS [WF_Employee] ,Count(e.Id) [Sourceemployee_Count]
 from Common.Employee e where CompanyId=@CompanyId and IsWorkflowOnly=1 and IsHROnly=1

 UNION ALL

 select 'Destination_Employee' AS [HR_Employee] ,Count(e.Id) [Destinationemployee_Count]
 from Common.Employee e where CompanyId=@CompanyId and IsWorkflowOnly=0

 UNION ALL

 select 'Matching_Count' AS [Matching_EmployeeCount] ,Count(Id) [Sourceemployee_Count]
 from Common.Employee  where CompanyId=@CompanyId and IsWorkflowOnly=1 and IsHROnly=1 and id in
(select e.Id from Common.Employee e where CompanyId=@CompanyId and IsWorkflowOnly=0)

UNION ALL

 select 'Non_Matching_Count' AS [NonMatching_EmployeeCount] ,Count(Id) [Sourceemployee_Count]
 from Common.Employee  where CompanyId=@CompanyId and IsWorkflowOnly=1 and IsHROnly=1 and id NOT IN 
(select e.Id from Common.Employee e where CompanyId=@CompanyId and IsWorkflowOnly=0)

UNION ALL

select 'Duplicate_Count' [Duplicate_Employee],Count(e.Id) 'Duplicate_employee' from Common.Employee e 
Inner join Common.Employee A on e.id=A.Id
where e.CompanyId=@CompanyId and e.IsWorkflowOnly=1 and e.IsWorkflowOnly=0 and e.IsHROnly=1
Group by e.id
Having Count(e.id)>1

) as AA) Books
PIVOT (
  SUM(Sourceemployee_Count) FOR WF_Employee IN ([Source_Employee], [Destination_Employee], [Matching_Count], [Non_Matching_Count],
[Duplicate_Count])
) Result;

END
GO
