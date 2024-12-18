USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_Account_Entity]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  --select * from CLientCursor.
--Exec  [dbo].[Common_Sync_MasterData_Account_Entity] 237,'46D5F9FD-AC99-42A4-B8A0-01F9686ACB34','Edit'  
CREATE Procedure [dbo].[Common_Sync_MasterData_Account_Entity]  
 @CompanyId BigInt,   
 @AccountId Uniqueidentifier,  
 @Action Varchar(50)  
As  
Begin  
 Declare @UserCreatedOrModified Varchar(10),  
   @GetDate DateTime2,  
   @BaseCurrency varchar(20),  
   @SyncStatusCompleted varchar(20),  
   @SyncStatusUpdateCompleted varchar(20),  
   @SyncStatusUpdateFalied varchar(20),  
   @SyncStatusFailed varchar(20),  
   @IsExternalData Int,  
   @CustNature Varchar(20),  
   @EntityId Uniqueidentifier,  
   @IndCount Int,  
   @Count Int,  
   @ContactId Uniqueidentifier,  
   @CDEntityId Uniqueidentifier,  
   @SyncEntityId Uniqueidentifier,  
   @AdrsCount int,  
   @AddressBookId Uniqueidentifier,  
   @New_ContctDtlId Uniqueidentifier,  
   @AdrsEntityId Uniqueidentifier,  
   @AdrsSyncEntitytId Uniqueidentifier,  
   @SyncAccountId Uniqueidentifier,  
   @ContactDetailId Uniqueidentifier,  
   @AddressId Uniqueidentifier,  
   @AddrsAddSecType Nvarchar(100),  
   @AdrsSyncEntityId Uniqueidentifier,  
   @AdrsSyncAccountId Uniqueidentifier,  
   @CntdtlEntityId Uniqueidentifier,  
   @CntDtlDestId Uniqueidentifier  
  Set @UserCreatedOrModified='System'  
  Set @GetDate=GetUtcdate()  
  Set @SyncStatusCompleted='Completed'  
  Set @SyncStatusUpdateCompleted='UpdateCompleted'  
  Set @SyncStatusUpdateFalied='UpdateFailed'  
  Set @IsExternalData=1  
  Set @CustNature='Trade'  
  Set @SyncStatusFailed='Failed'  
  
 --Declare Temp Table variable to store contact deatils  
 Create Table #Loc_Cont_Tbl (Id Int Identity(1,1),ContactDetailId Uniqueidentifier,EntityType Nvarchar(200),ContactId Uniqueidentifier,EntityId Uniqueidentifier,DestId Uniqueidentifier)  
 --Declare Temp Table variable to store Addresses deatils  
 Create Table #Loc_AdrsTbl (Id Int Identity(1,1),AddressId Uniqueidentifier,AddressBookId Uniqueidentifier,AddSectionType NVarchar(100),AdrsEntityId Uniqueidentifier,DestId Uniqueidentifier)  
  
 Select @BaseCurrency=BaseCurrency from bean.FinancialSetting where CompanyId=@CompanyId  
  
 If @BaseCurrency is null Set @BaseCurrency='SGD'  
 If Exists(Select Id From ClientCursor.Account Where CompanyId=@CompanyId And Id=@AccountId)  
 Begin  
  --Begin Transaction  
  Begin Transaction  
  --Try Block For Whole Transaction  
  Begin Try  
   If(@Action='Add')  
   Begin  
    If Not Exists (Select Id From Bean.Entity Where SyncAccountId=@AccountId And CompanyId=@CompanyId)  
    Begin  
     Begin Try  
      Set @EntityId=NEWID()  
      Insert Into Bean.Entity (Id,CompanyId,Name,TypeId,IdTypeId,IdNo,IsCustomer,CustTOPId,CustCurrency,CustNature,RecOrder,Remarks,UserCreated,CreatedDate,Status,IsExternalData,IsShowPayroll,Communication,ExternalEntityType,SyncAccountId,SyncAccountDate,
SyncAccountStatus,SyncAccountRemarks,DocumentId,Industry,IndustryCode,PrincipalActivities,SyncClientId)  
       Select @EntityId,@CompanyId,Name,AccountTypeId,AccountIdTypeId,AccountIdNo,1,Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from common.termsofpayment where companyid=@companyId and name='Credit - 0') end,  
         @BaseCurrency,@CustNature,RecOrder,Remarks,@UserCreatedOrModified,@GetDate,Status,1,1 ,Communication,'Account',@AccountId,@GetDate,@SyncStatusCompleted,null,@AccountId,Industry,IndustryCode,PrincipalActivities 
		 ,SyncClientId
       From ClientCursor.Account   
       Where CompanyId=@CompanyId And Id=@AccountId  

      Update ClientCursor.Account Set SyncEntityId=@EntityId,SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusCompleted,SyncEntityRemarks=null Where Id=@AccountId And CompanyId=@CompanyId  
      --ContactDetails From Account  
      Begin  
       Set @IndCount=1  
       Set @Count=0  
       Insert into #Loc_Cont_Tbl  
       Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncEntityId From Common.ContactDetails As CD  
       Inner Join ClientCursor.Account As A On A.Id=CD.EntityId  
       Inner Join Common.Contact As C On C.Id=CD.ContactId   
       Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null And A.Id=@AccountId  
       Select @Count=count(*) From #Loc_Cont_Tbl  
       While @Count>=@IndCount  
       Begin  
        Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncEntityId=DestId From #Loc_Cont_Tbl Where Id=@IndCount  
        If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)  
        Begin  
         Set @New_ContctDtlId=NewId()  
         Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)  
          Select @New_ContctDtlId,@ContactId,@SyncEntityId,'Entity',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'Bean',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Account',IsCopy From Common.ContactDetails Where Id=@ContactDetailId  
        End  
        Else  
        Begin  
         Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A  
         Inner Join   
         (Select * From Common.ContactDetails Where EntityId=@AccountId And ContactId=@ContactId) As B On B.ContactId=A.ContactId  
         Where A.ContactId=@ContactId And A.EntityId=@SyncEntityId  
        End  
        Set @IndCount=@IndCount+1  
       End  
       Truncate Table #Loc_Cont_Tbl  
      End   
      --ContactDetails From Entity  
      Begin  
       Set @IndCount=1  
       Set @Count=0  
       Insert into #Loc_Cont_Tbl  
       Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncAccountId From Common.ContactDetails As CD  
       Inner Join Bean.Entity As A On A.Id=CD.EntityId  
       Inner Join Common.Contact As C On C.Id=CD.ContactId   
       Where A.CompanyId=@CompanyId And A.SyncAccountId=@AccountId  
       Select @Count=count(*) From #Loc_Cont_Tbl  
       While @Count>=@IndCount  
       Begin  
        Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncAccountId=DestId From #Loc_Cont_Tbl Where Id=@IndCount  
        If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)  
        Begin  
         Delete From Common.ContactDetails Where Id=@ContactDetailId  
        End  
        Set @IndCount=@IndCount+1  
       End  
       Truncate Table #Loc_Cont_Tbl  
      End   
      --Addresses From Account  
      Begin  
       Set @IndCount=1  
       Insert into #Loc_AdrsTbl  
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncEntityId From Common.Addresses As Adrs  
       Inner join ClientCursor.Account As A On A.Id=Adrs.AddTypeId   
       Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null And A.Id=@AccountId  
       Select @AdrsCount=count(*) From #Loc_AdrsTbl  
       While @AdrsCount>=@IndCount  
       Begin  
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount  
        If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncEntityId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)  
        Begin  
         Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)  
          Select NEWID(),AddSectionType,'Entity',@AdrsSyncEntityId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/  
        End  
        Set @IndCount=@IndCount+1  
       End  
       Truncate Table #Loc_AdrsTbl  
      End   
      --Addresses From Entity  
      Begin  
       Set @IndCount=1  
       Insert into #Loc_AdrsTbl  
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncAccountId From Common.Addresses As Adrs  
       Inner join Bean.Entity As A On A.Id=Adrs.AddTypeId   
       Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And A.Id=@EntityId  
       Select @AdrsCount=count(*) From #Loc_AdrsTbl  
       While @AdrsCount>=@IndCount  
       Begin  
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncAccountId=DestId From #Loc_AdrsTbl Where Id=@IndCount  
        If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncAccountId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)  
        Begin  
         Delete From Common.Addresses Where Id=@AddressId  
        End  
        Set @IndCount=@IndCount+1  
       End  
       Truncate Table #Loc_AdrsTbl  
      End   
      --ContactDetail From Account  
      Begin  
       Set @IndCount=1  
       Insert into #Loc_AdrsTbl  
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As AccountId From Common.Addresses As Adrs  
       Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId   
       Where A.EntityId In (Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncEntityId Is Not Null And Id=@AccountId)  
       Select @AdrsCount=count(*) From #Loc_AdrsTbl  
       While @AdrsCount>=@IndCount  
       Begin  
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount  
        Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId  
        If @ContactId Is Not null And @SyncAccountId Is Not Null  
        Begin  
         Set @SyncEntityId=(Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)  
         If @SyncEntityId Is Not Null  
         Begin  
          Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncEntityId And ContactId=@ContactId  
          If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)  
          Begin  
           Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)  
            Select NEWID(),AddSectionType,'EntityContactDetailId',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/  
          End  
         End  
        End  
        Set @IndCount=@IndCount+1  
       End  
       Truncate Table #Loc_AdrsTbl  
      End   
      --ContactDetail From Entity  
      Begin  
       Set @IndCount=1  
       Insert into #Loc_AdrsTbl  
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs  
       Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId   
       Where A.EntityId In (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncAccountId=@AccountId)  
       Select @AdrsCount=count(*) From #Loc_AdrsTbl  
       While @AdrsCount>=@IndCount  
       Begin  
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount  
        Select @ContactId=ContactId,@SyncEntityId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId  
        If @ContactId Is Not null And @SyncEntityId Is Not Null  
        Begin  
         Set @SyncAccountId=(Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncEntityId=@SyncEntityId And SyncEntityId Is Not Null)  
         If @SyncAccountId Is Not Null  
         Begin  
          Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncAccountId And ContactId=@ContactId  
          If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)  
          Begin  
           Delete From Common.Addresses Where Id=@AddressId  
          End  
         End  
        End  
        Set @IndCount=@IndCount+1  
       End  
       Truncate Table #Loc_AdrsTbl  
      End   
  
    End Try  
    Begin Catch  
     Declare @ErrMsg Nvarchar(max)  
     Set @ErrMsg=(Select ERROR_MESSAGE())  
     Update ClientCursor.Account Set SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusFailed,SyncEntityRemarks=@ErrMsg Where Id=@AccountId And CompanyId=@CompanyId  
    End Catch  
    End  
    Else  
    Begin  
     Exec [dbo].[Common_Sync_MasterData_Account_Entity] @CompanyId,@AccountId,'Edit'  
    End  
   End  
   --Update bean.item table records based on documentid which is edited in common.service table   
   Else If(@Action='Edit')  
   Begin  
    --Edit  
    If Exists (Select ID From Bean.Entity Where CompanyId=@CompanyId And SyncAccountId=@AccountId)  
    Begin  
     Begin Try  
      Set @EntityId=(Select SyncEntityId From ClientCursor.Account Where Id=@AccountId And CompanyId=@CompanyId)  
      Update E Set E.CompanyId=@CompanyId,E.Name=A.Name,E.TypeId=A.AccountTypeId,E.IdTypeId=A.AccountIdTypeId,E.IdNo=A.AccountIdNo,E.IsCustomer=1,E.CustTOPId=Case when TermsOfPaymentId is not null then TermsOfPaymentId else (select id from common.termsofpayment where companyid=@companyId and name='Credit - 0') end,  
        E.CustCurrency=@BaseCurrency,E.CustNature=@CustNature,E.RecOrder=A.RecOrder,E.Remarks=A.Remarks,E.ModifiedBy=@UserCreatedOrModified,E.ModifiedDate=@GetDate,E.Status=Case When A.AccountStatus='Active' Then 1 When A.AccountStatus='InActive' Then 2 Else A.Status End,E.IsExternalData=@IsExternalData,IsShowPayroll=1,Communication=A.Communication,E.ExternalEntityType='Account',E.SyncAccountStatus=@SyncStatusUpdateCompleted,E.SyncAccountDate=@GetDate,SyncAccountRemarks=null,E.IndustryCode=A.IndustryCode,
E.Industry=A.Industry,E.PrincipalActivities=A.PrincipalActivities  
      From Bean.Entity As E  
      Inner Join ClientCursor.Account As A On A.Id=E.SyncAccountId  
      Where E.CompanyId=@CompanyId And A.Id=@AccountId  
  
      Update ClientCursor.Account Set SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusUpdateCompleted,SyncEntityRemarks=null Where CompanyId=@CompanyId And Id=@AccountId  
      /*  
      --ContactDetails From Account  
      Begin  
       Set @IndCount=1  
       Set @Count=0  
       Insert into #Loc_Cont_Tbl  
       Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncEntityId From Common.ContactDetails As CD  
       Inner Join ClientCursor.Account As A On A.Id=CD.EntityId  
       Inner Join Common.Contact As C On C.Id=CD.ContactId   
       Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null And A.Id=@AccountId  
       Select @Count=count(*) From #Loc_Cont_Tbl  
       While @Count>=@IndCount  
       Begin  
        Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncEntityId=DestId From #Loc_Cont_Tbl Where Id=@IndCount  
        If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncEntityId)  
        Begin  
         Set @New_ContctDtlId=NewId()  
         Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,Is
Copy)  
          Select @New_ContctDtlId,@ContactId,@SyncEntityId,'Entity',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'Bean',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Account',IsCo
py From Common.ContactDetails Where Id=@ContactDetailId  
        End  
        Else  
        Begin  
         Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModi
fied,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A  
         Inner Join   
         (Select * From Common.ContactDetails Where EntityId=@AccountId And ContactId=@ContactId) As B On B.ContactId=A.ContactId  
         Where A.ContactId=@ContactId And A.EntityId=@SyncEntityId  
        End  
        Set @IndCount=@IndCount+1  
       End  
       Truncate Table #Loc_Cont_Tbl  
      End   
      --ContactDetails From Entity  
      Begin  
       Set @IndCount=1  
       Set @Count=0  
       Insert into #Loc_Cont_Tbl  
       Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncAccountId From Common.ContactDetails As CD  
       Inner Join Bean.Entity As A On A.Id=CD.EntityId  
       Inner Join Common.Contact As C On C.Id=CD.ContactId   
       Where A.CompanyId=@CompanyId And A.SyncAccountId=@AccountId  
       Select @Count=count(*) From #Loc_Cont_Tbl  
       While @Count>=@IndCount  
       Begin  
        Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncAccountId=DestId From #Loc_Cont_Tbl Where Id=@IndCount  
        If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncAccountId)  
        Begin  
         Delete From Common.ContactDetails Where Id=@ContactDetailId  
        End  
        Set @IndCount=@IndCount+1  
       End  
       Truncate Table #Loc_Cont_Tbl  
      End   
      */  
      --Addresses From Account  
      Begin  
       Set @IndCount=1  
       Insert into #Loc_AdrsTbl  
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncEntityId From Common.Addresses As Adrs  
       Inner join ClientCursor.Account As A On A.Id=Adrs.AddTypeId   
       Where A.CompanyId=@CompanyId And A.SyncEntityId Is Not Null And A.Id=@AccountId  
       Select @AdrsCount=count(*) From #Loc_AdrsTbl  
       While @AdrsCount>=@IndCount  
       Begin  
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount  
        If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncEntityId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)  
        Begin  
         Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)  
          Select NEWID(),AddSectionType,'Entity',@AdrsSyncEntityId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/  
        End  
        Set @IndCount=@IndCount+1  
       End  
       Truncate Table #Loc_AdrsTbl  
      End   
      --Addresses From Entity  
      Begin  
       Set @IndCount=1  
       Insert into #Loc_AdrsTbl  
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncAccountId From Common.Addresses As Adrs  
       Inner join Bean.Entity As A On A.Id=Adrs.AddTypeId   
       Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And A.Id=@EntityId  
       Select @AdrsCount=count(*) From #Loc_AdrsTbl  
       While @AdrsCount>=@IndCount  
       Begin  
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncAccountId=DestId From #Loc_AdrsTbl Where Id=@IndCount  
        If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncAccountId And Addressbookid=@AddressBookId/*And CompanyId=@CompanyId*/)  
        Begin  
         Delete From Common.Addresses Where Id=@AddressId  
        End  
        Set @IndCount=@IndCount+1  
       End  
       Truncate Table #Loc_AdrsTbl  
      End   
      /*  
      --ContactDetail From Account  
      Begin  
       Set @IndCount=1  
       Insert into #Loc_AdrsTbl  
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId As AccountId From Common.Addresses As Adrs  
       Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId   
       Where A.EntityId In (Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncEntityId Is Not Null And Id=@AccountId)  
       Select @AdrsCount=count(*) From #Loc_AdrsTbl  
       While @AdrsCount>=@IndCount  
       Begin  
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount  
        Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId  
        If @ContactId Is Not null And @SyncAccountId Is Not Null  
        Begin  
         Set @SyncEntityId=(Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)  
         If @SyncEntityId Is Not Null  
         Begin  
          Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncEntityId And ContactId=@ContactId  
          If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)  
          Begin  
           Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)  
            Select NEWID(),AddSectionType,'EntityContactDetailId',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/  
          End  
         End  
        End  
        Set @IndCount=@IndCount+1  
       End  
       Truncate Table #Loc_AdrsTbl  
      End   
      --ContactDetail From Entity  
      Begin  
       Set @IndCount=1  
       Insert into #Loc_AdrsTbl  
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs  
       Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId   
       Where A.EntityId In (Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncAccountId=@AccountId)  
       Select @AdrsCount=count(*) From #Loc_AdrsTbl  
       While @AdrsCount>=@IndCount  
       Begin  
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount  
        Select @ContactId=ContactId,@SyncEntityId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId  
        If @ContactId Is Not null And @SyncEntityId Is Not Null  
        Begin  
         Set @SyncAccountId=(Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncEntityId=@SyncEntityId And SyncEntityId Is Not Null)  
         If @SyncAccountId Is Not Null  
         Begin  
          Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncAccountId And ContactId=@ContactId  
          If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId /*And CompanyId=@CompanyId*/)  
          Begin  
           Delete From Common.Addresses Where Id=@AddressId  
          End  
         End  
        End  
        Set @IndCount=@IndCount+1  
       End  
       Truncate Table #Loc_AdrsTbl  
      End   
      */  
     End Try  
     Begin catch  
      Declare @UpdtErrMsg Nvarchar(Max)  
      Set @UpdtErrMsg=(Select ERROR_MESSAGE())  
      Update ClientCursor.Account Set SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusUpdateFalied,SyncEntityRemarks=@UpdtErrMsg Where Id=@AccountId And CompanyId=@CompanyId  
     End Catch  
    End  
   /* Else  
    Begin  
     Exec [dbo].[Common_Sync_MasterData_Account_Entity] @CompanyId,@AccountId,'Add'  
    End */  
   End  
   Else If(@Action='Active' OR @Action='Inactive')  
   Begin  
    If Exists (Select ID From Bean.Entity Where CompanyId=@CompanyId And SyncAccountId=@AccountId)  
    Begin  
     Begin Try  
      Update Bean.Entity Set Status = Case When @Action='Active' Then 1 When @Action='Inactive' Then 2 End ,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,SyncAccountDate=@GetDate,SyncAccountStatus=@SyncStatusUpdateCompleted,SyncAccountRemarks=Null Where SyncAccountId= @AccountId And CompanyId=@CompanyId  
     End Try  
     Begin Catch  
      Declare @ActErrMsg Nvarchar(Max)  
      Set @ActErrMsg=(Select ERROR_MESSAGE())  
      Update ClientCursor.Account Set SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusUpdateFalied,SyncEntityRemarks=@ActErrMsg Where Id=@AccountId And CompanyId=@CompanyId  
      Update ClientCursor.Account Set SyncEntityId=@EntityId,SyncEntitydate=@GetDate,SyncEntityStatus=@SyncStatusUpdateCompleted,SyncEntityRemarks=null Where Id=@AccountId And CompanyId=@CompanyId  
     End Catch  
    End  
   End  
   IF OBJECT_ID(N'tempdb..#Loc_Cont_Tbl ') IS NOT NULL
BEGIN
DROP TABLE #Loc_Cont_Tbl 
END 
  IF OBJECT_ID(N'tempdb..#Loc_AdrsTbl') IS NOT NULL
BEGIN
DROP TABLE #Loc_AdrsTbl
END   
   Commit Transaction  
  End Try  
  
  Begin Catch  
  Rollback Transaction;  
  End Catch  
 End  
End  
  
  
GO
