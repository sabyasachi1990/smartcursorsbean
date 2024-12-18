USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_HR_CarryForwardReset]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Sp_HR_CarryForwardReset]
AS 
BEGIN

--Note Current = Adjustment + Prorated + RemainingProrated + BroughtForward 
--	 Leave Balance = Current - ( ApprovedAndTaken - ApprovedAndNotTaken )
--	 NoOfDays = Take it from HR.LeaveType Table 
--	 If Leave Balance < NoOfDays 
--	   BroughtForward = Leave Balance
--	 else 
--	  BroughtForward = NoOfDays


 BEGIN TRANSACTION
 BEGIN TRY

	--UPDATE  LEO SET LEO.BroughtForward = (CASE WHEN LEO.LeaveBalance < LEO.CarryForwardDays THEN LEO.LeaveBalance ELSE LEO.CarryForwardDays END) FROM 
	--(
	--	SELECT   LE.Id AS LeId, (ISNULL(LE.Adjustment,0) + ISNULL(LE.Prorated,0.0) + ISNULL(LE.BroughtForward,0)) --current
	--			 - (ISNULL(LE.ApprovedAndTaken,0) + ISNULL(LE.ApprovedAndNotTaken,0)) AS LeaveBalance ,ISNULL(CAST(LE.CarryForwardDays AS float),0) AS CarryForwardDays , LE.BroughtForward  FROM  
	--		Common.Employee E INNER JOIN 
	--		HR.LeaveEntitlement LE ON E.Id=LE.EmployeeId INNER JOIN 
	--		HR.LeaveType LT ON LT.Id=LE.LeaveTypeId INNER JOIN
	--		Common.HRSettings HS ON HS.CompanyId = E.CompanyId INNER JOIN
	--		Common.HRSettingdetails HRD ON HRD.MasterId = HS.Id 

	--	WHERE 
	--		LE.CreatedDate >= HRD.StartDate AND LE.CreatedDate < =HRD.EndDate
	--		AND LT.IsCarryForward = 1 AND LT.EntitlementType = 'Days' --AND LT.EntitlementType <> 'Hours'
	--		AND (ISNULL(LE.Adjustment,0) + ISNULL(LE.Prorated,0.0) + ISNULL(LE.BroughtForward,0)) --current
	--			 - (ISNULL(LE.ApprovedAndTaken,0) + ISNULL(LE.ApprovedAndNotTaken,0)) > 0 
	--		AND LE.CarryForwardDays IS NOT NULL--for no of days not null only
	--)LEO 

	-----UPDATE THE CARRYFORWARDRESETDATE AND ISRESETCOMPLETED IN HRSettingdetails
	--UPDATE HRSD SET HRSD.IsResetCompleted = 1 FROM 
	--(
	--	SELECT ROW_NUMBER() OVER(PARTITION BY HRSD.MasterId ORDER BY HRSD.StartDate DESC) AS Row_Num, HRSD.* 
	--	FROM 
	--		Common.HRSettings HRS INNER JOIN 
	--		Common.HRSettingdetails HRSD ON HRS.Id = HRSD.MasterId
	--	WHERE CAST( HRS.CarryforwardResetDate AS date)=CAST(GETUTCDATE() AS date) 
	--)HRSD WHERE HRSD.Row_Num = 1

	COMMIT;

 END TRY

 BEGIN CATCH

	ROLLBACK
	PRINT 'In Catch Block';
	THROW;
 END CATCH

END


GO
