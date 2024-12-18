USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Migartion_CompanyDetails_SP_New_Devbackup]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure  [dbo].[BR_Migartion_CompanyDetails_SP_New_Devbackup]

 --Exec [dbo].[BR_Migartion_CompanyDetails_SP_New] 1236
 @companyId bigint
AS
BEGIN

Declare --@companyId int=1257,
 @EntityDetailid uniqueidentifier,
 @Addressbookid uniqueidentifier,
 @CompanyNo nvarchar(Max),
 @EntityName nvarchar(Max)

--Declare @CompanyId bigint
--set @CompanyId=1

Declare BR_CompanyDetails Cursor For
select [Company No#] from  dbo.[BR_New_CompanyDetails_DevBackup] where [Company No#] is not null
		OPEN BR_CompanyDetails
        FETCH NEXT FROM BR_CompanyDetails INTO @CompanyNo
	    WHILE @@FETCH_STATUS = 0
         BEGIN
		 If Not Exists (Select Id from  Common.EntityDetail Where UEN=@CompanyNo and CompanyId=@companyId)
BEGIN

set @EntityDetailid=NUll
set @Addressbookid=Null
set @Addressbookid=NEWID()
set @EntityDetailid=NEWID()
---[Common].[EntityDetail]----

--select * from Common.EntityDetail where CompanyId=1257

insert into [Common].[EntityDetail](Id,CompanyId,RefNo,Register,HandlingOfficer,PraposedEntityName1,PraposedEntityName2,PraposedEntityName3,ChoosenEntityName,CompanyType,Suffix,CorporateEntityRegister,PraposedFYE
,IsFiveHours,NoOfHours,ReasonforCancellation,State,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Jurisdiction,Type,UEN,IncorporationDate,IsPrincipalApprovalReferalAuthorities
,CountryofIncorporation,Status,SubCompanyId,ExistingCompany,CompanyStatus,CeasedDate,EntityName,TakeOverDate,CurrentFYE,SubType,Communication,PartnerCompanyId,Istemporary)


select @EntityDetailid As Id ,@companyId AS CompanyId,Null AS RefNo,[Entity type] AS Register,Null HandlingOfficer,[Entity Name] AS PraposedEntityName1,Null PraposedEntityName2
,Null PraposedEntityName3,[Entity Name] AS ChoosenEntityName,[Company Type] AS CompanyType,Suffix AS Suffix,Null AS CorporateEntityRegister, 
  Convert(datetime,(Convert(varchar,Day([Current FYE (date & month)]))+'-'+ Convert(varchar,Month([Current FYE (date & month)]))+'-'+Convert(varchar,[Current FYE (Year)])),105) AS  PraposedFYE,
1 AS IsFiveHours,Null NoOfHours,
  NUll ReasonforCancellation,'Active' State,Null Remarks,Null RecOrder,'System' UserCreated,GETUTCDATE() CreatedDate,Null ModifiedBy,Null ModifiedDate,
  Null Version,Jurisdiction AS Jurisdiction,'Company Details' Type,[Company No#] AS UEN,convert(date,[Incorporation_Date (DD/MM/YYYY)]) IncorporationDate,
  0 AS IsPrincipalApprovalReferalAuthorities,Jurisdiction AS CountryofIncorporation,
  1 AS Status,Null AS SubCompanyId,Case when [Source (New/ Takeover)] ='NEW' then 'New' 
             when [Source (New/ Takeover)]='TAKEOVER' then 'Takeover' end AS ExistingCompany,Null CompanyStatus,NUll AS CeasedDate,
  [Entity Name] AS EntityName,Convert(datetime2,[Date (If takeover)]) AS TakeOverDate,
  Convert(varchar,Datename(Day,[Current FYE (date & month)]))+' '+ Left(Datename(Month,[Current FYE (date & month)]),3) As CurrentFYE,Null AS SubType,Null AS Communication,
  Null AS PartnerCompanyId,1 AS Istemporary
from dbo.[BR_New_CompanyDetails_DevBackup]
where  [Company No#]=@CompanyNo

---common.[EntityDetail] --Istemporary flag updated---- 

update [Common].[EntityDetail] set Istemporary=0 where Istemporary=1 and CompanyId=@companyId

---------------------------------------

--[Boardroom].[EntityActivity]--


insert into [Boardroom].[EntityActivity](Id,CompanyId,PASSICCode,PrimaryActivity,PADescription,SASSICCode,SecondaryActivity,SADescription,Type,IsPricipalApproval
,CreatedDate,UserCreated,ModifiedBy,ModifiedDate,EntityId,State,IsTemporary)

select NEWID() AS Id,Cast(@companyId as bigint) AS CompanyId,cast(SSIC_1 AS nvarchar(50)) AS PASSICCode,[Primary Activity] AS PrimaryActivity,[Additional Description] PADescription,Cast([SSIC_2] as nvarchar(100)) As SASSICCode,
[Secondary Activity] SecondaryActivity,[Additional Description1] AS SADescription,'Company Activities' AS Type,0 AS IsPricipalApproval,
GETUTCDATE() AS CreatedDate,'System' AS UserCreated,NUll ModifiedBy,NUll ModifiedDate,@EntityDetailid AS EntityId,
1 AS State,0 IsTemporary
from dbo.[BR_New_CompanyDetails_DevBackup] s where [Company No#]=@CompanyNo



--[Common].[AddressBook]--

Insert into [Common].[AddressBook]( Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude,Longitude,RecOrder
,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId ) 

select @AddressbookId Id,1 AS IsLocal,[Block/House No] BlockHouseNo,Street AS Street,[Level & Unit no] UnitNo,Building AS BuildingEstate,Country AS City,
[Postal Code] PostalCode,Country State,Country AS Country,Null Phone,Null Email,Null Website,Null Latitude,Null Longitude,NUll RecOrder,
Null Remarks,'System' UserCreated,GETUTCDATE() AS CreatedDate,Null ModifiedBy,Null ModifiedDate,Null Version,1 AS Status,Null DocumentId
from dbo.[BR_New_CompanyDetails_DevBackup] where [Company No#]=@CompanyNo
 

---[Common].[Addresses]---

insert into [Common].[Addresses](Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)

select NEWID()Id,[Address Type] AS AddSectionType,'Client' AddType,@EntityDetailid AddTypeId,Null AddTypeIdInt,@AddressbookId AddressBookId,
1 Status,Null AS DocumentId,
Null EntityId,Null ScreenName,Null IsCurrentAddress,@companyId AS CompanyId,Null CopyId
from dbo.[BR_New_CompanyDetails_DevBackup] where  [Company No#]=@CompanyNo

update Common.Addresses set AddSectionType='Registered Office Address' where CompanyId=1257 and AddSectionType='REGISTERED OFFICE ADDRESS'


END
fetch next from BR_CompanyDetails Into @CompanyNo
	END			
	Close BR_CompanyDetails
	Deallocate BR_CompanyDetails
	
	END
GO
