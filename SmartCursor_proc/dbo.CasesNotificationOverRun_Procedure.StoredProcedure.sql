USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CasesNotificationOverRun_Procedure]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE     PROCEDURE [dbo].[CasesNotificationOverRun_Procedure]
AS
BEGIN

--->> DECLARE @CompanyId Bigint = 1077, @CaseId UniqueIdentifier = 'AB305D4D-560E-F321-B421-FD6316524C98'

DECLARE @OtherRecipients TABLE (CompanyId Bigint,IsOn Int,OtherRecipients Nvarchar(2000), OtherEmailRecipient Nvarchar(2000))

INSERT INTO @OtherRecipients
SELECT * FROM (
SELECT A.CompanyId, A.IsOn, STRING_AGG(B.Username, ',') AS OtherRecipients, OtherEmailRecipient
FROM (
    SELECT  CompanyId, IsOn, TRIM(b.value) AS OtherRecipient, OtherEmailRecipient 
    FROM [Notification].[NotificationSettings] as a(NOLOCK)
     CROSS APPLY STRING_SPLIT(OtherRecipients, ',') as b
    WHERE CursorName = 'Workflow Cursor' AND ScreenName = 'Cases' AND ScreenAction = 'Over Run' AND IsOn = 1 AND CompanyUserId IS NULL AND OtherRecipients IS NOT NULL AND OtherRecipients != ''
) AS A
LEFT JOIN Common.CompanyUser AS B ON B.userName = A.OtherRecipient AND B.CompanyId = A.CompanyId
LEFT JOIN Common.CompanyUser AS C ON C.userName = A.OtherEmailRecipient AND C.CompanyId = A.CompanyId
GROUP BY A.CompanyId, A.IsOn,OtherEmailRecipient
) AS A
WHERE OtherRecipients IS NOT NULL OR OtherEmailRecipient IS NOT NULL

------->>> SELECT * FROM @OtherRecipients WHERE CompanyId = @CompanyId

SELECT * INTO #NotificationSettings 
FROM (
		SELECT A.Id, A.CompanyId, A.IsOn, Type, NotificationDescription, ScreenAction,A.CompanyUserId, b.Username, A.OtherRecipients,A.OtherEmailRecipient,NotificationSubject, Recipient
		FROM [Notification].[NotificationSettings] AS A (NOLOCK) 
		INNER JOIN Common.Company AS C (NOLOCK) ON A.CompanyId=C.Id
		LEFT JOIN Common.CompanyUser AS B ON B.Id = A.CompanyUserId AND B.CompanyId = A.CompanyId 
	
		WHERE CursorName = 'Workflow Cursor' AND ScreenName = 'Cases' AND ScreenAction = 'Over Run' AND C.Status=1-- AND A.CompanyId = @CompanyId
	) AS A	

------->>> SELECT * FROM #NotificationSettings WHERE CompanyId = @CompanyId


SELECT * INTO #CaseSchedule 
FROM (
	SELECT  CG.Id as CaseId, S.Id AS ScheduleId,  CG.Name as ClientName, CG.CaseNumber, CG.Stage, CG.CompanyId, cg.ActualDateOfCompletion, cg.DueDateForCompletion, cg.ApprovedDate,
		ISNULL(datediff(day, S.EndDate, Isnull(cg.ApprovedDate, GETUTCDATE())),0) AS DaysCount,N.Recipient
	FROM WorkFlow.CaseGroup AS CG (NOLOCK)
		INNER JOIN WorkFlow.ScheduleNew AS S (NOLOCK) ON S.CaseId = CG.Id
		INNER JOIN Common.Company AS C ON C.Id = cg.CompanyId AND c.ParentId IS NULL
		LEFT JOIN #NotificationSettings AS N (NOLOCK) ON N.CompanyId = CG.CompanyId AND N.CompanyUserId IS NULL AND IsOn = 1
	WHERE (Stage = 'Approve' OR Stage = 'Assigned') and c.Status=1 --- AND Cg.CompanyId = @CompanyId --AND CaseId = @CaseId
	) AS A
ORDER BY CaseNumber

------->>> SELECT * FROM #CaseSchedule WHERE CompanyId = @CompanyId  ORDER BY CompanyId,CaseNumber

SELECT * INTO #ScheduleDetailNew
FROM (
SELECT CompanyId,CaseId,CaseNumber,ClientName,ScheduleId,Recipient,TRIM(value) AS Type,
IsOn,Username,NotificationSubject,ScreenAction,NotificationDescription,OtherRecipients,OtherEmailRecipient
FROM (
		SELECT DISTINCT S.CompanyId,S.CaseId,S.CaseNumber,S.ClientName,S.ScheduleId,S.Recipient,SD.EmployeeId,E.Status,
			CASE WHEN N.CompanyUserId IS NULL THEN (CASE WHEN N1.CompanyId IS NOT NULL AND N1.IsOn = 1 THEN N1.IsOn END) ELSE (CASE WHEN N.IsOn = 1 THEN  N.IsOn END) END AS IsOn,
			CASE WHEN SD.IsPrimaryIncharge = 1 THEN 'PIC,Case Members' WHEN SD.IsQIIncharge = 1 THEN 'QIC,Case Members' WHEN SD.IsMicIncharge = 1 THEN 'MIC,Case Members' ELSE 'Case Members' END AS PICMICQIC,	
			CASE WHEN N.CompanyUserId IS NULL THEN (CASE WHEN N1.CompanyId IS NOT NULL AND N1.IsOn = 1 THEN CU.Id END) ELSE (CASE WHEN N.IsOn = 1 THEN  N.CompanyUserId END) END AS CompanyUserId,
			CASE WHEN N.CompanyUserId IS NULL THEN (CASE WHEN N1.CompanyId IS NOT NULL AND N1.IsOn = 1 THEN E.Username END) ELSE (CASE WHEN N.IsOn = 1 THEN E.Username END) END AS UserName,
			CASE WHEN N.CompanyUserId IS NULL THEN (CASE WHEN N1.CompanyId IS NOT NULL AND N1.IsOn = 1 THEN N1.Type END) ELSE (CASE WHEN N.IsOn = 1 THEN  N.Type END)  END AS Type,
			CASE WHEN N.CompanyUserId IS NULL THEN (CASE WHEN N1.CompanyId IS NOT NULL AND N1.IsOn = 1 THEN N1.NotificationSubject END) ELSE (CASE WHEN N.IsOn = 1 THEN  N.NotificationSubject END)  END AS NotificationSubject,
			CASE WHEN N.CompanyUserId IS NULL THEN (CASE WHEN N1.CompanyId IS NOT NULL AND N1.IsOn = 1 THEN N1.ScreenAction END) ELSE(CASE WHEN N.IsOn = 1 THEN  N.ScreenAction END)   END AS ScreenAction,
			CASE WHEN N.CompanyUserId IS NULL THEN (CASE WHEN N1.CompanyId IS NOT NULL AND N1.IsOn = 1 THEN N1.NotificationDescription END) ELSE (CASE WHEN N.IsOn = 1 THEN  N.NotificationDescription END)  END AS NotificationDescription,
			CASE WHEN N.CompanyUserId IS NOT NULL AND N.IsOn = 1 THEN  N.OtherRecipients  END AS OtherRecipients,
			CASE WHEN N.CompanyUserId IS NOT NULL AND N.IsOn = 1 THEN  N.OtherEmailRecipient  END AS OtherEmailRecipient
		FROM WorkFlow.ScheduleDetailNew AS SD
		INNER JOIN Common.Company AS C ON C.ID=SD.CompanyId
		INNER JOIN #CaseSchedule AS S ON S.ScheduleId = SD.MasterId
		INNER JOIN Common.Employee AS E ON E.id = Sd.EmployeeId AND E.Status = 1 
		INNER JOIN Common.CompanyUser AS CU ON CU.Username = E.Username AND CU.CompanyId = S.CompanyId
		LEFT JOIN #NotificationSettings AS N ON N.CompanyId = S.CompanyId AND N.CompanyUserId  = CU.Id
		LEFT JOIN 
			(SELECT CompanyId,IsOn,CompanyUserId,NotificationSubject,ScreenAction,NotificationDescription,Type,OtherRecipients,OtherEmailRecipient
			 FROM #NotificationSettings WHERE CompanyUserId IS NULL AND IsOn = 1
			) AS N1 ON N1.CompanyId = S.CompanyId
		WHERE S.DaysCount > 0 --- AND S.CompanyId = @CompanyId 
		) AS A
CROSS APPLY STRING_SPLIT(Type, ',')
WHERE Status = 1 AND (Recipient LIKE '%Case Members%' OR Recipient LIKE '%PIC%' OR Recipient LIKE '%QIC%' OR Recipient LIKE '%MIC%') ---AND CompanyId = @CompanyId 
) AS A

------->>> SELECT * FROM #ScheduleDetailNew


SELECT * INTO #OutPut FROM (
SELECT CaseId,CaseNumber,ClientName,A.CompanyId,NotificationSubject, ScreenAction,Template,Type,
	CASE WHEN Type LIKE '%Notification%' THEN CONCAT(STRING_AGG(Username, ','),',',A.OtherRecipients,',',B.OtherRecipients) END AS ListOfNotificationUser,
	CASE WHEN Type LIKE '%Email%' THEN CONCAT(STRING_AGG(Username, ','),',',B.OtherRecipients,',',A.OtherEmailRecipient,',',B.OtherEmailRecipient) END AS ListOfEmailUser
FROM (
		SELECT DISTINCT CaseId,CaseNumber,ClientName,A.CompanyId,
		REPLACE(REPLACE(NotificationSubject, '{{ClientName}}', ClientName), '{{CaseNo}}', CaseNumber) as NotificationSubject, ScreenAction,
		REPLACE(REPLACE(NotificationDescription, '{{ClientName}}', ClientName), '{{CaseNo}}', CaseNumber) as Template,Type AS [Type],
		STRING_AGG(Username, ',') AS Username,
		STRING_AGG(A.OtherRecipients, ',') AS OtherRecipients, STRING_AGG(A.OtherEmailRecipient, ',') AS OtherEmailRecipient
		FROM #ScheduleDetailNew AS A
		GROUP BY CaseId,CaseNumber,ClientName,A.CompanyId,NotificationDescription,NotificationSubject,ScreenAction, Type
	) AS A
	LEFT JOIN @OtherRecipients AS B ON B.CompanyId = A.CompanyId
GROUP BY CaseId,CaseNumber,ClientName,A.CompanyId,NotificationSubject, ScreenAction,Template,Type,A.OtherRecipients,B.OtherRecipients,A.OtherEmailRecipient,B.OtherEmailRecipient
) AS A

--------->>>>> Data Inserting into Table
INSERT INTO Notification.[Case]
(
	[Id],[CaseId],[CaseNumber],[ClientName],[CompanyId],[Subject],[ScreenAction],[Template],[NotificationType],
	[ToNotificationUser],[ToEmailUser],[Date],[UserCreated],[CreatedDate],[Status]
)
SELECT 	DISTINCT NEWID(),CaseId,CaseNumber,ClientName,CompanyId,NotificationSubject, ScreenAction,Template, STRING_AGG(NotificationType, ',') AS NotificationType,
MAX(NotificationUsers) AS NotificationUsers,MAX(EmailUsers) AS  EmailUsers,CONVERT(DATE, GETDATE()),'System',GETDATE(),1
FROM (
		SELECT 	DISTINCT CaseId,CaseNumber,ClientName,CompanyId,NotificationSubject, ScreenAction,Template,Type AS NotificationType,STRING_AGG(NotificationUsers,',') AS NotificationUsers,
		STRING_AGG(EmailUsers,',') AS EmailUsers
		FROM (
				SELECT DISTINCT 
					CaseId,CaseNumber,ClientName,CompanyId,NotificationSubject, ScreenAction,Template,Type,TRIM(B.value) AS NotificationUsers,NULL AS EmailUsers
				FROM #OutPut 
				CROSS APPLY STRING_SPLIT(ListOfNotificationUser, ',') as b
				WHERE b.value <> ''

				UNION ALL

				SELECT DISTINCT 
					CaseId,CaseNumber,ClientName,CompanyId,NotificationSubject, ScreenAction,Template,Type,Null as NotificationUsers,TRIM(C.value) AS EmailUsers
				FROM #OutPut 
				CROSS APPLY STRING_SPLIT(ListOfEmailUser, ',') as C
				WHERE C.value <> ''
		) AS A
		GROUP BY CaseId,CaseNumber,ClientName,CompanyId,NotificationSubject, ScreenAction,Template,Type
) AS A
GROUP BY CaseId,CaseNumber,ClientName,CompanyId,NotificationSubject, ScreenAction,Template


DROP TABLE #NotificationSettings
DROP TABLE #CaseSchedule
DROP TABLE #ScheduleDetailNew
DROP TABLE #OutPut
END
GO
