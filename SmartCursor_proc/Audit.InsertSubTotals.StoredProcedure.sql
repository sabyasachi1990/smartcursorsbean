USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Audit].[InsertSubTotals]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create Procedure [Audit].[InsertSubTotals](@EngagementId Uniqueidentifier)
As Begin
 BEGIN TRANSACTION
   BEGIN TRY 
		 Declare @id1 uniqueidentifier=newid(),
		 @id2 uniqueidentifier=newid(),
		 @id3 uniqueidentifier=newid();

		--Category for Total Income
		if not exists (select * from Audit.[Category] where name ='Profit before tax' and Type='LeadSheet' and EngagementId=@EngagementId)
		begin
			INSERT INTO Audit.[Category]([Id],EngagementId,[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
				 VALUES  (@id1,@EngagementId,'Profit before tax','LeadSheet',1,1,null,'clr1',null ,1)
		

			--Subcategory for Total Income
			insert into Audit.SubCategory ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[ParentId],[IsIncomeStatement])
			select newid(),Leadsheetname,'00000000-0000-0000-0000-000000000000',1,'LeadSheet',@EngagementId,Id,@id1,1
			 from audit.leadsheet where  (LeadsheetType='income' or  LeadsheetType='expenses') and LeadSheetName!='Tax expense'and EngagementId=@EngagementId order by [Index]
		 end
		 --Category for Total Expenses
		if not exists (select * from Audit.[Category] where name ='Profit for the year' and Type='SubTotal' and EngagementId=@EngagementId)
		begin
			INSERT INTO Audit.[Category]([Id],EngagementId,[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
				 VALUES  (@id2,@EngagementId,'Profit for the year','SubTotal',2,1,null,'clr2',null ,1)

			--Subcategory for Total Expenses
			 INSERT INTO Audit.SubCategory ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[ParentId],[IsIncomeStatement])
			select newid(),'Profit before tax','00000000-0000-0000-0000-000000000000',1,'SubTotal',@EngagementId,@id1,@id2,1
			 from audit.leadsheet where  LeadSheetName='Tax expense' and EngagementId=@EngagementId order by [Index]

			INSERT INTO Audit.SubCategory ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[ParentId],[IsIncomeStatement])
			select newid(),Leadsheetname,'00000000-0000-0000-0000-000000000000',1,'LeadSheet',@EngagementId,Id,@id2,1
			 from audit.leadsheet where  LeadSheetName='Tax expense' and EngagementId=@EngagementId order by [Index]

		 end

		--Main Total Net Profit
		if not exists (select * from Audit.[Category] where name ='Total comprehensive income for the year' and Type='SubTotal' and EngagementId=@EngagementId)
		begin
			 INSERT INTO Audit.[Category]([Id],EngagementId,[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
				 VALUES  (@id3,@EngagementId,'Total comprehensive income for the year','SubTotal',1,1,null,'clr3',null ,1)


			--main Totals Sub Category
			INSERT INTO Audit.[SubCategory] ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[ParentId],[IsIncomeStatement])
			VALUES (NEWID(),'Profit for the year','00000000-0000-0000-0000-000000000000',1,'SubTotal',@EngagementId,@id2,@id3,1)

			INSERT INTO Audit.[SubCategory] ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[ParentId],[IsIncomeStatement])
			VALUES (NEWID(),'Other Comprehensive Income','00000000-0000-0000-0000-000000000000',15,'LeadSheet',@EngagementId,'C764974A-AB39-4352-99EF-066D7A5261C8',@id3,1)

		end



		Declare @id4 uniqueidentifier=newid();
IF NOT EXISTS(select * from Audit.Category where Name='Total Assets' and EngagementId=@EngagementId)
Begin
INSERT INTO Audit.[Category]([Id],EngagementId,[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES  (@id4,@EngagementId,'Total Assets','LeadSheet',1,Null,null,'clr1',null ,1)
End


IF NOT EXISTS(select * from Audit.[SubCategory] where Name='Current Assets' and EngagementId=@EngagementId)
Begin	 
INSERT INTO Audit.[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
     VALUES (NEWID(),'Current Assets','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@EngagementId,'91021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id4,null,null,null,1)
End


IF NOT EXISTS(select * from Audit.[SubCategory] where Name='Non-current Assets' and EngagementId=@EngagementId)	
Begin
INSERT INTO Audit.[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
     VALUES (NEWID(),'Non-current Assets','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@EngagementId,'81021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id4,null,null,null,1)
End

--------

Declare @id5 uniqueidentifier=newid();
Begin
IF NOT EXISTS(select * from Audit.Category where Name='Liabilities' and EngagementId=@EngagementId)	
INSERT INTO Audit.[Category]([Id],[EngagementId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES  (@id5,@EngagementId,'Liabilities','LeadSheet',1,Null,null,'clr2',null ,1)
End


IF NOT EXISTS(select * from Audit.[SubCategory] where Name='Current Liabilities' and EngagementId=@EngagementId)	
Begin
INSERT INTO Audit.[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Current Liabilities','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@EngagementId,'71021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id5,null,null,null,1)
End


IF NOT EXISTS(select * from Audit.[SubCategory] where Name='Non-current Liabilities' and EngagementId=@EngagementId)	
Begin
INSERT INTO Audit.[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
     VALUES (NEWID(),'Non-current Liabilities','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@EngagementId,'61021766-F6F8-49FE-A230-66295B4BC3FB',null ,@id5,null,null,null,1)
End


Declare @id6 uniqueidentifier=newid();
IF NOT EXISTS(select * from Audit.Category where Name='Equity and Liabilities' and EngagementId=@EngagementId)	
Begin
INSERT INTO Audit.[Category]([Id],[EngagementId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
     VALUES  (@id6,@EngagementId,'Equity and Liabilities','SubTotal',2,Null,null,'clr5',null ,1)
End


IF NOT EXISTS(select * from Audit.[SubCategory] where Name='Equity' and EngagementId=@EngagementId)	
Begin
INSERT INTO Audit.[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Equity','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@EngagementId,'41021766-F6F8-49FE-A230-66295B4BC3FB'
           ,null ,@id6,null,null,null,1)
End



IF NOT EXISTS(select * from Audit.[SubCategory] where Name='Liabilities' and EngagementId=@EngagementId)	
Begin
INSERT INTO Audit.[SubCategory]  ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
[ColorCode],[AccountClass],[IsCollapse])
     VALUES (NEWID(),'Liabilities','00000000-0000-0000-0000-000000000000',2,'SubTotal',@EngagementId,(select Id  from Audit.Category where Name='Liabilities' and EngagementId=@EngagementId),null ,@id6,null,null,null,1)
End



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
