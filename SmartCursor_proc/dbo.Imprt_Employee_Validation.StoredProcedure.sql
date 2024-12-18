USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Imprt_Employee_Validation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--Exec [dbo].[Imprt_Employee_Validation] 2349,'5BCEAB22-3412-4EF9-8AB4-F244E379B00F'

CREATE PROCEDURE [dbo].[Imprt_Employee_Validation]
@CompanyId BIGINT, 
@TransactionId UNIQUEIDENTIFIER

AS
BEGIN

  Declare @LcBlockHouseNo bigint=COL_LENGTH('Common.AddressBook  ', 'BlockHouseNo')
  Declare @LcStreet bigint=COL_LENGTH('Common.AddressBook  ', 'Street')
  Declare @LcUnitNo bigint=COL_LENGTH('Common.AddressBook  ', 'UnitNo')
  Declare @LcBuildingEstate bigint=COL_LENGTH('Common.AddressBook  ', 'BuildingEstate')
  Declare @LcCity bigint=COL_LENGTH('Common.AddressBook  ', 'City')
  Declare @LcPostalCode bigint=COL_LENGTH('Common.AddressBook  ', 'PostalCode')
  Declare @LcState bigint=COL_LENGTH('Common.AddressBook  ', 'State')
  Declare @LcCountry bigint=COL_LENGTH('Common.AddressBook  ', 'Country')
  Declare @LcPhone bigint=COL_LENGTH('Common.AddressBook  ', 'Phone')
  Declare @LcEmail bigint=COL_LENGTH('Common.AddressBook  ', 'Email')



    DECLARE @UserCreated AS VARCHAR (20), @Getdate AS DATETIME2, @Count AS INT, @InnerCount AS INT, @EmpId AS UNIQUEIDENTIFIER, @EmployeeId AS NVARCHAR (200), @Mobile AS NVARCHAR (200), @Email AS NVARCHAR (200), @Comm AS NVARCHAR (MAX), @DeptName AS NVARCHAR (100), @DesgName AS NVARCHAR (100), @DeptId AS UNIQUEIDENTIFIER, @DesgId AS UNIQUEIDENTIFIER, @New_EmployeeId AS UNIQUEIDENTIFIER, @UserName AS VARCHAR (200), @LocalAddress AS NVARCHAR (MAX), @LclAdrs_Vrbl AS NVARCHAR (MAX), @New_Loc_AddressBookId AS UNIQUEIDENTIFIER, @New_Frn_AddressBookId AS UNIQUEIDENTIFIER, @ForigenAddress AS NVARCHAR (MAX), @BlockHouseNo AS NVARCHAR (512), @Street AS NVARCHAR (2000), @UnitNo AS NVARCHAR (512), @BuildingEstate AS NVARCHAR (512), @PostalCode AS NVARCHAR (20), @Country AS NVARCHAR (512), @Error_Message AS NVARCHAR (MAX), @Jsondata AS NVARCHAR (MAX), @EmailJson AS NVARCHAR (MAX), @MobileJson AS NVARCHAR (MAX), @EntityName AS NVARCHAR (400), @UserNameCheck AS BIGINT, @IdNo AS NVARCHAR (100),@IdType AS NVARCHAR (100);
    SET @UserCreated = 'System';
    SET @Getdate = GETUTCDATE();
    SET @InnerCount = 1;
    --BEGIN TRANSACTION;
    --BEGIN TRY


		--Data Type And Length Comparing
		-- ImportPersonalDetails
		Update ImportPersonalDetails Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Name Length Less then ',(Select COL_LENGTH('Common.Employee','FirstName'))) Else CONCAT('Please Enter The Name Length Less then ',(Select COL_LENGTH('Common.Employee','FirstName'))) End
		Where Len(Name)>(Select COL_LENGTH('Common.Employee','FirstName')) And TransactionId=@TransactionId
		Update ImportPersonalDetails Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The UserName Length Less then ',(Select COL_LENGTH('Common.Employee','UserName'))) Else CONCAT('Please Enter The UserName Length Less then ',(Select COL_LENGTH('Common.Employee','UserName'))) End
		Where LEN(UserName)>(Select COL_LENGTH('Common.Employee','UserName')) And TransactionId=@TransactionId
		Update ImportPersonalDetails Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Email Length Less then',(Select COL_LENGTH('Common.Employee','Email'))) Else CONCAT('Please Enter The Email Length Less then ',(Select COL_LENGTH('Common.Employee','Email'))) End
		Where LEN(Email)>(Select COL_LENGTH('Common.Employee','Email')) And TransactionId=@TransactionId
		Update ImportPersonalDetails Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Mobile Length Less then',(Select COL_LENGTH('Common.Employee','MobileNo'))) Else CONCAT('Please Enter The Mobile Number Length Less then',(Select COL_LENGTH('Common.Employee','MobileNo'))) End
		Where LEN(Mobile)>(Select COL_LENGTH('Common.Employee','MobileNo')) And TransactionId=@TransactionId 
		Update ImportPersonalDetails Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Mobile and Email Length Less then',(Select COL_LENGTH('Common.Employee','MobileNo'))) Else CONCAT('Please Enter The Mobile and Email Length Less then ',(Select COL_LENGTH('Common.Employee','MobileNo'))) End
		Where (LEN(Mobile)+LEN(Email)) >(Select COL_LENGTH('Common.Employee','Communication')) And TransactionId=@TransactionId 
		Update ImportPersonalDetails Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Nationality Length Less then ',(Select COL_LENGTH('Common.Employee','Nationality'))) Else CONCAT('Please Enter The Nationality Length Less then ',(Select COL_LENGTH('Common.Employee','Nationality'))) End
		Where LEN(Nationality)>(Select COL_LENGTH('Common.Employee','Nationality')) And TransactionId=@TransactionId
		Update ImportPersonalDetails Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The MaritalStatus Length Less then ',(Select COL_LENGTH('Common.Employee','MaritalStatus'))) Else CONCAT('Please Enter The MaritalStatus Length Less then ',(Select COL_LENGTH('Common.Employee','MaritalStatus'))) End
		Where LEN(MaritalStatus)>(Select COL_LENGTH('Common.Employee','MaritalStatus')) And TransactionId=@TransactionId
		Update ImportPersonalDetails Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Race Length Less then ',(Select COL_LENGTH('Common.Employee','Race'))) Else CONCAT('Please Enter The Race Length Less then ',(Select COL_LENGTH('Common.Employee','Race'))) End
		Where LEN(Race)>(Select COL_LENGTH('Common.Employee','Race')) And TransactionId=@TransactionId
		Update ImportPersonalDetails Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The IdNumber Length Less then ',(Select COL_LENGTH('Common.Employee','IdNo'))) Else CONCAT('Please Enter The IdNumber Length Less then ',(Select COL_LENGTH('Common.Employee','IdNo'))) End
		Where LEN(IdNumber)>(Select COL_LENGTH('Common.Employee','IdNo')) And TransactionId=@TransactionId
		Update ImportPersonalDetails Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The IdType Length Less then ',(Select COL_LENGTH('Common.Employee','IdType'))) Else CONCAT('Please Enter The IdType Length Less then ',(Select COL_LENGTH('Common.Employee','IdType'))) End
		Where LEN(IdType)>(Select COL_LENGTH('Common.Employee','IdType')) And TransactionId=@TransactionId
		Update ImportPersonalDetails Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The PassPortNumber Length Less then ',(Select COL_LENGTH('Common.Employee','PassportNumber'))) Else CONCAT('Please Enter The PassPortNumber Length Less then ',(Select COL_LENGTH('Common.Employee','PassportNumber'))) End
		Where LEN(PassPortNumber)>(Select COL_LENGTH('Common.Employee','PassportNumber')) And TransactionId=@TransactionId
		Update ImportPersonalDetails Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The EmployeeId Length Less then ',(Select COL_LENGTH('Common.Employee','EmployeeId'))) Else CONCAT('Please Enter The EmployeeId Length Less then ',(Select COL_LENGTH('Common.Employee','EmployeeId'))) End
		Where LEN(EmployeeId)>(Select COL_LENGTH('Common.Employee','EmployeeId')) And TransactionId=@TransactionId
		
		--ImportEmployeeDepartment
		Update ImportEmployeeDepartment Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Currency Length Less then ',(Select COL_LENGTH('HR.EmployeeDepartment','Currency'))) Else CONCAT('Please Enter The Currency Length Less then ',(Select COL_LENGTH('HR.EmployeeDepartment','Currency'))) End
		Where Len(Currency)>(Select COL_LENGTH('HR.EmployeeDepartment','Currency')) And TransactionId=@TransactionId
		Update ImportEmployeeDepartment Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The MonthlyBasicPay Length Less then ',(Select COL_LENGTH('HR.EmployeeDepartment','BasicPay'))) Else CONCAT('Please Enter The MonthlyBasicPay Length Less then ',(Select COL_LENGTH('HR.EmployeeDepartment','BasicPay'))) End
		Where Len(MonthlyBasicPay)>(Select COL_LENGTH('HR.EmployeeDepartment','BasicPay')) And TransactionId=@TransactionId
		Update ImportEmployeeDepartment Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Level Length Less then ',(Select COL_LENGTH('HR.EmployeeDepartment','Level'))) Else CONCAT('Please Enter The Level Length Less then ',(Select COL_LENGTH('HR.EmployeeDepartment','Level'))) End
		Where Len([Level])>(Select COL_LENGTH('HR.EmployeeDepartment','Level')) And TransactionId=@TransactionId
		
		--ImportEmployment
		Update ImportEmployment Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The TypeofEmployment Length Less then ',(Select COL_LENGTH('HR.Employment','TypeOfEmployment'))) Else CONCAT('Please Enter The TypeofEmployment Length Less then ',(Select COL_LENGTH('HR.Employment','TypeOfEmployment'))) End
		Where Len(TypeofEmployment)>(Select COL_LENGTH('HR.Employment','TypeOfEmployment')) And TransactionId=@TransactionId
		Update ImportEmployment Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Period Length Less then ',(Select COL_LENGTH('HR.Employment','Period'))) Else CONCAT('Please Enter The Period Length Less then ',(Select COL_LENGTH('HR.Employment','Period'))) End
		Where LEN(Period)>(Select COL_LENGTH('HR.Employment','Period')) And TransactionId=@TransactionId
		Update ImportEmployment Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The ConfirmationRemarks Length Less then ',(Select COL_LENGTH('HR.Employment','ConfirmationRemarks'))) Else CONCAT('Please Enter The ConfirmationRemarks Length Less then ',(Select COL_LENGTH('HR.Employment','ConfirmationRemarks'))) End
		Where LEN(ConfirmationRemarks)>(Select COL_LENGTH('HR.Employment','ConfirmationRemarks')) And TransactionId=@TransactionId
		
		--ImportFamily
		Update ImportFamily Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Name Length Less then ',(Select COL_LENGTH('HR.Familydetails','FirstName'))) Else CONCAT('Please Enter The Name Length Less then ',(Select COL_LENGTH('HR.Familydetails','FirstName'))) End
		Where Len(Name)>(Select COL_LENGTH('HR.Familydetails','FirstName')) And TransactionId=@TransactionId
		Update ImportFamily Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Relation Length Less then ',(Select COL_LENGTH('HR.Familydetails','RelationShip'))) Else CONCAT('Please Enter The Relation Length Less then ',(Select COL_LENGTH('HR.Familydetails','RelationShip'))) End
		Where LEN(Relation)>(Select COL_LENGTH('HR.Familydetails','RelationShip')) And TransactionId=@TransactionId
		Update ImportFamily Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Nationality Length Less then ',(Select COL_LENGTH('HR.Familydetails','Nationality'))) Else CONCAT('Please Enter The Nationality Length Less then ',(Select COL_LENGTH('HR.Familydetails','Nationality'))) End
		Where LEN(Nationality)>(Select COL_LENGTH('HR.Familydetails','Nationality')) And TransactionId=@TransactionId
		Update ImportFamily Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The IDNo Length Less then ',(Select COL_LENGTH('HR.Familydetails','IdNumber'))) Else CONCAT('Please Enter The IDNo Length Less then ',(Select COL_LENGTH('HR.Familydetails','IdNumber'))) End
		Where LEN(IDNo)>(Select COL_LENGTH('HR.Familydetails','IdNumber')) And TransactionId=@TransactionId
		Update ImportFamily Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The ContactNo Length Less then ',(Select COL_LENGTH('HR.Familydetails','ContactNo'))) Else CONCAT('Please Enter The ContactNo Length Less then ',(Select COL_LENGTH('HR.Familydetails','ContactNo'))) End
		Where LEN(ContactNo)>(Select COL_LENGTH('HR.Familydetails','ContactNo')) And TransactionId=@TransactionId
		Update ImportFamily Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The [NameofEmployer/School] Length Less then ',(Select COL_LENGTH('HR.Familydetails','NameOfEmployerOrSchool'))) Else CONCAT('Please Enter The [NameofEmployer/School] Length Less then ',(Select COL_LENGTH('HR.Familydetails','NameOfEmployerOrSchool'))) End
		Where LEN([NameofEmployer/School])>(Select COL_LENGTH('HR.Familydetails','NameOfEmployerOrSchool')) And TransactionId=@TransactionId
		
		--ImportQualification
		Update ImportQualification Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Type Length Less then ',(Select COL_LENGTH('HR.Qualification','QuaType'))) Else CONCAT('Please Enter The Type Length Less then ',(Select COL_LENGTH('HR.Qualification','QuaType'))) End
		Where LEN(Type)>(Select COL_LENGTH('HR.Qualification','QuaType')) And TransactionId=@TransactionId
		Update ImportQualification Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Qualification Length Less then ',(Select COL_LENGTH('HR.Qualification','Qualification'))) Else CONCAT('Please Enter The Qualification Length Less then ',(Select COL_LENGTH('HR.Qualification','Qualification'))) End
		Where LEN(Qualification)>(Select COL_LENGTH('HR.Qualification','Qualification')) And TransactionId=@TransactionId 
		Update ImportQualification Set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please Enter The Institution Length Less then ',(Select COL_LENGTH('HR.Qualification','Institution'))) Else CONCAT('Please Enter The Institution Length Less then ',(Select COL_LENGTH('HR.Qualification','Institution'))) End
		Where LEN(Institution)>(Select COL_LENGTH('HR.Qualification','Institution')) And TransactionId=@TransactionId



            IF EXISTS (SELECT ID,EmployeeId FROM   ImportPersonalDetails WHERE  EmployeeId IS NULL AND TransactionId = @TransactionId)
            BEGIN
			UPDATE ImportPersonalDetails SET ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Employee ID') Else 'Please enter the Employee ID' End ,ImportStatus = 0
            WHERE  EmployeeId IS NULL AND TransactionId = @TransactionId 
            END

            IF EXISTS (SELECT ID,Name FROM   ImportPersonalDetails WHERE  Name IS NULL  AND TransactionId = @TransactionId)
            BEGIN
			UPDATE ImportPersonalDetails SET    ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Employee Name') Else 'Please enter the Employee Name' End,ImportStatus = 0
            WHERE  Name IS NULL AND TransactionId = @TransactionId
            END

            IF EXISTS (SELECT ID,Name FROM   ImportPersonalDetails WHERE  IdType IS NULL AND TransactionId = @TransactionId)
            BEGIN
			UPDATE ImportPersonalDetails SET    ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Id Type') Else 'Please enter the Id Type' End, ImportStatus = 0
            WHERE  IdType IS NULL AND TransactionId = @TransactionId 
            END

            IF EXISTS (SELECT ID,IdNumber FROM   ImportPersonalDetails WHERE  IdNumber IS NULL  AND TransactionId = @TransactionId)
            BEGIN
			UPDATE ImportPersonalDetails SET ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Id number') Else 'Please enter the Id number' End,ImportStatus = 0
            WHERE  IdNumber IS NULL AND TransactionId = @TransactionId 
            END

            IF EXISTS (SELECT ID,Nationality FROM   ImportPersonalDetails WHERE  Nationality IS NULL AND TransactionId = @TransactionId)
            BEGIN
			UPDATE ImportPersonalDetails SET    ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Nationality') Else 'Please enter the Nationality' End,ImportStatus = 0
            WHERE  Nationality IS NULL AND TransactionId = @TransactionId 
            END

            IF EXISTS (SELECT ID,Race FROM   ImportPersonalDetails WHERE  Race IS NULL  AND TransactionId = @TransactionId)
            BEGIN
		    UPDATE ImportPersonalDetails SET  ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Race') Else 'Please enter the Race' End,ImportStatus = 0
            WHERE  Race IS NULL AND TransactionId = @TransactionId 
            END

            ELSE
            IF EXISTS (SELECT ID,DateofBirth FROM   ImportPersonalDetails WHERE  DateofBirth IS NULL AND TransactionId = @TransactionId)
            BEGIN
			UPDATE ImportPersonalDetails SET    ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Date of Birth') Else 'Please enter the Date of Birth' End, ImportStatus = 0
		    WHERE  DateofBirth IS NULL AND TransactionId = @TransactionId --AND ImportStatus is null--ImportStatus <> 0;
            END
            IF EXISTS (SELECT ID,Email FROM   ImportPersonalDetails WHERE  Email IS NULL AND TransactionId = @TransactionId)
            BEGIN
			UPDATE ImportPersonalDetails SET    ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Email/Mobile') Else 'Please enter the Email/Mobile' End,ImportStatus = 0
            WHERE  Email IS NULL and Mobile is null AND TransactionId = @TransactionId 
            END
		
		   IF  EXISTS (select  ID,IdType FROM   ImportPersonalDetails WHERE TransactionId = @TransactionId and IdType='NRIC(Blue)' and DateofSPRGranted is null)
           BEGIN
		   UPDATE ImportPersonalDetails SET  ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Date of SPR Granted is mandatory for NRIC(Blue)') Else 'Date of SPR Granted is mandatory for NRIC(Blue)' End,ImportStatus = 0
           WHERE  DateofSPRGranted IS NULL and IdType='NRIC(Blue)' AND TransactionId = @TransactionId --AND (ImportStatus <> 0 or ImportStatus is null);
           End

           IF EXISTS (SELECT ID FROM   ImportEmployment WHERE  EmployeeId IS NULL  AND TransactionId = @TransactionId)
           BEGIN
           UPDATE ImportEmployment SET    ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Employee ID') Else 'Please enter the Employee ID' End,ImportStatus = 0 
		   WHERE  EmployeeId IS NULL AND TransactionId = @TransactionId  
           END

           IF EXISTS (SELECT Id,TypeofEmployment FROM   ImportEmployment WHERE  TypeofEmployment IS NULL  AND TransactionId = @TransactionId)
           BEGIN
           UPDATE ImportEmployment SET ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please select the Type of Employment') Else 'Please select the Type of Employment' End,ImportStatus = 0
           WHERE  TypeofEmployment IS NULL AND TransactionId = @TransactionId 
           END

           IF EXISTS (SELECT Id,EmploymentStartDate FROM   ImportEmployment WHERE  EmploymentStartDate IS NULL  AND TransactionId = @TransactionId)
           BEGIN
           UPDATE ImportEmployment SET  ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Start Date') Else 'Please enter the Start Date' End,ImportStatus = 0
           WHERE  EmploymentStartDate IS NULL AND TransactionId = @TransactionId 
           END

           IF EXISTS (SELECT Id,EmployeeId FROM   ImportEmployeeDepartment WHERE  EmployeeId IS NULL  AND TransactionId = @TransactionId)
           BEGIN
           UPDATE ImportEmployeeDepartment SET  ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Employee ID') Else 'Please enter the Employee ID' End,ImportStatus = 0
           WHERE  EmployeeId IS NULL AND TransactionId = @TransactionId 
           END

           IF EXISTS (SELECT ID,EntityName FROM   ImportEmployeeDepartment WHERE  EntityName IS NULL  AND TransactionId = @TransactionId)
           BEGIN
           UPDATE ImportEmployeeDepartment SET  ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Entity Name Does not Exist') Else 'Entity Name Does not Exist' End,ImportStatus = 0
           WHERE  EntityName IS NULL AND TransactionId = @TransactionId 
           END

           IF EXISTS (SELECT ID,Department FROM   ImportEmployeeDepartment WHERE  Department IS NULL  AND TransactionId = @TransactionId)
           BEGIN
           UPDATE ImportEmployeeDepartment SET ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Department') Else 'Please enter the Department' End,ImportStatus = 0
           WHERE  Department IS NULL AND TransactionId = @TransactionId 
           END
           IF EXISTS (SELECT id,Designation FROM   ImportEmployeeDepartment WHERE  Designation IS NULL  AND TransactionId = @TransactionId)
           BEGIN
           UPDATE ImportEmployeeDepartment SET    ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please select the Designation') Else 'Please select the Designation' End,ImportStatus = 0
           WHERE  Designation IS NULL AND TransactionId = @TransactionId  
           END

    --      UPDATE A SET A.ErrorRemarks = 'Employment Start Date should be equal or less than the Effective From Date',A.ImportStatus = 0
		  --FROM   ImportEmployeeDepartment AS A
    --      INNER JOIN ImportEmployment AS B ON A.EmployeeId = B.EmployeeId AND A.TransactionId = B.TransactionId
    --      WHERE  A.TransactionId = @TransactionId and B.TransactionId=@TransactionId AND A.EffectiveFrom >= B.EmploymentStartDate 

            IF EXISTS (SELECT id,EmployeeId FROM   ImportQualification WHERE  EmployeeId IS NULL AND TransactionId = @TransactionId)
            BEGIN
            UPDATE ImportQualification SET ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Employee Id') Else 'Please enter the Employee Id' End,ImportStatus = 0
            WHERE  EmployeeId IS NULL AND TransactionId = @TransactionId 
            END

            IF EXISTS (SELECT id,EmployeeId FROM   ImportFamily WHERE  EmployeeId IS NULL  AND TransactionId = @TransactionId)
            BEGIN
            UPDATE ImportFamily SET ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Employee Id') Else 'Please enter the Employee Id' End, ImportStatus = 0
            WHERE  EmployeeId IS NULL AND TransactionId = @TransactionId 
            END

            IF EXISTS (SELECT id,EffectiveFrom FROM   ImportEmployeeDepartment WHERE  EffectiveFrom IS NULL  AND TransactionId = @TransactionId)
            BEGIN
            UPDATE ImportEmployeeDepartment SET  ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Effective From') Else 'Please enter the Effective From' End,ImportStatus = 0
            WHERE  EffectiveFrom IS NULL  AND TransactionId = @TransactionId 
            END

            UPDATE ImportPersonalDetails SET  ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Employee Id') Else 'Please enter the Employee Id' End  ,ImportStatus = 0
		    WHERE   TransactionId = @TransactionId and EmployeeId  not in(select EmployeeId from ImportEmployment where TransactionId = @TransactionId AND EmployeeId IS NOT NULL )

	        update ImportPersonalDetails set ImportStatus=case when ISNUMERIC(Replace(Replace(Replace(Mobile,'+','1'),' ','2'),'-','3'))=0 Then 0 end  ,
		    ErrorRemarks= Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Mobile allows to enter only Numbers') Else 'Mobile allows to enter only Numbers' End     
			where TransactionId=@TransactionId and Mobile is not null and case when ISNUMERIC(Replace(Replace(Replace(Mobile,'+','1'),' ','2'),'-','3'))=0 Then 0 end=0



				 --UPDATE ImportPersonalDetails SET  ErrorRemarks = 'Mandatory field EmployeeDepartment Employee Id  missed',ImportStatus = 0
     --           WHERE   TransactionId = @TransactionId AND (ImportStatus <> 0 or ImportStatus is null)
				 --and EmployeeId  not in
				 --(select EmployeeId from ImportEmployeeDepartment where TransactionId = @TransactionId  AND (ImportStatus <> 0 or ImportStatus is null)  )


				 --UPDATE ImportPersonalDetails SET  ErrorRemarks = 'Mandatory field ImportFamily Employee Id  missed',ImportStatus = 0
     --           WHERE   TransactionId = @TransactionId AND (ImportStatus <> 0 or ImportStatus is null)
				 --and EmployeeId  not in
				 --(select EmployeeId from ImportFamily where TransactionId = @TransactionId  AND (ImportStatus <> 0 or ImportStatus is null)  )
			---suresh


			 

		Declare @ImportStatus int
        CREATE TABLE #Empl_Temp (Id INT IDENTITY (1, 1),EmpId UNIQUEIDENTIFIER,UserName NVARCHAR (4000),EmployeeId NVARCHAR (4000),Mobile NVARCHAR (4000),Email NVARCHAR (4000),CompanyId  BIGINT,IdNo NVARCHAR (4000),IdType NVARCHAR (4000),ImportStatus Varchar(100));
        CREATE TABLE #Strng_Splt (Id INT IDENTITY (1, 1),AddrName NVARCHAR (MAX));
        INSERT INTO #Empl_Temp (EmpId, EmployeeId, UserName, Mobile, Email, CompanyId, IdNo,IdType,ImportStatus)
        SELECT DISTINCT ID,EmployeeId,UserName,Mobile,Email,@CompanyId,IdNumber,IdType,importstatus FROM ImportPersonalDetails 
		WHERE TransactionId = @TransactionId --AND (ImportStatus <> 0 Or ImportStatus is null)
		 Order by EmployeeId;
              SET @Count = (SELECT Count(*) FROM   #Empl_Temp);
         WHILE @Count >= @InnerCount
         BEGIN

		  --===================== 03.12.2019
		 
         Begin Transaction  
         Begin Try  
		 --==================== 03.12.2019



                 SELECT @EmpId = EmpId,@EmployeeId = EmployeeId,@UserName = Username,@Mobile = Mobile,@Email = Email,@IdNo = IdNo ,@IdType=IdType,@ImportStatus=importstatus FROM   #Empl_Temp
                 WHERE  Id = @InnerCount Order by  EmployeeId;

				SELECT @DeptName = Department,@DesgName = Designation FROM   ImportEmployeeDepartment
                WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId /*AND (ImportStatus <> 0 Or ImportStatus is null)*/;


	

				     Select @LocalAddress=LocalAddress,@ForigenAddress=Foreignaddress
	                 From ImportPersonalDetails
	                 Where   TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and ( LocalAddress is not null or Foreignaddress is not null)

					 --================================ LocalAddress in  ClientCursor.Account table=========================================
					 
					  If @LocalAddress Is Not Null  
					  Begin
					  	
					  Create Table #Strng7_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))

					  Insert Into #Strng7_Splt(AddrName)
					  Select Value From string_split(@LocalAddress,',')

					  IF Exists( Select AddrName From #Strng7_Splt Where Id=1 AND LEN(AddrName) >@LcBlockHouseNo )
					  begin
					  Update ImportPersonalDetails set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress BlockHouseNo Length Less then', CAST(@LcBlockHouseNo as nvarchar(100)))
                      Else CONCAT('Please enter the BlockHouseNo Length Less then', CAST(@LcBlockHouseNo as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and LocalAddress is not null
					  end
					   
					  if Exists (Select AddrName From #Strng7_Splt Where Id=2 AND LEN(AddrName) >@LcStreet)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress Street Length Less then', CAST(@LcStreet as nvarchar(100)))
                      Else CONCAT('Please enter the Street Length Less then', CAST(@LcStreet as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and LocalAddress is not null
					  end
						
					  if Exists (Select AddrName From #Strng7_Splt Where Id=3 AND LEN(AddrName) >@LcUnitNo)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100)))
                      Else CONCAT('Please enter the UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and LocalAddress is not null
					  end 

					  if Exists (Select AddrName From #Strng7_Splt Where Id=4 AND LEN(AddrName) >@LcBuildingEstate)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress BuildingEstate Length Less then', CAST(@LcBuildingEstate as nvarchar(100)))
                      Else CONCAT('Please enter the BuildingEstate Length Less then', CAST(@LcBuildingEstate as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and LocalAddress is not null
					  end 

					  if Exists (Select AddrName From #Strng7_Splt Where Id=5 AND LEN(AddrName) >@LcCity)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress City Length Less then', CAST(@LcCity as nvarchar(100)))
                      Else CONCAT('Please enter the City Length Less then', CAST(@LcCity as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and LocalAddress is not null
					  end

					   if Exists (Select AddrName From #Strng7_Splt Where Id=5 AND LEN(AddrName) >@LcState)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress state Length Less then', CAST(@LcState as nvarchar(100)))
                      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and LocalAddress is not null
					  end

					   if Exists (Select AddrName From #Strng7_Splt Where Id=5 AND LEN(AddrName) >@LcCountry)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks =  Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress Country Length Less then ', CAST(@LcCountry as nvarchar(100)))
                      Else CONCAT('Please enter the Country Length Less then ', CAST(@LcCountry as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and LocalAddress is not null
					  end

					  if Exists (Select AddrName From #Strng7_Splt Where Id=6 AND LEN(AddrName) >@LcPostalCode)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the LocalAddress PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100)))
                      Else CONCAT('Please enter the PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and LocalAddress is not null
					  end
					  drop table #Strng7_Splt
					  end
					 --=======================================================@ForigenAddress in  ClientCursor.Account table========================================
					  If @ForigenAddress Is Not Null  
					  Begin

					  Create Table #Strng8_Splt (Id Int Identity(1,1),AddrName Nvarchar(Max))
					  Insert Into #Strng8_Splt(AddrName)
				      Select Value From string_split(@ForigenAddress,',')
			        
					  if Exists (Select AddrName From #Strng8_Splt Where Id=1 AND LEN(AddrName) >@LcStreet)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress state Length Less then', CAST(@LcState as nvarchar(100)))
                      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and Foreignaddress is not null
					  end

					  if Exists (Select AddrName From #Strng8_Splt Where Id=2 AND LEN(AddrName) >@LcUnitNo)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100)))
                      Else CONCAT('Please enter the UnitNo Length Less then', CAST(@LcUnitNo as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and Foreignaddress is not null
					  end 

                      if Exists (Select AddrName From #Strng8_Splt Where Id=3 AND LEN(AddrName) >@LcCity)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress City Length Less then', CAST(@LcCity as nvarchar(100)))
                      Else CONCAT('Please enter the City Length Less then', CAST(@LcCity as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and Foreignaddress is not null
					  end

					  
                      if Exists (Select AddrName From #Strng8_Splt Where Id=4 AND LEN(AddrName) >@LcState)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress state Length Less then', CAST(@LcState as nvarchar(100)))
                      Else CONCAT('Please enter the state Length Less then', CAST(@LcState as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and Foreignaddress is not null
					  end
					  
                      if Exists (Select AddrName From #Strng8_Splt Where Id=5 AND LEN(AddrName) >@LcCountry)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress Country Length Less then ', CAST(@LcCountry as nvarchar(100)))
                      Else CONCAT('Please enter the Country Length Less then ', CAST(@LcCountry as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and Foreignaddress is not null
					  end
						
					  if Exists (Select AddrName From #Strng8_Splt Where Id=6 AND LEN(AddrName) >@LcPostalCode)
					  begin
					  Update ImportPersonalDetails set ErrorRemarks = Case when ErrorRemarks is not null then CONCAT(ErrorRemarks,',','Please enter the Foreignaddress PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100)))
                      Else CONCAT('Please enter the PostalCode Length Less then ', CAST(@LcPostalCode as nvarchar(100))) end, ImportStatus=0
		              where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId and Foreignaddress is not null
					  end
					  drop table #Strng8_Splt
					  end 

    --============================================================================end Address check length ==========================================================

          BEGIN TRY
	           update kk set kk.ImportStatus=case when  [month]=2 and [day] Between 1 and 29 then 1
               when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
               when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,
			   ErrorRemarks= Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','DateofSPRGranted must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'DateofSPRGranted must be in DD/MM/YYYY (Ex:31/01/1992) Format' End  from
              (
              select id,DateofSPRGranted,ImportStatus,ErrorRemarks,SUBSTRING(DateofSPRGranted,1,Charindex('/',DateofSPRGranted)-1) as 'DAY',SUBSTRING(DateofSPRGranted,Charindex('/',DateofSPRGranted)+1,Charindex('/',SUBSTRING(DateofSPRGranted,Charindex('/',DateofSPRGranted)+1,LEN(DateofSPRGranted)))-1)
              AS 'Month'  from ImportPersonalDetails  where TransactionId=@TransactionId
              /*and (ImportStatus<>0 Or ImportStatus is null)*/ and (DateofSPRGranted is not null or DateofSPRGranted<>'')
		       and Id = @EmpId and EmployeeId=@EmployeeId  --and  Username=@UserName
              )kk
              where  case when  [month]=2 and [day] Between 1 and 29 then 1
              when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
              when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
          END TRY

		      BEGIN CATCH
		             Declare @error nvarchar(max) = error_message();
					 If @error is not null
	                 begin 
                     UPDATE  ImportPersonalDetails set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','DateofSPRGranted must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'DateofSPRGranted must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					 ,ImportStatus=0  where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId  --and  Username=@UserName
                     End 
               END CATCH
 
          BEGIN TRY
             update kk set kk.ImportStatus=case when  [month]=2 and [day] Between 1 and 29 then 1
             when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
             when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','DateofBirth must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'DateofBirth must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
			  from
            (
             select id,DateofBirth,ImportStatus,ErrorRemarks,SUBSTRING(DateofBirth,1,Charindex('/',DateofBirth)-1) as 'DAY',SUBSTRING(DateofBirth,Charindex('/',DateofBirth)+1,Charindex('/',SUBSTRING(DateofBirth,Charindex('/',DateofBirth)+1,LEN(DateofBirth)))-1)
             AS 'Month'  from ImportPersonalDetails  where TransactionId=@TransactionId
             /*and (ImportStatus<>0 Or ImportStatus is null)*/ and (DateofBirth is not null or DateofBirth<>'')
		     and Id = @EmpId and EmployeeId=@EmployeeId  --and  Username=@UserName
             )kk
             where  case when  [month]=2 and [day] Between 1 and 29 then 1
             when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
             when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
         END TRY
		    BEGIN CATCH
		         Declare @error1 nvarchar(max) = error_message();
				 If @error1 is not null
	             begin 
                 UPDATE  ImportPersonalDetails set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','DateofBirth must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'DateofBirth must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
				 ,ImportStatus=0  where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId  --and  Username=@UserName
                 End 
             END CATCH

	 BEGIN TRY
           update kk set kk.ImportStatus=
           case when  [month]=2 and [day] Between 1 and 29 then 1
           when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
            when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,
			ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','PassportExpiry must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'PassportExpiry must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
			 from
           (
            select id,PassportExpiry,ImportStatus,ErrorRemarks,SUBSTRING(PassportExpiry,1,Charindex('/',PassportExpiry)-1) as 'DAY',SUBSTRING(PassportExpiry,Charindex('/',PassportExpiry)+1,Charindex('/',SUBSTRING(PassportExpiry,Charindex('/',PassportExpiry)+1,LEN(PassportExpiry)))-1)
            AS 'Month'  from ImportPersonalDetails  where TransactionId=@TransactionId
            /*and (ImportStatus<>0 Or ImportStatus is null)*/ and (PassportExpiry is not null or PassportExpiry<>'')
		     and Id = @EmpId and EmployeeId=@EmployeeId  ---and  Username=@UserName
            )kk
            where  case when  [month]=2 and [day] Between 1 and 29 then 1
            when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
            when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
     END TRY
		   BEGIN CATCH
		             Declare @error2 nvarchar(max) = error_message();
                     If @error2 is not null
	                 begin 
					 UPDATE  ImportPersonalDetails set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','PassportExpiry must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'PassportExpiry must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					 ,ImportStatus=0  where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId  --and  Username=@UserName
                     End 
            END CATCH

	 BEGIN TRY
           update kk set kk.ImportStatus=
           case when  [month]=2 and [day] Between 1 and 29 then 1
           when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
           when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','EmploymentEndDate must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'EmploymentEndDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
		    from
          (
          select id,EmploymentEndDate,ImportStatus,ErrorRemarks,SUBSTRING(EmploymentEndDate,1,Charindex('/',EmploymentEndDate)-1) as 'DAY',SUBSTRING(EmploymentEndDate,Charindex('/',EmploymentEndDate)+1,Charindex('/',SUBSTRING(EmploymentEndDate,Charindex('/',EmploymentEndDate)+1,LEN(EmploymentEndDate)))-1)
          AS 'Month'  from ImportEmployment  where TransactionId=@TransactionId
          /*and (ImportStatus<>0 Or ImportStatus is null)*/ and (EmploymentEndDate is not null or EmploymentEndDate<>'')
		   AND EmployeeId = @EmployeeId 
          )kk
          where  case when  [month]=2 and [day] Between 1 and 29 then 1
          when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
          when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
    END TRY
		 BEGIN CATCH
		         Declare @error3 nvarchar(max) = error_message();
			     If @error3 is not null
	             begin 
		         UPDATE  ImportEmployment set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','EmploymentEndDate must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'EmploymentEndDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
				 ,ImportStatus=0  where  TransactionId=@TransactionId  and  EmployeeId=@EmployeeId  
			     End 
         END CATCH  
    BEGIN TRY
           update kk set kk.ImportStatus=
           case when  [month]=2 and [day] Between 1 and 29 then 1
           when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
           when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','ConfirmationDate must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'ConfirmationDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
		    from
           (
           select id,ConfirmationDate,ImportStatus,ErrorRemarks,SUBSTRING(ConfirmationDate,1,Charindex('/',ConfirmationDate)-1) as 'DAY',SUBSTRING(ConfirmationDate,Charindex('/',ConfirmationDate)+1,Charindex('/',SUBSTRING(ConfirmationDate,Charindex('/',ConfirmationDate)+1,LEN(ConfirmationDate)))-1)
           AS 'Month'  from ImportEmployment  where TransactionId=@TransactionId
           /*and (ImportStatus<>0 Or ImportStatus is null)*/ and (ConfirmationDate is not null or ConfirmationDate<>'')
		   AND EmployeeId = @EmployeeId 
           )kk
           where  case when  [month]=2 and [day] Between 1 and 29 then 1
           when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
           when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
    END TRY
		    BEGIN CATCH
		            Declare @error4 nvarchar(max) = error_message();
					If @error4 is not null
	                begin 
			        UPDATE  ImportEmployment set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','ConfirmationDate must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'ConfirmationDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					,ImportStatus=0  where  TransactionId=@TransactionId  and  EmployeeId=@EmployeeId  
                    End 
             END CATCH

	        
  BEGIN TRY
           update kk set kk.ImportStatus=
           case when  [month]=2 and [day] Between 1 and 29 then 1
           when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
           when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','RejoinDate must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'RejoinDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
		    from
           (
           select id,RejoinDate,ImportStatus,ErrorRemarks,SUBSTRING(RejoinDate,1,Charindex('/',RejoinDate)-1) as 'DAY',SUBSTRING(RejoinDate,Charindex('/',RejoinDate)+1,Charindex('/',SUBSTRING(RejoinDate,Charindex('/',RejoinDate)+1,LEN(RejoinDate)))-1)
           AS 'Month'  from ImportEmployment  where TransactionId=@TransactionId
           /*and (ImportStatus<>0 Or ImportStatus is null)*/ and (RejoinDate is not null or RejoinDate<>'')
		   AND EmployeeId = @EmployeeId 
           )kk
           where  case when  [month]=2 and [day] Between 1 and 29 then 1
           when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
           when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
 END TRY
		    BEGIN CATCH
		             Declare @error5 nvarchar(max) = error_message();
					  If @error5 is not null
	                   begin 
					   UPDATE  ImportEmployment set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',', 'RejoinDate must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else  'RejoinDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					  ,ImportStatus=0  where  TransactionId=@TransactionId  and  EmployeeId=@EmployeeId  
                       End 
			END CATCH

	 BEGIN TRY
          update kk set kk.ImportStatus=
          case when  [month]=2 and [day] Between 1 and 29 then 1
          when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
          when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','StartDate must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'StartDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
		   from
         (
          select id,StartDate,ImportStatus,ErrorRemarks,SUBSTRING(StartDate,1,Charindex('/',StartDate)-1) as 'DAY',SUBSTRING(StartDate,Charindex('/',StartDate)+1,Charindex('/',SUBSTRING(StartDate,Charindex('/',StartDate)+1,LEN(StartDate)))-1)
          AS 'Month'  from ImportQualification  where TransactionId=@TransactionId
          /*and (ImportStatus<>0 Or ImportStatus is null)*/ and (StartDate is not null or StartDate<>'')
		  AND EmployeeId = @EmployeeId 
          )kk
          where  case when  [month]=2 and [day] Between 1 and 29 then 1
          when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
          when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0

   END TRY
		    BEGIN CATCH
		             Declare @error6 nvarchar(max) = error_message();
					 If @error6 is not null
	                 begin 
			         UPDATE  ImportQualification set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','StartDate must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'StartDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					 ,ImportStatus=0  where  TransactionId=@TransactionId  and  EmployeeId=@EmployeeId  
                     End 
		      END CATCH

	         

   BEGIN TRY
              update kk set kk.ImportStatus=
              case when  [month]=2 and [day] Between 1 and 29 then 1
              when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
              when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','EndDate must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'EndDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
			   from
             (
             select id,EndDate,ImportStatus,ErrorRemarks,SUBSTRING(EndDate,1,Charindex('/',EndDate)-1) as 'DAY',SUBSTRING(EndDate,Charindex('/',EndDate)+1,Charindex('/',SUBSTRING(EndDate,Charindex('/',EndDate)+1,LEN(EndDate)))-1)
             AS 'Month'  from ImportQualification  where TransactionId=@TransactionId
             /*and (ImportStatus<>0 Or ImportStatus is null)*/ and (EndDate is not null or EndDate<>'')
			 AND EmployeeId = @EmployeeId 
             )kk
             where  case when  [month]=2 and [day] Between 1 and 29 then 1
             when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
             when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
  END TRY
		 BEGIN CATCH
		             Declare @error7 nvarchar(max) = error_message();
					 If @error7 is not null
					 begin 
                     UPDATE  ImportQualification set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','EndDate must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'EndDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					 ,ImportStatus=0  where  TransactionId=@TransactionId  and  EmployeeId=@EmployeeId  
                     End 
		END CATCH
   BEGIN TRY
            update kk set kk.ImportStatus=
            case when  [month]=2 and [day] Between 1 and 29 then 1
            when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
            when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','DateofBirth must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'DateofBirth must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
			 from
            (
            select id,DateofBirth,ImportStatus,ErrorRemarks,SUBSTRING(DateofBirth,1,Charindex('/',DateofBirth)-1) as 'DAY',SUBSTRING(DateofBirth,Charindex('/',DateofBirth)+1,Charindex('/',SUBSTRING(DateofBirth,Charindex('/',DateofBirth)+1,LEN(DateofBirth)))-1)
            AS 'Month'  from ImportFamily  where TransactionId=@TransactionId
             and (DateofBirth is not null or DateofBirth<>'')
			AND EmployeeId = @EmployeeId 
            )kk
            where  case when  [month]=2 and [day] Between 1 and 29 then 1
            when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
            when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
    END TRY
		    BEGIN CATCH
		             Declare @error8 nvarchar(max) = error_message();
					 If @error8 is not null
                      begin 
                      UPDATE  ImportFamily set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','DateofBirth must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'DateofBirth must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					  ,ImportStatus=0  where  TransactionId=@TransactionId  and  EmployeeId=@EmployeeId  
                      End 
		     END CATCH

	BEGIN TRY
            update kk set kk.ImportStatus=
            case when  [month]=2 and [day] Between 1 and 29 then 1
            when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
            when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','EmploymentStartDate must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'EmploymentStartDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
			 from
            (
            select id,EmploymentStartDate,ImportStatus,ErrorRemarks,SUBSTRING(EmploymentStartDate,1,Charindex('/',EmploymentStartDate)-1) as 'DAY',SUBSTRING(EmploymentStartDate,Charindex('/',EmploymentStartDate)+1,Charindex('/',SUBSTRING(EmploymentStartDate,Charindex('/',EmploymentStartDate)+1,LEN(EmploymentStartDate)))-1)
            AS 'Month'  from ImportEmployment  where TransactionId=@TransactionId
            /*and (ImportStatus<>0 Or ImportStatus is null)*/ and (EmploymentStartDate is not null or EmploymentStartDate<>'')
			 AND EmployeeId = @EmployeeId 
            )kk
            where  case when  [month]=2 and [day] Between 1 and 29 then 1
            when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
            when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
    END TRY
		   BEGIN CATCH
		             Declare @error9 nvarchar(max) = error_message();
					 If @error9 is not null
	                 begin 
                     UPDATE  ImportEmployment set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','EmploymentStartDate must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'EmploymentStartDate must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					 ,ImportStatus=0  where  TransactionId=@TransactionId  and  EmployeeId=@EmployeeId  
                     End 
           END CATCH

	       
  BEGIN TRY
            update kk set kk.ImportStatus=
            case when  [month]=2 and [day] Between 1 and 29 then 1
            when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
            when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end ,ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','EffectiveFrom must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'EffectiveFrom must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
			 from
            (
            select id,EffectiveFrom,ImportStatus,ErrorRemarks,SUBSTRING(EffectiveFrom,1,Charindex('/',EffectiveFrom)-1) as 'DAY',SUBSTRING(EffectiveFrom,Charindex('/',EffectiveFrom)+1,Charindex('/',SUBSTRING(EffectiveFrom,Charindex('/',EffectiveFrom)+1,LEN(EffectiveFrom)))-1)
            AS 'Month'  from ImportEmployeeDepartment  where TransactionId=@TransactionId
            /*and (ImportStatus<>0 or ImportStatus is null)*/ and (EffectiveFrom is not null or EffectiveFrom<>'')
			  and Department = @DeptName AND Designation = @DesgName   AND EmployeeId = @EmployeeId
            )kk
            where  case when  [month]=2 and [day] Between 1 and 29 then 1
            when  [month] in (1,3,5,7,8,10,12) and [day] Between 1 and 31 then 1
            when  [month] in (4,6,9,11) and [day] Between 1 and 30 then 1 else 0  end=0
   END TRY
		 BEGIN CATCH
		             Declare @error10 nvarchar(max) = error_message();
					 If @error10 is not null
                     begin 
                     UPDATE  ImportEmployeeDepartment set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','EffectiveFrom must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'EffectiveFrom must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					 ,ImportStatus=0  where  TransactionId=@TransactionId  and Department = @DeptName AND Designation = @DesgName   AND EmployeeId = @EmployeeId 
                     End 
		 END CATCH

	 BEGIN TRY
			   UPDATE A SET A.ErrorRemarks =Case When A.ErrorRemarks Is Not Null Then CONCAT(A.ErrorRemarks,',','Employment Start Date should be equal or less than the Effective From Date') Else 'Employment Start Date should be equal or less than the Effective From Date' End
			   ,A.ImportStatus = 0
		       FROM   ImportEmployeeDepartment AS A
               INNER JOIN ImportEmployment AS B ON A.EmployeeId = B.EmployeeId AND A.TransactionId = B.TransactionId
               WHERE  A.TransactionId = @TransactionId and B.TransactionId=@TransactionId 
			   AND CONVERT(datetime2, B.EmploymentStartDate, 103) >  CONVERT(datetime2, A.EffectiveFrom , 103)

			   and (A.EffectiveFrom  is not null or A.EffectiveFrom <>'') and (B.EmploymentStartDate is not null or B.EmploymentStartDate<>'')
		       and Department = @DeptName AND Designation = @DesgName   AND a.EmployeeId = @EmployeeId and b.EmployeeId=@EmployeeId
      END TRY
	        BEGIN CATCH
		             Declare @error11 nvarchar(max) = error_message();
					 If @error11 is not null
	                 begin 
                     UPDATE  ImportEmployeeDepartment set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Employment Start Date must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'Employment Start Date must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					 ,ImportStatus=0  where  TransactionId=@TransactionId  and Department = @DeptName AND Designation = @DesgName   AND EmployeeId = @EmployeeId 
                     End 
		  END CATCH



		  	 BEGIN TRY
			   UPDATE A SET A.ErrorRemarks =Case When A.ErrorRemarks Is Not Null Then CONCAT(A.ErrorRemarks,',','Employment Start Date should be equal or less than the Employment End Date ') Else 'Employment Start Date should be equal or less than the Employment End Date ' End
			   ,A.ImportStatus = 0
		       FROM   ImportEmployment AS A
               WHERE  A.TransactionId = @TransactionId  AND CONVERT(datetime2, A.EmploymentStartDate, 103) >  CONVERT(datetime2, a.EmploymentEndDate, 103)
			   and (A.EmploymentEndDate  is not null or a.EmploymentEndDate <>'') and (a.EmploymentStartDate is not null or a.EmploymentStartDate<>'')
		       AND a.EmployeeId = @EmployeeId 
           END TRY
	        
			
			BEGIN CATCH
		             Declare @error21 nvarchar(max) = error_message();
					 If @error21 is not null
	                 begin 
                     UPDATE  ImportEmployment set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Employment Start Date or EmploymentEndDate  must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'Employment Start Date or EmploymentEndDate  must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					 ,ImportStatus=0  where  TransactionId=@TransactionId  AND EmployeeId = @EmployeeId 
                     End 
		  END CATCH


    BEGIN TRY
			  UPDATE a SET a.ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Employment Start Date should be equal or less than the EndDate') Else 'Employment Start Date should be equal or less than the EndDate' End
			  ,A.ImportStatus = 0
		      FROM    ImportQualification a   where TransactionId=@TransactionId
			  and (EndDate is not null or EndDate<>'') and (Startdate is not null or Startdate<>'')
			  AND EmployeeId = @EmployeeId   AND CONVERT(datetime2, A.Startdate, 103) >  CONVERT(datetime2, a.EndDate, 103)
     END TRY
		   BEGIN CATCH
		             Declare @error14 nvarchar(max) = error_message();
					 If @error14 is not null
	                 begin 
                     UPDATE  ImportQualification set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Employment Start Date must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'Employment Start Date must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					 ,ImportStatus=0  where  TransactionId=@TransactionId  AND EmployeeId = @EmployeeId 
                     End 
		    END CATCH

	    BEGIN TRY
		        Update ImportPersonalDetails set ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Date of birth cannot be a future date') Else 'Date of birth cannot be a future date' End
				, ImportStatus=0
		        where  CONVERT(datetime2, DateofBirth, 103) > GETUTCDATE() and  TransactionId=@TransactionId 
		        and id  in (select ID from ImportPersonalDetails  where  TransactionId=@TransactionId 
				and ( DateofBirth is not null OR DateofBirth=''))
				and Id = @EmpId and EmployeeId=@EmployeeId  ---and  Username=@UserName
	    END TRY
		     BEGIN CATCH
		             Declare @error12 nvarchar(max) = error_message();
					 If @error12 is not null
	                 begin 
                     UPDATE  ImportPersonalDetails set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Date of birth must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'Date of birth must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					 ,ImportStatus=0  where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId AND (ImportStatus<>0  OR ImportStatus IS NULL)  --and  Username=@UserName
                     End 
             END CATCH
       BEGIN TRY
			     Update ImportFamily set ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Date of birth cannot be a future date') Else 'Date of birth cannot be a future date' End
				 , ImportStatus=0
		         where  CONVERT(datetime2, DateofBirth, 103) > GETUTCDATE() and  TransactionId=@TransactionId
		         and id  in (select ID from ImportPersonalDetails  where  TransactionId=@TransactionId and (DateofBirth is not null OR DateofBirth=''))
	             and  EmployeeId=@EmployeeId 
        END TRY
		    BEGIN CATCH
		             Declare @error13 nvarchar(max) = error_message();
					 If @error13 is not null
	                begin 
                    UPDATE  ImportFamily set ErrorRemarks=Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Date of birth must be in DD/MM/YYYY (Ex:31/01/1992) Format') Else 'Date of birth must be in DD/MM/YYYY (Ex:31/01/1992) Format' End
					,ImportStatus=0  where  TransactionId=@TransactionId  and  EmployeeId=@EmployeeId AND (ImportStatus<>0  OR ImportStatus IS NULL)
                    End 
		    END CATCH



                IF EXISTS (SELECT Id FROM   Common.Department WHERE  Name = @DeptName AND CompanyId = @CompanyId)
                    BEGIN
                        SET @DeptId = (SELECT Id FROM   Common.Department WHERE  Name = @DeptName AND CompanyId = @CompanyId);
                    END
                ELSE
                    BEGIN
                        SET @DeptId = CAST (0x0 AS UNIQUEIDENTIFIER);
                    END
                IF EXISTS (SELECT Id FROM   Common.DepartmentDesignation WHERE  Name = @DesgName AND DepartmentId = @DeptId)
                    BEGIN
                        SET @DesgId = (SELECT Id FROM  Common.DepartmentDesignation WHERE  Name = @DesgName AND DepartmentId = @DeptId);
                    END
                ELSE
                    BEGIN
                        SET @DesgId = CAST (0x0 AS UNIQUEIDENTIFIER);
                    END
                SELECT @EntityName = EntityName FROM   ImportEmployeeDepartment WHERE  Department = @DeptName
                       AND Designation = @DesgName AND TransactionId = @TransactionId AND EmployeeId = @EmployeeId 
					   /*AND (ImportStatus <> 0 Or ImportStatus is null)*/;
                SET @UserNameCheck = (SELECT 1 FROM   Common.CompanyUser WHERE  Username = @UserName AND CompanyId = @CompanyId);
				------/////
				IF EXISTS (SELECT Id FROM   Common.Employee WHERE  Username = @UserName AND CompanyId = @CompanyId)
                BEGIN
                    UPDATE ImportPersonalDetails SET Importstatus = 0,ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','UserName Already Exists') Else 'UserName Already Exists' End
				
                    WHERE  TransactionId = @TransactionId AND UserName = @UserName AND Id = @EmpId;
                END
				IF Not EXISTS (SELECT Id FROM   Common.Company WHERE  ParentId = @CompanyId AND Name = @EntityName)
                BEGIN
                    UPDATE ImportEmployeeDepartment SET    Importstatus = 0,ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Entity Name Does not Exist') Else 'Entity Name Does not Exist' End
				
                    WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Designation = @DesgName AND Department = @DeptName;
                END
				IF EXISTS (SELECT idno FROM   Common.Employee WHERE  IdNo = @IdNo and IdType=@IdType AND CompanyId = @CompanyId)
				BEGIN
                    UPDATE ImportPersonalDetails SET ImportStatus = 0,ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',',' Id Number Already Exists') Else ' Id Number Already Exists' End
				
                    WHERE  EmployeeId = @EmployeeId AND TransactionId = @TransactionId and id=@EmpId;
                END
				IF Not EXISTS (SELECT EmployeeId FROM   ImportPersonalDetails
                       WHERE  TransactionId = @TransactionId AND EmployeeId IN (SELECT EmployeeId FROM   ImportEmployment
                        WHERE  TransactionId = @TransactionId AND EmployeeId IN (SELECT EmployeeId FROM   ImportEmployeeDepartment
                        WHERE  TransactionId = @TransactionId And EmployeeId=@EmployeeId)))
                BEGIN
                    UPDATE ImportPersonalDetails SET    ImportStatus = 0,ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please insert The Same Employee Id') Else 'Please insert The Same Employee Id' End
				
                    WHERE  EmployeeId = @EmployeeId AND TransactionId = @TransactionId and id=@EmpId;
                END
				IF @UserName IS Not NULL
                   And (@UserNameCheck <> 1 Or @UserNameCheck Is Null)
                BEGIN
                    UPDATE ImportPersonalDetails SET    ImportStatus = 0,ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Username Doesnot Exists') Else 'Username Doesnot Exists' End
				
                    WHERE  UserName = @UserName AND TransactionId = @TransactionId and id=@EmpId;
                END
				IF EXISTS (SELECT Id FROM   Common.Employee WHERE  EmployeeId = @EmployeeId AND CompanyId = @CompanyId)
                BEGIN
                    UPDATE ImportPersonalDetails SET Importstatus = 0,ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Employee Id Already Exists') Else 'Employee Id Already Exists.' End
				
                          WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Id = @EmpId;
                END
				----/////
				Set @ImportStatus= (Select Distinct ImportStatus From ImportPersonalDetails where TransactionId=@TransactionId And EmployeeId=@EmployeeId And ID=@EmpId)
				If @ImportStatus<>0 Or @ImportStatus Is Null
				Begin
                IF @UserName IS NULL
                   OR @UserNameCheck = 1
                    BEGIN
                        IF EXISTS (SELECT EmployeeId FROM   ImportPersonalDetails
                                   WHERE  TransactionId = @TransactionId AND EmployeeId IN (SELECT EmployeeId FROM   ImportEmployment
                                    WHERE  TransactionId = @TransactionId AND EmployeeId IN (SELECT EmployeeId FROM   ImportEmployeeDepartment
                                    WHERE  TransactionId = @TransactionId And EmployeeId=@EmployeeId)))
                            BEGIN


                                IF NOT EXISTS (SELECT idno FROM   Common.Employee WHERE  IdNo = @IdNo and IdType=@IdType AND CompanyId = @CompanyId)
                                    BEGIN
                                        UPDATE ImportPersonalDetails SET    Importstatus = 1,ErrorRemarks =Null /*'Null'*/
                                        WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Id = @EmpId And (Importstatus<>0 Or ImportStatus Is Null);
                                        IF EXISTS (SELECT Id FROM   Common.Company WHERE  ParentId = @CompanyId AND Name = @EntityName)
                                            BEGIN
                                                UPDATE ImportEmployeeDepartment SET Importstatus = 1,ErrorRemarks = Null/*'Null'*/
                                                WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND EntityName = @EntityName And (Importstatus<>0 Or ImportStatus Is Null);
                                                IF ((@DeptId IS NOT NULL AND @DeptId <> '00000000-0000-0000-0000-000000000000')
												AND (@DesgId IS NOT NULL AND @DesgId <> '00000000-0000-0000-0000-000000000000'))
                                                    BEGIN
                                                        IF NOT EXISTS (SELECT Id FROM   Common.Employee WHERE  Username = @UserName AND CompanyId = @CompanyId)
                                                            BEGIN
                                                                UPDATE ImportPersonalDetails SET Importstatus = 1, ErrorRemarks = Null/*'Null'*/
                                                                WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Id = @EmpId And (Importstatus<>0 Or ImportStatus Is Null);
                                                                IF NOT EXISTS (SELECT Id FROM   Common.Employee
                                                                               WHERE  EmployeeId = @EmployeeId AND CompanyId = @CompanyId)
                                                                    BEGIN
                                                                        SET @New_EmployeeId = NEWID();
                                                                        SET @EmailJson = (SELECT 'Email' AS 'key',Email AS 'value' FROM   #Empl_Temp WHERE  Id = @InnerCount AND Email IS NOT NULL FOR    JSON AUTO);
                                                                        SET @MobileJson = (SELECT 'Mobile' AS 'key',Mobile AS 'value'FROM   #Empl_Temp WHERE  Id = @InnerCount AND Mobile IS NOT NULL FOR    JSON AUTO);
                                                                        IF @EmailJson IS NOT NULL
                                                                            BEGIN
                                                                                IF @MobileJson IS NOT NULL
                                                                                    BEGIN
                                                                                        SET @Jsondata = Concat(Substring(@EmailJson, 1, len(@EmailJson) - 1), ',', Substring(@MobileJson, 2, len(@MobileJson)));
                                                                                    END
                                                                                ELSE
                                                                                    BEGIN
                                                                                        SET @Jsondata = @EmailJson;
                                                                                    END
                                                                            END
                                                                        IF @EmailJson IS NULL
                                                                            BEGIN
                                                                                IF @MobileJson IS NOT NULL
                                                                                    BEGIN
                                                                                        SET @Jsondata = @MobileJson;
                                                                                    END
                                                                                ELSE
                                                                                    BEGIN
                                                                                        SET @Jsondata = NULL;
                                                                                    END
                                                                            END
                                                                        INSERT INTO Common.Employee (Id, CompanyId, FirstName, Gender, DOB, Username, Email, MobileNo, Nationality, MaritalStatus, Race, IdNo, IDType, PassportNumber, PassportExpiry, EmployeeId, CreatedDate, UserCreated, Communication, IsWorkflowOnly,DateofSPRGranted)
                                                                        SELECT @New_EmployeeId,@CompanyId,Name,Gender,CONVERT (DATETIME2, DateofBirth, 103),UserName,Email,Mobile,Nationality,MaritalStatus,Race,
                                                                               IdNumber,IdType,PassPortNumber,CONVERT (DATETIME2, PassportExpiry, 103) as PassportExpiry,EmployeeId,@Getdate,@UserCreated,@Jsondata,0,Case when IdType='NRIC(Blue)' then Convert(Datetime2,DateofSPRGranted,103) End AS DateofSPRGranted FROM   ImportPersonalDetails
                                                                        WHERE  TransactionId = @TransactionId AND ID = @EmpId AND EmployeeId = @EmployeeId
                                                                               AND (ImportStatus <> 0 Or ImportStatus is null);
                                                                        UPDATE ImportPersonalDetails SET ErrorRemarks = NULL,ImportStatus = 1
                                                                        WHERE  TransactionId = @TransactionId AND ID = @EmpId AND EmployeeId = @EmployeeId And (Importstatus<>0 Or ImportStatus Is Null);
                                                                        SELECT @EntityName = EntityName
                                                                        FROM   ImportEmployeeDepartment
                                                                        WHERE  Department = @DeptName AND Designation = @DesgName AND TransactionId = @TransactionId  AND EmployeeId = @EmployeeId
                                                                               AND (ImportStatus <> 0 Or ImportStatus is null);
                                                                        SELECT Id FROM   Common.Company
                                                                        WHERE  ParentId = @CompanyId AND Name = @EntityName;
                                                                        INSERT INTO HR.EmployeeDepartment (Id, CompanyId, EmployeeId, DepartmentId, DepartmentDesignationId, EffectiveFrom, ReportingManagerId, Currency, BasicPay, ChargeOutRate, LevelRank,Level, UserCreated, CreatedDate)
                                                                        SELECT NewId(),(SELECT Id FROM   Common.Company WHERE  ParentId = @CompanyId AND Name = @EntityName),@New_EmployeeId,@DeptId,@DesgId,
																		CONVERT (DATETIME2, EffectiveFrom, 103), (   select top 1 id  from common.employee where  companyid=@CompanyId and Status=1 and FirstName in 
                                                                               (select Distinct ReportingTo from ImportEmployeeDepartment 
                                                                               where Department = @DeptName AND Designation = @DesgName AND TransactionId = @TransactionId
                                                                               AND EmployeeId = @EmployeeId AND (ImportStatus <> 0 Or ImportStatus is null) ))AS ReportingManagerId,Currency,
                                                                               MonthlyBasicPay,ChargeOutRate,[Level],[Level],@UserCreated,@Getdate
                                                                        FROM   ImportEmployeeDepartment
                                                                        WHERE  Department = @DeptName AND Designation = @DesgName AND TransactionId = @TransactionId
                                                                               AND EmployeeId = @EmployeeId AND (ImportStatus <> 0 Or ImportStatus is null);
                                                                        UPDATE ImportEmployeeDepartment SET ErrorRemarks = NULL,ImportStatus = 1
                                                                        WHERE  TransactionId = @TransactionId AND Department = @DeptName AND Designation = @DesgName And (Importstatus<>0 Or ImportStatus Is Null);
                                                                        INSERT INTO Hr.Employment (Id, CompanyId, EmployeeId, TypeOfEmployment, ProbationPeriod, StartDate, EndDate, IsReJoined, ConfirmationDate, ConfirmationRemarks, UserCreated, CreatedDate, EmployeeName)
                                                                        SELECT NEWID(),@CompanyId,@New_EmployeeId,TypeofEmployment,CAST ([Days/Months] AS VARCHAR (50)) + ' ' + [Period],CONVERT (DATETIME2, EmploymentStartDate, 103),
                                                                               CONVERT (DATETIME2, EmploymentEndDate,103),RejoinDate,CONVERT (DATETIME2, ConfirmationDate,103),ConfirmationRemarks,@UserCreated,@Getdate,
                                                                        (SELECT FirstName FROM   Common.Employee WHERE Id = @New_EmployeeId AND CompanyId = @CompanyId)
                                                                        FROM   ImportEmployment
                                                                        WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND (ImportStatus <> 0 Or ImportStatus is null);
                                                                        UPDATE ImportEmployment SET  ErrorRemarks = NULL,ImportStatus = 1
                                                                        WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId And (Importstatus<>0 Or ImportStatus Is Null);
                                                                        --IF NOT EXISTS (SELECT EmployeeId FROM   hr.FamilyDetails  WHERE  EmployeeId = @EmployeeId)
                                                                            --BEGIN
                                                                               INSERT INTO hr.FamilyDetails (Id,EmployeeId,FirstName, RelationShip, Nationality, IdNumber, DateOfBirth, ContactNo, NameOfEmployerOrSchool, IsEmergencyContact, UserCreated, CreatedDate, Recorder)
                                                                                SELECT NEWID(),@New_EmployeeId,f.Name,Relation,f.Nationality,IDNo,CONVERT (DATETIME2, f.DateofBirth, 103) AS DateofBirth,
                                                                                       ContactNo,[NameofEmployer/School],EmergencyContact,@UserCreated,@Getdate,1
                                                                                FROM   ImportFamily F
																				Inner Join ImportPersonalDetails P on p.EmployeeId=F.EmployeeId
                                                                                WHERE  p.EmployeeId = @EmployeeId AND p.TransactionId = @TransactionId and f.TransactionId=@TransactionId  AND (F.ImportStatus <> 0 Or F.ImportStatus is null);
                                                                         --  END
                                                                        --IF NOT EXISTS (SELECT EmployeeId FROM  hr.FamilyDetails WHERE  EmployeeId = @EmployeeId)
                                                                           -- BEGIN
                                                                                INSERT INTO HR.Qualification (Id, EmployeeId, QuaType, Qualification, Institution, StartDate, EndDate, UserCreated, CreatedDate)
                                                                                SELECT NEWID(),@New_EmployeeId,Type,Qualification,Institution,
                                                                                       CONVERT (DATETIME2, StartDate,103) AS StartDate,CONVERT (DATETIME2, EndDate,103) AS EndDate,@UserCreated, @Getdate 
																					   FROM   ImportQualification Q
																					   Inner join ImportPersonalDetails P on p.EmployeeId=Q.EmployeeId
                                                                                WHERE  p.TransactionId = @TransactionId  and p.EmployeeId = @EmployeeId and Q.TransactionId=@TransactionId AND (Q.ImportStatus <> 0 Or Q.ImportStatus is null);
                                                                           -- END
                                                                        UPDATE ImportQualification SET    ErrorRemarks = NULL,ImportStatus = 1 WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId And (Importstatus<>0 Or ImportStatus Is Null);
                                                                        SELECT @LocalAddress = LocalAddress,@ForigenAddress = Foreignaddress FROM  ImportPersonalDetails
                                                                        WHERE  EmployeeId = @EmployeeId AND ID = @EmpId AND TransactionId = @TransactionId AND (ImportStatus <> 0 Or ImportStatus is null);
                                                                        IF @LocalAddress IS NOT NULL
                                                                            BEGIN
                                                                                SET @New_Loc_AddressBookId = NewId();
                                                                                INSERT INTO #Strng_Splt (AddrName)
                                                                                SELECT Value
                                                                                FROM   string_split (@LocalAddress, ',');
                                                                                INSERT  INTO Common.AddressBook (Id, IsLocal, BlockHouseNo, Street, UnitNo, BuildingEstate, City, PostalCode, State, Country, Phone, Email, UserCreated, CreatedDate, DocumentId)
                                                                                VALUES (@New_Loc_AddressBookId, 1, (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 1), (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 2), (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 3), 
																						(SELECT AddrName FROM   #Strng_Splt WHERE  Id = 4), (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 5),
				                                                                        (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 6), (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 5), 
																						(SELECT AddrName FROM   #Strng_Splt WHERE  Id = 5), @Mobile, @Email, @UserCreated, @Getdate, @New_EmployeeId);
                                                                                TRUNCATE TABLE #Strng_Splt;
                                                                                INSERT  INTO Common.Addresses (Id, AddSectionType, AddType, AddTypeId, AddTypeIdInt, AddressBookId, CompanyId, DocumentId)
                                                                                VALUES (NEWID(), 'Residential Address', 'Employee', @New_EmployeeId, NULL, @New_Loc_AddressBookId, @CompanyId, NULL);
                                                                            END
                                                                        IF @ForigenAddress IS NOT NULL
                                                                            BEGIN
                                                                                SET @New_Frn_AddressBookId = NewId();
                                                                                INSERT INTO #Strng_Splt (AddrName)
                                                                                SELECT Value FROM   string_split (@ForigenAddress, ',');
                                                                                INSERT  INTO Common.AddressBook (Id, IsLocal, Street, UnitNo, City, State, Country,PostalCode, Phone, Email, UserCreated, CreatedDate, DocumentId)
                                                                                VALUES (@New_Frn_AddressBookId, 0, (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 1),(SELECT AddrName FROM   #Strng_Splt WHERE  Id = 2), 
                                                                                (SELECT AddrName  FROM   #Strng_Splt WHERE  Id = 3), (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 4), 
																				(SELECT AddrName FROM   #Strng_Splt WHERE  Id = 5), (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 6), @Mobile, @Email, @UserCreated, @Getdate, @New_EmployeeId);
                                                                                INSERT  INTO Common.Addresses (Id, AddSectionType, AddType, AddTypeId, AddTypeIdInt, AddressBookId, CompanyId, DocumentId)
                                                                                VALUES (NEWID(), 'Office Address', 'Employee', @New_EmployeeId, NULL, @New_Frn_AddressBookId, @CompanyId, NULL);
                                                                                TRUNCATE TABLE #Strng_Splt;
                                                                            END

                   --                                                        ---------- Add PayCOmponents SP and EmployeePayrollSetting -----=====-------
																			BEGIN
																			Exec [dbo].[EMP_PayCOmponents_Insertion] @CompanyId , @New_EmployeeId, NULL
																			END

																			if not Exists 
																			(select EmployeeId from hr.EmployeePayrollSetting where EmployeeId=@New_EmployeeId )
																			BEGIN

																			
                                                                               --ALTER PROCEDURE [dbo].[EMP_PayCOmponents_Insertion]
                                                                               --(@CompanyId bigint,
                                                                               -- @EmployeeId UNIQUEIDENTIFIER,
                                                                               -- @ModifiedBy NVARCHAR(50))
                                                                              Insert into  hr.EmployeePayrollSetting(Id,EmployeeId,CompanyId,WorkProfileId,AgencyFundId,AgencyFund,AgencyOptOutDate,IsCPFContributionFull,PayMode,SDLExempted,Remarks
                                                                              ,UserCreated,CreateDate,ModifiedDate,ModifiedBy,RecOrder,Status,Version,CPFExempted,PaySlipPassword,ExcludePayroll,IsPasswordChange)

																			   select NEWID() Id , @New_EmployeeId EmployeeId, @CompanyId CompanyId, 
                                                                              (select Id from hr.WorkProfile where CompanyId=@CompanyId and Status=1 and IsDefaultProfile=1) WorkProfileId,
                                                                              (select Id from hr.AgencyFund where Race = (select Race from Common.Employee where Id=@New_EmployeeId)) AgencyFundId,
                                                                              (case when (select Name from hr.AgencyFund
                                                                              where Race = (select Race from Common.Employee where Id=@New_EmployeeId)) is not null then 
                                                                              (select Name from hr.AgencyFund where Race = (select Race from Common.Employee where Id=@New_EmployeeId)) else 'Not applicable' end) AgencyFund
                                                                              ,null AgencyOptOutDate, 
                                                                              (case when (select EmployeeCPFContribution from hr.CompanyPayrollSettings where ParentCompanyId=@CompanyId and CompanyId= (select CompanyId from hr.Employment where EmployeeId=@New_EmployeeId and EndDate is null)) = 'Full' then 1 else 0 end) IsCPFContributionFull, 
                                                                              'Cash'  PayMode, 0 SDLExempted, null Remarks,'System' UserCreated, GETUTCDATE() CreateDate, null ModifiedDate,null ModifiedBy,
                                                                               null RecOrder,1 Status,null Version,0 CPFExempted,(select IdNo from Common.Employee where Id=@New_EmployeeId) PaySlipPassword,0 ExcludePayroll,0 IsPasswordChange 
                                                                               --from  hr.EmployeePayrollSetting where EmployeeId=@New_EmployeeId

																			 --insert into hr.EmployeePayrollSetting values (NEWID(), @New_EmployeeId, @CompanyId, (select Id from hr.WorkProfile where CompanyId=@CompanyId and Status=1 and IsDefaultProfile=1),
																			 --(select Id from hr.AgencyFund where Race = (select Race from Common.Employee where Id=@New_EmployeeId)),(case when (select Name from hr.AgencyFund
																			 -- where Race = (select Race from Common.Employee where Id=@New_EmployeeId)) is not null then 
																			 -- (select Name from hr.AgencyFund where Race = (select Race from Common.Employee where Id=@New_EmployeeId)) else 'Not applicable' end) ,null, 
																			 -- (case when (select EmployeeCPFContribution from hr.CompanyPayrollSettings where ParentCompanyId=@CompanyId and CompanyId= (select CompanyId from hr.Employment where EmployeeId=@New_EmployeeId and EndDate is null)) = 'Full' then 1 else 0 end), 
																			 -- 'Cash', 0, null,'System', GETUTCDATE(), null,null,null,1,null,0,'Welcome@123')
																			END
																			-------------hr.LeaveEntitlement==========
																			if not Exists 
																			(select EmployeeId from hr.LeaveEntitlement where EmployeeId=@New_EmployeeId)
																			BEGIN
																			Declare @SDate DATETIME2;
																			set @SDate=(select StartDate from Hr.Employment where  EmployeeId=@New_EmployeeId);
																				Exec [dbo].[SP_HR_LeaveEntitlement_At_EmpSave] @CompanyId , @New_EmployeeId, 'System',@SDate

																			END
																			
																			-------------------Claims -=================================
																			if not Exists 
																			(select EmployeeId from HR.EmployeeClaimsEntitlement where EmployeeId=@New_EmployeeId)
																			BEGIN
																			
																			
																			--set @SDate=(select StartDate from Hr.Employment where  EmployeeId=@New_EmployeeId);
																				Exec [dbo].[HR_Claim_Entitlement_Insertion]  @New_EmployeeId,@CompanyId 

																			END

																			--------------------------------------------------------------
                                                                    END
                                                                /*ELSE*/

                                                            END
                                                        /*ELSE*/

                                                    END
                                                /*ELSE*/
                                                    BEGIN
                                                        IF ((@DeptId IS NULL
                                                             OR @DeptId = '00000000-0000-0000-0000-000000000000')
                                                            AND (@DesgId IS NULL
                                                                 OR @DesgId = '00000000-0000-0000-0000-000000000000'))
                                                            BEGIN
                                                                UPDATE ImportEmployeeDepartment SET    Importstatus = 0,
                                                                       ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Department & Designation') Else 'Please enter the Department & Designation' End
																	   
                                                                WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Designation = @DesgName AND Department = @DeptName;
                                                            END
                                                        ELSE
                                                            IF (@DesgId IS NULL
                                                                OR @DesgId = '00000000-0000-0000-0000-000000000000')
                                                                BEGIN
                                                                    UPDATE ImportEmployeeDepartment SET    Importstatus = 0, ErrorRemarks = Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Department & Designation') Else 'Please enter the Department & Designation' End
																	
                                                                    WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Designation = @DesgName AND Department = @DeptName AND TransactionId = @TransactionId;
                                                                END
                                                            ELSE
                                                                IF (@DeptId IS NULL
                                                                    OR @DeptId = '00000000-0000-0000-0000-000000000000')
                                                                    BEGIN
                                                                        UPDATE ImportEmployeeDepartment SET    Importstatus = 0,ErrorRemarks =Case When ErrorRemarks Is Not Null Then CONCAT(ErrorRemarks,',','Please enter the Department & Designation') Else 'Please enter the Department & Designation' End
																		
                                                                        WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Designation = @DesgName AND Department = @DeptName;
                                                                    END
                                                    END
                                            END
                                        /*ELSE*/
                                    END
                                /*ELSE*/

                            END
                        /*ELSE*/

                    END
                End
				/*ELSE*/

               


						         --================================================================================03.12.2019
                COMMIT TRANSACTION;
                END TRY
                BEGIN CATCH
                Declare @ErrorMessage Nvarchar(4000)=error_message();
                ROLLBACK;
                If @ErrorMessage is not null
	                begin 

		            UPDATE  ImportPersonalDetails set ErrorRemarks=@ErrorMessage   where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId
		            UPDATE  ImportPersonalDetails set ImportStatus=0  where  TransactionId=@TransactionId  and Id = @EmpId and EmployeeId=@EmployeeId
	                
					End 
                END CATCH
		  --================================================================================03.12.2019
		   SET @InnerCount = @InnerCount + 1;
             END


        DROP TABLE #Empl_Temp;
        DROP TABLE #Strng_Splt;

		Update EmpDept Set ReportingManagerId=B.ReportingManagerId From HR.EmployeeDepartment As EmpDept 
		Inner Join Common.Employee As A On A.Id=EmpDept.EmployeeId
		Inner Join
		(
		Select Emp.Id As ReportingManagerId,FirstName,A.EmployeeId,RANK() Over (Partition by Firstname Order by createddate desc) As Rank_Order From ImportEmployeeDepartment As A
		Inner Join Common.Employee As Emp On Emp.FirstName=A.ReportingTo
		Where Emp.CompanyId=@CompanyId And TransactionId=@TransactionId
		) As B On B.EmployeeId=A.EmployeeId

        UPDATE P SET  P.ImportStatus = D.ImportStatus,P.ErrorRemarks = D.ErrorRemarks FROM ImportPersonalDetails AS P
               INNER JOIN ImportEmployeeDepartment AS D ON P.EmployeeId = D.EmployeeId
        WHERE  P.TransactionId = @TransactionId AND D.TransactionId = @TransactionId AND D.ImportStatus = 0  AND P.ImportStatus <> 0;

        UPDATE P  SET   P.ImportStatus = D.ImportStatus, P.ErrorRemarks = D.ErrorRemarks FROM ImportPersonalDetails AS P
               INNER JOIN ImportEmployment AS D ON P.EmployeeId = D.EmployeeId
        WHERE  P.TransactionId = @TransactionId AND D.TransactionId = @TransactionId AND D.ImportStatus = 0  AND P.ImportStatus <> 0;

        --DECLARE @FailedCount AS INT = (SELECT Count(*)FROM   ImportPersonalDetails WHERE  TransactionId = @TransactionId AND ImportStatus = 0);
        --DECLARE @FailedCount_1 AS INT = (SELECT Count(*) FROM   ImportEmployeeDepartment WHERE  TransactionId = @TransactionId AND ImportStatus = 0);
        --DECLARE @FailedCount_2 AS INT = (SELECT Count(*) FROM   ImportEmployment WHERE  TransactionId = @TransactionId AND ImportStatus = 0);
		DECLARE @FailedCount Int=0

		If Exists (SELECT Count(*)FROM   ImportPersonalDetails WHERE  TransactionId =@TransactionId AND ImportStatus = 0)
        Begin
			Set @FailedCount=@FailedCount+(SELECT Count(*)FROM   ImportPersonalDetails WHERE  TransactionId =@TransactionId AND ImportStatus = 0)
		End

		If Exists (SELECT Count(*) FROM   ImportEmployeeDepartment WHERE  TransactionId = @TransactionId AND ImportStatus = 0)
		Begin
			If @FailedCount=0
			Begin
				Set @FailedCount=@FailedCount+(SELECT Count(*) FROM   ImportEmployeeDepartment WHERE  TransactionId = @TransactionId AND ImportStatus = 0 )
			End
		End

		If Exists (SELECT Count(*) FROM   ImportEmployment WHERE  TransactionId = @TransactionId AND ImportStatus = 0 )
       Begin
			If @FailedCount=0
			Begin
				Set @FailedCount=@FailedCount+(SELECT Count(*) FROM   ImportEmployment WHERE  TransactionId = @TransactionId AND ImportStatus = 0 )
			End
		End

		If Exists (SELECT Count(*) FROM   ImportFamily WHERE  TransactionId = @TransactionId AND ImportStatus = 0 )
        Begin
			If @FailedCount=0
			Begin
				Set @FailedCount=@FailedCount+(SELECT Count(*) FROM   ImportFamily WHERE  TransactionId = @TransactionId AND ImportStatus = 0 )
			End
		End

		If Exists (SELECT Count(*) FROM   ImportQualification WHERE  TransactionId = @TransactionId AND ImportStatus = 0  )
		Begin
			If @FailedCount=0
			Begin
				Set @FailedCount=@FailedCount+(SELECT Count(*) FROM   ImportQualification WHERE  TransactionId = @TransactionId AND ImportStatus = 0 And @FailedCount=0)
			End
		End

        UPDATE Common.[Transaction] SET    TotalRecords  = (SELECT Count(*) FROM   ImportPersonalDetails WHERE  TransactionId = @TransactionId),
               FailedRecords =  Case  when @FailedCount>0 then  @FailedCount else 0 end 
        WHERE  Id = @TransactionId;

		
		--======================================  InitialCursorSetup ========================================
		If Exists ( select count(*) from Common.Employee where CompanyId=@CompanyId)
		begin 
		update Common.InitialCursorSetup set IsSetUpDone = 1 
		where CompanyId=@companyId and ModuleDetailId=(select Id from Common.ModuleDetail where companyId=@companyId and PermissionKey='hr_em_employees')
		end 
        	--======================================  InitialCursorSetup ========================================

    --    COMMIT TRANSACTION;
    --END TRY
    --BEGIN CATCH
    --    ROLLBACK;
    --    PRINT error_message();
    --END CATCH
    BEGIN
        EXECUTE [dbo].[Import_Emp_To_Entity] @CompanyId;
    END
	Begin
		update c set c.BlockHouseNo='', c.BuildingEstate=''  from  Common.AddressBook c
		inner join Common.Addresses a on a.AddressBookId=c.Id
		where a.CompanyId=@companyId 
		 and c.BlockHouseNo is null and  c.BuildingEstate is null
    End
 END

	  

GO
