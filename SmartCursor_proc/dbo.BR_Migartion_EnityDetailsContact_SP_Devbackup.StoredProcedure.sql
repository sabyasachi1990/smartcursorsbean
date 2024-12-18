USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Migartion_EnityDetailsContact_SP_Devbackup]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[BR_Migartion_EnityDetailsContact_SP_Devbackup]
@companyId bigint
AS
BEGIN

--Exec [dbo].[BR_Migartion_EnityDetailsContact_SP_Devbackup] 1236

Declare @GenericContactId uniqueidentifier,
@EntityName nvarchar(150),
--@companyId bigint=1731,
@ContactId  uniqueidentifier,
@EntityId  uniqueidentifier,
@RegistrationNo  nvarchar(150),
@Category  nvarchar(150),
@Position nvarchar(150)



Declare EntityContact Cursor For
        select  Distinct [Entity Name],[Company No#]  from   dbo.[BR_New_CompanyDetails_DevBackup] where  [Company No#] is not null 
		OPEN EntityContact
        FETCH NEXT FROM EntityContact INTO @EntityName,@RegistrationNo
	    WHILE @@FETCH_STATUS = 0
        BEGIN

			If  NOT Exists (Select Distinct Name from  Boardroom.GenericContact Where Name=@EntityName and CompanyId=@companyId   )
			BEGIN
			        Set @EntityId=Null
					Set @EntityId =(Select Distinct Id from  Common.EntityDetail Where UEN=@RegistrationNo and CompanyId=@companyId)
					Set @EntityName =(Select Distinct EntityName from  Common.EntityDetail Where UEN=@RegistrationNo and CompanyId=@companyId)
			        set @GenericContactId=NewId()
			        set @ContactId=NewId()
					Set @Category=(select Distinct Category from Boardroom.GenericContact  where Category='Corporate')
					Set @Position=(select Distinct Position from Boardroom.GenericContactDesignation where Position='Shareholder')


				    insert into Boardroom.GenericContact (Id,CompanyId,Category,Name,IDNumber,Status,ShortName)

                     select Distinct @GenericContactId AS Id,@CompanyId AS CompanyId,@Category AS Category,[Entity Name] Name,[Company No#] AS IDNumber,
			         1 Status, dbo.fnFirsties([Entity Name]) as  ShortName 
				     from dbo.[BR_New_CompanyDetails_DevBackup]
				     where [Company No#] is not null and [Entity Name]=@EntityName and [Company No#]=@RegistrationNo

					 Insert into Boardroom.Contacts(Id,CompanyId,GenericContactId,UserCreated,CreatedDate,Status,EntityId,IsEntity,
					 State,IsTemporary)
					
					 select Distinct @ContactId Id,@companyId CompanyId,@GenericContactId GenericContactId,'System' AS UserCreated,GETUTCDATE()CreatedDate,1 AS Status,@EntityId EntityId,1 IsEntity,
					 1 State,0 IsTemporary
					 from dbo.[BR_New_CompanyDetails_DevBackup]
					 where [Company No#] is not null and [Entity Name]=@EntityName and [Company No#]=@RegistrationNo

					 Insert into  Boardroom.GenericContactDesignation(Id,CompanyId,ContactId,GenericContactId,EntityId,Position,
					 ShortCode)

					select   Top 1 NEWID() AS Id,@CompanyId CompanyId,@ContactId ContactId,@GenericContactId GenericContactId,@EntityId EntityId,
					@Position AS Position,(Select ShortCode From Boardroom.ContactMapping Where Category=@Category And Position=@Position And Status=1) ShortCode
						--(Select Sort From Boardroom.ContactMapping Where Category=@Category And Position=@Position And Status=1) Sort
					From dbo.[BR_New_CompanyDetails_DevBackup]
					where [Company No#] is not null and [Entity Name]=@EntityName and [Company No#]=@RegistrationNo
			END
						Fetch next from EntityContact Into @EntityName,@RegistrationNo
						END
		                Close EntityContact
		                Deallocate EntityContact
						
						END
GO
