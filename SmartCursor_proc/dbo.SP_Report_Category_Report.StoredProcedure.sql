USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Report_Category_Report]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[SP_Report_Category_Report]  @UNIQUE_COMPANY_ID BIGINT, @CREATED_DATE DATETIME2(7), @NEW_COMPANY_ID BIGINT 
AS 
BEGIN

DROP TABLE IF EXISTS #Report
DROP TABLE IF EXISTS #ReportCategory

CREATE TABLE #Report 
(
Id	uniqueidentifier,CompanyId	bigint,[Name]	nvarchar(100),[Description]	nvarchar(1000),ThumbNail	nvarchar(254),ReportPath	nvarchar(1000),
RecOrder int,UserCreated	nvarchar(254),CreatedDate	datetime2,ModifiedBy	nvarchar(254),ModifiedDate datetime2,[Status]	int,
[Type] nvarchar(50),PathType nvarchar(500),PermissionKeys	nvarchar(254),TempReportId uniqueidentifier
)

INSERT #Report
(
	Id,CompanyId,Name,Description,ThumbNail,ReportPath,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,STATUS,Type,PathType,PermissionKeys,TempReportId
)
SELECT NEWID(),@NEW_COMPANY_ID,Name,Description,ThumbNail,ReportPath,RecOrder,UserCreated,@CREATED_DATE,NULL,NULL,STATUS,Type,PathType,PermissionKeys,Id
FROM [Report].[Report] WHERE CompanyId = @UNIQUE_COMPANY_ID

---------================================================================================================================---------
CREATE TABLE #ReportCategory 
(
Id	uniqueidentifier,CompanyId	bigint,[Name]	nvarchar(100),SpriteName	nvarchar(100),TabNames	nvarchar(1024),ModuleName	nvarchar(100),
RecOrder	int,UserCreated	nvarchar(254),CreatedDate	datetime2,ModifiedBy	nvarchar(254),ModifiedDate datetime2,[Status] int,
PermissionKeys	nvarchar(254),CockpitPermissionKeys	nvarchar(254),TempReportCategoryId UniqueIdentifier
)

INSERT #ReportCategory  (
	Id,CompanyId,Name,SpriteName,TabNames,ModuleName,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,STATUS,
	PermissionKeys,CockpitPermissionKeys,TempReportCategoryId
	)
SELECT NEWID(),@NEW_COMPANY_ID,Name,SpriteName,TabNames,ModuleName,RecOrder,UserCreated,@CREATED_DATE,NULL,
	NULL,STATUS,PermissionKeys,CockpitPermissionKeys,Id
FROM [Report].[ReportCategory]
WHERE CompanyId = @UNIQUE_COMPANY_ID

	BEGIN TRANSACTION
	BEGIN TRY
---------================================================================================================================---------
		PRINT 'Inserting into [Report].[Report] - Start...'

		INSERT [Report].[Report] 
		(
			Id,CompanyId,Name,Description,ThumbNail,ReportPath,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,STATUS,Type,PathType,PermissionKeys
		)
		SELECT Id,@NEW_COMPANY_ID,Name,Description,ThumbNail,ReportPath,RecOrder,UserCreated,@CREATED_DATE,NULL,NULL,STATUS,Type,PathType,PermissionKeys
		FROM #Report
		ORDER BY Name

		PRINT 'Inserting into [Report].[Report] - End'
		PRINT 'Inserting into [Report].[ReportCategory] - Start...'

		INSERT [Report].[ReportCategory] (
			Id,CompanyId,Name,SpriteName,TabNames,ModuleName,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,STATUS,
			PermissionKeys,CockpitPermissionKeys
			)
		SELECT Id,@NEW_COMPANY_ID,Name,SpriteName,TabNames,ModuleName,RecOrder,UserCreated,@CREATED_DATE,NULL,
			NULL,STATUS,PermissionKeys,CockpitPermissionKeys
		FROM #ReportCategory
		ORDER BY Name

		PRINT 'Inserting into [Report].[ReportCategory] - End'
		PRINT 'Inserting into [Report].[ReportCategoryReport] - Start...'

		INSERT [Report].[ReportCategoryReport] (Id,ReportCategoryId,ReportId,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,STATUS)
		SELECT NEWID(),RC.Id,R.Id,RCR.RecOrder,RCR.UserCreated,@CREATED_DATE,NULL,NULL,RCR.STATUS
		FROM [Report].[ReportCategoryReport] RCR
		INNER JOIN #ReportCategory RC ON RC.TempReportCategoryId = RCR.ReportCategoryId
		INNER JOIN #Report R ON R.TempReportId = RCR.ReportId
		WHERE R.CompanyId = @NEW_COMPANY_ID AND RC.CompanyId = @NEW_COMPANY_ID

		PRINT 'Inserting into [Report].[ReportCategoryReport] - End'		
---------================================================================================================================---------
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000),@ErrorSeverity INT,@ErrorState INT;
		SELECT @ErrorMessage = ERROR_MESSAGE(),@ErrorSeverity = ERROR_SEVERITY(),@ErrorState = ERROR_STATE();
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
		ROLLBACK TRANSACTION
	END CATCH

	BEGIN
		COMMIT TRANSACTION
	END

END
GO
