USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PROC_EmpClaimVerifeirMigrationScript]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[PROC_EmpClaimVerifeirMigrationScript]
@CompanyId BIGINT
AS 
BEGIN

	CREATE TABLE #EmployeRecandApprovers (SourceEmployeeId UNIQUEIDENTIFIER , Type NVARCHAR(50) , EmployeeId UNIQUEIDENTIFIER)

	SELECT ROW_NUMBER() OVER(ORDER BY EmployeeId) AS RowNum, * INTO #EmpTemp
	FROM 
	(
		SELECT  DISTINCT LE.ClaimsVerifiers,LE.EmployeeId,E.Username,LE.CompanyId 
		 FROM 
		HR.EmployeeClaimsEntitlement LE INNER JOIN  
		--HR.LeaveType LT ON LE.LeaveTypeId = LT.Id INNER JOIN 
		Common.Employee E ON E.Id = LE.EmployeeId --INNER JOIN 
		--Common.CompanyUser CU ON LOWER(E.Username) = LOWER(CU.Username)
		WHERE LE.CompanyId = @CompanyId  And E.CompanyId=@CompanyId AND /*CU.CompanyId = @CompanyId  AND*/ (ClaimsVerifiers <> '[]')  
	)p

	DECLARE @Count INT,@RowCount INT 
	SET @RowCount = @@ROWCOUNT
	SET @Count = 1
	WHILE @RowCount > @Count
	BEGIN
		DECLARE 
		@ClaimVerifiers NVARCHAR(MAX)
		,@EmployeeId UNIQUEIDENTIFIER


			SELECT @ClaimVerifiers = REPLACE(REPLACE(REPLACE(ClaimsVerifiers,'"',''),'[',''),']','') ,@EmployeeId = EmployeeId 
			FROM #EmpTemp 
			WHERE RowNum = @Count


			INSERT INTO #EmployeRecandApprovers 
			SELECT CAST(value AS uniqueidentifier) SourceEmployeeId, 'Verfier' AS Type, @EmployeeId AS EmployeeId 
			FROM string_split(@ClaimVerifiers , ',') WHERE value <> ''

			SET @Count = @Count + 1;
	END

 BEGIN TRANSACTION
 BEGIN TRY
	INSERT INTO  HR.EmployeRecandApprovers
	SELECT NEWID() AS Id,P.EmployeeId,P.Type,CU.Id AS TypeId ,P.ScreenName   FROM 
	(
		SELECT SourceEmployeeId , EmployeeId , Type  , 'Claims' ScreenName  FROM #EmployeRecandApprovers
		GROUP BY EmployeeId , Type  , SourceEmployeeId
	) P INNER JOIN	
	Common.companyUser E ON E.UserId = P.SourceEmployeeId INNER JOIN 
	Common.CompanyUser CU ON LOWER(E.Username) = LOWER(CU.Username) and E.CompanyId=@CompanyId and CU.CompanyId=@CompanyId
	order by P.EmployeeId

	COMMIT
 END TRY

 BEGIN CATCH

	ROLLBACK
	DROP TABLE #EmployeRecandApprovers
	DROP TABLE #EmpTemp
	PRINT 'In Catch Block';
	THROW;
 END CATCH

 	DROP TABLE #EmployeRecandApprovers
	DROP TABLE #EmpTemp

END

GO
