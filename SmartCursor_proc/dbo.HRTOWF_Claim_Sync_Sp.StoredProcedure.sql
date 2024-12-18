USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HRTOWF_Claim_Sync_Sp]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   procedure [dbo].[HRTOWF_Claim_Sync_Sp]      
@Claimsdata Nvarchar(Max)      
      
As      
Begin      
 Declare @New_ClaimId Uniqueidentifier,      
   @Max_recorder bigint,         
   @SyncHRClaimId Uniqueidentifier,      
   @ClaimRecordStatus Nvarchar(20),      
   @CompanyId bigint,     
   @YearId  Uniqueidentifier,                      
   @Count Int,      
   @Item nvarchar(250),      
   @Id Nvarchar(250) ,  
   @IsSplit bit         
      
Declare IDSplit_CSR Cursor For      
    Select items from dbo.SplitToTable(@Claimsdata,';')      
    Open IDSplit_CSR      
    Fetch Next From IDSplit_CSR Into @Item      
    While @@FETCH_STATUS=0      
    Begin      
      
      Set @Count=0      
      
   Declare ItemSolit_CSR Cursor For      
   Select items from dbo.SplitToTable(@Item,',')      
   Open ItemSolit_CSR      
   Fetch Next From ItemSolit_CSR Into @Id      
   While @@FETCH_STATUS=0      
   Begin      
   Set @Count=@Count+1      
    If @Count=1      
    Begin      
    Set @SyncHRClaimId=Cast(@Id As Uniqueidentifier)      
    End      
    If @Count=2      
    Begin      
    Set @ClaimRecordStatus=@Id      
    End           
    If @Count=3      
    Begin      
    Set @CompanyId=Cast(@Id As int)      
    End       
    If @Count=4      
    Begin      
    Set @YearId=Cast(@Id As Uniqueidentifier)      
    End  
   Fetch Next From ItemSolit_CSR Into @Id      
   End      
      
      Close ItemSolit_CSR       
      Deallocate ItemSolit_CSR      
      
      
     If @ClaimRecordStatus='Added'      
     Begin  
	  If  Exists(select Id from WorkFlow.Claim where SyncHRClaimId=@SyncHRClaimId)      
         Begin       
     Delete WorkFlow.Claim where SyncHRClaimId=@SyncHRClaimId      
      End      
      If Not Exists(select Id from WorkFlow.Claim where SyncHRClaimId=@SyncHRClaimId)      
       begin       
         Set @Max_recorder= (select max(RecOrder) from WorkFlow.Claim where CompanyId=@CompanyId)      
         Set @New_ClaimId=NewId()      
      
         Insert Into WorkFlow.Claim (Id,CompanyId,CaseId,ClaimDate,Category,Item,Descriptions,Amount,Currency,IsSystem,IsSystemId,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,HrStatus,ClaimantName,ClaimNumber,SyncHRClaimId,SyncHRClaimStatus,SyncHRClaimDate,SyncHRClaimRemarks,RecOrder,  
   EmployeeId,ClaimYearId,SyncHRClaimParentId,BaseCurrency,BaseAmount,DocToBaseExhRate)       
      
       select @New_ClaimId,ec.ParentCompanyId,ec.CaseGroupId,ecd.ClaimDate,inc.Category,inc.Item,null,  
    (ecd.ApprovedAmount * ecd.JurToWFDocExhRate),cg.Currency,1,null,ec.Remarks,ec.UserCreated,ec.CreatedDate,ec.ModifiedBy,ec.ModifiedDate,null,  
    1,ec.ClaimStatus,e.FirstName,ec.ClaimNumber,ecd.Id,'Completed',GETUTCDATE(),null,@Max_recorder,ec.EmployeId,@YearId,ec.id,cg.BaseCurrency,(ecd.ApprovedAmount * ecd.WFDocToBaseExhRate),ecd.WFDocToBaseExhRate   
    from Hr.EmployeeClaim1 as ec   
    join hr.EmployeeClaimDetail as ecd on ec.Id=ecd.EmployeeClaimId   
    join WorkFlow.IncidentalClaimItem  as inc on ecd.IncidentalClaimItemId=inc.Id      
       join Common.Employee as e on ec.EmployeId=e.Id   
    left join WorkFlow.CaseGroup as cg on ec.CaseGroupId = cg.Id   
    where ecd.Id=@SyncHRClaimId      
      
      
       update hr.EmployeeClaimDetail set SyncWFClaimId=@New_ClaimId,SyncWFClaimDate=GETUTCDATE(),SyncWFClaimStatus='Completed' where Id=@SyncHRClaimId      
      
        End        
     End      
  
  
   If @ClaimRecordStatus='Modified'      
      Begin      
      set @IsSplit =(Select IsSplit from Hr.EmployeeClaimDetail where Id = @SyncHRClaimId)  
  
   If @IsSplit = 1  
   Begin  
          If  Exists(select Id from WorkFlow.Claim where SyncHRClaimId=@SyncHRClaimId)      
                Begin       
                      Delete WorkFlow.Claim where SyncHRClaimId=@SyncHRClaimId      
                End      
   End  
  
   If @IsSplit = 0  
   Begin  
         If  Exists(select Id from WorkFlow.Claim where SyncHRClaimId=@SyncHRClaimId)      
         Begin       
      
         update  A set A.ClaimDate=B.ClaimDate,A.Category=B.Category,A.Item=B.Item,A.Descriptions=B.Description,A.Amount=B.ApprovedAmount,      
     A.ModifiedBy=B.ModifiedBy,A.ModifiedDate=B.ModifiedDate,A.HrStatus=B.ClaimStatus,A.BaseAmount=B.BaseAmount,A.DocToBaseExhRate=B.WFDocToBaseExhRate      
                    from WorkFlow.Claim as A join      
                   (select ecd.Id,ecd.ClaimDate,ecd.Description,inc.Category,inc.Item,(ecd.ApprovedAmount * ecd.JurToWFDocExhRate) as ApprovedAmount,ecd.Currency,ec.ModifiedBy,ec.ModifiedDate,ec.ClaimStatus,(ecd.ApprovedAmount * ecd.WFDocToBaseExhRate) as
 BaseAmount,  
       ecd.WFDocToBaseExhRate from  Hr.EmployeeClaim1 as ec join hr.EmployeeClaimDetail as ecd on ec.Id=ecd.EmployeeClaimId join WorkFlow.IncidentalClaimItem  as inc on ecd.IncidentalClaimItemId=inc.Id where ecd.Id=@SyncHRClaimId ) as B on A.SyncHRClaimId
=B.Id    
       where B.Id =@SyncHRClaimId         
      
         End    
    End    
  
     End      
  
  
            
          If @ClaimRecordStatus='Deleted'      
          Begin      
         If  Exists(select Id from WorkFlow.Claim where SyncHRClaimId=@SyncHRClaimId)      
         Begin       
     Delete WorkFlow.Claim where SyncHRClaimId=@SyncHRClaimId      
      End      
      End     
	  
--------------------------AuditLog Syncing New code Start----------------------------------------------
Declare @Empcliamid uniqueidentifier;
Declare @ClaimStatus Nvarchar(Max);
Declare @WfClaimId nvarchar(Max);
Declare @Empdetailid nvarchar(Max);
--SET @WfClaimId =(Select Id from WorkFlow.Claim where SyncHRClaimId='61BC71FD-44F9-4438-BCC7-612A860B5D1E');
--SELECT @WfClaimId = STRING_AGG(CONVERT(NVARCHAR(MAX), syncwfclaimid), ',')
--                    FROM HR.EmployeeClaimDetail WHERE employeeclaimid =@SyncHRClaimId ;
SET @Empcliamid =(Select EmployeeClaimId from HR.EmployeeClaimDetail where id=@SyncHRClaimId);
Set @ClaimStatus=(Select HrStatus from WorkFlow.Claim where SyncHRClaimId=@SyncHRClaimId )
----------------------------------------------
Set @Empdetailid =(select cld.EmployeeClaimId from HR.EmployeeClaim1 cli join HR.EmployeeClaimDetail cld
                     on cli.Id=cld.EmployeeClaimId where cld.Id=@SyncHRClaimId);
set @WfClaimId= (select STRING_AGG(CONVERT(NVARCHAR(MAX), syncwfclaimid), ',') from hr.EmployeeClaimDetail where employeeclaimid=@Empdetailid);
EXEC [dbo].[UpdateAuditSyncing] @Empcliamid,@WfClaimId,'Success',@ClaimStatus,Null,Null,Null,Null,Null,'HR Claim','WF Claim'
 
-----------------------------------AuditLog Syncing New END----------------------------------------------------------------
            
      
 Fetch Next From IDSplit_CSR Into @Item      
 End      
      
 Close IDSplit_CSR      
 Deallocate IDSplit_CSR      
      
      ---------------------Catch Block Code ----
	  --END TRY
    --BEGIN CATCH
        -- Error handling block
  --      DECLARE @ErrorMessage NVARCHAR(MAX);
  --      DECLARE @ErrorSeverity INT;
  --      DECLARE @ErrorState INT;
 
  --      SELECT 
  --          @ErrorMessage = ERROR_MESSAGE(),
  --          @ErrorSeverity = ERROR_SEVERITY(),
  --          @ErrorState = ERROR_STATE();
 
  --      -- Rollback any transactions if necessary
  --      -- Log error details or take appropriate action
  --      PRINT 'Error Message: ' + @ErrorMessage;
  --      PRINT 'Error Severity: ' + CAST(@ErrorSeverity AS NVARCHAR(10));
  --      PRINT 'Error State: ' + CAST(@ErrorState AS NVARCHAR(10));
 
		--EXEC [dbo].[UpdateAuditSyncing] @Empcliamid,@WfClaimId,'Failed',@ClaimStatus,'Low','NULL','NULL',@ErrorMessage,'NULL'
        -- Optionally re-throw the error
        -- THROW;
  --  END CATCH;
      -------------Catch Block Code End-------------------------------------------------
End  
GO
