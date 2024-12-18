USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_TimeLogschedule_Remap_Table]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[WF_TimeLogschedule_Remap_Table]

AS
BEGIN
-------------Common.TimeLogschedule------5923---

select CaseId,DepartmentId,DesignationId,EmployeeId,Level,ChargeoutRate,StartDate,EndDate,ActualHours,Hours,ActualCost,
 UserCreated,CreateDate,ModifiedBy,ModifiedDate,Status
 from 
(
select AA.CaseId,AA.DepartmentId,AA.DesignationId,AA.EmployeeId,AA.Level,Cast(AA.ChargeoutRate AS Decimal(29,2))ChargeoutRate,AA.StartDate,AA.EndDate,AA.ActualHours,cast(cast ((Hours ) / 60 + ((Hours ) % 60) / 100.0  as decimal(28,2)) as  varchar(max)) Hours,
  Cast(isnull(Round((Cast((AA.ActualHours)/600000000 As int)*isnull(ChargeoutRate,0))/60,4),0.00) as Decimal(29,9)) ActualCost,
  Cast('System' as nvarchar(Max)) AS Remarks, Cast(NUll as bigint) RecOrder,
 Cast('System' as nvarchar(Max)) AS UserCreated,Cast(GetDate() AS Datetime2) AS CreateDate,
 Cast('System' as nvarchar(Max)) ModifiedBy,Cast(GetDate() AS Datetime2) AS ModifiedDate,
 Cast(NUll as smallint) Version,Cast(1 AS int)AS Status,Cast(NUll as float(24)) FeeAllocationPercentage,
 Cast(Null As decimal(10,2))AS FeeAllocation,Cast(NUll as float(24)) FeeRecoveryPercentage

 

  FROM 
 (
   Select  TI.SystemId AS CaseId,DepartmentId,DesignationId AS DesignationId,l.EmployeeId,TD.level AS Level,Cast(ChargeoutRate as Decimal(28,9)) AS ChargeoutRate,
   SUm((Cast(SUBSTRING(CAST(REVERSE(CAST(Isnull(TD.Duration,'00:00:00.0000000') as BINARY(6))) as binary(6)), 1, 5) As bigint)))
    AS ActualHours,MIN(TD.Date)StartDate,MAX(TD.date) ENddate,
	sum(((DATEPART(HOUR,Duration)*60)+((DATEPART(MINUTE,Duration))))) as  Hours

    From COmmon.TimeLog l
    Inner join COmmon.TimeLogItem TI on TI.id=l.TimeLogItemId
    Inner join Common.TimeLogDetail TD on TD.MasterId=l.Id
    --where SystemId='CCACE369-7DB5-4C9A-8D6C-FA13103674A6'
    where SystemId is not null
  Group by TI.SystemId,DepartmentId,DesignationId,l.EmployeeId,ChargeoutRate,TD.level
)as AA
)as PP

END
GO
