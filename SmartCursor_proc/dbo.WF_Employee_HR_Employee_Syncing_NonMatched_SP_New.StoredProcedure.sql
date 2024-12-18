USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Employee_HR_Employee_Syncing_NonMatched_SP_New]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[WF_Employee_HR_Employee_Syncing_NonMatched_SP_New]
-- Exec [dbo].[WF_Employee_HR_Employee_Syncing_NonMatched_SP_New] 1
	@CompanyId Bigint
As
Begin

	 select Id 'NonMatching_Employee',FirstName as Name
	 from Common.Employee  where CompanyId=@CompanyId and IsWorkflowOnly=1 and IsHROnly=1 and id NOT IN 
	(select e.Id from Common.Employee e where CompanyId=@CompanyId and IsWorkflowOnly=0)

END
GO
