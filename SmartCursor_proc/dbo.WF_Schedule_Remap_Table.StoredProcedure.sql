USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[WF_Schedule_Remap_Table]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[WF_Schedule_Remap_Table]
AS
BEGIN 

-------WorkFlow.ScheduleNew-------5965--

select Id [SourceScheduleId],CompanyId 'TenantId',CaseId,StartDate,EndDate,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Status 'RecordStatus' from WorkFlow.ScheduleNew

---------[WorkFlow].[ScheduleTaskNEw]-------9897---------

select [SourceScheduleTaskId],[ServiceEntityId],EmployeeId,CaseId, [Title],StartDate,[Hours],[IsOverRunHours],[PBIName],
  ScheduleDetailId,[RecordStatus]
  from 
  (
 select Id [SourceScheduleTaskId],CompanyId [ServiceEntityId],EmployeeId,CaseId,Task AS [Title],StartDate,
  RIGHT('0' + CAST (FLOOR(COALESCE (PlannedHours, 0) / 60) AS VARCHAR (8)), 2) + ':' + 
RIGHT('0' + CAST (FLOOR(COALESCE (PlannedHours, 0) % 60) AS VARCHAR (2)), 2) + ':' + 
RIGHT('0' + CAST (FLOOR((PlannedHours* 60) % 60) AS VARCHAR (2)), 2) as [Hours],

 RIGHT('0' + CAST (FLOOR(COALESCE (OverRunHours, 0) / 60) AS VARCHAR (8)), 2) + ':' + 
RIGHT('0' + CAST (FLOOR(COALESCE (OverRunHours, 0) % 60) AS VARCHAR (2)), 2) + ':' + 
RIGHT('0' + CAST (FLOOR((OverRunHours* 60) % 60) AS VARCHAR (2)), 2)  [IsOverRunHours],
 Cast(Remarks AS nvarchar(max))  AS [PBIName],ScheduleDetailId,Status as [RecordStatus]
 from  [WorkFlow].[ScheduleTaskNEw]
 )as AA

-------------Workflow.ScheduleDetailNew------20318----

Select Case when ScheduleDetailId is null then SCD.Id else ScheduleDetailId end ScheduleDetailId,SCD.MasterId,
 Case when pp.EmployeeId is null then SCD.EmployeeId else pp.EmployeeId end EmployeeId,pp.Level,
 Case when pp.StartDate is null then SCD.StartDate else pp.StartDate end as StartDate,
 Case when pp.EndDate is null then SCD.EndDate else pp.EndDate end as EndDate,
 
 isnull((convert(float,PlannedHours)*600000000),0) PlannedHours,
  
 Case when  isnull(PP.ChargeOutRate,0) =0 and isnull(PlannedCost,0)=0  then isnull(SCD.ChargeOutRate,0) else isnull(PP.ChargeOutRate,0) end as ChargeOutRate,
 --isnull(PP.ChargeOutRate,0)ChargeOutRate,
 isnull(Cast([FeeAllocation(%)] AS Decimal(28,7)),0) AS FeeAllocationPercentage,
isnull(Cast([Fee Allocation($)] AS decimal(28,2)),0) FeeAllocation,isnull(Cast([Fee Recovery(%)] AS decimal(28,2)),0) 'Fee RecoveryPercentage', SCD.IsPrimaryIncharge IsPrimaryIncharge,isnull(PlannedCost,0)PlannedCost,
   Cast('System' as nvarchar(Max)) as UserCreated,SCD.CreatedDate as CreatedDate,
  Cast('System' as nvarchar(Max)) as ModifiedBy,
  Cast(GetDate() AS Datetime2) as ModifiedDate,Cast (SCD.Status AS int) RecordStatus,
  Case when pp.DepartmentId is null then SCD.DepartmentId else pp.DepartmentId end as DepartmentId,
  Case when pp.DesignationId is null then SCD.DesignationId else pp.DesignationId end as DesignationId,
   0 as IsSystem,isnull(PlannedCost,0) WithoutOverrunCost
  
   from 
	Workflow.ScheduleDetailNew SCD
		 Left Join
   (
 
 select CaseId,CompanyId,ScheduleDetailId,DepartmentId,DesignationId,EmployeeId,StartDate,EndDate,ChargeOutRate,
   PlannedHours PlannedHours,Level,
	-- CAST(CAST((PlannedHours) AS int) / 60 AS varchar) + ':'  +  right('0' + CAST(CAST((PlannedHours) AS int) % 60 AS varchar(2)),2) + ':' + '00'  AS PlannedHours1,
	 OverRunHours,TotalHours,PlannedCost,OverRunCost,PC,OC,CaseFee,[FeeAllocation(%)],
	Isnull(([FeeAllocation(%)]*CaseFee)/100,0) as 'Fee Allocation($)',
       Isnull(((([FeeAllocation(%)]*CaseFee)/100)/(NULLIF([PlannedCost],0)))*100,0) AS 'Fee Recovery(%)'

  from 
 (
 select A.CaseId,CompanyId,ScheduleDetailId,DepartmentId,DesignationId,EmployeeId,StartDate,EndDate,ChargeOutRate,Level,
 PlannedHours,isnull(OverRunHours,0)OverRunHours,TotalHours,PlannedCost,OverRunCost,P.PC,P.OC,P.CaseFee,
 (isnull((Cast([OverRunCost] AS decimal(28,9)))/(nullif((PC-OC),0)),0))*100 as 'FeeAllocation(%)'
  from 
 (
 select CaseId,CompanyId,ScheduleDetailId,DepartmentId,DesignationId,EmployeeId,min(StartDate) as StartDate ,max(EndDate) EndDate,Level,
      isnull((sum(isnull(ChargeOutRateNew,0))/nullif((sum(TotalHours)/60.0),0)),0) as ChargeOutRate,sum(PlannedHours )  as PlannedHours,sum(OverRunHours )OverRunHours,
      sum(TotalHours )TotalHours,sum(Isnull(ChargeOutRateNew,0)) as PlannedCost,sum(Isnull(OverRunCost,0)) as OverRunCost from 
     (
      select DISTINCT ScheduleDetailId,st.CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,Level,PlannedHours,OverRunHours,ChargeOutRate,
      (PlannedHours+OverRunHours) as TotalHours,(TotalHours*ChargeOutRate) as ChargeOutRateNew,(PlannedHoursnew*ChargeOutRate) as OverRunCost,st.CompanyId,StartDate,EndDate from
      (
        select st.ScheduleDetailId,st.CompanyId,CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,ST.Level,sum(isnull(PlannedHours,0)) as PlannedHours,sum(isnull(PlannedHours,0))/60.0 as PlannedHoursnew,sum(isnull(OverRunHours,0))  as OverRunHours,
        sum(isnull(OverRunHours,0))/60.0 as OverRunHoursnew,
        (sum(PlannedHours) +sum(isnull(OverRunHours,0)))/60.0 as TotalHours,isnull(st.ChargeoutRate,0) as ChargeoutRate,min(StartDate) as StartDate ,max(EndDate) EndDate   from 
        WorkFlow.ScheduleTaskNew st
        group by  st.ScheduleDetailId,st.CompanyId,CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,st.ChargeoutRate,ST.Level
      )st
    )k group  by CaseId,EmployeeId,DepartmentId,DesignationId,ScheduleDetailId,CompanyId,Level

)as A
LEFT JOIN
(

	select Cast(Sum(ChargeOutRateNew) as decimal(28,9)) 'PC',Cast(Sum(OverRunCost)as Decimal(28,9)) 'OC',CaseId,isnull(d.CaseFee,0) as CaseFee
   from 
    (
      select DISTINCT st.CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,ST.Level,PlannedHours,OverRunHours,ChargeOutRate,(PlannedHours+OverRunHours) as TotalHours,
      (TotalHours*ChargeOutRate) as ChargeOutRateNew,(OverRunHoursnew*ChargeOutRate) as OverRunCost,st.CompanyId from
      (
       select st.CompanyId,CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,ST.Level,sum(isnull(PlannedHours,0)) as PlannedHours,sum(isnull(OverRunHours,0))  as OverRunHours,
       sum(isnull(OverRunHours,0))/60.0 as OverRunHoursnew,
       (sum(PlannedHours) +sum(isnull(OverRunHours,0)))/60.0 as TotalHours,isnull(st.ChargeoutRate,0) as ChargeoutRate from 
       WorkFlow.ScheduleTaskNew st
      group by  st.CompanyId,CaseId,st.EmployeeId,st.DepartmentId,st.DesignationId,st.ChargeoutRate,ST.Level
      )st
    )k
    INNER join 
    (
      select Distinct Id,FEE AS CaseFee,CompanyId AS CaseCompanyId FROM WorkFlow.CaseGroup --where id='DB7195F5-521B-43D4-A800-9CA081468638'
    ) d on  d.Id=k.CaseId and d.CaseCompanyId=k.CompanyId 
      group  by k.CaseId,d.CaseFee
	  )as P on p.CaseId=A.CaseId
	  )as F
	 
	  )as pp on ScheduleDetailId=SCD.Id

	  END

--Select Case when F.ScheduleDetailId is null then SCD.Id else F.ScheduleDetailId end as SourceScheduleDetailId,SCD.MasterId,
--       Case when F.EmployeeId is null then SCD.EmployeeId else F.EmployeeId end as EmployeeId,SCD.Level,
--	   Case when F.StartDate is null then SCD.StartDate else F.StartDate end as StartDate,
--       Case when F.EndDate is null then SCD.EndDate else F.EndDate end as EndDate,
--       F.PlannedHours,F.ChargeoutRate,F.[FeeAllocation(%)] FeeAllocationPercentage,    
--       F.[Fee Allocation($)] FeeAllocation,F.[Fee Recovery(%)] 'Fee RecoveryPercentage',
--	   SCD.IsPrimaryIncharge IsPrimaryIncharge,F.[Planned Cost] PlannedCost,
--	    Cast('System' as nvarchar(Max)) as UserCreated,Cast(GetDate() AS Datetime2) as CreatedDate,
--		 Cast('System' as nvarchar(Max)) as ModifiedBy,
--		Cast(GetDate() AS Datetime2) as ModifiedDate,Cast (SCD.Status AS int) RecordStatus,
--	   Case when F.DepartmentId is null then SCD.DepartmentId else F.DepartmentId end as DepartmentId,
--       Case when F.DesignationId is null then SCD.DesignationId else F.DesignationId end as DesignationId,
--	   0 as IsSystem,F.[Planned Cost] WithoutOverrunCost

--	   --Case when F.CompanyId is null then SCD.CompanyId else F.CompanyId end as CompanyId,
--    --   F.IsOverRun,F.OverrunHours,F.CaseId,F.[Overrun Cost]

--from Workflow.ScheduleDetailNew SCD

--Left Join
--(

--Select K.SCDId 'ScheduleDetailId',K.CaseId,K.CompanyId,K.EmployeeId,K.DepartmentId,K.DesignationId,K.StartDate,K.EndDate,
--       K.IsOverRun,K.PH 'PlannedHours',K.ORH 'OverrunHours',K.ChargeoutRate,K.[PlannedCost] 'Planned Cost',K.[OverRunCost] 'Overrun Cost',
--      -- K.Total 'Total Hours',K.[Total Planned Cost],K.[Total OverRun Cost],
--       K.[FeeAllocation(%)],
--       Isnull(([FeeAllocation(%)]*CG.Fee)/100,0) as 'Fee Allocation($)',
--       Isnull(((([FeeAllocation(%)]*CG.Fee)/100)/(NULLIF([PlannedCost],0)))*100,0) AS 'Fee Recovery(%)'
--from
--(
--Select VN.*,isnull(([PlannedCost]/nullif((PC-OC),0)),0)*100 as 'FeeAllocation(%)' from
--(
--Select S2.CaseId,S2.CompanyId,S2.ScheduleDetailId SCDId,S2.DepartmentId,S2.DesignationId,S2.EmployeeId,S2.IsOverRun,
--       S2.StartDate,S2.EndDate,S2.ChargeoutRate,
--       Isnull(S2.[PlnnedHours],0) 'PH',Isnull(S2.[OverrunHours],0) 'ORH',
--       (Isnull(S2.[PlnnedHours],0)+Isnull(S2.[OverrunHours],0)) 'Total',
--       Cast(S2.[PlannedCost] AS Decimal(28,9))[PlannedCost],S2.[OverRunCost],S2.ScheduleDetailId,
--       ((SK.PC + SK.OC) * S2.ChargeoutRate) 'Total Planned Cost',((SK.OC) * S2.ChargeoutRate) 'Total OverRun Cost',SK.PC,SK.OC

--from
--(
--Select S1.ScheduleDetailId,S1.CompanyId,S1.CaseId,S1.DepartmentId,S1.DesignationId,S1.EmployeeId,
--       Min(S1.StartDate) StartDate,Max(S1.EndDate) EndDate,S1.IsOverRun,
--       SUM([PlannedHours]) 'PlnnedHours',SUM([OverRunHours]) 'OverrunHours',S1.ChargeoutRate,
--       (SUM([PlannedHours]) * (ChargeoutRate)) as 'PlannedCost',
--       (SUM([OverRunHours]) * (ChargeoutRate)) as 'OverRunCost',
--        (SUM([OverRunHours]) * (ChargeoutRate)) as 'OverCost'
--from
--(
--Select  SCTN.ScheduleDetailId,SCTN.CompanyId,SCTN.CaseId,SCTN.DepartmentId,SCTN.DesignationId,SCTN.EmployeeId,
--       SCTN.StartDate,SCTN.EndDate,SCTN.IsOverRun,
--       Cast((isnull(SCTN.PlannedHours,0))/60.0 as Decimal(28,2))  as 'PlannedHours',
--       Cast((isnull(SCTN.OverRunHours,0))/60.0 as Decimal(28,2))  as 'OverRunHours',SCTN.ChargeoutRate
--from WorkFlow.ScheduleTaskNew SCTN
--) as S1

--Group By S1.ScheduleDetailId,S1.CompanyId,S1.CaseId,S1.DepartmentId,S1.DesignationId,
--         S1.EmployeeId,S1.IsOverRun,S1.ChargeoutRate
--) as S2
         
--Left Join  
--(
--Select Cast(Sum(GS.[Planned Cost]) as decimal(28,9)) 'PC',Cast(Sum(GS.[OverRun Cost])as Decimal(28,9)) 'OC',GS.CaseId from 
--(
--Select HB.CaseId,HB.EmployeeId,Isnull(HB.[Plnned Hours],0) 'PH',Isnull(HB.[Overrun Hours],0) 'ORH',
--       (Isnull(HB.[Plnned Hours],0)+Isnull(HB.[Overrun Hours],0)) 'Total',
--       HB.ChargeoutRate,HB.[Planned Cost],HB.[OverRun Cost],HB.ScheduleDetailId from
--(
--Select (SUM(BH.[Planned Hours]) * (BH.ChargeoutRate)) as 'Planned Cost',
--       (SUM(BH.[OverRun Hours]) * (BH.ChargeoutRate)) as 'OverRun Cost',
--       SUM(BH.[Planned Hours]) 'Plnned Hours',SUM(BH.[OverRun Hours]) 'Overrun Hours',
--       BH.ScheduleDetailId,BH.CaseId,BH.ChargeoutRate,BH.EmployeeId from
--(
--Select SCTN.CompanyId,SCTN.CaseId,SCTN.ScheduleDetailId,
--       SCTN.EmployeeId,SCTN.PlannedHours,SCTN.OverRunHours,
--       Cast((isnull(PlannedHours,0))/60.0 as Decimal(28,2))  as 'Planned Hours',
--       Cast((isnull(OverRunHours,0))/60.0 as Decimal(28,2))  as 'OverRun Hours',
--       SCTN.ChargeoutRate from WOrkflow.ScheduleTaskNew SCTN

 

--) as BH
--Group By BH.ScheduleDetailId,BH.CaseId,BH.ChargeoutRate,BH.EmployeeId
--) as HB
--) as GS
--Group BY GS.CaseId
--) as SK on SK.CaseId=S2.CaseId
--) as VN
--) as K
--Inner Join WorkFlow.CaseGroup CG on CG.Id=K.CaseId
--) as F on F.ScheduleDetailId=SCD.Id


GO
