USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PROC_EmpRecAndAppMigrationScript]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[PROC_EmpRecAndAppMigrationScript]
@CompanyId BIGINT
AS 
BEGIN

	CREATE TABLE #EmployeRecandApprovers (SourceEmployeeId UNIQUEIDENTIFIER , Type NVARCHAR(50) , EmployeeId UNIQUEIDENTIFIER)

	SELECT ROW_NUMBER() OVER(ORDER BY EmployeeId) AS RowNum, * INTO #EmpTemp
	FROM 
	(
		SELECT  DISTINCT LE.LeaveApprovers,LE.LeaveRecommenders,LE.EmployeeId,E.Username,LT.CompanyId 
		 FROM 
		HR.LeaveEntitlement LE INNER JOIN  
		HR.LeaveType LT ON LE.LeaveTypeId = LT.Id INNER JOIN 
		Common.Employee E ON E.Id = LE.EmployeeId --INNER JOIN 
		--Common.CompanyUser CU ON LOWER(E.Username) = LOWER(CU.Username)
		WHERE LT.CompanyId = @CompanyId  And E.CompanyId=@CompanyId AND /*CU.CompanyId = @CompanyId  AND*/ (LeaveApprovers <> '[]' OR LeaveRecommenders <> '[]')  
	)p

	DECLARE @Count INT,@RowCount INT 
	SET @RowCount = @@ROWCOUNT
	SET @Count = 1
	WHILE @RowCount > @Count
	BEGIN
		DECLARE 
		@LeaveApprovers NVARCHAR(MAX)
		,@LeaveRcommenders NVARCHAR(MAX)
		,@EmployeeId UNIQUEIDENTIFIER


			SELECT @LeaveApprovers = REPLACE(REPLACE(REPLACE(LeaveApprovers,'"',''),'[',''),']','') , @LeaveRcommenders = REPLACE(REPLACE(REPLACE(LeaveRecommenders,'"',''),'[',''),']','') , @EmployeeId = EmployeeId 
			FROM #EmpTemp 
			WHERE RowNum = @Count


			INSERT INTO #EmployeRecandApprovers 
			SELECT CAST(value AS uniqueidentifier) SourceEmployeeId, 'Approver' AS Type, @EmployeeId AS EmployeeId 
			FROM string_split(@LeaveApprovers , ',') WHERE value <> ''
			UNION ALL
			SELECT CAST(value AS uniqueidentifier) SourceEmployeeId, 'Recommender' AS Type, @EmployeeId AS EmployeeId
			FROM string_split(@LeaveRcommenders , ',') WHERE value <> ''
	
			SET @Count = @Count + 1;
	END

 BEGIN TRANSACTION
 BEGIN TRY
	INSERT INTO  HR.EmployeRecandApprovers
	SELECT NEWID() AS Id,P.EmployeeId,P.Type,CU.Id AS TypeId ,P.ScreenName   FROM 
	(
		SELECT SourceEmployeeId , EmployeeId , Type  , 'Leaves' ScreenName  FROM #EmployeRecandApprovers
		GROUP BY EmployeeId , Type  , SourceEmployeeId
	) P INNER JOIN	
	Common.Employee E ON E.Id = P.SourceEmployeeId INNER JOIN 
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
