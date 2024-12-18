USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_MenuSetupandPermissionsInsertionforEngagement]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--added helilink reference id

CREATE
Procedure [dbo].[Audit_MenuSetupandPermissionsInsertionforEngagement](@PartnerCompanyId Bigint,@CompanyId Bigint,@EngagementId uniqueidentifier,@EngagementTypeId Nvarchar(100),@AdditionalReview1 Nvarchar(100),    @AdditionalReview2 Nvarchar(100),@AuditManualId uniqueidentifier)
AS Begin
    Declare @acmmId Uniqueidentifier;
    Declare @TypeId Uniqueidentifier;
    DECLARE @acmmOldId UNIQUEIDENTIFIER      
    If Not Exists (Select * from audit.auditcompanymenumaster where companyid=@CompanyId and engagementid=@EngagementId  and Engagementtype=@EngagementTypeId and AuditManualId=@AuditManualId)
    Begin        
        DECLARE MenuSetUp CURSOR FOR SELECT Id FROM Audit.auditcompanymenumaster where companyid=@PartnerCompanyId and engagementid is null  and EngagementTypeId=@EngagementTypeId and AuditManualId=@AuditManualId and Ishide=0;
          OPEN  MenuSetUp       
             FETCH NEXT FROM MenuSetUp INTO  @acmmOldId
             WHILE (@@FETCH_STATUS=0)      
             BEGIN      
                
                Set @acmmId =newid();
                set @TypeId=(select id from Audit.WPSetup where EngagementId=@EngagementId and ReferenceId =(select typeid from Audit.AuditCompanyMenuMaster where id=@acmmOldId))
                    Insert into audit.auditcompanymenumaster (Id,CompanyId,EngagementId,AuditMenuMasterId,Code,Heading,IsHide,TemplateName,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,AdditionalReview1,AdditionalReview2,IsCompilation,EngagementType,HelpLinkReferenceId,IsFolderCreated,TypeId,EngagementTypeId,AuditManualId)  
                select @acmmId,@CompanyId,@EngagementId,parentmm.AuditMenuMasterId,parentmm.Code,parentmm.Heading,parentmm.IsHide,parentmm.TemplateName,parentmm.RecOrder,parentmm.Remarks,parentmm.UserCreated,parentmm.CreatedDate,parentmm.ModifiedBy,parentmm.ModifiedDate,parentmm.Version,parentmm.Status,@AdditionalReview1,@AdditionalReview2,parentmm.IsCompilation,parentmm.EngagementType,parentmm.HelpLinkReferenceId,1,@TypeId,parentmm.EngagementTypeId,parentmm.AuditManualId from Audit.auditcompanymenumaster as parentmm where parentmm.Id=@acmmOldId


                Insert into Audit.auditmenupermissions (Id,AuditCompanyMenuMasterId,[Role],[View],[Add],Edit,[Disable],Lock,Prepared,Reviewed,DeleteDocument,Actions,RoleId)
                select Newid(),@acmmId,amp.[Role],amp.[View],amp.[Add],amp.Edit,amp.[Disable],amp.Lock,amp.Prepared,amp.Reviewed,amp.DeleteDocument,amp.Actions,amp.RoleId from Audit.auditmenupermissions as amp Where AuditCompanyMenuMasterId=@acmmOldId
                
                FETCH NEXT FROM MenuSetUp INTO     @acmmOldId
             END     
              
        CLOSE MenuSetUp      
        DEALLOCATE MenuSetUp 


        Insert into Audit.EngagementHistory (Id,EngagementId,SeedDataType,SeedDataStatus,Recorder)  Values (NewId(),@EngagementId,'MenuSetupAndPermissionsInserted','Success',1) 
    End
End
GO
