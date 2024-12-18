USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[UpdateLicensesUsed_AdminUser_Save]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  Create      PROCEDURE [Common].[UpdateLicensesUsed_AdminUser_Save] (
    @companyId BIGINT,
   @chargeUnit NVARCHAR(20)
)
AS
BEGIN
    DECLARE @country NVARCHAR(50);
    SELECT @country = Jurisdiction FROM Common.Company (NOLOCK) WHERE Id = @companyId;
   if(@chargeUnit='user')
	begin

		update S set S.LicensesUsed = 0 from License.Subscription S  (NOLOCK)
		Left JOIN License.Package P (NOLOCK) on S.PackageId = P.Id
		left join Common.CompanyUserSubscription CUS (NOLOCK) on S.Id = CUS.Subscriptionid
		--Join
		--(select CompanyId as CompanyId, SubscriptionId as Subscriptionid, count(*) as LicensesUsed 
		--from Common.CompanyUserSubscription where CompanyId=@companyId group by CompanyId, SubscriptionId) as S1
		--on S.Id = S1.Subscriptionid
		where s.CompanyId=@companyId and P.ChargeUnit= @chargeUnit and p.Country=@country and CUS.SubscriptionId is null

		update S set S.LicensesUsed =  isnull(S1.LicensesUsed,0) from License.Subscription S (NOLOCK)
		Left JOIN License.Package P (NOLOCK) on S.PackageId = P.Id
		left Join
		(select CompanyId as CompanyId, SubscriptionId as Subscriptionid, count(*) as LicensesUsed 
		from Common.CompanyUserSubscription (NOLOCK) where CompanyId=@companyId and isnull(Status,1)=1 group by CompanyId, SubscriptionId) as S1
		on S.Id = S1.Subscriptionid
		where s.CompanyId=@companyId and P.ChargeUnit= @chargeUnit and p.Country=@country

	end
END;
GO
