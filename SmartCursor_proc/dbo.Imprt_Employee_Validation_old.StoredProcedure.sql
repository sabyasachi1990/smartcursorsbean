USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Imprt_Employee_Validation_old]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create PROCEDURE [dbo].[Imprt_Employee_Validation_old]
@CompanyId BIGINT, @TransactionId UNIQUEIDENTIFIER
AS
BEGIN
    DECLARE @UserCreated AS VARCHAR (20), @Getdate AS DATETIME2, @Count AS INT, @InnerCount AS INT, @EmpId AS UNIQUEIDENTIFIER, @EmployeeId AS NVARCHAR (200), @Mobile AS NVARCHAR (200), @Email AS NVARCHAR (200), @Comm AS NVARCHAR (MAX), @DeptName AS NVARCHAR (100), @DesgName AS NVARCHAR (100), @DeptId AS UNIQUEIDENTIFIER, @DesgId AS UNIQUEIDENTIFIER, @New_EmployeeId AS UNIQUEIDENTIFIER, @UserName AS VARCHAR (200), @LocalAddress AS NVARCHAR (MAX), @LclAdrs_Vrbl AS NVARCHAR (MAX), @New_Loc_AddressBookId AS UNIQUEIDENTIFIER, @New_Frn_AddressBookId AS UNIQUEIDENTIFIER, @ForigenAddress AS NVARCHAR (MAX), @BlockHouseNo AS NVARCHAR (512), @Street AS NVARCHAR (2000), @UnitNo AS NVARCHAR (512), @BuildingEstate AS NVARCHAR (512), @PostalCode AS NVARCHAR (20), @Country AS NVARCHAR (512), @Error_Message AS NVARCHAR (MAX), @Jsondata AS NVARCHAR (MAX), @EmailJson AS NVARCHAR (MAX), @MobileJson AS NVARCHAR (MAX), @EntityName AS NVARCHAR (400), @UserNameCheck AS BIGINT, @IdNo AS NVARCHAR (100);
    SET @UserCreated = 'System';
    SET @Getdate = GETUTCDATE();
    SET @InnerCount = 1;
    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE C
        SET    ImportStatus = CASE WHEN charindex('/', DateofBirth) >= 1 THEN CASE WHEN CAST (Substring(DateofBirth, 0, charindex('/', DateofBirth)) AS INT) BETWEEN 1 AND 31 THEN CASE WHEN Substring(DateofBirth, charindex('/', DateofBirth) + 1, LEN(DateofBirth) - 8) BETWEEN 1 AND 12 THEN 1 ELSE 0 END ELSE 0 END ELSE 0 END,
               ErrorRemarks = 'DateOfBirth Must be In DD/MM/YYYY (Ex:31/01/1992) Format '
        FROM   ImportPersonalDetails AS C
        WHERE  TransactionId = @TransactionId
               AND DateofBirth IS NOT NULL
               AND CASE WHEN charindex('/', DateofBirth) >= 1 THEN CASE WHEN CAST (Substring(DateofBirth, 0, charindex('/', DateofBirth)) AS INT) BETWEEN 1 AND 31 THEN CASE WHEN Substring(DateofBirth, charindex('/', DateofBirth) + 1, LEN(DateofBirth) - 8) BETWEEN 1 AND 12 THEN 1 ELSE 0 END ELSE 0 END ELSE 0 END = 0
               AND ImportStatus <> 0;
        UPDATE C
        SET    ImportStatus = CASE WHEN charindex('/', EmploymentStartDate) >= 1 THEN CASE WHEN CAST (Substring(EmploymentStartDate, 0, charindex('/', EmploymentStartDate)) AS INT) BETWEEN 1 AND 31 THEN CASE WHEN Substring(EmploymentStartDate, charindex('/', EmploymentStartDate) + 1, LEN(EmploymentStartDate) - 8) BETWEEN 1 AND 12 THEN 1 ELSE 0 END ELSE 0 END ELSE 0 END,
               ErrorRemarks = 'EmploymentStartDate Must be In DD/MM/YYYY (Ex:31/01/1992) Format '
        FROM   ImportEmployment AS C
        WHERE  TransactionId = @TransactionId
               AND EmploymentStartDate IS NOT NULL
               AND CASE WHEN charindex('/', EmploymentStartDate) >= 1 THEN CASE WHEN CAST (Substring(EmploymentStartDate, 0, charindex('/', EmploymentStartDate)) AS INT) BETWEEN 1 AND 31 THEN CASE WHEN Substring(EmploymentStartDate, charindex('/', EmploymentStartDate) + 1, LEN(EmploymentStartDate) - 8) BETWEEN 1 AND 12 THEN 1 ELSE 0 END ELSE 0 END ELSE 0 END = 0
               AND ImportStatus <> 0;
        UPDATE C
        SET    ImportStatus = CASE WHEN charindex('/', EffectiveFrom) >= 1 THEN CASE WHEN CAST (Substring(EffectiveFrom, 0, charindex('/', EffectiveFrom)) AS INT) BETWEEN 1 AND 31 THEN CASE WHEN Substring(EffectiveFrom, charindex('/', EffectiveFrom) + 1, LEN(EffectiveFrom) - 8) BETWEEN 1 AND 12 THEN 1 ELSE 0 END ELSE 0 END ELSE 0 END,
               ErrorRemarks = 'EffectiveFrom Must be In DD/MM/YYYY (Ex:31/01/1992) Format '
        FROM   ImportEmployeeDepartment AS C
        WHERE  TransactionId = @TransactionId
               AND EffectiveFrom IS NOT NULL
               AND CASE WHEN charindex('/', EffectiveFrom) >= 1 THEN CASE WHEN CAST (Substring(EffectiveFrom, 0, charindex('/', EffectiveFrom)) AS INT) BETWEEN 1 AND 31 THEN CASE WHEN Substring(EffectiveFrom, charindex('/', EffectiveFrom) + 1, LEN(EffectiveFrom) - 8) BETWEEN 1 AND 12 THEN 1 ELSE 0 END ELSE 0 END ELSE 0 END = 0
               AND ImportStatus <> 0;

        IF EXISTS (SELECT EmployeeId FROM   ImportPersonalDetails
                   WHERE  EmployeeId IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN
                UPDATE ImportPersonalDetails SET    ErrorRemarks = 'Mandatory field EmployeeId  missed',ImportStatus = 0
                WHERE  EmployeeId IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END

        IF EXISTS (SELECT Name FROM   ImportPersonalDetails
                   WHERE  Name IS NULL AND ImportStatus IS NULL  AND TransactionId = @TransactionId)
            BEGIN
                UPDATE ImportPersonalDetails SET    ErrorRemarks = 'Mandatory field Name  missed',ImportStatus = 0
                WHERE  Name IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END

        IF EXISTS (SELECT IdType FROM   ImportPersonalDetails
                   WHERE  IdType IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN
                UPDATE ImportPersonalDetails
                SET    ErrorRemarks = 'Mandatory field IdType  missed', ImportStatus = 0
                WHERE  IdType IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END

        IF EXISTS (SELECT IdNumber FROM   ImportPersonalDetails
                   WHERE  IdNumber IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN
                UPDATE ImportPersonalDetails SET ErrorRemarks = 'Mandatory field IdNumber  missed',ImportStatus = 0
                WHERE  IdNumber IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END

        IF EXISTS (SELECT Nationality FROM   ImportPersonalDetails
                   WHERE  Nationality IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN
                UPDATE ImportPersonalDetails SET    ErrorRemarks = 'Mandatory field Nationality  missed',ImportStatus = 0
                WHERE  Nationality IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END

        IF EXISTS (SELECT Race FROM   ImportPersonalDetails WHERE  Race IS NULL  AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN
                UPDATE ImportPersonalDetails SET  ErrorRemarks = 'Mandatory field Race  missed',ImportStatus = 0
                WHERE  Race IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END

        ELSE
            IF EXISTS (SELECT DateofBirth FROM   ImportPersonalDetails WHERE  DateofBirth IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
                BEGIN
                    UPDATE ImportPersonalDetails SET    ErrorRemarks = 'Mandatory field DateofBirth  missed', ImportStatus = 0 WHERE  DateofBirth IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
                END
        IF EXISTS (SELECT Email FROM   ImportPersonalDetails WHERE  Email IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)

            BEGIN
                UPDATE ImportPersonalDetails SET    ErrorRemarks = 'Mandatory field Email  missed',ImportStatus = 0
                WHERE  Email IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END

        IF EXISTS (SELECT EmployeeId FROM   ImportEmployment WHERE  EmployeeId IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN

                UPDATE ImportEmployment SET    ErrorRemarks = 'Mandatory field EmployeeId  missed',ImportStatus = 0 WHERE  EmployeeId IS NULL AND TransactionId = @TransactionId  AND ImportStatus <> 0;
            END
        IF EXISTS (SELECT TypeofEmployment FROM   ImportEmployment WHERE  TypeofEmployment IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
           
		    BEGIN

                UPDATE ImportEmployment SET ErrorRemarks = 'Mandatory field TypeofEmployment  missed',ImportStatus = 0
                WHERE  TypeofEmployment IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END

        IF EXISTS (SELECT EmploymentStartDate FROM   ImportEmployment
                   WHERE  EmploymentStartDate IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN

                UPDATE ImportEmployment SET  ErrorRemarks = 'Mandatory field Employment Start Date  missed',ImportStatus = 0
                WHERE  EmploymentStartDate IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END
        IF EXISTS (SELECT EmployeeId FROM   ImportEmployeeDepartment
                   WHERE  EmployeeId IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN
                UPDATE ImportEmployeeDepartment SET  ErrorRemarks = 'Mandatory field EmployeeId missed',ImportStatus = 0
                WHERE  EmployeeId IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END
        IF EXISTS (SELECT EntityName FROM   ImportEmployeeDepartment
                   WHERE  EntityName IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN

                UPDATE ImportEmployeeDepartment SET  ErrorRemarks = 'Mandatory field EntityName missed',ImportStatus = 0
                WHERE  EntityName IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END

        IF EXISTS (SELECT Department FROM   ImportEmployeeDepartment
                   WHERE  Department IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN
                UPDATE ImportEmployeeDepartment SET ErrorRemarks = 'Mandatory field Department missed',ImportStatus = 0
                WHERE  Department IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END

        IF EXISTS (SELECT Designation FROM   ImportEmployeeDepartment
                   WHERE  Designation IS NULL AND ImportStatus IS NULL  AND TransactionId = @TransactionId)
            BEGIN

                UPDATE ImportEmployeeDepartment SET    ErrorRemarks = 'Mandatory field Designation missed',ImportStatus = 0
                WHERE  Designation IS NULL AND TransactionId = @TransactionId  AND ImportStatus <> 0;
            END

        UPDATE A SET A.ErrorRemarks = 'Employment Start Date should be equal to or less than the Effective From Date',A.ImportStatus = 0
		 FROM   ImportEmployeeDepartment AS A
               INNER JOIN ImportEmployment AS B ON A.EmployeeId = B.EmployeeId AND A.TransactionId = B.TransactionId
        WHERE  A.TransactionId = @TransactionId and B.TransactionId=@TransactionId AND A.EffectiveFrom < B.EmploymentStartDate --AND A.ImportStatus <> 0; ---6.36 (5/23/2019)

        IF EXISTS (SELECT EmployeeId FROM   ImportQualification WHERE  EmployeeId IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN
                UPDATE ImportFamily SET ErrorRemarks = 'Mandatory field EmployeeId  missed',ImportStatus = 0
                WHERE  EmployeeId IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END

        IF EXISTS (SELECT EmployeeId FROM   ImportFamily WHERE  EmployeeId IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN
                UPDATE ImportFamily SET ErrorRemarks = 'Mandatory field EmployeeId  missed', ImportStatus = 0
                WHERE  EmployeeId IS NULL AND TransactionId = @TransactionId AND ImportStatus <> 0;
            END

        IF EXISTS (SELECT EffectiveFrom FROM   ImportEmployeeDepartment
                   WHERE  EffectiveFrom IS NULL AND ImportStatus IS NULL AND TransactionId = @TransactionId)
            BEGIN
                UPDATE ImportEmployeeDepartment SET  ErrorRemarks = 'Mandatory field EffectiveFrom missed',ImportStatus = 0
                WHERE  EffectiveFrom IS NULL  AND TransactionId = @TransactionId --AND ImportStatus <> 0;
            END

        CREATE TABLE #Empl_Temp (Id INT IDENTITY (1, 1),EmpId UNIQUEIDENTIFIER,UserName NVARCHAR (200),EmployeeId NVARCHAR (200),Mobile NVARCHAR (200),Email NVARCHAR (200),CompanyId  BIGINT,IdNo NVARCHAR (100));
        CREATE TABLE #Strng_Splt (Id INT IDENTITY (1, 1),AddrName NVARCHAR (MAX));
        INSERT INTO #Empl_Temp (EmpId, EmployeeId, UserName, Mobile, Email, CompanyId, IdNo)
        SELECT DISTINCT ID,EmployeeId,UserName,Mobile,Email,@CompanyId,IdNumber FROM ImportPersonalDetails WHERE TransactionId = @TransactionId AND (ImportStatus <> 0 OR ImportStatus IS NULL);
        SET @Count = (SELECT Count(*) FROM   #Empl_Temp);
        WHILE @Count >= @InnerCount
            BEGIN
                SELECT @EmpId = EmpId,@EmployeeId = EmployeeId,@UserName = Username,@Mobile = Mobile,@Email = Email,@IdNo = IdNo FROM   #Empl_Temp
                WHERE  Id = @InnerCount;
                SELECT @DeptName = Department,@DesgName = Designation FROM   ImportEmployeeDepartment
                WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND (ImportStatus <> 0 OR ImportStatus IS NULL);
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
                       AND Designation = @DesgName AND TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND (ImportStatus <> 0 OR ImportStatus IS NULL);
                SET @UserNameCheck = (SELECT 1 FROM   Common.CompanyUser WHERE  Username = @UserName AND CompanyId = @CompanyId);
                IF @UserName IS NULL
                   OR @UserNameCheck = 1
                    BEGIN
                        IF EXISTS (SELECT EmployeeId FROM   ImportPersonalDetails
                                   WHERE  TransactionId = @TransactionId AND EmployeeId IN (SELECT EmployeeId FROM   ImportEmployment
                                    WHERE  TransactionId = @TransactionId AND EmployeeId IN (SELECT EmployeeId FROM   ImportEmployeeDepartment
                                    WHERE  TransactionId = @TransactionId)))
                            BEGIN
                                IF NOT EXISTS (SELECT idno FROM   Common.Employee WHERE  IdNo = @IdNo AND CompanyId = @CompanyId)
                                    BEGIN
                                        UPDATE ImportPersonalDetails SET    Importstatus = 1,ErrorRemarks = 'Null'
                                        WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Id = @EmpId;
                                        IF EXISTS (SELECT Id FROM   Common.Company WHERE  ParentId = @CompanyId AND Name = @EntityName)
                                            BEGIN
                                                UPDATE ImportEmployeeDepartment SET Importstatus = 1,ErrorRemarks = 'Null'
                                                WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND EntityName = @EntityName;
                                                IF ((@DeptId IS NOT NULL AND @DeptId <> '00000000-0000-0000-0000-000000000000')
												AND (@DesgId IS NOT NULL AND @DesgId <> '00000000-0000-0000-0000-000000000000'))
                                                    BEGIN
                                                        IF NOT EXISTS (SELECT Id FROM   Common.Employee WHERE  Username = @UserName AND CompanyId = @CompanyId)
                                                            BEGIN
                                                                UPDATE ImportPersonalDetails SET Importstatus = 1, ErrorRemarks = 'Null'
                                                                WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Id = @EmpId;
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
                                                                        INSERT INTO Common.Employee (Id, CompanyId, FirstName, Gender, DOB, Username, Email, MobileNo, Nationality, MaritalStatus, Race, IdNo, IDType, PassportNumber, PassportExpiry, EmployeeId, CreatedDate, UserCreated, Communication, IsWorkflowOnly)
                                                                        SELECT @New_EmployeeId,@CompanyId,Name,Gender,CONVERT (DATETIME2, DateofBirth, 103),UserName,Email,Mobile,Nationality,MaritalStatus,Race,
                                                                               IdNumber,IdType,PassPortNumber,PassportExpiry,EmployeeId,@Getdate,@UserCreated,@Jsondata,0 FROM   ImportPersonalDetails
                                                                        WHERE  TransactionId = @TransactionId AND ID = @EmpId AND EmployeeId = @EmployeeId
                                                                               AND (ImportStatus <> 0 OR ImportStatus IS NULL);
                                                                        UPDATE ImportPersonalDetails SET ErrorRemarks = NULL,ImportStatus = 1
                                                                        WHERE  TransactionId = @TransactionId AND ID = @EmpId AND EmployeeId = @EmployeeId;
                                                                        SELECT @EntityName = EntityName
                                                                        FROM   ImportEmployeeDepartment
                                                                        WHERE  Department = @DeptName AND Designation = @DesgName AND TransactionId = @TransactionId  AND EmployeeId = @EmployeeId
                                                                               AND (ImportStatus <> 0 OR ImportStatus IS NULL);
                                                                        SELECT Id FROM   Common.Company
                                                                        WHERE  ParentId = @CompanyId AND Name = @EntityName;
                                                                        INSERT INTO HR.EmployeeDepartment (Id, CompanyId, EmployeeId, DepartmentId, DepartmentDesignationId, EffectiveFrom, ReportingManagerId, Currency, BasicPay, ChargeOutRate, Level, UserCreated, CreatedDate)
                                                                        SELECT NewId(),(SELECT Id FROM   Common.Company WHERE  ParentId = @CompanyId AND Name = @EntityName),@New_EmployeeId,@DeptId,@DesgId,CONVERT (DATETIME2, EffectiveFrom, 103),NULL AS ReportingManagerId,Currency,
                                                                               MonthlyBasicPay,ChargeOutRate,[Level],@UserCreated,@Getdate
                                                                        FROM   ImportEmployeeDepartment
                                                                        WHERE  Department = @DeptName AND Designation = @DesgName AND TransactionId = @TransactionId
                                                                               AND EmployeeId = @EmployeeId AND (ImportStatus <> 0 OR ImportStatus IS NULL);
                                                                        UPDATE ImportEmployeeDepartment SET ErrorRemarks = NULL,ImportStatus = 1
                                                                        WHERE  TransactionId = @TransactionId AND Department = @DeptName AND Designation = @DesgName;
                                                                        INSERT INTO Hr.Employment (Id, CompanyId, EmployeeId, TypeOfEmployment, Period, StartDate, EndDate, IsReJoined, ConfirmationDate, ConfirmationRemarks, UserCreated, CreatedDate, EmployeeName)
                                                                        SELECT NEWID(),@CompanyId,@New_EmployeeId,TypeofEmployment,CAST ([Days/Months] AS VARCHAR (50)) + ' ' + [Period],CONVERT (DATETIME2, EmploymentStartDate, 103),
                                                                               CONVERT (DATETIME2, EmploymentEndDate),RejoinDate,CONVERT (DATETIME2, ConfirmationDate),ConfirmationRemarks,@UserCreated,@Getdate,
                                                                        (SELECT FirstName FROM   Common.Employee WHERE Id = @New_EmployeeId AND CompanyId = @CompanyId)
                                                                        FROM   ImportEmployment
                                                                        WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND (ImportStatus <> 0 OR ImportStatus IS NULL);
                                                                        UPDATE ImportEmployment SET  ErrorRemarks = NULL,ImportStatus = 1
                                                                        WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId;
                                                                        --IF NOT EXISTS (SELECT EmployeeId FROM   hr.FamilyDetails  WHERE  EmployeeId = @EmployeeId)
                                                                            --BEGIN
                                                                               INSERT INTO hr.FamilyDetails (Id,EmployeeId,FirstName, RelationShip, Nationality, IdNumber, DateOfBirth, ContactNo, NameOfEmployerOrSchool, IsEmergencyContact, UserCreated, CreatedDate, Recorder)
                                                                                SELECT NEWID(),@New_EmployeeId,f.Name,Relation,f.Nationality,IDNo,CONVERT (DATETIME, f.DateofBirth) AS DateofBirth,
                                                                                       ContactNo,[NameofEmployer/School],EmergencyContact,@UserCreated,@Getdate,1
                                                                                FROM   ImportFamily F
																				Inner Join ImportPersonalDetails P on p.EmployeeId=F.EmployeeId
                                                                                WHERE  p.EmployeeId = @EmployeeId AND p.TransactionId = @TransactionId  AND (F.ImportStatus <> 0 OR F.ImportStatus IS NULL);
                                                                         --  END
                                                                        --IF NOT EXISTS (SELECT EmployeeId FROM  hr.FamilyDetails WHERE  EmployeeId = @EmployeeId)
                                                                           -- BEGIN
                                                                                INSERT INTO HR.Qualification (Id, EmployeeId, QuaType, Qualification, Institution, StartDate, EndDate, UserCreated, CreatedDate)
                                                                                SELECT NEWID(),@New_EmployeeId,Type,Qualification,Institution,
                                                                                       CONVERT (DATETIME2, StartDate) AS StartDate,CONVERT (DATETIME2, EndDate) AS EndDate,@UserCreated, @Getdate FROM   ImportQualification Q
																					   Inner join ImportPersonalDetails P on p.EmployeeId=Q.EmployeeId
                                                                                WHERE  p.TransactionId = @TransactionId  and p.EmployeeId = @EmployeeId AND (Q.ImportStatus <> 0 OR Q.ImportStatus IS NULL);
                                                                           -- END
                                                                        UPDATE ImportQualification SET    ErrorRemarks = NULL,ImportStatus = 1 WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId;
                                                                        SELECT @LocalAddress = LocalAddress,@ForigenAddress = Foreignaddress FROM  ImportPersonalDetails
                                                                        WHERE  EmployeeId = @EmployeeId AND ID = @EmpId AND TransactionId = @TransactionId AND (ImportStatus <> 0 OR ImportStatus IS NULL);
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
                                                                                INSERT  INTO Common.AddressBook (Id, IsLocal, BlockHouseNo, Street, UnitNo, BuildingEstate, City, PostalCode, State, Country, Phone, Email, UserCreated, CreatedDate, DocumentId)
                                                                                VALUES (@New_Frn_AddressBookId, 0, (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 1),(SELECT AddrName FROM   #Strng_Splt WHERE  Id = 2), 
                                                                                (SELECT AddrName  FROM   #Strng_Splt WHERE  Id = 3), (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 4), 
																				(SELECT AddrName FROM   #Strng_Splt WHERE  Id = 5), (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 6), 
																				(SELECT AddrName FROM   #Strng_Splt WHERE  Id = 5), (SELECT AddrName FROM   #Strng_Splt WHERE  Id = 5),@Mobile, @Email, @UserCreated, @Getdate, @New_EmployeeId);
                                                                                INSERT  INTO Common.Addresses (Id, AddSectionType, AddType, AddTypeId, AddTypeIdInt, AddressBookId, CompanyId, DocumentId)
                                                                                VALUES (NEWID(), 'Office Address', 'Employee', @New_EmployeeId, NULL, @New_Frn_AddressBookId, @CompanyId, NULL);
                                                                                TRUNCATE TABLE #Strng_Splt;
                                                                            END
                                                                    END
                                                                ELSE
                                                                    BEGIN
                                                                        UPDATE ImportPersonalDetails SET Importstatus = 0,ErrorRemarks = 'Employee Id Exists In Table'
                                                                              WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Id = @EmpId;
                                                                    END
                                                            END
                                                        ELSE
                                                            BEGIN
                                                                UPDATE ImportPersonalDetails SET Importstatus = 0,ErrorRemarks = 'UserName Already Exists'
                                                                WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Id = @EmpId;
                                                            END
                                                    END
                                                ELSE
                                                    BEGIN
                                                        IF ((@DeptId IS NULL
                                                             OR @DeptId = '00000000-0000-0000-0000-000000000000')
                                                            AND (@DesgId IS NULL
                                                                 OR @DesgId = '00000000-0000-0000-0000-000000000000'))
                                                            BEGIN
                                                                UPDATE ImportEmployeeDepartment SET    Importstatus = 0,
                                                                       ErrorRemarks = 'Employee Must Have Department & Designation Please Add Department & Designation'
                                                                WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Designation = @DesgName AND Department = @DeptName;
                                                            END
                                                        ELSE
                                                            IF (@DesgId IS NULL
                                                                OR @DesgId = '00000000-0000-0000-0000-000000000000')
                                                                BEGIN
                                                                    UPDATE ImportEmployeeDepartment SET    Importstatus = 0, ErrorRemarks = 'Employee Must Have Designation Please Add Designation'
                                                                    WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Designation = @DesgName AND Department = @DeptName AND TransactionId = @TransactionId;
                                                                END
                                                            ELSE
                                                                IF (@DeptId IS NULL
                                                                    OR @DeptId = '00000000-0000-0000-0000-000000000000')
                                                                    BEGIN
                                                                        UPDATE ImportEmployeeDepartment SET    Importstatus = 0,ErrorRemarks = 'Employee Must Have Department Please Add Department'
                                                                        WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Designation = @DesgName AND Department = @DeptName;
                                                                    END
                                                    END
                                            END
                                        ELSE
                                            BEGIN
                                                UPDATE ImportEmployeeDepartment SET    Importstatus = 0,ErrorRemarks = 'Please Add Service Entity Name'
                                                WHERE  TransactionId = @TransactionId AND EmployeeId = @EmployeeId AND Designation = @DesgName AND Department = @DeptName;
                                            END
                                    END
                                ELSE
                                    BEGIN
                                        UPDATE ImportPersonalDetails SET ImportStatus = 0,ErrorRemarks = 'Id Number Already Existing'
                                        WHERE  EmployeeId = @EmployeeId AND TransactionId = @TransactionId;
                                    END
                            END
                        ELSE
                            BEGIN
                                UPDATE ImportPersonalDetails SET    ImportStatus = 0,ErrorRemarks = 'Please Insert The Same EmployeeId'
                                WHERE  EmployeeId = @EmployeeId AND TransactionId = @TransactionId;
                            END
                    END
                ELSE
                    BEGIN
                        UPDATE ImportPersonalDetails SET    ImportStatus = 0,ErrorRemarks = 'UserName Doesnot Exists,Please Add UserName'
                        WHERE  EmployeeId = @EmployeeId AND TransactionId = @TransactionId;
                    END
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

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT error_message();
    END CATCH
    BEGIN
        EXECUTE [dbo].[Import_Emp_To_Entity] @CompanyId;
    END

		---============================ InitialCursorSetup update 1  ========================================================
	
	 If Exists(select Id from common.Employee where companyid=@Companyid)
     Begin
           
			   Update Isp Set IsSetUpDone=1 FROM  common.InitialCursorSetup Isp  where companyid=@Companyid and Status=1 and IsSetUpDone=0 and ModuleDetailId 
			   in ( select id from common.ModuleDetail where companyid=@Companyid and Status=1 and Heading='Employees') 


	           If  NOT Exists  (SELECT ModuleId FROM  common.InitialCursorSetup where CompanyId=@Companyid and Status=1 and IsSetUpDone=0  and MainModuleId 
	           in (select Id  from Common.ModuleMaster where  Status=1 and  Name='Hr Cursor') )
			   Begin 

                update  common.CompanyModule set SetUpDone=1 where CompanyId=@Companyid and Status=1  AND SetUpDone=0 and  ModuleId 
			    in  (select Id  from Common.ModuleMaster where Name='Hr Cursor')
             END
     
      END

	---============================ InitialCursorSetup update 1  ========================================================
END

GO
