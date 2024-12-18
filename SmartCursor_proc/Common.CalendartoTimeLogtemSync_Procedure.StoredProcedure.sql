USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[CalendartoTimeLogtemSync_Procedure]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create     PROCEDURE [Common].[CalendartoTimeLogtemSync_Procedure]
(@CalendarId UniqueIdentifier,@CompanyId BigInt)

AS
BEGIN
Begin Transaction
BEGIN TRY
DECLARE @ApplyTo Nvarchar(10) = (SELECT ApplyTo FROM Common.Calender (NOLOCK) WHERE Id = @CalendarId),
		@IUDTimeLogItemId uniqueidentifier = (SELECT Id FROM Common.TimeLogItem (NOLOCK)  WHERE SystemId = @CalendarId)

DECLARE @TimeLogItemId UniqueIdentifier = NewId();

------------------------------------------->>> Comaprision between Old and New Records.
SELECT * INTO #MainTableData FROM (
	SELECT *,RANK()OVER (ORDER BY StartDate ASC,EndDate DESC) AS ExistingRankOrder  
	FROM (
			SELECT Id,SystemId,StartDate,EndDate FROM  Common.TimeLogItem (NOLOCK) WHERE SystemId = @CalendarId AND CompanyId= @CompanyId
			UNION ALL
			SELECT Id,SystemId,StartDate,EndDate FROM  Common.TimeLogItem (NOLOCK) WHERE SystemId = @IUDTimeLogItemId AND CompanyId= @CompanyId
		) AS A
	) AS A

------------------ DELETE FROM TimeLogItem And TimeLogItemDetail
DELETE FROM Common.TimeLogItemDetail 
WHERE TimeLogItemId IN (
						 SELECT Id FROM #MainTableData
					   )

-------------------------------------------------------->>>> 
SELECT * INTO #NewDataTimeLogItem 
FROM (
	SELECT *,RANK()OVER (ORDER BY StartDate ASC,EndDate DESC) AS NewRankOrder 
	FROM (
		SELECT @TimeLogItemId AS Id, A.CompanyId, A.CalendarType AS [Type], A.Name AS SubType,A.ChargeType,'Calender' AS SystemType,  
		A.Id AS SystemId, 1 as IsSystem,
		CASE WHEN  A.ApplyTo ='All' THEN 1 ELSE 0 END AS ApplyToAll,  A.FromDateTime as StartDate,  A.ToDateTime as EndDate, A.Remarks,
		 NULL AS RecOrder, A.UserCreated, GETDATE() AS CreatedDate, CAST(NULL AS Nvarchar(300)) AS ModifiedBy, cast(NULL as datetime2) AS ModifiedDate, A.[Version], A.Status, Hours, Days,
		 NULL AS  FirstHalfFromTime,NULL AS FirstHalfToTime,NULL AS FirstHalfTotalHours, NULL AS SecondHalfFromTime,NULL AS SecondHalfToTime,
		 NULL AS SecondHalfTotalHours,1 AS IsMain, NULL AS TimeType,NULL AS ActualHours,NULL AS SystemSubTypeStatus
		FROM Common.Calender AS A (NOLOCK)
		INNER JOIN 
			(
				SELECT CalenderId, SUM(Hours) AS Hours, 
				SUM(CASE 
						WHEN Hours != 8 THEN Hours/8
						WHEN Hours = 8 THEN 1
					END
					) AS days
				FROM Common.CalenderSchedule  (NOLOCK)
				WHERE CalenderId = @CalendarId
				GROUP BY CalenderId
			) AS B 
			ON B.CalenderId = A.Id
		WHERE A.Id = @CalendarId AND a.CompanyId = @CompanyId

		UNION ALL

		SELECT NEWID() AS Id, A.CompanyId, A.CalendarType AS [Type], A.Name AS SubType, A.ChargeType,'Calender' AS SystemType, 
		@TimeLogItemId AS SystemId, 1 as IsSystem,
		CASE WHEN  A.ApplyTo ='All' THEN 1 ELSE 0 END AS ApplyToAll,  B.StartDate,  B.EndDate, A.Remarks,
		 NULL AS RecOrder, A.UserCreated, GETDATE() AS CreatedDate, CAST(NULL AS Nvarchar(300)) AS ModifiedBy, cast(NULL as datetime2) AS ModifiedDate, A.[Version], A.Status,B.Hours,
		 CASE WHEN Hours != 8 THEN Hours/8 WHEN Hours = 8 THEN 1 ELSE 1 END AS Days,
		 B.FirstHalfFromTime, B.FirstHalfToTime,B.FirstHalfTotalHours, B.SecondHalfFromTime,B.SecondHalfToTime,
		 B.SecondHalfTotalHours,0 AS IsMain, B.TimeType,NULL AS ActualHours,NULL AS SystemSubTypeStatus
		FROM Common.Calender AS A (NOLOCK)
		INNER JOIN  Common.CalenderSchedule AS B (NOLOCK)
			ON B.CalenderId = A.Id
		WHERE A.Id = @CalendarId AND a.CompanyId = @CompanyId
		) AS A
	) AS B


----->>> INSERT
INSERT INTO Common.TimeLogItem
SELECT 
A.Id, A.CompanyId, A.Type, A.SubType, A.ChargeType, A.SystemType, CASE WHEN @IUDTimeLogItemId IS NULL THEN  A.SystemId ELSE @IUDTimeLogItemId END AS SystemId,
A.IsSystem, A.ApplyToAll, A.StartDate, A.EndDate, A.Remarks, 
A.RecOrder, A.UserCreated, A.CreatedDate, A.ModifiedBy, A.ModifiedDate, A.Version, A.Status, A.Hours, A.Days, A.FirstHalfFromTime, 
A.FirstHalfToTime, A.FirstHalfTotalHours, A.SecondHalfFromTime, A.SecondHalfToTime, A.SecondHalfTotalHours, A.IsMain, 
A.TimeType, A.ActualHours, A.SystemSubTypeStatus
FROM #NewDataTimeLogItem AS A
FULL JOIN  #MainTableData AS B
ON B.ExistingRankOrder = A.NewRankOrder
WHERE B.ExistingRankOrder IS NULL

------->>> UPDATE
UPDATE A SET
	A.Type = B.Type, A.SubType = B.SubType, A.ChargeType = B.ChargeType, A.SystemType = B.SystemType, A.SystemId = B.SystemId ,
	A.IsSystem = B.IsSystem, A.ApplyToAll = B.ApplyToAll, A.StartDate = B.StartDate , A.EndDate = B.EndDate , A.Remarks = B.Remarks ,
	A.RecOrder = B.RecOrder, A.Status = B.Status, A.Hours = B.Hours, A.Days = B.Days, A.FirstHalfFromTime = B.FirstHalfFromTime ,
	A.FirstHalfToTime = B.FirstHalfToTime, A.FirstHalfTotalHours = B.FirstHalfTotalHours, A.SecondHalfFromTime = B.SecondHalfFromTime ,
	A.SecondHalfToTime = B.SecondHalfToTime, A.SecondHalfTotalHours = B.SecondHalfTotalHours, A.IsMain = B.IsMain, A.TimeType = B.TimeType 
FROM Common.TimeLogItem AS A
JOIN (
		SELECT 
		B.Id,A.Type, A.SubType, A.ChargeType, A.SystemType, 
		CASE 
			WHEN B.ExistingRankOrder = 1 AND A.NewRankOrder = 1 THEN @CalendarId
			WHEN B.ExistingRankOrder != 1 AND @IUDTimeLogItemId IS NOT NULL THEN @IUDTimeLogItemId
			WHEN B.ExistingRankOrder IS NULL AND  A.NewRankOrder = 1 THEN @CalendarId
			WHEN B.ExistingRankOrder != 1 AND @IUDTimeLogItemId IS NULL THEN A.SystemId
		END AS SystemId,
		A.IsSystem, A.ApplyToAll, A.StartDate, A.EndDate, A.Remarks, A.RecOrder, A.UserCreated, A.CreatedDate, A.ModifiedBy, 
		A.ModifiedDate, A.Version, A.Status, A.Hours, A.Days, A.FirstHalfFromTime, A.FirstHalfToTime, A.FirstHalfTotalHours, 
		A.SecondHalfFromTime, A.SecondHalfToTime, A.SecondHalfTotalHours, A.IsMain, A.TimeType, A.ActualHours, A.SystemSubTypeStatus
		FROM #NewDataTimeLogItem AS A
		INNER JOIN  #MainTableData AS B
		ON B.ExistingRankOrder = A.NewRankOrder
	) AS B ON B.Id = A.Id

------->>> DELETE
DELETE FROM Common.TimeLogItem
WHERE Id IN(
			SELECT B.Id
			FROM #NewDataTimeLogItem AS A
			FULL JOIN  #MainTableData AS B
			ON B.ExistingRankOrder = A.NewRankOrder
			WHERE A.Id IS NULL
			)

SET @IUDTimeLogItemId = (SELECT Id FROM Common.TimeLogItem (NOLOCK)  WHERE SystemId = @CalendarId)

--------->>> Insert Into TimeLogItemDetail
INSERT INTO Common.TimeLogItemDetail
SELECT NEWID() as Id,* 
FROM (
		SELECT DISTINCT A.Id AS TimeLogItemId,
		CASE 
			WHEN @ApplyTo != 'All' THEN B.EmployeeId
			WHEN @ApplyTo = 'All' THEN B.EmpId
			ELSE B.EmpId
		END AS EmployeeId,
		NULL AS IsNew 
		FROM (SELECT Id FROM Common.TimeLogItem  WHERE SystemId IN (@CalendarId,@IUDTimeLogItemId) ) AS A 
		CROSS JOIN 
		(
				SELECT A.Id AS EmpId, B.EmployeeId FROM Common.Employee AS A
				LEFT JOIN Common.CalenderDetails AS B ON B.EmployeeId = A.Id AND MasterId = @CalendarId
				WHERE  A.CompanyId = @CompanyId
			) AS B 
	) AS A
WHERE EmployeeId IS NOT NULL
ORDER BY A.TimeLogItemId

DROP TABLE #NewDataTimeLogItem
DROP TABLE #MainTableData
Commit Transaction;
		END TRY
		BEGIN CATCH
			RollBack Transaction;
			DECLARE
			@ErrorMessage NVARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState INT;
			SELECT
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
		END CATCH
END

GO
