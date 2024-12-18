USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[UserInactivation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create proc [Common].[UserInactivation] (@CompanyUserId bigint)
AS
BEGIN
--Delete Common.CompanyUserSubscription where SubscriptionId=@UserId
Declare @CUSub Table(SubscriptionId Uniqueidentifier,CompanyUserId bigint)
Declare @Temp Table(CompanyUserId bigint)
Declare @Sub Table(CompanyId bigint , LicensesReserved int ,ModuleMasterId int)

--insert into @Temp
--select CU.Id from  Common.CompanyUser CU  where CU.UserId='e9b2214d-22f4-4d9b-bcdf-e5152fe451a5' and CU.CompanyId=1819
--select* from @Temp

insert into @CUSub
select CUS.SubscriptionId , CUS.CompanyUserId from Common.CompanyUserSubscription CUS where CUS.CompanyUserId in (@CompanyUserId)
--select * from @CUSub

insert into @Sub
select S.CompanyId, S.LicensesReserved,PM.ModuleMasterId from License.Subscription S join License.PackageModule PM on S.PackageId=PM.PackageId where S.Id in (select SubscriptionId from @CUSub)
--select * from @Sub

IF  EXISTS ( SELECT *  FROM  @CUSub)
begin

Update S set S.LicensesUsed=(S.LicensesUsed - 1) from License.Subscription S where Id in (select SubscriptionId from @CUSub) and S.LicensesUsed<>0

update CP set CP.LicensesUsed=(CP.LicensesUsed - 1) from License.CompanyPackageModule CP  
inner join @Sub T on CP.ModuleMasterId=T.ModuleMasterId where T.CompanyId=CP.CompanyId and CP.LicensesUsed<>0

update  Auth.UserRoleNew set Status=2 where CompanyUserId in (@CompanyUserId)

Delete Common.CompanyUserSubscription where CompanyUserId in (@CompanyUserId) and SubscriptionId in (select SubscriptionId from @CUSub) 
End
End
GO
