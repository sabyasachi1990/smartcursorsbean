USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_ContactsDetailUPADTE_Validation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure  [dbo].[Import_ContactsDetailUPADTE_Validation] 
  --- exec [dbo].[Import_ContactsDetail_Validation]  1558,'6B4E5F46-D4AB-45B6-8573-09D4DB2FF550'
@companyId int,
@TransactionId uniqueidentifier
AS
BEGIN 

 Declare --@companyId int=809,            
 @AccountId Uniqueidentifier,
 @ContactId Uniqueidentifier,
 @ContactIdDeatialId Uniqueidentifier,
 @MasterId NVARCHAR(MAX),
 @COMMN Nvarchar(max),
 @COMMNDeatil Nvarchar(max),
 @LocalAddress Nvarchar(Max),
 @PerLocalAddress Nvarchar(Max),
 @EntyLocalAddress Nvarchar(Max),
 @LclAdrs_Vrbl Nvarchar(Max),
 @New_Loc_AddressBookId Uniqueidentifier,
 @New_Frn_AddressBookId Uniqueidentifier,
 @ForigenAddress Nvarchar(Max),
 @PerForigenAddress Nvarchar(Max),
 @EntyForigenAddress Nvarchar(Max),
 @BlockHouseNo Nvarchar(512),
 @Street Nvarchar(2000),
 @UnitNo Nvarchar(512),
 @BuildingEstate Nvarchar(512),
 @PostalCode Nvarchar(20),
 @Country Nvarchar(512),
 @PerEmailJson  Nvarchar(max),
 @PerMobileJson  Nvarchar(max),
 @EntEmailJson  Nvarchar(max),
 @EntMobileJson  Nvarchar(max),
 @PerJsondata  Nvarchar(max),
 @EntJsondata Nvarchar(max),
 @ContactName Nvarchar(max),
 @IdType Nvarchar(max),
 @IdNumber Nvarchar(max),
 @id Uniqueidentifier,
 @IdTypeID  Nvarchar(max),
 @AccountNewId Uniqueidentifier,
 @ContactNewId Uniqueidentifier,
 @ContactIdDeatialNewId Uniqueidentifier,
 @AccountName Nvarchar(max),
 @AccountNewName Nvarchar(max)
 --===================Contact Common.AddressBook check column length=========================================
 Declare @LcBlockHouseNo bigint=COL_LENGTH('Common.AddressBook', 'BlockHouseNo')
 Declare @LcStreet bigint=COL_LENGTH('Common.AddressBook', 'Street')
 Declare @LcUnitNo bigint=COL_LENGTH('Common.AddressBook', 'UnitNo')
 Declare @LcBuildingEstate bigint=COL_LENGTH('Common.AddressBook', 'BuildingEstate')
 Declare @LcCity bigint=COL_LENGTH('Common.AddressBook', 'City')
 Declare @LcPostalCode bigint=COL_LENGTH('Common.AddressBook', 'PostalCode')
 Declare @LcState bigint=COL_LENGTH('Common.AddressBook', 'State')
 Declare @LcCountry bigint=COL_LENGTH('Common.AddressBook', 'Country')
 Declare @LcPhone bigint=COL_LENGTH('Common.AddressBook', 'Phone')
 Declare @LcEmail bigint=COL_LENGTH('Common.AddressBook', 'Email')
 --============ update DateofBirth null where  DateofBirth=''========================================
 UPDATE  ImportContacts set DateofBirth=null
 where  DateofBirth=''  and  TransactionId=@TransactionId
 Declare ContactIdUpdate_Get Cursor For
 select  Id,Name as ContactName,   IdentificationType , IdentificationNumber,MasterId from ImportContacts where TransactionId=@TransactionId 
        ---AND ( ImportStatus<>0 oR  ImportStatus IS NULL)  ---and  id not in (select DISTINCT   Id from Common.Contact where CompanyId=@companyId)
 Open ContactIdUpdate_Get
 fetch next from ContactIdUpdate_Get Into @id,@ContactName,@IdType,@IdNumber,@MasterId
 While @@FETCH_STATUS=0
 BEGIN
  --========================================================================= Start Address check length =======================================================
   Select @PerLocalAddress=PersonalLocalAddress,@EntyLocalAddress=EntityLocalAddress,
   @PerForigenAddress=PersonalForeignAddress,@EntyForigenAddress=EntityForeignAddress
   From ImportContacts 
   Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
  --========================================= PersonalLocalAddress ===================================================
   If @PerLocalAddress Is Not Null 
   BEGIN
     Create Table #Strng_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))
     Insert Into #Strng_Splt(AddrName)
	 Select Value From string_split(@PerLocalAddress,',')
     IF Exists( Select AddrName From #Strng_Splt Where Id=1 AND LEN(AddrName) >@LcBlockHouseNo )
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalLocalAddress BlockHouseNo Length Less then', CAST(@LcBlockHouseNo as nvarchar(100)))
      Else CONCAT('Please enter the BlockHouseNo Length Less then', CAST(@LcBlockHouseNo as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalLocalAddress is not null
	 END
	 if Exists (Select AddrName From #Strng_Splt Where Id=2 AND LEN(AddrName) >@LcStreet)
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalLocalAddress Street Length Less then', CAST(@LcStreet as nvarchar(100)))
      Else CONCAT('Please enter the Street Length Less then', CAST(@LcStreet as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalLocalAddress is not null
	 END
	 if Exists (Select AddrName From #Strng_Splt Where Id=3 AND LEN(AddrName) >@LcUnitNo)
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalLocalAddress UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100)))
      Else CONCAT('Please enter the UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalLocalAddress is not null
	 END 
     if Exists (Select AddrName From #Strng_Splt Where Id=4 AND LEN(AddrName) >@LcBuildingEstate)
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalLocalAddress BuildingEstate Length Less then', CAST(@LcBuildingEstate as nvarchar(100)))
      Else CONCAT('Please enter the BuildingEstate Length Less then', CAST(@LcBuildingEstate as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalLocalAddress is not null
	 END 
     if Exists (Select AddrName From #Strng_Splt Where Id=5 AND LEN(AddrName) >@LcCity)
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalLocalAddress City Length Less then', CAST(@LcCity as nvarchar(100)))
      Else CONCAT('Please enter the City Length Less then', CAST(@LcCity as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalLocalAddress is not null
	 end
     if Exists (Select AddrName From #Strng_Splt Where Id=5 AND LEN(AddrName) >@LcState)
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalLocalAddress state Length Less then', CAST(@LcState as nvarchar(100)))
      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalLocalAddress is not null
	 END
     if Exists (Select AddrName From #Strng_Splt Where Id=5 AND LEN(AddrName) >@LcCountry)
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalLocalAddress Country Length Less then ', CAST(@LcCountry as nvarchar(100)))
      Else CONCAT('Please enter the Country Length Less then ', CAST(@LcCountry as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalLocalAddress is not null
	 end
     if Exists (Select AddrName From #Strng_Splt Where Id=6 AND LEN(AddrName) >@LcPostalCode)
	 BEGIN
	  Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalLocalAddress PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100)))
      Else CONCAT('Please enter the PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100))) end, ImportStatus=0
      Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId  and PersonalLocalAddress is not null
	 END
	 drop Table #Strng_Splt
   END
   --=================================================PersonalForeignAddress ==============================================================================		
   If @PerForigenAddress Is Not Null 
   BEGIN
     Create Table #Strng1_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))
	 Insert Into #Strng1_Splt(AddrName)
	 Select Value From string_split(@PerForigenAddress,',')
	 if Exists (Select AddrName From #Strng1_Splt Where Id=1 AND LEN(AddrName) >@LcStreet)
	 BEGIN
	  Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalForeignAddress state Length Less then', CAST(@LcState as nvarchar(100)))
      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
      Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalForeignAddress is not null
	 END
     if Exists (Select AddrName From #Strng1_Splt Where Id=2 AND LEN(AddrName) >@LcUnitNo)
	 BEGIN
	  Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalForeignAddress UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100)))
      Else CONCAT('Please enter the UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalForeignAddress is not null
	 END 
     if Exists (Select AddrName From #Strng1_Splt Where Id=3 AND LEN(AddrName) >@LcCity)
	 BEGIN
	  Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalForeignAddress City Length Less then', CAST(@LcCity as nvarchar(100)))
      Else CONCAT('Please enter the City Length Less then', CAST(@LcCity as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalForeignAddress is not null
	 END
     if Exists (Select AddrName From #Strng1_Splt Where Id=4 AND LEN(AddrName) >@LcState)
	 BEGIN
	  Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalForeignAddress state Length Less then', CAST(@LcState as nvarchar(100)))
      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalForeignAddress is not null
	 END
	 if Exists (Select AddrName From #Strng1_Splt Where Id=5 AND LEN(AddrName) >@LcCountry)
	 BEGIN
	  Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalForeignAddress Country Length Less then ', CAST(@LcCountry as nvarchar(100)))
      Else CONCAT('Please enter the Country Length Less then ', CAST(@LcCountry as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalForeignAddress is not null
	 END
	 if Exists (Select AddrName From #Strng1_Splt Where Id=6 AND LEN(AddrName) >@LcPostalCode)
	 BEGIN
	  Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the PersonalForeignAddress PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100)))
      Else CONCAT('Please enter the PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and PersonalForeignAddress is not null
	 END
	 drop Table #Strng1_Splt
   END 
 --======================================================= EntityLocalAddress ========================================================
   If @EntyLocalAddress Is Not Null  
   BEGIN
	 Create Table #Strng2_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))
     Insert Into #Strng2_Splt(AddrName)
	 Select Value From string_split(@EntyLocalAddress,',')
     IF Exists( Select AddrName From #Strng2_Splt Where Id=1 AND LEN(AddrName) >@LcBlockHouseNo )
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityLocalAddress BlockHouseNo Length Less then', CAST(@LcBlockHouseNo as nvarchar(100)))
      Else CONCAT('Please enter the BlockHouseNo Length Less then', CAST(@LcBlockHouseNo as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityLocalAddress is not null
	 END
	 if Exists (Select AddrName From #Strng2_Splt Where Id=2 AND LEN(AddrName) >@LcStreet)
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityLocalAddress Street Length Less then', CAST(@LcStreet as nvarchar(100)))
      Else CONCAT('Please enter the Street Length Less then', CAST(@LcStreet as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityLocalAddress is not null
	 end
	 if Exists (Select AddrName From #Strng2_Splt Where Id=3 AND LEN(AddrName) >@LcUnitNo)
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityLocalAddress UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100)))
      Else CONCAT('Please enter the UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityLocalAddress is not null
	 END 
	 if Exists (Select AddrName From #Strng2_Splt Where Id=4 AND LEN(AddrName) >@LcBuildingEstate)
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityLocalAddress BuildingEstate Length Less then', CAST(@LcBuildingEstate as nvarchar(100)))
      Else CONCAT('Please enter the BuildingEstate Length Less then', CAST(@LcBuildingEstate as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityLocalAddress is not null
	 END 
	 if Exists (Select AddrName From #Strng2_Splt Where Id=5 AND LEN(AddrName) >@LcCity)
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityLocalAddress City Length Less then', CAST(@LcCity as nvarchar(100)))
      Else CONCAT('Please enter the City Length Less then', CAST(@LcCity as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityLocalAddress is not null
	 END
	 if Exists (Select AddrName From #Strng2_Splt Where Id=5 AND LEN(AddrName) >@LcState)
	 begin
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityLocalAddress state Length Less then', CAST(@LcState as nvarchar(100)))
      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityLocalAddress is not null
	 END
	 if Exists (Select AddrName From #Strng2_Splt Where Id=5 AND LEN(AddrName) >@LcCountry)
	 BEGIN
	  Update ImportContacts set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityLocalAddress Country Length Less then ', CAST(@LcCountry as nvarchar(100)))
      Else CONCAT('Please enter the Country Length Less then ', CAST(@LcCountry as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityLocalAddress is not null
	 END
	 if Exists (Select AddrName From #Strng2_Splt Where Id=6 AND LEN(AddrName) >@LcPostalCode)
	 BEGIN
	  Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityLocalAddress PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100)))
      Else CONCAT('Please enter the PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100))) end, ImportStatus=0
	  Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityLocalAddress is not null
	 END
	  drop Table #Strng2_Splt
   END
	--================================================== EntityForeignAddress  ===========================================================		
   If @EntyForigenAddress Is Not Null 
   BEGIN
	 Create Table #Strng3_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))
	 Insert Into #Strng3_Splt(AddrName)
	 Select Value From string_split(@EntyForigenAddress,',')
	 if Exists (Select AddrName From #Strng3_Splt Where Id=1 AND LEN(AddrName) >@LcStreet)
	 BEGIN
	   Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityForeignAddress state Length Less then', CAST(@LcState as nvarchar(100)))
       Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
	   Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityForeignAddress is not null
	  END
	  if Exists (Select AddrName From #Strng3_Splt Where Id=2 AND LEN(AddrName) >@LcUnitNo)
	  BEGIN
	    Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityForeignAddress UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100)))
        Else CONCAT('Please enter the UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100))) end, ImportStatus=0
	    Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityForeignAddress is not null
	  END 
      if Exists (Select AddrName From #Strng3_Splt Where Id=3 AND LEN(AddrName) >@LcCity)
	  BEGIN
	    Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityForeignAddress City Length Less then', CAST(@LcCity as nvarchar(100)))
        Else CONCAT('Please enter the City Length Less then', CAST(@LcCity as nvarchar(100))) end, ImportStatus=0
	    Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityForeignAddress is not null
	  END
      if Exists (Select AddrName From #Strng3_Splt Where Id=4 AND LEN(AddrName) >@LcState)
	  BEGIN
	   Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityForeignAddress state Length Less then', CAST(@LcState as nvarchar(100)))
       Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
	   Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityForeignAddress is not null
	  END
      if Exists (Select AddrName From #Strng3_Splt Where Id=5 AND LEN(AddrName) >@LcCountry)
	  BEGIN
	   Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityForeignAddress Country Length Less then ', CAST(@LcCountry as nvarchar(100)))
       Else CONCAT('Please enter the Country Length Less then ', CAST(@LcCountry as nvarchar(100))) end, ImportStatus=0
	   Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityForeignAddress is not null
	  END
	  if Exists (Select AddrName From #Strng3_Splt Where Id=6 AND LEN(AddrName) >@LcPostalCode)
	  BEGIN
	   Update ImportContacts set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the EntityForeignAddress PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100)))
       Else CONCAT('Please enter the PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100))) end, ImportStatus=0
	   Where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId and EntityForeignAddress is not null
	  END
	   drop Table  #Strng3_Splt
   END 
    --============================================================================end Address check length ==========================================================
   set @IdTypeID=(select id  from Common.IdType where  Name=@IdType and CompanyId=@companyId)
    -- If Not  Exists (Select   Id from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId) 
    -- Begin
    --UPDATE  ImportContacts set ErrorRemarks=Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',',  'Please enter the correct Accountid')
    --Else 'Please enter the correct Accountid' end  where Name=@ContactName  and id=@id AND  MasterId=@MasterId and TransactionId=@TransactionId
    -- UPDATE  ImportContacts set ImportStatus=0  where  Name=@ContactName  and id=@id AND MasterId=@MasterId and TransactionId=@TransactionId
    -- END 
    If Exists (Select   Id from  Common.Contact Where  FirstName=@ContactName and  case when  IdType is null  then 'xxx' else IdType end   =  case when  @IdTypeID is null  then 'xxx' else @IdTypeID end  and  case when  IdNo is null  then 'xxx' else IdNo end = case when  @IdNumber is null  then 'xxx' else @IdNumber end  and  CompanyId=@companyId ) ---===Check ContactName  in Common.Contact table
    BEGIN
	 SET @AccountNewId =(Select  Id from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId)
	 SET @AccountNewName =(Select  Name from  ClientCursor.Account Where AccountId=@MasterId and  CompanyId=@companyId)
	 SET @ContactNewId=(Select  Id from  Common.Contact Where  FirstName=@ContactName and  case when  IdType is null  then 'xxx' else IdType end   =  case when  @IdTypeID is null  then 'xxx' else @IdTypeID end  and  case when  IdNo is null  then 'xxx' else IdNo end = case when  @IdNumber is null  then 'xxx' else @IdNumber END and  CompanyId=@companyId )
     If  Exists (Select Distinct Id from  Common.ContactDetails Where ContactId=@ContactNewId  AND EntityId=@AccountNewId) ---===Check ContactName  in Common.Contact table
	 BEGIN
	  UPDATE  ImportContacts set ErrorRemarks=Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',',  'Contactname Already Exists Please entered the correct information.')
      Else 'Contactname Already Exists Please entered the correct information.' end  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
	  UPDATE  ImportContacts set ImportStatus=0  where Name=@ContactName  and id=@id and MasterId=@MasterId and TransactionId=@TransactionId
     END
    END 
    BEGIN Try  
     update kk set kk.ImportStatus=
     case when  [month]=2 and [day] Between 1 and 29 then 1
     when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
     when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,ErrorRemarks= Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'DateofBirth must be in DD/MM/YYYY (Ex:31/01/1992) Format')
     Else 'DateofBirth must be in DD/MM/YYYY (Ex:31/01/1992) Format' end  from
     (
      select id,DateofBirth,ImportStatus,ErrorRemarks,SUBSTRING(DateofBirth,1,Charindex('/',DateofBirth)-1) as 'DAY',SUBSTRING(DateofBirth,Charindex('/',DateofBirth)+1,Charindex('/',SUBSTRING(DateofBirth,Charindex('/',DateofBirth)+1,LEN(DateofBirth)))-1)
      AS 'Month'  from ImportContacts  where TransactionId=@TransactionId
      and (DateofBirth is not null or DateofBirth<>'')
	  and MasterId=@MasterId  and id=@Id and name=@ContactName
     )kk
     where  case when  [month]=2 and [day] Between 1 and 29 then 1
     when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
     when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
    END TRY
    BEGIN CATCH
	 Declare @error nvarchar(max) = error_message();
	 If @error is not null
	 BEGIN 
      UPDATE  ImportContacts set ErrorRemarks=Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',', 'DateofBirth must be in DD/MM/YYYY (Ex:31/01/1992) Format')
      Else 'DateofBirth must be in DD/MM/YYYY (Ex:31/01/1992) Format' end  where  TransactionId=@TransactionId  and MasterId=@MasterId  and id=@Id and name=@ContactName
      UPDATE  ImportContacts set ImportStatus=0  where  TransactionId=@TransactionId  and MasterId=@MasterId  and id=@Id and name=@ContactName
	 End 
	END CATCH
    BEGIN Try  
     Update ImportContacts set ErrorRemarks =Case when ErrorRemarks is not null then  CONCAT(ErrorRemarks,',',  'Date of birth cannot be a future date')
     Else 'Date of birth cannot be a future date' end  , ImportStatus=0
	 where  CONVERT(datetime, DateofBirth, 103) > GETUTCDATE() and  TransactionId=@TransactionId --and (ImportStatus<>0 or ImportStatus is null)
	 and id  in (select ID from ImportContacts  where  TransactionId=@TransactionId and MasterId=@MasterId  and id=@Id and name=@ContactName  AND ( ImportStatus<>0 oR  ImportStatus IS NULL))
	 and MasterId=@MasterId  and id=@Id and name=@ContactName AND ( ImportStatus<>0 oR  ImportStatus IS NULL)
	END TRY
	BEGIN CATCH
	 Declare @error1 nvarchar(max) = error_message();
	 If @error1 is not null
	 BEGIN 
      UPDATE  ImportContacts set ErrorRemarks=ErrorRemarks  where  TransactionId=@TransactionId  and MasterId=@MasterId  and id=@Id and name=@ContactName
	  UPDATE  ImportContacts set ImportStatus=0  where  TransactionId=@TransactionId  and MasterId=@MasterId  and id=@Id and name=@ContactName
	 END 
    END CATCH
    Update ImportContacts set ErrorRemarks = case when charindex(',',ErrorRemarks)=1 then SUBSTRING(ErrorRemarks,2,len(ErrorRemarks))
    else ErrorRemarks  end, ImportStatus=0 where   TransactionId=@TransactionId AND ErrorRemarks IS NOT NULL
    fetch next from ContactIdUpdate_Get Into @id,@ContactName,@IdType,@IdNumber,@MasterId
 End
 Close ContactIdUpdate_Get
 Deallocate ContactIdUpdate_Get
End 
GO
