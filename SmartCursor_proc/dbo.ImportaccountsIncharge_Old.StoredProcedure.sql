USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ImportaccountsIncharge_Old]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[ImportaccountsIncharge_Old]    ------ EXEC [dbo].[ImportaccountsIncharge] 1829,'4711DD8A-8582-4EBE-874F-FE3BD1CAB7A1'
@companyId int,
@TransactionId uniqueidentifier
as
begin

Declare ---@companyId int=?,
@Id Uniqueidentifier,
@AccountId Nvarchar(MAX),
@Name Nvarchar(100),
@Userid int

	 --Begin Transaction  
  --    Begin Try  

    Declare AccountId_Get Cursor For

	--------============== Import  Incharge names   not in ClientCursor.AccountIncharg table --===============================
    SELECT  AccountId,RTRIM(LTRIM(value))FROM Importleads 
    CROSS APPLY STRING_SPLIT(InchargesinClientCursor , ',') where TransactionId=@TransactionId  and AccountId 
	not in ( select Distinct   A.AccountId  from ClientCursor.Account A
	Inner join ClientCursor.AccountIncharge I ON I.AccountId=A.Id
	where  A.CompanyId=@companyId)
	Open AccountId_Get
	fetch next from AccountId_Get Into @AccountId,@Name
	While @@FETCH_STATUS=0
    Begin
     --If Not Exists (  select AccountId  from ClientCursor.AccountIncharge where AccountId  in (select  id  from ClientCursor.Account where  AccountId=@AccountId and CompanyId=@companyId) )  ---===Check AccountId  in ClientCursor.Account table
     --Begin
        If Exists ( select  id  from ClientCursor.Account where  AccountId=@AccountId and CompanyId=@companyId )  ---===Check AccountId  in ClientCursor.Account table
        Begin
           If  Exists ( select  id  from Common.CompanyUser where  FirstName in (@Name) and CompanyId=@companyId )   ---===Check FirstName  in Common.CompanyUser  table
           Begin
                set @Userid= (select  id  from Common.CompanyUser where FirstName in (@Name) and  CompanyId=@companyId )
				set @Id=( select  id  from ClientCursor.Account where  AccountId=@AccountId and CompanyId=@companyId )
				 ---- get CompanyUserid using FirstName in Importleads
				--------  if not in  AccountId in  ClientCursor.AccountIncharge for first name is primary incharge 

                If  Not exists (select id from ClientCursor.AccountIncharge where AccountId=( select  id  from ClientCursor.Account where  AccountId=@AccountId and CompanyId=@companyId))
                Begin 

						Insert Into ClientCursor.AccountIncharge (Id,AccountId,RecOrder,UserCreated,CreatedDate,Status,ISPrimary,CompanyUserId )
						SELECT Newid() as Id, @Id as AccountId,1 AS RecOrder,'System' as UserCreated,GetDate() as CreatedDate,1 as Status,1 as ISPrimary,@Userid as CompanyUserId  
						FROM Importleads where AccountId=@AccountId AND TransactionId=@TransactionId  --and (AccountImportStatus<>0 or AccountImportStatus is null)
						    UPDATE  Importleads set InchargeErrorRemarks=null  where AccountId=@AccountId AND TransactionId=@TransactionId
				            UPDATE  Importleads set InchargeImportStatus=1  where AccountId=@AccountId AND TransactionId=@TransactionId
				END
				Else 
				Begin
				Insert Into ClientCursor.AccountIncharge (Id,AccountId,RecOrder,UserCreated,CreatedDate,Status,ISPrimary,CompanyUserId )
				SELECT Newid() as Id, @Id as AccountId, (select  max(RecOrder)+1  from  ClientCursor.AccountIncharge where AccountId=@Id),'System' as UserCreated,GetDate() as CreatedDate,1 as Status,0 as ISPrimary,@Userid as CompanyUserId  
				FROM Importleads where AccountId=@AccountId AND TransactionId=@TransactionId  --and (AccountImportStatus<>0 or AccountImportStatus is null)
				UPDATE  Importleads set InchargeErrorRemarks=null  where AccountId=@AccountId AND TransactionId=@TransactionId
				UPDATE  Importleads set InchargeImportStatus=1  where AccountId=@AccountId AND TransactionId=@TransactionId
				End 
				END
				 ---------------------------------------------------  update ErrorRemarks and ImportStatus in Importleads table
		   ELSE 
		   BEGIN 
		   UPDATE  Importleads set InchargeErrorRemarks='Please Insert Primary Incharge'  where AccountId=@AccountId AND TransactionId=@TransactionId
		   UPDATE  Importleads set InchargeImportStatus=0  where AccountId=@AccountId AND TransactionId=@TransactionId
		   END 
		   END 
		ELSE 
		BEGIN 
		UPDATE  Importleads set InchargeErrorRemarks='Please Insert Accountid'  where AccountId=@AccountId AND TransactionId=@TransactionId
		UPDATE  Importleads set InchargeImportStatus=0  where AccountId=@AccountId AND TransactionId=@TransactionId
		END 
	 --   END 
	 --ELSE 
	 --BEGIN 
	 --UPDATE  Importleads set InchargeErrorRemarks='AccountInchargeId  Already Exists'  where AccountId=@AccountId AND TransactionId=@TransactionId
	 --UPDATE  Importleads set InchargeImportStatus=0  where AccountId=@AccountId AND TransactionId=@TransactionId
	 --END 
				fetch next from AccountId_Get Into @AccountId,@Name
				End
	Close AccountId_Get
	Deallocate AccountId_Get
	End 

				--Commit Transaction  
				--End Try  
				--Begin Catch  
				--RollBack Transaction  
				--Throw;  
				--End Catch  

			


				--select * from ImportLeads where TransactionId='50220569-4688-4D4D-A23D-62DE4DB8284D'

				--select * from ClientCursor.AccountIncharge c
				--inner join ImportLeads a on a.id=c.AccountId
				--where TransactionId='50220569-4688-4D4D-A23D-62DE4DB8284D'
		
				--sp_RENAME 'ImportLeads.ErrorRemarks1' , 'InchargeErrorRemarks', 'COLUMN'
				--sp_RENAME 'ImportLeads.ImportStatus1' , 'InchargeImportStatus', 'COLUMN'
				--sp_RENAME 'ImportLeads.ErrorRemarks' , 'AccountErrorRemarks', 'COLUMN'
				--sp_RENAME 'ImportLeads.ImportStatus' , 'AccountImportStatus', 'COLUMN'
		
GO
