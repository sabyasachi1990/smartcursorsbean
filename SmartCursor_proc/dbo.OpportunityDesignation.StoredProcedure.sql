USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[OpportunityDesignation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[OpportunityDesignation](@Id uniqueidentifier)
AS
BEGIN
	SELECT * from ClientCursor.OpportunityDesignation where DepartmentDesignationId=@Id
END
GO
