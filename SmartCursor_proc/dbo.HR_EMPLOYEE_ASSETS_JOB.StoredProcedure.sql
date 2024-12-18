USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_EMPLOYEE_ASSETS_JOB]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure   [dbo].[HR_EMPLOYEE_ASSETS_JOB] 

AS 
BEGIN

BEGIN TRY
BEGIN TRANSACTION

Declare @StartTime Datetime2(7)=(getdate())
update HR.AssetSetupDetails WITH (ROWLOCK) set EmployeeId = null where Id in (select AssetSetupDetailsId from HR.Asset(NOLOCK) where CONVERT(DATE,ReturnDate) < CONVERT(DATE,DATEADD(DAY,-1, GETDATE())))

Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )
values (newid(),'HRCursor','Employee AssetJob','Job','Employee AssetJob',@StartTime,getdate(),null,null,'Completed')

COMMIT TRANSACTION
END TRY

BEGIN CATCH
   ROLLBACK TRANSACTION;

DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
RAISERROR (@ErrorMessage, 16, 1);
INSERT INTO Common.JobStatus  
    (Id, Module, Jobname, [Type], [Purpose], [StartDate], [EndDate], RecordsEffeted, Remarks, JobStatus)
VALUES 
    (NEWID(), 'HRCursor', 'Employee AssetJob', 'Job', 'Employee AssetJob', @StartTime, GETDATE(), NULL, 'Failed ' + @ErrorMessage, 'Failed');

END CATCH

END



GO
