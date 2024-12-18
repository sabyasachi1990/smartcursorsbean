USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_TABLETOEXCELTRANSACTIONS_oldnew]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






create PROCEDURE [dbo].[SP_TABLETOEXCELTRANSACTIONS_oldnew] (@TRANSACTIONID UNIQUEIDENTIFIER,@SCREENNAME NVARCHAR(4000))

AS BEGIN

Declare @UploadDate date=( select UploadDate from [Common].[Transaction] where id=@TRANSACTIONID and ScreenName=@SCREENNAME)
Declare @Date date='2020-10-10'
--============================================================ OLD=============================================
IF(@Date>=@UploadDate)
BEGIN
 IF(@SCREENNAME='Client Cursor-Accounts')
       BEGIN

		     ---LEAD
             DECLARE  @LEAD TABLE (Id NVARCHAR(4000),Type NVARCHAR(4000),Name NVARCHAR(4000),SourceType NVARCHAR(4000),[Source/Remarks] NVARCHAR(4000),AccountType NVARCHAR(4000),
	         IdentificationType NVARCHAR(4000),IdentificationNumber NVARCHAR(4000),CreditTerms NVARCHAR(4000),Industry NVARCHAR(4000),Incorporationdate NVARCHAR(4000),
	         IncorporationCountry NVARCHAR(4000),FinancialyearEnd NVARCHAR(4000),CompanySecretary NVARCHAR(4000),InchargesinClientCursor  NVARCHAR(4000),PrincipalActivities NVARCHAR(MAX),
	         RemindersAGM Nvarchar(10) ,RemindersECI Nvarchar(10) ,RemindersAudit Nvarchar(10),RemindersFinalTax Nvarchar(10),Email NVARCHAR(4000) ,Phone NVARCHAR(4000),
	         LocalAddress NVARCHAR(MAX),ForeignAddress NVARCHAR(MAX),AccountErrorRemarks NVARCHAR(MAX))

             INSERT INTO @LEAD (Id,Type,Name,SourceType,[Source/Remarks],AccountType,IdentificationType,IdentificationNumber,CreditTerms,Industry,Incorporationdate
	         ,IncorporationCountry,FinancialyearEnd,CompanySecretary,InchargesinClientCursor,PrincipalActivities,RemindersAGM,RemindersECI,RemindersAudit,RemindersFinalTax,
	         Email,Phone,LocalAddress,ForeignAddress,AccountErrorRemarks)  SELECT AccountId,Type,Name,SourceType,[Source/Remarks],AccountType,IdentificationType,IdentificationNumber,CreditTerms,Industry,IncorporationDate,IncorporationCountry,FinancialYearEnd,CompanySecretary,InchargesinClientCursor,PrincipalActivities,
			 CASE WHEN RemindersAGM=1 THEN 'YES' ELSE 'NO' END AS RemindersAGM ,      --Bool
	         CASE WHEN RemindersECI=1 THEN 'YES' ELSE 'NO' END AS RemindersECI ,      --Bool
			 CASE WHEN RemindersAudit=1 THEN 'YES' ELSE 'NO' END AS RemindersAudit ,  --Bool
			 CASE WHEN RemindersFinalTax=1 THEN 'YES' ELSE 'NO' END AS RemindersFinalTax ,  --Bool
			 Email,Phone,LocalAddress,Foreignaddress,AccountErrorRemarks FROM ImportLeads WHERE TransactionId=@TRANSACTIONID  and  AccountImportStatus=0


			 ---CONTACT
	         DECLARE  @CONTACT TABLE (MASTERID NVARCHAR(4000),Salutation NVARCHAR(4000),Name NVARCHAR(4000),DateofBirth NVARCHAR(4000),IdentificationType NVARCHAR(4000),IdentificationNumber NVARCHAR(4000),
			 CountryofResidence NVARCHAR(4000),PersonalEmail NVARCHAR(4000),PersonalPhone NVARCHAR(4000),PersonalLocalAddress NVARCHAR(MAX),PersonalForeignAddress NVARCHAR(MAX),
	         EntityDesignation NVARCHAR(4000),PrimaryContacts Nvarchar(10),ReminderRecipient Nvarchar(10),EntityEmail NVARCHAR(4000) ,EntityPhone NVARCHAR(4000),
	         EntityLocalAddress NVARCHAR(MAX),EntityForeignAddress NVARCHAR(MAX),Remarks NVARCHAR(MAX),CopyCommunicationandAddress Nvarchar(10),ErrorRemarks NVARCHAR(MAX))																											  											
	        
             Insert Into @CONTACT(MASTERID,Salutation,Name,DateofBirth,IdentificationType,IdentificationNumber,CountryofResidence,PersonalEmail,PersonalPhone,PersonalLocalAddress,PersonalForeignAddress,
	         EntityDesignation,PrimaryContacts,ReminderRecipient,EntityEmail,EntityPhone,EntityLocalAddress,EntityForeignAddress,Remarks,CopyCommunicationandAddress,ErrorRemarks)
	         Select MasterId,Salutation,Name,DateofBirth,IdentificationType,IdentificationNumber,CountryOfResidence,PersonalEmail,PersonalPhone,PersonalLocalAddress,PersonalForeignAddress, EntityDesignation,
			 CASE WHEN PrimaryContacts=1 THEN 'YES' ELSE 'NO' END AS PrimaryContacts,  --Bool
			 CASE WHEN ReminderRecipient=1 THEN 'YES' ELSE 'NO' END AS ReminderRecipient,  --Bool
			 EntityEmail,EntityPhone,EntityLocalAddress,EntityForeignAddress,Remarks,
			 CASE WHEN CopycommunicationandAddress=1 THEN 'YES' ELSE 'NO' END AS CopycommunicationandAddress,  --Bool
			 ErrorRemarks  
	         from ImportContacts  where  TransactionId=@TRANSACTIONID and  importstatus=0


	         SELECT * FROM @LEAD
	         SELECT * FROM @CONTACT

      END

 ELSE IF(@SCREENNAME='Workflow Cursor-Clients')
       BEGIN
		    
			--CLIENT
	        DECLARE  @CLIENT TABLE  (ClientRefnumber NVARCHAR(4000),Name NVARCHAR(4000),ClientType NVARCHAR(4000),Identificationtype NVARCHAR(4000),IdentificationNumber NVARCHAR(4000),
            CreditTerms  NVARCHAR(4000),IncorporationDate NVARCHAR(4000),IncorporationCountry NVARCHAR(4000),Financialyearend NVARCHAR(4000),Industry NVARCHAR(4000),
            PrinicipalActivities NVARCHAR(4000),Mobile NVARCHAR(4000),Email NVARCHAR(4000),LocalAddress NVARCHAR(MAX),ForeignAddress NVARCHAR(MAX),ErrorRemarks NVARCHAR(MAX))  
			
			INSERT INTO @CLIENT (ClientRefnumber,Name,ClientType,Identificationtype,IdentificationNumber,CreditTerms,IncorporationDate,IncorporationCountry,Financialyearend,
			Industry,PrinicipalActivities,Mobile,Email,LocalAddress,ForeignAddress,ErrorRemarks) SELECT ClientRefNumber,Name,ClientType,Identificationtype,IdentificationNumber,CreditTerms,
			IncorporationDate,IncorporationCountry,FinancialYearEnd,Industry,PrinicipalActivities,Mobile,Email,LocalAddress,ForeignAddress,ErrorRemarks FROM ImportWFClient
			WHERE TransactionID=@TRANSACTIONID AND 	importstatus=0																																													  


			---WFCONTACT

			DECLARE  @WFCONTACT TABLE (ClientRefnumber NVARCHAR(4000),Salutation NVARCHAR(4000),Name NVARCHAR(4000),DateofBirth NVARCHAR(4000),IdentificationType NVARCHAR(4000),IdentificationNumber NVARCHAR(4000),
			CountryofResidence NVARCHAR(4000),PersonalEmail NVARCHAR(4000),PersonalMobile NVARCHAR(4000),PersonalLocalAddress NVARCHAR(MAX),PersonalForeignAddress NVARCHAR(MAX),
			EntityDesignation NVARCHAR(4000),PrimaryContact Nvarchar(10),EntityEmail NVARCHAR(4000) ,EntityMobile NVARCHAR(4000),EntityLocalAddress NVARCHAR(MAX),EntityForeignAddress NVARCHAR(MAX),
			Remarks NVARCHAR(MAX),CopyCommunicationandAddress Nvarchar(10),ErrorRemarks NVARCHAR(MAX))	
			
																													  											
			INSERT INTO @WFCONTACT (ClientRefnumber,Salutation,Name,DateofBirth,IdentificationType,IdentificationNumber,CountryofResidence,PersonalEmail,PersonalMobile,PersonalLocalAddress,PersonalForeignAddress,
			EntityDesignation,PrimaryContact,EntityEmail,EntityMobile,EntityLocalAddress,EntityForeignAddress,Remarks,CopyCommunicationandAddress,ErrorRemarks) SELECT ClientRefNumber,Salutation,Name,DateofBirth,
			IdentificationType,IdentificationNumber,CountryOfResidence,PersonalEmail,PersonalMobile,PersonalLocalAddress,PersonalForeignAddress,EntityDesignation,
			CASE WHEN PrimaryContact=1 THEN 'YES' ELSE 'NO' END AS PrimaryContact ,  --Bool
			EntityEmail,EntityMobile,
			EntityLocalAddress,EntityForeignAddress,Remarks,
			CASE WHEN CopycommunicationandAddress=1 THEN 'YES' ELSE 'NO' END AS CopycommunicationandAddress,  --Bool
			ErrorRemarks  FROM ImportWFContacts WHERE TransactionId=@TRANSACTIONID  AND importstatus=0

			SELECT * FROM @CLIENT
			SELECT * FROM @WFCONTACT


       END
  
 ELSE IF(@SCREENNAME='Bean Cursor-Entities')
       BEGIN

	        ---ENTITIES
			DECLARE  @ENTITIES TABLE (EntityName NVARCHAR(4000),EntityType NVARCHAR(4000),EntityIdentificationType NVARCHAR(4000),EntityIdentificationNumber NVARCHAR(4000),GSTRegistrationNumber NVARCHAR(4000),
			Customer NVARCHAR(10),CreditTerms NVARCHAR(4000),CreditLimit NVARCHAR(4000),CustNature NVARCHAR(4000),CustCurrency NVARCHAR(4000),Vendor NVARCHAR(4000),PaymentTerms NVARCHAR(4000),VendorType NVARCHAR(4000),
			VenNature NVARCHAR(4000),VenCurrency NVARCHAR(4000),DefaultCOA NVARCHAR(4000),
			DefaultTaxCode NVARCHAR(4000), Email NVARCHAR(4000) ,Phone NVARCHAR(4000),LocalAddress NVARCHAR(MAX),ForeignAddress NVARCHAR(MAX),ErrorRemarks NVARCHAR(MAX))


			INSERT INTO @ENTITIES (EntityName,EntityType,EntityIdentificationType,EntityIdentificationNumber,GSTRegistrationNumber,Customer,CreditTerms,CreditLimit,CustNature,CustCurrency,Vendor,PaymentTerms,
			VendorType,VenNature,VenCurrency,DefaultCOA,DefaultTaxCode,Email,Phone,LocalAddress,ForeignAddress,ErrorRemarks) 
			SELECT EntityName,EntityType,EntityIdentificationType,EntityIdentificationNumber,GSTRegistrationNumber,
			CASE WHEN Customer=1 THEN 'YES' ELSE 'NO' END AS Customer ,  --Bool
			CreditTerms,CreditLimit,CustNature,CustCurrency,
			CASE WHEN Vendor=1 THEN 'YES' ELSE 'NO' END AS Vendor ,  --Bool
			PaymentTerms,VendorType,VenNature,VenCurrency,DefaultCOA,DefaultTaxCode,Email,Phone,LocalAddress,ForeignAddress,ErrorRemarks FROM ImportEntities WHERE TransactionId=@TRANSACTIONID
			AND ImportStatus=0

		


			--BEANCONTACT
			DECLARE  @BEANCONTACT TABLE (EntityName NVARCHAR(4000),Salutation NVARCHAR(4000),Name NVARCHAR(4000),DateofBirth NVARCHAR(4000),IdentificationType NVARCHAR(4000),IdentificationNumber NVARCHAR(4000),
			CountryofResidence NVARCHAR(4000),PersonalEmail NVARCHAR(4000),PersonalPhone NVARCHAR(4000),PersonalLocalAddress NVARCHAR(MAX),PersonalForeignAddress NVARCHAR(MAX),
	        Designation NVARCHAR(4000),PrimaryContacts Nvarchar(10),EntityEmail NVARCHAR(4000) ,EntityPhone NVARCHAR(4000),EntityLocalAddress NVARCHAR(MAX),EntityForeignAddress NVARCHAR(MAX),Remarks NVARCHAR(MAX),CopyCommunicationandAddress Nvarchar(10),ErrorRemarks NVARCHAR(MAX))																											  											

			INSERT INTO @BEANCONTACT (EntityName,Salutation,Name,DateofBirth,IdentificationType,IdentificationNumber,CountryofResidence,PersonalEmail,PersonalPhone,PersonalLocalAddress,PersonalForeignAddress,
			Designation,PrimaryContacts,EntityEmail,EntityPhone,EntityLocalAddress,EntityForeignAddress,Remarks,CopyCommunicationandAddress,ErrorRemarks)  SELECT EntityName,Salutation,Name,DateofBirth,IdentificationType,
			IdentificationNumber,CountryOfResidence,PersonalEmail,PersonalPhone,PersonalLocalAddress,PersonalForeignAddress,Designation,
			CASE WHEN PrimaryContacts=1 THEN 'YES' ELSE 'NO' END AS PrimaryContacts,  --Bool
			EntityEmail,EntityPhone,EntityLocalAddress,EntityForeignAddress,
			Remarks,
			CASE WHEN CopycommunicationandAddress=1 THEN 'YES' ELSE 'NO' END AS CopycommunicationandAddress,  --Bool
			ErrorRemarks  FROM ImportBeanContacts WHERE TransactionId=@TRANSACTIONID AND importstatus =0


			SELECT * FROM @ENTITIES
			SELECT * FROM @BEANCONTACT
	     END

 ELSE IF(@SCREENNAME='HR Cursor-Employees')
       BEGIN

	       --PERSONAL DEATAILS
	       DECLARE  @PERSONALDETAILS TABLE (EmployeeID NVARCHAR(4000),Name NVARCHAR(4000),IdType NVARCHAR(4000),IdNumber NVARCHAR(4000),DateofSPRGranted NVARCHAR(4000),Nationality NVARCHAR(4000),Race NVARCHAR(4000),
		   DateOfBirth NVARCHAR(4000),Age int,Gender NVARCHAR(4000),MaritalStatus NVARCHAR(4000),PassportNumber  NVARCHAR(4000),PassportExpiry NVARCHAR(4000),UserName NVARCHAR(4000),
		   LocalAddress NVARCHAR(MAX),ForeignAddress NVARCHAR(MAX),Email NVARCHAR(4000) ,Mobile NVARCHAR(4000),ErrorRemarks NVARCHAR(MAX))																											  											
	
	       INSERT INTO @PERSONALDETAILS (EmployeeID,Name,IdType,IdNumber,Nationality,Race,DateOfBirth,Age,Gender,MaritalStatus,PassportNumber,PassportExpiry,UserName,
		   LocalAddress,ForeignAddress,Email,Mobile,DateofSPRGranted,ErrorRemarks) SELECT EmployeeId,Name,IdType,IdNumber,Nationality,Race,DateofBirth,Age,Gender,MaritalStatus,PassPortNumber,PassportExpiry,
		   UserName,LocalAddress,Foreignaddress,Email,Mobile,DateofSPRGranted,ErrorRemarks FROM ImportPersonalDetails WHERE TransactionId=@TRANSACTIONID AND importstatus=0



		   --EMPLOYMENT
		   DECLARE  @EMPLOYMENT TABLE (EmployeeID NVARCHAR(4000),TypeofEmployment NVARCHAR(4000),EmploymentStartDate NVARCHAR(4000),EmploymentEndDate NVARCHAR(4000),
	       Period NVARCHAR(4000),[Days/Months] int,ConfirmationDate NVARCHAR(4000),ConfirmationRemarks NVARCHAR(MAX),RejoinDate NVARCHAR(4000),EntityName NVARCHAR(4000),
		   Department NVARCHAR(4000),Designation NVARCHAR(4000),Level int,ReportingTo NVARCHAR(4000),EffectiveFrom NVARCHAR(4000),Currency NVARCHAR(4000),MonthlyBasicPay NVARCHAR(4000),
		   ChargeoutRate NVARCHAR(4000),ErrorRemarks NVARCHAR(MAX))

		   INSERT INTO @EMPLOYMENT (EmployeeID,TypeofEmployment,EmploymentStartDate,EmploymentEndDate,Period,[Days/Months],ConfirmationDate,ConfirmationRemarks,RejoinDate,EntityName,
		   Department,Designation,Level,ReportingTo,EffectiveFrom,Currency,MonthlyBasicPay,ChargeoutRate,ErrorRemarks)SELECT E.EmployeeId,E.TypeofEmployment,E.EmploymentStartDate,E.EmploymentEndDate,E.Period,
		   E.[Days/Months],E.ConfirmationDate,E.ConfirmationRemarks,E.RejoinDate,ED.EntityName,ED.Department,ED.Designation,ED.Level,ED.ReportingTo,ED.EffectiveFrom,ED.Currency,ED.MonthlyBasicPay,
		   ED.ChargeOutRate,concat(E.ErrorRemarks,ED.ErrorRemarks) FROM ImportEmployment E JOIN ImportEmployeeDepartment ED ON E.EmployeeId=ED.EmployeeId WHERE E.TransactionId=@TRANSACTIONID and ED.TransactionId=@TRANSACTIONID and  (ED.ImportStatus=0 or E.ImportStatus=0 )



		   --QUALIFICATION
		   DECLARE  @QUALIFICATION TABLE (EmployeeId NVARCHAR(4000),Type NVARCHAR(4000),Qualification NVARCHAR(4000),Institution NVARCHAR(4000),StartDate NVARCHAR(4000),EndDate NVARCHAR(4000),Attachments NVARCHAR(MAX),ErrorRemarks NVARCHAR(MAX))	

		   INSERT INTO @QUALIFICATION (EmployeeId,Type,Qualification,Institution,StartDate,EndDate,Attachments,ErrorRemarks) SELECT EmployeeId,Type,Qualification,Institution,StartDate,EndDate,Attachments,ErrorRemarks FROM ImportQualification
		   WHERE TransactionId=@TRANSACTIONID AND importstatus=0




		   --FAMILY
		   DECLARE  @FAMILY TABLE (EmployeeId NVARCHAR(4000),Name NVARCHAR(4000),Relation NVARCHAR(4000),Nationality NVARCHAR(4000),IDNo NVARCHAR(4000),DateOfBirth NVARCHAR(4000),Age int,ContactNo NVARCHAR(4000),[NameofEmployer/School]  NVARCHAR(4000),EmergencyContact bit,ErrorRemarks NVARCHAR(MAX))
		   
		   INSERT INTO @FAMILY(EmployeeId,Name,Relation,Nationality,IDNo,DateOfBirth,Age,ContactNo,[NameofEmployer/School],EmergencyContact,ErrorRemarks) SELECT EmployeeId,Name,Relation,Nationality,IDNo,DateofBirth,Age,ContactNo,
		   [NameofEmployer/School],EmergencyContact,ErrorRemarks FROM ImportFamily WHERE TransactionId=@TRANSACTIONID AND  importstatus=0


		   SELECT * FROM @PERSONALDETAILS
		   SELECT * FROM @EMPLOYMENT
		   SELECT * FROM @QUALIFICATION
		   SELECT * FROM @FAMILY 

	   END
	   
 ELSE IF(@SCREENNAME='BR Cursor-Entity')
	BEGIN
		DECLARE  @EntityDetails TABLE (Source NVARCHAR(4000),[Entity Name] NVARCHAR(4000),[Company Type] NVARCHAR(4000),Suffix NVARCHAR(4000),EntityIncharge NVARCHAR(4000),EntityType NVARCHAR(4000),Jurisdiction NVARCHAR(4000),
		   RegistrationNo NVARCHAR(4000),IncorporationDate NVARCHAR(4000),TakeoverDate NVARCHAR(4000),FormerNameifany NVARCHAR(4000),Email  NVARCHAR(4000),Phone NVARCHAR(4000),Communacation NVARCHAR(4000),
		   LastFYE NVARCHAR(MAX),FirstAGM NVARCHAR(MAX),LastAGM NVARCHAR(4000) ,CurrentFYE NVARCHAR(4000),CurrentYear NVARCHAR(MAX),AGMDate NVARCHAR(MAX),ARDate NVARCHAR(MAX),AddressType NVARCHAR(4000) ,LocalAddress NVARCHAR(4000),
		   [Block/HouseNo] NVARCHAR(MAX),Street NVARCHAR(MAX),Unitno NVARCHAR(MAX),Building NVARCHAR(4000) ,Country NVARCHAR(4000),PostalCode NVARCHAR(MAX),PSSICCode NVARCHAR(4000),PrimaryActivity NVARCHAR(4000),PrimaryActitvityDescription NVARCHAR(MAX),
		   [SSSIC Code] NVARCHAR(4000),[Secondary Activity] NVARCHAR(4000),[Secondary Activty Description] NVARCHAR(MAX),ErrorRemarks NVARCHAR(MAX),ImportStatus NVARCHAR(4000))																											  											
	
		INSERT INTO @EntityDetails (Source,[Entity Name],[Company Type],Suffix,EntityIncharge,EntityType,Jurisdiction,RegistrationNo,IncorporationDate,TakeoverDate,FormerNameifany,Email,Phone,
		   Communacation,LastFYE,FirstAGM,LastAGM,CurrentFYE,CurrentYear,AGMDate,ARDate,AddressType,LocalAddress,[Block/HouseNo],Street,Unitno,Building,Country,PostalCode,
		   PSSICCode,PrimaryActivity,PrimaryActitvityDescription,[SSSIC Code],[Secondary Activity],[Secondary Activty Description],ErrorRemarks,ImportStatus) 
		   SELECT Source,[Entity Name],[Company Type],Suffix,[Entity Incharge],[Entity Type],Jurisdiction,[Registration No],IncorporationDate,[Takeover Date],[Former Name if any],Email,Phone,
		   Communacation,[Last FYE],[First AGM],[Last AGM],[Current FYE],[Current Year],[AGM Date],[AR Date],[Address Type],[Local Address],[Block/House No],Street,[Unit no],Building,Country,[Postal Code],
		   [PSSIC Code],[Primary Activity],[Primary Actitvity Description],[SSSIC Code],[Secondary Activity],[Secondary Activty Description],ErrorRemarks,ImportStatus FROM [Import].[BRFailureEnity] WHERE TransactionId=@TRANSACTIONID AND importstatus=0

		SELECT * FROM @EntityDetails
	END
	   
 ELSE IF(@SCREENNAME='BR Cursor-Contact')
	BEGIN
	DECLARE  @EntityContacts TABLE (NominatedByid NVARCHAR(4000),[Entity Name] NVARCHAR(4000),[Registration No] NVARCHAR(4000),Category NVARCHAR(4000),Signatory NVARCHAR(4000),Salutation NVARCHAR(4000),Name NVARCHAR(4000),
		   [ID Number/UEN] NVARCHAR(4000),[ID Type] NVARCHAR(4000),[Passport Expiry (dd/mm/yyyy)] NVARCHAR(4000),Nationality NVARCHAR(4000),[Date of Birth (dd/mm/yyyy)]  NVARCHAR(4000),[Country of Residence] NVARCHAR(4000),[Country of Incorporation] NVARCHAR(4000), [Company Type] NVARCHAR(MAX),[Former Name] NVARCHAR(MAX),[Date of Incorporation (dd/mm/yyyy)] NVARCHAR(4000) ,Position NVARCHAR(4000),Nominee NVARCHAR(MAX),Nominators NVARCHAR(MAX),[DateOfNomination (dd/mm/yyyy)] NVARCHAR(MAX),[Nominators DateOfEntry(dd/MM/YYYY)] NVARCHAR(4000) ,[Appointment Date (dd/mm/yyyy)] NVARCHAR(4000),
		   [Cessation Date  (dd/mm/yyyy)] NVARCHAR(MAX),[Reason for Cessation] NVARCHAR(MAX),IsRegistrableController NVARCHAR(MAX),IsSignificantInterest NVARCHAR(4000) ,IsSignificantControl NVARCHAR(4000),DateofEntry NVARCHAR(MAX),[Legal Form] NVARCHAR(MAX),[Governing Jurisdiction Law] NVARCHAR(4000),[Register of Companies of the Jurisdiction] NVARCHAR(4000),Email NVARCHAR(MAX),[Phone No] NVARCHAR(MAX),[Address Type] NVARCHAR(4000),[Local Address] NVARCHAR(4000),[Block/House No] NVARCHAR(4000),[Unit no] NVARCHAR(4000),Street NVARCHAR(4000),Building NVARCHAR(4000),Country NVARCHAR(4000),[Postal Code] NVARCHAR(4000),ErrorRemarks NVARCHAR(max))																											  											
	
		INSERT INTO @EntityContacts (NominatedByid,[Entity Name],[Registration No],Category,Signatory,Salutation,Name,[ID Number/UEN],[ID Type],[Passport Expiry (dd/mm/yyyy)],Nationality,[Date of Birth (dd/mm/yyyy)],[Country of Residence],[Country of Incorporation],[Company Type],[Former Name],[Date of Incorporation (dd/mm/yyyy)],Position,Nominee,Nominators,[DateOfNomination (dd/mm/yyyy)],[Nominators DateOfEntry(dd/MM/YYYY)],[Appointment Date (dd/mm/yyyy)],[Cessation Date  (dd/mm/yyyy)],[Reason for Cessation],IsRegistrableController,IsSignificantInterest,IsSignificantControl,DateofEntry,[Legal Form],[Governing Jurisdiction Law],[Register of Companies of the Jurisdiction],Email,[Phone No],[Address Type],[Local Address],[Block/House No],[Unit no],Street,Building,Country,[Postal Code],ErrorRemarks) 
		   SELECT NominatedByid,[Entity Name],[Registration No],Category,Signatory,Salutation,Name,[ID Number/UEN],[ID Type],[Passport Expiry (dd/mm/yyyy)],Nationality,[Date of Birth (dd/mm/yyyy)],[Country of Residence],[Country of Incorporation],[Company Type],[Former Name],[Date of Incorporation (dd/mm/yyyy)],Position,Nominee,Nominators,[DateOfNomination (dd/mm/yyyy)],[Nominators DateOfEntry(dd/MM/YYYY)],[Appointment Date (dd/mm/yyyy)],[Cessation Date  (dd/mm/yyyy)],[Reason for Cessation],IsRegistrableController,IsSignificantInterest,IsSignificantControl,DateofEntry,[Legal Form],[Governing Jurisdiction Law],[Register of Companies of the Jurisdiction],Email,[Phone No],[Address Type],[Local Address],[Block/House No],[Unit no],Street,Building,Country,[Postal Code],ErrorRemarks
		   FROM [Import].[BRFailureEnityContact] WHERE TransactionId=@TRANSACTIONID AND importstatus=0

		select * from @EntityContacts

	END

  ELSE IF(@SCREENNAME='BR Cursor-Shares')
	BEGIN
	DECLARE  @Entityshares TABLE ([Entity Name] NVARCHAR(4000),[Registration No] NVARCHAR(4000),Category NVARCHAR(4000),Position NVARCHAR(4000),Name NVARCHAR(4000),UEN NVARCHAR(4000),[Transaction Date] NVARCHAR(4000),[Transaction Type] NVARCHAR(4000),ShareType NVARCHAR(4000),ShareClass NVARCHAR(4000),Currency NVARCHAR(4000),ShareDescription  NVARCHAR(4000),mode NVARCHAR(4000),Nature NVARCHAR(4000), [Shares held in trust] NVARCHAR(MAX),[Name of the trust] NVARCHAR(MAX),NumberOfShares NVARCHAR(4000) ,Issued NVARCHAR(4000),[Paid Up] NVARCHAR(MAX),[Certificate No] NVARCHAR(MAX),Remarks NVARCHAR(MAX),Toatalbalance NVARCHAR(4000) ,ErrorRemarks NVARCHAR(max))																											  											
	
		INSERT INTO @Entityshares ([Entity Name],[Registration No],Category,Position,Name,UEN,[Transaction Date],[Transaction Type],ShareType,ShareClass,Currency,ShareDescription,mode,Nature,[Shares held in trust],[Name of the trust],NumberOfShares,Issued,[Paid Up],[Certificate No],Remarks,Toatalbalance,ErrorRemarks) 
		   SELECT [Entity Name],[Registration No],Category,Position,Name,UEN,[Transaction Date],[Transaction Type],ShareType,ShareClass,Currency,ShareDescription,mode,Nature,[Shares held in trust],[Name of the trust],NumberOfShares,Issued,[Paid Up],[Certificate No],Remarks,Toatalbalance,ErrorRemarks
		   FROM [Import].[BRFailureEntityShare] WHERE TransactionId=@TRANSACTIONID AND importstatus=0

		select * from @Entityshares

	END
	   END
--====================================================New changes sp===========================

IF(@Date<@UploadDate)
BEGIN
IF(@SCREENNAME='Client Cursor-Accounts')
       BEGIN
	       
		  -- ---==================================== New changes ======================================
		  -- ---AccountContact
		  --   Declare @CCAccountContact Table ([Id] [nvarchar](1024) ,[Type] [nvarchar](1024) ,[Name] [nvarchar](1024) ,[Source Type] [nvarchar](1024),[Source/Remarks] [nvarchar](1024),[Account Type] [nvarchar](1024) ,[Identification Type] [nvarchar](1024) ,[Identification number] [nvarchar](1024) ,
		  --   [Credit Term Days] [nvarchar](1024) ,[Industry] [nvarchar](1024) ,[Incorporation Date] [nvarchar](1024) ,[Incorporation Country] [nvarchar](1024) ,[Financial Year End] [nvarchar](1024) ,[Company Secretary] [nvarchar](1024) ,[Incharges (internal staff)] [nvarchar](1024) ,
		  --   [Principal Activities] [nvarchar](1024) ,[RemindersAGM] [nvarchar](1024) ,[RemindersECI] [nvarchar](1024) ,[RemindersAudit] [nvarchar](1024) ,[RemindersFinal Tax] [nvarchar](1024) ,[Email] [nvarchar](1024) ,[Phone] [nvarchar](1024) ,[Local Address Block/House No] [nvarchar](1024) ,
		  --   [Local Address Street] [nvarchar](1024) ,[Local Address Unit No] [nvarchar](1024) ,[Local Address Building] [nvarchar](1024) ,[Local Address Country] [nvarchar](1024) ,[Local Address Postal code] [nvarchar](1024) ,
		     
		  --   [Salutation] [nvarchar](1024) ,[Contact Name] [nvarchar](1024) ,[Date of Birth] [nvarchar](1024) ,[Contact Identification Type] [nvarchar](1024) ,[Contact Identification Number] [nvarchar](1024) ,[Country Of Residence] [nvarchar](1024) ,[PersonalEmail] [nvarchar](1024) ,
		  --   [PersonalPhone] [nvarchar](1024) ,[PersonalLocal Address Block/House No] [nvarchar](1024) ,[PersonalLocal Address address Street] [nvarchar](1024) ,[PersonalLocal Address address Unit No] [nvarchar](1024) ,[PersonalLocal Address address Building] [nvarchar](1024) ,
		  --   [PersonalLocal Address address Country] [nvarchar](1024) ,[PersonalLocal Address address Postal code] [nvarchar](1024) ,[EntityDesignation] [nvarchar](1024) ,[Primary Contacts] [nvarchar](1024) ,[Reminder Recipient] [nvarchar](1024) ,[EntityEmail] [nvarchar](1024) ,
		  --   [EntityPhone] [nvarchar](1024) ,[EntityLocal Address Block/House No] [nvarchar](1024) ,[EntityLocal Address Street] [nvarchar](1024) ,[EntityLocal Address Unit No] [nvarchar](1024) ,[EntityLocal Address Building] [nvarchar](1024) ,[EntityLocal Address Country] [nvarchar](1024) ,
		  --   [EntityLocal Address Postal code] [nvarchar](1024) ,[Remarks] [nvarchar](1024) ,[Copy communication and Address] [nvarchar](1024),
		  --   ErrorRemarks NVARCHAR(MAX),[Contact ErrorRemarks] NVARCHAR(MAX))
			 --DELETE FROM @CCAccountContact
			 
		  --    INSERT INTO @CCAccountContact (
		  --    [Id] ,[Type] ,[Name]  ,[Source Type] ,[Source/Remarks] ,[Account Type]  ,[Identification Type]  ,[Identification number]  ,
		  --    [Credit Term Days]  ,[Industry]  ,[Incorporation Date]  ,[Incorporation Country]  ,[Financial Year End]  ,[Company Secretary]  ,[Incharges (internal staff)]  ,
		  --    [Principal Activities]  ,[RemindersAGM]  ,[RemindersECI]  ,[RemindersAudit]  ,[RemindersFinal Tax]  ,[Email]  ,[Phone]  ,[Local Address Block/House No]  ,
		  --    [Local Address Street]  ,[Local Address Unit No]  ,[Local Address Building]  ,[Local Address Country]  ,[Local Address Postal code]  ,
		      
		  --    [Salutation]  ,[Contact Name] ,[Date of Birth]  ,[Contact Identification Type]  ,[Contact Identification Number]  ,[Country Of Residence]  ,[PersonalEmail]  ,
		  --    [PersonalPhone] ,[PersonalLocal Address Block/House No]  ,[PersonalLocal Address address Street]  ,[PersonalLocal Address address Unit No]  ,[PersonalLocal Address address Building]  ,
		  --    [PersonalLocal Address address Country]  ,[PersonalLocal Address address Postal code]  ,[EntityDesignation]  ,[Primary Contacts]  ,[Reminder Recipient]  ,[EntityEmail]  ,
		  --    [EntityPhone]  ,[EntityLocal Address Block/House No]  ,[EntityLocal Address Street]  ,[EntityLocal Address Unit No]  ,[EntityLocal Address Building]  ,[EntityLocal Address Country]  ,
		  --    [EntityLocal Address Postal code]  ,[Remarks]  ,[Copy communication and Address] ,
		  --    ErrorRemarks ,[Contact ErrorRemarks] ) 

			 -- SELECT  A.AccountId,A.Type,A.Name,A.SourceType,A.[Source/Remarks],A.AccountType,A.IdentificationType,A.IdentificationNumber,A.CreditTerms,
	   --      A.Industry,A.IncorporationDate,A.IncorporationCountry,A.FinancialYearEnd,A.CompanySecretary,A.InchargesinClientCursor,A.PrincipalActivities,
			 --CASE WHEN A.RemindersAGM=1 THEN 'YES' ELSE 'NO' END AS RemindersAGM ,      --Bool
	   --      CASE WHEN A.RemindersECI=1 THEN 'YES' ELSE 'NO' END AS RemindersECI ,      --Bool
			 --CASE WHEN A.RemindersAudit=1 THEN 'YES' ELSE 'NO' END AS RemindersAudit ,  --Bool
			 --CASE WHEN A.RemindersFinalTax=1 THEN 'YES' ELSE 'NO' END AS RemindersFinalTax ,  --Bool
			 --A.Email,A.Phone,A.LocalAddressBlockHouseNo,A.LocalAddressStreet,A.LocalAddressUnitNo,A.LocalAddressBuilding,A.LocalAddressCountry,A.LocalAddressPostalcode,
			 
			 --C.Salutation, C.Name, C.DateofBirth, C.IdentificationType, C.IdentificationNumber, C.CountryOfResidence, C.PersonalEmail, C.PersonalPhone, C.PersonalLocalAddressBlockHouseNo, C.PersonalLocalAddressStreet, C.PersonalLocalAddressUnitNo, C.PersonalLocalAddressBuilding, C.PersonalLocalAddressCountry, C.PersonalLocalAddressPostalcode, C.EntityDesignation,
			 --CASE WHEN  C.PrimaryContacts=1 THEN 'YES' ELSE 'NO' END AS PrimaryContacts,  --Bool
			 --CASE WHEN  C.ReminderRecipient=1 THEN 'YES' ELSE 'NO' END AS ReminderRecipient,  --Bool
			 -- C.EntityEmail, C.EntityPhone, C.EntityLocalAddressBlockHouseNo, C.EntityLocalAddressStreet, C.EntityLocalAddressUnitNo, C.EntityLocalAddresssBuilding, C.EntityLocalAddressCountry, C.EntityLocalAddressPostalcode, C.Remarks,
    --         CASE WHEN  C.CopycommunicationandAddress=1 THEN 'YES' ELSE 'NO' END AS CopycommunicationandAddress,  --Bool
			 --A.ErrorRemarks, C.ErrorRemarks
			 --FROM MigrationDBPRD.[Import].[CCAccount] A
			 --LEFT JOIN  MigrationDBPRD.[Import].[CCContact] C ON C.MasterId=A.AccountId AND C.TransactionId=@TRANSACTIONID and  C.ImportStatus=0
			 --WHERE A.TransactionId=@TRANSACTIONID   and  A.ImportStatus=0 
			 --GROUP BY  A.AccountId,A.Type,A.Name,A.SourceType,A.[Source/Remarks],A.AccountType,A.IdentificationType,A.IdentificationNumber,A.CreditTerms,
	   --      A.Industry,A.IncorporationDate,A.IncorporationCountry,A.FinancialYearEnd,A.CompanySecretary,A.InchargesinClientCursor,A.PrincipalActivities,
			 --CASE WHEN A.RemindersAGM=1 THEN 'YES' ELSE 'NO' END  ,      --Bool
	   --      CASE WHEN A.RemindersECI=1 THEN 'YES' ELSE 'NO' END  ,      --Bool
			 --CASE WHEN A.RemindersAudit=1 THEN 'YES' ELSE 'NO' END  ,  --Bool
			 --CASE WHEN A.RemindersFinalTax=1 THEN 'YES' ELSE 'NO' END  ,  --Bool
			 --A.Email,A.Phone,A.LocalAddressBlockHouseNo,A.LocalAddressStreet,A.LocalAddressUnitNo,A.LocalAddressBuilding,A.LocalAddressCountry,A.LocalAddressPostalcode,
			 
			 --C.Salutation, C.Name, C.DateofBirth, C.IdentificationType, C.IdentificationNumber, C.CountryOfResidence, C.PersonalEmail, C.PersonalPhone, C.PersonalLocalAddressBlockHouseNo, C.PersonalLocalAddressStreet, C.PersonalLocalAddressUnitNo, C.PersonalLocalAddressBuilding, C.PersonalLocalAddressCountry, C.PersonalLocalAddressPostalcode, C.EntityDesignation,
			 --CASE WHEN  C.PrimaryContacts=1 THEN 'YES' ELSE 'NO' END ,  --Bool
			 --CASE WHEN  C.ReminderRecipient=1 THEN 'YES' ELSE 'NO' END ,  --Bool
			 -- C.EntityEmail, C.EntityPhone, C.EntityLocalAddressBlockHouseNo, C.EntityLocalAddressStreet, C.EntityLocalAddressUnitNo, C.EntityLocalAddresssBuilding, C.EntityLocalAddressCountry, C.EntityLocalAddressPostalcode, C.Remarks,
    --         CASE WHEN  C.CopycommunicationandAddress=1 THEN 'YES' ELSE 'NO' END ,  --Bool
			 --A.ErrorRemarks, C.ErrorRemarks
			 --SELECT * FROM @CCAccountContact
		   --================================================== Old=========================================================
		     ---LEAD
             DECLARE  @CCAccount TABLE (Id NVARCHAR(4000),Type NVARCHAR(4000),Name NVARCHAR(4000),SourceType NVARCHAR(4000),[Source/Remarks] NVARCHAR(4000),AccountType NVARCHAR(4000),
	         IdentificationType NVARCHAR(4000),IdentificationNumber NVARCHAR(4000),CreditTerms NVARCHAR(4000),Industry NVARCHAR(4000),Incorporationdate NVARCHAR(4000),
	         IncorporationCountry NVARCHAR(4000),FinancialyearEnd NVARCHAR(4000),CompanySecretary NVARCHAR(4000),InchargesinClientCursor  NVARCHAR(4000),PrincipalActivities NVARCHAR(MAX),
	         RemindersAGM Nvarchar(10) ,RemindersECI Nvarchar(10) ,RemindersAudit Nvarchar(10),RemindersFinalTax Nvarchar(10),Email NVARCHAR(4000) ,Phone NVARCHAR(4000)
			 ,LocalAddress NVARCHAR(4000),Foreignaddress NVARCHAR(4000),
			 AccountErrorRemarks NVARCHAR(MAX))

             INSERT INTO @CCAccount (Id,Type,Name,SourceType,[Source/Remarks],AccountType,IdentificationType,IdentificationNumber,CreditTerms,Industry,Incorporationdate
	         ,IncorporationCountry,FinancialyearEnd,CompanySecretary,InchargesinClientCursor,PrincipalActivities,RemindersAGM,RemindersECI,RemindersAudit,RemindersFinalTax,
	         Email,Phone,LocalAddress,Foreignaddress,AccountErrorRemarks) 
			 
			 SELECT AccountId,Type,Name,SourceType,[Source/Remarks],AccountType,IdentificationType,IdentificationNumber,CreditTerms,
	         Industry,IncorporationDate,IncorporationCountry,FinancialYearEnd,CompanySecretary,InchargesinClientCursor,PrincipalActivities,
			 CASE WHEN RemindersAGM=1 THEN 'YES' ELSE 'NO' END AS RemindersAGM ,      --Bool
	         CASE WHEN RemindersECI=1 THEN 'YES' ELSE 'NO' END AS RemindersECI ,      --Bool
			 CASE WHEN RemindersAudit=1 THEN 'YES' ELSE 'NO' END AS RemindersAudit ,  --Bool
			 CASE WHEN RemindersFinalTax=1 THEN 'YES' ELSE 'NO' END AS RemindersFinalTax ,  --Bool
			 Email,Phone,LocalAddress,Foreignaddress,AccountErrorRemarks
			 FROM Importleads WHERE TransactionId=@TRANSACTIONID  and  AccountImportStatus=0


			 ---CONTACT
	         DECLARE  @CCContact TABLE (MASTERID NVARCHAR(4000),Salutation NVARCHAR(4000),Name NVARCHAR(4000),DateofBirth NVARCHAR(4000),IdentificationType NVARCHAR(4000),IdentificationNumber NVARCHAR(4000),
			 CountryofResidence NVARCHAR(4000),PersonalEmail NVARCHAR(4000),PersonalPhone NVARCHAR(4000),PersonalLocalAddress NVARCHAR(4000),PersonalForeignAddress NVARCHAR(4000),
	         EntityDesignation NVARCHAR(4000),PrimaryContacts Nvarchar(10),ReminderRecipient Nvarchar(10),EntityEmail NVARCHAR(4000) ,EntityPhone NVARCHAR(4000),
	        EntityLocalAddress NVARCHAR(4000),EntityForeignAddress NVARCHAR(4000),Remarks NVARCHAR(MAX),CopyCommunicationandAddress Nvarchar(10),ErrorRemarks NVARCHAR(MAX))																											  											
	        
             Insert Into @CCContact(MASTERID,Salutation,Name,DateofBirth,IdentificationType,IdentificationNumber,CountryofResidence,PersonalEmail,PersonalPhone,PersonalLocalAddress,PersonalForeignAddress,
	         EntityDesignation,PrimaryContacts,ReminderRecipient,EntityEmail,EntityPhone,EntityLocalAddress,EntityForeignAddress,Remarks,CopyCommunicationandAddress,ErrorRemarks)
	        
			Select MasterId,Salutation,Name,DateofBirth,IdentificationType,IdentificationNumber,CountryOfResidence,PersonalEmail,PersonalPhone,PersonalLocalAddress,PersonalForeignAddress,EntityDesignation,
			 CASE WHEN PrimaryContacts=1 THEN 'YES' ELSE 'NO' END AS PrimaryContacts,  --Bool
			 CASE WHEN ReminderRecipient=1 THEN 'YES' ELSE 'NO' END AS ReminderRecipient,  --Bool
			 EntityEmail,EntityPhone,EntityLocalAddress,EntityForeignAddress,Remarks,
            CASE WHEN CopycommunicationandAddress=1 THEN 'YES' ELSE 'NO' END AS CopycommunicationandAddress,  --Bool
			 ErrorRemarks  
	         from ImportContacts where  TransactionId=@TRANSACTIONID and  importstatus=0
	


	         SELECT * FROM @CCAccount
	         SELECT * FROM @CCContact

      END

 ELSE IF(@SCREENNAME='Workflow Cursor-Clients')
       BEGIN
		    
			--CLIENT
	        DECLARE  @WFClient TABLE  (ClientRefnumber NVARCHAR(4000),Name NVARCHAR(4000),ClientType NVARCHAR(4000),Identificationtype NVARCHAR(4000),IdentificationNumber NVARCHAR(4000),
            CreditTerms  NVARCHAR(4000),IncorporationDate NVARCHAR(4000),IncorporationCountry NVARCHAR(4000),Financialyearend NVARCHAR(4000),Industry NVARCHAR(4000),
            PrinicipalActivities NVARCHAR(4000),Mobile NVARCHAR(4000),Email NVARCHAR(4000),LocalAddressBlockHouseNo NVARCHAR(4000),LocalAddressStreet NVARCHAR(4000),LocalAddressUnitNo NVARCHAR(4000),LocalAddressBuilding NVARCHAR(4000),LocalAddressCountry NVARCHAR(4000),LocalAddressPostalcode NVARCHAR(4000),ErrorRemarks NVARCHAR(MAX))  
			
			INSERT INTO @WFClient (ClientRefnumber,Name,ClientType,Identificationtype,IdentificationNumber,CreditTerms,IncorporationDate,IncorporationCountry,Financialyearend,
			Industry,PrinicipalActivities,Mobile,Email,LocalAddressBlockHouseNo,LocalAddressStreet,LocalAddressUnitNo,LocalAddressBuilding,LocalAddressCountry,LocalAddressPostalcode,ErrorRemarks)
			SELECT ClientRefNumber,Name,ClientType,Identificationtype,IdentificationNumber,CreditTerms,
			IncorporationDate,IncorporationCountry,FinancialYearEnd,Industry,PrinicipalActivities,Mobile,Email,LocalAddressBlockHouseNo,LocalAddressStreet,LocalAddressUnitNo,LocalAddressBuilding,LocalAddressCountry,LocalAddressPostalcode,ErrorRemarks 
			FROM MigrationDBPRD.[Import].[WFClient]
			WHERE TransactionID=@TRANSACTIONID AND 	importstatus=0																																													  
			GROUP BY ClientRefNumber,Name,ClientType,Identificationtype,IdentificationNumber,CreditTerms,
			IncorporationDate,IncorporationCountry,FinancialYearEnd,Industry,PrinicipalActivities,Mobile,Email,LocalAddressBlockHouseNo,LocalAddressStreet,LocalAddressUnitNo,LocalAddressBuilding,LocalAddressCountry,LocalAddressPostalcode,ErrorRemarks 

			---WFCONTACT

			DECLARE  @WFContacts TABLE (ClientRefnumber NVARCHAR(4000),Salutation NVARCHAR(4000),Name NVARCHAR(4000),DateofBirth NVARCHAR(4000),IdentificationType NVARCHAR(4000),IdentificationNumber NVARCHAR(4000),
			CountryofResidence NVARCHAR(4000),PersonalEmail NVARCHAR(4000),PersonalMobile NVARCHAR(4000),PersonalLocalAddressBlockHouseNo NVARCHAR(4000),PersonalLocalAddressStreet NVARCHAR(4000),PersonalLocalAddressUnitNo NVARCHAR(4000),PersonalLocalAddressBuilding NVARCHAR(4000),PersonalLocalAddressCountry NVARCHAR(4000),PersonalLocalAddressPostalcode NVARCHAR(4000),
			EntityDesignation NVARCHAR(4000),PrimaryContact Nvarchar(10),EntityEmail NVARCHAR(4000) ,EntityMobile NVARCHAR(4000),EntityLocalAddressBlockHouseNo NVARCHAR(4000),EntityLocalAddressStreet NVARCHAR(4000),EntityLocalAddressUnitNo NVARCHAR(4000),EntityLocalAddresssBuilding NVARCHAR(4000),EntityLocalAddressCountry NVARCHAR(4000),EntityLocalAddressPostalcode NVARCHAR(4000),
			Remarks NVARCHAR(MAX),CopyCommunicationandAddress Nvarchar(10),ErrorRemarks NVARCHAR(MAX))	
			
																													  											
			INSERT INTO @WFContacts (ClientRefnumber,Salutation,Name,DateofBirth,IdentificationType,IdentificationNumber,CountryofResidence,PersonalEmail,PersonalMobile,PersonalLocalAddressBlockHouseNo,PersonalLocalAddressStreet,PersonalLocalAddressUnitNo,PersonalLocalAddressBuilding,PersonalLocalAddressCountry,PersonalLocalAddressPostalcode,
			EntityDesignation,PrimaryContact,EntityEmail,EntityMobile,EntityLocalAddressBlockHouseNo,EntityLocalAddressStreet,EntityLocalAddressUnitNo,EntityLocalAddresssBuilding,EntityLocalAddressCountry,EntityLocalAddressPostalcode,Remarks,CopyCommunicationandAddress,ErrorRemarks)
			SELECT ClientRefNumber,Salutation,Name,DateofBirth,
			IdentificationType,IdentificationNumber,CountryOfResidence,PersonalEmail,PersonalMobile,PersonalLocalAddressBlockHouseNo,PersonalLocalAddressStreet,PersonalLocalAddressUnitNo,PersonalLocalAddressBuilding,PersonalLocalAddressCountry,PersonalLocalAddressPostalcode,EntityDesignation,
			CASE WHEN PrimaryContact=1 THEN 'YES' ELSE 'NO' END AS PrimaryContact ,  --Bool
			EntityEmail,EntityMobile,
			EntityLocalAddressBlockHouseNo,EntityLocalAddressStreet,EntityLocalAddressUnitNo,EntityLocalAddresssBuilding,EntityLocalAddressCountry,EntityLocalAddressPostalcode,Remarks,
			CASE WHEN CopycommunicationandAddress=1 THEN 'YES' ELSE 'NO' END AS CopycommunicationandAddress,  --Bool
			ErrorRemarks  
			FROM MigrationDBPRD.[Import].[WFContact] WHERE TransactionId=@TRANSACTIONID  AND importstatus=0
			GROUP BY  ClientRefNumber,Salutation,Name,DateofBirth,
			IdentificationType,IdentificationNumber,CountryOfResidence,PersonalEmail,PersonalMobile,PersonalLocalAddressBlockHouseNo,PersonalLocalAddressStreet,PersonalLocalAddressUnitNo,PersonalLocalAddressBuilding,PersonalLocalAddressCountry,PersonalLocalAddressPostalcode,EntityDesignation,
			CASE WHEN PrimaryContact=1 THEN 'YES' ELSE 'NO' END  ,  --Bool
			EntityEmail,EntityMobile,
			EntityLocalAddressBlockHouseNo,EntityLocalAddressStreet,EntityLocalAddressUnitNo,EntityLocalAddresssBuilding,EntityLocalAddressCountry,EntityLocalAddressPostalcode,Remarks,
			CASE WHEN CopycommunicationandAddress=1 THEN 'YES' ELSE 'NO' END ,  --Bool
			ErrorRemarks  

			SELECT * FROM @WFClient
			SELECT * FROM @WFContacts


       END
  
 ELSE IF(@SCREENNAME='Bean Cursor-Entities')
       BEGIN

	            Declare @CCEntityContact Table ([Name] [nvarchar](2000) ,[Entity Type] [nvarchar](2000) ,[Identification Type] [nvarchar](2000) ,[Identification Number] [nvarchar](2000) ,[GST Registration Number] [nvarchar](2000) ,
               [Customer] [nvarchar](2000) ,[Credit Term Days] [nvarchar](2000) ,[Credit Limit][nvarchar](2000) ,[Cust Nature] [nvarchar](2000) ,[Cust Currency] [nvarchar](2000) ,
               [Vendor] [nvarchar](2000) ,[Payment Term Days] [nvarchar](2000),[Vendor Type] [nvarchar](2000),[Ven Nature][nvarchar](2000),[Ven Currency] [nvarchar](2000),
               [Default COA] [nvarchar](2000),[Default Tax Code] [nvarchar](2000),[Email] [nvarchar](2000) ,[Phone] [nvarchar](2000) ,[Local Address Block/House No] [nvarchar](2000) ,
               [Local Address Street] [nvarchar](2000) ,[Local Address Unit No] [nvarchar](2000) ,[Local Address Building] [nvarchar](2000) ,[Local Address Country] [nvarchar](2000) ,[Local Address Postal code] [nvarchar](2000) ,
               
               [Salutation] [nvarchar](2000) ,[Contact Name] [nvarchar](2000) ,[Date of Birth] [nvarchar](2000) ,[Contact Identification Type] [nvarchar](2000) ,[Contact Identification Number] [nvarchar](2000) ,
               [Country Of Residence] [nvarchar](2000) ,[PersonalEmail] [nvarchar](2000) ,[PersonalPhone] [nvarchar](2000) ,[PersonalLocal Address Block/House No] [nvarchar](2000) ,
               [PersonalLocal Address address Street] [nvarchar](2000) ,[PersonalLocal Address address Unit No] [nvarchar](2000) ,[PersonalLocal Address address Building] [nvarchar](2000) ,[PersonalLocal Address address Country] [nvarchar](2000) ,
               [PersonalLocal Address address Postal code] [nvarchar](2000) ,
               [Designation] [nvarchar](2000) ,[Primary Contacts] [nvarchar](2000) ,[EntityEmail] [nvarchar](2000) ,[EntityPhone] [nvarchar](2000) ,[EntityLocal Address Block/House No] [nvarchar](2000) ,
               [EntityLocal Address Street] [nvarchar](2000) ,[EntityLocal Address Unit No] [nvarchar](2000) ,[EntityLocal Address Building] [nvarchar](2000) ,[EntityLocal Address Country] [nvarchar](2000) ,
               [EntityLocal Address Postal code] [nvarchar](2000) ,[Remarks] [nvarchar](2000) ,[Copy communication and Address] [nvarchar](2000) ,
               ErrorRemarks NVARCHAR(MAX),[Contact ErrorRemarks] NVARCHAR(MAX))
			    DELETE FROM @CCEntityContact

			   	INSERT INTO @CCEntityContact(
	            [Name]  ,[Entity Type]  ,[Identification Type]  ,[Identification Number]  ,[GST Registration Number]  ,[Customer]  ,[Credit Term Days]  ,[Credit Limit] ,
	            [Cust Nature]  ,[Cust Currency]  ,[Vendor]  ,[Payment Term Days] ,[Vendor Type] ,[Ven Nature],[Ven Currency] ,[Default COA] ,[Default Tax Code] ,
	            [Email]  ,[Phone]  ,[Local Address Block/House No]  ,[Local Address Street]  ,[Local Address Unit No]  ,[Local Address Building]  ,[Local Address Country] ,[Local Address Postal code]  ,
	            
	            [Salutation]  ,[Contact Name]  ,[Date of Birth]  ,[Contact Identification Type]  ,[Contact Identification Number]  ,[Country Of Residence]  ,
	            [PersonalEmail]  ,[PersonalPhone]  ,[PersonalLocal Address Block/House No] ,[PersonalLocal Address address Street]  ,[PersonalLocal Address address Unit No]  ,[PersonalLocal Address address Building]  ,
	            [PersonalLocal Address address Country]  ,[PersonalLocal Address address Postal code]  ,[Designation]  ,[Primary Contacts]  ,[EntityEmail]  ,[EntityPhone]  ,
	            [EntityLocal Address Block/House No]  ,[EntityLocal Address Street]  ,[EntityLocal Address Unit No]  ,[EntityLocal Address Building]  ,[EntityLocal Address Country]  ,
                [EntityLocal Address Postal code]  ,[Remarks]  ,[Copy communication and Address] ,
	            ErrorRemarks ,[Contact ErrorRemarks]  )

				SELECT A.EntityName,A.EntityType,A.EntityIdentificationType,A.EntityIdentificationNumber,A.GSTRegistrationNumber,
			     CASE WHEN A.Customer=1 THEN 'YES' ELSE 'NO' END AS Customer ,  --Bool
			     A.CreditTerms,A.CreditLimit,A.CustNature,A.CustCurrency,
			     CASE WHEN A.Vendor=1 THEN 'YES' ELSE 'NO' END AS Vendor ,  --Bool
			     A.PaymentTerms,A.VendorType,A.VenNature,A.VenCurrency,A.DefaultCOA,A.DefaultTaxCode,A.Email,A.Phone,
			     A.LocalAddressBlockHouseNo,A.LocalAddressStreet,A.LocalAddressUnitNo,A.LocalAddressBuilding,A.LocalAddressCountry,A.LocalAddressPostalcode,
			     
			     C.Salutation,C.Name,C.DateofBirth,C.IdentificationType,C.IdentificationNumber,C.CountryOfResidence,C.PersonalEmail,
			     C.PersonalPhone,C.PersonalLocalAddressBlockHouseNo,C.PersonalLocalAddressStreet,C.PersonalLocalAddressUnitNo,C.PersonalLocalAddressBuilding,C.PersonalLocalAddressCountry,C.PersonalLocalAddressPostalcode,C.Designation,
			     CASE WHEN C.PrimaryContacts=1 THEN 'YES' ELSE 'NO' END AS PrimaryContacts,  --Bool
			     C.EntityEmail,C.EntityPhone,C.EntityLocalAddressBlockHouseNo,C.EntityLocalAddressStreet,C.EntityLocalAddressUnitNo,C.EntityLocalAddresssBuilding,C.EntityLocalAddressCountry,C.EntityLocalAddressPostalcode,
			     C.Remarks,CASE WHEN C.CopycommunicationandAddress=1 THEN 'YES' ELSE 'NO' END AS CopycommunicationandAddress,
			     A.ErrorRemarks,C.ErrorRemarks 
			     FROM MigrationDBPRD.[Import].[BCEntities]  A
			     LEFT JOIN MigrationDBPRD.[Import].[BCContact] C ON C.EntityName=A.EntityName AND C.TransactionId=@TRANSACTIONID AND C.ImportStatus=0
			     WHERE A.TransactionId=@TRANSACTIONID AND A.ImportStatus=0  
				 GROUP BY  A.EntityName,A.EntityType,A.EntityIdentificationType,A.EntityIdentificationNumber,A.GSTRegistrationNumber,
			     CASE WHEN A.Customer=1 THEN 'YES' ELSE 'NO' END  ,  --Bool
			     A.CreditTerms,A.CreditLimit,A.CustNature,A.CustCurrency,
			     CASE WHEN A.Vendor=1 THEN 'YES' ELSE 'NO' END  ,  --Bool
			     A.PaymentTerms,A.VendorType,A.VenNature,A.VenCurrency,A.DefaultCOA,A.DefaultTaxCode,A.Email,A.Phone,
			     A.LocalAddressBlockHouseNo,A.LocalAddressStreet,A.LocalAddressUnitNo,A.LocalAddressBuilding,A.LocalAddressCountry,A.LocalAddressPostalcode,
			     
			     C.Salutation,C.Name,C.DateofBirth,C.IdentificationType,C.IdentificationNumber,C.CountryOfResidence,C.PersonalEmail,
			     C.PersonalPhone,C.PersonalLocalAddressBlockHouseNo,C.PersonalLocalAddressStreet,C.PersonalLocalAddressUnitNo,C.PersonalLocalAddressBuilding,C.PersonalLocalAddressCountry,C.PersonalLocalAddressPostalcode,C.Designation,
			     CASE WHEN C.PrimaryContacts=1 THEN 'YES' ELSE 'NO' END ,  --Bool
			     C.EntityEmail,C.EntityPhone,C.EntityLocalAddressBlockHouseNo,C.EntityLocalAddressStreet,C.EntityLocalAddressUnitNo,C.EntityLocalAddresssBuilding,C.EntityLocalAddressCountry,C.EntityLocalAddressPostalcode,
			     C.Remarks,CASE WHEN C.CopycommunicationandAddress=1 THEN 'YES' ELSE 'NO' END ,
			     A.ErrorRemarks,C.ErrorRemarks 
				 SELECT * FROM @CCEntityContact

	   ----============================================================ OLD===============================================
	  --      ---ENTITIES
			--DECLARE  @BCEntities TABLE (EntityName NVARCHAR(4000),EntityType NVARCHAR(4000),EntityIdentificationType NVARCHAR(4000),EntityIdentificationNumber NVARCHAR(4000),GSTRegistrationNumber NVARCHAR(4000),
			--Customer NVARCHAR(10),CreditTerms NVARCHAR(4000),CreditLimit NVARCHAR(4000),CustNature NVARCHAR(4000),CustCurrency NVARCHAR(4000),Vendor NVARCHAR(4000),PaymentTerms NVARCHAR(4000),VendorType NVARCHAR(4000),
			--VenNature NVARCHAR(4000),VenCurrency NVARCHAR(4000),DefaultCOA NVARCHAR(4000),
			--DefaultTaxCode NVARCHAR(4000), Email NVARCHAR(4000) ,Phone NVARCHAR(4000),LocalAddressBlockHouseNo NVARCHAR(4000),LocalAddressStreet NVARCHAR(4000),LocalAddressUnitNo NVARCHAR(4000),LocalAddressBuilding NVARCHAR(4000),LocalAddressCountry NVARCHAR(4000),LocalAddressPostalcode NVARCHAR(4000),ErrorRemarks NVARCHAR(MAX))


			--INSERT INTO @BCEntities (EntityName,EntityType,EntityIdentificationType,EntityIdentificationNumber,GSTRegistrationNumber,Customer,CreditTerms,CreditLimit,CustNature,CustCurrency,Vendor,PaymentTerms,
			--VendorType,VenNature,VenCurrency,DefaultCOA,DefaultTaxCode,Email,Phone,LocalAddressBlockHouseNo,LocalAddressStreet,LocalAddressUnitNo,LocalAddressBuilding,LocalAddressCountry,LocalAddressPostalcode,ErrorRemarks) 
			
			--SELECT EntityName,EntityType,EntityIdentificationType,EntityIdentificationNumber,GSTRegistrationNumber,
			--CASE WHEN Customer=1 THEN 'YES' ELSE 'NO' END AS Customer ,  --Bool
			--CreditTerms,CreditLimit,CustNature,CustCurrency,
			--CASE WHEN Vendor=1 THEN 'YES' ELSE 'NO' END AS Vendor ,  --Bool
			--PaymentTerms,VendorType,VenNature,VenCurrency,DefaultCOA,DefaultTaxCode,Email,Phone,
			--LocalAddressBlockHouseNo,LocalAddressStreet,LocalAddressUnitNo,LocalAddressBuilding,LocalAddressCountry,LocalAddressPostalcode,
			--ErrorRemarks 
			--FROM MigrationDBPRD.[Import].[BCEntities]  WHERE TransactionId=@TRANSACTIONID
			--AND ImportStatus=0

			----BEANCONTACT
			--DECLARE  @BCContact TABLE (EntityName NVARCHAR(4000),Salutation NVARCHAR(4000),Name NVARCHAR(4000),DateofBirth NVARCHAR(4000),IdentificationType NVARCHAR(4000),IdentificationNumber NVARCHAR(4000),
			--CountryofResidence NVARCHAR(4000),PersonalEmail NVARCHAR(4000),PersonalPhone NVARCHAR(4000),PersonalLocalAddressBlockHouseNo NVARCHAR(4000),PersonalLocalAddressStreet NVARCHAR(4000),PersonalLocalAddressUnitNo NVARCHAR(4000),PersonalLocalAddressBuilding NVARCHAR(4000),PersonalLocalAddressCountry NVARCHAR(4000),PersonalLocalAddressPostalcode NVARCHAR(4000),
	  --      Designation NVARCHAR(4000),PrimaryContacts Nvarchar(10),EntityEmail NVARCHAR(4000) ,EntityPhone NVARCHAR(4000),EntityLocalAddressBlockHouseNo NVARCHAR(4000),EntityLocalAddressStreet NVARCHAR(4000),EntityLocalAddressUnitNo NVARCHAR(4000),EntityLocalAddresssBuilding NVARCHAR(4000),EntityLocalAddressCountry NVARCHAR(4000),EntityLocalAddressPostalcode NVARCHAR(4000),Remarks NVARCHAR(MAX),CopyCommunicationandAddress Nvarchar(10),ErrorRemarks NVARCHAR(MAX))																											  											

			--INSERT INTO @BCContact (EntityName,Salutation,Name,DateofBirth,IdentificationType,IdentificationNumber,CountryofResidence,PersonalEmail,PersonalPhone,PersonalLocalAddressBlockHouseNo,PersonalLocalAddressStreet,PersonalLocalAddressUnitNo,PersonalLocalAddressBuilding,PersonalLocalAddressCountry,PersonalLocalAddressPostalcode,
			--Designation,PrimaryContacts,EntityEmail,EntityPhone,EntityLocalAddressBlockHouseNo,EntityLocalAddressStreet,EntityLocalAddressUnitNo,EntityLocalAddresssBuilding,EntityLocalAddressCountry,EntityLocalAddressPostalcode,Remarks,CopyCommunicationandAddress,ErrorRemarks)
			
			--SELECT EntityName,Salutation,Name,DateofBirth,IdentificationType,
			--IdentificationNumber,CountryOfResidence,PersonalEmail,PersonalPhone,PersonalLocalAddressBlockHouseNo,PersonalLocalAddressStreet,PersonalLocalAddressUnitNo,PersonalLocalAddressBuilding,PersonalLocalAddressCountry,PersonalLocalAddressPostalcode,Designation,
			--CASE WHEN PrimaryContacts=1 THEN 'YES' ELSE 'NO' END AS PrimaryContacts,  --Bool
			--EntityEmail,EntityPhone,EntityLocalAddressBlockHouseNo,EntityLocalAddressStreet,EntityLocalAddressUnitNo,EntityLocalAddresssBuilding,EntityLocalAddressCountry,EntityLocalAddressPostalcode,
			--Remarks,
			--CASE WHEN CopycommunicationandAddress=1 THEN 'YES' ELSE 'NO' END AS CopycommunicationandAddress,  --Bool
			--ErrorRemarks 
			--FROM MigrationDBPRD.[Import].[BCContact]  WHERE TransactionId=@TRANSACTIONID AND importstatus =0

			
			--SELECT * FROM @BCEntities
			--SELECT * FROM @BCContact
	     END

 ELSE IF(@SCREENNAME='HR Cursor-Employees')
       BEGIN



	       --PERSONAL DEATAILS
	       DECLARE  @PERSONALDETAILS1 TABLE (EmployeeID NVARCHAR(4000),Name NVARCHAR(4000),IdType NVARCHAR(4000),IdNumber NVARCHAR(4000),DateofSPRGranted NVARCHAR(4000),Nationality NVARCHAR(4000),Race NVARCHAR(4000),
		   DateOfBirth NVARCHAR(4000),Age int,Gender NVARCHAR(4000),MaritalStatus NVARCHAR(4000),PassportNumber  NVARCHAR(4000),PassportExpiry NVARCHAR(4000),UserName NVARCHAR(4000),
		   LocalAddress NVARCHAR(MAX),ForeignAddress NVARCHAR(MAX),Email NVARCHAR(4000) ,Mobile NVARCHAR(4000),ErrorRemarks NVARCHAR(MAX))																											  											
	
	       INSERT INTO @PERSONALDETAILS (EmployeeID,Name,IdType,IdNumber,Nationality,Race,DateOfBirth,Age,Gender,MaritalStatus,PassportNumber,PassportExpiry,UserName,
		   LocalAddress,ForeignAddress,Email,Mobile,DateofSPRGranted,ErrorRemarks) SELECT EmployeeId,Name,IdType,IdNumber,Nationality,Race,DateofBirth,Age,Gender,MaritalStatus,PassPortNumber,PassportExpiry,
		   UserName,LocalAddress,Foreignaddress,Email,Mobile,DateofSPRGranted,ErrorRemarks FROM ImportPersonalDetails WHERE TransactionId=@TRANSACTIONID AND importstatus=0



		   --EMPLOYMENT
		   DECLARE  @EMPLOYMENT1 TABLE (EmployeeID NVARCHAR(4000),TypeofEmployment NVARCHAR(4000),EmploymentStartDate NVARCHAR(4000),EmploymentEndDate NVARCHAR(4000),
	       Period NVARCHAR(4000),[Days/Months] int,ConfirmationDate NVARCHAR(4000),ConfirmationRemarks NVARCHAR(MAX),RejoinDate NVARCHAR(4000),EntityName NVARCHAR(4000),
		   Department NVARCHAR(4000),Designation NVARCHAR(4000),Level int,ReportingTo NVARCHAR(4000),EffectiveFrom NVARCHAR(4000),Currency NVARCHAR(4000),MonthlyBasicPay NVARCHAR(4000),
		   ChargeoutRate NVARCHAR(4000),ErrorRemarks NVARCHAR(MAX))

		   INSERT INTO @EMPLOYMENT (EmployeeID,TypeofEmployment,EmploymentStartDate,EmploymentEndDate,Period,[Days/Months],ConfirmationDate,ConfirmationRemarks,RejoinDate,EntityName,
		   Department,Designation,Level,ReportingTo,EffectiveFrom,Currency,MonthlyBasicPay,ChargeoutRate,ErrorRemarks)SELECT E.EmployeeId,E.TypeofEmployment,E.EmploymentStartDate,E.EmploymentEndDate,E.Period,
		   E.[Days/Months],E.ConfirmationDate,E.ConfirmationRemarks,E.RejoinDate,ED.EntityName,ED.Department,ED.Designation,ED.Level,ED.ReportingTo,ED.EffectiveFrom,ED.Currency,ED.MonthlyBasicPay,
		   ED.ChargeOutRate,concat(E.ErrorRemarks,ED.ErrorRemarks) FROM ImportEmployment E JOIN ImportEmployeeDepartment ED ON E.EmployeeId=ED.EmployeeId WHERE E.TransactionId=@TRANSACTIONID and ED.TransactionId=@TRANSACTIONID and  (ED.ImportStatus=0 or E.ImportStatus=0 )



		   --QUALIFICATION
		   DECLARE  @QUALIFICATION1 TABLE (EmployeeId NVARCHAR(4000),Type NVARCHAR(4000),Qualification NVARCHAR(4000),Institution NVARCHAR(4000),StartDate NVARCHAR(4000),EndDate NVARCHAR(4000),Attachments NVARCHAR(MAX),ErrorRemarks NVARCHAR(MAX))	

		   INSERT INTO @QUALIFICATION (EmployeeId,Type,Qualification,Institution,StartDate,EndDate,Attachments,ErrorRemarks) SELECT EmployeeId,Type,Qualification,Institution,StartDate,EndDate,Attachments,ErrorRemarks FROM ImportQualification
		   WHERE TransactionId=@TRANSACTIONID AND importstatus=0




		   --FAMILY
		   DECLARE  @FAMILY1 TABLE (EmployeeId NVARCHAR(4000),Name NVARCHAR(4000),Relation NVARCHAR(4000),Nationality NVARCHAR(4000),IDNo NVARCHAR(4000),DateOfBirth NVARCHAR(4000),Age int,ContactNo NVARCHAR(4000),[NameofEmployer/School]  NVARCHAR(4000),EmergencyContact bit,ErrorRemarks NVARCHAR(MAX))
		   
		   INSERT INTO @FAMILY(EmployeeId,Name,Relation,Nationality,IDNo,DateOfBirth,Age,ContactNo,[NameofEmployer/School],EmergencyContact,ErrorRemarks) SELECT EmployeeId,Name,Relation,Nationality,IDNo,DateofBirth,Age,ContactNo,
		   [NameofEmployer/School],EmergencyContact,ErrorRemarks FROM ImportFamily WHERE TransactionId=@TRANSACTIONID AND  importstatus=0


		   SELECT * FROM @PERSONALDETAILS1
		   SELECT * FROM @EMPLOYMENT1
		   SELECT * FROM @QUALIFICATION1
		   SELECT * FROM @FAMILY1 





	  --     --PERSONAL DEATAILS
	  --     DECLARE  @HRPersonalDetails TABLE (EmployeeID NVARCHAR(4000),Name NVARCHAR(4000),IdType NVARCHAR(4000),IdNumber NVARCHAR(4000),DateofSPRGranted NVARCHAR(4000),Nationality NVARCHAR(4000),Race NVARCHAR(4000),
		 --  DateOfBirth NVARCHAR(4000),Age int,Gender NVARCHAR(4000),MaritalStatus NVARCHAR(4000),PassportNumber  NVARCHAR(4000),PassportExpiry NVARCHAR(4000),UserName NVARCHAR(4000),
		 --  LocalAddressBlockHouseNo NVARCHAR(4000),LocalAddressStreet NVARCHAR(4000),LocalAddressUnitNo NVARCHAR(4000),LocalAddressBuilding NVARCHAR(4000),LocalAddressCountry NVARCHAR(4000),LocalAddressPostalcode NVARCHAR(4000),Email NVARCHAR(4000) ,Mobile NVARCHAR(4000),ErrorRemarks NVARCHAR(MAX))																											  											
	
	  --     INSERT INTO @HRPersonalDetails (EmployeeID,Name,IdType,IdNumber,Nationality,Race,DateOfBirth,Age,Gender,MaritalStatus,PassportNumber,PassportExpiry,UserName,
		 --  LocalAddressBlockHouseNo,LocalAddressStreet,LocalAddressUnitNo,LocalAddressBuilding,LocalAddressCountry,LocalAddressPostalcode,Email,Mobile,DateofSPRGranted,ErrorRemarks) 
		   
		 --  SELECT EmployeeId,Name,IdType,IdNumber,Nationality,Race,DateofBirth,Age,Gender,MaritalStatus,PassPortNumber,PassportExpiry,
		 --  UserName,LocalAddressBlockHouseNo,LocalAddressStreet,LocalAddressUnitNo,LocalAddressBuilding,LocalAddressCountry,LocalAddressPostalcode,Email,Mobile,DateofSPRGranted,ErrorRemarks 
		 --  FROM MigrationDBPRD.[Import].[HRPersonalDetails] WHERE TransactionId=@TRANSACTIONID AND importstatus=0
		 --  GROUP BY EmployeeId,Name,IdType,IdNumber,Nationality,Race,DateofBirth,Age,Gender,MaritalStatus,PassPortNumber,PassportExpiry,
		 --  UserName,LocalAddressBlockHouseNo,LocalAddressStreet,LocalAddressUnitNo,LocalAddressBuilding,LocalAddressCountry,LocalAddressPostalcode,Email,Mobile,DateofSPRGranted,ErrorRemarks 
		   

		 --  --EMPLOYMENT
		 --  DECLARE  @HREmployeeEmploymentDepartment TABLE (EmployeeID NVARCHAR(4000),TypeofEmployment NVARCHAR(4000),EmploymentStartDate NVARCHAR(4000),EmploymentEndDate NVARCHAR(4000),
	  --     Period NVARCHAR(4000),[Days/Months] int,ConfirmationDate NVARCHAR(4000),ConfirmationRemarks NVARCHAR(MAX),RejoinDate NVARCHAR(4000),EntityName NVARCHAR(4000),
		 --  Department NVARCHAR(4000),Designation NVARCHAR(4000),Level int,ReportingTo NVARCHAR(4000),EffectiveFrom NVARCHAR(4000),Currency NVARCHAR(4000),MonthlyBasicPay NVARCHAR(4000),
		 --  ChargeoutRate NVARCHAR(4000),EffectiveTo NVARCHAR(4000), ErrorRemarks NVARCHAR(MAX))

		 --  INSERT INTO @HREmployeeEmploymentDepartment (EmployeeID,TypeofEmployment,EmploymentStartDate,EmploymentEndDate,Period,[Days/Months],ConfirmationDate,ConfirmationRemarks,RejoinDate,EntityName,
		 --  Department,Designation,Level,ReportingTo,EffectiveFrom,Currency,MonthlyBasicPay,ChargeoutRate, EffectiveTo, ErrorRemarks)
		   
		 --  SELECT E.EmployeeId,E.TypeofEmployment,E.EmploymentStartDate,E.EmploymentEndDate,E.Period,
		 --  E.[Days/Months],E.ConfirmationDate,E.ConfirmationRemarks,E.RejoinDate,ED.EntityName,ED.Department,ED.Designation,ED.Level,ED.ReportingTo,ED.EffectiveFrom,ED.Currency,ED.MonthlyBasicPay,
		 --  ED.ChargeOutRate, ED.EffectiveTo,concat(E.ErrorRemarks,ED.ErrorRemarks) 
		 --  FROM MigrationDBPRD.[Import].[HREmployment] E JOIN MigrationDBPRD.[Import].[HREmployeeDepartment] ED ON E.EmployeeId=ED.EmployeeId WHERE E.TransactionId=@TRANSACTIONID and ED.TransactionId=@TRANSACTIONID and  (ED.ImportStatus=0 or E.ImportStatus=0 )
		 --  GROUP BY  E.EmployeeId,E.TypeofEmployment,E.EmploymentStartDate,E.EmploymentEndDate,E.Period,
		 --  E.[Days/Months],E.ConfirmationDate,E.ConfirmationRemarks,E.RejoinDate,ED.EntityName,ED.Department,ED.Designation,ED.Level,ED.ReportingTo,ED.EffectiveFrom,ED.Currency,ED.MonthlyBasicPay,
		 --  ED.ChargeOutRate, ED.EffectiveTo,concat(E.ErrorRemarks,ED.ErrorRemarks) 
	

		 --  --QUALIFICATION
		 --  DECLARE  @HRQualification TABLE (EmployeeId NVARCHAR(4000),Type NVARCHAR(4000),Qualification NVARCHAR(4000),Institution NVARCHAR(4000),StartDate NVARCHAR(4000),EndDate NVARCHAR(4000),Attachments NVARCHAR(MAX),ErrorRemarks NVARCHAR(MAX))	

		 --  INSERT INTO @HRQualification (EmployeeId,Type,Qualification,Institution,StartDate,EndDate,Attachments,ErrorRemarks)
		 --  SELECT EmployeeId,Type,Qualification,Institution,StartDate,EndDate,Attachments,ErrorRemarks 
		 --  FROM MigrationDBPRD.[Import].[HRQualification] 
		 --  WHERE TransactionId=@TRANSACTIONID AND importstatus=0 GROUP BY EmployeeId,Type,Qualification,Institution,StartDate,EndDate,Attachments,ErrorRemarks 




		 --  --FAMILY
		 --  DECLARE  @HRFamily TABLE (EmployeeId NVARCHAR(4000),Name NVARCHAR(4000),Relation NVARCHAR(4000),Nationality NVARCHAR(4000),IDNo NVARCHAR(4000),DateOfBirth NVARCHAR(4000),Age int,ContactNo NVARCHAR(4000),[NameofEmployer/School]  NVARCHAR(4000),EmergencyContact bit,ErrorRemarks NVARCHAR(MAX))
		   
		 --  INSERT INTO @HRFamily(EmployeeId,Name,Relation,Nationality,IDNo,DateOfBirth,Age,ContactNo,[NameofEmployer/School],EmergencyContact,ErrorRemarks) 
		 --  SELECT EmployeeId,Name,Relation,Nationality,IDNo,DateofBirth,Age,ContactNo,
		 --  [NameofEmployer/School],EmergencyContact,ErrorRemarks FROM MigrationDBPRD.[Import].[HRFamily]  
		 --  WHERE TransactionId=@TRANSACTIONID AND  importstatus=0 GROUP BY EmployeeId,Name,Relation,Nationality,IDNo,DateofBirth,Age,ContactNo,
		 --  [NameofEmployer/School],EmergencyContact,ErrorRemarks


		 ----  --=========================================== NEW CHANGES=============================================================
			----select PD.EmployeeId,PD.Name,PD.IdType,PD.IDNumber,PD.DateofSPRGranted,PD.Nationality,PD.Race,PD.DateofBirth,PD.Gender,PD.MaritalStatus,PD.PassportNumber,PD.PassportExpiry,PD.Username,PD.LocalAddressBlockHouseNo AS [LocalAddressBlock/HouseNo],PD.LocalAddressStreet,PD.LocalAddressUnitNo,PD.LocalAddressBuilding,PD.LocalAddressCountry,PD.LocalAddressPostalcode,PD.Email,PD.Mobile,
			
			----HED.TypeofEmployment,HED.EmploymentStartDate,HED.EmploymentEndDate,HED.Period AS EmploymentPeriod,HED.[Days/Months] AS [EmploymentDays/Months],HED.ConfirmationDate AS EmploymentConfirmationDate,HED.ConfirmationRemarks AS EmploymentConfirmationRemarks,HED.RejoinDate AS EmploymentRejoinDate,HED.EntityName,HED.Department AS EmploymentDepartment,HED.Designation AS EmploymentDesignation,HED.Level AS EmployentLevel,HED.ReportingTo AS EmploymentReportingTo,HED.EffectiveFrom AS EmploymentEffectiveFrom,HED.EffectiveTo AS EmploymentEffectiveTo,HED.Currency AS EmploymentCurrency,HED.MonthlyBasicPay AS EmploymentMonthlyBasicPay,
	  ----      HED.ChargeoutRate AS [EmploymentChargeoutRate(Per hour)],

			----Q.Type AS QualificationType,Q.Qualification,Q.Institution AS QualificationInstitution,Q.StartDate AS QualificationStartDate,Q.EndDate AS QualificationEndDate,
			
			----F.Name AS FamilyName,F.Relation AS FamilyRelation,F.Nationality AS FamilyNationality,F.IDNo AS FamilyIDNo,F.DateOfBirth AS FamilyDateOfBirth,F.ContactNo AS FamilyContactNo,F.[NameofEmployer/School] AS [FamilyNameofEmployer/School],F.EmergencyContact AS FamilyEmergencyContact,
			----PD.ErrorRemarks,HED.ErrorRemarks AS [EmploymentDepartment ErrorRemarks],Q.ErrorRemarks AS [Qualification ErrorRemarks],F.ErrorRemarks AS [Family ErrorRemarks]
			----FROM @HRPersonalDetails PD
			----left join @HREmployeeEmploymentDepartment HED on PD.EmployeeID = HED.EmployeeID
			----left join @HRQualification Q on Q.EmployeeID = HED.EmployeeID
			----left join @HRFamily F on F.EmployeeID = HED.EmployeeID

			
			--	DELETE FROM MigrationDBPRD.[Import].[HREmployee_ErrorRecords]  where TransactionId <>@TRANSACTIONID

			--	update A set A.ErrorRemarks=B. ErrorRemarks,A.importstatus=0 
			--	FROM MigrationDBPRD.[Import].[HREmployee_ErrorRecords] A
			--	INNER JOIN @HRPersonalDetails B ON B.EmployeeId=A.EmployeeId 
			--	where A.TransactionId =@TRANSACTIONID

			--	update A set A.[EmploymentDepartment ErrorRemarks]=B. ErrorRemarks ,A.importstatus=0 
			--	FROM MigrationDBPRD.[Import].[HREmployee_ErrorRecords] A
			--	INNER JOIN @HREmployeeEmploymentDepartment B ON B.EmployeeId=A.EmployeeId 
			--	where A.TransactionId =@TRANSACTIONID

			--	update A set A.[Qualification ErrorRemarks]=B. ErrorRemarks ,A.importstatus=0 
			--	FROM MigrationDBPRD.[Import].[HREmployee_ErrorRecords] A
			--	INNER JOIN @HRQualification B ON B.EmployeeId=A.EmployeeId 
			--	where A.TransactionId =@TRANSACTIONID

			--	update A set A.[Family ErrorRemarks]=B. ErrorRemarks ,A.importstatus=0 
			--	FROM MigrationDBPRD.[Import].[HREmployee_ErrorRecords] A
			--	INNER JOIN @HRFamily B ON B.EmployeeId=A.EmployeeId 
			--	where A.TransactionId =@TRANSACTIONID

			--DELETE FROM MigrationDBPRD.[Import].[HREmployee_ErrorRecords] WHERE TransactionId =@TRANSACTIONID AND importstatus IS NULL   

			--SELECT EmployeeId ,	Name ,IdType ,IDNumber ,DateofSPRGranted ,Nationality	,Race ,DateofBirth ,Gender ,MaritalStatus ,PassportNumber ,PassportExpiry ,
   --         Username ,[LocalAddressBlock/HouseNo] ,	LocalAddressStreet ,LocalAddressUnitNo ,LocalAddressBuilding ,LocalAddressCountry	,LocalAddressPostalcode	,
   --         Email ,Mobile ,	TypeofEmployment ,EmploymentStartDate	,EmploymentEndDate ,EmploymentPeriod ,[EmploymentDays/Months] ,EmploymentConfirmationDate ,EmploymentConfirmationRemarks ,
   --         EmploymentRejoinDate ,EntityName ,EmploymentDepartment ,EmploymentDesignation ,EmployentLevel ,EmploymentReportingTo ,	EmploymentEffectiveFrom ,
   --         EmploymentEffectiveTo ,EmploymentCurrency ,	EmploymentMonthlyBasicPay ,	[EmploymentChargeoutRate(Per hour)] ,QualificationType ,
   --         Qualification ,	QualificationInstitution ,QualificationStartDate ,QualificationEndDate ,FamilyName ,FamilyRelation ,FamilyNationality ,FamilyIDNo ,
   --         FamilyDateOfBirth ,FamilyContactNo ,[FamilyNameofEmployer/School] ,FamilyEmergencyContact ,ErrorRemarks ,[EmploymentDepartment ErrorRemarks] ,[Qualification ErrorRemarks] ,[Family ErrorRemarks] 
   --         FROM MigrationDBPRD.[Import].[HREmployee_ErrorRecords] where TransactionId =@TRANSACTIONID AND importstatus=0 
			--GROUP BY EmployeeId ,	Name ,IdType ,IDNumber ,DateofSPRGranted ,Nationality	,Race ,DateofBirth ,Gender ,MaritalStatus ,PassportNumber ,PassportExpiry ,
   --         Username ,[LocalAddressBlock/HouseNo] ,	LocalAddressStreet ,LocalAddressUnitNo ,LocalAddressBuilding ,LocalAddressCountry	,LocalAddressPostalcode	,
   --         Email ,Mobile ,	TypeofEmployment ,EmploymentStartDate	,EmploymentEndDate ,EmploymentPeriod ,[EmploymentDays/Months] ,EmploymentConfirmationDate ,EmploymentConfirmationRemarks ,
   --         EmploymentRejoinDate ,EntityName ,EmploymentDepartment ,EmploymentDesignation ,EmployentLevel ,EmploymentReportingTo ,	EmploymentEffectiveFrom ,
   --         EmploymentEffectiveTo ,EmploymentCurrency ,	EmploymentMonthlyBasicPay ,	[EmploymentChargeoutRate(Per hour)] ,QualificationType ,
   --         Qualification ,	QualificationInstitution ,QualificationStartDate ,QualificationEndDate ,FamilyName ,FamilyRelation ,FamilyNationality ,FamilyIDNo ,
   --         FamilyDateOfBirth ,FamilyContactNo ,[FamilyNameofEmployer/School] ,FamilyEmergencyContact ,ErrorRemarks ,[EmploymentDepartment ErrorRemarks] ,[Qualification ErrorRemarks] ,[Family ErrorRemarks] 
           



--==================================== OLD ==============================
		   --SELECT * FROM @HRPersonalDetails
		   --SELECT * FROM @HREmployeeEmploymentDepartment
		   --SELECT * FROM @HRQualification
		   --SELECT * FROM @HRFamily 

	   END
ELSE IF(@SCREENNAME='BR Cursor-Entity')
	BEGIN
		DECLARE  @BREntityDetails TABLE (Source NVARCHAR(4000),[Entity Name] NVARCHAR(4000),[Company Type] NVARCHAR(4000),Suffix NVARCHAR(4000),EntityIncharge NVARCHAR(4000),EntityType NVARCHAR(4000),Jurisdiction NVARCHAR(4000),
		   RegistrationNo NVARCHAR(4000),IncorporationDate NVARCHAR(4000),TakeoverDate NVARCHAR(4000),FormerNameifany NVARCHAR(4000),Email  NVARCHAR(4000),Phone NVARCHAR(4000),Communacation NVARCHAR(4000),
		   LastFYE NVARCHAR(MAX),FirstAGM NVARCHAR(MAX),LastAGM NVARCHAR(4000) ,CurrentFYE NVARCHAR(4000),CurrentYear NVARCHAR(MAX),AGMDate NVARCHAR(MAX),ARDate NVARCHAR(MAX),AddressType NVARCHAR(4000) ,LocalAddress NVARCHAR(4000),
		   [Block/HouseNo] NVARCHAR(MAX),Street NVARCHAR(MAX),Unitno NVARCHAR(MAX),Building NVARCHAR(4000) ,Country NVARCHAR(4000),PostalCode NVARCHAR(MAX),PSSICCode NVARCHAR(4000),PrimaryActivity NVARCHAR(4000),PrimaryActitvityDescription NVARCHAR(MAX),
		   [SSSIC Code] NVARCHAR(4000),[Secondary Activity] NVARCHAR(4000),[Secondary Activty Description] NVARCHAR(MAX),ErrorRemarks NVARCHAR(MAX))																											  											
	
		INSERT INTO @BREntityDetails (Source,[Entity Name],[Company Type],Suffix,EntityIncharge,EntityType,Jurisdiction,RegistrationNo,IncorporationDate,TakeoverDate,FormerNameifany,Email,Phone,
		   Communacation,LastFYE,FirstAGM,LastAGM,CurrentFYE,CurrentYear,AGMDate,ARDate,AddressType,LocalAddress,[Block/HouseNo],Street,Unitno,Building,Country,PostalCode,
		   PSSICCode,PrimaryActivity,PrimaryActitvityDescription,[SSSIC Code],[Secondary Activity],[Secondary Activty Description],ErrorRemarks) 
		   SELECT Source,[Entity Name],[Company Type],Suffix,[Entity Incharge],[Entity Type],Jurisdiction,[Registration No],IncorporationDate,[Takeover Date],[Former Name if any],Email,Phone,
		   Communacation,[Last FYE],[First AGM],[Last AGM],[Current FYE],[Current Year],[AGM Date],[AR Date],[Address Type],[Local Address],[Block/House No],Street,[Unit no],Building,Country,[Postal Code],
		   [PSSIC Code],[Primary Activity],[Primary Actitvity Description],[SSSIC Code],[Secondary Activity],[Secondary Activty Description],ErrorRemarks FROM MigrationDBPRD.[Import].[BRFailureEnity] WHERE TransactionId=@TRANSACTIONID AND importstatus=0

		SELECT * FROM @BREntityDetails
	END
	   
 ELSE IF(@SCREENNAME='BR Cursor-Contact')
	BEGIN
	DECLARE  @BREntityContacts TABLE (NominatedByid NVARCHAR(4000),[Entity Name] NVARCHAR(4000),[Registration No] NVARCHAR(4000),Category NVARCHAR(4000),Signatory NVARCHAR(4000),Salutation NVARCHAR(4000),Name NVARCHAR(4000),
		   [ID Number/UEN] NVARCHAR(4000),[ID Type] NVARCHAR(4000),[Passport Expiry (dd/mm/yyyy)] NVARCHAR(4000),Nationality NVARCHAR(4000),[Date of Birth (dd/mm/yyyy)]  NVARCHAR(4000),[Country of Residence] NVARCHAR(4000),[Country of Incorporation] NVARCHAR(4000), [Company Type] NVARCHAR(MAX),[Former Name] NVARCHAR(MAX),[Date of Incorporation (dd/mm/yyyy)] NVARCHAR(4000) ,Position NVARCHAR(4000),Nominee NVARCHAR(MAX),Nominators NVARCHAR(MAX),[DateOfNomination (dd/mm/yyyy)] NVARCHAR(MAX),[Nominators DateOfEntry(dd/MM/YYYY)] NVARCHAR(4000) ,[Appointment Date (dd/mm/yyyy)] NVARCHAR(4000),
		   [Cessation Date  (dd/mm/yyyy)] NVARCHAR(MAX),[Reason for Cessation] NVARCHAR(MAX),IsRegistrableController NVARCHAR(MAX),IsSignificantInterest NVARCHAR(4000) ,IsSignificantControl NVARCHAR(4000),DateofEntry NVARCHAR(MAX),[Legal Form] NVARCHAR(MAX),[Governing Jurisdiction Law] NVARCHAR(4000),[Register of Companies of the Jurisdiction] NVARCHAR(4000),Email NVARCHAR(MAX),[Phone No] NVARCHAR(MAX),[Address Type] NVARCHAR(4000),[Local Address] NVARCHAR(4000),[Block/House No] NVARCHAR(4000),[Unit no] NVARCHAR(4000),Street NVARCHAR(4000),Building NVARCHAR(4000),Country NVARCHAR(4000),[Postal Code] NVARCHAR(4000),ErrorRemarks NVARCHAR(max))																											  											
	
		INSERT INTO @BREntityContacts (NominatedByid,[Entity Name],[Registration No],Category,Signatory,Salutation,Name,[ID Number/UEN],[ID Type],[Passport Expiry (dd/mm/yyyy)],Nationality,[Date of Birth (dd/mm/yyyy)],[Country of Residence],[Country of Incorporation],[Company Type],[Former Name],[Date of Incorporation (dd/mm/yyyy)],Position,Nominee,Nominators,[DateOfNomination (dd/mm/yyyy)],[Nominators DateOfEntry(dd/MM/YYYY)],[Appointment Date (dd/mm/yyyy)],[Cessation Date  (dd/mm/yyyy)],[Reason for Cessation],IsRegistrableController,IsSignificantInterest,IsSignificantControl,DateofEntry,[Legal Form],[Governing Jurisdiction Law],[Register of Companies of the Jurisdiction],Email,[Phone No],[Address Type],[Local Address],[Block/House No],[Unit no],Street,Building,Country,[Postal Code],ErrorRemarks) 
		   SELECT NominatedByid,[Entity Name],[Registration No],Category,Signatory,Salutation,Name,[ID Number/UEN],[ID Type],[Passport Expiry (dd/mm/yyyy)],Nationality,[Date of Birth (dd/mm/yyyy)],[Country of Residence],[Country of Incorporation],[Company Type],[Former Name],[Date of Incorporation (dd/mm/yyyy)],Position,Nominee,Nominators,[DateOfNomination (dd/mm/yyyy)],[Nominators DateOfEntry(dd/MM/YYYY)],[Appointment Date (dd/mm/yyyy)],[Cessation Date  (dd/mm/yyyy)],[Reason for Cessation],IsRegistrableController,IsSignificantInterest,IsSignificantControl,DateofEntry,[Legal Form],[Governing Jurisdiction Law],[Register of Companies of the Jurisdiction],Email,[Phone No],[Address Type],[Local Address],[Block/House No],[Unit no],Street,Building,Country,[Postal Code],ErrorRemarks
		   FROM MigrationDBPRD.[Import].[BRFailureEnityContact] WHERE TransactionId=@TRANSACTIONID AND importstatus=0

		select * from @BREntityContacts

	END

  ELSE IF(@SCREENNAME='BR Cursor-Shares')
	BEGIN
	DECLARE  @BREntityshares TABLE ([Entity Name] NVARCHAR(4000),[Registration No] NVARCHAR(4000),Category NVARCHAR(4000),Position NVARCHAR(4000),Name NVARCHAR(4000),UEN NVARCHAR(4000),[Transaction Date] NVARCHAR(4000),[Transaction Type] NVARCHAR(4000),ShareType NVARCHAR(4000),ShareClass NVARCHAR(4000),Currency NVARCHAR(4000),ShareDescription  NVARCHAR(4000),mode NVARCHAR(4000),Nature NVARCHAR(4000), [Shares held in trust] NVARCHAR(MAX),[Name of the trust] NVARCHAR(MAX),NumberOfShares NVARCHAR(4000) ,Issued NVARCHAR(4000),[Paid Up] NVARCHAR(MAX),[Certificate No] NVARCHAR(MAX),Remarks NVARCHAR(MAX),Toatalbalance NVARCHAR(4000) ,ErrorRemarks NVARCHAR(max))																											  											
	
		INSERT INTO @BREntityshares ([Entity Name],[Registration No],Category,Position,Name,UEN,[Transaction Date],[Transaction Type],ShareType,ShareClass,Currency,ShareDescription,mode,Nature,[Shares held in trust],[Name of the trust],NumberOfShares,Issued,[Paid Up],[Certificate No],Remarks,Toatalbalance,ErrorRemarks) 
		   SELECT [Entity Name],[Registration No],Category,Position,Name,UEN,[Transaction Date],[Transaction Type],ShareType,ShareClass,Currency,ShareDescription,mode,Nature,[Shares held in trust],[Name of the trust],NumberOfShares,Issued,[Paid Up],[Certificate No],Remarks,Toatalbalance,ErrorRemarks
		   FROM MigrationDBPRD.[Import].[BRFailureEntityShare] WHERE TransactionId=@TRANSACTIONID AND importstatus=0

		select * from @BREntityshares

	END


		  ELSE IF(@SCREENNAME='Admin Cursor-Users')
	BEGIN
	--DECLARE  @BREntityshares TABLE ([Entity Name] NVARCHAR(4000),[Registration No] NVARCHAR(4000),Category NVARCHAR(4000),Position NVARCHAR(4000),Name NVARCHAR(4000),UEN NVARCHAR(4000),[Transaction Date] NVARCHAR(4000),[Transaction Type] NVARCHAR(4000),ShareType NVARCHAR(4000),ShareClass NVARCHAR(4000),Currency NVARCHAR(4000),ShareDescription  NVARCHAR(4000),mode NVARCHAR(4000),Nature NVARCHAR(4000), [Shares held in trust] NVARCHAR(MAX),[Name of the trust] NVARCHAR(MAX),NumberOfShares NVARCHAR(4000) ,Issued NVARCHAR(4000),[Paid Up] NVARCHAR(MAX),[Certificate No] NVARCHAR(MAX),Remarks NVARCHAR(MAX),Toatalbalance NVARCHAR(4000) ,ErrorRemarks NVARCHAR(max))																											  											
select B.Salutation,B.UserFullName,B.UserName,B.ShortCode,B.ServiceEntities,B.Role1,B.Role2,B.Role3,B.Role4,B.Role5,B.Role6,B.Role7,B.Role8,B.Role9,B.Role10,B.ValidationMessage 
from MigrationDBPRD.Import.FailureUsers B
--INNER JOIN MigrationDBPRD.Import.Users B ON B.Id=A.UserId
WHERE B.TransactionId=@TRANSACTIONID  AND B.ValidationMessage IS NOT NULL 

	END

--	  ELSE IF(@SCREENNAME='Admin-users')
--	BEGIN
--	--DECLARE  @BREntityshares TABLE ([Entity Name] NVARCHAR(4000),[Registration No] NVARCHAR(4000),Category NVARCHAR(4000),Position NVARCHAR(4000),Name NVARCHAR(4000),UEN NVARCHAR(4000),[Transaction Date] NVARCHAR(4000),[Transaction Type] NVARCHAR(4000),ShareType NVARCHAR(4000),ShareClass NVARCHAR(4000),Currency NVARCHAR(4000),ShareDescription  NVARCHAR(4000),mode NVARCHAR(4000),Nature NVARCHAR(4000), [Shares held in trust] NVARCHAR(MAX),[Name of the trust] NVARCHAR(MAX),NumberOfShares NVARCHAR(4000) ,Issued NVARCHAR(4000),[Paid Up] NVARCHAR(MAX),[Certificate No] NVARCHAR(MAX),Remarks NVARCHAR(MAX),Toatalbalance NVARCHAR(4000) ,ErrorRemarks NVARCHAR(max))																											  											
--select B.Salutation,B.UserFullName,B.UserName,B.ShortCode,B.ServiceEntities,B.Role1,B.Role2,B.Role3,B.Role4,B.Role5,B.Role6,B.Role7,B.Role8,B.Role9,B.Role10,A.ValidationMessage 
--from MigrationDBPRD.Import.FailureUsers A
--INNER JOIN MigrationDBPRD.Import.Users B ON B.Id=A.UserId
--WHERE A.TransactionId=@TRANSACTIONID AND B.TransactionId=@TRANSACTIONID

--	END


END 

--=====================================================================================================================


END


--exec [dbo].[SP_TABLETOEXCELTRANSACTIONS] '733d3516-433d-46dd-b241-7a3582c8b6cb','Client Cursor-Accounts'


GO
