USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_Opportunity_Stage_and_History_Updated]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[Common_Sync_MasterData_Opportunity_Stage_and_History_Updated] 
@Id Varchar(max),
@ReasonForCancellation nvarchar(500), 
@Stage nvarchar(50),
@ModifiedBy nvarchar(500),
@ModifiedDate datetime2,
@Remarks nvarchar(500),
@CompanyId bigint

As
Begin

Declare @Item table (id uniqueidentifier)

Insert Into @Item
Select items from [dbo].[SplitToTable] (@id,',')

--select * from @Item

Declare Opp_Update Cursor For
Select * from @Item

Open Opp_Update
Fetch Next From Opp_Update Into @Id
      While @@FETCH_STATUS=0
				 BEGIN

				 if Exists(select id from ClientCursor.Opportunity where id=@Id)
				 Begin
				update  ClientCursor.Opportunity  set ReasonForCancellation=@ReasonForCancellation,Stage=Case When @Stage='Cancelled' then 'Cancelled' when @stage='Complete' Then 'Complete' END,
				ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate,Remarks=@Remarks,CompanyId=@CompanyId from ClientCursor.Opportunity where id=@id --and Companyid=@Companyid
			

				Insert into ClientCursor.OpportunityStatusChange
				select NEWID(),@Companyid,@id,@Stage,@ModifiedBy,@ModifiedDate from ClientCursor.Opportunity where id=@id --and Companyid=@Companyid

				------------------------------ Audit Logs---------------------------------------------------
				DECLARE @CaseId UNIQUEIDENTIFIER;
				SET @CaseId = (SELECT CaseId FROM ClientCursor.Opportunity WHERE Id =@Id)
				EXEC [dbo].[UpdateAuditSyncing] @Id, @CaseId, 'Success', @Stage, NULL, NULL, NULL, NULL, NULL, 'CC Opportunity','WF Cases';	
				------------------------------ Audit Logs---------------------------------------------------

                Fetch Next From Opp_Update Into @Id
				 END
				 END
				 
			 Close Opp_Update
			 Deallocate Opp_Update

			 END
GO
