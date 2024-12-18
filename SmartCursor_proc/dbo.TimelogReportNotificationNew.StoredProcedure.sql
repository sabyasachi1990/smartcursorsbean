USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[TimelogReportNotificationNew]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc   [dbo].[TimelogReportNotificationNew]
@CompanyyId BIGINT
 As
 Begin
 
 Declare  @EmployeeId Uniqueidentifier,
          @weeklyenddate DateTime,
		  @weeklystartdate DateTime,
		  @CompanyId Int,
		  @WoringHours numeric(19,2),
		  @WeekName nvarchar(50),
		  @Enddate Datetime,
		  @TotalHours numeric(19,2),
		  @UserName nvarchar(50),
		  @CompanyUId int,		
		  @lstNotificationUser nvarchar(max),
		  @lstEmailUser nvarchar(max),
		  @NotificationType nvarchar(150),
		  @NotificationTemplate nvarchar(max),
		  @NotificationSubject nvarchar(500),
		  @OtherRecipients nvarchar(1000),
		  @OtherEmailRecipient nvarchar(max),
		  @Type nvarchar(50),
		  @FirstName nvarchar(50),
		  @ScreenAction varchar(256),   
		   @OtherHours numeric(19,2),
		   @Date DateTime
		  set @weeklyenddate = GETUTCDATE()
		  set @weeklystartdate =convert (date ,DATEADD(day, -7, GETUTCDATE()))
		  set @Date =convert (date ,DATEADD(day, -7, GETUTCDATE()))
		  Set @WeekName= DATENAME(DW,CONVERT(VARCHAR(20),@weeklyenddate,101))
		  Set @OtherHours=0

		 
		 
             Declare Employee_Csr Cursor For  --- 1

             Select   Id,CompanyId,Username from Common.Employee  where Username is not null   and CompanyId=@CompanyyId
			 --and id='630D8A35-0BCB-44B9-9309-9415DD7EB8C5'

             Open Employee_Csr
			  
            Fetch Next From Employee_Csr  into @EmployeeId,@CompanyId,@Username

			--------------------------  Verifing Holiday and Items      --------------------------
	--		 while(@Date <=@weeklyenddate)
	--	   begin
	--	  if exists (Select * from Common.Calender   as Cal inner join Common.CalenderDetails as CalDe on Cal.Id =  CalDe.MasterId
	--where ( CONVERT(date,Cal.FromDateTime) <= CONVERT(date, @Date) and CONVERT(date,Cal.ToDateTime) >=CONVERT(date, @Date)) and Cal.companyId=@CompanyId and CalDe.EmployeeId = @EmployeeId)
	--	 begin

	--		set @OtherHours=@OtherHours + (Select Cal.NoOfHours from Common.Calender   as Cal inner join Common.CalenderDetails as CalDe on Cal.Id =  CalDe.MasterId
	--where ( CONVERT(date,Cal.FromDateTime) <= CONVERT(date, @Date) and CONVERT(date,Cal.ToDateTime) >=CONVERT(date, @Date)) and Cal.companyId=@CompanyId and CalDe.EmployeeId = @EmployeeId)
			 
	--	  end
	--	  else if exists (Select * from Common.Calender  where CompanyId=@CompanyId and ApplyTo ='All'and CONVERT(date,FromDateTime) <= CONVERT(date, @Date) and CONVERT(date,ToDateTime) >=CONVERT(date, @Date))
	--	  begin 
	--	  set @OtherHours= @OtherHours+( Select NoOfHours from Common.Calender  where CompanyId=@CompanyId and ApplyTo ='All'and CONVERT(date,FromDateTime) <= CONVERT(date, @Date) and CONVERT(date,ToDateTime) >=CONVERT(date, @Date))
	--	  End

	--	 set @Date= @Date+1

	--	 End



			---------------------------------------------------------------

            While @@FETCH_STATUS=0
            Begin
   
	          set @WoringHours =(select [dbo].[UFN_Duration_Minutes_Into_HoursMinutes](WorkingHours)
             from 
               (
                Select 
                 sum(DATEPART(HOUR,WorkingHours)*60)+sum((DATEPART(MINUTE,WorkingHours))) As WorkingHours
                 from Common.WorkWeekSetUp  where CompanyId=@CompanyId  and EmployeeId is null and IsWorkingDay=1
                )as A)

				if(@OtherHours!=0)
				begin
				set @WoringHours =@WoringHours
				---@OtherHours
				End

   If(@WeekName='Friday')
       Begin

       set @Enddate=convert (date ,DATEADD(day, -1, GETUTCDATE()))
     
         set @TotalHours=  (select [dbo].[UFN_Duration_Minutes_Into_HoursMinutes](Duration)
          from 
              (
              Select 
               sum(DATEPART(HOUR,TLD.Duration)*60)+sum((DATEPART(MINUTE,TLD.Duration))) As Duration
              from Common.TimeLog as TL
             inner join Common.TimeLogDetail as TLD on TL.Id=TLD.MasterId
              Where TL.Startdate=@weeklystartdate and TL.Enddate=@Enddate and TL.EmployeeId=@EmployeeId
              )as A)

         if(ISNULL(@TotalHours,0)< ISNULL(@WoringHours,0))
                Begin
----------------------------------------------------------------------------------------------------------------------------------------------
          Declare ScheduleDetail_ScDetailId_Csr   Cursor for 
           Select  Distinct(E.Username),E.FirstName,CU.Id from Common.Employee as E
           inner join Common.CompanyUser as CU on E.Username = CU.Username
           Where E.id=@EmployeeId and CU.CompanyId=@CompanyId and E.Status=1
		   Open ScheduleDetail_ScDetailId_Csr
				 Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId

                While @@FETCH_STATUS=0
                Begin

		     If Exists ( Select Id from [Notification].[NotificationSettings]  
				 where CursorName='Workflow Cursor'and ScreenName='Time Log Report'and  ScreenAction='Job' 
				 --and IsPersonalSetting=1 and IsOn=1  
				  and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
				 Begin
				  If Exists ( Select Id from [Notification].[NotificationSettings]  
				 where CursorName='Workflow Cursor'and ScreenName='Time Log Report'and  ScreenAction='Job' 
				 --and IsPersonalSetting=1
				  and IsOn=1    and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
				  Begin
              

			  set @Type=( Select Type from [Notification].[NotificationSettings]  
				 where CursorName='Workflow Cursor'and ScreenName='Time Log Report'and  ScreenAction='Job' 
				 --and IsPersonalSetting=1
				  and IsOn=1    and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
				  begin

				  set @OtherRecipients=( Select OtherEmailRecipient from [Notification].[NotificationSettings]  
				 where CursorName='Workflow Cursor'and ScreenName='Time Log Report'and  ScreenAction='Job' 
				 --and IsPersonalSetting=1
				  and IsOn=1    and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
				  If (@Type like '%Notification%')
					            	  Begin
					                 set @lstNotificationUser= CONCAT(@lstNotificationUser ,',',@UserName)
					                 End
					                If (@Type like '%Email%')
					                Begin
					                        set @lstEmailUser=CONCAT(@lstEmailUser,',',@UserName,',',@OtherEmailRecipient)
											set @OtherEmailRecipient=null
					                End


						        End





 --------------------------------------------------------------------- 4th

           Declare Notification_Csr   Cursor for 
             Select  ScreenAction, [Type] as NotificationType, NotificationDescription,NotificationSubject,RTRIM(LTRIM(value)) as OtherRecipients
	         from [Notification].[NotificationSettings] CROSS APPLY STRING_SPLIT(OtherRecipients, ',')  
			 where CursorName='Workflow Cursor'and  ScreenName='Time Log Report'and  ScreenAction='Job'  and IsPersonalSetting=1 and IsOn=1  and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId

		     	 Open Notification_Csr
			     Fetch Next From Notification_Csr  into @ScreenAction, @NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients

                  While @@FETCH_STATUS=0
                   Begin 

               set @CompanyUId=(Select id from Common.CompanyUser where userName=@OtherRecipients and companyId=@companyId)
			      if(@CompanyUId is not null)
					   begin

					 --    If Exists ( Select Id from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and  ScreenName='Time Log Report'and  ScreenAction='Job'  and IsPersonalSetting=1 and IsOn=1   and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
					 --   begin
					 --set @Type=   (Select   [Type]  from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and  ScreenName='Time Log Report'and  ScreenAction='Job'  and IsPersonalSetting=1 and IsOn=1   and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

					 -- If (@Type like '%Notification%')
						-- begin
						-- set @lstNotificationUser=@lstNotificationUser +','+@OtherRecipients
						-- End
						-- If (@Type like '%Email%')
						-- begin
						--  set @lstEmailUser=@lstEmailUser +','+@OtherRecipients
						-- End
						-- end 
						  if Exists (Select id from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and  ScreenName='Time Log Report'and  ScreenAction='Job'  and IsOn=1 and companyId=@CompanyId and CompanyUserId is null)
						 begin
						 set @Type=   (Select   [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and  ScreenName='Time Log Report'and  ScreenAction='Job'   and IsOn=1   and   CompanyId=@CompanyId and CompanyUserId is null)
						  If (@Type like '%Notification%')
						 begin
						 set @lstNotificationUser=@lstNotificationUser +','+@OtherRecipients
						 End
						 If (@Type like '%Email%')
						 begin
						  set @lstEmailUser=@lstEmailUser +','+@OtherRecipients
						 End

------------------------------------

       --select @lstNotificationUser,@lstEmailUser,@CompanyUId,@companyId,@Type

--------------------------------------

	   end 
	   end 

 Fetch Next From Notification_Csr  into  @ScreenAction,@NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients
end
Close Notification_Csr
Deallocate Notification_Csr

end
End

         else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Time Log Report'and ScreenAction='Job' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Time Log Report'and  ScreenAction='Job'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					  set @OtherEmailRecipient=(Select OtherEmailRecipient from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Time Log Report'and  ScreenAction='Job'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

					 If (@Type like '%Notification%')
					  begin
					 	       set @lstNotificationUser=CONCAT(@lstNotificationUser ,',',@UserName)
						 End
					 If (@Type like '%Email%')
				 	 Begin
				 	         set @lstEmailUser=CONCAT(@lstEmailUser ,',',@UserName,',',@OtherEmailRecipient)
							 set @OtherEmailRecipient=null
			     	 End
                                

		                  

        End



Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
 end
 Close ScheduleDetail_ScDetailId_Csr
 Deallocate ScheduleDetail_ScDetailId_Csr
  End 


    If Exists ( Select Id from [Notification].[NotificationSettings]  
				 where CursorName='Workflow Cursor'and  ScreenName='Time Log Report'and  ScreenAction='Job' 
				  and IsOn=1and CompanyId=@CompanyId)
				 Begin
                -- set	@lstNotificationUser=@UserName
				  Declare Notification_Csr   Cursor for 
             Select  ScreenAction, [Type] as NotificationType, NotificationDescription,NotificationSubject,RTRIM(LTRIM(value)) as OtherRecipients
	         from [Notification].[NotificationSettings] CROSS APPLY STRING_SPLIT(OtherRecipients, ',')  
			 where CursorName='Workflow Cursor'and  ScreenName='Time Log Report'and  ScreenAction='Job'   and IsOn=1  and CompanyId=@CompanyId and CompanyUserId is null

		     	 Open Notification_Csr
			     Fetch Next From Notification_Csr  into @ScreenAction, @NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients

                  While @@FETCH_STATUS=0
                   Begin 

               set @CompanyUId=(Select id from Common.CompanyUser where userName=@OtherRecipients and companyId=@companyId)
			      if(@CompanyUId is not null)
					   begin

					 --    If Exists ( Select Id from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and  ScreenName='Time Log Report'and  ScreenAction='Job'  and IsPersonalSetting=1 and IsOn=1   and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
					 --   begin
					 --set @Type=   (Select   [Type]  from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and  ScreenName='Time Log Report'and  ScreenAction='Job'  and IsPersonalSetting=1 and IsOn=1   and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

					 -- If (@Type like '%Notification%')
						-- begin
						-- set @lstNotificationUser=@lstNotificationUser +','+@OtherRecipients
						-- End
						-- If (@Type like '%Email%')
						-- begin
						--  set @lstEmailUser=@lstEmailUser +','+@OtherRecipients
						-- End
						-- end 
						  if Exists (Select id from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and  ScreenName='Time Log Report'and  ScreenAction='Job'  and IsOn=1 and companyId=@CompanyId and CompanyUserId is null)
						 begin
						 set @Type=   (Select   [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and  ScreenName='Time Log Report'and  ScreenAction='Job'   and IsOn=1   and   CompanyId=@CompanyId and CompanyUserId is null)
						  If (@Type like '%Notification%')
						 begin
						 set @lstNotificationUser= CONCAT(@lstNotificationUser ,',',@OtherRecipients)
						 End
						 If (@Type like '%Email%')
						 begin
						  set @lstEmailUser=CONCAT(@lstEmailUser ,',',@OtherRecipients)
						 End

------------------------------------

       --select @lstNotificationUser,@lstEmailUser,@CompanyUId,@companyId,@Type

--------------------------------------

	   end 
	   end 

 Fetch Next From Notification_Csr  into  @ScreenAction,@NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients
end
Close Notification_Csr
Deallocate Notification_Csr

end
         




--------------------------------------------------------------------------------------------------------------------------------------------
      --Select  @WoringHours,@weeklyenddate,@weeklystartdate,@WeekName,@TotalHours

 If(@NotificationTemplate is not null)
  begin 

			insert into  Notification.TimeLogReport ([Id],[EmployeeId], [CompanyId], [Subject], [ScreenAction], [Template], [NotificationType], [ToNotificationUser], [ToEmailUser], [Date], [UserCreated], [CreatedDate], [Status])
			 values (NEWID(),@EmployeeId,@CompanyId,@NotificationSubject,@ScreenAction,@NotificationTemplate,@NotificationType,@lstNotificationUser,@lstEmailUser,GETDATE(),'System',GETDATE(),1)
			 -----------------------------------

			 set @NotificationTemplate = null
			--Select NEWID(),@CompanyId,@NotificationSubject,@ScreenAction,@Template,@NotificationType,@lstNotificationUser,@lstEmailUser,GETDATE(),'System',GETDATE(),@NotificationTemplate
			-------------------------------------
---------------------------------------------------- 3rd

end


      End
Fetch Next From Employee_Csr into  @EmployeeId,@CompanyId,@Username
end
Close Employee_Csr
Deallocate Employee_Csr

 End


 --SELECT  DATENAME(DW,CONVERT(VARCHAR(20),GETDATE(),101))
 -- Function 
 --------------------

-- Create Function [dbo].[UFN_Duration_Minutes_Into_HoursMinutes]
--(
--@Minutes int
--)
--Returns numeric(19,2)

 

--AS
--BEGIN

 

--Declare @DurationInMinutes numeric(19,2)
--Set @DurationInMinutes=
--(
--    Select Convert(numeric(19,2),(RIGHT('0' +CAST(@Minutes/60 as varchar),10)+'.'+RIGHT('0' +CAST(@Minutes%60 as varchar),2)))
--)

 

--Return @DurationInMinutes
--END
------------------------------------------------

--set @WoringHours =(select [dbo].[UFN_Duration_Minutes_Into_HoursMinutes](Duration)
--  from 
-- (
-- Select 
-- sum(DATEPART(HOUR,TLD.Duration)*60)+sum((DATEPART(MINUTE,TLD.Duration))) As Duration
--from Common.TimeLog as TL
--      inner join Common.TimeLogDetail as TLD on TL.Id=TLD.MasterId
--     Where TL.Startdate=@weeklystartdate and TL.Enddate=@Enddate and TL.EmployeeId=@EmployeeId
--   )as A)


--set @WoringHours =(select [dbo].[UFN_Duration_Minutes_Into_HoursMinutes](Duration)
--  from 
-- (
-- Select 
-- sum(DATEPART(HOUR,TLD.Duration)*60)+sum((DATEPART(MINUTE,TLD.Duration))) As Duration
--from Common.TimeLog as TL
--      inner join Common.TimeLogDetail as TLD on TL.Id=TLD.MasterId
--      Where TL.Startdate='2018-12-09' and TL.Enddate='2018-12-15' and TL.EmployeeId='630D8A35-0BCB-44B9-9309-9415DD7EB8C5'
--   )as A)

     --  Select TLD.Duration, * from Common.TimeLog as TL
     -- inner join Common.TimeLogDetail as TLD on TL.Id=TLD.MasterId
     --Where TL.Startdate='2018-12-09' and TL.Enddate='2018-12-15' and TL.EmployeeId='630D8A35-0BCB-44B9-9309-9415DD7EB8C5'
GO
