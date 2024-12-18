USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_Account_Client]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
      
--ALTER TABLE common.timelogitem  ADD SystemSubTypeStatus NVARCHAR(20)      
      
--update ti set ti.SystemSubTypeStatus=la.leavestatus from Common.TimeLogItem as ti join hr.LeaveApplication as la on ti.systemid=la.id where SystemType = 'LeaveApplication'      
      
      
--UPDATE Common.Employee SET isemployee=1 WHERE ID='94A06793-4158-4221-B3FE-1799DBDE450D'      
      
--==================================================================================      
      
      
      
--Exec  [dbo].[Common_Sync_MasterData_Account_Client] 237,'251C3BE9-0F7F-45D1-8648-F6F046BF24BF','Add'      
CREATE   Procedure [dbo].[Common_Sync_MasterData_Account_Client]      
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
   @ClientId Uniqueidentifier,      
   @IndCount Int,      
   @Count Int,      
   @ContactId Uniqueidentifier,      
   @CDEntityId Uniqueidentifier,      
   @SyncClientId Uniqueidentifier,      
   @AdrsCount int,      
   @AddressBookId Uniqueidentifier,      
   @AdrsEntityId Uniqueidentifier,      
   @AdrsSyncClientId Uniqueidentifier,      
   @SystemRefnum Varchar(100),      
   @GeneratedNumber Varchar(100),      
   @New_ContctDtlId Uniqueidentifier,      
   @ContactDetailId Uniqueidentifier,      
   @CntdtlAddressId Uniqueidentifier,      
   @CntDtl_AddBookId Uniqueidentifier,      
   @cntdtlAddType Nvarchar(50),      
   @AddressId UniqueIdentifier,      
   @SyncEntityId Uniqueidentifier,      
   @SyncAccountId Uniqueidentifier,      
   @AddrsAddSecType Nvarchar(100),      
   @AdrsSyncAccountId Uniqueidentifier,      
   @CntDtlDestId Uniqueidentifier,      
   @CntdtlEntityId Uniqueidentifier,      
   @Err_Msg Nvarchar(4000)      
  Set @UserCreatedOrModified='System'      
  Set @GetDate=Getutcdate()      
  Set @SyncStatusCompleted='Completed'      
  Set @SyncStatusUpdateCompleted='UpdateCompleted'      
  Set @SyncStatusUpdateFalied='UpdateFailed'      
  Set @IsExternalData=1      
  Set @CustNature='Trade'      
  Set @SyncStatusFailed='Failed'      
 --Declare Temp Table variable to store contact deatils      
 if object_id('tempdb..#Loc_Cont_Tbl', 'U') is null      
 Create Table #Loc_Cont_Tbl (Id Int Identity(1,1),ContactDetailId Uniqueidentifier,EntityType Nvarchar(200),ContactId Uniqueidentifier,EntityId Uniqueidentifier,DestId Uniqueidentifier)      
 --Declare Temp Table variable to store Addresses deatils      
 if object_id('tempdb..#Loc_AdrsTbl', 'U') is null      
 Create Table #Loc_AdrsTbl (Id Int Identity(1,1),AddressId Uniqueidentifier,AddressBookId Uniqueidentifier,AddSectionType NVarchar(100),AdrsEntityId Uniqueidentifier,DestId Uniqueidentifier)      
      
 Truncate table #Loc_Cont_Tbl      
 Truncate table #Loc_AdrsTbl      
      
 Set @GeneratedNumber=(Select GeneratedNumber From Common.AutoNumber Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))      
 Set @SystemRefnum=(Select Top(1) SystemRefNo From WorkFlow.Client Where CompanyId=@CompanyId And SystemRefNo Is not null Order By CreatedDate Desc)      
 If @SystemRefnum Is Null       
 Begin      
  Set @SystemRefnum=(Select Preview From Common.AutoNumber Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))      
 End      
 Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1,DATALENGTH(@SystemRefnum)))      
      
 --Set @SystemRefnum=CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+1) As varchar),Len(@GeneratedNumber)))      
      
 If Exists(Select Id From ClientCursor.Account Where CompanyId=@CompanyId And Id=@AccountId)      
 Begin       
  --Begin Transaction      
  Begin Transaction      
  --Try Block For Whole Transaction      
  Begin Try      
   --If new record inserted in ClientCursor.Account table that time record must be inserted in Workflow.Client table with inserted CC.Id as SyncAccountId        
   If(@Action='Add')      
   Begin      
    If Not Exists(Select Id From WorkFlow.Client Where SyncAccountId=@AccountId And CompanyId=@CompanyId)      
    Begin      
     Begin Try      
      Set @ClientId=NEWID()      
      Insert Into WorkFlow.Client (Id,Name,CompanyId,ClientTypeId,IdtypeId,ClientIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,ClientStatus,PrincipalActivities,RecOrder,Remarks,UserCreated,CreatedDate,Version,Status,Communication,SystemRefNo,SyncAccountId,SyncAccountDate,SyncAccountRemarks,SyncAccountStatus,AccountId,IndustryCode)      
        Select @ClientId,Name,@CompanyId,AccountTypeId,AccountIdTypeId,AccountIdNo,TermsOfPaymentId,Industry,Source,SourceId,SourceName,SourceRemarks,IncorporationDate,FinancialYearEnd,CountryOfIncorporation,AccountStatus,PrincipalActivities,RecOrder,    
  Remarks,@UserCreatedOrModified,@GetDate,Version,Status,Communication,      
        CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+ROW_NUMBER () Over (Order By Id) ) As varchar),Len(@GeneratedNumber))),Id,@GetDate,Null,@SyncStatusCompleted,@AccountId,IndustryCode      
        From ClientCursor.Account       
        Where CompanyId=@CompanyId --And IsAccount=1 And Status=1       
        And Id=@AccountId      
      Update ClientCursor.Account Set SyncClientId=@ClientId,SyncClientDate=@GetDate,SyncClientStatus=@SyncStatusCompleted,SyncClientRemarks=null,ClientId=@ClientId Where Id=@AccountId And CompanyId=@CompanyId      
      --Insert Into ClientStatusChange      
      Insert Into WorkFlow.ClientStatusChange (Id,CompanyId,ClientId,State,ModifiedBy,ModifiedDate)      
       Values(NEWID(),@CompanyId,@ClientId,'Active',@UserCreatedOrModified,@GetDate)            
      --ContactDetails From Account      
      Begin      
       Set @IndCount=1      
       Set @Count=0      
       Insert into #Loc_Cont_Tbl      
       Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD      
       Inner Join ClientCursor.Account As A On A.Id=CD.EntityId      
       Inner Join Common.Contact As C On C.Id=CD.ContactId       
       Where A.CompanyId=@CompanyId And A.SyncClientId=@ClientId      
       Select @Count=count(*) From #Loc_Cont_Tbl      
       While @Count>=@IndCount      
       Begin      
        Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncClientId=DestId From #Loc_Cont_Tbl Where Id=@IndCount      
        If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)      
        Begin      
         Set @New_ContctDtlId=NewId()      
         Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,IsCopy)      
          Select @New_ContctDtlId,@ContactId,@SyncClientId,'Client',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'WF',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Account',IsCopy
  
    
 From Common.ContactDetails Where Id=@ContactDetailId      
        End      
        Else      
        Begin      
         Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A      
         Inner Join       
         (Select * From Common.ContactDetails Where EntityId=@AccountId And ContactId=@ContactId) As B On B.ContactId=A.ContactId      
         Where A.ContactId=@ContactId And A.EntityId=@SyncClientId      
        End      
        Set @IndCount=@IndCount+1      
       End      
       Truncate Table #Loc_Cont_Tbl      
      End       
      --ContactDetails From Client      
      Begin      
       Set @IndCount=1      
       Set @Count=0      
       Insert into #Loc_Cont_Tbl      
       Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncAccountId From Common.ContactDetails As CD      
       Inner Join WorkFlow.Client As A On A.Id=CD.EntityId      
       Inner Join Common.Contact As C On C.Id=CD.ContactId       
       Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And A.Id=@ClientId      
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
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncClientId From Common.Addresses As Adrs      
       Inner join ClientCursor.Account As A On A.Id=Adrs.AddTypeId       
       Where A.CompanyId=@CompanyId And A.SyncClientId=@ClientId      
       Select @AdrsCount=count(*) From #Loc_AdrsTbl      
       While @AdrsCount>=@IndCount      
       Begin      
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncClientId=DestId From #Loc_AdrsTbl Where Id=@IndCount      
        If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncClientId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)      
        Begin      
         Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)      
          Select NEWID(),AddSectionType,'Client',@AdrsSyncClientId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/      
        End      
        Set @IndCount=@IndCount+1      
       End      
       Truncate Table #Loc_AdrsTbl      
      End       
      --Addresses From Client      
      Begin      
       Set @IndCount=1      
       Insert into #Loc_AdrsTbl      
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncAccountId From Common.Addresses As Adrs      
       Inner join WorkFlow.Client As A On A.Id=Adrs.AddTypeId       
       Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And A.Id=@ClientId      
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
       Where A.EntityId In (Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncClientId=@ClientId)      
       Select @AdrsCount=count(*) From #Loc_AdrsTbl      
       While @AdrsCount>=@IndCount      
       Begin      
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount      
        Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId      
        If @ContactId Is Not null And @SyncAccountId Is Not Null      
        Begin      
         Set @SyncClientId=(Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)      
         If @SyncClientId Is Not Null      
         Begin      
          Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncClientId And ContactId=@ContactId      
          If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)      
          Begin      
           Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)      
            Select NEWID(),AddSectionType,'ClientContactDetailId',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/      
          End      
         End      
        End      
        Set @IndCount=@IndCount+1      
       End      
       Truncate Table #Loc_AdrsTbl      
      End       
      --ContactDetail From Client      
      Begin      
       Set @IndCount=1      
       Insert into #Loc_AdrsTbl      
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs      
       Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId       
       Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId Is Not Null And Id=@ClientId)      
       Select @AdrsCount=count(*) From #Loc_AdrsTbl      
       While @AdrsCount>=@IndCount      
       Begin      
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount      
        Select @ContactId=ContactId,@SyncClientId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId      
        If @ContactId Is Not null And @SyncClientId Is Not Null      
        Begin      
         Set @SyncAccountId=(Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And Id=@SyncClientId And SyncAccountId Is Not Null)      
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
      Update ClientCursor.Account Set SyncClientDate=@GetDate,SyncClientStatus=@SyncStatusFailed,SyncClientRemarks=@ErrMsg Where Id=@AccountId And CompanyId=@CompanyId      
     End Catch      
    End      
    Else      
    Begin      
     Exec [dbo].[Common_Sync_MasterData_Account_Client] @CompanyId,@AccountId,'Edit'      
    End      
   End      
          
   Else If(@Action='Edit')      
   Begin      
    --Edit      
    If Exists (Select Id From WorkFlow.Client Where SyncAccountId=@AccountId And CompanyId=@CompanyId)      
    Begin      
     Begin Try      
      Set @ClientId=(Select SyncClientId From ClientCursor.Account Where Id=@AccountId And CompanyId=@CompanyId)      
      --Update WorkFlow.Client table records based on SyncClientId which is edited in ClientCursor.Account table      
      Update C Set C.Name=A.Name,C.ClientTypeId=A.AccountTypeId,C.IdtypeId=A.AccountIdTypeId,C.ClientIdNo=A.AccountIdNo,C.TermsOfPaymentId=    
   A.TermsOfPaymentId,C.Industry=A.Industry,C.Source=A.Source,C.SourceId=A.SourceId,C.SourceName=A.SourceName,    
   C.SourceRemarks=A.SourceRemarks,C.IncorporationDate=A.IncorporationDate,      
        C.FinancialYearEnd=A.FinancialYearEnd,C.CountryOfIncorporation=A.CountryOfIncorporation,C.PrincipalActivities=    
  A.PrincipalActivities,C.RecOrder=A.RecOrder,C.Remarks=A.Remarks,C.ModifiedBy=@UserCreatedOrModified,C.ModifiedDate=@GetDate,    
  C.Version=A.Version,    
  C.Status=A.Status,      
       C.Communication=A.Communication,C.SyncAccountStatus=@SyncStatusUpdateCompleted,C.SyncAccountDate=@GetDate,    
    C.SyncAccountRemarks=null ,c.IndustryCode=a.IndustryCode--,C.ClientStatus=A.AccountStatus,   --,C.SystemRefNo=A.SystemRefNo      
      From WorkFlow.Client As C      
      Inner Join ClientCursor.Account As A On A.Id=C.SyncAccountId      
      Where A.CompanyId=@CompanyId And A.Id=@AccountId      
      
      ----Nikitha      
      
      if exists (select * from WorkFlow.CaseGroup where clientid in  (select id from workflow.client where SyncAccountId=@AccountId))      
      begin      
        update WorkFlow.CaseGroup set name = (select name from workflow.client where SyncAccountId=@AccountId) where clientid in  (select id from workflow.client where SyncAccountId=@AccountId)      
        update Common.TimeLogItem set SubType =(select name from workflow.client where SyncAccountId=@AccountId) where systemid in (select id from WorkFlow.CaseGroup where clientid in (select id from workflow.client where SyncAccountId=@AccountId))      
      end      
      
      
      
      --      
      Update ClientCursor.Account Set SyncClientDate=@GetDate,SyncClientStatus=@SyncStatusUpdateCompleted,SyncClientRemarks=Null Where Id=@AccountId And CompanyId=@CompanyId      
            
      /*--ContactDetails From Account      
      Begin      
       Set @IndCount=1      
       Set @Count=0      
       Insert into #Loc_Cont_Tbl      
       Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncClientId From Common.ContactDetails As CD      
       Inner Join ClientCursor.Account As A On A.Id=CD.EntityId      
       Inner Join Common.Contact As C On C.Id=CD.ContactId       
       Where A.CompanyId=@CompanyId And A.SyncClientId Is Not Null And A.SyncClientId=@ClientId      
       Select @Count=count(*) From #Loc_Cont_Tbl      
       While @Count>=@IndCount      
       Begin      
        Select @ContactDetailId=ContactDetailId,@ContactId=ContactId,@CDEntityId=EntityId,@SyncClientId=DestId From #Loc_Cont_Tbl Where Id=@IndCount      
        If Not Exists (Select Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@SyncClientId)      
        Begin      
         Set @New_ContctDtlId=NewId()      
         Insert Into Common.ContactDetails (Id,ContactId,EntityId,EntityType,Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,CursorShortCode,Status,UserCreated,CreatedDate,Remarks,DocId,DocType,Is
  
    
Copy)      
          Select @New_ContctDtlId,@ContactId,@SyncClientId,'Client',Designation,Communication,Matters,IsPrimaryContact,IsReminderReceipient,RecOrder,OtherDesignation,IsPinned,'WF',Status,@UserCreatedOrModified,@Getdate,Remarks,@CDEntityId,'Account',IsCopy
  
    
 From Common.ContactDetails Where Id=@ContactDetailId      
        End      
        Else      
        Begin      
         Update A Set A.Designation=B.Designation,A.Communication=B.Communication,A.IsPrimaryContact=B.IsPrimaryContact,A.Matters=B.Matters,A.RecOrder=B.RecOrder,A.Status=B.Status,A.IsReminderReceipient=B.IsReminderReceipient,ModifiedBy=@UserCreatedOrModi
  
    
fied,ModifiedDate=@GetDate,A.Remarks=B.Remarks,A.IsCopy=B.IsCopy From Common.ContactDetails As A      
         Inner Join       
         (Select * From Common.ContactDetails Where EntityId=@AccountId And ContactId=@ContactId) As B On B.ContactId=A.ContactId      
         Where A.ContactId=@ContactId And A.EntityId=@SyncClientId      
        End      
        Set @IndCount=@IndCount+1      
       End      
       Truncate Table #Loc_Cont_Tbl      
      End       
      --ContactDetails From Client      
      Begin      
       Set @IndCount=1      
       Set @Count=0      
       Insert into #Loc_Cont_Tbl      
       Select Distinct Cd.Id As ContactDetailId,CD.EntityType,CD.ContactId,CD.EntityId,A.SyncAccountId From Common.ContactDetails As CD      
       Inner Join WorkFlow.Client As A On A.Id=CD.EntityId      
       Inner Join Common.Contact As C On C.Id=CD.ContactId       
       Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And A.Id=@ClientId      
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
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncClientId From Common.Addresses As Adrs      
       Inner join ClientCursor.Account As A On A.Id=Adrs.AddTypeId       
       Where A.CompanyId=@CompanyId And A.SyncClientId=@ClientId      
       Select @AdrsCount=count(*) From #Loc_AdrsTbl      
       While @AdrsCount>=@IndCount      
       Begin      
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@AdrsSyncClientId=DestId From #Loc_AdrsTbl Where Id=@IndCount      
        If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@AdrsSyncClientId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)      
        Begin      
         Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)      
          Select NEWID(),AddSectionType,'Client',@AdrsSyncClientId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/      
        End      
        Set @IndCount=@IndCount+1      
       End      
       Truncate Table #Loc_AdrsTbl      
      End       
      --Addresses From Client      
      Begin      
       Set @IndCount=1      
       Insert into #Loc_AdrsTbl      
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.SyncAccountId From Common.Addresses As Adrs      
       Inner join WorkFlow.Client As A On A.Id=Adrs.AddTypeId       
       Where A.CompanyId=@CompanyId And A.SyncAccountId Is Not Null And A.Id=@ClientId      
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
       Where A.EntityId In (Select Id From ClientCursor.Account Where CompanyId=@CompanyId And SyncClientId=@ClientId)      
       Select @AdrsCount=count(*) From #Loc_AdrsTbl      
       While @AdrsCount>=@IndCount      
       Begin      
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount      
        Select @ContactId=ContactId,@SyncAccountId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId      
        If @ContactId Is Not null And @SyncAccountId Is Not Null      
        Begin      
         Set @SyncClientId=(Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId=@SyncAccountId And SyncAccountId Is Not Null)      
         If @SyncClientId Is Not Null      
         Begin      
          Select @CntDtlDestId=Id From Common.ContactDetails Where EntityId=@SyncClientId And ContactId=@ContactId      
          If Not Exists (Select Id From Common.Addresses Where Addsectiontype=@AddrsAddSecType And AddTypeId=@CntDtlDestId And AddressBookId=@AddressBookId/*And CompanyId=@CompanyId*/)      
          Begin      
           Insert Into Common.Addresses(Id,AddSectionType,AddType,AddTypeId,AddTypeIdInt,AddressBookId,Status,DocumentId,EntityId,ScreenName,IsCurrentAddress,CompanyId)      
            Select NEWID(),AddSectionType,'ClientContactDetailId',@CntDtlDestId,AddTypeIdInt,AddressBookId,Status,@AdrsEntityId,null,null,IsCurrentAddress,@CompanyId From Common.Addresses Where Id=@AddressId /*And CompanyId=@CompanyId*/      
          End      
         End      
        End      
        Set @IndCount=@IndCount+1      
       End      
       Truncate Table #Loc_AdrsTbl      
      End       
      --ContactDetail From Client      
      Begin      
       Set @IndCount=1      
       Insert into #Loc_AdrsTbl      
       Select Distinct Adrs.id As AddressId,Adrs.AddressBookId,Adrs.AddSectionType,Adrs.AddTypeId,A.EntityId From Common.Addresses As Adrs      
       Inner join Common.ContactDetails As A On A.Id=Adrs.AddTypeId       
       Where A.EntityId In (Select Id From WorkFlow.Client Where CompanyId=@CompanyId And SyncAccountId Is Not Null And Id=@ClientId)      
       Select @AdrsCount=count(*) From #Loc_AdrsTbl      
       While @AdrsCount>=@IndCount      
       Begin      
        Select @AddressId=AddressId,@AddressBookId=AddressBookId,@AddrsAddSecType=AddSectionType,@AdrsEntityId=AdrsEntityId,@CntdtlEntityId=DestId From #Loc_AdrsTbl Where Id=@IndCount      
        Select @ContactId=ContactId,@SyncClientId=EntityId From Common.ContactDetails Where Id=@AdrsEntityId      
        If @ContactId Is Not null And @SyncClientId Is Not Null      
        Begin      
         Set @SyncAccountId=(Select SyncAccountId From WorkFlow.Client Where CompanyId=@CompanyId And Id=@SyncClientId And SyncAccountId Is Not Null)      
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
	  print @UpdtErrMsg
      Update ClientCursor.Account Set SyncClientDate=@GetDate,SyncClientStatus=@SyncStatusUpdateFalied,SyncClientRemarks=@UpdtErrMsg Where Id=@AccountId And CompanyId=@CompanyId      
     End Catch      
    End      
   /* Else      
    Begin      
     Exec [dbo].[Common_Sync_MasterData_Account_Client] @CompanyId,@AccountId,'Add'      
    End */      
   End      
   Else If(@Action='Active' OR @Action='Inactive')      
   Begin      
    If Exists (Select Id From WorkFlow.Client Where SyncAccountId=@AccountId And CompanyId=@CompanyId)      
    Begin      
     Begin Try      
      Update WorkFlow.Client Set ClientStatus=@Action,Status = Case When @Action='Active' Then 1 When @Action='Inactive' Then 2 End ,ModifiedBy=@UserCreatedOrModified,ModifiedDate=@GetDate,SyncAccountDate=@GetDate,SyncAccountStatus=    
   @SyncStatusUpdateCompleted,SyncAccountRemarks=null Where CompanyId=@CompanyId And SyncAccountId=@AccountId      
      Insert Into WorkFlow.ClientStatusChange (Id,CompanyId,ClientId,State,ModifiedBy,ModifiedDate)      
         Values(Newid(),@CompanyId,(Select Id From WorkFlow.Client Where SyncAccountId=@AccountId And CompanyId=@CompanyId),@Action,@UserCreatedOrModified,@GetDate)      
      Update ClientCursor.Account Set SyncClientDate=@GetDate,SyncClientStatus=@SyncStatusUpdateCompleted,SyncClientRemarks=null Where CompanyId=@CompanyId And Id=@AccountId      
     End Try      
     Begin Catch      
      Declare @ActErrMsg Nvarchar(Max)      
      Set @ActErrMsg=(Select ERROR_MESSAGE())      
      Update ClientCursor.Account Set SyncClientDate=@GetDate,SyncClientStatus=@SyncStatusUpdateFalied,SyncClientRemarks=@ActErrMsg Where Id=@AccountId And CompanyId=@CompanyId      
     End Catch      
    End      
   End      
         
   Set @SystemRefnum=(Select Top(1) SystemRefNo From WorkFlow.Client Where CompanyId=@CompanyId And SystemRefNo Is not null Order By CreatedDate Desc)      
   Set @SystemRefnum=Reverse(SUBSTRING(Reverse(@SystemRefnum),0,PATINDEX('%[0-9][^0-9]%', Reverse(@SystemRefnum))+1))      
   Update Common.AutoNumber Set GeneratedNumber=@SystemRefnum Where CompanyId=@CompanyId And EntityType='WorkFlow Client' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor')      
    IF OBJECT_ID(N'tempdb..#Loc_Cont_Tbl') IS NOT NULL
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
   Set @Err_Msg=(Select  Error_Message()) 
   print @Err_Msg
   Raiserror(@Err_Msg,16,1)      
  End Catch      
 End      
End 
GO
