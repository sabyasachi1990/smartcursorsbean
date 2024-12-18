USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CaseIncharge_Modification]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[CaseIncharge_Modification]

-- Exec CaseIncharge_Modification

AS
BEGIN

select Distinct PP.[Case Ref No],ClientNane ClientName,
Incharge,Incharge2,Incharge3,Incharge4,PrimaryIncharge,PIC,Employee
,Employee1,Employee2,Employee3,Employee4,Employee5,Employee6,Employee7,Employee8
from 
(
select * from 
(
select tt.Date,tt.ClientNane,tt.[Case Ref No],tt.Incharge,tt.Incharge2,tt.Incharge3,tt.Incharge4,
tt.FirstName,
Case when Employee is Null Then pic else Employee end as Employee,Employee1,Employee2,Employee3,Employee4,Employee5,Employee6,Employee7,Employee8,PIC,PrimaryIncharge

 from 
(
select DENSE_RANK() OVER (PARTITION BY casenumber ORDER BY e.firstName) AS Rank,
A.Date,A.ClientNane,A.PrimaryIncharge,A.PIC,
A.[Case Ref No],A.Incharge,A.Incharge2,A.Incharge3,Incharge4,e.FirstName,td.employeeid
 from [dbo].[CaseIncharge$] A
Inner Join WorkFlow.CaseGroup AS CG on CG.caseNumber=A.[Case Ref No]
Inner Join WorkFlow.Client C ON C.id=CG.ClientId
Left Join WorkFlow.Schedule T on T.caseid=CG.Id
Left Join WorkFlow.Scheduledetail Td on T.Id=td.masterid
Left Join Common.Employee e on e.Id=td.EmployeeId
where c.CompanyId=1 
)as TT
--Order By Rank

left Join
(
select FirstName as Employee,[Case Ref No]--,Rank,Date,ClientNane,Incharge,Incharge2,Incharge3,Incharge4 
from 
(
select DENSE_RANK() OVER (PARTITION BY casenumber ORDER BY e.firstName Desc) AS Rank,
A.Date,A.ClientNane,A.PIC,A.PrimaryIncharge,
A.[Case Ref No],A.Incharge,A.Incharge2,A.Incharge3,Incharge4,e.FirstName,td.employeeid
 from [dbo].[CaseIncharge$] A
Inner Join WorkFlow.CaseGroup AS CG on cG.caseNumber=A.[Case Ref No]
Inner Join WorkFlow.Client C ON C.id=CG.ClientId
Left Join WorkFlow.Schedule T on T.caseid=CG.Id
Left Join WorkFlow.Scheduledetail Td on T.Id=td.masterid
Left Join Common.Employee e on e.Id=td.EmployeeId
where c.CompanyId=1 
)as AA
--Order By Rank
where Rank=1
)as bb on bb.[Case Ref No]=TT.[Case Ref No]
Left Join
(

select  Distinct FirstName AS Employee1 ,[Case Ref No] from 
(
select RANK() OVER (PARTITION BY casenumber ORDER BY e.firstName DeSC) AS Rank,A.Date,A.ClientNane,A.PIC,A.[Case Ref No],A.Incharge,A.Incharge2,A.Incharge3,Incharge4,e.FirstName,td.employeeid,A.PrimaryIncharge
 from [dbo].[CaseIncharge$] A
Inner Join WorkFlow.CaseGroup AS CG on cG.caseNumber=A.[Case Ref No]
Inner Join WorkFlow.Client C ON C.id=CG.ClientId
Left Join WorkFlow.Schedule T on T.caseid=CG.Id
Left Join WorkFlow.Scheduledetail Td on T.Id=td.masterid
Left Join Common.Employee e on e.Id=td.EmployeeId
where c.CompanyId=1 
)as AA
where Rank=2
)as CC on CC.[Case Ref No]=TT.[Case Ref No]
Left Join
(
select Distinct FirstName AS Employee2,[Case Ref No] from 
(
select RANK() OVER (PARTITION BY casenumber ORDER BY e.firstName DeSC) AS Rank,A.Date,A.ClientNane,
A.[Case Ref No],A.Incharge,A.Incharge2,A.Incharge3,Incharge4,e.FirstName,td.employeeid,A.PIC,A.PrimaryIncharge
 from [dbo].[CaseIncharge$] A
Inner Join WorkFlow.CaseGroup AS CG on cG.caseNumber=A.[Case Ref No]
Inner Join WorkFlow.Client C ON C.id=CG.ClientId
Left Join WorkFlow.Schedule T on T.caseid=CG.Id
Left Join WorkFlow.Scheduledetail Td on T.Id=td.masterid
Left Join Common.Employee e on e.Id=td.EmployeeId
where c.CompanyId=1 
)as AA
where Rank=3 
)as DD on dd.[Case Ref No]=CC.[Case Ref No]
Left Join 
(
select Distinct FirstName AS Employee3,[Case Ref No] from 
(
select RANK() OVER (PARTITION BY casenumber ORDER BY e.firstName DeSC) AS Rank,A.Date,A.ClientNane,
A.[Case Ref No],A.Incharge,A.Incharge2,A.Incharge3,Incharge4,e.FirstName,td.employeeid,A.PIC,A.PrimaryIncharge
 from [dbo].[CaseIncharge$] A
Inner Join WorkFlow.CaseGroup AS CG on cG.caseNumber=A.[Case Ref No]
Inner Join WorkFlow.Client C ON C.id=CG.ClientId
Left Join WorkFlow.Schedule T on T.caseid=CG.Id
Left Join WorkFlow.Scheduledetail Td on T.Id=td.masterid
Left Join Common.Employee e on e.Id=td.EmployeeId
where c.CompanyId=1 --and [Case Ref No]='CE-RNTRBA-2018-01599'
)as AA
where Rank=4
)as EE on EE.[Case Ref No]=DD.[Case Ref No]
Left Join 
(
select Distinct FirstName AS Employee4,[Case Ref No] from 
(
select RANK() OVER (PARTITION BY casenumber ORDER BY e.firstName DeSC) AS Rank,A.Date,A.ClientNane,
A.[Case Ref No],A.Incharge,A.Incharge2,A.Incharge3,Incharge4,e.FirstName,td.employeeid,A.PIC,A.PrimaryIncharge
 from [dbo].[CaseIncharge$] A
Inner Join WorkFlow.CaseGroup AS CG on cG.caseNumber=A.[Case Ref No]
Inner Join WorkFlow.Client C ON C.id=CG.ClientId
Left Join WorkFlow.Schedule T on T.caseid=CG.Id
Left Join WorkFlow.Scheduledetail Td on T.Id=td.masterid
Left Join Common.Employee e on e.Id=td.EmployeeId
where c.CompanyId=1 
)as AA
where Rank=5
)as GG on GG.[Case Ref No]=EE.[Case Ref No]
Left Join 
(
select Distinct FirstName AS Employee5,[Case Ref No] from 
(
select RANK() OVER (PARTITION BY casenumber ORDER BY e.firstName DeSC) AS Rank,A.Date,A.ClientNane,
A.[Case Ref No],A.Incharge,A.Incharge2,A.Incharge3,Incharge4,e.FirstName,td.employeeid,A.PIC,A.PrimaryIncharge
 from [dbo].[CaseIncharge$] A
Inner Join WorkFlow.CaseGroup AS CG on cG.caseNumber=A.[Case Ref No]
Inner Join WorkFlow.Client C ON C.id=CG.ClientId
Left Join WorkFlow.Schedule T on T.caseid=CG.Id
Left Join WorkFlow.Scheduledetail Td on T.Id=td.masterid
Left Join Common.Employee e on e.Id=td.EmployeeId
where c.CompanyId=1 
)as AA
where Rank=6
)as hh on hh.[Case Ref No]=GG.[Case Ref No]
Left Join 
(
select  Distinct FirstName AS Employee6,[Case Ref No] from 
(
select RANK() OVER (PARTITION BY casenumber ORDER BY e.firstName DeSC) AS Rank,A.Date,A.ClientNane,
A.[Case Ref No],A.Incharge,A.Incharge2,A.Incharge3,Incharge4,e.FirstName,td.employeeid,A.PIC,A.PrimaryIncharge
 from [dbo].[CaseIncharge$] A
Inner Join WorkFlow.CaseGroup AS CG on cG.caseNumber=A.[Case Ref No]
Inner Join WorkFlow.Client C ON C.id=CG.ClientId
Left Join WorkFlow.Schedule T on T.caseid=CG.Id
Left Join WorkFlow.Scheduledetail Td on T.Id=td.masterid
Left Join Common.Employee e on e.Id=td.EmployeeId
where c.CompanyId=1 
)as AA
where Rank=7
)as KK on KK.[Case Ref No]=hh.[Case Ref No]

Left Join 
(
select  Distinct FirstName AS Employee7,[Case Ref No] from 
(
select RANK() OVER (PARTITION BY casenumber ORDER BY e.firstName DeSC) AS Rank,A.Date,A.ClientNane,
A.[Case Ref No],A.Incharge,A.Incharge2,A.Incharge3,Incharge4,e.FirstName,td.employeeid,A.PIC,A.PrimaryIncharge
 from [dbo].[CaseIncharge$] A
Inner Join WorkFlow.CaseGroup AS CG on cG.caseNumber=A.[Case Ref No]
Inner Join WorkFlow.Client C ON C.id=CG.ClientId
Left Join WorkFlow.Schedule T on T.caseid=CG.Id
Left Join WorkFlow.Scheduledetail Td on T.Id=td.masterid
Left Join Common.Employee e on e.Id=td.EmployeeId
where c.CompanyId=1 
)as AA
where Rank=8
)as mm on mm.[Case Ref No]=KK.[Case Ref No]

Left Join 
(
select Distinct FirstName AS Employee8,[Case Ref No] from 
(
select RANK() OVER (PARTITION BY casenumber ORDER BY e.firstName DeSC) AS Rank,A.Date,A.ClientNane,
A.[Case Ref No],A.Incharge,A.Incharge2,A.Incharge3,Incharge4,e.FirstName,td.employeeid,A.PIC,A.PrimaryIncharge
 from [dbo].[CaseIncharge$] A
Inner Join WorkFlow.CaseGroup AS CG on cG.caseNumber=A.[Case Ref No]
Inner Join WorkFlow.Client C ON C.id=CG.ClientId
Left Join WorkFlow.Schedule T on T.caseid=CG.Id
Left Join WorkFlow.Scheduledetail Td on T.Id=td.masterid
Left Join Common.Employee e on e.Id=td.EmployeeId
where c.CompanyId=1 
)as AA
where Rank=9
)as nn on nn.[Case Ref No]=mm.[Case Ref No]
)as oo
)as PP 
--where [Case Ref No]='CE-ACCACT-2018-00282'
Order By ClientName
--where oo.Employee8
END







GO
