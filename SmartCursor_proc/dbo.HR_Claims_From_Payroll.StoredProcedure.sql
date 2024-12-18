USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Claims_From_Payroll]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec HR_Claims_From_Payroll '9d33a39b-247e-4e91-8873-b830f93ce3c8','Saved As Draft','2021-Dec','00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000',2603

CREATE proc [dbo].[HR_Claims_From_Payroll]
@payrollId UNIQUEIDENTIFIER,@payrollStatus NVARCHAR(MAX),@PayrollYearMonth NVARCHAR(MAX),@EmployeeId UNIQUEIDENTIFIER,@payrollDetailId UNIQUEIDENTIFIER,@companyId BIGINT,@parentCompanyId bigint
AS
BEGIN
--Local Variables
DECLARE @ErrorMessage NVARCHAR(4000)
Declare @Count int = 1
Declare @recCount int
Declare @tempEmp table(S_No int identity(1,1),EmployeeId Uniqueidentifier)
--Declare @parentCompanyId BIGINT
	BEGIN TRY
	--BEGIN TRANSACTION
	--SET @parentCompanyId = (Select ParentId from Common.Company Where Id = @companyId)
	IF(@EmployeeId != '00000000-0000-0000-0000-000000000000' AND @payrollDetailId !='00000000-0000-0000-0000-000000000000')
	begin
	Declare @ClaimIds NVARCHAR(MAX)
	--Update HR.EmployeeClaim1 Set PayrollId = @payrollId, PayrollStatus = @payrollStatus, PayrollYearMonth = @PayrollYearMonth Where EmployeId = @EmployeeId and ClaimStatus = 'Approved' 

		SELECT @ClaimIds =(select ClaimIds from HR.PayrollDetails (NOLOCK) where MasterId=@payrollId and EmployeeId=@EmployeeId)

		--Update HR.PayrollDetails Set ClaimIds = @ClaimIds Where Id = @payrollDetailId
		if(@payrollStatus!='Cancelled')
		begin --1
		Update HR.EmployeeClaim1 Set PayrollId = @payrollId, PayrollStatus = @payrollStatus, PayrollYearMonth = @PayrollYearMonth Where EmployeId = @EmployeeId and (ClaimStatus = 'Approved') AND ParentCompanyId = @parentCompanyId and id in ( select items from dbo.SplitToTable(@ClaimIds,','))
		end --1
		else
		begin --2
		if not exists(select * from HR.HrAuditTrails (NOLOCK) where Type='Payroll' and TypeId=@payrollId and RecordStatus='Processed' )
		begin--3
		Update HR.EmployeeClaim1 Set PayrollId = null, PayrollStatus = null, PayrollYearMonth = null Where EmployeId = @EmployeeId and (ClaimStatus = 'Approved' ) AND ParentCompanyId = @parentCompanyId and id in ( select items from dbo.SplitToTable(@ClaimIds,','))
		update HR.PayrollDetails set ClaimIds=null where EmployeeId=@EmployeeId and MasterId=@payrollId
		end--3
		else
		begin --4
		Update HR.EmployeeClaim1 Set PayrollStatus =@payrollStatus  Where EmployeId = @EmployeeId and (ClaimStatus = 'Approved' ) AND ParentCompanyId = @parentCompanyId and id in ( select items from dbo.SplitToTable(@ClaimIds,','))
		end--4
		end--2
	end
	else
	begin
		Insert into @tempEmp
		Select PD.EmployeeId from HR.Payroll P (NOLOCK)
		Inner Join HR.PayrollDetails PD (NOLOCK) ON P.Id = PD.MasterId
		Inner Join HR.PayrollSplit PS (NOLOCK) ON PD.Id = PS.PayrollDetailId
		Inner Join HR.PayComponent PC (NOLOCK) ON PS.PayComponentId = PC.Id where PC.[Name] = 'Claim Reimbursements' AND P.Id = @payrollId
		
		Set @recCount = (Select Count(*) From @tempEmp)
		While(@recCount >= @Count)
		Begin
		IF Exists(Select * from @tempEmp)
		BEGIN
		Declare @ClaimIdss NVARCHAR(MAX)
		SET @EmployeeId = (Select EmployeeId from @tempEmp where S_No = @count)
		
		set @payrollDetailId = (Select ID from HR.PayrollDetails (NOLOCK) where MasterId = @payrollId AND EmployeeId = @EmployeeId)
		
		
		--Update HR.EmployeeClaim1 Set PayrollId = @payrollId, PayrollStatus = @payrollStatus, PayrollYearMonth = @PayrollYearMonth Where EmployeId = @EmployeeId and (ClaimStatus = 'Approved' OR ClaimStatus = 'Processed') AND ParentCompanyId = @parentCompanyId

		--SELECT @ClaimIdss = COALESCE(@claimIds + ',', '') + CAST(Id AS VARCHAR(MAX)) FROM HR.EmployeeClaim1 Where EmployeId = @EmployeeId and ClaimStatus = 'Approved' AND ParentCompanyId = @parentCompanyId and PayrollId=@payrollId
		SELECT @ClaimIdss=(select ClaimIds from HR.PayrollDetails (NOLOCK) where MasterId=@payrollId and EmployeeId=@EmployeeId)

		--Update HR.PayrollDetails Set ClaimIds = @ClaimIdss Where Id = @payrollDetailId
		if(@payrollStatus!='Cancelled')
		begin --1
		Update HR.EmployeeClaim1 Set PayrollId = @payrollId, PayrollStatus = @payrollStatus, PayrollYearMonth = @PayrollYearMonth Where EmployeId = @EmployeeId and (ClaimStatus = 'Approved' OR ClaimStatus = 'Processed') AND ParentCompanyId = @parentCompanyId and id in ( select items from dbo.SplitToTable(@ClaimIdss,','))
		end --1
		else
		begin --2
		if not exists(select * from HR.HrAuditTrails (NOLOCK) where Type='Payroll' and TypeId=@payrollId and RecordStatus='Processed' )
		begin--3
		Update HR.EmployeeClaim1 Set PayrollId = null, PayrollStatus = null, PayrollYearMonth = null Where EmployeId = @EmployeeId and (ClaimStatus = 'Approved' OR ClaimStatus = 'Processed') AND ParentCompanyId = @parentCompanyId and id in ( select items from dbo.SplitToTable(@ClaimIdss,','))
		update HR.PayrollDetails set ClaimIds=null where EmployeeId=@EmployeeId and MasterId=@payrollId
		end --3
		else
		begin--4
		Update HR.EmployeeClaim1 Set PayrollStatus = @payrollStatus Where EmployeId = @EmployeeId and (ClaimStatus = 'Approved' OR ClaimStatus = 'Processed') AND ParentCompanyId = @parentCompanyId and id in ( select items from dbo.SplitToTable(@ClaimIdss,','))
		end--4
		end--2


		END
	
		Set @Count = @Count + 1
		End
	end
	--COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		--ROLLBACK
		SELECT @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
	END CATCH
END
GO
