USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_leadsAccounts_Validation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   procedure [dbo].[Import_leadsAccounts_Validation]  ------EXEC Import_leadsAccounts_Validation 809,'50220569-4688-4D4D-A23D-62DE4DB8284D'
@companyId int,
@TransactionId uniqueidentifier
as
BEGIN

Begin
EXEC [dbo].[Import_ContactsDetailUPADTE_Validation] @companyId,@TransactionId
end 

BEGIN
EXEC [dbo].[Importleadsandaccounts] @companyId,@TransactionId

END
BEGIN
EXEC [dbo].[ImportaccountsIncharge] @companyId,@TransactionId
END 
END 



GO
