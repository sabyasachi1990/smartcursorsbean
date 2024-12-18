USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_OpportunityReOpen]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_OpportunityReOpen](@OpportunityId UNIQUEIDENTIFIER ,@NewOpportunityId UNIQUEIDENTIFIER)
AS BEGIN
/****** Author : G Sreenivasulu    Object:  StoredProcedure [dbo].[SP_OpportunityReOpen]   Script Date: 23-Jan-16 9:52:19 AM ******/
UPDATE [ClientCursor].[OpportunityIncharge] set OpportunityId=@NewOpportunityId where OpportunityId=@OpportunityId
UPDATE [ClientCursor].[OpportunityDesignation] set OpportunityId=@NewOpportunityId where OpportunityId=@OpportunityId 
END
GO
