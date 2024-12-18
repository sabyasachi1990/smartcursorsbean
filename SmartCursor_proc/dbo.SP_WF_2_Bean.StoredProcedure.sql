USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_WF_2_Bean]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[SP_WF_2_Bean]
@companyId bigint

AS 
BEGIN

	Declare @contactid UNIQUEIDENTIFIER;
	Declare @clientid UNIQUEIDENTIFIER;
	Declare @addressid UNIQUEIDENTIFIER;
	Declare @entityId UNIQUEIDENTIFIER;
	Declare @entityContactId UNIQUEIDENTIFIER;
	Declare @entityAddresBookId UNIQUEIDENTIFIER;
	Declare @entityAddresBookId2 UNIQUEIDENTIFIER;
	DECLARE	@ErrorMessage NVARCHAR(4000)
	Declare @UserCreatedOrModified Varchar(10)
	Declare @GetDate DateTime2
	Declare @SyncStatusCompleted varchar(20)
		Set @UserCreatedOrModified='System'
		Set @GetDate=Getutcdate()
		Set @SyncStatusCompleted='Completed'
	Declare @RecCount Int=1
	Declare @Count Int
	Declare @Client_IdTbl Table (Id Int Identity(1,1),ClientId Uniqueidentifier)


	BEGIN TRANSACTION
	BEGIN TRY
		IF Exists (Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Workflow Cursor') And Status=1 And Exists (Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1 ))
		BEGIN
			Insert Into @Client_IdTbl (ClientId)
			Select Distinct Id From WorkFlow.Client Where CompanyId=@companyId And Id Not In (Select SyncClientId From Bean.Entity Where CompanyId=@companyId And SyncClientId Is Not Null)
			
			Select @Count=Count(*) From @Client_IdTbl
			While @Count>=@RecCount
			BEGIN	
					Select @clientid=ClientId From @Client_IdTbl Where Id=@RecCount
					set @entityId=NEWID();
					IF NOT EXISTS(select Id from Bean.Entity where DocumentId =@clientid)
					BEGIN
							insert into Bean.Entity (Id,CompanyId,Name,DocumentId,TypeId,IdTypeId,IdNo,IsCustomer,
							CustTOPId,CustCurrency,CustNature,RecOrder,Remarks,UserCreated,CreatedDate,Status,IsExternalData,IsShowPayroll,Communication,ExternalEntityType,SyncClientId)
							
							select @entityId,wc.CompanyId,wc.Name,@clientid,wc.ClientTypeId,wc.IdtypeId,wc.ClientIdNo,1, 
									case when wc.TermsOfPaymentId is not null then wc.TermsOfPaymentId 
										 else
											(select id from common.termsofpayment where companyid=@companyId and name='Credit - 0')
									end
									,'SGD','Trade',wc.RecOrder,wc.Remarks,wc.UserCreated,GETDATE(),wc.Status,1,1 ,wc.Communication,'Client',@clientid
							From WorkFlow.Client as wc where Id=@clientid
							--Client Address Insertion start
							DECLARE lstAddress CURSOR FOR select Id from Common.Addresses where AddTypeId=@clientid 
							OPEN lstAddress
							FETCH NEXT FROM lstAddress INTO @addressid
							WHILE @@FETCH_STATUS = 0
							BEGIN	
								set @entityAddresBookId=newid();
									insert into Common.AddressBook(Id,BlockHouseNo,BuildingEstate,City,Country,CreatedDate,DocumentId,Email,IsLocal,Phone,PostalCode,State,Street,Status) 
										select @entityAddresBookId,adb.BlockHouseNo,adb.BuildingEstate,adb.City,adb.Country,adb.CreatedDate,adb.DocumentId,adb.Email,adb.IsLocal,adb.Phone,adb.PostalCode,adb.State,adb.Street,adb.Status from Common.AddressBook as adb where Id =(select AddressBookId from Common.Addresses where Id=@addressid)
								insert into Common.Addresses (Id,AddTypeId,AddSectionType,AddType,AddressBookId,Status) 
									select NEWID(),@entityId,ad.AddSectionType,'Entity',@entityAddresBookId,1 from Common.Addresses as ad where Id=@addressid

								FETCH NEXT FROM lstAddress INTO @addressid	
							END
							CLOSE lstAddress
							DEALLOCATE lstAddress
							--Client Address Insertion End
						END
						--Contact Insertion start
						DECLARE lstContactDetailIds CURSOR FOR select ContactId from Common.ContactDetails where EntityId=@clientid
						OPEN lstContactDetailIds
						FETCH NEXT FROM lstContactDetailIds INTO @contactid
						WHILE @@FETCH_STATUS = 0
						BEGIN	
								set @entityContactId=newid();
								IF NOT EXISTS (select Id from Common.ContactDetails where ContactId=@contactid and EntityId=(select Id from Bean.Entity where DocumentId=@clientid))
								BEGIN
								
									insert into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Communication,CreatedDate,Designation,IsCopy,IsPinned,IsPrimaryContact,CursorShortCode,Status) 
									select NEWID() as Id ,ccd.ContactId,
									(select Id from Bean.Entity where DocumentId=@clientid)--@entityId
									,'Entity',ccd.Communication,ccd.CreatedDate,ccd.Designation,ccd.IsCopy,ccd.IsPinned,ccd.IsPrimaryContact,'Bean',ccd.Status from Common.ContactDetails as ccd where ContactId=@contactid and EntityId=@clientid
										--for contact address start	
									DECLARE lstAddress CURSOR FOR select Id from Common.Addresses where AddTypeId=@contactid 
									OPEN lstAddress
									FETCH NEXT FROM lstAddress INTO @addressid
									WHILE @@FETCH_STATUS = 0
									BEGIN	
										set @entityAddresBookId2=newid();


										insert into Common.AddressBook (Id,BlockHouseNo,BuildingEstate,City,Country,CreatedDate,DocumentId,Email,IsLocal,Phone,PostalCode,State,Street,Status) select @entityAddresBookId2,adb.BlockHouseNo,adb.BuildingEstate,adb.City,adb.Country,adb.CreatedDate,adb.DocumentId,adb.Email,adb.IsLocal,adb.Phone,adb.PostalCode,adb.State,adb.Street,adb.Status from Common.AddressBook as adb where Id =(select AddressBookId from Common.Addresses where Id=@addressid)

										insert into Common.Addresses (Id,AddTypeId,AddSectionType,AddType,AddressBookId,Status) select 
										NEWID(),@entityContactId,ad.AddSectionType,'BeanContact',@entityAddresBookId2,1 from Common.Addresses as ad where Id=@addressid

										

										FETCH NEXT FROM lstAddress INTO @addressid	
									END	
									CLOSE lstAddress
									DEALLOCATE lstAddress
									--for contact address end	
								END
								FETCH NEXT FROM lstContactDetailIds INTO @contactid
								END
						CLOSE lstContactDetailIds
						DEALLOCATE lstContactDetailIds
				Update Bean.Entity Set SyncClientId=@clientid,SyncClientStatus=@SyncStatusCompleted,SyncClientDate=@GetDate Where Id=@entityId And CompanyId=@companyId
				Set @RecCount=@RecCount+1
			END
		END 
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT @ErrorMessage = ERROR_MESSAGE()
		RAISERROR (@ErrorMessage,16,1);
	END CATCH


END
GO
