USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[POC_AnalyticsReport]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   Procedure [dbo].[POC_AnalyticsReport]                               
@FromDate Datetime,                    
@ToDate Datetime ,
@CompanyValue Varchar(max),
@EmployeeName varchar(max),
@MONTHYear varchar(100)


AS                                                                     
BEGIN 

Declare @CompanyId Int

select @CompanyId = dbo.DecryptCompanyValue(@CompanyValue)  

 --Exec POC_AnalyticsReport '2018-01-01','2018-02-28',10,' Naga subba reddy','jan-18'



--Declare @Fromdate datetime='2018-02-01',
--@ToDate datetime='2018-02-28',
--@CompanyId int=10,
--@EmployeeName Varchar(Max)='Prabhakar Rachapalli',
--@CaseNuber Varchar(Max)='CASE-2018-00013'



Select CaseNumber,ServiceGroup,EmployeeName,

convert(nvarchar(100),Planned) as 'Planned',
convert(nvarchar(100),Actual) as 'Actual',
convert(nvarchar(100),Recovery) as 'Recovery',MonthYear
 from

(

SELECT   
 EmployeeName,CaseNumber,ServiceGroup,
 Left(datename(MONTH,Date),3)+'-'+Right(Year(Date),2) as MonthYear,
Year(Date) as Year,MONTH(Date) as Month,

--isnull(ChargeOutRate,0) ChargeOutRate,
 CAST((sum(PlannedHours) / 60) AS VARCHAR(10)) + ':' + 
       RIGHT('0' + CAST((sum(PlannedHours) % 60) AS VARCHAR(10)), 2) Planned, 


 CAST((sum(ActualHours) / 60) AS VARCHAR(10)) + ':' + 
       RIGHT('0' + CAST((sum(ActualHours) % 60) AS VARCHAR(10)), 2) Actual,

    dbo.[CalculateHours](sum(PlannedHours),sum(ActualHours)) as Recovery


	from
( -- P

select Date,ServiceCompany,ServiceGroup,CreatedDate,EmployeeName,CaseNumber,EffectiveFrom,EndDate,ChargeOutRate,
Coalesce(sum(ActualHours),0) as 'ActualHours',Coalesce(sum(PlannedHours),0) as PlannedHours

-- ,Month,Year  
from 

( -- PP

Select B1.*,0 as 'PlannedHours' from Common.Employee E2
Inner Join
(

select Comp.name as ServiceCompany,SG.Name as ServiceGroup,E.CreatedDate,TLD.Date as Date,
    E.FirstName as EmployeeName,CG1.CaseNumber,cast(HR.EffectiveFrom as date) as EffectiveFrom,
    Case when HR.EndDate is null then COALESCE(HR.enddate,dateadd(year,10,getdate()))  else
    HR.EndDate end as 'EndDate',
    (DATEPART(hh, TLD.Duration) * 60 ) + (DATEPART(mi, TLD.Duration) ) as  'ActualHours'
    ,(cast(cast(HR.ChargeOutRate AS float)as int)) as 'ChargeOutRate'

   from Common.Employee as E

   Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
   Inner Join [Common].[TimeLog] as TL on TL.EmployeeId = E.Id 
   Inner Join [Common].[TimeLogDetail] as TLD on  TLD.MasterId= TL.Id
   and TLD.Date>=HR.EffectiveFrom and TLD.Date<= COALESCE(HR.enddate,dateadd(year,10,getdate())) 
   Left Join Common.TimeLogItem as TLI on TLI.Id = TL.TimeLogItemId
   Left Join WorkFlow.CaseGroup as CG1 on CG1.Id = TLI.SystemId
   Left Join Common.ServiceGroup as SG on SG.Id = CG1.ServiceGroupId
   Left Join Common.Company as Comp on Comp.Id = CG1.ServiceCompanyId

   where E.CompanyId = @CompanyId and TLD.Date >=@Fromdate and TLD.Date<=@ToDate  and E.FirstName=@EmployeeName
   --and CG1.CaseNumber=@CaseNuber
   and CG1.CaseNumber is not null

   ) as B1 on B1.EmployeeName = E2.FirstName
	where E2.CompanyId=@CompanyId 

UNION ALL

Select B.* from Common.Employee as E1
Inner Join
(

SELECT   Comp.Name as ServiceCompany,SG.Name as ServiceGroup,E.CreatedDate,ST.StartDate as Date,
 E.FirstName as EmployeeName,CG.CaseNumber,HR.EffectiveFrom,
 Case when HR.EndDate is null then COALESCE(HR.enddate,dateadd(year,10,getdate()))  
 else HR.EndDate end as 'EndDate',0 as 'ActualHours'
 
 ,(cast(cast(HR.ChargeOutRate AS float)as int)) as 'ChargeOutRate',
 (DATEPART(hh, ST.Hours) * 60 ) + (DATEPART(mi, ST.Hours) ) as 'PlannedHours'
 
 from Common.Employee as E
 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
 Inner join workflow.ScheduleTask ST on ST.EmployeeId=E.Id
 and ST.StartDate>=HR.effectivefrom and 
 ST.startdate<=COALESCE(HR.enddate,dateadd(year,10,getdate())) 
 Inner Join WorkFlow.CaseGroup as CG on  CG.Id=ST.caseId
 Inner Join Common.ServiceGroup as SG on SG.Id = CG.ServiceGroupId
 Inner Join Common.Company as Comp on Comp.Id = CG.ServiceCompanyId

 where E.CompanyId = @CompanyId and ST.StartDate >=@Fromdate and ST.StartDate<=@ToDate and E.FirstName=@EmployeeName
   -- and CG.CaseNumber=@CaseNuber
    and CG.CaseNumber is not null

	) as B on B.EmployeeName = E1.FirstName
	where E1.CompanyId=@CompanyId 
	
	) as PP

GROUP BY Date,ServiceCompany,ServiceGroup,CreatedDate,EmployeeName,CaseNumber,EffectiveFrom,EndDate,ChargeOutRate

) as P
GROUP BY EmployeeName,ChargeOutRate,CaseNumber,ServiceGroup,
 Left(datename(MONTH,Date),3)+'-'+Right(Year(Date),2) ,
Year(Date),MONTH(Date)

) B 

where MonthYear=@MONTHYear and Actual <>'0:00' and Planned <>'0:00'

Order By Year,Month,CaseNumber Asc


End
GO
