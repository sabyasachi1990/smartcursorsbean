USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[NewYear_Calenar_Holidays_Insertion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [Common].[NewYear_Calenar_Holidays_Insertion]
As
BEGIN
declare @comapnyId bigint=0

declare calendar_migration cursor for select Id from common.company where parentId is null and jurisdiction = 'Singapore'
open calendar_migration
fetch next from calendar_migration into @comapnyId
while @@FETCH_STATUS = 0
Begin
    print @comapnyId
	Begin 
	if not Exists(select * from Common.Calender where CompanyId=@comapnyId and Name='New Year’s Day' and FromDateTime='2021-01-01 09:00:00.0000000' and ToDateTime='2021-01-01 18:00:00.0000000')     --New Year’s Day  1 Jan 2020  
	begin 
	insert into Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status)  --1 Jan 2020 
	values(NEWID(),@comapnyId,'Holidays','New Year’s Day ','2021-01-01 09:00:00.0000000','2021-01-01 18:00:00.0000000','08:00','All','Non-Working',NULL,NULL,'System',(select GETDATE()),NULL,NULL,NULL,1)
	end
	end

	Begin 
	if not Exists(select * from Common.Calender where CompanyId=@comapnyId and Name='Chinese New Year'  and FromDateTime='2021-02-12 09:00:00.0000000' and ToDateTime='2021-02-13 18:00:00.0000000')   ---- Chinese New Year  25 Jan 2020  ,26 Jan 2020
	begin
	insert into Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status)
	values(NEWID(),@comapnyId,'Holidays','Chinese New Year','2021-02-12 09:00:00.0000000','2021-02-13 18:00:00.0000000','08:00','All','Non-Working',NULL,NULL,'System',(select GETDATE()),NULL,NULL,NULL,1)
	end
	end

	Begin 
	if not Exists(select * from Common.Calender where CompanyId=@comapnyId and Name='Good Friday'  and FromDateTime='2021-04-02 09:00:00.0000000' and ToDateTime='2021-04-02 18:00:00.0000000')  -- Good Friday  10 Apr 2020
	begin
	insert into Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status)
	values(NEWID(),@comapnyId,'Holidays','Good Friday','2021-04-02 09:00:00.0000000','2021-04-02 18:00:00.0000000','08:00','All','Non-Working',NULL,NULL,'System',(select GETDATE()),NULL,NULL,NULL,1)
	end
	end

	Begin 
	if not Exists(select * from Common.Calender where CompanyId=@comapnyId and Name='Labour Day'  and FromDateTime='2021-05-01 09:00:00.0000000' and ToDateTime='2021-05-01 18:00:00.0000000')  --- Labour Day  1 May 2020
	begin
	insert into Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status)
	values(NEWID(),@comapnyId,'Holidays','Labour Day','2021-05-01 09:00:00.0000000','2021-05-01 18:00:00.0000000','00:00','All','Non-Working',NULL,NULL,'System',(select GETDATE()),NULL,NULL,NULL,1)
	end
	end

	Begin 
	if not Exists(select * from Common.Calender where CompanyId=@comapnyId and Name='Hari Raya Puasa'  and FromDateTime='2021-05-13 09:00:00.0000000' and ToDateTime='2021-05-13 18:00:00.0000000')   ---- Hari Raya Puasa  24 May 2020*
	begin
	insert into Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status)
	values(NEWID(),@comapnyId,'Holidays','Hari Raya Puasa','2021-05-13 09:00:00.0000000','2021-05-13 18:00:00.0000000','08:00','All','Non-Working',NULL,NULL,'System',(select GETDATE()),NULL,NULL,NULL,1)
	end
	end

	Begin 
	if not Exists(select * from Common.Calender where CompanyId=@comapnyId and Name='Vesak Day'  and FromDateTime='2021-05-26 09:00:00.0000000' and ToDateTime='2021-05-26 18:00:00.0000000')   --Vesak Day  7 May 2020	
	begin
	insert into Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status)
	values(NEWID(),@comapnyId,'Holidays','Vesak Day','2021-05-26 09:00:00.0000000','2021-05-26 18:00:00.0000000','08:00','All','Non-Working',NULL,NULL,'System',(select GETDATE()),NULL,NULL,NULL,1)
	end
	end

	Begin 
	if not Exists(select * from Common.Calender where CompanyId=@comapnyId and Name='Hari Raya Haji'  and FromDateTime='2021-07-20 09:00:00.0000000' and ToDateTime='2021-07-20 18:00:00.0000000') --Hari Raya Haji  31 July 2020
	begin
	insert into Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status)
	values(NEWID(),@comapnyId,'Holidays','Hari Raya Haji','2021-07-20 09:00:00.0000000','2021-07-20 18:00:00.0000000','08:00','All','Non-Working',NULL,NULL,'System',(select GETDATE()),NULL,NULL,NULL,1)
	end
	end

	Begin 
	if not Exists(select * from Common.Calender where CompanyId=@comapnyId and Name='National Day'  and FromDateTime='2021-08-09 09:00:00.0000000' and ToDateTime='2021-08-09 18:00:00.0000000')  ---- National Day  9 Aug 2020*
	begin
	insert into Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status)
	values(NEWID(),@comapnyId,'Holidays','National Day','2021-08-09 09:00:00.0000000','2021-08-09 18:00:00.0000000','08:00','All','Non-Working',NULL,NULL,'System',(select GETDATE()),NULL,NULL,NULL,1)
	end
	end

	Begin 
	if not Exists(select * from Common.Calender where CompanyId=@comapnyId and Name='Deepavali'  and FromDateTime='2021-11-04 09:00:00.0000000' and ToDateTime='2021-11-04 18:00:00.0000000')  --- Deepavali  14 Nov 2020
	begin
	insert into Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status)
	values(NEWID(),@comapnyId,'Holidays','Deepavali','2021-11-04 09:00:00.0000000','2021-11-04 18:00:00.0000000','08:00','All','Non-Working',NULL,NULL,'System',(select GETDATE()),NULL,NULL,NULL,1)
	end
	end

	Begin 
	if not Exists(select * from Common.Calender where CompanyId=@comapnyId and Name='Christmas Day'  and FromDateTime='2021-12-25 09:00:00.0000000' and ToDateTime='2021-12-25 18:00:00.0000000')  ---  Christmas Day  25 Dec 2020
	begin
	insert into Common.Calender(Id,CompanyId,CalendarType,Name,FromDateTime,ToDateTime,NoOfHours,ApplyTo,ChargeType,Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status)
	values(NEWID(),@comapnyId,'Holidays','Christmas Day','2021-12-25 09:00:00.0000000','2021-12-25 18:00:00.0000000','00:00','All','Non-Working',NULL,NULL,'System',(select GETDATE()),NULL,NULL,NULL,1)
	end
	end
	exec [dbo].[CALENDAR_TO_TIMELOGITEM_INSETTION] @comapnyId
	fetch next from calendar_migration into @comapnyId
end
close calendar_migration
deallocate calendar_migration

END
















GO
