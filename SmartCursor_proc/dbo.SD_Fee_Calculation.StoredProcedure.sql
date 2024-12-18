USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SD_Fee_Calculation]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[SD_Fee_Calculation]

        @ScheduleId Uniqueidentifier,

        @CaseId Uniqueidentifier

 As

 Begin

Declare @ScheduleDetailId Uniqueidentifier

Declare ScheduleDetId_CaseId_Csr Cursor For 

        Select Id From WorkFlow.ScheduleDetail where MasterId=@ScheduleId

Open ScheduleDetId_CaseId_Csr

Fetch Next From ScheduleDetId_CaseId_Csr into @ScheduleDetailId

    While @@FETCH_STATUS=0

    Begin

    Declare @CaseFee Money,

            @HoursCost Decimal(18,7),

            @FeeAllocationPer float, 

            @FeeAllocationDollor Decimal(18,7),

            @FeeRecovery float

    Select @CaseFee=fee from WorkFlow.CaseGroup Where Id=@CaseId

    --Select @HoursCost=Sum(Isnull(PlannedCost,0)) From WorkFlow.ScheduleDetail Where MasterId=@ScheduleId


 


    Select @HoursCost=Sum(PlannedMinutes *( Isnull(ChargeoutRate,0)/60)) From

    (

    Select EmployeeId,MasterId,ChargeoutRate,PlannedCost As Cost,

           Cast(ISnull(PlanedHours,0)/600000000 As int) As PlannedMinutes

                

                      

    From WorkFlow.ScheduleDetail Where MasterId=@ScheduleId

    ) As A Group By MasterId

    

    --Select @HoursCost=Sum(Hours * Isnull(ChargeoutRate,0)) From

    --(

    --Select EmployeeId,MasterId,ChargeoutRate,PlannedCost As Cost,

    --       CASE WHEN Cast(ISnull(PlanedHours,0)/600000000 As int) >= 60 THEN

    --             Cast(Cast(ISnull(PlanedHours,0)/600000000 As int) / 60 As Varchar) + '.' +

    --             --Case when --(Cast(PlanedHours/600000000 As int) % 60)  > 0 Then

    --             Case When (Cast(ISnull(PlanedHours,0)/600000000 As int) % 60) < 10 Then

    --               '0'+Cast (Cast (ISnull(PlanedHours,0)/600000000 As int) % 60 As varchar) 

    --        Else

    --            Cast(Cast(ISnull(PlanedHours,0)/600000000 As int) % 60 As varchar)

    --        End


 


    --         Else

    --            Concat('0.',Cast(Cast(ISnull(PlanedHours,0)/600000000 As int) % 60 As varchar)) End    As Hours

    --            --Cast( Cast (PlanedHours/600000000 As int) % 60  As varchar) End As Hours

                      

    --From WorkFlow.ScheduleDetail Where MasterId=@ScheduleId

    --) As A Group By MasterId


 


    Declare @PlannedCost Decimal(28,7)

    --Select @PlannedCost=Sum(isnull(PlannedCost,0)) From WorkFlow.ScheduleDetail Where Id=@ScheduleDetailId


 


    Select  @PlannedCost=(PlanedMinutes*(isnull(ChargeoutRate,0)))/60

    From

    (

    Select ChargeoutRate,Cast(ISnull(PlanedHours,0)/600000000 As int) As PlanedMinutes              

    From WorkFlow.ScheduleDetail Where Id=@ScheduleDetailId

    ) As A


 


    --Select  @PlannedCost=(Hours*isnull(ChargeoutRate,0))

    --From

    --(

    --Select ChargeoutRate,CASE WHEN Cast(ISnull(PlanedHours,0)/600000000 As int) >= 60 THEN

    --             Cast(Cast(ISnull(PlanedHours,0)/600000000 As int) / 60 As Varchar) + '.' +

    --             --Case when --(Cast(PlanedHours/600000000 As int) % 60)  > 0 Then

    --             Case When (Cast(ISnull(PlanedHours,0)/600000000 As int) % 60) < 10 Then

    --               '0'+Cast (Cast (ISnull(PlanedHours,0)/600000000 As int) % 60 As varchar) 

    --        Else

                

    --             Cast(Cast(ISnull(PlanedHours,0)/600000000 As int) % 60 As varchar)

    --        End


 


    --         Else

    --            Concat('0.',Cast(Cast(ISnull(PlanedHours,0)/600000000 As int) % 60 As varchar)) End    As Hours

    --            --Cast( Cast (PlanedHours/600000000 As int) % 60  As varchar) End    As Hours                  

    --From WorkFlow.ScheduleDetail Where Id=@ScheduleDetailId

    --) As A


 


    Select @FeeAllocationPer=Isnull(Round( Round(@PlannedCost,7) / Nullif(@HoursCost,0)*100,7),0) From WorkFlow.ScheduleDetail Where Id=@ScheduleDetailId  

    

    Select @FeeAllocationDollor=Isnull(Round((@FeeAllocationPer*@CaseFee) / 100,2),0) From WorkFlow.ScheduleDetail Where Id=@ScheduleDetailId 


 


    Select @FeeRecovery=Isnull(Round(@FeeAllocationDollor / Nullif(Round(PlannedCost,7),0)*100,2),0) From WorkFlow.ScheduleDetail Where Id=@ScheduleDetailId 


 


    --Select @FeeRecovery=Isnull(Round(@FeeAllocationDollor / Nullif(PlannedCost,0)*100,4),0) From WorkFlow.ScheduleDetail Where Id=@ScheduleDetailId 


 


    Update WorkFlow.ScheduleDetail Set FeeAllocationPercentage=@FeeAllocationPer,FeeAllocation=@FeeAllocationDollor,[Fee RecoveryPercentage]=@FeeRecovery
         ,[WithoutOverrunCost]=@PlannedCost
             Where Id=@ScheduleDetailId 


 


    --TimeLogScheduleTable Updating

    Update TLS Set TLS.FeeAllocation=WFSD.FeeAllocation,TLS.FeeAllocationPercentage=WFSD.FeeAllocationPercentage,TLS.FeeRecoveryPercentage=ROUND((isnull(WFSD.FeeAllocation,0)/Nullif(ActualCost,0)*100),4)   From Common.TimeLogSchedule As TLS

    Inner Join

    (

    Select S.CaseId,SD.DepartmentId,SD.MasterId As ScheduleId,SD.DesignationId,SD.EmployeeId,SD.FeeAllocation,SD.FeeAllocationPercentage,SD.[Fee RecoveryPercentage],SD.ChargeoutRate,SD.Level From WorkFlow.Schedule As S

    Inner Join WorkFlow.ScheduleDetail As SD On SD.MasterId=S.Id 

    ) As WFSD On WFSD.CaseId=TLS.CaseId And WFSD.DepartmentId=TLS.DepartmentId And WFSD.DesignationId=TLS.DesignationId And WFSD.EmployeeId=TLS.EmployeeId And WFSD.Level=TLS.Level And TLS.ChargeoutRate=WFSD.ChargeoutRate

    Where WFSD.ScheduleId=@ScheduleId And WFSD.CaseId=@CaseId


 




    Fetch Next From ScheduleDetId_CaseId_Csr into @ScheduleDetailId


 


    


 


    End


 


    Close ScheduleDetId_CaseId_Csr

    Deallocate ScheduleDetId_CaseId_Csr


 


    update  workFlow.scheduleDetail   set planedHours=0 where  PlanedHours is null

    update workFlow.scheduleDetail   set FeeAllocationPercentage=0 where  FeeAllocationPercentage is null 

    update workFlow.scheduleDetail   set FeeAllocation=0 where  FeeAllocation is null 

    update workFlow.scheduleDetail   set [Fee RecoveryPercentage] =0 where  [Fee RecoveryPercentage]  is null 

    update workFlow.scheduleDetail   set [WithoutOverrunCost] =0 where  [WithoutOverrunCost]  is null 

    --update WorkFlow.scheduletask  set IsOverRunHours='0',IsOverRun=0 where IsOverRunHours is null 

    End
GO
