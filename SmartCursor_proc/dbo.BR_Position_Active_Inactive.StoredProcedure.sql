USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Position_Active_Inactive]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[BR_Position_Active_Inactive] @transcationId uniqueidentifier,@contactIds nvarchar(Max)
as
Begin
  Declare @contactId nvarchar(200),@noofshares int
   Begin
    Declare allotmentdetailcontact cursor  for Select items  From [dbo].[SplitToTable] (@contactIds,',')  
    OPEN allotmentdetailcontact

    FETCH NEXT FROM allotmentdetailcontact into @contactId 
	While @@FETCH_STATUS=0
     Begin
	  If Exists(Select Id from Boardroom.AllotmentDetails where ContactId=Convert(uniqueidentifier,@contactId))
	   Begin
	      SET @noofshares=(select sum(NoOfShares)from Boardroom.AllotmentDetails where ContactId=Convert(uniqueidentifier,@contactId))
	       if(@noofshares>0)
	        Begin
		     update Boardroom.GenericContactDesignation set Status=1 where (Position='Corporate shareholder' or Position='Shareholder') and ContactId=Convert(uniqueidentifier,@contactId)
	        End
		Else
	         Begin
	       update Boardroom.GenericContactDesignation set Status=2 where (Position='Corporate shareholder' or Position='Shareholder') and ContactId=Convert(uniqueidentifier,@contactId)
	        End
		End
	  Else
	     Begin
	       update Boardroom.GenericContactDesignation set Status=2 where (Position='Corporate shareholder' or Position='Shareholder') and ContactId=Convert(uniqueidentifier,@contactId)
	    End
  
     FETCH NEXT FROM allotmentdetailcontact into @contactId
   END
  Close allotmentdetailcontact
  Deallocate  allotmentdetailcontact
 End
 End
 
GO
