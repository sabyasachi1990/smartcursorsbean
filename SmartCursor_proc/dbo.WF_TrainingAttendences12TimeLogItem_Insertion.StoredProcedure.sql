USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_TrainingAttendences12TimeLogItem_Insertion]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- >> EXEC [dbo].[WF_TrainingAttendences12TimeLogItem_Insertion] '5373dfc9-0432-42d7-b64c-b6f7063c09fd'

CREATE PROCEDURE [dbo].[WF_TrainingAttendences12TimeLogItem_Insertion] @TrainingId uniqueidentifier

AS
BEGIN

BEGIN TRANSACTION
 BEGIN TRY

      DECLARE @EmployeeId1 uniqueidentifier,
              @Date1 datetime,
              @AttendanceDate1 datetime

      SELECT @EmployeeId1 = EmployeeId, @AttendanceDate1 = AttendanceDate
      FROM HR.TrainingAttendance(NOLOCK)
      WHERE TrainingId = @TrainingId
     
	 DECLARE Trainer_Cursor CURSOR FOR

      SELECT EmployeeId, AttendanceDate
      FROM Hr.TrainingAttendance(NOLOCK)
      WHERE TrainingId = @TrainingId 
	  
	 OPEN Trainer_Cursor

      FETCH NEXT FROM Trainer_Cursor INTO @EmployeeId1, @AttendanceDate1
      WHILE @@FETCH_STATUS = 0
      BEGIN

        SET @Date1 = @AttendanceDate1

        UPDATE Common.TimeLogItem
        SET FirstHalfToTime = NULL,
            FirstHalfFromTime = NULL,
            FirstHalfTotalHours = NULL,
            Hours = 0,
            SecondHalfFromTime = NULL,
            SecondHalfToTime = NULL,
            SecondHalfTotalHours = NULL
        FROM common.TimeLogItem AS TL  
        JOIN Common.TimeLogItemDetail AS TLD (NOLOCK)
          ON TL.Id = TLD.TimeLogItemId
        WHERE TL.SystemId = @TrainingId AND TLD.EmployeeId = @EmployeeId1 AND CONVERT(date, TL.StartDate) = CONVERT(date, @Date1)

        FETCH NEXT FROM Trainer_Cursor INTO @EmployeeId1, @AttendanceDate1
      END
      CLOSE Trainer_Cursor
      DEALLOCATE Trainer_Cursor


      DECLARE @EmployeeId uniqueidentifier,
              @AttendanceDate datetime

      DECLARE Training_Cursor CURSOR FOR
      SELECT
        EmployeeId,
        AttendanceDate
      FROM Hr.TrainingAttendance(NOLOCK)
      WHERE TrainingId = @TrainingId

      OPEN Training_Cursor
      FETCH NEXT FROM Training_Cursor INTO @EmployeeId, @AttendanceDate
      WHILE @@FETCH_STATUS = 0
      BEGIN

        DECLARE @Date datetime,
                @hours decimal(17, 2),
                @newId uniqueidentifier,
                @FirstHalfFromTime time(7),
                @FirstHalfToTime time(7),
                @FirstHalfTotalHours time(7),
                @SecondHalfFromTime time(7),
                @SecondHalfToTime time(7),
                @SecondHalfTotalHours time(7),
                @FirstHalfTotalHours1 decimal(17, 2),
                @SecondHalfTotalHours1 decimal(17, 2),
                @totalhours time(7),
                @sethours nvarchar(50),
                @setFirsthours nvarchar(50),
                @setSecondhours nvarchar(50)

        SELECT
          @FirstHalfFromTime = FirstHalfFromTime,
          @FirstHalfToTime = FirstHalfToTime,
          @FirstHalfTotalHours = FirstHalfTotalHours,
          @SecondHalfFromTime = SecondHalfFromTime,
          @SecondHalfToTime = SecondHalfToTime,
          @SecondHalfTotalHours = SecondHalfTotalHours
        FROM Hr.TrainingSchedule AS TS (NOLOCK)
        JOIN Hr.Training AS TR (NOLOCK)
          ON TS.TrainingId = TR.Id
        WHERE TS.TrainingId = @TrainingId AND TrainingDate = @AttendanceDate

        DECLARE @AmAttended bit,  @PmAttended bit

        SELECT
          @AmAttended = AMAttended, @PmAttended = PMAttended
        FROM HR.TrainingAttendance AS TA (NOLOCK)
        JOIN HR.Training AS TR (NOLOCK)
          ON Ta.TrainingId = TR.Id
        WHERE Ta.TrainingId = @TrainingId
        AND CONVERT(date, AttendanceDate) = CONVERT(date, @AttendanceDate)
        AND EmployeeId = @EmployeeId


        --SET @totalhours = DATEADD(SECOND, DATEDIFF(SECOND, 0, @FirstHalfTotalHours), @SecondHalfTotalHours)
        --SET @sethours = LEFT(@totalhours, 5)
        --SET @sethours = REPLACE(@sethours, ':', '.')
        --SET @hours = CONVERT(decimal(17, 2), @sethours)
        --SET @setFirsthours = LEFT(@FirstHalfTotalHours, 5)
        --SET @setFirsthours = REPLACE(@setFirsthours, ':', '.')
        --SET @FirstHalfTotalHours1 = CONVERT(decimal(17, 2), @setFirsthours)
        --SET @setSecondhours = LEFT(@SecondHalfTotalHours, 5)
        --SET @setSecondhours = REPLACE(@setSecondhours, ':', '.')
        --SET @SecondHalfTotalHours1 = CONVERT(decimal(17, 2), @setSecondhours)

		SET @FirstHalfTotalHours1 =  CAST(REPLACE(LEFT(@FirstHalfTotalHours, 5), ':', '.' ) AS Decimal(17,2))
		SET @SecondHalfTotalHours1 =  CAST(REPLACE(LEFT(@SecondHalfTotalHours, 5), ':', '.' ) AS Decimal(17,2))
		SET @hours =  CAST(REPLACE(LEFT(DATEADD(SECOND,DATEDIFF(SECOND,0,@FirstHalfTotalHours), @SecondHalfTotalHours),5), ':', '.' ) AS Decimal(17,2))



        SET @Date = @AttendanceDate

        
        IF (@AmAttended = 1 AND (@PmAttended = 0 OR @PmAttended IS NULL))

        BEGIN

          UPDATE Common.TimeLogItem
          SET FirstHalfToTime = @FirstHalfToTime,
              FirstHalfFromTime = @FirstHalffromTime,
              FirstHalfTotalHours = @FirstHalfTotalHours,
              [Hours] = @hours,
              ActualHours = @FirstHalfTotalHours1
          FROM common.TimeLogItem AS TL
          JOIN Common.TimeLogItemDetail AS TLD (NOLOCK)
            ON TL.Id = TLD.TimeLogItemId
          WHERE TL.SystemId = @TrainingId
          AND TLD.EmployeeId = @EmployeeId
          AND CONVERT(date, TL.StartDate) = CONVERT(date, @Date)

        END

        IF (@AmAttended = 1 AND @PmAttended = 1)
        BEGIN

          UPDATE Common.TimeLogItem
          SET FirstHalfToTime = @FirstHalfToTime,
              FirstHalfFromTime = @FirstHalffromTime,
              FirstHalfTotalHours = @FirstHalfTotalHours,
              [Hours] = @hours,
              SecondHalfFromTime = @SecondHalfFromTime,
              SecondHalfToTime = @SecondHalfToTime,
              SecondHalfTotalHours = @SecondHalfTotalHours,
              ActualHours = @hours
          FROM common.TimeLogItem AS TL
          JOIN Common.TimeLogItemDetail AS TLD (NOLOCK)
            ON TL.Id = TLD.TimeLogItemId
          WHERE TL.SystemId = @TrainingId
          AND TLD.EmployeeId = @EmployeeId
          AND CONVERT(date, TL.StartDate) = CONVERT(date, @Date)
        END


        IF ((@AmAttended = 0 OR @AmAttended IS NULL)  AND @PmAttended = 1)
        BEGIN
          UPDATE Common.TimeLogItem
          SET SecondHalfToTime = @SecondHalfToTime,
              SecondHalfFromTime = @SecondHalffromTime,
              SecondHalfTotalHours = @secondHalfTotalHours,
              ActualHours = @SecondHalfTotalHours1,
              [Hours] = @hours
          FROM common.TimeLogItem AS TL 
          JOIN Common.TimeLogItemDetail AS TLD (NOLOCK)
            ON TL.Id = TLD.TimeLogItemId
          WHERE TL.SystemId = @TrainingId
          AND TLD.EmployeeId = @EmployeeId
          AND CONVERT(date, TL.StartDate) = CONVERT(date, @Date)

        END


        IF ((@AmAttended IS NULL AND @PmAttended IS NULL) OR (@AmAttended = 0 AND @PmAttended = 0) OR (@AmAttended IS NULL AND @PmAttended = 0)
          OR (@AmAttended = 0 AND @PmAttended IS NULL))
        BEGIN
          UPDATE Common.TimeLogItem
          SET FirstHalfToTime = NULL,
              FirstHalfFromTime = NULL,
              FirstHalfTotalHours = NULL,
              [Hours] = 0,
              SecondHalfFromTime = NULL,
              SecondHalfToTime = NULL,
              SecondHalfTotalHours = NULL,
              ActualHours = NULL
          FROM common.TimeLogItem AS TL 
          JOIN Common.TimeLogItemDetail AS TLD (NOLOCK)
            ON TL.Id = TLD.TimeLogItemId
          WHERE TL.SystemId = @TrainingId
          AND TLD.EmployeeId = @EmployeeId
          AND CONVERT(date, TL.StartDate) = CONVERT(date, @Date)
        END

        FETCH NEXT FROM Training_Cursor INTO @EmployeeId, @AttendanceDate
      END
      CLOSE Training_Cursor
      DEALLOCATE Training_Cursor
COMMIT TRANSACTION 	  
END TRY


  BEGIN CATCH
  ROLLBACK TRANSACTION;

    PRINT 'In Catch Block';
	

  Throw:

  END CATCH
END
GO
