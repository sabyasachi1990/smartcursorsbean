USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Tax_DashBoardPercentage]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
--------------------------------------------------

CREATE Procedure [dbo].[SP_Tax_DashBoardPercentage] @engagementId uniqueidentifier
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
		 Begin	 

			--**Trail balance Percentage**		
							(select @TBPreparedpercentage=(select percentage from  Tax.EngagementPercentage where EngagementId=@engagementId and PercentageType='Prepared' and groupname='Financials'))

				 
							
							(select @TBReviewdpercentage= (select percentage from  Tax.EngagementPercentage where EngagementId=@engagementId and PercentageType='Reviewd' and groupname='Financials'))

			--**Work Program Percentage**        
							(select @WPPreparedpercentage= (select percentage from  Tax.EngagementPercentage where EngagementId=@engagementId and PercentageType='Prepared' and groupname='WorkProgram'))
							
							(select @WPReviewdpercentage= (select percentage from  Tax.EngagementPercentage where EngagementId=@engagementId and PercentageType='Reviewd' and groupname='WorkProgram'))


			--**Planning Percentage** 
							(select @PlanningPreparedpercentage= (select percentage from  Tax.EngagementPercentage where EngagementId=@engagementId and PercentageType='Prepared' and groupname='Planning'))
							
							(select @PlanningReviewdpercentage= (select percentage from  Tax.EngagementPercentage where EngagementId=@engagementId and PercentageType='Reviewd' and groupname='Planning'))


			--**Complition Percentage**       
							(select @CompletionPreparedpercentage= (select percentage from  Tax.EngagementPercentage where EngagementId=@engagementId and PercentageType='Prepared' and groupname='Completion'))
							
							(select @CompletionReviewdpercentage= (select percentage from  Tax.EngagementPercentage where EngagementId=@engagementId and PercentageType='Reviewd' and groupname='Completion'))

			select @OverallPrepared =(select percentage from  Tax.EngagementPercentage where EngagementId=@engagementId and PercentageType='Prepared' and groupname='OverallPrepared')
			select @OverallReviewed = (select percentage from  Tax.EngagementPercentage where EngagementId=@engagementId and PercentageType='Reviewd' and groupname='OverallReviewd')
			select @OverallPercentage = (select percentage from  Tax.EngagementPercentage where EngagementId=@engagementId and PercentageType='Percentage' and groupname='OverallPercentage')



						select COALESCE(@TBPreparedpercentage,0) as TBPreparedpercentage,COALESCE(@TBReviewdpercentage,0) as TBReviewdpercentage,
				   COALESCE(@WPPreparedpercentage,0) as WPPreparedpercentage,COALESCE(@WPReviewdpercentage,0) as WPReviewdpercentage,
				   COALESCE(@PlanningPreparedpercentage,0) as PlanningPreparedpercentage,COALESCE(@PlanningReviewdpercentage,0) as PlanningReviewdpercentage,
				   COALESCE(@CompletionPreparedpercentage,0) as CompletionPreparedpercentage,COALESCE(@CompletionReviewdpercentage,0) as CompletionReviewdpercentage,
				   COALESCE(@OverallPrepared,0) as OverallPrepared , COALESCE(@OverallReviewed,0) as OverallReviewed, COALESCE(@OverallPercentage,0) as OverallPercentage;
		

		END
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
