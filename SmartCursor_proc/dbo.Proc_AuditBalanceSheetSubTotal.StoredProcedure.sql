USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AuditBalanceSheetSubTotal]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Proc_AuditBalanceSheetSubTotal] (@EngagementId uniqueidentifier)
As Begin
 BEGIN TRANSACTION
   BEGIN TRY 

Declare @id1 uniqueidentifier=newid();
IF NOT EXISTS(select * from Audit.Category where Name='Total Assets' and EngagementId=@EngagementId)
Begin
INSERT INTO Audit.[Category]([Id],EngagementId,[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES  (@id1,@EngagementId,'Total Assets','LeadSheet',1,Null,null,'clr1',null ,1)
End


IF NOT EXISTS(select * from Audit.[SubCategory] where Name='Current Assets' and EngagementId=@EngagementId)
Begin	 
INSERT INTO Audit.[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
     VALUES (NEWID(),'Current Assets','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@EngagementId,'91021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id1,null,null,null,1)
End


IF NOT EXISTS(select * from Audit.[SubCategory] where Name='Non-current Assets' and EngagementId=@EngagementId)	
Begin
INSERT INTO Audit.[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
     VALUES (NEWID(),'Non-current Assets','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@EngagementId,'81021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id1,null,null,null,1)
End

--------

Declare @id2 uniqueidentifier=newid();
Begin
IF NOT EXISTS(select * from Audit.Category where Name='Liabilities' and EngagementId=@EngagementId)	
INSERT INTO Audit.[Category]([Id],[EngagementId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES  (@id2,@EngagementId,'Liabilities','LeadSheet',1,Null,null,'clr2',null ,1)
End


IF NOT EXISTS(select * from Audit.[SubCategory] where Name='Current Liabilities' and EngagementId=@EngagementId)	
Begin
INSERT INTO Audit.[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Current Liabilities','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@EngagementId,'71021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id2,null,null,null,1)
End


IF NOT EXISTS(select * from Audit.[SubCategory] where Name='Non-current Liabilities' and EngagementId=@EngagementId)	
Begin
INSERT INTO Audit.[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
     VALUES (NEWID(),'Non-current Liabilities','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@EngagementId,'61021766-F6F8-49FE-A230-66295B4BC3FB',null ,@id2,null,null,null,1)
End


Declare @id3 uniqueidentifier=newid();
IF NOT EXISTS(select * from Audit.Category where Name='Equity and Liabilities' and EngagementId=@EngagementId)	
Begin
INSERT INTO Audit.[Category]([Id],[EngagementId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES  (@id3,@EngagementId,'Equity and Liabilities','SubTotal',2,Null,null,'clr5',null ,1)
End


IF NOT EXISTS(select * from Audit.[SubCategory] where Name='Equity' and EngagementId=@EngagementId)	
Begin
INSERT INTO Audit.[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Equity','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@EngagementId,'41021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id3,null,null,null,1)
End



IF NOT EXISTS(select * from Audit.[SubCategory] where Name='Liabilities' and EngagementId=@EngagementId)	
Begin
INSERT INTO Audit.[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Liabilities','00000000-0000-0000-0000-000000000000',2,'SubTotal',@EngagementId,(select Id  from Audit.Category where Name='Liabilities' and EngagementId=@EngagementId),null ,@id3,null,null,null,1)
End

     Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@EngagementId,'AuditBalanceSheetSubTotalInserted','Success',14)


 BEGIN 
      COMMIT TRANSACTION
    END
   END TRY

   BEGIN CATCH
        DECLARE
        @ErrorMessage NVARCHAR(4000),
        @ErrorSeverity INT,
        @ErrorState INT;
        SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
    ROLLBACK TRANSACTION
    END CATCH
END
GO
