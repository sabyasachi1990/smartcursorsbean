USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AppraiseeInsertQestionnire]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[Proc_AppraiseeInsertQestionnire] (@AppraisalId UNIQUEIDENTIFIER, @QuestionnireId UNIQUEIDENTIFIER, @UserId UNIQUEIDENTIFIER, @CompanyId BIGINT,@IsEdit bit )
AS
BEGIN --s1
	BEGIN TRANSACTION --s2

	BEGIN TRY --s3
		DECLARE @IsAllowAllServiceEntityAtAppraisal BIT = (
				SELECT IsAllowAllServiceentitiesForAppraisal
				FROM Common.HRSettings
				WHERE CompanyId = @CompanyId
				)
		DECLARE @DepartmentIds NVARCHAR(3000)
		DECLARE @DesignationIds NVARCHAR(3000)

		SELECT @DepartmentIds = DepartmentId, @DesignationIds = DesignationId
		FROM HR.Questionnaire
		WHERE Id = @QuestionnireId

		IF (@IsAllowAllServiceEntityAtAppraisal = 1)
		BEGIN --1
			INSERT INTO [HR].[AppraisalAppraiseeDetails] ([Id], [AppraisalId], [EmployeeId], [DepartmentId], [DesignationId], [Level], [Recorder], [AppraiserIds], [RepliedCount], [AppraiserCount])
			SELECT NEWID(), @AppraisalId, Id, DepartmentId, DesignationId, NULL, NULL, NULL, NULL, 0
			FROM Common.Employee
			WHERE IdType IS NOT NULL AND STATUS = 1 AND DepartmentId IN (
					SELECT items
					FROM dbo.SplitToTable(@DepartmentIds, ',')
					) AND DesignationId IN (
					SELECT items
					FROM dbo.SplitToTable(@DesignationIds, ',')
					)
		END --1
		ELSE
		BEGIN --2
			INSERT INTO [HR].[AppraisalAppraiseeDetails] ([Id], [AppraisalId], [EmployeeId], [DepartmentId], [DesignationId], [Level], [Recorder], [AppraiserIds], [RepliedCount], [AppraiserCount])
			SELECT NEWID(), @AppraisalId, Id, DepartmentId, DesignationId, NULL, NULL, NULL, NULL, null
			FROM Common.Employee
			WHERE IdType IS NOT NULL AND STATUS = 1 AND DepartmentId IN (
					SELECT items
					FROM dbo.SplitToTable(@DepartmentIds, ',')
					) AND DesignationId IN (
					SELECT items
					FROM dbo.SplitToTable(@DesignationIds, ',')
					) AND CurrentServiceEnittyId IN (
					SELECT ServiceEntityId
					FROM Common.CompanyUserDetail
					WHERE Id = @UserId
					)
		END --2
		update HR.Appraisal set AppraiseesCount =(select count(Id) from [HR].[AppraisalAppraiseeDetails] where [AppraisalId]=@AppraisalId) where id=@AppraisalId
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
