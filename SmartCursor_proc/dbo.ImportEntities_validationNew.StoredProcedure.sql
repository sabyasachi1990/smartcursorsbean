USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ImportEntities_validationNew]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create Procedure  [dbo].[ImportEntities_validationNew]  
 --Exec [dbo].[ImportEntities_validation] 727,'A3741C1E-198A-4FA9-8C23-599300E995B6'
@CompanyId int,
@TransactionId UNIQUEIDENTIFIER

AS
BEGIN
DECLARE 
-- @companyId int=237,
--@TransactionId uniqueidentifier='D643FC9E-CDA9-4FFE-8AAE-61C995279288',
@EntityName AS NVARCHAR (MAX),
@AccountType AS NVARCHAR (MAX),
@IdType AS NVARCHAR (MAX), 
@CreditTerms AS NVARCHAR (MAX), 
@PaymentTerms AS NVARCHAR (MAX),
@COAName AS NVARCHAR (MAX),
@AccountTypeid AS BIGINT,
@IdTypeId AS BIGINT,
@CreditTermsId AS BIGINT,
@PaymentTermsId AS BIGINT,
@COAId AS BIGINT,
@TaxId AS BIGINT,
@Jsondata AS NVARCHAR (MAX),
@EmailJson AS NVARCHAR (MAX),
@MobileJson AS NVARCHAR (MAX),
@Id uniqueidentifier,
@Customer bigint,
@Nature nvarchar(100),
@Currency nvarchar(100),
@Vendor bigint, 
@VendorType nvarchar(100),
@DefaultTaxCode nvarchar(100),
@EntityId uniqueidentifier


    --BEGIN TRANSACTION
    --BEGIN TRY


	 --====================================== Entities Mandatory field ==================================================

	 Update importEntities  set ErrorRemarks='Mandatory field EntityName  missed',ImportStatus=0 
	  ---SELECT Distinct EntityName  FROM importEntities 
	  where TransactionId=@TransactionId and EntityName is null and (ImportStatus<>0 or ImportStatus is null)


	         Update importEntities  set ErrorRemarks='Please Check  EntityType Not Matched in Seedata',ImportStatus=0 
	  ---SELECT Distinct EntityType  FROM importEntities 
	  where TransactionId=@TransactionId and EntityType is not null and (ImportStatus<>0 or ImportStatus is null)
	  and EntityType Not in ( select Distinct Name  from Common.AccountType where   CompanyId=@companyId)


	  	  Update importEntities  set ErrorRemarks='Please Check  EntityIdentificationType Not Matched in Seedata ',ImportStatus=0 
	  --SELECT Distinct EntityIdentificationType  FROM importEntities 
	  where TransactionId=@TransactionId and EntityIdentificationType is not null and (ImportStatus<>0 or ImportStatus is null)
	  and EntityIdentificationType COLLATE DATABASE_DEFAULT  Not in ( select Distinct Name  from Common.IdType where   CompanyId=@companyId)



	           Update importEntities  set ErrorRemarks='Mandatory field Customer (Is Check) and CreditTerms  missed',ImportStatus=0 
	  ---SELECT Distinct CreditTerms  FROM importEntities 
	  where TransactionId=@TransactionId and Customer=1 and  CreditTerms is null  and (ImportStatus<>0 or ImportStatus is null)


	  	           Update importEntities  set ErrorRemarks='Mandatory field Customer (Is Check) and Nature  missed',ImportStatus=0 
	  ---SELECT Distinct Nature  FROM importEntities 
	  where TransactionId=@TransactionId and Customer=1   and Nature is null   and (ImportStatus<>0 or ImportStatus is null)

	  	           Update importEntities  set ErrorRemarks='Mandatory field Customer (Is Check) and Currency  missed',ImportStatus=0 
	  ---SELECT Distinct Currency  FROM importEntities 
	  where TransactionId=@TransactionId and Customer=1 and Currency is null  and (ImportStatus<>0 or ImportStatus is null)



	  	           Update importEntities  set ErrorRemarks='Mandatory field Vendor (Is Check) and PaymentTerms  missed',ImportStatus=0 
	  ---SELECT Distinct PaymentTerms  FROM importEntities 
	  where TransactionId=@TransactionId and Vendor=1 and  PaymentTerms is null  and (ImportStatus<>0 or ImportStatus is null)

	       Update importEntities  set ErrorRemarks='Mandatory field Vendor (Is Check) and VendorType  missed',ImportStatus=0 
	  ---SELECT Distinct VendorType  FROM importEntities 
	  where TransactionId=@TransactionId and Vendor=1 and  VendorType is null  and (ImportStatus<>0 or ImportStatus is null)


	  	           Update importEntities  set ErrorRemarks='Mandatory field Vendor (Is Check) and Nature  missed',ImportStatus=0 
	  ---SELECT Distinct Nature  FROM importEntities 
	  where TransactionId=@TransactionId and Vendor=1   and Nature is null   and (ImportStatus<>0 or ImportStatus is null)

	  	           Update importEntities  set ErrorRemarks='Mandatory field Vendor (Is Check) and Currency  missed',ImportStatus=0 
	  ---SELECT Distinct Currency  FROM importEntities 
	  where TransactionId=@TransactionId and Vendor=1 and Currency is null  and (ImportStatus<>0 or ImportStatus is null)




	    	  Update importEntities  set ErrorRemarks='Please Check  DefaultCOA Not Matched in Seedata ',ImportStatus=0 
	  --SELECT Distinct DefaultCOA  FROM importEntities 
	  where TransactionId=@TransactionId and DefaultCOA is not null and (ImportStatus<>0 or ImportStatus is null)
	  and DefaultCOA   Not in ( select Distinct Name  from bean.ChartOfAccount where   CompanyId=@companyId)


	  	Update importEntities  set ErrorRemarks='Please Check  DefaultTaxCode Not Matched in Seedata ',ImportStatus=0 
	  ---SELECT Distinct DefaultTaxCode  FROM importEntities 
	  where TransactionId=@TransactionId and DefaultTaxCode is not null and (ImportStatus<>0 or ImportStatus is null)
	  and DefaultTaxCode   Not in ( select Distinct Name  from [Bean].[TaxCode] ) --where   CompanyId=@companyId
	  

	    --====================================== Contacts Mandatory field ==================================================
    Update c set EntityPhone=PersonalPhone,EntityEmail=PersonalEmail,EntityLocalAddress=PersonalLocalAddress,EntityForeignAddress=PersonalForeignAddress 
	from ImportBeanContacts C  where   C.TransactionId=@TransactionId and C.CopycommunicationandAddress=1

	if Exists (select Name from ImportBeanContacts where Name is null and  TransactionId=@TransactionId)
	begin
		Update ImportBeanContacts set ErrorRemarks = 'Mandatory field Name  missed', ImportStatus=0
		where  Name is null and TransactionId=@TransactionId
	end 

	 if Exists (select EntityName from ImportBeanContacts where EntityName is null  and TransactionId=@TransactionId)
	begin
		Update ImportBeanContacts set ErrorRemarks = 'Mandatory field EntityName  missed', ImportStatus=0
		where  EntityName is null and TransactionId=@TransactionId
	end 


		 if Exists (select PrimaryContacts from ImportBeanContacts where PrimaryContacts is null  and TransactionId=@TransactionId)
	begin
		Update ImportBeanContacts set ErrorRemarks = 'Mandatory field PrimaryContacts  missed', ImportStatus=0
		where  PrimaryContacts is null and TransactionId=@TransactionId
	end 

	 if Exists (select ID from ImportBeanContacts where EntityEmail is null and EntityPhone is null and PersonalPhone is null and  PersonalEmail is null  and TransactionId=@TransactionId)
	begin
		Update ImportBeanContacts set ErrorRemarks = 'Mandatory field ContactCommunication missed', ImportStatus=0
		where  EntityEmail is null and EntityPhone is null and PersonalPhone is null and  PersonalEmail is null and TransactionId=@TransactionId
	end 


		 if Exists (select ID from ImportBeanContacts  where  CONVERT(datetime2, DateofBirth, 103) > GETDATE()  and  TransactionId=@TransactionId)
	begin
		Update ImportBeanContacts set ErrorRemarks = 'DateofBirth Should not have Future Dates', ImportStatus=0
		 where  CONVERT(datetime, DateofBirth, 103) > GETDATE() and  TransactionId=@TransactionId
	end 



---===================================================================================

        DECLARE Entityid_Get CURSOR
          FOR SELECT DISTINCT ID,EntityName,EntityType,EntityIdentificationType,CreditTerms,PaymentTerms,DefaultCOA,DefaultTaxCode
          FROM ImportEntities WHERE  TransactionId = @TransactionId   and (ImportStatus<>0 or ImportStatus is null) 
        OPEN Entityid_Get
        FETCH NEXT FROM Entityid_Get INTO  @EntityId,@EntityName, @AccountType, @IdType,@CreditTerms, @PaymentTerms,@COAName,@DefaultTaxCode
		--, @TaxName
        WHILE @@FETCH_STATUS = 0
         BEGIN

		 IF  Exists (select Distinct EntityName  from ImportBeanContacts  where  EntityName=@EntityName and TransactionId=@TransactionId  and  ( ImportStatus<>0 oR  ImportStatus IS NULL))
		 BEGIN
		 IF Not EXISTS (SELECT DISTINCT Name FROM bean.Entity WHERE  CompanyId = @Companyid and Name=@EntityName)
		 BEGIN
          --IF EXISTS (SELECT id FROM Common.AccountType WHERE Name = @AccountType AND CompanyId = @companyId)
          --BEGIN
          -- IF EXISTS (SELECT id FROM Common.IdType WHERE Name = @IdType AND CompanyId = @companyId)
          --  BEGIN
            --IF EXISTS (SELECT id FROM Common.TermsOfPayment WHERE Name = @CreditTerms AND CompanyId = @companyId)
            -- BEGIN
             --IF EXISTS (SELECT id FROM Common.TermsOfPayment WHERE Name = @PaymentTerms AND CompanyId = @companyId)
             --BEGIN
            -- IF EXISTS (SELECT id FROM bean.ChartOfAccount WHERE Name = @COAName AND CompanyId = @companyId)
            ----BEGIN
            ---- IF EXISTS (SELECT id FROM Bean.TaxCode WHERE Name = @TaxName)
            --  BEGIN
              SET @AccountTypeid = (SELECT id FROM   Common.AccountType WHERE  Name = @AccountType AND CompanyId = @companyId)
              SET @IdTypeId = (SELECT id FROM   Common.IdType WHERE  Name = @IdType AND CompanyId = @companyId)
              SET @CreditTermsId = (SELECT id FROM   Common.TermsOfPayment WHERE  Name = @CreditTerms AND CompanyId = @companyId)
              SET @PaymentTermsId = (SELECT id FROM   Common.TermsOfPayment WHERE  Name = @PaymentTerms  AND CompanyId = @companyId)
              SET @COAId = (SELECT id FROM   bean.ChartOfAccount WHERE  Name = @COAName AND CompanyId = @companyId)
			  SET @TaxId = (SELECT id FROM   Bean.TaxCode WHERE  Name = @DefaultTaxCode --and CompanyId=@companyId
			  )

              Set @EmailJson = (Select 'Email' As 'key',Email As 'value' FROM   ImportEntities WHERE  EntityName=@EntityName and  TransactionId=@TransactionId FOR  JSON AUTO)
              Set @MobileJson = (Select 'Phone' As 'key',Phone As 'value' FROM   ImportEntities WHERE  EntityName=@EntityName and TransactionId=@TransactionId FOR   JSON AUTO)
          
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
						set  @Id=NewId()
                    INSERT INTO Bean.entity (Id, CompanyId, Name, TypeId, IdTypeId, IdNo, GSTRegNo, IsCustomer, CustTOPId, CustCreditLimit, CustNature, VenNature, CustCurrency,
					VenCurrency, IsVendor, VenTOPId, VendorType, COAId,TaxId,Communication,CreatedDate,UserCreated)

                    SELECT NewId(),@CompanyId,EntityName AS Name,@AccountTypeid AS TypeId,@IdTypeId AS IdTypeId,EntityIdentificationNumber AS IdNo,GSTRegistrationNumber AS GSTRegNo,Customer AS IsCustomer,@CreditTermsId AS CustTOPId,
                    CreditLimit AS CustCreditLimit,Nature  AS CustNature,Nature  AS VenNature, Currency  AS CustCurrency,
                    Currency as  VenCurrency,Vendor AS IsVendor,@PaymentTermsId AS VenTOPId,VendorType,@COAId AS COAId,@TaxId AS TaxId
					,@Jsondata AS Communication,GETUTCDATE() as CreatedDate,'system' as UserCreated FROM ImportEntities WHERE  TransactionId = @TransactionId  and EntityName=@EntityName AND id = @EntityId
					     
                    UPDATE ImportEntities SET ErrorRemarks = NULL,ImportStatus = 1 WHERE TransactionId = @TransactionId AND EntityName=@EntityName
                   END                             
                    --ELSE
                   --  BEGIN
                   --  UPDATE ImportEntities SET ErrorRemarks = 'Please Insert Seedata in  TaxId' WHERE  id = @EntityId
                   --  UPDATE ImportEntities SET ImportStatus = 0 WHERE  id = @EntityId AND TransactionId = @TransactionId
                   --  END
                   --  END
                  --ELSE
                  -- BEGIN
                  --  UPDATE ImportEntities SET ErrorRemarks = 'Please Insert Seedata in  COAId' WHERE  EntityName=@EntityName
                  --  UPDATE ImportEntities SET ImportStatus = 0 WHERE  EntityName=@EntityName AND TransactionId = @TransactionId
                  --  END
                  --   END
                    -- ELSE
                    -- BEGIN
                    --UPDATE ImportEntities SET ErrorRemarks = 'Please Insert Seedata in  PaymentTermsId' WHERE  EntityName=@EntityName
                    --UPDATE ImportEntities SET ImportStatus = 0 WHERE  EntityName=@EntityName AND TransactionId = @TransactionId
                    --END
                    --END
                  --  ELSE
                  --BEGIN
                  --  UPDATE ImportEntities SET ErrorRemarks = 'Please Insert Seedata in  CreditTermsId' WHERE  EntityName=@EntityName
                  --  UPDATE ImportEntities SET ImportStatus = 0 WHERE EntityName=@EntityName AND TransactionId = @TransactionId
                  --  END
                  --  END
                  --ELSE
                  -- BEGIN
                  --  UPDATE ImportEntities SET ErrorRemarks = 'Please Insert Seedata in  IdTypeId' WHERE  EntityName=@EntityName
                  --  UPDATE ImportEntities SET ImportStatus = 0 WHERE  EntityName=@EntityName AND TransactionId = @TransactionId
                  --  END
        --          --  END
        --        ELSE
        --            BEGIN
        --             UPDATE ImportEntities SET ErrorRemarks = 'Please Insert Seedata in  EntityType' WHERE  EntityName=@EntityName
        --             UPDATE ImportEntities SET ImportStatus = 0 WHERE  EntityName=@EntityName AND TransactionId = @TransactionId
        --            END
					   --END
                     ELSE
                     BEGIN
                     UPDATE ImportEntities SET ErrorRemarks = 'EntityName Already Exists' WHERE  EntityName=@EntityName
                     UPDATE ImportEntities SET ImportStatus = 0 WHERE  EntityName=@EntityName AND TransactionId = @TransactionId
                     END
			   END
					 ELSE
                     BEGIN
                     UPDATE ImportEntities SET ErrorRemarks = 'Primary Contact Mandatory'  WHERE  EntityName=@EntityName
                     UPDATE ImportEntities SET ImportStatus = 0 WHERE  EntityName=@EntityName AND TransactionId = @TransactionId
                     END

                FETCH NEXT FROM Entityid_Get INTO  @EntityId,@EntityName, @AccountType, @IdType,@CreditTerms, @PaymentTerms,@COAName,@DefaultTaxCode
	
         END
        CLOSE Entityid_Get;
        DEALLOCATE Entityid_Get;
        DECLARE @FailedCount AS INT = (SELECT Count(*) FROM   ImportEntities WHERE  TransactionId = @TransactionId AND ImportStatus = 0)
        UPDATE Common.[Transaction] SET TotalRecords = (SELECT Count(*) FROM   ImportEntities WHERE  TransactionId = @TransactionId),
               FailedRecords =  ISNULL(@FailedCount,0)  WHERE  Id = @TransactionId
END 


    --    COMMIT TRANSACTION;
    --END TRY
    --BEGIN CATCH
    --    ROLLBACK TRANSACTION Throw;
    --END CATCH





 
GO
