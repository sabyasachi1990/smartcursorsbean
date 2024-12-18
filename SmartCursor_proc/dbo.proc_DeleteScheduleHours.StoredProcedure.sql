USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[proc_DeleteScheduleHours]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--USE [AppsWorldDev]
--GO
--/****** Object:  StoredProcedure [dbo].[proc_DeleteScheduleHours]    Script Date: 05/23/2017 4:35:46 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
CREATE PROCEDURE [dbo].[proc_DeleteScheduleHours] @ID NVARCHAR(MAX),@CaseId UNIQUEIDENTIFIER
AS BEGIN
--- New Code---
DECLARE @valueList Nvarchar(max)
DECLARE @pos INT
DECLARE @len INT
DECLARE @value Nvarchar(max) 
SET @valueList = @ID
set @pos = 0
set @len = 0
WHILE CHARINDEX(',', @valueList, @pos+1)>0
BEGIN
    set @len = CHARINDEX(',', @valueList, @pos+1) - @pos
    set @value = SUBSTRING(@valueList, @pos, @len)        
    PRINT @value 
    DELETE FROM WorkFlow.ScheduleTask WHERE EmployeeId =cast (@value  AS UNIQUEIDENTIFIER) AND CaseId = @CaseId
    set @pos = CHARINDEX(',', @valueList, @pos+@len) +1
END
----------------

--DELETE FROM WorkFlow.ScheduleTask WHERE EmployeeId IN (@ID) AND CaseId = @CaseId  -- Previous Code
END
















GO
