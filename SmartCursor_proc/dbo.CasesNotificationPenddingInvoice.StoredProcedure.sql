USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CasesNotificationPenddingInvoice]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Proc [dbo].[CasesNotificationPenddingInvoice] 

--@companyyId BigInt
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
			    @OtherRecipients nvarchar(1000),
			    @Type varchar(50),
				@UserName nvarchar(50),
		        @FirstName nvarchar(50),
			    @CompanyUId int,
				@Template nvarchar(max),
				@ApprovedDate Date,
				@DaysCount int ,
				@ActualDateOfCompletion Date,
				@DueDateForCompletion Date,
				@ScheduleCompletionDate Date, 
			    @ScreenAction varchar(256)
		
		        --set @lstEmailUser = null
				 Declare @Receipent nvarchar(250)
			   set @Receipent= (Select Recipient from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='Case is approved but case invoice state is not yet fully invoiced' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)     

         Declare CaseGroup_CaseId_Csr Cursor For 

		 Select CG.Id, S.Id,CG.Name,CG.CaseNumber,CG.Stage,CG.CompanyId,cg.ActualDateOfCompletion,cg.DueDateForCompletion 
		 from WorkFlow.CaseGroup as CG  Inner join  WorkFlow.ScheduleNew  as S on s.CaseId=CG.Id
       	 where (Stage='Approve' and InvoiceState!='Fully Invoiced' --or Stage='Assigned' or Stage='Complete'
		 ) 
		-- and Cg.CompanyId= @companyyId --and cg.CaseNumber='CASE-2019-00033' --and Cg.Id='435A26ED-5AE4-49AE-8E35-03996B1184AD' 
		 Open CaseGroup_CaseId_Csr
         Fetch Next From CaseGroup_CaseId_Csr  into @CaseId,@ScheduleId,@ClientName ,@CaseNumber,@Stage,@CompanyId,@ActualDateOfCompletion,@DueDateForCompletion
         While @@FETCH_STATUS=0
         Begin
         
 ----------------------------------CaseInvoice not yet fully paid------------------------

       Declare Invoices_CaseId_Csr Cursor For 

	   Select top 1 State from WorkFlow.Invoice  where  CaseId= @CaseId and State !='Fully Paid' and State!='Void'
	   Open Invoices_CaseId_Csr
       Fetch Next From Invoices_CaseId_Csr  into @InvoiceState
       While @@FETCH_STATUS=0
       Begin
	   
            If(@Stage ='Approve' and (@InvoiceState != 'Fully Paid' or @InvoiceState != 'Void'))
		    Begin
				   ----------------------------------------------------------------------------------------------------------------------------------------------------
				   if(@Receipent='Case Members')
				   begin
			    Declare ScheduleDetail_ScDetailId_Csr   Cursor for 
				   Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD 
				   inner join Common.Employee  as E on E.id=Sd.EmployeeId
	               inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId where sd.MasterId=@ScheduleId and E.Status=1
				
				   Open ScheduleDetail_ScDetailId_Csr
				   Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                   While @@FETCH_STATUS=0
                   Begin
      
			          If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 and  IsOn=1
								 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
				      Begin
                           If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
							Begin

							    Set @Type =( Select Type  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
								begin

								  set @NotificationType=@Type
								 Set @OtherRecipients =( Select OtherEmailRecipient  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

								Set @NotificationSubject =( Select NotificationSubject  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
									Set @ScreenAction =( Select ScreenAction  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
								Set @NotificationTemplate =( Select NotificationDescription  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
								 If (@Type like '%Notification%')
					            	  Begin
					                 set @lstNotificationUser= CONCAT(@lstNotificationUser ,',',@UserName)
					                 End
					                If (@Type like '%Email%')
					                Begin
					                        set @lstEmailUser=CONCAT(@lstEmailUser,',',@UserName,',',@OtherRecipients)
											set @OtherRecipients= null
					                End


						        End

				            

						 END
					 End
					 	  else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='Case is approved but case invoice state is not yet fully invoiced' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)


  set @NotificationType=@Type
						  set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                           set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
						  set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

						  set @OtherRecipients=(Select OtherEmailRecipient as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					 If (@Type like '%Notification%')
					  begin
					 	       set @lstNotificationUser=CONCAT(@lstNotificationUser ,',',@UserName)
						 End
					 If (@Type like '%Email%')
				 	 Begin
				 	         set @lstEmailUser=CONCAT(@lstEmailUser ,',',@UserName,',',@OtherRecipients)
							 set @OtherRecipients=null
			     	 End
                                

		                  

        End 
  

				   Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                   End
                   Close ScheduleDetail_ScDetailId_Csr
                   Deallocate ScheduleDetail_ScDetailId_Csr
				   end
				   if(@Receipent='PIC')
				   begin
				    Declare ScheduleDetail_ScDetailId_Csr   Cursor for 
				   Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD 
				   inner join Common.Employee  as E on E.id=Sd.EmployeeId
	               inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId where sd.MasterId=@ScheduleId and E.Status=1 and sd.IsPrimaryIncharge=1
				
				   Open ScheduleDetail_ScDetailId_Csr
				   Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                   While @@FETCH_STATUS=0
                   Begin
      
			          If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 and  IsOn=1
								 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
				      Begin
                           If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
							Begin

							    Set @Type =( Select Type  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
								begin

								  set @NotificationType=@Type
								 Set @OtherRecipients =( Select OtherEmailRecipient  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

								Set @NotificationSubject =( Select NotificationSubject  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
									Set @ScreenAction =( Select ScreenAction  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
								Set @NotificationTemplate =( Select NotificationDescription  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
								 If (@Type like '%Notification%')
					            	  Begin
					                 set @lstNotificationUser= CONCAT(@lstNotificationUser ,',',@UserName)
					                 End
					                If (@Type like '%Email%')
					                Begin
					                        set @lstEmailUser=CONCAT(@lstEmailUser,',',@UserName,',',@OtherRecipients)
											set @OtherRecipients= null
					                End


						        End

				            

						 END
					 End
					 	  else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='Case is approved but case invoice state is not yet fully invoiced' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)


  set @NotificationType=@Type
						  set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                           set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
						  set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

						  set @OtherRecipients=(Select OtherEmailRecipient as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					 If (@Type like '%Notification%')
					  begin
					 	       set @lstNotificationUser=CONCAT(@lstNotificationUser ,',',@UserName)
						 End
					 If (@Type like '%Email%')
				 	 Begin
				 	         set @lstEmailUser=CONCAT(@lstEmailUser ,',',@UserName,',',@OtherRecipients)
							 set @OtherRecipients=null
			     	 End
                                

		                  

        End 
  

				   Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                   End
                   Close ScheduleDetail_ScDetailId_Csr
                   Deallocate ScheduleDetail_ScDetailId_Csr
				   end
				    if(@Receipent='QIC')
				   begin
				    Declare ScheduleDetail_ScDetailId_Csr   Cursor for 
				   Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD 
				   inner join Common.Employee  as E on E.id=Sd.EmployeeId
	               inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId where sd.MasterId=@ScheduleId and E.Status=1 and sd.IsQIIncharge=1
				
				   Open ScheduleDetail_ScDetailId_Csr
				   Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                   While @@FETCH_STATUS=0
                   Begin
      
			          If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 and  IsOn=1
								 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
				      Begin
                           If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
							Begin

							    Set @Type =( Select Type  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
								begin

								  set @NotificationType=@Type
								 Set @OtherRecipients =( Select OtherEmailRecipient  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

								Set @NotificationSubject =( Select NotificationSubject  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
									Set @ScreenAction =( Select ScreenAction  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
								Set @NotificationTemplate =( Select NotificationDescription  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
								 If (@Type like '%Notification%')
					            	  Begin
					                 set @lstNotificationUser= CONCAT(@lstNotificationUser ,',',@UserName)
					                 End
					                If (@Type like '%Email%')
					                Begin
					                        set @lstEmailUser=CONCAT(@lstEmailUser,',',@UserName,',',@OtherRecipients)
											set @OtherRecipients= null
					                End


						        End

				            

						 END
					 End
					 	  else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='Case is approved but case invoice state is not yet fully invoiced' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)


  set @NotificationType=@Type
						  set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                           set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
						  set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

						  set @OtherRecipients=(Select OtherEmailRecipient as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					 If (@Type like '%Notification%')
					  begin
					 	       set @lstNotificationUser=CONCAT(@lstNotificationUser ,',',@UserName)
						 End
					 If (@Type like '%Email%')
				 	 Begin
				 	         set @lstEmailUser=CONCAT(@lstEmailUser ,',',@UserName,',',@OtherRecipients)
							 set @OtherRecipients=null
			     	 End
                                

		                  

        End 
  

				   Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                   End
                   Close ScheduleDetail_ScDetailId_Csr
                   Deallocate ScheduleDetail_ScDetailId_Csr
				   end
				    if(@Receipent='MIC')
				   begin
				    Declare ScheduleDetail_ScDetailId_Csr   Cursor for 
				   Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD 
				   inner join Common.Employee  as E on E.id=Sd.EmployeeId
	               inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId where sd.MasterId=@ScheduleId and E.Status=1 and IsMicIncharge=1
				
				   Open ScheduleDetail_ScDetailId_Csr
				   Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                   While @@FETCH_STATUS=0
                   Begin
      
			          If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 and  IsOn=1
								 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
				      Begin
                           If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
							Begin

							    Set @Type =( Select Type  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
								begin

								  set @NotificationType=@Type
								 Set @OtherRecipients =( Select OtherEmailRecipient  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

								Set @NotificationSubject =( Select NotificationSubject  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
									Set @ScreenAction =( Select ScreenAction  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
								Set @NotificationTemplate =( Select NotificationDescription  from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'
					             and ScreenAction='Case is approved but case invoice state is not yet fully invoiced'
								--  and IsPersonalSetting=1 
								and  IsOn=1 and CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
								 If (@Type like '%Notification%')
					            	  Begin
					                 set @lstNotificationUser= CONCAT(@lstNotificationUser ,',',@UserName)
					                 End
					                If (@Type like '%Email%')
					                Begin
					                        set @lstEmailUser=CONCAT(@lstEmailUser,',',@UserName,',',@OtherRecipients)
											set @OtherRecipients= null
					                End


						        End

				            

						 END
					 End
					 	  else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and ScreenAction='Case is approved but case invoice state is not yet fully invoiced' 
				    and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
	      Begin
                  set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)


  set @NotificationType=@Type
						  set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                           set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
						  set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

						  set @OtherRecipients=(Select OtherEmailRecipient as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
										   and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					 If (@Type like '%Notification%')
					  begin
					 	       set @lstNotificationUser=CONCAT(@lstNotificationUser ,',',@UserName)
						 End
					 If (@Type like '%Email%')
				 	 Begin
				 	         set @lstEmailUser=CONCAT(@lstEmailUser ,',',@UserName,',',@OtherRecipients)
							 set @OtherRecipients=null
			     	 End
                                

		                  

        End 
  

				   Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
                   End
                   Close ScheduleDetail_ScDetailId_Csr
                   Deallocate ScheduleDetail_ScDetailId_Csr
				   end


                                  if Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and ScreenName='Cases'and 
						          ScreenAction='Case is approved but case invoice state is not yet fully invoiced' and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
				      Begin
                           -- set	@lstNotificationUser=@UserName 
				            Declare CaseInvcoie_NotificationSettings_Csr   Cursor for 
                            Select   ScreenAction, [Type] as NotificationType, NotificationDescription,NotificationSubject,RTRIM(LTRIM(value)) as OtherRecipients
	                        from [Notification].[NotificationSettings] CROSS APPLY STRING_SPLIT(OtherRecipients, ',') where CursorName='Workflow Cursor'and ScreenName='Cases' and ScreenAction='Case is approved but case invoice state is not yet fully invoiced' and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null
		              
		     	            Open CaseInvcoie_NotificationSettings_Csr
			                Fetch Next From CaseInvcoie_NotificationSettings_Csr  into @ScreenAction, @NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients
				             
                            While @@FETCH_STATUS=0
                            Begin 
                                 set @CompanyUId=(Select id from Common.CompanyUser where userName=@OtherRecipients and companyId=@companyId)
			                     If(@CompanyUId is not null)
					             Begin

					      					                   if Exists (Select id from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and ScreenName='Cases'
									  and ScreenAction='Case is approved but case invoice state is not yet fully invoiced' and IsOn=1 and companyId=@CompanyId and CompanyUserId is null ) 
					                  Begin
					             	        set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and ScreenName='Cases'and  ScreenAction='Case is approved but case invoice state is not yet fully invoiced'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
					             	            If (@Type like '%Notification%')
					             	            Begin
					                                  set @lstNotificationUser= CONCAT(@lstNotificationUser ,',',@OtherRecipients)
					                            End
					                            If (@Type like '%Email%')
					                            Begin
					                                  set @lstEmailUser=CONCAT(@lstEmailUser ,',',@OtherRecipients)
					                            End
				                     End 
	                             End 
------------------------------------

       --select @lstNotificationUser,@lstEmailUser,@CompanyUId,@companyId,@Type

--------------------------------------

                             Fetch Next From CaseInvcoie_NotificationSettings_Csr  into     @ScreenAction,@NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients
                             End
                            Close CaseInvcoie_NotificationSettings_Csr
                            Deallocate CaseInvcoie_NotificationSettings_Csr
                      End
			
			End

       Fetch Next From Invoices_CaseId_Csr  into @InvoiceState
       End 
       Close Invoices_CaseId_Csr
       Deallocate Invoices_CaseId_Csr
			   
-----------------------CaseInvocie insert in notification table----------------------

            If(@NotificationTemplate is not null)
            Begin 
                  set  @Template = REPLACE(REPLACE(@NotificationTemplate,'{{ClientName}}',@ClientName),'{{CaseNo}}',@CaseNumber);
				  set @NotificationSubject=REPLACE(REPLACE(@NotificationSubject,'{{ClientName}}',@ClientName),'{{CaseNo}}',@CaseNumber);
			 
		     	insert into  [Notification].[Case] ([Id],[CaseId],[CaseNumber],[ClientName], [CompanyId], [Subject], [ScreenAction], [Template], [NotificationType], [ToNotificationUser], [ToEmailUser],  [Date],     [UserCreated], [CreatedDate], [Status])
		     	 values (NEWID(),@CaseId,@CaseNumber,@ClientName,@CompanyId,@NotificationSubject,@ScreenAction,@Template,@NotificationType,@lstNotificationUser,@lstEmailUser, convert(date,GETDATE()),'System',GETDATE(),1)
		     	 -----------------------------------

				  set @NotificationTemplate =null
			  set @NotificationSubject=null
			  set @ScreenAction=null
			  set @lstEmailUser =null
              set @lstNotificationUser=null
		     	--Select NEWID(),@CompanyId,@NotificationSubject,@ScreenAction,@Template,@NotificationType,@lstNotificationUser,@lstEmailUser,GETDATE(),'System',GETDATE     (),@NotificationTemplate
            End
		      --End

			   set @NotificationTemplate =null
			  set @NotificationSubject=null
			  set @ScreenAction=null
			  set @lstEmailUser =null
              set @lstNotificationUser=null


 -------------------Over Due ------------------------------------------

       Fetch Next From CaseGroup_CaseId_Csr  into @CaseId,@ScheduleId,@ClientName ,@CaseNumber,@Stage,@CompanyId,@ActualDateOfCompletion,@DueDateForCompletion
        End       
		   
         Close CaseGroup_CaseId_Csr
         Deallocate CaseGroup_CaseId_Csr 
  End

GO
