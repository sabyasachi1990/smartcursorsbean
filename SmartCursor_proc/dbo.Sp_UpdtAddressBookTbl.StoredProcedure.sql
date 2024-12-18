USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_UpdtAddressBookTbl]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[Sp_UpdtAddressBookTbl] @ContactId Uniqueidentifier
As
Begin
Declare @ContactDtl_Id Uniqueidentifier,
	    @AddSec_Tp Varchar(max),
	    @AddBookId Uniqueidentifier
-- Declaring first Cursor To Get ContactDetail Id based on Contact Id
Declare Contact_DtlCsr cursor For
        Select Id from Common.ContactDetails where ContactId=@ContactId And IsCopy=1
Open Contact_DtlCsr -- Open First Cursor

Fetch Next From Contact_DtlCsr Into @ContactDtl_Id

While @@FETCH_STATUS=0
Begin
-- Delete Records From Common.Addresses Table Where AddSectionType is not matched with data while compare with ContactId And ContactDetailId 
Delete From Common.Addresses Where AddTypeId=@ContactDtl_Id And AddSectionType Not In (Select Distinct AddSectionType from Common.Addresses where AddTypeId=@ContactId)

-- Declaring Second Cursor to get AddSectiontype & AddressBookId 
Declare Address_Csr Cursor for
        Select AddSectionType,AddressBookId from Common.Addresses where AddTypeId=@ContactId
Open Address_Csr --Second Cursor Opened
Fetch next from Address_Csr into @AddSec_Tp,@AddBookId
While @@FETCH_STATUS=0
Begin

Declare @count Int
-- If Addresse Is Available In Contact And Not Available In ContactDetail then have to Insert Into Addresses & AddressBook
Select @count=COUNT(*) from Common.Addresses Where AddSectionType=@AddSec_Tp And AddTypeId=@ContactDtl_Id
--If Address is not available for ContactDetailId
If @count = 0
Begin
Declare @AddSectionType Nvarchar(Max),
        @AddressBookId UniqueIdentifier
 -- Declare third Cursor to store AddressbookId And Addsectiontype
  Declare AddressBook_Csr Cursor For
          Select AddSectionType,AddressBookId from Common.Addresses As A
		  Inner join Common.AddressBook As AB on AB.Id=A.AddressBookId 
		  Where AddSectionType=@AddSec_Tp And AddTypeId=@ContactId
  Open AddressBook_Csr -- Open Third Cursor
  Fetch Next From AddressBook_Csr Into @AddSectionType,@AddressBookId
  While @@FETCH_STATUS=0
  Begin
-- Declare variable To store NewID
  Declare @NewAdd_BookId uniqueidentifier
  Set @NewAdd_BookId = NEWID()
-- Insert Into AddressBook Table For ContactdetailId getting data from Addressbook table using AddressbookId Of contact Id
  Insert Into Common.AddressBook ([Id],[IsLocal],[BlockHouseNo],[Street],[UnitNo],[BuildingEstate],[City],[PostalCode],[State],[Country],[Phone],[Email],[Website],[Latitude],[Longitude],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[DocumentId])
         Select @NewAdd_BookId,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude,Longitude,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId
         From Common.AddressBook Where Id=@AddressBookId
-- Insert Into Addresses Table For ContactDetailId getting data From Addresses Table Using AddressBookId Of ContactId
   Insert Into Common.Addresses ([Id],[AddSectionType],[AddType],[AddTypeIdInt],[AddressBookId],[Status],[DocumentId],[AddTypeId],[EntityId],[ScreenName],[CompanyId],[IsCurrentAddress],[CopyId])
          Select NEWID(),AddSectionType,AddType,AddTypeIdInt,@NewAdd_BookId,Status,DocumentId,@ContactDtl_Id,EntityId,ScreenName,CompanyId,IsCurrentAddress,Null 
	      From Common.Addresses 
	      Where AddSectionType=@AddSectionType And AddressBookId=@AddressBookId

   Fetch Next From AddressBook_Csr Into @AddSectionType,@AddressBookId

  End

   Close AddressBook_Csr -- Close Third Cursor
   Deallocate AddressBook_Csr -- Deallocate Third Cursor
 
  End
--If Address is available for ContactDetailId
  Else
   Begin
-- Update AddressBookId Table containing contact DetailId With Addressbook Table data containing ContactId
   Update  A1 Set  A1.IsLocal=A.IsLocal , A1.BlockHouseNo=A.BlockHouseNo , A1.Street=A.Street , A1.UnitNo=A.UnitNo , A1.BuildingEstate=A.BuildingEstate,
                   A1.City= A.City , A1.PostalCode=A.PostalCode , A1.State=A.State , A1.Country=A.Country , A1.Phone=A.Phone , A1.Email=A.Email , A1.Website=A.Website,
                   A1.Latitude=A.Latitude , A1.RecOrder=A.RecOrder , A1.Remarks=A.Remarks , A1.UserCreated=A.UserCreated , A1.CreatedDate=A.CreatedDate,
				   A1.ModifiedBy=A.ModifiedBy , A1.ModifiedDate=A.ModifiedDate , A1.Version=A.Version , A1.Status=A.Status 
				   From Common.AddressBook As A1
					    Inner Join Common.Addresses As Ads
					    On Ads.AddressBookId= A1.Id
					    Inner Join
					    (
						 Select AddSectionType,AB.Id As AddressBookId,AB.IsLocal,AB.BlockHouseNo,AB.Street,AB.UnitNo,AB.BuildingEstate,AB.City,AB.PostalCode,AB.State,AB.Country,AB.Phone,AB.Email,AB.Website,
                                     AB.Latitude,AB.Longitude,AB.RecOrder,AB.Remarks,AB.UserCreated,AB.CreatedDate,AB.ModifiedBy,AB.ModifiedDate,AB.Version,AB.Status 
						 From Common.Addresses As CA
					          Inner Join Common.AddressBook As AB on CA.AddressBookId = AB.Id
				         Where AddSectionType=@AddSec_Tp And AB.Id=@AddBookId
						 ) As A On A.AddSectionType = Ads.AddSectionType 
					Where Ads.AddTypeId=@ContactDtl_Id And Ads.AddSectionType=@AddSec_Tp

   End							  

   Fetch Next From Address_Csr Into @AddSec_Tp,@AddBookId

   End
   Close Address_Csr --Second Cursor closed
   Deallocate Address_Csr --Second Cursor Deallocated


   Fetch Next From Contact_DtlCsr Into @ContactDtl_Id
   
   End
   
   Close Contact_DtlCsr  --First Cursor closed
   Deallocate Contact_DtlCsr --First Cursor Deallocated

End

GO
