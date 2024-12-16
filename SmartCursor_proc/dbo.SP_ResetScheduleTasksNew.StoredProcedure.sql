USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_ResetScheduleTasksNew]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   Procedure [dbo].[SP_ResetScheduleTasksNew] 

--@CompanyId BIGINT,

@CaseId Uniqueidentifier


As

Begin


      Delete WorkFlow.ScheduleTaskNew where CaseId=@CaseId

    update WorkFlow.ScheduleDetailNew set IsLocked=0, StartDate=null,EndDate=null where 

 MasterId in (Select Id from WorkFlow.ScheduleNew where CaseId=@CaseId)


End
GO
