USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[AllEMPSDLCalculation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[AllEMPSDLCalculation] (@PayrollId uniqueidentifier,@PayrollStartDate datetime2(7),@ParentCompanyId bigint)
as
begin
begin try
begin transaction
	
	print 'Entered into SDL SP 1'
	declare @Recount int=1	
	declare	@Sdl money
	declare @SDLRate money 
	declare @MainSdl money=0
	declare @SDLMIn money
	declare @SDlMax money
	declare @SDlWage money
	declare @SDLAmount money	
	declare @TotalCount int 
	--declare @Recount int 
	declare @SDLTable SDL
	declare @PayrollDetailId uniqueidentifier 
	declare @PayComponentId uniqueidentifier
	declare @EmployeeId uniqueidentifier
	declare @PayType NVARCHAR(30)
	declare @Recorder int 

	INSERT INTO @SDLTable
		SELECT Id, TotalWageFrom, TotalWageTo, EffectiveFrom, EffectiveTo, SDLRate, SDLMin, SDLMax, STATUS
		FROM SmartCursorTST.HR.SDL (NOLOCK)
		WHERE EffectiveFrom <= @PayrollStartDate AND (EffectiveTo >= @PayrollStartDate OR EffectiveTo IS NULL) AND STATUS = 1
	
	CREATE TABLE #EmployeeData (S_No INT Identity(1, 1), TempPayrollMasterId UNIQUEIDENTIFIER, Employeeid UNIQUEIDENTIFIER, SDLWage money NULL,DetailId uniqueidentifier)

		INSERT INTO #EmployeeData
		SELECT MasterId, EmployeeId, SDLWage, Id
		FROM HR.PayrollDetails (NOLOCK)
		WHERE MasterId = @PayrollId and (SDLExampted=0 or SDLExampted is null)
	
	SET @TotalCount = (
				SELECT COUNT(DetailId)
				FROM #EmployeeData
				)
				print @TotalCount
				print @Recount
select @PayComponentId=Id,@PayType=Type,@Recorder=RecOrder from HR.PayComponent (NOLOCK) where CompanyId=@ParentCompanyId and Name='SDL'
	
	WHILE @TotalCount >= @Recount
		BEGIN --mm
		print 'Entered into SDL employee lopp'
	select @SDlWage=SDLWage,@PayrollDetailId=DetailId,@EmployeeId=Employeeid from #EmployeeData where S_No=@Recount

		if exists (
				select *
				from @SDLTable
				where TotalWageFrom <= @SDlWage and TotalWageTo >= @SDlWage and status = 1
				)
		begin--1
			
select @SDlMax=SDlMax,@SDLMIn=SDLMIn,@SDLRate=SDlRate
					from @SDLTable
					where TotalWageFrom <= @SDlWage and TotalWageTo >= @SDlWage and EffectiveFrom <= @PayrollStartDate and (EffectiveTo >= @PayrollStartDate or EffectiveTo is null) and status = 1



			set @MainSdl = @SDlWage * @SDLRate

			if (@MainSdl = 0 or @MainSdl is null)
			begin--2
				set @SDLAmount = 0
			end--2
			else if (@MainSdl < @SDLMIn)
			begin--3
				set @SDLAmount = @SDLMIn
			end--3
			else if (@MainSdl > @SDlMax)
			begin--4
				set @SDLAmount = @SDlMax
			end--4
			else
			begin--5
				set @SDLAmount = @MainSdl
			end--5

			update HR.PayrollDetails set SDL=@SDLAmount where id=@PayrollDetailId
			insert into HR.PayrollSplit (Id,PayrollDetailId,PayComponentId,PayType,Amount,Recorder,IsTemporary) select NEWID(),@PayrollDetailId,@PayComponentId,@PayType,@SDLAmount,@Recorder,1
			
		end --1
		set @Recount=@Recount+1
		end--mm
		IF OBJECT_ID(N'tempdb..#EmployeeData') IS NOT NULL
		BEGIN
			DROP TABLE #EmployeeData
		END
		commit transaction --s2
	end try --s3

	begin catch
		rollback transaction

		declare @ErrorMessage nvarchar(4000), @ErrorSeverity int, @ErrorState int;

		select @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		raiserror (@ErrorMessage, @ErrorSeverity, @ErrorState);
	end catch
end --1
GO
