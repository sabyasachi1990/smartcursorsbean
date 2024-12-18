USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ControlCodeCategory_SP_New_Migration]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[ControlCodeCategory_SP_New_Migration]
As
Begin
	Declare @CompCount Int
	Declare @CompRecCount Int
	Declare @CompanyId BigInt
	Declare @ModuleId Int
	Declare @CompanyModule Table (S_No Int Identity(1,1),CompanyId Bigint,ModuleId Int)
	Insert into @CompanyModule
	Select CompanyId,ModuleId From Common.CompanyModule Where CompanyId <> 0 and Status = 1
	Set @CompCount=(Select Count(*) From @CompanyModule)
	Set @CompRecCount=1
	While @CompCount>=@CompRecCount
	Begin
		Set @CompanyId=(Select CompanyId From @CompanyModule Where S_no=@CompRecCount)
		Set @ModuleId=(Select ModuleId From @CompanyModule Where S_no=@CompRecCount)

		Exec [dbo].[ControlCodeCategory_SP_New] @CompanyId,@ModuleId

		Set @CompRecCount=@CompRecCount+1
	End

End
GO
