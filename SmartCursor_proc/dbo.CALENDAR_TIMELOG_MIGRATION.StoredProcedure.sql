USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CALENDAR_TIMELOG_MIGRATION]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CALENDAR_TIMELOG_MIGRATION]
AS
BEGIN
declare @companyId bigint
declare Company_Cursor cursor for (select Id from Common.Company where ParentId is null and Jurisdiction='Singapore' and Id=19) 
open Company_Cursor
fetch next from Company_Cursor into @companyId
while @@FETCH_STATUS > -1   
BEGIN  
    print 'company Id' 
    print @companyId
    print '-------------------------------'
    declare @CalendarId uniqueidentifier
    declare Calendar_Item_Cursor cursor for (select Id from Common.Calender where CompanyId=@companyId and DATEPART(year, FromDateTime) = '2020' and CalendarType='Holidays' and ChargeType='Non-Working') 
    open Calendar_Item_Cursor
    fetch next from Calendar_Item_Cursor into @CalendarId
    while @@FETCH_STATUS > -1   
    BEGIN  
        declare @days int
        declare @newid uniqueidentifier = newid()
        print 'Calendar Id :-----' 
        if not exists (select * from Common.TimeLogItem where CompanyId=@companyId and SystemId=@CalendarId and Type='Holidays')
        BEGIN
             print @CalendarId
             set @days = (select DATEDIFF(DAY,(select Convert(date,FromDateTime) from Common.Calender where Id=@CalendarId and CompanyId=@companyId), (select Convert(date,ToDateTime) from Common.Calender where Id=@CalendarId and CompanyId=@companyId))+1)
             
             insert into Common.TimeLogItem (Id, CompanyId, Type, SubType, ChargeType, SystemType, SystemId, IsSystem, ApplyToAll, StartDate, EndDate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, Hours, Days, FirstHalfFromTime, FirstHalfToTime, FirstHalfTotalHours, SecondHalfFromTime, SecondHalfToTime, SecondHalfTotalHours, IsMain)
             select @newid,@companyId,'Holidays',(select Name from Common.Calender where Id=@CalendarId and CompanyId=@companyId),'Non-Working','Calender',@CalendarId,1,1,(select FromDateTime from Common.Calender where Id=@CalendarId and CompanyId=@companyId), (select ToDateTime from Common.Calender where Id=@CalendarId and CompanyId=@companyId), null,null,null,GETUTCDATE(),null,null,null,1,(select DefaultWorkingHours * @days from Common.Localization where CompanyId=@companyId),@days,null,null,null,null,null,null,1
        END
        ELSE
        BEGIN
            set @newid = (select Id from Common.TimeLogItem where CompanyId=@companyId and SystemId=@CalendarId and Type='Holidays')
        END
        if not exists (select Id from Common.TimeLogItem where SystemId=@newid)
        BEGIN
            DECLARE @HOLIDAY_ST_DATE DATETIME2(7) = (SELECT StartDate FROM Common.TimeLogItem WHERE iD=@newid)
			DECLARE @HOLIDAY_END_DATE DATETIME2(7) = (SELECT EndDate FROM Common.TimeLogItem WHERE iD=@newid)
			DECLARE @DATE_CALENDAR DATETIME2(7)
			DECLARE DATES_CURSOR CURSOR FOR
			WITH mycte AS
			(
				SELECT CAST(@HOLIDAY_ST_DATE AS DATETIME) DateValue
				UNION ALL
				SELECT  DateValue + 1
				FROM    mycte   
				WHERE   DateValue + 1 <= @HOLIDAY_END_DATE
			) SELECT DateValue FROM mycte OPTION (MAXRECURSION 0)
			OPEN DATES_CURSOR
			FETCH NEXT FROM DATES_CURSOR INTO @DATE_CALENDAR
			while @@FETCH_STATUS > -1   
			BEGIN  
				PRINT @DATE_CALENDAR
				IF EXISTS (SELECT * FROM Common.TimeLogItem WHERE SystemId=@newid AND CompanyId=@companyId)
				BEGIN
					DELETE FROM Common.TimeLogItem WHERE SystemId=@newid AND CompanyId=@companyId
				END
            	insert into Common.TimeLogItem (Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,IsSystem,ApplyToAll,StartDate,EndDate,Remarks,RecOrder, UserCreated,CreatedDate,ModifiedBy,ModifiedDate, Version, Status,Hours,Days,FirstHalfFromTime,FirstHalfToTime, FirstHalfTotalHours,SecondHalfFromTime,SecondHalfToTime,SecondHalfTotalHours, IsMain)
            	select NEWID(),CompanyId,Type,SubType,ChargeType,SystemType,@newid,IsSystem,ApplyToAll,@DATE_CALENDAR,@DATE_CALENDAR,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,Hours,Days,'09:00:00.0000000','13:00:00.0000000','04:00:00.0000000','14:00:00.0000000','18:00:00.0000000','04:00:00.0000000',0 from Common.TimeLogItem where Id = @newid
			FETCH NEXT FROM DATES_CURSOR INTO @DATE_CALENDAR
			END
 
			CLOSE DATES_CURSOR
			DEALLOCATE DATES_CURSOR
        END
    fetch next from Calendar_Item_Cursor into @CalendarId
    END
    CLOSE Calendar_Item_Cursor
    DEALLOCATE Calendar_Item_Cursor
fetch next from Company_Cursor into @companyId
END
CLOSE Company_Cursor
DEALLOCATE Company_Cursor
END
GO
