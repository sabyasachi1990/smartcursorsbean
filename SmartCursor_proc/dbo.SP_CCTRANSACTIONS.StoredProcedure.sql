USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_CCTRANSACTIONS]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[SP_CCTRANSACTIONS](@COMPANYID BIGINT, @FILEPATH NVARCHAR(MAX),@TYPE NVARCHAR(100),@TRANSACTIONID NVARCHAR(100))
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


	IF(@TYPE='Client Cursor-Accounts')
	     BEGIN
	         DECLARE  @LEAD TABLE (Id Nvarchar(100),Type Nvarchar(100),Name nvarchar(100),SourceType nvarchar(100),SourceRemarks nvarchar(50),AccountType nvarchar(50),
	         IdentificationType nvarchar(50),IdentificationNumber Nvarchar(100),CreditTerms Nvarchar(50),Industry Nvarchar(50),Incorporationdate nvarchar(100),
	         IncorporationCountry nvarchar(100),FinancialyearEnd nvarchar(100),CompanySecretary nvarchar(100),InchargesinClientCursor  NVARCHAR(100),PrincipalActivities NVARCHAR(Max),
	         RemindersAGM BIT ,RemindersECI BIT ,RemindersAudit BIT,RemindersFinalTax BIT,Email NVARCHAR(100) ,Phone NVARCHAR(100),
	         LocalAddress nvarchar(max),ForeignAddress nvarchar(max))																											  											
	         																																														  
	         Declare @sql nvarchar(max)
	         
	         Set @sql=' SELECT * FROM OPENROWSET(
	         	            ''Microsoft.ACE.OLEDB.12.0'',
	         	            ''Excel 12.0 xml;HDR=YES;Database=' + @FILEPATH + ''',  
	         	            ''SELECT * FROM [Leads$A1:X]'')'   
	
         
	         INSERT INTO @LEAD 
		     EXEC(@sql)
			 --SELECT * FROM @LEAD

			 Insert Into dbo.ImportLeads(Id,TransactionId,AccountId,[Type],[Name],SourceType,[Source/Remarks],AccountType,IdentificationType,IdentificationNumber,CreditTerms,Industry,IncorporationDate,IncorporationCountry,FinancialYearEnd,CompanySecretary,InchargesinClientCursor,PrincipalActivities,RemindersAGM,RemindersECI,RemindersAudit,RemindersFinalTax,Email,Phone,LocalAddress,Foreignaddress)
			 select NEWID(),@TRANSACTIONID,Id,Type,Name,SourceType,SourceRemarks,AccountType,IdentificationType,IdentificationNumber,CreditTerms,Industry,Incorporationdate,IncorporationCountry,FinancialyearEnd,CompanySecretary,InchargesinClientCursor,PrincipalActivities,RemindersAGM,RemindersECI,RemindersAudit,RemindersFinalTax,Email,Phone,LocalAddress,ForeignAddress FROM @LEAD where Id is not null
    ----    END

   -- ELSE IF(@TYPE='Contacts')
	  
	-- BEGIN
	         DECLARE  @CONTACT TABLE (MASTERID NVARCHAR(100),Salutation Nvarchar(100),Name nvarchar(100),DateofBirth Nvarchar(100),IdentificationType nvarchar(50),IdentificationNumber Nvarchar(100),
			 CountryofResidence Nvarchar(50),PersonalEmail Nvarchar(100),PersonalPhone nvarchar(100),PersonalLocalAddress nvarchar(max),PersonalForeignAddress nvarchar(max),
	         EntityDesignation Nvarchar(100),PrimaryContacts bit,ReminderRecipient bit,Fee BIT ,Quotation BIT ,Admin BIT,AssignmentBilling BIT,Others BIT,EntityEmail NVARCHAR(100) ,EntityPhone NVARCHAR(100),
	         EntityLocalAddress nvarchar(max),EntityForeignAddress nvarchar(max),Remarks nvarchar(max),Inactive BIT,CopyCommunicationandAddress BIT)																											  											
	         																																														  
	         Declare @c nvarchar(max)
	         
	         Set @c=' SELECT * FROM OPENROWSET(
	         	            ''Microsoft.ACE.OLEDB.12.0'',
	         	            ''Excel 12.0 xml;HDR=YES;Database=' + @FILEPATH + ''',  
	         	            ''SELECT * FROM [Contacts$A1:Z]'')'  
	        
 
	         INSERT INTO @CONTACT 
		     EXEC(@c)
			 --SELECT * FROM @CONTACT

			 INSERT INTO Dbo.ImportContacts (ID,TransactionId,MasterId,Salutation,Name,DateofBirth,IdentificationType,IdentificationNumber,CountryOfResidence,PersonalEmail,PersonalPhone,PersonalLocalAddress,PersonalForeignAddress,EntityDesignation,PrimaryContacts,ReminderRecipient,Fee,Quotation,Admin,AssignmentBilling,Others,EntityEmail,EntityPhone,EntityLocalAddress,EntityForeignAddress,Remarks,Inactive,CopycommunicationandAddress)
			 Select NEWID(),@TRANSACTIONID,MASTERID,Salutation,Name,DateofBirth,IdentificationType,IdentificationNumber,CountryofResidence,PersonalEmail,PersonalPhone,PersonalLocalAddress,PersonalForeignAddress,EntityDesignation,PrimaryContacts,ReminderRecipient,Fee,Quotation,Admin,AssignmentBilling,Others,EntityEmail,EntityPhone,EntityLocalAddress,EntityForeignAddress,Remarks,Inactive,CopyCommunicationandAddress   FROM @CONTACT where MASTERID is not null
         END
		

		

	
END				


--exec [dbo].[SP_CCTRANSACTIONS] 395,'D:\CC_NEW Excel.xlsx','Client Cursor-Accounts','C7ACBA38-116C-4865-A948-6401A41C0DEE'
GO
