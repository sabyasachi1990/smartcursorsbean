USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Tax_TaxStatusBar]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Tax_TaxStatusBar] @engagementId uniqueidentifier,@type Nvarchar(30)
As
BEGIN	
		Declare @TBPreparedpercentage int=0;													
		Declare @TBReviewdpercentage int=0;
		Declare @WPPreparedpercentage int=0;
		Declare @WPReviewdpercentage int=0;
		Declare @PlanningPreparedpercentage int=0;
		Declare @PlanningReviewdpercentage int=0;
		Declare @CompletionPreparedpercentage int=0;
		Declare @CompletionReviewdpercentage int=0;
		Declare @OverallPrepared int=0;
		Declare @OverallReviewed int=0;
		Declare @OverallPercentage int=0;

Begin Transaction
BEGIN TRY
		If(@type ='Percentage')
		 Begin	 

			--**Trail balance Percentage**		
							(select @TBPreparedpercentage= (100 * (select count( distinct Screen) from  Tax.UserApproval where EngagementId=@engagementId and  Type='Prepared' and Screen in 
															(select Heading from Tax.TaxCompanyMenuMaster where EngagementId=@engagementId and IsHide =0 and 
															TaxMenuMasterId in (select Id from Tax.TaxMenuMaster where GroupName='Financials')))/
															nullif((select COUNT(Id) from Tax.TaxCompanyMenuMaster where EngagementId=@engagementId and IsHide =0 and TaxMenuMasterId in (select Id from Tax.TaxMenuMaster where GroupName='Financials')and Heading <> 'Changes in Equity'),0)))

				 
							
							(select @TBReviewdpercentage= (100 * (select count( distinct Screen) from  Tax.UserApproval where EngagementId=@engagementId and  Type='Reviewed' and Screen in 
															(select Heading from Tax.TaxCompanyMenuMaster where EngagementId=@engagementId and IsHide =0 and 
															TaxMenuMasterId in (select Id from Tax.TaxMenuMaster where GroupName='Financials')))/
															nullif((select COUNT(Id) from tax.TaxCompanyMenuMaster where EngagementId=@engagementId and IsHide =0 and TaxMenuMasterId in (select Id from Tax.TaxMenuMaster where GroupName='Financials')and Heading <> 'Changes in Equity'),0)))

			--**Work Program Percentage**        
							(select @WPPreparedpercentage= (100 * (select count( distinct Screen) from  Tax.UserApproval where EngagementId=@engagementId and  Type='Prepared' and Screen in 
															(select Heading from Tax.TaxCompanyMenuMaster where EngagementId=@engagementId and IsHide =0 and 
															TaxMenuMasterId in (select Id from Tax.TaxMenuMaster where GroupName='Work Program')))/
															nullif((select COUNT(Id) from Tax.TaxCompanyMenuMaster where EngagementId=@engagementId and IsHide =0 and TaxMenuMasterId in (select Id from Tax.TaxMenuMaster where GroupName='Work Program' and Heading <>'workprogramcopy')),0)))
							
							(select @WPReviewdpercentage= (100 * (select count( distinct Screen) from  Tax.UserApproval where EngagementId=@engagementId and  Type='Reviewed' and Screen in 
															(select Heading from Tax.TaxCompanyMenuMaster where EngagementId=@engagementId and IsHide =0 and 
															TaxMenuMasterId in (select Id from Tax.TaxMenuMaster where GroupName='Work Program')))/
															nullif((select COUNT(Id) from Tax.TaxCompanyMenuMaster where EngagementId=@engagementId and IsHide =0 and TaxMenuMasterId in (select Id from Tax.TaxMenuMaster where GroupName='Work Program' and Heading <>'workprogramcopy')),0)))


			--**Planning Percentage** 
							(select @PlanningPreparedpercentage= (100 * (select count( distinct Screen) from  Tax.UserApproval where EngagementId=@engagementId and  Type='Prepared' and Screen in 
																(select Heading from Tax.TaxCompanyMenuMaster where EngagementId=@engagementId and IsHide =0 and 
																 TaxMenuMasterId in (select Id from Tax.TaxMenuMaster where GroupName='Planning')))/
				                                  				nullif((select COUNT(Id) from Tax.TaxCompanyMenuMaster where EngagementId=@engagementId and IsHide =0 and TaxMenuMasterId in (select Id from Tax.TaxMenuMaster where GroupName='Planning')),0)))
							
							(select @PlanningReviewdpercentage= (100 * (select count( distinct Screen) from  Tax.UserApproval where EngagementId=@engagementId and  Type='Reviewed' and Screen in 
																(select Heading from Tax.TaxCompanyMenuMaster where EngagementId=@engagementId and IsHide =0 and 
																TaxMenuMasterId in (select Id from Tax.TaxMenuMaster where GroupName='Planning')))/
																nullif((select COUNT(Id) from Tax.TaxCompanyMenuMaster where EngagementId=@engagementId and IsHide =0 and TaxMenuMasterId in (select Id from Tax.TaxMenuMaster where GroupName='Planning')),0)))


			

			select @OverallPrepared =((@TBPreparedpercentage+@WPPreparedpercentage+@PlanningPreparedpercentage)/nullif(3,0))
			select @OverallReviewed = ((@TBReviewdpercentage+@WPReviewdpercentage+@PlanningReviewdpercentage)/nullif(3,0))
			select @OverallPercentage = ((@TBPreparedpercentage+@TBReviewdpercentage+@WPPreparedpercentage+@WPReviewdpercentage+@PlanningPreparedpercentage+@PlanningReviewdpercentage)/nullif(6,0))

		
			select COALESCE(@TBPreparedpercentage,0) as TBPreparedpercentage,COALESCE(@TBReviewdpercentage,0) as TBReviewdpercentage,
				   COALESCE(@WPPreparedpercentage,0) as WPPreparedpercentage,COALESCE(@WPReviewdpercentage,0) as WPReviewdpercentage,
				   COALESCE(@PlanningPreparedpercentage,0) as PlanningPreparedpercentage,COALESCE(@PlanningReviewdpercentage,0) as PlanningReviewdpercentage,
				   COALESCE(@CompletionPreparedpercentage,0) as CompletionPreparedpercentage,COALESCE(@CompletionReviewdpercentage,0) as CompletionReviewdpercentage,
				   COALESCE(@OverallPrepared,0) as OverallPrepared , COALESCE(@OverallReviewed,0) as OverallReviewed, COALESCE(@OverallPercentage,0) as OverallPercentage;

			Update [Tax].[EngagementPercentage] set Percentage=COALESCE(@TBPreparedpercentage,0)			where GroupName='Financials' and PercentageType='Prepared' and EngagementId=@engagementId
			Update [Tax].[EngagementPercentage] set Percentage=COALESCE(@TBReviewdpercentage,0)			where GroupName='Financials' and PercentageType='Reviewd' and EngagementId=@engagementId
			Update [Tax].[EngagementPercentage] set Percentage=COALESCE(@WPPreparedpercentage,0)			where GroupName='Workprogram' and PercentageType='Prepared' and EngagementId=@engagementId
			Update [Tax].[EngagementPercentage] set Percentage=COALESCE(@WPReviewdpercentage,0)			where GroupName='Workprogram' and PercentageType='Reviewd' and EngagementId=@engagementId
			Update [Tax].[EngagementPercentage] set Percentage=COALESCE(@PlanningPreparedpercentage,0)	where GroupName='Planning' and PercentageType='Prepared' and EngagementId=@engagementId
			Update [Tax].[EngagementPercentage] set Percentage=COALESCE(@PlanningReviewdpercentage,0)		where GroupName='Planning' and PercentageType='Reviewd' and EngagementId=@engagementId
			Update [Tax].[EngagementPercentage] set Percentage=COALESCE(@CompletionPreparedpercentage,0)	where GroupName='Completion' and PercentageType='Prepared' and EngagementId=@engagementId
			Update [Tax].[EngagementPercentage] set Percentage=COALESCE(@CompletionReviewdpercentage,0)	where GroupName='Completion' and PercentageType='Reviewd' and EngagementId=@engagementId
			Update [Tax].[EngagementPercentage] set Percentage=COALESCE(@OverallPrepared,0)				where GroupName='OverallPrepared' and PercentageType='Prepared' and EngagementId=@engagementId
			Update [Tax].[EngagementPercentage] set Percentage=COALESCE(@OverallReviewed,0)				where GroupName='OverallReviewd' and PercentageType='Reviewd' and EngagementId=@engagementId
			Update [Tax].[EngagementPercentage] set Percentage=COALESCE(@OverallPercentage,0)				where GroupName='OverallPercentage' and PercentageType='Percentage' and EngagementId=@engagementId

		END
	If(@type ='Comment')
		 Begin
		    Update [Tax].[EngagementPercentage]  set Percentage=(select count(*) from  [Common].[Comment] Where IsReview=1 and GroupTypeId=@engagementId and Status=1) where GroupName='ReviewComment' and PercentageType='Comment' and EngagementId=@engagementId
		 End
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
