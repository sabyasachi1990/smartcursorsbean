USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Import].[HR_Payroll_Unpivot]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [Import].[HR_Payroll_Unpivot] 'SmartCursorTST.import.HRPayroll_ede926ef_81ac_4acc_bf25_7bf96e548ca6'
CREATE   proc [Import].[HR_Payroll_Unpivot]
@tablename Nvarchar(1000)
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
           for xml path('')), 1, 54, '')
Set @colsUnpivot = (Select Replace(@colsUnpivot,'&amp;','&'))
--Select @colsUnpivot 
set @query 
  = 'select CompanyName,Month,Year,FirstName,EmployeeId,PayComponentName,Amount
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
