USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_ReOpenOpportunity]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[Proc_ReOpenOpportunity]
AS
BEGIN
	DECLARE @MyUTCDatetime DATETIME2(7)
	DECLARE @SingaporeDatetoday DATETIME2(7)
	DECLARE @OpportunityToday DATETIME2(7)

	SET @MyUTCDatetime = (
			SELECT GETUTCDATE()
			);

	PRINT @SingaporeDatetoday

	SET @SingaporeDatetoday = (
			SELECT (
					convert(DATETIME, SWITCHOFFSET(CONVERT(DATETIMEOFFSET, GETUTCDATE()), (
								SELECT current_utc_offset
								FROM sys.time_zone_info
								WHERE name = 'Singapore Standard Time'
								)))
					)
			)

	PRINT @SingaporeDatetoday

	SET @OpportunityToday = (
			SELECT (DATEADD(DAY, 2, GETUTCDATE()))
			)

	CREATE TABLE #TempTableOpportunity (S_No INT Identity(1, 1), OpportunityId UNIQUEIDENTIFIER, ServiceCompanyId BIGINT, ServiceGroupId BIGINT, ServiceId BIGINT, CompanyId BIGINT, ReOpeningDate DATETIME2(7), ReOpen DATETIME2(7), SGCode NVARCHAR(20), SCode NVARCHAR(20), AUEntityType NVARCHAR(200), AUFormat NVARCHAR(200), AUGeneratedNumber INT, AUPreview NVARCHAR(100), SCShortName NVARCHAR(10), AutoNumberID UNIQUEIDENTIFIER, CounterLength INT)

	

	BEGIN TRY
		DECLARE @Recount INT
		DECLARE @OpportunityCount INT

		INSERT INTO #TempTableOpportunity
		SELECT DISTINCT op.Id, op.ServiceCompanyId, op.ServiceGroupId, op.ServiceId, op.CompanyId, op.ReOpeningDate, op.ReOpen, sg.Code, s.Code, AU.EntityType, au.[Format], convert(INT, AU.GeneratedNumber), AU.Preview, c.ShortName, AU.Id, AU.CounterLength
		FROM ClientCursor.Opportunity OP
		JOIN Common.Company C ON op.ServiceCompanyId = c.Id
		JOIN Common.ServiceGroup SG ON Op.ServiceGroupId = SG.Id
		JOIN Common.Service S ON op.ServiceId = S.Id
		JOIN Common.AutoNumber AU ON op.CompanyId = AU.CompanyId
		WHERE OP.IsTemp = 1 AND OP.ReOpen <= (DATEADD(DAY, 2, GETUTCDATE())) AND (day(OP.ReOpen) <= day(@SingaporeDatetoday) AND Month(OP.ReOpen) <= Month(@SingaporeDatetoday) AND Year(OP.reopen) <= Year(@SingaporeDatetoday)) AND AU.EntityType = 'Opportunity' --set @GenerateNumber =(select GeneratedNumber  from Common.AutoNumber where CompanyId=2058 and EntityType='Opportunity');

		SET @OpportunityCount = (
				SELECT count(*)
				FROM #TempTableOpportunity
				)
		SET @Recount = 1

		WHILE @OpportunityCount >= @Recount
		BEGIN
		BEGIN TRANSACTION --s2
			DECLARE @ReOpeningDate DATETIME2(7)
			DECLARE @OppNumberFormat NVARCHAR(50)
			DECLARE @OpportunityNumber NVARCHAR(50)
			DECLARE @OppOldGenerateNum NVARCHAR(10)
			--DECLARE @NewGenerateNum NVARCHAR(10)
			DECLARE @OppId UNIQUEIDENTIFIER
			DECLARE @AutoNumberId UNIQUEIDENTIFIER
			DECLARE @preview NVARCHAR(40)
			DECLARE @CompanyId BIGINT
			DECLARE @AULengeth INT
			DECLARE @CShortName NVARCHAR(10)
			DECLARE @SGShortName NVARCHAR(20)
			DECLARE @SShortName NVARCHAR(20)

			SELECT @ReOpeningDate = ReOpeningDate, @OppId = OpportunityId, @AutoNumberId = AutoNumberID, @preview = AUPreview, @CompanyId = CompanyId, @OppNumberFormat = AUFormat, @AULengeth = CounterLength, @CShortName = SCShortName, @SGShortName = SGCode, @SShortName = SCode
			FROM #TempTableOpportunity
			WHERE S_No = @Recount

			SET @OppOldGenerateNum = (
					SELECT GeneratedNumber
					FROM Common.AutoNumber
					WHERE Id = @AutoNumberId
					)

			UPDATE Common.AutoNumber
			SET GeneratedNumber = (@OppOldGenerateNum + 1)
			WHERE Id = @AutoNumberId

			SET @OpportunityNumber = (
					SELECT [dbo].[AutoNumberFormatting](@OppNumberFormat, @AULengeth, @CShortName, @SGShortName, @SShortName, (@OppOldGenerateNum + 1))
					)

			UPDATE ClientCursor.Opportunity
			SET ReOpen = @ReOpeningDate, Type = 'ReOpen', Stage = 'Created', UserCreated = 'System', CreatedDate = @MyUTCDatetime, IsTemp = 0, OpportunityNumber = @OpportunityNumber, OppNumberFormat = @OppNumberFormat
			WHERE Id = @OppId

			INSERT INTO ClientCursor.OpportunityStatusChange (Id, CompanyId, OpportunityId, STATE, ModifiedBy, ModifiedDate)
			VALUES (NEWID(), @CompanyId, @OppId, 'Created', 'System', Getutcdate())

			COMMIT TRANSACTION --s2


			EXEC [dbo].[UpdateAuditSyncing] @OppId, '00000000-0000-0000-0000-000000000000', 'Pending','Created', NULL, NULL, NULL, NULL, NULL, 'CC Opportunity','WF Cases';	
			SET @Recount = @Recount + 1


		END

		

		IF OBJECT_ID(N'tempdb..#TempTableOpportunity') IS NOT NULL
		BEGIN
			DROP TABLE #TempTableOpportunity
		END
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000)

		SELECT @ErrorMessage = ERROR_MESSAGE()

		RAISERROR (@ErrorMessage, 16, 1);
	END CATCH
END
GO
