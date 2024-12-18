USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[TranscationLog_Mogration]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[TranscationLog_Mogration]
as
Begin
--Exec TranscationLog_Mogration
  Declare @logCreatedDate DateTime2(7),@translogId uniqueidentifier,@logIdorder bigint=1,@logNAture nvarchar(2000)
  If Exists(Select Id from [Boardroom].[Transaction] where ParentId is null)
  Begin
  Declare @transcationtype nvarchar(200),@transcationId uniqueidentifier,@logtype nvarchar(200)
  Declare Transcations cursor for (Select Id,TransactionType from [Boardroom].[Transaction] where ParentId is null and TransactionType in ('Redemption','Acquisition','Transfer Out','Transfer In')) order by TransactionDate
  Open Transcations
   FETCH NEXT FROM Transcations into @transcationId,@transcationtype
   WHILE @@FETCH_STATUS = 0
   Begin
   Declare TransLog Cursor for (Select Id,CreatedDate,TransactionType,Nature from [Boardroom].[TransactionLog] where TransactionId in (@transcationId) and ContactId Is not null)order by TransactionDate
   Open TransLog
   FETCH NEXT FROM TransLog into @translogId,@logCreatedDate,@logtype,@logNAture
   WHILE @@FETCH_STATUS = 0
   Begin       
         
          If(@logtype='Transfer Out' OR (@transcationtype='Transfer In' And @logNAture='Tranfer Out'))
		  Begin
		  
		    Update [Boardroom].[TransactionLog] set CreatedDate=DATEADD(millisecond,-1,@logCreatedDate) where CreatedDate Is not null and Id=@translogId
			Set @logIdorder = @logIdorder+1
		  End
		  Else if(@logtype='Cancelled' OR (@transcationtype='Transfer In' And @logNAture='Cancelled from Transfer Out'))
		  Begin
		    Update [Boardroom].[TransactionLog] set CreatedDate=DATEADD(millisecond,1,@logCreatedDate) where CreatedDate Is not null and Id=@translogId
			Set @logIdorder = @logIdorder+1
		  End
		  else 
		  Begin
		  Update [Boardroom].[TransactionLog] set CreatedDate=DATEADD(millisecond,2,@logCreatedDate) where CreatedDate Is not null and Id=@translogId
          Set @logIdorder = @logIdorder+1
		  End
       
      
	   FETCH NEXT FROM TransLog into @translogId,@logCreatedDate,@logtype,@logNAture
       END
   Close TransLog
   DEALLOCATE  TransLog
       
   FETCH NEXT FROM Transcations into @transcationId,@transcationtype
   END
   Close Transcations
   DEALLOCATE  Transcations
   
   End
 End
GO
