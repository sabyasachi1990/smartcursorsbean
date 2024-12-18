USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Payroll_Delete]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--EXEC [dbo].[HR_Payroll_Delete] 'C2B1FBCD-FBC1-4BE2-BF1E-94E4FE00B0C2,E9A46C5F-81A1-4F6E-BF08-4D66B3254A0B,35B4283E-F488-4DE8-81E3-ED4829DFA9E8,56EC8586-38FD-43BE-9B48-F00F5D1BD18F,CD0F3C81-B520-4CCA-A456-DD814F75DB18,5E316FF9-E11D-4B60-8B9C-0BBFA8AD5FA4,2DAD6E88-A9F8-4548-9C80-29BEDDE3BB41,5BF768F8-0769-4C13-968A-460D396B9DE3,C66F2854-1480-4BA8-9D60-3114B8C6EA7A,2252734F-9895-4199-B656-08CC417021C8,6CD02677-8F3D-42EB-90EC-B8935D5508D0,71880FCE-9ACD-4EC5-99DB-6193008DCC57,DAEAFC39-5651-4AD7-B7BC-8064D571FDF3'
CREATE proc [dbo].[HR_Payroll_Delete]
@payrollIds NVARCHAR(MAX)
AS
BEGIN
--Local Variables
DECLARE @ErrorMessage NVARCHAR(4000)

	BEGIN TRY
	
	DECLARE @payrollId UNIQUEIDENTIFIER
	Declare BillDelete Cursor For Select items from dbo.SplitToTable(@payrollIds,',')
	Open BillDelete 
	Fetch Next From BillDelete Into @payrollId
	While @@FETCH_STATUS=0
    Begin

	IF EXISTS(Select DH.*
	from Bean.DocumentHistory DH
	Join Bean.Bill B on B.Id = DH.DocumentId where B.PayrollId = @payrollId)
	BEGIN
	Delete DH
	--Select DH.*
	from Bean.DocumentHistory DH
	Join Bean.Bill B on B.Id = DH.DocumentId where B.PayrollId = @payrollId
	END


	IF EXISTS(Select JD.*
	from Bean.JournalDetail JD
	JOIN Bean.Journal J on J.Id = JD.JournalId
	JOIN Bean.Bill B on J.DocumentId = B.Id where B.PayrollId =@payrollId)
	BEGIN
	Delete JD
	--Select JD.*
	from Bean.JournalDetail JD
	JOIN Bean.Journal J on J.Id = JD.JournalId
	JOIN Bean.Bill B on J.DocumentId = B.Id where B.PayrollId =@payrollId
	END


	IF EXISTS(Select J.*
	from Bean.Journal J
	JOIN Bean.Bill B on J.DocumentId = B.Id where B.PayrollId = @payrollId)
	BEGIN
	Delete J
	--Select J.*
	from Bean.Journal J
	JOIN Bean.Bill B on J.DocumentId = B.Id where B.PayrollId = @payrollId
	END

	IF EXISTS(Select Id.*
	from Bean.Bill I
	Join Bean.BillDetail ID on I.Id = ID.BillId
	where I.PayrollId = @payrollId)
	BEGIN
	Delete Id
	--Select Id.*
	from Bean.Bill I
	Join Bean.BillDetail ID on I.Id = ID.BillId
	where I.PayrollId = @payrollId
	END


	IF EXISTS(Select I.*
	from Bean.Bill I
	where I.PayrollId = @payrollId)
	BEGIN
	Delete I
	--Select I.*
	from Bean.Bill I
	where I.PayrollId = @payrollId
	END

	
	Fetch Next From BillDelete Into @payrollId
	END -- Cursor Loop End
	Close BillDelete
	Deallocate BillDelete
	
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
	END CATCH
END
GO
