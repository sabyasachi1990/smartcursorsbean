USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[Audit_UpdateLicensesUsed]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Common].[Audit_UpdateLicensesUsed](
@companyId bigint,
@moduleName nvarchar(50),   
@status nvarchar(20),       
@chargeUnit nvarchar(20),
@type nvarchar(50)
)
As begin

DECLARE @PARTNER_COMPANYID BIGINT     
          Set @PARTNER_COMPANYID=(select AccountingFirmId from Common.Company where Id=@companyId)
    IF @PARTNER_COMPANYID IS NULL
    BEGIN
            SET @PARTNER_COMPANYID=@companyId
    END

begin try
declare @country nvarchar(50) =(select Jurisdiction from Common.Company where Id=@PARTNER_COMPANYID)
	--if(@status = 'active')
	--begin
	--	update CPM set CPM.LicensesUsed = case when (ISNULL(CPM.licensesUsed,0)+1) > cpm.LicensesReserved then cpm.LicensesReserved else (ISNULL(CPM.licensesUsed,0)+1) end   
	--	from License.CompanyPackageModule CPM
	--	join License.PackageModule PM on CPM.ModuleMasterId = PM.ModuleMasterId
	--	join License.Package P on P.Id = PM.PackageId
	--	Join Common.ModuleMaster MM on MM.Id = PM.ModuleMasterId
	--	where CPM.CompanyId = @PARTNER_COMPANYID and MM.Name=@moduleName and PM.ModuleMasterId = MM.Id and P.ChargeUnit = @chargeUnit and p.Country=@country and CPM.ChargeUnit=@chargeUnit
	--end
	--else if(@status = 'inactive')
	--begin
	--	update CPM set CPM.LicensesUsed = case when (ISNULL(CPM.licensesUsed,0)-1) > 0 then (ISNULL(CPM.licensesUsed,0)-1) else 0 end
	--	from License.CompanyPackageModule CPM
	--	join License.PackageModule PM on  CPM.ModuleMasterId = PM.ModuleMasterId
 --   	join License.Package P on P.Id = PM.PackageId
	--	Join Common.ModuleMaster MM on MM.Id = PM.ModuleMasterId
	--	where CPM.CompanyId = @PARTNER_COMPANYID and MM.Name=@moduleName and PM.ModuleMasterId = MM.Id and P.ChargeUnit = @chargeUnit and p.Country=@country and CPM.ChargeUnit=@chargeUnit
	--end
   IF (@chargeUnit = 'Engagement' OR @status = 'active' OR @status = 'inactive')
	begin
	Declare @subScriptionId uniqueidentifier
	 --if(@type = 'Audit FS')
	 --Begin
	 --set @subScriptionId  = (select top 1 Id from License.Subscription where SubscriptionName like '%Audit FS%' and Status=1 and CompanyId=@companyId)
	 --End
	 --else if(@type = 'Audit Statutory')
	 --Begin
	 --set @subScriptionId  = (select Id from License.Subscription where SubscriptionName like '%Audit Statutory%' and Status=1 and CompanyId=@companyId)
	 --end
	 --select @subScriptionId
	 set @subScriptionId = case when (@type = 'Audit FS') then (select top 1 Id from License.Subscription where SubscriptionName like '%Audit%' and Status=1 and CompanyId=@PARTNER_COMPANYID)  when (@type = 'Audit Statutory') then (select Id from License.Subscription where SubscriptionName like '%Audit%' and Status=1 and CompanyId=@PARTNER_COMPANYID) end

		update top(1) S set S.LicensesUsed = 
		case when @status = 'active' 
		then 
		(case when (ISNULL(s.licensesUsed,0)+1) > s.LicensesReserved then s.LicensesReserved else (ISNULL(s.licensesUsed,0)+1) end) 
		else ( case when (ISNULL(s.licensesUsed,0)-1) > 0 then (ISNULL(s.licensesUsed,0)-1) else 0 end) end		
		from License.Subscription S 
		Left JOIN License.Package P on S.PackageId = P.Id
		where S.CompanyId=@PARTNER_COMPANYID and P.ChargeUnit= @chargeUnit and p.Country=@country and S.LicensesReserved > S.LicensesUsed and S.Id=@subScriptionId
	end

end try
begin catch

end catch
END
GO
