USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[IsMonthlyProrationStatus]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[IsMonthlyProrationStatus] ---- EXEC dbo.IsMonthlyProrationStatus
AS

BEGIN
	UPDATE [HR].[LeaveEntitlement] SET IsMonthlyProration = 0 WHERE IsMonthlyProration = 1
END
GO
