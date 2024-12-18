USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[AuditGLImportAzureBlobCSVSP1]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--Exec AuditGLImportAzureBlobCSVSP '30381344-0795-4F17-9A74-DED76BE1808C','GL','https://stagingsmartcursors.blob.core.windows.net/assets/GL2019Test.csv',1
CREATE         Procedure [dbo].[AuditGLImportAzureBlobCSVSP1]
@EngagamentId Uniqueidentifier,
@Type Nvarchar(124),
@Path Nvarchar(4000),
@IsOverRide Bit,
@CompanyId Bigint
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
    Set @TempTbl='Import.GLImportFromCSV'

	Truncate table Import.ImportGl
	--delete from AUDIT.ENGAGEMENTHISTORY where engagementid=@EngagamentId and seeddatatype='GL' 

	INSERT INTO AUDIT.ENGAGEMENTHISTORY(Id, EngagementId, SeedDataType, SeedDataStatus,Recorder,CreatedTime)  Values(NewId(),@EngagamentId,'GL',@Path,'7',Getdate())

    If Exists (Select TABLE_SCHEMA,TABLE_NAME From INFORMATION_SCHEMA.TABLES Where TABLE_SCHEMA='Import' And TABLE_NAME='GLImportFromCSV')
    Begin
        Truncate Table Import.GLImportFromCSV
    End
    Else
    Begin
        Create Table Import.GLImportFromCSV
        (    
            Account Nvarchar(1024),
            [Date] Nvarchar(1024),
            [Type] Nvarchar(1024),
            [Sub Type] Nvarchar(1024),
            [Doc No] Nvarchar(1024),
            Entity Nvarchar(1024),
            Description Nvarchar(1024),
            Curr Nvarchar(1024),
            Debit Nvarchar(1024),
            Credit Nvarchar(1024),
            Balance Nvarchar(1024)
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
	  --SECRET = 'sv=2021-12-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2023-04-05T13:27:43Z&st=2023-04-05T05:27:43Z&spr=https&sig=L%2FLiK%2Bpig%2BN0olx%2FNl3x0fWpZ23OEIVUx4hWsVtLPiY%3D';
	  SECRET='?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2025-05-01T12:05:27Z&st=2023-08-30T04:05:27Z&spr=https&sig=EIlix2gJNpOau4S18bOgzxrNN%2B%2FVP2%2BCYv%2Br%2F5nxlvQ%3D';
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
    Begin Try
        Set @DynSql=
        'BULK INSERT '+@TempTbl+'
        FROM '''+@FileName+'''
        WITH 
		(
		DATA_SOURCE = '''+@DataSource+''',
        FORMAT = '''+@Format+''',
        FIRSTROW = 2
		);'
		print @DynSql
        --Exec (@DynSql)

		--select * from Import.GLImportFromCSV
  --      Insert Into Import.ImportGl
  --      Select Account,CASE WHEN TRY_CONVERT(date,Date,103) IS NULL THEN null Else date END as Date,Type,[Sub Type],Entity,[Description],Null As Source,[Doc No],Curr,Null As Amount,
		


		--dbo.GetOnlyNumbers(Debit),
		--dbo.GetOnlyNumbers(Credit),
		--dbo.GetOnlyNumbers(Balance),
		
		
		--@EngagamentId,@Type,ROW_NUMBER() Over(Order By @EngagamentId) 
  --      From Import.GLImportFromCSV
		--exec  [dbo].[Audit_GL_InsertingNew]  @EngagamentId,@CompanyId,@IsOverRide,@Type

    End Try
    Begin Catch
        Select ERROR_MESSAGE()
			INSERT INTO AUDIT.ENGAGEMENTHISTORY(Id, EngagementId, SeedDataType, SeedDataStatus,Recorder,CreatedTime)  Values(NewId(),@EngagamentId,'GL',ERROR_MESSAGE(),'9',Getdate())
    End Catch
End

 

 --Alter DATABASE SCOPED CREDENTIAL bulktest  
 --       WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
 --       SECRET = '?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2025-05-01T12:05:27Z&st=2023-08-30T04:05:27Z&spr=https&sig=EIlix2gJNpOau4S18bOgzxrNN%2B%2FVP2%2BCYv%2Br%2F5nxlvQ%3D';

		









GO
