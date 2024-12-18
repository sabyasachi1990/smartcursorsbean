USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Changesredirectparams]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Changesredirectparams]
AS
Begin
declare @id uniqueidentifier,@changein nvarchar(Max),@changesId nvarchar(Max)
declare entityChanges cursor for Select Id,changeIn from Boardroom.Changes where EntityId in (select Id from Common.EntityDetail where companyId=689)   and Changein='Notice of Place Where Register of Members and Index is Kept'
 Open entityChanges
    FETCH NEXT FROM entityChanges into @id,@changein
    WHILE @@FETCH_STATUS = 0
    Begin
	   if Exists(select Id from Boardroom.Changes where Id=@id)
	   Begin
	    set @changesId=Convert(nvarchar(50),@id)
	     Declare @redirectparam nvarchar(Max)
		 	    set @redirectparam= Concat('{"id":"',@changesId,'","changeIn":"',@changein,'"}')
	     Update Boardroom.Changes set RedirectUrlParams=@redirectparam where Id=@id
	    End
   
	 FETCH NEXT FROM entityChanges into @id,@changein
   End
   close entityChanges
   DEALLOCATE  entityChanges
End
GO
