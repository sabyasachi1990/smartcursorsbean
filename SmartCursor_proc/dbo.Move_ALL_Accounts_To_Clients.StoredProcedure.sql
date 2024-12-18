USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Move_ALL_Accounts_To_Clients]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Move_ALL_Accounts_To_Clients]
as
begin


         --                        ===========================Move all CC-Accounts to WF-Clients ===========================================


------========================================================================STEP 1  BEGIN

------------alter Industry column in  Workflow.client table 

Alter Table Workflow.client alter column Industry Nvarchar(100)
------========================================================================STEP 2 END

------========================================================================STEP 2 BEGIN

----==================================== Account move to client 

Declare @companyId int=1,
@AccountId Uniqueidentifier,
@SysRef varchar(100)-------check this  ='CNT-2019-00617' (select id,SystemRefNo from Workflow.client where CompanyId=1 order by SystemRefNo desc) ='CNT-2019-00617'

Declare AccountId_Get Cursor For
select id from ClientCursor.Account where CompanyId=@companyId and IsAccount=1  and 
id not in (select AccountId from WorkFlow.Client where CompanyId=@companyId)
Open AccountId_Get
fetch next from AccountId_Get Into @AccountId
While @@FETCH_STATUS=0

Begin
--------------------- insert into ClientCursor.Account  to  WorkFlow.Client
Declare	@RefNumber varchar(100)= Concat (Reverse(Substring(Reverse(@SysRef),CHARINDEX('-',Reverse(@SysRef)),LEN(Reverse(@SysRef)))),  right('00'+Cast(Cast (Reverse(SUBSTRING(Reverse(@SysRef),0,CHARINDEX('-',Reverse(@SysRef)))) As int)+1 As varchar),5))
Set @SysRef=@RefNumber
Insert Into WorkFlow.Client
(Id,Name,CompanyId, ClientTypeId ,IdtypeId,ClientIdNo,TermsOfPaymentId,Industry,Source,SourceId,
SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,ClientStatus,
PrincipalActivities,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,AccountId,SystemRefNo)

SELECT NEWID(),Name,CompanyId, AccountTypeId ,AccountIdTypeId,AccountIdNo,TermsOfPaymentId,Industry,Source,SourceId,
SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,AccountStatus,
PrincipalActivities,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Id,
@RefNumber As SystemRefNo
from ClientCursor.Account Where  IsAccount=1  and  Id=@AccountId And CompanyId=@companyId

fetch next from AccountId_Get Into @AccountId
End
Close AccountId_Get
Deallocate AccountId_Get
------==============================================================STEP 2 END

------==============================================================STEP 3 BEGIN

----=====================Account Contact  Move to  Client Contact
--Declare @companyId int=1,
--@AccountId Uniqueidentifier

Declare AccountId_Get Cursor For
select a.Id from  ClientCursor.Account A INNER JOIN ClientCursor.AccountContact AC ON AC.AccountId=A.Id 
where A.CompanyId=@companyId and A.IsAccount=1  AND A.ID  NOT IN
(SELECT C.AccountId FROM WorkFlow.Client C INNER JOIN  WorkFlow.ClientContact CC ON CC.ClientId=C.Id where C.CompanyId=@companyId)
Open AccountId_Get
fetch next from AccountId_Get Into @AccountId
While @@FETCH_STATUS=0

Begin
--------------------- insert into ClientCursor.AccountContact to  in WorkFlow.ClientContact
Insert Into WorkFlow.ClientContact
(Id,ContactId,Designation,Communication,IsPrimaryContact,IsReminderReceipient,Website,RecOrder,Status,OtherDesignation,ClientId)

SELECT  NEWID(),A.ContactId,A.Designation,A.Communication,A.IsPrimaryContact,A.IsReminderReceipient,A.Website,A.RecOrder,
A.Status,A.OtherDesignation,C.Id from ClientCursor.AccountContact A
INNER JOIN WorkFlow.Client C ON C.AccountId=A.AccountId WHERE A.AccountId=@AccountId AND C.CompanyId=@companyId

fetch next from AccountId_Get Into @AccountId
End
Close AccountId_Get
Deallocate AccountId_Get

------==============================================================STEP 3 END

------==============================================================STEP 4 BEGIN

---================ update client table Clientid   to  account table clientid
--Declare @companyId int=1,
--@AccountId Uniqueidentifier

Declare AccountId_Get Cursor For
select id from ClientCursor.Account where CompanyId=@companyId and IsAccount=1  and ClientId is null and 
Id in (select AccountId from WorkFlow.Client where CompanyId=@companyId)
Open AccountId_Get
fetch next from AccountId_Get Into @AccountId
While @@FETCH_STATUS=0
Begin
--------------------- UPDATE WorkFlow.Client  clientid  to ClientCursor.Account WHERE clientid IS NULL
UPDATE A SET A.ClientId=C.ID FROM  WorkFlow.Client c
inner join ClientCursor.Account A ON A.ID=C.AccountId
where  A.IsAccount=1  and A.ClientId is null AND C.AccountId=@AccountId And C.CompanyId=@companyId

fetch next from AccountId_Get Into @AccountId
End
Close AccountId_Get
Deallocate AccountId_Get
---=================================================================STEP 4 END 

---=================================================================STEP 5 BEGIN

--================update TermsOfPaymentId=7  where   and  TermsOfPaymentId is null  in  Workflow.Client
--Declare @companyId int=1

Update Workflow.Client Set TermsOfPaymentId=7
Where CompanyId=@companyId and TermsOfPaymentId is null 
---=================================================================STEP 5 END

--===================================================================STEP 6 BEGIN

--================= Account Address & Address Book  move to client Address & Address Book 

Declare --@CompanyId Bigint=1,
       -- @AccountId Uniqueidentifier,
		@ClientId Uniqueidentifier,
		@ContactDtlId Uniqueidentifier,
		@AddressId Uniqueidentifier,
		@AddressBookId Uniqueidentifier,
		@AddSectionType Nvarchar(250),
		@AddType Nvarchar(250),
		@Status Int,
		@AddBookNewId Uniqueidentifier,
		@AddId Uniqueidentifier

--// Declare First Cursor To get AccountId And Relavent Client Id From Workflow.Client
Declare AccId_CSR Cursor For
		Select C.Id as ClientId,C.AccountId 
		From ClientCursor.Account As A 
		Inner Join WorkFlow.Client As C On C.AccountId=A.Id
		Where C.CompanyId=@CompanyId And A.IsAccount=1
	Open AccId_CSR
	Fetch Next From AccId_CSR Into @ClientId,@AccountId
	While @@FETCH_STATUS=0
		Begin
--// Declare Second Cursor to get AddressId And AddressBoom ID 
		Declare Addres_Csr Cursor For
				Select Id,AddressBookId,AddSectionType,AddType,Status From Common.Addresses Where AddTypeId=@AccountId
			Open Addres_Csr;
			Fetch Next From Addres_Csr Into @AddressId,@AddressBookId,@AddSectionType,@AddType,@Status
			While @@FETCH_STATUS=0
				Begin
--// Check If the Client Id Saved in Address Table Or Not
				If NOT Exists (Select Id From Common.Addresses Where AddSectionType=@AddSectionType And AddType='Client' And Status=@Status And AddTypeId=@ClientId)
					Begin
					Set @AddBookNewId=NEWID()
					Set @AddId = NEWID()
--// Insert Into Address Book Table
						Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude
														,Longitude,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId)
								Select @AddBookNewId,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude
										,Longitude,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId 
								From Common.AddressBook Where Id=@AddressBookId order by  RecOrder
--// Insert Into Addresses Table
						Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)
						
						Select @AddId,AddSectionType,'Client',@ClientId,AddTypeIdInt,@AddBookNewId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,@AddressId from Common.Addresses Where Id=@AddressId
--// Update Common.addresses Table
						Update Common.Addresses Set CopyId=@AddId Where Id=@AddressId

					End

			
				Fetch Next From Addres_Csr Into @AddressId,@AddressBookId,@AddSectionType,@AddType,@Status
				End
--// Close Second Cursor
		Close Addres_Csr;
		Deallocate Addres_Csr;

		Fetch Next From AccId_CSR Into @ClientId,@AccountId
		End
--// Close First Cursor
	Close AccId_CSR;
	Deallocate AccId_CSR;
	---================================================================STEP 6 END


---================================================================STEP 7 BEGIN

--========== Account Contact Deatil & Address & Address Book  move to Client Contact Deatil Address & Address Book 

Declare --@CompanyId Bigint=1,
		@ContDetlId Uniqueidentifier,
		--@ClientId Uniqueidentifier,
		--@AccountId Uniqueidentifier,
		@ContactId Uniqueidentifier,---------above
		--@Designation Nvarchar(200),
		--@Communication Nvarchar(2000),
		--@IsPrimaryContact Bit,
		--@Status int,
		--@Iscopy Bit,
		@UserCreated Nvarchar(512),
		@Createddate datetime2,
		@Client_ContDetailid Uniqueidentifier,
		@New_Client_ContDtlId Uniqueidentifier,
		@New_AddressId Uniqueidentifier,
		@New_AddressBookId Uniqueidentifier,
		@Acc_AddressId Uniqueidentifier,
		@Acc_AddressBookId Uniqueidentifier

--// Declare First Cursor to get ContactDetailId 
Declare Cont_DtlId Cursor For
			Select distinct CD.Id As ContactdtlId,C.Id As ClientId,CD.ContactId,C.AccountId--,CD.Designation,Cd.Communication,Cd.IsPrimaryContact,CD.Status,CD.IsCopy,CD.UserCreated,CD.CreatedDate 
			From Common.ContactDetails As CD
			Inner Join WorkFlow.Client As C On C.AccountId=CD.EntityId 
			Where C.CompanyId=@CompanyId And Cd.EntityType='Account' Order By ContactId 
		
		Open Cont_DtlId
		Fetch Next From Cont_DtlId Into			@ContDetlId,@ClientId,@ContactId,@AccountId--,@Designation,@Communication,@IsPrimaryContact,@Status,@Iscopy,@UserCreated,@Createddate
		While @@FETCH_STATUS=0
		Begin
			If Not Exists (Select Id from Common.ContactDetails Where ContactId=@ContactId And EntityId=@ClientId )
			--And Coalesce(Designation,'')=Coalesce(@Designation,'') --And	Coalesce(Communication,'')=Coalesce(@Communication,'') And Isnull(IsPrimaryContact,9)=Isnull(@IsPrimaryContact,9) And Isnull(Status,8)=Isnull(@Status,8) And Isnull(IsCopy,7)=Isnull(@Iscopy,7) And Coalesce(UserCreated,'Null')=Coalesce--(@UserCreated,'Null') And	 CreatedDate=@Createddate)
			Begin
				Set @New_Client_ContDtlId=Newid()

				Insert into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,IsCopy,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Remarks,DocId,DocType)

				Select	@New_Client_ContDtlId,@ContactId,@ClientId,'Client',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'WF',Status,IsCopy,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Remarks,@AccountId,'Account' From Common.ContactDetails
					Where Id=@ContDetlId
				--// Declare Second Cursor to get Address & AddressBook id's 
					Declare Address_Csr Cursor For
							Select Id,AddressBookId from Common.Addresses Where AddTypeId=@ContDetlId
						Open Address_Csr
						Fetch Next From Address_Csr Into @Acc_AddressId,@Acc_AddressBookId
						While @@FETCH_STATUS=0
							Begin
								Set @New_AddressId=NEWID()
								Set @New_AddressBookId=NEWID()
							-- // Insert Into AddressBook table
								Insert Into Common.AddressBook (Id,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude
														,Longitude,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId)
									Select @New_AddressBookId,IsLocal,BlockHouseNo,Street,UnitNo,BuildingEstate,City,PostalCode,State,Country,Phone,Email,Website,Latitude
										,Longitude,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,DocumentId 
									From Common.AddressBook Where Id=@Acc_AddressBookId order by  RecOrder
							--// Insert Into Addresses Table
								Insert Into Common.Addresses (Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,CopyId)
						
								Select @New_AddressId,AddSectionType,'ClientContact',@New_Client_ContDtlId,AddTypeIdInt,@New_AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId,@Acc_AddressId from Common.Addresses Where Id=@Acc_AddressId
							--// Update Common.addresses Table
								Update Common.Addresses Set CopyId=@New_AddressId Where Id=@Acc_AddressId

								Fetch Next From Address_Csr Into @Acc_AddressId,@Acc_AddressBookId
							End
					-- // Closing Second Cursor

						Close Address_Csr				
						Deallocate Address_Csr
			End -- If Not Exists End


			Fetch Next From Cont_DtlId Into @ContDetlId,@ClientId,@ContactId,@AccountId--,@Designation,@Communication,@IsPrimaryContact,@Status,@Iscopy,@UserCreated,@Createddate

		End
-- // Closing First Cursor
Close Cont_DtlId
Deallocate Cont_DtlId

--=======================================================================STEP 7 END 

--======================================================================= STEP 8  BEGIN

---======================Address book update  order by Recorder ------AddType Accouts
--Declare @companyId int=1,
--@AccountId Uniqueidentifier

Declare AccountId_Get Cursor For

 select distinct  A.AddTypeId from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN ClientCursor.Account AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId and K.RecOrder IS NULL and A.AddType ='Account'   ORDER BY A.AddTypeId

Open AccountId_Get
fetch next from AccountId_Get Into @AccountId
While @@FETCH_STATUS=0

Begin
--------------------- insert into clientid in WorkFlow.Client
 --select k.RecOrder from 
update k set k.RecOrder=1
  from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN ClientCursor.Account AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId  and A.AddTypeId= @AccountId and K.RecOrder IS NULL and A.AddType ='Account' and A.AddSectionType='Registered Address'  --select k.RecOrder from  update k set k.RecOrder=2
   from  Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN ClientCursor.Account AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId  and A.AddTypeId= @AccountId and K.RecOrder IS NULL and A.AddType ='Account' and A.AddSectionType='Mailing Address'    --select k.RecOrder  from  update k set k.RecOrder=3
  from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN ClientCursor.Account AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId  and A.AddTypeId= @AccountId and K.RecOrder IS NULL and A.AddType ='Account' and A.AddSectionType='Others'

fetch next from AccountId_Get Into @AccountId

End
Close AccountId_Get
Deallocate AccountId_Get

--======================================================================= STEP 8  end 



--======================================================================= STEP 9  BEGIN

 ---======================Address book update  order by Recorder ------AddType_ client

--Declare @companyId int=1,
--@ClientId Uniqueidentifier
Declare AccountId_Get Cursor For

 select distinct  A.AddTypeId from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN WorkFlow.Client AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId and K.RecOrder IS NULL and A.AddType ='Client'   ORDER BY A.AddTypeId

Open AccountId_Get
fetch next from AccountId_Get Into @ClientId
While @@FETCH_STATUS=0

Begin
--------------------- insert into clientid in WorkFlow.Client
 --select k.RecOrder from 
update k set k.RecOrder=1
  from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN WorkFlow.Client AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId  and A.AddTypeId= @ClientId and K.RecOrder IS NULL and A.AddType ='Client' and A.AddSectionType='Registered Address'  --select k.RecOrder from  update k set k.RecOrder=2
   from  Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN WorkFlow.Client AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId  and A.AddTypeId= @ClientId and K.RecOrder IS NULL and A.AddType ='Client' and A.AddSectionType='Mailing Address'    --select k.RecOrder  from  update k set k.RecOrder=3
  from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN WorkFlow.Client AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=@companyId  and A.AddTypeId= @ClientId and K.RecOrder IS NULL and A.AddType ='Client' and A.AddSectionType='Others'

fetch next from AccountId_Get Into @ClientId

End
Close AccountId_Get
Deallocate AccountId_Get
--======================================================================= STEP 9  end

--======================================================================= STEP 10  begin  not exc  only check data

     ---UPDATE K SET RecOrder=2 	     SELECT A.AddTypeId,K.RecOrder,A.AddSectionType 	 from Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN ClientCursor.Account AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=1 and A.AddType ='Account' AND  A.AddTypeId='6663551E-BA17-415A-A14C-4503042041DE' AND A.AddSectionType='Others'



   --update k set k.RecOrder=1
    SELECT A.AddTypeId,K.RecOrder,A.AddSectionType 	from  Common.AddressBook K  INNER JOIN Common.Addresses A ON A.AddressBookId=K.Id  INNER JOIN WorkFlow.Client AA ON AA.ID=A.AddTypeId  WHERE   aa.CompanyId=1  AND  A.AddTypeId='6957601F-2A96-4654-ABD7-3107B8C528AD'  and A.AddType ='Client' and A.AddSectionType='Mailing Address'   --======================================================================= STEP 10 end  end 
GO
