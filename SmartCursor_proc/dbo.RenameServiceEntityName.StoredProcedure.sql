USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RenameServiceEntityName]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC dbo.RenameServiceEntityName '','','PTS','YB',1,8

CREATE   PROCEDURE [dbo].[RenameServiceEntityName]
(@OldName NVARCHAR(200) ,@NewName NVARCHAR(200) ,@OldCode NVARCHAR(50) ,@NewCode NVARCHAR(50) ,@CompanyId NVARCHAR(20),@ServiceCompanyId BigInt)
AS
BEGIN

--DECLARE @OldName NVARCHAR(50) = 'SCS GLOBAL PAC',
--        @OldCode NVARCHAR(50) = 'SCS',
--		@NewName NVARCHAR(50) = 'SCS GLOBAL PAC2',
--		@NewCode NVARCHAR(50) = 'SCS2',
--		@CompanyId BigInt = 1517,
--		@ServiceCompanyId BigInt = 1518

BEGIN TRANSACTION
BEGIN TRY
IF ((@OldCode != '' AND @OldCode IS NOT NULL) AND (@NewCode != '' AND @NewCode IS NOT NULL) AND (@OldCode != @NewCode))
BEGIN

----->>> Table name : Common.CompanyUser , column name : ServiceEntities
--SELECT Id,ServiceEntities, STRING_AGG(New,',') AS UpdateServiceEntity
--FROM (
--	SELECT Id, ServiceEntities,CASE WHEN value= @OldCode THEN REPLACE(value, @OldCode,@NewCode) ELSE value END AS NEW
--	FROM 
--		(
--			SELECT  Id,value,ServiceEntities
--			FROM  Common.CompanyUser 
--			CROSS APPLY STRING_SPLIT(ServiceEntities, ',')
--			WHERE CompanyId = @CompanyId AND ServiceEntities LIKE '%' + @OldCode + '%' 
--		) AS A
--	) AS A
--GROUP BY Id,ServiceEntities
UPDATE A SET ServiceEntities = UpdateServiceEntity
FROM Common.CompanyUser AS A
INNER JOIN 
	(
		SELECT Id,ServiceEntities, STRING_AGG(New,',') AS UpdateServiceEntity
		FROM (
			SELECT Id, ServiceEntities,CASE WHEN value= @OldCode THEN REPLACE(value, @OldCode,@NewCode) ELSE value END AS NEW
			FROM 
				(
					SELECT  Id,value,ServiceEntities
					FROM  Common.CompanyUser 
					CROSS APPLY STRING_SPLIT(ServiceEntities, ',')
					WHERE CompanyId = @CompanyId AND ServiceEntities LIKE '%' + @OldCode + '%' 
				) AS A
			) AS A
		GROUP BY Id,ServiceEntities
	) AS B ON B.Id = A.Id

----->>> Table name : Bean.ChartOfAccount , column name : Name
--SELECT Id,Name, STRING_AGG(New,' - ') AS UpdateName
--FROM (
--	SELECT Id, Name,CASE WHEN value = @OldCode THEN REPLACE(value, @OldCode,@NewCode) ELSE value END AS NEW
--	FROM 
--		(
--			SELECT Id,TRIM(VALUE) AS Value, Name
--			FROM Bean.ChartOfAccount
--			CROSS APPLY STRING_SPLIT(Name, '-')
--			WHERE CompanyId = @CompanyId AND Name LIKE '%' + @OldCode + '%'
--		) AS A
--	) AS A
--GROUP BY Id,Name

UPDATE A SET A.Name = B.UpdateName
FROM Bean.ChartOfAccount AS A
INNER JOIN 
	(
		SELECT Id,Name, STRING_AGG(New,' - ') AS UpdateName
		FROM (
			SELECT Id, Name,CASE WHEN value = @OldCode THEN REPLACE(value, @OldCode,@NewCode) ELSE value END AS NEW
			FROM 
				(
					SELECT Id,TRIM(VALUE) AS Value, Name
					FROM Bean.ChartOfAccount
					CROSS APPLY STRING_SPLIT(Name, '-')
					WHERE CompanyId = @CompanyId AND Name LIKE '%' + @OldCode + '%'
				) AS A
			) AS A
		GROUP BY Id,Name
	) AS B ON B.Id = A.Id

----->>> Table name : Common.GenericTemplate  column name : ServiceCompanyNames 
--SELECT Id,ServiceCompanyNames, STRING_AGG(New,',') AS UpdateServiceCompanyNames
--FROM (
--		SELECT Id, ServiceCompanyNames,CASE WHEN value= @OldCode THEN REPLACE(value, @OldCode,@NewCode) ELSE value END AS NEW
--		FROM 
--			(
--				SELECT  Id,value,ServiceCompanyNames
--				FROM  Common.GenericTemplate
--				CROSS APPLY STRING_SPLIT(ServiceCompanyNames, ',')
--				WHERE CompanyId = @CompanyId AND ServiceCompanyNames LIKE '%' + @OldCode + '%' 
--			) AS A
--		) AS A
--GROUP BY Id,ServiceCompanyNames	

UPDATE A SET ServiceCompanyNames = UpdateServiceCompanyNames
FROM Common.GenericTemplate AS A
INNER JOIN 
	(
	SELECT Id,ServiceCompanyNames, STRING_AGG(New,',') AS UpdateServiceCompanyNames
	FROM (
			SELECT Id, ServiceCompanyNames,CASE WHEN value= @OldCode THEN REPLACE(value, @OldCode,@NewCode) ELSE value END AS NEW
			FROM 
				(
					SELECT  Id,value,ServiceCompanyNames
					FROM  Common.GenericTemplate
					CROSS APPLY STRING_SPLIT(ServiceCompanyNames, ',')
					WHERE CompanyId = @CompanyId AND ServiceCompanyNames LIKE '%' + @OldCode + '%' 
				) AS A
			) AS A
	GROUP BY Id,ServiceCompanyNames	
	) AS B ON B.Id = A.Id


----->>> Table name : audit.AuditCompanyEngagement       column name : ProjectName
--SELECT a.Id, CompanyId, ProjectName,REPLACE(ProjectName, @OldCode, @NewCode) AS UpdatedProjectName
--FROM  audit.AuditCompanyEngagement as a
--INNER JOIN Audit.AuditCompany as b on b.Id = a.AuditCompanyId
--WHERE b.CompanyId = @CompanyId AND ProjectName LIKE '%' + @OldCode + '%'

UPDATE A SET ProjectName =  B.UpdatedProjectName 
FROM audit.AuditCompanyEngagement AS A
INNER JOIN (
			SELECT a.Id, CompanyId, ProjectName,REPLACE(ProjectName, @OldCode, @NewCode) AS UpdatedProjectName
			FROM  audit.AuditCompanyEngagement as a
			INNER JOIN Audit.AuditCompany as b on b.Id = a.AuditCompanyId
			WHERE b.ServiceCompanyId = @ServiceCompanyId AND ProjectName LIKE '%' + @OldCode + '%'
		) AS B ON B.Id = A.Id

END

IF ((@OldName != '' AND @OldName IS NOT NULL) AND (@NewName != '' AND @NewName IS NOT NULL) AND (@OldName != @NewName))
BEGIN
----->>> Table name : Common.Communication , column name : FilePath	
--SELECT Id,FilePath, STRING_AGG(New,'/') AS UpdateFilePath
--FROM (
--	SELECT Id, FilePath,CASE WHEN value = @OldName THEN REPLACE(value, @OldName,@NewName) ELSE value END AS NEW
--	FROM 
--		(
--			SELECT  value,Id, FilePath 
--			FROM  Common.Communication
--			CROSS APPLY STRING_SPLIT(FilePath, '/')
--			WHERE FilePath LIKE '%' + @OldName + '%'
--		) AS A
--	) AS A
--GROUP BY Id,FilePath

UPDATE A SET FilePath = UpdateFilePath
FROM Common.Communication AS A
INNER JOIN 
	(
		SELECT Id,FilePath, STRING_AGG(New,'/') AS UpdateFilePath
		FROM (
			SELECT Id, FilePath,CASE WHEN value = @OldName THEN REPLACE(value, @OldName,@NewName) ELSE value END AS NEW
			FROM 
				(
					SELECT  value,Id, FilePath 
					FROM  Common.Communication
					CROSS APPLY STRING_SPLIT(FilePath, '/')
					WHERE FilePath LIKE '%' + @OldName + '%'
				) AS A
			) AS A
		GROUP BY Id,FilePath
	) AS B ON B.Id = A.Id


----->>> Table name : Common.Communication , column name : AzurePath	
--SELECT Id,AzurePath, STRING_AGG(New,'/') AS UpdateAzurePath
--FROM (
--	SELECT Id, AzurePath,CASE WHEN value = @OldName THEN REPLACE(value, @OldName,@NewName) ELSE value END AS NEW
--	FROM 
--		(
--			SELECT  value,Id, AzurePath 
--			FROM  Common.Communication
--			CROSS APPLY STRING_SPLIT(AzurePath, '/')
--			WHERE AzurePath LIKE '%' + @OldName + '%'
--		) AS A
--	) AS A
--GROUP BY Id,AzurePath

UPDATE A SET FilePath = UpdateAzurePath
FROM Common.Communication AS A
INNER JOIN 
	(
		SELECT Id,AzurePath, STRING_AGG(New,'/') AS UpdateAzurePath
		FROM (
			SELECT Id, AzurePath,CASE WHEN value = @OldName THEN REPLACE(value, @OldName,@NewName) ELSE value END AS NEW
			FROM 
				(
					SELECT  value,Id, AzurePath 
					FROM  Common.Communication
					CROSS APPLY STRING_SPLIT(AzurePath, '/')
					WHERE AzurePath LIKE '%' + @OldName + '%'
				) AS A
			) AS A
		GROUP BY Id,AzurePath
	) AS B ON B.Id = A.Id


----->>> Table name : Common.DocRepository , column name : AzurePath	
--SELECT Id,AzurePath, STRING_AGG(New,'/') AS UpdateAzurePath
--FROM (
--	SELECT Id, AzurePath,CASE WHEN value = @OldName THEN REPLACE(value, @OldName,@NewName) ELSE value END AS NEW
--	FROM 
--		(
--			SELECT  value,Id, AzurePath 
--			FROM  Common.DocRepository
--			CROSS APPLY STRING_SPLIT(AzurePath, '/')
--			WHERE AzurePath LIKE '%' + @OldName + '%'
--		) AS A
--	) AS A
--GROUP BY Id,AzurePath

UPDATE A SET AzurePath = UpdateAzurePath
FROM Common.DocRepository AS A
INNER JOIN 
	(
		SELECT Id,AzurePath, STRING_AGG(New,'/') AS UpdateAzurePath
		FROM (
			SELECT Id, AzurePath,CASE WHEN value = @OldName THEN REPLACE(value, @OldName,@NewName) ELSE value END AS NEW
			FROM 
				(
					SELECT  value,Id, AzurePath 
					FROM  Common.DocRepository
					CROSS APPLY STRING_SPLIT(AzurePath, '/')
					WHERE AzurePath LIKE '%' + @OldName + '%'
				) AS A
			) AS A
		GROUP BY Id,AzurePath
	) AS B ON B.Id = A.Id

------>>> Table name : HR.IR8AHRSetUp , column name : DeductionsName
--SELECT Id, DeductionsName,REPLACE(DeductionsName, @OldName, @NewName) AS UpdatedDeductionsName
--FROM HR.IR8AHRSetUp
--WHERE  CompanyId = @ServiceCompanyId AND DeductionsName LIKE '%' + @OldName + '%'
 
UPDATE A SET DeductionsName = UpdatedDeductionsName
FROM HR.IR8AHRSetUp AS A
INNER JOIN 
	(
		SELECT Id, DeductionsName,REPLACE(DeductionsName, @OldName, @NewName) AS UpdatedDeductionsName
		FROM HR.IR8AHRSetUp
		WHERE  CompanyId = @ServiceCompanyId AND DeductionsName LIKE '%' + @OldName + '%'
	) AS B ON B.Id = A.Id
 
------>>> Table name : HR.IR8AHRSetUp , column name : NameOfTheEmployeer
--SELECT Id, NameOfTheEmployeer,REPLACE(NameOfTheEmployeer, @OldName, @NewName) AS UpdatedNameOfTheEmployeer
--FROM HR.IR8AHRSetUp
--WHERE  CompanyId = @ServiceCompanyId AND NameOfTheEmployeer LIKE '%' + @OldName + '%'
 
UPDATE A SET NameOfTheEmployeer = UpdatedNameOfTheEmployeer
FROM HR.IR8AHRSetUp AS A
INNER JOIN 
	(
		SELECT Id, NameOfTheEmployeer,REPLACE(NameOfTheEmployeer, @OldName, @NewName) AS UpdatedNameOfTheEmployeer
		FROM HR.IR8AHRSetUp
		WHERE  CompanyId = @ServiceCompanyId AND NameOfTheEmployeer LIKE '%' + @OldName + '%'
	) AS B ON B.Id = A.Id
 
----->>> Table name : HR.IR8ACompanySetUp , column name : NameOfTheEmployeer
--SELECT Id, NameOfTheEmployeer,REPLACE(NameOfTheEmployeer, @OldName, @NewName) AS UpdatedNameOfTheEmployeer
--FROM HR.IR8ACompanySetUp
--WHERE  CompanyId = @ServiceCompanyId AND NameOfTheEmployeer LIKE '%' + @OldName + '%'
 
UPDATE A SET NameOfTheEmployeer = UpdatedNameOfTheEmployeer
FROM HR.IR8ACompanySetUp AS A
INNER JOIN 
	(
		SELECT Id, NameOfTheEmployeer,REPLACE(NameOfTheEmployeer, @OldName, @NewName) AS UpdatedNameOfTheEmployeer
		FROM HR.IR8ACompanySetUp
		WHERE  CompanyId = @ServiceCompanyId AND NameOfTheEmployeer LIKE '%' + @OldName + '%'
	) AS B ON B.Id = A.Id
END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
 DECLARE @ErrorMessage NVARCHAR(500) ;
        SET @ErrorMessage = ERROR_MESSAGE();
		SELECT @ErrorMessage
		THROW;
END CATCH
END
GO
