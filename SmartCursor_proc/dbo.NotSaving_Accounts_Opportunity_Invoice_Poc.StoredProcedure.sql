USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[NotSaving_Accounts_Opportunity_Invoice_Poc]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure  [dbo].[NotSaving_Accounts_Opportunity_Invoice_Poc]
 @CompanyId BIGINT 
 AS
 BEGIN
  -------EXEC  NotSaving_Accounts_Opportunity_Invoice_Poc 1

 --===================================================== Account Details =======================================================================================================================================
SELECT  A.ID AS AccountId,a.AccountId as AccountNumber ,ClientId,AccountStatus,CompanyId,CreatedDate,AccountTypeId,AccountIdTypeId,AccountIdNo,AddressBookId,Name as 'Name' 
     from ClientCursor.Account A WHERE A.CompanyId=@CompanyId AND A.IsAccount=1 AND Status=1 AND 
     A.ID  NOT IN (SELECT DISTINCT  C.AccountId  FROM WorkFlow.Client C WHERE C.CompanyId=@CompanyId)

--====================================================== Opportunity Details ===============================================================================================================================
SELECT  ID AS OpportunityId,OpportunityNumber,CaseId,AccountId,CreatedDate,Type,Stage,Nature
     from ClientCursor.Opportunity WHERE CompanyId=@CompanyId AND Stage in('Won','Pending')  AND STATUS=1 And (IsTemp  IS NULL OR IsTemp=0)  AND
     ID  NOT IN (SELECT DISTINCT OpportunityId from WorkFlow.CaseGroup WHERE CompanyId=@CompanyId)

--====================================================== Invoice Details ===============================================================================================================================
 SELECT id as InvId,DocumentId,Number as InvNumber,CaseId,State,InvDate,CreatedDate,ModifiedDate
    FROM WorkFlow.Invoice where CompanyId=@CompanyId and  
    DocumentId not in (Select Id from Bean.invoice where companyid=@CompanyId)


 --=========================================== EXEC  NotSaving_Accounts_Opportunity 1 ============================================================================

Declare @WF_SYCING table ( Type Nvarchar(10), Id Uniqueidentifier,DesId Uniqueidentifier,Name Nvarchar(100),Number Nvarchar(100),STATE Nvarchar(50),CompanyId BIGINT,CreatedDate datetime2 )
Declare
@AccountId Uniqueidentifier,
@ClientId Uniqueidentifier,
@OpportunityId Uniqueidentifier,
@CaseId Uniqueidentifier,
 @InvId Uniqueidentifier,
@DocumentId Uniqueidentifier
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
--====================================================Declare third Cursor to get Invoice Details ===============================================================================================================================
begin

Declare InvId_Get Cursor For
  SELECT id ,DocumentId FROM WorkFlow.Invoice where CompanyId=@CompanyId and  
    DocumentId not in (Select Id from Bean.invoice where companyid=@CompanyId)
Open InvId_Get
fetch next from InvId_Get Into @InvId,@DocumentId
While @@FETCH_STATUS=0

Begin
If NOT Exists (Select DISTINCT  Id from Bean.invoice where companyid=@CompanyId AND DocumentId=@InvId)
Begin
If NOT Exists (Select DISTINCT  Id from Bean.invoice where companyid=@CompanyId AND Id=@DocumentId )
Begin
Insert Into @WF_SYCING  

 SELECT 'Invoice',id as InvId,DocumentId,'Invoice',Number as InvNumber,State,CompanyId,InvDate
    FROM WorkFlow.Invoice where CompanyId=@CompanyId and Id=@InvId
	 END
	 END
fetch next from InvId_Get Into @InvId,@DocumentId
End
Close InvId_Get
Deallocate InvId_Get
end

select * from @WF_SYCING 
order by Type 

end
end
GO
