USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Insert_NewReOpening_Opportunity]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Insert_NewReOpening_Opportunity] -- EXEC [dbo].[Insert_NewReOpening_Opportunity]    
@OpportunityId Uniqueidentifier ,    
@User Nvarchar(200)    
    
AS     
BEGIN    
    
DECLARE     
 @NewReOpeningOpp uniqueidentifier = NEWID()    
    
        
    
--SELECT * FROM @ServiceRecurring    
    
--SELECT Id,NextFromDate,NextToDate,ReOpeningDate FROM ClientCursor.Opportunity WHERE Id = @OpportunityId    
    
    
DECLARE     
 @ReOpening DATETIME2,    
 @NextFromDate DateTime2,    
 @NextToDate DateTime2    
    
    
    
    
--SET @NextFromDate =    
--(    
--SELECT    
-- CASE     
-- WHEN B.Frequency = 'Monthly' THEN DATEADD(MM,1,FromDate)    
-- WHEN B.Frequency = 'Quarterly' THEN DATEADD(MM,3,FromDate)    
-- WHEN B.Frequency = 'Semi-annually' THEN DATEADD(MM,6,FromDate)    
-- WHEN B.Frequency = 'Annually' THEN DATEADD(YEAR,1,FromDate)    
-- END as NextFromDate    
--FROM    
-- ClientCursor.Opportunity B    
 
--WHERE     
-- B.Id = @OpportunityId    
--)    
    
   SET @NextFromDate =  (select DATEADD(DD,1,NextToDate) from clientcursor.opportunity where Id=@OpportunityId) 
declare @NextToDate1 datetime2
SET @NextToDate1 =    
(    
SELECT    
 CASE     
 WHEN A.Frequency = 'Monthly' THEN DATEADD(MM,1,@NextFromDate)    
 WHEN A.Frequency = 'Quarterly' THEN DATEADD(MM,3,@NextFromDate)    
 WHEN A.Frequency = 'Semi-annually' THEN DATEADD(MM,6,@NextFromDate)    
 WHEN A.Frequency = 'Annually' THEN DATEADD(YEAR,1,@NextFromDate)    
 END as NextFromDate    
FROM    
 ClientCursor.Opportunity A    
   
WHERE     
 A.Id = @OpportunityId    
) 

set @NextToDate = (select DATEADD(DD,-1,@NextToDate1))


SET @ReOpening =     
(    
SELECT     
 CASE     
 WHEN FromToDate = 'From Date(New Service Period)' AND OperatorSymbol = '+' AND Frequency = 'Monthly' THEN DATEADD(DD,NoOfDays,@NextFromDate)     
 WHEN FromToDate = 'From Date(New Service Period)' AND OperatorSymbol = '-' AND Frequency = 'Monthly' THEN DATEADD(DD,-NoOfDays,@NextFromDate)     
 WHEN FromToDate = 'To Date(New Service Period)' AND OperatorSymbol = '+' AND Frequency = 'Monthly' THEN DATEADD(DD,NoOfDays,@NextToDate)     
 WHEN FromToDate = 'To Date(New Service Period)' AND OperatorSymbol = '-' AND Frequency = 'Monthly' THEN DATEADD(DD,-NoOfDays,@NextToDate)     
 WHEN FromToDate = 'From Date(New Service Period)' AND OperatorSymbol = '+' AND Frequency = 'Quarterly' THEN DATEADD(DD,NoOfDays,@NextFromDate)     
 WHEN FromToDate = 'From Date(New Service Period)' AND OperatorSymbol = '-' AND Frequency = 'Quarterly' THEN DATEADD(DD,-NoOfDays,@NextFromDate)     
 WHEN FromToDate = 'To Date(New Service Period)' AND OperatorSymbol = '+' AND Frequency = 'Quarterly' THEN DATEADD(DD,NoOfDays,@NextToDate)     
 WHEN FromToDate = 'To Date(New Service Period)' AND OperatorSymbol = '-' AND Frequency = 'Quarterly' THEN DATEADD(DD,-NoOfDays,@NextToDate)    
 WHEN FromToDate = 'From Date(New Service Period)' AND OperatorSymbol = '+' AND Frequency = 'Semi-annually' THEN DATEADD(DD,NoOfDays,@NextFromDate)     
 WHEN FromToDate = 'From Date(New Service Period)' AND OperatorSymbol = '-' AND Frequency = 'Semi-annually' THEN DATEADD(DD,-NoOfDays,@NextFromDate)     
 WHEN FromToDate = 'To Date(New Service Period)' AND OperatorSymbol = '+' AND Frequency = 'Semi-annually' THEN DATEADD(DD,NoOfDays,@NextToDate)     
 WHEN FromToDate = 'To Date(New Service Period)' AND OperatorSymbol = '-' AND Frequency = 'Semi-annually' THEN DATEADD(DD,-NoOfDays,@NextToDate)    
 WHEN FromToDate = 'From Date(New Service Period)' AND OperatorSymbol = '+' AND Frequency = 'Annually' THEN DATEADD(DD,NoOfDays,@NextFromDate)     
 WHEN FromToDate = 'From Date(New Service Period)' AND OperatorSymbol = '-' AND Frequency = 'Annually' THEN DATEADD(DD,-NoOfDays,@NextFromDate)     
 WHEN FromToDate = 'To Date(New Service Period)' AND OperatorSymbol = '+' AND Frequency = 'Annually' THEN DATEADD(DD,NoOfDays,@NextToDate)     
 WHEN FromToDate = 'To Date(New Service Period)' AND OperatorSymbol = '-' AND Frequency = 'Annually' THEN DATEADD(DD,-NoOfDays,@NextToDate)    
 END AS ReOpen    
FROM    
 ClientCursor.Opportunity A    
 
WHERE     
 A.Id = @OpportunityId    
    
)



    
INSERT INTO ClientCursor.Opportunity    
SELECT     
 @NewReOpeningOpp as Id,    
 Name,    
 CompanyId,    
 AccountId,    
 ServiceCompanyId,    
 ServiceGroupId,    
 ServiceId,    
 NULL as QuoteNumber,    
 'ReOpening' as Type,    
 ' ' as Stage,    
 Nature,    
 NextFromDate as FromDate,    
 NextToDate as ToDate,    
 Reopen as ReOpen,    
 Frequency,    
 FeeType,    
 Fee,    
 Currency,    
 RecommendedFee,    
 RecoCurrency,    
 NULL as TargettedRecovery,    
 NULL as TotalEstdHours,    
 NULL as SpecialRemarks,    
 NULL as RecOrder,    
 NULL as Remarks,    
 @User as UserCreated,    
 GETDATE() as CreatedDate,    
 NULL as ModifiedBy,    
 NULL as ModifiedDate,    
 NULL as Version,    
 Status,    
 IsRecurring,    
 IsAdHoc,    
 'Temp'+'-'+OpportunityNumber as OpportunityNumber,    
 RecurringScopeofWork,    
 ReportPath,    
 ScopeOfWork,    
 StandardTerms,    
 KeyTerms,    
 NULL as KeyTemplateContent,    
 NULL as IsModify,    
 StandardTemplateContent,    
 MainServiceFee,    
 SubServiceFee,    
 @NextFromDate as NextFromDate,    
 @NextToDate as NextToDate,    
 NULL as CaseId,    
 id as ParentId,    
 NULL as ReasonForCancellation,    
 NULL as MainServiceId,    
 NULL as SubServiceId,    
 NULL as OpportunityRemarks,    
 IsEnableKeyTerms,    
 IsEnableStandardTerms,    
 NULL as StandardTemplateName,    
 KeyTemplateName,    
 IsCreatedBeforeWorkflowActivate,    
 1 as IsAccount,    
 1 as IsTemp,    
 @ReOpening as ReOpeningDate,    
 NULL as SyncCaseId,    
 NULL as SyncCaseStatus,    
 NULL as SyncCaseDate,    
 NULL as SyncCaseRemarks,    
 OppNumberFormat,    
 BaseCurrency,    
 BaseFee,    
 DocToBaseExhRate,    
 IsMultiCurrency,    
 NULL as IsPrecedingAuditor,    
 NULL as IsSucceedingAuditor,    
 NULL as IsAssuranceResignationDate,    
 NULL as IsReasonForResignation,    
 NULL as PrecedingAuditor,    
 NULL as SucceedingAuditor,    
 NULL as AssuranceResignationDate,    
 NULL as ReasonForResignation,    
 NULL as IsAdditionalSettings,    
 IsOpportunityReopen ,
 period,
 NoOfDays,
 FromToDate,
 OperatorSymbol
 
FROM     
 ClientCursor.Opportunity WHERE Id = @OpportunityId    


	---------------------------------------- Audit Logs Insertion ----------------------------------------
   Declare @CompanyId Bigint;
   SET @CompanyId= (SELECT CompanyId FROM ClientCursor.Opportunity WHERE Id= @OpportunityId)
   EXEC [dbo].[InsertAuditSyncing] @NewReOpeningOpp, '00000000-0000-0000-0000-000000000000','Pending',@CompanyId,'CC Opportunity','WF Cases','ReOpen',NULL,NULL,NULL,NULL,NULL
   ---------------------------------------- Audit Logs Insertion ----------------------------------------
    
    
INSERT INTO ClientCursor.OpportunityIncharge    
SELECT     
 NEWID() as Id,    
 @NewReOpeningOpp as OpportunityId,    
 IsPrimary,    
 RecOrder,    
 @User as UserCreated,    
 GETDATE() as CreatedDate,    
 NULL as ModifiedBy,    
 NULL as ModifiedDate,    
 Version,    
 Status,    
 CompanyUserId    
FROM    
 ClientCursor.OpportunityIncharge     
WHERE    
 OpportunityId = @OpportunityId    
    
    
INSERT INTO ClientCursor.OpportunityDesignation    
SELECT     
 NEWID() as Id,    
 @NewReOpeningOpp as OpportunityId,    
 DefaultRate,    
 Currency,    
 BillingRate,    
 BillCurrency,    
 EstdHours,    
 RecOrder,    
 Status,    
 Designation,    
 Rate,    
 DepartmentId,    
 DepartmentDesignationId    
FROM     
 ClientCursor.OpportunityDesignation     
WHERE    
 OpportunityId = @OpportunityId    
  
 INSERT INTO ClientCursor.OpportunityStatusChange        
VALUES        
(        
 NEWID(),(select CompanyId from clientcursor.Opportunity where Id=@OpportunityId),@NewReOpeningOpp, '',@User, GETDATE()        
)   
    
    
END  
  
  
GO
