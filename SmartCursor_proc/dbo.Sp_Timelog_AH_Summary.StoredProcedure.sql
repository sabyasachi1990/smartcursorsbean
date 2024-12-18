USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Timelog_AH_Summary]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	
	CREATE PROCEDURE [dbo].[Sp_Timelog_AH_Summary]  -----  -- Summary (OUTSIDE )

 @Fromdate date,
 @ToDate date,
 @DesignationId uniqueidentifier,
 @DepartmentId uniqueidentifier,
 @EmployeeId  uniqueidentifier, 
 @CompanyId int
 AS
 BEGIN
	
	
	--   Declare @Fromdate date='12/30/2018 12:00:00 AM'
  --      Declare @ToDate date='01/05/2019 12:00:00 AM'
		--Declare @EmployeeId  uniqueidentifier='630d8a35-0bcb-44b9-9309-9415dd7eb8c5'
		--Declare @DepartmentId uniqueidentifier=NUll
		----'B72E0F75-0361-45CD-83AB-42C891E84552'
		--Declare @DesignationId uniqueidentifier=NUll
		----'DEB181C7-7362-4197-9A5A-B907DDC5CC0A'
  --      Declare @CompanyId int=1

	 --   Declare @Fromdate date='2018-01-01'
  --      Declare @ToDate date='2018-09-29'
		--Declare @EmployeeId  uniqueidentifier='9A6068A7-1AEC-24A4-819A-3F3C3E29805B'
		--Declare @DepartmentId uniqueidentifier=NUll
		----'B72E0F75-0361-45CD-83AB-42C891E84552'
		--Declare @DesignationId uniqueidentifier=NUll
		----'DEB181C7-7362-4197-9A5A-B907DDC5CC0A'
  --      Declare @CompanyId int=1

	--------------TImeLog=cases=0


DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),STARTDATE DATE,ENDDATE DATE,
TOTALHOURS varchar(max),IsOverRunHours varchar(max),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(100),PHOTOURL NVARCHAR(1000),SystemId UNIQUEIDENTIFIER,SystemType NVARCHAR(1000), IsType bit)


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


   IF (@EmployeeId IS NULL AND @DepartmentId IS NULL  AND @DesignationId IS NULL )
   BEGIN 
   Insert Into @OUTPUT

   --============================================CaseGroup STEP 1 ====================================
	SELECT  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate,--SUM(DATEDIFF(MINUTE,0,TLD.Duration))/60.0 As TOATLHOURS,0 AS IsOverRunHours,
		    RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
            RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2)As TOATLHOURS,'00.00' AS IsOverRunHours,E.Id AS EMPLOYEEID,
		    e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,TLI.Id AS SystemId,TLI.SystemType,0 as IsType 
		    FROM Common.TimeLog T (NOLOCK)
		          INNER JOIN Common.TimeLogDetail TLD (NOLOCK) ON T.Id=TLD.MasterId
		          INNER JOIN Common.TimeLogItem TLI (NOLOCK) ON TLI.Id=T.TimeLogItemId
		          LEFT JOIN WorkFlow.CaseGroup CG (NOLOCK) on TLI.SystemId = CG.Id
		          INNER JOIN Common.Employee E (NOLOCK) on T.EmployeeId = E.Id  
		          INNER JOIN [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
		          LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		    WHERE T.CompanyId = @CompanyId and t.Status=1 AND SystemType='CaseGroup' AND t.Status=1 AND tld.Duration <> '00:00:00.0000000' 
			      --AND CAST (T.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
			      --AND  CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%')
			      --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
                  AND   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                        else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
			      AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100), Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		          AND T.StartDate >= @CsrSdate And T.EndDate <= @csrEdate --and CG.ServiceNatureType = 0
		   GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.Id, TLI.SystemType,MR.Small  

	
	UNION ALL
	-------====================================LeaveApplication STEP 2 ===========================================

   SELECT  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate, CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS IsOverRunHours,
		   E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		   TLI.SystemId AS SystemId, TLI.SystemType AS 'SystemType', 1 as IsType 
		   from  Common.TimeLogItem TLI (NOLOCK)
		         INNER JOIN Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id
		         INNER JOIN Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId 
		         INNER JOIN [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
		         LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		         LEFT JOIN hr.LeaveApplication as La (NOLOCK) on La.Id=TLI.SystemId
		   WHERE TLI.CompanyId = @CompanyId 
		   --      and CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
				 --AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') 
				 --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
		         AND ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
		               else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
			     AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		         AND  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate AND TLI.Status=1
		         AND TLI.IsSystem=1 and TLI.SystemType='LeaveApplication'  and La.leavestatus in ('Approved','For Cancellation')
		    GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

  UNION ALL
		----=====================================Calender STEP 3 =================================


    SELECT  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate, CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS,'00.00' AS IsOverRunHours,
		    E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		    TLI.SystemId AS SystemId, TLI.SystemType AS 'SystemType', 2 as IsType 
	        from  Common.TimeLogItem TLI (NOLOCK)
		         INNER JOIN  Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id
		         INNER JOIN Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId 
		         INNER JOIN  [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
		         LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		         --INNER join hr.LeaveApplication as La on La.Id=TLI.SystemId
		    where TLI.CompanyId = @CompanyId  AND TLI.Status=1 AND TLI.ApplyToAll=0 
			   --   AND CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
				  --AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') 
				  --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
                  AND   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
		                else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date)
				  AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		          AND  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		          AND TLI.IsSystem=1 and TLI.SystemType='Calender' and TLI.IsMain=0 ----
		    GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 


	union all
		---=====================================Calender ApplyToAll STEP 4 =================================

		select  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate, CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS ISOVERRUNHOURS,
		        E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		        TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 3 as IsType 
		        from  Common.TimeLogItem TLI (NOLOCK)
		              inner join Common.Employee E (NOLOCK) on E.CompanyId = TLI.CompanyId
		              Inner Join [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
		              LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		        where TLI.CompanyId = @CompanyId 
			         --AND CAST (E.Id  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
			         --AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%')
			         --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
			         AND   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
			               else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date)
		             AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		             AND  TLI.StartDate >= @CsrSdate And TLI.EndDate <=@csrEdate
		             AND TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and TLI.IsMain=0 -- Need to Check 
		       Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 


	union all

				---=====================================Time Log Iteml STEP 5 =================================
		select  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate,
	            RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
                RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2)As TOATLHOURS, '00.00' AS IsOverRunHours,
		        E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		        TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 4 as IsType 
	 	        from  Common.TimeLogItem TLI (NOLOCK)
		              Inner Join Common.TimeLog L (NOLOCK) on l.TimeLogItemId=TLI.id
		              Inner Join Common.TimeLogDetail TLD (NOLOCK) ON TLD.MasterId=L.Id
		              inner join Common.Employee E (NOLOCK) on E.Id = L.EmployeeId
		              Inner Join [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = L.EmployeeId
		              LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		         where TLI.CompanyId = @CompanyId  
				       --AND  CAST (E.Id  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
				       --AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') 
				       --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
			           AND ((@CsrSdate between cast(TLd.Date as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
		                   else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
				       AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		               AND  TLD.Date >= @CsrSdate And TLd.Date <= @csrEdate
                       AND TLI.SystemType='Time Log Item' and TLI.Status=1 and TLI.ApplyToAll is null and tld.Duration <> '00:00:00.0000000'
		        Group by E.FirstName,TLd.Date,E.Id,e.EmployeeId, TLI.Id, TLI.SystemType, TLI.Type,MR.Small,TLI.SubType, TLI.SystemId 
    END 
	ELSE 
	BEGIN 

	Insert Into @OUTPUT

   --============================================CaseGroup STEP 1 ====================================
	SELECT  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate,--SUM(DATEDIFF(MINUTE,0,TLD.Duration))/60.0 As TOATLHOURS,0 AS IsOverRunHours,
		    RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
            RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2)As TOATLHOURS,'00.00' AS IsOverRunHours,E.Id AS EMPLOYEEID,
		    e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,TLI.Id AS SystemId,TLI.SystemType,0 as IsType 
		    FROM Common.TimeLog T (NOLOCK)
		          INNER JOIN Common.TimeLogDetail TLD (NOLOCK) ON T.Id=TLD.MasterId
		          INNER JOIN Common.TimeLogItem TLI (NOLOCK) ON TLI.Id=T.TimeLogItemId
		          LEFT JOIN WorkFlow.CaseGroup CG (NOLOCK) on TLI.SystemId = CG.Id
		          INNER JOIN Common.Employee E (NOLOCK) on T.EmployeeId = E.Id  
		          INNER JOIN [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
		          LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		    WHERE T.CompanyId = @CompanyId and t.Status=1 AND SystemType='CaseGroup' AND t.Status=1 AND tld.Duration <> '00:00:00.0000000' 
			      AND CAST (T.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
			      AND  CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%')
			      AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
                  AND   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
                        else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
			      AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100), Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		          AND T.StartDate >= @CsrSdate And T.EndDate <= @csrEdate --and CG.ServiceNatureType = 0
		   GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.Id, TLI.SystemType,MR.Small  

	
	UNION ALL
	-------====================================LeaveApplication STEP 2 ===========================================

   SELECT  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate, CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS IsOverRunHours,
		   E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		   TLI.SystemId AS SystemId, TLI.SystemType AS 'SystemType', 1 as IsType 
		   from  Common.TimeLogItem TLI (NOLOCK)
		         INNER JOIN Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id
		         INNER JOIN Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId 
		         INNER JOIN [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
		         LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		         LEFT JOIN hr.LeaveApplication as La (NOLOCK) on La.Id=TLI.SystemId
		   WHERE TLI.CompanyId = @CompanyId 
		         and CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
				 AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') 
				 AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
		         AND ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
		               else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
			     AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		         AND  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate AND TLI.Status=1
		         AND TLI.IsSystem=1 and TLI.SystemType='LeaveApplication'  and La.leavestatus in ('Approved','For Cancellation')
		    GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 

  UNION ALL
		----=====================================Calender STEP 3 =================================


    SELECT  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate, CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS,'00.00' AS IsOverRunHours,
		    E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		    TLI.SystemId AS SystemId, TLI.SystemType AS 'SystemType', 2 as IsType 
	        from  Common.TimeLogItem TLI (NOLOCK)
		         INNER JOIN  Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id
		         INNER JOIN Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId 
		         INNER JOIN  [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
		         LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		         --INNER join hr.LeaveApplication as La on La.Id=TLI.SystemId
		    where TLI.CompanyId = @CompanyId  AND TLI.Status=1 AND TLI.ApplyToAll=0 
			      AND CAST (TLD.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
				  AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') 
				  AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
                  AND   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
		                else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date)
				  AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		          AND  TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate
		          AND TLI.IsSystem=1 and TLI.SystemType='Calender' and TLI.IsMain=0 ----
		    GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 


	union all
		---=====================================Calender ApplyToAll STEP 4 =================================

		select  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate, CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS ISOVERRUNHOURS,
		        E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		        TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 3 as IsType 
		        from  Common.TimeLogItem TLI (NOLOCK)
		              inner join Common.Employee E (NOLOCK) on E.CompanyId = TLI.CompanyId
		              Inner Join [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
		              LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		        where TLI.CompanyId = @CompanyId 
			         AND CAST (E.Id  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
			         AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%')
			         AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
			         AND   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
			               else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date)
		             AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		             AND  TLI.StartDate >= @CsrSdate And TLI.EndDate <=@csrEdate
		             AND TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and TLI.IsMain=0 -- Need to Check 
		       Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small 


	union all

				---=====================================Time Log Iteml STEP 5 =================================
		select  E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate,
	            RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
                RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2)As TOATLHOURS, '00.00' AS IsOverRunHours,
		        E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,
		        TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 4 as IsType 
	 	        from  Common.TimeLogItem TLI (NOLOCK)
		              Inner Join Common.TimeLog L (NOLOCK) on l.TimeLogItemId=TLI.id
		              Inner Join Common.TimeLogDetail TLD (NOLOCK) ON TLD.MasterId=L.Id
		              inner join Common.Employee E (NOLOCK) on E.Id = L.EmployeeId
		              Inner Join [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = L.EmployeeId
		              LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		         where TLI.CompanyId = @CompanyId  
				       AND  CAST (E.Id  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
				       AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') 
				       AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
			           AND ((@CsrSdate between cast(TLd.Date as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) 
		                   else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
				       AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		               AND  TLD.Date >= @CsrSdate And TLd.Date <= @csrEdate
                       AND TLI.SystemType='Time Log Item' and TLI.Status=1 and TLI.ApplyToAll is null and tld.Duration <> '00:00:00.0000000'
		        Group by E.FirstName,TLd.Date,E.Id,e.EmployeeId, TLI.Id, TLI.SystemType, TLI.Type,MR.Small,TLI.SubType, TLI.SystemId 
	END 
		
	Fetch Next From Week_Csr into @CsrSdate,@csrEdate
End

close Week_Csr
Deallocate Week_Csr
  

  Select EMPLOYEENAME ,STARTDATE ,ENDDATE ,
TOTALHOURS ,IsOverRunHours ,EMPLOYEEID ,EMPLOYEEAUTONUMBER ,PHOTOURL ,SystemId  ,SystemType , IsType
  From @OUTPUT
 End
 end 
GO
