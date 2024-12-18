USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Delete_WFData_CompanyIdWise]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec Delete_WFData_CompanyIdWise 10
Create procedure [dbo].[Delete_WFData_CompanyIdWise] 
@CompanyId Bigint
As
Begin

--1)Incidental
delete from [WorkFlow].[Incidental] where ClaimItemId in
(
	select ID from [WorkFlow].[IncidentalClaimItem] where CompanyId=@CompanyId --2
)
and InvoiceId in
(
	select Id from WorkFlow.Invoice where CompanyId=@CompanyId and CaseId in --1
	(
		select id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
		(
			select Id from WorkFlow.Client where CompanyId=@CompanyId --3
		)
	)
)

--2)IncidentalClaimItem 2
delete from [WorkFlow].[IncidentalClaimItem] where CompanyId=@CompanyId 
--Claim 0

delete from WorkFlow.Claim where CompanyId=@CompanyId and CaseId in
(
	select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
		select Id from WorkFlow.Client where CompanyId=@CompanyId  --3
	)
)

--3)InvoiceDesignation 5
delete from WorkFlow.InvoiceDesignation where InvoiceId in 
(
	select Id from WorkFlow.Invoice where CompanyId=@CompanyId and CaseId in --1
	(
		select id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
		(
			select Id from WorkFlow.Client where CompanyId=@CompanyId --3
		)
	)
) 
and CaseId in
(
	select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
	   select Id from WorkFlow.Client where CompanyId=@CompanyId  --3
	)
)

--4)InvoiceState 0
delete from WorkFlow.InvoiceState where InvoiceId in
(
	select Id from WorkFlow.Invoice where CompanyId=@CompanyId and CaseId in --1
	(
		select id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
		(
			select Id from WorkFlow.Client where CompanyId=@CompanyId --3
		)
	)
)

--5)invoices --1
delete from WorkFlow.Invoice where CompanyId=@CompanyId and CaseId in
(
	select id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
		select Id from WorkFlow.Client where CompanyId=@CompanyId --3
	)
)

--6)[CaseAmendDateOfCompletion] --0
delete from [WorkFlow].[CaseAmendDateOfCompletion] where caseId  in
(
	select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
		select Id from WorkFlow.Client where CompanyId=@CompanyId --3
	)

)

--7)CaseDesignation  153
delete from [WorkFlow].[CaseDesignation] where CaseId in
(
	select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
		select Id from WorkFlow.Client where CompanyId=@CompanyId --3
	)

)

--8)CaseDoc --0
delete from WorkFlow.CaseDoc where CompanyId=@CompanyId and caseid in
(
	select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
		select Id from WorkFlow.Client where CompanyId=@CompanyId --3
	)
)

--9)CaseIncharge  26
delete  from [WorkFlow].[CaseIncharge] where CaseId in
(
	select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
		select Id from WorkFlow.Client where CompanyId=@CompanyId --3
	)

)

--10)CaseLikelihoodHistory  --0
delete from [WorkFlow].[CaseLikelihoodHistory] where CaseId in
(
	select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
		select Id from WorkFlow.Client where CompanyId=@CompanyId --3
	)

)

--11)CasesAssigned 0
delete from [WorkFlow].[CasesAssigned] where CaseId in
(
	select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
		select Id from WorkFlow.Client where CompanyId=@CompanyId --3
	)

)

--12)CaseStatusChange 231
delete from [WorkFlow].[CaseStatusChange] where CompanyId=@CompanyId and CaseId in
(
	select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
		select Id from WorkFlow.Client where CompanyId=@CompanyId --3
	)

)

--13)ScheduleDetail 131
delete from WorkFlow.ScheduleDetail where MasterId in 
(
	select Id from WorkFlow.Schedule where CompanyId=@CompanyId and CaseId in --20
	(
		select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
		(
			select Id from WorkFlow.Client where CompanyId=@CompanyId --3
		)

	)
)

--14)Schedule 20
delete from WorkFlow.Schedule where CompanyId=@CompanyId and CaseId in
(
	select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
		select Id from WorkFlow.Client where CompanyId=@CompanyId --3
	)
)

--15)ScheduleTaskDetail  --0
delete from WorkFlow.ScheduleTaskDetail where ScheduleTaskId in
(
	select Id from WorkFlow.ScheduleTask where CompanyId=@CompanyId and CaseId in --1240
	(
		select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
		(
			select Id from WorkFlow.Client where CompanyId=@CompanyId --3
		)
	)
)

--16)ScheduleTask 1240
delete from WorkFlow.ScheduleTask where CompanyId=@CompanyId and CaseId in
(
	select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
		select Id from WorkFlow.Client where CompanyId=@CompanyId --3
	)
)

--17)CaseFeature --0
delete from [WorkFlow].[CaseFeature] where CaseId in
(
	select Id from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in --20
	(
		select Id from WorkFlow.Client where CompanyId=@CompanyId  --3
	)

)
--18)cases --20
delete from WorkFlow.CaseGroup  where CompanyId=@CompanyId and ClientId in 
(
	select Id from WorkFlow.Client where CompanyId=@CompanyId --3
)

--19)client contacts --1 or 3
delete  from WorkFlow.ClientContact where ClientId in --3
(
	select id from WorkFlow.Client where CompanyId=@CompanyId --3

)

--20) Client Status Change --3
delete from WorkFlow.ClientStatusChange where CompanyId=@CompanyId and ClientId in
(
	select Id from WorkFlow.Client where CompanyId=@CompanyId --3
)

--21)clients--3
delete from WorkFlow.Client where CompanyId=@CompanyId 

End
GO
