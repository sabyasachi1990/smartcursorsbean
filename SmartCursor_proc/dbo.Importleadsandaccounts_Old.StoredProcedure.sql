USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Importleadsandaccounts_Old]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





 create PROCEDURE [dbo].[Importleadsandaccounts_Old]  
--exec [dbo].[Importleadsandaccounts] 583,'6DAC014A-69CF-411D-9616-B0B1B124EDD3'
@companyId int,
@TransactionId uniqueidentifier

AS
BEGIN 

Declare
 --@companyId int=809,
--@TransactionId uniqueidentifier='6DAC014A-69CF-411D-9616-B0B1B124EDD3',
@AccountId nvarchar (max),
@AccountType nvarchar(max),
@IdType nvarchar(max),
@CreditTerms nvarchar(max),
@Secretary nvarchar(max),
@AccountTypeId bigint,
@IdTypeId bigint,
@CreditTermsId bigint,
@SecretaryId uniqueidentifier,
@COMMN Nvarchar(max),
@SourceId Varchar(100),
@Source Nvarchar(max),
@SourceType varchar(100),
@Jsondata  Nvarchar(max),
@EmailJson Nvarchar(max),
@MobileJson Nvarchar(max),
@Id uniqueidentifier,
@Name nvarchar (max),
@IdImp uniqueidentifier

 --Begin Transaction  
 --Begin Try  

 
    	----------------======================== Importleads Validation of ImportleadsTables validate	and update AccountImportStatus=0 =============================
 Update ImportLeads Set AccountImportStatus=Case When charindex('/',FinancialYearEnd)>=1 Then

        Case When Cast(Substring(FinancialYearEnd,0,charindex('/',FinancialYearEnd)) As Int) between 1 and 31 then

        Case When Substring(FinancialYearEnd,charindex('/',FinancialYearEnd)+1,LEN(FinancialYearEnd)) in ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec') Then 1 Else 0 End

        Else 0  End

         Else 0 End ,

         AccountErrorRemarks='Financial Year End Date Was Not In DD/MM (Ex:31/Jan) Format '

         FROM ImportLeads where  TransactionId=@TransactionId And FinancialYearEnd Is not null

         And Case When charindex('/',FinancialYearEnd)>=1 Then

        Case When Cast(Substring(FinancialYearEnd,0,charindex('/',FinancialYearEnd)) As Int) between 1 and 31 then

        Case When Substring(FinancialYearEnd,charindex('/',FinancialYearEnd)+1,LEN(FinancialYearEnd)) in ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec') Then 1 Else 0 End

        Else 0  End

         Else 0 End =0

	
	if Exists (select Distinct AccountId from Importleads where AccountId is null  and TransactionId=@TransactionId)
	begin
		Update Importleads set AccountErrorRemarks = 'Mandatory field AccountId  missed', AccountImportStatus=0
		where  AccountId is null and TransactionId=@TransactionId
	end 

	 if Exists (select Type from Importleads where Type is null  and TransactionId=@TransactionId)
	begin
		Update Importleads set AccountErrorRemarks = 'Mandatory field Type  missed', AccountImportStatus=0
		where  Type is null and TransactionId=@TransactionId
	end 

	 if Exists (select Name from Importleads where Name is null  and TransactionId=@TransactionId)
	begin
		Update Importleads set AccountErrorRemarks = 'Mandatory field Name  missed', AccountImportStatus=0
		where  Name is null and TransactionId=@TransactionId
	end 

	 if Exists (select SourceType from Importleads where SourceType is null  and TransactionId=@TransactionId)
	begin
		Update Importleads set AccountErrorRemarks = 'Mandatory field SourceType  missed', AccountImportStatus=0
		where  SourceType is null and TransactionId=@TransactionId
	end 

	 if Exists (select [Source/Remarks] from Importleads where [Source/Remarks] is null  and TransactionId=@TransactionId)
	begin
		Update Importleads set AccountErrorRemarks = 'Mandatory field [Source/Remarks]  missed', AccountImportStatus=0
		where  [Source/Remarks] is null and SourceType in ('Customer','Referral Partner','Employee','Marketing Campaign') and TransactionId=@TransactionId
	end 

	 if Exists (select InchargesinClientCursor from Importleads where InchargesinClientCursor is null  and TransactionId=@TransactionId)
	begin
		Update Importleads set AccountErrorRemarks = 'Mandatory field InchargesinClientCursor  missed', AccountImportStatus=0
		where  InchargesinClientCursor is null and TransactionId=@TransactionId
	end 

 --    if Exists (select Email from Importleads where Email is null  and TransactionId=@TransactionId)
	--begin
	--	Update Importleads set AccountErrorRemarks = 'Mandatory field Email  missed', AccountImportStatus=0
	--	where  Email is null and TransactionId=@TransactionId
	--end 

	-- if Exists (select Phone from Importleads where Phone is null  and TransactionId=@TransactionId)
	--begin
	--	Update Importleads set AccountErrorRemarks = 'Mandatory field Phone  missed', AccountImportStatus=0
	--	where  Phone is null and TransactionId=@TransactionId
	--end 

	----------------======================== ImportContacts Validation of ImportContacts Tables validate	and update ImportStatus=0 =============================

	if Exists (select Name from ImportContacts where Name is null and  TransactionId=@TransactionId)
	begin
		Update ImportContacts set ErrorRemarks = 'Mandatory field Name  missed', ImportStatus=0
		where  Name is null and TransactionId=@TransactionId
	end 

	 if Exists (select MasterId from ImportContacts where MasterId is null  and TransactionId=@TransactionId)
	begin
		Update ImportContacts set ErrorRemarks = 'Mandatory field MasterId  missed', ImportStatus=0
		where  MasterId is null and TransactionId=@TransactionId
	end 

	 if Exists (select Salutation from ImportContacts where Salutation is null  and TransactionId=@TransactionId)
	begin
		Update ImportContacts set ErrorRemarks = 'Mandatory field Salutation  missed', ImportStatus=0
		where  Salutation is null and TransactionId=@TransactionId
	end 

	-- if Exists (select PersonalEmail from ImportContacts where PersonalEmail is null  and TransactionId=@TransactionId)
	--begin
	--	Update ImportContacts set ErrorRemarks = 'Mandatory field PersonalEmail  missed', ImportStatus=0
	--	where  PersonalEmail is null and TransactionId=@TransactionId
	--end 

	-- if Exists (select PersonalPhone from ImportContacts where PersonalPhone is null  and TransactionId=@TransactionId)
	--begin
	--	Update ImportContacts set ErrorRemarks = 'Mandatory field PersonalPhone  missed', ImportStatus=0
	--	where  PersonalPhone is null and TransactionId=@TransactionId
	--end 

	 if Exists (select PrimaryContacts from ImportContacts where PrimaryContacts is null  and TransactionId=@TransactionId)
	begin
		Update ImportContacts set ErrorRemarks = 'Mandatory field PrimaryContacts  missed', ImportStatus=0
		where  PrimaryContacts is null and TransactionId=@TransactionId
	end 

	-- if Exists (select EntityEmail from ImportContacts where EntityEmail is null  and TransactionId=@TransactionId)
	--begin
	--	Update ImportContacts set ErrorRemarks = 'Mandatory field EntityEmail  missed', ImportStatus=0
	--	where  EntityEmail is null and TransactionId=@TransactionId
	--end 

		 if Exists (select ID from ImportContacts where EntityEmail is null and EntityPhone is null and PersonalPhone is null and  PersonalEmail is null  and TransactionId=@TransactionId)
	begin
		Update ImportContacts set ErrorRemarks = 'Mandatory field ContactCommunication missed', ImportStatus=0
		where  EntityEmail is null and EntityPhone is null and PersonalPhone is null and  PersonalEmail is null and TransactionId=@TransactionId
	end 



 -- 	Update Importleads set AccountErrorRemarks = 'Mandatory fields missed', AccountImportStatus=0
	--where TransactionId=@TransactionId and ( AccountId is null or Type is null or Name is Null or SourceType is Null or [Source/Remarks] is null or InchargesinClientCursor is null or Email is null  or Phone is null)
	
 Declare AccountId_Get Cursor For
   --------============== Import ACCOUNTS not in ClientCursor.Account table --===============================

	SELECT Distinct id,AccountId,AccountType,IdentificationType,CreditTerms,CompanySecretary,[Source/Remarks],SourceType,Name FROM Importleads  where  TransactionId=@TransactionId and (AccountImportStatus<>0 or AccountImportStatus is null)--- and AccountId not in (select distinct  AccountId  from ClientCursor.Account where CompanyId=@companyId)
	Open AccountId_Get
	fetch next from AccountId_Get Into   @IdImp,@AccountId,@AccountType ,@IdType,@CreditTerms,@Secretary,@Source,@SourceType,@Name
	While @@FETCH_STATUS=0
    BEGIN
		IF  Exists (select Distinct MasterId  from ImportContacts  where  MasterId=@AccountId and TransactionId=@TransactionId  and  ( ImportStatus<>0 oR  ImportStatus IS NULL))
			BEGIN

	  If  Not Exists   (select distinct  AccountId  from ClientCursor.Account where CompanyId=@companyId  and AccountId=@AccountId)
			BEGIN

		If  Not Exists   (select distinct  Name  from ClientCursor.Account where CompanyId=@companyId  and  Name=@Name)
					BEGIN
		 If  Exists ( select distinct  FirstName from Common.CompanyUser where CompanyId=@companyId and FirstName in(SELECT Distinct value FROM Importleads --- CHECK FirstName IN Common.CompanyUser TABLE
                     CROSS APPLY STRING_SPLIT(InchargesinClientCursor , ',') where  AccountId=@AccountId and TransactionId=@TransactionId   /*and CompanyId=@companyId*/)  )
			BEGIN
			 If  Exists ( select  id  from Common.AccountType where  Name=@AccountType and CompanyId=@companyId )-- CHECK AccountTypeID IN  Common.AccountType TABLE
			   BEGIN
				 If Exists ( select  id  from Common.IdType where  Name=@IdType and CompanyId=@companyId ) -- CHECK IdTypeID IN  Common.IdType TABLE
				   BEGIN
						If  Exists ( select  id  from Common.TermsOfPayment where  Name=@CreditTerms and CompanyId=@companyId ) -- CHECK CreditTermsID IN  Common.TermsOfPayment TABLE
					  BEGIN
							If  Exists ( select  id  from ClientCursor.Vendor where  Name=@Secretary and CompanyId=@companyId ) or @Secretary is null -- CHECK SecretaryID IN  ClientCursor.Vendor TABLE
				
						BEGIN

							If @SourceType='Employee' ---- CHECK SourceType AND SOURCENAME IN Common.CompanyUser TABLE
							Begin
			
								Set @SourceId=( select cast(id As varchar(100)) from Common.CompanyUser where FirstName=@Source and CompanyId=@companyId )
							End
							Else If @SourceType='Customer'  ---- CHECK SourceType AND SOURCENAME IN ClientCursor.Account TABLE 
							Begin
								Set @SourceId=( select  id  from ClientCursor.Account  where Name=@Source and CompanyId=@companyId )
							End
							Else If @SourceType='Referral Partner' ---- CHECK SourceType AND SOURCENAME IN ClientCursor.Vendor TABLE 
							Begin
								Set @SourceId=( select  id  from ClientCursor.Vendor  where Name=@Source and CompanyId=@companyId )
							End
							Else If @SourceType='Marketing Campaign' ---- CHECK SourceType AND SOURCENAME IN ClientCursor.Campaign TABLE 
							Begin
								Set @SourceId=(select  id  from ClientCursor.Campaign  where Name=@Source and CompanyId=@companyId )
							End
					
							BEGIN    ------------ SET AccountTypeId,IdTypeId,CreditTermsId,SecretaryId,EmailJson,MobileJson FOR JSON

								set @AccountTypeId= (select  id  from Common.AccountType where  Name=@AccountType and CompanyId=@companyId)
								set @IdTypeId= (select  id  from Common.IdType where  Name=@IdType and CompanyId=@companyId)
								set @CreditTermsId= (select  id  from Common.TermsOfPayment where  Name=@CreditTerms and CompanyId=@companyId)
								set @SecretaryId= (select  id  from ClientCursor.Vendor where  Name=@Secretary and CompanyId=@companyId)
 								Set @EmailJson =(Select 'Email' As 'key',Email As 'value' From ImportLeads Where AccountId=@AccountId and Name=@Name and Email is not null  and id=@IdImp and  TransactionId=@TransactionId  For Json Auto)
                               Set @MobileJson =(Select 'Phone' As 'key',Phone As 'value' From ImportLeads Where AccountId=@AccountId and Name=@Name and Phone is not null   and id=@IdImp and TransactionId=@TransactionId For Json Auto)
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
           
								If @SourceId Is Not Null
								Begin
								set  @Id=NewId()
								-------------------------- insert into  ClientCursor.Account table 
									Insert Into  ClientCursor.Account (id,AccountId,Name,Source,SourceName,Industry,IncorporationDate,FinancialYearEnd ,
									PrincipalActivities,CountryOfIncorporation ,IsAGMDocsReminders,IsCorporateTaxReminders,
									IsAuditReminders,IsFinalTax,IsAccount,Communication,AccountIdNo,AccountTypeId,AccountIdTypeId,TermsOfPaymentId,CompanySecretaryId,
									CreatedDate,IsLocal,Status,AccountStatus,UserCreated,CompanyId,SourceId)  

									SELECT   @Id ,AccountId,Name ,SourceType as source,[Source/Remarks] AS SourceName,Industry,CONVERT(datetime2,IncorporationDate,103) as IncorporationDate,cast(REPLACE( FinancialYearEnd, '/', ' ') + cast(datepart(year, getdate()) as char(4)) as datetime2)  as FinancialYearEnd,
									PrincipalActivities,IncorporationCountry as CountryOfIncorporation,RemindersAGM as IsAGMDocsReminders,RemindersECI as IsCorporateTaxReminders,
									RemindersAudit as IsAuditReminders,RemindersFinalTax as IsFinalTax,case when type='Lead' THEN 0 WHEN type='Account' THEN 1 END IsAccount ,
									@Jsondata AS Communication ,IdentificationNumber AS AccountIdNo,@AccountTypeId AS AccountTypeId,@IdTypeId AS AccountIdTypeId ,@CreditTermsId AS TermsOfPaymentId ,@SecretaryId AS CompanySecretaryId,
									getdate() as CreatedDate,1 AS IsLocal ,1 AS Status,case when type='Lead' THEN 'New' WHEN type='Account' THEN 'Active' END AS AccountStatus,'system' as UserCreated,@companyId,@SourceId AS SourceId
									FROM Importleads  where  AccountId=@AccountId and Name=@Name  and id=@IdImp and  TransactionId=@TransactionId and (AccountImportStatus<>0 or AccountImportStatus is null)

									-------------------------- insert into  ClientCursor.Accountstatuschange table 
									Insert Into ClientCursor.Accountstatuschange (id,companyid,accountid,isaccount,state,modifiedby,modifieddate)

									select  Newid(),@companyid,@Id,case when type='Lead' THEN 0 WHEN type='Account' THEN 1 END IsAccount,
									case when type='Lead' THEN 'New' WHEN type='Account' THEN 'Active' END AS state,'system' as modifiedby,getdate() as modifieddate 
									FROM  importleads where  AccountId=@AccountId and Name=@Name  and id=@IdImp and  TransactionId=@TransactionId and (AccountImportStatus<>0 or AccountImportStatus is null)

									Update ImportLeads Set AccountErrorRemarks=null,AccountImportStatus=1 Where TransactionId=@TransactionId And AccountId=@AccountId and Name=@Name  and id=@IdImp 
								End
								else
									If @SourceType  not in  ('Customer','Employee','Marketing Campaign','Referral Partner') 
								Begin
								set  @Id=NewId()
										-------------------------- insert into  ClientCursor.Account table 
									Insert Into  ClientCursor.Account (id,AccountId,Name,Source,SourceName,Industry,IncorporationDate,FinancialYearEnd ,
									PrincipalActivities,CountryOfIncorporation ,IsAGMDocsReminders,IsCorporateTaxReminders,
									IsAuditReminders,IsFinalTax,IsAccount,Communication,AccountIdNo,AccountTypeId,AccountIdTypeId,TermsOfPaymentId,CompanySecretaryId,
									CreatedDate,IsLocal,Status,AccountStatus,UserCreated,CompanyId,SourceId)  

									SELECT  @Id ,AccountId,Name ,SourceType as source,[Source/Remarks] AS SourceName,Industry,CONVERT(datetime2,IncorporationDate,103) as IncorporationDate,cast(REPLACE( FinancialYearEnd, '/', ' ') + cast(datepart(year, getdate()) as char(4)) as datetime2)  as FinancialYearEnd,
									PrincipalActivities,IncorporationCountry as CountryOfIncorporation,RemindersAGM as IsAGMDocsReminders,RemindersECI as IsCorporateTaxReminders,
									RemindersAudit as IsAuditReminders,RemindersFinalTax as IsFinalTax,case when type='Lead' THEN 0 WHEN type='Account' THEN 1 END IsAccount ,
									@Jsondata AS Communication ,IdentificationNumber AS AccountIdNo,@AccountTypeId AS AccountTypeId,@IdTypeId AS AccountIdTypeId ,@CreditTermsId AS TermsOfPaymentId ,@SecretaryId AS CompanySecretaryId,
									getdate() as CreatedDate,1 AS IsLocal ,1 AS Status,case when type='Lead' THEN 'New' WHEN type='Account' THEN 'Active' END AS AccountStatus,'system' as UserCreated,@companyId,@SourceId AS SourceId
									FROM Importleads  where  AccountId=@AccountId and Name=@Name  and id=@IdImp and  TransactionId=@TransactionId and (AccountImportStatus<>0 or AccountImportStatus is null)

									-------------------------- insert into  ClientCursor.Accountstatuschange table 	
									Insert Into ClientCursor.Accountstatuschange (id,companyid,accountid,isaccount,state,modifiedby,modifieddate)

									select  Newid(),@companyid,@Id,case when type='Lead' THEN 0 WHEN type='Account' THEN 1 END IsAccount,
									case when type='Lead' THEN 'New' WHEN type='Account' THEN 'Active' END AS state,'system' as modifiedby,getdate() as modifieddate 
									FROM  importleads where  AccountId=@AccountId and Name=@Name  and id=@IdImp and  TransactionId=@TransactionId and (AccountImportStatus<>0 or AccountImportStatus is null)

									Update ImportLeads Set AccountErrorRemarks=null,AccountImportStatus=1 Where TransactionId=@TransactionId And AccountId=@AccountId and Name=@Name  and id=@IdImp  
								End



	---------------------------------------------------  update ErrorRemarks and ImportStatus in Importleads table
								Else 
								BEGIN
									UPDATE  Importleads set AccountErrorRemarks='Please Insert Source Info Data'  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
			 						UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
								END 
					       ENd
							
						end
						 ELSE 
			             BEGIN 
			 			 UPDATE  Importleads set AccountErrorRemarks='Please Insert Vendor'  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
			 			 UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
			             END 
					 End
					 ELSE 
					 BEGIN 
			 		 UPDATE  Importleads set AccountErrorRemarks='Please Insert Seedata in TermsOfPaymentId'  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
			 		 UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
					 END 
			     End 
				 ELSE 
				 BEGIN 
			 	 UPDATE  Importleads set AccountErrorRemarks='Please Insert Seedata in AccountIdTypeId'  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
			 	 UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
				 END 
		       End 
			  ELSE 
			  BEGIN 
			  UPDATE  Importleads set AccountErrorRemarks='Please Insert Seedata in AccountTypeId'  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
			  UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
			  END 
	    End 
		ELSE 
		BEGIN 
		 UPDATE  Importleads set AccountErrorRemarks='Please Insert Primary Incharge'  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
		 UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
		END 
        End 
        ELSE 
		BEGIN 
		 UPDATE  Importleads set AccountErrorRemarks='AccountName  Already Exists'  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
		 UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
		END 
		End 
		ELSE 
		BEGIN 
		 UPDATE  Importleads set AccountErrorRemarks='AccountId  Already Exists'  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
		 UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
		END 
		End 
		ELSE 
		BEGIN 
		 UPDATE  Importleads set AccountErrorRemarks='Primary Contact Mandatory'  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
		 UPDATE  Importleads set AccountImportStatus=0  where AccountId=@AccountId and TransactionId=@TransactionId and Name=@Name  and id=@IdImp 
		END 
		
		fetch next from AccountId_Get Into @IdImp,@AccountId,@AccountType ,@IdType,@CreditTerms,@Secretary,@Source,@SourceType,@Name
	
		End
		Close AccountId_Get
		Deallocate AccountId_Get

declare @FailedCount int = (Select Count(*) from Importleads Where TransactionId=@TransactionId and AccountImportStatus=0)
Update Common.[Transaction] Set TotalRecords=(Select Count(*) from Importleads Where TransactionId=@TransactionId ),
     FailedRecords=  (Case When @FailedCount>0 then @FailedCount else 0 end)   where Id=@TransactionId
	   	END
GO
