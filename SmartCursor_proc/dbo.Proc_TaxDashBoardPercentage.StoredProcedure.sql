USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TaxDashBoardPercentage]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------
--Dashboard SP

Create   procedure [dbo].[Proc_TaxDashBoardPercentage](@EngagementId uniqueidentifier)
as begin

Begin Transaction
BEGIN TRY

BEGIN
   IF NOT EXISTS (SELECT * FROM [Tax].[EngagementPercentage]
 WHERE [EngagementId] = @EngagementId  and GroupName='Financials' and PercentageType='Prepared') 
   BEGIN
INSERT [Tax].[EngagementPercentage] ([Id], [EngagementId], [GroupName], [PercentageType], [Percentage])
VALUES (NEWID(), @EngagementId, 'Financials', N'Prepared', 0)
   END
END;



BEGIN
   IF NOT EXISTS (SELECT * FROM [Tax].[EngagementPercentage]
 WHERE [EngagementId] = @EngagementId and GroupName='Planning' and PercentageType='Prepared')
   BEGIN
INSERT [Tax].[EngagementPercentage] ([Id], [EngagementId], [GroupName], [PercentageType], [Percentage])
VALUES (NEWID(), @EngagementId, 'Planning', N'Prepared', 0)
   END
END;


BEGIN
   IF NOT EXISTS (SELECT * FROM [Tax].[EngagementPercentage]
 WHERE [EngagementId] = @EngagementId and GroupName='Completion' and PercentageType='Prepared')
   BEGIN
INSERT [Tax].[EngagementPercentage] ([Id], [EngagementId], [GroupName], [PercentageType], [Percentage])
VALUES (NEWID(), @EngagementId, 'Completion', N'Prepared', 0)
   END
END;



BEGIN
   IF NOT EXISTS (SELECT * FROM [Tax].[EngagementPercentage]
 WHERE [EngagementId] = @EngagementId and GroupName='Workprogram' and PercentageType='Prepared')
   BEGIN
INSERT [Tax].[EngagementPercentage] ([Id], [EngagementId], [GroupName], [PercentageType], [Percentage])
VALUES (NEWID(), @EngagementId, 'Workprogram', N'Prepared', 0)
   END
END;



BEGIN
   IF NOT EXISTS (SELECT * FROM [Tax].[EngagementPercentage]
 WHERE [EngagementId] = @EngagementId and GroupName='OverallPrepared' and PercentageType='Prepared')
   BEGIN
INSERT [Tax].[EngagementPercentage] ([Id], [EngagementId], [GroupName], [PercentageType], [Percentage])
VALUES (NEWID(), @EngagementId, 'OverallPrepared', N'Prepared', 0)
   END
END;



BEGIN
   IF NOT EXISTS (SELECT * FROM [Tax].[EngagementPercentage]
 WHERE [EngagementId] = @EngagementId and GroupName='Financials' and PercentageType='Reviewd')
   BEGIN
INSERT [Tax].[EngagementPercentage] ([Id], [EngagementId], [GroupName], [PercentageType], [Percentage])
VALUES (NEWID(), @EngagementId, 'Financials', N'Reviewd', 0)
   END
END;



BEGIN
   IF NOT EXISTS (SELECT * FROM [Tax].[EngagementPercentage]
 WHERE [EngagementId] = @EngagementId and GroupName='Planning' and PercentageType='Reviewd')
   BEGIN
INSERT [Tax].[EngagementPercentage] ([Id], [EngagementId], [GroupName], [PercentageType], [Percentage])
VALUES (NEWID(), @EngagementId, 'Planning', N'Reviewd', 0)
   END
END;


BEGIN
   IF NOT EXISTS (SELECT * FROM [Tax].[EngagementPercentage]
 WHERE [EngagementId] = @EngagementId and GroupName='Completion' and PercentageType='Reviewd')
   BEGIN
INSERT [Tax].[EngagementPercentage] ([Id], [EngagementId], [GroupName], [PercentageType], [Percentage])
VALUES (NEWID(), @EngagementId, 'Completion', N'Reviewd', 0)
   END
END;



BEGIN
   IF NOT EXISTS (SELECT * FROM [Tax].[EngagementPercentage]
 WHERE [EngagementId] = @EngagementId and GroupName='Workprogram' and PercentageType='Reviewd')
   BEGIN
INSERT [Tax].[EngagementPercentage] ([Id], [EngagementId], [GroupName], [PercentageType], [Percentage])
VALUES (NEWID(), @EngagementId, 'Workprogram', N'Reviewd', 0)
   END
END;


BEGIN
   IF NOT EXISTS (SELECT * FROM [Tax].[EngagementPercentage]
 WHERE [EngagementId] = @EngagementId and GroupName='OverallReviewd' and PercentageType='Reviewd')
   BEGIN
INSERT [Tax].[EngagementPercentage] ([Id], [EngagementId], [GroupName], [PercentageType], [Percentage])
VALUES (NEWID(), @EngagementId, 'OverallReviewd', N'Reviewd', 0)
   END
END;

 

 

BEGIN
   IF NOT EXISTS (SELECT * FROM [Tax].[EngagementPercentage]
 WHERE [EngagementId] = @EngagementId and GroupName='OverallPercentage' and PercentageType='Percentage')
   BEGIN
INSERT [Tax].[EngagementPercentage] ([Id], [EngagementId], [GroupName], [PercentageType], [Percentage])
VALUES (NEWID(), @EngagementId, 'OverallPercentage', N'Percentage', 0)
   END
END;

 

 


BEGIN
   IF NOT EXISTS (SELECT * FROM [Tax].[EngagementPercentage]
 WHERE [EngagementId] = @EngagementId and GroupName='ReviewComment' and PercentageType='Comment')
   BEGIN
INSERT [Tax].[EngagementPercentage] ([Id], [EngagementId], [GroupName], [PercentageType], [Percentage])
VALUES (NEWID(), @EngagementId, 'ReviewComment', N'Comment', 0)
   END
END;

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
