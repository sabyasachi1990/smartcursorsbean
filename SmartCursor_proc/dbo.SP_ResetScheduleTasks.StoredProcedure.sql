USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_ResetScheduleTasks]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  Procedure [dbo].[SP_ResetScheduleTasks] 

--@CompanyId BIGINT,

@CaseId Uniqueidentifier


As

Begin

Delete WorkFlow.ScheduleTask where CaseId=@CaseId


update WorkFlow.ScheduleDetail set IsLocked=0, PlanedHours=0,FeeAllocationPercentage=0,FeeAllocation=0,[Fee RecoveryPercentage]=0,StartDate=null,EndDate=null,PlannedCost=0 where 
--EmployeeId not in (Select EmployeeId from Common.TimeLogSchedule where CaseId=@CaseId ) and
 MasterId in (Select Id from WorkFlow.Schedule where CaseId=@CaseId)

End




GO
