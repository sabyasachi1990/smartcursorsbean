USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Allotment_Delete]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[BR_Allotment_Delete] @transcationId uniqueidentifier,@allotmentId uniqueidentifier
as
Declare @contactIds nvarchar(Max),@entityId uniqueidentifier
If Exists(select Id from Boardroom.[Transaction] where Id=@transcationId and AllotmentId=@allotmentId and  IsFirst=1 and ChangeTransId Is Null)
  Begin
  
 --Set @contactIds= Select +CONVERT(nvarchar(Max),Select Distinct(ContactId) from Boardroom.AllotmentDetails where AllotmentId=@allotmentId))
    SELECT @contactIds = COALESCE(@contactIds+',' ,'') + Cast(ContactId As varchar(250)) From Boardroom.AllotmentDetails where AllotmentId=(Select Id from Boardroom.Allotment where  Id=@allotmentId)
   	Delete Boardroom.TransactionLog where TransactionId=@transcationId
     Delete Boardroom.SharesCurrentDetails where TransactionId=@transcationId
	Delete Boardroom.[Transaction] where AllotmentId=@allotmentId
    Delete Boardroom.AllotmentDetails where AllotmentId=@allotmentId
    Delete Boardroom.Allotment where Id=@allotmentId
    Delete Common.DocRepository where TypeId=@transcationId
	Exec [dbo].[BR_Position_Active_Inactive] @transcationId,@contactIds
  End
 if Exists(select Id from Boardroom.[Transaction] where Id=@transcationId and AllotmentId=@allotmentId and  IsFirst=1 and ChangeTransId Is Not Null and ParentId is null)
  Begin
     
    SELECT @contactIds = COALESCE(@contactIds+',' ,'') + Cast(ContactId As varchar(250)) From Boardroom.AllotmentDetails where AllotmentId=(Select Id from Boardroom.Allotment where  Id=@allotmentId)
   	Delete Boardroom.TransactionLog where TransactionId=@transcationId
    Delete Boardroom.SharesCurrentDetails where TransactionId=@transcationId
	Delete Boardroom.[Transaction] where (Id=@transcationId or ParentId=@transcationId) and AllotmentId =@allotmentId
	Delete Boardroom.AllotmentDetails where AllotmentId=@allotmentId
    Update  Boardroom.Allotment Set Status=4 where Id=@allotmentId
    Delete Common.DocRepository where TypeId=@transcationId
	Exec [dbo].[BR_Position_Active_Inactive] @transcationId,@contactIds


  End
  
  

GO
