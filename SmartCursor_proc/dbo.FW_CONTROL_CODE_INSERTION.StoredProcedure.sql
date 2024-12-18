USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_CONTROL_CODE_INSERTION]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE     PROC [dbo].[FW_CONTROL_CODE_INSERTION] (@unique_companyId bigint, @new_CompanyId bigint, @module_name nvarchar(100))
AS
BEGIN
----BEGIN TRANSACTION
BEGIN TRY

--DECLARE 
--	@unique_companyId BIGINT = 0,
--	@new_CompanyId BIGINT = 2050,--2799
--	@module_name NVARCHAR(100) = 'Admin Cursor'


DROP TABLE IF EXISTS #Delete
DROP TABLE IF EXISTS #DeleteId
 
SELECT * INTO #Delete FROM(
SELECT  A.Id as ControlCodeId, B.Id as ControlCodeCategoryId, B.ControlCodeCategoryCode,CodeKey, A.Jurisdiction, 
C.Jurisdiction AS CompanyJurisdiction
FROM Common.ControlCode AS A
LEFT JOIN Common.ControlCodeCategory AS B ON B.Id = A.ControlCategoryId AND ControlCodeCategoryCode IN ('IdType','Tax Classification','PayComponentType')
LEFT JOIN common.Company AS C ON C.Id = B.CompanyId
WHERE C.Id = @new_CompanyId AND CodeKey IN ('Passport','Foreign Registration Number','Others','FIN','NRIC(Blue)','NRIC(Pink)','Earning','Deduction','Reimbursement','N/A','Passport','Aadhar','Voter Id')
 AND (A.Jurisdiction = 'India' OR (C.Jurisdiction = 'India' AND A.Jurisdiction IS NULL))
) AS A

SELECT DISTINCT ControlCodeId  INTO #DeleteId FROM ( 
SELECT ControlCodeId FROM #Delete
WHERE ControlCodeCategoryCode = 'IdType'  
AND CodeKey IN ('Passport','Foreign Registration Number','Others','FIN','NRIC(Blue)','NRIC(Pink)') AND Jurisdiction IS NULL AND CompanyJurisdiction = 'India'

UNION ALL

SELECT ControlCodeId FROM #Delete
WHERE ControlCodeCategoryCode = 'Tax Classification'  
AND CodeKey ='Others' AND Jurisdiction IS NULL AND CompanyJurisdiction = 'India'

UNION ALL

SELECT ControlCodeId FROM #Delete
WHERE ControlCodeCategoryCode = 'PayComponentType' 
AND CodeKey IN ('Earning','Deduction','Reimbursement','N/A') AND Jurisdiction IS NULL AND CompanyJurisdiction = 'India'

UNION ALL

SELECT ControlCodeId FROM #Delete
WHERE ControlCodeCategoryCode = 'IdType'  
AND CodeKey IN ('Passport','Aadhar','Voter Id','Others') AND Jurisdiction = 'India'

UNION ALL

SELECT ControlCodeId FROM #Delete
WHERE ControlCodeCategoryCode = 'Tax Classification'  
AND CodeKey ='Others' AND Jurisdiction = 'India'

UNION ALL

SELECT ControlCodeId FROM #Delete
WHERE ControlCodeCategoryCode = 'PayComponentType' 
AND CodeKey IN ('Earning','Deduction') AND Jurisdiction = 'India'
) AS A

DECLARE @dynamicControlCategoryData NVARCHAR(MAX) = '(select (SELECT MAX(Id) FROM Common.ControlCodeCategory)+ROW_NUMBER() OVER(ORDER BY ID)  AS Id,' + Convert(NVARCHAR(20), @new_CompanyId) + ',ControlCodeCategoryCode, ControlCodeCategoryDescription, DataType, Format, RecOrder, Remarks, UserCreated, GETUTCDATE(), null, null, Version, Status, ModuleNamesUsing, DefaultValue from Common.ControlCodeCategory where CompanyId=' + Convert(NVARCHAR(20), @unique_companyId) + ' and ControlCodeCategoryCode not in (select ControlCodeCategoryCode from  Common.ControlCodeCategory where CompanyId=' + Convert(NVARCHAR(20), @new_CompanyId) + ' and ModuleNamesUsing like ''%' + @module_name + '%'') and ModuleNamesUsing like ''%' + @module_name + '%'')'

PRINT @dynamicControlCategoryData
PRINT 'FW_CONTROL_CODE_INSERTION---->>>Insertion Common.ControlCodeCategory --start'

INSERT INTO Common.ControlCodeCategory
EXEC (@dynamicControlCategoryData)

PRINT 'FW_CONTROL_CODE_INSERTION ----->>>>>Insertion Common.ControlCodeCategory --END'

DECLARE @dynamicControlCodeData NVARCHAR(max) = 'select (SELECT MAX(Id) FROM Common.ControlCode)+ROW_NUMBER() OVER(ORDER BY C.ID) AS Id, CC_new.Id  as controlCategoryId, C.CodeKey,C.CodeValue,C.IsSystem,C.RecOrder,C.Remarks,C.UserCreated,CC.CreatedDate,C.ModifiedBy,C.ModifiedDate,C.Version,C.Status,C.IsDefault,C.ModuleNamesUsing,C.Jurisdiction from Common.ControlCodeCategory CC
    join Common.ControlCode C on C.ControlCategoryId = CC.Id
    left join Common.ControlCodeCategory CC_New on CC.ControlCodeCategoryCode = CC_New.ControlCodeCategoryCode
    where CC.CompanyId=' + cast(@unique_companyId AS NVARCHAR(20)) + ' and CC.ModuleNamesUsing like ''%' + @module_name + '%'' and CC_New.CompanyId=' + cast(@new_companyId AS NVARCHAR(20)) + ' and CC_New.Id not in (select ControlCategoryId from  Common.ControlCode where ControlCategoryId in (select Id from Common.ControlCodeCategory where CompanyId= ' + cast(@new_companyId AS NVARCHAR(20)) + ' and ModuleNamesUsing like ''%' + @module_name + 
	'%'')) and cc_New.ModuleNamesUsing like ''%' + @module_name + '%'''

PRINT @dynamicControlCodeData

INSERT INTO Common.ControlCode
EXEC (@dynamicControlCodeData)

------>>>> Removed IfElse and removed multiple delete statements and replaced with single Delete Statement
DELETE FROM Common.ControlCode
WHERE Id IN (SELECT ControlCodeId FROM #DeleteId) 

--============================================== ControlCodeCategoryModule ===============================
PRINT 'FW_CONTROL_CODE_INSERTION---->>>INSERT INTO  Common.ControlCodeCategoryModule --start'

INSERT INTO Common.ControlCodeCategoryModule
SELECT *
FROM (
		SELECT (ROW_NUMBER() OVER (ORDER BY CCCM.Id) + (SELECT Max(CM.Id)FROM Common.ControlCodeCategoryModule CM)) AS Id,
			@NEW_COMPANYID AS companyId,
			(SELECT TOP 1 Id FROM Common.ControlCodeCategory WHERE ControlCodeCategoryCode = 
			(SELECT ControlCodeCategoryCode FROM Common.ControlCodeCategory WHERE Id = CCCM.ControlCategoryId) AND CompanyId = @NEW_COMPANYID) AS ControlCategoryId,
			CCCM.ModuleMasterId
		FROM Common.ControlCodeCategoryModule CCCM
		JOIN Common.ControlCodeCategory CCC ON CCC.Id = CCCM.ControlCategoryId
		WHERE CCCM.CompanyId = @UNIQUE_COMPANYID
			AND CCC.ModuleNamesUsing LIKE '%' + @module_name + '%' AND CCCM.ModuleMasterId = (SELECT Id FROM Common.ModuleMaster WHERE Name = @module_name)
	) AS A
WHERE ControlCategoryId NOT IN (
		SELECT ControlCategoryId FROM Common.ControlCodeCategoryModule
		WHERE CompanyId = @NEW_COMPANYID AND ModuleMasterId = (SELECT Id FROM Common.ModuleMaster WHERE Name = @module_name))

PRINT 'FW_CONTROL_CODE_INSERTION---->>>INSERT INTO  Common.ControlCodeCategoryModule --End'

---- COMMIT TRANSACTION
END TRY
BEGIN CATCH
    PRINT 'FAILED..!'
    DECLARE      
     @ErrorMessage NVARCHAR(4000),      
     @ErrorSeverity INT,      
     @ErrorState INT;      
SELECT      
     @ErrorMessage = ERROR_MESSAGE(),      
     @ErrorSeverity = ERROR_SEVERITY(),      
     @ErrorState = ERROR_STATE();      
   RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
    --ROLLBACK TRANSACTION;
END CATCH
END
GO
