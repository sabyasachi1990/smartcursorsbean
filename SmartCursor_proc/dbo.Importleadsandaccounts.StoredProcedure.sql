USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Importleadsandaccounts]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












CREATE Procedure  [dbo].[Importleadsandaccounts]  
--exec [dbo].[Importleadsandaccounts] 583,'6DAC014A-69CF-411D-9616-B0B1B124EDD3'
@companyId int,
@TransactionId uniqueidentifier
AS
BEGIN 
 Declare
  --@companyId int=809,
 --@TransactionId uniqueidentifier='6DAC014A-69CF-411D-9616-B0B1B124EDD3',
 @AccountId nvarchar (max),
 @AccountType nvarchar(max),
 @IdType nvarchar(max),
 @CreditTerms nvarchar(max),
 @Secretary nvarchar(max),
 @AccountTypeId bigint,
 @IdTypeId bigint,
 @CreditTermsId bigint,
 @SecretaryId uniqueidentifier,
 @COMMN Nvarchar(max),
 @SourceId Varchar(100),
 @Source Nvarchar(max),
 @SourceType varchar(100),
 @Jsondata  Nvarchar(max),
 @EmailJson Nvarchar(max),
 @MobileJson Nvarchar(max),
 @Id uniqueidentifier,
 @Name nvarchar (max),
 @IdImp uniqueidentifier,
 @LocalAddress Nvarchar(Max),
 @ForigenAddress Nvarchar(Max)
   --Begin Transaction  
 ---Begin Try  
 --===========================ClientCursor.Account Table column lengths=========================================
 Declare @LAccountId  bigint=COL_LENGTH('ClientCursor.Account', 'AccountId') 
 Declare @LName bigint=COL_LENGTH('ClientCursor.Account', 'Name')
 Declare @LSource bigint=COL_LENGTH('ClientCursor.Account', 'Source')
 Declare @LSourceName bigint=COL_LENGTH('ClientCursor.Account', 'SourceName')
 Declare @LIndustry bigint=COL_LENGTH('ClientCursor.Account', 'Industry     ')
 Declare @LPrincipalActivities bigint=COL_LENGTH('ClientCursor.Account', 'PrincipalActivities')
 Declare @LCountryOfIncorporation bigint=COL_LENGTH('ClientCursor.Account', 'CountryOfIncorporation')
 Declare @LAccountIdNo bigint=COL_LENGTH('ClientCursor.Account', 'AccountIdNo')
 Declare @LCommunication bigint=COL_LENGTH('ClientCursor.Account', 'Communication')
 --===========================Common.Contact and Common.AddressBook Table column lengths=========================================
 Declare @LcFirstName bigint=COL_LENGTH('Common.Contact', 'FirstName')
 Declare @LcIdentificationNumber bigint=COL_LENGTH('Common.Contact', 'IdNo')
 Declare @LcCountryOfResidence bigint=COL_LENGTH('Common.Contact', 'CountryOfResidence')
 Declare @LcRemarks bigint=COL_LENGTH('Common.Contact', 'Remarks')
 Declare @LcDesignation bigint=COL_LENGTH('Common.ContactDetails ', 'Designation')
 Declare @LcCommunication bigint=COL_LENGTH('Common.ContactDetails ', 'Communication')
 Declare @LcBlockHouseNo bigint=COL_LENGTH('Common.AddressBook  ', 'BlockHouseNo')
 Declare @LcStreet bigint=COL_LENGTH('Common.AddressBook  ', 'Street')
 Declare @LcUnitNo bigint=COL_LENGTH('Common.AddressBook  ', 'UnitNo')
 Declare @LcBuildingEstate bigint=COL_LENGTH('Common.AddressBook  ', 'BuildingEstate')
 Declare @LcCity bigint=COL_LENGTH('Common.AddressBook  ', 'City')
 Declare @LcPostalCode bigint=COL_LENGTH('Common.AddressBook  ', 'PostalCode')
 Declare @LcState bigint=COL_LENGTH('Common.AddressBook  ', 'State')
 Declare @LcCountry bigint=COL_LENGTH('Common.AddressBook  ', 'Country')
 Declare @LcPhone bigint=COL_LENGTH('Common.AddressBook  ', 'Phone')
 Declare @LcEmail bigint=COL_LENGTH('Common.AddressBook  ', 'Email')
           --================== Remove comma in Address=======================================
        Update ImportContacts set PersonalLocalAddress = case when charindex(',',PersonalLocalAddress)=1 then SUBSTRING(PersonalLocalAddress,2,len(PersonalLocalAddress))
        else PersonalLocalAddress  end where   TransactionId=@TransactionId AND PersonalLocalAddress IS NOT NULL
        
        Update ImportContacts set PersonalForeignAddress = case when charindex(',',PersonalForeignAddress)=1 then SUBSTRING(PersonalForeignAddress,2,len(PersonalForeignAddress))
        else PersonalForeignAddress  end where   TransactionId=@TransactionId AND PersonalForeignAddress IS NOT NULL
        
        Update ImportContacts set EntityLocalAddress = case when charindex(',',EntityLocalAddress)=1 then SUBSTRING(EntityLocalAddress,2,len(EntityLocalAddress))
        else EntityLocalAddress  end where   TransactionId=@TransactionId AND EntityLocalAddress IS NOT NULL
        
        Update ImportContacts set EntityForeignAddress = case when charindex(',',EntityForeignAddress)=1 then SUBSTRING(EntityForeignAddress,2,len(EntityForeignAddress))
        else EntityForeignAddress  end where   TransactionId=@TransactionId AND EntityForeignAddress IS NOT NULL
        
        update Importleads set LocalAddress=case when charindex(',',LocalAddress)=1 then SUBSTRING(LocalAddress,2,len(LocalAddress))
        else LocalAddress  end  where TransactionId=@TransactionId AND  LocalAddress IS NOT NULL
        
        update Importleads set Foreignaddress=case when charindex(',',Foreignaddress)=1 then SUBSTRING(Foreignaddress,2,len(Foreignaddress))
        else Foreignaddress  end  where TransactionId=@TransactionId AND  Foreignaddress IS NOT NULL
        
        --==================Upadate	FinancialYearEnd null and ReminderRecipient ===========================================  
            
        UPDATE  Importleads set FinancialYearEnd=null
        where  FinancialYearEnd=''  and  TransactionId=@TransactionId
        
        UPDATE A SET A.ReminderRecipient=0 from ImportContacts  A
        INNER JOIN ImportLeads  C ON C.AccountId=A.MasterId
        where A.TransactionId=@TransactionId AND C.TransactionId=@TransactionId
        and RemindersAGM=0 and RemindersECI=0 and RemindersAudit=0 and RemindersFinalTax=0 AND A.ReminderRecipient=1
        
        UPDATE A SET A.ReminderRecipient=0 from ImportContacts  A
        INNER JOIN ImportLeads  C ON C.AccountId=A.MasterId
        where A.TransactionId=@TransactionId AND C.TransactionId=@TransactionId
        and RemindersAGM IS NULL and RemindersECI IS NULL and RemindersAudit IS NULL and RemindersFinalTax IS NULL  AND A.ReminderRecipient=1
        
        UPDATE A SET A.ReminderRecipient=1 from ImportContacts  A
        INNER JOIN ImportLeads  C ON C.AccountId=A.MasterId
        where A.TransactionId=@TransactionId AND C.TransactionId=@TransactionId
        and (RemindersAGM=1 OR RemindersECI=1 OR RemindersAudit=1 OR RemindersFinalTax=1) AND A.ReminderRecipient=0

		--====================== Check lengths Importleads table ====================================================

  	    Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please entered the AccountId Length Less then', CAST(@LAccountId as nvarchar(100)))
        Else CONCAT('Please entered the AccountId Length Less then', CAST(@LAccountId as nvarchar(100))) end, AccountImportStatus=0
		where  TransactionId=@TransactionId  and AccountId is not null AND LEN(AccountId)>@LAccountId

		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please entered the Name Length Less then ', CAST(@LName as nvarchar(100)))
        Else CONCAT('Please entered the Name Length Less then ', CAST(@LName as nvarchar(100))) end, AccountImportStatus=0
		where  TransactionId=@TransactionId and name is not null AND LEN(Name)>@LName

		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please entered the Source Length Less then ', CAST(@LSource as nvarchar(100)))
        Else CONCAT('Please entered the Source Length Less then ', CAST(@LSource as nvarchar(100))) end, AccountImportStatus=0
		where  TransactionId=@TransactionId  and SourceType is not null AND LEN(SourceType)>@LSource

		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please entered the SourceName Length Less then ', CAST(@LSourceName as nvarchar(100)))
        Else CONCAT('Please entered the SourceName Length Less then ', CAST(@LSourceName as nvarchar(100))) end, AccountImportStatus=0
		where  TransactionId=@TransactionId  and [Source/Remarks] is not null  AND LEN([Source/Remarks])>@LSourceName

		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please entered the Industry Length Less then ', CAST(@LIndustry as nvarchar(100)))
        Else CONCAT('Please entered the Industry Length Less then ', CAST(@LIndustry as nvarchar(100))) end, AccountImportStatus=0
		where  TransactionId=@TransactionId  and Industry is not null AND LEN(Industry)>@LIndustry 

		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please entered the PrincipalActivities Length Less then ', CAST(@LPrincipalActivities as nvarchar(100)))
        Else CONCAT('Please entered the PrincipalActivities Length Less then ', CAST(@LPrincipalActivities as nvarchar(100))) end, AccountImportStatus=0
		where  TransactionId=@TransactionId and PrincipalActivities is not null  AND LEN(PrincipalActivities)>@LPrincipalActivities

		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please entered the CountryOfIncorporation Length Less then ', CAST(@LCountryOfIncorporation as nvarchar(100)))
        Else CONCAT('Please entered the CountryOfIncorporation Length Less then ', CAST(@LCountryOfIncorporation as nvarchar(100))) end, AccountImportStatus=0
		where  TransactionId=@TransactionId  and IncorporationCountry is not null AND LEN(IncorporationCountry)>@LCountryOfIncorporation

		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please entered the AccountIdNo Length Less then ', CAST(@LAccountIdNo as nvarchar(100)))
        Else CONCAT('Please entered the AccountIdNo Length Less then ', CAST(@LAccountIdNo as nvarchar(100))) end, AccountImportStatus=0
		where  TransactionId=@TransactionId and IdentificationNumber is not null  AND LEN(IdentificationNumber)>@LAccountIdNo

		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please entered the Phone and Email Length Less then ', CAST(@LCommunication as nvarchar(100)))
        Else CONCAT('Please entered the Phone and Email Length Less then ',CAST(@LCommunication as nvarchar(100))) end, AccountImportStatus=0
		where  TransactionId=@TransactionId  and Phone is not null and Email is not null   AND (LEN(Phone)+ len(Email))>@LCommunication

		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please entered the Phone Length Less then ', CAST(@LCommunication as nvarchar(100)))
        Else CONCAT('Please entered the Phone Length Less then ',CAST(@LCommunication as nvarchar(100))) end, AccountImportStatus=0
		where  TransactionId=@TransactionId  and Phone is not null and Email is null   AND (LEN(Phone))>@LCommunication

	    Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please entered the Email Length Less then ', CAST(@LCommunication as nvarchar(100)))
        Else CONCAT('Please entered the Email Length Less then ',CAST(@LCommunication as nvarchar(100))) end, AccountImportStatus=0
		where  TransactionId=@TransactionId  and Phone is null and Email is not null   AND ( len(Email))>@LCommunication

			--======================  Importleads Validation of  Tables validate and update ImportStatus=0 ====================================================

	    if Exists (select Distinct AccountId from Importleads where AccountId is null  and TransactionId=@TransactionId)
	    begin
		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the AccountId')
        Else 'Please enter the AccountId' end  , AccountImportStatus=0
		where  AccountId is null and TransactionId=@TransactionId
	    end 

        if Exists (select Type from Importleads where Type is null  and TransactionId=@TransactionId)
	    begin
		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the Type')
        Else 'Please enter the Type' end, AccountImportStatus=0
		where  Type is null and TransactionId=@TransactionId
	    end 

	    if Exists (select Name from Importleads where Name is null  and TransactionId=@TransactionId)
	    begin
		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the Name')
        Else 'Please enter the Name' end  , AccountImportStatus=0
		where  Name is null and TransactionId=@TransactionId
	    end 

	    if Exists (select SourceType from Importleads where SourceType is null  and TransactionId=@TransactionId)
	    begin
		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Please enter the SourceType')
        Else 'Please enter the SourceType' end   , AccountImportStatus=0
		where  SourceType is null and TransactionId=@TransactionId
	    end 

	    if Exists (select [Source/Remarks] from Importleads where [Source/Remarks] is null  and TransactionId=@TransactionId)
	    begin
		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Please enter the Source/Remarks')
        Else 'Please enter the Source/Remarks' end , AccountImportStatus=0
		where  [Source/Remarks] is null and SourceType in ('Customer','Referral Partner','Employee','Marketing Campaign') and TransactionId=@TransactionId
	    end 

	    UPDATE  Importleads set AccountErrorRemarks=Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Please enter the   CreditTerms' ) 
        Else 'Please enter the   CreditTerms' end   , AccountImportStatus=0
	    where  CreditTerms is null  and  TransactionId=@TransactionId

	    if Exists (select InchargesinClientCursor from Importleads where InchargesinClientCursor is null  and TransactionId=@TransactionId)
	    begin
		Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Please enter the Account incharge')
        Else 'Please enter the Account incharge' end , AccountImportStatus=0
		where  InchargesinClientCursor is null and TransactionId=@TransactionId
	    end 

	    update Importleads set AccountImportStatus=case when ISNUMERIC(Replace(Replace(Replace(Phone,'+','1'),' ','2'),'-','3'))=0 Then 0 end ,AccountErrorRemarks= Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Phone allows to enter only Numbers') 
        Else 'Phone allows to enter only Numbers' end  
        where TransactionId=@TransactionId and Phone is not null --and (AccountImportStatus<>0 or AccountImportStatus is null)
        and case when ISNUMERIC(Replace(Replace(Replace(Phone,'+','1'),' ','2'),'-','3'))=0 Then 0 end=0

	      ---==============================================03.12.2019
	    Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','AccountId Already Exists Please entered the correct information.') 
	    Else 'AccountId Already Exists Please entered the correct information.' end , AccountImportStatus=0
	    where   TransactionId=@TransactionId  and AccountId is not null  and AccountId  in 
	    (select distinct  AccountId  from ClientCursor.Account where CompanyId=@companyId)

	    Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Name Already Exists Please entered the correct information.')
        Else 'Name Already Exists Please entered the correct information.' end, AccountImportStatus=0
	    where   TransactionId=@TransactionId  and Name is not null  and Name  in 
	    (select distinct  Name  from ClientCursor.Account where CompanyId=@companyId)
	     ---==============================================03.12.2019

	    Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Please enter the Primary Contact') 
        Else 'Please enter the Primary Contact' end , AccountImportStatus=0
	    where  AccountId is not null and TransactionId=@TransactionId  and AccountId  not in 
	    (select Distinct MasterId  from ImportContacts  where TransactionId=@TransactionId and MasterId is not null)

	    --Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Please enter the Primary Contact') 
        --Else 'Please enter the Primary Contact' end , AccountImportStatus=0
	    --where  TransactionId=@TransactionId  and (RemindersAGM=1 or RemindersAudit=1 or RemindersECI=1 or RemindersFinalTax=1) and AccountId in 
	    --(select Distinct MasterId  from ImportContacts  where TransactionId=@TransactionId and (ReminderRecipient=0  or ReminderRecipient is null) and PersonalEmail is null and EntityEmail is null)

         --====================== Check lengths ImportContacts table ====================================================

	    Update c set EntityPhone=PersonalPhone,EntityEmail=PersonalEmail,EntityLocalAddress=PersonalLocalAddress,EntityForeignAddress=PersonalForeignAddress 
	    from ImportContacts C  where   C.TransactionId=@TransactionId and C.CopycommunicationandAddress=1


		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the FirstName Length ', CAST(@LcFirstName as nvarchar(100)))
        Else CONCAT('Please enter the FirstName Length ', CAST(@LcFirstName as nvarchar(100))) end , ImportStatus=0
		where  TransactionId=@TransactionId  and Name is not null  and len(Name)>@LcFirstName 

		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the IdentificationNumber Length ', CAST(@LcIdentificationNumber as nvarchar(100)))
        Else CONCAT('Please enter the IdentificationNumber Length ', CAST(@LcIdentificationNumber as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and IdentificationNumber is not null  and len(IdentificationNumber)>@LcIdentificationNumber

		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the CountryOfResidence Length Less Then ', CAST(@LcCountryOfResidence as nvarchar(100)))
        Else CONCAT('Please enter the CountryOfResidence Length Less Then ', CAST(@LcCountryOfResidence as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and CountryOfResidence is not null  and len(CountryOfResidence)>@LcCountryOfResidence

		Update ImportContacts set ErrorRemarks =Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the Remarks Length Less Then ', CAST(@LcRemarks as nvarchar(100)))
        Else  CONCAT('Please enter the Remarks Length Less Then ', CAST(@LcRemarks as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and Remarks is not null  and len(Remarks)>@LcRemarks


		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the EntityDesignation Length Less Then ', CAST(@LcDesignation as nvarchar(100)))
        Else  CONCAT('Please enter the EntityDesignation Length Less Then ', CAST(@LcDesignation as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityDesignation is not null  and len(EntityDesignation)>@LcDesignation

	    Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the PersonalPhone and PersonalEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the PersonalPhone and PersonalEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and PersonalPhone is not null  and PersonalEmail is not null and (len(PersonalPhone)+len(PersonalEmail))>@LcCommunication

		  Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the CommunicationPersonalPhone Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the CommunicationPersonalPhone Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and PersonalPhone is not null  and PersonalEmail is null and (len(PersonalPhone))>@LcCommunication

		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the CommunicationPersonalEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the CommunicationPersonalEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and PersonalPhone is null  and PersonalEmail is not null and (len(PersonalEmail))>@LcCommunication

		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the EntityPhone and EntityEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the EntityPhone and EntityEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityPhone is not null  and EntityEmail is not null and (len(EntityPhone)+len(EntityEmail))>@LcCommunication

		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the CommunicationEntityPhone Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the CommunicationEntityPhone Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityPhone is not null  and EntityEmail is null and (len(EntityPhone))>@LcCommunication

		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the CommunicationEntityEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the CommunicationEntityEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityPhone is null  and EntityEmail is not null and (len(EntityEmail))>@LcCommunication

		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the PersonalPhone Length Less Then ', CAST(@LcPhone as nvarchar(100)))
        Else  CONCAT('Please enter the PersonalPhone Length Less Then ', CAST(@LcPhone as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and PersonalPhone is not null  and len(PersonalPhone)>@LcPhone

		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the EntityPhone Length Less Then', CAST(@LcPhone as nvarchar(100)))
        Else  CONCAT('Please enter the EntityPhone Length Less Then', CAST(@LcPhone as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityPhone is not null  and len(EntityPhone)>@LcPhone


		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the PersonalEmail Length Less Then ', CAST(@LcEmail as nvarchar(100)))
        Else  CONCAT( 'Please enter the PersonalEmail Length Less Then ', CAST(@LcEmail as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and PersonalEmail is not  null and len(PersonalEmail)>@LcEmail


		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the EntityEmail Length Less Then ',CAST(@LcEmail as nvarchar(100)))
        Else  CONCAT('Please enter the EntityEmail Length Less Then ', CAST(@LcEmail as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and EntityEmail is not null  and len(EntityEmail)>@LcEmail

		---========== ImportContacts Validation of ImportContacts Tables validate and update ImportStatus=0 =============================

	    if Exists (select Name from ImportContacts where Name is null and  TransactionId=@TransactionId)
	    begin
		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the Name')
        Else  'Please enter the Name' end, ImportStatus=0
		where  Name is null and TransactionId=@TransactionId
	    end 

	    if Exists (select MasterId from ImportContacts where MasterId is null  and TransactionId=@TransactionId)
	    begin
		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the MasterId')
        Else  'Please enter the MasterId' end, ImportStatus=0
		where  MasterId is null and TransactionId=@TransactionId
	    end 

	    if Exists (select PrimaryContacts from ImportContacts where PrimaryContacts is null  and TransactionId=@TransactionId)
	    begin
	    Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the PrimaryContact')
        Else  'Please enter the PrimaryContact' end , ImportStatus=0
	    where  PrimaryContacts is null and TransactionId=@TransactionId
	    end 

		if Exists (select ID from ImportContacts where EntityEmail is null and EntityPhone is null and PersonalPhone is null and  PersonalEmail is null  and TransactionId=@TransactionId)
	    begin
		Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the ContactCommunication')
        Else 'Please enter the ContactCommunication' end, ImportStatus=0
		where  EntityEmail is null and EntityPhone is null and PersonalPhone is null and  PersonalEmail is null and TransactionId=@TransactionId
	    end 

	    Update ImportContacts  set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please check Salutation not matched in ControlCode')
        Else 'Please check Salutation not matched in ControlCode' end,ImportStatus=0 
        where  TransactionId=@TransactionId and Salutation is not null ---and (ImportStatus<>0 or ImportStatus is null)
	    and Salutation COLLATE DATABASE_DEFAULT  Not in 
		(
		  select Distinct CodeKey from Common.ControlCode c
		  inner join  Common.ControlCodeCategory cc on c.ControlCategoryId=cc.Id 
		  where CompanyId=@companyId  and CodeKey is not null and ControlCodeCategoryCode='Salutation'
		 )

	    update ImportContacts set ImportStatus=case when ISNUMERIC(Replace(Replace(Replace(PersonalPhone,'+','1'),' ','2'),'-','3'))=0 Then 0 end  ,ErrorRemarks=Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'PersonalPhone allows to enter only Numbers')
        Else 'PersonalPhone allows to enter only Numbers' end   
        where TransactionId=@TransactionId and PersonalPhone is not null --and (ImportStatus<>0 or ImportStatus is null)
        and case when ISNUMERIC(Replace(Replace(Replace(PersonalPhone,'+','1'),' ','2'),'-','3'))=0 Then 0 end=0
	    
	    
        update ImportContacts set ImportStatus=case when ISNUMERIC(Replace(Replace(Replace(EntityPhone,'+','1'),' ','2'),'-','3'))=0 Then 0 end  ,ErrorRemarks=Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'EntityPhone allows to enter only Numbers') 
        Else 'EntityPhone allows to enter only Numbers'end 
        where TransactionId=@TransactionId and EntityPhone is not null 
        and case when ISNUMERIC(Replace(Replace(Replace(EntityPhone,'+','1'),' ','2'),'-','3'))=0 Then 0 end=0
	    
        Update ImportContacts set ErrorRemarks =Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the PersonalEmail or EntityEmail') 
        Else 'Please enter the PersonalEmail or EntityEmail' end , ImportStatus=0
	    where  ReminderRecipient=1 and EntityEmail is null and PersonalEmail is null and TransactionId=@TransactionId

	    Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please entered the correct MasterId')
        Else  'Please entered the correct MasterId' end, ImportStatus=0
		where  MasterId is NOT null and TransactionId=@TransactionId AND MasterId NOT IN 
        (SELECT Distinct AccountId FROM ImportLeads  where  AccountId is not null and TransactionId=@TransactionId)

		Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please entered the ReminderRecipient is Yes')
        Else  'Please entered the ReminderRecipient is true' end, ImportStatus=0
		where  MasterId is NOT null and TransactionId=@TransactionId and (ReminderRecipient=0  or ReminderRecipient is null)  AND MasterId IN 
        (SELECT Distinct AccountId FROM ImportLeads  where  AccountId is not null and TransactionId=@TransactionId and (RemindersAGM=1 or RemindersAudit=1 or RemindersECI=1 or RemindersFinalTax=1) )

        Update ImportContacts set ErrorRemarks = case when charindex(',',ErrorRemarks)=1 then SUBSTRING(ErrorRemarks,2,len(ErrorRemarks))
	    else ErrorRemarks  end, ImportStatus=0 where   TransactionId=@TransactionId AND ErrorRemarks IS NOT NULL

 ---================================================   AccountId_Get Cursor for Impoert leads insert =========================================================		  

  Declare AccountId_Get Cursor For
  SELECT Distinct id,AccountId,AccountType,IdentificationType,CreditTerms,CompanySecretary,[Source/Remarks],SourceType,Name FROM Importleads 
  where  TransactionId=@TransactionId   AND (NAME NOT IN (select distinct  Name  from ClientCursor.Account where CompanyId=@companyId)
  OR AccountId NOT IN (select distinct  AccountId  from ClientCursor.Account where CompanyId=@companyId))
  	   ----and (AccountImportStatus<>0 or AccountImportStatus is null)--- and AccountId not in (select distinct  AccountId  from ClientCursor.Account where CompanyId=@companyId)
  Order by AccountId
  Open AccountId_Get
  fetch next from AccountId_Get Into   @IdImp,@AccountId,@AccountType ,@IdType,@CreditTerms,@Secretary,@Source,@SourceType,@Name
  While @@FETCH_STATUS=0
  BEGIN
	--===================== 03.12.2019
   Begin Transaction  
   Begin Try  
    --==================== 03.12.2019

	--========================================================================= Start Address check length =======================================================

	Select @LocalAddress=LocalAddress,@ForigenAddress=Foreignaddress
	From ImportLeads
	Where   TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and ( LocalAddress is not null or Foreignaddress is not null)

    --================================ LocalAddress in  ClientCursor.Account table=========================================
					 
	If @LocalAddress Is Not Null  
	Begin
		
	 Create Table #Strng_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))
	 
	 Insert Into #Strng_Splt(AddrName)
	 Select Value From string_split(@LocalAddress,',')
	 
	 IF Exists( Select AddrName From #Strng_Splt Where Id=1 AND LEN(AddrName) >@LcBlockHouseNo )
	 begin
	 Update Importleads set AccountErrorRemarks =  Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the LocalAddress BlockHouseNo Length Less then', CAST(@LcBlockHouseNo as nvarchar(100)))
     Else CONCAT('Please enter the BlockHouseNo Length Less then', CAST(@LcBlockHouseNo as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and LocalAddress is not null
	 end
	 				 
	 if Exists (Select AddrName From #Strng_Splt Where Id=2 AND LEN(AddrName) >@LcStreet)
	 begin
	 Update Importleads set AccountErrorRemarks =  Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the LocalAddress Street Length Less then', CAST(@LcStreet as nvarchar(100)))
     Else CONCAT('Please enter the Street Length Less then', CAST(@LcStreet as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and LocalAddress is not null
	 end
	 				
	 if Exists (Select AddrName From #Strng_Splt Where Id=3 AND LEN(AddrName) >@LcUnitNo)
	 begin
	 Update Importleads set AccountErrorRemarks =  Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the LocalAddress UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100)))
     Else CONCAT('Please enter the UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and LocalAddress is not null
	 end 
	 
	 if Exists (Select AddrName From #Strng_Splt Where Id=4 AND LEN(AddrName) >@LcBuildingEstate)
	 begin
	 Update Importleads set AccountErrorRemarks =  Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the LocalAddress BuildingEstate Length Less then', CAST(@LcBuildingEstate as nvarchar(100)))
     Else CONCAT('Please enter the BuildingEstate Length Less then', CAST(@LcBuildingEstate as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and LocalAddress is not null
	 end 
	 
	 if Exists (Select AddrName From #Strng_Splt Where Id=5 AND LEN(AddrName) >@LcCity)
	 begin
	 Update Importleads set AccountErrorRemarks =  Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the LocalAddress City Length Less then', CAST(@LcCity as nvarchar(100)))
     Else CONCAT('Please enter the City Length Less then', CAST(@LcCity as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and LocalAddress is not null
	 end
	 
	 if Exists (Select AddrName From #Strng_Splt Where Id=5 AND LEN(AddrName) >@LcState)
	 begin
	 Update Importleads set AccountErrorRemarks =  Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the LocalAddress state Length Less then', CAST(@LcState as nvarchar(100)))
     Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and LocalAddress is not null
	 end
	 
	 if Exists (Select AddrName From #Strng_Splt Where Id=5 AND LEN(AddrName) >@LcCountry)
	 begin
	 Update Importleads set AccountErrorRemarks =  Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the LocalAddress Country Length Less then ', CAST(@LcCountry as nvarchar(100)))
     Else CONCAT('Please enter the Country Length Less then ', CAST(@LcCountry as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and LocalAddress is not null
	 end
	 
	 if Exists (Select AddrName From #Strng_Splt Where Id=6 AND LEN(AddrName) >@LcPostalCode)
	 begin
	 Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the LocalAddress PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100)))
     Else CONCAT('Please enter the PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and LocalAddress is not null
	 end
	 drop Table #Strng_Splt
	END
					 --=======================================================@ForigenAddress in  ClientCursor.Account table========================================
	If @ForigenAddress Is Not Null  
	Begin
	 Create Table #Strng1_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))
	 Insert Into #Strng1_Splt(AddrName)
	 Select Value From string_split(@ForigenAddress,',')
			        
	 if Exists (Select AddrName From #Strng1_Splt Where Id=1 AND LEN(AddrName) >@LcStreet)
	 begin
	 Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the Foreignaddress state Length Less then', CAST(@LcState as nvarchar(100)))
     Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and Foreignaddress is not null
	 end

	 if Exists (Select AddrName From #Strng1_Splt Where Id=2 AND LEN(AddrName) >@LcUnitNo)
	 begin
	 Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the Foreignaddress UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100)))
     Else CONCAT('Please enter the UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and Foreignaddress is not null
	 end 

     if Exists (Select AddrName From #Strng1_Splt Where Id=3 AND LEN(AddrName) >@LcCity)
	 begin
	 Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the Foreignaddress City Length Less then', CAST(@LcCity as nvarchar(100)))
     Else CONCAT('Please enter the City Length Less then', CAST(@LcCity as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and Foreignaddress is not null
	 end

	 if Exists (Select AddrName From #Strng1_Splt Where Id=4 AND LEN(AddrName) >@LcState)
	 begin
	 Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the Foreignaddress state Length Less then', CAST(@LcState as nvarchar(100)))
     Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and Foreignaddress is not null
	 end
					  
     if Exists (Select AddrName From #Strng1_Splt Where Id=5 AND LEN(AddrName) >@LcCountry)
	 begin
	 Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the Foreignaddress Country Length Less then ', CAST(@LcCountry as nvarchar(100)))
     Else CONCAT('Please enter the Country Length Less then ', CAST(@LcCountry as nvarchar(100))) end, AccountImportStatus=0
	 where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and Foreignaddress is not null
	 end
						
	 if Exists (Select AddrName From #Strng1_Splt Where Id=6 AND LEN(AddrName) >@LcPostalCode)
	 begin
	 Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Please enter the Foreignaddress PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100)))
     Else CONCAT('Please enter the PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100))) end, AccountImportStatus=0
     where  TransactionId=@TransactionId  AND ID=@IdImp and AccountId=@AccountId and Name=@Name and Foreignaddress is not null
	 end
	  drop Table #Strng1_Splt
	END 
    --============================================================================end Address check length ==========================================================
	Begin Try  
          update kk set kk.AccountImportStatus=
          case when  [month] in ('Feb')  and [day] Between 1 and 29 then 1
          when  [month] in ('Jan','Mar','May','Jul','Aug','Oct','Dec') and [day] Between 1 and 31 then 1
          when  [month] in ('Apr','Jun','Sep','Nov') and [day] Between 1 and 30 then 1 else 0  end ,AccountErrorRemarks=Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Financial Year End must be in DD/MMM (Ex:31/Jan) Format'  ) 
          Else 'Financial Year End must be in DD/MMM (Ex:31/Jan) Format' end from
          (
           select id,IncorporationDate,AccountImportStatus,AccountErrorRemarks,Cast(Substring(FinancialYearEnd,0,charindex('/',FinancialYearEnd)) As Int) as 'DAY',Substring(FinancialYearEnd,charindex('/',FinancialYearEnd)+1,LEN(FinancialYearEnd))
           AS 'Month'  from Importleads  where TransactionId=@TransactionId and (FinancialYearEnd is not null OR  FinancialYearEnd<>'')
            and AccountId=@AccountId and Name=@Name  and id=@IdImp 
           )kk
           where   case when  [month] in ('Feb')  and [day] Between 1 and 29 then 1
           when  [month] in ('Jan','Mar','May','Jul','Aug','Oct','Dec') and [day] Between 1 and 31 then 1
           when  [month] in ('Apr','Jun','Sep','Nov') and [day] Between 1 and 30 then 1 else 0  end=0
      END TRY
	  BEGIN CATCH
		    Declare @error nvarchar(max) = error_message();
			If @error is not null
	        begin 
		    UPDATE  Importleads set AccountErrorRemarks=Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Financial Year End must be in DD/MMM (Ex:31/Jan) Format'  ) 
            Else 'Financial Year End must be in DD/MMM (Ex:31/Jan) Format' end    where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp
		    UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
	        End 
      END CATCH

      Begin Try 
            update kk set kk.AccountImportStatus=
            case when  [month]=2 and [day] Between 1 and 29 then 1
            when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
            when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,AccountErrorRemarks=Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'IncorporationDate must be in DD/MM/YYYY (Ex:31/01/1992) Format')
            Else 'IncorporationDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' end  from
            (
            select id,IncorporationDate,AccountImportStatus,AccountErrorRemarks,SUBSTRING(IncorporationDate,1,Charindex('/',IncorporationDate)-1) as 'DAY',SUBSTRING(IncorporationDate,Charindex('/',IncorporationDate)+1,Charindex('/',SUBSTRING(IncorporationDate,Charindex('/',IncorporationDate)+1,LEN(IncorporationDate)))-1)
            AS 'Month'  from ImportLeads  where TransactionId=@TransactionId
            and (IncorporationDate is not null or IncorporationDate <>'')
			and id=@IdImp and AccountId=@AccountId and Name=@Name
            )kk
            where  case when  [month]=2 and [day] Between 1 and 29 then 1
            when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
            when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
      END TRY
	  BEGIN CATCH
		    Declare @error1 nvarchar(max) = error_message();
			If @error1 is not null
	        begin 
		    UPDATE  Importleads set AccountErrorRemarks=Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'IncorporationDate must be in DD/MM/YYYY (Ex:31/01/1992) Format')
            Else 'IncorporationDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' end   where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp
		    UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
	        End 
	  END CATCH

	  If NOT Exists ( select distinct  FirstName from Common.CompanyUser where CompanyId=@companyId and FirstName in(SELECT Distinct value FROM Importleads --- CHECK FirstName IN Common.CompanyUser TABLE
      CROSS APPLY STRING_SPLIT(InchargesinClientCursor , ',') where  AccountId=@AccountId and TransactionId=@TransactionId  and InchargesinClientCursor is not null  /*and CompanyId=@companyId*/)  )
	  BEGIN
	  UPDATE  Importleads set AccountErrorRemarks=Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Please Check Incharge not matched in seedata' )
      Else 'Please Check Incharge not matched in seedata' end   ,AccountImportStatus=0 where AccountId=@AccountId 
	  and TransactionId=@TransactionId and Name=@Name  and id=@IdImp and InchargesinClientCursor is not null
	  END 

      If  NOT Exists ( select  id  from Common.TermsOfPayment where  Name=@CreditTerms and CompanyId=@companyId and name is not null  ) -- CHECK CreditTermsID IN  Common.TermsOfPayment TABLE
	  BEGIN
	  UPDATE  Importleads set AccountErrorRemarks=Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Please check CreditTerms not matched in seedata' ) 
      Else 'Please check CreditTerms not matched in seedata' end  , AccountImportStatus=0
	  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp  and CreditTerms is not null
	  END 

      If  Exists ( select  id  from ClientCursor.Vendor where  Name=@Secretary and CompanyId=@companyId and Status=1 )or @Secretary is null   -- CHECK SecretaryID IN  ClientCursor.Vendor TABLE
      BEGIN
        If @SourceType='Employee' ---- CHECK SourceType AND SOURCENAME IN Common.CompanyUser TABLE
		Begin
		Set @SourceId=( select top 1 cast(id As varchar(100)) from Common.CompanyUser where FirstName=@Source and CompanyId=@companyId and FirstName is not null and Status=1 )
		End
		Else If @SourceType='Customer'  ---- CHECK SourceType AND SOURCENAME IN ClientCursor.Account TABLE 
		Begin
		Set @SourceId=( select top 1 id  from ClientCursor.Account  where Name=@Source and CompanyId=@companyId and name is not null and Status=1 )
		End
		Else If @SourceType='Referral Partner' ---- CHECK SourceType AND SOURCENAME IN ClientCursor.Vendor TABLE 
		Begin
		Set @SourceId=( select top 1  id  from ClientCursor.Vendor  where Name=@Source and CompanyId=@companyId and name is not null and Status=1 )
		End
		Else If @SourceType='Marketing Campaign' ---- CHECK SourceType AND SOURCENAME IN ClientCursor.Campaign TABLE 
		Begin
		Set @SourceId=(select top 1  id  from ClientCursor.Campaign  where Name=@Source and CompanyId=@companyId and name is not null and Status=1  )
		End
		--Else 
		--BEGIN
		IF @SourceType IN ('Marketing Campaign','Referral Partner','Customer','Employee') AND  @SourceId IS NULL
	    BEGIN 
		UPDATE  Importleads set AccountErrorRemarks=Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Please check Source Info Data not matched in seedata' )
        Else 'Please check Source Info Data not matched in seedata' end  , AccountImportStatus=0 
		where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp  and [Source/Remarks] is not null  
        END 
		--END 
	  END
	  ELSE 
	  BEGIN 
	  UPDATE  Importleads set AccountErrorRemarks=Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Please check Vendor not matched in seedata' ) 
      Else 'Please check Vendor not matched in seedata' end    where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp and CompanySecretary is not null 
	  UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp  and CompanySecretary is not null 
	  END 
           --========================================================03.12.2019
		   -- Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','AccountId Already Exists Please entered the correct information.') 
		   -- Else 'AccountId Already Exists Please entered the correct information.' end , AccountImportStatus=0
		   -- where  AccountId=@AccountId and Name=@Name  and id=@IdImp and  TransactionId=@TransactionId  and AccountId is not null  and AccountId  in 
		   -- (select distinct  AccountId  from ClientCursor.Account where CompanyId=@companyId)
		   
		   --Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',','Name Already Exists Please entered the correct information.')
           -- Else 'Name Already Exists Please entered the correct information.' end, AccountImportStatus=0
		   --where  AccountId=@AccountId and Name=@Name  and id=@IdImp and  TransactionId=@TransactionId  and Name is not null  and Name  in 
		   --(select distinct  Name  from ClientCursor.Account where CompanyId=@companyId)
	                     
		 --========================================================03.12.2019

		---============================================  leads Valiation Start ===================================================================================
						  
	  Update Importleads set AccountErrorRemarks = Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Please Check the Contact') 
      Else 'Please Check the Contact' end , AccountImportStatus=0
	  where  AccountId is not null and TransactionId=@TransactionId and (AccountImportStatus<>0 or AccountImportStatus is null)  and AccountId in 
	  (select Distinct MasterId  from ImportContacts  where TransactionId=@TransactionId AND ImportStatus=0 )

      update Importleads set AccountErrorRemarks=case when charindex(',',AccountErrorRemarks)=1 then SUBSTRING(AccountErrorRemarks,2,len(AccountErrorRemarks))
	  else AccountErrorRemarks  end,AccountImportStatus=0  where TransactionId=@TransactionId AND  AccountErrorRemarks IS NOT NULL

	   --============================================================== leads Validation  End =====================================================

      ---============================================  Contact Valiation Start ===================================================================================

       Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please check Leads')
       Else  'Please check Leads' end, ImportStatus=0
	   where  MasterId is NOT null and TransactionId=@TransactionId  and (ImportStatus<>0 or ImportStatus is null) AND MasterId IN 
       (SELECT Distinct AccountId FROM ImportLeads  where  AccountId is not null and TransactionId=@TransactionId and AccountImportStatus=0)

	   Update ImportContacts set ErrorRemarks = case when charindex(',',ErrorRemarks)=1 then SUBSTRING(ErrorRemarks,2,len(ErrorRemarks))
	   else ErrorRemarks  end, ImportStatus=0 where   TransactionId=@TransactionId AND ErrorRemarks IS NOT NULL

       --============================================================== Contact Validation  End =====================================================

     IF  Exists (SELECT Distinct id FROM Importleads  where  TransactionId=@TransactionId and (AccountImportStatus<>0 or AccountImportStatus is null)and Name=@Name  and id=@IdImp AND AccountId=@AccountId )
	 BEGIN
       IF  Exists (select Distinct MasterId  from ImportContacts  where  MasterId=@AccountId and TransactionId=@TransactionId  and  ( ImportStatus<>0 oR  ImportStatus IS NULL))
	   BEGIN
         If  Not Exists   (select distinct  AccountId  from ClientCursor.Account where CompanyId=@companyId  and AccountId=@AccountId and AccountId is not null)
		 BEGIN
           If  Not Exists   (select distinct  Name  from ClientCursor.Account where CompanyId=@companyId  and  Name=@Name  and name is not null)
		   BEGIN
              set @AccountTypeId= (select top 1  id  from Common.AccountType where  Name=@AccountType and CompanyId=@companyId)
			  set @IdTypeId= ( select Distinct top 1  It.Id  from Common.IdType It
		      inner join Common.AccountTypeIdType Att on att.IdTypeId=it.Id
		      inner join  Common.AccountType atp on atp.id=att.AccountTypeId
		      where  it.Name=@IdType and it.CompanyId=@companyId and atp.CompanyId=@companyId  and atp.Name=@AccountType)
			  set @CreditTermsId= (select top 1  id  from Common.TermsOfPayment where  Name=@CreditTerms and CompanyId=@companyId)
			  set @SecretaryId= (select TOP 1  V.Id  from ClientCursor.Vendor V INNER JOIN ClientCursor.VendorTypeVendor VT ON VT.VendorId=V.Id
	          where  V.Name=@Secretary and V.CompanyId=@companyId AND VT.Status=1 AND VendorTypeName='Company Secretary' AND  V.Name IS NOT NULL)
 			  Set @EmailJson =(Select 'Email' As 'key',Email As 'value' From ImportLeads Where AccountId=@AccountId and Name=@Name and Email is not null  and id=@IdImp and  TransactionId=@TransactionId  For Json Auto)
              Set @MobileJson =(Select 'Phone' As 'key',Phone As 'value' From ImportLeads Where AccountId=@AccountId and Name=@Name and Phone is not null   and id=@IdImp and TransactionId=@TransactionId For Json Auto)
		      If @EmailJson Is Not Null
		      Begin
			    If @MobileJson Is Not Null
			    Begin
				Set @Jsondata =Concat(Substring(@EmailJson,1,len(@EmailJson)-1),',',Substring(@MobileJson,2,len(@MobileJson)))
			    End	
			    Else
			    Begin
				Set @Jsondata=@EmailJson
			    End
		      End
		      If @EmailJson Is Null
		      Begin
			    If @MobileJson Is Not Null
			    Begin
				Set @Jsondata=@MobileJson
			    End
			    Else
			    Begin
				Set @Jsondata=null
			    End
              END
            If @SourceId Is Not Null
		    Begin
			 set  @Id=NewId()
			  -----==============================- insert into  ClientCursor.Account table ========================================================
			 Insert Into  ClientCursor.Account (id,AccountId,Name,Source,SourceName,Industry,IncorporationDate,FinancialYearEnd ,
			 PrincipalActivities,CountryOfIncorporation ,IsAGMDocsReminders,IsCorporateTaxReminders,
			 IsAuditReminders,IsFinalTax,IsAccount,Communication,AccountIdNo,AccountTypeId,AccountIdTypeId,TermsOfPaymentId,CompanySecretaryId,
			 CreatedDate,IsLocal,Status,AccountStatus,UserCreated,CompanyId,SourceId,Reminders)  

			 SELECT   @Id ,AccountId,Name ,SourceType as source,[Source/Remarks] AS SourceName,Industry,CONVERT(datetime2,IncorporationDate,103) as IncorporationDate,
			 case when  FinancialYearEnd is not null and FinancialYearEnd <>' ' then 
	         cast(REPLACE( FinancialYearEnd, '/', ' ') + cast(datepart(year, GETUTCDATE()) as char(4)) as datetime2)  end  as FinancialYearEnd,
			 PrincipalActivities,IncorporationCountry as CountryOfIncorporation,RemindersAGM as IsAGMDocsReminders,RemindersECI as IsCorporateTaxReminders,
			 RemindersAudit as IsAuditReminders,RemindersFinalTax as IsFinalTax,case when type='Lead' THEN 0 WHEN type='Account' THEN 1 END IsAccount ,
			 @Jsondata AS Communication ,IdentificationNumber AS AccountIdNo,@AccountTypeId AS AccountTypeId,@IdTypeId AS AccountIdTypeId ,@CreditTermsId AS TermsOfPaymentId ,@SecretaryId AS CompanySecretaryId,
			 GETUTCDATE() as CreatedDate,1 AS IsLocal ,1 AS Status,case when type='Lead' THEN 'New' WHEN type='Account' THEN 'Active' END AS AccountStatus,'system' as UserCreated,@companyId,@SourceId AS SourceId,
			  concat('[',case when RemindersAGM=1 then '{"key":"AGM","value":true}' else '{"key":"AGM","value":false}' end ,',',
                  case when RemindersECI=1 then '{"key":"ECI","value":true}' else '{"key":"ECI","value":false}' end ,',',
                  case when RemindersAudit=1 then '{"key":"Audit","value":true}' else '{"key":"Audit","value":false}' end ,',',
                  case when RemindersFinalTax=1 then '{"key":"Final Tax","value":true}' else '{"key":"Final Tax","value":false}' end ,']') as Reminders
			 FROM Importleads  where  AccountId=@AccountId and Name=@Name  and id=@IdImp and  TransactionId=@TransactionId and (AccountImportStatus<>0 or AccountImportStatus is null)

			------================================insert into  ClientCursor.Accountstatuschange table =============================================================
			 Insert Into ClientCursor.Accountstatuschange (id,companyid,accountid,isaccount,state,modifiedby,modifieddate)

			 select  Newid(),@companyid,@Id,case when type='Lead' THEN 0 WHEN type='Account' THEN 1 END IsAccount,
			 case when type='Lead' THEN 'New' WHEN type='Account' THEN 'Active' END AS state,'system' as modifiedby,GETUTCDATE() as modifieddate 
			 FROM  importleads where  AccountId=@AccountId and Name=@Name  and id=@IdImp and  TransactionId=@TransactionId and (AccountImportStatus<>0 or AccountImportStatus is null)

			 Update ImportLeads Set AccountErrorRemarks=null,AccountImportStatus=1 Where TransactionId=@TransactionId And AccountId=@AccountId and Name=@Name  and id=@IdImp 
		    End
		     else
		     If @SourceType  not in  ('Customer','Employee','Marketing Campaign','Referral Partner') 
		     Begin
		      set  @Id=NewId()
			  ------------======================== insert into  ClientCursor.Account table ===========================================================
		      Insert Into  ClientCursor.Account (id,AccountId,Name,Source,SourceName,Industry,IncorporationDate,FinancialYearEnd ,
		      PrincipalActivities,CountryOfIncorporation ,IsAGMDocsReminders,IsCorporateTaxReminders,
		      IsAuditReminders,IsFinalTax,IsAccount,Communication,AccountIdNo,AccountTypeId,AccountIdTypeId,TermsOfPaymentId,CompanySecretaryId,
		      CreatedDate,IsLocal,Status,AccountStatus,UserCreated,CompanyId,SourceId,Reminders)  
		      
		      SELECT  @Id ,AccountId,Name ,SourceType as source,[Source/Remarks] AS SourceName,Industry,CONVERT(datetime2,IncorporationDate,103) as IncorporationDate,cast(REPLACE( FinancialYearEnd, '/', ' ') + cast(datepart(year, GETUTCDATE()) as char(4)) as datetime2)  as FinancialYearEnd,
		      PrincipalActivities,IncorporationCountry as CountryOfIncorporation,RemindersAGM as IsAGMDocsReminders,RemindersECI as IsCorporateTaxReminders,
		      RemindersAudit as IsAuditReminders,RemindersFinalTax as IsFinalTax,case when type='Lead' THEN 0 WHEN type='Account' THEN 1 END IsAccount ,
		      @Jsondata AS Communication ,IdentificationNumber AS AccountIdNo,@AccountTypeId AS AccountTypeId,@IdTypeId AS AccountIdTypeId ,@CreditTermsId AS TermsOfPaymentId ,@SecretaryId AS CompanySecretaryId,
		      GETUTCDATE() as CreatedDate,1 AS IsLocal ,1 AS Status,case when type='Lead' THEN 'New' WHEN type='Account' THEN 'Active' END AS AccountStatus,'system' as UserCreated,@companyId,@SourceId AS SourceId,
			    concat('[',case when RemindersAGM=1 then '{"key":"AGM","value":true}' else '{"key":"AGM","value":false}' end ,',',
                  case when RemindersECI=1 then '{"key":"ECI","value":true}' else '{"key":"ECI","value":false}' end ,',',
                  case when RemindersAudit=1 then '{"key":"Audit","value":true}' else '{"key":"Audit","value":false}' end ,',',
                  case when RemindersFinalTax=1 then '{"key":"Final Tax","value":true}' else '{"key":"Final Tax","value":false}' end ,']') as Reminders
		      FROM Importleads  where  AccountId=@AccountId and Name=@Name  and id=@IdImp and  TransactionId=@TransactionId and (AccountImportStatus<>0 or AccountImportStatus is null)

			-------------------------- insert into  ClientCursor.Accountstatuschange table 	
			  Insert Into ClientCursor.Accountstatuschange (id,companyid,accountid,isaccount,state,modifiedby,modifieddate)

			  select  Newid(),@companyid,@Id,case when type='Lead' THEN 0 WHEN type='Account' THEN 1 END IsAccount,
			  case when type='Lead' THEN 'New' WHEN type='Account' THEN 'Active' END AS state,'system' as modifiedby,GETUTCDATE() as modifieddate 
			  FROM  importleads where  AccountId=@AccountId and Name=@Name  and id=@IdImp and  TransactionId=@TransactionId and (AccountImportStatus<>0 or AccountImportStatus is null)

			  Update ImportLeads Set AccountErrorRemarks=null,AccountImportStatus=1 Where TransactionId=@TransactionId And AccountId=@AccountId and Name=@Name  and id=@IdImp  
		     End
          END
                            --   ELSE 
	                           --BEGIN 
	                           --UPDATE  Importleads set AccountErrorRemarks=Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'AccountName  Already Exists Please entered the correct information.' ) 
                            --   Else 'AccountName  Already Exists Please entered the correct information.' end   where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
	                           --UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
	                           --END 
	    End 
	                           --ELSE 
	                           --BEGIN 
	                           --UPDATE  Importleads set AccountErrorRemarks=Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'AccountId  Already Exists Please entered the correct information.' ) 
                            --   Else 'AccountId  Already Exists Please entered the correct information.' end    where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
	                           --UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
	                           --END 
	  End 
	                           --ELSE 
	                           --BEGIN 
	                           --UPDATE  Importleads set AccountErrorRemarks=Case when AccountErrorRemarks is not null then CONCAT(AccountErrorRemarks,',', 'Please enter the Primary Contact' ) 
                            --    Else 'Please enter the Primary Contact' end    where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
	                           --UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
	                           --END 
     END 
	  --================================================================================03.12.2019
      COMMIT TRANSACTION;
      END TRY
      BEGIN CATCH
      Declare @ErrorMessage Nvarchar(4000)=error_message();
      ROLLBACK;
      If @ErrorMessage is not null
	  begin 
      UPDATE  Importleads set AccountErrorRemarks=@ErrorMessage   where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp
      UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
	  End 
      END CATCH
	  --================================================================================03.12.2019

  fetch next from AccountId_Get Into @IdImp,@AccountId,@AccountType ,@IdType,@CreditTerms,@Secretary,@Source,@SourceType,@Name
 END
 Close AccountId_Get
 Deallocate AccountId_Get
 --declare @FailedCount int = (Select Count(*) from Importleads Where TransactionId=@TransactionId and AccountImportStatus=0)
 --Update Common.[Transaction] Set TotalRecords=(Select Count(*) from Importleads Where TransactionId=@TransactionId ),
 --FailedRecords=  (Case When @FailedCount>0 then @FailedCount else 0 end)   where Id=@TransactionId


     Declare @Failure int=( select count(*) from Importleads where TransactionId=@TransactionId and AccountImportStatus=0)
   Declare @Success int=( select count(*) from Importleads where TransactionId=@TransactionId and AccountImportStatus=1)

   update Common.[Transaction] 
   set FailedRecords=@Failure,
   [Status]=(select case when @Failure<>0 and @Success<>0 then 'Partially Completed' when @Failure=0 and @Success<>0 then 'Completed'when @Failure<>0 and @Success=0 then 'Failed'end )
   , TotalRecords=( select count(*) from Importleads where TransactionId=@TransactionId)
   , [Remarks]=(select case when @Failure<>0 and @Success<>0 then 'Some Accounts Inserted' when @Failure=0 and @Success<>0 then 'All Accounts Inserted'when @Failure<>0 and @Success=0 then 'All Accounts Failed'end )
  where CompanyId=@companyId and id=@TransactionId


END

	  --COMMIT TRANSACTION;
      --END TRY
      --BEGIN CATCH
	  --Declare @ErrorMessage Nvarchar(4000)
	  --ROLLBACK;
	  --Select @ErrorMessage=error_message();
	  --Raiserror(@ErrorMessage,16,1);
  --   Declare @error nvarchar(max) = error_message();
  --END CATCH

	 
GO
