USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_ClaimCarryForwardJob]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Proc_ClaimCarryForwardJob]
AS
BEGIN --s1	
	DECLARE @CompanyCount INT
	DECLARE @RecCount INT
	Declare @StartTime Datetime2(7)=(getdate())

	DECLARE @HrSettingtable TABLE (S_No INT Identity(1, 1), HRSettingid UNIQUEIDENTIFIER, CompanyId BIGINT, HRSettingDetailId UNIQUEIDENTIFIER, ClaimsCarryforwardResetDate DATETIME, IsClaimResetCompleted BIT)

	BEGIN TRANSACTION --s2

	BEGIN TRY --s3
		INSERT INTO @HrSettingtable
		SELECT HRS.Id, HRS.CompanyId, HRSD.Id, HRSD.[ClaimsCarryforwardResetDate], HRSD.[IsClaimResetCompleted]
		FROM [Common].[HRSettings] HRS (NOLOCK)
		JOIN [Common].[HRSettingdetails] HRSD (NOLOCK) ON HRS.Id = HRSD.MasterId
		WHERE Convert(DATE, HRSD.[ClaimsCarryforwardResetDate]) = dateadd(day, datediff(day, 1, GETDATE()), 0)

		SET @CompanyCount = (
				SELECT Count(*)
				FROM @HrSettingtable
				)
				print @CompanyCount
		SET @RecCount = 1

		WHILE @CompanyCount >= @RecCount
		BEGIN --1
			DECLARE @SettingId UNIQUEIDENTIFIER
			DECLARE @SettingCompanyid BIGINT
			DECLARE @SettingDetailId UNIQUEIDENTIFIER
			DECLARE @IsClaimResetCompleted BIT

			SELECT @SettingId = HRSettingid, @SettingCompanyid = CompanyId, @SettingDetailId = HRSettingDetailId, @IsClaimResetCompleted = IsClaimResetCompleted
			FROM @HrSettingtable
			WHERE S_No = @RecCount

			IF (@IsClaimResetCompleted is null or @IsClaimResetCompleted=0)
			BEGIN--2
			print @IsClaimResetCompleted
			print 'Executed'
			print @SettingDetailId
				UPDATE [Common].[HRSettingdetails] WITH (ROWLOCK) SET [IsClaimResetCompleted] = 1 WHERE id = @SettingDetailId
			END--2

			SET @RecCount = @RecCount + 1
		END--1
		Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )
values (newid(),'HRCursor','Claim CarryForward Job','Job','Claim CarryForward Job',@StartTime,getdate(),null,null,'Completed')
		COMMIT TRANSACTION --s2
	END TRY --s3

	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @ErrorMessage NVARCHAR(4000) --, @ErrorSeverity INT, @ErrorState INT;
		SELECT @ErrorMessage = ERROR_MESSAGE() --, @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
		RAISERROR (@ErrorMessage, 16, 1);
		Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus )
		values (newid(),'HRCursor','Claim CarryForward Job','Job','Claim CarryForward Job',@StartTime,getdate(),null,'Failed: '+ @ErrorMessage,'Failed')
	END CATCH
END
GO
