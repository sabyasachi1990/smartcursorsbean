USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PROC_ParkedJournal_DELETE]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



Create PROCEDURE [dbo].[PROC_ParkedJournal_DELETE](@Id UNIQUEIDENTIFIER, @IsGst bit)
AS
BEGIN 
IF(@IsGst = 1)
BEGIN
delete from Bean.JournalGSTDetail where JournalId=@Id
END
ELSE
BEGIN
DELETE from Bean.JournalDetail where JournalId=@Id
END;
END;

GO
