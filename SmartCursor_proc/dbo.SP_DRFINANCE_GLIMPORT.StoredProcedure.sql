USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_DRFINANCE_GLIMPORT]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[SP_DRFINANCE_GLIMPORT]
@COMPANYID NVARCHAR (100), @FROM_DB NVARCHAR (500), @TO_DB NVARCHAR (500), @YEAR NVARCHAR (10), @ENGAGEMENTID NVARCHAR (500)
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @QUERY AS NVARCHAR (MAX);
        DECLARE @QUERY_0 AS NVARCHAR (MAX);
        DECLARE @QUERY_1 AS NVARCHAR (MAX);
        DECLARE @QUERY_2 AS NVARCHAR (MAX);
        DECLARE @QUERY_3 AS NVARCHAR (MAX);
        DECLARE @QUERY_4 AS NVARCHAR (MAX);
        DECLARE @QUERY_5 AS NVARCHAR (MAX);
        DECLARE @DIMCOMPANYID AS NVARCHAR (MAX);
		Declare @OperatingFact Nvarchar(Max);
		Declare @Op_Fact_Id Nvarchar(50);
		Declare @Cal_Sp Nvarchar(Max);
        BEGIN
            SET @DIMCOMPANYID = '(SELECT CompanyId from ' + @TO_DB + ' .[dbo].[dimcompany] where SourceCompanyID = ' + @COMPANYID + ' And EngagementId=' + '''' + @ENGAGEMENTID + '''' + ')';
            SET @QUERY_0 = 'DELETE FROM ' + @TO_DB + '.[dbo].[DimAccount] where Year =' + @YEAR + ' and CompanyId=' + @DIMCOMPANYID + '';
            EXECUTE sp_executesql @QUERY_0;
            SET @QUERY_1 = 'Insert into ' + @TO_DB + '.[dbo].[DimAccount] (AccountNo,AccountName,AccountType,CashflowType,isRevaluation,AccountClass,AccountCategory,AccountSubCategory,AccountNature,QuickAssets,NAForCreditorTurnOver,COGS,TenantId,CompanyId,isBank,isActive,Year,EngagementId)
	select GLH.AccountNumber, GLH.AccountName,AT.Name, AT.CashFlowType, AT.ShowRevaluation, AT.Class, AT.SubCategory, NULL, AT.Nature, AT.QuickAssets, AT.NAForCreditorTurnOver, AT.COGS, ' + @DIMCOMPANYID + ', ' + @DIMCOMPANYID + ', (case when (select count(*) from ' + @FROM_DB + '.dr.GeneralLedgerHeader where AccountName=''Cash and cash equivalent'' and CompanyId = GLH.CompanyId) > 0 then 1 else 0 end),1,' + @YEAR + ',' + '''' + @ENGAGEMENTID + '''' + ' from ' + @FROM_DB + '.dr.GeneralLedgerHeader GLH
	join ' + @FROM_DB + '.dr.AccountType AT on GLH.AccountTypeId = AT.FRATId
	where (GLH.AccountName not in (select AccountName from ' + @TO_DB + '.[dbo].[DimAccount] where CompanyId = ' + @DIMCOMPANYID + ' And Year=' + @YEAR + ') and GLH.EngagementId=' + '''' + @ENGAGEMENTID + '''' + ' and GLH.year=' + @YEAR + ') group by 
	GLH.AccountNumber, GLH.AccountName,AT.Name, AT.CashFlowType, AT.ShowRevaluation, AT.Class, AT.Category, AT.SubCategory, AT.Nature, AT.QuickAssets, AT.NAForCreditorTurnOver, AT.COGS, GLH.CompanyId, GLH.EngagementId';
            EXECUTE sp_executesql @QUERY_1;
        END
        BEGIN
            SET @QUERY_2 = 'DELETE FROM ' + @TO_DB + '.[dbo].[DimDocument] where Year =' + @YEAR + ' and CompanyId=' + @DIMCOMPANYID + '';
            EXECUTE sp_executesql @QUERY_2;
            SET @QUERY_3 = 'Insert Into ' + @TO_DB + '.[dbo].[DimDocument] (DocumentNo,DocumentType,DocumentRefNo,DocumentDesc,year,CompanyId)
			Select Distinct DocNo,DocType,DocumentRefNo,Description,' + @Year + ',' + @DIMCOMPANYID + ' From ' + @FROM_DB + '.DR.GeneralLedgerDetail
					Where GeneralLedgerId in (Select Id From ' + @FROM_DB + '.DR.GeneralLedgerHeader where CompanyId= ' + @CompanyId + ' And [Year]= ' + @Year + ')';
            EXECUTE sp_executesql @QUERY_3;
        END
        BEGIN
            SET @QUERY_4 = 'DELETE FROM ' + @TO_DB + '.dbo.FactGL where Year =' + @YEAR + ' and CompanyId=' + @DIMCOMPANYID + '';
            EXECUTE sp_executesql @QUERY_4;
            SET @QUERY_5 = 'insert into ' + @TO_DB + '.dbo.FactGL (SourceTransGLId,PostingDateId,DocumentId,AccountId,CompanyId,CustomerId,VendorId,DocCurrency,DocDebit,DocCredit,BaseCurrency,BaseDebit,BaseCredit,Year,EngagementId)
		Select NULL As SourceTransGLId,GD.GLDate As Postingdate,
		DD.DocumentId As Documentid
		,AC.AccountID,' + @DIMCOMPANYID + ',Null As CustomerId,Null As VendorId,Null As DocCurrency,Null As DocDebit,Null As DocCredit,
		GD.Currency As BaseCurrency,GD.Debit As BaseDebit,GD.Credit As BaseCredit,GH.Year,' + '''' + @ENGAGEMENTID + '''' + '
		From ' + @FROM_DB + '.DR.GeneralLedgerDetail As GD
		Inner Join ' + @FROM_DB + '.DR.GeneralLedgerHeader As GH  on GH.Id=GD.GeneralLedgerId
		Inner Join ' + @TO_DB + '.[dbo].[DimAccount] As AC on AC.AccountName=GH.AccountName
		Left Join ' + @TO_DB + '.[dbo].[DimDocument] As DD on coalesce(DD.DocumentNo,''Null1'')=coalesce(GD.DocNo,''Null1'') And coalesce(Dd.DocumentDesc,''Null1'')=coalesce(GD.Description,''Null1'') and coalesce(DD.DocumentRefNo,''Null1'')=coalesce(GD.DocumentRefNo,''Null1'') And coalesce(DD.DocumentType,''Null1'')=coalesce(GD.DocType,''Null1'')
			and DD.CompanyId=' + @DIMCOMPANYID + ' And DD.Year=' + @YEAR + '
		where AC.Year=' + @YEAR + 'and GH.Year=' + @YEAR + ' and AC.CompanyId = ' + @DIMCOMPANYID + ' and gh.EngagementId=' + '''' + @ENGAGEMENTID + '''' + '';
            EXECUTE sp_executesql @QUERY_5;

			Set @OperatingFact ='Exec ' + @TO_DB + '.[dbo].[SP_OperatingFact] ' + @YEAR + ',' + @COMPANYID + ',' + '''' + @ENGAGEMENTID + '''' + ''

			Exec (@OperatingFact)
						
			Set @Cal_Sp='Exec ' + @TO_DB + '.[dbo].[Sp_Calculation]'

			Exec (@Cal_Sp)

            BEGIN
                COMMIT TRANSACTION;
            END
        END
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
