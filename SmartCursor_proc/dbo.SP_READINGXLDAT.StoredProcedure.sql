USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_READINGXLDAT]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- exec [SP_READINGXLDAT] 19, , 'CE0D898D-7B2A-4FBE-9EDA-13D8915C4CC1', 'madhu@yopmail.com', 2019-01-28 12:35:54.0000000'

CREATE PROCEDURE [dbo].[SP_READINGXLDAT](@COMPANYID BIGINT, @FILENAME NVARCHAR(MAX),@ATTACHMENTID UNIQUEIDENTIFIER,@UPLOADEDBY NVARCHAR(100),@DATEOFUPLOAD DATETIME2(7))
AS 
 BEGIN 

  	EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1
	EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
	--CONFIGURING SQL INSTANCE TO ACCEPT ADVANCED OPTIONS
	EXEC sp_configure 'show advanced options', 1
	RECONFIGURE
	--ENABLING USE OF DISTRIBUTED QUERIES
	EXEC sp_configure 'Ad Hoc Distributed Queries', 1
	RECONFIGURE

	-- New way to read the Excel data-------------------------

	DECLARE  @T TABLE (DATEANDTIME DATETIME2(7),NAME NVARCHAR(100))
	--Declare @Route VARCHAR(4000)
	Declare @sql nvarchar(max)
	--Set @Route='D:\Appsworld.Attendance1.xlsx'
	Set @sql=' SELECT * FROM OPENROWSET(
		            ''Microsoft.ACE.OLEDB.12.0'',
		            ''Excel 12.0 xml;HDR=YES;Database=' + @FILENAME + ''',  
		            ''SELECT * FROM [Sheet1$]'')'   --'D:\Appsworld.Attendance1.xlsx' in 192.168.0.110
	--DECLARE @AttachmentTime datetime2(7) = Convert (Date,GETDATE())
	BEGIN TRY
	insert into @T
		        Exec(@sql)
	END TRY
	BEGIN CATCH

	END CATCH

	IF EXISTS(SELECT * from @T)
	BEGIN
	select * from @T

	DECLARE @ATTACHMENT_FILENAME NVARCHAR(1000) = (SELECT AttachmentPath FROM Common.AttendanceAttachments WHERE Id=@ATTACHMENTID)
	DECLARE @IS_FILE_OVERRIDDEN INT = 0
	--IF EXISTS(SELECT TOP 1 * FROM Common.AttendanceAttachments WHERE CONVERT(DATE,FromDate)=CONVERT(DATE,(select Min(CONVERT(date,DATEANDTIME)) from @T)) AND CONVERT(DATE,ToDate)=CONVERT(DATE,(select Max(Convert(date,DATEANDTIME)) from @T)) AND CompanyId=@COMPANYID ORDER BY DateOfUpload DESC)
	--BEGIN	    
	--  DELETE FROM Common.AttendanceAttachments WHERE Id=@ATTACHMENTID AND CompanyId=@COMPANYID
	--	SET @ATTACHMENTID=(SELECT TOP 1 Id FROM Common.AttendanceAttachments WHERE CONVERT(DATE,FromDate)=CONVERT(date,(select Min(CONVERT(date,DATEANDTIME)) from @T)) AND CONVERT(DATE,ToDate)=CONVERT(date,(select Max(Convert(date,DATEANDTIME)) from @T)) AND CompanyId=@COMPANYID ORDER BY DateOfUpload DESC)
	--	UPDATE Common.AttendanceAttachments set Remarks='Successfully overridden the earlier file' where Id=@ATTACHMENTID
	--	PRINT 'Existing Attachment was updated'
	--	SET @IS_FILE_OVERRIDDEN = @IS_FILE_OVERRIDDEN + 1
	--END
	
	UPDATE Common.AttendanceAttachments set Remarks='Error: Employees does not exist',UploadStatus='Failed', AttachmentPath=@ATTACHMENT_FILENAME, FromDate=(select Min(CONVERT(date,DATEANDTIME)) from @T), 
											ToDate=(select Max(Convert(date,DATEANDTIME)) from @T), UploadedBy=@UPLOADEDBY, DateOfUpload=@DATEOFUPLOAD WHERE CompanyId=@COMPANYID and Id = @ATTACHMENTID
	
	--IF EXIST(select fromdate, todate from Common.AttendanceAttachments)
	DELETE @T WHERE NAME IS  NULL      
		SELECT DISTINCT(CONVERT(CHAR(10), DATEANDTIME, 120)) AS DATE FROM  @T    
    DECLARE @EmployeeID UNIQUEIDENTIFIER
	DECLARE @COUNT INT=0
	DECLARE @EMPLOYEENAME NVARCHAR(100)
    DECLARE @DATETIME datetime2(7)
	DECLARE @EmployeeIdAtCalendarSetup UNIQUEIDENTIFIER
	DECLARE @EmployeeExist INT = 0
	DECLARE @EmployeeNotExist INT = 0

	---cursor for distinct dates--------------------------------------------

    DECLARE ATTENDANCE_CURSOR CURSOR FOR
		SELECT DISTINCT(CONVERT(CHAR(10), DATEANDTIME, 120)) AS DATE FROM  @T    
    OPEN ATTENDANCE_CURSOR
		    FETCH NEXT FROM ATTENDANCE_CURSOR INTO @DATETIME
    while @@FETCH_STATUS > -1   
    BEGIN  

	----cursor for EmployeeName in perticular date-----------------------------
		DECLARE ATTENDANCE_CURSOR_FOR_EMPLOYEE CURSOR FOR
			SELECT DISTINCT NAME as EmployeeName FROM @T where CONVERT(CHAR(10), DATEANDTIME, 120) = @DATETIME
		OPEN ATTENDANCE_CURSOR_FOR_EMPLOYEE
				FETCH NEXT FROM ATTENDANCE_CURSOR_FOR_EMPLOYEE INTO @EMPLOYEENAME
		while @@FETCH_STATUS > -1   
		BEGIN  
		   --UPDATE Common.AttendanceAttachments set Remarks='',UploadStatus='Completed' WHERE CompanyId=@COMPANYID and Id = @ATTACHMENTID
		   DECLARE @CountOfTimingsInDate int
		   DECLARE @LeaveStatus nvarchar(15)
		   DECLARE @ApplyTo nvarchar(15)
		   DECLARE @AttendanceStatus nvarchar(15)
		   DECLARE @ISWORKINGDAY BIT
		   DECLARE @ATTENDANCEID UNIQUEIDENTIFIER
			   --SET @EmployeeID = (select distinct e.Id from Common.Employee e join @T t on t.NAME=e.FirstName and e.CompanyId=@COMPANYID and Convert(date,t.DATEANDTIME)=convert(date,@DATETIME))
			   SET @EmployeeID = (select distinct top 1 e.Id from Common.Employee e join @T t on e.FirstName=@EMPLOYEENAME and e.CompanyId=@COMPANYID and Convert(date,t.DATEANDTIME)=convert(date,@DATETIME))
			   if(@EmployeeID is not null)
			   BEGIN
				   print 'EmployeeId AT ATTENDANCE & UPDATING ATTENDANCE_TYPE'
				   print(@EmployeeID)	
				   --SET @LeaveStatus = (select LeaveStatus from hr.LeaveApplication where @DATETIME>=StartDateTime and @DATETIME <= EndDateTime and companyId=@COMPANYID and EmployeeId=@EmployeeID and DATENAME(WEEKDAY,@DATETIME)!='Saturday' and DATENAME(WEEKDAY,@DATETIME)!='Sunday')
				   --SET @ApplyTo = (select ApplyTo from Common.Calender where Convert(date, FromDateTime) <=Convert(Date, @DATETIME) and Convert(Date,ToDateTime) >=Convert(Date, @DATETIME) and CompanyId=@COMPANYID)
				   
				   --IF(@ApplyTo = 'Selected')
					    --SET @EmployeeIdAtCalendarSetup =(select CD.EmployeeId from Common.Calender c join Common.CalenderDetails cd on c.Id=cd.MasterId where cd.EmployeeId=@EmployeeID and c.CompanyId=@COMPANYID and Convert(Date, @DATETIME) >= Convert(Date, c.FromDateTime) and Convert(Date, @DATETIME) <= Convert(Date, c.ToDateTime))
				 
				   IF EXISTS(SELECT * FROM Common.Attendance WHERE CompanyId = @COMPANYID AND Date = @DATETIME) 
				   BEGIN
						--if(@LeaveStatus ='Approved')
						--BEGIN
						--	set @AttendanceStatus='NS Leave' 		 
						--END
						--if(@ApplyTo='All')
						--BEGIN
						--	set @AttendanceStatus='Holidays' 	
						--END
						--else 
						if EXISTS((select ISWORKINGDAY from COMMON.WORKWEEKSETUP where WEEKDAY = (SELECT DATENAME(WEEKDAY,CONVERT(date,@DATETIME))) and COMPANYID=@COMPANYID and EmployeeId=@EmployeeID))				 
						BEGIN
							set @AttendanceStatus=(select case WHEN ISWORKINGDAY=0 THEN 'Non-working' ELSE NULL END from COMMON.WORKWEEKSETUP where WEEKDAY = (SELECT DATENAME(WEEKDAY,CONVERT(date,@DATETIME))) and COMPANYID=@COMPANYID and EmployeeId=@EmployeeID)
						END
						ELSE
						BEGIN
							set @AttendanceStatus=(select case WHEN ISWORKINGDAY=0 THEN 'Non-working' ELSE NULL END from COMMON.WORKWEEKSETUP where WEEKDAY = (SELECT DATENAME(WEEKDAY,CONVERT(date,@DATETIME))) and COMPANYID=@COMPANYID and EmployeeId IS NULL)
						END

						SET @ATTENDANCEID = (select Id from Common.Attendance where Date=CONVERT(date,@DATETIME) and CompanyId=@COMPANYID)
						--IF EXISTS(select * from Common.AttendanceDetails where EmployeeId=@EmployeeID and AttendenceId=@AttendanceId)
						--BEGIN
							--IF((@EmployeeIdAtCalendarSetup IS NOT NULL) and (@ApplyTo ='Selected'))		
							--BEGIN	 
							--    set @AttendanceStatus='Holidays'	
							--UPDATE COMMON.AttendanceDetails SET AttendanceType=@AttendanceStatus where EmployeeId=@EmployeeID and AttendenceId=(select Id from Common.Attendance where Date=@DATETIME and CompanyId=@COMPANYID)
							--END
							--ELSE IF(@ApplyTo !='Selected')	
								--UPDATE COMMON.AttendanceDetails SET AttendanceType=@AttendanceStatus where EmployeeId=@EmployeeID and AttendenceId=(select Id from Common.Attendance where Date=@DATETIME and CompanyId=@COMPANYID)
						--END
						--ELSE --IF((@EmployeeIdAtCalendarSetup IS NOT NULL) and (@ApplyTo ='Selected'))		
						--BEGIN	 
							--set @AttendanceStatus='Holidays'	
							--INSERT INTO Common.AttendanceDetails(Id, EmployeeId, AttendenceId, AttendanceType, CreatedDate, Status) VALUES(NEWID(),@EmployeeID,@AttendanceId,@AttendanceStatus,GETDATE(), 1)
						--END
						--ELSE
						    --INSERT INTO Common.AttendanceDetails(Id, EmployeeId, AttendenceId, AttendanceType, CreatedDate, Status) VALUES(NEWID(),@EmployeeID,@AttendanceId,@AttendanceStatus,GETDATE(), 1)
							
							--IF(@AttendanceStatus IS NOT NULL)
							--BEGIN
							--	IF EXISTS(SELECT * FROM Common.AttendanceDetails WHERE AttendenceId=(SELECT Id FROM Common.Attendance WHERE CompanyId=@COMPANYID AND Date=CONVERT(DATE,@DATETIME)) AND EmployeeId=@EmployeeID)
							--		UPDATE COMMON.AttendanceDetails SET AttendanceType=@AttendanceStatus where EmployeeId=@EmployeeID and AttendenceId=(select Id from Common.Attendance where Date=@DATETIME and CompanyId=@COMPANYID)
							--	ELSE
							--		INSERT INTO Common.AttendanceDetails(Id, EmployeeId, AttendenceId, AttendanceType, CreatedDate, Status) VALUES(NEWID(),@EmployeeID,(SELECT Id FROM Common.Attendance WHERE CompanyId=@COMPANYID AND Date=CONVERT(DATE,@DATETIME)),@AttendanceStatus,GETDATE(), 1)
							--END
				   END
				   ELSE
				   BEGIN
						--if(@LeaveStatus ='Approved')
						--BEGIN
						--	set @AttendanceStatus='NS Leave' 		 
						--END
						--if(@ApplyTo='All')
						--BEGIN
						--	set @AttendanceStatus='Holidays' 	
						--END
						--else 
						if EXISTS((select ISWORKINGDAY from COMMON.WORKWEEKSETUP where WEEKDAY = (SELECT DATENAME(WEEKDAY,CONVERT(date,@DATETIME))) and COMPANYID=@COMPANYID and EmployeeId=@EmployeeID))				 
						BEGIN
							set @AttendanceStatus=(select case WHEN ISWORKINGDAY=0 THEN 'Non-working' ELSE NULL END from COMMON.WORKWEEKSETUP where WEEKDAY = (SELECT DATENAME(WEEKDAY,CONVERT(date,@DATETIME))) and COMPANYID=@COMPANYID and EmployeeId=@EmployeeID)
						END
						ELSE
						BEGIN
							set @AttendanceStatus=(select case WHEN ISWORKINGDAY=0 THEN 'Non-working' ELSE NULL END from COMMON.WORKWEEKSETUP where WEEKDAY = (SELECT DATENAME(WEEKDAY,CONVERT(date,@DATETIME))) and COMPANYID=@COMPANYID and EmployeeId IS NULL)
						END
							INSERT INTO COMMON.ATTENDANCE(Id,CompanyId,Date,Remarks,Status) VALUES(NEWID(),@COMPANYID,@DATETIME,NULL,1)
							SET @ATTENDANCEID  = (select Id from Common.Attendance where Date=CONVERT(date,@DATETIME) and CompanyId=@COMPANYID)
							--IF((@EmployeeIdAtCalendarSetup IS NOT NULL) and (@ApplyTo ='Selected'))		
							--BEGIN	 
							--    set @AttendanceStatus='Holidays'
							--    INSERT INTO Common.AttendanceDetails(Id, EmployeeId, AttendenceId, AttendanceType, CreatedDate, Status) VALUES(NEWID(),@EmployeeID,@AttendanceIds,@AttendanceStatus,GETDATE(), 1)
                            --END
							--ELSE

							--IF(@AttendanceStatus IS NOT NULL)
							--BEGIN
							--	IF EXISTS(SELECT * FROM Common.AttendanceDetails WHERE AttendenceId=(SELECT Id FROM Common.Attendance WHERE CompanyId=@COMPANYID AND Date=CONVERT(DATE,@DATETIME)) AND EmployeeId=@EmployeeID)
							--		UPDATE COMMON.AttendanceDetails SET AttendanceType=@AttendanceStatus where EmployeeId=@EmployeeID and AttendenceId=(select Id from Common.Attendance where Date=@DATETIME and CompanyId=@COMPANYID)
							--	ELSE
							--		INSERT INTO Common.AttendanceDetails(Id, EmployeeId, AttendenceId, AttendanceType, CreatedDate, Status) VALUES(NEWID(),@EmployeeID,(SELECT Id FROM Common.Attendance WHERE CompanyId=@COMPANYID AND Date=CONVERT(DATE,@DATETIME)),@AttendanceStatus,GETDATE(), 1)
							--END
					END
					If EXISTS((select ISWORKINGDAY from COMMON.WORKWEEKSETUP where WEEKDAY = (SELECT DATENAME(WEEKDAY,CONVERT(date,@DATETIME))) and COMPANYID=@COMPANYID and EmployeeId=@EmployeeID))				 
						BEGIN
							set @ISWORKINGDAY=(select IsWorkingDay from COMMON.WORKWEEKSETUP where WEEKDAY = (SELECT DATENAME(WEEKDAY,CONVERT(date,@DATETIME))) and COMPANYID=@COMPANYID and EmployeeId=@EmployeeID)
						END
					ELSE
						BEGIN
							set @ISWORKINGDAY=(select IsWorkingDay from COMMON.WORKWEEKSETUP where WEEKDAY = (SELECT DATENAME(WEEKDAY,CONVERT(date,@DATETIME))) and COMPANYID=@COMPANYID and EmployeeId IS NULL)
						END
				END
				-----------------------------------updating TimeFrom and TimeTo in ommon.AttendanceDetails------------------------

				--SET @EmployeeID = (select distinct e.Id from Common.Employee e join @T t on t.NAME=e.FirstName and e.CompanyId=@COMPANYID and Convert(date,t.DATEANDTIME)=@DATETIME)
				print 'EmployeeId AT TIME_FROM AND TIME_TO'
				print(@EmployeeID)				
				DECLARE @EmployeeFirstName NVARCHAR(100) = (SELECT FirstName FROM Common.Employee where Id=@EmployeeID)
				--DECLARE @CountOfTimingsInDate int
				SET @CountOfTimingsInDate = (SELECT COUNT(*) FROM @T where (datediff(day, DATEANDTIME, CONVERT(DATE,@DATETIME)) = 0) AND NAME=@EmployeeFirstName) --get the count of maching dates
				--IF EXISTS(SELECT TIMEFROM, TIMETO FROM Common.AttendanceDetails where EmployeeId=@EmployeeID and AttendenceId=( select id from Common.Attendance where CompanyId=@COMPANYID and Date=@DATETIME))		
				SET @COUNT=0
				if(@EmployeeID IS NOT NULL)
				BEGIN
     				SET @COUNT=1
					SET @EmployeeExist = @EmployeeExist + 1
					IF(@EmployeeNotExist = 0 AND @IS_FILE_OVERRIDDEN = 1)
						UPDATE Common.AttendanceAttachments set Remarks='Successfully overridden the earlier file',UploadStatus='Completed', FromDate=(select Min(CONVERT(date,DATEANDTIME)) from @T),ToDate=(select Max(Convert(date,DATEANDTIME)) from @T) WHERE CompanyId=@COMPANYID and Id = @ATTACHMENTID
					ELSE IF(@IS_FILE_OVERRIDDEN = 0 AND @EmployeeNotExist=0)
					    UPDATE Common.AttendanceAttachments set Remarks='',UploadStatus='Completed', FromDate=(select Min(CONVERT(date,DATEANDTIME)) from @T),ToDate=(select Max(Convert(date,DATEANDTIME)) from @T) WHERE CompanyId=@COMPANYID and Id = @ATTACHMENTID
					IF( @CountOfTimingsInDate >= 2)
					BEGIN
						DECLARE @timeFrom time = (select top 1 CONVERT(time,DATEANDTIME) from @T where datediff(day, CONVERT(DATE,DATEANDTIME), CONVERT(DATE,@DATETIME)) = 0 
						and NAME = @EmployeeFirstName order by DATEANDTIME )
						DECLARE @timeTo time = (select top 1 CONVERT(time,DATEANDTIME) from @T where datediff(day, CONVERT(DATE,DATEANDTIME), CONVERT(DATE,@DATETIME)) = 0 
						and NAME = @EmployeeFirstName order by DATEANDTIME desc)
						IF(@timeFrom > @timeTo)
						    SET @timeTo = @timeFrom
						IF EXISTS(select AttendenceId from Common.AttendanceDetails where EmployeeID=@EmployeeID and AttendenceId=(select Id from Common.Attendance where CompanyId=@COMPANYID and Date=CONVERT(date,@DATETIME)))
							BEGIN
								IF(@timeFrom='' AND @timeTo='')
									UPDATE ad set ad.TimeFrom=@timeFrom, ad.TimeTo=@timeTo, ad.IsWorkingDay=0 from Common.AttendanceDetails ad WHERE ad.EmployeeId=@EmployeeID and ad.AttendenceId=@ATTENDANCEID
								ELSE
									UPDATE ad set ad.TimeFrom=@timeFrom, ad.TimeTo=@timeTo, ad.IsWorkingDay=1 from Common.AttendanceDetails ad WHERE ad.EmployeeId=@EmployeeID and ad.AttendenceId=@ATTENDANCEID
							END
						ELSE	 
							BEGIN
								INSERT INTO Common.AttendanceDetails(Id,EmployeeId,AttendenceId,TimeFrom,TimeTo,CreatedDate,IsWorkingDay) VALUES(NEWID(),@employeeId,(select Id from Common.Attendance where CompanyId=@COMPANYID and Date=Convert(date,@DATETIME)),@timeFrom,@timeTo,GETDATE(),@ISWORKINGDAY)
							END
					END
					ELSE
					BEGIN
						 DECLARE @timeFrom1 time = (select CONVERT(time,DATEANDTIME) from @T where datediff(day, DATEANDTIME, CONVERT(DATE,@DATETIME)) = 0 AND NAME=@EmployeeFirstName)
						 DECLARE @timeTo1 time = (select CONVERT(time,DATEANDTIME) from @T where datediff(day, DATEANDTIME, CONVERT(DATE,@DATETIME)) = 0 AND NAME=@EmployeeFirstName)
						 --DECLARE @timeTo1 time
						 --IF EXISTS((select EmployeeId from COMMON.WORKWEEKSETUP where WEEKDAY = (SELECT DATENAME(WEEKDAY,CONVERT(date,@DATETIME))) and COMPANYID=@COMPANYID and EmployeeId=@EmployeeID))
							--SET @timeTo1 =(SELECT PMToTime from Common.WorkWeekSetUp WHERE CompanyId=@COMPANYID AND (EmployeeId = @EmployeeID) AND WeekDay=(SELECT DATENAME(DW,@DATETIME))) 
						 --ELSE
							--SET @timeTo1 =(SELECT PMToTime from Common.WorkWeekSetUp WHERE CompanyId=@COMPANYID AND (EmployeeId IS NULL) AND WeekDay=(SELECT DATENAME(DW,@DATETIME))) 
						 --IF(@timeFrom1 > @timeTo1)
						 --   SET @timeTo1 = @timeFrom1
						 IF EXISTS(select AttendenceId from Common.AttendanceDetails where EmployeeId=@EmployeeID and AttendenceId=(select Id from Common.Attendance where CompanyId=@COMPANYID and Date=Convert(date,@DATETIME)))
							UPDATE Common.AttendanceDetails set TimeFrom = @timeFrom1,TimeTo = @timeTo1, IsWorkingDay=1 where AttendenceId=@ATTENDANCEID and EmployeeId = @EmployeeID
						 ELSE IF (@EmployeeID IS NOT NULL)
							INSERT INTO Common.AttendanceDetails(Id,EmployeeId,AttendenceId,TimeFrom,TimeTo,CreatedDate,IsWorkingDay) VALUES(NEWID(),@EmployeeID,(select Id from Common.Attendance where CompanyId=@COMPANYID and Date=Convert(date,@DATETIME)),@timeFrom1,@timeTo1,GETDATE(),@ISWORKINGDAY)
					END		

				--------------------------------------Updating LateIn and LateOut Status in Common.AttendanceDetails--------------------------------------------

				DECLARE @LateInType NVARCHAR(10)
				DECLARE @LateoutType NVARCHAR(10)
				DECLARE @LateinTimeType NVARCHAR(10)
				DECLARE @LateOutTimeType NVARCHAR(10)
				--DECLARE @AttendanceType NVARCHAR(50) = (select ad.AttendanceType from Common.Attendance a join Common.AttendanceDetails ad on a.Id = ad.AttendenceId where a.CompanyId=@COMPANYID and ad.EmployeeId=@EmployeeID and a.Date=@DATETIME)
				SET @LateInType=(select LateInType from Common.AttendanceRules where CompanyId=@COMPANYID and (LateOutStatus=1 OR LateOutStatus=2))
				SET @LateoutType=(select LateOutType from Common.AttendanceRules where CompanyId=@COMPANYID and (LateOutStatus=1 OR LateOutStatus=2))
				SET @LateOutTimeType =(select LateOutTimeType from Common.AttendanceRules where CompanyId=@COMPANYID and (LateOutStatus=1 OR LateOutStatus=2))
				SET @LateinTimeType =(select LateinTimeType from Common.AttendanceRules where CompanyId=@COMPANYID and (LateOutStatus=1 OR LateOutStatus=2))
				DECLARE @timeFromAD time = (SELECT DISTINCT LEFT(CONVERT(VARCHAR(26), ad.TimeFrom, 109),14) from common.AttendanceDetails ad join Common.Attendance a on a.Id=ad.AttendenceId where a.Date = @DATETIME and a.companyId=@COMPANYID and EmployeeId=@EmployeeID)
				DECLARE @timeToAD time = (SELECT DISTINCT LEFT(CONVERT(VARCHAR(26), ad.TimeTo, 109),14) from common.AttendanceDetails ad join Common.Attendance a on a.Id=ad.AttendenceId where a.Date = @DATETIME and a.companyId=@COMPANYID and EmployeeId=@EmployeeID)

				if(@EmployeeID IS NOT NULL)
				BEGIN
						print 'EmployeeId AT LATE_IN, LATE_OUT CALCULATION'
						print(@EmployeeID)	
						if(@LateinTimeType ='FromTime')
						BEGIN
							if(@LateInType ='After')   

								if EXISTS(select Id from Common.WorkWeekSetup where employeeId=@EmployeeID)
								update ad set ad.lateIn=1,ad.AdminLateIn=1 from Common.AttendanceDetails ad 
										join Common.Attendance a on  a.Id = ad.AttendenceId 
										join Common.WorkWeekSetUp w on w.EmployeeId = ad.EmployeeId
										join Common.AttendanceRules ar on ar.CompanyId = w.CompanyId
										where a.CompanyId=@COMPANYID 
										and a.date = CONVERT(date,@DATETIME)
										and ad.EmployeeId=@EmployeeID
										and ad.AttendenceId=@ATTENDANCEID
										and  w.WeekDay = DATENAME(WEEKDAY,CONVERT(date,@DATETIME))
										and (DATEADD(minute,ar.LateInTime,w.AMFromTime) < ad.TimeFrom)  AND  @AttendanceStatus IS NULL and AR.LateInStatus=1
								ELSE
								update ad set ad.lateIn=1,ad.AdminLateIn=1 from Common.AttendanceDetails ad 
										join Common.Attendance a on  a.Id = ad.AttendenceId 
										join Common.WorkWeekSetUp w on w.CompanyId = a.CompanyId AND w.EmployeeId IS NULL
										join Common.AttendanceRules ar on ar.CompanyId = w.CompanyId
										where a.CompanyId=@COMPANYID 
										and a.date = CONVERT(date,@DATETIME)
										and ad.EmployeeId=@EmployeeID
										and ad.AttendenceId=@ATTENDANCEID
										and  w.WeekDay = DATENAME(WEEKDAY,CONVERT(date,@DATETIME))
										and (DATEADD(minute,ar.LateInTime,w.AMFromTime) < ad.TimeFrom)  AND  @AttendanceStatus IS NULL and AR.LateInStatus=1

								if EXISTS(select Id from Common.WorkWeekSetup where employeeId=@EmployeeID)		--============== First LateIn and LateOut should be true. After update timings as per company / Employee LateIn and LateOut remain 'True' 
								update ad set ad.lateIn=0,ad.AdminLateIn=0 from Common.AttendanceDetails ad 
										join Common.Attendance a on  a.Id = ad.AttendenceId 
										join Common.WorkWeekSetUp w on w.EmployeeId = ad.EmployeeId
										join Common.AttendanceRules ar on ar.CompanyId = w.CompanyId
										where a.CompanyId=@COMPANYID 
										and a.date = CONVERT(date,@DATETIME)
										and ad.EmployeeId=@EmployeeID
										and ad.AttendenceId=@ATTENDANCEID
										and  w.WeekDay = DATENAME(WEEKDAY,CONVERT(date,@DATETIME)) --AND  @AttendanceStatus IS NOT NULL and AR.LateInStatus=1
										and (((DATEADD(minute,ar.LateInTime,w.AMFromTime) >= ad.TimeFrom) AND  @AttendanceStatus IS NULL and AR.LateInStatus=1) OR AR.LateInStatus = 2)
								ELSE
								update ad set ad.lateIn=0,ad.AdminLateIn=0 from Common.AttendanceDetails ad 
										join Common.Attendance a on  a.Id = ad.AttendenceId 
										join Common.WorkWeekSetUp w on w.CompanyId = a.CompanyId AND w.EmployeeId IS NULL
										join Common.AttendanceRules ar on ar.CompanyId = w.CompanyId
										where a.CompanyId=@COMPANYID 
										and a.date = CONVERT(date,@DATETIME)
										and ad.EmployeeId=@EmployeeID
										and ad.AttendenceId=@ATTENDANCEID
										and  w.WeekDay = DATENAME(WEEKDAY,CONVERT(date,@DATETIME)) --AND  @AttendanceStatus IS NOT NULL and AR.LateInStatus=1
										and (((DATEADD(minute,ar.LateInTime,w.AMFromTime) >= ad.TimeFrom) AND  @AttendanceStatus IS NULL and AR.LateInStatus=1) OR AR.LateInStatus = 2)

						END
						if(@LateOutTimeType ='ToTime')
						BEGIN
							if(@LateoutType ='After') 

								IF EXISTS(select Id from Common.WorkWeekSetup where employeeId=@EmployeeID)
								update ad set ad.LateOut=1,ad.AdminLateOut=1 from Common.AttendanceDetails ad 
										join Common.Attendance a on  a.Id = ad.AttendenceId 
										join Common.WorkWeekSetUp w on w.EmployeeId = ad.EmployeeId
										join Common.AttendanceRules ar on ar.CompanyId = w.CompanyId
										where a.CompanyId=@COMPANYID 
										and a.date = CONVERT(date,@DATETIME)
										and ad.EmployeeId=@EmployeeID
										and ad.AttendenceId=@ATTENDANCEID
										and  w.WeekDay = DATENAME(WEEKDAY,CONVERT(date,@DATETIME))
										and (DATEADD(minute,ar.LateOutTime,w.PMToTime) < ad.TimeTo)  AND  @AttendanceStatus IS NULL and AR.LateOutStatus=1
								ELSE
								update ad set ad.LateOut=1,ad.AdminLateOut=1 from Common.AttendanceDetails ad 
										join Common.Attendance a on  a.Id = ad.AttendenceId 
										join Common.WorkWeekSetUp w on w.CompanyId = a.CompanyId AND w.EmployeeId IS NULL
										join Common.AttendanceRules ar on ar.CompanyId = w.CompanyId
										where a.CompanyId=@COMPANYID 
										and a.date = CONVERT(date,@DATETIME)
										and ad.EmployeeId=@EmployeeID
										and ad.AttendenceId=@ATTENDANCEID
										and  w.WeekDay = DATENAME(WEEKDAY,CONVERT(date,@DATETIME))
										and (DATEADD(minute,ar.LateOutTime,w.PMToTime) < ad.TimeTo)  AND  @AttendanceStatus IS NULL and AR.LateOutStatus=1

								IF EXISTS(select Id from Common.WorkWeekSetup where employeeId=@EmployeeID)	   --============== First LateIn and LateOut should be true. After update timings as per company / Employee LateIn and LateOut remain 'True' 
								update ad set ad.LateOut=0,ad.AdminLateOut=0 from Common.AttendanceDetails ad 
										join Common.Attendance a on  a.Id = ad.AttendenceId 
										join Common.WorkWeekSetUp w on w.EmployeeId = ad.EmployeeId
										join Common.AttendanceRules ar on ar.CompanyId = w.CompanyId
										where a.CompanyId=@COMPANYID 
										and a.date = CONVERT(date,@DATETIME)
										and ad.EmployeeId=@EmployeeID
										and ad.AttendenceId=@ATTENDANCEID
										and  w.WeekDay = DATENAME(WEEKDAY,CONVERT(date,@DATETIME)) --AND @AttendanceStatus IS NOT NULL and AR.LateOutStatus=1
										and (((DATEADD(minute,ar.LateOutTime,w.PMToTime) >= ad.TimeTo) AND  @AttendanceStatus IS NULL and AR.LateOutStatus=1) OR AR.LateOutStatus = 2)
								ELSE
								update ad set ad.LateOut=0,ad.AdminLateOut=0 from Common.AttendanceDetails ad 
										join Common.Attendance a on  a.Id = ad.AttendenceId 
										join Common.WorkWeekSetUp w on w.CompanyId = a.CompanyId AND w.EmployeeId IS NULL
										join Common.AttendanceRules ar on ar.CompanyId = w.CompanyId
										where a.CompanyId=@COMPANYID 
										and a.date = CONVERT(date,@DATETIME)
										and ad.EmployeeId=@EmployeeID
										and ad.AttendenceId=@ATTENDANCEID
										and  w.WeekDay = DATENAME(WEEKDAY,CONVERT(date,@DATETIME)) --AND @AttendanceStatus IS NOT NULL and AR.LateOutStatus=1
									    and (((DATEADD(minute,ar.LateOutTime,w.PMToTime) >= ad.TimeTo) AND  @AttendanceStatus IS NULL and AR.LateOutStatus=1) OR AR.LateOutStatus = 2)
						END
					END
				END
				ELSE IF(@COUNT = 0)
				BEGIN
					 --UPDATE COMMON.AttendanceAttachments SET FromDate=(SELECT MIN(CONVERT(date,DATEANDTIME)) from @T),ToDate=(SELECT MAX(Convert(date,DATEANDTIME)) from @T), Remarks='ERROR: One or more Employees does not exist', UploadStatus='Completed' WHERE CompanyId=@COMPANYID and Id=@ATTACHMENTID
					 UPDATE COMMON.AttendanceAttachments SET FromDate=(SELECT MIN(CONVERT(date,DATEANDTIME)) from @T),ToDate=(SELECT MAX(Convert(date,DATEANDTIME)) from @T), Remarks='WARNING: Few Employees in Excel does not exist in Company', UploadStatus='Completed' WHERE CompanyId=@COMPANYID and Id=@ATTACHMENTID
					 SET @EmployeeNotExist = @EmployeeNotExist + 1
			    END
				IF(@EmployeeExist = 0 AND @EmployeeNotExist=(select top 1 COUNT(*) OVER () AS TotalRecords from @T group by CONVERT(DATE,DATEANDTIME), NAME))
				BEGIN
				     UPDATE COMMON.AttendanceAttachments 
					 SET FromDate=(SELECT MIN(CONVERT(date,DATEANDTIME)) from @T),ToDate=(SELECT MAX(Convert(date,DATEANDTIME)) from @T), Remarks='ERROR: Employees does not exist', UploadStatus='Failed'    
					 WHERE CompanyId=@COMPANYID and Id=@ATTACHMENTID
				END	 
			FETCH NEXT FROM ATTENDANCE_CURSOR_FOR_EMPLOYEE INTO @EMPLOYEENAME
			END
 
			CLOSE ATTENDANCE_CURSOR_FOR_EMPLOYEE
			DEALLOCATE ATTENDANCE_CURSOR_FOR_EMPLOYEE

		FETCH NEXT FROM ATTENDANCE_CURSOR INTO @DATETIME
		END
 
		CLOSE ATTENDANCE_CURSOR
		DEALLOCATE ATTENDANCE_CURSOR

		--------------------------------------Previous Day Attendance---------------------------------------------------------------------

		print 'Previous Day Attendance Calculation'
		DECLARE @PREVIOUESTIME INT=(SELECT PreviousTime FROM Common.AttendanceRules WHERE CompanyId=@COMPANYID AND Status=1 AND PreviousStatus=1)
		IF (@PREVIOUESTIME >=0)
		BEGIN
		DECLARE @Employee_Id UNIQUEIDENTIFIER
		DECLARE PreViouesDay_Cursor CURSOR FOR 
		SELECT DISTINCT ID FROM @T T LEFT JOIN COMMON.EMPLOYEE E ON T.NAME=E.FIRSTNAME WHERE COMPANYID=@COMPANYID 
		GROUP BY  ID ORDER BY ID 
		OPEN PreViouesDay_Cursor
		FETCH NEXT FROM PreViouesDay_Cursor INTO @Employee_Id
		WHILE @@FETCH_STATUS=0    
			BEGIN              
					DECLARE @DATEANDTIME DATETIME2(7),@NAME NVARCHAR(100),@EMPLOYEEID_ID UNIQUEIDENTIFIER
					DECLARE Employee_Cursor CURSOR FOR 
					SELECT DISTINCT CONVERT(DATE, DATEANDTIME) AS DATEANDTIME, NAME, ID FROM @T T LEFT JOIN 
									COMMON.EMPLOYEE E ON T.NAME=E.FIRSTNAME WHERE COMPANYID=@COMPANYID 
									AND ID=@Employee_Id	GROUP BY  DATEANDTIME,NAME,ID ORDER BY NAME    
					OPEN Employee_Cursor
					FETCH NEXT FROM Employee_Cursor INTO @DATEANDTIME,@NAME,@EMPLOYEEID_ID
					WHILE @@FETCH_STATUS=0    
					BEGIN    
						DECLARE @AMFROMTIME TIME(7)
						if EXISTS(select Id from Common.WorkWeekSetup where employeeId=@EmployeeID)
			  			BEGIN
							SET @AMFROMTIME = (SELECT AMFromTime FROM COMMON.WorkWeekSetUp  WHERE CompanyId=@COMPANYID AND (EmployeeId = @EMPLOYEEID_ID) AND WeekDay = DATENAME(WEEKDAY,CONVERT(DATE,@DATEANDTIME)) AND IsWorkingDay=1)
						END
						ELSE
						BEGIN
							SET @AMFROMTIME = (SELECT AMFromTime FROM COMMON.WorkWeekSetUp  WHERE CompanyId=@COMPANYID AND (EmployeeId IS NULL) AND WeekDay = DATENAME(WEEKDAY,CONVERT(DATE,@DATEANDTIME)) AND IsWorkingDay=1)
						END
							IF (@AMFROMTIME  >= '00:00:00')
								BEGIN		
								DECLARE @EMPLOYEE_TIME TIME(7)= (SELECT TOP 1 CONVERT(time,DATEANDTIME)  AS DATEANDTIME FROM @T WHERE NAME=@NAME AND DATEANDTIME >= @DATEANDTIME AND DATEANDTIME <= DATEADD(MINUTE,1399,@DATEANDTIME) ORDER BY DATEANDTIME)
								IF ((DATEADD(MINUTE,-@PREVIOUESTIME, @AMFROMTIME))>=@EMPLOYEE_TIME)
									BEGIN
									    print 'Prevoius Day TimeTo updating'
										UPDATE AD SET AD.LateOut=1, AD.AdminLateOut=1 ,AD.TimeTo = @EMPLOYEE_TIME FROM Common.Attendance A INNER JOIN COMMON.AttendanceDetails AD ON A.Id = AD.AttendenceId 
												WHERE A.COMPANYID = @COMPANYID AND AD.EmployeeId = @EMPLOYEEID_ID AND Date=DATEADD(D,-1, @DATEANDTIME)--LATEOUT

										---------
										IF(@EMPLOYEE_TIME IS NOT NULL  AND @EMPLOYEE_TIME != '00:00:00')
										BEGIN
											DECLARE @DATESCOUNT INT = (SELECT COUNT(*) FROM @T where (datediff(day, DATEANDTIME, CONVERT(DATE,@DATEANDTIME)) = 0) AND NAME=@NAME AND CONVERT(TIME,DATEANDTIME)>(DATEADD(MINUTE,-@PREVIOUESTIME, @AMFROMTIME))) 
											IF(@DATESCOUNT = 0)
											BEGIN
												DELETE FROM Common.AttendanceDetails WHERE AttendenceId=(SELECT ID FROM Common.Attendance WHERE CompanyId=@COMPANYID AND Date=@DATEANDTIME) AND EmployeeId=@EMPLOYEEID_ID											
											END
										END
										---------

										--DECLARE @TIMEFROMTIME TIME(7) =	(SELECT TOP 1 CONVERT(TIME, DATEANDTIME) FROM @T WHERE DATEANDTIME<= DATEADD(MINUTE,1399,@DATEANDTIME)  AND Convert(time,DATEANDTIME) >= DATEADD(day, DATEDIFF(day, 0, @DATEANDTIME), DATEADD(MINUTE,-@PREVIOUESTIME, @AMFROMTIME)) ORDER BY DATEANDTIME)
										DECLARE @TIMETOTIME time
										DECLARE @TIMEFROMTIME TIME(7) = (SELECT TOP 1 CONVERT(TIME, DATEANDTIME) FROM @T WHERE CONVERT(time, DATEANDTIME) > DATEADD(MINUTE,-@PREVIOUESTIME, @AMFROMTIME) AND NAME = @NAME AND CONVERT(date,DATEANDTIME) = CONVERT(date, @DATEANDTIME) ORDER BY DATEANDTIME)
										
										IF(@CountOfTimingsInDate > 3)
											SET @TIMETOTIME = (select top 1 CONVERT(time,DATEANDTIME) from @T where datediff(day, DATEANDTIME, CONVERT(DATE,@DATEANDTIME)) = 0 AND NAME = @NAME order by DATEANDTIME desc)
						                ELSE
											BEGIN
												IF EXISTS((select EmployeeId from COMMON.WORKWEEKSETUP where WEEKDAY = (SELECT DATENAME(WEEKDAY,CONVERT(date,@DATEANDTIME))) and COMPANYID=@COMPANYID and EmployeeId=@EMPLOYEEID_ID))
													SET @TIMETOTIME =(SELECT PMToTime from Common.WorkWeekSetUp WHERE CompanyId=@COMPANYID AND (EmployeeId = @EMPLOYEEID_ID) AND WeekDay=(SELECT DATENAME(DW,@DATEANDTIME))) 
												ELSE
													SET @TIMETOTIME =(SELECT PMToTime from Common.WorkWeekSetUp WHERE CompanyId=@COMPANYID AND (EmployeeId IS NULL) AND WeekDay=(SELECT DATENAME(DW,@DATEANDTIME))) 
											END

										IF (@TIMEFROMTIME >= '00:00:00')
											BEGIN
												print 'Current Day TimeFrom updating'
												UPDATE AD SET TimeFrom = @TIMEFROMTIME, TimeTo=@TIMETOTIME FROM Common.Attendance A INNER JOIN COMMON.AttendanceDetails AD ON A.Id = AD.AttendenceId 
														WHERE A.COMPANYID = @COMPANYID AND AD.EmployeeId = @EMPLOYEEID_ID AND Date= @DATEANDTIME
											END
									END						 		  
								END				
					
					FETCH NEXT FROM Employee_Cursor INTO @DATEANDTIME,@NAME,@EMPLOYEEID_ID
					END 
					CLOSE Employee_Cursor
					DEALLOCATE Employee_Cursor 
			FETCH NEXT FROM PreViouesDay_Cursor INTO @Employee_Id
			END 
		CLOSE PreViouesDay_Cursor
		DEALLOCATE PreViouesDay_Cursor
		END	   
	   END
	ELSE
	BEGIN
		IF EXISTS(SELECT TOP 1 * FROM Common.AttendanceAttachments WHERE CONVERT(DATE,FromDate)=CONVERT(date,(select Min(CONVERT(date,DATEANDTIME)) from @T)) AND CONVERT(DATE,ToDate)=CONVERT(date,(select Max(Convert(date,DATEANDTIME)) from @T)) AND CompanyId=@COMPANYID ORDER BY DateOfUpload DESC)
		BEGIN
     		DELETE FROM Common.AttendanceAttachments WHERE Id=@ATTACHMENTID AND CompanyId=@COMPANYID
			SET @ATTACHMENTID=(SELECT TOP 1 Id FROM Common.AttendanceAttachments WHERE CONVERT(DATE,FromDate)=CONVERT(date,(select Min(CONVERT(date,DATEANDTIME)) from @T)) AND CONVERT(DATE,ToDate)=CONVERT(date,(select Max(Convert(date,DATEANDTIME)) from @T)) AND CompanyId=@COMPANYID ORDER BY DateOfUpload DESC)
			--UPDATE Common.AttendanceAttachments set Remarks='Override the Existing file' where Id=@ATTACHMENTID
			PRINT 'Existing Attachment was updated'
		END
	UPDATE COMMON.AttendanceAttachments set FromDate=GETUTCDATE(),ToDate=GETUTCDATE(),Remarks='ERROR: Employee Excel has no data..!',UploadStatus='Failed'  where CompanyId=@COMPANYID and Id=@ATTACHMENTID
	END
END















GO
