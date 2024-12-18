USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CompanyInformation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[CompanyInformation]
As
Begin

SELECT  *
FROM    (
select R.CompanyId,c.Name, MM.Name as ModuleName, ISNULL(COUNT(distinct CompanyUserId),0) as UserCount from Auth.UserRoleNew URN
inner join Auth.RoleNew R on R.Id = URN.RoleId
inner join Common.ModuleMaster MM on R.ModuleMasterId = MM.Id
inner join Common.Company C on R.CompanyId = C.Id
where URN.Status=1 and c.ParentId IS NULL and MM.IsModuleShow = 1
group by R.companyId, c.Name, ModuleMasterId, MM.Name
--order by R.CompanyId
) qwe
PIVOT (SUM(UserCount) FOR ModuleName IN ([Admin Cursor],[Analytics],[Audit Cursor],[Bean Cursor],[BR Cursor],[Client Cursor],[Doc Cursor],[Dr Finance],[HR Cursor],[Knowledge Cursor],[Partner Cursor],[Tax Cursor],[Workflow Cursor])) pvt
order by Name
 
End
GO
