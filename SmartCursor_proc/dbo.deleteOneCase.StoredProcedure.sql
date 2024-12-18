USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[deleteOneCase]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[deleteOneCase] 
@casenumber nvarchar(250),
@companyId bigint

As
 Begin
  declare @caseId Uniqueidentifier,
  @schId Uniqueidentifier,
  @timelogitemId Uniqueidentifier
set @caseId=(select id from  WorkFlow.CaseGroup   where CaseNumber=@casenumber and CompanyId=@companyId)

delete from  WorkFlow.CaseIncharge where CaseId=@caseId
delete from WorkFlow.CaseLikelihoodHistory where  CaseId=@caseId
delete from WorkFlow.CaseMileStone where CaseId=@caseId
delete from WorkFlow.CasesAssigned where CaseId=@caseId
delete from WorkFlow.CaseAmendDateOfCompletion where CaseId=@caseId
delete from WorkFlow.CaseDesignation where CaseId=@caseId
delete from WorkFlow.CaseDoc where CaseId=@caseId
set @timelogitemId=(select Id from Common.TimeLogItem where SystemId=@caseId)
delete from Common.TimeLogItemDetail where TimeLogItemId=@timelogitemId
delete from Common.TimeLogItem where SystemId=@caseId
delete from WorkFlow.CaseStatusChange where CaseId=@caseId
delete from WorkFlow.Claim where CaseId=@caseId
delete from WorkFlow.InvoiceDesignation where CaseId=@caseId
delete from WorkFlow.Invoice where CaseId=@caseId
set @schId=(select sc.Id from WorkFlow.Schedule  as sc where CaseId=@caseId)
delete from WorkFlow.ScheduleDetail where MasterId=@schId
delete from WorkFlow.ScheduleTask where CaseId=@caseId
delete from WorkFlow.Schedule where CaseId=@caseId
delete from WorkFlow.CaseGroup where Id=@caseId
end


GO
