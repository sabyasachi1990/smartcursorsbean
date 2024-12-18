USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_Clients_Validation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









 CREATE PROCEDURE [dbo].[Import_Clients_Validation]  
--exec [dbo].[Import_Clients_Validation]  1136,'F693258B-F201-4C5F-B671-4EF4F26199A3'
@companyId int,
@TransactionId uniqueidentifier

AS
BEGIN 

Declare
-- @companyId int=239,
--@TransactionId uniqueidentifier='3D682EA1-2DA1-48BB-9729-845EB1C03EA6',
  @ClientId nvarchar (max),
  @Clientname nvarchar (max),
  @ClienttType nvarchar(max),
  @IdType nvarchar(max),
  @CreditTerms nvarchar(max),
  @ClientTypeId bigint,
  @IdTypeId bigint,
  @CreditTermsId bigint,
  @Jsondata  Nvarchar(max),
  @EmailJson Nvarchar(max),
  @MobileJson Nvarchar(max),
  @Id uniqueidentifier,
  @ClientId_New uniqueidentifier,
  @LocalAddress Nvarchar(Max),
@ForigenAddress Nvarchar(Max)

   -------------------
   --BEGIN TRANSACTION;
   -- BEGIN TRY
	---------------------
  Declare @WSystemRefNo  bigint=COL_LENGTH('WorkFlow.Client', 'SystemRefNo') 
  Declare @WName bigint=COL_LENGTH('WorkFlow.Client', 'Name')
  Declare @WSource bigint=COL_LENGTH('WorkFlow.Client', 'Source')
  Declare @WSourceName bigint=COL_LENGTH('WorkFlow.Client', 'SourceName')
  Declare @WSourceRemarks bigint=COL_LENGTH('WorkFlow.Client', 'SourceRemarks')
  Declare @WIndustry bigint=COL_LENGTH('WorkFlow.Client', 'Industry     ')
  Declare @WPrincipalActivities bigint=COL_LENGTH('WorkFlow.Client', 'PrincipalActivities')
  Declare @WCountryOfIncorporation bigint=COL_LENGTH('WorkFlow.Client', 'CountryOfIncorporation')
  Declare @WClientIdNo bigint=COL_LENGTH('WorkFlow.Client', 'ClientIdNo')
  Declare @WCommunication bigint=COL_LENGTH('WorkFlow.Client', 'Communication')

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



	Begin
	Exec [dbo].[Import_WFContactsDetailUPADTE_Validation] @companyId,@TransactionId
	end 








 --====================================== Client Mandatory field ==================================================
     

	        Update ImportWFContacts set PersonalLocalAddress = case when charindex(',',PersonalLocalAddress)=1 then SUBSTRING(PersonalLocalAddress,2,len(PersonalLocalAddress))
	       else PersonalLocalAddress  end where   TransactionId=@TransactionId AND PersonalLocalAddress IS NOT NULL

		   Update ImportWFContacts set PersonalForeignAddress = case when charindex(',',PersonalForeignAddress)=1 then SUBSTRING(PersonalForeignAddress,2,len(PersonalForeignAddress))
	       else PersonalForeignAddress  end where   TransactionId=@TransactionId AND PersonalForeignAddress IS NOT NULL

		   Update ImportWFContacts set EntityLocalAddress = case when charindex(',',EntityLocalAddress)=1 then SUBSTRING(EntityLocalAddress,2,len(EntityLocalAddress))
	       else EntityLocalAddress  end where   TransactionId=@TransactionId AND EntityLocalAddress IS NOT NULL


		   	   Update ImportWFContacts set EntityForeignAddress = case when charindex(',',EntityForeignAddress)=1 then SUBSTRING(EntityForeignAddress,2,len(EntityForeignAddress))
	       else EntityForeignAddress  end where   TransactionId=@TransactionId AND EntityForeignAddress IS NOT NULL


		   update ImportWFClient set LocalAddress=case when charindex(',',LocalAddress)=1 then SUBSTRING(LocalAddress,2,len(LocalAddress))
		   else LocalAddress  end  where TransactionId=@TransactionId AND  LocalAddress IS NOT NULL

		     update ImportWFClient set Foreignaddress=case when charindex(',',Foreignaddress)=1 then SUBSTRING(Foreignaddress,2,len(Foreignaddress))
		   else Foreignaddress  end  where TransactionId=@TransactionId AND  Foreignaddress IS NOT NULL

		    update ImportWFClient set FinancialYearEnd=null  where TransactionId=@TransactionId AND  FinancialYearEnd =''
			update ImportWFClient set IncorporationDate=null  where TransactionId=@TransactionId AND  IncorporationDate =''



         Update ImportWFClient  set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the ClientName')
         Else 'Please enter the ClientName' end,ImportStatus=0 
	     where TransactionId=@TransactionId and Name is null ---and (ImportStatus<>0 or ImportStatus is null)
	     
	     Update ImportWFClient  set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the ClientRefNumber')
         Else 'Please enter the ClientRefNumber' end,ImportStatus=0 
	     where TransactionId=@TransactionId and ClientRefNumber is null ---and (ImportStatus<>0 or ImportStatus is null)


		 Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the ClientRefNumber Length Less then', CAST(@WSystemRefNo as nvarchar(100)))
        Else CONCAT('Please entered the ClientRefNumber Length Less then', CAST(@WSystemRefNo as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and ClientRefNumber is not null AND LEN(ClientRefNumber)>@WSystemRefNo

		Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the Name Length Less then ', CAST(@WName as nvarchar(100)))
        Else CONCAT('Please entered the Name Length Less then ', CAST(@WName as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  AND Name IS NOT NULL AND LEN(Name)>@WName


		Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the Industry Length Less then ', CAST(@WIndustry as nvarchar(100)))
        Else CONCAT('Please entered the Industry Length Less then ', CAST(@WIndustry as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and Industry is not null AND LEN(Industry)>@WIndustry 

		Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the PrinicipalActivities Length Less then ', CAST(@WPrincipalActivities as nvarchar(100)))
        Else CONCAT('Please entered the PrincipalActivities Length Less then ', CAST(@WPrincipalActivities as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and PrinicipalActivities is not null  AND LEN(PrinicipalActivities)>@WPrincipalActivities

		Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the CountryOfIncorporation Length Less then ', CAST(@WCountryOfIncorporation as nvarchar(100)))
        Else CONCAT('Please entered the CountryOfIncorporation Length Less then ', CAST(@WCountryOfIncorporation as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and IncorporationCountry is not null AND LEN(IncorporationCountry)>@WCountryOfIncorporation

		Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the IdentificationNumber Length Less then ', CAST(@WClientIdNo as nvarchar(100)))
        Else CONCAT('Please entered the IdentificationNumber Length Less then ', CAST(@WClientIdNo as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and IdentificationNumber is not null  AND LEN(IdentificationNumber)>@WClientIdNo

		Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the  Mobile and Email Length Less then ', CAST(@wCommunication as nvarchar(100)))
        Else CONCAT('Please entered the  Mobile and Email Length Less then ',CAST(@wCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and Mobile is not null and Email is not null   AND (LEN(Mobile)+ len(Email))>@wCommunication

		Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the Mobile Length Less then ', CAST(@wCommunication as nvarchar(100)))
        Else CONCAT('Please entered the Mobile Length Less then ',CAST(@wCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and Mobile is not null and Email is null   AND (LEN(Mobile))>@wCommunication

	    Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the Email Length Less then ', CAST(@wCommunication as nvarchar(100)))
        Else CONCAT('Please entered the Email Length Less then ',CAST(@wCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and Mobile is null and Email is not null   AND ( len(Email))>@wCommunication
		 
		  UPDATE  ImportWFClient set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the Primary Contact')
          Else 'Please enter the Primary Contact' end
		  WHERE TransactionId=@TransactionId AND ClientRefNumber IS NOT NULL AND  ClientRefNumber NOT IN
		    (
		        select Distinct ClientRefNumber  from ImportWFContacts  where  TransactionId=@TransactionId AND  ClientRefNumber IS NOT NULL
		     )
		  			 
	
		   --===========================================03.12.2019

		    UPDATE  ImportWFClient set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'SystemRefNo Already Exists Please entered the correct information.')
          Else 'SystemRefNo Already Exists Please entered the correct information.' end ,ImportStatus=0 
		  WHERE TransactionId=@TransactionId     AND ClientRefNumber IS NOT NULL AND  ClientRefNumber IN
	       (
		   select Distinct SystemRefNo  from workflow.client where CompanyId=@companyId AND SystemRefNo IS NOT NULL
		   )
		  
		  
		  UPDATE  ImportWFClient set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'ClientName Already Exists Please entered the correct information.')
          Else 'ClientName Already Exists Please entered the correct information.' end ,ImportStatus=0 
		  WHERE TransactionId=@TransactionId AND name IS NOT NULL AND  name IN
	       (
		   select Distinct name  from workflow.client where CompanyId=@companyId AND name IS NOT NULL
		   )
		   		   --===========================================03.12.2019
		   

		   UPDATE  ImportWFClient set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the CreditTerms')
           Else 'Please enter the CreditTerms' end,ImportStatus=0 
		  WHERE TransactionId=@TransactionId AND CreditTerms IS NULL
		  
		  UPDATE  ImportWFClient set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please Check CreditTerms not matched in controlcode')
           Else 'Please Check CreditTerms not matched in controlcode' end ,ImportStatus=0 
		  WHERE TransactionId=@TransactionId AND CreditTerms IS NOT NULL AND  CreditTerms NOT IN
	       (
		   select Distinct name  from Common.TermsOfPayment where CompanyId=@companyId AND name IS NOT NULL
		   )



	     Update ImportWFClient  set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please Check Industry not matched in controlcode')
         Else 'Please Check Industry not matched in controlcode' end,ImportStatus=0 
	     where TransactionId=@TransactionId and Industry is not null ---and (ImportStatus<>0 or ImportStatus is null)
	     and Industry  Not in 
	       (
	     SELECT Distinct  CodeKey FROM Common.ControlCode cc 
	     inner join Common.ControlCodeCategory ccc on ccc.id=cc.ControlCategoryId
	     WHERE  ccc.ControlCodeCategoryCode='Industries' AND ccc.CompanyId=@companyId 
		    )

	  
	    Update ImportWFClient  set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please check ClientTypeId not matched in seedata')
        Else 'Please check ClientTypeId not matched in seedata' end,ImportStatus=0 
	    where TransactionId=@TransactionId and ClientType is not null ---and (ImportStatus<>0 or ImportStatus is null)
	    and ClientType Not in ( select Distinct Name  from Common.AccountType where   CompanyId=@companyId)
	    
	    Update ImportWFClient  set IncorporationDate=null
	    where TransactionId=@TransactionId and IncorporationDate=''
	    
	    
	    Update ImportWFClient  set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please check IdtypetId not matched in seedata')
        Else 'Please check IdtypetId not matched in seedata' end,ImportStatus=0 
	    where TransactionId=@TransactionId and Identificationtype is not null ---and (ImportStatus<>0 or ImportStatus is null)
	    and Identificationtype COLLATE DATABASE_DEFAULT  Not in ( select Distinct Name  from Common.IdType where   CompanyId=@companyId)
	    
        Update ImportWFClient  set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please check Incorporationcountry not matched in ControlCode')
        Else 'Please check Incorporationcountry not matched in ControlCode' end,ImportStatus=0 
        where  TransactionId=@TransactionId and IncorporationCountry is not null ---and (ImportStatus<>0 or ImportStatus is null)
	    and IncorporationCountry COLLATE DATABASE_DEFAULT  Not in 
	    (  
	    select Distinct CodeKey from Common.ControlCode c
        inner join  Common.ControlCodeCategory cc on c.ControlCategoryId=cc.Id 
	    where CompanyId=@companyId  and CodeKey is not null
	    )

		update ImportWFClient set ImportStatus=case when ISNUMERIC(Replace(Replace(Replace(Mobile,'+','1'),' ','2'),'-','3'))=0 Then 0 end  ,ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Mobile allows to enter only Numbers' )
        Else 'Mobile allows to enter only Numbers' end  
        where TransactionId=@TransactionId and Mobile is not null ---and (ImportStatus<>0 or ImportStatus is null)
        and case when ISNUMERIC(Replace(Replace(Replace(Mobile,'+','1'),' ','2'),'-','3'))=0 Then 0 end=0

	 --====================================== Contacts Mandatory field ==================================================

	   Update c set EntityMobile=PersonalMobile,EntityEmail=PersonalEmail,EntityLocalAddress=PersonalLocalAddress,EntityForeignAddress=PersonalForeignAddress 
	   from ImportWFContacts C  where   C.TransactionId=@TransactionId and C.CopycommunicationandAddress=1


	   Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the FirstName Length ', CAST(@LcFirstName as nvarchar(100)))
        Else CONCAT('Please enter the FirstName Length ', CAST(@LcFirstName as nvarchar(100))) end , ImportStatus=0
		where  TransactionId=@TransactionId  and Name is not null  and len(Name)>@LcFirstName 

		Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the IdentificationNumber Length ', CAST(@LcIdentificationNumber as nvarchar(100)))
        Else CONCAT('Please enter the IdentificationNumber Length ', CAST(@LcIdentificationNumber as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and IdentificationNumber is not null  and len(IdentificationNumber)>@LcIdentificationNumber

		Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the CountryOfResidence Length Less Then ', CAST(@LcCountryOfResidence as nvarchar(100)))
        Else CONCAT('Please enter the CountryOfResidence Length Less Then ', CAST(@LcCountryOfResidence as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and CountryOfResidence is not null  and len(CountryOfResidence)>@LcCountryOfResidence

		Update ImportWFContacts set ErrorRemarks =Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the Remarks Length Less Then ', CAST(@LcRemarks as nvarchar(100)))
        Else  CONCAT('Please enter the Remarks Length Less Then ', CAST(@LcRemarks as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and Remarks is not null  and len(Remarks)>@LcRemarks


		Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the EntityDesignation Length Less Then ', CAST(@LcDesignation as nvarchar(100)))
        Else  CONCAT('Please enter the EntityDesignation Length Less Then ', CAST(@LcDesignation as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityDesignation is not null  and len(EntityDesignation)>@LcDesignation

	    Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the PersonalMobile and PersonalEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the PersonalMobile and PersonalEmail  Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and PersonalMobile is not null  and PersonalEmail is not null and (len(PersonalMobile)+len(PersonalEmail))>@LcCommunication

		 Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the CommunicationPersonalMobile Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the CommunicationPersonalMobile Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and PersonalMobile is not null  and PersonalEmail is null and (len(PersonalMobile))>@LcCommunication

		Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the CommunicationPersonalEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the CommunicationPersonalEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and PersonalMobile is null  and PersonalEmail is not null and (len(PersonalEmail))>@LcCommunication


		Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the EntityMobile and EntityEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the EntityMobile and EntityEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityMobile is not null  and EntityEmail is not null and (len(EntityMobile)+len(EntityEmail))>@LcCommunication

		Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the CommunicationEntityMobile Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the CommunicationEntityMobile Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityMobile is not null  and EntityEmail is null and (len(EntityMobile))>@LcCommunication

		Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the CommunicationEntityEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the CommunicationEntityEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityMobile is null  and EntityEmail is not null and (len(EntityEmail))>@LcCommunication

		Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the PersonalMobile Length Less Then ', CAST(@LcPhone as nvarchar(100)))
        Else  CONCAT('Please enter the PersonalMobile Length Less Then ', CAST(@LcPhone as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and PersonalMobile is not null  and len(PersonalMobile)>@LcPhone

		Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the EntityMobile Length Less Then', CAST(@LcPhone as nvarchar(100)))
        Else  CONCAT('Please enter the EntityMobile Length Less Then', CAST(@LcPhone as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityMobile is not null  and len(EntityMobile)>@LcPhone


		Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the PersonalEmail Length Less Then ', CAST(@LcEmail as nvarchar(100)))
        Else  CONCAT( 'Please enter the PersonalEmail Length Less Then ', CAST(@LcEmail as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and PersonalEmail is not  null and len(PersonalEmail)>@LcEmail


		Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the EntityEmail Length Less Then ',CAST(@LcEmail as nvarchar(100)))
        Else  CONCAT('Please enter the EntityEmail Length Less Then ', CAST(@LcEmail as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and EntityEmail is not null  and len(EntityEmail)>@LcEmail







          if Exists (select Name from ImportWFContacts where Name is null and  TransactionId=@TransactionId)
	      begin
		  Update ImportWFContacts set ErrorRemarks =   Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the Name')
          Else 'Please enter the Name' end, ImportStatus=0
		  where  Name is null and TransactionId=@TransactionId
	      end 

	     if Exists (select ClientRefNumber from ImportWFContacts where ClientRefNumber is null  and TransactionId=@TransactionId)
	     begin
		 Update ImportWFContacts set ErrorRemarks =   Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the ClientRefNumber')
         Else 'Please enter the ClientRefNumber' end, ImportStatus=0
		 where  ClientRefNumber is null and TransactionId=@TransactionId
	     end 


		 if Exists (select PrimaryContact from ImportWFContacts where PrimaryContact is null  and TransactionId=@TransactionId)
	     begin
		 Update ImportWFContacts set ErrorRemarks =Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the PrimaryContact')
         Else 'Please enter the PrimaryContact' end, ImportStatus=0
		 where  PrimaryContact is null and TransactionId=@TransactionId
	     end 

	    if Exists (select ID from ImportWFContacts where EntityEmail is null and EntityMobile is null and PersonalMobile is null and  PersonalEmail is null  and TransactionId=@TransactionId)
	    begin
		Update ImportWFContacts set ErrorRemarks =   Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the Contact Communication')
        Else 'Please enter the Contact Communication' end, ImportStatus=0
		where  EntityEmail is null and EntityMobile is null and PersonalMobile is null and  PersonalEmail is null and TransactionId=@TransactionId
	    end 


	
        --Update ImportWFContacts set ErrorRemarks = 'Mandatory field PrimaryContacts is not Inactive', ImportStatus=0
		--where  PrimaryContacts =1 and TransactionId=@TransactionId and Inactive=1


		 Update ImportWFContacts  set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please check IdentificationType not matched in seedata')
         Else 'Please check IdentificationType not matched in seedata' end,ImportStatus=0 
         where TransactionId=@TransactionId and IdentificationType is not null ---and (ImportStatus<>0 or ImportStatus is null)
	     and IdentificationType COLLATE DATABASE_DEFAULT  Not in ( select Distinct Name  from Common.IdType where   CompanyId=@companyId)

	  	 Update ImportWFContacts  set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please check EntityDesignation not matched in ControlCode')
         Else 'Please check EntityDesignation not matched in ControlCode' end,ImportStatus=0 
         where TransactionId=@TransactionId and EntityDesignation is not null ---and (ImportStatus<>0 or ImportStatus is null)
	     and EntityDesignation COLLATE DATABASE_DEFAULT  Not in 
		    (
             select Distinct CodeKey from Common.ControlCode c
			 inner join  Common.ControlCodeCategory cc on c.ControlCategoryId=cc.Id 
			 where CompanyId=@companyId  and CodeKey is not null
			)

		 Update ImportWFContacts  set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please check CountryOfResidence not matched in ControlCode')
         Else 'Please check CountryOfResidence not matched in ControlCode' end,ImportStatus=0 
         where  TransactionId=@TransactionId and CountryOfResidence is not null ---and (ImportStatus<>0 or ImportStatus is null)
	     and CountryOfResidence COLLATE DATABASE_DEFAULT  Not in 
		      (
			select Distinct CodeKey from Common.ControlCode c
			inner join  Common.ControlCodeCategory cc on c.ControlCategoryId=cc.Id 
			where CompanyId=@companyId  and CodeKey is not null 
			   )


		 Update ImportWFContacts  set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please check Salutation not matched in ControlCode')
         Else 'Please check Salutation not matched in ControlCode' end,ImportStatus=0 
         where  TransactionId=@TransactionId and Salutation is not null ---and (ImportStatus<>0 or ImportStatus is null)
	     and Salutation COLLATE DATABASE_DEFAULT  Not in 
		      (
			select Distinct CodeKey from Common.ControlCode c
			inner join  Common.ControlCodeCategory cc on c.ControlCategoryId=cc.Id 
			where CompanyId=@companyId  and CodeKey is not null and ControlCodeCategoryCode='Salutation'
			   )


		  update ImportWFContacts set ImportStatus=case when ISNUMERIC(Replace(Replace(Replace(PersonalMobile,'+','1'),' ','2'),'-','3'))=0 Then 0 end  ,ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'PersonalMobile allows to enter only Numbers' )
          Else 'PersonalMobile allows to enter only Numbers' end   
          where TransactionId=@TransactionId and PersonalMobile is not null ---and (ImportStatus<>0 or ImportStatus is null)
          and case when ISNUMERIC(Replace(Replace(Replace(PersonalMobile,'+','1'),' ','2'),'-','3'))=0 Then 0 end=0


          update ImportWFContacts set ImportStatus=case when ISNUMERIC(Replace(Replace(Replace(EntityMobile,'+','1'),' ','2'),'-','3'))=0 Then 0 end  ,ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'EntityMobile allows to enter only Numbers' )
          Else 'EntityMobile allows to enter only Numbers' end   
          where TransactionId=@TransactionId and EntityMobile is not null ----and (ImportStatus<>0 or ImportStatus is null)
          and case when ISNUMERIC(Replace(Replace(Replace(EntityMobile,'+','1'),' ','2'),'-','3'))=0 Then 0 end=0



		  Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please entered the correct MasterId')
          Else  'Please entered the correct MasterId' end, ImportStatus=0
		  where  ClientRefNumber is NOT null and TransactionId=@TransactionId AND ClientRefNumber NOT IN 
          (
		  SELECT Distinct ClientRefNumber FROM ImportWFClient  where  ClientRefNumber is not null and TransactionId=@TransactionId
		  )





       Update ImportWFContacts set ErrorRemarks = case when charindex(',',ErrorRemarks)=1 then SUBSTRING(ErrorRemarks,2,len(ErrorRemarks))
	   else ErrorRemarks  end, ImportStatus=0 where   TransactionId=@TransactionId AND ErrorRemarks IS NOT NULL


 --------==============  Client Not in workflow.Client table Using Import excl Import clients in Workflow.Client  --===============================
				
   Declare ClientId_Get Cursor For
	   SELECT Distinct ID,ClientRefNumber,ClientType,Identificationtype,CreditTerms,Name FROM ImportWFClient 
       where  TransactionId=@TransactionId and ( ClientRefNumber   not in  (select Distinct SystemRefNo  from workflow.client where CompanyId=@companyId AND SystemRefNo IS NOT NULL)
	   or  Name   not in  (select Distinct Name  from workflow.client where CompanyId=@companyId AND Name IS NOT NULL))
	   
	     ---and (ImportStatus<>0 or ImportStatus is null) 
	   order by ClientRefNumber
		Open ClientId_Get
		fetch next from ClientId_Get Into @Id,@ClientId,@ClienttType ,@IdType,@CreditTerms,  @Clientname 
		While @@FETCH_STATUS=0
        BEGIN


		--===================== 03.12.2019
		 
         Begin Transaction  
         Begin Try  
		 --==================== 03.12.2019

		    

				--========================================================================= Start Address check length =======================================================

	                      Select @LocalAddress=LocalAddress,@ForigenAddress=Foreignaddress
	                      From ImportWFClient
	                      Where   TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and ( LocalAddress is not null or Foreignaddress is not null)

					 --================================ LocalAddress in  ClientCursor.Account table=========================================
					 
					  If @LocalAddress Is Not Null  
					  Begin
					  	
					  Create Table #Strng_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))

					  Insert Into #Strng_Splt(AddrName)
					  Select Value From string_split(@LocalAddress,',')

					  IF Exists( Select AddrName From #Strng_Splt Where Id=1 AND LEN(AddrName) >@LcBlockHouseNo )
					  begin
					  Update ImportWFClient set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress BlockHouseNo Length Less then', CAST(@LcBlockHouseNo as nvarchar(100)))
                      Else CONCAT('Please enter the BlockHouseNo Length Less then', CAST(@LcBlockHouseNo as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and LocalAddress is not null
					  end
					   
					  if Exists (Select AddrName From #Strng_Splt Where Id=2 AND LEN(AddrName) >@LcStreet)
					  begin
					  Update ImportWFClient set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress Street Length Less then', CAST(@LcStreet as nvarchar(100)))
                      Else CONCAT('Please enter the Street Length Less then', CAST(@LcStreet as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and LocalAddress is not null
					  end
						
					  if Exists (Select AddrName From #Strng_Splt Where Id=3 AND LEN(AddrName) >@LcUnitNo)
					  begin
					  Update ImportWFClient set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100)))
                      Else CONCAT('Please enter the UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and LocalAddress is not null
					  end 

					  if Exists (Select AddrName From #Strng_Splt Where Id=4 AND LEN(AddrName) >@LcBuildingEstate)
					  begin
					  Update ImportWFClient set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress BuildingEstate Length Less then', CAST(@LcBuildingEstate as nvarchar(100)))
                      Else CONCAT('Please enter the BuildingEstate Length Less then', CAST(@LcBuildingEstate as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and LocalAddress is not null
					  end 

					  if Exists (Select AddrName From #Strng_Splt Where Id=5 AND LEN(AddrName) >@LcCity)
					  begin
					  Update ImportWFClient set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress City Length Less then', CAST(@LcCity as nvarchar(100)))
                      Else CONCAT('Please enter the City Length Less then', CAST(@LcCity as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and LocalAddress is not null
					  end

					   if Exists (Select AddrName From #Strng_Splt Where Id=5 AND LEN(AddrName) >@LcState)
					  begin
					  Update ImportWFClient set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress state Length Less then', CAST(@LcState as nvarchar(100)))
                      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and LocalAddress is not null
					  end

					   if Exists (Select AddrName From #Strng_Splt Where Id=5 AND LEN(AddrName) >@LcCountry)
					  begin
					  Update ImportWFClient set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress Country Length Less then ', CAST(@LcCountry as nvarchar(100)))
                      Else CONCAT('Please enter the Country Length Less then ', CAST(@LcCountry as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and LocalAddress is not null
					  end

					  if Exists (Select AddrName From #Strng_Splt Where Id=6 AND LEN(AddrName) >@LcPostalCode)
					  begin
					  Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100)))
                      Else CONCAT('Please enter the PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and LocalAddress is not null
					  end
					  drop table #Strng_Splt
					  end
					 --=======================================================@ForigenAddress in  ClientCursor.Account table========================================
					  If @ForigenAddress Is Not Null  
					  Begin

					  Create Table #Strng1_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))
					  Insert Into #Strng1_Splt(AddrName)
				      Select Value From string_split(@ForigenAddress,',')
			        
					  if Exists (Select AddrName From #Strng1_Splt Where Id=1 AND LEN(AddrName) >@LcStreet)
					  begin
					  Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress state Length Less then', CAST(@LcState as nvarchar(100)))
                      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and Foreignaddress is not null
					  end

					  if Exists (Select AddrName From #Strng1_Splt Where Id=2 AND LEN(AddrName) >@LcUnitNo)
					  begin
					  Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100)))
                      Else CONCAT('Please enter the UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and Foreignaddress is not null
					  end 

                      if Exists (Select AddrName From #Strng1_Splt Where Id=3 AND LEN(AddrName) >@LcCity)
					  begin
					  Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress City Length Less then', CAST(@LcCity as nvarchar(100)))
                      Else CONCAT('Please enter the City Length Less then', CAST(@LcCity as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and Foreignaddress is not null
					  end

					  
                      if Exists (Select AddrName From #Strng1_Splt Where Id=4 AND LEN(AddrName) >@LcState)
					  begin
					  Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress state Length Less then', CAST(@LcState as nvarchar(100)))
                      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and Foreignaddress is not null
					  end
					  
                      if Exists (Select AddrName From #Strng1_Splt Where Id=5 AND LEN(AddrName) >@LcCountry)
					  begin
					  Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress Country Length Less then ', CAST(@LcCountry as nvarchar(100)))
                      Else CONCAT('Please enter the Country Length Less then ', CAST(@LcCountry as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and Foreignaddress is not null
					  end
						
					  if Exists (Select AddrName From #Strng1_Splt Where Id=6 AND LEN(AddrName) >@LcPostalCode)
					  begin
					  Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100)))
                      Else CONCAT('Please enter the PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@Id and ClientRefNumber=@ClientId and Name=@Clientname and Foreignaddress is not null
					  end
					  drop table #Strng1_Splt
					  end 

    --============================================================================end Address check length ==========================================================


		 Begin Try  
       	update kk set kk.ImportStatus=
            case when  [month] in ('Feb')  and [day] Between 1 and 29 then 1
            when  [month] in ('Jan','Mar','May','Jul','Aug','Oct','Dec') and [day] Between 1 and 31 then 1
            when  [month] in ('Apr','Jun','Sep','Nov') and [day] Between 1 and 30 then 1 else 0  end ,ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Financial Year End must be in DD/MMM (Ex:31/Jan) Format'  ) 
            Else 'Financial Year End must be in DD/MMM (Ex:31/Jan) Format' end from
            (
             select id,IncorporationDate,ImportStatus,ErrorRemarks,Cast(Substring(FinancialYearEnd,0,charindex('/',FinancialYearEnd)) As Int) as 'DAY',Substring(FinancialYearEnd,charindex('/',FinancialYearEnd)+1,LEN(FinancialYearEnd))
             AS 'Month'  from ImportWFClient  where TransactionId=@TransactionId and (FinancialYearEnd is not null OR  FinancialYearEnd='')
             AND ID=@Id AND ClientRefNumber=@ClientId AND Name=@Clientname
             )kk
            where   case when  [month] in ('Feb')  and [day] Between 1 and 29 then 1
            when  [month] in ('Jan','Mar','May','Jul','Aug','Oct','Dec') and [day] Between 1 and 31 then 1
            when  [month] in ('Apr','Jun','Sep','Nov') and [day] Between 1 and 30 then 1 else 0  end=0
        END TRY
		      BEGIN CATCH
		             Declare @error nvarchar(max) = error_message();
					 If @error is not null
	                 begin 

		              UPDATE  ImportWFClient set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Financial Year End must be in DD/MMM (Ex:31/Jan) Format'  ) 
                      Else 'Financial Year End must be in DD/MMM (Ex:31/Jan) Format' end ,ImportStatus=0    where  TransactionId=@TransactionId AND ID=@Id AND ClientRefNumber=@ClientId AND Name=@Clientname
		              
	                  End 
               END CATCH

	        


    Begin Try 
          	update kk set kk.ImportStatus=
            case when  [month]=2 and [day] Between 1 and 29 then 1
            when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
            when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'IncorporationDate must be in DD/MM/YYYY (Ex:31/01/1992) Format'  ) 
            Else 'IncorporationDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' end from
            (
             select id,IncorporationDate,ImportStatus,ErrorRemarks,SUBSTRING(IncorporationDate,1,Charindex('/',IncorporationDate)-1) as 'DAY',SUBSTRING(IncorporationDate,Charindex('/',IncorporationDate)+1,Charindex('/',SUBSTRING(IncorporationDate,Charindex('/',IncorporationDate)+1,LEN(IncorporationDate)))-1)
             AS 'Month'  from ImportWFClient  where TransactionId=@TransactionId and (IncorporationDate is not null OR  IncorporationDate='')
             AND ID=@Id AND ClientRefNumber=@ClientId AND Name=@Clientname
             )kk
            where  case when  [month]=2 and [day] Between 1 and 29 then 1
            when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
            when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
    END TRY
		   BEGIN CATCH
		             Declare @error1 nvarchar(max) = error_message();
					 If @error1 is not null
	                 begin 

		              UPDATE  ImportWFClient set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'IncorporationDate must be in DD/MM/YYYY (Ex:31/01/1992) Format'  ) 
                      Else 'IncorporationDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' end ,ImportStatus=0    where  TransactionId=@TransactionId AND ID=@Id AND ClientRefNumber=@ClientId AND Name=@Clientname
	                  End 
		   END CATCH

		  -- --===========================================03.12.2019

		  --  UPDATE  ImportWFClient set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'SystemRefNo Already Exists Please entered the correct information.')
    --      Else 'SystemRefNo Already Exists Please entered the correct information.' end
		  --WHERE TransactionId=@TransactionId  AND ID=@Id AND ClientRefNumber=@ClientId AND Name=@Clientname    AND ClientRefNumber IS NOT NULL AND  ClientRefNumber IN
	   --    (
		  -- select Distinct SystemRefNo  from workflow.client where CompanyId=@companyId AND SystemRefNo IS NOT NULL
		  -- )
		  
		  
		  --UPDATE  ImportWFClient set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'ClientName Already Exists Please entered the correct information.')
    --      Else 'ClientName Already Exists Please entered the correct information.' end
		  --WHERE TransactionId=@TransactionId AND ID=@Id AND ClientRefNumber=@ClientId AND Name=@Clientname AND name IS NOT NULL AND  name IN
	   --    (
		  -- select Distinct name  from workflow.client where CompanyId=@companyId AND name IS NOT NULL
		  -- )
		  -- 		   --===========================================03.12.2019
		   		
	 	          Update ImportWFClient set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please Check the Contact') 
                  Else 'Please Check the Contact' end , ImportStatus=0
	              where  ClientRefNumber is not null and TransactionId=@TransactionId and (ImportStatus<>0 or ImportStatus is null)  and ClientRefNumber in 
	              (
		          select Distinct ClientRefNumber  from ImportWFContacts  where TransactionId=@TransactionId AND ImportStatus=0
		          )


		   	      update ImportWFClient set ErrorRemarks=case when charindex(',',ErrorRemarks)=1 then SUBSTRING(ErrorRemarks,2,len(ErrorRemarks))
		          else ErrorRemarks  end,ImportStatus=0  where TransactionId=@TransactionId AND ErrorRemarks IS NOT NULL



				  
---============================================  Contact Valiation ===================================================================================

                    Update ImportWFContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please check Client')
                     Else  'Please check Client' end, ImportStatus=0
		             where  ClientRefNumber is NOT null and TransactionId=@TransactionId  and (ImportStatus<>0 or ImportStatus is null) AND ClientRefNumber IN 
                   (SELECT Distinct ClientRefNumber FROM ImportWFClient  where  ClientRefNumber is not null and TransactionId=@TransactionId and ImportStatus=0)

				    Update ImportWFContacts set ErrorRemarks = case when charindex(',',ErrorRemarks)=1 then SUBSTRING(ErrorRemarks,2,len(ErrorRemarks))
	               else ErrorRemarks  end, ImportStatus=0 where   TransactionId=@TransactionId AND ErrorRemarks IS NOT NULL

 --============================================================== Contact Validation  End =====================================================

--===================================================================================================================================================
    IF  Exists (  SELECT Distinct ID Name FROM ImportWFClient where  TransactionId=@TransactionId   AND ID=@Id AND ClientRefNumber=@ClientId AND Name=@Clientname  and (ImportStatus<>0 or ImportStatus is null))
	       BEGIN 

			 IF  Exists (select Distinct ClientRefNumber  from ImportWFContacts  where  ClientRefNumber=@ClientId and TransactionId=@TransactionId  and  ( ImportStatus<>0 oR  ImportStatus IS NULL))
			  BEGIN

		    If Not  Exists  (select Distinct SystemRefNo  from workflow.client where CompanyId=@companyId and SystemRefNo=@ClientId and SystemRefNo is not null)
	          BEGIN 
			  
		    If Not  Exists  (select Distinct name  from workflow.client where CompanyId=@companyId and name=@Clientname and name is not null)
	          BEGIN  

			 If  Exists ( select  id  from Common.TermsOfPayment where  Name=@CreditTerms and CompanyId=@companyId and name is not null ) -- CHECK CreditTermsID IN  Common.TermsOfPayment TABLE
			  BEGIN

		
					   ------------ SET ClienttTypeId,IdTypeId,CreditTermsId,EmailJson,MobileJson FOR JSON
					            
								set @ClientTypeId = (select  id  from Common.AccountType where  Name=@ClienttType and CompanyId=@companyId)
								set @IdTypeId= (	select Distinct top 1  It.Id  from Common.IdType It
		                                            inner join Common.AccountTypeIdType Att on att.IdTypeId=it.Id
		                                            inner join  Common.AccountType atp on atp.id=att.AccountTypeId
		                                            where  it.Name=@IdType and it.CompanyId=@companyId and atp.CompanyId=@companyId  and atp.Name=@ClienttType)
								set @CreditTermsId= (select  id  from Common.TermsOfPayment where  Name=@CreditTerms and CompanyId=@companyId)
 								Set @EmailJson =(Select 'Email' As 'key',Email As 'value' From ImportWFClient Where ClientRefNumber=@ClientId AND ID=@Id and name=@Clientname AND Email IS NOT NULL and TransactionId=@TransactionId  For Json Auto)
                                Set @MobileJson =(Select 'Phone' As 'key',Mobile As 'value' From ImportWFClient Where ClientRefNumber=@ClientId AND ID=@Id and name=@Clientname AND Mobile  IS NOT NULL and TransactionId=@TransactionId For Json Auto)
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
                                Begin  
								 set @ClientId_New =NewId()
								  --============================ insert into  workflow.client table ====================================
									  Insert Into  workflow.client (Id,SystemRefNo,Name,CompanyId,ClientTypeId,IdtypeId,ClientIdNo,Communication,TermsOfPaymentId,Industry,IncorporationDate,CountryOfIncorporation,
                                      FinancialYearEnd,PrincipalActivities,ClientStatus,UserCreated,CreatedDate,Status)  

									  select @ClientId_New as Id ,ClientRefNumber as SystemRefNo, Name,@companyId as CompanyId,@ClientTypeId as ClientTypeId,	@IdTypeId as IdtypeId,
									  IdentificationNumber as ClientIdNo,@Jsondata as Communication,@CreditTermsId as TermsOfPaymentId,Industry,	CONVERT(datetime2,IncorporationDate,103) as IncorporationDate,	
									  IncorporationCountry as CountryOfIncorporation,	case when  FinancialYearEnd is not null and FinancialYearEnd <>' ' then 
	                                cast(REPLACE( FinancialYearEnd, '/', ' ') + cast(datepart(year, getutcdate()) as char(4)) as datetime2)  end  as FinancialYearEnd,PrinicipalActivities,'Active' as ClientStatus,'system' as UserCreated,
									  getutcdate() as CreatedDate,1 as Status from ImportWFClient where id=@Id and ClientRefNumber=@ClientId and name=@Clientname and  TransactionId=@TransactionId	

									--======================== insert into workflow.clientstatuschange table ===========================
									  Insert Into workflow.clientstatuschange (Id,CompanyId,ClientId,State,ModifiedBy,ModifiedDate)

								      select Newid(),@companyId as CompanyId,@ClientId_New  as ClientId,'Active'as State,'system' as ModifiedBy,getutcdate() as ModifiedDate from ImportWFClient
                                      where id=@Id and ClientRefNumber=@ClientId  and  TransactionId=@TransactionId	

									   Update ImportWFClient Set ErrorRemarks=null,ImportStatus=1 where id=@Id and ClientRefNumber=@ClientId  and name=@Clientname and  TransactionId=@TransactionId	
								END
	                    
				END
					  --ELSE 
					  --BEGIN 
			 		 -- UPDATE  ImportWFClient set ErrorRemarks='Please Insert Seedata in CreditTerms' where id=@Id and ClientRefNumber=@ClientId  and name=@Clientname and  TransactionId=@TransactionId	
			 		 -- UPDATE ImportWFClient set ImportStatus=0  where id=@Id and ClientRefNumber=@ClientId  and name=@Clientname and  TransactionId=@TransactionId	
					  --END
				 END
				  --   ELSE 
					 --BEGIN 
			 		-- UPDATE  ImportWFClient set ErrorRemarks='ClientName Already Exists Please entered the correct information.'  where id=@Id and ClientRefNumber=@ClientId and name=@Clientname and  TransactionId=@TransactionId	
			 		-- UPDATE ImportWFClient set ImportStatus=0  where id=@Id and ClientRefNumber=@ClientId and name=@Clientname and  TransactionId=@TransactionId	
				  --   END
				END
					 --ELSE 
					 --BEGIN 
			 		-- UPDATE  ImportWFClient set ErrorRemarks='SystemRefNo Already Exists Please entered the correct information.'  where id=@Id and ClientRefNumber=@ClientId and name=@Clientname and  TransactionId=@TransactionId	
			 		-- UPDATE ImportWFClient set ImportStatus=0  where id=@Id and ClientRefNumber=@ClientId  and name=@Clientname and  TransactionId=@TransactionId	
					 --END 
			
			     END
					 --ELSE 
					 --BEGIN 
			 		-- UPDATE  ImportWFClient set ErrorRemarks='Please enter the Primary Contact'   where id=@Id and ClientRefNumber=@ClientId and name=@Clientname and  TransactionId=@TransactionId	
			 		-- UPDATE ImportWFClient set ImportStatus=0  where id=@Id and ClientRefNumber=@ClientId  and name=@Clientname and  TransactionId=@TransactionId	
					 --END 
		
			    End
		

		       --================================================================================03.12.2019
                    COMMIT TRANSACTION;
                    END TRY
                    BEGIN CATCH
                    Declare @ErrorMessage Nvarchar(4000)=error_message();
                    ROLLBACK;
                    If @ErrorMessage is not null
	                begin 

		            UPDATE  ImportWFClient set ErrorRemarks=@ErrorMessage    where id=@Id and ClientRefNumber=@ClientId  and name=@Clientname and  TransactionId=@TransactionId	
		            UPDATE  ImportWFClient set ImportStatus=0  where id=@Id and ClientRefNumber=@ClientId  and name=@Clientname and  TransactionId=@TransactionId	
	                
					End 
                    END CATCH
		  --================================================================================03.12.2019



		
		fetch next from ClientId_Get Into @Id,@ClientId,@ClienttType ,@IdType,@CreditTerms,@Clientname 
	
		End
		Close ClientId_Get
		Deallocate ClientId_Get

        Declare @FailedCount int = (Select Count(*) from ImportWFClient Where TransactionId=@TransactionId and ImportStatus=0)
        Update Common.[Transaction] Set TotalRecords=(Select Count(*) from ImportWFClient Where TransactionId=@TransactionId ),
        FailedRecords=  (Case When @FailedCount>0 then @FailedCount else 0 end)   where Id=@TransactionId



	 	--------------------------
		 -- COMMIT TRANSACTION;
   --   END TRY
   --   BEGIN CATCH
	  --Declare @ErrorMessage Nvarchar(4000)
	  --ROLLBACK;
	  --Select @ErrorMessage=error_message();
	  --Raiserror(@ErrorMessage,16,1);
   --   END CATCH
	  ----------------------------------

	   	END





		
GO
