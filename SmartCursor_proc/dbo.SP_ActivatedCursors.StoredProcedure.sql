USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_ActivatedCursors]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ActivatedCursors](@PartnerCompanyId bigint)
AS BEGIN


    Select * From
(
select R.CompanyId,c.Name,c.Status, MM.Name as ModuleName,-- ISNULL(CompanyUserId,0) as UserCount,
    Row_Number() Over (Partition By R.CompanyId,c.Name,c.Status, MM.Name, ISNULL(CompanyUserId,0) Order By ISNULL(CompanyUserId,0)) As R_no
from Auth.UserRoleNew URN
inner join Auth.RoleNew R on R.Id = URN.RoleId
inner join Common.ModuleMaster MM on R.ModuleMasterId = MM.Id
inner join Common.Company C on R.CompanyId = C.Id
inner join Common.CompanyModule cm on cm.ModuleId=MM.id and CM.companyId=C.AccountingFirmId and CM.Status=1
Inner Join Common.CompanyUser As CU On CU.Id=URN.CompanyUserId
where URN.Status=1 and c.ParentId IS NULL and MM.IsMainCursor=1 and c.AccountingFirmId=@PartnerCompanyId  And CU.Status=1
group by R.companyId, c.Name, ModuleMasterId, MM.Name,c.Status,CompanyUserId
) As A
PIVOT (SUM(R_no) FOR ModuleName IN ([Admin Cursor],[Audit Cursor],[Bean Cursor],[BR Cursor],[Client Cursor],[Doc Cursor],[Dr Finance],[HR Cursor],[Knowledge Cursor],[Tax Cursor],[Workflow Cursor])) pvt
Order By Name

END
GO
