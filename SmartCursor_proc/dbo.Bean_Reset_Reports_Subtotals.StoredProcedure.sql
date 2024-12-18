USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Reset_Reports_Subtotals]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Bean_Reset_Reports_Subtotals] (@NEW_COMPANY_ID bigint,@screenName Nvarchar(150))
AS
BEGIN
	IF(@screenName ='Income Statement')
		BEGIN
--delete old seed data
			delete from Bean.Category where IsIncomeStatement=1 and CompanyId=@NEW_COMPANY_ID
			delete from Bean.SubCategory where IsIncomeStatement=1 and CompanyId=@NEW_COMPANY_ID
			delete from Bean.[Order] where LeadSheetType='Income Statement' and CompanyId=@NEW_COMPANY_ID
			update Bean.ChartOfAccount set FRRecOrder=null,CategoryId=null,SubCategoryId=null where Category='Income Statement' and CompanyId=@NEW_COMPANY_ID
			-- insert new seed data
			------------------GrossProfit
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[Category] WHERE Name='Gross Profit' and CompanyId=@NEW_COMPANY_ID )
			BEGIN 
			
			INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement], [LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
			VALUES
			(NEWID(),@NEW_COMPANY_ID,'Gross Profit','LeadSheet',1,1,null,'clr1',null,null)
			END
			END;
			-------------------Profit before Tax
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[Category] WHERE Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement], [LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
			VALUES
			(NEWID(),@NEW_COMPANY_ID,'Profit before Tax','SubTotal',2,1,null,'clr2',null,null)
			END
			END;
			-------------------Profit after Tax
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[Category] WHERE Name='Profit after Tax' and CompanyId=@NEW_COMPANY_ID )
			BEGIN 
			
			INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement], [LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
			VALUES
			(NEWID(),@NEW_COMPANY_ID,'Profit after Tax','SubTotal',2,1,null,'clr3',null,null)
			END
			END;
			----------------Income Statement --Seed Data for SubCategory
			------------------GrossProfit--Revenue
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Gross Profit' and CompanyId=@NEW_COMPANY_ID) and Name='Revenue' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Revenue','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Revenue'),'',(Select Id From [Bean].[Category]Where Name='Gross Profit' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------GrossProfit--Direct costs
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Gross Profit' and CompanyId=@NEW_COMPANY_ID) and Name='Direct costs' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Direct costs','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Direct costs'),'',(Select Id From [Bean].[Category]Where Name='Gross Profit' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			-----------------Profit before Tax-----GrossProfit
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Gross Profit' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Gross Profit','00000000-0000-0000-0000-000000000000',1,'SubTotal',@NEW_COMPANY_ID,(Select Id From [Bean].[Category] Where CompanyId=@NEW_COMPANY_ID and Name='Gross Profit'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit before Tax--Operating expenses
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Operating expenses' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Operating expenses','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Operating expenses'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit before Tax--Exchange gain/loss
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Exchange gain/loss' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Exchange gain/loss','00000000-0000-0000-0000-000000000000',3,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Exchange gain/loss'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit before Tax--Rounding
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Rounding' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Rounding','00000000-0000-0000-0000-000000000000',4,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Rounding'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit before Tax--Other expenses
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Other expenses' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Other expenses','00000000-0000-0000-0000-000000000000',4,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Other expenses'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit before Tax--Other income
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Other income' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Other income','00000000-0000-0000-0000-000000000000',5,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Other income'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit before Tax--General and admin expenses
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='General and admin expenses' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'General and admin expenses','00000000-0000-0000-0000-000000000000',6,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='General and admin expenses'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit before Tax--Sales and marketing expenses
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Sales and marketing expenses' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Sales and marketing expenses','00000000-0000-0000-0000-000000000000',7,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Sales and marketing expenses'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit before Tax--Amortisation
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Amortisation' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Amortisation','00000000-0000-0000-0000-000000000000',8,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Amortisation'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit before Tax--Depreciation
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Depreciation' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Depreciation','00000000-0000-0000-0000-000000000000',9,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Depreciation'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit before Tax--Interest expenses
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Interest expenses' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Interest expenses','00000000-0000-0000-0000-000000000000',10,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Interest expenses'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit before Tax--Interest income
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Interest income' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Interest income','00000000-0000-0000-0000-000000000000',11,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Interest income'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit before Tax--Interest income
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Staff cost' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Staff cost','00000000-0000-0000-0000-000000000000',12,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Staff cost'),'',(Select Id From [Bean].[Category]Where Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			-----------------Profit after Tax-----Profit before Tax'
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit after Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Profit before Tax' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Profit before Tax','00000000-0000-0000-0000-000000000000',1,'SubTotal',@NEW_COMPANY_ID,(Select Id From [Bean].[Category] Where CompanyId=@NEW_COMPANY_ID and Name='Profit before Tax'),'',(Select Id From [Bean].[Category]Where Name='Profit after Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			------------------Profit after Tax--Operating expenses
			BEGIN 
			IF NOT EXISTS (SELECT * FROM [Bean].[SubCategory] WHERE ParentId =(Select Id From [Bean].[Category] Where Name='Profit after Tax' and CompanyId=@NEW_COMPANY_ID) and Name='Taxation' and CompanyId=@NEW_COMPANY_ID)
			BEGIN 
			
			INSERT INTO [Bean].[SubCategory]([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],
			[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Taxation','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@NEW_COMPANY_ID,(Select FRATId From Bean.AccountType Where CompanyId=@NEW_COMPANY_ID and Name='Taxation'),'',(Select Id From [Bean].[Category]Where Name='Profit after Tax' and CompanyId=@NEW_COMPANY_ID),1,null,null,null)
			END
			END;
			END
ELSE IF(@screenName ='Balance Sheet')
		BEGIN
--delete old seed data
			delete from Bean.Category where IsIncomeStatement is null and CompanyId=@NEW_COMPANY_ID
			delete from Bean.SubCategory where IsIncomeStatement is null and CompanyId=@NEW_COMPANY_ID
			delete from Bean.[Order] where LeadSheetType !='Income Statement' and CompanyId=@NEW_COMPANY_ID
			update Bean.ChartOfAccount set FRRecOrder=null,CategoryId=null,SubCategoryId=null where Category='Balance Sheet' and CompanyId=@NEW_COMPANY_ID
			--insert new seed data
			
			Declare @id1 uniqueidentifier=newid();
			if not exists(select * from Bean.Category where Name='Assets' and CompanyId=@NEW_COMPANY_ID)
			Begin
			INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (@id1,@NEW_COMPANY_ID,'Assets','LeadSheet',1,Null,null,'clr1',null ,1)
			End
			
			if not exists(select * from Bean.[SubCategory] where Name='Current Assets' and CompanyId=@NEW_COMPANY_ID)
			Begin	 
			INSERT INTO [Bean].[SubCategory] ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
			VALUES (NEWID(),'Current Assets','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,'91021766-F6F8-49FE-A230-66295B4BC3FB'
			,null ,@id1,null,null,null,1)
			End
			
			if not exists(select * from Bean.[SubCategory] where Name='Non-current Assets' and CompanyId=@NEW_COMPANY_ID)	
			Begin
			INSERT INTO [Bean].[SubCategory] ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
			VALUES (NEWID(),'Non-current Assets','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@NEW_COMPANY_ID,'81021766-F6F8-49FE-A230-66295B4BC3FB'
			,null ,@id1,null,null,null,1)
			End
			
			Declare @id2 uniqueidentifier=newid();
			Begin
			if not exists(select * from Bean.Category where Name='Liabilities' and CompanyId=@NEW_COMPANY_ID)	
			INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (@id2,@NEW_COMPANY_ID,'Liabilities','LeadSheet',1,Null,null,'clr2',null ,1)
			End
			
			if not exists(select * from Bean.[SubCategory] where Name='Current Liabilities' and CompanyId=@NEW_COMPANY_ID)	
			Begin
			INSERT INTO [Bean].[SubCategory] ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
			[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Current Liabilities','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,'71021766-F6F8-49FE-A230-66295B4BC3FB'
			,null ,@id2,null,null,null,1)
			End
			
			if not exists(select * from Bean.[SubCategory] where Name='Non-current Liabilities' and CompanyId=@NEW_COMPANY_ID)	
			Begin
			INSERT INTO [Bean].[SubCategory] ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],[ColorCode], [AccountClass],[IsCollapse])
			VALUES (NEWID(),'Non-current Liabilities','00000000-0000-0000-0000-000000000000',2,'LeadSheet',@NEW_COMPANY_ID,'61021766-F6F8-49FE-A230-66295B4BC3FB',null ,@id2,null,null,null,1)
			End
			
			Declare @id3 uniqueidentifier=newid();
			if not exists(select * from Bean.Category where Name='Equity and Liabilities' and CompanyId=@NEW_COMPANY_ID)	
			Begin
			INSERT INTO [Bean].[Category]([Id],[CompanyId],[Name],[Type],[Recorder],[IsIncomeStatement],[LeadsheetId],[ColorCode],[AccountClass],[IsCollapse])
			VALUES (@id3,@NEW_COMPANY_ID,'Equity and Liabilities','SubTotal',2,Null,null,'clr5',null ,1)
			End
			
			if not exists(select * from Bean.[SubCategory] where Name='Equity' and CompanyId=@NEW_COMPANY_ID)	
			Begin
			INSERT INTO [Bean].[SubCategory] ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
			[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Equity','00000000-0000-0000-0000-000000000000',1,'LeadSheet',@NEW_COMPANY_ID,'41021766-F6F8-49FE-A230-66295B4BC3FB'
			,null ,@id3,null,null,null,1)
			End
			
			if not exists(select * from Bean.[SubCategory] where Name='Liabilities' and CompanyId=@NEW_COMPANY_ID)	
			Begin
			INSERT INTO [Bean].[SubCategory] ([Id],[Name],[CategoryId],[Recorder],[Type],[CompanyId],[TypeId],[SubCategoryOrder],[ParentId],[IsIncomeStatement],
			[ColorCode],[AccountClass],[IsCollapse])
			VALUES (NEWID(),'Liabilities','00000000-0000-0000-0000-000000000000',2,'SubTotal',@NEW_COMPANY_ID,(select Id from Bean.Category where Name='Liabilities' and CompanyId=@NEW_COMPANY_ID),null ,@id3,null,null,null,1)
			End
			END
END
GO
