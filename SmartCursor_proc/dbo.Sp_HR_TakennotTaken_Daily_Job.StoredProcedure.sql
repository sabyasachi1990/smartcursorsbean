USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_HR_TakennotTaken_Daily_Job]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--->>> EXEC [dbo].[Sp_HR_TakennotTaken_Daily_Job]

CREATE PROCEDURE [dbo].[Sp_HR_TakennotTaken_Daily_Job]
AS
BEGIN

BEGIN TRY
BEGIN TRANSACTION

    DECLARE @Employeeid UNIQUEIDENTIFIER,
            @leaveTypeId UNIQUEIDENTIFIER,
            @companyId BIGINT,
            @startdate DATETIME,
            @approvedDate DATETIME,
            @Days FLOAT,
            @Hours FLOAT,
            @entitlementType NVARCHAR(50),
            @HrSettingDetailId UNIQUEIDENTIFIER,
            @toDayDate DATETIME;

    DECLARE @StartTime DATETIME2(7) = GETDATE();

    CREATE TABLE #LeaveApplications 
	(	SNo Int Identity(1,1),
        EmployeeId UNIQUEIDENTIFIER,
        LeaveTypeId UNIQUEIDENTIFIER,
        EntitlementType NVARCHAR(50),
        StartDate DATE,
        Days FLOAT,
        Hours FLOAT,
        ApprovedDate DATE,
        CompanyId BIGINT
    );

    INSERT INTO #LeaveApplications (EmployeeId, LeaveTypeId, EntitlementType, StartDate, Days, Hours, ApprovedDate, CompanyId)
    SELECT le.EmployeeId,
           le.LeaveTypeId,
           lt.EntitlementType,
           CAST(le.StartDateTime AS DATE),
           SUM(ISNULL(Days, 0)),
           SUM(ISNULL(Hours, 0)),
           CAST(jj.CreatedDate AS DATE) AS ApprovedDate,
           lt.CompanyId
    FROM HR.LeaveApplication AS le (NOLOCK)
    JOIN HR.LeaveType AS lt (NOLOCK) ON le.LeaveTypeId = lt.Id
    LEFT JOIN (SELECT LeaveApplicationId,
                      CONVERT(DATE, CreatedDate) AS CreatedDate
               FROM (SELECT RANK() OVER (PARTITION BY LeaveApplicationId ORDER BY CreatedDate DESC) AS rank,
                            LeaveApplicationId,
                            CreatedDate
                     FROM HR.LeaveApplicationHistory (NOLOCK)
                     WHERE LeaveStatus IN ('Approved', 'For Cancellation')) gg
               WHERE rank = 1) jj ON jj.LeaveApplicationId = le.Id
    WHERE (le.LeaveStatus = 'Approved' OR le.LeaveStatus = 'For Cancellation')
      AND CONVERT(DATE, le.StartDateTime) = CONVERT(DATE, GETDATE())
      AND (le.IsTaken IS NULL OR le.IsTaken = 0)
    GROUP BY le.EmployeeId,
             le.LeaveTypeId,
             lt.EntitlementType,
             CAST(le.StartDateTime AS DATE),
             CAST(jj.CreatedDate AS DATE),
             lt.CompanyId
    ORDER BY le.EmployeeId;

    DECLARE @RowCount INT = (SELECT COUNT(*) FROM #LeaveApplications);
    DECLARE @Counter INT = 1;

    WHILE @Counter <= @RowCount
    BEGIN
        SELECT  @Employeeid = EmployeeId,
                @leaveTypeId = LeaveTypeId,
                @entitlementType = EntitlementType,
                @startdate = StartDate,
                @Days = Days,
                @Hours = Hours,
                @approvedDate = ApprovedDate,
                @companyId = CompanyId
        FROM #LeaveApplications
        WHERE SNo = @Counter

        SET @HrSettingDetailId = (SELECT HRMD.Id
                                  FROM COMMON.HRSETTINGS AS HRM (NOLOCK)
                                  JOIN COMMON.HRSETTINGDETAILS AS HRMD (NOLOCK) ON HRM.ID = HRMD.MASTERID
                                  WHERE COMPANYID = @companyId
                                    AND HRMD.StartDate <= @approvedDate
                                    AND @approvedDate <= HRMD.EndDate)

        SET @toDayDate = (SELECT TOP (1) TakenNotTakenDate
                          FROM HR.LeaveEntitlement (NOLOCK)
                          WHERE EmployeeId = @Employeeid
                            AND LeaveTypeId = @leaveTypeId
                            AND HrSettingDetaiId = @HrSettingDetailId
                            AND EntitlementStatus = 1)

        SET @toDayDate = CASE
                             WHEN @toDayDate IS NULL THEN DATEADD(DAY, DATEDIFF(DAY, 1, GETDATE()), 0)
                             ELSE @toDayDate
                         END

--SELECT @Employeeid AS Employeeid, @leaveTypeId AS leaveTypeId, @entitlementType AS entitlementType ,@startdate AS startdate,@Days AS Days,@Hours AS Hours,@approvedDate AS approvedDate,@companyId AS companyId,@HrSettingDetailId AS HrSettingDetailId,@toDayDate AS toDayDate

        IF (CONVERT(DATE, @startdate) = CONVERT(DATE, GETDATE()) AND CONVERT(DATE, @toDayDate) != CONVERT(DATE, GETDATE()))
        BEGIN
            IF (@entitlementType = 'Days')
            BEGIN
		INSERT INTO HR.TakenNotTakenTracing (CompanyId ,EmployeeId ,leaveTypeId ,entitlementType ,startdate,todaydate ,Days ,Hours ,approvedDate ,CurrentApprovedAndTaken ,
		CurrentApprovedAndNotTaken ,TakenNotTakenDate ,UpdateApprovedAndTaken ,UpdateApprovedAndNotTaken ,CreatedDate)

				SELECT @companyId, @Employeeid, @leaveTypeId, @entitlementType, @startdate, @toDayDate,@Days, @Hours, @approvedDate,
				ApprovedAndTaken,ApprovedAndNotTaken,TakenNotTakenDate,ISNULL(ApprovedAndTaken, 0) + @Days,ISNULL(ApprovedAndNotTaken, 0) - @Days,
				GETDATE()
				FROM HR.LeaveEntitlement
                WHERE EmployeeId = @Employeeid
                  AND LeaveTypeId = @leaveTypeId
                  AND HrSettingDetaiId = @HrSettingDetailId
                  AND EntitlementStatus = 1

				UPDATE HR.LeaveEntitlement
				SET ApprovedAndTaken = ISNULL(ApprovedAndTaken, 0) + @Days, ApprovedAndNotTaken = ISNULL(ApprovedAndNotTaken, 0) - @Days,
				TakenNotTakenDate = GETDATE()
                WHERE EmployeeId = @Employeeid
                  AND LeaveTypeId = @leaveTypeId
                  AND HrSettingDetaiId = @HrSettingDetailId
                  AND EntitlementStatus = 1

            END
            
			ELSE
            BEGIN

			INSERT INTO HR.TakenNotTakenTracing (CompanyId ,EmployeeId ,leaveTypeId ,entitlementType ,startdate ,todaydate ,Days ,Hours ,approvedDate ,CurrentApprovedAndTaken ,
			CurrentApprovedAndNotTaken ,TakenNotTakenDate ,UpdateApprovedAndTaken ,UpdateApprovedAndNotTaken ,CreatedDate)

             SELECT @companyId, @Employeeid, @leaveTypeId, @entitlementType, @startdate, @toDayDate,@Days, @Hours, @approvedDate,
			 ApprovedAndTaken , ApprovedAndNotTaken ,TakenNotTakenDate ,ISNULL(ApprovedAndTaken, 0) + @Hours, ISNULL(ApprovedAndNotTaken, 0) - @Hours,GETDATE()
				FROM HR.LeaveEntitlement
                WHERE EmployeeId = @Employeeid
                  AND LeaveTypeId = @leaveTypeId
                  AND HrSettingDetaiId = @HrSettingDetailId
                  AND EntitlementStatus = 1

				UPDATE HR.LeaveEntitlement
				SET ApprovedAndTaken = ISNULL(ApprovedAndTaken, 0) + @Hours, ApprovedAndNotTaken = ISNULL(ApprovedAndNotTaken, 0) - @Hours,
				TakenNotTakenDate = GETDATE()
                WHERE EmployeeId = @Employeeid
                  AND LeaveTypeId = @leaveTypeId
                  AND HrSettingDetaiId = @HrSettingDetailId
                  AND EntitlementStatus = 1

            END
        END

        SET @Counter = @Counter + 1
    END

    DROP TABLE #LeaveApplications;


   	INSERT INTO Common.JobStatus (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus)
	VALUES (NEWID(),'HRCursor', 'Taken Not Taken Job', 'Job', 'Taken Not Taken Job', @StartTime, GETDATE(), NULL, NULL, 'Completed');

COMMIT TRANSACTION
END TRY

BEGIN CATCH
        ROLLBACK TRANSACTION;

DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
RAISERROR (@ErrorMessage, 16, 1);
INSERT INTO Common.JobStatus  
    (Id, Module, Jobname, [Type], [Purpose], [StartDate], [EndDate], RecordsEffeted, Remarks, JobStatus)
VALUES 
    (NEWID(),'HRCursor', 'Taken Not Taken Job', 'Job', 'Taken Not Taken Job', @StartTime, GETDATE(), NULL, 'Failed: '+ @ErrorMessage, 'Failed');

END CATCH
END;
GO
