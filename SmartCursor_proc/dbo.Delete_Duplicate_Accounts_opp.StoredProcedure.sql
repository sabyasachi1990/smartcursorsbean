USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Delete_Duplicate_Accounts_opp]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure  [dbo].[Delete_Duplicate_Accounts_opp] ---------- exec Delete_Duplicate_Accounts_opp
as
begin 

Declare @companyId int=1,
        @AccountId Uniqueidentifier,
		@count Int
Declare AccountId_Get Cursor For
        Select Id from ClientCursor.Account where CompanyId=@companyId and IsAccount=1
Open AccountId_Get
fetch next from AccountId_Get Into @AccountId
While @@FETCH_STATUS=0

Begin

Select @count=COUNT(*) from ClientCursor.AccountStatusChange Where State='Active' and CompanyId=@companyId
If @count>1
Begin
--Select id,AccountId,State,ModifiedDate from ClientCursor.AccountStatusChange where CompanyId=@companyId and AccountId=@AccountId
Delete from ClientCursor.AccountStatusChange Where AccountId=@AccountId And State='Active' And 
       Id not in(Select top(1)id from clientcursor.AccountStatusChange where State='Active' and CompanyId=@companyId
       And AccountId=@AccountId order by ModifiedDate Asc)
End

fetch next from AccountId_Get Into @AccountId


End

Close AccountId_Get
Deallocate AccountId_Get


Declare
 ----@companyId int=1,
        @OpportunityId Uniqueidentifier----,
		---@count Int
Declare OpportunityId_Get Cursor For
        Select Id from ClientCursor.Opportunity where CompanyId=@companyId and STATUS=1
Open OpportunityId_Get
fetch next from OpportunityId_Get Into @OpportunityId
While @@FETCH_STATUS=0

Begin

Select @count=COUNT(*) from ClientCursor.OpportunityStatusChange Where State='Created' and CompanyId=@companyId
If @count>1
Begin
--Select id,AccountId,State,ModifiedDate from ClientCursor.AccountStatusChange where CompanyId=@companyId and AccountId=@AccountId
Delete from ClientCursor.OpportunityStatusChange Where OpportunityId=@OpportunityId And State='Created' And 
       Id not in(Select top(1)id from ClientCursor.OpportunityStatusChange where State='Created' and CompanyId=@companyId
       And OpportunityId=@OpportunityId order by ModifiedDate asc)
End

fetch next from OpportunityId_Get Into @OpportunityId


End

Close OpportunityId_Get
Deallocate OpportunityId_Get
end 
GO
