USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Contact_Balance]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[BR_Contact_Balance] @transactionId uniqueidentifier ,@allotmentId uniqueidentifier
as
Begin
Declare @childTransId uniqueidentifier,@contactId uniqueidentifier,@documentId uniqueidentifier,
@childTranstype nvarchar(300),@parentTranstype nvarchar(200),@transDate DateTime2(7),@prvsTransType nvarchar(400),@totalBalShares BigInt,@shareCert Bigint,@TranscreatdDate Datetime2(7)
Declare @curnttransctiontemp table (CurntTransId uniqueidentifier,CurntCntctId uniqueidentifier,CurntDocId uniqueidentifier,CurntShares Bigint,CurntTranstype Nvarchar(500),CurntTranscrtdDate Datetime2(7),CurrentShareCert Bigint) 
If Exists(Select Id from [Boardroom].[Transaction] where Id=@transactionId  and IsFirst!=1)
  Begin 
    Set @parentTranstype=(Select TransactionType from [Boardroom].[Transaction] where Id=@transactionId)
	Set @transDate=(Select TransactionDate from [Boardroom].[Transaction] where Id=@transactionId)
	--Set @prvsTransType=(select Top 1(TransactionType) from [Boardroom].[Transaction] where Id!=@transactionId and DocumentId=@allotmentId and ParentId Is NULL and TransactionDate <= @transDate order by TransactionDate Desc)
  
	Insert Into @curnttransctiontemp (CurntTransId,CurntCntctId,CurntDocId,CurntShares,CurntTranstype,CurrentShareCert)
	(Select Id,ContactId,DocumentId,NoOfShares,TransactionType,ShareCertificate from [Boardroom].[Transaction] where ParentId=@transactionId) order by CreatedDate,ShareCertificate
	
	Declare balance Cursor For (Select CurntTransId,CurntCntctId,CurntDocId,CurntTranstype,CurrentShareCert from  @curnttransctiontemp) 
    Open balance
    FETCH NEXT FROM balance into @childTransId,@contactId,@documentId,@childTranstype,@sharecert
    While @@FETCH_STATUS=0
    Begin
     IF (@parentTranstype='Allotment' OR @childTranstype='TransferIn')
	     
	     Begin 
		   Set @totalBalShares = (Select Top 1 CurntShares from @curnttransctiontemp where CurntTransId!=@childTransId and CurntCntctId=@contactId and CurrentShareCert < @shareCert order by CurntTranscrtdDate,CurrentShareCert) 
		   Select @totalBalShares
		   IF(@totalBalShares =0 Or @totalBalShares Is NUll)
		   Begin
			  Set @totalBalShares = (Select Top 1 BalanceShares from [Boardroom].[Transaction] where AllotmentId=@allotmentId  and ContactId=@contactId and ShareCertificate < @shareCert  order by CreatedDate)
		     IF(@totalBalShares =0 Or @totalBalShares Is NUll)
			   Update [Boardroom].[Transaction] Set BalanceShares =(select Noofshares from [Boardroom].[Transaction] where Id=@childTransId) where Id=@childTransId
		      Else
			   Update [Boardroom].[Transaction] Set BalanceShares =@totalBalShares + (select Noofshares from [Boardroom].[Transaction] where Id=@childTransId) where Id=@childTransId
		   End
		   Else
		   Begin
	         Set @totalBalShares= @totalBalShares + (select NoOfShares from [Boardroom].[Transaction] where Id=@childTransId)
	         Update [Boardroom].[Transaction] Set BalanceShares=@totalBalShares where Id=@childTransId	      
          End 
         End
	 Else
	   Begin 
		   Set @totalBalShares = (Select Top 1 CurntShares from @curnttransctiontemp where CurntTransId!=@childTransId and CurntCntctId=@contactId and CurrentShareCert < @shareCert order by CurntTranscrtdDate,CurrentShareCert) 
		   Select @totalBalShares
		   IF(@totalBalShares =0 Or @totalBalShares Is NUll)
		   Begin
			  Set @totalBalShares = (Select Top 1 BalanceShares from [Boardroom].[Transaction] where AllotmentId=@allotmentId  and ContactId=@contactId and ShareCertificate < @shareCert  order by CreatedDate)
		     IF(@totalBalShares =0 Or @totalBalShares Is NUll)
			   Update [Boardroom].[Transaction] Set BalanceShares =(select Noofshares from [Boardroom].[Transaction] where Id=@childTransId) where Id=@childTransId
		      Else
			   Update [Boardroom].[Transaction] Set BalanceShares =@totalBalShares - (select Noofshares from [Boardroom].[Transaction] where Id=@childTransId) where Id=@childTransId
		   End
		   Else
		   Begin
	         Set @totalBalShares= @totalBalShares - (select NoOfShares from [Boardroom].[Transaction] where Id=@childTransId)
	         Update [Boardroom].[Transaction] Set BalanceShares=@totalBalShares where Id=@childTransId	      
          End 
         End


	   		     
    FETCH NEXT FROM balance into @childTransId,@contactId,@documentId,@childTranstype,@sharecert
	End
    Close balance
    Deallocate balance
    
  End
   Else
   Begin 
    Insert Into @curnttransctiontemp (CurntTransId,CurntCntctId,CurntDocId,CurntShares,CurntTranstype,CurntTranscrtdDate,CurrentShareCert)
	(Select Id,ContactId,DocumentId,NoOfShares,TransactionType,CreatedDate,ShareCertificate from [Boardroom].[Transaction] where ParentId=@transactionId) order by CreatedDate,ShareCertificate
	Declare altmntbalance Cursor For (Select CurntTransId,CurntCntctId,CurntDocId,CurrentShareCert from @curnttransctiontemp) order by CurntTranscrtdDate,CurrentShareCert
    Open altmntbalance
    FETCH NEXT FROM altmntbalance into @childTransId,@contactId,@documentId,@shareCert
    While @@FETCH_STATUS=0
    Begin   
	 
      Set @totalBalShares = (Select Top 1 CurntShares from @curnttransctiontemp where CurntTransId!=@childTransId and CurntCntctId=@contactId and CurrentShareCert < @shareCert order by CurntTranscrtdDate,CurrentShareCert) 
	  If(@totalBalShares=0 OR @totalBalShares Is Null)
	  Begin
	   Set @totalBalShares = (Select CurntShares from @curnttransctiontemp where CurntTransId=@childTransId) 
	   Update [Boardroom].[Transaction] Set BalanceShares=@totalBalShares where Id=@childTransId
	  End
	 Else
	 Begin
	  Set @totalBalShares= @totalBalShares + (select NoOfShares from [Boardroom].[Transaction] where Id=@childTransId)
	  Update [Boardroom].[Transaction] Set BalanceShares=@totalBalShares where Id=@childTransId
	  --Set @totalBalShares = (Select Top 1 CurntShares from @curnttransctiontemp where CurntTransId!=@childTransId and CurntCntctId=@contactId  order by CurntTranscrtdDate,CurrentShareCert) 
      
    End    		     
    FETCH NEXT FROM altmntbalance into @childTransId,@contactId,@documentId,@shareCert
	End
    Close altmntbalance
    Deallocate altmntbalance

   End

End
GO
