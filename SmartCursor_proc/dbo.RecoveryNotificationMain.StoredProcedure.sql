USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RecoveryNotificationMain]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  Proc  [dbo].[RecoveryNotificationMain] 
--@CompanyyId BIGINT

as 
begin

   Declare  @ScheduleId Uniqueidentifier,
            @CaseId Uniqueidentifier,
            @TargettedRecovery Decimal(18,7),
		    @Stage nvarchar(50),
		    @CaseNumber nvarchar(50),
		    @ClientName nvarchar(100),
		    @CompanyId  int ,
		    @ScheduleDetailId Uniqueidentifier,
		    @CaseFee Money,
            @HoursCost Decimal(18,7),
            @FeeAllocationPer float,
            @PlannedCost Money,
			@ActualCost Money,
			@FeeRecovery  Decimal(18,7),
			@ActualRecovery  Decimal(18,7),
		    @Template varchar(Max),
			@UserName nvarchar(50),
		    @FirstName nvarchar(50),
			@CompanyUId int,
			@lstNotificationUser nvarchar(max),
		    @lstEmailUser nvarchar(max),
			@NotificationType nvarchar(150),
			@NotificationTemplate nvarchar(max),
			@NotificationSubject nvarchar(500),
			@OtherRecipients nvarchar(max),
			@OtherEmailRecipient nvarchar(max),
			@Type varchar(50),
			@ScreenAction varchar(256),
			@Count BigInt
  --========= Here  @Planned and @Actualn Table Declare for  PlannedCost and ActCost and FeeAllocationPer and  FeeAllocation  ==============

   Declare @Planned Table(CaseId Uniqueidentifier,PlannedCost Decimal(28,9),FeeAllocationPer Decimal(28,9),FeeAllocation Decimal(28,9) )
   Declare @Actual Table(CaseId Uniqueidentifier,ActCost Decimal(28,9) )

---================= Here Declare Cursor For Getting Cases in 'Assigned''In-Progress'================================

   Declare CaseGroup_CaseId_Csr Cursor For  -----========== Start Cursor CaseGroup_CaseId_Csr
   Select S.Id,s.CaseId,CG.TargettedRecovery,CG.Stage,Cg.CaseNumber,CG.Name,CG.CompanyId from WorkFlow.CaseGroup  As CG
   inner join WorkFlow.ScheduleNew as S on Cg.Id=s.CaseId where (Stage='Assigned' or Stage='In-Progress') 
   --and Cg.CompanyId= 1 ---and CG.CaseNumber in ('CE-AUDSTA-2019-05174') 
   Order by cg.CompanyId
   Open CaseGroup_CaseId_Csr
   Fetch Next From CaseGroup_CaseId_Csr  into @ScheduleId ,@CaseId , @TargettedRecovery,@Stage,@CaseNumber,@ClientName,@CompanyId
   While @@FETCH_STATUS=0
   BEGIN
SET @CaseFee=0
SET @PlannedCost =0
SET @FeeAllocationPer =0
SET @ActualCost =0
SET @TargettedRecovery =0

     BEGIN -- start 1 ST
--============================= Here insert  PlannedCost,ActCost,FeeAllocationPer,FeeAllocation in table @Planned,@Actual ===================================================================
       insert into @Planned
       select CaseId,sum(isnull(PlannedCost,0)) as PlannedCost,sum(isnull(FeeAllocationPer,0)) as FeeAllocationPer,
	   sum(isnull(FeeAllocation,0)) as FeeAllocation from 
       (
        select gg.CaseId,EmployeeId, PlannedCost,isnull((PlannedCostnew/nullif((CasePlannedCost-CaseOverrunCost),0)),0)*100 
        as FeeAllocationPer,cast(isnull(((isnull((PlannedCostnew/nullif((CasePlannedCost-CaseOverrunCost),0)),0)*100 )*(CaseFee))/100,0)
		as decimal(28,9)) as FeeAllocation
        from 
         (
           select CaseId,EmployeeId,sum(isnull(PlannedCost,0)) PlannedCost,sum(isnull(PlannedCostnew,0)) PlannedCostnew from 
           (
            select  CaseId,EmployeeId,(((sum(isnull(PlannedHours,0))))/60.0)*(isnull(ChargeoutRate,0)) as PlannedCostnew,
            (((sum(isnull(PlannedHours,0)))+(sum(isnull(OverRunHours,0))))/60.0)* (isnull(ChargeoutRate,0)) as PlannedCost,
            isnull(ChargeoutRate,0)ChargeoutRate from WorkFlow.ScheduleTaskNew
            where caseid=@CaseId
            group by CaseId,EmployeeId,ChargeoutRate
            )kk
           group by CaseId,EmployeeId
         )ll
         inner join 
         (
           select caseId,CaseFee,sum(isnull(PlannedCost,0)) CasePlannedCost,sum(isnull(OverrunCost,0)) as CaseOverrunCost from 
           (
             select  CaseId,EmployeeId,(((sum(isnull(PlannedHours,0)))+(sum(isnull(OverRunHours,0))))/60.0)* (isnull(ChargeoutRate,0)) as PlannedCost,
             ((sum(isnull(OverRunHours,0))/60.0)*(sum(isnull(OverRunHours,0)))) as OverrunCost,
             isnull(ChargeoutRate,0)ChargeoutRate from WorkFlow.ScheduleTaskNew
             where caseid=@CaseId
             group by CaseId,EmployeeId,ChargeoutRate
            )jj
      	    INNER join 
            (
              select Id,FEE AS CaseFee,CompanyId AS CaseCompanyId FROM WorkFlow.CaseGroup where id=@CaseId
             ) d on  d.Id=jj.CaseId 
             group by caseId,CaseFee
          )gg on gg.CaseId=ll.CaseId
        )hh
        group by CaseId
       --============================= =====================================insert in ActCost=============================================================
       insert into @Actual
       select SystemId as Caseid,sum(isnull(ActCost,0)) as ActCost from 
     	  (
     		 select SystemId,EmployeeId,ChargeOutRate,((Hours/60.0)*ChargeOutRate) as ActCost from 
     		(
     		  Select SystemId,tl.EmployeeId,sum(((DATEPART(HOUR,Duration)*60)+((DATEPART(MINUTE,Duration))))) as Hours ,isnull(TLD.ChargeoutRate,0) ChargeoutRate
     		  From Common.TimeLog As TL
     		  Inner Join Common.TimeLogItem As TLI On TLI.Id=TL.TimeLogItemId 
     		  Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id
     		  --inner join hr.EmployeeDepartment hr on hr.EmployeeId=tl.EmployeeId and tld.date between hr.EffectiveFrom and isnull(hr.EffectiveTo,getutcdate())
     		  Where  SystemId=@CaseId AND
     		  Duration<>'00:00:00.0000000' and SystemId is not null
     		  group by SystemId,tl.EmployeeId,TLD.ChargeOutRate
     		 )kk
     	    )hh
     	    group by SystemId
     END -- end 1 ST
	 -- ============= here calculate and set  @PlannedCost,@FeeAllocationPer,@ActualCost,@TargettedRecovery ====================
     BEGIN -- Start 2 nd 
        Select @Count = COUNT(*) from WorkFlow.ScheduleTasknew  where CaseId=@CaseId
        Select @CaseFee=fee from WorkFlow.CaseGroup Where Id=@CaseId
        Select  @PlannedCost= ISNULL(PlannedCost,0) From @Planned Where CaseId=@CaseId  and PlannedCost is not null
        Select @FeeAllocationPer=ROUND((ISNULL(FeeAllocation,0)),2) From @Planned Where CaseId=@CaseId and FeeAllocation is not null
        select @ActualCost = (ISNULL(ActCost,0)) From @Actual Where CaseId=@CaseId  and ActCost is not null
       	select @TargettedRecovery= Isnull(TargettedRecovery,0) from WorkFlow.CaseGroup Where Id=@CaseId
       
       	Select  @PlannedCost=ISNULL( @PlannedCost ,0)
       	Select @FeeAllocationPer =ISNULL(case when isnull(@FeeAllocationPer,0)=0 then isnull(@CaseFee,0) else  @FeeAllocationPer end ,0)
       	select @ActualCost=ISNULL(@ActualCost,0)

		--================ here Check @PlannedCost @ActualCost AND @FeeAllocationPer @FeeRecovery @ActualRecovery  <> IN 0 =================================
       	If(@PlannedCost!=0 and @FeeAllocationPer!=0)
       	BEGIN
       	   set @FeeRecovery= Round(((@FeeAllocationPer/@PlannedCost) *100),2)
        END
		Else
       	BEGIN
       	set @FeeRecovery=0
       	END
       	If(@ActualCost!=0 and @FeeAllocationPer!=0)
       	BEGIN
       	 set @ActualRecovery= Round(((@FeeAllocationPer/@ActualCost) *100),2)
       	END
       	Else
       	BEGIN
       	set @ActualRecovery=0
       	END 

		--================================= Here check stage in Assigned and @FeeRecovery @TargettedRecovery !=0 =======

        if( @Stage='Assigned' and @FeeRecovery!=0 and @TargettedRecovery !=0)
       	BEGIN --===== Start 3 nd 
          If(isnull(@FeeRecovery,0)<isnull(@TargettedRecovery,0))  --===== here check   Planned recovery below target recovery
       	  BEGIN  --===== Start 4 nd 

---================= Here Declare Cursor For Getting Username,FirstName,UserId ================================

       		Declare ScheduleDetail_ScDetailId_Csr   Cursor for   -----========== Start Cursor ScheduleDetail_ScDetailId_Csr
            Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD 
       		inner join Common.Employee  as E on E.id=Sd.EmployeeId
       	    inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId  and E.Status=1
       	    where sd.MasterId=@ScheduleId
            Open ScheduleDetail_ScDetailId_Csr
       		Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
            While @@FETCH_STATUS=0
            BEGIN
                 If Exists ( Select Id from [Notification].[NotificationSettings]  
       			 where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Planned Recovery' 
       		     and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

       			 BEGIN  
       				 If Exists ( Select Id from [Notification].[NotificationSettings]  
       				 where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Planned Recovery' 
       				 and IsOn=1    and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

       				 BEGIN
       				    set @Type = (Select Type  from [Notification].[NotificationSettings]  
       				    where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Planned Recovery' 
       				    and IsOn=1    and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

       				    BEGIN
       				      set @NotificationType=@Type
       				      set @NotificationTemplate = (Select NotificationTemplate  from [Notification].[NotificationSettings]  
       				      where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Planned Recovery' 
       				      and IsOn=1    and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
       				      set @NotificationSubject = (Select NotificationSubject  from [Notification].[NotificationSettings]  
       				      where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Planned Recovery' 
       				      and IsOn=1    and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
       				      set @ScreenAction = (Select ScreenAction  from [Notification].[NotificationSettings]  
       				      where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Planned Recovery' 
       				      and IsOn=1    and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
       				      set @OtherEmailRecipient = (Select OtherEmailRecipient  from [Notification].[NotificationSettings]  
       				      where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Planned Recovery' 
       				      and IsOn=1    and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)

       				       If (@Type like '%Notification%')
       					   BEGIN
       					     set @lstNotificationUser= CONCAT(@lstNotificationUser ,',',@UserName)
       					   END
       					   If (@Type like '%Email%')
       					   BEGIN
       					     set @lstEmailUser=CONCAT(@lstEmailUser,',',@UserName,',',@OtherEmailRecipient)
       						 set @OtherEmailRecipient=null
       					   END
       					END
                     END
                 END
       			 Else If 
				 Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'
				         and ScreenName='Cases'and ScreenAction='Over Run' and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
       	         BEGIN
                     set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
       				 and ScreenName='Recovery' and  ScreenAction='Planned Recovery'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
       			     set @NotificationType=@Type
       				 set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
       				 and ScreenName='Recovery' and  ScreenAction='Planned Recovery'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                     set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
       				 and ScreenName='Recovery' and  ScreenAction='Planned Recovery'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                     set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
       				 and ScreenName='Recovery' and  ScreenAction='Planned Recovery'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
                     set @OtherEmailRecipient=(Select OtherEmailRecipient from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
       				 and ScreenName='Recovery' and  ScreenAction='Planned Recovery'  and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)

                     If (@Type like '%Notification%')
       				 BEGIN
       					 set @lstNotificationUser=CONCAT(@lstNotificationUser ,',',@UserName)
       				 End
       				 If (@Type like '%Email%')
       				 BEGIN
       				    set @lstEmailUser=CONCAT(@lstEmailUser ,',',@UserName,',',@OtherEmailRecipient)
       					set @OtherEmailRecipient=null
       			     End
                 End     
            Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
            End
            Close ScheduleDetail_ScDetailId_Csr
            Deallocate ScheduleDetail_ScDetailId_Csr   -----========== END Cursor ScheduleDetail_ScDetailId_Csr
 ---================= Here Declare Cursor For Getting Username,FirstName,UserId ================================      
       
            If Exists ( Select Id from [Notification].[NotificationSettings]  
       		         where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Planned Recovery' 
       				  and IsOn=1and CompanyId=@CompanyId  and CompanyUserId is null)
       		BEGIN --- -===== Start 5 nd 
---==Here Declare Cursor For Getting @ScreenAction,@NotificationType,@NotificationTemplate,@NotificationSubject ,@OtherRecipients,@OtherEmailRecipient ================================    

                 Declare Notification_Csr   Cursor for -----========== Start Cursor Notification_Csr
                 Select  ScreenAction, [Type] as NotificationType, NotificationDescription,NotificationSubject,RTRIM(LTRIM(value)) as OtherRecipients,OtherEmailRecipient
       	         from [Notification].[NotificationSettings] CROSS APPLY STRING_SPLIT(OtherRecipients, ',')  
       			 where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Planned Recovery'  and IsOn=1  and CompanyId=@CompanyId and CompanyUserId is null
       		     Open Notification_Csr
       			 Fetch Next From Notification_Csr  into @ScreenAction, @NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients,@OtherEmailRecipient
                 While @@FETCH_STATUS=0
                 BEGIN 
                      set @CompanyUId=(Select top 1 id from Common.CompanyUser where userName=@OtherRecipients and companyId=@companyId)
       			      if(@CompanyUId is not null)
       				  BEGIN
                        if Exists (Select id from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Planned Recovery' and IsOn=1 and companyId=@CompanyId)
       					BEGIN
       						set @Type=   (Select top 1   [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Planned Recovery' and IsOn=1   and   CompanyId=@CompanyId)
       						if(@Type like '%Notification%')
       						BEGIN
       						 set @lstNotificationUser= CONCAT(@lstNotificationUser ,',',@OtherRecipients)
       						End
       						If (@Type like '%Email%')
       						BEGIN
       						  set @lstEmailUser=CONCAT(@lstEmailUser ,',',@OtherRecipients,',',@OtherEmailRecipient)
       						End
       	                End 
       	              End 
                 Fetch Next From Notification_Csr  into  @ScreenAction,@NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients,@OtherEmailRecipient
                 End
                 Close Notification_Csr
                 Deallocate Notification_Csr  -----========== END Cursor Notification_Csr

 ---==Here Declare Cursor For Getting @ScreenAction,@NotificationType,@NotificationTemplate,@NotificationSubject ,@OtherRecipients,@OtherEmailRecipient ================================    
      
            End --- -===== END 5 nd 
          End --===== END 4 nd 
          If(@NotificationTemplate is not null)
          BEGIN 
            set  @Template = REPLACE(REPLACE(@NotificationTemplate,'{{ClientName}}',@ClientName),'{{CaseNo}}',@CaseNumber);
       		set @NotificationSubject=REPLACE(REPLACE(@NotificationSubject,'{{ClientName}}',@ClientName),'{{CaseNo}}',@CaseNumber);

       	    insert into  Notification.Recovery ([Id],CaseId,[CaseNumber],[ClientName], [CompanyId], [Subject], [ScreenAction], [Template], [NotificationType], [ToNotificationUser], [ToEmailUser], [Date], [UserCreated], [CreatedDate], [Status])
       		values (NEWID(),@CaseId,@CaseNumber,@ClientName,@CompanyId,@NotificationSubject,@ScreenAction,@Template,@NotificationType,@lstNotificationUser,@lstEmailUser,GETDATE(),'System',GETDATE(),1)
       	    set @NotificationTemplate =null
       		set @NotificationSubject=null
       		set @ScreenAction=null
       		set @lstEmailUser =null
            set @lstNotificationUser=null
       ---------------------------------------------------- 3rd
          End
        End --===== END  3 nd   
	--================================= Here check stage in Assigned and @@ActualRecovery @FeeRecovery !=0 =======
       	Else  If(@Stage='In-Progress'and @ActualRecovery!=0 and isnull(case when isnull(@FeeRecovery ,0)=0 then isnull(@TargettedRecovery,0) else isnull(@FeeRecovery ,0) end,0) !=0)
       	BEGIN -- START 6 TH
       		If(isnull(@ActualRecovery,0) < isnull(case when isnull(@FeeRecovery ,0)=0 then isnull(@TargettedRecovery,0) else isnull(@FeeRecovery ,0) end,0))  --===== here check   Actual recovery below planned recovery 
       		BEGIN -- START 7 TH

			---================= Here Declare Cursor For Getting Username,FirstName,UserId ================================

              Declare ScheduleDetail_ScDetailId_Csr   Cursor for   -----========== Start Cursor ScheduleDetail_ScDetailId_Csr
       		  Select  Distinct(E.Username),E.FirstName,CU.Id from WorkFlow.ScheduleDetailNew  as SD 
       		  inner join Common.Employee  as E on E.id=Sd.EmployeeId
       	      inner join Common.CompanyUser  as CU on CU.Username=E.Username and CU.CompanyId=@CompanyId and E.Status=1
       	      where sd.MasterId=@ScheduleId
              Open ScheduleDetail_ScDetailId_Csr
       		  Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
              While @@FETCH_STATUS=0
              BEGIN
                   If Exists ( Select Id from [Notification].[NotificationSettings]  
       			   where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Actual Recovery' 
       			   and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
       			   BEGIN
       				  If Exists ( Select Id from [Notification].[NotificationSettings]  
       				  where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Actual Recovery' 
       				  and IsOn=1 and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
       				  BEGIN
       				    set @Type =  ( Select Type from [Notification].[NotificationSettings]  
       				    where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Actual Recovery' 
                        and IsOn=1 and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
       				    set @NotificationTemplate =  ( Select NotificationTemplate from [Notification].[NotificationSettings]  
       				    where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Actual Recovery' 
       				    and IsOn=1 and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
       				    set @ScreenAction =  ( Select ScreenAction from [Notification].[NotificationSettings]  
       				    where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Actual Recovery' 
       				    and IsOn=1 and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
       				    set @NotificationSubject =  ( Select NotificationSubject from [Notification].[NotificationSettings]  
       				    where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Actual Recovery' 
       				    and IsOn=1 and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
       				    BEGIN
       					   set @OtherEmailRecipient =  ( Select OtherEmailRecipient from [Notification].[NotificationSettings]  
       				       where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Actual Recovery' 
       				       and IsOn=1 and   CompanyUserId=@CompanyUId and CompanyId=@CompanyId)
       					   If (@Type like '%Notification%')
       				       BEGIN
       					       set @lstNotificationUser= CONCAT(@lstNotificationUser ,',',@UserName)
       					   End
       					   If (@Type like '%Email%')
       					   BEGIN
       					        set @lstEmailUser=CONCAT(@lstEmailUser,',',@UserName,',',@OtherEmailRecipient)
       						    set @OtherEmailRecipient= null
       					   End
       				    End
                      End
                   End
                   Else If Exists ( Select Id from [Notification].[NotificationSettings] where CursorName='Workflow Cursor'and 
				   ScreenName='Cases'and ScreenAction='Over Run' 
				   and IsOn=1and CompanyId=@CompanyId and CompanyUserId is null)
       	           BEGIN
                        set @Type=(Select [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
       					and ScreenName='Recovery' and  ScreenAction='Actual Recovery'   and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
       			        set @NotificationType=@Type
       			        set @NotificationTemplate=(Select NotificationDescription from [Notification].[NotificationSettings] 
						where CursorName='Workflow Cursor'
       					and ScreenName='Recovery' and  ScreenAction='Actual Recovery'   and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
       			        set @NotificationSubject=(Select NotificationSubject from [Notification].[NotificationSettings]  
						where CursorName='Workflow Cursor'
       					and ScreenName='Recovery' and  ScreenAction='Actual Recovery'   and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
       			        set @ScreenAction=(Select ScreenAction from [Notification].[NotificationSettings]  
						where CursorName='Workflow Cursor'
       					and ScreenName='Recovery' and  ScreenAction='Actual Recovery'   and IsOn=1 and CompanyId=@CompanyId 
						and CompanyUserId is null)
       			        set @OtherEmailRecipient=(Select @OtherEmailRecipient from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
       					and ScreenName='Recovery' and  ScreenAction='Actual Recovery'   and IsOn=1 and CompanyId=@CompanyId and CompanyUserId is null)
       					If (@Type like '%Notification%')
       					BEGIN
       					 	 set @lstNotificationUser=CONCAT(@lstNotificationUser ,',',@UserName)
       					End
       					If (@Type like '%Email%')
       				 	 BEGIN
       				 	      set @lstEmailUser=CONCAT(@lstEmailUser ,',',@UserName,',',@OtherEmailRecipient)
       						  set @OtherEmailRecipient=null
       			     	 End
                   End
              Fetch Next From ScheduleDetail_ScDetailId_Csr  into @UserName ,@FirstName , @CompanyUId
              End
              Close ScheduleDetail_ScDetailId_Csr
              Deallocate ScheduleDetail_ScDetailId_Csr -----========== Start Cursor ScheduleDetail_ScDetailId_Csr
       
  			---================= Here Declare Cursor For Getting Username,FirstName,UserId ===============================

              If Exists ( Select Id from [Notification].[NotificationSettings]  
       		  where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Actual Recovery' 
       	      and IsOn=1and CompanyId=@CompanyId)
       		  BEGIN
---==Here De  clare Cursor For Getting @ScreenAction,@NotificationType,@NotificationTemplate,@NotificationSubject ,@OtherRecipients,@OtherEmailRecipient ================================    
       		      
			  	Declare Notification_Csr   Cursor for   -----========== Start Cursor Notification_Csr
                  Select  ScreenAction, [Type] as NotificationType, NotificationDescription,NotificationSubject,RTRIM(LTRIM(value)) as OtherRecipients,OtherEmailRecipient
       	          from [Notification].[NotificationSettings] CROSS APPLY STRING_SPLIT(OtherRecipients, ',')  
       		  	where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Actual Recovery'  and IsOn=1  and CompanyId=@CompanyId and CompanyUserId is null
       		      Open Notification_Csr
       		  	Fetch Next From Notification_Csr  into @ScreenAction, @NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients,@OtherEmailRecipient
                  While @@FETCH_STATUS=0
                  BEGIN 
                       set @CompanyUId=(Select  top 1 id from Common.CompanyUser where userName=@OtherRecipients and companyId=@companyId)
       		  	     if(@CompanyUId is not null)
       		  		  BEGIN
                            if Exists (Select id from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'
			  		      and ScreenName='Recovery'and  ScreenAction='Actual Recovery' and IsOn=1 and companyId=@CompanyId and CompanyUserId is null)
       		  		      BEGIN
			  		          set @Type=   (Select  top 1 [Type] as NotificationType from [Notification].[NotificationSettings]  where CursorName='Workflow Cursor'and ScreenName='Recovery'and  ScreenAction='Actual Recovery' and  IsOn=1   and companyId=@CompanyId and CompanyUserId is null)
       		  		          if(@Type like '%Notification%')
       		  		          BEGIN
       		  				     set @lstNotificationUser=CONCAT(@lstNotificationUser ,',',@OtherRecipients)
       		  				  End
       		  				  If (@Type like '%Email%')
       		  				  BEGIN
       		  				     set @lstEmailUser=CONCAT(@lstEmailUser ,',',@OtherRecipients,',',@OtherEmailRecipient)
       		  				      set @OtherEmailRecipient= null
       		  				  End
       	                    End 
       	                End 
                  Fetch Next From Notification_Csr  into  @ScreenAction,@NotificationType,@NotificationTemplate,@NotificationSubject,@OtherRecipients,@OtherEmailRecipient
                  End
                  Close Notification_Csr
                  Deallocate Notification_Csr -----========== END Cursor Notification_Csr
       ---==  Here Declare Cursor For Getting @ScreenAction,@NotificationType,@NotificationTemplate,@NotificationSubject ,@OtherRecipients,@OtherEmailRecipient ================================    	    
              End
            End 
            If(@NotificationTemplate is not null)
            BEGIN 
                set  @Template = REPLACE(REPLACE(@NotificationTemplate,'{{ClientName}}',@ClientName),'{{CaseNo}}',@CaseNumber);
       			set @NotificationSubject=REPLACE(REPLACE(@NotificationSubject,'{{ClientName}}',@ClientName),'{{CaseNo}}',@CaseNumber);

       			 insert into  Notification.Recovery ([Id],CaseId,[CaseNumber],[ClientName], [CompanyId], [Subject], [ScreenAction], [Template], [NotificationType], [ToNotificationUser], [ToEmailUser], [Date], [UserCreated], [CreatedDate], [Status])
       			 values (NEWID(),@CaseId,@CaseNumber,@ClientName,@CompanyId,@NotificationSubject,@ScreenAction,@Template,@NotificationType,@lstNotificationUser,@lstEmailUser,GETDATE(),'System',GETDATE(),1)
       			  
				  set @NotificationTemplate =null
       			  set @NotificationSubject=null
       			  set @ScreenAction=null
       			  set @lstEmailUser =null
                  set @lstNotificationUser=null

            End
        END
  	   
     END -- END 2 ND
   Fetch Next From CaseGroup_CaseId_Csr  into @ScheduleId ,@CaseId , @TargettedRecovery,@Stage,@CaseNumber,@ClientName,@CompanyId
   END
   Close CaseGroup_CaseId_Csr
   Deallocate CaseGroup_CaseId_Csr 
END



GO
