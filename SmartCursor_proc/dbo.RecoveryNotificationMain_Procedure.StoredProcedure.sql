USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RecoveryNotificationMain_Procedure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

----->>> EXEC dbo.RecoveryNotificationMain_Procedure

CREATE     PROCEDURE [dbo].[RecoveryNotificationMain_Procedure]
AS 
BEGIN

---->>> DECLARE @CaseId UniqueIdentifier = '9459127A-8C6A-4126-816B-02488B0F0C29'--'1CCFF4A1-8648-4CAD-8D04-05786A2C928B'--'D43F8497-063F-4873-9790-67A5B4596F37'

DECLARE @OtherRecipients TABLE (CompanyId BigInt, Type Nvarchar(30) ,ScreenAction Nvarchar(50),NotificationUserId BigInt Null,OtherRecipients Nvarchar(2000), OtherEmailRecipient Nvarchar(2000),CompanyUserIdNullCompanyId BigInt Null)

-------------->>> Notification Settings
SELECT * INTO #NotificationSettings FROM (
SELECT 
	CompanyId,IsOn,CompanyUserId,ScreenAction, Type ,NotificationTemplate, NotificationSubject, OtherRecipients,OtherEmailRecipient
FROM Notification.NotificationSettings
WHERE CursorName = 'Workflow Cursor' AND ScreenName = 'Recovery' AND ScreenAction IN ('Planned Recovery','Actual Recovery')
) AS A

--SELECT * FROM #NotificationSettings WHERE CompanyId = 1 --AND CompanyUserId = 55
-------===============================================================================================================================------
-------------->>> Other Recipients
----->> Functionaly for OtherRecipients:
----->> For Planned Recovery: 
----->> 	If IsOn =1 and CompanyUserId IsNull for companyId then have to fetch other recipients for that company where companyUserId is Null and have to split the coma seperated values 
----->> 	and have to check each username in common.CompanyUserTable, If exists then have to consider the username else ignore.

----->> For Actual Recovery:
----->> 	If IsOn =1 for companyId then have to fetch other recipients  and have to fetch records for that company where companyUserId is Null and have to split the coma seperated values 
----->> 	and have to check each username in common.CompanyUserTable, If exists then have to consider the username else ignore.


INSERT INTO @OtherRecipients
SELECT A.CompanyId,a.Type, A.ScreenAction,A.NotificationUserId,a.OtherRecipients,a.OtherEmailRecipient, b.CompanyUserIdNullCompanyId 
FROM ( 
		SELECT A.CompanyId,A.Type, A.ScreenAction,A.NotificationUserId,STRING_AGG(A.OtherRecipient,',') AS OtherRecipients,OtherEmailRecipient 
		FROM 
			(
				SELECT DISTINCT A.CompanyId,A.Type, ScreenAction,b.Id AS CompanyUserId,NotificationUserId,OtherRecipient,OtherEmailRecipient
				FROM (
					SELECT DISTINCT CompanyId, Type,ScreenAction, TRIM(value) AS OtherRecipient,OtherEmailRecipient,CompanyUserId AS NotificationUserId
					FROM #NotificationSettings as a(NOLOCK)  CROSS APPLY STRING_SPLIT(OtherRecipients, ',')
					WHERE  IsOn = 1 
					) AS A
				INNER JOIN Common.CompanyUser AS B ON B.userName = A.OtherRecipient AND B.CompanyId = A.CompanyId
			)
		AS A
		WHERE NotificationUserId IS NULL
		GROUP BY A.CompanyId,A.ScreenAction,A.NotificationUserId,OtherEmailRecipient,a.Type
	) AS A
LEFT JOIN 
	(SELECT DISTINCT  CompanyId as CompanyUserIdNullCompanyId,CompanyUserId FROM #NotificationSettings 
	 WHERE CompanyUserId IS NULL 
	) AS B ON B.CompanyUserIdNullCompanyId = A.CompanyId
ORDER BY a.CompanyId,ScreenAction

------>>> NOTE:   1.For Planned Recovery consider records where CompanyUserIdNullCompanyId is Not Null and NotificationUserId Is Null, "pass both in where Condition"
------>>>		  2.For Actual recovery consider records where NotificationUserId Is Null, there is no need for considering CompanyUserIdNullCompanyId, "pass only NotificationUserId in Where Condition"
--SELECT * FROM @OtherRecipients

-------===============================================================================================================================------

SELECT * INTO #RawData 
FROM (
		SELECT  
			S.Id AS ScheduleNewId, CG.Id as CaseId, ISNULL(CG.TargettedRecovery,0) AS TargettedRecovery, CG.Stage, Cg.CaseNumber, ISNULL(cg.Fee,0) AS CaseFee,
			CG.Name as ClientName, CG.CompanyId,ST.EmployeeId,ISNULL(ST.PlannedHours, 0) AS PlannedHours,
			ISNULL(ST.ChargeoutRate, 0) ChargeoutRate,isnull(ST.OverRunHours, 0) AS OverRunHours
		FROM WorkFlow.CaseGroup AS CG (NOLOCK)
		INNER JOIN WorkFlow.ScheduleNew AS S (NOLOCK) ON Cg.Id = s.CaseId 
		INNER JOIN WorkFlow.ScheduleTaskNew AS ST (NOLOCK) ON ST.CaseId = CG.Id
		WHERE (Stage = 'Assigned' OR Stage = 'In-Progress')  ---AND CG.Id = @CaseId
	) AS A

----SELECT * FROM #RawData
-------===============================================================================================================================------

------------->>>> Summazired data from #RawData
SELECT * INTO #SummarizedData  FROM (
SELECT CompanyId,CaseId,ScheduleNewId,CaseNumber,CaseFee,ClientName, Stage,EmployeeId, (SUM(PlannedHours)/60.0 * ChargeoutRate) AS PlannedCostnew,
	(SUM(PlannedHours)+SUM(OverRunHours))/60.0*ChargeoutRate AS PlannedCost,
	(SUM(OverRunHours) / 60.0) * (SUM(OverRunHours)) AS OverrunCost,
	TargettedRecovery
FROM #RawData
---WHERE Caseid = @CaseId
GROUP BY CaseId,CaseNumber, EmployeeId, ChargeoutRate,CaseFee,TargettedRecovery,Stage,CompanyId,ClientName,ScheduleNewId
) AS A 

----SELECT * FROM #SummarizedData
-------===============================================================================================================================------

------------->>>> Planned Cost
SELECT * INTO #PlannedCost 
FROM (
		SELECT CompanyId,CaseId,ScheduleNewId,CaseNumber,Stage,CaseFee,ClientName,SUM(PlannedCost) AS PlannedCost, SUM(FeeAllocationPer) AS FeeAllocationPer, SUM(FeeAllocation) AS FeeAllocation,TargettedRecovery
		FROM (
				SELECT CompanyId,A.CaseId,A.ScheduleNewId,CaseNumber,Stage, CaseFee,ClientName,EmployeeId,PlannedCost, ISNULL((PlannedCostnew / NULLIF((CasePlannedCost - CaseOverrunCost), 0)), 0) * 100 AS FeeAllocationPer, 
				CAST(ISNULL(((ISNULL((PlannedCostnew / NULLIF((CasePlannedCost - CaseOverrunCost), 0)), 0) * 100) * (CaseFee)) / 100, 0) AS DECIMAL(28, 9)) AS FeeAllocation,
				TargettedRecovery
				FROM #SummarizedData AS A
				INNER JOIN 
					( SELECT CaseId,SUM(PlannedCost) AS CasePlannedCost, SUM(OverrunCost) AS CaseOverrunCost FROM #SummarizedData GROUP BY CaseId) AS B 
				ON B.CaseId = A.CaseId
		) AS A
		GROUP BY CaseId,CaseFee,TargettedRecovery,Stage,CompanyId,CaseNumber,ClientName,ScheduleNewId
	) AS A
ORDER BY CaseId
-------===============================================================================================================================------

------------->>>> Actual Cost
SELECT * INTO #ActualCost 
FROM (
		SELECT SystemId AS CaseId, SUM(ISNULL(ActCost, 0)) AS ActCost
		FROM (
			SELECT SystemId, EmployeeId, ChargeOutRate, ((Hours / 60.0) * ChargeOutRate) AS ActCost
			FROM (
				SELECT SystemId, tl.EmployeeId, sum(((DATEPART(HOUR, Duration) * 60) + ((DATEPART(MINUTE, Duration))))) AS Hours, ISNULL(TLD.ChargeoutRate, 0) ChargeoutRate
				FROM Common.TimeLog AS TL (NOLOCK)
				INNER JOIN Common.TimeLogItem AS TLI (NOLOCK) ON TLI.Id = TL.TimeLogItemId
				INNER JOIN Common.TimeLogDetail AS TLD (NOLOCK) ON TLD.MasterId = TL.Id
				WHERE  Duration <> '00:00:00.0000000' AND SystemId IS NOT NULL ----AND SystemId = @CaseId 
				GROUP BY SystemId, tl.EmployeeId, TLD.ChargeOutRate
				) kk
			) hh
		GROUP BY SystemId
	) as A
-------===============================================================================================================================------

------->>> CaseData
SELECT * INTO #CaseData 
FROM (
	SELECT
	CompanyId, CaseId,CaseNumber, Stage, CaseFee,ScheduleNewId, ClientName, PlannedCost,ActualCost,TargettedRecovery,FeeAllocation,FeeAllocationPer,
	CASE WHEN PlannedCost != 0 AND FeeAllocationPer != 0 THEN ROUND(((FeeAllocationPer / PlannedCost) * 100), 2) ELSE 0 END AS FeeRecovery,
	CASE WHEN ISNULL(ActualCost,0) != 0 AND FeeAllocationPer != 0 THEN Round(((FeeAllocationPer / ISNULL(ActualCost,0)) * 100), 2) ELSE 0 END AS ActualRecovery
	FROM (
			SELECT A.CompanyId,A.CaseId,A.ScheduleNewId,CaseNumber,Stage,A.CaseFee, ClientName, ISNULL(A.PlannedCost,0) AS PlannedCost,ISNULL(B.ActCost,0) AS ActualCost,TargettedRecovery, A.FeeAllocation,
				CASE WHEN ISNULL(ROUND((ISNULL(FeeAllocation, 0)), 2),0) = 0 THEN ISNULL(CaseFee,0) ELSE ROUND((ISNULL(FeeAllocation, 0)), 2) END AS FeeAllocationPer
			FROM #PlannedCost AS A
			LEFT JOIN #ActualCost AS B ON B.CaseId = A.CaseId
			----WHERE A.CaseId = @CaseId
		) AS A
) AS A

----SELECT * FROM #CaseData
-------===============================================================================================================================------

------->>> CaseUsers
SELECT * INTO #CaseUsers 
FROM (
	SELECT DISTINCT 
		A.CompanyId, A.ClientName, A.CaseId,A.CaseNumber,A.Stage,A.FeeRecovery,A.TargettedRecovery,A.ActualRecovery,B.EmployeeId,E.FirstName as EmployeeName, E.Username, CU.Id as CompanyUserId,
		N.CompanyUserId as NCompanyUserId,N.CompanyId as NcompanyId,N.IsOn AS NIsOn,N.Type, N.NotificationTemplate, N.NotificationSubject,N.OtherEmailRecipient,
		N.ScreenAction AS NScreenAction,N1.ScreenAction AS N1ScreenAction,N1.CompanyId as N1CompanyId,N1.IsOn as N1IsOn,N1.Type AS N1Type, N1.NotificationTemplate AS N1NotificationTemplate, 
		N1.NotificationSubject AS N1NotificationSubject,N1.OtherEmailRecipient AS N1OtherEmailRecipient
	FROM #CaseData AS A
	INNER JOIN  WorkFlow.ScheduleDetailNew AS B (NOLOCK) ON B.MasterId = A.ScheduleNewId
	INNER JOIN Common.Employee AS E ON E.id = B.EmployeeId
	INNER JOIN Common.CompanyUser AS CU ON CU.Username = E.Username  AND E.STATUS = 1 AND CU.CompanyId = a.CompanyId
	LEFT JOIN (SELECT DISTINCT CompanyId,ScreenAction,IsOn, Type,  NotificationTemplate,  NotificationSubject, OtherEmailRecipient FROM #NotificationSettings WHERE CompanyUserId IS NULL) AS N1 ON  N1.CompanyId = CU.CompanyId 
	LEFT JOIN #NotificationSettings AS N ON N.CompanyId = CU.CompanyId AND N.CompanyUserId = CU.Id AND N.ScreenAction = N1.ScreenAction
) AS A

----SELECT * FROM #CaseUsers
-------===============================================================================================================================------


------->>> NotificationUsers
SELECT * INTO #NotificationUsers 
FROM (
SELECT  A.CompanyId,ClientName, CaseId,CaseNumber,Stage,FeeRecovery,TargettedRecovery,ActualRecovery,IsOn,A.ScreenAction,UserName,A.Type,NotificationTemplate,NotificationSubject,A.OtherEmailRecipient,
CASE WHEN A.ScreenAction = 'Planned Recovery' AND CompanyUserIdNullCompanyId IS NOT NULL AND NotificationUserId IS NULL THEN OtherRecipients
WHEN A.ScreenAction = 'Actual Recovery' AND NotificationUserId IS NULL THEN OtherRecipients
END AS OtherRecipients
FROM (
	SELECT CompanyId,ClientName, CaseId,CaseNumber,Stage,FeeRecovery,TargettedRecovery,ActualRecovery,
	CASE 
		WHEN CompanyId = NcompanyId AND CompanyUserId = NCompanyUserId AND NIsOn = 1 THEN NIsOn
		WHEN NcompanyId IS NULL AND NCompanyUserId IS NULL AND NIsOn IS NULL AND CompanyId = N1CompanyId AND N1IsOn = 1AND N1CompanyId IS NOT NULL THEN N1IsOn
		ELSE NULL
	END AS IsOn,
	CASE 
		WHEN CompanyId = NcompanyId AND CompanyUserId = NCompanyUserId AND NIsOn = 1 THEN NScreenAction
		WHEN NcompanyId IS NULL AND NCompanyUserId IS NULL AND NIsOn IS NULL AND CompanyId = N1CompanyId AND N1IsOn = 1AND N1CompanyId IS NOT NULL THEN N1ScreenAction
		ELSE NULL
	END AS ScreenAction,
	CASE 
		WHEN CompanyId = NcompanyId AND CompanyUserId = NCompanyUserId AND NIsOn = 1 THEN Username
		WHEN NcompanyId IS NULL AND NCompanyUserId IS NULL AND NIsOn IS NULL AND CompanyId = N1CompanyId AND N1IsOn = 1AND N1CompanyId IS NOT NULL THEN Username
		ELSE NULL
	END AS UserName,
	CASE 
		WHEN CompanyId = NcompanyId AND CompanyUserId = NCompanyUserId AND NIsOn = 1 THEN Type
		WHEN NcompanyId IS NULL AND NCompanyUserId IS NULL AND NIsOn IS NULL AND CompanyId = N1CompanyId AND N1IsOn = 1AND N1CompanyId IS NOT NULL THEN N1Type
		ELSE NULL
	END AS [Type],
	CASE 
		WHEN CompanyId = NcompanyId AND CompanyUserId = NCompanyUserId AND NIsOn = 1 THEN NotificationTemplate
		WHEN NcompanyId IS NULL AND NCompanyUserId IS NULL AND NIsOn IS NULL AND CompanyId = N1CompanyId AND N1IsOn = 1AND N1CompanyId IS NOT NULL THEN N1NotificationTemplate
		ELSE NULL
	END AS NotificationTemplate,
	CASE 
		WHEN CompanyId = NcompanyId AND CompanyUserId = NCompanyUserId AND NIsOn = 1 THEN NotificationSubject
		WHEN NcompanyId IS NULL AND NCompanyUserId IS NULL AND NIsOn IS NULL AND CompanyId = N1CompanyId AND N1IsOn = 1AND N1CompanyId IS NOT NULL THEN N1NotificationSubject
		ELSE NULL
	END AS NotificationSubject,
	CASE 
		WHEN CompanyId = NcompanyId AND CompanyUserId = NCompanyUserId AND NIsOn = 1 THEN OtherEmailRecipient
		WHEN NcompanyId IS NULL AND NCompanyUserId IS NULL AND NIsOn IS NULL AND CompanyId = N1CompanyId AND N1IsOn = 1AND N1CompanyId IS NOT NULL THEN N1OtherEmailRecipient
		ELSE NULL
	END AS OtherEmailRecipient
	FROM #CaseUsers AS A
	) AS A
	LEFT JOIN @OtherRecipients AS B ON B.CompanyId = A.CompanyId AND B.ScreenAction = A.ScreenAction

) AS A

----SELECT * FROM #NotificationUsers
-------===============================================================================================================================------


; WITH [OutPut] AS (
--------->>> Stage = 'Assigned'
SELECT 
	CompanyId,CaseId,CaseNumber,ClientName,Stage,NotificationSubject as OldNotificationSubject,
	REPLACE(REPLACE(NotificationSubject, '{{ClientName}}', ClientName), '{{CaseNo}}', CaseNumber) as NotificationSubject,
	ScreenAction,REPLACE(REPLACE(NotificationTemplate, '{{ClientName}}', ClientName), '{{CaseNo}}', CaseNumber) as Template, Type as NotificationType, 
	CASE WHEN Type LIKE '%Notification%' THEN CONCAT (STRING_AGG(UserName,','), ',', MIN(OtherRecipients)) END AS ListOfNotificationUsers,
	CASE WHEN Type LIKE '%Email%' THEN CONCAT (STRING_AGG(UserName,','), ',', MIN(OtherRecipients), ',', MIN(OtherEmailRecipient)) END AS ListOfEmailUsers
FROM #NotificationUsers
WHERE Stage = 'Assigned' AND FeeRecovery != 0 AND TargettedRecovery != 0
GROUP BY CompanyId,CaseId,CaseNumber,ClientName,NotificationSubject,ScreenAction,NotificationTemplate, ClientName, CaseNumber, Type,Stage
--ORDER BY CompanyId,CaseId

UNION ALL
------->>> Stage = 'In-Progress'
SELECT 
	CompanyId,CaseId,CaseNumber,ClientName,Stage,NotificationSubject as OldNotificationSubject,
	REPLACE(REPLACE(NotificationSubject, '{{ClientName}}', ClientName), '{{CaseNo}}', CaseNumber) as NotificationSubject,
	ScreenAction,REPLACE(REPLACE(NotificationTemplate, '{{ClientName}}', ClientName), '{{CaseNo}}', CaseNumber) as Template, Type as NotificationType, 
	CASE WHEN Type LIKE '%Notification%' THEN CONCAT (STRING_AGG(UserName,','), ',', MIN(OtherRecipients)) END AS ListOfNotificationUsers,
	CASE WHEN Type LIKE '%Email%' THEN CONCAT (STRING_AGG(UserName,','), ',', MIN(OtherRecipients), ',', MIN(OtherEmailRecipient)) END AS ListOfEmailUsers
FROM #NotificationUsers
WHERE  Stage = 'In-Progress' AND ActualRecovery != 0 AND isnull(CASE WHEN isnull(FeeRecovery, 0) = 0 THEN isnull(TargettedRecovery, 0) ELSE isnull(FeeRecovery, 0) END, 0) != 0
GROUP BY CompanyId,CaseId,CaseNumber,ClientName,NotificationSubject,ScreenAction,NotificationTemplate, ClientName, CaseNumber, Type,Stage
--ORDER BY CompanyId,CaseId
) 
-------===============================================================================================================================------

INSERT INTO  [Notification].[Recovery] ([Id],CaseId,[CaseNumber],[ClientName], [CompanyId], [Subject], [ScreenAction], [Template], [NotificationType], [ToNotificationUser], [ToEmailUser], [Date], [UserCreated], [CreatedDate], [Status])  
SELECT NEWID() AS Id,CaseId,CaseNumber,ClientName,CompanyId,NotificationSubject,ScreenAction,Template,NotificationType,ListOfNotificationUsers,ListOfEmailUsers,GETDATE(),'System',GETDATE(),1 
FROM [OutPut]

DROP TABLE #NotificationSettings
DROP TABLE #RawData
DROP TABLE #SummarizedData
DROP TABLE #PlannedCost
DROP TABLE #ActualCost
DROP TABLE #CaseData
DROP TABLE #CaseUsers
DROP TABLE #NotificationUsers


END
GO
