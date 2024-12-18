USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Sprint_36_Migration_Script]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Bean_Sprint_36_Migration_Script]
(
@CompanyId int
)
As
Begin
update Common.AutoNumber Set IsEditableDisable=0 where ModuleMasterId=4 and IsEditableDisable=1 and EntityType not in ('VendorBill') and CompanyId=@CompanyId

update Bean.Entity set IsExternalData=1 where IsShowPayroll=0 and Companyid=@CompanyId
END
GO
