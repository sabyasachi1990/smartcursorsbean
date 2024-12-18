USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Tax_MenuSetupforEngagement]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------
--Menu Setup SP
create
Procedure [dbo].[Tax_MenuSetupforEngagement](@PartnerCompanyId Bigint,@CompanyId Bigint,@EngagementId uniqueidentifier,@AdditionalReview1 Nvarchar(100),@AdditionalReview2 Nvarchar(100),@TaxManualId uniqueidentifier)
AS Begin
Begin Transaction
BEGIN TRY
    Declare @acmmId Uniqueidentifier;
    DECLARE @acmmOldId UNIQUEIDENTIFIER      
    If Not Exists (Select * from Tax.TaxCompanyMenuMaster where companyid=@CompanyId and engagementid=@EngagementId and TaxManualId=@TaxManualId )
    Begin        
        DECLARE MenuSetUp CURSOR FOR SELECT Id FROM Tax.TaxCompanyMenuMaster where companyid=@PartnerCompanyId and engagementid is null  and Ishide=0 and TaxManualId=@TaxManualId;
          OPEN  MenuSetUp       
             FETCH NEXT FROM MenuSetUp INTO  @acmmOldId
             WHILE (@@FETCH_STATUS=0)      
             BEGIN      
                
                Set @acmmId =newid();
                    Insert into Tax.TaxCompanyMenuMaster (Id,CompanyId,EngagementId,TaxMenuMasterId,Code,Heading,IsHide,TemplateName,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,AdditionalReviewer,AdditionalReviewer1,IsReviewer,IsReviewer1)  
                select @acmmId,@CompanyId,@EngagementId,parentmm.TaxMenuMasterId,parentmm.Code,parentmm.Heading,parentmm.IsHide,parentmm.TemplateName,parentmm.RecOrder,parentmm.Remarks,parentmm.UserCreated,parentmm.CreatedDate,parentmm.ModifiedBy,parentmm.ModifiedDate,parentmm.Version,parentmm.Status,@AdditionalReview1,@AdditionalReview2,parentmm.IsReviewer,parentmm.IsReviewer1 from Tax.TaxCompanyMenuMaster as parentmm where parentmm.Id=@acmmOldId

				    Insert into Tax.Taxmenupermissions (Id,TaxCompanyMenuMasterId,[Role],[View],[Add],Edit,[Disable],Lock,Prepared,Reviewed,DeleteDocument,Actions,RoleId)
                select Newid(),@acmmId,amp.[Role],amp.[View],amp.[Add],amp.Edit,amp.[Disable],amp.Lock,amp.Prepared,amp.Reviewed,amp.DeleteDocument,amp.Actions,(select Id from tax.roles where Engagementid=@EngagementId and [role]=(select [Role] from tax.roles where  Id=amp.RoleId)) from Tax.Taxmenupermissions as amp Where TaxCompanyMenuMasterId=@acmmOldId

                FETCH NEXT FROM MenuSetUp INTO     @acmmOldId
             END     
              
        CLOSE MenuSetUp      
        DEALLOCATE MenuSetUp 
    End
	Commit Transaction;
	END TRY
BEGIN CATCH
	RollBack Transaction;
	DECLARE
	   @ErrorMessage NVARCHAR(4000),
	   @ErrorSeverity INT,
	   @ErrorState INT;
	   SELECT
	   @ErrorMessage = ERROR_MESSAGE(),
	   @ErrorSeverity = ERROR_SEVERITY(),
	   @ErrorState = ERROR_STATE();
	  RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH     
End
GO
