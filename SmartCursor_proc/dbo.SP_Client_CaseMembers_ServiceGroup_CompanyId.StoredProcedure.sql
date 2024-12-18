USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Client_CaseMembers_ServiceGroup_CompanyId]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[SP_Client_CaseMembers_ServiceGroup_CompanyId]

@CompanyId BigInt

As
Begin

-- Exec [dbo].[SP_Client_CaseMembers_ServiceGroup_CompanyId] 1

--Declare @CompanyId BigInt=1

--Select Distinct Name as Client
--from WorkFlow.Client
--Where CompanyId=@CompanyId
--Order BY Name


    SELECT  A.Id as ClientId,A.NAME AS 'Client'  , STUFF((
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
     WHERE  A.CompanyId=@CompanyId -- and A.Id=@ClientId
   --  WHERE A.CompanyId=1 
     ORDER BY A.NAME

End
GO
