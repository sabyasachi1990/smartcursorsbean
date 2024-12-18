USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AuditBalancesheet_DashBoad]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE   procedure [dbo].[Proc_AuditBalancesheet_DashBoad](@EngagementId Uniqueidentifier,@companyId Bigint)
as begin

	
declare @BalanceSheet table (Year varchar(25),Value money,Name Nvarchar(50))

Declare 
              @CurrentAssestsCyBalance money,
              @CurrentAssestsPYBalance money,
              @NonCurrentAssestsCyBalance money,
              @NonCurrentAssestsPYBalance money,
              @CurrentAssestsAjes money,
              @NonCurrentAssestsAjes money,
              @CurrentLiabilitiesCyBalance money,
              @CurrentLiabilitiesPYBalance money,
              @NonCurrentLiabilitiesCyBalance money,
              @NonCurrentLiabilitiesPYBalance money,
              @CurrentLiabilitiesAjes money,
              @NonCurrentLiabilitiesAjes money,
              @EquityCyBalance money,
              @EquityPyBalance money,
              @CYEquityAjes money,
              @CurrentAsstsFinal money,
              @NonCurrentAssetsFinal money,
              @CurrentLiabilitiesFinal money,
              @NonCurrentLiabilitiesFinal money,
              @EquityFinal money,
              @PYEquityAjes money,
              @PYCurrentAssestsAjes money,
              @PYNonCurrentAssestsAjes money,
              @PYCurrentLiabilitiesAjes money,
              @PYNonCurrentLiabilitiesAjes money,
              @PYCurrentAsstsFinal money,
              @PYNonCurrentAssetsFinal money,
              @PYCurrentLiabilitiesFinal money,
              @PYNonCurrentLiabilitiesFinal money,
              @PYEquityFinal money,
              @CurrentYearEngagement Int,
              @PriorYearEngagement int,
              @ISprioryearexists bit,
              @NetIncome money,
              @NetIncomeAjes money,
              @NetIncomePY money,
              @totalEquity money,
			  @Pyengagementexist int
 
 ---Engagment Dates
set @CurrentYearEngagement=(select Year(YearEndDate) from audit.AuditCompanyEngagement where Id=@EngagementId)

set @PriorYearEngagement=(select Year(PriorYearEnd) from audit.AuditCompanyEngagement where Id=@EngagementId)

Begin Transaction
BEGIN TRY 
if(select Count(*) from audit.TrialBalanceImport  where EngagementId=@EngagementId and AccountType='PY')>1
set @ISprioryearexists=1


declare @Filecount int

set @Filecount=(select count(*) from audit.TrialBalanceFileDetails where EngagementId=@engagementid and AccountType='CY')


------------------------CY and PY at a time-------------------------------

--IF(@Filecount=1 and @PriorYearEngagement is not null)
--begin

--------------------------------------------current year----------------------------
 ---------Current Assets--------------
 set @CurrentAssestsCyBalance =    (select Sum(Final) from audit.TrialBalanceImport as tb 
                                   join audit.LeadSheet as l on tb.LeadSheetId=l.Id  where tb.EngagementId=@EngagementId 
							       and  l.CompanyId=@CompanyId and l.LeadsheetType='Assets' and l.AccountClass='Current')

set @CurrentAssestsAjes  =         (Select Sum(DebitOrCredit) as Ajes from audit.AdjustmentAccount where Account 
                                   in(select Id  from audit.TrialBalanceImport  where EngagementId=@EngagementId 
							       and  LeadSheetId in(Select id from audit.LeadSheet where CompanyId=@CompanyId 
							       and LeadsheetType='Assets' and AccountClass='Current')))


---------Non-Current Assets--------------
 set @NonCurrentAssestsCyBalance=  (select Sum(Final) from audit.TrialBalanceImport as tb 
								   join audit.LeadSheet as l on tb.LeadSheetId=l.Id  where tb.EngagementId=@EngagementId  
								   and l.CompanyId=@CompanyId and l.LeadsheetType='Assets' and l.AccountClass='Non-Current')

 set @NonCurrentAssestsAjes=       (Select Sum(DebitOrCredit) as Ajes from audit.AdjustmentAccount where Account 
                                   in(select Id  from audit.TrialBalanceImport  where EngagementId=@EngagementId  
								   and LeadSheetId in(Select id from audit.LeadSheet where CompanyId=@CompanyId 
								   and LeadsheetType='Assets' and AccountClass='Non-Current')))


---------Current Liabilities--------------
 set @CurrentLiabilitiesCyBalance=  (select Sum(Final) from audit.TrialBalanceImport as tb 
                                    join audit.LeadSheet as l on tb.LeadSheetId=l.Id  where tb.EngagementId=@EngagementId 
								    and  l.CompanyId=@CompanyId and l.LeadsheetType='Liabilities' and l.AccountClass='Current')*-1

 set @CurrentLiabilitiesAjes=      (Select Sum(DebitOrCredit) as Ajes from audit.AdjustmentAccount where Account
                                   in(select Id  from audit.TrialBalanceImport  where EngagementId=@EngagementId  
								   and LeadSheetId in(Select id from audit.LeadSheet where CompanyId=@CompanyId 
								   and LeadsheetType='Liabilities' and AccountClass='Current')))*-1


---------Non-Current Liabilities--------------
 set @NonCurrentLiabilitiesCyBalance=(select Sum(Final) from audit.TrialBalanceImport as tb 
                                      join audit.LeadSheet as l on tb.LeadSheetId=l.Id  where tb.EngagementId=@EngagementId 
									  and  l.CompanyId=@CompanyId and l.LeadsheetType='Liabilities' and l.AccountClass='Non-Current')*-1

 set @NonCurrentLiabilitiesAjes=     (Select Sum(DebitOrCredit) as Ajes from audit.AdjustmentAccount where Account
                                     in(select Id  from audit.TrialBalanceImport  where EngagementId=@EngagementId
								     and LeadSheetId in(Select id from audit.LeadSheet where CompanyId=@CompanyId 
									 and LeadsheetType='Liabilities' and AccountClass='Non-Current')))*-1

--------Equity------------
 set @EquityCyBalance=   (select Sum(Final) from audit.TrialBalanceImport as tb 
                          join audit.LeadSheet as l on tb.LeadSheetId=l.Id  where tb.EngagementId=@EngagementId 
						  and l.CompanyId=@CompanyId and l.LeadsheetType='Equity')*-1

 set @CYEquityAjes=      (Select Sum(DebitOrCredit)  from audit.AdjustmentAccount where Account
                          in(select Id  from audit.TrialBalanceImport  where EngagementId=@EngagementId 
						  and LeadSheetId in(Select id from audit.LeadSheet where CompanyId=@CompanyId and LeadsheetType='Equity')))*-1


--------------------------Final----------------
Set @CurrentAsstsFinal=COALESCE (@CurrentAssestsCyBalance,0)+ COALESCE (@CurrentAssestsAjes,0)
set @NonCurrentAssetsFinal=COALESCE(@NonCurrentAssestsCyBalance,0)+COALESCE (@NonCurrentAssestsAjes,0)

Set @CurrentLiabilitiesFinal =COALESCE (@CurrentLiabilitiesCyBalance,0)+ COALESCE (@CurrentLiabilitiesAjes,0)
set @NonCurrentLiabilitiesFinal=COALESCE(@NonCurrentLiabilitiesCyBalance,0)+COALESCE (@NonCurrentLiabilitiesAjes,0)

--set @EquityFinal=COALESCE(@EquityCyBalance,0)+COALESCE (@CYEquityAjes,0)


Set @NetIncome=       (select sum(t.Final) from audit.leadsheet as l 
                       join audit.TrialBalanceImport as t on  l.Id=t.LeadSheetId 
                       where l.companyid=@companyId and t.EngagementId=@EngagementId 
					   and (l.LeadsheetType='Income' or l.LeadsheetType='Expenses'))*-1

Set @NetIncomePY  =   (select sum(t.PreviousYearBalance) from audit.leadsheet as l
                      join audit.TrialBalanceImport as t on  l.Id=t.LeadSheetId 
                      where l.companyid=@companyId and t.EngagementId=@EngagementId 
					  and (l.LeadsheetType='Income' or l.LeadsheetType='Expenses'))*-1

set @NetIncomeAjes=   (Select Sum(DebitOrCredit)  from audit.AdjustmentAccount where Account 
                      in(select Id  from audit.TrialBalanceImport  where EngagementId=@EngagementId and AccountType='CY' 
                      and LeadSheetId in(Select id from audit.LeadSheet where CompanyId=@CompanyId and (LeadsheetType='Income' or LeadsheetType='Expenses'))))*-1


set @totalEquity=COALESCE(@EquityCyBalance,0)+COALESCE(@CYEquityAjes,0) +COALESCE(@NetIncome,0)+COALESCE(@NetIncomeAjes,0);

set @EquityFinal=COALESCE(@totalEquity,0)

-------------Proioryear ---------------------

 ---------Current Assets--------------
set @CurrentAssestsPYBalance=(select Sum(PreviousYearBalance) from audit.TrialBalanceImport as tb join audit.LeadSheet as l on tb.LeadSheetId=l.Id  where tb.EngagementId=@EngagementId and  l.CompanyId=@CompanyId and l.LeadsheetType='Assets' and l.AccountClass='Current')
--set @PYCurrentAssestsAjes=(Select Sum(DebitOrCredit) as Ajes from audit.AdjustmentAccount where Account in(select Id  from audit.TrialBalanceImport  where EngagementId=@EngagementId and AccountType='CY' and LeadSheetId in(Select id from audit.LeadSheet where CompanyId=@CompanyId and LeadsheetType='Assets' and AccountClass='Current')))


---------Non-Current Assets--------------
 set @NonCurrentAssestsPYBalance=(select Sum(PreviousYearBalance) from audit.TrialBalanceImport as tb join audit.LeadSheet as l on tb.LeadSheetId=l.Id  where tb.EngagementId=@EngagementId and  l.CompanyId=@CompanyId and l.LeadsheetType='Assets' and l.AccountClass='Non-Current')
--set @PYNonCurrentAssestsAjes=(Select Sum(DebitOrCredit) as Ajes from audit.AdjustmentAccount where Account in(select Id  from audit.TrialBalanceImport  where EngagementId=@EngagementId and AccountType='CY' and LeadSheetId in(Select id from audit.LeadSheet where CompanyId=@CompanyId and LeadsheetType='Assets' and AccountClass='Non-Current')))


---------Current Liabilities--------------
 set @CurrentLiabilitiesPYBalance=(select Sum(PreviousYearBalance) from audit.TrialBalanceImport as tb join audit.LeadSheet as l on tb.LeadSheetId=l.Id  where tb.EngagementId=@EngagementId and  l.CompanyId=@CompanyId and l.LeadsheetType='Liabilities' and l.AccountClass='Current')*-1
--set @PYCurrentLiabilitiesAjes=(Select Sum(DebitOrCredit) as Ajes from audit.AdjustmentAccount where Account in(select Id  from audit.TrialBalanceImport  where EngagementId=@EngagementId and AccountType='CY' and LeadSheetId in(Select id from audit.LeadSheet where CompanyId=@CompanyId and LeadsheetType='Liabilities' and AccountClass='Current')))*-1


---------Non-Current Liabilities--------------
 set @NonCurrentLiabilitiesPYBalance=(select Sum(PreviousYearBalance) from audit.TrialBalanceImport as tb join audit.LeadSheet as l on tb.LeadSheetId=l.Id  where tb.EngagementId=@EngagementId and  l.CompanyId=@CompanyId and l.LeadsheetType='Liabilities' and l.AccountClass='Non-Current')*-1
 --set @PYNonCurrentLiabilitiesAjes=(Select Sum(DebitOrCredit) as Ajes from audit.AdjustmentAccount where Account in(select Id  from audit.TrialBalanceImport  where EngagementId=@EngagementId and AccountType='CY' and LeadSheetId in(Select id from audit.LeadSheet where CompanyId=@CompanyId and LeadsheetType='Liabilities' and AccountClass='Non-Current')))*-1

--------Equity------------
 set @EquityPyBalance=(select Sum(PreviousYearBalance) from audit.TrialBalanceImport as tb join audit.LeadSheet as l on tb.LeadSheetId=l.Id  where tb.EngagementId=@EngagementId and  l.CompanyId=@CompanyId and l.LeadsheetType='Equity')*-1
 --set @PYEquityAjes=(Select Sum(DebitOrCredit)  from audit.AdjustmentAccount where Account in(select Id  from audit.TrialBalanceImport  where EngagementId=@EngagementId and AccountType='CY' and LeadSheetId in(Select id from audit.LeadSheet where CompanyId=@CompanyId and LeadsheetType='Equity')))*-1
-----------------------------------------------





Set @PYCurrentAsstsFinal=COALESCE(@CurrentAssestsPYBalance,0)+ COALESCE (@PYCurrentAssestsAjes,0)
set @PYNonCurrentAssetsFinal=COALESCE(@NonCurrentAssestsPYBalance,0)+COALESCE (@PYNonCurrentAssestsAjes,0)

Set @PYCurrentLiabilitiesFinal =COALESCE (@CurrentLiabilitiesPYBalance,0)+ COALESCE (@PYCurrentLiabilitiesAjes,0)
set @PYNonCurrentLiabilitiesFinal=COALESCE(@NonCurrentLiabilitiesPYBalance,0)+COALESCE (@PYNonCurrentLiabilitiesAjes,0)

set @PYEquityFinal=COALESCE(@EquityPyBalance,0)+COALESCE(@PYEquityAjes,0)+COALESCE(@NetIncomePY,0)



--set @Pyengagementexist=( select count(*) from audit.TrialBalanceImport where EngagementId=@EngagementId and AccountType='CY')

--------------------------------
--IF(@PriorYearEngagement is not null and @Pyengagementexist =0 and @Filecount=1)
IF(@PriorYearEngagement is not null and @CurrentYearEngagement is null )
	Begin
		Insert Into @BalanceSheet values(@PriorYearEngagement,@PYCurrentAsstsFinal,'Current Assets')
		Insert Into @BalanceSheet values(@PriorYearEngagement,@PYNonCurrentAssetsFinal,'Non Current Assets')
		Insert Into @BalanceSheet values(@PriorYearEngagement,@PYCurrentLiabilitiesFinal,'Current Liabilities')
		Insert Into @BalanceSheet values(@PriorYearEngagement,@PYNonCurrentLiabilitiesFinal,'Non Current Liabilities')
		Insert Into @BalanceSheet values(@PriorYearEngagement,@PYEquityFinal,'Equity')
	End
else IF(@PriorYearEngagement is not null and @CurrentYearEngagement is not null)
	Begin
		Insert Into @BalanceSheet values(@CurrentYearEngagement,@CurrentAsstsFinal,'Current Assets')
		Insert Into @BalanceSheet values(@PriorYearEngagement,@PYCurrentAsstsFinal,'Current Assets')
		Insert Into @BalanceSheet values(@CurrentYearEngagement,@NonCurrentAssetsFinal,'Non Current Assets')
		Insert Into @BalanceSheet values(@PriorYearEngagement,@PYNonCurrentAssetsFinal,'Non Current Assets')
		Insert Into @BalanceSheet values(@CurrentYearEngagement,@CurrentLiabilitiesFinal,'Current Liabilities')
		Insert Into @BalanceSheet values(@PriorYearEngagement,@PYCurrentLiabilitiesFinal,'Current Liabilities')
		Insert Into @BalanceSheet values(@CurrentYearEngagement,@NonCurrentLiabilitiesFinal,'Non Current Liabilities')
		Insert Into @BalanceSheet values(@PriorYearEngagement,@PYNonCurrentLiabilitiesFinal,'Non Current Liabilities')
		Insert Into @BalanceSheet values(@CurrentYearEngagement,@EquityFinal,'Equity')
		Insert Into @BalanceSheet values(@PriorYearEngagement,@PYEquityFinal,'Equity')
	End
Else
	Begin 
		Insert Into @BalanceSheet values(@CurrentYearEngagement,@CurrentAsstsFinal,'Current Assets')
		Insert Into @BalanceSheet values(@CurrentYearEngagement,@NonCurrentAssetsFinal,'Non Current Assets')
		Insert Into @BalanceSheet values(@CurrentYearEngagement,@CurrentLiabilitiesFinal,'Current Liabilities')
		Insert Into @BalanceSheet values(@CurrentYearEngagement,@NonCurrentLiabilitiesFinal,'Non Current Liabilities')
		Insert Into @BalanceSheet values(@CurrentYearEngagement,@EquityFinal,'Equity')
	End

select * from @BalanceSheet
	Commit Transaction;
END TRY

BEGIN CATCH
	RollBack Transaction;
	DECLARE
	   @ErrorMessage NVARCHAR(4000),
	   @ErrorSeverity INT,
	   @ErrorState INT;
	   SELECT
	   @ErrorMessage = ERROR_MESSAGE(),
	   @ErrorSeverity = ERROR_SEVERITY(),
	   @ErrorState = ERROR_STATE();
	  RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH

end

GO
