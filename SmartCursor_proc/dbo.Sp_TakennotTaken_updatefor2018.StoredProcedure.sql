USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_TakennotTaken_updatefor2018]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure  [dbo].[Sp_TakennotTaken_updatefor2018]  (@companyId bigint)
AS BEGIN

Declare @Employeeid Uniqueidentifier,
		@leaveTypeId Uniqueidentifier,
		@startdate Datetime,
		@Days float,
		@Hours float,
		@EntitlementType Nvarchar(50)

		update HR.LeaveEntitlement set ApprovedAndTaken=null,ApprovedAndNotTaken=null  from HR.LeaveEntitlement  as le join 
Common.Employee  as ce on le.EmployeeId = ce.Id
where ce.CompanyId=@companyId and le.Status=2 and EntitlementStatus=2


Declare Leave_App Cursor For
	select EmployeeId,LeaveTypeId,StartDateTime, ISNULL(Days,0),IsNull(Hours,0) from HR.LeaveApplication    as le  
join HR.LeaveType as lt on le.LeaveTypeId = lt.Id
 where le.CompanyId=@companyId and  ( le.LeaveStatus='Approved' or LeaveStatus= 'For Cancellation')  and 
 lt.CompanyId=@companyId  and le.StartDateTime like '%2018%' and le.EndDateTime like '%2018%'
  order by EmployeeId

Open Leave_App
Fetch Next From Leave_App Into @Employeeid,@leaveTypeId,@startdate,@Days,@Hours
While @@FETCH_STATUS=0
Begin 

  set @EntitlementType=(select EntitlementType from HR.LeaveType where Id= @leaveTypeId );

If convert(date,@startdate) <= convert(date,GETDATE())
  Begin
  If (@EntitlementType = 'Days')
  Begin
   update HR.LeaveEntitlement set ApprovedAndTaken=ISNULL(ApprovedAndTaken,0)+@Days Where EmployeeId=@Employeeid And LeaveTypeId=@leaveTypeId and Status=2 and EntitlementStatus=2
   End
   else
   Begin
   update HR.LeaveEntitlement set ApprovedAndTaken=ISNULL(ApprovedAndTaken,0)+@Hours Where EmployeeId=@Employeeid And LeaveTypeId=@leaveTypeId and Status=2 and EntitlementStatus=2
   End
 End
Else 
  Begin
  If (@EntitlementType = 'Days')
  Begin
   update HR.LeaveEntitlement set ApprovedAndNotTaken=ISNULL(ApprovedAndNotTaken,0)+@Days Where EmployeeId=@Employeeid And LeaveTypeId=@leaveTypeId and Status=2 and EntitlementStatus=2
   End
   else
   Begin
   update HR.LeaveEntitlement set ApprovedAndNotTaken=ISNULL(ApprovedAndNotTaken,0)+@Hours Where EmployeeId=@Employeeid And LeaveTypeId=@leaveTypeId and Status=2 and EntitlementStatus=2
   End
  End

Fetch Next From Leave_App Into @Employeeid,@leaveTypeId,@startdate,@Days,@Hours
End

Close Leave_App
Deallocate Leave_App

End
GO
