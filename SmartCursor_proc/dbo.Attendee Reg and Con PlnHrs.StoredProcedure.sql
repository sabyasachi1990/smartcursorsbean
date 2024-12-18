USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Attendee Reg and Con PlnHrs]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


---->> EXEC [dbo].[Attendee Reg AND Con PlnHrs] '8550864b-ddeb-4706-8d14-7d372e36a343'

CREATE PROCEDURE [dbo].[Attendee Reg and Con PlnHrs]
@TrainingId uniqueidentifier

AS
BEGIN

BEGIN TRANSACTION
BEGIN TRY

DECLARE --@TrainingId uniqueidentifier = '45d69571-43f0-4b57-86a3-59919703f918',
@EmployeeId1 uniqueIdentifier,
@Date1 dateTime,
@AttendanceDate1 DateTime,
@EmployeeTrainigStatus nvarchar(50),
@TrainigStatus nvarchar(50)


SELECT @EmployeeId1=EmployeeId, @AttendanceDate1=AttendanceDate 
FROM HR.TrainingAttendance (NOLOCK) 
WHERE TrainingId=@TrainingId

DECLARE @EmployeeId uniqueIdentifier, @AttendanceDate DateTime

DECLARE Attendee_Cursor CURSOR FOR  

	SELECT a.EmployeeId,AttendanceDate,b.EmployeeTrainigStatus,c.TrainingStatus 
	FROM Hr.TrainingAttendance AS a (NOLOCK) 
	INNER JOIN hr.TrainingAttendee AS b (NOLOCK) ON b.TrainingId = a.TrainingId  AND B.EmployeeId = A.EmployeeId
	INNER JOIN hr.Training AS c (NOLOCK) ON c.Id = b.TrainingId
	WHERE a.TrainingId = @TrainingId --AND A.EmployeeId = 'C928FDEA-CF3A-45A7-B4C3-CBFB80E171B5'

OPEN Attendee_Cursor
FETCH NEXT FROM Attendee_Cursor INTO @EmployeeId, @AttendanceDate,@EmployeeTrainigStatus,@TrainigStatus
WHILE @@FETCH_STATUS=0
BEGIN

DECLARE 
@Date DateTime,
@hours decimal(17,2),
@newId UniqueIdentifier,
@FirstHalfFromTime Time(7),
@FirstHalfToTime Time(7),
@FirstHalfTotalHours time(7),
@SecondHalfFromTime time(7),
@SecondHalfToTime time(7),
@SecondHalfTotalHours time(7),	
@FirstHalfTotalHours1 decimal(17,2),
@SecondHalfTotalHours1 decimal(17,2),
@totalhours time(7),
@sethours nvarchar(50),
@setFirsthours nvarchar(50),
@setSecondhours nvarchar(50)
                
SELECT 
	@FirstHalfFromTime= FirstHalfFromTime,@FirstHalfToTime=FirstHalfToTime ,@FirstHalfTotalHours=FirstHalfTotalHours ,
	@SecondHalfFromTime= SecondHalfFromTime ,@SecondHalfToTime= SecondHalfToTime ,@SecondHalfTotalHours = SecondHalfTotalHours  
FROM Hr.TrainingSchedule AS TS (NOLOCK) 
JOIN Hr.Training AS TR (NOLOCK) ON TS.TrainingId=TR.Id 
WHERE TS.TrainingId=@TrainingId AND TrainingDate=@AttendanceDate


DECLARE   @AmAttended bit,@PmAttended bit 

SELECT
	@AmAttended = AMAttended ,
	@PmAttended=PMAttended 
FROM HR.TrainingAttendance AS TA (NOLOCK) 
JOIN HR.Training AS TR (NOLOCK) 
ON Ta.TrainingId=TR.Id 
WHERE Ta.TrainingId=@TrainingId AND  CONVERT(Date,AttendanceDate)= CONVERT(Date,@AttendanceDate) AND EmployeeId=@EmployeeId


--SET @totalhours =dateadd(second,datediff(second,0,@FirstHalfTotalHours),@SecondHalfTotalHours)
--SET @sethours=LEFT(@totalhours, 5)
--SET @sethours=REPLACE(@sethours, ':', '.' )
--SET @hours =CONVERT(DECIMAL(17,2),@sethours)
--SET @setFirsthours=LEFT(@FirstHalfTotalHours, 5)
--SET @setFirsthours=REPLACE(@setFirsthours, ':', '.' )
--SET @FirstHalfTotalHours1=CONVERT(DECIMAL(17,2),@setFirsthours)
--SET @setSecondhours=LEFT(@SecondHalfTotalHours, 5)
--SET @setSecondhours=REPLACE(@setSecondhours, ':', '.' )
--SET @SecondHalfTotalHours1=CONVERT(DECIMAL(17,2),@setSecondhours)

SET @FirstHalfTotalHours1 =  CAST(REPLACE(LEFT(@FirstHalfTotalHours, 5), ':', '.' ) AS Decimal(17,2))
SET @SecondHalfTotalHours1 =  CAST(REPLACE(LEFT(@SecondHalfTotalHours, 5), ':', '.' ) AS Decimal(17,2))
SET @hours =  CAST(REPLACE(LEFT(DATEADD(SECOND,DATEDIFF(SECOND,0,@FirstHalfTotalHours), @SecondHalfTotalHours),5), ':', '.' ) AS Decimal(17,2))


SET @Date=@AttendanceDate

IF (@EmployeeTrainigStatus ='Registered' AND @TrainigStatus= 'Confirmed' AND ((@AmAttended is null OR @AmAttended = 0 ) AND (@PmAttended is null OR @PmAttended = 0)))
BEGIN



	update Common.TimeLogItem SET FirstHalfToTime=@FirstHalfToTime ,FirstHalfFromTime=@FirstHalffromTime ,FirstHalfTotalHours=@FirstHalfTotalHours,
	SecondHalfToTime=@SecondHalfToTime ,SecondHalfFromTime=@SecondHalffromTime ,SecondHalfTotalHours=@secondHalfTotalHours,HOURS = @hours
	FROM common.TimeLogItem AS TL WITH (NOLOCK) JOIN Common.TimeLogItemDetail AS TLD WITH (NOLOCK) ON TL.Id=TLD.TimeLogItemId 
	WHERE TL.SystemId=@TrainingId AND TLD.EmployeeId=@EmployeeId AND TL.StartDate = @AttendanceDate


END

IF (@EmployeeTrainigStatus = 'Absent' AND @TrainigStatus ='Completed' AND ((@AmAttended is null OR @AmAttended = 0 ) AND (@PmAttended is null OR @PmAttended = 0)))
BEGIN
 

	UPDATE Common.TimeLogItem SET FirstHalfToTime=@FirstHalfToTime ,FirstHalfFromTime=@FirstHalffromTime ,FirstHalfTotalHours=@FirstHalfTotalHours,
	SecondHalfToTime=@SecondHalfToTime ,SecondHalfFromTime=@SecondHalffromTime ,SecondHalfTotalHours=@secondHalfTotalHours,HOURS = @hours
	FROM common.TimeLogItem AS TL WITH (NOLOCK) JOIN Common.TimeLogItemDetail AS TLD WITH (NOLOCK) ON TL.Id=TLD.TimeLogItemId 
	WHERE TL.SystemId=@TrainingId AND TLD.EmployeeId=@EmployeeId  AND TL.StartDate = @AttendanceDate

END


IF (@TrainigStatus = 'Cancelled')
BEGIN

	DELETE FROM Common.TimeLogItemDetail 
	WHERE TimeLogItemId IN (SELECT Id FROM Common.TimeLogItem WHERE SYSTEMID = @TrainingId) 

	DELETE FROM Common.AttendanceDetails WHERE TrainingId IN (SELECT id FROM Common.TimeLogItem (NOLOCK) WHERE SystemId = @TrainingId)

	DELETE FROM Common.TimeLogItem  WHERE SystemId IN (@TrainingId)

END


FETCH NEXT FROM Attendee_Cursor INTO @EmployeeId,@AttendanceDate,@EmployeeTrainigStatus,@TrainigStatus
END
CLOSE Attendee_Cursor
DEALLOCATE Attendee_Cursor

IF EXISTS (SELECT id FROM HR.Training (NOLOCK) WHERE Id = @TrainingId AND TrainingStatus IN ('Confirmed','Completed'))
BEGIN 

UPDATE Common.TimeLogItem SET ActualHours = Hours 
WHERE SystemId = @TrainingId AND Id IN (SELECT DISTINCT TimeLogItemId FROM Common.TimeLogItemDetail  WITH (NOLOCK)
WHERE EmployeeId NOT IN (SELECT DISTINCT EmployeeId FROM HR.TrainingAttendee WITH (NOLOCK) WHERE TrainingId = @TrainingId))

END


COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK;

	PRINT 'In Catch Block';

	THROW

END CATCH

END

GO
