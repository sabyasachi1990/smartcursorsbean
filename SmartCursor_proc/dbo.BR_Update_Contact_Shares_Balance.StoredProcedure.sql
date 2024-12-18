USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Update_Contact_Shares_Balance]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Proc [dbo].[BR_Update_Contact_Shares_Balance] 
 @transcationId uniqueidentifier, @allotmentId uniqueidentifier, @transcationType nvarchar(300), @entityId uniqueidentifier
As 
Begin
Declare @ContactId uniqueidentifier
 Declare @DocumentId uniqueidentifier
 Declare @TransactionlogId uniqueidentifier
 Declare @contacttotalbalanceshares bigint
 Declare @ShareCertficate bigint
 Declare @NoOfShares bigint
 Declare @childTranType nvarchar(300)

Declare @ReissueTransactionLog table (TransactionId uniqueidentifier,TransactionlogId uniqueidentifier,AllotmentId uniqueidentifier,ContactId uniqueidentifier,TransactionType nvarchar(500),
NoOfShares int,DocumentId uniqueidentifier,ShareCertficate int,CreatedDate Datetime) 

Declare @CancelledTransactionLog table (TransactionId uniqueidentifier,TransactionlogId uniqueidentifier,AllotmentId uniqueidentifier,ContactId uniqueidentifier,TransactionType nvarchar(500),
NoOfShares int,DocumentId uniqueidentifier,ShareCertficate int,CreatedDate Datetime) 

Declare @AllotmentDetails Table(AllotmentId uniqueidentifier,ContactId uniqueidentifier,DocumentId uniqueidentifier,NoOfShares Bigint,ShareCertificate Bigint)

Insert Into @ReissueTransactionLog(TransactionId,TransactionlogId,AllotmentId,ContactId,TransactionType,NoOfShares,DocumentId,ShareCertficate,CreatedDate)
Select tl.TransactionId,tl.Id TransactionlogId,Tl.AllotmentId,tl.ContactId,tl.TransactionType,tl.NoOfShares,
Tl.DocumentId,tl.ShareCertficate,tl.CreatedDate from Boardroom.TransactionLog Tl 
where tl.TransactionId=@transcationId and  tl.NoOfShares >0 and
tl.ContactId is not null  and TransactionType not in ('Cancelled','Transfer Out') 
order by tl.ShareCertficate,tl.ContactId


Insert Into @CancelledTransactionLog(TransactionId,TransactionlogId,AllotmentId,ContactId,TransactionType,NoOfShares,DocumentId,ShareCertficate,CreatedDate)
Select tl.TransactionId,tl.Id TransactionlogId,Tl.AllotmentId,tl.ContactId,tl.TransactionType,tl.NoOfShares,
Tl.DocumentId,tl.ShareCertficate,tl.CreatedDate from Boardroom.TransactionLog Tl 
where tl.TransactionId=@transcationId and 
tl.ContactId is not null  and (TransactionType in ('Cancelled','Transfer Out') OR (@transcationType='Transfer In' And Nature in ('Transfer Out')))
order by tl.ContactId,tl.CreatedDate,tl.ShareCertficate




Insert Into @AllotmentDetails (AllotmentId,ContactId,DocumentId,NoOfShares,ShareCertificate)

Select a.Id,ad.ContactId,ad.Id,ad.NoOfShares,ad.ShareCertificate from Boardroom.Allotment as a 
inner join Boardroom.AllotmentDetails as ad on a.Id=ad.AllotmentId
where a.EntityId=@entityId And ad.Id not in (Select DocumentId from @ReissueTransactionLog as reissueLog) and ad.AllotmentId=@allotmentId




Declare balance Cursor for (Select TransactionlogId,ContactId,DocumentId,NoOfShares,ShareCertficate,TransactionType from @ReissueTransactionLog)
Open balance
Fetch Next From balance into @TransactionlogId,@ContactId,@DocumentId,@NoOfShares,@ShareCertficate,@childTranType
While @@FETCH_STATUS=0
Begin


Declare @allotmtDtilssum Bigint =ISNULL((Select SUM(NoOfShares) from @AllotmentDetails where ContactId in (@ContactId) And ShareCertificate <= @ShareCertficate),0)
--Declare @reissueSum Bigint =ISNULL((Select SUM(NoOfShares) from @ReissueTransactionLog where ContactId in (@ContactId) And ShareCertficate<@ShareCertficate),0)
Select @allotmtDtilssum As AllotmentdetailSum
  If((@transcationType='Allotment' OR @transcationType='Balance' OR @childTranType='Transfer In') )
  Begin
   Declare @reissueAllotmenttotal Bigint= IsNULL((Select Sum(NoOfShares) from @ReissueTransactionLog where ContactId in (@ContactId) And ShareCertficate <= @ShareCertficate),0)
   Select @allotmtDtilssum + @reissueAllotmenttotal As finaltotal
   Update Boardroom.TransactionLog set TotalBalance=  (@allotmtDtilssum + @reissueAllotmenttotal) where Id=@TransactionlogId
  End
 Else
  Begin
   
    Declare @reissueSum Bigint=ISNULL((Select Sum(NoOfShares) from @ReissueTransactionLog where ContactId in (@ContactId) and ShareCertficate <= @ShareCertficate),0)
	Declare @cancelsum Bigint=0
    Declare @cancellogcount bigint=(Select COUNT(*) from @CancelledTransactionLog)
    If(@cancellogcount > 0)
    Begin
     Set @cancelsum =ABS(ISNULL((Select SUM(cancellog.NoOfShares) from @CancelledTransactionLog as cancellog
                           join @ReissueTransactionLog as reissuelog on cancellog.DocumentId=reissuelog.DocumentId
                           where cancellog.ContactId in (@ContactId)  And reissuelog.ShareCertficate>@ShareCertficate),0))
   
   End
   Declare @totlSum bigint=(@allotmtDtilssum + @reissueSum + @cancelsum)
   Update Boardroom.TransactionLog set TotalBalance=@totlSum where Id=@TransactionlogId

  End
    

  
Fetch Next From balance into @TransactionlogId,@ContactId,@DocumentId,@NoOfShares,@ShareCertficate,@childTranType
End
close balance
Deallocate balance
End
GO
