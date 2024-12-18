USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[DeleteCompanyDataCursor_Final]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[DeleteCompanyDataCursor_Final] -----> EXEC dbo.DeleteCompanyDataCursor_Final
AS

BEGIN

DECLARE @CompanyId Int

DECLARE CompanyDataDeletion CURSOR 
FOR 
	SELECT 
		Id
	FROM 
		Common.Company 
	WHERE 
		Status != 1 AND ParentId IS NULL AND Id NOT IN (1804);

OPEN CompanyDataDeletion

FETCH NEXT FROM CompanyDataDeletion INTO @CompanyId

WHILE @@FETCH_STATUS = 0
BEGIN

	EXEC dbo.DeleteCompanyData_AllCursors @CompanyId

	FETCH NEXT FROM CompanyDataDeletion INTO @CompanyId

END

CLOSE CompanyDataDeletion
DEALLOCATE CompanyDataDeletion


END
GO
