USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[sp_updateIslockFlagNew]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create   PROCEDURE [dbo].[sp_updateIslockFlagNew] @Caseid nvarchar(max)
AS
BEGIN
DECLARE @ScheduleId uniqueidentifier, @ScheduleDetailId uniqueidentifier, @EmployeeId uniqueidentifier
DECLARE @WhileLoopTable TABLE (S_No Int Identity(1,1), CaseId uniqueidentifier, ScheduleId uniqueidentifier, ScheduleDetailId uniqueidentifier, EmployeeId uniqueidentifier)

INSERT INTO @WhileLoopTable
SELECT s.CaseId, s.id AS ScheduleId, sd.id AS ScheduleDetailId, sd.EmployeeId
FROM WorkFlow.ScheduleNew s (NOLOCK)
INNER JOIN WorkFlow.ScheduleDetailNew sd (NOLOCK) ON sd.MasterId = s.Id
WHERE s.CaseId IN ((SELECT LTRIM(items) AS Items FROM [dbo].[SplitToTable](@Caseid, ',')))
ORDER BY s.CaseId

BEGIN TRANSACTION
BEGIN TRY
    UPDATE sd
    SET IsLocked = CASE
        WHEN stn.Id IS NOT NULL THEN 1
        ELSE 0
    END
    FROM WorkFlow.ScheduleDetailNew sd
    INNER JOIN @WhileLoopTable wlt ON wlt.ScheduleDetailId = sd.Id
    LEFT JOIN WorkFlow.ScheduleTaskNew stn ON stn.CaseId = wlt.CaseId AND stn.EmployeeId = wlt.EmployeeId AND stn.ScheduleDetailId = wlt.ScheduleDetailId
    WHERE sd.Id = wlt.ScheduleDetailId AND sd.EmployeeId = wlt.EmployeeId AND sd.MasterId = wlt.ScheduleId

    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage nvarchar(4000) = ERROR_MESSAGE();
    ROLLBACK
    SELECT @ErrorMessage
END CATCH
END
GO
