USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_LeavesCount]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[SP_LeavesCount](@CompanyId bigint, @UserName nvarchar(50), @isFromESS bit, @hrsettingDetailId uniqueidentifier, @isLeaveManager bit, @leaveTypeId uniqueidentifier = null)
as 
begin
	begin try
	    declare @LeavesCount table (Leavestate nvarchar(20), LeaveCount int)
		declare @EmployeeId uniqueidentifier
		declare @startDate datetime2(7) = (select startDate from Common.HRSettingdetails (NOLOCK) where id=@hrsettingDetailId)
		declare @endDate datetime2(7) = (select EndDate from Common.HRSettingdetails (NOLOCK) where id=@hrsettingDetailId)

		 if(@UserName is not null)
		 begin

			SET @EmployeeId = (select Id from Common.Employee (NOLOCK) where Username=@UserName and CompanyId=@CompanyId)
		end
		begin
			if(/*@EmployeeId is not null and*/ @isFromESS = 1)   -- Employee Wise Leave Applications (My Leaves)
			begin
		    if(@startDate is not null)
			 begin
			 if(@leaveTypeId is not null)
			 begin
			 insert into @LeavesCount values('All', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) and LeaveTypeId=@leaveTypeId ))     --  All count		     

				insert into @LeavesCount values('Submitted', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Submitted' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) and LeaveTypeId=@leaveTypeId ))    -- Submitted count

	    		insert into @LeavesCount values('Approved', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Approved' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >= Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) and LeaveTypeId=@leaveTypeId ))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Rejected' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)and LeaveTypeId=@leaveTypeId  ))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Recommended' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) and LeaveTypeId=@leaveTypeId ))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Cancelled' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)and LeaveTypeId=@leaveTypeId  ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='For Cancellation' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) and LeaveTypeId=@leaveTypeId ))  -- For Cancellation Count
			 end
		  else
			 begin
				insert into @LeavesCount values('All', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) ))     --  All count		     

				insert into @LeavesCount values('Submitted', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Submitted' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))    -- Submitted count

	    		insert into @LeavesCount values('Approved', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Approved' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >= Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Rejected' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) ))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Recommended' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Cancelled' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='For Cancellation' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))  -- For Cancellation Count

				end
				end
			else
				begin
				 if(@leaveTypeId is not null)
				 begin
				 insert into @LeavesCount values('All', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId))     --  All count		     

				insert into @LeavesCount values('Submitted', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Submitted' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId ))    -- Submitted count

	    		insert into @LeavesCount values('Approved', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Approved' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Rejected' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Recommended' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Cancelled' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='For Cancellation' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId))  -- For Cancellation Count
				 end
			 else
				 begin
				 insert into @LeavesCount values('All', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and EmployeeId=@EmployeeId))     --  All count		     

				insert into @LeavesCount values('Submitted', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Submitted' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId ))    -- Submitted count

	    		insert into @LeavesCount values('Approved', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Approved' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Rejected' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId ))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Recommended' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId ))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Cancelled' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='For Cancellation' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId))  -- For Cancellation Count
				end
				end

			end
			else if(@isFromESS != 1 and @isLeaveManager = 1)   -- company wise Leave Applications (Leave Management)
			begin
				insert into @LeavesCount values('All', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))     --  All count		     

				insert into @LeavesCount values('Submitted', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Submitted' and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))    -- Submitted count

	    		insert into @LeavesCount values('Approved', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Approved' and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Rejected' and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Recommended' and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Cancelled' and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select COUNT(*) from HR.LeaveApplication (NOLOCK) where CompanyId=@CompanyId and  Status=1 and LeaveStatus='For Cancellation' and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))  -- For Cancellation Count

     		end
		end
		select * from @LeavesCount
	 end try
	begin catch
		print ('Failed..!')
	end catch
end






GO
