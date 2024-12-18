USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_PerviousEmployeeClaims_Calculations]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


   CREATE procedure [dbo].[HR_PerviousEmployeeClaims_Calculations] ( @EmployeeId uniqueidentifier,@CompanyId BIGINT,@HrSettingDetaiId uniqueidentifier , @StartDate datetime2,@Enddate datetime2,@ClaimsCarryforwardResetDate datetime2,@IsperviousYear bit, @EmployeClaimId uniqueidentifier)
   AS
Begin
BEGIN TRANSACTION
BEGIN TRY
   DECLARE @ClaimItemId_Ids uniqueidentifier
   DECLARE @UtilizedAmount money
    DECLARE @SubmittedAmount money
	  DECLARE @RemainingAmount decimal

	DECLARE employeeclaimdetailcursor CURSOR FOR select Distinct ClaimItemId from HR.EmployeeClaimDetail where EmployeeClaimId in (select Id from HR.EmployeeClaim1 where ParentCompanyId=@CompanyId and  Id = @EmployeClaimId)
	OPEN employeeclaimdetailcursor 
	FETCH NEXT FROM employeeclaimdetailcursor INTO @ClaimItemId_Ids
					
	WHILE @@FETCH_STATUS = 0
	begin	


	set @UtilizedAmount = ( select CAST(sum(ECD.ApprovedAmount) as money) from 
   HR.EmployeeClaim1 as EC 
join HR.EmployeeClaimDetail as ECD on EC.Id = ECD.EmployeeClaimId 
where  EC.EmployeId =@EmployeeId and EC.ParentCompanyId = @CompanyId and  EC.ClaimStatus='Processed' and ECD.ParentId is null and EC.CaseGroupId is null and EC.ClientId is null   and  ECD.ClaimItemId =@ClaimItemId_Ids and EC.Id=@EmployeClaimId and   ECD.EmployeeClaimId=@EmployeClaimId and

(( @IsperviousYear=1  and  Convert(Date,@StartDate) <= Convert(Date ,EC.MasterClaimDate)  and Convert(Date,EC.MasterClaimDate) <=   Convert(Date,@Enddate) ) or 

(@IsperviousYear=0  and  DATEADD(YEAR,-1,@ClaimsCarryforwardResetDate)  <= Convert(Date ,EC.CreatedDate) )) )




set @SubmittedAmount = ( select CAST(sum(ECD.ApprovedAmount) as money) from 
   HR.EmployeeClaim1 as EC 
join HR.EmployeeClaimDetail as ECD on EC.Id = ECD.EmployeeClaimId 
where  EC.EmployeId =@EmployeeId and EC.ParentCompanyId = @CompanyId and EC.ClaimStatus!='Processed' and EC.ClaimStatus!='Rejected' and  EC.ClaimStatus!='Drafted'  and  EC.ClaimStatus!='Cancelled' and  EC.ClaimStatus!='Void' and ECD.ParentId is null and EC.CaseGroupId is null and EC.ClientId is null and  ECD.ClaimItemId =@ClaimItemId_Ids  and EC.Id=@EmployeClaimId and   ECD.EmployeeClaimId=@EmployeClaimId and
(( @IsperviousYear=1  and  Convert(Date,@StartDate) <= Convert(Date ,EC.MasterClaimDate)  and Convert(Date,EC.MasterClaimDate) <=   Convert(Date,@Enddate) ) or 
(@IsperviousYear=0  and  DATEADD(YEAR,-1,@ClaimsCarryforwardResetDate)  <= Convert(Date ,EC.CreatedDate) ))  )

 

 

 

update ECED set ECED.SubmittedAmount = ( ISnull(ECED.SubmittedAmount,0) - ISnull(@SubmittedAmount,0) ),ECED.RemainingAmount =  

   (Case when  ECED.RemainingAmount is not null then  (ISNull(ECED.RemainingAmount,0) + ISNull(@SubmittedAmount,0)) else null end) 


--( Case when (ECED.AnnualLimit is null or ECED.AnnualLimit=0) and (ECED.TransactionLimit is null or ECED.TransactionLimit = 0)  then null when ECED.AnnualLimit is not null then  isnull(ECED.AnnualLimit,0) - ( (ISNull(ECED.RemainingAmount,0) + ISNull(@SubmittedAmount,0)) ) else isnull(ECED.TransactionLimit,0) -  ( (ISNull(ECED.RemainingAmount,0) + ISNull(@SubmittedAmount,0)) ) end)


    from HR.EmployeeClaimsEntitlementDetail as ECED
  join HR.EmployeeClaimsEntitlement as ECE on ECE.Id = ECED.EmployeeClaimsEntitlementId
  join HR.EmployeeClaimDetail as ECD on ECD.ClaimItemId = @ClaimItemId_Ids
  where ECE.EmployeeId = @EmployeeId and ECE.CompanyId = @CompanyId and ECED.ClaimItemId = ECD.ClaimItemId and ECED.HrSettingDetaiId = @HrSettingDetaiId and ECD.ClaimItemId =@ClaimItemId_Ids  and   ECD.EmployeeClaimId=@EmployeClaimId 

  FETCH NEXT FROM employeeclaimdetailcursor INTO @ClaimItemId_Ids
   End
	CLOSE employeeclaimdetailcursor
	DEALLOCATE employeeclaimdetailcursor


				update E set E.CategoryUtilizedAmount = A.UtilizedAmount ,E.CategoryPreApprovedAmount = A.SubmittedAmount 
				
				, 	 E.CategoryBalanceAmount =  (  Case when ( E.CategoryLimit is null )  then null else ISNULL(E.CategoryLimit,0) - (ISNULL(A.UtilizedAmount,0) + ISNULL( A.SubmittedAmount,0) ) end ) from hr.EmployeeClaimsEntitlementDetail E
		 join HR.ClaimItem CI on E.ClaimItemId = CI.Id
						Join
	              (
				select ECD.Id,CI.Category, SUM(ECED.UtilizedAmount)  as UtilizedAmount, SUM(ECED.SubmittedAmount)  as SubmittedAmount from HR.EmployeeClaimsEntitlementDetail  ECED
						  join HR.EmployeeClaimsEntitlement ECD on ECED.EmployeeClaimsEntitlementId = ECD.Id 
						   join HR.ClaimItem CI on ECED.ClaimItemId = CI.Id
						  where ECD.EmployeeId = @EmployeeId and ECD.CompanyId = @CompanyId and CI.CompanyId=@CompanyId and ECED.HrSettingDetaiId = @HrSettingDetaiId and ECED.ClaimItemId in ((select ClaimItemId from hr.EmployeeClaimsEntitlementDetail where EmployeeClaimsEntitlementId = ECD.Id and HrSettingDetaiId = @HrSettingDetaiId )) group by ECD.Id ,CI.Category
						) A on A.Id = E.EmployeeClaimsEntitlementId and E.HrSettingDetaiId = @HrSettingDetaiId and  E.ClaimItemId in ((select ClaimItemId from hr.EmployeeClaimsEntitlementDetail where EmployeeClaimsEntitlementId = A.Id and HrSettingDetaiId = @HrSettingDetaiId ))  and A.Category = CI.Category and CI.CompanyId=@CompanyId



	end try
begin catch
	DECLARE
			@ErrorMessage NVARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState INT;

	SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

	ROLLBACK TRANSACTION

	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
end catch
commit transaction
end





GO
