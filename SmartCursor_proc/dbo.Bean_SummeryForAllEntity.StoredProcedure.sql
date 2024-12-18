USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_SummeryForAllEntity]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create Procedure [dbo].[Bean_SummeryForAllEntity] @CompanyId bigint
As
Begin
--// Declaring temp Variable To Store Inner Stored Procedure Result
Declare @Entity Table (Billing Money,PaidAmt Money,CreditAmount Money,GrossBalance money,DebtProvAmount money, NetBalance money)
--// Declaring variables
Declare @EntityId Uniqueidentifier
--// Declare Cursor To Pass All Company Customer Entity Id's One by one
Declare Entity_Csr Cursor For
Select Id From Bean.Entity where IsCustomer=1 and Companyid=@CompanyId

Open Entity_Csr
Fetch Next From Entity_Csr Into @EntityId
While @@FETCH_STATUS=0
Begin
Insert Into @Entity 

Exec [dbo].[Bean_SoaSummaryForEntity] @CompanyId,@EntityId

Update Bean.Entity Set CustBal=(Select GrossBalance From @Entity) Where Id=@EntityId And CompanyId=@CompanyId

Delete From @Entity

Fetch Next From Entity_Csr Into @EntityId
End

Close Entity_Csr
Deallocate Entity_Csr
End
GO
