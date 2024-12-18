USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CC_WF_Delete]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  procedure [dbo].[CC_WF_Delete]

@CompanyId BigInt
as
begin 
Begin Try
--Declare @CompanyId BigInt=?

 ---EXEC dbo.CC_WF_Delete 10

--Common.TimeLogSchedule
Delete From TLDS From Common.TimeLogDetailSplit As TLDS
Inner Join Common.TimeLogDetail As TLD On TLD.Id=TLDS.TimelogDetailId
Inner Join Common.TimeLogSchedule As TLS On TLS.Id=TLD.TimeLogScheduleId
Inner Join WorkFlow.CaseGroup As CG On CG.Id=TLS.CaseId
Where CompanyId=@CompanyId

Delete From TLD From Common.TimeLogDetail As TLD 
Inner Join Common.TimeLogSchedule As TLS On TLS.Id=TLD.TimeLogScheduleId
Inner Join WorkFlow.CaseGroup As CG On CG.Id=TLS.CaseId
Where CompanyId=@CompanyId

Delete From TLS From Common.TimeLogSchedule As TLS 
Inner Join WorkFlow.CaseGroup As CG On CG.Id=TLS.CaseId
Where CompanyId=@CompanyId


Delete From TLD From Common.TimeLogDetail As TLD 
Inner Join Common.TimeLog As TL ON TL.ID=TLD.MasterId
Inner Join Common.TimeLogITEM As TLS On TLS.Id=TL.TimeLogItemId
Where TLS.CompanyId=@CompanyId


Delete From TL From Common.TimeLog As TL 
Inner Join Common.TimeLogITEM As TLS On TLS.Id=TL.TimeLogItemId
Where TLS.CompanyId=@CompanyId


Delete  From TLID FROM  Common.TimeLogItemDetail TLID 
Inner Join Common.TimeLogITEM As TLS On TLS.Id=TLID.TimeLogItemId
Where TLS.CompanyId=@CompanyId

Delete  From TLS  FROM Common.TimeLogITEM As TLS 
Where TLS.CompanyId=@CompanyId

--WorkFlow.CaseStatusChange
Delete From CS From WorkFlow.CaseStatusChange As CS 
Inner Join WorkFlow.CaseGroup As CG On CG.Id=CS.CaseId
Where CG.CompanyId=@CompanyId

Delete From WorkFlow.CaseStatusChange Where CompanyId=@CompanyId

--WorkFlow.Schedule
Delete From STD From WorkFlow.ScheduleTaskDetail As STD
Inner Join WorkFlow.ScheduleTask As ST On ST.Id=STD.ScheduleTaskId
Inner Join WorkFlow.ScheduleDetail As SD On SD.Id=ST.ScheduleDetailId
Inner Join WorkFlow.Schedule As S On S.Id=SD.MasterId
Where S.CompanyId=@CompanyId

Delete From ST From WorkFlow.ScheduleTask As ST 
Inner Join WorkFlow.ScheduleDetail As SD On SD.Id=ST.ScheduleDetailId
Inner Join WorkFlow.Schedule As S On S.Id=SD.MasterId
Where S.CompanyId=@CompanyId

Delete From SD From WorkFlow.ScheduleDetail As SD
Inner Join WorkFlow.Schedule As S On S.Id=SD.MasterId
Where S.CompanyId=@CompanyId

Delete From WorkFlow.Schedule Where CompanyId=@CompanyId

--WorkFlow.ScheduleTask
Delete From STD From WorkFlow.ScheduleTaskDetail As STD
Inner Join WorkFlow.ScheduleTask As ST On ST.Id=STD.ScheduleTaskId
Where ST.CompanyId=@CompanyId

Delete From WorkFlow.ScheduleTask Where CompanyId=@CompanyId

--WorkFlow.ScheduleTask
Delete From STD From WorkFlow.ScheduleTaskDetail As STD
Inner Join WorkFlow.ScheduleTask As ST On ST.Id=STD.ScheduleTaskId
Inner Join WorkFlow.CaseGroup As CG On CG.Id=ST.CaseId
Where CG.CompanyId=@CompanyId

Delete From ST From WorkFlow.ScheduleTask As ST
Inner Join WorkFlow.CaseGroup As CG On CG.Id=ST.CaseId
Where CG.CompanyId=@CompanyId

--WorkFlow.Invoice
Delete From ID From WorkFlow.InvoiceDesignation As ID
Inner Join WorkFlow.Invoice As I On i.Id=ID.InvoiceId
Where I.CompanyId=@CompanyId

Delete From ID From WorkFlow.InvoiceDesignation As ID
Inner Join WorkFlow.CaseGroup As CG On CG.Id=ID.CaseId
Where CG.CompanyId=@CompanyId

Delete From Incd From WorkFlow.Incidental As Incd
Inner Join WorkFlow.Invoice as I On I.Id=Incd.InvoiceId
Where I.CompanyId=@CompanyId

Delete From Invst From [WorkFlow].[InvoiceState] As Invst
Inner Join WorkFlow.Invoice As I On I.Id=Invst.InvoiceId
Where I.CompanyId=@CompanyId

Delete From I From WorkFlow.Invoice As I 
Inner Join WorkFlow.CaseGroup as CG On CG.Id=i.CaseId
Where CG.CompanyId=@CompanyId

Delete From WorkFlow.Invoice Where CompanyId=@CompanyId


--[WorkFlow].[IncidentalClaimItem]
Delete From Incd From WorkFlow.Incidental As Incd
Inner Join WorkFlow.IncidentalClaimItem As ICI On ICI.Id=Incd.ClaimItemId
Where ICI.CompanyId=@CompanyId

Delete From WorkFlow.IncidentalClaimItem Where CompanyId=@CompanyId

--WorkFlow.CaseFeature
Delete From TDS From Common.TimeLogDetailSplit As TDS
Inner Join WorkFlow.CaseFeature As CF On CF.Id=TDS.CaseFeatureId
Inner Join WorkFlow.CaseGroup As CG On CG.Id=CF.CaseId
Where CG.CompanyId=@CompanyId

Delete From STD From WorkFlow.ScheduleTaskDetail As STD
Inner Join WorkFlow.CaseFeature as CF On CF.Id=STD.CaseFeatureId
Inner Join WorkFlow.CaseGroup As CG On CG.Id=CF.CaseId
Where CG.CompanyId=@CompanyId

Delete From CF From WorkFlow.CaseFeature As CF 
Inner Join WorkFlow.CaseGroup As CG On CG.Id=CF.CaseId
Where CG.CompanyId=@CompanyId

--WorkFlow.CaseIncharge
Delete From CI From WorkFlow.CaseIncharge As CI
Inner Join WorkFlow.CaseGroup As CG On CG.Id=CI.CaseId
Where CG.CompanyId=@CompanyId

--WorkFlow.CaseDesignation
Delete From CD From WorkFlow.CaseDesignation As CD
Inner Join WorkFlow.CaseGroup As CG On CG.Id=CD.CaseId
Where CG.CompanyId=@CompanyId

--WorkFlow.CaseAmendDateOfCompletion
Delete From CCADC From WorkFlow.CaseAmendDateOfCompletion As CCADC 
Inner Join WorkFlow.CaseGroup As CG On CG.Id=CCADC.CaseId
Where CG.CompanyId=@CompanyId



--WorkFlow.CaseMileStone
Delete From CMS From WorkFlow.CaseMileStone As CMS
Inner Join WorkFlow.CaseGroup As CG On CG.Id=CMS.CaseId
Where CG.CompanyId=@CompanyId

--WorkFlow.CasesAssigned
Delete From CA From WorkFlow.CasesAssigned As CA 
Inner Join WorkFlow.CaseGroup As CG On CG.Id=CA.CaseId
Where CG.CompanyId=@CompanyId

--WorkFlow.Claim

Delete From C From WorkFlow.Claim As C
Inner Join WorkFlow.CaseGroup As CG On CG.Id=C.CaseId
Where CG.CompanyId=@CompanyId

Delete From WorkFlow.Claim Where CompanyId=@CompanyId



--HR.EmployeeClaim1
Delete From ECD From HR.EmployeeClaimDetail As ECD
Inner Join HR.EmployeeClaim1 As EC On EC.Id=ECD.EmployeeClaimId
Inner Join WorkFlow.CaseGroup As CG On CG.Id=EC.CaseGroupId
Where CG.CompanyId=@CompanyId

Delete From EC From HR.EmployeeClaim1 As EC 
Inner Join WorkFlow.CaseGroup As CG On CG.Id=EC.CaseGroupId
Where CG.CompanyId=@CompanyId


--WorkFlow.CaseGroup
Delete From WorkFlow.CaseGroup Where CompanyId=@CompanyId

--ClientCursor.QuotationSummaryDetails
DELETE FROM A
FROM ClientCursor.Quotation AI
Inner Join ClientCursor.QuotationSummaryDetails A ON AI.Id=A.QuotationId
Where AI.CompanyId=@CompanyId

--ClientCursor.QuotationDetailTemplate
DELETE FROM DT
FROM ClientCursor.Quotation AI
Inner Join ClientCursor.QuotationDetail A ON AI.Id=A.MasterId
Inner Join ClientCursor.QuotationDetailTemplate DT ON DT.QuotationDetailId=A.Id
Where AI.CompanyId=@CompanyId

--ClientCursor.QuotationDetail
DELETE FROM A
FROM ClientCursor.Quotation AI
Inner Join ClientCursor.QuotationDetail A ON AI.Id=A.MasterId
Where AI.CompanyId=@CompanyId

--ClientCursor.QuotationHistory
DELETE FROM A
FROM ClientCursor.Quotation AI
Inner Join ClientCursor.QuotationHistory A ON AI.Id=A.QuotationId
Where AI.CompanyId=@CompanyId

--ClientCursor.Quotation
DELETE FROM AI
FROM ClientCursor.Quotation AI
Inner Join [ClientCursor].[Account] A ON AI.AccountId=A.Id
Where A.CompanyId=@CompanyId

--ClientCursor.OpportunityDesignation
DELETE From OD 
From ClientCursor.OpportunityDesignation OD
Inner Join ClientCursor.Opportunity O ON O.Id=OD.OpportunityId
Where O.CompanyId=@CompanyId 

--ClientCursor.OpportunityHistory
DELETE From OH From ClientCursor.OpportunityHistory OH
Inner Join ClientCursor.Opportunity O ON O.Id=OH.OpportunityId
Where O.CompanyId=@CompanyId

--ClientCursor.OpportunityIncharge
DELETE From OI From ClientCursor.OpportunityIncharge OI
Inner Join ClientCursor.Opportunity O ON O.Id=OI.OpportunityId
Where O.CompanyId=@CompanyId

--ClientCursor.OpportunityStatusChange
DELETE From OSC From ClientCursor.OpportunityStatusChange OSC
Inner Join ClientCursor.Opportunity O ON O.Id=OSC.OpportunityId
Where O.CompanyId=@CompanyId 

--ClientCursor.OpportunityDoc
DELETE From OD From ClientCursor.OpportunityDoc OD
Inner Join ClientCursor.Opportunity O ON O.Id=OD.OpportunityId
Where O.CompanyId=@CompanyId 

--ClientCursor.OpportunityTermsCondition
DELETE From OTC From ClientCursor.OpportunityTermsCondition OTC
Inner Join ClientCursor.Opportunity O ON O.Id=OTC.OpportunityId
Where O.CompanyId=@CompanyId 

--ClientCursor.Opportunity
Delete From ClientCursor.Opportunity WHERE CompanyId=@CompanyId

End Try
Begin Catch
Select ERROR_MESSAGE()

End Catch
end 
GO
