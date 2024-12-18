USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Update_Contact_Shares_Balance1]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[BR_Update_Contact_Shares_Balance1] 
 @transcationId uniqueidentifier, @allotmentId uniqueidentifier, @transcationType nvarchar(300), @entityId uniqueidentifier
As 
Begin

--Declare @transcationId uniqueidentifier='99b6f180-f544-44ba-bd70-98433a85bea2',
--@allotmentId uniqueidentifier='bf0a5628-910f-425f-b5be-bd1eaa55ea85', 
--@transcationType nvarchar(300)='Transfer In',
--@entityId uniqueidentifier='9a51b349-620e-4d5c-9422-3bb6cd157b9a'

 Declare  @prviustemp1  Table (prviuContactId uniqueidentifier,prviutotalbal bigint)
   Insert Into @prviustemp1(prviuContactId,prviutotalbal)
 (select tlog.ContactId,SUM(tlog.NoOfShares) from  Boardroom.TransactionLog as tlog
 where  tlog.AllotmentId=@allotmentId and 
tlog.ContactId is not null and tlog.TransactionId not in (@transcationId)
Group by tlog.contactId )



 Declare  @temp1  Table (LogId uniqueidentifier,NoofShares Bigint,ContactId uniqueidentifier,DocumentId Uniqueidentifier,CreateDate Datetime2(7),totalbal bigint,originalbalance Bigint,Nature Nvarchar(1000))

 Declare  @temp2  Table (temp2contactId uniqueidentifier,temp2totalbal bigint)
  Insert Into @temp1(LogId,NoofShares,ContactId,DocumentId,CreateDate,totalbal,originalbalance,Nature )
 (select tlog.Id,tlog.NoOfShares,tlog.ContactId,DocumentId,tlog.CreatedDate,0,tlog.TotalBalance,Nature from  Boardroom.TransactionLog as tlog
  where  tlog.ContactId is not null and   tlog.TransactionId in (@transcationId))


Declare @LogId uniqueidentifier,@NoofShares Bigint,@ContactId uniqueidentifier,@CreateDate DateTime2(7),
@totalBal Bigint,@documentId uniqueidentifier,@nature Nvarchar(1000)
Declare totalbal cursor for select LogId,NoofShares,ContactId,DocumentId,CreateDate,Nature from @temp1 order by CreateDate
Open totalbal
Fetch Next From totalbal into  @LogId,@NoofShares,@ContactId,@documentId,@CreateDate,@nature
While @@FETCH_STATUS=0
Begin

----find the contacts curnt balnce--

--Declare @curntBalance Bigint=ISNULL((select pre from @prviustemp1 where prviuContactId=@ContactId),0)
Declare @previusBal bigint =ISNULL((select prviutotalbal from @prviustemp1 where prviuContactId=@ContactId),0)
Set @totalBal=@previusBal+@NoofShares
If Not Exists(Select prviuContactId from @prviustemp1 where prviuContactId=@ContactId)
 Begin 
  
  Insert Into @prviustemp1(prviuContactId,prviutotalbal)
   (select @ContactId,@totalBal)

 End
Else
 Begin
 Update @prviustemp1 set prviutotalbal=@totalBal where prviuContactId=@ContactId

 End

 --Update @temp1 set totalbal=@totalBal where LogId=@LogId
Update Boardroom.TransactionLog set TotalBalance=@totalBal where Id=@LogId and TransactionType Not in ('Cancelled','Transfer Out')

If (@nature='Transfer Out')
  Begin
  Update Boardroom.TransactionLog set TotalBalance=(Select ABS(NoOfShares) from [Boardroom].[TransactionLog] where TransactionId in (@transcationId) 
  and ContactId=@ContactId and DocumentId=@documentId and TransactionType='Cancelled')
  where Id=@LogId and Nature in ('Transfer Out')
  End


Fetch Next From totalbal into  @LogId,@NoofShares,@ContactId,@documentId,@CreateDate,@nature
End
close  totalbal
Deallocate totalbal

End
GO
