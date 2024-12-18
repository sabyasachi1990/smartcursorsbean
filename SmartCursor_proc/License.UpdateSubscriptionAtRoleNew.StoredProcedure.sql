USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [License].[UpdateSubscriptionAtRoleNew]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 Create     proc [License].[UpdateSubscriptionAtRoleNew] (
@subscriptionId Uniqueidentifier,
@companyId bigint)
AS
BEGIN
BEGIN TRY  
	BEGIN TRANSACTION;  
		declare @temp table (subscriptionId uniqueidentifier, subscriptionName nvarchar(200), PackageName nvarchar(200), ModuleMasterId int, CompanyId bigint, [Status] int)
		insert into @temp
		select S.Id as SubscriptionId, S.SubscriptionName, P.Name, PM.ModuleMasterId, S.CompanyId, S.Status  from License.Subscription S
		JOIN License.Package P ON s.PackageId = P.Id
		JOIN License.PackageModule PM ON P.Id = PM.PackageId
		where S.Id = @subscriptionId and S.CompanyId = @companyId

		--select * from @temp

		declare @temp1 table (subscriptionId uniqueidentifier, subscriptionName nvarchar(200), [Status] int)
		IF Exists ( select * from @temp where ModuleMasterId <= 2 )
		BEGIN
		Print 'ModuleMasterId <=2'
			insert into @temp1
			select R.SubscriptionId, s.SubscriptionName, S.Status from Auth.RoleNew R
			join License.Subscription S on R.SubscriptionId = S.Id
			where R.ModuleMasterId in (select ModuleMasterId from @temp) and R.CompanyId = @companyId 
		END
		ELSE
		BEGIN
		print 'ModuleMasterId > 2'
			insert into @temp1
			select R.SubscriptionId, s.SubscriptionName, S.Status from Auth.RoleNew R
			join License.Subscription S on R.SubscriptionId = S.Id
			where R.ModuleMasterId in (select ModuleMasterId from @temp) and R.CompanyId = @companyId and S.SubscriptionName like CONCAT('%', (select top 1 PackageName from @temp), '%') 
		END

		--select * from @temp1

		if Exists (select * from @temp1 where status=4)
		BEGIN
			declare @activeSubScriptionId uniqueidentifier = 
			(select top 1 S.Id as SubscriptionId from License.Subscription S
				JOIN License.Package P ON s.PackageId = P.Id
				JOIN License.PackageModule PM ON P.Id = PM.PackageId
				where PM.ModuleMasterId = (select top 1 ModuleMasterId from @temp) 
				and SubscriptionName like CONCAT('%', (select top 1 PackageName from @temp), '%')
				and S.CompanyId = @companyId and S.Status= 1)
			--select @activeSubScriptionId
			IF (@activeSubScriptionId IS NOT NULL)
			  begin 
				 update Auth.Rolenew set SubscriptionId= @activeSubScriptionId where CompanyId = @companyId and  SubscriptionId in (select distinct subscriptionId from @temp1) 
			  End
		END
	COMMIT TRANSACTION;  
	END TRY  
	BEGIN CATCH  
		SELECT   
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_MESSAGE() AS ErrorMessage; 
		ROLLBACK TRANSACTION;  
	END CATCH;  
END
GO
