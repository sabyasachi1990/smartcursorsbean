USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Client_CaseMembers_ServiceGroup_CompanyIdandClientId]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[SP_Client_CaseMembers_ServiceGroup_CompanyIdandClientId]

@CompanyId BigInt,
@ClientId uniqueidentifier

As
Begin

-- Exec [dbo].[SP_Client_CaseMembers_ServiceGroup_CompanyIdandClientId] 1,'C7D7613F-A5A6-4E60-A742-002D630F3FD7'

--Declare @CompanyId BigInt=1,
--        @ClientId uniqueidentifier='C7D7613F-A5A6-4E60-A742-002D630F3FD7'

--Select Distinct sg.Name 'Service Group'
--from WorkFlow.Client C
-- left join WorkFlow.CaseGroup CG ON CG.ClientId=C.Id
-- Join Common.ServiceGroup sg on sg.id=CG.ServiceGroupId
-- Where C.CompanyId=1 and C.Id=@ClientId
-- Order By sg.Name
    
	SELECT  Distinct sg.Id 'ServiceGroupId',sg.Name as 'Service Group'  , STUFF((
     SELECT Distinct  ', ' + Email
     FROM 
     (
      select Distinct A.CompanyId ,SG.Id AS SGId,A.id AS ClientId,E.Username as Email  from 
      WorkFlow.Client A 
      Left  join WorkFlow.CaseGroup CG ON CG.ClientId=A.Id
      LEFT JOIN WorkFlow.ScheduleNew S ON S.CaseId=CG.Id
      LEFT JOIN WorkFlow.ScheduleDetailNew SD ON SD.MasterId=S.Id
      LEFT JOIN Common.Employee E ON E.ID=SD.EmployeeId
      left join Common.ServiceGroup SG on SG.id=CG.ServiceGroupId
      where sd.IsPrimaryIncharge=1
     --WHERE A.CompanyId=1 AND and A.Id ='C7D7613F-A5A6-4E60-A742-002D630F3FD7' 
     )GG
      WHERE GG.ClientId=A.Id and GG.CompanyId=a.CompanyId  and GG.SGId=SG.Id
      FOR XML PATH('')), 1, 1, '') as  'Owner'
      FROM  WorkFlow.Client A
      left join WorkFlow.CaseGroup C ON C.ClientId=A.Id
      left join Common.ServiceGroup sg on sg.id=c.ServiceGroupId
      WHERE  A.CompanyId=@CompanyId and A.Id =@ClientId   
      ------WHERE A.CompanyId=1 AND and A.Id ='C7D7613F-A5A6-4E60-A742-002D630F3FD7' 
      
      ORDER BY sg.Name


 End
GO
