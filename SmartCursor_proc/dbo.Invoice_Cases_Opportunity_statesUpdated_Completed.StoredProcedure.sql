USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Invoice_Cases_Opportunity_statesUpdated_Completed]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Invoice_Cases_Opportunity_statesUpdated_Completed]

AS
BEGIN

-- Exec Invoice_Cases_Opportunity_statesUpdated_Completed

 select o.id,o.name,count(cg.Id)  as  count FROM WorkFlow.CaseGroup CG
 INNER JOIN [ClientCursor].[Opportunity] O ON O.ID=CG.OpportunityId
  WHERE CG.CompanyId=1 AND CG.Id IN 
(
select DISTINCT CaseId from 
(
select year(InvDate)Year,InvDate,CaseId,State from WorkFlow.Invoice 
where   State='Fully Paid' and CompanyId=1 
)AS AA
where Year=2018
)
group by o.id,o.name
 having count(cg.Id)>1  ---========================== duplicates  opp count ==63





    select distinct  o.id FROM WorkFlow.CaseGroup CG
 INNER JOIN [ClientCursor].[Opportunity] O ON O.ID=CG.OpportunityId
  WHERE CG.CompanyId=1 AND CG.Id IN 
(
select DISTINCT CaseId from 
(
select year(InvDate)Year,InvDate,CaseId,State from WorkFlow.Invoice 
where   State='Fully Paid' and CompanyId=1 
)AS AA
where Year=2018
)--=====================================================total opp count =2245



 select distinct id  from   WorkFlow.CaseGroup   WHERE COMPANYID=1 AND ID IN 
(
select DISTINCT CaseId from 
(
select year(InvDate)Year,InvDate,CaseId,State from WorkFlow.Invoice 
where   State='Fully Paid' and CompanyId=1 
)AS AA
where Year=2018
)--======================================================= total cases count =2308




/* Update Statements in Comment-----we will Verify uncomment-------


---================================================ UPDATE  CASESTATE IS 'Complete'===CASECOUNT=2308

BEGIN TRANSACTION
GO

Declare @CompanyId INT=1

UPDATE  WorkFlow.CaseGroup  SET STAGE='Complete' WHERE COMPANYID=@CompanyId AND ID IN 
(
select DISTINCT CaseId from 
(
select year(InvDate)Year,InvDate,CaseId,State from WorkFlow.Invoice 
where   State='Fully Paid' and CompanyId=@CompanyId 
)AS AA
where Year=2018
)

--=====================================================================================
ROLLBACK TRANSACTION
GO


---================================================ UPDATE   OPPSTATE  IS 'Complete'=== OPPCOUNT=2245

 
BEGIN TRANSACTION
GO

Declare @CompanyId INT=1

 UPDATE O SET O.STAGE='Complete' FROM WorkFlow.CaseGroup CG
 INNER JOIN [ClientCursor].[Opportunity] O ON O.ID=CG.OpportunityId
  WHERE CG.CompanyId=@CompanyId AND CG.Id IN 
(
select DISTINCT CaseId from 
(
select year(InvDate)Year,InvDate,CaseId,State from WorkFlow.Invoice 
where   State='Fully Paid' and CompanyId=@CompanyId 
)AS AA
where Year=2018
)

ROLLBACK TRANSACTION
GO

--=================================================================

 
 ---================================================  INSERT  CASESTATESCHANGE   IS 'Complete'=== OPPCOUNT=2308

 BEGIN TRANSACTION
GO

Declare @CompanyId INT=1

 INSERT INTO  WorkFlow.CaseStatusChange (Id,CompanyId,CaseId,State,ModifiedBy,ModifiedDate)

 SELECT DISTINCT Newid() as Id,CG.CompanyId,cg.id as CaseId,cg.Stage as State,'System' AS ModifiedBy,getdate() as ModifiedDate FROM  WorkFlow.CaseGroup CG
 --INNER JOIN WorkFlow.CaseStatusChange S ON S.CaseId=CG.Id
 
  WHERE CG.CompanyId=@CompanyId  AND  CG.Id IN 
(
select DISTINCT CaseId from 
(
select year(InvDate)Year,InvDate,CaseId,State from WorkFlow.Invoice 
where   State='Fully Paid' and CompanyId=@CompanyId 
)AS AA
where Year=2018
)

ROLLBACK TRANSACTION
GO
---===========================================================================================

--=================================================================  insert into OpportunityStatusChange IS 'Complete =2245

BEGIN TRANSACTION
GO

Declare @CompanyId INT=1

 INSERT INTO  [ClientCursor].[OpportunityStatusChange] (Id,CompanyId,Opportunityid,State,ModifiedBy,ModifiedDate) 

select distinct Newid() as Id ,o.CompanyId,o.Id as Opportunityid,o.Stage as state,'System' as ModifiedBy,getdate() as modifiedDate FROM [ClientCursor].[Opportunity] O where o.id in 
(
 select distinct o.Id FROM WorkFlow.CaseGroup CG
 INNER JOIN [ClientCursor].[Opportunity] O ON O.ID=CG.OpportunityId
  WHERE CG.CompanyId=@CompanyId AND CG.Id IN 
(
select DISTINCT CaseId from 
(
select year(InvDate)Year,InvDate,CaseId,State from WorkFlow.Invoice 
where   State='Fully Paid' and CompanyId=@CompanyId 
)AS AA
where Year=2018
)
)

ROLLBACK TRANSACTION
GO

--==============================================================================================================================================

  select DISTINCT CaseId,number,State,Stage,InvType ,year(InvDate)Year from WorkFlow.Invoice i  inner join WorkFlow.CaseGroup cg on cg.id=i.CaseId  where State='Fully Paid'and InvType='Interim' and year(InvDate)=2018 and cg.CompanyId=1  and CaseId  not in    ( select DISTINCT CaseId from (select year(InvDate)Year,InvDate,CaseId,State,InvType,number from WorkFlow.Invoice where   State='Fully Paid' and InvType='Final'  and CompanyId=1 )AS AAwhere Year=2018)order by Stage------------================================Some Changes =============================================================================================update WorkFlow.CaseGroup set stage='Assigned' where CompanyId=1  and  id in ('772F75B3-C856-48C2-B9D0-F2FDDDD37E2D','67869D3F-F381-4105-82A1-97F4D73E77E9','80AC98A5-2A2F-497A-BF36-78575BF4AE17','F73299A3-0541-48AB-A9FA-65815F9455D0')update WorkFlow.CaseGroup set stage='In-Progress' where CompanyId=1  and id in ('A224ED23-78A0-482A-A8D7-633250B660E0','1B14F866-2607-430C-8FAA-8535B7AD9C6F','544824DA-F48A-4CF4-8F39-90B3D2F1AC6C','C3D4E4AB-388F-4584-AF42-A1890C8D977D')update   ClientCursor.Opportunity  set Stage='Won'   where   CompanyId=1 and CaseId in ('772F75B3-C856-48C2-B9D0-F2FDDDD37E2D','67869D3F-F381-4105-82A1-97F4D73E77E9','80AC98A5-2A2F-497A-BF36-78575BF4AE17','F73299A3-0541-48AB-A9FA-65815F9455D0','A224ED23-78A0-482A-A8D7-633250B660E0','1B14F866-2607-430C-8FAA-8535B7AD9C6F','544824DA-F48A-4CF4-8F39-90B3D2F1AC6C','C3D4E4AB-388F-4584-AF42-A1890C8D977D') delete from  WorkFlow.CaseStatusChange    where CompanyId=1  and  state='Complete' and  CaseId in ('A224ED23-78A0-482A-A8D7-633250B660E0','1B14F866-2607-430C-8FAA-8535B7AD9C6F','544824DA-F48A-4CF4-8F39-90B3D2F1AC6C','C3D4E4AB-388F-4584-AF42-A1890C8D977D','772F75B3-C856-48C2-B9D0-F2FDDDD37E2D','67869D3F-F381-4105-82A1-97F4D73E77E9','80AC98A5-2A2F-497A-BF36-78575BF4AE17','F73299A3-0541-48AB-A9FA-65815F9455D0') delete from  ClientCursor.OpportunityStatusChange    where CompanyId=1  and  State='Complete' and  OpportunityId in ('7E39E1A0-D98A-4D22-B374-500ABA2CEBF7','F16EDD49-4DAE-4333-A8FE-E51CCB44BE56','AAFF669C-6E82-8846-AC08-CFDAA3E3F365','1BF45AD6-89CB-4AC7-A90C-868354502BBC','7F613C84-8D0A-4BAF-82BA-E5AF4DD5210A','A17110DA-4CC1-58F2-D422-52489D020FA6','0A8B068B-1B60-056F-FA50-5477C5130C2A','06BD7D77-538C-480A-A574-A5285CB25945') select * from  ClientCursor.OpportunityStatusChange     where  CompanyId=1  and  OpportunityId in ('7E39E1A0-D98A-4D22-B374-500ABA2CEBF7','F16EDD49-4DAE-4333-A8FE-E51CCB44BE56','AAFF669C-6E82-8846-AC08-CFDAA3E3F365','1BF45AD6-89CB-4AC7-A90C-868354502BBC','7F613C84-8D0A-4BAF-82BA-E5AF4DD5210A','A17110DA-4CC1-58F2-D422-52489D020FA6','0A8B068B-1B60-056F-FA50-5477C5130C2A','06BD7D77-538C-480A-A574-A5285CB25945')-----57-8 select * from  WorkFlow.CaseStatusChange    where    CompanyId=1  and CaseId in ('A224ED23-78A0-482A-A8D7-633250B660E0','1B14F866-2607-430C-8FAA-8535B7AD9C6F','544824DA-F48A-4CF4-8F39-90B3D2F1AC6C','C3D4E4AB-388F-4584-AF42-A1890C8D977D','772F75B3-C856-48C2-B9D0-F2FDDDD37E2D','67869D3F-F381-4105-82A1-97F4D73E77E9','80AC98A5-2A2F-497A-BF36-78575BF4AE17','F73299A3-0541-48AB-A9FA-65815F9455D0')---------------31-8=23 select * from   ClientCursor.Opportunity     where   CompanyId=1 and CaseId in ('772F75B3-C856-48C2-B9D0-F2FDDDD37E2D','67869D3F-F381-4105-82A1-97F4D73E77E9','80AC98A5-2A2F-497A-BF36-78575BF4AE17','F73299A3-0541-48AB-A9FA-65815F9455D0','A224ED23-78A0-482A-A8D7-633250B660E0','1B14F866-2607-430C-8FAA-8535B7AD9C6F','544824DA-F48A-4CF4-8F39-90B3D2F1AC6C','C3D4E4AB-388F-4584-AF42-A1890C8D977D')*/END
GO
