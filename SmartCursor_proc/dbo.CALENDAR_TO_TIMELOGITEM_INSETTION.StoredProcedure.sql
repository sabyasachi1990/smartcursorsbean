USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CALENDAR_TO_TIMELOGITEM_INSETTION]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CALENDAR_TO_TIMELOGITEM_INSETTION](@NEW_COMPANYID BIGINT)
AS
BEGIN
BEGIN TRANSACTION
BEGIN TRY
declare @companyId bigint
declare Company_Cursor cursor for (select Id from Common.Company where ParentId is null and Jurisdiction='Singapore' and Id=@NEW_COMPANYID) 
open Company_Cursor
fetch next from Company_Cursor into @companyId
while @@FETCH_STATUS > -1   
BEGIN  
    print 'company Id' 
    print @companyId
    print '-------------------------------'
    declare @CalendarId uniqueidentifier
    declare Calendar_Item_Cursor cursor for (select Id from Common.Calender where CompanyId=@companyId and DATEPART(year, FromDateTime) = '2024' and CalendarType='Holidays' and ChargeType='Non-Working') 
	print  'Enter into Calendar_Item_Cursor'
    open Calendar_Item_Cursor
    fetch next from Calendar_Item_Cursor into @CalendarId
    while @@FETCH_STATUS > -1   
    BEGIN  
        declare @days int
        declare @newid uniqueidentifier = newid()
        print 'Calendar Id :-----' 
        --=================== PARENT - TIME LOG ITEM INSERTION ================================

        if not exists (select * from Common.TimeLogItem where CompanyId=@companyId and SystemId=@CalendarId and Type='Holidays')
        BEGIN
             print @CalendarId
             set @days = (select DATEDIFF(DAY,(select Convert(date,FromDateTime) from Common.Calender where Id=@CalendarId and CompanyId=@companyId), (select Convert(date,ToDateTime) from Common.Calender where Id=@CalendarId and CompanyId=@companyId))+1)
             print @days
             insert into Common.TimeLogItem (Id, CompanyId, Type, SubType, ChargeType, SystemType, SystemId, IsSystem, ApplyToAll, StartDate, EndDate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, Hours, Days, FirstHalfFromTime, FirstHalfToTime, FirstHalfTotalHours, SecondHalfFromTime, SecondHalfToTime, SecondHalfTotalHours, IsMain, TimeType)
             select @newid as Id,@companyId as CompanyId ,'Holidays' as [Type],(select Name from Common.Calender where Id=@CalendarId and CompanyId=@companyId) as SubType,'Non-Working' as ChargeType,'Calender' as SystemType,@CalendarId as SystemId,1 as IsSystem,1 as ApplyToAll,(select FromDateTime from Common.Calender where Id=@CalendarId and CompanyId=@companyId) as StartDate, (select ToDateTime from Common.Calender where Id=@CalendarId and CompanyId=@companyId) as EndDate, null as Remarks,null as RecOrder,'System' as UserCreated,GETUTCDATE() as CreatedDate,null as ModifiedBy,null as ModifiedDate,null as [Version],1 as [Status],/*(select DefaultWorkingHours * @days from Common.Localization where CompanyId=@companyId)*/ 8*@days as [Hours],@days as [Days],null as[FirstHalfFromTime],null as [FirstHalfToTime],null as [FirstHalfTotalHours],null as SecondHalfFromTime,null as SecondHalfToTime,null as SecondHalfTotalHours,1 as IsMain, null as TimeType
			Print 'Insertion Completed'
        END
        ELSE
        BEGIN
            set @newid = (select Id from Common.TimeLogItem where CompanyId=@companyId and SystemId=@CalendarId and Type='Holidays')
        END
        --==================== CHILD - TIME LOG ITEMS INSERTION ================================

		DECLARE @HOURS BIGINT = 8 --(SELECT DefaultWorkingHours FROM Common.Localization WHERE CompanyId=@companyId)
        DECLARE @HOLIDAY_ST_DATE DATETIME2(7) = (SELECT StartDate FROM Common.TimeLogItem WHERE iD=@newid)
        DECLARE @HOLIDAY_END_DATE DATETIME2(7) = (SELECT EndDate FROM Common.TimeLogItem WHERE iD=@newid)
        DECLARE @DATE_CALENDAR DATETIME2(7)
        DECLARE DATES_CURSOR CURSOR FOR
        WITH mycte AS
        (
            SELECT CAST(@HOLIDAY_ST_DATE AS DATETIME) DateValue
            UNION ALL
            SELECT  DateValue + 1
            FROM    mycte   
            WHERE   DateValue + 1 <= @HOLIDAY_END_DATE
        ) SELECT DateValue FROM mycte OPTION (MAXRECURSION 0)
        OPEN DATES_CURSOR
        FETCH NEXT FROM DATES_CURSOR INTO @DATE_CALENDAR
        while @@FETCH_STATUS > -1   
        BEGIN  
            PRINT @DATE_CALENDAR
            DECLARE @IS_WORKING_DAY BIT = (SELECT IsWorkingDay FROM Common.WorkWeekSetUp WHERE CompanyId=@companyId AND WEEKDAY = (SELECT DATENAME(WEEKDAY,CONVERT(date,@DATE_CALENDAR))) and EmployeeId is null)

            IF EXISTS (SELECT * FROM Common.TimeLogItem WHERE SystemId=@newid AND CompanyId=@companyId AND StartDate= @DATE_CALENDAR)
            BEGIN
                UPDATE Common.TimeLogItem SET StartDate=@DATE_CALENDAR, EndDate=@DATE_CALENDAR, Hours=@HOURS WHERE ID= (SELECT Id FROM Common.TimeLogItem WHERE SystemId=@newid AND CompanyId=@companyId AND StartDate= @DATE_CALENDAR)
            END
            IF NOT EXISTS (SELECT * FROM Common.TimeLogItem WHERE SystemId=@newid AND CompanyId=@companyId AND Convert(date,StartDate)=convert(date,@DATE_CALENDAR))
            BEGIN
                insert into Common.TimeLogItem (Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,ApplyToAll,StartDate,EndDate,Remarks,RecOrder, UserCreated,CreatedDate,ModifiedBy,ModifiedDate, Version, Status,Hours,Days,FirstHalfFromTime,FirstHalfToTime, FirstHalfTotalHours,SecondHalfFromTime,SecondHalfToTime,SecondHalfTotalHours, IsMain, TimeType)
                select NEWID(),CompanyId,Type,SubType,ChargeType,SystemType,@newid,IsSystem,ApplyToAll,@DATE_CALENDAR,@DATE_CALENDAR,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,@HOURS,Days,'09:00:00.0000000','13:00:00.0000000','04:00:00.0000000','14:00:00.0000000','18:00:00.0000000','04:00:00.0000000',0, 'Full' from Common.TimeLogItem where Id = @newid
            END
            IF EXISTS (SELECT * FROM Common.TimeLogItem WHERE SystemId=@newid AND CompanyId=@companyId AND Convert(date,StartDate)=convert(date,@DATE_CALENDAR))
            BEGIN
                IF(@IS_WORKING_DAY = 0)  -- non working
				BEGIN
              	   UPDATE Common.TimeLogItem SET StartDate=@DATE_CALENDAR, EndDate=@DATE_CALENDAR, Hours=0.00, Days=0.00, 
                   FirstHalfFromTime= '00:00:00.0000000',FirstHalfToTime='00:00:00.0000000', FirstHalfTotalHours= '00:00:00.0000000',
				   SecondHalfFromTime= '00:00:00.0000000',SecondHalfToTime= '00:00:00.0000000',SecondHalfTotalHours ='00:00:00.0000000' 
				   WHERE ID= (SELECT Id FROM Common.TimeLogItem WHERE SystemId=@newid AND CompanyId=@companyId AND Convert(date,StartDate)=convert(date,@DATE_CALENDAR))
				END
				ELSE IF(@IS_WORKING_DAY = 1) -- working
				BEGIN

			Declare @TimeType NVARCHAR(10)=(select timeType from Common.TimeLogItem WHERE ID= (SELECT Id FROM Common.TimeLogItem WHERE SystemId=@newid AND CompanyId=@companyId AND Convert(date,StartDate)=convert(date,@DATE_CALENDAR)))


              	   UPDATE Common.TimeLogItem SET StartDate=@DATE_CALENDAR, EndDate=@DATE_CALENDAR, Hours=(case when (@TimeType='AM' or @TimeType='PM') then 4 else @HOURS end), Days=1, 
                   FirstHalfFromTime= '09:00:00.0000000',FirstHalfToTime='13:00:00.0000000', FirstHalfTotalHours= '04:00:00.0000000',
				   SecondHalfFromTime= '14:00:00.0000000',SecondHalfToTime= '18:00:00.0000000',SecondHalfTotalHours ='04:00:00.0000000' 
				   WHERE ID= (SELECT Id FROM Common.TimeLogItem WHERE SystemId=@newid AND CompanyId=@companyId AND Convert(date,StartDate)=convert(date,@DATE_CALENDAR))
				END
            END
        FETCH NEXT FROM DATES_CURSOR INTO @DATE_CALENDAR
        END
 
        CLOSE DATES_CURSOR
        DEALLOCATE DATES_CURSOR
        
        IF EXISTS (SELECT * FROM Common.TimeLogItem WHERE Id=@newid AND CompanyId=@companyId)
		BEGIN
			IF NOT EXISTS (SELECT * FROM Common.TimeLogItem WHERE SystemId=@newid AND (Hours != 0.00 OR Hours!=0))
			BEGIN
				UPDATE Common.TimeLogItem SET Hours=0.00 WHERE ID=@newid AND CompanyId=@companyId
				UPDATE Common.Calender SET NoOfHours=00.00 where Id=@CalendarId AND CompanyId=@companyId
			END
			ELSE IF EXISTS (SELECT * FROM Common.TimeLogItem WHERE SystemId=@newid AND (Hours != 0.00 OR Hours!=0))
			BEGIN
			--Commented on 17-11-2021 by priyanka 
				--DECLARE @NO_OF_DAYS INT = (SELECT COUNT(*) FROM Common.TimeLogItem WHERE SystemId=@newid AND (Hours != 0.00 OR Hours!=0))
				--UPDATE Common.TimeLogItem SET Hours = (@NO_OF_DAYS * @HOURS) WHERE ID=@newid AND CompanyId=@companyId
				--UPDATE Common.Calender SET NoOfHours=(@NO_OF_DAYS * @HOURS) where Id=@CalendarId AND CompanyId=@companyId

				UPDATE Common.TimeLogItem SET Hours = (SELECT sum(Hours) FROM Common.TimeLogItem WHERE SystemId=@newid AND (Hours != 0.00 OR Hours!=0)) WHERE ID=@newid AND CompanyId=@companyId
				UPDATE Common.Calender SET NoOfHours=(SELECT sum(Hours) FROM Common.TimeLogItem WHERE SystemId=@newid AND (Hours != 0.00 OR Hours!=0)) where Id=@CalendarId AND CompanyId=@companyId

			END
		END
     
    fetch next from Calendar_Item_Cursor into @CalendarId
    END
    CLOSE Calendar_Item_Cursor
    DEALLOCATE Calendar_Item_Cursor
fetch next from Company_Cursor into @companyId
END
CLOSE Company_Cursor
DEALLOCATE Company_Cursor

update Common.TimeLogItem set StartDate = CONVERT(date,StartDate), EndDate=CONVERT(date,EndDate) where CompanyId=@companyId and Type='Holidays'

COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK;
END CATCH
END
GO
