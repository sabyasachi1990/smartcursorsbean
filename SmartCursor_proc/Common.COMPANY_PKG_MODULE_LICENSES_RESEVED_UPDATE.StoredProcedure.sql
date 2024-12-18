USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[COMPANY_PKG_MODULE_LICENSES_RESEVED_UPDATE]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [Common].[COMPANY_PKG_MODULE_LICENSES_RESEVED_UPDATE] (@companyId bigint)
AS 
BEGIN
    -- deleting the un necessary records
	delete CPM from License.CompanyPackageModule CPM
	Join
	(select * , ROW_NUMBER() OVER(PARTITION BY moduleMasterId  ORDER BY moduleMasterId) AS RowNumberRank from License.CompanyPackageModule where CompanyId=@companyId) CPM2 on CPM.Id = CPM2.Id
	where CPM2.RowNumberRank > 1 and CPM.CompanyId=@companyId and  CPM2.CompanyId=@companyId
	
	-- updating the Licenses Reserved

	update CPM1 set CPM1.LicensesReserved = CPM2.LicensesReserved from License.CompanyPackageModule CPM1
	Join
	(
		select CP.ModuleMasterId,sum(cp.LicensesReserved) as LicensesReserved from
		(		
			select CPM.ModuleMasterId, s.LicensesReserved from License.Subscription S
			Join License.Package P on P.Id = S.PackageId
			Join License.PackageModule PM on PM.PackageId = P.Id
			left Join License.CompanyPackageModule CPM on CPM.ModuleMasterId = PM.ModuleMasterId
			where s.CompanyId = @companyId and CPM.CompanyId=@companyId
			group by CPM.ModuleMasterId, P.Id, s.SubscriptionName, s.LicensesReserved
		) CP
		group by CP.ModuleMasterId
	) CPM2 on CPM1.ModuleMasterId = CPM2.ModuleMasterId
	where CPM1.CompanyId = @companyId
	
END
GO
