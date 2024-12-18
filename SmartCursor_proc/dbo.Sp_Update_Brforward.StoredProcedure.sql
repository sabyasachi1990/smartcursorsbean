USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Update_Brforward]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE procedure  [dbo].[Sp_Update_Brforward]  (@companyId bigint)
AS BEGIN

Declare @Employeeid Uniqueidentifier,
		@leaveTypeId Uniqueidentifier,
		@BroughtForward float

Declare Update_Brf Cursor For
	select EmployeeId,LeaveTypeId,BroughtForward  from SmartCursorPRDLiveReplicaHR.HR.LeaveEntitlement   
 where EmployeeId in (select Id from Common.Employee where CompanyId=@companyId) and LeaveTypeId='CB156EE4-43D9-44E9-891E-8FE9A3063A7B' and Status=1
  order by EmployeeId

Open Update_Brf
Fetch Next From Update_Brf Into @Employeeid,@leaveTypeId,@BroughtForward
While @@FETCH_STATUS=0
Begin 

update HR.LeaveEntitlement set BroughtForward=@BroughtForward where EmployeeId=@Employeeid and LeaveTypeId='CB156EE4-43D9-44E9-891E-8FE9A3063A7B' and Status=1
  

Fetch Next From Update_Brf Into @Employeeid,@leaveTypeId,@BroughtForward
End

Close Update_Brf
Deallocate Update_Brf

End
GO
