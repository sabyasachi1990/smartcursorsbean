USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_DeleteScheduleTasks]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--========================================================================21 ==================================================================
create Procedure [dbo].[SP_DeleteScheduleTasks] @ID NVARCHAR(MAX)
AS BEGIN

DECLARE @valueList Nvarchar(max)
SET @valueList = @ID
Select items From SplitToTable(@valueList,',')
BEGIN

delete WorkFlow.ScheduleTaskNew where Id in (Select items From SplitToTable(@valueList,','))

end
End





GO
