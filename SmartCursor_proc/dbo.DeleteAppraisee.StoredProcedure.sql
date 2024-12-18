USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[DeleteAppraisee]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[DeleteAppraisee] (@AppraisalId UNIQUEIDENTIFIER, @IsEdit BIT, @CompanyId BIGINT)
AS
BEGIN --s1
	BEGIN TRANSACTION --s2

	BEGIN TRY --s3
		
		delete HR.AppraiseAppraisers where AppraisalDetailId in (select [Id ] from HR.AppraisalAppraiseeDetails where AppraisalId=@AppraisalId)
		delete HR.AppraisalResult where AppraisalId=@AppraisalId
		Delete HR.AppraisalAppraiseeDetails where AppraisalId=@AppraisalId
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
