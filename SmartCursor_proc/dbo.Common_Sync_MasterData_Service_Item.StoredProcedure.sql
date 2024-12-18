USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_Service_Item]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec  Common_Sync_MasterData_Service_Item 237,99900,'Add'
CREATE  PROCEDURE [dbo].[Common_Sync_MasterData_Service_Item]
	@CompanyId BigInt, 
	@ServiceId Bigint,
	@Action Varchar(50)
As
Begin
Declare @UserCreatedOrModfd Varchar(10),
		@GetDate DateTime2,
		@BaseCurrency varchar(20),
		@SyncStatusCompleted varchar(20),
		@SyncStatusUpdateCompleted varchar(20),
		@SyncStatusUpdateFalied varchar(20),
		@SyncStatusFailed varchar(20),
		@IsExternalData Int,
		@CustNature Varchar(20),
		@ItemId Uniqueidentifier
	Set @UserCreatedOrModfd='System'
	Set @GetDate=Getutcdate()
	Set @SyncStatusCompleted='Completed'
	Set @SyncStatusUpdateCompleted='UpdateCompleted'
	Set @SyncStatusUpdateFalied='UpdateFailed'
	Set @IsExternalData=1
	Set @SyncStatusFailed='Failed'
		
	--Begin Transaction
	Begin Transaction
	--Try Block For Whole Transaction
	Begin Try
		--If new record inserted in Common.Service table that time record must be inserted in bean.Item table with inserted service id as documentid	
		If(@Action='Add')
		Begin
			If Not Exists(Select Id From Bean.Item Where CompanyId=@CompanyId And SyncServiceId=@ServiceId)
			Begin
				Begin Try
					Set @ItemId=NEWID()
					Insert Into Bean.Item (Id,CompanyId,Code,COAId,Description,DefaultTaxcodeId,RecOrder,Remarks,UserCreated,CreatedDate,Version,Status,IsExternalData,SyncServiceId,SyncServiceStatus,SyncServicedate,SyncServiceRemarks,DocumentId)
						Select @ItemId,@CompanyId,Concat(Sg.code,S.Code),CoaId,S.Name,Case when S.IsGSTActivate =1 Then S.TaxCodeId Else Null End As TaxCodeId,S.RecOrder,S.Remarks,@UserCreatedOrModfd,@GetDate,S.Version,S.Status,1,@ServiceId,@SyncStatusCompleted,@GetDate,null,@ServiceId From Common.Service As S
						Inner Join Common.ServiceGroup As SG On SG.Id=S.ServiceGroupId
						Where S.Id=@ServiceId And S.CompanyId=@CompanyId
					Update Common.Service Set SyncItemId=@ItemId,SyncItemdate=@GetDate,SyncItemStatus=@SyncStatusCompleted,SyncItemRemarks=null Where Id=@ServiceId And CompanyId=@CompanyId
				End Try
				Begin Catch
					Declare @ErrMsg Nvarchar(max)
					Set @ErrMsg=(Select ERROR_MESSAGE())
					Update Common.Service Set SyncItemdate=@GetDate,SyncItemStatus=@SyncStatusFailed,SyncItemRemarks=@ErrMsg Where Id=@ServiceId And CompanyId=@CompanyId
				End Catch
			End
			Else
			Begin
				Exec [dbo].[Common_Sync_MasterData_Service_Item] @CompanyId,@ServiceId,'Edit'
			End
		End
		--Update bean.item table records based on documentid which is edited in common.service table	
		Else If(@Action='Edit')
		Begin
			--Edit
			If Exists (Select ID From Bean.Item Where SyncServiceId=@ServiceId And CompanyId=@CompanyId)
			Begin
				Begin Try

					Update I Set I.Code=Concat(Sg.code,s.Code),I.COAId=S.CoaId,I.ModifiedBy=@UserCreatedOrModfd,i.ModifiedDate=@GetDate,I.Version=S.Version,I.Status=S.Status,i.Remarks=s.Remarks,I.Description=S.Name,I.DefaultTaxcodeId=Case when S.IsGSTActivate =1 Then S.TaxCodeId Else Null End,I.IsExternalData=1,I.SyncServicedate=@GetDate,I.SyncServiceRemarks=null,I.SyncServiceStatus=@SyncStatusUpdateCompleted,I.SyncServiceId=S.Id
					From Bean.Item I
					Inner Join Common.Service S On S.SyncItemId = I.Id
					Inner Join Common.ServiceGroup As SG On SG.Id=S.ServiceGroupId
					Where S.Id= @ServiceId And I.CompanyId=@CompanyId
								
				End Try
				Begin catch
					Declare @UpdtErrMsg Nvarchar(Max)
					Set @ErrMsg=(Select ERROR_MESSAGE())
					Update Common.Service Set SyncItemdate=@GetDate,SyncItemStatus=@SyncStatusUpdateFalied,SyncItemRemarks=@UpdtErrMsg Where Id=@ServiceId And CompanyId=@CompanyId
				End Catch
			End
			--Else 
			--Begin
			--	Exec [dbo].[Common_Sync_MasterData_Service_Item] @CompanyId,@ServiceId,'Add'
			--End
		End
		Else If(@Action='Active' OR @Action='Inactive')
		Begin
			If Exists (Select Id From Bean.Item Where SyncServiceId=@ServiceId And CompanyId=@CompanyId)
			Begin
				Begin Try
					Update Bean.Item Set Status = Case When @Action='Active' Then 1 When @Action='Inactive' Then 2 End ,ModifiedBy=@UserCreatedOrModfd,ModifiedDate=@GetDate,SyncServicedate=@GetDate,SyncServiceStatus=@SyncStatusUpdateCompleted,SyncServiceRemarks=null Where SyncServiceId=@ServiceId And CompanyId=@CompanyId
					
				End Try
				Begin Catch
					Declare @ActErrMsg Nvarchar(Max)
					Set @ErrMsg=(Select ERROR_MESSAGE())
					Update Common.Service Set SyncItemdate=@GetDate,SyncItemStatus=@SyncStatusUpdateFalied,SyncItemRemarks=@ActErrMsg Where Id=@ServiceId And CompanyId=@CompanyId
				End Catch
			End
		End
		Commit Transaction
	End Try

	Begin Catch
		Rollback Transaction;
		Print Error_message()
	End Catch

End

GO
