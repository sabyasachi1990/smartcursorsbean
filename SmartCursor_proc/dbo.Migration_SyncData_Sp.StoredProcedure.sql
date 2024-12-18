USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Migration_SyncData_Sp]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec  [dbo].[Migration_SyncData_Sp] 1,'WorkFlow Cursor'
CREATE Procedure [dbo].[Migration_SyncData_Sp]
@CompanyId BigInt,
@CursorName Varchar(20)
As
Begin
	Declare @GetDate Datetime2,
			@SyncUpdtStatusComplete Varchar(20)
		Set @GetDate = GETUTCDATE()
		Set @SyncUpdtStatusComplete = 'UpdateCompleted'
	IF @CursorName='Bean Cursor'
	Begin
		If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Workflow Cursor') And Status=1)
		Begin
			--SyncServiceDetails In Item Table
			Update I Set SyncServiceId=S.Id,SyncServicedate=@GetDate,SyncServiceRemarks=Null,SyncServiceStatus=@SyncUpdtStatusComplete From Bean.Item As I
			Inner Join Common.Service As S On S.Id=I.DocumentId
			Where I.CompanyId=@CompanyId And I.DocumentId Is Not Null
			--SyncItemDetails In Service Table
			Update S Set S.SyncItemId=I.Id,S.SyncItemdate=@GetDate,S.SyncItemRemarks=Null,S.SyncItemStatus=@SyncUpdtStatusComplete From Common.Service As S
			Inner Join Bean.Item As I On I.DocumentId=S.Id
			Where I.CompanyId=@CompanyId And I.DocumentId Is Not Null
			 ---  SyncEmployeeId IN  Entity Table
                Update E Set E.SyncEmployeeId=A.Id,E.SyncEmployeeStatus=@SyncUpdtStatusComplete,E.SyncEmployeeRemarks=Null,E.SyncEmployeeDate=@GetDate From Bean.Entity As E
			     Inner Join Common.Employee As A On A.Id=E.DocumentId
			    Where E.CompanyId=@CompanyId  and E.ExternalEntityType='Employee' And E.DocumentId Is Not Null
               ---   SyncEntityId In  Employee Table
			   Update A Set A.SyncEntityId=E.Id,A.SyncEntityStatus=@SyncUpdtStatusComplete,A.SyncEntityRemarks=Null,A.SyncEntityDate=@GetDate From Bean.Entity As E
			   Inner Join Common.Employee As A On A.Id=E.DocumentId
			   Where A.CompanyId=@CompanyId And E.DocumentId Is Not Null
			If Exists (Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Client Cursor') And Status=1)
			Begin
				--SyncClientDetails In Account Table
				Update A Set A.SyncClientId=C.Id,A.SyncClientRemarks=Null,A.SyncClientStatus=@SyncUpdtStatusComplete,SyncClientDate=@GetDate From ClientCursor.Account As A
				Inner Join WorkFlow.Client As C On C.AccountId=A.Id
				Where A.CompanyId=@CompanyId And C.AccountId Is NOt Null
				--SyncAccountDetails In Client Table
				Update C Set C.SyncAccountId=A.Id,SyncAccountDate=@GetDate,SyncAccountStatus=@SyncUpdtStatusComplete,SyncAccountRemarks=Null From WorkFlow.Client As C
				Inner Join ClientCursor.Account As A On A.ClientId=C.Id
				Where C.CompanyId=@CompanyId And A.ClientId Is Not Null
			End
			--SyncClientDeatils In Entity Table
			Update E Set E.SyncClientId=C.Id,E.SyncClientDate=@GetDate,E.SyncClientRemarks=Null,E.SyncClientStatus=@SyncUpdtStatusComplete From Bean.Entity As E
			Inner Join WorkFlow.Client As C On C.Id=E.DocumentId
			Where E.CompanyId=@CompanyId And E.DocumentId Is Not Null
			--SyncEntityDetails In Client Table
			Update C Set C.SyncEntityId=E.Id,C.SyncEntityRemarks=Null,C.SyncEntityStatus=@SyncUpdtStatusComplete,C.SyncEntitydate=@GetDate From WorkFlow.Client As C
			Inner Join Bean.Entity As E On E.DocumentId=C.Id
			Where C.CompanyId=@CompanyId And E.DocumentId Is Not Null
			--SyncAccountDetails In Entity Table
			Update E Set E.SyncAccountId=A.Id,E.SyncAccountStatus=@SyncUpdtStatusComplete,E.SyncAccountRemarks=Null,E.SyncAccountDate=@GetDate From Bean.Entity As E
			Inner Join ClientCursor.Account As A On A.SyncClientId=E.DocumentId
			Where E.CompanyId=@CompanyId And E.DocumentId Is Not Null
			Update A Set A.SyncEntityId=E.Id,A.SyncEntityStatus=@SyncUpdtStatusComplete,A.SyncEntityRemarks=Null,A.SyncEntityDate=@GetDate From Bean.Entity As E
			Inner Join ClientCursor.Account As A On A.SyncClientId=E.SyncClientId
			Where E.CompanyId=@CompanyId And A.SyncClientId Is Not Null
			 ---  SyncEmployeeId IN  Entity Table
                Update E Set E.SyncEmployeeId=A.Id,E.SyncEmployeeStatus=@SyncUpdtStatusComplete,E.SyncEmployeeRemarks=Null,E.SyncEmployeeDate=@GetDate From Bean.Entity As E
			     Inner Join Common.Employee As A On A.Id=E.DocumentId
			    Where E.CompanyId=@CompanyId  and E.ExternalEntityType='Employee' And E.DocumentId Is Not Null
               ---   SyncEntityId In  Employee Table
			   Update A Set A.SyncEntityId=E.Id,A.SyncEntityStatus=@SyncUpdtStatusComplete,A.SyncEntityRemarks=Null,A.SyncEntityDate=@GetDate From Bean.Entity As E
			   Inner Join Common.Employee As A On A.Id=E.DocumentId
			   Where A.CompanyId=@CompanyId And E.DocumentId Is Not Null

		End
		Else If Exists (Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Client Cursor') And Status=1)
		Begin
			--SyncEntityDetails In Client Table
			Update C Set C.SyncEntityId=E.Id,C.SyncEntityRemarks=Null,C.SyncEntityStatus=@SyncUpdtStatusComplete,C.SyncEntitydate=@GetDate From WorkFlow.Client As C
			Inner Join Bean.Entity As E On E.DocumentId=C.Id
			Where C.CompanyId=@CompanyId And E.DocumentId Is Not Null
			--SyncAccountDetails In Entity Table
			Update E Set E.SyncAccountId=A.Id,E.SyncAccountStatus=@SyncUpdtStatusComplete,E.SyncAccountRemarks=Null,E.SyncAccountDate=@GetDate From Bean.Entity As E
			Inner Join ClientCursor.Account As A On  A.SyncClientId=E.DocumentId
			Where E.CompanyId=@CompanyId And E.DocumentId Is Not Null
			  ---  SyncEmployeeId IN  Entity Table
                Update E Set E.SyncEmployeeId=A.Id,E.SyncEmployeeStatus=@SyncUpdtStatusComplete,E.SyncEmployeeRemarks=Null,E.SyncEmployeeDate=@GetDate From Bean.Entity As E
			     Inner Join Common.Employee As A On A.Id=E.DocumentId
			    Where E.CompanyId=@CompanyId  and E.ExternalEntityType='Employee' And E.DocumentId Is Not Null
               ---   SyncEntityId In  Employee Table
			   Update A Set A.SyncEntityId=E.Id,A.SyncEntityStatus=@SyncUpdtStatusComplete,A.SyncEntityRemarks=Null,A.SyncEntityDate=@GetDate From Bean.Entity As E
			   Inner Join Common.Employee As A On A.Id=E.DocumentId
			   Where A.CompanyId=@CompanyId And E.DocumentId Is Not Null
		End
	End
	Else IF @CursorName='Client Cursor'
	Begin
		If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Workflow Cursor') And Status=1)
		Begin
			--SyncClientDetails In Account Table
			Update A Set A.SyncClientId=C.Id,A.SyncClientRemarks=Null,A.SyncClientStatus=@SyncUpdtStatusComplete,SyncClientDate=@GetDate From ClientCursor.Account As A
			Inner Join WorkFlow.Client As C On C.AccountId=A.Id
			Where A.CompanyId=@CompanyId And C.AccountId Is NOt Null
			--SyncAccountDetails In Client Table
			Update C Set C.SyncAccountId=A.Id,SyncAccountDate=@GetDate,SyncAccountStatus=@SyncUpdtStatusComplete,SyncAccountRemarks=Null From WorkFlow.Client As C
			Inner Join ClientCursor.Account As A On A.ClientId=C.Id
			Where C.CompanyId=@CompanyId And A.ClientId Is Not Null
			If Exists (Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
			Begin
				--SyncEntityDetails In Client Table
				Update C Set C.SyncEntityId=E.Id,C.SyncEntityRemarks=Null,C.SyncEntityStatus=@SyncUpdtStatusComplete,C.SyncEntitydate=@GetDate From WorkFlow.Client As C
				Inner Join Bean.Entity As E On E.DocumentId=C.Id
				Where C.CompanyId=@CompanyId And E.DocumentId Is Not Null
				--SyncAccountDetails In Entity Table
				Update E Set E.SyncAccountId=A.Id,E.SyncAccountStatus=@SyncUpdtStatusComplete,E.SyncAccountRemarks=Null,E.SyncAccountDate=@GetDate From Bean.Entity As E
				Inner Join ClientCursor.Account As A On A.SyncClientId=E.DocumentId
				Where E.CompanyId=@CompanyId And E.DocumentId Is Not Null
				  ---  SyncEmployeeId IN  Entity Table
                Update E Set E.SyncEmployeeId=A.Id,E.SyncEmployeeStatus=@SyncUpdtStatusComplete,E.SyncEmployeeRemarks=Null,E.SyncEmployeeDate=@GetDate From Bean.Entity As E
			     Inner Join Common.Employee As A On A.Id=E.DocumentId
			    Where E.CompanyId=@CompanyId  and E.ExternalEntityType='Employee' And E.DocumentId Is Not Null
               ---  SyncEntityId In  Employee Table
			   Update A Set A.SyncEntityId=E.Id,A.SyncEntityStatus=@SyncUpdtStatusComplete,A.SyncEntityRemarks=Null,A.SyncEntityDate=@GetDate From Bean.Entity As E
			   Inner Join Common.Employee As A On A.Id=E.DocumentId
			   Where A.CompanyId=@CompanyId And E.DocumentId Is Not Null
			End
		End
		Else If Exists (Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
		Begin
			--SyncEntityDetails In Client Table
			Update C Set C.SyncEntityId=E.Id,C.SyncEntityRemarks=Null,C.SyncEntityStatus=@SyncUpdtStatusComplete,C.SyncEntitydate=@GetDate From WorkFlow.Client As C
			Inner Join Bean.Entity As E On E.DocumentId=C.Id
			Where C.CompanyId=@CompanyId And E.DocumentId Is Not Null
			--SyncAccountDetails In Entity Table
			Update E Set E.SyncAccountId=A.Id,E.SyncAccountStatus=@SyncUpdtStatusComplete,E.SyncAccountRemarks=Null,E.SyncAccountDate=@GetDate From Bean.Entity As E
			Inner Join ClientCursor.Account As A On A.SyncClientId=E.DocumentId
			Where E.CompanyId=@CompanyId And E.DocumentId Is Not Null
			---  SyncEmployeeId IN  Entity Table
             Update E Set E.SyncEmployeeId=A.Id,E.SyncEmployeeStatus=@SyncUpdtStatusComplete,E.SyncEmployeeRemarks=Null,E.SyncEmployeeDate=@GetDate From Bean.Entity As E
			  Inner Join Common.Employee As A On A.Id=E.DocumentId
			  Where E.CompanyId=@CompanyId  and E.ExternalEntityType='Employee' And E.DocumentId Is Not Null
              ---   SyncEntityId In  Employee Table
			  Update A Set A.SyncEntityId=E.Id,A.SyncEntityStatus=@SyncUpdtStatusComplete,A.SyncEntityRemarks=Null,A.SyncEntityDate=@GetDate From Bean.Entity As E
			  Inner Join Common.Employee As A On A.Id=E.DocumentId
			  Where A.CompanyId=@CompanyId And E.DocumentId Is Not Null
		End
	End
	Else IF @CursorName='WorkFlow Cursor'
	Begin
		If Exists(Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Workflow Cursor') And Status=1)
		Begin
			--SyncClientDetails In Account Table
			Update A Set A.SyncClientId=C.Id,A.SyncClientRemarks=Null,A.SyncClientStatus=@SyncUpdtStatusComplete,SyncClientDate=@GetDate From ClientCursor.Account As A
			Inner Join WorkFlow.Client As C On C.AccountId=A.Id
			Where A.CompanyId=@CompanyId And C.AccountId Is NOt Null
			--SyncAccountDetails In Client Table
			Update C Set C.SyncAccountId=A.Id,SyncAccountDate=@GetDate,SyncAccountStatus=@SyncUpdtStatusComplete,SyncAccountRemarks=Null From WorkFlow.Client As C
			Inner Join ClientCursor.Account As A On A.ClientId=C.Id
			Where C.CompanyId=@CompanyId And A.ClientId Is Not Null
			If Exists (Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
			Begin
				--SyncClientDeatils In Entity Table
				Update C Set C.SyncEntityId=E.Id,C.SyncEntityDate=@GetDate,C.SyncEntityRemarks=Null,C.SyncEntityStatus=@SyncUpdtStatusComplete From Bean.Entity As E
				Inner Join WorkFlow.Client As C On C.Id=E.DocumentId
				Where E.CompanyId=@CompanyId And E.DocumentId Is Not Null
				--SyncClientDeatils In Entity Table
				Update E Set E.SyncClientId=C.Id,E.SyncClientDate=@GetDate,E.SyncClientRemarks=Null,E.SyncClientStatus=@SyncUpdtStatusComplete From Bean.Entity As E
				Inner Join WorkFlow.Client As C On C.Id=E.DocumentId
				Where E.CompanyId=@CompanyId And E.DocumentId Is Not Null
				  ---  SyncEmployeeId IN  Entity Table
                Update E Set E.SyncEmployeeId=A.Id,E.SyncEmployeeStatus=@SyncUpdtStatusComplete,E.SyncEmployeeRemarks=Null,E.SyncEmployeeDate=@GetDate From Bean.Entity As E
			     Inner Join Common.Employee As A On A.Id=E.DocumentId
			    Where E.CompanyId=@CompanyId  and E.ExternalEntityType='Employee' And E.DocumentId Is Not Null
               ---   SyncEntityId In  Employee Table
			   Update A Set A.SyncEntityId=E.Id,A.SyncEntityStatus=@SyncUpdtStatusComplete,A.SyncEntityRemarks=Null,A.SyncEntityDate=@GetDate From Bean.Entity As E
			   Inner Join Common.Employee As A On A.Id=E.DocumentId
			   Where A.CompanyId=@CompanyId And E.DocumentId Is Not Null
			End
		End
		Else If Exists (Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Bean Cursor') And Status=1)
		Begin
			--SyncClientDeatils In Entity Table
			Update C Set C.SyncEntityId=E.Id,C.SyncEntityDate=@GetDate,C.SyncEntityRemarks=Null,C.SyncEntityStatus=@SyncUpdtStatusComplete From Bean.Entity As E
			Inner Join WorkFlow.Client As C On C.Id=E.DocumentId
			Where E.CompanyId=@CompanyId And E.DocumentId Is Not Null
			--SyncClientDeatils In Entity Table
			Update E Set E.SyncClientId=C.Id,E.SyncClientDate=@GetDate,E.SyncClientRemarks=Null,E.SyncClientStatus=@SyncUpdtStatusComplete From Bean.Entity As E
			Inner Join WorkFlow.Client As C On C.Id=E.DocumentId
			Where E.CompanyId=@CompanyId And E.DocumentId Is Not Null
			
          ---   SyncEmployeeId IN  Entity Table
           Update E Set E.SyncEmployeeId=A.Id,E.SyncEmployeeStatus=@SyncUpdtStatusComplete,E.SyncEmployeeRemarks=Null,E.SyncEmployeeDate=@GetDate From Bean.Entity As E
			Inner Join Common.Employee As A On A.Id=E.DocumentId
			Where E.CompanyId=@CompanyId  and E.ExternalEntityType='Employee' And E.DocumentId Is Not Null
           ---   SyncEntityId In  Employee Table
			Update A Set A.SyncEntityId=E.Id,A.SyncEntityStatus=@SyncUpdtStatusComplete,A.SyncEntityRemarks=Null,A.SyncEntityDate=@GetDate From Bean.Entity As E
			Inner Join Common.Employee As A On A.Id=E.DocumentId
			Where A.CompanyId=@CompanyId And E.DocumentId Is Not Null

		End
	End
End


----------------------------------------------------------------- alter column 
----Common.Service
--Alter Table Common.Service Add SyncItemId Uniqueidentifier,SyncItemStatus Varchar(50),SyncItemdate Datetime2,SyncItemRemarks NVarchar(Max)


----Bean.Item
--Alter Table Bean.Item Add SyncServiceId Bigint,SyncServiceStatus Varchar(50),SyncServicedate Datetime2,SyncServiceRemarks NVarchar(Max)

---- Common.Employee
--Alter Table Common.Employee Add SyncEntityId Uniqueidentifier,SyncEntityStatus Varchar(50),SyncEntityDate Datetime2,SyncEntityRemarks Nvarchar(Max)

---- Bean.Entity

--Alter Table Bean.Entity Add SyncClientId Uniqueidentifier,SyncClientStatus Varchar(20),SyncClientRemarks Nvarchar(Max),SyncClientDate Datetime2

--Alter Table Bean.Entity Add SyncAccountId Uniqueidentifier,SyncAccountStatus Varchar(20),SyncAccountRemarks Nvarchar(Max),SyncAccountDate Datetime2

--Alter Table Bean.Entity Add SyncEmployeeId Uniqueidentifier,SyncEmployeeStatus Varchar(20),SyncEmployeeDate Datetime2,SyncEmployeeRemarks Nvarchar(Max)


---- ClientCursor.Account

--Alter Table Clientcursor.Account Add SyncEntityId Uniqueidentifier,SyncEntityStatus Varchar(50),SyncEntityRemarks Nvarchar(Max),SyncEntityDate Datetime2

--Alter Table Clientcursor.Account Add SyncClientId Uniqueidentifier,SyncClientStatus Varchar(50),SyncClientRemarks Nvarchar(Max),SyncClientDate Datetime2


----Workflow.Client

--Alter Table Workflow.Client Add SyncAccountId Uniqueidentifier,SyncAccountStatus Varchar(50),SyncAccountRemarks Nvarchar(Max),SyncAccountDate Datetime2

--Alter Table Workflow.Client Add SyncEntityId Uniqueidentifier,SyncEntityStatus Varchar(50),SyncEntityRemarks Nvarchar(Max),SyncEntityDate Datetime2

----------------------- end



			----======================================================= UPDATE  SyncEmployeeId
   --         select E.id as EntityId, A.Id as EmployeeId ,E.SyncEmployeeId,E.SyncEmployeeStatus,E.SyncEmployeeRemarks ,E.SyncEmployeeDate From Bean.Entity As E
			--Inner Join Common.Employee As A On A.Id=E.DocumentId
			--Where E.CompanyId IN (1,19) and E.ExternalEntityType='Employee' And E.DocumentId Is Not Null


   --          --======================================================= UPDATE  SyncEntityId
   --          SELECT  a.Id as EmployeeId,e.id EntityId,  A.SyncEntityId,A.SyncEntityStatus,A.SyncEntityRemarks,A.SyncEntityDate From Bean.Entity As E
			-- Inner Join Common.Employee As A On A.Id=E.DocumentId
			-- Where A.CompanyId IN(1,19) And E.DocumentId Is Not Null

GO
