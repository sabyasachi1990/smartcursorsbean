USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AppraisalDeleteJob]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[Proc_AppraisalDeleteJob]
AS
BEGIN --s1
	BEGIN TRANSACTION --s2

	BEGIN TRY --s3
		DECLARE @AppraisalId UNIQUEIDENTIFIER

		DECLARE AppraisalCursor CURSOR
		FOR
		SELECT Id
		FROM HR.Appraisal
		WHERE (
				STATUS IS NULL
				OR STATUS = 0
				OR STATUS = 4
				)
			AND CONVERT(DATE, CreatedDate) <= (dateadd(day, datediff(day, 2, GETDATE()), 0))

		OPEN AppraisalCursor

		FETCH NEXT
		FROM AppraisalCursor
		INTO @AppraisalId

		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT @AppraisalId

			DELETE FROM HR.AppraisalAppraiseeWeightage WHERE AppraisalId = @AppraisalId

			DELETE	FROM HR.AppraiseAppraisers WHERE AppraiserId IN (
					SELECT Id
					FROM HR.AppraisalAppraiseeDetails
					WHERE AppraisalId = @AppraisalId
					)

			DELETE 	FROM HR.AppraisalResult	WHERE AppraisalId = @AppraisalId

			DELETE 	FROM HR.AppraisalAppraiseeDetails WHERE AppraisalId = @AppraisalId

			DELETE	FROM HR.Appraisal WHERE Id = @AppraisalId

			FETCH NEXT
			FROM AppraisalCursor
			INTO @AppraisalId
		END

		CLOSE AppraisalCursor

		DEALLOCATE AppraisalCursor

		COMMIT TRANSACTION --s2
	END TRY --s3

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
END
GO
