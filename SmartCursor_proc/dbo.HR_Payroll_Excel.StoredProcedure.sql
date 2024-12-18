USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Payroll_Excel]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [HR_Payroll_Excel] 'fe92b9dd-4875-411d-b773-4861cf48dce9',1077
CREATE   PROC [dbo].[HR_Payroll_Excel] @PayrollId UNIQUEIDENTIFIER, @companyId BIGINT
AS
BEGIN
	--Local Variables
	DECLARE @ErrorMessage NVARCHAR(4000)

	--BEGIN TRY
		--BEGIN TRANSACTION

		SELECT *
		INTO #table2
		FROM (
			SELECT PayData.CompanyName, PayData.[ShortName],PayData.[Year], PayData.[Month], PayData.FirstName, PayData.EmployeeId, PayData.PayrollDetailId, PayData.ComponentId, ps.PayComponentId, PayData.Name, ps.Amount
			FROM (
				SELECT payroll.[CompanyName],payroll.[ShortName] ,payroll.[Year], payroll.[Month], payroll.FirstName, payroll.EmployeeId, payroll.PayrollDetailId, PC.Name, PC.Id AS ComponentId
				FROM HR.Paycomponent PC (NOLOCK)
				CROSS JOIN (
					SELECT c.[Name] AS CompanyName,c.Shortname, p.[Year], p.[Month], CE.FirstName, CE.EmployeeId, PD.Id AS PayrollDetailId
					FROM Common.Employee CE (NOLOCK)
					JOIN HR.PayrollDetails PD (NOLOCK) ON CE.Id = PD.EmployeeId
					JOIN HR.Payroll P (NOLOCK) ON Pd.MasterId = p.Id
					JOIN Common.Company c (NOLOCK) ON p.CompanyId = c.Id
					WHERE p.Id = @PayrollId
					) payroll
				WHERE PC.CompanyId = @companyId and (PC.IsStatutoryComponent =0 OR PC.IsStatutoryComponent is null) and PC.[Status] = 1
				) PayData
			LEFT JOIN HR.PayrollSplit PS (NOLOCK) ON PayData.PayrollDetailId = PS.PayrollDetailId AND PS.PayComponentId = PayData.ComponentId --order by PayData.FirstName
			) gg

		DECLARE @columns NVARCHAR(MAX), @sql NVARCHAR(MAX);

		SET @columns = N'';

		SELECT @columns += N', p.' + QUOTENAME([Name])
		FROM (
			SELECT name AS [Name]
			FROM #table2 AS p
			GROUP BY name
			) AS x;

		SET @sql = N'
SELECT CompanyName,ShortName,Year,Month,FirstName,EmployeeId,' + STUFF(@columns, 1, 2, '') + ' FROM
(
SELECT CompanyName,ShortName,Year,Month,FirstName,EmployeeId, [Amount] AS [Amount1], [Name] as [Name1]
FROM #table2) AS j PIVOT (SUM(Amount1) FOR [Name1] in
(' + STUFF(REPLACE(@columns, ', p.[', ',['), 1, 1, '') + ')) AS p;';

		EXEC sp_executesql @sql

		--select * from #table2
		--Insert into Import.HRPayrollCSV
		--Select @CSVNewId,FirstName,EmployeeId,Convert(varchar(100),companyid),Convert(varchar(100),[Month]),Convert(varchar(100),[Year]),PayrollDetailId,ComponentId,PayComponentId,Convert(varchar(100),[Name]),Convert(varchar(100),[Amount]) from #table2
		DROP TABLE #table2

		--COMMIT TRANSACTION
	--END TRY

	--BEGIN CATCH
	--	--ROLLBACK

	--	SELECT @ErrorMessage = ERROR_MESSAGE()

	--	RAISERROR (@ErrorMessage, 16, 1);
	--END CATCH
END
GO
