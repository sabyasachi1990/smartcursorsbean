USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Upadte_LinkedAccounts]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec [dbo].[Bean_Upadte_LinkedAccounts] 1
CREATE Procedure [dbo].[Bean_Upadte_LinkedAccounts]
	@CompanyId BigInt
As
Begin

Declare @COADocId Nvarchar(250),
		@COAId Int,
		@CursorName Varchar(25),
		@DocType Varchar(25),
		@MDFDate Datetime2,
		@MDFBy Nvarchar(250)
Begin Transaction
Begin Try
--//Declare Temparary table variable to store [COALinkedAccounts] Data
	Declare @Temp Table (Id int,[CoaId] [int],[CursorName] [nvarchar](250),[CompanyId] [bigint],[DocumentType] [nvarchar](250),[DocId] [nvarchar](250))
--//Create Table To Store COAID Details If table doesn't exist
	IF Not EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='Bean' And TABLE_NAME = 'COALinkedAccounts')
	Begin
		CREATE TABLE [Bean].[COALinkedAccounts]([CoaId] [int],[CursorName] [nvarchar](250),[CompanyId] [bigint],[DocumentType] [nvarchar](250),[DocId] [nvarchar](250),[CreatedDate] [datetime2](7),[CreatedBy] [nvarchar](250))
	End
--// Delete records from [COALinkedAccounts] table those are not exist in source tables
	Declare Delete_NonExistDocid_Csr Cursor For
		Select DocId,CoaId,CursorName,DocumentType From Bean.COALinkedAccounts Where CompanyId=@CompanyId
	Open Delete_NonExistDocid_Csr;
	Fetch Next From Delete_NonExistDocid_Csr Into @COADocId,@COAId,@CursorName,@DocType
	While @@FETCH_STATUS=0
	Begin
		IF @CursorName='Admin Cursor' And @DocType='Service'
		Begin
			IF Not Exists (Select Id From Common.Service Where Id=Cast(@COADocId As bigint) And CoaId=@COAId And CompanyId=@CompanyId)
			Begin
			Delete From Bean.COALinkedAccounts Where CoaId=@COAId and DocId=@COADocId And CursorName=@CursorName And DocumentType=@DocType And CompanyId=@CompanyId
			End
		End
		Else IF @CursorName='Admin Cursor' And @DocType='Item' 
		Begin
			IF Not Exists (Select Id From Bean.Item Where Id=Cast(@COADocId As uniqueidentifier) And CoaId=@COAId And CompanyId=@CompanyId)
			Begin
			Delete From Bean.COALinkedAccounts Where CoaId=@COAId and DocId=@COADocId And CursorName=@CursorName And DocumentType=@DocType And CompanyId=@CompanyId
			End
		End
		Else IF @CursorName='HR Cursor' And @DocType='ClaimItem' 
		Begin
			IF Not Exists (Select Id From HR.ClaimItem Where Id=Cast(@COADocId As uniqueidentifier) And CoaId=@COAId And CompanyId=@CompanyId)
			Begin
			Delete From Bean.COALinkedAccounts Where CoaId=@COAId and DocId=@COADocId And CursorName=@CursorName And DocumentType=@DocType And CompanyId=@CompanyId
			End
		End
		Else IF @CursorName='HR Cursor' And @DocType='PayComponent' 
		Begin
			IF Not Exists (Select Id From HR.PayComponent Where Id=cast(@COADocId As uniqueidentifier) And CoaId=@COAId And CompanyId=@CompanyId)
			Begin
			Delete From Bean.COALinkedAccounts Where CoaId=@COAId and DocId=@COADocId And CursorName=@CursorName And DocumentType=@DocType And CompanyId=@CompanyId
			End
		End
		Else IF @CursorName='WorkFlow Cursor' And @DocType='IncidentalClaimItem' 
		Begin
			IF Not Exists (Select Id From WorkFlow.IncidentalClaimItem Where Id=Cast(@COADocId As uniqueidentifier) And CoaId=@COAId And CompanyId=@CompanyId)
			Begin
			Delete From Bean.COALinkedAccounts Where CoaId=@COAId and DocId=@COADocId And CursorName=@CursorName And DocumentType=@DocType And CompanyId=@CompanyId
			End
		End
		Else IF @CursorName='Bean Cursor' And @DocType='ChartOfAccount' 
		Begin
			IF Not Exists (Select Id From Bean.ChartOfAccount Where Id=@COAId And CompanyId=@CompanyId)
			Begin
			Delete From Bean.COALinkedAccounts Where CoaId=@COAId and DocId=@COADocId And CursorName=@CursorName And DocumentType=@DocType And CompanyId=@CompanyId
			End
		End

		
	Fetch Next From Delete_NonExistDocid_Csr Into @COADocId,@COAId,@CursorName,@DocType
	End
	Close Delete_NonExistDocid_Csr
	Deallocate Delete_NonExistDocid_Csr


--//Declare Cursor to get COAId Detaild from required tables

	Declare COAList_Csr Cursor For
		Select Cast(Id As Nvarchar(250)) As Id,CoaId,'Admin Cursor','Service',ModifiedDate,ModifiedBy From Common.Service Where CompanyId=@CompanyId And CoaId Is Not Null
		Union All
		Select Cast(Id As Nvarchar(250)) As Id,COAId,'Admin Cursor','Item',ModifiedDate,ModifiedBy From Bean.Item Where CompanyId=@CompanyId And CoaId Is Not Null And IsIncidental=1
		Union All
		Select Cast(Id As Nvarchar(250)) As Id,COAId,'HR Cursor','ClaimItem',ModifiedDate,ModifiedBy From HR.ClaimItem Where CompanyId=@CompanyId And CoaId Is Not Null
		Union All
		Select Cast(Id As Nvarchar(250)) As Id,COAId,'HR Cursor','PayComponent',ModifiedDate,ModifiedBy from HR.PayComponent Where CompanyId=@CompanyId And CoaId Is Not Null
		Union All
		Select Cast(Id As Nvarchar(250)) As Id,COAId,'WorkFlow Cursor','IncidentalClaimItem',ModifiedDate,ModifiedBy From WorkFlow.IncidentalClaimItem Where CompanyId=@CompanyId And CoaId Is Not Null
		Union All
		Select Cast(Id As Nvarchar(250)) As Id,Id As COAId,'Bean Cursor','ChartOfAccount',ModifiedDate,ModifiedBy From Bean.ChartOfAccount Where CompanyId=@CompanyId 
			And IsSystem=0 And IsLinkedAccount=1
	Open COAList_Csr;
	Fetch Next From COAList_Csr Into @COADocId,@COAId,@CursorName,@DocType,@MDFDate,@MDFBy
	While @@FETCH_STATUS=0
	Begin
--//Check if the coaid is exist in the table with relevant documnetid[source table id] or not
		IF Not Exists (Select DocId From Bean.COALinkedAccounts Where DocId=@COADocId And COAId=@COAId And CompanyId=@CompanyId)
		Begin
			Insert Into Bean.COALinkedAccounts ([CoaId],[CompanyId],[DocId],[CursorName],[DocumentType],[CreatedDate] ,[CreatedBy] )
					Values(@COAId,@CompanyId,@COADocId,@CursorName,@DocType,Isnull(@MDFDate,Getdate()),Isnull(@MDFBy,'System'))
		End
	
	Fetch Next From COAList_Csr Into @COADocId,@COAId,@CursorName,@DocType,@MDFDate,@MDFBy
	End
	
	Close COAList_Csr;
	Deallocate COAList_Csr;
--//Update COAId with IsLinkedAccount Is True
	Update Bean.ChartOfAccount Set IsLinkedAccount=1 Where Id In (Select Distinct COAId From Bean.COALinkedAccounts Where CompanyId=@CompanyId) And CompanyId=@CompanyId
--//Update COAId with IsLinkedAccount Is False
	--Update Bean.ChartOfAccount Set IsLinkedAccount=0 Where Id Not In (Select Distinct COAId From Bean.COALinkedAccounts Where CompanyId=@CompanyId) And CompanyId=@CompanyId And IsSystem<>0

	Commit Transaction
End Try

	Begin Catch
		RollBack Transaction;
		Throw;
	End Catch


End
GO
