USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[FeaturePermission]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [Common].[FeaturePermission](@companyId bigint,@companyUserId bigint,@cursorName nvarchar(50))

As begin
if(@cursorName='Client Cursor')
Begin

declare @CCtemp table (LeadFeature nvarchar(500), AccountFeature nvarchar(100), OpportunityFeature nvarchar(100),LeavesRecomender nvarchar(100),LeavesApprover nvarchar(100),ClaimsVerify nvarchar(100),ClaimsReview nvarchar(100),ClaimsApprover nvarchar(100),CasePrimaryIncharge nvarchar(100),Casemember nvarchar(100),CaseQIC nvarchar(100))

   declare @Lead nvarchar(500) =   ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Form.Tabs[0].Actions[5].Chk') in('true')   then 'Lead Incharge' when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Form.Tabs[0].Actions[5].Chk') in('false')   then 'Leads' end  from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Form.Tabs[0].Actions[5].Chk') in('true') and
      ModuleDetailId=(select  Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=1 and PermissionKey='client_leads'
) and CompanyUserId=@companyUserId and Status=1 and IsView=1)

	declare @Account nvarchar(500) = ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Form.Tabs[0].Actions[5].Chk') in('true')   then 'Account Incharge' when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Form.Tabs[0].Actions[5].Chk') in('false')   then 'Account Incharge' end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Form.Tabs[0].Actions[5].Chk') in('true') and
      ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=1 and PermissionKey='client_leads') and CompanyUserId=@companyUserId and Status=1 and IsView=1)



	 declare @Opportunity nvarchar(500) =( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Actions[5].Chk') in('true')   then 'Opportunity Incharge' when  JSON_VALUE(Permissions, '$.Tabs[0].Actions[5].Chk') in('false')   then 'Opportunity Incharge' end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Actions[5].Chk') in('true') and
      ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=1 and PermissionKey='client_Opportunities') and CompanyUserId=@companyUserId and Status=1 and IsView=1)

	  if not exists(select * from @CCtemp)
	begin
		insert into @CCtemp 
		select @Lead, @Account, @Opportunity,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	end
	select * from @CCtemp
	  End

	  if(@cursorName='HR Cursor')
       Begin
	   declare @LeaveRecomender nvarchar(500) =   ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[7].Chk') in('true')   then 'Leave Recommender'  end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[7].Chk') in('true') and
      ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=8 and PermissionKey='hr_leaveapplications'
) and CompanyUserId=@companyUserId and Status=1 and IsView=1)

declare @ManageLeaveRecomender nvarchar(500) =   ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[7].Chk') in('true')   then 'Leave Recommender'  end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[5].Chk') in('true') and
      ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=8 and PermissionKey='hr_mss_manageleaves'
) and CompanyUserId=@companyUserId and Status=1 and IsView=1)


	  declare @LeaveApprover nvarchar(500) =   ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[6].Chk') in('true')   then 'Leave Approver' end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[6].Chk') in('true') and
      ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=8 and PermissionKey='hr_leaveapplications'
) and CompanyUserId=@companyUserId and Status=1 and IsView=1)

declare @ManageLeaveApprover nvarchar(500) =   ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[6].Chk') in('true')   then 'Leave Approver' end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[6].Chk') in('true') and
      ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=8 and PermissionKey='hr_mss_manageleaves'
) and CompanyUserId=@companyUserId and Status=1 and IsView=1)

	  declare @ClaimVerify nvarchar(500) =   ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Actions[5].Chk') in('true')   then 'Claims Verifier'  end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Actions[5].Chk') in('true') and
      ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=8 and PermissionKey='hr_claims') and CompanyUserId=@companyUserId and Status=1 and IsView=1)

	    declare @ManageClaimVerify nvarchar(500) =   ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Actions[5].Chk') in('true')   then 'Claims Verifier'  end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Actions[5].Chk') in('true') and
      ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=8 and PermissionKey='hr_mss_manageclaims') and CompanyUserId=@companyUserId and Status=1 and IsView=1)

	  declare @ClaimReview nvarchar(500) =   ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Actions[8].Chk') in('true')   then 'Claims Reviewer'  end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Actions[8].Chk') in('true') and
      ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=8 and PermissionKey='hr_claims') and CompanyUserId=@companyUserId and Status=1 and IsView=1)

	    declare @ManageClaimReview nvarchar(500) =   ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Actions[8].Chk') in('true')   then 'Claims Reviewer'  end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Actions[8].Chk') in('true') and
      ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=8 and PermissionKey='hr_mss_manageclaims') and CompanyUserId=@companyUserId and Status=1 and IsView=1)

	  declare @ClaimApprover nvarchar(500) =   ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Actions[10].Chk') in('true')   then 'Claims Approver'  end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Actions[10].Chk') in('true') and
      ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=8 and PermissionKey='hr_claims') and CompanyUserId=@companyUserId and Status=1 and IsView=1)

	  declare @ManageClaimApprover nvarchar(500) =( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Actions[12].Chk') in('true')   then 'Claims Approver'  end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Actions[10].Chk') in('true') and
      ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=8 and PermissionKey='hr_mss_manageclaims') and CompanyUserId=@companyUserId and Status=1 and IsView=1)
	  set @ClaimVerify = (CASE WHEN (@ClaimVerify='Claims Verifier') THEN 'Claims Verifier' ELSE @ManageClaimVerify END)

	  set @ClaimReview = (CASE WHEN (@ClaimReview='Claims Reviewer') THEN 'Claims Reviewer' ELSE @ManageClaimReview END)

	  set @ClaimApprover = (CASE WHEN (@ClaimApprover='Claims Approver') THEN 'Claims Approver' ELSE @ManageClaimApprover END)
	  set @LeaveApprover = (CASE WHEN (@LeaveApprover='Leave Approver') THEN 'Leave Approver' ELSE @ManageLeaveApprover END)
	  set @LeaveRecomender = (CASE WHEN (@LeaveRecomender='Leave Recommender') THEN 'Leave Recommender' ELSE @ManageLeaveRecomender END)


	  --declare @RecJobApplication nvarchar(500) =   ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[1].Actions[4].Chk') in('true')   then 'Recuritment' when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[1].Actions[4].Chk') in('false')   then 'Recuritment' end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[1].Actions[4].Chk') in('true') and
   --   ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=8 and PermissionKey='hr_jobapplications') and CompanyUserId=@companyUserId and Status=1 and IsView=1)


	  --declare @TrainingManagement nvarchar(500) =   ( select top(1) Case when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[0].Chk') in('true')   then 'TrainingManagement' when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[0].Chk') in('false')   then 'TrainingManagement' end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[0].Chk') in('true') and
   --   ModuleDetailId=(select Id from Common.ModuleDetail where CompanyId=@companyId and ModuleMasterId=8 and PermissionKey='hr_trainings') and CompanyUserId=@companyUserId and Status=1 and IsView=1)


	  --declare @Appraisal nvarchar(500) =   ( select Case when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[0].Chk') in('true')   then 'Appraisal' when  JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[0].Chk') in('false')   then 'Appraisal' end from Auth.UserPermissionNew  where JSON_VALUE(Permissions, '$.Tabs[0].Form.Tabs[0].Actions[0].Chk') in('true') and
   --   ModuleDetailId=654 and CompanyUserId=@companyUserId and Status=1 and IsView=1)

	  if not exists(select * from @CCtemp)
	begin
		insert into @CCtemp 
		select NULL,NULL,NULL,@LeaveRecomender,@LeaveApprover,@ClaimVerify,@ClaimReview,@ClaimApprover,NULL,NULL,NULL
	end
	select * from @CCtemp


	   End
	  	  if(@cursorName='WorkFlow Cursor')
       Begin

	    IF EXISTS (select * from common.CompanyUser as cu join common.Employee as e on cu.Username=e.Username where cu.CompanyId=@companyId and e.IsHROnly=1 and e.CompanyId=@companyId and cu.id=@companyUserId)
			declare @CasePrimaryIncharge nvarchar(500) ='Case PIC' 
		IF EXISTS (select * from common.CompanyUser as cu join common.Employee as e on cu.Username=e.Username where cu.CompanyId=@companyId and e.IsHROnly=1  and e.CompanyId=@companyId and cu.id=@companyUserId)
			declare @Casemember nvarchar(500) ='Case Member' 
		IF EXISTS (select * from common.CompanyUser as cu join common.Employee as e on cu.Username=e.Username where cu.CompanyId=@companyId and e.IsHROnly=1 and e.CompanyId=@companyId and cu.id=@companyUserId)
			declare @CaseQIC nvarchar(500) ='Case QIC' 
    	
	  if not exists(select * from @CCtemp)
	begin
		insert into @CCtemp 
		select NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,@CasePrimaryIncharge,@Casemember,@CaseQIC
	end
	select * from @CCtemp


	   End

	  End

GO
