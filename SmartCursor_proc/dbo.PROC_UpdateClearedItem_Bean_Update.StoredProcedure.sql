USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PROC_UpdateClearedItem_Bean_Update]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec [dbo].[PROC_UpdateClearedItem_Bean_Update] @Id='A787BD69-598F-4A45-A046-7C901E5247AA',@DocDate='2014-11-01 00:00:00.0000000',@CompanyId=1294
Create PROCEDURE [dbo].[PROC_UpdateClearedItem_Bean_Update](@Id UNIQUEIDENTIFIER,@DocDate DATETIME2,@CompanyId BIGINT)
AS
BEGIN 
 Declare @COAId table(Id bigint)
 Insert into @COAId
 Select Id
 From   Bean.ChartOfAccount 
 where  CompanyId=@CompanyId
 and    ModuleType='Bean' and Category='Balance Sheet'
 --Select * from @COAId

 UPDATE Bean.JournalDetail set ClearingStatus='Cleared',ClearingDate=@DocDate
 where  id in
 (
  Select   JD.Id
  From     Bean.Journal J
  Join     Bean.JournalDetail JD on JD.JournalId=J.Id
  where    CompanyId=@CompanyId and JD.DocumentId=@Id
  and      JD.COAId in(Select Id from @COAId)
 )
END;
GO
