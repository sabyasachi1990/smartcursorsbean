USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_DRFINANCE_KPI]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[SP_DRFINANCE_KPI]
@COMPANYID NVARCHAR (100), @FROM_DB NVARCHAR (500), @TO_DB NVARCHAR (500)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @QUERY_12 AS NVARCHAR (MAX);
        DECLARE @QUERY_13 AS NVARCHAR (MAX);
        DECLARE @QUERY_14 AS NVARCHAR (MAX);
        DECLARE @DIMCOMPANYID AS NVARCHAR (MAX);
        Declare @EngCompId nvarchar(10);
		Declare @Update Nvarchar(Max)
		Declare @Temp table (Companyid nvarchar(10))
        SET @QUERY_14 = 'delete from ' + @TO_DB + '.[dbo].[FactRatioTarget] where EngagementId Is null And CompanyId=' + @COMPANYID;
        EXECUTE sp_executesql @QUERY_14;
        SET @QUERY_13 = 'insert into ' + @TO_DB + '.[dbo].[FactRatioTarget] (Year, MeasureTypeId, CompanyId, Target,FairStartRange,FairEndRange)
		select null,M.Id,' + @COMPANYID + ', K.Target,K.FairStartValue,K.FairEndValue
		from ' + @TO_DB + '.[dbo].[DimMeasure] M
		join ' + @FROM_DB + '.dr.KPITarget K on M.Measure = K.TargetName And M.Category=K.TargetType
		where K.CompanyId= ' + @COMPANYID + 'group by M.Id, K.CompanyId, K.Target,K.FairStartValue,K.FairEndValue';
		        EXECUTE sp_executesql @QUERY_13;

		SET @DIMCOMPANYID = '(SELECT CompanyId from ' + @TO_DB + '.[dbo].[dimcompany] where SourceCompanyID = ' + @COMPANYID + ')';
		Insert into @Temp 
		Exec (@DIMCOMPANYID)
		Declare Engid_KPi Cursor For
		Select CompanyId From @Temp
		Open Engid_KPi
		Fetch next from Engid_KPi into @EngCompId
		While @@FETCH_STATUS=0
			Begin
				Set @Update='Update A Set A.Target=B.Target,A.FairEndRange=b.FairEndRange,A.FairStartRange=B.FairStartRange From ' + @TO_DB + '..FactRatioTarget As A
				inner Join 
				(Select * From ' + @TO_DB + '..FactRatioTarget Where EngagementId Is null And CompanyId=' + @COMPANYID + ') As B
				On A.MeasureTypeId=B.MeasureTypeId And A.CompanyId=' + @EngCompId + ''
				Exec (@Update)
				Fetch next from Engid_KPi into @EngCompId
			End
		close Engid_KPi
		Deallocate Engid_KPi


        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage AS NVARCHAR (4000), @ErrorSeverity AS INT, @ErrorState AS INT;
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        ROLLBACK;
        PRINT ('FAILED');
    END CATCH
END

GO
