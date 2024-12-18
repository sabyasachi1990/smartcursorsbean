USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_DeleteOBInvoiceAndOBBillLineItem]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[Proc_DeleteOBInvoiceAndOBBillLineItem](@OBId uniqueidentifier, @DocID uniqueidentifier, @CompanyId bigInt, @IsInvoice bit)
AS Begin
IF(@IsInvoice=1)
 BEGIN	
	IF Exists( select  * from Bean.Invoice where Id=@DocID and DocumentState='Not Paid' and CompanyId=@CompanyId and OpeningBalanceId= @OBId)
		BEGIN
			DELETE from Bean.InvoiceDetail where InvoiceId=@DocID 
			DELETE from Bean.Invoice where Id=@DocID and CompanyId=@CompanyId and OpeningBalanceId= @OBId and DocumentState='Not Paid'
		END
 END
	ELSE
		BEGIN
			IF EXISTS(select * from Bean.Bill where Id=@DocID and CompanyId=@CompanyId and OpeningBalanceId= @OBId and DocumentState='Not Paid' )
				BEGIN
					DELETE from Bean.BillDetail where BillId=@DocID 
					DELETE from Bean.Bill where Id=@DocID and CompanyId=@CompanyId and OpeningBalanceId= @OBId and DocumentState='Not Paid'
				END
	    END
 END
GO
