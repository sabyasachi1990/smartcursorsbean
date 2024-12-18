USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_WFTRANSACTIONS]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec [dbo].[SP_WFTRANSACTIONS] 10,'Client Template - Copy.xls','WorkflowCursor-Clients','2B3A1145-780B-4285-93CC-C6CFB7808BC7'

CREATE PROCEDURE [dbo].[SP_WFTRANSACTIONS](@COMPANYID BIGINT, @FILEPATH NVARCHAR(MAX),@TYPE NVARCHAR(100),@TRANSACTIONID NVARCHAR(100))
AS 
 BEGIN 

  	EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
	EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
	--CONFIGURING SQL INSTANCE TO ACCEPT ADVANCED OPTIONS
	EXEC sp_configure 'show advanced options', 1
	RECONFIGURE
	--ENABLING USE OF DISTRIBUTED QUERIES
	EXEC sp_configure 'Ad Hoc Distributed Queries', 1
	RECONFIGURE


	IF(@TYPE='Workflow Cursor-Clients')
	     BEGIN
	           Declare  @CLIENT table  (Clientreferencenumber Nvarchar(100),Name NVARCHAR(100),ClientType NVARCHAR(100),Identificationtype Nvarchar(100),IdentificationNumber Nvarchar(100),
               CreditTerms  NVARCHAR(100),IncorporationDate Nvarchar(100),IncorporationCountry nvarchar(100),Financialyearend Nvarchar(100),Industry nvarchar(100),
               PrinicipalActivities Nvarchar(100),Mobile nvarchar(100),Email nvarchar(100),LocalAddress nvarchar(max),ForignAddress nvarchar(max))  																																														  
	           Declare @sql nvarchar(max)
	         
	         Set @sql=' SELECT * FROM OPENROWSET(
	         	            ''Microsoft.ACE.OLEDB.12.0'',
	         	            ''Excel 12.0 xml;HDR=YES;Database=' + @FILEPATH + ''',  
	         	            ''SELECT * FROM [Client$]'')'   
	         
	         INSERT INTO @CLIENT 
		     EXEC(@sql)
			 --SELECT * FROM @CLIENT

			 Insert Into DBO.ImportWFClient(Id,TransactionId,ClientRefNumber,ClientType,[Name],IdentificationType,IdentificationNumber,CreditTerms,IncorporationDate,IncorporationCountry,FinancialYearEnd,Industry,PrinicipalActivities,Mobile,Email,LocalAddress,ForeignAddress)
			 select NEWID(),@TRANSACTIONID,Clientreferencenumber,ClientType,Name,IdentificationType,IdentificationNumber,CreditTerms,Incorporationdate,IncorporationCountry,FinancialyearEnd,Industry,PrinicipalActivities,Mobile,Email,LocalAddress,ForignAddress FROM @CLIENT where Clientreferencenumber is not null
      --   END

   -- ELSE IF(@TYPE='Contacts')
	  
	-- BEGIN
	         DECLARE  @WFCONTACT TABLE (Clientreferencenumber Nvarchar(100),Salutation Nvarchar(100),Name nvarchar(100),DateofBirth NVARCHAR(100),IdentificationType nvarchar(50),IdentificationNumber Nvarchar(100),
			 CountryofResidence Nvarchar(50),PersonalEmail Nvarchar(100),PersonalPhone nvarchar(100),PersonalLocalAddress nvarchar(max),PersonalForeignAddress nvarchar(max),
	         EntityDesignation Nvarchar(100),PrimaryContacts bit,EntityEmail NVARCHAR(100) ,EntityPhone NVARCHAR(100),EntityLocalAddress nvarchar(max),EntityForeignAddress nvarchar(max),Remarks nvarchar(max),Inactive BIT,CopyCommunicationandAddres BIT)																											  											
	         																																														  
	         Declare @con nvarchar(max)
	         
	         Set @con=' SELECT * FROM OPENROWSET(
	         	            ''Microsoft.ACE.OLEDB.12.0'',
	         	            ''Excel 12.0 xml;HDR=YES;Database=' + @FILEPATH + ''',  
	         	            ''SELECT * FROM [Contact$]'')'  
	         
	         INSERT INTO @WFCONTACT 
		     EXEC(@con)
			 --SELECT * FROM @WFCONTACT

			 INSERT INTO DBO.ImportWFContacts (ID,TransactionId,Salutation,Name,DateofBirth,IdentificationType,IdentificationNumber,CountryOfResidence,PersonalEmail,PersonalPhone,PersonalLocalAddress,PersonalForeignAddress,Designation,PrimaryContacts,EntityEmail,EntityPhone,EntityLocalAddress,EntityForeignAddress,Remarks,Inactive,CopycommunicationandAddress,ClientRefNumber)
			 SELECT NEWID(),@TRANSACTIONID,Salutation,NAME,DateofBirth,IdentificationType,IdentificationNumber,CountryofResidence,PersonalEmail,PersonalPhone,PersonalLocalAddress,PersonalForeignAddress,EntityDesignation,PrimaryContacts,EntityEmail,EntityPhone,EntityLocalAddress,EntityForeignAddress,Remarks,Inactive,CopyCommunicationandAddres,Clientreferencenumber  FROM @WFCONTACT WHERE NAME IS NOT NULL
        END

End				

GO
