USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_DynamicTemplate_SeedData]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[BR_DynamicTemplate_SeedData]
@CompanyId BigInt
As
Begin
	Declare @Createddate Datetime2
	Declare @CreatedBy Varchar(124)
	Declare @ModuleMasterId Int=9
	Declare @OldCompanyId Int=0
	Set @CreatedBy='System'
	Set @Createddate=GETDATE()
	Begin Try
    Begin Transaction

	--================================== Check new CompanyId data in  Common.TemplateType ====================================
	If Not exists (	Select Id From Common.TemplateType Where ModuleMasterId=@ModuleMasterId And CompanyId=@CompanyId And IsSystem=0)
	Begin 
	--================================ drop #Template ==========================================================
	  IF OBJECT_Id('tempdb..#Template') Is Not Null
	  Begin
	  	Drop table #Template
	  End
	  --=================================== create #Template ======================================
	  Create Table #Template (OldId Uniqueidentifier,NewIds Uniqueidentifier)
	  
	  --================================insert data in #Template===================================================
	  Insert into #Template
	  Select Id,NewId() As Newids From Common.TemplateType Where ModuleMasterId=@ModuleMasterId And CompanyId=@OldCompanyId And IsSystem=0
	  
	  --================================== insert data in Common.TemplateType===========================================
	  Insert Into Common.TemplateType (Id,CompanyId,ModuleMasterId,Name,Description,RecOrder,Remarks,Status,Actions,IsSystem,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,IsServiceCompany,ISAllowDuplicates)
	  Select B.NewIds,@CompanyId,ModuleMasterId,Name,Description,RecOrder,Remarks,Status,Actions,IsSystem,@CreatedBy
	  	,@Createddate,ModifiedBy,ModifiedDate,IsServiceCompany ,ISAllowDuplicates
	  From Common.TemplateType As A
	  Join #Template As B On A.Id=B.OldId
	  Where ModuleMasterId=@ModuleMasterId And CompanyId=@OldCompanyId And IsSystem=0
	  --======================================insert data in Common.TemplateTypeDetail==========================================
	  Insert into Common.TemplateTypeDetail
	  Select NewId() Id,C.NewIds,ViewModelName,ViewModelJson,A.RecOrder,A.Status,IsShow,NewViewModelName 
	  From Common.TemplateTypeDetail As A
	  Join Common.TemplateType As B On A.TemplateTypeId=B.Id
	  Join #Template As C On C.OldId=B.Id 
	  Where B.Id=C.OldId And B.ModuleMasterId=@ModuleMasterId And B.CompanyId=@OldCompanyId And B.IsSystem=0
	  ----================================ drop #Template ==========================================================
	  --IF OBJECT_Id('tempdb..#Template') Is Not Null
	  --Begin
	  --	Drop table #Template
	  --End
	End 
	Declare @ErrorMessage Nvarchar(1000), @ErrorServirity Int, @ErrorState Int
   	Commit Transaction
	End Try
	Begin Catch
	RollBack Transaction 
	Select @ErrorMessage=ERROR_MESSAGE(),
	@ErrorServirity=ERROR_SEVERITY(),
	@ErrorState=ERROR_STATE()
	RAISERROR(@ErrorMessage,@ErrorServirity,@ErrorState)
	End Catch
	BEGIN
    Print 'BR_DynamicTemplate_SeedData SP Completed'
    END

End
GO
