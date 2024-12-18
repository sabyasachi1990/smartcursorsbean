USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_TimeLogSchedule_All]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SP_TimeLogSchedule_All]   @CompanyId int 
As
Begin
Declare @EmployeeId Uniqueidentifier,
		@CaseId Uniqueidentifier,
		--@FromDate DateTime2='1990-09-23 00:00:00.0000000',
		--@Todate DateTime2='2099-09-23 00:00:00.0000000',
		@TimeLogId Uniqueidentifier,
		@TimeLogTaskId Uniqueidentifier,
		@TimLogTaskDate DateTime2,
		@TimLogTaskHours Time(7),
		@Count Int,
		@DepartmentId Uniqueidentifier,
		@DesignationId Uniqueidentifier,
		@LevelRank Int,
		@ChargeOutRate Nvarchar(500),
		@TimeLogSchedulId Uniqueidentifier,
		@TimelogHours_Tics BigInt
--// Declare Cursor to get employees
Declare EmpId_Dist Cursor For
		Select Distinct EmployeeId From Common.TimeLog Where CompanyId=@CompanyId
	Open EmpId_Dist
	Fetch Next From EmpId_Dist Into @EmployeeId
	While @@FETCH_STATUS=0
	Begin --// cursor1
		--// Declare cursor to get Cases of employee
		Declare Case_IdCsr Cursor For
		Select distinct TLI.SystemId from Common.TimeLog As TL
		Inner Join Common.TimeLogItem As TLI On TLI.Id=TL.TimeLogItemId
		Where TL.EmployeeId=@EmployeeId And TLI.SystemId Is not null
		Open Case_IdCsr
		Fetch Next From Case_IdCsr Into @CaseId
		While @@FETCH_STATUS=0
		Begin --// cursor1
			--//Declare Cursor To fecth Timelogid based on caseid and employeeid
			 Declare TimeLogId_Csr Cursor For
			 Select TL.Id As TimeLogId,TLD.Id As TimeLogDetailId,TLD.Date,TLD.Duration From Common.TimeLog As TL
			 Inner Join Common.TimeLogItem As TLI On TLI.Id=TL.TimeLogItemId 
			 Inner Join Common.TimeLogDetail As TLD On TLD.MasterId=TL.Id
			 Where TL.EmployeeId=@EmployeeId And TLI.SystemId=@CaseId --And TL.Startdate>=@FromDate And TL.Enddate<=@Todate
			 --And TLD.Duration<>'00:00:00.0000000'
			 Open TimeLogId_Csr
			 Fetch Next From TimeLogId_Csr Into @TimeLogId,@TimeLogTaskId,@TimLogTaskDate,@TimLogTaskHours
			 While @@FETCH_STATUS=0
			 Begin --//Cursor 3
			--//Checking The Employee Department
			Select @Count=Count(*) From HR.EmployeeDepartment 
			Where EmployeeId=@EmployeeId And EffectiveFrom <= @TimLogTaskDate and (@TimLogTaskDate <= EffectiveTo  or EffectiveTo is null)
			--//If count<>0 then Employee Is in EmployeeDepartment	
			If @Count<>0
			Begin --//Count
				Select @DepartmentId=DepartmentId,@DesignationId=DepartmentDesignationId,@LevelRank=LevelRank,@ChargeOutRate=ChargeOutRate 
				From HR.EmployeeDepartment 
				Where EmployeeId=@EmployeeId And EffectiveFrom <= @TimLogTaskDate and (@TimLogTaskDate <= EffectiveTo  or EffectiveTo is null)
			--//Check The Employee task in TimeLog Schedule 
				If Exists (Select * From common.TimeLogSchedule 
									Where EmployeeId=@EmployeeId And CaseId=@CaseId And DepartmentId=@DepartmentId And DesignationId=@DesignationId And Isnull(Level,0)=Isnull(@LevelRank,0) And Isnull(ChargeoutRate,0)=Isnull(@ChargeOutRate,0))
				Begin --// Exists TimLogSchdl
					Select @TimeLogSchedulId=Id From common.TimeLogSchedule 
							Where EmployeeId=@EmployeeId And CaseId=@CaseId And DepartmentId=@DepartmentId And DesignationId=@DesignationId And Isnull(Level,0)=Isnull(@LevelRank,0) And coalesce(ChargeoutRate,'Null')=Coalesce(@ChargeOutRate,'Null')
					--Set @TimelogHours_Tics = Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(@TimLogTaskHours,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint) 
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
					Declare @ActualCost Decimal(18,7)= Round(Cast(@TimelogHours_Tics/600000000 As int) * (cast(@ChargeoutRate As float) /60),4)
					--Declare @ActualCost Decimal(18,7)=Cast(CASE WHEN Cast(@TimelogHours_Tics/600000000 As int) >= 60 THEN
					--												Cast(Cast(@TimelogHours_Tics/600000000 As int) / 60 As Varchar) + '.' +
					--												Case When (Cast(@TimelogHours_Tics/600000000 As int) % 60) < 10 Then
					--												'0'+Cast (Cast (@TimelogHours_Tics/600000000 As int) % 60 As varchar) 
					--												Else
					--												Cast(Cast(@TimelogHours_Tics/600000000 As int) % 60 As varchar)
					--												End
					--												Else
					--												Cast( Cast (@TimelogHours_Tics/600000000 As int) % 60  As varchar) End As Decimal(18,7)) * @ChargeoutRate
					Insert Into Common.TimeLogSchedule (Id,CaseId,DepartmentId,DesignationId,EmployeeId,Level,ChargeoutRate,ActualHours,ActualCost,CreatedDate,Status)
									Values(@NewId,@CaseId,@DepartmentId,@DesignationId,@EmployeeId,@LevelRank,@ChargeOutRate,@TimelogHours_Tics,@ActualCost,GETDATE(),1)
				
					Update Common.TimeLogDetail Set TimeLogScheduleId=@NewId Where Id=@TimeLogTaskId
				End --//Else Exists TimLogSchdl
			End --//Count
			Fetch Next From TimeLogId_Csr Into @TimeLogId,@TimeLogTaskId,@TimLogTaskDate,@TimLogTaskHours
			End --// Cursor 3
			 Close TimeLogId_Csr; --// Cursor 3
			 Deallocate TimeLogId_Csr; --// Cursor 3
			
			--Update Common.TimeLogDetail Set TimeLogScheduleId=null where Duration='00:00:00.0000000'
			-- delete Common.TimeLogSchedule  not in  Common.TimeLogDetail
			DELETE from  Common.TimeLogSchedule where  Id  Not in  ( Select  TimeLogScheduleId from Common.TimeLogDetail WHERE TimeLogScheduleId IS NOT NULL)

			Begin
			Declare @Sc_Id uniqueidentifier,
					@Actl_Hours Bigint,
					@StartDate datetime2,
					@EndDate Datetime2
				Declare TimLg_Schd Cursor For 
				Select TLS.Id from Common.TimeLogSchedule As TLS
				Inner Join Common.TimeLogDetail As TLD on TLD.TimeLogScheduleId=TLS.Id Where TLS.CaseId=@CaseId
				Open TimLg_Schd
				Fetch Next From TimLg_Schd Into @Sc_Id
				While @@FETCH_STATUS=0
				Begin
					Select @StartDate=MIN(Date),@EndDate=MAX(Date) from Common.TimeLogDetail Where TimeLogScheduleId=@Sc_Id And Duration <> '00:00:00.0000000'
					Set @Actl_Hours=(Select Sum(Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(Duration,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)) from Common.TimeLogDetail where TimeLogScheduleId=@Sc_Id)
					Update Common.TimeLogSchedule Set ActualHours=@Actl_Hours,
																StartDate=@StartDate,EndDate=@EndDate,
																ActualCost=Round(Cast(@Actl_Hours/600000000 As int) * (cast(ChargeoutRate As float) /60),4)
																--CASE WHEN Cast((@Actl_Hours)/600000000 As int) >= 60 THEN
																--		Cast(Cast((@Actl_Hours)/600000000 As int) / 60 As Varchar) + '.' +
																--		Case When (Cast((@Actl_Hours)/600000000 As int) % 60) < 10 Then
																--		'0'+Cast (Cast ((@Actl_Hours)/600000000 As int) % 60 As varchar) 
																--		Else
																--		Cast(Cast((@Actl_Hours)/600000000 As int) % 60 As varchar)
																--		End
																--		Else
																--		Cast( Cast ((@Actl_Hours)/600000000 As int) % 60  As varchar) End * ChargeoutRate
																		Where Id=@Sc_Id
			
					Fetch Next From TimLg_Schd Into @Sc_Id
				End
				Close TimLg_Schd
				Deallocate TimLg_Schd
		
		End
		Fetch Next From Case_IdCsr Into @CaseId
		End
		Close Case_IdCsr --// cursor2
		Deallocate Case_IdCsr --// cursor2

	Fetch Next From EmpId_Dist Into @EmployeeId
	End
Close EmpId_Dist --// cursor1
Deallocate EmpId_Dist --// cursor1
	


End
GO
