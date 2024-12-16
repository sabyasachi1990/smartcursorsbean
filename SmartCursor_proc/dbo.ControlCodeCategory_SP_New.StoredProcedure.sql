USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ControlCodeCategory_SP_New]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[ControlCodeCategory_SP_New]
 @NewcompanyId bigint,
 @NewModuleMasterId bigint
AS
Begin
--  exec [dbo].[ControlCodeCategory_SP_New] 12,2
Declare 
@oldCompanyId bigint=0,
@ControlCategoryId bigint,
@ControlCodeCategoryCode nvarchar(50),
@ControlCodeCategoryId bigint
Declare @Count Int
Declare @recCount Int
Declare @ERROR_MESSAGE Nvarchar(Max)
Declare @TempTbl Table (S_No Int Identity(1,1),ControlCategoryId Int)
Begin Transaction
Begin Try
	Declare @ControleCodeCatList Table(ControlCategoryId int,ControleCategoryCode Nvarchar(500),CompanyId BigInt)
	Insert Into @TempTbl
	select Distinct ControlCategoryId from [Common].[ControlCodeCategoryModule] where CompanyId=@oldCompanyId and ModuleMasterId=@NewModuleMasterId 
	Set @Count=(Select Count(*) From @TempTbl)
	Set @recCount=1
    While @Count>=@recCount
	Begin
		Set @ControlCategoryId=(Select ControlCategoryId From @TempTbl Where S_No=@recCount)
        SET @ControlCodeCategoryCode=(select ControlCodeCategoryCode from Common.ControlCodeCategory where CompanyId=@oldCompanyId  and id=@ControlCategoryId )
        SET @ControlCodeCategoryId=(select id from Common.ControlCodeCategory where CompanyId=@NewcompanyId and ControlCodeCategoryCode=@ControlCodeCategoryCode)
		if(@ControlCodeCategoryId is null)
		begin
			Insert Into @ControleCodeCatList
			Select @ControlCategoryId,@ControlCodeCategoryCode,@NewcompanyId
		end
		Else
		Begin
			If Not Exists (select Id from [Common].[ControlCodeCategoryModule] 
			                 where CompanyId=@NewcompanyId And ControlCategoryId=@ControlCodeCategoryId And ModuleMasterId=@NewModuleMasterId
			               )
			BEGIN
				Insert into [Common].[ControlCodeCategoryModule] (Id,CompanyId,ControlCategoryId,ModuleMasterId)
			    select Max(id)+1 AS Id,@NewCOmpanyid ,@ControlCodeCategoryId ,@NewModuleMasterId  
			    from [Common].[ControlCodeCategoryModule] 
			END
		End
		Set @recCount=@recCount+1
     END   
	 Select * From @ControleCodeCatList
	 Commit 
	 END Try
	 Begin Catch

		RollBack

		Set @ERROR_MESSAGE=(Select ERROR_MESSAGE())
		Raiserror(@ERROR_MESSAGE,16,1)
	 END Catch
END
GO
