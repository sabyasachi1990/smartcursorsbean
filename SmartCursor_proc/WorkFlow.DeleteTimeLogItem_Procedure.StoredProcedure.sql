USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [WorkFlow].[DeleteTimeLogItem_Procedure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE       PROCEDURE [WorkFlow].[DeleteTimeLogItem_Procedure] (@LeaveApplicationId NVARCHAR(MAX))
AS
BEGIN
Begin Transaction
BEGIN TRY
 
-- DECLARE @LeaveApplicationId NVARCHAR(MAX) = '6F11BC3A-BB2F-4110-B112-00017C473A24,75393517-7EA2-4E8C-BF3E-000262D167B7,E9725B37-56EF-4828-BE36-00073CC86BA9, 213E1A4B-1597-4E4E-B3E4-00086A1C071B,50C525B3-2C67-4699-9DDE-00088D1050FC,D143AE1A-157D-4598-A647-00090582632C,2866AAC0-D41A-43CA-A427-00095B4D72A5, C877DBC7-14EC-4CD8-8FE7-0009DC8438EE,8DBC2C68-E499-4BA5-BC71-000A2360F98E,BD86CB10-0EAB-4C92-BECF-000B152BF271'
SELECT * INTO #LeaveApplicationIdStatus 
FROM (
		SELECT Id, LeaveStatus 
		FROM HR.LeaveApplication
		WHERE Id IN (
						SELECT TRIM(Value)
						FROM STRING_SPLIT(@LeaveApplicationId, ',')
						WHERE LTRIM(RTRIM(value)) <> ''
					)
	) AS A
WHERE LeaveStatus IN('Rejected','Cancelled','ApproveCancelled')
 
		DELETE TLID FROM Common.TimeLogItem TLI 
		JOIN Common.TimeLogItemDetail TLID ON TLI.Id = TLID.TimeLogItemId 
		JOIN #LeaveApplicationIdStatus AS C  ON C.Id = TLI.SystemId 

		DELETE TLI FROM Common.TimeLogItem AS TLI
		JOIN #LeaveApplicationIdStatus AS C  ON C.Id = TLI.SystemId 
		UPDATE A  SET AttendanceType = null 
		FROM Common.AttendanceDetails AS A
		JOIN #LeaveApplicationIdStatus AS C  ON C.Id = A.LeaveApplicationId

		DECLARE @status Nvarchar(max)
	    set @status =(select top 1 S.LeaveStatus from #LeaveApplicationIdStatus as S);
		Exec [dbo].[UpdateAuditSyncing] @LeaveApplicationId, null,'Success',@status,null,null,null,null,null,'HR Leaves','WF TimeLog'

	DROP TABLE #LeaveApplicationIdStatus
 
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

	    Exec [dbo].[UpdateAuditSyncing] @LeaveApplicationId, null,'Failed',@status,'Critical',null,'TimeLog Syncing Failed',@ErrorMessage,@LeaveApplicationId,'HR Leaves','WF TimeLog'
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
		END CATCH

		END
GO
