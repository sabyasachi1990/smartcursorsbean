USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TaxIncomeStatment_Dashboard]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------------------------------------------
 

Create Procedure [dbo].[Proc_TaxIncomeStatment_Dashboard] (@EngagementId Uniqueidentifier,@CompanyId Bigint)
As begin

declare @Incomestatement table (Year varchar(25),Value money,Name Nvarchar(50))

Declare 
			@CurrentIncomeFinal money,
			@CurrentExpenseFinal money,
			@Currentprofit money,
			@CurrentYearEngagement Int;
 ---Engagment Dates
set @CurrentYearEngagement=(select Year(YearEndDate) from Tax.TaxCompanyEngagement where Id=@EngagementId)

Begin Transaction
BEGIN TRY
 


set @CurrentIncomeFinal  = 	(select Sum(Balance) from Tax.ProfitAndLossImport as tb 
							join Tax.Classification as l on tb.ClassificationId=l.Id 
							where tb.EngagementId=@EngagementId and  l.CompanyId=@CompanyId and l.ClassificationType='Income')*-1

set @CurrentExpenseFinal = 	(select Sum(Balance) from Tax.ProfitAndLossImport as tb 
							join Tax.Classification as l on tb.ClassificationId=l.Id 
							where tb.EngagementId=@EngagementId and  l.CompanyId=@CompanyId and l.ClassificationType='Expenses')
 

Set @Currentprofit       =  COALESCE(@CurrentIncomeFinal,0)+COALESCE (@CurrentExpenseFinal,0)

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
