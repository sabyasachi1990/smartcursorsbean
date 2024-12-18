USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Claim_SavePaycomponent]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   proc [dbo].[HR_Claim_SavePaycomponent]
@employeeId UNIQUEIDENTIFIER,@companyId BIGINT
AS
BEGIN
--Local Variables
DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @clmRemId UNIQUEIDENTIFIER
DECLARE @deptId UNIQUEIDENTIFIER
DECLARE @desigId UNIQUEIDENTIFIER
DECLARE @count int = 1
DECLARE @reCount int

Declare @tempDept table (S_no int identity(1,1),DeptId Uniqueidentifier,DesigId Uniqueidentifier)
	BEGIN TRY
	BEGIN TRANSACTION
		SET @clmRemId = (SELECT Id FROM HR.PayComponent where companyId = @companyId and [Name] = 'Claim Reimbursements')
		Insert into @tempDept
		SELECT DepartmentId,DepartmentDesignationId FROM HR.EMPLOYEEDEPARTMENT where employeeid = @employeeId
		Set @reCount = (select COUNT(*) from @tempDept)
		While(@reCount >= @count)
		Begin
		Set @deptId = (Select DeptId from @tempDept where S_no = @count)
		Set @desigId = (Select DesigId from @tempDept where S_no = @count)

		Insert Into Hr.paycomponentdetail(Id,MasterId,DepartmentId,DesignationId,EmployeeId,PayMethod,UserCreated,CreatedDate,[Status])
			select NewId(),@clmRemId,@deptId,@desigId,@employeeId,'Amount','System',GetUtcDate(),1

		Set @count = @count +1
		End
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK
		SELECT @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
	END CATCH
END

select * from hr.paycomponent where companyid = 2602

select * from hr.paycomponentdetail where masterid = '3FD8B008-234D-4E3F-A061-8B0CEE5116C0'

sELECT * FROM hr.payrolldetails where masterid = '9d33a39b-247e-4e91-8873-b830f93ce3c8'
GO
