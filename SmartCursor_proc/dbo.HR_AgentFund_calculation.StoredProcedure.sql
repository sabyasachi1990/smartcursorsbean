USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_AgentFund_calculation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[HR_AgentFund_calculation] (@PayrollId UNIQUEIDENTIFIER, @PayrollStartDate DATETIME2(7))
AS
begin transaction
BEGIN TRY

	DECLARE @agencyFund DECIMAL = 0, @grosswage DECIMAL = 0
	DECLARE @AgencyFundDetails AgencyFundDetails

	INSERT INTO @AgencyFundDetails
	SELECT AFD.Id, AF.Id, AF.CompanyId, AFD.WageFrom, AFD.WageTo, AFD.Contribution, AFD.EffectiveFrom, AFD.EffectiveTo, AFD.STATUS ,AF.Name ,AF.Code
	FROM SmartCursorTST.HR.AgencyFund AF (NOLOCK)
	JOIN SmartCursorTST.HR.AgencyFundDetail AFD (NOLOCK) ON AF.Id = AFD.AgencyFundId
	WHERE EffectiveFrom <= @PayrollStartDate
		AND EffectiveTo >= @PayrollStartDate
		AND AFD.STATUS = 1

	DECLARE @AgencyFundId UNIQUEIDENTIFIER

	CREATE TABLE #AgencyFundIds (S_No INT Identity(1, 1),AgnecyFundId UNIQUEIDENTIFIER NULL)
	CREATE TABLE #AgencyFundIdValues (AgnecyFundId UNIQUEIDENTIFIER NULL,AgencyFundValue money,AgencyFundName NVARCHAR(500),AgencyFundCode NVARCHAR(100) )

	DECLARE @CompanyCount INT
	DECLARE @RecCount INT
	DECLARE @PayrollDetailId UNIQUEIDENTIFIER;
	DECLARE @AgencyFundIds NVARCHAR(1000)
	DECLARE @ordinaryWage MONEY
	DECLARE @additionalWage MONEY
	DECLARE @SPROWWage MONEY
	Declare @AgencyFundName NVARCHAR(500)
	Declare @AgencyFundCode NVARCHAR(100)



	DECLARE PayrollDetail_cursor CURSOR
	FOR
	SELECT Id, AgencyFundId, OrdinaryWage, AdditionalWage, SPROWWage
	FROM hr.PayrollDetails (NOLOCK)
	WHERE AgencyFundId IS NOT NULL and  masterId=@PayrollId

	OPEN PayrollDetail_cursor

	FETCH NEXT
	FROM PayrollDetail_cursor
	INTO @PayrollDetailId, @AgencyFundIds, @ordinaryWage, @additionalWage, @SPROWWage

	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO #AgencyFundIds
		SELECT items
		FROM dbo.SplitToTable(@AgencyFundIds, ',')

		SET @CompanyCount = (
				SELECT Count(*)
				FROM #AgencyFundIds
				)
		SET @RecCount = 1
		set @agencyFund=0
		WHILE @CompanyCount >= @RecCount
		BEGIN --1
		set @AgencyFundId=(select AgnecyFundId from #AgencyFundIds where S_No=@RecCount)
			IF (
					@AgencyFundId IS NOT NULL
					OR @AgencyFundId != '00000000-0000-0000-0000-000000000000'
					)
			BEGIN
				SET @grosswage = @ordinaryWage + @additionalWage

				IF (
						@grosswage IS NOT NULL
						AND @grosswage > 0
						)
				BEGIN
					IF EXISTS (
							SELECT *
							FROM @AgencyFundDetails
							WHERE AgencyFundId = @AgencyFundId 
								AND STATUS = 1
							)
					BEGIN
						  
								SELECT @agencyFund= Contribution ,@AgencyFundName=AgencyFundName ,@AgencyFundCode=AgencyFundCode
								FROM @AgencyFundDetails
								WHERE STATUS = 1 and  WageFrom<=(case when isnull(@SPROWWage,0)>0 then (ISNULL(@SPROWWage,0)+ISNULL(@additionalWage,0)) else (ISNULL(@ordinaryWage,0)+ISNULL(@additionalWage,0)) end) and WageTo>=(case when isnull(@SPROWWage,0)>0 then (ISNULL(@SPROWWage,0)+ISNULL(@additionalWage,0)) else (ISNULL(@ordinaryWage,0)+ISNULL(@additionalWage,0)) end) AND AgencyFundId = @AgencyFundId

								insert into #AgencyFundIdValues select @AgencyFundId,@agencyFund,@AgencyFundName,@AgencyFundCode
								
					END
					ELSE
					BEGIN
						SET @agencyFund = 0
					END
				END
				ELSE
				BEGIN
					SET @agencyFund = 0
				END
			END
			ELSE
			BEGIN
				SET @agencyFund = 0
			END
			set @RecCount=@RecCount+1;
		END --1

		update HR.PayrollDetails set AgencyFund=(select sum(AgencyFundValue) from #AgencyFundIdValues) where id =@PayrollDetailId



		DECLARE @json NVARCHAR(MAX)=(select AgencyFundName as AgencyFundName ,AgencyFundCode as AgencyFundCode,AgnecyFundId as AgencyFundId,AgencyFundValue as Value from #AgencyFundIdValues for  JSON path)

        update HR.PayrollDetails set Agencyfundmodel=@json where id=@PayrollDetailId

		truncate table #AgencyFundIds
		truncate table #AgencyFundIdValues
		FETCH NEXT
		FROM PayrollDetail_cursor
		INTO @PayrollDetailId, @AgencyFundIds, @ordinaryWage, @additionalWage, @SPROWWage
	END

	CLOSE PayrollDetail_cursor

	DEALLOCATE PayrollDetail_cursor
	IF OBJECT_ID(N'tempdb..#AgencyFundIds') IS NOT NULL
BEGIN
DROP TABLE #AgencyFundIds
END


	IF OBJECT_ID(N'tempdb..#AgencyFundIdValues') IS NOT NULL
BEGIN
DROP TABLE #AgencyFundIdValues
END

	COMMIT TRANSACTION --1
	END TRY --2

	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();

		RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
	END CATCH
--END
GO
