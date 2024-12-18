USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[DeleteTableExcel]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[DeleteTableExcel]
@Path Nvarchar(1024)
As
Begin
	Declare @FileName Nvarchar(254)
	Declare @Location Nvarchar(1024)
	Declare @DynSql Nvarchar(Max)
	Declare @Format Varchar(24)
	Declare @DataSource Varchar(54)
	Declare @TempTbl Varchar(54)

	Set @FileName=SUBSTRING(REVERSE(@Path),1,CHARINDEX('/',REVERSE(@Path))-1)
	Set @FileName=Reverse(@FileName)
	Set @Location=SUBSTRING(REVERSE(@Path),CHARINDEX('/',REVERSE(@Path))+1,LEN(@Path))
	Set @Location=REVERSE(@Location)
	Set @Format='CSV'
	Set @DataSource='bulktest'
	Set @TempTbl='Common.DeleteTableList'
	If Exists (Select * From INFORMATION_SCHEMA.TABLES Where TABLE_SCHEMA='Common' And TABLE_NAME='DeleteTableList')
	Begin
		Truncate Table Common.DeleteTableList
	End
	Else
	Begin
		Create Table Common.DeleteTableList
		(
		SchemaName	Nvarchar(525),
		TableName Nvarchar(525),
		RecCount Nvarchar(525),
		Relation Nvarchar(525),
		LastCreatedDate Nvarchar(525),
		LastModifiedDate Nvarchar(525),
		[Status] Nvarchar(525),
		Remarks Nvarchar(525),
		[Team Remarks] Nvarchar(525),
		[Used Relation] Nvarchar(525),
		[Verified By]	Nvarchar(525)
		)
	End
	IF Not Exists(SELECT name FROM sys.symmetric_keys WHERE name LIKE '%DatabaseMasterKey%')
	Begin
		CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Welcome@123';
	End
	IF Not Exists(Select name From sys.database_scoped_credentials Where name='bulktest')
	Begin
		create DATABASE SCOPED CREDENTIAL bulktest  
		WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
		SECRET = 'sv=2019-12-12&ss=bfqt&srt=sco&sp=rwdlacupx&se=2020-09-29T21:47:15Z&st=2020-08-28T13:47:15Z&spr=https&sig=%2BzTHPSm4lGFcFPVjmWIFVTHJ8l3xx6mNRAHISylyZxY%3D';
	End
	IF Not Exists (Select name From Sys.external_data_sources Where name='bulktest')
	Begin
		Set @DynSql=
		'CREATE EXTERNAL DATA SOURCE bulktest
		WITH  (

			TYPE = BLOB_STORAGE,

			LOCATION = '''+ @Location +''',    -- Example: https://phdr.blob.core.windows.net/phdr

			CREDENTIAL = bulktest  

			);'
			Exec (@DynSql)
	End
	Else
	Begin
		Set @DynSql=
		'Alter EXTERNAL DATA SOURCE bulktest
		Set
			LOCATION = '''+ @Location +''',   -- Example: https://phdr.blob.core.windows.net/phdr

			CREDENTIAL = bulktest'
			Exec (@DynSql)
	End
		Set @DynSql=
		'BULK INSERT '+@TempTbl+'
		FROM '''+@FileName+'''
		WITH (DATA_SOURCE = '''+@DataSource+''',
		FORMAT = '''+@Format+''',
		FIRSTROW = 2);'
		Exec (@DynSql)
End

Exec DeleteTableExcel 'https://stagingsmartcursors.blob.core.windows.net/assets/DbTableDetailsCSVFile.csv'
GO
