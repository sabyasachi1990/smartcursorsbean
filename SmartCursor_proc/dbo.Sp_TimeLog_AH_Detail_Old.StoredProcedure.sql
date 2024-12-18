USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_TimeLog_AH_Detail_Old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--EXEC [dbo].[Sp_TimeLog_AH_Detail] '2018-11-04 00:00:00.0000000','2018-11-10 00:00:00.0000000','CC51AC0E-6226-4965-A22F-40FFC6F43D43',1
create PROCEDURE [dbo].[Sp_TimeLog_AH_Detail_Old]  -----  -- Detail (INSIDE)

 @FROMDATE DATE, 
 @TODATE DATE,
 @EMPLOYEEID  UNIQUEIDENTIFIER,
 @COMPANYID INT


 AS
 BEGIN



	 --   Declare @Fromdate date='2018-01-01'
  --      Declare @ToDate date='2018-12-29'
		--Declare @EmployeeId  uniqueidentifier='CC51AC0E-6226-4965-A22F-40FFC6F43D43'
		----Declare @DepartmentId uniqueidentifier=NUll
		----'B72E0F75-0361-45CD-83AB-42C891E84552'
		----Declare @DesignationId uniqueidentifier=NUll
		----'DEB181C7-7362-4197-9A5A-B907DDC5CC0A'
  --      Declare @CompanyId int=1


   
DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),
                        CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),CASENAME NVARCHAR(1000), STARTDATE DATE,
						ENDDATE DATE,TOATLHOURS varchar(max),IsOverRunHours varchar(max),CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000),SCHEDULETYPEID UNIQUEIDENTIFIER NULL ,SUBTYPE NVARCHAR(1000), OppSTAGE NVARCHAR(50) ,SCHEDULETYPE NVARCHAR(100), IsType bit)


--Insert Into @OUTPUT
Begin
Declare @CsrSdate Date,@csrEdate date
Declare @Temp table (StartDate date,Enddate date)


;with cte as
(
  select @FROMDATE StartDate, DATEADD(wk, DATEDIFF(wk, 0, @FROMDATE), 5) EndDate
  union all
  select dateadd(ww, 1, StartDate),dateadd(ww, 1, EndDate)
  from cte where dateadd(ww, 1, StartDate)<=  @TODATE
)
Insert Into @Temp
select StartDate,EndDate
from cte

Declare Week_Csr Cursor for 
	    Select StartDate,Enddate from @Temp
        Open Week_Csr
Fetch Next From Week_Csr into @CsrSdate,@csrEdate
While @@FETCH_STATUS=0
Begin
Insert Into @OUTPUT

	--------------TImeLog=cases=0


	  SELECT  E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID,e.EmployeeId AS EMPLOYEEAUTONUMBER,
	          C.NAME AS CLIENTNAME ,CG.SYSTEMREFNO AS CASENUMBER, C.NAME AS CASENAME,T.StartDate as STARTDATE,T.Enddate AS ENDDATE,
	          RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
              RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2) As TOATLHOURS,'00.00' AS IsOverRunHours,CG.ID AS CASEID,MR.Small as PHOTOURL,
		      CG.id AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,o.stage as OppSTAGE,tli.SystemType AS  SCHEDULETYPE, 0 as  IsType 
              FROM Common.TimeLog T
		           INNER JOIN Common.TimeLogDetail TLD ON T.Id=TLD.MasterId
		           INNER JOIN Common.TimeLogItem TLI ON TLI.Id=T.TimeLogItemId
		           LEFT JOIN WorkFlow.CaseGroup CG on TLI.SystemId = CG.Id
		           LEFT JOIN  ClientCursor.Opportunity o on o.Id=cg.OpportunityId --- new changes 27-01-2020
		           LEFT JOIN  WORKFLOW.CLIENT C ON C.ID=CG.CLIENTID
		           INNER JOIN Common.Employee E on T.EmployeeId = E.Id  
		           INNER JOIN [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		           LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		      WHERE T.CompanyId =@CompanyId AND T.EmployeeId = @EmployeeId AND SystemType='CaseGroup' AND t.Status=1 AND tld.Duration <> '00:00:00.0000000'
	                AND   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                           else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date)
					and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		            and T.StartDate >= @CsrSdate And T.EndDate <= @csrEdate --and CG.ServiceNatureType = 0
		    GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.SystemId,TLI.SubType, TLI.SystemType,MR.Small,C.NAME,CG.Id,c.id,CG.SYSTEMREFNO,o.stage

	--SELECT DISTINCT EMPLOYEENAME,EMPLOYEEID,EMPLOYEEAUTONUMBER,CLIENTNAME,CASENUMBER,CASENAME,@CsrSdate,@csrEdate ,
	--(CAST((TOATLHOURS)/60 AS varchar(6)) + '.' + CAST((TOATLHOURS)%60 As varchar(20))) As TOTALHOURS,0 AS IsOverRunHours,
	--CASEID,PHOTOURL,SCHEDULETYPEID,SUBTYPE AS SUBTYPE,OppSTAGE,SCHEDULETYPE, 0 as IsType 
	--FROM
	--(
	--SELECT DISTINCT E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID,e.EmployeeId AS EMPLOYEEAUTONUMBER,TLI.SubType AS SUBTYPE,
	--    C.NAME AS CLIENTNAME ,CG.SYSTEMREFNO AS CASENUMBER, C.NAME AS CASENAME,T.StartDate as STARTDATE,T.Enddate AS ENDDATE,
	--    SUM(DATEPART(hh,duration)*60+DATEPART(MI,duration)) As TOATLHOURS,CG.ID AS CASEID,MR.Small as PHOTOURL,
	--	CG.id AS SCHEDULETYPEID,o.stage as OppSTAGE,tli.SystemType AS  SCHEDULETYPE--, 0 as  IsType 
 --       FROM Common.TimeLog T
	--	INNER JOIN Common.TimeLogDetail TLD ON T.Id=TLD.MasterId
	--	INNER JOIN Common.TimeLogItem TLI ON TLI.Id=T.TimeLogItemId
	--	LEFT JOIN WorkFlow.CaseGroup CG on TLI.SystemId = CG.Id
	--	LEFT JOIN  ClientCursor.Opportunity o on o.CaseId=cg.Id
	--	LEFT JOIN  WORKFLOW.CLIENT C ON C.ID=CG.CLIENTID
	--	INNER JOIN Common.Employee E on T.EmployeeId = E.Id  
	--	INNER JOIN [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
	--	LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
	--	WHERE T.CompanyId =@CompanyId AND T.EmployeeId = @EmployeeId AND t.Status=1 AND tld.Duration <> '00:00:00.0000000'
	-- AND   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
 --       then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
 --       else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
 --      cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
 --      Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
	--	and T.StartDate >= @CsrSdate And T.EndDate <= @csrEdate --and CG.ServiceNatureType = 0
	--	GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.SystemId,TLI.SubType, TLI.SystemType,MR.Small,C.NAME,CG.Id,c.id,CG.SYSTEMREFNO,o.stage  
	--	)AS AA
	
	UNION ALL
	------------------------- TimeLogItem.SystemType='LeaveApplication'=1

      SELECT  E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER,TLI.SubType AS CASENAME ,TLI.SubType AS CASENUMBER, NULL AS  CLIENTNAME,@CsrSdate,@csrEdate,
              CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,
		      MR.Small as PHOTOURL,TLI.SystemId AS SCHEDULETYPEID, TLI.SubType AS SUBTYPE,NULL as OppSTAGE,TLI.SystemType AS SCHEDULETYPE, 1 as IsType 
		      from  Common.TimeLogItem TLI
		            INNER JOIN Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		            INNER JOIN Common.Employee E on E.Id = TLD.EmployeeId 
		            INNER JOIN [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		            LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		            LEFT JOIN hr.LeaveApplication as La on La.Id=TLI.SystemId
		      WHERE TLI.CompanyId = @CompanyId AND TLD.EmployeeId  = @EmployeeId AND  TLI.Status=1
	                and   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
		                  else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
					and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		            and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		            and TLI.IsSystem=1 and TLI.SystemType='LeaveApplication'  and La.leavestatus in ('Approved','For Cancellation')
		      Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small ,TLI.SubType

		UNION ALL
		------------------------ TimeLogItem.SystemType='Calender'=2

	/*	
        select  E.FirstName as EMPLOYEENAME,	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,
		  TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,
		@CsrSdate,@csrEdate ,SUM(TLI.Hours) As TOATLHOURS, 0.00 AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,
	 MR.Small as PHOTOURL,
		 TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,2 as IsType 
		from  Common.TimeLogItem TLI
		inner join Common.Employee E on E.CompanyId = TLI.CompanyId
		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		where TLI.CompanyId = @CompanyId and 
			E.Id  = @EmployeeId AND 
  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		 and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and  TLI.IsMain=0
		Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small,TLI.SubType 


		
--        select  E.FirstName as EMPLOYEENAME,TLD.EmployeeId AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,
--		  TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,
--		@CsrSdate,@csrEdate ,SUM(TLI.Hours) As TOATLHOURS, 0.00 AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,
--	 MR.Small as PHOTOURL,
--		 TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,2 as IsType 
--		from  Common.TimeLogItem TLI
--		inner join Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
--		inner join Common.Employee E on E.Id = TLD.EmployeeId 
--		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId =TLD.EmployeeId
--		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
--		where TLI.CompanyId = @CompanyId and 
--			TLD.EmployeeId  = @EmployeeId AND  TLI.IsMain=0 AND
--  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
-- then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
--else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
--cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
--Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
--		and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
--		 and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=0 and  TLI.IsMain=0
--		Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small,TLI.SubType 


  --  SELECT  E.FirstName as EMPLOYEENAME,	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER,
		--  TLI.SubType AS  CASENAME,TLI.SubType AS CASENUMBER, null AS CLIENTNAME ,@CsrSdate,@csrEdate,--TLI.StartDate as STARTDATE,TLI.Enddate AS ENDDATE,
	 --     SUM(TLI.Hours) As TOATLHOURS, 0 AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,MR.Small as PHOTOURL,
		-- TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE,TLI.SystemType AS SCHEDULETYPE, 2 as IsType
	 --   from  Common.TimeLogItem TLI
		--INNER JOIN  Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		--INNER JOIN Common.Employee E on E.Id = TLD.EmployeeId 
		--INNER JOIN  [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		--LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		----INNER join hr.LeaveApplication as La on La.Id=TLI.SystemId
		--where TLI.CompanyId = @CompanyId  AND 
		--TLD.EmployeeId  = @EmployeeId AND

		--   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
		--then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
		--else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
		--cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
		--Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		--and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		--and TLI.IsSystem=1 and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=0 AND TLI.IsMain=0
		--Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small,TLI.SubType 


			union all
		------------------------ TimeLogItem.SystemType='Calender'=2

		 SELECT  E.FirstName as EMPLOYEENAME,	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER,
		  TLI.Type AS  CASENAME,TLI.Type AS CASENUMBER, null AS CLIENTNAME,--tld.Date as Startdate,TLD.Date Enddate,
		  @CsrSdate,@csrEdate,
	       (CAST((SUM(DATEPART(hh,tld.Duration)*60+DATEPART(MI,tld.Duration)))/60 AS varchar(6)) + '.' + CAST((SUM(DATEPART(hh,tld.Duration)*60+DATEPART(MI,tld.Duration)))%60 As varchar(20))) As TOATLHOURS, 0 AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,MR.Small as PHOTOURL,
		 TLI.Id AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE,TLI.SystemType AS SCHEDULETYPE,4 as IsType
	 	from  Common.TimeLogItem TLI
		Inner Join Common.TimeLog L on l.TimeLogItemId=TLI.id
		Inner Join Common.TimeLogDetail TLD ON TLD.MasterId=L.Id
		inner join Common.Employee E on E.Id = L.EmployeeId
		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = L.EmployeeId
		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		where TLI.CompanyId = @CompanyId  AND 
	    L.EmployeeId  = @EmployeeId AND
		   ((@CsrSdate between cast(TLd.Date as date) and cast(case when EffectiveTo is null
		then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
		else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
		cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
		Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLD.Date >= @CsrSdate And TLd.Date <= @csrEdate
		--and tld.Date between @CsrSdate and @csrEdate

	 and TLI.SystemType='Time Log Item' and TLI.Status=1 and TLI.ApplyToAll is null and tld.Duration <> '00:00:00.0000000'
		Group by E.FirstName,TLd.Date,E.Id,e.EmployeeId, TLI.Id, TLI.SystemType, TLI.Type,MR.Small,TLI.SubType 
-------------------------
--   select  E.FirstName as EMPLOYEENAME,	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,
--		  TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,
--		@CsrSdate,@csrEdate ,SUM(TLI.Hours) As TOATLHOURS, 0.00 AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,
--	 MR.Small as PHOTOURL,
--		 TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,2 as IsType 
--		from  Common.TimeLogItem TLI
--		inner join Common.Employee E on E.CompanyId = TLI.CompanyId
--		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
--		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
--		where TLI.CompanyId = @CompanyId and 
--			E.Id  = @EmployeeId AND 
--  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
-- then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
--else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
--cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
--Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
--		and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
--		 and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and  TLI.IsMain=0
--		Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small,TLI.SubType 

		-------------------------------------
		  
  --select EMPLOYEENAME,EMPLOYEEID,EMPLOYEENUMBER,CLIENTNAME,CASENUMBER,null AS CASENAME,@CsrSdate,@csrEdate,
  --(CAST((TOATLHOURS)/60 AS varchar(6)) + '.' + CAST((TOATLHOURS)%60 As varchar(20))) As TOTALHOURS,
  --0.00 AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,PHOTOURL,SCHEDULETYPEID,
  --SUBTYPE,NULL as OppSTAGE,SCHEDULETYPE,2 as IsType 
  
  -- from 
  --(
  --select DIstinct E.FirstName as EMPLOYEENAME,	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,
		--  TLI.Type AS CLIENTNAME ,TLI.Type AS CASENUMBER,TLI.StartDate,TLI.Enddate,--@CsrSdate,@csrEdate,
		--SUM(DATEPART(hh,tld.Duration)*60+DATEPART(MI,tld.Duration)) As  TOATLHOURS ,
	 --MR.Small as PHOTOURL,
		-- TLI.Id AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,TLI.SystemType AS SCHEDULETYPE
		--from  Common.TimeLogItem TLI
		--Inner Join Common.TimeLog L on l.TimeLogItemId=TLI.id
		--Inner Join Common.TimeLogDetail TLD ON TLD.MasterId=L.Id
		--inner join Common.Employee E on E.CompanyId = TLI.CompanyId
		-- Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		--  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		----  where L.CompanyId = @CompanyId and 
		----L.employeeid  = @EmployeeId AND
		--where L.CompanyId = @CompanyId and 
		--	E.Id  = @EmployeeId AND
		--  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
		-- then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
		--else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
		--cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
		--Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		--		and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		-- and TLI.SystemType='Time Log Item'  and TLI.Status=1 and TLI.ApplyToAll is null and TLI.IsSystem=0----and  TLI.IsMain=1
		--Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId,TLI.SystemType,MR.Small,TLI.SubType,TLI.Type ,TLI.Id
		--)as AA



--        select DIstinct E.FirstName as EMPLOYEENAME,	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,
--		  TLI.Type AS CLIENTNAME ,TLI.Type AS CASENUMBER, null AS CASENAME,
--		@CsrSdate,@csrEdate ,SUM(TLI.Hours) As TOATLHOURS, 0.00 AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,
--	 MR.Small as PHOTOURL,
--		 TLI.Id AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE,TLI.SystemType AS SCHEDULETYPE,2 as IsType 
--		from  Common.TimeLogItem TLI
--		inner join Common.Employee E on E.CompanyId = TLI.CompanyId
--		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
--		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
--		where TLI.CompanyId = @CompanyId and 
--			E.Id  = @EmployeeId AND 
--  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
-- then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
--else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
--cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
--Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
--		and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
--		 and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll is null ----and  TLI.IsMain=1
--		Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.Id, TLI.SystemType,MR.Small,TLI.SubType,Type 

*/





        select  E.FirstName as EMPLOYEENAME,	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,
		        TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,
		        @CsrSdate,@csrEdate , CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,
	            MR.Small as PHOTOURL,TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,2 as IsType 
		         from  Common.TimeLogItem TLI
		              inner join Common.TimeLogItemDetail TLD on TLD.TimelogitemId=TLI.Id
		              inner join Common.Employee E on E.Id = TLD.EmployeeId 
		              Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		              LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		          where TLI.CompanyId = @CompanyId and TLD.EmployeeId  = @EmployeeId 
				       AND  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                       else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
				       and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		               and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		               and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=0 and  TLI.IsMain=0
		          Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

			union all
		------------------------ TimeLogItem.SystemType='Calender'=2


        select  E.FirstName as EMPLOYEENAME,	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,
		  TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,
		@CsrSdate,@csrEdate , CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS,'00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,
	 MR.Small as PHOTOURL,
		 TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,2 as IsType 
		from  Common.TimeLogItem TLI
		inner join Common.Employee E on E.CompanyId = TLI.CompanyId
		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id
		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		where TLI.CompanyId = @CompanyId and 
			E.Id  = @EmployeeId AND 
  ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null
 then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		 and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and  TLI.IsMain=0
		Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

		Union All

		
		------------------------ TimeLogItem.SystemType='Calender'=2

		 SELECT  E.FirstName as EMPLOYEENAME,	E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER,
		  TLI.Type AS  CASENAME,TLI.Type AS CASENUMBER, null AS CLIENTNAME,--tld.Date as Startdate,TLD.Date Enddate,
		  @CsrSdate,@csrEdate,
	       RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
       RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2) As TOATLHOURS, '00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,MR.Small as PHOTOURL,
		 TLI.Id AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE,TLI.SystemType AS SCHEDULETYPE,4 as IsType
	 	from  Common.TimeLogItem TLI
		Inner Join Common.TimeLog L on l.TimeLogItemId=TLI.id
		Inner Join Common.TimeLogDetail TLD ON TLD.MasterId=L.Id
		inner join Common.Employee E on E.Id = L.EmployeeId
		 Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = L.EmployeeId
		  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId
		where TLI.CompanyId = @CompanyId  AND 
	    E.Id  = @EmployeeId AND
		   ((@CsrSdate between cast(TLd.Date as date) and cast(case when EffectiveTo is null
		then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
		else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and 
		cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),
		Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		and  TLD.Date >= @CsrSdate And TLd.Date <= @csrEdate
		--and tld.Date between @CsrSdate and @csrEdate

	 and TLI.SystemType='Time Log Item' and TLI.Status=1 and TLI.ApplyToAll is null and tld.Duration <> '00:00:00.0000000'
		Group by E.FirstName,TLd.Date,E.Id,e.EmployeeId, TLI.Id, TLI.SystemType, TLI.Type,MR.Small,TLI.SubType 


		Fetch Next From Week_Csr into @CsrSdate,@csrEdate
End

close Week_Csr
Deallocate Week_Csr
  

  Select EMPLOYEENAME ,EMPLOYEEID ,EMPLOYEENUMBER , CLIENTNAME ,CASENUMBER ,CASENAME , STARTDATE ,	ENDDATE ,TOATLHOURS ,IsOverRunHours ,CASEID ,PHOTOURL ,SCHEDULETYPEID,SUBTYPE , OppSTAGE , SCHEDULETYPE , IsType 
  From @OUTPUT
  End

 END
GO
