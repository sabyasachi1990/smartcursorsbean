USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_ClaimDetail_Delink]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





--exec HR_ClaimDetail_Delink 'a7d2d19c-1676-4425-99d3-9b71d9241648','c978df27-d7aa-43c2-90ec-891d67ac3271',2602

Create   proc [dbo].[HR_ClaimDetail_Delink]
@payrollId UNIQUEIDENTIFIER,@employeeId UNIQUEIDENTIFIER,@companyId BIGINT
AS
BEGIN
--Local Variables
DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ClaimIds NVARCHAR(MAX)
CREATE TABLE #ClaimPayrollDelink(ClaimId UNIQUEIDENTIFIER,DocNo NVARCHAR(500),EmployeeName NVARCHAR(500),ApprovedAMount MONEY,Delink BIT,EmployeeId Uniqueidentifier,PayrollId Uniqueidentifier,ClaimStatus NVARCHAR(100))
Declare @tempClaim table(ClaimId Uniqueidentifier)
	--BEGIN TRY
	--BEGIN TRANSACTION
	SET @ClaimIds = (SELECT claimIds FROM HR.PayrollDetails where MasterId = @payrollId and EmployeeId = @employeeId)
	
	Insert Into #ClaimPayrollDelink
		Select EC.Id,EC.ClaimNumber,E.FirstName,EC.TotalApprovedAmount,1,@employeeId,@payrollId,EC.ClaimStatus from HR.EmployeeClaim1 EC		
		INNER JOIN Common.Employee E ON E.ID = EC.EmployeId Where EmployeId = @employeeId and EC.ClaimStatus = 'Approved' and ec.ParentCompanyId = @companyId and EC.Id in ( select items from dbo.SplitToTable(@ClaimIds,','))
	Insert into @tempClaim
		Select ClaimId from #ClaimPayrollDelink
	
	
	
	
	DECLARE @claimId NVARCHAR(MAX)
	Declare ClaimDetails Cursor For Select items from dbo.SplitToTable(@ClaimIds,',')
	Open ClaimDetails 
	Fetch Next From ClaimDetails Into @claimId
	While @@FETCH_STATUS=0
	BEGIN
		IF(@claimId !='')
		BEGIN
			Declare @clmId Uniqueidentifier = Convert(uniqueidentifier,@claimId)
		END
		UPDATE #ClaimPayrollDelink SET Delink = 0 WHERE ClaimId in (Select ClaimId from @tempClaim except SELECT @clmId)
	Fetch Next From ClaimDetails Into @claimId
	END -- Cursor Loop End
	Close ClaimDetails
	Deallocate ClaimDetails
	SELECT ClaimId AS ClaimId,DocNo AS DocNo,EmployeeName as EmployeeName,ApprovedAMount as ApprovedAmount, Delink as Delink,EmployeeId As EmployeeId , PayrollId As PayrollId,ClaimStatus As ClaimStatus FROM #ClaimPayrollDelink
	DROP TABLE #ClaimPayrollDelink
	--COMMIT TRANSACTION
	--END TRY
	--BEGIN CATCH
	--	ROLLBACK
	--	SELECT @ErrorMessage=ERROR_MESSAGE()
	--		RAISERROR(@ErrorMessage,16,1);
	--END CATCH
END
GO
