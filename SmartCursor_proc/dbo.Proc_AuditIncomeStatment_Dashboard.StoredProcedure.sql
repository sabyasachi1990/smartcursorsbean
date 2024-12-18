USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_AuditIncomeStatment_Dashboard]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 


CREATE Procedure [dbo].[Proc_AuditIncomeStatment_Dashboard] (@EngagementId Uniqueidentifier,@CompanyId Bigint)
As begin

declare @Incomestatement table (Year varchar(25),Value money,Name Nvarchar(50))

Declare 
			@IncomeCyBalance money,
			@IncomePYBalance money,
			@ExpensesCyBalance money,
			@ExpensesPYBalance money,
			@IncomeAjes money,
			@ExpensesAjes money,
			@CurrentIncomeFinal money,
			@CurrentExpenseFinal money,
			@PriorIncomeFinal money,
			@PriorExpenseFinal money,
			@PYIncomeAjes money,
			@PYExpensesAjes money,
			@Currentprofit money,
			@PriorProfit money,
			@CurrentYearEngagement Int,
			@PriorYearEngagement int,
			@ISprioryearexists bit,
			@Pyengagementexist int
 
 ---Engagment Dates
set @CurrentYearEngagement=(select Year(YearEndDate) from audit.AuditCompanyEngagement where Id=@EngagementId)
set @PriorYearEngagement=(select Year(PriorYearEnd) from audit.AuditCompanyEngagement where Id=@EngagementId)
Begin Transaction
BEGIN TRY
if(select Count(*) from audit.TrialBalanceImport  where EngagementId=@EngagementId and AccountType='PY')>1
set @ISprioryearexists=1

-------------------------------------------------------------------One engagement CY-PY update-----------------------------

declare @Filecount int
set @Filecount=(select count(*) from audit.TrialBalanceFileDetails where EngagementId=@engagementid)
set @IncomeCyBalance =  (select Sum(ActualCYAmount) from audit.TrialBalanceImport as tb 
						join audit.LeadSheet as l on tb.LeadSheetId=l.Id 
						where tb.EngagementId=@EngagementId and  l.CompanyId=@CompanyId and l.LeadsheetType='Income' 
						)*-1

set @IncomeAjes=        (Select Sum(DebitOrCredit) as Ajes from audit.AdjustmentAccount as adj 
						join 
						audit.TrialBalanceImport as tb on adj.Account=tb.Id 
						join audit.LeadSheet as l on tb.LeadSheetId=l.ID 
						where tb.EngagementId=@EngagementId and  l.CompanyId=@CompanyId and LeadsheetType='Income')*-1

--------Expenses------------
set @ExpensesCyBalance= (select Sum(ActualCYAmount) from audit.TrialBalanceImport as tb 
                        join audit.LeadSheet as l on tb.LeadSheetId=l.Id where tb.EngagementId=@EngagementId 
						and  l.CompanyId=@CompanyId and l.LeadsheetType='Expenses')

set @ExpensesAjes=      (Select Sum(DebitOrCredit) from audit.AdjustmentAccount as adj 
                        join audit.TrialBalanceImport as tb on adj.Account=tb.Id 
						join audit.LeadSheet as l on tb.LeadSheetId=l.ID where tb.EngagementId=@EngagementId 
						and  l.CompanyId=@CompanyId and LeadsheetType='Expenses')
If(SIGN(@ExpensesCyBalance) = -1)
Begin
set @ExpensesCyBalance=@ExpensesCyBalance*-1;
End

If(SIGN(@ExpensesAjes) = -1)
Begin
set @ExpensesAjes=@ExpensesAjes*-1;
End

Set @CurrentIncomeFinal=COALESCE (@IncomeCyBalance,0)+ COALESCE (@IncomeAjes,0)
set @CurrentExpenseFinal=COALESCE(@ExpensesCyBalance,0)+COALESCE (@ExpensesAjes,0)

-------------Proioryear ---------------------
set @IncomePYBalance= 	(select Sum(ActualPYAmount) from audit.TrialBalanceImport as tb 
						join audit.LeadSheet as l on tb.LeadSheetId=l.Id 
						where tb.EngagementId=@EngagementId and  l.CompanyId=@CompanyId and l.LeadsheetType='Income'
						)*-1

 
					    
set @ExpensesPYBalance= (select Sum(ActualPYAmount) from audit.TrialBalanceImport as tb 
                        join audit.LeadSheet as l on tb.LeadSheetId=l.Id 
						where tb.EngagementId=@EngagementId  and l.CompanyId=@CompanyId and l.LeadsheetType='Expenses')
 
If(SIGN(@ExpensesPYBalance) = -1)
Begin
set @ExpensesPYBalance=@ExpensesPYBalance*-1;
End


Set @PriorIncomeFinal=COALESCE(@IncomePYBalance,0)+COALESCE(@PYIncomeAjes,0)
set @PriorExpenseFinal=COALESCE(@ExpensesPYBalance,0)+COALESCE(@PYExpensesAjes,0)

set @Currentprofit=@CurrentIncomeFinal-@CurrentExpenseFinal
set @PriorProfit=@PriorIncomeFinal-@PriorExpenseFinal

--End

set @Pyengagementexist=( select count(*) from audit.TrialBalanceImport where EngagementId=@EngagementId and AccountType='CY')




if(@PriorYearEngagement is not null and @Pyengagementexist =0 and @Filecount=1)
Begin 
Insert Into @Incomestatement values(@PriorYearEngagement,@PriorIncomeFinal,'Income')
Insert Into @Incomestatement values(@PriorYearEngagement,@PriorExpenseFinal,'Expenses')
Insert Into @Incomestatement values(@PriorYearEngagement,@PriorProfit,'Profit')
End

Else IF(@PriorYearEngagement is not null )
Begin
Insert Into @Incomestatement values(@CurrentYearEngagement,@CurrentIncomeFinal,'Income')
Insert Into @Incomestatement values(@PriorYearEngagement,@PriorIncomeFinal,'Income')
Insert Into @Incomestatement values(@CurrentYearEngagement,@CurrentExpenseFinal,'Expenses')
Insert Into @Incomestatement values(@PriorYearEngagement,@PriorExpenseFinal,'Expenses')
Insert Into @Incomestatement values(@CurrentYearEngagement,@Currentprofit,'Profit')
Insert Into @Incomestatement values(@PriorYearEngagement,@PriorProfit,'Profit')
End



else

Begin 
Insert Into @Incomestatement values(@CurrentYearEngagement,@CurrentIncomeFinal,'Income')
Insert Into @Incomestatement values(@CurrentYearEngagement,@CurrentExpenseFinal,'Expenses')
Insert Into @Incomestatement values(@CurrentYearEngagement,@Currentprofit,'Profit')

end

select * from @Incomestatement
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

End  

GO
