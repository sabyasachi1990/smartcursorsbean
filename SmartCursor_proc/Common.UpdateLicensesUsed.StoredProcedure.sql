USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[UpdateLicensesUsed]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     procedure [Common].[UpdateLicensesUsed]
(
@companyId bigint,
@moduleName nvarchar(50),   -- hr, wf, cc, br, audit, bean
@status nvarchar(20),       -- active, inactive
@chargeUnit nvarchar(20)    -- user, engagement, entity  -- exec Common.UpdateLicensesUsed 667,'Wirkflow Cursor','active','user'
)

As begin
begin try
declare @country nvarchar(50) =(select Jurisdiction from Common.Company (NOLOCK) where Id=@companyId)

	----#region
	--if(@status = 'active')
	--begin
	--	update CPM set CPM.LicensesUsed = case when (ISNULL(CPM.licensesUsed,0)+1) > cpm.LicensesReserved then cpm.LicensesReserved else (ISNULL(CPM.licensesUsed,0)+1) end   
	--	from License.CompanyPackageModule CPM (NOLOCK)
	--	join License.PackageModule PM (NOLOCK) on CPM.ModuleMasterId = PM.ModuleMasterId
	--	join License.Package P (NOLOCK) on P.Id = PM.PackageId
	--	Join Common.ModuleMaster MM (NOLOCK) on MM.Id = PM.ModuleMasterId
	--	 WHERE 
	--       CPM.CompanyId = @companyId AND PM.ModuleMasterId = MM.Id AND P.ChargeUnit = @chargeUnit AND P.Country = @country AND CPM.ChargeUnit = @chargeUnit
	--	  and (MM.Name = @moduleName)
	--        --and ((@moduleName IN ('Workflow Cursor', 'Client Cursor') AND MM.Name IN ('Workflow Cursor', 'Client Cursor'))
	--        --OR (MM.Name = @moduleName)) 
	--end
	--else if(@status = 'inactive')
	--begin
	--	update CPM set CPM.LicensesUsed = case when (ISNULL(CPM.licensesUsed,0)-1) > 0 then (ISNULL(CPM.licensesUsed,0)-1) else 0 end
	--	--select * 
	--	from License.CompanyPackageModule CPM  (NOLOCK)
	--	join License.PackageModule PM (NOLOCK) on  CPM.ModuleMasterId = PM.ModuleMasterId
	--   	join License.Package P (NOLOCK) on P.Id = PM.PackageId
	--	Join Common.ModuleMaster MM (NOLOCK) on MM.Id = PM.ModuleMasterId
	--	 WHERE 
	--       CPM.CompanyId = @companyId AND PM.ModuleMasterId = MM.Id AND P.ChargeUnit = @chargeUnit AND P.Country = @country AND CPM.ChargeUnit = @chargeUnit
	--	and (MM.Name = @moduleName)
	--       -- and ((@moduleName IN ('Workflow Cursor', 'Client Cursor') AND MM.Name IN ('Workflow Cursor', 'Client Cursor'))
	--       --OR (MM.Name = @moduleName)) 
	--end

	
	--if(@status = 'active')
 --       BEGIN
 --           UPDATE s 
 --           SET s.LicensesUsed = 
 --               CASE 
 --                   WHEN (ISNULL(s.LicensesUsed, 0) + 1) > s.LicensesReserved THEN s.LicensesReserved 
 --                   ELSE (ISNULL(s.LicensesUsed, 0) + 1) 
 --               END
 --           FROM License.Subscription AS s WITH (NOLOCK)
	--		 JOIN License.Package AS P WITH (NOLOCK) ON P.Id = s.PackageId
 --           JOIN License.PackageModule AS PM WITH (NOLOCK) ON p.Id = PM.PackageId
 --           JOIN Common.ModuleMaster AS MM WITH (NOLOCK) ON MM.Id = PM.ModuleMasterId
 --           WHERE s.CompanyId = @companyId
 --           AND P.ChargeUnit = @chargeUnit
 --           AND P.Country = @country
 --           AND MM.Name = @moduleName;
 --       END

	--else if(@status = 'inactive')
 --      BEGIN
 --          UPDATE s 
 --          SET s.LicensesUsed = 
 --              CASE 
 --                  WHEN (ISNULL(s.LicensesUsed, 0) - 1) > 0 THEN (ISNULL(s.LicensesUsed, 0) - 1) 
 --                  ELSE 0 
 --              END
 --          FROM License.Subscription AS s WITH (NOLOCK)
 --          JOIN License.PackageModule AS PM WITH (NOLOCK) ON s.PackageId = PM.PackageId
 --          JOIN License.Package AS P WITH (NOLOCK) ON P.Id = PM.PackageId
 --          JOIN Common.ModuleMaster AS MM WITH (NOLOCK) ON MM.Id = PM.ModuleMasterId
 --          WHERE s.CompanyId = @companyId
 --          AND PM.ModuleMasterId = MM.Id
 --          AND P.ChargeUnit = @chargeUnit
 --          AND P.Country = @country
 --          AND MM.Name = @moduleName;
 --      END

	if(@chargeUnit='user')
	begin

		exec [Common].[UpdateLicensesUsed_AdminUser_Save]  @companyId,@chargeUnit

	end
	else if(@chargeUnit='entity')
	begin
		update top(1) S set S.LicensesUsed = 
		case when @status = 'active' 
		then 
		(case when (ISNULL(s.licensesUsed,0)+1) > s.LicensesReserved then s.LicensesReserved else (ISNULL(s.licensesUsed,0)+1) end) 
		else ( case when (ISNULL(s.licensesUsed,0)-1) > 0 then (ISNULL(s.licensesUsed,0)-1) else 0 end) end		
		from License.Subscription S (NOLOCK) 
		Left JOIN License.Package P (NOLOCK) on S.PackageId = P.Id
		--Join
		--(select CompanyId as CompanyId, count(*) as LicensesUsed 
		--from Common.EntityDetail where CompanyId=@companyId and Status=1 group by  CompanyId) as S1
		--on S.CompanyId = S1.CompanyId
		where s.CompanyId=@companyId and P.ChargeUnit= @chargeUnit and p.Country=@country and S.LicensesReserved >= S.LicensesUsed and S.Status=1
	end
	else if(@chargeUnit='employee')
	begin
         UPDATE A 
         SET A.LicensesUsed = b.LicensesUsed
         FROM License.Subscription AS A
         INNER JOIN
         (
         	SELECT SubscriptionId,ISNULL(COUNT(A.EmployeeSubscriptionId),0) As LicensesUsed
         	FROM (
         		select S.Id AS Subscriptionid,S.CompanyId,e.SubscriptionId as EmployeeSubscriptionId 
         		FROM License.Subscription S WITH (NOLOCK)
         		LEFT JOIN License.Package P WITH (NOLOCK) ON S.PackageId = P.Id
         		LEFT JOIN Common.Employee E WITH (NOLOCK) ON E.SubscriptionId = S.Id and e.Status=1 
         		WHERE S.CompanyId = @companyId and s.Status=1
         		AND P.ChargeUnit = @chargeUnit
         		AND S.LicensesReserved >= S.LicensesUsed) AS A
         	GROUP BY SubscriptionId
         ) AS B ON B.Subscriptionid = A.Id



		--update top(1) S set S.LicensesUsed = 
		--case when @status = 'active' 
		--then 
		--(case when (ISNULL(s.licensesUsed,0)+1) > s.LicensesReserved then s.LicensesReserved else (ISNULL(s.licensesUsed,0)+1) end) 
		--else ( case when (ISNULL(s.licensesUsed,0)-1) > 0 then (ISNULL(s.licensesUsed,0)-1) else 0 end) end		
		--from License.Subscription S (NOLOCK) 
		--Left JOIN License.Package P (NOLOCK) on S.PackageId = P.Id
		----Join
		----(select CompanyId as CompanyId, count(*) as LicensesUsed 
		----from Common.Employee where CompanyId=@companyId and Status=1 group by  CompanyId) as S1
		----on S.CompanyId = S1.CompanyId
		--where S.CompanyId=@companyId and P.ChargeUnit= @chargeUnit and p.Country=@country and S.LicensesReserved >= S.LicensesUsed
	end
	
	--else if(@chargeUnit='engagement' and @moduleName= 'Tax Cursor')
	--begin
	--	update top(1) S set S.LicensesUsed = 
	--	case when @status = 'active' 
	--	then 
	--	(case when (ISNULL(s.licensesUsed,0)+1) > s.LicensesReserved then s.LicensesReserved else (ISNULL(s.licensesUsed,0)+1) end) 
	--	else ( case when (ISNULL(s.licensesUsed,0)-1) > 0 then (ISNULL(s.licensesUsed,0)-1) else 0 end) end		
	--	from License.Subscription S (NOLOCK) 
	--	Left JOIN License.Package P (NOLOCK) on S.PackageId = P.Id
	--	--Join
	--	--(select CompanyId as CompanyId, count(*) as LicensesUsed 
	--	--from Audit.AuditCompanyEngagement Ace  join 
	--	--Audit.AuditCompany Ac on Ace.AuditCompanyId=Ac.Id where Ac.CompanyId=@companyId and Ace.Status=1 group by  CompanyId) as S1
	--	--on S.CompanyId = S1.CompanyId
	--	where S.CompanyId=@companyId and P.ChargeUnit= @chargeUnit and p.Country=@country and S.LicensesReserved >= S.LicensesUsed
	--end

end try
begin catch

end catch
END
GO
