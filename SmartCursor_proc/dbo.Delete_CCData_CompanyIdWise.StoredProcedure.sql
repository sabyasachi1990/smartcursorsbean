USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Delete_CCData_CompanyIdWise]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec Delete_CCData_CompanyIdWise 10
Create Procedure [dbo].[Delete_CCData_CompanyIdWise]
@CompanyId Bigint

As
Begin
--1)ReminderDetailTemplate 2
delete from [ClientCursor].[ReminderDetailTemplate] where ReminderDetailId in
(
	select ID from [ClientCursor].[ReminderDetail] where ReminderMasterId in
	(
		select Id from [ClientCursor].[ReminderMaster] where CompanyId=@CompanyId
	)
)

--2)ReminderDetail 2
delete from [ClientCursor].[ReminderDetail] where ReminderMasterId in
(
	select Id from [ClientCursor].[ReminderMaster] where CompanyId=@CompanyId
)

--3)ReminderMaster 2
delete from [ClientCursor].[ReminderMaster] where CompanyId=@CompanyId

--4)JobHoursLevel 4595
delete from [ClientCursor].[JobHoursLevel] where JobTypeId in
(
	select Id from ClientCursor.JobType where CompanyId=@CompanyId
)

--5)JobRisk 2757
delete from ClientCursor.JobRisk where JobTypeId in
(
	select Id from ClientCursor.JobType where CompanyId=@CompanyId
)

--6)JobType 640
delete from ClientCursor.JobType where CompanyId=@CompanyId

--7)EstimatedTimeCostQuestionnaire 0
delete from ClientCursor.EstimatedTimeCostQuestionnaire where CompanyId=@CompanyId

--8)EmployeeRank 14
delete from ClientCursor.EmployeeRank where CompanyId=@CompanyId

--9)CampaignDetail 1
delete from ClientCursor.CampaignDetail where CampaignId in
(
	select Id from ClientCursor.Campaign where CompanyId=@CompanyId --2
)

--10)Campaign 2
delete from ClientCursor.Campaign where CompanyId=@CompanyId

--11)VendorContact 1
delete from [ClientCursor].[VendorContact] where VendorId in
(
	select Id from ClientCursor.Vendor where CompanyId=@CompanyId
)

--12)VendorNote 0
delete from [ClientCursor].[VendorNote] where VendorId in
(
	select Id from ClientCursor.Vendor where CompanyId=@CompanyId
)

--13)VendorService 5
delete from [ClientCursor].[VendorService] where VendorId in
(
	select Id from ClientCursor.Vendor where CompanyId=@CompanyId
)

--14)VendorTypeVendor 6
delete from ClientCursor.VendorTypeVendor where VendorId in
(
	select Id from ClientCursor.Vendor where CompanyId=@CompanyId
)
--15)Vendor 1
delete from ClientCursor.Vendor where CompanyId=@CompanyId

--16)Communication  0
delete from  Common.Communication where LeadId in
(
	select Id from ClientCursor.Account where CompanyId=@CompanyId  
)

--17)Quotation Detail Template --0
delete from ClientCursor.QuotationDetailTemplate where QuotationDetailId in 
(
	select Id from ClientCursor.QuotationDetail where MasterId in
	(
		select Id from ClientCursor.Quotation where CompanyId=@CompanyId and AccountId in
		(
		   select ID from ClientCursor.Account where CompanyId=@CompanyId 		
		)
	)
	and OpportunityId in
	(
		select Id from ClientCursor.Opportunity where CompanyId=@CompanyId and AccountId in 
		(
		  select ID from ClientCursor.Account where CompanyId=@CompanyId  		  
		)
	)
)
--18)Quotation Details 22
delete from ClientCursor.QuotationDetail where MasterId in
(
	select Id from ClientCursor.Quotation where CompanyId=@CompanyId and AccountId in
	(
		select ID from ClientCursor.Account where CompanyId=@CompanyId 
	)
)
and OpportunityId in
(
	select Id from ClientCursor.Opportunity where CompanyId=@CompanyId and AccountId in 
	(
	  select ID from ClientCursor.Account where CompanyId=@CompanyId  
	)
)

--19)Quotation 17
delete from ClientCursor.Quotation where CompanyId=@CompanyId and AccountId in
(
	select ID from ClientCursor.Account where CompanyId=@CompanyId 
)

--20)opportunity designation 85
delete from ClientCursor.OpportunityDesignation where OpportunityId in
(
	select Id from ClientCursor.Opportunity where CompanyId=@CompanyId and AccountId in 
	(
		select ID from ClientCursor.Account where CompanyId=@CompanyId 
	)
)

--21)opportunity history 75
delete  from ClientCursor.OpportunityHistory where CompanyId=@CompanyId and OpportunityId  in
(
	select Id from ClientCursor.Opportunity where CompanyId=@CompanyId and AccountId in 
	(
	  select ID from ClientCursor.Account where CompanyId=@CompanyId 
	)
)

--22)opportunity Incharge 21
delete from ClientCursor.OpportunityIncharge where OpportunityId in
(
	select Id from ClientCursor.Opportunity where CompanyId=@CompanyId and AccountId in 
	(
		select ID from ClientCursor.Account where CompanyId=@CompanyId 
	)
)

--23)OpportunityDoc 0
delete from ClientCursor.OpportunityDoc where CompanyId=@CompanyId and OpportunityId in
(
	select Id from ClientCursor.Opportunity where CompanyId=@CompanyId and AccountId in 
	(
		select ID from ClientCursor.Account where CompanyId=@CompanyId 
	)
)

--24)OpportunityTermsCondition -- 0
delete from ClientCursor.OpportunityTermsCondition where OpportunityId in
(
	select Id from ClientCursor.Opportunity where CompanyId=@CompanyId and AccountId in 
	(
	  select ID from ClientCursor.Account where CompanyId=@CompanyId  
	)
)

--25)Opportunity Status Change --90
delete from ClientCursor.OpportunityStatusChange where CompanyId=@CompanyId and OpportunityId in
(
	select Id from ClientCursor.Opportunity where CompanyId=@CompanyId and AccountId in 
	(
		select ID from ClientCursor.Account where CompanyId=@CompanyId  
	)
)

--26)opportunity 21
delete from ClientCursor.Opportunity where CompanyId=@CompanyId and AccountId in 
(
  select ID from ClientCursor.Account where CompanyId=@CompanyId  
)

-- 27)ManualAssociation 0
delete from ClientCursor.ManualAssociation where FromAccountId in
(
	select ID from ClientCursor.Account where CompanyId=@CompanyId  
)
or ToAccountId in
(
	select ID from ClientCursor.Account where CompanyId=@CompanyId  
)

--28)Account Note --0
delete from ClientCursor.AccountNote where AccountId in
(
	select ID from ClientCursor.Account where CompanyId=@CompanyId  
)

--29)Account Incharge 3
delete from ClientCursor.AccountIncharge  where AccountId in
(
	select ID from ClientCursor.Account where CompanyId=@CompanyId  
)

--30)Account Contact --3
delete from ClientCursor.AccountContact where AccountId in
(
	select ID from ClientCursor.Account where CompanyId=@CompanyId  
)

--31)Account Status Change --23
delete from ClientCursor.AccountStatusChange where CompanyId=@CompanyId and AccountId in
(
	select ID from ClientCursor.Account where CompanyId=@CompanyId   --3
)

--32)ReminderBatchList 0
delete from Common.ReminderBatchList where CompanyId=@CompanyId and AccountId in 
(
	select ID from ClientCursor.Account where CompanyId=@CompanyId --3
)	

--33)Account 3
delete from ClientCursor.Account where CompanyId=@CompanyId 

----Contacts 28
--delete from common.contact where CompanyId=@CompanyId     	--Other cursors can have reference for these contacts.

End


GO
