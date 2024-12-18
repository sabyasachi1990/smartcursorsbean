USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[UpdateLicensesUsed_AdminCursor]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create   procedure [Common].[UpdateLicensesUsed_AdminCursor]
(
@companyId bigint,
--@moduleName nvarchar(50),   -- hr, wf, cc, br, audit, bean
@status nvarchar(20),       -- active, inactive
@chargeUnit nvarchar(20),   -- user, engagement, entity  -- exec Common.UpdateLicensesUsed 667,'Wirkflow Cursor','active','user'
@companyUserId bigint       -- Login user Id  
)
AS
BEGIN

    delete from Common.CompanyUserSubscription where CompanyUserId=@companyUserId

	insert into Common.CompanyUserSubscription (Id, CompanyId, CompanyUserId, SubscriptionId)
	select newId(), @companyId, @companyUserId, R.SubscriptionId  /*, S.SubscriptionName,URN.CompanyUserId, count(*)*/ 
	from Auth.RoleNew R
	left Join Auth.UserRoleNew URN on R.Id = URN.RoleId
	Left Join License.Subscription S on S.Id = R.SubscriptionId
	where R.CompanyId=@companyId and R.SubscriptionId is not null and URN.CompanyUserId = @companyUserId And URN.Status=1
	group by R.SubscriptionId, S.SubscriptionName, URN.CompanyUserId

    exec [Common].[UpdateLicensesUsed_AdminUser_Save] @companyId,  @chargeUnit
END
GO
