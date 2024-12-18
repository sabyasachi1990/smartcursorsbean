USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Import_Clients_ValidationNew]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





 CREATE PROCEDURE [dbo].[Import_Clients_ValidationNew]  
--exec [dbo].[Import_Clients_Validation]  583,'5A383B99-9C32-4F11-A7CD-A0E0249221AE'
@companyId int,
@TransactionId uniqueidentifier

AS
BEGIN 

Declare
-- @companyId int=239,
--@TransactionId uniqueidentifier='3D682EA1-2DA1-48BB-9729-845EB1C03EA6',
  @ClientId nvarchar (max),
  @Clientname nvarchar (max),
  @ClienttType nvarchar(max),
  @IdType nvarchar(max),
  @CreditTerms nvarchar(max),
  @ClientTypeId bigint,
  @IdTypeId bigint,
  @CreditTermsId bigint,
  @Jsondata  Nvarchar(max),
  @EmailJson Nvarchar(max),
  @MobileJson Nvarchar(max),
  @Id uniqueidentifier,
  @ClientId_New uniqueidentifier



 --====================================== Client Mandatory field ==================================================


 

        Update ImportWFClient  set ErrorRemarks='Mandatory field ClientName  missed',ImportStatus=0 
	  ---SELECT Distinct Name  FROM ImportWFClient 
	  where TransactionId=@TransactionId and Name is null and (ImportStatus<>0 or ImportStatus is null)

	   Update ImportWFClient  set ErrorRemarks='Mandatory field SystemRefNo  missed',ImportStatus=0 
	  ---SELECT Distinct ClientRefNumber  FROM ImportWFClient 
	  where TransactionId=@TransactionId and ClientRefNumber is null and (ImportStatus<>0 or ImportStatus is null)


	     Update ImportWFClient  set ErrorRemarks='Please Check  Industry Not Matched in ControlCode ',ImportStatus=0 
	  --SELECT Distinct Industry  FROM ImportWFClient 
	  where TransactionId=@TransactionId and Identificationtype is not null and (ImportStatus<>0 or ImportStatus is null)
	  and Industry  Not in 
	  (
	  SELECT Distinct  CodeKey FROM Common.ControlCode cc 
	   inner join Common.ControlCodeCategory ccc on ccc.id=cc.ControlCategoryId
	  WHERE  ccc.ControlCodeCategoryCode='Industries' AND ccc.CompanyId=@companyId )

	   Update ImportWFClient Set ImportStatus=Case When charindex('/',FinancialYearEnd)>=1 Then

        Case When Cast(Substring(FinancialYearEnd,0,charindex('/',FinancialYearEnd)) As Int) between 1 and 31 then

        Case When Substring(FinancialYearEnd,charindex('/',FinancialYearEnd)+1,LEN(FinancialYearEnd)) in ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec') Then 1 Else 0 End

        Else 0  End

         Else 0 End ,

         ErrorRemarks='Financial Year End Date Was Not In DD/MMM (Ex:31/Jan) Format '

         FROM ImportWFClient where  TransactionId=@TransactionId and (ImportStatus<>0 or ImportStatus is null) And FinancialYearEnd Is not null and FinancialYearEnd<>' '

         And Case When charindex('/',FinancialYearEnd)>=1 Then

        Case When Cast(Substring(FinancialYearEnd,0,charindex('/',FinancialYearEnd)) As Int) between 1 and 31 then

        Case When Substring(FinancialYearEnd,charindex('/',FinancialYearEnd)+1,LEN(FinancialYearEnd)) in ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec') Then 1 Else 0 End

        Else 0  End

         Else 0 End =0

	  
	  Update ImportWFClient  set ErrorRemarks='Please Check  ClientTypeId Not Matched in Seedata',ImportStatus=0 
	  ---SELECT Distinct ClientType  FROM ImportWFClient 
	  where TransactionId=@TransactionId and ClientType is not null and (ImportStatus<>0 or ImportStatus is null)
	  and ClientType Not in ( select Distinct Name  from Common.AccountType where   CompanyId=@companyId)

	  Update ImportWFClient  set ErrorRemarks='Please Check  IdtypetId Not Matched in Seedata ',ImportStatus=0 
	  --SELECT Distinct Identificationtype  FROM ImportWFClient 
	  where TransactionId=@TransactionId and Identificationtype is not null and (ImportStatus<>0 or ImportStatus is null)
	  and Identificationtype COLLATE DATABASE_DEFAULT  Not in ( select Distinct Name  from Common.IdType where   CompanyId=@companyId)


	 --====================================== Contacts Mandatory field ==================================================
	  	if Exists (select Name from ImportWFContacts where Name is null and  TransactionId=@TransactionId)
	begin
		Update ImportWFContacts set ErrorRemarks = 'Mandatory field Name  missed', ImportStatus=0
		where  Name is null and TransactionId=@TransactionId
	end 

	 if Exists (select ClientRefNumber from ImportWFContacts where ClientRefNumber is null  and TransactionId=@TransactionId)
	begin
		Update ImportWFContacts set ErrorRemarks = 'Mandatory field MasterId  missed', ImportStatus=0
		where  ClientRefNumber is null and TransactionId=@TransactionId
	end 


		 if Exists (select PrimaryContacts from ImportWFContacts where PrimaryContacts is null  and TransactionId=@TransactionId)
	begin
		Update ImportWFContacts set ErrorRemarks = 'Mandatory field PrimaryContacts  missed', ImportStatus=0
		where  PrimaryContacts is null and TransactionId=@TransactionId
	end 

	 if Exists (select ID from ImportWFContacts where EntityEmail is null and EntityPhone is null and PersonalPhone is null and  PersonalEmail is null  and TransactionId=@TransactionId)
	begin
		Update ImportWFContacts set ErrorRemarks = 'Mandatory field ContactCommunication missed', ImportStatus=0
		where  EntityEmail is null and EntityPhone is null and PersonalPhone is null and  PersonalEmail is null and TransactionId=@TransactionId
	end 


		 if Exists (select ID from ImportWFContacts  where  CONVERT(datetime, DateofBirth, 103) > GETDATE()  and  TransactionId=@TransactionId)
	begin
		Update ImportWFContacts set ErrorRemarks = 'DateofBirth Should not have Future Dates', ImportStatus=0
		 where  CONVERT(datetime, DateofBirth, 103) > GETDATE() and  TransactionId=@TransactionId
	end 



	  --================================

						
   Declare ClientId_Get Cursor For
   --------==============  Client Not in workflow.Client table Using Import excl Import clients in Workflow.Client  --===============================

	SELECT Distinct ID,ClientRefNumber,ClientType,Identificationtype,CreditTerms,Name FROM ImportWFClient 
	where  TransactionId=@TransactionId  and (ImportStatus<>0 or ImportStatus is null)  --and  name='John'--and ClientRefNumber not in (select Distinct SystemRefNo  from workflow.client where CompanyId=@companyId)
		Open ClientId_Get
		fetch next from ClientId_Get Into @Id,@ClientId,@ClienttType ,@IdType,@CreditTerms,  @Clientname 
		While @@FETCH_STATUS=0

		BEGIN
			 IF  Exists (select Distinct ClientRefNumber  from ImportWFContacts  where  ClientRefNumber=@ClientId and TransactionId=@TransactionId  and  ( ImportStatus<>0 oR  ImportStatus IS NULL))
			  BEGIN

		    If Not  Exists  (select Distinct SystemRefNo  from workflow.client where CompanyId=@companyId and SystemRefNo=@ClientId and name=@Clientname)
	          BEGIN 
			  
		    If Not  Exists  (select Distinct name  from workflow.client where CompanyId=@companyId and name=@Clientname)
	          BEGIN  

			 If  Exists ( select  id  from Common.TermsOfPayment where  Name=@CreditTerms and CompanyId=@companyId ) -- CHECK CreditTermsID IN  Common.TermsOfPayment TABLE
			  BEGIN

		
					   ------------ SET ClienttTypeId,IdTypeId,CreditTermsId,EmailJson,MobileJson FOR JSON
					            
								set @ClientTypeId = (select  id  from Common.AccountType where  Name=@ClienttType and CompanyId=@companyId)
								set @IdTypeId= (select  id  from Common.IdType where  Name=@IdType and CompanyId=@companyId)
								set @CreditTermsId= (select  id  from Common.TermsOfPayment where  Name=@CreditTerms and CompanyId=@companyId)
 								Set @EmailJson =(Select 'Email' As 'key',Email As 'value' From ImportWFClient Where ClientRefNumber=@ClientId AND ID=@Id and name=@Clientname AND Email IS NOT NULL and TransactionId=@TransactionId  For Json Auto)
                                Set @MobileJson =(Select 'Phone' As 'key',Mobile As 'value' From ImportWFClient Where ClientRefNumber=@ClientId AND ID=@Id and name=@Clientname AND Mobile  IS NOT NULL and TransactionId=@TransactionId For Json Auto)
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
                                Begin  
								 set @ClientId_New =NewId()
								  --============================ insert into  workflow.client table ====================================
									  Insert Into  workflow.client (Id,SystemRefNo,Name,CompanyId,ClientTypeId,IdtypeId,ClientIdNo,Communication,TermsOfPaymentId,Industry,IncorporationDate,CountryOfIncorporation,
                                      FinancialYearEnd,PrincipalActivities,ClientStatus,UserCreated,CreatedDate,Status)  

									  select @ClientId_New as Id ,ClientRefNumber as SystemRefNo, Name,@companyId as CompanyId,@ClientTypeId as ClientTypeId,	@IdTypeId as IdtypeId,
									  IdentificationNumber as ClientIdNo,@Jsondata as Communication,@CreditTermsId as TermsOfPaymentId,Industry,	CONVERT(datetime2,IncorporationDate,103) as IncorporationDate,	
									  IncorporationCountry as CountryOfIncorporation,	case when  FinancialYearEnd is not null and FinancialYearEnd <>' ' then 
	                                cast(REPLACE( FinancialYearEnd, '/', ' ') + cast(datepart(year, getdate()) as char(4)) as datetime2)  end  as FinancialYearEnd,PrinicipalActivities,'Active' as ClientStatus,'system' as UserCreated,
									  Getdate() as CreatedDate,1 as Status from ImportWFClient where id=@Id and ClientRefNumber=@ClientId and name=@Clientname and  TransactionId=@TransactionId	

									--======================== insert into workflow.clientstatuschange table ===========================
									  Insert Into workflow.clientstatuschange (Id,CompanyId,ClientId,State,ModifiedBy,ModifiedDate)

								      select Newid(),@companyId as CompanyId,@ClientId_New  as ClientId,'Active'as State,'system' as ModifiedBy,Getdate() as ModifiedDate from ImportWFClient
                                      where id=@Id and ClientRefNumber=@ClientId  and  TransactionId=@TransactionId	

									   Update ImportWFClient Set ErrorRemarks=null,ImportStatus=1 where id=@Id and ClientRefNumber=@ClientId  and name=@Clientname and  TransactionId=@TransactionId	
								END
	                    
				END
					  ELSE 
					  BEGIN 
			 		  UPDATE  ImportWFClient set ErrorRemarks='Please Insert Seedata in TermsOfPaymentId' where id=@Id and ClientRefNumber=@ClientId  and name=@Clientname and  TransactionId=@TransactionId	
			 		  UPDATE ImportWFClient set ImportStatus=0  where id=@Id and ClientRefNumber=@ClientId  and name=@Clientname and  TransactionId=@TransactionId	
					  END
				 END
				     ELSE 
					 BEGIN 
			 		 UPDATE  ImportWFClient set ErrorRemarks='ClientName  Already Exists'  where id=@Id and ClientRefNumber=@ClientId and name=@Clientname and  TransactionId=@TransactionId	
			 		 UPDATE ImportWFClient set ImportStatus=0  where id=@Id and ClientRefNumber=@ClientId and name=@Clientname and  TransactionId=@TransactionId	
				     END
				END
					 ELSE 
					 BEGIN 
			 		 UPDATE  ImportWFClient set ErrorRemarks='ClientName  Already Exists'  where id=@Id and ClientRefNumber=@ClientId and name=@Clientname and  TransactionId=@TransactionId	
			 		 UPDATE ImportWFClient set ImportStatus=0  where id=@Id and ClientRefNumber=@ClientId  and name=@Clientname and  TransactionId=@TransactionId	
					 END 
			
			     END
					 ELSE 
					 BEGIN 
			 		 UPDATE  ImportWFClient set ErrorRemarks='Primary Contact Mandatory'   where id=@Id and ClientRefNumber=@ClientId and name=@Clientname and  TransactionId=@TransactionId	
			 		 UPDATE ImportWFClient set ImportStatus=0  where id=@Id and ClientRefNumber=@ClientId  and name=@Clientname and  TransactionId=@TransactionId	
					 END 
		
			
		
		
		fetch next from ClientId_Get Into @Id,@ClientId,@ClienttType ,@IdType,@CreditTerms,@Clientname 
	
		End
		Close ClientId_Get
		Deallocate ClientId_Get

     Declare @FailedCount int = (Select Count(*) from ImportWFClient Where TransactionId=@TransactionId and ImportStatus=0)
     Update Common.[Transaction] Set TotalRecords=(Select Count(*) from ImportWFClient Where TransactionId=@TransactionId ),
     FailedRecords=  (Case When @FailedCount>0 then @FailedCount else 0 end)   where Id=@TransactionId
	   	END

		
GO
