USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SSISC_Codes_InsertAndUpdate]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SSISC_Codes_InsertAndUpdate]
As
Begin
Begin Transaction
Begin Try
    Declare @Code Nvarchar(200)
    Declare @Industry Nvarchar(4000)
    Declare @Err_Msg Nvarchar(4000)
    Declare CSR Cursor For
    Select Distinct [SSIC 2015 (Version 2018)],Industry From BR_SSICCode Where [SSIC 2015 (Version 2018)] Is Not Null 
    Open CSR
    Fetch Next From CSR Into @Code,@Industry
    While @@FETCH_STATUS=0
    Begin
        If Exists (Select Id From Boardroom.SSICCodes Where Code=@Code)
        Begin
            Update Boardroom.SSICCodes Set Industry=@Industry,Status=1 Where Code=@Code
        End 
        Else
        Begin
            Insert into Boardroom.SSICCodes (Id,Code,Industry,Status,CreatedDate,UserCreated,ModifiedBy,ModifiedDate,CompanyId)
            Values(NewId(),@Code,@Industry,1,GETDATE(),'System',Null,Null,0)
        End
        Fetch Next From CSR Into @Code,@Industry
    End
    Close CSR
    Deallocate CSR
    Commit Transaction
End Try
Begin catch
    Rollback
    Set @Err_Msg=(Select ERROR_MESSAGE())
    RaisError(@Err_Msg,16,1)

 

End Catch

 

End
GO
