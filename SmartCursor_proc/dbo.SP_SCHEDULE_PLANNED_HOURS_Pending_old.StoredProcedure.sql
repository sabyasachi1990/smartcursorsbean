USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_SCHEDULE_PLANNED_HOURS_Pending_old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[SP_SCHEDULE_PLANNED_HOURS_Pending_old]  -----  -- Summary (OUTSIDE )

 @Fromdate date,
 @ToDate date,
 @DesignationId uniqueidentifier,
 @DepartmentId uniqueidentifier,
 @EmployeeId  uniqueidentifier, 
 @CompanyId int
 AS
 BEGIN
 

	-------------------------------- -- Summary (OUTSIDE ) 
		--Declare @Fromdate date='2018-01-01'
  --      Declare @ToDate date='2019-10-30'
		--Declare @EmployeeId  uniqueidentifier='66758197-B627-4B66-92BE-B2D5096A2D76'
		--Declare @DepartmentId uniqueidentifier='C1E1996C-1D9E-4607-821F-8DDEE5F26075'
		--Declare @DesignationId uniqueidentifier='73B9A29F-0AF4-4043-B82E-001F8A452A57'
  --      Declare @CompanyId int=1

	--------------ScheduleTask=cases=0

	select distinct  E.FirstName as EMPLOYEENAME,ST.StartDate as STARTDATE, 
		ST.Enddate AS ENDDATE,CAST (SUM(DATEDIFF(MINUTE,0,ST.Hours))/60.0  AS DECIMAL (20,2))As TOATLHOURS ,
		isnull(CAST (SUM(DATEDIFF(MINUTE,0,ST.IsOverRunHours))/60.0  AS DECIMAL (20,2)),0.00) As ISOVERRUNHOURS,E.Id AS EMPLOYEEID,
		e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,ST.CaseId AS SystemId, 
		  'CaseGroup'AS 'SystemType', 0 as  IsType 
		from WorkFlow.ScheduleTask ST
		 inner join WorkFlow.CaseGroup CG on ST.CaseId = CG.Id
		 Inner Join ClientCursor.Opportunity o on o.Id=cg.OpportunityId
	     inner join Common.Employee E on ST.EmployeeId = E.Id  
		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		 LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		where st.CompanyId = @CompanyId and  o.Stage='Pending' and
			CAST (ST.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') AND 
CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') AND
CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
and   ((@FromDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
else EffectiveTo end  as Date)) or (@ToDate between cast(EffectiveFrom as date) and 
cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and ST.StartDate >= @Fromdate And ST.EndDate <= @ToDate and st.Status=1 ---and CG.ServiceNatureType = 0  ---- Need to Check 
		Group by E.FirstName,ST.StartDate,ST.Enddate,E.Id,e.EmployeeId, ST.CaseId, ST.SystemType,MR.Small  
	
--	union all
--	------------------------- TimeLogItem.SystemType='LeaveApplication'=1

--       select DIstinct E.FirstName as EMPLOYEENAME,TLI.StartDate as STARTDATE,
--	    TLI.Enddate AS ENDDATE,SUM(TLI.Hours) As TOATLHOURS, 0.00 AS ISOVERRUNHOURS,
--		E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
--		 TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 1 as IsType 
--		from  Common.TimeLogItem TLI
--		inner join Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
--		inner join Common.Employee E on E.Id = TLD.EmployeeId 
--		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
--		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
--		 LEFT join hr.LeaveApplication as La on La.Id=TLI.SystemId
--		where TLI.CompanyId = @CompanyId and 
--			CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') AND 
--CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') AND
--CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
--and   ((@FromDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
-- then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
--else EffectiveTo end  as Date)) or (@ToDate between cast(EffectiveFrom as date) and 
--cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
--Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
--		and  TLI.StartDate >= @Fromdate And TLI.EndDate <= @ToDate
--		and TLI.IsSystem=1 and TLI.Status=1 and TLI.SystemType='LeaveApplication'  and La.leavestatus in ('Submitted','Recommended','Approved','For Cancellation')
--		Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

--		union all
--		------------------------ TimeLogItem.SystemType='Calender'=2


--        select DIstinct E.FirstName as EMPLOYEENAME,TLI.StartDate as STARTDATE,
--	    TLI.Enddate AS ENDDATE,SUM(TLI.Hours) As TOATLHOURS, 0.00 AS ISOVERRUNHOURS,
--		E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
--		 TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 2 as IsType 
--		from  Common.TimeLogItem TLI
--		inner join Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
--		inner join Common.Employee E on E.Id = TLD.EmployeeId 
--		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
--		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
--		where TLI.CompanyId = @CompanyId and 
--			CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') AND 
--CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') AND
--CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
--and   ((@FromDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
-- then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
--else EffectiveTo end  as Date)) or (@ToDate between cast(EffectiveFrom as date) and 
--cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
--Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
--		and  TLI.StartDate >= @Fromdate And TLI.EndDate <= @ToDate
--		and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=0 --and TLI.IsMain=1 -- Need to Check 
--		Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

--			union all

--		     select DIstinct E.FirstName as EMPLOYEENAME,TLI.StartDate as STARTDATE,
--	    TLI.Enddate AS ENDDATE,SUM(TLI.Hours) As TOATLHOURS, 0.00 AS ISOVERRUNHOURS,
--		E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
--		 TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 2 as IsType 
--		from  Common.TimeLogItem TLI
--		inner join Common.Employee E on E.CompanyId = TLI.CompanyId
--		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
--		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
--		where TLI.CompanyId = @CompanyId and 
--			CAST (E.Id  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') AND 
--CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') AND
--CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
--and   ((@FromDate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
-- then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
--else EffectiveTo end  as Date)) or (@ToDate between cast(EffectiveFrom as date) and 
--cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
--Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
--		and  TLI.StartDate >= @Fromdate And TLI.EndDate <= @ToDate
--		and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 --and TLI.IsMain=1 -- Need to Check 
--		Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 


		end

GO
