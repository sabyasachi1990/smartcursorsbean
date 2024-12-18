USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_GenericTemplate_SeedData]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE Procedure [dbo].[BR_GenericTemplate_SeedData]
@CompanyId BigInt
As
Begin

	Declare @OldCompanyId Int=0
	Declare @CursorName Varchar(524)
	Declare @Createddate Datetime2
	Declare @CreatedBy Varchar(124)
	Set @CursorName='BR Cursor'
	Set @CreatedBy='System'
	Set @Createddate=GETDATE()
	Begin Try
    Begin Transaction
	--================================== Check new CompanyId data in  Common.GenericTemplate ====================================
	If Not exists (	Select Id From Common.GenericTemplate Where  CompanyId=@CompanyId And CursorName=@CursorName and IsSystem=1)
	Begin
		--================================ drop #GenTemplate ==========================================================
	  IF OBJECT_Id('tempdb..#GenTemplate') Is Not Null
	  Begin
		Drop table #GenTemplate
	  End
	 --=================================== create #GenTemplate ======================================
	  Create Table #GenTemplate (OldId Uniqueidentifier,NewIds Uniqueidentifier)

	--================================insert data in #GenTemplate===================================================
	  Insert Into #GenTemplate
	  Select Id,NewId() As Newids From Common.GenericTemplate 
	  Where CompanyId=@OldCompanyId And CursorName=@CursorName and IsSystem=1

	 --================================== insert data in Common.GenericTemplate=========================================== 
	  Insert Into Common.GenericTemplate(Id,CompanyId,TemplateTypeId,Name,Code,TempletContent,IsSystem,IsFooterExist,IsHeaderExist,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Category,Conditions,IsUsed,FromEmailId,ToEmailId,CCEmailIds,BCCEmailIds,TemplateType,
	  Subject,IsPartnerTemplate,IsDefultTemplate,Isthisemailtemplate,IsLandscape,CursorName,ServiceCompanyIds,ServiceCompanyNames)
	  Select B.NewIds As Id,@CompanyId, case when c.id is null then A.TemplateTypeId ELSE C.ID END AS TemplateTypeId 
	  ,a.Name,Code,TempletContent,a.IsSystem,IsFooterExist,IsHeaderExist,a.RecOrder,a.Remarks,@CreatedBy,@Createddate
	  ,Null As ModifiedBy,Null As ModifiedDate,Version,a.Status,Category,Conditions,IsUsed,FromEmailId,ToEmailId,CCEmailIds,BCCEmailIds,TemplateType,Subject,IsPartnerTemplate
	  ,IsDefultTemplate,Isthisemailtemplate,IsLandscape,CursorName,ServiceCompanyIds,ServiceCompanyNames 
	  From Common.GenericTemplate As A
	  Join #GenTemplate As B On A.Id=B.OldId	
	  LEFT join  Common.TemplateType As C On C.Name=A.Category and c.CompanyId=@CompanyId AND C.IsSystem=0
	  Where a.CompanyId=@OldCompanyId 
	  And CursorName=@CursorName and a.IsSystem=1
	  Group By B.NewIds,A.TemplateTypeId,a.Name,c.id ,Code,TempletContent,a.IsSystem,IsFooterExist,IsHeaderExist,a.RecOrder,a.Remarks
	  ,Version,a.Status,Category,Conditions,IsUsed,FromEmailId,ToEmailId,CCEmailIds,BCCEmailIds,TemplateType,Subject,IsPartnerTemplate
	  ,IsDefultTemplate,Isthisemailtemplate,IsLandscape,CursorName,ServiceCompanyIds,ServiceCompanyNames
	  
	  --======================================insert data in Common.GenericTemplateDetail==========================================
	  Insert Into Common.GenericTemplateDetail
	  Select NEWID() As Id,B.NewIds,A.Name,A.Activity ,C.TemplateTypeId,C.TemplateDtlId 
	  From Common.GenericTemplateDetail As A
	  Join #GenTemplate As B On A.GenericTemplateId=B.OldId
	  LEFT Join
	  (
	  Select A.Id As TemplateTypeId,B.Id As TemplateDtlId,A.Name,B.ViewModelName From Common.TemplateType As A
	  Join Common.TemplateTypeDetail As B On A.Id=B.TemplateTypeId
	  Where A.CompanyId=@CompanyId And A.IsSystem=0
	  ) As C ON C.Name=A.Activity
	   ----================================ drop #GenTemplate ========================================================== 
	  --IF OBJECT_Id('tempdb..#GenTemplate') Is Not Null
	  --Begin
	  --	Drop table #GenTemplate
	  --End
   END
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
    Print 'BR_GenericTemplate_SeedData SP Completed'
    END
END
GO
