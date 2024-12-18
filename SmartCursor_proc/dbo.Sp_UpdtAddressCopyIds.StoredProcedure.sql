USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_UpdtAddressCopyIds]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[Sp_UpdtAddressCopyIds] @ContactId Uniqueidentifier
as begin
Declare 
       --@ContactId Uniqueidentifier,--='E6F620AF-C567-4AC6-A119-E3A65A5D1B7E',
        @Cont_DtlId Uniqueidentifier,
		@DocId Uniqueidentifier

Declare @Contact_DtlIdTbl Table(Id Uniqueidentifier)
--Declare First Cursor To get contactdetailid based on ContactId
Declare Cont_DtlIdCsr Cursor For
        Select Id,DocId from Common.ContactDetails where ContactId=@ContactId And IsCopy=1
Open Cont_DtlIdCsr-- First Cursor Open
Fetch Next From Cont_DtlIdCsr Into @Cont_DtlId,@DocId
While @@FETCH_STATUS=0
Begin
If @Cont_DtlId Not in (Select * From @Contact_DtlIdTbl)
Begin
-- Declare Second Cursor To get ContactId Address Details
Declare @AddSectiontype Nvarchar(Max),
        @ContactDtl_AddressId Uniqueidentifier,
		@DocumentId Uniqueidentifier
Declare Address_ContDtlCsr Cursor For
        Select AddSectionType,Id From Common.Addresses Where AddTypeId=@Cont_DtlId
Open Address_ContDtlCsr -- Open Second Cursor
Fetch Next From Address_ContDtlCsr Into @AddSectiontype,@ContactDtl_AddressId
While @@FETCH_STATUS=0
Begin
Declare @ContDtlId_DocContId Uniqueidentifier,
        @AddressId_ConDtl Uniqueidentifier
Begin

Select @ContDtlId_DocContId=Id From Common.ContactDetails Where ContactId=@ContactId And EntityId=@DocId

Select @AddressId_ConDtl=Id From Common.Addresses Where AddTypeId=@ContDtlId_DocContId And AddSectionType=@AddSectiontype

Update Common.Addresses Set CopyId=@AddressId_ConDtl Where Id=@ContactDtl_AddressId And AddSectionType=@AddSectiontype

Update Common.Addresses Set CopyId=@ContactDtl_AddressId Where Id=@AddressId_ConDtl And AddSectionType=@AddSectiontype

Insert Into @Contact_DtlIdTbl values(@ContDtlId_DocContId)

End

Fetch Next From Address_ContDtlCsr Into @AddSectiontype,@ContactDtl_AddressId
End

Close Address_ContDtlCsr -- Close Second Cursor
Deallocate Address_ContDtlCsr -- Deallocate Second Cursor
End
Fetch Next From Cont_DtlIdCsr Into @Cont_DtlId,@DocId
End

Close Cont_DtlIdCsr -- Close First Cursor
Deallocate Cont_DtlIdCsr -- Deallocate First Cursor
End
GO
