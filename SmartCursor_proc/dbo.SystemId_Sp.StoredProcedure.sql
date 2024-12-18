USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SystemId_Sp]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create Procedure [dbo].[SystemId_Sp]
@CompanyId Bigint
As
Begin
-- @CompanyId Bigint=158,
Declare @TimeLogItmId Uniqueidentifier,
@SysyemId Uniqueidentifier,
@StartDate Datetime2,
@EndDate Datetime2,
@NewId Uniqueidentifier,
@IsNew Int,
@Dtime Datetime2

--// Declare Temptable store dates
Declare @Temp table(Date1 Datetime2)
--// Declare Cursor to get SystemId based On Companyid
Declare SystemId_CSR Cursor For
Select Id,SystemId,convert(Date,StartDate) As StartDate,Convert(date,EndDate) As EndDate from Common.TimeLogItem Where SystemType='Calender' And IsMain<>0 And CompanyId=@CompanyId
Open SystemId_CSR
Fetch Next From SystemId_CSR Into @TimeLogItmId,@SysyemId,@StartDate,@EndDate
While @@FETCH_STATUS=0
Begin
Begin
Delete From @Temp

;WITH Dates AS (
SELECT @StartDate as [Date]

UNION ALL 
SELECT DATEADD(DAY, 1, [Date])
FROM Dates
where Date < @EndDate
) 

Insert Into @Temp 
SELECT [Date] FROM Dates
OPTION (MAXRECURSION 4000)
End
--// Declare Cursor to pass dates one by one
Declare Date_Csr Cursor For
Select Date1 From @Temp
Open Date_Csr
Fetch Next From Date_Csr Into @Dtime
While @@FETCH_STATUS=0
Begin
Set @NewId =NEWID()
Insert Into Common.TimeLogItem	(Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,ApplyToAll,StartDate,EndDate,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Hours,Days,FirstHalfFromTime,FirstHalfToTime,SecondHalfFromTime,SecondHalfToTime,IsMain,SecondHalfTotalHours,FirstHalfTotalHours)
Select	@NewId,CompanyId,Type,SubType,ChargeType,SystemType,@TimeLogItmId,IsSystem,ApplyToAll,@Dtime,@Dtime,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate	,
Version,Status,'8.00' As Hours,1 As Days,'09:00:00.0000000 'as FirstHalfFromTime,'13:00:00.0000000' as FirstHalfToTime,'14:00:00.0000000' as	SecondHalfFromTime,'18:00:00.0000000' as SecondHalfToTime,0,'04:00:00.0000000' as SecondHalfTotalHours,'04:00:00.0000000' as FirstHalfTotalHours From	Common.TimeLogItem Where id=@TimeLogItmId and CompanyId=@Companyid and SystemType='Calender'

If Exists (Select Id From Common.Calender Where Id=@SysyemId)
Begin
Declare @CalId Uniqueidentifier
Select @CalId=Id From Common.Calender Where Id=@SysyemId

Insert Into Common.TimeLogItemDetail
Select Newid(),@NewId,EmployeeId,@isnew From Common.CalenderDetails Where MasterId=@CalId 

End

Fetch Next From Date_Csr Into @Dtime
End
Close Date_Csr
Deallocate Date_Csr

Fetch Next From SystemId_CSR Into @TimeLogItmId,@SysyemId,@StartDate,@EndDate
End
Close SystemId_CSR
Deallocate SystemId_CSR

End
GO
