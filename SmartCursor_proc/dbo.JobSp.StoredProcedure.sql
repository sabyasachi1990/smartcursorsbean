USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[JobSp]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[JobSp] (@StartTime datetime2(7),@EndTime datetime2(7))
	As Begin
		Begin Transaction
		BEGIN TRY	
Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )
values (newid(),'HRCursor','HR Settings Job','Job','HR Settings Job',@StartTime,@EndTime,null,null,'Completed')

    	Commit Transaction
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
