USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_HR_Payroll_Unpivot]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec Import_HR_Payroll_Unpivot 'SmartCursorPRD.Import.HRPayroll_a61ce415_24b6_4922_aa49_240f8c1b31d2'

Create   proc [dbo].[Import_HR_Payroll_Unpivot]
@tablename NVARCHAR(1000)
AS
BEGIN
--Local Variables
DECLARE @ErrorMessage NVARCHAR(4000)

	BEGIN TRY
	BEGIN TRANSACTION
		DECLARE @colsUnpivot AS NVARCHAR(MAX),
   @query  AS NVARCHAR(MAX)
select @colsUnpivot 
  = stuff((select ','+quotename(C.name)
           FROM sys.columns c
           WHERE c.object_id = OBJECT_ID(@tablename) 
           for xml path('')), 1, 67, '')

Set @colsUnpivot = (Select Replace(@colsUnpivot,'&amp;','&'))
set @query 
  = 'select CompanyName,ShortName,[Month],[Year],FirstName,EmployeeId,PayComponentName,Amount
     from '+@tablename+' 
     unpivot
     (
        Amount
        for PayComponentName in ('+ @colsunpivot +')
     ) u'
exec sp_executesql @query;
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
	ROLLBACK
		SELECT @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
	END CATCH
END
GO
