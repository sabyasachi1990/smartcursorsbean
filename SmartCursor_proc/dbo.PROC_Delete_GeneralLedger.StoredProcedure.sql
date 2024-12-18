USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PROC_Delete_GeneralLedger]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PROC_Delete_GeneralLedger](@EngagementId UNIQUEIDENTIFIER ,@FileId UNIQUEIDENTIFIER,@Type INT)
AS 
   BEGIN
    if(@Type=0)
			BEGIN
				Update [Audit].[GeneralLedgerImport] set [IsFlag]=1 where EngagementId=@EngagementId;
			END
		ELSE
			BEGIN
				DELETE from [Audit].[GeneralLedgerImport] where EngagementId=@EngagementId and [IsFlag]=1;
			END
	END
GO
