USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CasesNotificationPriorToEndDate]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[CasesNotificationPriorToEndDate] 
As 
Begin

       Declare  @ScheduleId Uniqueidentifier,
                @CaseId Uniqueidentifier,        
		        @Stage nvarchar(50),
		        @CaseNumber nvarchar(50),
		        @ClientName nvarchar(100),
		        @CompanyId  int ,
		        @InvoiceState nvarchar(50),
				@lstNotificationUser nvarchar(max),
		        @lstEmailUser nvarchar(max),
			    @NotificationType nvarchar(150),
			    @NotificationTemplate nvarchar(max),
			    @NotificationSubject nvarchar(500),
			    @NotificationDescription nvarchar(500),
			    @OtherRecipients nvarchar(1000),
				@OtherEmailRecipient nvarchar(1000),
			    @Type varchar(50),
				@UserName nvarchar(50),
		        @FirstName nvarchar(50),
			    @CompanyUId int,
				@Template nvarchar(max),
				@ApprovedDate Date,
				@DaysCount int ,
				--@ActualDateOfCompletion Date,
				--@DueDateForCompletion Date,
				--@ScheduleCompletionDate Date, 
			    @ScreenAction varchar(256),
				@EndDate DateTime2(7),
				@AmmendDate DateTime2(7),
				@Recount int,
				@CaseCount int,
				@NotificationDate DateTime2(7)
				

				BEGIN TRANSACTION--s2
	BEGIN TRY--s3

	 Declare @Receipent nvarchar(250)
			   set @Receipent= (Select Recipient from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='End Date' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null) 
				create table #TempCaseTbl(S_No INT Identity(1, 1),Id UniqueIdentifier,ScheduleId uniqueIdentifier,name nvarchar(250),CaseNumber nvarchar(250),Stage nvarchar(250),CompanyId bigint,EndDate DateTime2(7),AmmendDate Datetime2(7),ApprovedDate DateTime2(7))
		
		Declare @PresentDate DateTime2(7)
		set @PresentDate=GETDATE()

		insert into #TempCaseTbl 
		Select CG.Id, S.Id,CG.Name,CG.CaseNumber,CG.Stage,CG.CompanyId,s.EndDate,cmd.AmendDate,cg.ApprovedDate
		 from WorkFlow.CaseGroup as CG  Inner join  WorkFlow.ScheduleNew  as S  on s.CaseId=CG.Id left join Workflow.CaseAmendDateOfCompletion as cmd on cg.Id=cmd.CaseId where  (cg.ApprovedDate is null or  (CONVERT(date,@PresentDate)<=Convert(date,cg.ApprovedDate))) and stage not in ('Complete','Cancelled') and (ScheduleEndDate is not null or cg.AmendDate is not null)
       	 --where s.StartDate is not null and (s.EndDate is not null or cmd.AmendDate is not null)


		 set @CaseCount=(SELECT Count(*)
		FROM #TempCaseTbl
		)
		set @Recount=1
		WHILE @CaseCount >= @Recount
		begin

		SELECT @CaseId=Id,@ScheduleId=ScheduleId,@ClientName=Name,@CaseNumber=CaseNumber,@Stage=Stage,@CompanyId=CompanyId,@EndDate=EndDate,@AmmendDate=AmmendDate,@ApprovedDate=ApprovedDate
		FROM #TempCaseTbl
		WHERE S_No = @Recount
		print @CaseId
		set @EndDate=(select AmmendDate from  #TempCaseTbl where S_No=@Recount)
		print @EndDate
		if(@EndDate is null)
		begin
		set @EndDate=(select EndDate from  #TempCaseTbl where S_No=@Recount)
		end
		if(@EndDate is not null)
		begin
		Declare @EndDate1 DateTime2(7)
		

		

		set @EndDate1 = (DATEADD(day,-10,@EndDate))

		
		if(@ApprovedDate is not null)
		begin 
		if((Convert(date,@PresentDate)>=Convert(date,@EndDate1)) and (CONVERT(date,@PresentDate)<=Convert(date,@ApprovedDate)))

		--if((DAY(@EndDate1)=Day(@PresentDate) and Month(@EndDate1)=Month(@PresentDate) and Year(@EndDate1)=Year(@PresentDate)) or (@EndDate1=@NotificationDate and @PresentDate<=@ApprovedDate))
		begin
		if(@Receipent='Case members')
		begin
		  Declare OverRun_ScheduleDetail_ScDetailId_Csr   Cursor for 

				            Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD inner join Common.Employee  as E on E.id=Sd.EmployeeId
	                           inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId where sd.MasterId=@ScheduleId  and e.Status=1

				            Open OverRun_ScheduleDetail_ScDetailId_Csr
				            Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId

                            While @@FETCH_STATUS=0
                            Begin
             
         If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and IsOn=1		   and
		   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
         Begin
		 If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		   begin
              set  @Type= (Select Type from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   begin
		     set @NotificationType=@Type
		    set  @NotificationTemplate= (Select NotificationDescription from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @NotificationSubject= (Select NotificationSubject from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @ScreenAction= (Select ScreenAction from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   set  @OtherEmailRecipient= (Select OtherEmailRecipient from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
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
			                   
			         

        End
         End
		 ------------------------------------------mailli New Code ---------------
		  else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='End Date' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

										     set @NotificationType=@Type
										    set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                                            set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
										    set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					  set @OtherEmailRecipient=(Select OtherEmailRecipient from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

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

		 ---------------------------------------------Malli new Code --------------
		   Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                           End
                           Close OverRun_ScheduleDetail_ScDetailId_Csr
                           Deallocate OverRun_ScheduleDetail_ScDetailId_Csr
						   end
						   if(@Receipent='PIC')
						   begin
						    Declare OverRun_ScheduleDetail_ScDetailId_Csr   Cursor for 

				            Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD inner join Common.Employee  as E on E.id=Sd.EmployeeId
	                           inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId where sd.MasterId=@ScheduleId  and e.Status=1 and sd.IsPrimaryIncharge=1

				            Open OverRun_ScheduleDetail_ScDetailId_Csr
				            Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId

                            While @@FETCH_STATUS=0
                            Begin
             
         If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and IsOn=1		   and
		   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
         Begin
		 If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		   begin
              set  @Type= (Select Type from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   begin
		     set @NotificationType=@Type
		    set  @NotificationTemplate= (Select NotificationDescription from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @NotificationSubject= (Select NotificationSubject from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @ScreenAction= (Select ScreenAction from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   set  @OtherEmailRecipient= (Select OtherEmailRecipient from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
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
			                   
			         

        End
         End
		 ------------------------------------------mailli New Code ---------------
		  else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='End Date' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

										     set @NotificationType=@Type
										    set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                                            set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
										    set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					  set @OtherEmailRecipient=(Select OtherEmailRecipient from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

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

		 ---------------------------------------------Malli new Code --------------
		   Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                           End
                           Close OverRun_ScheduleDetail_ScDetailId_Csr
                           Deallocate OverRun_ScheduleDetail_ScDetailId_Csr
						   end
						   end

						   if(@Receipent='QIC')
						   begin
						   Declare OverRun_ScheduleDetail_ScDetailId_Csr   Cursor for 

				            Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD inner join Common.Employee  as E on E.id=Sd.EmployeeId
	                           inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId where sd.MasterId=@ScheduleId  and e.Status=1 and sd.IsQIIncharge=1

				            Open OverRun_ScheduleDetail_ScDetailId_Csr
				            Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId

                            While @@FETCH_STATUS=0
                            Begin
             
         If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and IsOn=1		   and
		   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
         Begin
		 If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		   begin
              set  @Type= (Select Type from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   begin
		     set @NotificationType=@Type
		    set  @NotificationTemplate= (Select NotificationDescription from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @NotificationSubject= (Select NotificationSubject from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @ScreenAction= (Select ScreenAction from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   set  @OtherEmailRecipient= (Select OtherEmailRecipient from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
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
			                   
			         

        End
         End
		 ------------------------------------------mailli New Code ---------------
		  else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='End Date' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

										     set @NotificationType=@Type
										    set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                                            set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
										    set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					  set @OtherEmailRecipient=(Select OtherEmailRecipient from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

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

		 ---------------------------------------------Malli new Code --------------
		   Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                           End
                           Close OverRun_ScheduleDetail_ScDetailId_Csr
                           Deallocate OverRun_ScheduleDetail_ScDetailId_Csr
						   end
						   if(@Receipent='MIC')
						   begin
						    Declare OverRun_ScheduleDetail_ScDetailId_Csr   Cursor for 

				            Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD inner join Common.Employee  as E on E.id=Sd.EmployeeId
	                           inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId where sd.MasterId=@ScheduleId  and e.Status=1 and sd.IsMicIncharge=1

				            Open OverRun_ScheduleDetail_ScDetailId_Csr
				            Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId

                            While @@FETCH_STATUS=0
                            Begin
             
         If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and IsOn=1		   and
		   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
         Begin
		 If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		   begin
              set  @Type= (Select Type from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   begin
		     set @NotificationType=@Type
		    set  @NotificationTemplate= (Select NotificationDescription from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @NotificationSubject= (Select NotificationSubject from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @ScreenAction= (Select ScreenAction from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   set  @OtherEmailRecipient= (Select OtherEmailRecipient from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
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
			                   
			         

        End
         End
		 ------------------------------------------mailli New Code ---------------
		  else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='End Date' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

										     set @NotificationType=@Type
										    set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                                            set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
										    set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					  set @OtherEmailRecipient=(Select OtherEmailRecipient from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

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

		 ---------------------------------------------Malli new Code --------------
		   Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                           End
                           Close OverRun_ScheduleDetail_ScDetailId_Csr
                           Deallocate OverRun_ScheduleDetail_ScDetailId_Csr
						   end


		 ---------- Commenetd-----
           If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='End Date' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
               --  set	@lstNotificationUser=@UserName

		                   Declare OverRun_NotificationSettings_Csr   Cursor for 
                           Select  ScreenAction, [Type] as NotificationType, NotificationDescription,NotificationSubject,RTRIM(LTRIM(value)) as OtherRecipients,OtherEmailRecipient
	                       from [Notification].[NotificationSettings] CROSS APPLY STRING_SPLIT(OtherRecipients, ',')  
			               where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1  and CompanyId=@CompanyId and CompanyUserId is null

		     	           Open OverRun_NotificationSettings_Csr
			               Fetch Next From OverRun_NotificationSettings_Csr  into @ScreenAction, @NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients,@OtherEmailRecipient
				   
                           While @@FETCH_STATUS=0
                           Begin 

                                set @CompanyUId=(Select id from Common.CompanyUser where userName=@OtherRecipients and companyId=@companyId)

			          If(@CompanyUId is not null)
					   Begin

					   
					            if Exists (Select id from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and ScreenName='Cases'
							                 and ScreenAction='End Date' and IsOn=1 and companyId=@CompanyId)
					            Begin
					             	    set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					             	 If (@Type like '%Notification%')
					             	 begin
					             	       set @lstNotificationUser=CONCAT(@lstNotificationUser ,',',@OtherRecipients)
					             	 End
					             	 If (@Type like '%Email%')
					             	 Begin
					             	         set @lstEmailUser=CONCAT(@lstEmailUser ,',',@OtherRecipients,',',@OtherEmailRecipient)
					             	 End
                                End
					 End 
      
                           Fetch Next From OverRun_NotificationSettings_Csr  into  @ScreenAction,@NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients,@OtherEmailRecipient
                           End
                           Close OverRun_NotificationSettings_Csr
                           Deallocate OverRun_NotificationSettings_Csr

        End


		  If(@NotificationTemplate is not null)
              Begin 

                   set  @Template = Replace(REPLACE(REPLACE(@NotificationTemplate,'{{ClientName}}',@ClientName),'{{CaseNo}}',@CaseNumber),'{{EndDate}}',@EndDate);
				   set @NotificationSubject=REPLACE(REPLACE(@NotificationSubject,'{{ClientName}}',@ClientName),'{{CaseNo}}',@CaseNumber);

				   print @Template 
				   print @NotificationSubject
				   print @CaseId
			 if not exists(select * from Notification.[Case] where CaseId=@CaseId and ScreenAction=@ScreenAction)
			 begin
			        insert into  Notification.[Case]([Id],[CaseId],[CaseNumber],[ClientName], [CompanyId], [Subject], [ScreenAction], [Template], [NotificationType], [ToNotificationUser], [ToEmailUser], [Date], [UserCreated], [CreatedDate], [Status])
			        values (NEWID(),@CaseId,@CaseNumber,@ClientName,@CompanyId,@NotificationSubject,@ScreenAction,@Template,@NotificationType,@lstNotificationUser,@lstEmailUser,convert(date,GETDATE()),'System',GETDATE(),1)
			end
			-----------------------------------
			  set @NotificationTemplate =null
			  set @NotificationSubject=null
			  set @ScreenAction=null
			  set @lstEmailUser =null
              set @lstNotificationUser=null
			--Select NEWID(),@CompanyId,@NotificationSubject,@ScreenAction,@Template,@NotificationType,@lstNotificationUser,@lstEmailUser,GETDATE(),'System',GETDATE(),@NotificationTemplate

            End

			 set @NotificationTemplate =null
			  set @NotificationSubject=null
			  set @ScreenAction=null
			  set @lstEmailUser =null
              set @lstNotificationUser=null


                         
	

                   
		
		end
		else if(Convert(date,@PresentDate)>=Convert(date,@EndDate1))
		begin

		if(@Receipent='Case Members')
		begin
		  Declare OverRun_ScheduleDetail_ScDetailId_Csr   Cursor for 

				            Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD inner join Common.Employee  as E on E.id=Sd.EmployeeId
	                           inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId where sd.MasterId=@ScheduleId  and e.Status=1

				            Open OverRun_ScheduleDetail_ScDetailId_Csr
				            Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId

                            While @@FETCH_STATUS=0
                            Begin
             
         If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and IsOn=1		   and
		   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
         Begin
		 If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		   begin
              set  @Type= (Select Type from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   begin
		     set @NotificationType=@Type
		    set  @NotificationTemplate= (Select NotificationDescription from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @NotificationSubject= (Select NotificationSubject from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @ScreenAction= (Select ScreenAction from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   set  @OtherEmailRecipient= (Select OtherEmailRecipient from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
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
			                   
			         

        End
         End
		 ------------------------------------------mailli New Code ---------------
		  else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='End Date' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

										     set @NotificationType=@Type
										    set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                                            set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
										    set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					  set @OtherEmailRecipient=(Select OtherEmailRecipient from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

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

		 ---------------------------------------------Malli new Code --------------
		   Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                           End
                           Close OverRun_ScheduleDetail_ScDetailId_Csr
                           Deallocate OverRun_ScheduleDetail_ScDetailId_Csr
						   end
						   if(@Receipent='PIC')
						   begin
						   Declare OverRun_ScheduleDetail_ScDetailId_Csr   Cursor for 

				            Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD inner join Common.Employee  as E on E.id=Sd.EmployeeId
	                           inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId where sd.MasterId=@ScheduleId  and e.Status=1 and sd.IsPrimaryIncharge=1

				            Open OverRun_ScheduleDetail_ScDetailId_Csr
				            Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId

                            While @@FETCH_STATUS=0
                            Begin
             
         If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and IsOn=1		   and
		   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
         Begin
		 If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		   begin
              set  @Type= (Select Type from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   begin
		     set @NotificationType=@Type
		    set  @NotificationTemplate= (Select NotificationDescription from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @NotificationSubject= (Select NotificationSubject from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @ScreenAction= (Select ScreenAction from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   set  @OtherEmailRecipient= (Select OtherEmailRecipient from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
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
			                   
			         

        End
         End
		 ------------------------------------------mailli New Code ---------------
		  else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='End Date' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

										     set @NotificationType=@Type
										    set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                                            set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
										    set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					  set @OtherEmailRecipient=(Select OtherEmailRecipient from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

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

		 ---------------------------------------------Malli new Code --------------
		   Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                           End
                           Close OverRun_ScheduleDetail_ScDetailId_Csr
                           Deallocate OverRun_ScheduleDetail_ScDetailId_Csr
						   end
						    if(@Receipent='QIC')
						   begin
						   Declare OverRun_ScheduleDetail_ScDetailId_Csr   Cursor for 

				            Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD inner join Common.Employee  as E on E.id=Sd.EmployeeId
	                           inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId where sd.MasterId=@ScheduleId  and e.Status=1 and sd.IsQIIncharge=1

				            Open OverRun_ScheduleDetail_ScDetailId_Csr
				            Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId

                            While @@FETCH_STATUS=0
                            Begin
             
         If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and IsOn=1		   and
		   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
         Begin
		 If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		   begin
              set  @Type= (Select Type from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   begin
		     set @NotificationType=@Type
		    set  @NotificationTemplate= (Select NotificationDescription from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @NotificationSubject= (Select NotificationSubject from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @ScreenAction= (Select ScreenAction from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   set  @OtherEmailRecipient= (Select OtherEmailRecipient from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
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
			                   
			         

        End
         End
		 ------------------------------------------mailli New Code ---------------
		  else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='End Date' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

										     set @NotificationType=@Type
										    set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                                            set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
										    set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					  set @OtherEmailRecipient=(Select OtherEmailRecipient from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

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

		 ---------------------------------------------Malli new Code --------------
		   Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                           End
                           Close OverRun_ScheduleDetail_ScDetailId_Csr
                           Deallocate OverRun_ScheduleDetail_ScDetailId_Csr
						   end
						    if(@Receipent='MIC')
						   begin
						   Declare OverRun_ScheduleDetail_ScDetailId_Csr   Cursor for 

				            Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD inner join Common.Employee  as E on E.id=Sd.EmployeeId
	                           inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId where sd.MasterId=@ScheduleId  and e.Status=1 and sd.IsMicIncharge=1

				            Open OverRun_ScheduleDetail_ScDetailId_Csr
				            Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId

                            While @@FETCH_STATUS=0
                            Begin
             
         If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and IsOn=1		   and
		   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
         Begin
		 If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		   begin
              set  @Type= (Select Type from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   begin
		     set @NotificationType=@Type
		    set  @NotificationTemplate= (Select NotificationDescription from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @NotificationSubject= (Select NotificationSubject from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

		  set  @ScreenAction= (Select ScreenAction from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
		   set  @OtherEmailRecipient= (Select OtherEmailRecipient from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date' and --IsPersonalSetting=1 and
		  IsOn=1 and  CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
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
			                   
			         

        End
         End
		 ------------------------------------------mailli New Code ---------------
		  else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='End Date' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

										     set @NotificationType=@Type
										    set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                                            set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
										    set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					  set @OtherEmailRecipient=(Select OtherEmailRecipient from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

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

		 ---------------------------------------------Malli new Code --------------
		   Fetch Next From OverRun_ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                           End
                           Close OverRun_ScheduleDetail_ScDetailId_Csr
                           Deallocate OverRun_ScheduleDetail_ScDetailId_Csr
						   end

		 ---------- Commenetd-----
           If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='End Date' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
               --  set	@lstNotificationUser=@UserName

		                   Declare OverRun_NotificationSettings_Csr   Cursor for 
                           Select  ScreenAction, [Type] as NotificationType, NotificationDescription,NotificationSubject,RTRIM(LTRIM(value)) as OtherRecipients,OtherEmailRecipient
	                       from [Notification].[NotificationSettings] CROSS APPLY STRING_SPLIT(OtherRecipients, ',')  
			               where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1  and CompanyId=@CompanyId and CompanyUserId is null

		     	           Open OverRun_NotificationSettings_Csr
			               Fetch Next From OverRun_NotificationSettings_Csr  into @ScreenAction, @NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients,@OtherEmailRecipient
				   
                           While @@FETCH_STATUS=0
                           Begin 

                                set @CompanyUId=(Select id from Common.CompanyUser where userName=@OtherRecipients and companyId=@companyId)

			          If(@CompanyUId is not null)
					   Begin

					   
					            if Exists (Select id from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and ScreenName='Cases'
							                 and ScreenAction='End Date' and IsOn=1 and companyId=@CompanyId)
					            Begin
					             	    set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='End Date'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					             	 If (@Type like '%Notification%')
					             	 begin
					             	       set @lstNotificationUser=CONCAT(@lstNotificationUser ,',',@OtherRecipients)
					             	 End
					             	 If (@Type like '%Email%')
					             	 Begin
					             	         set @lstEmailUser=CONCAT(@lstEmailUser ,',',@OtherRecipients,',',@OtherEmailRecipient)
					             	 End
                                End
					 End 
      
                           Fetch Next From OverRun_NotificationSettings_Csr  into  @ScreenAction,@NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients,@OtherEmailRecipient
                           End
                           Close OverRun_NotificationSettings_Csr
                           Deallocate OverRun_NotificationSettings_Csr

        End


		  If(@NotificationTemplate is not null)
              Begin 

                   set  @Template = Replace(REPLACE(REPLACE(@NotificationTemplate,'{{ClientName}}',@ClientName),'{{CaseNo}}',@CaseNumber),'{{EndDate}}',@EndDate);
				   set @NotificationSubject=REPLACE(REPLACE(@NotificationSubject,'{{ClientName}}',@ClientName),'{{CaseNo}}',@CaseNumber);

				   
			 --if not exists(select * from Notification.[Case] where CaseId=@CaseId and ScreenAction=@ScreenAction)
			 --begin
			        insert into  Notification.[Case]([Id],[CaseId],[CaseNumber],[ClientName], [CompanyId], [Subject], [ScreenAction], [Template], [NotificationType], [ToNotificationUser], [ToEmailUser], [Date], [UserCreated], [CreatedDate], [Status])
			        values (NEWID(),@CaseId,@CaseNumber,@ClientName,@CompanyId,@NotificationSubject,@ScreenAction,@Template,@NotificationType,@lstNotificationUser,@lstEmailUser,convert(date,GETDATE()),'System',GETDATE(),1)
			--end
			-----------------------------------
			  set @NotificationTemplate =null
			  set @NotificationSubject=null
			  set @ScreenAction=null
			  set @lstEmailUser =null
              set @lstNotificationUser=null
			--Select NEWID(),@CompanyId,@NotificationSubject,@ScreenAction,@Template,@NotificationType,@lstNotificationUser,@lstEmailUser,GETDATE(),'System',GETDATE(),@NotificationTemplate

            End

			 set @NotificationTemplate =null
			  set @NotificationSubject=null
			  set @ScreenAction=null
			  set @lstEmailUser =null
              set @lstNotificationUser=null


                         
	

                   
		end
		
		end
		set @Recount = @Recount+1
		end
		

		IF OBJECT_ID(N'tempdb..#TempCaseTbl') IS NOT NULL
BEGIN
DROP TABLE #TempCaseTbl
END

Commit Transaction--s2
	End try --s3
	Begin Catch
	ROLLBACK TRANSACTION
		DECLARE
				@ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;
		SELECT
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	End Catch
	end--1

		





		       

   










GO
