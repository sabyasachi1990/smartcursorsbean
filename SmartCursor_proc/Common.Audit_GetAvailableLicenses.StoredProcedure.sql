USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[Audit_GetAvailableLicenses]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE procedure [Common].[Audit_GetAvailableLicenses] (
@moduleName nvarchar(100),
@companyId nvarchar(100),
@chargeUnit nvarchar(100))
As 
Begin

DECLARE @PARTNER_COMPANYID BIGINT     
          Set @PARTNER_COMPANYID=(select AccountingFirmId from Common.Company where Id=@companyId)
    IF @PARTNER_COMPANYID IS NULL
    BEGIN
            SET @PARTNER_COMPANYID=@companyId
    END

 Declare  @FSLicenseReserved bigint = (select sum(LicensesReserved) from License.Subscription where CompanyId=@PARTNER_COMPANYID and SubscriptionName like '%Audit%' and Status=1)
  Declare  @FSLicenseUsed bigint = (select sum(LicensesUsed) from License.Subscription where CompanyId=@PARTNER_COMPANYID and SubscriptionName like '%Audit%' and Status=1)

  -- Declare  @StatutoryLicenseReserved bigint = (select sum(LicensesReserved) from License.Subscription where CompanyId=@PARTNER_COMPANYID and SubscriptionName like '%Audit Statutory%' and Status=1)
  --Declare  @StatutoryLicenseUsed bigint = (select sum(LicensesUsed) from License.Subscription where CompanyId=@PARTNER_COMPANYID and SubscriptionName like '%Audit Statutory%' and Status=1)

    declare @temp table (CompanyName nvarchar(500) null, ModuleName nvarchar(100) null, ChargeUnit nvarchar(100) null, FSAvailableLicenses int null,StatutoryAvailableLicenses int null, CompanyCreatedDate datetime2(7) null, CompanyStatus nvarchar(20))
	insert into @temp
	select C.Name as CompanyName, 'Audit Cursor' as ModuleName, @chargeUnit as ChargeUnit, (@FSLicenseReserved - @FSLicenseUsed) as FSAvailableLicenses,0 as FSAvailableLicenses,C.CreatedDate as CompanyCreatedDate, (case when C.Status=2 then 'Inactive' else 'Active' end) as CompanyStatus 
	from License.Subscription S
	left join Common.Company C on S.CompanyId = C.Id
	--Join Common.ModuleMaster MM on CPM.ModuleMasterId = MM.Id
	where S.CompanyId=@PARTNER_COMPANYID 
	if not exists(select * from @temp)
	begin
		insert into @temp 
		select Name, @moduleName, @chargeUnit,0, 0, CreatedDate, (case when [status]=2 then 'Inactive' else 'Active' end) as CompanyStatus from Common.Company where Id=@PARTNER_COMPANYID
	end
	select * from @temp
End
GO
