USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Client_CaseMembers_ServiceGroup_CompanyIdandClientIdandServiGroupId]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SP_Client_CaseMembers_ServiceGroup_CompanyIdandClientIdandServiGroupId]

@CompanyId BigInt,
@ClientId uniqueidentifier,
@ServiceGroupId BigInt

As
Begin

-- Exec [dbo].[SP_Client_CaseMembers_ServiceGroup_CompanyIdandClientIdandServiGroupId] 1,'C7D7613F-A5A6-4E60-A742-002D630F3FD7',7

 --Declare @CompanyId int=1,
 --        @ClientId uniqueidentifier='C7D7613F-A5A6-4E60-A742-002D630F3FD7',
	--	 @ServiceGroupId BigInt=7

-- Select FirstName as Employee,Username as Email 
-- from WorkFlow.Client A
-- left join WorkFlow.CaseGroup C ON C.ClientId=A.Id
-- left join Common.ServiceGroup sg on sg.id=c.ServiceGroupId
-- LEFT JOIN 
-- (
--  SELECT Distinct S.CaseId,E.FirstName,Username,c.CompanyId FROM WorkFlow.CaseGroup C
--  INNER JOIN WorkFlow.ScheduleNew S ON S.CaseId=C.Id
--  INNER JOIN WorkFlow.ScheduleDetailNew SD ON SD.MasterId=S.Id
--  INNER JOIN Common.Employee E ON E.ID=SD.EmployeeId
  
--  )gg on gg.CaseId=c.Id and gg.CompanyId=C.CompanyId
--where  a.CompanyId=@CompanyId  and A.Id=@ClientId and sg.Id=@ServiceGroupId
--order by a.Name,CaseNumber,FirstName
     Select Distinct FirstName as Employee,Username as  'Owner' 
     from WorkFlow.Client A
     left join WorkFlow.CaseGroup C ON C.ClientId=A.Id
     left join Common.ServiceGroup sg on sg.id=c.ServiceGroupId
     LEFT JOIN 
    (
     SELECT Distinct S.CaseId,E.FirstName,Username,c.CompanyId FROM WorkFlow.CaseGroup C
     INNER JOIN WorkFlow.ScheduleNew S ON S.CaseId=C.Id
     INNER JOIN WorkFlow.ScheduleDetailNew SD ON SD.MasterId=S.Id
     INNER JOIN Common.Employee E ON E.ID=SD.EmployeeId
     
     )gg on gg.CaseId=c.Id and gg.CompanyId=C.CompanyId
     where  a.CompanyId=@CompanyId  and A.Id=@ClientId and sg.Id=@ServiceGroupId
   ------WHERE A.CompanyId=1 AND and A.Id ='C7D7613F-A5A6-4E60-A742-002D630F3FD7'  AND and sg.Id=7
     order by FirstName
End
GO
