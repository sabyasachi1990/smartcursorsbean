USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_DRFINANCE_COMPANY]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Use [SmartCursorTSTNew]

CREATE Procedure [dbo].[SP_DRFINANCE_COMPANY]
@COMPANYID NVARCHAR (100), @FROM_DB NVARCHAR (500), @TO_DB NVARCHAR (500), @ENGAGEMENTID NVARCHAR (500)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @QUERY_1 AS NVARCHAR (MAX);
        DECLARE @QUERY_5 AS NVARCHAR (MAX);
        DECLARE @QUERY_11 AS NVARCHAR (MAX);
        DECLARE @QUERY_12 AS NVARCHAR (MAX);
        DECLARE @QUERY_13 AS NVARCHAR (MAX);
        DECLARE @QUERY_14 AS NVARCHAR (MAX);
		Declare @DIMCOMPANYID Nvarchar(Max);
        SET @QUERY_5 = 'select * from ' + @TO_DB + '.dbo.DimCompany where SourceCompanyID = ' + @COMPANYID + ' And EngagementId=' + '''' + @ENGAGEMENTID + '''' + ' ';
        EXECUTE sp_executesql @QUERY_5;
        DECLARE @COUNT AS INT = @@ROWCOUNT;
        IF (@COUNT > 0)
            BEGIN
                SET @QUERY_1 = 'update DC set dc.SourceCompanyID=c.Id, dc.RegistrationNo = c.RegistrationNo, dc.CompanyName = c.Name, dc.LogoId=c.LogoId, dc.TenantID = c.TenantId, dc.TenantName=c.Name, dc.RegistrationDate =  FC.IncorporationDate, dc.EngagementId=' + '''' + @ENGAGEMENTID + '''' + '
		from ' + @TO_DB + '.[dbo].DimCompany as DC 
		inner join ' + @FROM_DB + '.common.company as C on c.Id = dc.SourceCompanyID 
		inner join ' + @FROM_DB + '.Dr.FinanceCompany as FC on C.Id = FC.ServiceCompanyId
		where DC.EngagementId=' + '''' + @ENGAGEMENTID + '''' + ' And DC.SourceCompanyID=' + @COMPANYID;
                EXECUTE sp_executesql @QUERY_1;

		Set @DIMCOMPANYID = '(SELECT CompanyId from ' + @TO_DB + '.[dbo].[dimcompany] where SourceCompanyID = ' + @COMPANYID + ' And EngagementId=' + '''' + @ENGAGEMENTID  + '''' + ')'

                SET @QUERY_12 = 'insert into ' + @TO_DB + '.[dbo].[DimMeasure] (Id, Measure, Category, QuickRatioId)
		select ROW_NUMBER() OVER(ORDER BY ID) + (select Max(Id) from ' + @TO_DB + '.[dbo].[DimMeasure])+1,
		TargetName, TargetType,QuickRatioId from
(Select distinct Id,TargetName, TargetType, NULL as QuickRatioId  from ' + @FROM_DB + '.dr.KPITarget where TargetName not in (select Measure from ' + @TO_DB + '.[dbo].[DimMeasure]))P';
                EXECUTE sp_executesql @QUERY_12;
                SET @QUERY_14 = 'delete from ' + @TO_DB + '.[dbo].[FactRatioTarget] where EngagementId=' + '''' + @ENGAGEMENTID + '''' + ' And CompanyId=' + @DIMCOMPANYID + '';
                EXECUTE sp_executesql @QUERY_14;
                SET @QUERY_13 = 'insert into ' + @TO_DB + '.[dbo].[FactRatioTarget] (Year, MeasureTypeId, CompanyId, Target,EngagementId,FairStartRange,FairEndRange)
		select null,M.Id,' + @DIMCOMPANYID + ', K.Target,' + '''' + @ENGAGEMENTID + '''' + ',K.FairStartValue,k.FairEndValue
		from ' + @TO_DB + '.[dbo].[DimMeasure] M
		join ' + @FROM_DB + '.dr.KPITarget K on M.Measure = K.TargetName And M.Category=K.TargetType
		where K.CompanyId= ' + @COMPANYID + ' group by M.Id, K.CompanyId, K.Target,K.FairStartValue,k.FairEndValue';
                EXECUTE sp_executesql @QUERY_13;
            END
        ELSE
            BEGIN
                SET @QUERY_11 = 'insert into ' + @TO_DB + '.[dbo].DimCompany (SourceCompanyID, RegistrationNo, CompanyName, LogoId, TenantID, TenantName, RegistrationDate,EngagementId)
		select C.Id, C.RegistrationNo, C.Name, C.LogoId, C.TenantId,C.Name, FC.IncorporationDate,' + '''' + @ENGAGEMENTID + '''' + '
		from ' + @FROM_DB + '.common.company C 
		inner join ' + @FROM_DB + '.Dr.FinanceCompany as FC on C.Id = FC.ServiceCompanyId
		where C.Id=' + @COMPANYID;
                EXECUTE sp_executesql @QUERY_11;

		Set @DIMCOMPANYID = '(SELECT CompanyId from ' + @TO_DB + '.[dbo].[dimcompany] where SourceCompanyID = ' + @COMPANYID + ' And EngagementId=' + '''' + @ENGAGEMENTID  + '''' + ')'

                SET @QUERY_12 = 'insert into ' + @TO_DB + '.[dbo].[DimMeasure] (Id, Measure, Category, QuickRatioId)
		select ROW_NUMBER() OVER(ORDER BY ID) + (select Max(Id) from ' + @TO_DB + '.[dbo].[DimMeasure])+1, TargetName, TargetType, NULL from ' + @FROM_DB + '.dr.KPITarget where TargetName not in (select Measure from ' + @TO_DB + '.[dbo].[DimMeasure])';
                EXECUTE sp_executesql @QUERY_12;
                SET @QUERY_14 = 'delete from ' + @TO_DB + '.[dbo].[FactRatioTarget] where  EngagementId=' + '''' + @ENGAGEMENTID + '''' + ' And CompanyId=' + @DIMCOMPANYID + '';
                EXECUTE sp_executesql @QUERY_14;
                SET @QUERY_13 = 'insert into ' + @TO_DB + '.[dbo].[FactRatioTarget] (Year, MeasureTypeId, CompanyId, Target,EngagementId,FairStartRange,FairEndRange)
		select null,M.Id,' + @DIMCOMPANYID + ', K.Target ,' + '''' + @ENGAGEMENTID + '''' + ',K.FairStartValue,k.FairEndValue
		from ' + @TO_DB + '.[dbo].[DimMeasure] M
		join ' + @FROM_DB + '.dr.KPITarget K on M.Measure = K.TargetName And M.Category=K.TargetType
		where K.CompanyId= ' + @COMPANYID;
                EXECUTE sp_executesql @QUERY_13;
            END
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage AS NVARCHAR (4000) = @@ROWCOUNT, @ErrorSeverity AS INT = @@ROWCOUNT, @ErrorState AS INT = @@ROWCOUNT;
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        ROLLBACK;
        PRINT ('FAILED');
    END CATCH
    BEGIN
        COMMIT TRANSACTION;
    END
END

GO
