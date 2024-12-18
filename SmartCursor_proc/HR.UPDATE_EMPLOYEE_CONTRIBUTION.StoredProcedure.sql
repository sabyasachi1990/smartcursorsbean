USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [HR].[UPDATE_EMPLOYEE_CONTRIBUTION]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [HR].[UPDATE_EMPLOYEE_CONTRIBUTION](@Company_Id bigint, @Pare_Company_Id bigint)
AS
BEGIN
	--select * 
	Update EPS set EPS.IsCPFContributionFull=0 from hr.EmployeePayrollSetting EPS (NOLOCK)
    Join Common.Employee E (NOLOCK) on EPS.EmployeeId = E.Id
	Join HR.EmployeeDepartment ED (NOLOCK) on E.Id = ED.EmployeeId
	where (Convert(date,EffectiveFrom) <= CONVERT(date,GETDATE()) AND (EffectiveTo IS NULL or CONVERT(date,EffectiveTo) >= CONVERT(date,GETDATE())))
	and ED.CompanyId = @Company_Id and E.CompanyId= @Pare_Company_Id and EPS.CompanyId=@Pare_Company_Id
END
GO
