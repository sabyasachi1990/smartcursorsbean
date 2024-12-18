USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[SingleEntityLicenseUsedUpdate]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [Common].[SingleEntityLicenseUsedUpdate] (
@companyId bigint,
@moduleName nvarchar(50),   -- hr, wf, cc, br, audit, bean
@status nvarchar(20),       -- active, inactive
@chargeUnit nvarchar(20))    -- user, engagement, entity  -- exec Common.UpdateLicensesUsed 667,'Wirkflow Cursor','active','user'

as begin
  declare @country nvarchar(50) =(select Jurisdiction from Common.Company where Id=@companyId)

declare @LicensesUsedcount int = (select LicensesUsed from License.Subscription where CompanyId=@companyId and SubscriptionName like '%Accounting with Single Entity%' and Status=1)
declare @count int = (select COUNT(*) from License.Subscription where CompanyId=@companyId and SubscriptionName like '%Accounting with Single Entity%' and Status=1)
  if(@LicensesUsedcount=0 and @count=1)
  begin
	begin

	--Update  License.Subscription set LicensesUsed=1 where CompanyId=@companyId and SubscriptionName like '%Accounting with Single Entity%' and Status=1

		update CPM set CPM.LicensesUsed = case when (ISNULL(CPM.licensesUsed,0)+1) > cpm.LicensesReserved then cpm.LicensesReserved else (ISNULL(CPM.licensesUsed,0)+1) end   
		from License.CompanyPackageModule CPM
		join License.PackageModule PM on CPM.ModuleMasterId = PM.ModuleMasterId
		join License.Package P on P.Id = PM.PackageId
		Join Common.ModuleMaster MM on MM.Id = PM.ModuleMasterId
		where CPM.CompanyId = @companyId and MM.Name=@moduleName and PM.ModuleMasterId = MM.Id and P.ChargeUnit = @chargeUnit and p.Country=@country and CPM.ChargeUnit=@chargeUnit
	end
	end


	declare @Multicount int = (select top(1) LicensesUsed from License.Subscription where CompanyId=@companyId and SubscriptionName like '%Accounting with Multi Entity%' and Status=1)
  if(@Multicount=0)
  begin
  Declare @SingleEntityIds table (ID uniqueidentifier)
  Declare @SingleEntityIdsCount int
  insert into @SingleEntityIds(ID) (select Id from License.Subscription where  SubscriptionName like '%Accounting with Single Entity%' and CompanyId=@companyId and Status=1)

  			 Set @SingleEntityIdsCount=(Select Count(*) From @SingleEntityIds)

		if(@SingleEntityIdsCount>0)
		Begin
		update License.Subscription set Status=4 where  SubscriptionName like '%Accounting with Single Entity%' and CompanyId=@companyId and Status=1
		End



		update CPM set CPM.LicensesUsed = case when (ISNULL(CPM.licensesUsed,0)+1) > cpm.LicensesReserved then cpm.LicensesReserved else (ISNULL(CPM.licensesUsed,0)+1) end   
		from License.CompanyPackageModule CPM
		join License.PackageModule PM on CPM.ModuleMasterId = PM.ModuleMasterId
		join License.Package P on P.Id = PM.PackageId
		Join Common.ModuleMaster MM on MM.Id = PM.ModuleMasterId
		where CPM.CompanyId = @companyId and MM.Name=@moduleName and PM.ModuleMasterId = MM.Id and P.ChargeUnit = @chargeUnit and p.Country=@country and CPM.ChargeUnit=@chargeUnit

			Update  License.Subscription set LicensesUsed=1 where CompanyId=@companyId and SubscriptionName like '%Accounting with Multi Entity%' and Status=1
		
	end
	End
GO
