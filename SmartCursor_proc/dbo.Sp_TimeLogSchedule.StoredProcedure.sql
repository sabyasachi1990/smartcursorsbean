USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_TimeLogSchedule]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[Sp_TimeLogSchedule]
@CaseId Nvarchar(max),
@EmployeeId Uniqueidentifier,
@FromDate DateTime,
@Todate DateTime
As
Begin
	Declare @TimeLogId Uniqueidentifier,
			@TimeLogTaskId Uniqueidentifier,
			@TimLogTaskDate DateTime2,
			@TimLogTaskHours Time(7),
			@Var_CaseId uniqueidentifier,
			@Count Int,
			@DepartmentId Uniqueidentifier,
			@DesignationId Uniqueidentifier,
			@LevelRank Int,
			@ChargeOutRate Nvarchar(500),
			@TimeLogSchedulId Uniqueidentifier,
			@TimelogHours_Tics BigInt
	--// Declare Cursor To fetch caseid from comma separated parameter	
	-- STRING_SPLIT (@CaseId,',')
	Declare CaseId_Csr Cursor For 
	Select items From [dbo].[SplitToTable] (@CaseId,',')
	Open CaseId_Csr
	Fetch Next From CaseId_Csr into @Var_CaseId
	While @@FETCH_STATUS=0
	Begin --// Cursor 1
		--//Declare Cursor To fecth Timelogid based on caseid and employeeid
		Declare TimeLogId_Csr Cursor For
			Select TL.Id As TimeLogId,TLD.Id As TimeLogDetailId,TLD.Date,TLD.Duration From Common.TimeLog As TL
			Inner Join Common.TimeLogItem As TLI On TLI.Id=TL.TimeLogItemId 
			Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id
			Where TL.EmployeeId=@EmployeeId And TLI.SystemId=@Var_CaseId And TL.Startdate>=@FromDate And TL.Enddate<=@Todate
			--And TLD.Duration<>'00:00:00.0000000'
		Open TimeLogId_Csr
		Fetch Next From TimeLogId_Csr Into @TimeLogId,@TimeLogTaskId,@TimLogTaskDate,@TimLogTaskHours
		While @@FETCH_STATUS=0
		Begin --//Cursor 2
			--//Checking The Employee Department
			Select @Count=Count(*) From HR.EmployeeDepartment 
			Where EmployeeId=@EmployeeId And EffectiveFrom <= @TimLogTaskDate and (@TimLogTaskDate <= EffectiveTo  or EffectiveTo is null)
			--//If count<>0 then Employee Is in EmployeeDepartment	
			If @Count<>0
			Begin --//Count
				Select @DepartmentId=DepartmentId,@DesignationId=DepartmentDesignationId,@LevelRank=LevelRank,@ChargeOutRate=ChargeOutRate 
				From HR.EmployeeDepartment 
				Where EmployeeId=@EmployeeId And EffectiveFrom <= @TimLogTaskDate and (EffectiveTo >= @TimLogTaskDate or EffectiveTo is null) --AND ChargeoutRate IS NOT NULL ----CHAN1 
				--//Check The Employee task in TimeLog Schedule 
				If Exists (Select * From common.TimeLogSchedule Where EmployeeId=@EmployeeId And CaseId=@Var_CaseId And DepartmentId=@DepartmentId And DesignationId=@DesignationId And Isnull(Level,0)=Isnull(@LevelRank,0) And ChargeoutRate=@ChargeOutRate)
				/*coalesce(ChargeoutRate,'NULL')=Coalesce(@ChargeOutRate,'NULL') )*/
				Begin --// Exists TimLogSchdl
					Select @TimeLogSchedulId=Id From common.TimeLogSchedule Where EmployeeId=@EmployeeId And CaseId=@Var_CaseId And DepartmentId=@DepartmentId And DesignationId=@DesignationId 
					And Isnull(Level,0)=Isnull(@LevelRank,0) And ChargeoutRate=@ChargeOutRate --AND ChargeoutRate IS NOT NULL ----CHAN1
					Set @TimelogHours_Tics = Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@TimLogTaskHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint) 
					--Update Common.TimeLogSchedule Set ActualHours=ActualHours+@TimelogHours_Tics,
					--									ActualCost=CASE WHEN Cast((ActualHours+@TimelogHours_Tics)/600000000 As int) >= 60 THEN
					--												Cast(Cast((ActualHours+@TimelogHours_Tics)/600000000 As int) / 60 As Varchar) + '.' +
					--												Case When (Cast((ActualHours+@TimelogHours_Tics)/600000000 As int) % 60) < 10 Then
					--												'0'+Cast (Cast ((ActualHours+@TimelogHours_Tics)/600000000 As int) % 60 As varchar) 
					--												Else
					--												Cast(Cast((ActualHours+@TimelogHours_Tics)/600000000 As int) % 60 As varchar)
					--												End
					--												Else
					--												Cast( Cast ((ActualHours+@TimelogHours_Tics)/600000000 As int) % 60  As varchar) End * ChargeoutRate
					--												Where Id=@TimeLogSchedulId
					Update Common.TimeLogDetail Set TimeLogScheduleId=@TimeLogSchedulId Where Id=@TimeLogTaskId
					
				End --// Exists TimLogSchdl
				Else
				Begin --//Else Exists TimLogSchdl
					Declare @NewId Uniqueidentifier=Newid()
					Set @TimelogHours_Tics = Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@TimLogTaskHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint) 
					Declare @ActualCost Decimal(18,7)=  Round((Cast((@TimelogHours_Tics)/600000000 As int)*(cast(@ChargeoutRate As float)))/60,4)
					--Declare @ActualCost Decimal(18,7)= Round((Cast(@TimelogHours_Tics/600000000 As int) * (cast(@ChargeoutRate As float))) /60,3)
					--Declare @ActualCost Decimal(18,7)=Cast(CASE WHEN Cast(@TimelogHours_Tics/600000000 As int) >= 60 THEN
					--													Cast(Cast(@TimelogHours_Tics/600000000 As int) / 60 As Varchar) + '.' +
					--													Case When (Cast(@TimelogHours_Tics/600000000 As int) % 60) < 10 Then
					--													'0'+Cast (Cast (@TimelogHours_Tics/600000000 As int) % 60 As varchar) 
					--													Else
					--													Cast(Cast(@TimelogHours_Tics/600000000 As int) % 60 As varchar)
					--													End
					--													Else
					--													--Cast( Cast (@TimelogHours_Tics/600000000 As int) % 60  As varchar) End As Decimal(18,7)) * @ChargeoutRate
					--													Concat('0.',Cast(Cast(ISnull(@TimelogHours_Tics,0)/600000000 As int) % 60 As varchar)) End As Decimal(18,7)) * (@ChargeoutRate/60)
																	
					Insert Into Common.TimeLogSchedule (Id,CaseId,DepartmentId,DesignationId,EmployeeId,Level,ChargeoutRate,ActualHours,ActualCost,CreatedDate,Status)
							Values(@NewId,@Var_CaseId,@DepartmentId,@DesignationId,@EmployeeId,@LevelRank,@ChargeOutRate,@TimelogHours_Tics,ISNULL(@ActualCost,0.00),GETDATE(),1)
				
					Update Common.TimeLogDetail Set TimeLogScheduleId=@NewId Where Id=@TimeLogTaskId
				End --//Else Exists TimLogSchdl
			End --//Count
			Fetch Next From TimeLogId_Csr Into @TimeLogId,@TimeLogTaskId,@TimLogTaskDate,@TimLogTaskHours
		End --// Cursor 2
		Close TimeLogId_Csr; --// Cursor 2
		Deallocate TimeLogId_Csr; --// Cursor 2
	
		--Update Common.TimeLogDetail Set TimeLogScheduleId=null where Duration='00:00:00.0000000'
		--  delete Common.TimeLogSchedule  not in  Common.TimeLogDetail
        DELETE from  Common.TimeLogSchedule where  Id  Not in  ( Select  TimeLogScheduleId from Common.TimeLogDetail WHERE TimeLogScheduleId IS NOT NULL)

		Begin
		Declare @Sc_Id uniqueidentifier,
				@Actl_Hours Bigint,
				@StartDate Datetime2,
				@EndDate Datetime2
		Declare TimLg_Schd Cursor For 
			Select distinct TLS.Id from Common.TimeLogSchedule As TLS
					Inner Join Common.TimeLogDetail As TLD on TLD.TimeLogScheduleId=TLS.Id Where TLS.CaseId=@Var_CaseId
			Open TimLg_Schd
			Fetch Next From TimLg_Schd Into @Sc_Id
			While @@FETCH_STATUS=0
			Begin
			Select @StartDate=MIN(Date),@EndDate=MAX(Date) from Common.TimeLogDetail Where TimeLogScheduleId=@Sc_Id And Duration <> '00:00:00.0000000'
			Set @Actl_Hours=(Select Sum(Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(Duration,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)) from Common.TimeLogDetail where TimeLogScheduleId=@Sc_Id)
		
			Update Common.TimeLogSchedule Set ActualHours=@Actl_Hours,
														StartDate=@StartDate,EndDate=@EndDate,
														--ActualCost = ( Cast((@Actl_Hours)/600000000 As int)  * (ChargeoutRate/60))
														ActualCost = isnull(Round( (Cast((@Actl_Hours)/600000000 As int)*isnull(ChargeoutRate,0))/60,4),0.00)
														Where Id=@Sc_Id
			--Update Common.TimeLogSchedule Set ActualHours=@Actl_Hours,
			--								StartDate=@StartDate,EndDate=@EndDate,
			--								ActualCost=CASE WHEN Cast((@Actl_Hours)/600000000 As int) >= 60 THEN
			--											Cast(Cast((@Actl_Hours)/600000000 As int) / 60 As Varchar) + '.' +
			--											Case When (Cast((@Actl_Hours)/600000000 As int) % 60) < 10 Then
			--											'0'+Cast (Cast ((@Actl_Hours)/600000000 As int) % 60 As varchar) 
			--											Else
			--											Cast(Cast((@Actl_Hours)/600000000 As int) % 60 As varchar)
			--											End
			--											Else
			--											--Cast( Cast ((@Actl_Hours)/600000000 As int) % 60  As varchar) End * ChargeoutRate
			--											Concat('0.',Cast(Cast(ISnull(@Actl_Hours,0)/600000000 As int) % 60 As varchar)) End * ChargeoutRate
			--											Where Id=@Sc_Id
		
			Fetch Next From TimLg_Schd Into @Sc_Id
			End
			Close TimLg_Schd
			Deallocate TimLg_Schd
		
		End
		
			Fetch Next From CaseId_Csr into @Var_CaseId
		End --// Cursor 1
		Close CaseId_Csr  --// Cursor 1
		Deallocate CaseId_Csr --// Cursor 1
	
	
	
		--TimeLogScheduleTable Updating
		Update TLS Set TLS.FeeAllocation=WFSD.FeeAllocation,TLS.FeeAllocationPercentage=WFSD.FeeAllocationPercentage,TLS.FeeRecoveryPercentage= ROUND((isnull(WFSD.FeeAllocation,0)/Nullif(ActualCost,0)*100),4)   From Common.TimeLogSchedule As TLS
		Inner Join
		(
		Select S.CaseId,SD.DepartmentId,SD.MasterId As ScheduleId,SD.DesignationId,SD.EmployeeId,SD.FeeAllocation,SD.FeeAllocationPercentage,SD.[Fee RecoveryPercentage],SD.ChargeoutRate,SD.Level From WorkFlow.Schedule As S
		Inner Join WorkFlow.ScheduleDetail As SD On SD.MasterId=S.Id 
		) As WFSD On WFSD.CaseId=TLS.CaseId And WFSD.DepartmentId=TLS.DepartmentId And WFSD.DesignationId=TLS.DesignationId And WFSD.EmployeeId=TLS.EmployeeId And WFSD.Level=TLS.Level And TLS.ChargeoutRate=WFSD.ChargeoutRate
		Where TLS.CaseId=@CaseId And TLS.EmployeeId=@EmployeeId

		update   Common.TimeLogSchedule  set ActualCost='0.0000000'  where ActualCost is null
End





GO
