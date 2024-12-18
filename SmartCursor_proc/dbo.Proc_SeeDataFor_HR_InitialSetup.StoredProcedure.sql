USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SeeDataFor_HR_InitialSetup]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [dbo].[Proc_SeeDataFor_HR_InitialSetup]


  --- exec [dbo].[Proc_SeeDataFor_HR_InitialSetup] 2439,19

  @NEW_COMPANY_ID bigint,
  @UNIQUE_COMPANY_ID bigint

 --Exec  InitialSetup_SP_NEW 19,10
AS
BEGIN
--select * from Common.Department where CompanyId=19 and Code='tst'
--Declare @NEW_COMPANY_ID int
-- Declare @UNIQUE_COMPANY_ID int
 Declare @DepartmentId uniqueidentifier
 Declare @DesgnationId uniqueidentifier
 Declare @ClaimSetupId uniqueidentifier
 Declare @ClaimItemId uniqueidentifier
 Declare @ClaimSetupDetailId uniqueidentifier
 Declare @CompanyId Bigint
 Declare @CoaId bigint
 Declare @ChartOfAccount nvarchar(500)
 Declare @CoaIdnew bigint
 Declare @ClaimCoaId bigint
 Declare @ClaimCategory  nvarchar(500)
 
 Declare @Department_Cnt bigint
 Declare @Leavetypeid  uniqueidentifier
 Declare @HRSettingsid uniqueidentifier
 Declare @entityid uniqueidentifier
Declare @MediaRepositoryid uniqueidentifier
Declare @entityName nvarchar(500)
Declare @name nvarchar(500)
Declare @SyncEmployeeId uniqueidentifier
Declare @Departmentidnew uniqueidentifier
Declare @Desgnationidnew uniqueidentifier
Declare @entityidnew uniqueidentifier
Declare @SyncEmployeeIdnew uniqueidentifier
Declare @EmployeeId uniqueidentifier
Declare @Employeename nvarchar(200)
Declare @SyncEntityId uniqueidentifier
Declare @PhotoId uniqueidentifier
Declare @Employeeno nvarchar(200)


 Declare @DetailID  uniqueidentifier

 Declare @Category NVARCHAR(100)
 Declare @Type  NVARCHAR(100)
 Declare @ItemName  NVARCHAR(100)
 Declare @ClaimItemIdNEW uniqueidentifier
 Declare @ClaimSetupIdnew uniqueidentifier
Declare @DepartmentName nvarchar(200)
Declare @DesgnationName nvarchar(200)
Declare @Code nvarchar(200)
Declare @depName nvarchar(200)

 


    Declare Depart_Get Cursor For
	  select d.Id,dd.id,CompanyId,d.Code,d.Name from Common.Department d inner join Common.DepartmentDesignation dd on d.Id=dd.DepartmentId
	    where CompanyId=@UNIQUE_COMPANY_ID
	  Open Depart_Get
	  fetch next from Depart_Get Into @Departmentid,@Desgnationid,@CompanyId,@Code,@depName
	  While @@FETCH_STATUS=0
	  BEGIN

	 If Not Exists (select id from Common.Department where CompanyId=@NEW_COMPANY_ID and code=@Code and name=@depName )
    BEGIN
		 set @Departmentidnew=NEWID()
       Insert into Common.Department(Id,Code,CompanyId,Name,Remarks,RecOrder,UserCreated,CreatedDate,Status,ChargeOfRate,Currency)

       select @Departmentidnew,Code,@NEW_COMPANY_ID AS CompanyId,Name,Remarks,RecOrder,'System' AS UserCreated,Getutcdate() AS CreatedDate,Status,ChargeOfRate,Currency
        From Common.Department where CompanyId=@UNIQUE_COMPANY_ID and Id=@DepartmentId

		
	  set @Desgnationidnew=NEWID()

        insert into Common.DepartmentDesignation(Id,Code,DepartmentId,Name,DepartmentRank,Level,LevelRank,IsApplicable,Remarks,RecOrder,UserCreated,CreatedDate,Status,Rank)

        Select @Desgnationidnew,Code,@Departmentidnew,Name,DepartmentRank,Level,LevelRank,IsApplicable,Remarks,RecOrder,'System' AS UserCreated,Getutcdate() AS CreatedDate,Status,Rank 
        FROM Common.DepartmentDesignation where DepartmentId=@DepartmentId and Id=@DesgnationId

		

	     Insert into [HR].[Questionnaire](Id,CompanyId,Name,Designation,Level,RecOrder,UserCreated,CreatedDate,Version,Status,Remarks,IsLocked,DepartmentId,DesignationId,AppraisalCycle)

	     SELECT NEWID(),@NEW_COMPANY_ID AS CompanyId,Name,Designation,Level,RecOrder,'System' AS UserCreated,Getutcdate() AS CreatedDate,Version,Status,Remarks,IsLocked
         ,@Departmentidnew,@Desgnationidnew,AppraisalCycle FROM [HR].[Questionnaire] where CompanyId=@UNIQUE_COMPANY_ID and DepartmentId=@DepartmentId and DesignationId=@DesgnationId


 
    end
		fetch next from Depart_Get Into @Departmentid,@Desgnationid,@CompanyId,@Code,@depName
		END		
	Close Depart_Get
	Deallocate Depart_Get

	--------------Employee--------

	 Declare Employee_Get Cursor For
	  select id,FirstName,EmployeeId,SyncEntityId,PhotoId,CompanyId from  Common.Employee  where CompanyId=@UNIQUE_COMPANY_ID
	 
	  Open Employee_Get
	  fetch next from Employee_Get Into @EmployeeId,@Employeename,@Employeeno,@SyncEntityId,@PhotoId,@CompanyId
	  While @@FETCH_STATUS=0
	  BEGIN


      IF Not Exists( select id  from Common.Employee where CompanyId=@NEW_COMPANY_ID and FirstName=@Employeename and EmployeeId= @Employeeno)
     BEGIN
      
   --   set @MediaRepositoryid=Newid()
	  --set @SyncEmployeeIdnew=Newid()

	  	If Exists (Select Id From Common.CompanyModule Where CompanyId=@NEW_COMPANY_ID And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
			Begin
			
			 if  exists ( select id from bean.entity where  CompanyId=@UNIQUE_COMPANY_ID and id=@SyncEntityId and id is not null )
			 Begin 
			  set @entityidnew=Newid()
			  end
			 If  exists ( select id from Common.MediaRepository where  CompanyId=@UNIQUE_COMPANY_ID and   id=@PhotoId and id is not null )
			    begin
	           set @MediaRepositoryid=Newid()
		       end
	         set @SyncEmployeeIdnew=Newid()

	       

      Insert into  bean.entity(Id,CompanyId,Name,TypeId,IdTypeId,IdNo,GSTRegNo,IsCustomer,CustTOPId,CustTOP,CustTOPValue,CustCreditLimit,CustCurrency,CustNature,IsVendor,VenTOPId,VenTOP,
      VenTOPValue,VenCurrency,VenNature,AddressBookId,IsLocal,ResBlockHouseNo,ResStreet,ResUnitNo,ResBuildingEstate,ResCity,ResPostalCode,ResState,ResCountry,
      RecOrder,Remarks,UserCreated,CreatedDate,Version,Status,VenCreditLimit,Communication,VendorType,IsShowPayroll,IsExternalData,DocumentId,COAId,TaxId,
      CreditLimitValue,ExternalEntityType,CustBal,VenBal,SyncEmployeeId,SyncEmployeeStatus,SyncEmployeeDate,SyncEmployeeRemarks)  -----ServiceEntityId
      
        select @entityidnew,@NEW_COMPANY_ID AS CompanyId,Name,TypeId,IdTypeId,IdNo,GSTRegNo,IsCustomer,CustTOPId,CustTOP,CustTOPValue,CustCreditLimit,CustCurrency,CustNature,IsVendor,VenTOPId,VenTOP
        ,VenTOPValue,VenCurrency,VenNature,AddressBookId,IsLocal,ResBlockHouseNo,ResStreet,ResUnitNo,ResBuildingEstate,ResCity,ResPostalCode,ResState,ResCountry
        ,RecOrder,Remarks,UserCreated,CreatedDate,Version,Status,VenCreditLimit,Communication,VendorType,IsShowPayroll,IsExternalData,DocumentId,COAId,TaxId
        ,CreditLimitValue,ExternalEntityType,CustBal,VenBal,
        --SyncClientId,SyncClientStatus,SyncClientRemarks,SyncClientDate,SyncAccountId,SyncAccountStatus,SyncAccountRemarks,SyncAccountDate,
         @SyncEmployeeIdnew as SyncEmployeeId,'Completed' as SyncEmployeeStatus, getutcdate() as SyncEmployeeDate,SyncEmployeeRemarks
		 --ServiceEntityId
          From  bean.entity where CompanyId=@UNIQUE_COMPANY_ID  and SyncEmployeeId=@EmployeeId and SyncEmployeeId is not null




		    Insert into  Common.MediaRepository(Id,CompanyId,SourceType,MediaType,Original,Small,Medium,Large,CssSprite,Status,DocumentId)
             select @MediaRepositoryid,@NEW_COMPANY_ID AS CompanyId,SourceType,MediaType,Original,Small,Medium,Large,CssSprite,Status,DocumentId from Common.MediaRepository
             where CompanyId=@UNIQUE_COMPANY_ID and id=@PhotoId and id is not null


   

       Insert into Common.Employee(Id,CompanyId,Title,Gender,FirstName,LastName,PhoneNo,DOB,Username,Email,Role,PhotoId,DeactivationDate,MetadataValues,DateOfJoin,UsecompanyWorkProfile,Remarks,UserCreated,
       CreatedDate,Version,Status,Communication,EmployeeType,EmployeeId,MobileNo,Designation,Nationality,CountryOfOrigin,MaritalStatus,Race,Religion,MemberShip,
       IdNo,ResidenceStatus,IdType,AgencyFund,PassportNumber,PassportExpiry,OtherIDType,OtherIDNumber,IDExpiryDate,WorkPassType,WorkPassNumber,WorkPassDateofApplication,WorkPassDateofIssue,
       WorkPassDateofExpiry,DateOfSPRGranted,DateOfSPRExpiry,NRICNumber,FIN,IsMandatoryTimeReport,IsWorkflowOnly,JobApplicationId,IsHROnly,EntityId,SyncEntityId,SyncEntityStatus,SyncEntityDate,
       SyncEntityRemarks,IsEmployee)

       select @SyncEmployeeIdnew as Id,@NEW_COMPANY_ID AS CompanyId,Title,Gender,FirstName,LastName,PhoneNo,DOB,Username,Email,Role,@MediaRepositoryid as PhotoId,DeactivationDate,MetadataValues,DateOfJoin,UsecompanyWorkProfile,Remarks, 'System' AS UserCreated
       ,Getutcdate() AS CreatedDate,Version,Status,Communication,EmployeeType,EmployeeId,MobileNo,Designation,Nationality,CountryOfOrigin,MaritalStatus,Race,Religion,MemberShip
       ,IdNo,ResidenceStatus,IdType,AgencyFund,PassportNumber,PassportExpiry,OtherIDType,OtherIDNumber,IDExpiryDate,WorkPassType,WorkPassNumber,WorkPassDateofApplication,WorkPassDateofIssue
       ,WorkPassDateofExpiry,DateOfSPRGranted,DateOfSPRExpiry,NRICNumber,FIN,IsMandatoryTimeReport,IsWorkflowOnly,JobApplicationId,IsHROnly,@entityidnew EntityId,@entityidnew as SyncEntityId,SyncEntityStatus, Getutcdate()as SyncEntityDate
       ,SyncEntityRemarks,IsEmployee from Common.Employee
       where CompanyId=@UNIQUE_COMPANY_ID and id=@EmployeeId and FirstName=@Employeename and EmployeeId=@Employeeno

	  end
          
		   else 
		   begin

		   	 If  exists ( select id from Common.MediaRepository where  CompanyId=@UNIQUE_COMPANY_ID and   id=@PhotoId and id is not null )
			    begin
	           set @MediaRepositoryid=Newid()
		       end
	          set @SyncEmployeeIdnew=Newid()

             Insert into  Common.MediaRepository(Id,CompanyId,SourceType,MediaType,Original,Small,Medium,Large,CssSprite,Status,DocumentId)
             select @MediaRepositoryid,@NEW_COMPANY_ID AS CompanyId,SourceType,MediaType,Original,Small,Medium,Large,CssSprite,Status,DocumentId from Common.MediaRepository
             where CompanyId=@UNIQUE_COMPANY_ID and id=@PhotoId


   

       Insert into Common.Employee(Id,CompanyId,Title,Gender,FirstName,LastName,PhoneNo,DOB,Username,Email,Role,PhotoId,DeactivationDate,MetadataValues,DateOfJoin,UsecompanyWorkProfile,Remarks,UserCreated,
       CreatedDate,Version,Status,Communication,EmployeeType,EmployeeId,MobileNo,Designation,Nationality,CountryOfOrigin,MaritalStatus,Race,Religion,MemberShip,
       IdNo,ResidenceStatus,IdType,AgencyFund,PassportNumber,PassportExpiry,OtherIDType,OtherIDNumber,IDExpiryDate,WorkPassType,WorkPassNumber,WorkPassDateofApplication,WorkPassDateofIssue,
       WorkPassDateofExpiry,DateOfSPRGranted,DateOfSPRExpiry,NRICNumber,FIN,IsMandatoryTimeReport,IsWorkflowOnly,JobApplicationId,IsHROnly,EntityId,SyncEntityId,SyncEntityStatus,SyncEntityDate,
       SyncEntityRemarks,IsEmployee)

       select @SyncEmployeeIdnew as Id,@NEW_COMPANY_ID AS CompanyId,Title,Gender,FirstName,LastName,PhoneNo,DOB,Username,Email,Role,@MediaRepositoryid as PhotoId,DeactivationDate,MetadataValues,DateOfJoin,UsecompanyWorkProfile,Remarks, 'System' AS UserCreated
       ,Getutcdate() AS CreatedDate,Version,Status,Communication,EmployeeType,EmployeeId,MobileNo,Designation,Nationality,CountryOfOrigin,MaritalStatus,Race,Religion,MemberShip
       ,IdNo,ResidenceStatus,IdType,AgencyFund,PassportNumber,PassportExpiry,OtherIDType,OtherIDNumber,IDExpiryDate,WorkPassType,WorkPassNumber,WorkPassDateofApplication,WorkPassDateofIssue
       ,WorkPassDateofExpiry,DateOfSPRGranted,DateOfSPRExpiry,NRICNumber,FIN,IsMandatoryTimeReport,IsWorkflowOnly,JobApplicationId,IsHROnly,@entityidnew EntityId,@entityidnew as SyncEntityId,SyncEntityStatus,SyncEntityDate
       ,SyncEntityRemarks,IsEmployee from Common.Employee
       where CompanyId=@UNIQUE_COMPANY_ID and id=@EmployeeId and FirstName=@Employeename and EmployeeId=@Employeeno
	   end
     END
  fetch next from Employee_Get Into @EmployeeId,@Employeename,@Employeeno,@SyncEntityId,@PhotoId,@CompanyId
	END		
	Close Employee_Get
	Deallocate Employee_Get
	---------------------	
		
		 Declare ClaimSetup_Get Cursor For
	 		 		 
         SELECT  ID,Category,Type,ItemName,CompanyId,COAId FROM HR.ClaimItem where CompanyId=@UNIQUE_COMPANY_ID 

	  Open ClaimSetup_Get
	  fetch next from ClaimSetup_Get Into @ClaimItemId,@Category,@Type,@ItemName,@CompanyId,@CoaId
	  While @@FETCH_STATUS=0
	  BEGIN
      
  	 If Not Exists (select id FROM HR.ClaimItem where CompanyId=@NEW_COMPANY_ID and Category=@Category AND Type=@Type AND ItemName=@ItemName )
    BEGIN
	 SET @ClaimItemIdNEW=Newid()
	 --SET @ClaimSetupIdnew=Newid()

	  --set @ClaimSetupId=(SELECT Distinct  ClaimSetupId FROM  [HR].[ClaimSetupDetail] where ClaimItemId=@ClaimItemId)
	  -- SET @DepartmentName=( Select  Name from Common.Department where id in  (SELECT DepartmentId FROM [HR].[ClaimSetup] where CompanyId=@UNIQUE_COMPANY_ID  and id=@ClaimSetupId  AND DepartmentId IS NOT NULL))
	  -- SET @DesgnationName=(Select  Name from Common.DepartmentDesignation where id in  (SELECT DesignationId FROM [HR].[ClaimSetup] where CompanyId=@UNIQUE_COMPANY_ID  and id=@ClaimSetupId  AND DesignationId IS NOT NULL))
	  -- SET @Departmentidnew=(Select  Id from Common.Department where name=@DepartmentName and CompanyId=@NEW_COMPANY_ID)
	  -- SET @Desgnationidnew=(Select  Id from Common.DepartmentDesignation where  name=@DepartmentName and DepartmentId in(Select  Id from Common.Department where name=@DepartmentName and CompanyId=@NEW_COMPANY_ID))

	     set @CoaId= (select  Distinct CoaId  from  [HR].[ClaimItem] WHERE CompanyId=@UNIQUE_COMPANY_ID AND COAId=@CoaId and Id=@ClaimItemId and CoaId is not null)
        set @ChartOfAccount = (select Distinct Name from  Bean.ChartOfAccount where id=@CoaId and CompanyId=@UNIQUE_COMPANY_ID)
        set @CoaIdnew = (select Distinct Id from  Bean.ChartOfAccount where name=@ChartOfAccount and CompanyId=@NEW_COMPANY_ID)


  Insert into [HR].[ClaimItem] (Id, CompanyId,Category,Type,ItemName,IsVerifier,Remarks,UserCreated,CreatedDate,RecOrder,Status,Version,IsCategoryDisable,COAId)
  SELECT @ClaimItemIdNEW as id,@NEW_COMPANY_ID as CompanyId,Category,Type,ItemName,IsVerifier,Remarks,'System' AS UserCreated,Getutcdate() AS CreatedDate,RecOrder,Status,Version,IsCategoryDisable,@CoaIdnew AS COAId 
  FROM [HR].[ClaimItem]  where CompanyId=@UNIQUE_COMPANY_ID and id=@ClaimItemId and Category=@Category and Type=@Type and ItemName=@ItemName

 

  --Insert into [HR].[ClaimSetup](Id,CompanyId,Category,Type,ApplyTo,DepartmentId,DesignationId,CategoryLimit,Remarks,UserCreated,CreatedDate,RecOrder,Status,Version,IsFromClaimItem,IsCategoryDisable)

  --SELECT @ClaimSetupIdnew as id,@NEW_COMPANY_ID AS [CompanyId],[Category],[Type],[ApplyTo],@Departmentidnew,@Desgnationidnew,[CategoryLimit],[Remarks],'System' AS  [UserCreated],Getutcdate() AS [CreatedDate],
  --[RecOrder],[Status],[Version],[IsFromClaimItem],[IsCategoryDisable] FROM [HR].[ClaimSetup] 
  --where CompanyId=@UNIQUE_COMPANY_ID  and id=@ClaimSetupId

 

 
   --insert into [HR].[ClaimSetupDetail](Id,ClaimSetupId,ClaimItemId,TransactionLimit,AnnualLimit,CreatedDate,UserCreated,RecOrder,Status,Version)
   --SELECT NEWID(),@ClaimSetupIdnew AS ClaimSetupId,@ClaimItemIdNEW AS ClaimItemId,TransactionLimit,AnnualLimit,Getutcdate() AS CreatedDate,'System' AS UserCreated,RecOrder,Status,Version FROM 
   --[HR].[ClaimSetupDetail] where ClaimSetupId=@ClaimSetupId and ClaimItemId=@ClaimItemId


	END 
      
  fetch next from ClaimSetup_Get Into @ClaimItemId,@Category,@Type,@ItemName,@CompanyId,@CoaId
	END		
	Close ClaimSetup_Get
	Deallocate ClaimSetup_Get
		--====================[DevelopmentPlan]
		 If Not Exists (select Top 1 id  from [HR].[DevelopmentPlan]  where CompanyId=@NEW_COMPANY_ID )
    BEGIN
     
          Insert into [HR].[DevelopmentPlan](Id,CompanyId,DevelopmentPlanMethod,Description,RecOrder,UserCreated,CreatedDate,Version,Status,Remarks)
          SELECT   NEWID(),@NEW_COMPANY_ID AS CompanyId,DevelopmentPlanMethod,Description,RecOrder,'System' AS UserCreated,Getutcdate() AS CreatedDate,Version,Status,Remarks
          FROM [HR].[DevelopmentPlan] where CompanyId=@UNIQUE_COMPANY_ID
 
      END

	 ------------ Question-------------

	  If Not Exists (select Top 1 id  from [HR].[Question]  where CompanyId=@NEW_COMPANY_ID )
        BEGIN

          Insert Into [HR].[Question](Id,CompanyId,Name,Category,QuestionType,RecOrder,UserCreated,CreatedDate,Version,Status,Remarks,QuestionOptions)

          SELECT  NEWID(),@NEW_COMPANY_ID AS CompanyId,Name,Category,QuestionType,RecOrder,'System' AS UserCreated,Getutcdate() AS CreatedDate,Version,Status,Remarks,QuestionOptions
           FROM [HR].[Question] where CompanyId=@UNIQUE_COMPANY_ID
	   END

	  --------Competence----

	   If Not Exists (select Top 1 id  from [HR].[Competence]  where CompanyId=@NEW_COMPANY_ID )
        BEGIN
	
           Insert Into [HR].[Competence](Id,CompanyId,Name,Description,RecOrder,UserCreated,CreatedDate,Version,Status,Remarks)
		      
		   select NEWID(),@NEW_COMPANY_ID AS CompanyId,Name,Description,RecOrder,'System' AS UserCreated,Getutcdate() AS CreatedDate,Version,1 AS Status,Remarks FROM [HR].[Competence]
		   where CompanyId=@UNIQUE_COMPANY_ID

		END

		---- Objectives----

	
	
	   If Not Exists (select Top 1 id  from HR.Objective  where CompanyId=@NEW_COMPANY_ID )
        BEGIN

		
		    Insert into HR.Objective(Id,CompanyId,Name,Type,Progress,Weight,RecOrder,UserCreated,CreatedDate,Version,Status,Remarks)

		    select NEWID(),@NEW_COMPANY_ID AS CompanyId,Name,Type,Progress,Weight,RecOrder,'System' AS UserCreated,Getutcdate() AS CreatedDate,Version,Status,Remarks from HR.Objective
		     where CompanyId=@UNIQUE_COMPANY_ID
         END

       -----------HR.CompanyPayrollsetup----
	     If Not Exists (select Top 1 id  from HR.CompanyPayrollSettings   where ParentCompanyId=@NEW_COMPANY_ID )
        BEGIN
	 
             Insert into HR.CompanyPayrollSettings(Id,CompanyId,ParentCompanyId,CPFSubmissionNumber,TaxReferenceNumber,DefaultPayDayoftheMonth,DefaultPayFrequency,SPRFirstYear,SPRSecondYear,Remarks,RecOrder,UserCreated,
             CreatedDate,Version,Status,EmployeeCPFContribution)
		     
             Select NEWID(), CompanyId,@NEW_COMPANY_ID AS ParentCompanyId,CPFSubmissionNumber,TaxReferenceNumber,DefaultPayDayoftheMonth,DefaultPayFrequency,SPRFirstYear,SPRSecondYear,Remarks,RecOrder,
             'System' AS UserCreated,Getutcdate() AS CreatedDate,Version,Status,EmployeeCPFContribution from HR.CompanyPayrollSettings
              where ParentCompanyId=@UNIQUE_COMPANY_ID
           END

    ---------Common.AttendanceSetup----------------

	   If Not Exists (select Top 1 id  from Common.AttendanceRules   where CompanyId=@NEW_COMPANY_ID )
        BEGIN
	
           Insert into Common.AttendanceRules(Id,CompanyId,LateInTime,LateInType,LateInTimeType,LateInStatus,LateOutTime,LateOutType,LateOutTimeType,LateOutStatus,PreviousTime,PreviousType,PreviousTimeType,PreviousStatus
           ,UserCreated,CreatedDate,Version,Status)
              
            select NEWID(),@NEW_COMPANY_ID AS CompanyId,LateInTime,LateInType,LateInTimeType,LateInStatus,LateOutTime,LateOutType,LateOutTimeType,LateOutStatus,PreviousTime,PreviousType,PreviousTimeType,PreviousStatus
            ,'System' AS UserCreated,Getutcdate() AS CreatedDate,Version,Status
             from Common.AttendanceRules where CompanyId=@UNIQUE_COMPANY_ID
         END

     --------LeaveSetup------

	       If Not Exists (select Top 1 id  from HR.LeaveType  where CompanyId=@NEW_COMPANY_ID )
        BEGIN
   
		     set @Leavetypeid=NEWID()
             Insert into  HR.LeaveType(Id,CompanyId,Name,NoOfLeaves,IsShowToUser,LeaveAccuralType,AccuralDays,IsCarryForward,NoOfDays,IsAllowExcess,EnableLeaveRecommender,IsNoOfDays
             ,Remarks,RecOrder,UserCreated,CreatedDate,Version,Status,EntitlementType,EntitlementHours,ApplyToAll)
              
             Select NEWID(),@NEW_COMPANY_ID AS CompanyId,Name,NoOfLeaves,IsShowToUser,LeaveAccuralType,AccuralDays,IsCarryForward,NoOfDays,IsAllowExcess,EnableLeaveRecommender,IsNoOfDays
            ,Remarks,RecOrder,'System' AS UserCreated,Getutcdate() AS CreatedDate,Version,Status,EntitlementType,EntitlementHours,ApplyToAll from HR.LeaveType
             where CompanyId=@UNIQUE_COMPANY_ID
           END 




    --------Claender----

	   If Not Exists (select Top 1 id  from Common.Calender  where CompanyId=@NEW_COMPANY_ID )
        BEGIN
      
              Insert into Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,Version,Status)
              select NEWID(),@NEW_COMPANY_ID AS CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,
             'System' AS UserCreated,Getutcdate() AS CreatedDate,Version,Status from Common.Calender
	          where CompanyId=@UNIQUE_COMPANY_ID

	       END



		   --========================================== [HR].[ClaimSetup]

		     Insert into [HR].[ClaimSetup](Id,CompanyId,Category,Type,ApplyTo,DepartmentId,DesignationId,CategoryLimit,Remarks,UserCreated,CreatedDate,RecOrder,Status,Version,IsFromClaimItem,IsCategoryDisable)

  SELECT newid() as id,@NEW_COMPANY_ID AS [CompanyId],[Category],[Type],[ApplyTo],null,null,[CategoryLimit],[Remarks],'System' AS  [UserCreated],Getutcdate() AS [CreatedDate],
  [RecOrder],[Status],[Version],[IsFromClaimItem],[IsCategoryDisable] FROM [HR].[ClaimSetup] 
  where CompanyId=@UNIQUE_COMPANY_ID  --and id=@ClaimSetupId

  --===========================================[HR].[ClaimSetup]

    ----------settings----------

	If Not Exists (select Top 1 id  from Common.HRSettings  where CompanyId=@NEW_COMPANY_ID )
        BEGIN
      
		  set @HRSettingsid=NEWID()

            Insert into Common.HRSettings(Id,CompanyId,ResetLeaveBalanceType,ResetLeaveBalanceDate,Year,Month,Remarks,RecOrder,UserCreated,CreatedDate,Version,Status,
            CustomYear,CustomMonth,IsExistEmployeeAutoNumber,CarryforwardResetDate,IsHideAppraiserName,IsSelfAppraisal)
            
            select @HRSettingsid,@NEW_COMPANY_ID AS CompanyId,ResetLeaveBalanceType,ResetLeaveBalanceDate,Year,Month,Remarks,RecOrder, 'System' AS UserCreated,Getutcdate() AS CreatedDate,Version,Status,
            CustomYear,CustomMonth,IsExistEmployeeAutoNumber,CarryforwardResetDate,IsHideAppraiserName,IsSelfAppraisal  from Common.HRSettings
	        where CompanyId=@UNIQUE_COMPANY_ID
          

		   Insert into Common.HRSettingdetails(Id,MasterId,StartDate,EndDate,CarryforwardResetDate,IsResetCompleted,Recorder)
		     select NEWID(),@HRSettingsid AS Masterid,StartDate,EndDate,CarryforwardResetDate,IsResetCompleted,Recorder
             from Common.HRSettingdetails where MasterId in (select  id from Common.HRSettings
	                                                                    where CompanyId=@UNIQUE_COMPANY_ID)
          end
		END

GO
