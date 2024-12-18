USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [License].[SuspendSubscription]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  Create    proc [License].[SuspendSubscription] (
@subscriptionId Uniqueidentifier,
@status nvarchar(20))
AS BEGIN
	if(@Status = 'Delete')
	BEGIN
		Delete Common.CompanyUserSubscription where SubscriptionId=@SubscriptionId
		Declare @Temp Table(CompanyId bigint , LicensesReserved int ,ModuleMasterId int)
		insert into @Temp
		select S.CompanyId, S.LicensesReserved,PM.ModuleMasterId from License.Subscription S join License.PackageModule PM on S.PackageId=PM.PackageId where S.Id=@SubscriptionId
		update CP set CP.LicensesReserved=(CP.LicensesReserved - T.LicensesReserved) from License.CompanyPackageModule CP  
		inner join @Temp T on CP.ModuleMasterId=T.ModuleMasterId where T.CompanyId=CP.CompanyId
		update License.Subscription set LicensesReserved=(select top 1 LicensesReserved from @Temp) where Id=@SubscriptionId
	End
	else
	BEGIN
		Declare @Sub Table(LicensesReserved int)
		insert into @Sub 
		select S.LicensesReserved from License.Subscription S where Id=@SubscriptionId
		select S.CompanyId, S.LicensesReserved,PM.ModuleMasterId from License.Subscription S join License.PackageModule PM on S.PackageId=PM.PackageId where S.Id=@SubscriptionId
		insert into @Temp
		select S.CompanyId, S.LicensesReserved,PM.ModuleMasterId from License.Subscription S join License.PackageModule PM on S.PackageId=PM.PackageId where S.Id=@SubscriptionId
		update CP set CP.LicensesReserved=(CP.LicensesReserved + (select LicensesReserved from @Sub)) from License.CompanyPackageModule CP  
		inner join @Temp T on CP.ModuleMasterId=T.ModuleMasterId where T.CompanyId=CP.CompanyId
	END

	declare @companyId bigint = (select companyId from License.Subscription where Id = @subscriptionId)
	exec [License].[UpdateSubscriptionAtRoleNew] @subscriptionId, @companyId

END	
GO
