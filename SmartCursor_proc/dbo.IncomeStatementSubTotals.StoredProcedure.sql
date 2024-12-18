USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[IncomeStatementSubTotals]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--exec [dbo].[IncomeStatementSubTotals] 'c7781ee8-5a71-4ee7-b0fe-a28d07970326',2156
CREATE Procedure [dbo].[IncomeStatementSubTotals](@enagagementId Uniqueidentifier,@companyId Bigint)
AS Begin
		 Declare @id1 uniqueidentifier=newid(),
		 @id2 uniqueidentifier=newid(),
		 @id3 uniqueidentifier=newid();

		--Category for Total Income
		INSERT INTO Audit.[Category]([Id],EngagementId,[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
			 VALUES  (@id1,@enagagementId,'Profit before tax','LeadSheet',1,1,null,'clr1',null ,1)

		--Subcategory for Total Income
		insert into Audit.SubCategory ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[ParentId],[IsIncomeStatement])
		select newid(),Leadsheetname,'00000000-0000-0000-0000-000000000000',1,'LeadSheet',@enagagementId,Id,@id1,1
		 from audit.leadsheet where companyid=@companyId and (LeadsheetType='income' or  LeadsheetType='expenses') and LeadSheetName!='Tax expense'and EngagementId=@enagagementId order by [Index]

		 --Category for Total Expenses
		INSERT INTO Audit.[Category]([Id],EngagementId,[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
			 VALUES  (@id2,@enagagementId,'Profit for the year','SubTotal',2,1,null,'clr2',null ,1)

		--Subcategory for Total Expenses
	     INSERT INTO Audit.SubCategory ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[ParentId],[IsIncomeStatement])
		select newid(),'Profit before tax','00000000-0000-0000-0000-000000000000',1,'SubTotal',@enagagementId,@id1,@id2,1
		 from audit.leadsheet where companyid=@companyId and LeadSheetName='Tax expense' and EngagementId=@enagagementId order by [Index]

		INSERT INTO Audit.SubCategory ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[ParentId],[IsIncomeStatement])
		select newid(),Leadsheetname,'00000000-0000-0000-0000-000000000000',1,'LeadSheet',@enagagementId,Id,@id2,1
		 from audit.leadsheet where companyid=@companyId and LeadSheetName='Tax expense' and EngagementId=@enagagementId order by [Index]



		--Main Total Net Profit

		 INSERT INTO Audit.[Category]([Id],EngagementId,[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
			 VALUES  (@id3,@enagagementId,'Total comprehensive income for the year','SubTotal',1,1,null,'clr3',null ,1)


		--main Totals Sub Category
		INSERT INTO Audit.[SubCategory] ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[ParentId],[IsIncomeStatement])
		VALUES (NEWID(),'Profit for the year','00000000-0000-0000-0000-000000000000',1,'SubTotal',@enagagementId,@id2,@id3,1)

		INSERT INTO Audit.[SubCategory] ([Id],[Name],[CategoryId],[Recorder],[Type],[EngagementId],[TypeId],[ParentId],[IsIncomeStatement])
		VALUES (NEWID(),'Other Comprehensive Income','00000000-0000-0000-0000-000000000000',15,'LeadSheet',@enagagementId,'C764974A-AB39-4352-99EF-066D7A5261C8',@id3,1)


		Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@enagagementId,'IncomeStatementSubTotalsInserted','Success',15)

	End
	
GO
