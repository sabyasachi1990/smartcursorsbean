USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Client_CaseMembers_POC]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SP_Client_CaseMembers_POC]
@CompanyId BigInt,
@ClientId uniqueidentifier,
@ServiceGroupId BigInt
As
Begin
------EXEC [dbo].[SP_Client_CaseMembers_POC] 1,'C7D7613F-A5A6-4E60-A742-002D630F3FD7',7
------ EXEC [dbo].[SP_Client_CaseMembers_POC] 1,'C7D7613F-A5A6-4E60-A742-002D630F3FD7',NULL
-------EXEC [dbo].[SP_Client_CaseMembers_POC] 1,NULL,NULL
  IF (@CompanyId IS NOT NULL AND @ClientId IS NULL AND @ServiceGroupId IS NULL)
  BEGIN 
  --- ================================= Client Name  AND Email =====================================
    SELECT  A.NAME AS 'Client'  , STUFF((
    SELECT Distinct  ', ' + Email
    FROM 
    (
      select Distinct A.CompanyId ,A.id AS ClientId,E.username as Email  from 
      WorkFlow.Client A 
      Left  join WorkFlow.CaseGroup CG ON CG.ClientId=A.Id
      LEFT JOIN WorkFlow.ScheduleNew S ON S.CaseId=CG.Id
      LEFT JOIN WorkFlow.ScheduleDetailNew SD ON SD.MasterId=S.Id
      LEFT JOIN Common.Employee E ON E.ID=SD.EmployeeId
      where sd.IsPrimaryIncharge=1
      --WHERE A.CompanyId=1 AND and A.Id ='C7D7613F-A5A6-4E60-A742-002D630F3FD7' 
     )GG
     WHERE GG.ClientId=A.Id and GG.CompanyId=a.CompanyId 
     FOR XML PATH('')), 1, 1, '') as 'Owner'
     FROM  WorkFlow.Client A
     WHERE  A.CompanyId=@CompanyId 
      ------WHERE A.CompanyId=1 AND and A.Id ='C7D7613F-A5A6-4E60-A742-002D630F3FD7' 
     ORDER BY A.NAME
  END  
  IF (@CompanyId IS NOT NULL AND @ClientId IS NOT NULL AND @ServiceGroupId IS NULL)
  BEGIN 
  --- =================================  ServiceGroup AND Email =====================================
     SELECT  Distinct sg.Name as 'Service Group'  , STUFF((
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
  END 
  IF (@CompanyId IS NOT NULL AND @ClientId IS NOT NULL AND @ServiceGroupId IS NOT  NULL)
  BEGIN 
  --- =================================  Employee AND Email =====================================
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
  END

End
GO
