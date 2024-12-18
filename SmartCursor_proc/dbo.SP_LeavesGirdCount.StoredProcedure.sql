USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_LeavesGirdCount]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



 CREATE procedure [dbo].[SP_LeavesGirdCount](@CompanyId bigint,@UserName nvarchar(50), @isFromESS bit,@employeeId uniqueidentifier, @hrsettingDetailId uniqueidentifier, @leaveTypeId uniqueidentifier = null,@Type nvarchar(50))
as 
begin
	begin try
	    declare @LeavesCount table (Leavestate nvarchar(20), LeaveCount int)
		declare @startDate datetime2(7) = (select startDate from Common.HRSettingdetails where id=@hrsettingDetailId)
		declare @endDate datetime2(7) = (select EndDate from Common.HRSettingdetails where id=@hrsettingDetailId)
		--declare @CompanyUserId bigint
		declare @RecEmployeId uniqueidentifier
		-- if(@UserName is not null)
		-- begin

		--	--SET @CompanyUserId = (select Id from Common.CompanyUser where Username=@UserName and CompanyId=@CompanyId)

		--	--SET @RecEmployeId = ( select EMPRA.EmployeeId from HR.EmployeRecandApprovers as EMPRA Join Common.CompanyUser as CU on  CU.CompanyId = @CompanyId  
		--	--                        Where EMPRA.TypeId = CU.Id and CU.Username = @UserName )

		--end

		begin
			if(/*@EmployeeId is not null and*/ @isFromESS = 1)   -- Employee Wise Leave Applications (My Leaves)
			begin
		    if(@startDate is not null)
			 begin
			 if(@leaveTypeId is not null)
			 begin
               if(@Type='My Leaves')
			   begin
			    insert into @LeavesCount values('All', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) and LeaveTypeId=@leaveTypeId ))     --  All count	

				insert into @LeavesCount values('Submitted', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Submitted' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) and LeaveTypeId=@leaveTypeId ))    -- Submitted count

	    		insert into @LeavesCount values('Approved', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Approved' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >= Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) and LeaveTypeId=@leaveTypeId ))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Rejected' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)and LeaveTypeId=@leaveTypeId  ))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Recommended' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) and LeaveTypeId=@leaveTypeId ))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Cancelled' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)and LeaveTypeId=@leaveTypeId  ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='For Cancellation' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) and LeaveTypeId=@leaveTypeId ))  -- For Cancellation Count
			end

			 else if(@Type='As Approver')
				begin
				insert into @LeavesCount values('All', (select COUNT( DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and LA.LeaveTypeId=@leaveTypeId
									and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )))     --  All count		     

				insert into @LeavesCount values('Submitted', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and LA.LeaveStatus='Submitted'and  Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)  and 
									 LA.LeaveTypeId=@leaveTypeId 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )))    -- Submitted count

	    		insert into @LeavesCount values('Approved',(select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Approved' and  Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select  COUNT( DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Rejected' and 
									  Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Recommended' and 
									  Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Cancelled' and 
									  Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId and LA.LeaveTypeId=@leaveTypeId 
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='For Cancellation'
									 and  Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- For Cancellation Count

				end

				else if(@Type='As Recommender')
				begin
				insert into @LeavesCount values('All', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName  and LA.LeaveTypeId=@leaveTypeId 
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId
									 and EMPR.ScreenName ='Leaves')  ) ))     --  All count		     

				insert into @LeavesCount values('Submitted', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Submitted' and  Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )))    -- Submitted count

	    		insert into @LeavesCount values('Approved', (select COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Approved' and LA.LeaveTypeId=@leaveTypeId and  Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Rejected' and LA.LeaveTypeId=@leaveTypeId and  Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Recommended' and LA.LeaveTypeId=@leaveTypeId and  Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Cancelled' and LA.LeaveTypeId=@leaveTypeId  and  Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId and  Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate) 
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='For Cancellation' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )))  -- For Cancellation Count

			end

		  end
		      else ------ without @leaveType fileter 


	            begin
				 if(@Type='My Leaves')
			    begin
				insert into @LeavesCount values('All', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) ))     --  All count		     

				insert into @LeavesCount values('Submitted', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Submitted' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))    -- Submitted count

	    		insert into @LeavesCount values('Approved', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Approved' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >= Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Rejected' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) ))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Recommended' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Cancelled' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate) ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='For Cancellation' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and Convert(Date,StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,StartDateTime) <= Convert(Date,@endDate)))  -- For Cancellation Count
				end
				 else if(@Type='As Approver')
			   begin
			       insert into @LeavesCount values('All', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName 
									and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))     --  All count		     

				insert into @LeavesCount values('Submitted', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Submitted'
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))    -- Submitted count

	    		insert into @LeavesCount values('Approved', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Approved'
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Rejected'
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Recommended'
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Cancelled'
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='For Cancellation'
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- For Cancellation Count
			   end


			    else if(@Type='As Recommender')
			   begin
			       insert into @LeavesCount values('All', (select COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName 
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))     --  All count		     

				insert into @LeavesCount values('Submitted', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Submitted'
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )  ))    -- Submitted count

	    		insert into @LeavesCount values('Approved', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Approved'
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Rejected'
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName  and  LA.LeaveStatus='Recommended'
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select  COUNT(DISTINCT LA.Id)from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Cancelled'
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )  ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='For Cancellation'
									 and Convert(Date,LA.StartDateTime) >=Convert(Date,@startDate) and  Convert(Date,LA.StartDateTime) <= Convert(Date,@endDate)
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )  ))  -- For Cancellation Count
			   end





		       end

			  


	   end






			else ---------without year fileter 
				begin
				 if(@leaveTypeId is not null)
				 begin


				   if(@Type='My Leaves')
				    begin
				          insert into @LeavesCount values('All', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId))     --  All count		     

				          insert into @LeavesCount values('Submitted', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Submitted' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId ))    -- Submitted count

	    		            insert into @LeavesCount values('Approved', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Approved' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId))  -- Approved Count

				              insert into @LeavesCount values('Rejected', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Rejected' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId))  -- Rejected Count

				           insert into @LeavesCount values('Recommended', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Recommended' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId))  -- Recommended Count

				          insert into @LeavesCount values('Cancelled', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Cancelled' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId))  -- Cancelled Count

				            insert into @LeavesCount values('ForCancellation', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='For Cancellation' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId and LeaveTypeId=@leaveTypeId))  -- For Cancellation Count





				 end

				 	else if(@Type='As Approver')
					 begin
				          insert into @LeavesCount values('All', (select COUNT(DISTINCT LA.Id)  from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )  ))     --  All count		     

				          insert into @LeavesCount values('Submitted', (select COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Submitted' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )  ))    -- Submitted count

	    		            insert into @LeavesCount values('Approved', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Approved' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )  ))  -- Approved Count

				              insert into @LeavesCount values('Rejected', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName  and  LA.LeaveStatus='Rejected' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )  ))  -- Rejected Count

				           insert into @LeavesCount values('Recommended', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Recommended' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )  ))  -- Recommended Count

				          insert into @LeavesCount values('Cancelled', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Cancelled' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Cancelled Count

				            insert into @LeavesCount values('ForCancellation', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='For Cancellation' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- For Cancellation Count

             		  end
 

 	                 else if(@Type='As Recommender')
					 begin
				          insert into @LeavesCount values('All', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))     --  All count		     

				          insert into @LeavesCount values('Submitted', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Submitted' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )  ))    -- Submitted count

	    		            insert into @LeavesCount values('Approved', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Approved' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Approved Count

				              insert into @LeavesCount values('Rejected', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Rejected' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Rejected Count

				           insert into @LeavesCount values('Recommended', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Recommended' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Recommended Count

				          insert into @LeavesCount values('Cancelled', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Cancelled' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Cancelled Count

				            insert into @LeavesCount values('ForCancellation', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='For Cancellation' and LA.LeaveTypeId=@leaveTypeId 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )  ))  -- For Cancellation Count

             		  end
















				   end

             


			 else ---------without leaveType fileter
				 begin


				 if(@Type='My Leaves')
				 begin

				 insert into @LeavesCount values('All', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and EmployeeId=@EmployeeId))     --  All count		     

				insert into @LeavesCount values('Submitted', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Submitted' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId ))    -- Submitted count

	    		insert into @LeavesCount values('Approved', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Approved' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Rejected' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId ))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Recommended' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId ))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='Cancelled' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select COUNT(*) from HR.LeaveApplication where CompanyId=@CompanyId and  Status=1 and LeaveStatus='For Cancellation' and EmployeeId=@EmployeeId and EmployeeId=@EmployeeId))  -- For Cancellation Count
				end

				 if(@Type='As Approver')
				 begin
				  insert into @LeavesCount values('All', (select  COUNT(DISTINCT LA.Id)from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))     --  All count		     

				   insert into @LeavesCount values('Submitted', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Submitted'
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  )  ))    -- Submitted count

	    		insert into @LeavesCount values('Approved', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Approved'
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Rejected'
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select COUNT(DISTINCT LA.Id)  from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Recommended'
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Cancelled'
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='For Cancellation'
									and( (LA.ApproverUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Approver' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- For Cancellation Count
				end


				 if(@Type='As Recommender')
				 begin
				  insert into @LeavesCount values('All', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName 
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))    -- Submitted count

		        	insert into @LeavesCount values('Submitted', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Submitted'
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Approved Count

	    		insert into @LeavesCount values('Approved', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Approved'
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Approved Count

				insert into @LeavesCount values('Rejected', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName  and  LA.LeaveStatus='Rejected'
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Rejected Count

				insert into @LeavesCount values('Recommended', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Recommended'
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Recommended Count

				insert into @LeavesCount values('Cancelled', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='Cancelled'
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- Cancelled Count

				insert into @LeavesCount values('ForCancellation', (select  COUNT(DISTINCT LA.Id) from  Common.Companyuser  as CU
                                     join  HR.LeaveApplication as LA  on LA.CompanyId=@CompanyId
									 join HR.EmployeRecandApprovers as EMPR on cu.Id = EMPR.TypeId
									 where CU.CompanyId=@CompanyId and LA.CompanyId=@CompanyId and CU.Username=@UserName and  LA.LeaveStatus='For Cancellation'
									and( (LA.RecommenderUserId= CU.Id) or (EMPR.TypeId = cu.Id  and  EMPR.Type='Recommender' and  LA.EmployeeId = EMPR.EmployeeId and EMPR.ScreenName ='Leaves')  ) ))  -- For Cancellation Count
				end

				 end

				end

		end

		end
		select * from @LeavesCount
	 end try
	begin catch
		print ('Failed..!')
	end catch
end






GO
