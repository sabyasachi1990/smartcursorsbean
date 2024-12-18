USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_Update_CustBalance]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--exec Bean_Update_CustBalance 308,'19c2e120-2ee1-444c-b382-6e611416ddb0,d7d288e8-437f-454a-818c-ada4a4812230,742e62c3-dc84-4577-ab00-9029469a175e'

Create Procedure [dbo].[Bean_Update_CustBalance]
(
@CompanyId bigint,
@entitIds nvarchar(MAX)
)
As
Begin
	--// Declaring temp Variable To Store Inner Stored Procedure Result
	Declare @Entity Table (Billing Money,PaidAmt Money,CreditAmount Money,GrossBalance money,DebtProvAmount money, NetBalance money)
	--// Declaring variables
	Declare  @entityId Uniqueidentifier
	
	Declare Update_Entity_Cust_balance cursor for select items from dbo.SplitToTable(@entitIds,',')
	Open Update_Entity_Cust_balance
	Fetch Next From Update_Entity_Cust_balance Into @entityId
	While @@FETCH_STATUS=0
	BEGIN
		BEGIN TRY
			IF Exists(Select Id from Bean.Entity where CompanyId=@CompanyId and Id=@entityId and IsCustomer=1)
			BEGIN --Begin If Entity Exists
				--Print Convert(nvarchar(50),@items)
				Insert Into @Entity Exec [dbo].[Bean_SoaSummaryForEntity] @CompanyId,@entityId
				--select * from @Entity
				--Updating the Customer Balance
				Update Bean.Entity Set CustBal=(Select GrossBalance From @Entity) Where Id=@entityId And CompanyId=@CompanyId and IsCustomer=1
			END --End of If Entity Exists
		END TRY
		BEGIN CATCH
			Print Convert(nvarchar(40),@entityId)
			Print ERROR_MESSAGE()
		END CATCH
	Delete from @Entity
	Fetch Next From  Update_Entity_Cust_balance Into @entityId
	END
	Close Update_Entity_Cust_balance
	Deallocate Update_Entity_Cust_balance

End





GO
