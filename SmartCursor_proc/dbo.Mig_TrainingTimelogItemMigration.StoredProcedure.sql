USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Mig_TrainingTimelogItemMigration]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[Mig_TrainingTimelogItemMigration] (@CompanyId BIGINT, @year INT)
AS
BEGIN
	BEGIN TRANSACTION --1

	BEGIN TRY --2
		--declare @CompanyId bigint;
		DECLARE @TrainerId UNIQUEIDENTIFIER
		DECLARE @TrainingId UNIQUEIDENTIFIER
		DECLARE @CourseName NVARCHAR(500)
		DECLARE @TrainerIds NVARCHAR(max)

		DECLARE companpany_cursor CURSOR
		FOR
		SELECT HT.TrainerId, HT.Id, HT.CompanyId, HC.CourseName, HT.TrainerIds
		FROM HR.Training HT
		JOIN HR.CourseLibrary HC ON HT.CourseLibraryId = HC.Id
		WHERE HT.CompanyId = @CompanyId AND year(HT.CreatedDate) = @year

		OPEN companpany_cursor

		FETCH NEXT
		FROM companpany_cursor
		INTO @TrainerId, @TrainingId, @CompanyId, @CourseName, @TrainerIds

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC [dbo].[WF_Taining_Timelog_Migration] @TrainerId, @TrainingId, @CompanyId, @CourseName, @TrainerIds

			FETCH NEXT
			FROM companpany_cursor
			INTO @TrainerId, @TrainingId, @CompanyId, @CourseName, @TrainerIds
		END

		CLOSE companpany_cursor

		DEALLOCATE companpany_cursor

		COMMIT TRANSACTION --1
	END TRY --2

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END
GO
