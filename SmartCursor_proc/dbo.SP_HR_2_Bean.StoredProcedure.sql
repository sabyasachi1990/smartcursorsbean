USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_HR_2_Bean]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 --Exec [dbo].[SP_HR_2_Bean] 10
CREATE procedure [dbo].[SP_HR_2_Bean](@companyId bigint) AS
BEGIN
	Declare @employeeId UNIQUEIDENTIFIER;
	Declare @addressid UNIQUEIDENTIFIER;
	Declare @entityId UNIQUEIDENTIFIER;
	--Declare @entityContactId UNIQUEIDENTIFIER;
	Declare @entityAddresBookId UNIQUEIDENTIFIER;
	Declare @entityAddresBookId2 UNIQUEIDENTIFIER;
	Declare @empName Nvarchar(100);
	Declare @communication Nvarchar(1000);
	Declare @idno Nvarchar(50);
	Declare @beanentityemployeeid  UNIQUEIDENTIFIER;
	Declare @photoId  UNIQUEIDENTIFIER ;
	Declare @dob  DateTime2(7);
	DECLARE @listStr VARCHAR(MAX);

	If (Not (((select status from common.companymodule(Nolock) where companyid=@companyId 
	and moduleid=(select Id from common.ModuleMaster(Nolock) where Name='Hr Cursor' and companyId=0)) = 1) 
	and ((select status from common.companymodule(Nolock) where companyid=@companyId 
	and moduleid=(select Id from common.ModuleMaster(Nolock) where Name='Bean Cursor' and companyId=0)) = 1)))
		Return

	BEGIN TRANSACTION
	BEGIN 
		TRY
		BEGIN
			--for employee loop
			DECLARE lstEmployeeIds CURSOR FOR select Id from Common.Employee(Nolock) where CompanyId=@companyId and (idtype != null or idtype is not null)
			OPEN lstEmployeeIds
			FETCH NEXT FROM lstEmployeeIds INTO @employeeId
			WHILE @@FETCH_STATUS = 0
			BEGIN							 
				Set @entityId=NEWID();
				IF NOT EXISTS (select Id from Bean.Entity(Nolock) where DocumentId=@employeeId)
				BEGIN
					SET @entityId=NEWID();
					INSERT INTO Bean.Entity (Id,CompanyId,Name,DocumentId,TypeId,IdTypeId,IdNo,IsCustomer,IsVendor,VenTOPId,VenCurrency,VenNature,
					RecOrder,Remarks,UserCreated,CreatedDate,Communication,Status,IsExternalData,IsShowPayroll,VendorType,ExternalEntityType)
					select @entityId,emp.CompanyId,(emp.FirstName+'('+ emp.EmployeeId+')'),@employeeId,null,null,emp.IdNo,0,1,(select id from common.termsofpayment(Nolock) where companyid=@companyId and name='Credit - 0'),
					'SGD','Others',1,emp.Remarks,emp.UserCreated,GETDATE(),emp.Communication,1,1,1,'Employee','Employee' 
					from Common.Employee(Nolock) as emp where Id=@employeeId
					--for entity id update in employee table
			update Common.Employee set EntityId= @entityId where Id=@employeeId
				END
				ELSE
				BEGIN							   
					--update Bean.Entity set Name=@empName ,Communication=@communication,IdNo=@idno where DocumentId=@employeeId
					update ben set ben.Name=(emp.FirstName+'('+ emp.EmployeeId+')') ,ben.Communication=emp.Communication,ben.IdNo=emp.IdNo ,ben.Remarks=emp.Remarks
					from Bean.Entity as ben 
					join Common.Employee as emp on emp.Id =ben.DocumentId 
					where emp.Id=@employeeId
				END
				--Employee Address
				BEGIN
				    Select @beanentityemployeeid = (select Id from Bean.Entity(Nolock) where DocumentId=@employeeId)
					SET @listStr = Null
					Select @dob=emp.DOB, @empName=emp.FirstName, @photoId=emp.PhotoId, @communication=emp.Communication, @idno=emp.IdNo from Common.Employee as emp Where emp.Id = @employeeId	
					SELECT @listStr = COALESCE(@listStr+',' ,'') + Id FROM (SELECT DISTINCT convert(nvarchar(50),AddressBookId) as Id FROM Common.Addresses(Nolock)
						where AddTypeId=@beanentityemployeeid) d;
					Delete Common.Addresses where AddTypeId=@beanentityemployeeid
					Delete From Common.Addresses Where AddressBookId in (@listStr)
					Delete Common.AddressBook where Id in (@listStr)
        
					DECLARE lstAddress CURSOR FOR select Id from Common.Addresses(Nolock) where AddTypeId=@employeeId 
					OPEN lstAddress
					FETCH NEXT FROM lstAddress INTO @addressid
					WHILE @@FETCH_STATUS = 0
					BEGIN	
						set @entityAddresBookId=newid();
						insert into Common.AddressBook (Id,BlockHouseNo,BuildingEstate,City,Country,CreatedDate,DocumentId,Email,IsLocal,Phone,PostalCode, State,Street,Status) select   @entityAddresBookId,adb.BlockHouseNo,adb.BuildingEstate,adb.City,adb.Country,adb.CreatedDate,									
						adb.DocumentId,adb.Email,adb.IsLocal,adb.Phone,adb.PostalCode,adb.State,adb.Street,adb.Status from Common.AddressBook(Nolock) as adb
						where Id =(select AddressBookId from Common.Addresses(Nolock) where Id=@addressid)
		
						insert into Common.Addresses (Id,AddTypeId,AddSectionType,AddType,AddressBookId,Status) 
						select NEWID(),@beanentityemployeeid,ad.AddSectionType,'Entity',@entityAddresBookId,1 from Common.Addresses(Nolock) as ad where Id=@addressid
		
						FETCH NEXT FROM lstAddress INTO @addressid	
					END
					CLOSE lstAddress
					DEALLOCATE lstAddress
				END
				--Employee Contact
				--set @entityContactId=newid();
				--IF NOT EXISTS (select Id from Common.ContactDetails where EntityId=(select Id from Bean.Entity where DocumentId=@employeeId))
				--BEGIN
				--	insert into Common.Contact ( Id,DOB,PhotoId,Salutation,FirstName,Communication,Status) 
				--	select @entityContactId,DOB,@photoId,'Mr.',emp.FirstName,emp.Communication,emp.Status from Common.Employee as emp where Id=@employeeId	insert into Common.ContactDetails(Id,ContactId,EntityId,EntityType,CursorShortCode,IsPrimaryContact,Status) 
				--	values ( NEWID() ,@entityContactId,@beanentityemployeeid--@entityId
				--			,'Entity','Bean',1,1)						 
				--END	
				--ELSE
				--BEGIN			
				--	Update Common.Contact  set   DOB=@dob, PhotoId=@photoId,FirstName=@empName, Communication=@communication where Id= (select ContactId from Common.ContactDetails where EntityId =@beanentityemployeeid)
				--END
				FETCH NEXT FROM lstEmployeeIds INTO @employeeId
			END
			CLOSE lstEmployeeIds
			DEALLOCATE lstEmployeeIds	
		END				
		END TRY
	BEGIN CATCH
	DECLARE
	@ErrorMessage NVARCHAR(4000),
	@ErrorSeverity INT,
	@ErrorState INT;
	SELECT
	@ErrorMessage = ERROR_MESSAGE(),
	@ErrorSeverity = ERROR_SEVERITY(),
	@ErrorState = ERROR_STATE();
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	ROLLBACK TRANSACTION
	END CATCH
	BEGIN
	COMMIT TRANSACTION
	END
END
GO
