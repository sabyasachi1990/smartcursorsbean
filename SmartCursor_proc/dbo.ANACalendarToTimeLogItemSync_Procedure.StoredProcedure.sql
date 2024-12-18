USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ANACalendarToTimeLogItemSync_Procedure]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[ANACalendarToTimeLogItemSync_Procedure]  ----->>> EXEC dbo.ANACalendarToTimeLogItemSync_Procedure 
AS
BEGIN

DROP TABLE IF EXISTS #TimeLogItem
DROP TABLE IF EXISTS #TimeLogItemData
DROP TABLE IF EXISTS #NewCalendarTimeLogItem
DROP TABLE IF EXISTS #OldCalendarTimeLogItemRecords
DROP TABLE IF EXISTS #Detail
DROP TABLE IF EXISTS #Child

CREATE TABLE #TimeLogItem
(
	[Id] [uniqueidentifier] NOT NULL Primary key,
	[CompanyId] [bigint] NOT NULL,
	[Type] [nvarchar](40) NULL,
	[SubType] [nvarchar](500) NULL,
	[ChargeType] [nvarchar](20) NOT NULL,
	[SystemType] [nvarchar](20) NULL,
	[SystemId] [uniqueidentifier] NULL,
	[IsSystem] [bit] NULL DEFAULT (0),
	[ApplyToAll] [bit] NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL DEFAULT (1),
	[Hours] [decimal](17, 2) NOT NULL DEFAULT (0),
	[Days] [decimal](17, 2) NOT NULL DEFAULT (0),
	[FirstHalfFromTime] [time](7) NULL,
	[FirstHalfToTime] [time](7) NULL,
	[FirstHalfTotalHours] [time](7) NULL,
	[SecondHalfFromTime] [time](7) NULL,
	[SecondHalfToTime] [time](7) NULL,
	[SecondHalfTotalHours] [time](7) NULL,
	[IsMain] [bit] NULL,
	[TimeType] [nvarchar](50) NULL,
	[ActualHours] [decimal](17, 2) NULL,
	[SystemSubTypeStatus] [nvarchar](20) NULL
)


-------->>>> Existing Records
SELECT * INTO #OldCalendarTimeLogItemRecords 
FROM (
	SELECT 
		CompanyId,Id,SystemId,SubType,IsMain,StartDate,EndDate,ROW_NUMBER()OVER (PARTITION BY CompanyId, YEAR(StartDate),SubType ORDER BY IsMain DESC,StartDate ASC,EndDate DESC) AS OldRankOrder 
	FROM [Common].[ANACalendarTimeLogItem]
	WHERE YEAR(StartDate) >= 2024 --AND CompanyId IN (1)
	) AS A 

-----===============================================================================================================================-------

INSERT INTO #TimeLogItem 
SELECT
	NEWID() AS Id, A.CompanyId, A.CalendarType AS [Type], A.Name AS SubType,A.ChargeType,'Calender' AS SystemType,  
    A.Id AS SystemId, 1 as IsSystem,
    CASE WHEN  A.ApplyTo ='All' THEN 1 ELSE 0 END AS ApplyToAll,  A.FromDateTime as StartDate,  A.ToDateTime as EndDate, A.Remarks,
    NULL AS RecOrder, A.UserCreated, GETDATE() AS CreatedDate, CAST(NULL AS Nvarchar(300)) AS ModifiedBy, cast(NULL as datetime2) AS ModifiedDate, A.[Version], A.Status, Hours, Days,
    NULL AS  FirstHalfFromTime,NULL AS FirstHalfToTime,NULL AS FirstHalfTotalHours, NULL AS SecondHalfFromTime,NULL AS SecondHalfToTime,
    NULL AS SecondHalfTotalHours,1 AS IsMain, NULL AS TimeType,NULL AS ActualHours,NULL AS SystemSubTypeStatus
FROM Common.Calender AS A 
INNER JOIN 
      (
        SELECT CalenderId, SUM(Hours) AS Hours, 
        SUM(CASE 
            WHEN Hours != 8 THEN Hours/8
            WHEN Hours = 8 THEN 1
          END
          ) AS days
        FROM Common.CalenderSchedule  
        GROUP BY CalenderId
      ) AS B 
      ON B.CalenderId = A.Id
WHERE Status = 1 AND YEAR(FromDateTime) >= 2024 --AND CompanyId IN (1) --AND A.Id = 'F31EEE24-CD1C-4AD3-B834-1F5C6FCB8030' 



SELECT * INTO #TimeLogItemData FROM (
	SELECT * FROM #TimeLogItem

	UNION ALL

	SELECT NEWID() AS Id, A.CompanyId, A.CalendarType AS [Type], A.Name AS SubType, A.ChargeType,'Calender' AS SystemType, 
    	C.Id AS SystemId, 1 as IsSystem,
    	CASE WHEN  A.ApplyTo ='All' THEN 1 ELSE 0 END AS ApplyToAll,  B.StartDate,  B.EndDate, A.Remarks,
    	NULL AS RecOrder, A.UserCreated, GETDATE() AS CreatedDate, CAST(NULL AS Nvarchar(300)) AS ModifiedBy, cast(NULL as datetime2) AS ModifiedDate, A.[Version], A.Status,B.Hours,
    	CASE WHEN B.Hours != 8 THEN B.Hours/8 WHEN B.Hours = 8 THEN 1 ELSE 1 END AS Days,
    	B.FirstHalfFromTime, B.FirstHalfToTime,B.FirstHalfTotalHours, B.SecondHalfFromTime,B.SecondHalfToTime,
    	B.SecondHalfTotalHours,0 AS IsMain, B.TimeType,NULL AS ActualHours,NULL AS SystemSubTypeStatus
	FROM Common.Calender AS A 
	INNER JOIN  Common.CalenderSchedule AS B  ON B.CalenderId = A.Id
	INNER JOIN  #TimeLogItem AS C ON C.SystemId = A.Id
	WHERE A.Status = 1 AND YEAR(A.FromDateTime) >= 2024 --AND CompanyId IN (2058,1)
) AS A
ORDER BY CompanyId,StartDate, [Type], A.IsMain Desc


-------------------------------------- Insert Into Analytics TimeLogItem and Details Tables --------------------------------------

--SELECT * INTO #NewCalendarTimeLogItem
--FROM (
--SELECT DISTINCT ROW_NUMBER()OVER (PARTITION BY CompanyId, YEAR(StartDate),SubType ORDER BY IsMain DESC,StartDate ASC,EndDate DESC) AS NewRankOrder, 
--	A.Id, A.CompanyId, A.Type, A.SubType, A.ChargeType, A.SystemType, A.SystemId,
--	A.IsSystem, A.ApplyToAll, A.StartDate, A.EndDate, A.Remarks, 
--	A.RecOrder, A.UserCreated, A.CreatedDate, A.ModifiedBy, A.ModifiedDate, A.Version, A.Status, A.Hours, A.Days, A.FirstHalfFromTime, 
--	A.FirstHalfToTime, A.FirstHalfTotalHours, A.SecondHalfFromTime, A.SecondHalfToTime, A.SecondHalfTotalHours, A.IsMain, 
--	A.TimeType, A.ActualHours, A.SystemSubTypeStatus
--FROM #TimeLogItemData AS A
--) AS B

SELECT * INTO #NewCalendarTimeLogItem
FROM (
SELECT DISTINCT ROW_NUMBER()OVER (PARTITION BY A.CompanyId, YEAR(A.StartDate),A.SubType ORDER BY A.IsMain DESC,A.StartDate ASC,A.EndDate DESC) AS NewRankOrder, 
	CASE WHEN B.Id IS NOT NULL THEN B.Id ELSE A.Id END AS Id, A.CompanyId, A.Type, A.SubType, A.ChargeType, A.SystemType, 
	CASE WHEN B.SystemId IS NOT NULL THEN B.SystemId ELSE A.SystemId END AS SystemId,
	A.IsSystem, A.ApplyToAll, A.StartDate, A.EndDate, A.Remarks, 
	A.RecOrder, A.UserCreated, A.CreatedDate, A.ModifiedBy, A.ModifiedDate, A.Version, A.Status, A.Hours, A.Days, A.FirstHalfFromTime, 
	A.FirstHalfToTime, A.FirstHalfTotalHours, A.SecondHalfFromTime, A.SecondHalfToTime, A.SecondHalfTotalHours, A.IsMain, 
	A.TimeType, A.ActualHours, A.SystemSubTypeStatus
FROM #TimeLogItemData AS A
LEFT JOIN [Common].[TimeLogItem] AS B ON B.CompanyId = A.CompanyId AND B.SubType = A.SubType AND A.SystemType = B.SystemType 
AND CAST(A.StartDate AS Date) = CAST(B.StartDate as Date) AND CAST(A.EndDate AS Date) = CAST(B.EndDate as Date) AND A.IsMain = (CASE WHEN B.FirstHalfFromTime IS NULL THEN 1 ELSE 0 END)
) AS B

----->> Update
--SELECT A.Id, A.SubType, A.StartDate, B.StartDate,A.EndDate, B.EndDate, A.IsMain, B.IsMain,B.NewRankOrder,A.OldRankOrder
--FROM #OldCalendarTimeLogItemRecords AS A
--INNER JOIN #NewCalendarTimeLogItem AS B 
--	ON B.CompanyId= A.CompanyId AND B.SubType = A.SubType AND YEAR(B.StartDate) =  YEAR(B.StartDate) AND A.OldRankOrder = B.NewRankOrder
--ORDER BY A.CompanyId,  A.SubType, A.StartDate ,A.IsMain desc;

UPDATE A SET 
	A.ChargeType = B.ChargeType, A.SystemType = B.SystemType, 
	A.IsSystem = B.IsSystem, A.ApplyToAll = B.ApplyToAll, A.StartDate = B.StartDate, A.EndDate = B.EndDate, A.Remarks = B.Remarks, 
	A.RecOrder = B.RecOrder, A.UserCreated = B.UserCreated, A.CreatedDate =B.CreatedDate, A.ModifiedBy = B.ModifiedBy, A.ModifiedDate = B.ModifiedDate, 
	A.Version = B.Version, A.Status = B.Status, A.Hours = B.Hours, A.Days = B.Days, A.FirstHalfFromTime = B.FirstHalfFromTime, 
	A.FirstHalfToTime = A.FirstHalfToTime, A.FirstHalfTotalHours = B.FirstHalfTotalHours, A.SecondHalfFromTime = B.SecondHalfFromTime, A.SecondHalfToTime = B.SecondHalfToTime, A.SecondHalfTotalHours = B.SecondHalfTotalHours, A.IsMain = B.IsMain, 
	A.TimeType = B.TimeType, A.ActualHours = B.ActualHours, A.SystemSubTypeStatus = B.SystemSubTypeStatus
FROM Common.ANACalendarTimeLogItem AS A
INNER JOIN (
				SELECT A.Id,B.CompanyId, B.Type, B.SubType, B.ChargeType, B.SystemType, B.SystemId,
					B.IsSystem, B.ApplyToAll, B.StartDate, B.EndDate, B.Remarks, 
					B.RecOrder, B.UserCreated, B.CreatedDate, B.ModifiedBy, B.ModifiedDate, B.Version, B.Status, B.Hours, B.Days, B.FirstHalfFromTime, 
					B.FirstHalfToTime, B.FirstHalfTotalHours, B.SecondHalfFromTime, B.SecondHalfToTime, B.SecondHalfTotalHours, B.IsMain, 
					B.TimeType, B.ActualHours, B.SystemSubTypeStatus
				FROM #OldCalendarTimeLogItemRecords AS A
				INNER JOIN #NewCalendarTimeLogItem AS B 
					ON B.CompanyId= A.CompanyId AND B.SubType = A.SubType AND YEAR(B.StartDate) =  YEAR(B.StartDate) AND A.OldRankOrder = B.NewRankOrder
					---ORDER BY A.CompanyId,  A.SubType, A.StartDate ,A.IsMain desc
			) AS B ON B.Id = A.Id


----->> Insert
--SELECT A.SubType,A.StartDate, B.StartDate,A.EndDate, B.EndDate, A.IsMain, B.IsMain,a.NewRankOrder,b.OldRankOrder
--FROM #NewCalendarTimeLogItem AS A
--LEFT JOIN #OldCalendarTimeLogItemRecords AS B 
--	ON B.CompanyId= A.CompanyId AND B.SubType = A.SubType AND YEAR(B.StartDate) =  YEAR(B.StartDate) AND B.OldRankOrder = A.NewRankOrder
--ORDER BY A.CompanyId,  A.SubType, A.StartDate ,A.IsMain desc;

INSERT INTO [Common].[ANACalendarTimeLogItem]
SELECT
	A.Id, A.CompanyId, A.Type, A.SubType, A.ChargeType, A.SystemType, A.SystemId,
	A.IsSystem, A.ApplyToAll, A.StartDate, A.EndDate, A.Remarks, 
	A.RecOrder, A.UserCreated, A.CreatedDate, A.ModifiedBy, A.ModifiedDate, A.Version, A.Status, A.Hours, A.Days, A.FirstHalfFromTime, 
	A.FirstHalfToTime, A.FirstHalfTotalHours, A.SecondHalfFromTime, A.SecondHalfToTime, A.SecondHalfTotalHours, A.IsMain, 
	A.TimeType, A.ActualHours, A.SystemSubTypeStatus
FROM #NewCalendarTimeLogItem AS A
LEFT JOIN #OldCalendarTimeLogItemRecords AS B 
	ON B.CompanyId = A.CompanyId AND B.SubType = A.SubType AND YEAR(B.StartDate) =  YEAR(B.StartDate) AND B.OldRankOrder = A.NewRankOrder
	WHERE B.Id IS NULL
ORDER BY A.CompanyId,  A.SubType, A.StartDate ,A.IsMain desc;

----->> Delete
DELETE  FROM Common.ANACalendarTimeLogItemDetail
WHERE TimeLogItemId IN (
							SELECT DISTINCT Id
							FROM (
									SELECT B.Id--,A.SubType,A.StartDate, B.StartDate,A.EndDate, B.EndDate, A.IsMain, B.IsMain,a.NewRankOrder,b.OldRankOrder
									FROM #NewCalendarTimeLogItem AS A
									RIGHT JOIN #OldCalendarTimeLogItemRecords AS B 
										ON B.CompanyId= A.CompanyId AND B.SubType = A.SubType AND YEAR(B.StartDate) =  YEAR(B.StartDate) AND B.OldRankOrder = A.NewRankOrder
										WHERE A.Id IS NULL
								) AS A
						)
--ORDER BY A.CompanyId,  A.SubType, A.StartDate ,A.IsMain desc;

----->> Delete 
DELETE  FROM Common.ANACalendarTimeLogItem
WHERE Id IN (
				SELECT DISTINCT Id
				FROM (
						SELECT B.Id--,A.SubType,A.StartDate, B.StartDate,A.EndDate, B.EndDate, A.IsMain, B.IsMain,a.NewRankOrder,b.OldRankOrder
						FROM #NewCalendarTimeLogItem AS A
						RIGHT JOIN #OldCalendarTimeLogItemRecords AS B 
							ON B.CompanyId= A.CompanyId AND B.SubType = A.SubType AND YEAR(B.StartDate) =  YEAR(B.StartDate) AND B.OldRankOrder = A.NewRankOrder
							WHERE A.Id IS NULL
					) AS A
			)
--ORDER BY A.CompanyId,  A.SubType, A.StartDate ,A.IsMain desc;


--------->>>> Detail
SELECT Id,SystemId,ApplyToAll,CompanyId,SubType INTO #Detail
FROM (
		SELECT A.Id, A.SystemId,B.ApplyToAll, A.CompanyId, A.SubType
		FROM #OldCalendarTimeLogItemRecords AS A
		INNER JOIN #NewCalendarTimeLogItem AS B 
			ON B.CompanyId= A.CompanyId AND B.SubType = A.SubType AND YEAR(B.StartDate) =  YEAR(B.StartDate) AND A.OldRankOrder = B.NewRankOrder

		UNION ALL

		SELECT
			A.Id, a.SystemId,A.ApplyToAll, A.CompanyId, A.SubType
		FROM #NewCalendarTimeLogItem AS A
		LEFT JOIN #OldCalendarTimeLogItemRecords AS B 
			ON B.CompanyId = A.CompanyId AND B.SubType = A.SubType AND YEAR(B.StartDate) =  YEAR(B.StartDate) AND B.OldRankOrder = A.NewRankOrder
			WHERE B.Id IS NULL
	) AS A


SELECT * INTO #child 
FROM (
SELECT NEWID() as Id, CompanyId, Id AS TimeLogItemId,SubType,CASE WHEN ApplyToAll != 1 THEN EmployeeId WHEN ApplyToAll = 1 THEN EmpId ELSE EmpId END AS EmployeeId, NULL as IsNew
FROM (
        SELECT DISTINCT C.Id,C.SubType,a.CompanyId, A.Id AS EmpId, B.EmployeeId,C.ApplyToAll FROM Common.Employee AS A
		INNER JOIN [Common].[ANACalendarTimeLogItem] AS C ON C.CompanyId = A.CompanyId
        LEFT JOIN (SELECT DISTINCT B.Name, A.MasterId,A.EmployeeId FROM Common.CalenderDetails AS A
					INNER JOIN Common.Calender AS B ON B.Id = A.MasterId) AS B ON B.EmployeeId = A.Id AND C.SubType = B.Name
			----WHERE A.Status =1 AND A.CompanyId = 689 AND YEAR(StartDate) = 2024  AND SubType  = 'Calendar Testing'
	) AS A
	WHERE CASE WHEN ApplyToAll != 1 THEN EmployeeId WHEN ApplyToAll = 1 THEN EmpId ELSE EmpId END IS NOT NULL
) AS A
ORDER BY CompanyId,EmployeeId,A.TimeLogItemId

-------->>> Fetching Data to insert into TimeLogItemDetail  by comparing it with Existing TimeLogItemDetail Data.
INSERT INTO [Common].[ANACalendarTimeLogItemDetail] (Id,TimeLogItemId,EmployeeId,IsNew)
SELECT DISTINCT 
	CASE WHEN B.Id IS NOT NULL THEN B.Id ELSE A.Id END AS Id,
	A.TimeLogItemId,a.EmployeeId,a.IsNew
FROM #child AS A
LEFT JOIN [Common].[ANACalendarTimeLogItemDetail] AS B ON B.TimeLogItemId = A.TimeLogItemId AND A.EmployeeId = B.EmployeeId
WHERE B.Id IS NULL

END

----->>> EXEC dbo.ANACalendarToTimeLogItemSync_Procedure 
GO
