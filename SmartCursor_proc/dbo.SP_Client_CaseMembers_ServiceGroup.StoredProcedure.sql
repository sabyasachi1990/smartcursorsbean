USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_Client_CaseMembers_ServiceGroup]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 create Procedure [dbo].[SP_Client_CaseMembers_ServiceGroup] 
 @CompanyId bigint ,
 @Client nvarchar (max)
  as
  begin
  --- Exec SP_Client_CaseMembers_ServiceGroup 1,null
  ---Exec SP_Client_CaseMembers_ServiceGroup 1,'1 CLICK INVESTMENTS PTE. LTD.'

 if (@Client is not null)
 select distinct  a.Name as 'Client Name',CaseNumber,sg.Name as ServiceGroup ,FromDate,ToDate,FirstName as Employee,Username as Email 
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
where  a.CompanyId=@CompanyId  and A.Name=@Client
order by a.Name,CaseNumber,FirstName
 else 
  select distinct a.Name as 'Client Name',CaseNumber,sg.Name as ServiceGroup,FromDate,ToDate,FirstName as Employee,Username as Email 
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
where  a.CompanyId=@CompanyId 
order by a.Name,CaseNumber,FirstName
end 



                


GO
