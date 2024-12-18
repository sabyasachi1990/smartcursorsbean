USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ImportEntities_validation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE Procedure  [dbo].[ImportEntities_validation]  
 --Exec [dbo].[ImportEntities_validation] 727,'A3741C1E-198A-4FA9-8C23-599300E995B6'
@CompanyId int,
@TransactionId UNIQUEIDENTIFIER

AS
BEGIN
DECLARE 
-- @companyId int=237,
--@TransactionId uniqueidentifier='D643FC9E-CDA9-4FFE-8AAE-61C995279288',
@EntityName AS NVARCHAR (MAX),
@AccountType AS NVARCHAR (MAX),
@IdType AS NVARCHAR (MAX), 
@CreditTerms AS NVARCHAR (MAX), 
@PaymentTerms AS NVARCHAR (MAX),
@COAName AS NVARCHAR (MAX),
@AccountTypeid AS BIGINT,
@IdTypeId AS BIGINT,
@CreditTermsId AS BIGINT,
@PaymentTermsId AS BIGINT,
@COAId AS BIGINT,
@TaxId AS BIGINT,
@Jsondata AS NVARCHAR (MAX),
@EmailJson AS NVARCHAR (MAX),
@MobileJson AS NVARCHAR (MAX),
@Id uniqueidentifier,
@Customer bigint,
@Nature nvarchar(100),
@Currency nvarchar(100),
@Vendor bigint, 
@VendorType nvarchar(100),
@DefaultTaxCode nvarchar(100),
@EntityId uniqueidentifier,
  @LocalAddress Nvarchar(Max),
@ForigenAddress Nvarchar(Max)


    --BEGIN TRANSACTION
    --BEGIN TRY

  Declare @bName bigint=COL_LENGTH('bean.Entity', 'Name')
  Declare @bGSTRegNo bigint=COL_LENGTH('bean.Entity', 'GSTRegNo')
  Declare @bIdNo bigint=COL_LENGTH('bean.Entity', 'IdNo')
  Declare @bCustCurrency bigint=COL_LENGTH('bean.Entity', 'CustCurrency')
  Declare @bCustNature bigint=COL_LENGTH('bean.Entity', 'CustNature     ')
  Declare @bVenCurrency bigint=COL_LENGTH('bean.Entity', 'VenCurrency')
  Declare @bVenNature bigint=COL_LENGTH('bean.Entity', 'VenNature')
  Declare @bVendorType bigint=COL_LENGTH('bean.Entity', 'VendorType')
  Declare @bCommunication bigint=COL_LENGTH('bean.Entity', 'Communication')

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
	Exec [dbo].[Import_Bean_ContactsDetailUPDATE_Validation]   @companyId,@TransactionId
	end 

	 --====================================== Entities Mandatory field ==================================================


	      Update ImportBeanContacts set PersonalLocalAddress = case when charindex(',',PersonalLocalAddress)=1 then SUBSTRING(PersonalLocalAddress,2,len(PersonalLocalAddress))
	       else PersonalLocalAddress  end where   TransactionId=@TransactionId AND PersonalLocalAddress IS NOT NULL

		   Update ImportBeanContacts set PersonalForeignAddress = case when charindex(',',PersonalForeignAddress)=1 then SUBSTRING(PersonalForeignAddress,2,len(PersonalForeignAddress))
	       else PersonalForeignAddress  end where   TransactionId=@TransactionId AND PersonalForeignAddress IS NOT NULL

		   Update ImportBeanContacts set EntityLocalAddress = case when charindex(',',EntityLocalAddress)=1 then SUBSTRING(EntityLocalAddress,2,len(EntityLocalAddress))
	       else EntityLocalAddress  end where   TransactionId=@TransactionId AND EntityLocalAddress IS NOT NULL


		   	   Update ImportBeanContacts set EntityForeignAddress = case when charindex(',',EntityForeignAddress)=1 then SUBSTRING(EntityForeignAddress,2,len(EntityForeignAddress))
	       else EntityForeignAddress  end where   TransactionId=@TransactionId AND EntityForeignAddress IS NOT NULL


		   update importEntities set LocalAddress=case when charindex(',',LocalAddress)=1 then SUBSTRING(LocalAddress,2,len(LocalAddress))
		   else LocalAddress  end  where TransactionId=@TransactionId AND  LocalAddress IS NOT NULL

		     update importEntities set Foreignaddress=case when charindex(',',Foreignaddress)=1 then SUBSTRING(Foreignaddress,2,len(Foreignaddress))
		   else Foreignaddress  end  where TransactionId=@TransactionId AND  Foreignaddress IS NOT NULL





	     Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the EntityName')
         Else 'Please enter the EntityName' end,ImportStatus=0 
	     where TransactionId=@TransactionId and EntityName is null ----and (ImportStatus<>0 or ImportStatus is null)

		


		Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the EntityName Length Less then ', CAST(@bName as nvarchar(100)))
        Else CONCAT('Please entered the EntityName Length Less then ', CAST(@bName as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  AND EntityName IS NOT NULL AND LEN(EntityName)>@bName


		Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the GSTRegistrationNumber Length Less then ', CAST(@bGSTRegNo as nvarchar(100)))
        Else CONCAT('Please entered the GSTRegistrationNumber Length Less then ', CAST(@bGSTRegNo as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and GSTRegistrationNumber is not null AND LEN(GSTRegistrationNumber)>@bGSTRegNo 

		Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the EntityIdentificationNumber Length Less then ', CAST(@bIdNo as nvarchar(100)))
        Else CONCAT('Please entered the EntityIdentificationNumber Length Less then ', CAST(@bIdNo as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityIdentificationNumber is not null  AND LEN(EntityIdentificationNumber)>@bIdNo


		Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the CustCurrency Length Less then ', CAST(@bCustCurrency as nvarchar(100)))
        Else CONCAT('Please entered the CustCurrency Length Less then ', CAST(@bCustCurrency as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and CustCurrency is not null AND LEN(CustCurrency)>@bCustCurrency

		Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the CustNature Length Less then ', CAST(@bCustNature as nvarchar(100)))
        Else CONCAT('Please entered the CustNature Length Less then ', CAST(@bCustNature as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and CustNature is not null  AND LEN(CustNature)>@bCustNature


		Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the VenCurrency Length Less then ', CAST(@bVenCurrency as nvarchar(100)))
        Else CONCAT('Please entered the  VenCurrency Length Less then ', CAST(@bVenCurrency as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and VenCurrency is not null  AND LEN(VenCurrency)>@bVenCurrency

		Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the VenNature Length Less then ', CAST(@bVenNature as nvarchar(100)))
        Else CONCAT('Please entered the VenNature Length Less then ', CAST(@bVenNature as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and VenNature is not null  AND LEN(VenNature)>@bVenNature

		Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the VendorType Length Less then ', CAST(@bVendorType as nvarchar(100)))
        Else CONCAT('Please entered the VendorType Length Less then ', CAST(@bVendorType as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and VendorType is not null  AND LEN(VendorType)>@bVendorType

		Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the Phone and Email Length Less then ', CAST(@bCommunication as nvarchar(100)))
        Else CONCAT('Please entered the  Phone and Email Length Less then ',CAST(@bCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and Phone is not null and Email is not null   AND (LEN(Phone)+ len(Email))>@bCommunication

		Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the Phone Length Less then ', CAST(@bCommunication as nvarchar(100)))
        Else CONCAT('Please entered the Phone Length Less then ',CAST(@bCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and Phone is not null and Email is null   AND (LEN(Phone))>@bCommunication

	    Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please entered the Email Length Less then ', CAST(@bCommunication as nvarchar(100)))
        Else CONCAT('Please entered the Email Length Less then ',CAST(@bCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and Phone is null and Email is not null   AND ( len(Email))>@bCommunication

		 
		 -------===============================================================================02.12/2019
		  UPDATE  importEntities set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the Primary Contact')
          Else 'Please enter the Primary Contact' end
		  WHERE TransactionId=@TransactionId and EntityName IS NOT NULL  AND  Customer=1 ---- Vendor
		  AND   EntityName NOT IN
		    (
		        select Distinct EntityName  from ImportBeanContacts  where  TransactionId=@TransactionId AND  EntityName IS NOT NULL
		     )
			 --===============================================================================02.12/2019

			 -- UPDATE  importEntities set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the Primary Contact')
    --      Else 'Please enter the Primary Contact' end
		  --WHERE TransactionId=@TransactionId AND Customer=1 and Vendor=1  and EntityName IS NOT NULL AND  EntityName NOT IN
		  --  (
		  --      select Distinct EntityName  from ImportBeanContacts  where  TransactionId=@TransactionId AND  EntityName IS NOT NULL
		  --   )

			 --=======================================================================


	      Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please Check EntityType not matched in Seedata')
          Else 'Please Check EntityType not matched in Seedata' end,ImportStatus=0 
	      where TransactionId=@TransactionId and EntityType is not null ---and (ImportStatus<>0 or ImportStatus is null)
	      and EntityType Not in ( select Distinct Name  from Common.AccountType where   CompanyId=@companyId and Name is not null)


	  	  Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please Check EntityIdentificationType not matched in Seedata ')
          Else 'Please Check EntityIdentificationType not matched in Seedata ' end,ImportStatus=0 
          where TransactionId=@TransactionId and EntityIdentificationType is not null ---and (ImportStatus<>0 or ImportStatus is null)
	      and EntityIdentificationType COLLATE DATABASE_DEFAULT  Not in ( select Distinct Name  from Common.IdType where   CompanyId=@companyId and Name is not null)



	      Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the CreditTerms')
          Else 'Please enter the CreditTerms' end,ImportStatus=0 
	      where TransactionId=@TransactionId and Customer=1 and  CreditTerms is null  ---and (ImportStatus<>0 or ImportStatus is null)

          Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the CustNature')
          Else 'Please enter the CustNature' end,ImportStatus=0 
	      where TransactionId=@TransactionId and Customer=1   and [CustNature] is null   ---and (ImportStatus<>0 or ImportStatus is null)

	  	  Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the CustCurrency')
          Else 'Please enter the CustCurrency' end,ImportStatus=0 
          where TransactionId=@TransactionId and Customer=1 and [CustCurrency] is null  ----and (ImportStatus<>0 or ImportStatus is null)


	  	  Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the PaymentTerms')
          Else 'Please enter the PaymentTerms'end,ImportStatus=0 
          where TransactionId=@TransactionId and Vendor=1 and  PaymentTerms is null  ---and (ImportStatus<>0 or ImportStatus is null)

	      Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the VendorType')
          Else 'Please enter the VendorType' end,ImportStatus=0 
	      where TransactionId=@TransactionId and Vendor=1 and  VendorType is null  ----and (ImportStatus<>0 or ImportStatus is null)


	  	  Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the VenNature')
          Else 'Please enter the VenNature' end,ImportStatus=0 
	      where TransactionId=@TransactionId and Vendor=1   and [VenNature] is null   ---and (ImportStatus<>0 or ImportStatus is null)

	  	  Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the VenCurrency')
          Else 'Please enter the VenCurrency' end,ImportStatus=0 
          where TransactionId=@TransactionId and Vendor=1 and [VenCurrency] is null  ---and (ImportStatus<>0 or ImportStatus is null)



          Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please Check DefaultCOA not matched in Seedata')
          Else 'Please Check DefaultCOA not matched in Seedata' end,ImportStatus=0 
          where TransactionId=@TransactionId and DefaultCOA is not null ---and (ImportStatus<>0 or ImportStatus is null)
	      and DefaultCOA   Not in ( select Distinct Name  from bean.ChartOfAccount where   CompanyId=@companyId and Name is not null)


	  	 Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please Check DefaultTaxCode not matched in Seedata')
         Else 'Please Check DefaultTaxCode not matched in Seedata' end,ImportStatus=0 
         where TransactionId=@TransactionId and DefaultTaxCode is not null ---and (ImportStatus<>0 or ImportStatus is null)
	     and DefaultTaxCode   Not in ( select Distinct Name  from [Bean].[TaxCode] where Name is not null  ) --where   CompanyId=@companyId


	     Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter atleast one Customer/Vendor')
         Else 'Please enter atleast one Customer/Vendor' end,ImportStatus=0 
         where TransactionId=@TransactionId and Customer is null  and  Vendor is null --- and (ImportStatus<>0 or ImportStatus is null)

	  	 Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter atleast one Customer/Vendor')
         Else 'Please enter atleast one Customer/Vendor' end,ImportStatus=0 
         where TransactionId=@TransactionId and Customer=0  and  Vendor=0  ----and (ImportStatus<>0 or ImportStatus is null)
	  
         update importEntities set ImportStatus=case when ISNUMERIC(Replace(Replace(Replace(Phone,'+','1'),' ','2'),'-','3'))=0 Then 0 end  ,ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Phone allows to enter only Numbers')
         Else 'Phone allows to enter only Numbers' end   
         where TransactionId=@TransactionId and Phone is not null ---and (ImportStatus<>0 or ImportStatus is null)
         and case when ISNUMERIC(Replace(Replace(Replace(Phone,'+','1'),' ','2'),'-','3'))=0 Then 0 end=0




	                      ---======================================================03.12.2019
				
		             UPDATE  importEntities set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'EntityName Already Exists Please entered the correct information.')
                     Else 'EntityName Already Exists Please entered the correct information.' end
		             WHERE   TransactionId = @TransactionId  AND EntityName IS NOT NULL AND  EntityName IN
	                  (
		              select Distinct Name  from Bean.Entity where CompanyId=@companyId AND Name IS NOT NULL
		              )
		

	                     ---======================================================03.12.2019

 --==============================================================  'Multi-Currency'   ===========================================================================================
		 if not exists( select * from   Common.Feature f
	                    inner join Common.CompanyFeatures cf on cf.FeatureId=f.Id
				        where cf.CompanyId=@CompanyId and f.Name='Multi-Currency' and VisibleStyle='SuperUser-CheckBox' and f.Status=1 and cf.Status=1)
		  begin
		  Update importEntities  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please Activate Multi-Currency super user level & In Bean general setting Activate Multi-Currency')
          Else 'Please Activate Multi-Currency super user level & In Bean general setting Activate Multi-Currency' end,ImportStatus=0 
          where  TransactionId=@TransactionId   and  CustCurrency  is not null and CustCurrency not in (select  BaseCurrency from  Common.Localization where CompanyId=@CompanyId)
		  end

		 if Not exists( select * from   Common.Feature f     
				       inner join Common.CompanyFeatures cf on cf.FeatureId=f.Id
				        where cf.CompanyId=@CompanyId and f.Name='Multi-Currency' and VisibleStyle='SuperUser-CheckBox' and f.Status=1  and cf.Status=1)
		 begin
		 Update importEntities  set VenCurrency=CustCurrency where  TransactionId=@TransactionId ---and (ImportStatus<>0 or ImportStatus is null)
		 and CustCurrency in (select  BaseCurrency from   Common.Localization where CompanyId=@CompanyId)
		 end

		  --update importEntities set ErrorRemarks=case when charindex(',',ErrorRemarks)=1 then SUBSTRING(ErrorRemarks,2,len(ErrorRemarks))
		  --else ErrorRemarks  end,ImportStatus=0  where TransactionId=@TransactionId AND ErrorRemarks IS NOT NULL


--====================================== Contacts Mandatory field ==================================================
          Update c set EntityPhone=PersonalPhone,EntityEmail=PersonalEmail,EntityLocalAddress=PersonalLocalAddress,EntityForeignAddress=PersonalForeignAddress 
	      from ImportBeanContacts C  where   C.TransactionId=@TransactionId and C.CopycommunicationandAddress=1

	       if Exists (select Name from ImportBeanContacts where Name is null and  TransactionId=@TransactionId)
	       begin
	       Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the Name')
           Else 'Please enter the Name' end, ImportStatus=0
	       where  Name is null and TransactionId=@TransactionId
	       end 

	       if Exists (select EntityName from ImportBeanContacts where EntityName is null  and TransactionId=@TransactionId)
	       begin
	       Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the EntityName')
           Else 'Please enter the EntityName' end, ImportStatus=0
	       where  EntityName is null and TransactionId=@TransactionId
	       end 



		    Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the FirstName Length ', CAST(@LcFirstName as nvarchar(100)))
        Else CONCAT('Please enter the FirstName Length ', CAST(@LcFirstName as nvarchar(100))) end , ImportStatus=0
		where  TransactionId=@TransactionId  and Name is not null  and len(Name)>@LcFirstName 

		Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the IdentificationNumber Length ', CAST(@LcIdentificationNumber as nvarchar(100)))
        Else CONCAT('Please enter the IdentificationNumber Length ', CAST(@LcIdentificationNumber as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and IdentificationNumber is not null  and len(IdentificationNumber)>@LcIdentificationNumber

		Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the CountryOfResidence Length Less Then ', CAST(@LcCountryOfResidence as nvarchar(100)))
        Else CONCAT('Please enter the CountryOfResidence Length Less Then ', CAST(@LcCountryOfResidence as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and CountryOfResidence is not null  and len(CountryOfResidence)>@LcCountryOfResidence

		Update ImportBeanContacts set ErrorRemarks =Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the Remarks Length Less Then ', CAST(@LcRemarks as nvarchar(100)))
        Else  CONCAT('Please enter the Remarks Length Less Then ', CAST(@LcRemarks as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and Remarks is not null  and len(Remarks)>@LcRemarks


		Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the Designation Length Less Then ', CAST(@LcDesignation as nvarchar(100)))
        Else  CONCAT('Please enter the Designation Length Less Then ', CAST(@LcDesignation as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and Designation is not null  and len(Designation)>@LcDesignation

	    Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the PersonalPhone and PersonalEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the PersonalPhone and PersonalEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and PersonalPhone is not null  and PersonalEmail is not null and (len(PersonalPhone)+len(PersonalEmail))>@LcCommunication

		 Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the CommunicationPersonalPhone Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the CommunicationPersonalPhone Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and PersonalPhone is not null  and PersonalEmail is null and (len(PersonalPhone))>@LcCommunication

		Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the CommunicationPersonalEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the CommunicationPersonalEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and PersonalPhone is null  and PersonalEmail is not null and (len(PersonalEmail))>@LcCommunication


		Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the EntityPhone and EntityEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the EntityPhone and EntityEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityPhone is not null  and EntityEmail is not null and (len(EntityPhone)+len(EntityEmail))>@LcCommunication

		Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the CommunicationEntityPhone Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the CommunicationEntityPhone Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityPhone is not null  and EntityEmail is null and (len(EntityPhone))>@LcCommunication

		Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the CommunicationEntityEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100)))
        Else  CONCAT('Please enter the CommunicationEntityEmail Length Less Then ', CAST(@LcCommunication as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityPhone is null  and EntityEmail is not null and (len(EntityEmail))>@LcCommunication

		Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the PersonalPhone Length Less Then ', CAST(@LcPhone as nvarchar(100)))
        Else  CONCAT('Please enter the PersonalPhone Length Less Then ', CAST(@LcPhone as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and PersonalPhone is not null  and len(PersonalPhone)>@LcPhone

		Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the EntityPhone Length Less Then', CAST(@LcPhone as nvarchar(100)))
        Else  CONCAT('Please enter the EntityPhone Length Less Then', CAST(@LcPhone as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId and EntityPhone is not null  and len(EntityPhone)>@LcPhone


		Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the PersonalEmail Length Less Then ', CAST(@LcEmail as nvarchar(100)))
        Else  CONCAT( 'Please enter the PersonalEmail Length Less Then ', CAST(@LcEmail as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and PersonalEmail is not  null and len(PersonalEmail)>@LcEmail


		Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please enter the EntityEmail Length Less Then ',CAST(@LcEmail as nvarchar(100)))
        Else  CONCAT('Please enter the EntityEmail Length Less Then ', CAST(@LcEmail as nvarchar(100))) end, ImportStatus=0
		where  TransactionId=@TransactionId  and EntityEmail is not null  and len(EntityEmail)>@LcEmail


		   if Exists (select PrimaryContacts from ImportBeanContacts where PrimaryContacts is null  and TransactionId=@TransactionId)
	       begin
		   Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the PrimaryContact')
           Else 'Please enter the PrimaryContact' end, ImportStatus=0
		   where  PrimaryContacts is null and TransactionId=@TransactionId
	       end 

	       if Exists (select ID from ImportBeanContacts where EntityEmail is null and EntityPhone is null and PersonalPhone is null and  PersonalEmail is null  and TransactionId=@TransactionId)
	       begin
		   Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please enter the Contact Communication')
           Else 'Please enter the Contact Communication' end, ImportStatus=0
		   where  EntityEmail is null and EntityPhone is null and PersonalPhone is null and  PersonalEmail is null and TransactionId=@TransactionId
	       end 

		   ------1 date
		   --Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Date of birth cannot be a future date')
     --      Else 'Date of birth cannot be a future date' end, ImportStatus=0
		   --where  CONVERT(datetime, DateofBirth, 103) > getutcdate() and  TransactionId=@TransactionId ---and (ImportStatus<>0 or ImportStatus is null)
		   --and id in (select ID from ImportBeanContacts  where  TransactionId=@TransactionId) ---and (ImportStatus<>0 or ImportStatus is null))
	    --   --1 date


	       Update ImportBeanContacts  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please Check IdentificationType not matched in Seedata')
           Else 'Please Check IdentificationType not matched in Seedata' end,ImportStatus=0 
	       where TransactionId=@TransactionId and IdentificationType is not null ---and (ImportStatus<>0 or ImportStatus is null)
	       and IdentificationType COLLATE DATABASE_DEFAULT  Not in ( select Distinct Name  from Common.IdType where   CompanyId=@companyId and Name is not null)

	  	   Update ImportBeanContacts  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please Check Designation not matched in control code')
           Else 'Please Check Designation not matched in control code' end,ImportStatus=0 
	       where TransactionId=@TransactionId and Designation is not null --and (ImportStatus<>0 or ImportStatus is null)
	       and Designation COLLATE DATABASE_DEFAULT  Not in (
               select Distinct CodeKey from Common.ControlCode c
			   inner join  Common.ControlCodeCategory cc on c.ControlCategoryId=cc.Id 
			   where CompanyId=@companyId  and CodeKey is not null
			   )

		   Update ImportBeanContacts  set ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please Check CountryOfResidence not matched in control code')
           Else 'Please Check CountryOfResidence not matched in control code' end,ImportStatus=0 
           where  TransactionId=@TransactionId and CountryOfResidence is not null ---and (ImportStatus<>0 or ImportStatus is null)
	       and CountryOfResidence COLLATE DATABASE_DEFAULT  Not in (
			   select Distinct CodeKey from Common.ControlCode c
			   inner join  Common.ControlCodeCategory cc on c.ControlCategoryId=cc.Id 
			   where CompanyId=@companyId  and CodeKey is not null 
			   )

		  update ImportBeanContacts set ImportStatus= case when ISNUMERIC(Replace(Replace(Replace(PersonalPhone,'+','1'),' ','2'),'-','3'))=0 Then 0 end  ,ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'PersonalPhone allows to enter only Numbers' )
          Else 'PersonalPhone allows to enter only Numbers'  end  
          where TransactionId=@TransactionId and PersonalPhone is not null --and (ImportStatus<>0 or ImportStatus is null)
          and case when ISNUMERIC(Replace(Replace(Replace(PersonalPhone,'+','1'),' ','2'),'-','3'))=0 Then 0 end=0

          update ImportBeanContacts set ImportStatus=case when ISNUMERIC(Replace(Replace(Replace(EntityPhone,'+','1'),' ','2'),'-','3'))=0 Then 0 end  ,ErrorRemarks=Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'EntityPhone allows to enter only Numbers'  )
          Else 'EntityPhone allows to enter only Numbers'   end  
          where TransactionId=@TransactionId and EntityPhone is not null ---and (ImportStatus<>0 or ImportStatus is null)
          and case when ISNUMERIC(Replace(Replace(Replace(EntityPhone,'+','1'),' ','2'),'-','3'))=0 Then 0 end=0

		 Update ImportBeanContacts  set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please check Salutation not matched in ControlCode')
         Else 'Please check Salutation not matched in ControlCode' end,ImportStatus=0 
         where  TransactionId=@TransactionId and Salutation is not null ---and (ImportStatus<>0 or ImportStatus is null)
	     and Salutation COLLATE DATABASE_DEFAULT  Not in 
		      (
			select Distinct CodeKey from Common.ControlCode c
			inner join  Common.ControlCodeCategory cc on c.ControlCategoryId=cc.Id 
			where CompanyId=@companyId  and CodeKey is not null and ControlCodeCategoryCode='Salutation'
			   )

		  Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please entered the correct EntityName')
          Else  'Please entered the correct EntityName' end, ImportStatus=0
		  where  EntityName is NOT null and TransactionId=@TransactionId AND EntityName NOT IN 
          (
		  SELECT Distinct EntityName FROM ImportEntities  where  EntityName is not null and TransactionId=@TransactionId
		  )

	

		  update importEntities set ErrorRemarks=case when charindex(',',ErrorRemarks)=1 then SUBSTRING(ErrorRemarks,2,len(ErrorRemarks))
		  else ErrorRemarks  end,ImportStatus=0  where TransactionId=@TransactionId AND ErrorRemarks IS NOT NULL

          Update ImportBeanContacts set ErrorRemarks = case when charindex(',',ErrorRemarks)=1 then SUBSTRING(ErrorRemarks,2,len(ErrorRemarks))
	      else ErrorRemarks  end, ImportStatus=0 where   TransactionId=@TransactionId AND ErrorRemarks IS NOT NULL

---==========================================================================================================================================================

        DECLARE Entityid_Get CURSOR
          FOR SELECT DISTINCT ID,EntityName,EntityType,EntityIdentificationType,CreditTerms,PaymentTerms,DefaultCOA,DefaultTaxCode
          FROM ImportEntities WHERE  TransactionId = @TransactionId
		   and EntityName not  in ( select Distinct Name  from Bean.Entity where CompanyId=@companyId AND Name IS NOT NULL )
		  
		   --- and (ImportStatus<>0 or ImportStatus is null) 
		  order by EntityName
        OPEN Entityid_Get
        FETCH NEXT FROM Entityid_Get INTO  @EntityId,@EntityName, @AccountType, @IdType,@CreditTerms, @PaymentTerms,@COAName,@DefaultTaxCode
		--, @TaxName
        WHILE @@FETCH_STATUS = 0
         BEGIN


		  --===================== 03.12.2019
		 
         Begin Transaction  
         Begin Try  
		 --==================== 03.12.2019

		 --========================================================================= Start Address check length =======================================================

	                      Select @LocalAddress=LocalAddress,@ForigenAddress=Foreignaddress
	                      From ImportEntities
	                      Where   TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and ( LocalAddress is not null or Foreignaddress is not null)

					 --================================ LocalAddress in  ClientCursor.Account table=========================================
					 
					  If @LocalAddress Is Not Null  
					  Begin
					  	
					  Create Table #Strng_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))

					  Insert Into #Strng_Splt(AddrName)
					  Select Value From string_split(@LocalAddress,',')

					  IF Exists( Select AddrName From #Strng_Splt Where Id=1 AND LEN(AddrName) >@LcBlockHouseNo )
					  begin
					  Update ImportEntities set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress BlockHouseNo Length Less then', CAST(@LcBlockHouseNo as nvarchar(100)))
                      Else CONCAT('Please enter the BlockHouseNo Length Less then', CAST(@LcBlockHouseNo as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and LocalAddress is not null
					  end
					   
					  if Exists (Select AddrName From #Strng_Splt Where Id=2 AND LEN(AddrName) >@LcStreet)
					  begin
					  Update ImportEntities set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress Street Length Less then', CAST(@LcStreet as nvarchar(100)))
                      Else CONCAT('Please enter the Street Length Less then', CAST(@LcStreet as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and LocalAddress is not null
					  end
						
					  if Exists (Select AddrName From #Strng_Splt Where Id=3 AND LEN(AddrName) >@LcUnitNo)
					  begin
					  Update ImportEntities set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100)))
                      Else CONCAT('Please enter the UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and LocalAddress is not null
					  end 

					  if Exists (Select AddrName From #Strng_Splt Where Id=4 AND LEN(AddrName) >@LcBuildingEstate)
					  begin
					  Update ImportEntities set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress BuildingEstate Length Less then', CAST(@LcBuildingEstate as nvarchar(100)))
                      Else CONCAT('Please enter the BuildingEstate Length Less then', CAST(@LcBuildingEstate as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and LocalAddress is not null
					  end 

					  if Exists (Select AddrName From #Strng_Splt Where Id=5 AND LEN(AddrName) >@LcCity)
					  begin
					  Update ImportEntities set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress City Length Less then', CAST(@LcCity as nvarchar(100)))
                      Else CONCAT('Please enter the City Length Less then', CAST(@LcCity as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and LocalAddress is not null
					  end

					   if Exists (Select AddrName From #Strng_Splt Where Id=5 AND LEN(AddrName) >@LcState)
					  begin
					  Update ImportEntities set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress state Length Less then', CAST(@LcState as nvarchar(100)))
                      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and LocalAddress is not null
					  end

					   if Exists (Select AddrName From #Strng_Splt Where Id=5 AND LEN(AddrName) >@LcCountry)
					  begin
					  Update ImportEntities set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress Country Length Less then ', CAST(@LcCountry as nvarchar(100)))
                      Else CONCAT('Please enter the Country Length Less then ', CAST(@LcCountry as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and LocalAddress is not null
					  end

					  if Exists (Select AddrName From #Strng_Splt Where Id=6 AND LEN(AddrName) >@LcPostalCode)
					  begin
					  Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100)))
                      Else CONCAT('Please enter the PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and LocalAddress is not null
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
					  Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress state Length Less then', CAST(@LcState as nvarchar(100)))
                      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and Foreignaddress is not null
					  end

					  if Exists (Select AddrName From #Strng1_Splt Where Id=2 AND LEN(AddrName) >@LcUnitNo)
					  begin
					  Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100)))
                      Else CONCAT('Please enter the UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and Foreignaddress is not null
					  end 

                      if Exists (Select AddrName From #Strng1_Splt Where Id=3 AND LEN(AddrName) >@LcCity)
					  begin
					  Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress City Length Less then', CAST(@LcCity as nvarchar(100)))
                      Else CONCAT('Please enter the City Length Less then', CAST(@LcCity as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and Foreignaddress is not null
					  end

					  
                      if Exists (Select AddrName From #Strng1_Splt Where Id=4 AND LEN(AddrName) >@LcState)
					  begin
					  Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress state Length Less then', CAST(@LcState as nvarchar(100)))
                      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and Foreignaddress is not null
					  end
					  
                      if Exists (Select AddrName From #Strng1_Splt Where Id=5 AND LEN(AddrName) >@LcCountry)
					  begin
					  Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress Country Length Less then ', CAST(@LcCountry as nvarchar(100)))
                      Else CONCAT('Please enter the Country Length Less then ', CAST(@LcCountry as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and Foreignaddress is not null
					  end
						
					  if Exists (Select AddrName From #Strng1_Splt Where Id=6 AND LEN(AddrName) >@LcPostalCode)
					  begin
					  Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100)))
                      Else CONCAT('Please enter the PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName  and Foreignaddress is not null
					  end
					  drop table #Strng1_Splt
					  end 

					  
    --============================================================================end Address check length ==========================================================


	                 --         ---======================================================03.12.2019

		                -- UPDATE  importEntities set ErrorRemarks=  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'EntityName Already Exists Please entered the correct information.')
                  --       Else 'EntityName Already Exists Please entered the correct information.' end
		                -- WHERE   TransactionId = @TransactionId  and EntityName=@EntityName AND id = @EntityId AND EntityName IS NOT NULL AND  EntityName IN
	                 --     (
		                --  select Distinct Name  from Bean.Entity where CompanyId=@companyId AND Name IS NOT NULL
		                --  )
					  	
						
	                 --         ---======================================================03.12.2019

	 	                Update ImportEntities set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',', 'Please Check the Contact') 
                        Else 'Please Check the Contact' end , ImportStatus=0
	                    where  EntityName is not null and TransactionId=@TransactionId and (ImportStatus<>0 OR ImportStatus IS NULL)    and EntityName in 
	                    (
		                select Distinct EntityName  from ImportBeanContacts  where TransactionId=@TransactionId AND ImportStatus=0
		                )
						



					  	  
						-- --===========================
					 --   Update ImportEntities set ErrorRemarks =  null , ImportStatus=null
	     --               where  EntityName is not null and TransactionId=@TransactionId and Vendor=1 and (ImportStatus<>0 OR ImportStatus IS NULL)    and EntityName in 
	     --               (
		    --            select Distinct EntityName  from ImportBeanContacts  where TransactionId=@TransactionId AND ImportStatus=0
		    --            )
						----=====================================

					   update ImportEntities set ErrorRemarks=case when charindex(',',ErrorRemarks)=1 then SUBSTRING(ErrorRemarks,2,len(ErrorRemarks))
		              else ErrorRemarks  end,ImportStatus=0  where TransactionId=@TransactionId AND ErrorRemarks IS NOT NULL


	  
---============================================  Contact Valiation ===================================================================================

                    Update ImportBeanContacts set ErrorRemarks = Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'Please check Entities')
                     Else  'Please check Entities' end, ImportStatus=0
		             where  EntityName is NOT null and TransactionId=@TransactionId  and (ImportStatus<>0 or ImportStatus is null) AND EntityName IN 
                   (SELECT Distinct EntityName FROM ImportEntities  where  EntityName is not null and TransactionId=@TransactionId and ImportStatus=0)

				    Update ImportBeanContacts set ErrorRemarks = case when charindex(',',ErrorRemarks)=1 then SUBSTRING(ErrorRemarks,2,len(ErrorRemarks))
	               else ErrorRemarks  end, ImportStatus=0 where   TransactionId=@TransactionId AND ErrorRemarks IS NOT NULL

 --============================================================== Contact Validation  End =====================================================

		 IF  Exists(SELECT DISTINCT ID FROM ImportEntities WHERE  TransactionId = @TransactionId   and id=@EntityId and EntityName=@EntityName and (ImportStatus<>0 or ImportStatus is null)) 
		 BEGIN
		 IF  Exists (select Distinct EntityName  from ImportBeanContacts  where  EntityName=@EntityName and TransactionId=@TransactionId  and  ( ImportStatus<>0 oR  ImportStatus IS NULL))
		 BEGIN
		 IF Not EXISTS (SELECT DISTINCT Name FROM bean.Entity WHERE  CompanyId = @Companyid and Name=@EntityName)
		 BEGIN
 
              SET @AccountTypeid = (SELECT id FROM   Common.AccountType WHERE  Name = @AccountType AND CompanyId = @companyId)
              SET @IdTypeId = ( select Distinct top 1  It.Id  from Common.IdType It
		                        inner join Common.AccountTypeIdType Att on att.IdTypeId=it.Id
		                        inner join  Common.AccountType atp on atp.id=att.AccountTypeId
		                        where  it.Name=@IdType and it.CompanyId=@companyId and atp.CompanyId=@companyId  and atp.Name=@AccountType)
              SET @CreditTermsId = (SELECT id FROM   Common.TermsOfPayment WHERE  Name = @CreditTerms AND CompanyId = @companyId)
              SET @PaymentTermsId = (SELECT id FROM   Common.TermsOfPayment WHERE  Name = @PaymentTerms  AND CompanyId = @companyId)
              SET @COAId = (SELECT id FROM   bean.ChartOfAccount WHERE  Name = @COAName AND CompanyId = @companyId)
			  SET @TaxId = (SELECT top 1 id FROM   Bean.TaxCode WHERE  Name = @DefaultTaxCode --and CompanyId=@companyId
			  )

              Set @EmailJson = (Select 'Email' As 'key',Email As 'value' FROM   ImportEntities WHERE  EntityName=@EntityName and Email is not null  and  TransactionId=@TransactionId FOR  JSON AUTO)
              Set @MobileJson = (Select 'Phone' As 'key',Phone As 'value' FROM   ImportEntities WHERE  EntityName=@EntityName and Phone is not null and TransactionId=@TransactionId FOR   JSON AUTO)
          
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
						--set  @Id=NewId()
                    INSERT INTO Bean.entity (Id, CompanyId, Name, TypeId, IdTypeId, IdNo, GSTRegNo, IsCustomer, CustTOPId, CustCreditLimit, CustNature, VenNature, CustCurrency,
					VenCurrency, IsVendor, VenTOPId, VendorType, COAId,TaxId,Communication,CreatedDate,UserCreated,IsShowPayroll)

                    SELECT NewId(),@CompanyId,EntityName AS Name,@AccountTypeid AS TypeId,@IdTypeId AS IdTypeId,EntityIdentificationNumber AS IdNo,GSTRegistrationNumber AS GSTRegNo,Customer AS IsCustomer,@CreditTermsId AS CustTOPId,
                    CreditLimit AS CustCreditLimit,[CustNature]  AS CustNature,[VenNature]  AS VenNature, [CustCurrency]  AS CustCurrency,
                    [VenCurrency] as  VenCurrency,Vendor AS IsVendor,@PaymentTermsId AS VenTOPId,VendorType,@COAId AS COAId,@TaxId AS TaxId
					,@Jsondata AS Communication,GETUTCDATE() as CreatedDate,'system' as UserCreated ,1 as IsShowPayroll FROM ImportEntities WHERE  TransactionId = @TransactionId  and EntityName=@EntityName AND id = @EntityId
					     
                    UPDATE ImportEntities SET ErrorRemarks = NULL,ImportStatus = 1 WHERE TransactionId = @TransactionId AND EntityName=@EntityName
                   END                             
                
                     --ELSE
                     --BEGIN
                     --UPDATE ImportEntities SET ErrorRemarks = 'EntityName Already Exists Please entered the correct information.' WHERE  EntityName=@EntityName
                     --UPDATE ImportEntities SET ImportStatus = 0 WHERE  EntityName=@EntityName AND TransactionId = @TransactionId
                     --END
			  end
			  --================================================================== vendar

			   else 
	     IF   not Exists (select Distinct EntityName  from ImportBeanContacts  where  EntityName=@EntityName and TransactionId=@TransactionId  and  ( ImportStatus<>0 oR  ImportStatus IS NULL))
		 BEGIN
		 IF Not EXISTS (SELECT DISTINCT Name FROM bean.Entity WHERE  CompanyId = @Companyid and Name=@EntityName)
		 BEGIN

		 IF EXISTS (SELECT DISTINCT ID FROM ImportEntities WHERE  TransactionId = @TransactionId  and EntityName=@EntityName AND id = @EntityId AND Vendor=1 and Customer<>1)
		 BEGIN
 
              SET @AccountTypeid = (SELECT id FROM   Common.AccountType WHERE  Name = @AccountType AND CompanyId = @companyId)
              SET @IdTypeId = ( select Distinct top 1  It.Id  from Common.IdType It
		                        inner join Common.AccountTypeIdType Att on att.IdTypeId=it.Id
		                        inner join  Common.AccountType atp on atp.id=att.AccountTypeId
		                        where  it.Name=@IdType and it.CompanyId=@companyId and atp.CompanyId=@companyId  and atp.Name=@AccountType)
              SET @CreditTermsId = (SELECT id FROM   Common.TermsOfPayment WHERE  Name = @CreditTerms AND CompanyId = @companyId)
              SET @PaymentTermsId = (SELECT id FROM   Common.TermsOfPayment WHERE  Name = @PaymentTerms  AND CompanyId = @companyId)
              SET @COAId = (SELECT id FROM   bean.ChartOfAccount WHERE  Name = @COAName AND CompanyId = @companyId)
			  SET @TaxId = (SELECT top 1 id FROM   Bean.TaxCode WHERE  Name = @DefaultTaxCode --and CompanyId=@companyId
			  )

              Set @EmailJson = (Select 'Email' As 'key',Email As 'value' FROM   ImportEntities WHERE  EntityName=@EntityName and Email is not null  and  TransactionId=@TransactionId FOR  JSON AUTO)
              Set @MobileJson = (Select 'Phone' As 'key',Phone As 'value' FROM   ImportEntities WHERE  EntityName=@EntityName and Phone is not null and TransactionId=@TransactionId FOR   JSON AUTO)
          
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
						--set  @Id=NewId()
                    INSERT INTO Bean.entity (Id, CompanyId, Name, TypeId, IdTypeId, IdNo, GSTRegNo, IsCustomer, CustTOPId, CustCreditLimit, CustNature, VenNature, CustCurrency,
					VenCurrency, IsVendor, VenTOPId, VendorType, COAId,TaxId,Communication,CreatedDate,UserCreated,IsShowPayroll)

                    SELECT NewId(),@CompanyId,EntityName AS Name,@AccountTypeid AS TypeId,@IdTypeId AS IdTypeId,EntityIdentificationNumber AS IdNo,GSTRegistrationNumber AS GSTRegNo,Customer AS IsCustomer,@CreditTermsId AS CustTOPId,
                    CreditLimit AS CustCreditLimit,[CustNature]  AS CustNature,[VenNature]  AS VenNature, [CustCurrency]  AS CustCurrency,
                    [VenCurrency] as  VenCurrency,Vendor AS IsVendor,@PaymentTermsId AS VenTOPId,VendorType,@COAId AS COAId,@TaxId AS TaxId
					,@Jsondata AS Communication,GETUTCDATE() as CreatedDate,'system' as UserCreated ,1 as IsShowPayroll FROM ImportEntities WHERE  TransactionId = @TransactionId  and EntityName=@EntityName AND id = @EntityId
					     
                    UPDATE ImportEntities SET ErrorRemarks = NULL,ImportStatus = 1 WHERE TransactionId = @TransactionId AND EntityName=@EntityName
                   END    
				   end 
				   end                          
                

			  --====================================================================vendar

	         End



			 
		       --================================================================================03.12.2019
                COMMIT TRANSACTION;
                END TRY
                BEGIN CATCH
                Declare @ErrorMessage Nvarchar(4000)=error_message();
                ROLLBACK;
                If @ErrorMessage is not null
	                begin 

		            UPDATE  ImportEntities set ErrorRemarks=@ErrorMessage   where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName
		            UPDATE  ImportEntities set ImportStatus=0   where  TransactionId=@TransactionId  AND ID=@EntityId and EntityName=@EntityName
	                
					End 
                END CATCH
		  --================================================================================03.12.2019



                FETCH NEXT FROM Entityid_Get INTO  @EntityId,@EntityName, @AccountType, @IdType,@CreditTerms, @PaymentTerms,@COAName,@DefaultTaxCode
	
         END
        CLOSE Entityid_Get;
        DEALLOCATE Entityid_Get;
        DECLARE @FailedCount AS INT = (SELECT Count(*) FROM   ImportEntities WHERE  TransactionId = @TransactionId AND ImportStatus = 0)
        UPDATE Common.[Transaction] SET TotalRecords = (SELECT Count(*) FROM   ImportEntities WHERE  TransactionId = @TransactionId),
               FailedRecords =  ISNULL(@FailedCount,0)  WHERE  Id = @TransactionId
END 


    --    COMMIT TRANSACTION;
    --END TRY
    --BEGIN CATCH
    --    ROLLBACK TRANSACTION Throw;
    --END CATCH





 
GO
