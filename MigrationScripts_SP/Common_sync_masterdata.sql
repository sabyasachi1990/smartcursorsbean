USE SmartCursorSTG
GO

IF EXISTS ( Select 1 from sys.objects where name='Common_Sync_MasterData'AND type='P')
BEGIN
 Drop Proc Common_Sync_MasterData
END
GO
          
CREATE PROCEDURE [dbo].[Common_Sync_MasterData] (                
@CompanyId int,  
@Type nvarchar(50), --Service, Client, HREmployee etc..  
@SourceId Nvarchar(250),  
@Action nvarchar(20) -- Add,Edit,Delete,Active,Inactive               
 )                
AS                
BEGIN   
Declare @ServiceId Bigint,  
  @ClientId Uniqueidentifier,  
  @AccountId Uniqueidentifier,  
  @EntityId Uniqueidentifier,  
  @HREmpId Uniqueidentifier,  
  @SyncStatusCompleted varchar(20),  
  @UserCreatedOrModfd Varchar(10),  
  @GetDate DateTime2,  
  @SyncStatusUpdateCompleted varchar(20),  
  @SyncStatusFailed varchar(20),  
  @SyncStatusUpdateFalied varchar(20)  
 Set @UserCreatedOrModfd='System'  
 Set @GetDate=Getutcdate()  
 Set @SyncStatusCompleted='Completed'  
 Set @SyncStatusUpdateCompleted='UpdateCompleted'  
 Set @SyncStatusUpdateFalied='UpdateFailed'  
 Set @SyncStatusFailed='Failed'  
 BEGIN TRY                
  BEGIN TRAN                
	IF (@Type = 'Service')  
	 BEGIN  
	--// WorkFlow And Bean Should be activated for this company  
	  IF Exists (Select Id From Common.CompanyModule (nolock) Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster (nolock) Where Name='Workflow Cursor') And Status=1 And Exists (Select Id From Common.CompanyModule (nolock) Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster (nolock) Where Name='Bean Cursor') And Status=1 ))  
	  Begin  
	   Set @ServiceId=CAST(@SourceId As bigint)  
	   Exec [dbo].[Common_Sync_MasterData_Service_Item] @CompanyId, @ServiceId,@Action  
	  End  
	 END  
	ELSE IF (@Type = 'Account')  
	 BEGIN  
	  Set @AccountId=Cast(@SourceId As uniqueidentifier)  
	  If Exists (Select Id From Common.CompanyModule (nolock) Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster (nolock) Where Name='Workflow Cursor') And Status=1)  
	  Begin  
	   Exec [dbo].[Common_Sync_MasterData_Account_Client] @CompanyId, @AccountId,@Action  
  
			If Exists (Select Id From Common.CompanyModule (nolock) Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster (nolock) Where Name='Bean Cursor') And Status=1)  
			Begin
				Set @ClientId=(Select Id From WorkFlow.Client (nolock) Where SyncAccountId=@AccountId And CompanyId=@CompanyId) 
				 declare @syncEntityId uniqueIdentifier=(Select SyncEntityId From WorkFlow.Client (nolock) Where SyncAccountId=@AccountId And CompanyId=@CompanyId)
				 print @syncEntityId
				 if(@syncEntityId is not null)
				 Begin
					Exec [dbo].[Common_Sync_MasterData_Client_Entity] @CompanyId,@ClientId,@Action  
					--Update Sync Details in Entity And Account tables  
					Set @EntityId=(Select Id From Bean.Entity (nolock) Where CompanyId=@CompanyId And SyncClientId=@ClientId)  
					Update ClientCursor.Account Set SyncEntityId=@EntityId,SyncEntityStatus=Case When @Action='Add' Then @SyncStatusCompleted Else @SyncStatusUpdateCompleted End,SyncEntityDate=@GetDate,SyncEntityRemarks=null  
					 Where SyncClientId=@ClientId  
					Update E Set SyncAccountId=A.Id,SyncAccountDate=@GetDate,SyncAccountStatus=Case When @Action='Add' Then @SyncStatusCompleted Else @SyncStatusUpdateCompleted End,SyncAccountRemarks=null From Bean.Entity As E (nolock)  
					Inner Join ClientCursor.Account As A (nolock) On A.SyncEntityId=E.Id  
					Where E.CompanyId=@CompanyId And E.Id=@EntityId 
				End
			ELSE
				Begin  
				   Exec [dbo].[Common_Sync_MasterData_Account_Entity] @CompanyId,@AccountId,@Action  
				   --Update Sync Details in Entity And Account tables  
					Set @EntityId=(Select Id From Bean.Entity (nolock) Where CompanyId=@CompanyId And SyncClientId=@ClientId)  
					update WorkFlow.Client set SyncEntityId=@EntityId where id=@ClientId and CompanyId=@CompanyId
					Update ClientCursor.Account Set SyncEntityId=@EntityId,SyncEntityStatus=Case When @Action='Add' Then @SyncStatusCompleted Else @SyncStatusUpdateCompleted End,SyncEntityDate=@GetDate,SyncEntityRemarks=null  
					 Where SyncClientId=@ClientId  
					Update E Set SyncAccountId=A.Id,SyncAccountDate=@GetDate,SyncAccountStatus=Case When @Action='Add' Then @SyncStatusCompleted Else @SyncStatusUpdateCompleted End,SyncAccountRemarks=null From Bean.Entity As E (nolock)  
					Inner Join ClientCursor.Account As A (nolock) On A.SyncEntityId=E.Id  
					Where E.CompanyId=@CompanyId And E.Id=@EntityId 

				End 
			End
	  End
	Else If Exists (Select Id From Common.CompanyModule (nolock) Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster (nolock) Where Name='Bean Cursor') And Status=1)  
	Begin  
	   Exec [dbo].[Common_Sync_MasterData_Account_Entity] @CompanyId,@AccountId,@Action  
	  End  
	End  
	ELSE IF (@Type = 'Client')   
	 BEGIN  
	  Set @ClientId=Cast(@SourceId As uniqueidentifier)  
	  If Exists (Select Id From Common.CompanyModule (nolock) Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster (nolock) Where Name='Bean Cursor') And Status=1)  
	  Begin  
	   Exec [dbo].[Common_Sync_MasterData_Client_Entity] @CompanyId, @ClientId,@Action  
	   If Exists (Select Id From Common.CompanyModule (nolock) Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster (nolock) Where Name='Client Cursor') And Status=1)  
	   Begin  
		Exec [dbo].[Common_Sync_MasterData_Client_Account] @CompanyId,@ClientId,@Action  
		--Set @EntityId=(Select Id From Bean.Entity Where CompanyId=@CompanyId And SyncClientId=@ClientId)  
		Update E Set SyncAccountId=A.Id,SyncAccountDate=@GetDate,SyncAccountStatus=Case When @Action='Add' Then @SyncStatusCompleted Else @SyncStatusUpdateCompleted End,SyncAccountRemarks=null From Bean.Entity As E (nolock)  
		Inner Join ClientCursor.Account As A (nolock) On A.SyncClientId=E.SyncClientId  
		Where E.CompanyId=@CompanyId And E.SyncClientId=@ClientId  
  
		Update A Set SyncEntityId=E.Id,SyncEntityDate=@GetDate,SyncEntityStatus=Case When @Action='Add' Then @SyncStatusCompleted Else @SyncStatusUpdateCompleted End,SyncEntityRemarks=null From Bean.Entity As E (nolock)  
		Inner Join ClientCursor.Account As A (nolock) On A.SyncClientId=E.SyncClientId  
		Where E.CompanyId=@CompanyId And E.SyncClientId=@ClientId  
	   End  
	  End  
	  Else If Exists (Select Id From Common.CompanyModule (nolock) Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster (nolock) Where Name='Client Cursor') And Status=1)  
	  Begin  
	   Exec [dbo].[Common_Sync_MasterData_Client_Account] @CompanyId,@ClientId,@Action   
	  End  
	 End  
	ELSE IF (@Type = 'HREmployee')  
	 BEGIN  
	  If Exists (Select Id From Common.CompanyModule (nolock) Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster (nolock) Where Name='Bean Cursor') And Status=1)  
	  Begin  
	   Set @HREmpId=CAST(@SourceId As uniqueidentifier)  
	   Exec [dbo].[Common_Sync_MasterData_HREmployee_Entity] @CompanyId,@HREmpId,@Action  
	  End  
	 End  
	ELSE IF (@Type = 'Entity')  
	 BEGIN  
	  Set @EntityId=CAST(@SourceId As uniqueidentifier)  
	  If Exists (Select Id From Common.CompanyModule (nolock) Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster (nolock) Where Name='Workflow Cursor') And Status=1)  
	   Begin  
		--Call Entity To Client Sp  
		Exec [dbo].[Common_Sync_MasterData_Entity_Client] @CompanyId,@EntityId,@Action  
	   End  
	   If Exists (Select Id From Common.CompanyModule (nolock) Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster (nolock) Where Name='Client Cursor') And Status=1)  
	   Begin  
		--Call Entity To Account Sp  
		Exec [dbo].[Common_Sync_MasterData_Entity_Account] @CompanyId,@EntityId,@Action  
		-- Update SyncDetails  
		Update C Set SyncAccountId=A.Id,SyncAccountDate=@GetDate,SyncAccountStatus=Case When @Action='Add' Then @SyncStatusCompleted Else @SyncStatusUpdateCompleted End,SyncAccountRemarks=null   
		From WorkFlow.Client As C (nolock)  
		Inner Join ClientCursor.Account As A (nolock) On A.SyncEntityId=C.SyncEntityId  
		Where C.CompanyId=@CompanyId And C.SyncEntityId=@EntityId  
  
		Update A Set SyncClientId=C.Id,SyncClientDate=@GetDate,SyncClientStatus=Case When @Action='Add' Then @SyncStatusCompleted Else @SyncStatusUpdateCompleted End,SyncClientRemarks=null   
		From WorkFlow.Client As C (nolock)  
		Inner Join ClientCursor.Account As A (nolock) On A.SyncEntityId=C.SyncEntityId  
		Where C.CompanyId=@CompanyId And C.SyncEntityId=@EntityId  
	   End  
	  Else If Exists (Select Id From Common.CompanyModule (nolock) Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster (nolock) Where Name='Client Cursor') And Status=1)  
	  Begin  
	   --Call Entity To Account Sp  
	   Exec [dbo].[Common_Sync_MasterData_Entity_Account] @CompanyId,@EntityId,@Action  
	  End  
	 End  
  COMMIT TRAN                
 END TRY              
              
 BEGIN CATCH              
  SELECT ERROR_NUMBER() AS ErrorNumber              
   ,ERROR_SEVERITY() AS ErrorSeverity              
   ,ERROR_STATE() AS ErrorState              
   ,ERROR_PROCEDURE() AS ErrorProcedure              
   ,ERROR_LINE() AS ErrorLine              
   ,ERROR_MESSAGE() AS ErrorMessage;              
  ROLLBACK TRAN;              
 END CATCH;              
END