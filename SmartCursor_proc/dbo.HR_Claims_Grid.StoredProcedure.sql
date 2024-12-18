USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Claims_Grid]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[HR_Claims_Grid]


 --exec[dbo].[HR_Claims_Grid]  1,0,'00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000','e9acff2f-2436-4f0e-a795-9b24742bbe1d',null

@ParentCompanyId bigint,
@subCompanyId varchar(4000),
@DepartmentId uniqueidentifier,
@DesignationId uniqueidentifier,
@claimant uniqueidentifier,
@hrsettingDetailId uniqueidentifier,
@tabName  varchar(4000)

As
Begin

Begin try


Declare 
    @EndDate datetime2(7) = (select EndDate from Common.HRSettingdetails where MasterId in (select Id from Common.HRSettings where companyId=@ParentCompanyId) and Id = @hrsettingDetailId),
    @StartDate datetime2(7) = (select StartDate from Common.HRSettingdetails where MasterId in (select Id from Common.HRSettings where companyId=@ParentCompanyId) and Id = @hrsettingDetailId),
	 @Error_Message nvarchar(MAX),
	 @Error_Servirity int,
	 @Error_State int
 

 if @hrsettingDetailId = '00000000-0000-0000-0000-000000000000'
begin

select 

EC.Id,CL.Name as ClientName ,CG.SystemRefNo as SystemRefNo,sum(ECD.ApprovedAmount) as ApprovedAmount,EC.ClaimStatus, sum(ECD.BaseAmount) as Amount,	EC.ClaimNumber,C.ShortName as ServiceEntity,EC.MongoId,EC.DepartmentId,EC.DesignationId,DocumentId,EC.CreatedDate,EC.UserCreated,EC.ModifiedBy,MasterClaimDate,EC.ModifiedDate,EC.EmployeId,EC.CompanyId,(select ccd.IsGstSetting from Common.Company as ccd where ccd.Id=@ParentCompanyId) as IsGSTActivate,E.Username as EmployeeUserName,EC.PostingDate,EC.Isvendor,EC.Ispaycomponent,(select Includepaycomponent from Common.HRSettings where companyId=@ParentCompanyId) as Includepaycomponent,E.FirstName as Claimant


from hr.EmployeeClaim1 EC
Join Common.Employee E on EC.EmployeId = E.Id
Join Common.Company C on C.Id = EC.CompanyId
Join hr.EmployeeClaimDetail ECD on EC.Id = ECD.EmployeeClaimId
--Join hr.EmployeeClaimsEntitlement ECE on ECE.EmployeeId = E.Id
--Join Hr.EmployeeClaimsEntitlementDetail ECED on ECE.Id = ECED.EmployeeClaimsEntitlementId
Left Join WorkFlow.CaseGroup CG on EC.CaseGroupId = CG.Id
Left Join WorkFlow.Client CL on EC.ClientId  = CL.Id
where EC.ParentCompanyId=@parentCompanyId  
and EC.CompanyId=(case when @subCompanyId Is not null AND @subCompanyId != 'All' then cast( @subCompanyId as bigint) else EC.CompanyId END)  -- Sub Company filteration
and EC.DepartmentId in (case when @departmentId Is not null AND @departmentId != '00000000-0000-0000-0000-000000000000' then @departmentId else EC.DepartmentId END) -- department filteration
and EC.DesignationId in (case when @designationId Is not null AND @designationId != '00000000-0000-0000-0000-000000000000' then @designationId else EC.DesignationId END) -- designation filteration
and E.Id in (case when @claimant Is not null AND @claimant != '00000000-0000-0000-0000-000000000000' then @claimant else E.Id END) -- employee filteration
and ECD.id not in (select ParentId from hr.EmployeeClaimDetail where ParentId is not null and EmployeeClaimId in (EC.Id)) and  EC.ClaimStatus = case when upper(@tabName)!= 'ALL' then @tabName else EC.ClaimStatus end
group by EC.Id,CL.Name ,CG.SystemRefNo ,EC.ClaimStatus, 	EC.ClaimNumber,C.ShortName ,E.Username,EC.MongoId,EC.DepartmentId,EC.DesignationId,DocumentId,EC.CreatedDate,EC.UserCreated,EC.ModifiedBy,MasterClaimDate,EC.ModifiedDate,EC.EmployeId,EC.CompanyId,EC.PostingDate,EC.Isvendor,EC.Ispaycomponent,E.FirstName 
order by EC.CreatedDate desc

end
else if @hrsettingDetailId <> '00000000-0000-0000-0000-000000000000'
 begin

 
select 

EC.Id,CL.Name as ClientName ,CG.SystemRefNo as SystemRefNo,sum(ECD.ApprovedAmount) as ApprovedAmount,sum(ECD.BaseAmount) as Amount,EC.ClaimStatus, 	EC.ClaimNumber,C.ShortName as ServiceEntity,EC.MongoId,EC.DepartmentId,EC.DesignationId,DocumentId,EC.CreatedDate,EC.UserCreated,EC.ModifiedBy,MasterClaimDate,EC.ModifiedDate,EC.EmployeId,EC.CompanyId,(select ccd.IsGstSetting from Common.Company as ccd where ccd.Id=@ParentCompanyId) as IsGSTActivate,E.Username as EmployeeUserName,EC.PostingDate,EC.Isvendor,EC.Ispaycomponent,(select Includepaycomponent from Common.HRSettings where companyId=@ParentCompanyId) as Includepaycomponent,E.FirstName as Claimant

from hr.EmployeeClaim1 EC
Join Common.Employee E on EC.EmployeId = E.Id
Join Common.Company C on C.Id = EC.CompanyId
Join hr.EmployeeClaimDetail ECD on EC.Id = ECD.EmployeeClaimId
--Join hr.EmployeeClaimsEntitlement ECE on ECE.EmployeeId = E.Id
--Join Hr.EmployeeClaimsEntitlementDetail ECED on ECE.Id = ECED.EmployeeClaimsEntitlementId
Left Join WorkFlow.CaseGroup CG on EC.CaseGroupId = CG.Id
Left Join WorkFlow.Client CL on EC.ClientId  = CL.Id
where EC.ParentCompanyId=@parentCompanyId  
and EC.CompanyId=(case when @subCompanyId Is not null AND @subCompanyId != 'All' then cast( @subCompanyId as bigint) else EC.CompanyId END)  -- Sub Company filteration
and EC.DepartmentId in (case when @departmentId Is not null AND @departmentId != '00000000-0000-0000-0000-000000000000' then @departmentId else EC.DepartmentId END) -- department filteration
and EC.DesignationId in (case when @designationId Is not null AND @designationId != '00000000-0000-0000-0000-000000000000' then @designationId else EC.DesignationId END) -- designation filteration
and E.Id in (case when @claimant Is not null AND @claimant != '00000000-0000-0000-0000-000000000000' then @claimant else E.Id END) -- employee filteration
and ECD.id not in (select ParentId from hr.EmployeeClaimDetail where ParentId is not null and EmployeeClaimId in (EC.Id))
and (Convert(date,EC.MasterClaimDate) >= Convert(date,@StartDate )  and Convert(date,EC.MasterClaimDate) <= Convert(date,@EndDate )) and EC.ClaimStatus = case when upper(@tabName)!= 'ALL' then @tabName else EC.ClaimStatus end
group by EC.Id,CL.Name ,CG.SystemRefNo ,EC.ClaimStatus,E.Username ,	EC.ClaimNumber,C.ShortName ,EC.MongoId,EC.DepartmentId,EC.DesignationId,DocumentId,EC.CreatedDate,EC.UserCreated,EC.ModifiedBy,MasterClaimDate,EC.ModifiedDate,EC.EmployeId,EC.CompanyId,EC.PostingDate,EC.Isvendor,EC.Ispaycomponent,E.FirstName 
order by EC.CreatedDate desc
 
 end
	 
	 	End Try
		Begin catch

		Select @Error_Message=ERROR_MESSAGE(),
			@Error_Servirity=ERROR_SEVERITY(),
			@Error_State=ERROR_STATE()
		RAISERROR(@Error_Message,@Error_Servirity,@Error_State)
	End Catch


	 END
 




GO
