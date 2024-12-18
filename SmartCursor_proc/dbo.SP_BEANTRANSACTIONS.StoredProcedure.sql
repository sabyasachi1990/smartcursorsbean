USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_BEANTRANSACTIONS]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[SP_BEANTRANSACTIONS](@COMPANYID BIGINT, @FILEPATH NVARCHAR(MAX),@TYPE NVARCHAR(100),@TRANSACTIONID NVARCHAR(100))
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

	  IF(@TYPE='Bean Cursor-Entities')
	  
	     BEGIN
	             DECLARE  @ENTITIES TABLE (EntityName Nvarchar(100),EntityType Nvarchar(100),EntityIdentificationType nvarchar(100),EntityIdentificationNumber nvarchar(100),
			     GSTRegistrationNumber nvarchar(100),Customer bit,CreditTerms nvarchar(100),CreditLimit nvarchar(100),Nature nvarchar(100),Currency nvarchar(100),
			     Vendor nvarchar(100),PaymentTerms nvarchar(100),VendorType nvarchar(100),DefaultCOA nvarchar(100),DefaultTaxCode nvarchar(100),
	             Email NVARCHAR(100) ,Phone NVARCHAR(100),LocalAddress nvarchar(max),ForeignAddress nvarchar(max))																											  											
	             																																														  
	             Declare @Ent nvarchar(max)
	             
	             Set @Ent=' SELECT * FROM OPENROWSET(
	             	            ''Microsoft.ACE.OLEDB.12.0'',
	             	            ''Excel 12.0 xml;HDR=YES;Database=' + @FILEPATH + ''',  
	             	            ''SELECT * FROM [Entities$]'')'  
	             
	             INSERT INTO @ENTITIES 
		         EXEC(@Ent)
			     --SELECT * FROM @ENTITIES
				 INSERT INTO DBO.ImportEntities (ID,TransactionId,EntityName,EntityType,EntityIdentificationNumber,EntityIdentificationType,GSTRegistrationNumber,Customer,CreditTerms,CreditLimit,Nature,Currency,Vendor,PaymentTerms,VendorType,DefaultCOA,DefaultTaxCode,Email,Phone,LocalAddress,ForeignAddress)
				 SELECT NEWID(),@TRANSACTIONID,EntityName,EntityType,EntityIdentificationNumber,EntityIdentificationType,GSTRegistrationNumber,Customer,CreditTerms,CreditLimit,Nature,Currency,Vendor,PaymentTerms,VendorType,DefaultCOA,DefaultTaxCode,Email,Phone,LocalAddress,ForeignAddress  FROM @ENTITIES WHERE EntityName IS NOT NULL
     ----    --  END




	--	 ELSE IF(@TYPE='Contacts')
	  
	-- BEGIN
	         DECLARE  @BEANCONTACT TABLE (EntityName Nvarchar(100),Saluatuion Nvarchar(100),Name nvarchar(100),DateofBirth NVARCHAR(100),IdentificationType nvarchar(50),IdentificationNumber Nvarchar(100),
			 CountryofResidence Nvarchar(50),PersonalEmail Nvarchar(100),PersonalPhone nvarchar(100),PersonalLocalAddress nvarchar(max),PersonalForeignAddress nvarchar(max),
	         EntityDesignation Nvarchar(100),PrimaryContacts bit,EntityEmail NVARCHAR(100) ,EntityPhone NVARCHAR(100),EntityLocalAddress nvarchar(max),EntityForeignAddress nvarchar(max),Remarks nvarchar(max),Inactive BIT,CopyCommunicationandAddres BIT)																											  											
	         																																														  
	         Declare @con nvarchar(max)
	         
	         Set @con=' SELECT * FROM OPENROWSET(
	         	            ''Microsoft.ACE.OLEDB.12.0'',
	         	            ''Excel 12.0 xml;HDR=YES;Database=' + @FILEPATH + ''',  
	         	            ''SELECT * FROM [Contacts$]'')'  
	         
	         INSERT INTO @BEANCONTACT 
		     EXEC(@con)
			 --SELECT * FROM @BEANCONTACT

			 INSERT INTO DBO.ImportBeanContacts (ID,TransactionId,Salutation,Name,DateofBirth,IdentificationType,IdentificationNumber,CountryOfResidence,PersonalEmail,PersonalPhone,PersonalLocalAddress,PersonalForeignAddress,Designation,PrimaryContacts,EntityEmail,EntityPhone,EntityLocalAddress,EntityForeignAddress,Remarks,Inactive,CopycommunicationandAddress,EntityName)
			 SELECT NEWID(),@TRANSACTIONID,Saluatuion,NAME,DateofBirth,IdentificationType,IdentificationNumber,CountryofResidence,PersonalEmail,PersonalPhone,PersonalLocalAddress,PersonalForeignAddress,EntityDesignation,PrimaryContacts,EntityEmail,EntityPhone,EntityLocalAddress,EntityForeignAddress,Remarks,Inactive,CopyCommunicationandAddres,EntityName FROM @BEANCONTACT WHERE NAME IS NOT NULL
           END
END
GO
