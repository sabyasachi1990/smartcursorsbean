USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Syncing_NotSaving_Accounts_Opportunity]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  Procedure  [dbo].[WF_Syncing_NotSaving_Accounts_Opportunity]
 @CompanyId BIGINT 
 AS
 BEGIN
 --=========================================== EXEC  WF_Syncing_NotSaving_Accounts_Opportunity 1 ============================================================================

Declare @WF_SYCING table ( Type Nvarchar(10), Id Uniqueidentifier,DesId Uniqueidentifier,Name Nvarchar(100),Number Nvarchar(100),STATE Nvarchar(50),CompanyId BIGINT,CreatedDate datetime2 )
Declare
@AccountId Uniqueidentifier,
@ClientId Uniqueidentifier,
@OpportunityId Uniqueidentifier,
@CaseId Uniqueidentifier
 --===================================================== // Declare First Cursor to get Account Details =======================================================================================================================================
Declare AccountId_Get Cursor For
		select id,ClientId from ClientCursor.Account where CompanyId=@companyId and IsAccount=1 AND STATUS=1
Open AccountId_Get
fetch next from AccountId_Get Into @AccountId,@ClientId
While @@FETCH_STATUS=0

Begin
If NOT Exists (select AccountId from WorkFlow.Client where CompanyId=@companyId AND AccountId=@AccountId )
	Begin
	If NOT Exists (select AccountId from WorkFlow.Client where CompanyId=@companyId AND Id=@ClientId )
		Begin

		Insert Into @WF_SYCING 

				SELECT 'Account',A.ID AS AccountId,ClientId,Name as 'Name',a.AccountId as AccountNumber ,AccountStatus,CompanyId,CreatedDate
				from ClientCursor.Account A WHERE A.CompanyId=@CompanyId AND Id=@AccountId AND A.IsAccount=1 AND Status=1
		end
	End	

	fetch next from AccountId_Get Into @AccountId,@ClientId 
	End
Close AccountId_Get
Deallocate AccountId_Get
--====================================================Declare Second Cursor to get Opportunity Details ===============================================================================================================================
	Begin
		Declare OpportunityId_Get Cursor For
			SELECT DISTINCT ID ,CASEID from ClientCursor.Opportunity WHERE CompanyId=@CompanyId AND Stage in('Won','Pending') AND STATUS=1 And (IsTemp IS NULL OR IsTemp=0)
		Open OpportunityId_Get
		fetch next from OpportunityId_Get Into @OpportunityId,@CaseId
		While @@FETCH_STATUS=0
		
		Begin
			If NOT Exists (SELECT DISTINCT OpportunityId from WorkFlow.CaseGroup WHERE CompanyId=@CompanyId AND OpportunityId=@OpportunityId)
			Begin
				If NOT Exists (SELECT DISTINCT OpportunityId from WorkFlow.CaseGroup WHERE CompanyId=@CompanyId AND Id=@CaseId )
				Begin
					Insert Into @WF_SYCING 
						SELECT 'Opportunity',ID AS OpportunityId,CaseId,Name as 'Name',OpportunityNumber,Stage,CompanyId,CreatedDate
						from ClientCursor.Opportunity WHERE CompanyId=@CompanyId AND ID=@OpportunityId AND Stage in('Won','Pending') AND STATUS=1 And (IsTemp IS NULL OR IsTemp=0)
				END
			END
			fetch next from OpportunityId_Get Into @OpportunityId,@CaseId
		End
		Close OpportunityId_Get
		Deallocate OpportunityId_Get
	End

select * from @WF_SYCING 
order by Type

end
GO
