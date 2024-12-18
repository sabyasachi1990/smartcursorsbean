USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[TimeLogNotifications_JobRun]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure  [dbo].[TimeLogNotifications_JobRun] @companyId BigInt,@date date

As 
Begin

   Declare  
           -- @CompanyId BigInt,
			@WorkWeekHours DECIMAL (20,2),
			@StartDate datetime2,
			@EndDate datetime2,
			@CompanyUId int,
		    @ScreenAction varchar(256),
		    @NotificationType nvarchar(150),
		   -- @NotificationTemplate nvarchar(max),
			@NotificationSubject nvarchar(500),
			@NotificationDescription nvarchar(500),
			@UserName  nvarchar(500),
			@FirstName  nvarchar(100),

			 @EmployeeId Uniqueidentifier,
			 @EmployeeName NVARCHAR (1000),
			 @TotalHours DECIMAL (20,2),
			-- @WeekDay NVARCHAR (20),
		     @WorkingHours time,
			 @type NVARCHAR (20),
			 @lstNotificationUser nvarchar(max),
			 @lstEmailUser nvarchar(max),
			 @EmpBookedHours int,
			 @LeavesHours int,
			 @TrainingHours int,
			 @CalenderHours int,
			 @AllHours int,
			 @EmpDiffHours int,
			 @EmpOverAllHours  DECIMAL (20,2)


		 DECLARE @OUTPUT TABLE (EMPLOYEEID Uniqueidentifier,EMPLOYEENAME NVARCHAR (1000),EmpNotBookedHours varchar(max),TOATLHOURS varchar(max),STARTDATE DATE,ENDDATE DATE,UserName nvarchar(500),CompanyUId int,ScreenAction nvarchar(50),NotificationType nvarchar(50),NotificationSubject nvarchar(50),NotificationDescription nvarchar(500),NotificationUser nvarchar(max),EmailUser nvarchar(max),FirstName nvarchar(100))


		   
             set  @WorkWeekHours =( Select CAST (SUM(DATEDIFF(MINUTE,0,WorkingHours))/60.0  AS DECIMAL (20,2)) from Common.Workweeksetup (NOLOCK) where
		     CompanyId=@CompanyId and EmployeeId is null and IsWorkingday=1 )

		      set @StartDate=( SELECT  DATEADD(dd, -(DATEPART(dw,@date)-1), @date))
		      set @EndDate=( SELECT DATEADD(dd, 7-(DATEPART(dw, @date)), @date))

		    Declare Employees_Csr Cursor For 
		    Select Distinct emp.Id,emp.FirstName ,cu.Username,cu.Id,emp.FirstName from Common.Employee as emp (NOLOCK)
			join Common.CompanyUser as cu (NOLOCK) on emp.Username = cu.Username and emp.CompanyId = cu.CompanyId
			left join Common.TimeLogSetup as tls (NOLOCK) on emp.Id = tls.EmployeeId
			where emp.CompanyId= @CompanyId  and emp.IsHronly=1 
			--and ( tls.StartDate <= @StartDate or  tls.StartDate <= @EndDate ) and emp.Status=1
			and  ((tls.StartDate <= @StartDate or tls.StartDate between @StartDate and @EndDate ) and  ((isnull( tls.EndDate ,@EndDate ) >= @EndDate) or tls.EndDate between @StartDate and @EndDate)) and emp.Status=1

	        Open Employees_Csr
            Fetch Next From Employees_Csr  into @EmployeeId,@EmployeeName,@UserName , @CompanyUId,@FirstName
            While @@FETCH_STATUS=0
            Begin
	        
                
	       set @EmpBookedHours = (select isnull((Select sum(DATEPART(HOUR,tld.Duration)*60)+sum((DATEPART(MINUTE,tld.Duration))) from Common.TimeLog as tl (NOLOCK)
                join  Common.TimeLogDetail as tld (NOLOCK) on tl.Id = tld.MasterId
                where tl.CompanyId=@CompanyId and tl.EmployeeId= @EmployeeId and tl.StartDate=@StartDate and tl.EndDate=@EndDate),0))
	        
			
		  set @LeavesHours=(Select Sum([dbo].[UFN_Decimal_Into_Minutes](tli.Hours)) from Common.TimeLogItem  as tli (NOLOCK)
                          join HR.LeaveApplication as la (NOLOCK) on tli.SystemId=la.Id
                          where  tli.SystemType='LeaveApplication' and tli.IsSystem=1 and tli.ApplyToAll !=1
                         and ( la.LeaveStatus='Approved' or la.LeaveStatus='For Cancellation') and tli.StartDate >=@StartDate and tli.EndDate <=@EndDate and la.EmployeeId=@EmployeeId  and tli.CompanyId=@CompanyId) 
	        
		  --set @CalenderHours=(Select Sum([dbo].[UFN_Decimal_Into_Minutes](tli.Hours)) from Common.TimeLogItem as tli where tli.SystemType='Calender' and tli.IsSystem=1 and tli.ApplyToAll =1 and IsMain=0  and tli.StartDate >=@StartDate and tli.EndDate <=@EndDate  and tli.CompanyId=@CompanyId)

		   set @CalenderHours=(Select  Sum(calenderHrs)  from 
                             ( Select Sum([dbo].[UFN_Decimal_Into_Minutes](tli.Hours))  as calenderHrs from Common.TimeLogItem as tli (NOLOCK)
                              where tli.SystemType='Calender' and tli.IsSystem=1 and tli.ApplyToAll =1 and IsMain=0  and tli.StartDate >=@StartDate and tli.EndDate <=@EndDate  and tli.CompanyId=@CompanyId
                                UNion all
                                Select Sum([dbo].[UFN_Decimal_Into_Minutes](tli.Hours)) from Common.TimeLogItem as tli (NOLOCK)
                                join Common.TimeLogItemDetail as tld (NOLOCK) on tli.Id =tld.TimeLogItemId
                                 where tli.SystemType='Calender' and tli.IsSystem=1 and tli.ApplyToAll =0 and IsMain=0  and tli.StartDate >=@StartDate and tli.EndDate <=@EndDate  
								 and tli.CompanyId=@CompanyId and tld.EmployeeId = @EmployeeId ) hh)

          set @TrainingHours=(Select Sum([dbo].[UFN_Decimal_Into_Minutes](tli.Hours)) from Common.TimeLogItem as tli (NOLOCK)
                                join Common.TimeLogItemDetail as tld (NOLOCK) on tli.Id=tld.TimeLogItemId
                               where tli.SystemType='Training' and tli.IsSystem=1 and tli.ApplyToAll =0  and tli.StartDate >=@StartDate and
							    tli.EndDate <=@EndDate and tld.EmployeeId=@EmployeeId and tli.CompanyId=@CompanyId)

             set @AllHours= (isnull(@EmpBookedHours,0) + isnull(@LeavesHours,0) + isnull(@CalenderHours,0) + isnull(@TrainingHours,0))

			set @EmpOverAllHours=(Cast( @AllHours / 60 + (@AllHours % 60) / 100.0  AS DECIMAL (20,2)))

	      If(@EmpOverAllHours < @WorkWeekHours)
	      Begin
	          
		       set  @EmpDiffHours= ([dbo].[UFN_Decimal_Into_Minutes]( @WorkWeekHours) -  [dbo].[UFN_Decimal_Into_Minutes](@EmpOverAllHours))

			    set @TotalHours=(Cast( @EmpDiffHours / 60 + (@EmpDiffHours % 60) / 100.0  AS DECIMAL (20,2)))

			   If Exists ( Select Id from [Notification].[NotificationSettings] (NOLOCK) where CursorName='Workflow Cursor'and ScreenName='TimeLog'and  ScreenAction='Timelog not completed' and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
               Begin

		         If Exists ( Select Id from [Notification].[NotificationSettings] (NOLOCK) where CursorName='Workflow Cursor'and ScreenName='TimeLog'and  ScreenAction='Timelog not completed' and IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		        Begin

                   set  @Type= (Select Type from [Notification].[NotificationSettings] (NOLOCK) where CursorName='Workflow Cursor'and ScreenName='TimeLog'and  ScreenAction='Timelog not completed'and IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

				  set  @ScreenAction= (Select ScreenAction from [Notification].[NotificationSettings] (NOLOCK) where CursorName='Workflow Cursor'and ScreenName='TimeLog'and  ScreenAction='Timelog not completed' and  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
	
		          set  @NotificationSubject= (Select NotificationSubject from [Notification].[NotificationSettings] (NOLOCK) where CursorName='Workflow Cursor'and ScreenName='TimeLog'and  ScreenAction='Timelog not completed' and  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

				  set  @NotificationDescription= (Select NotificationDescription from [Notification].[NotificationSettings] (NOLOCK) where CursorName='Workflow Cursor'and ScreenName='TimeLog'and  ScreenAction='Timelog not completed' and  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		          If(@NotificationDescription is not null)
				  Begin
				       set  @NotificationDescription = @NotificationDescription
				  End

				 If (@Type like '%Notification%')
				 Begin				     
					 set @lstNotificationUser = @UserName					 
				 End
				 Else
				 Begin
				        set @lstNotificationUser = NULL
				 End

				 If (@Type like '%Email%')
				 Begin			    
					   set @lstEmailUser = @UserName				
				  End
				  Else
				  Begin
				        set @lstEmailUser  = NULL
				  End           

				   Insert into @OUTPUT  
				   Select @EmployeeId,@EmployeeName,@TotalHours,@WorkWeekHours,@StartDate,@EndDate,@UserName,@CompanyUId,@ScreenAction,@Type,@NotificationSubject,
				   @NotificationDescription,@lstNotificationUser,@lstEmailUser,@FirstName

               End

		      End

		 ------------------------------------------mailli New Code ---------------

		       Else If Exists ( Select Id from [Notification].[NotificationSettings] (NOLOCK) where CursorName='Workflow Cursor'and ScreenName='TimeLog'and  ScreenAction='Timelog not completed' and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
	          Begin

                 set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings] (NOLOCK) where CursorName='Workflow Cursor' and ScreenName='TimeLog'and  ScreenAction='Timelog not completed' and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

				set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings] (NOLOCK) where CursorName='Workflow Cursor'and ScreenName='TimeLog'and  ScreenAction='Timelog not completed' and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

                set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings] (NOLOCK) where CursorName='Workflow Cursor' and ScreenName='TimeLog'and  ScreenAction='Timelog not completed'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
		
			    set  @NotificationDescription= (Select NotificationDescription from [Notification].[NotificationSettings] (NOLOCK) where CursorName='Workflow Cursor'and ScreenName='TimeLog'and  ScreenAction='Timelog not completed' and  IsOn=1 and  CompanyId=@CompanyId and CompanyUserId is null)

		          If(@NotificationDescription is not null)
				  Begin
				       set  @NotificationDescription = @NotificationDescription
				  End

			      If (@Type like '%Notification%')
				 Begin				     
					 set @lstNotificationUser = @UserName					 
				 End
				 Else
				 Begin
				        set @lstNotificationUser = NULL
				 End

				 If (@Type like '%Email%')
				 Begin			    
					   set @lstEmailUser = @UserName				
				  End
				  Else
				  Begin
				        set @lstEmailUser  = NULL
				  End               
                              

			  Insert into @OUTPUT  
				   Select @EmployeeId,@EmployeeName,@TotalHours,@WorkWeekHours,@StartDate,@EndDate,@UserName,@CompanyUId,@ScreenAction,@Type,@NotificationSubject,
				   @NotificationDescription,@lstNotificationUser,@lstEmailUser,@FirstName
	                 
         End

		    
		       
	    End


		   Fetch Next From Employees_Csr  into  @EmployeeId,@EmployeeName,@UserName , @CompanyUId,@FirstName
            End       		   
            Close Employees_Csr
            Deallocate Employees_Csr

	  Select * from @OUTPUT

End

		
GO
