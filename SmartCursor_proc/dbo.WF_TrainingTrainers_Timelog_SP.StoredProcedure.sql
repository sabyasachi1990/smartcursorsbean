USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_TrainingTrainers_Timelog_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


------ALTER TABLE Common.TimeLogItem ADD ActualHours decimal(17,2)
------UPDATE Common.TimeLogItem SET ActualHours = 0.00


CREATE PROCEDURE [dbo].[WF_TrainingTrainers_Timelog_SP]
@TrainingId Uniqueidentifier, @AttendeeId Uniqueidentifier
AS
BEGIN


IF EXISTS (SELECT EmployeeTrainigStatus FROM HR.TrainingAttendee(NOLOCK) WHERE EmployeeId = @AttendeeId AND TrainingId =@TrainingId AND EmployeeTrainigStatus = 'Withdrawn')
BEGIN

--SELECT * FROM Common.TimeLogItemDetail  
--WHERE TimeLogItemId IN (SELECT Id FROM Common.TimeLogItem WHERE SYSTEMID = @TrainingId) AND EmployeeId = @AttendeeId

--SELECT * FROM Common.TimeLogItem 
--WHERE Id IN (SELECT TimeLogItemId FROM Common.TimeLogItemDetail  WHERE TimeLogItemId IN (SELECT Id FROM Common.TimeLogItem WHERE SYSTEMID = @TrainingId) AND EmployeeId = @AttendeeId)

--SELECT * FROM Common.AttendanceDetails WHERE TrainingId IN (SELECT id FROM Common.TimeLogItem WHERE SystemId = @TrainingId AND EmployeeId = @AttendeeId )

DECLARE @timelogItemId uniqueidentifier= (Select TimeLogItemId from Common.TimeLogItemDetail(NOLOCK) 
WHERE TimeLogItemId IN (SELECT Id FROM Common.TimeLogItem(NOLOCK) WHERE SYSTEMID = @TrainingId) AND EmployeeId = @AttendeeId)

DELETE FROM Common.TimeLogItemDetail 
WHERE TimeLogItemId IN (SELECT Id FROM Common.TimeLogItem(NOLOCK) WHERE SYSTEMID = @TrainingId) AND EmployeeId = @AttendeeId

DELETE FROM Common.AttendanceDetails WHERE TrainingId IN (SELECT id FROM Common.TimeLogItem(NOLOCK) WHERE SystemId = @TrainingId AND EmployeeId = @AttendeeId )

DELETE FROM Common.TimeLogItem 
WHERE Id IN (@timelogItemId)


END

END


GO
