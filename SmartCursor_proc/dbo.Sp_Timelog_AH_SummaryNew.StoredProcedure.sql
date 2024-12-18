USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Timelog_AH_SummaryNew]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--==EXEC [dbo].[Sp_Timelog_AH_SummaryNew] '2020-11-29 00:00:00.0000000','2020-12-05 00:00:00.0000000','partner','1099e962-c92f-4ba8-81d5-c14daee599d2','fe7acf54-128a-4a07-8157-e9b7aa584563',646  
CREATE Procedure  [dbo].[Sp_Timelog_AH_SummaryNew] ---- [dbo].[Sp_Timelog_AH_SummaryNew]  -----  -- Summary (OUTSIDE )  
  
 @Fromdate date,  
 @ToDate date,  
 @DesignationName nvarchar (max),  
 @DepartmentId nvarchar (max),  
 @EmployeeId  nvarchar (max),   
 @CompanyId int  
 AS  
 BEGIN  
   --   Declare @Fromdate date='2020-11-29'  
      --   Declare @ToDate date='2020-12-05'  
   --   Declare @DesignationName nvarchar (max)='partner'  
    --   Declare @DepartmentId uniqueidentifier='1099e962-c92f-4ba8-81d5-c14daee599d2'  
   --   Declare @EmployeeId  uniqueidentifier='fe7acf54-128a-4a07-8157-e9b7aa584563'  
      --   Declare @CompanyId int=646  
  
  --   DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),STARTDATE DATE,ENDDATE DATE,  
  --   TOTALHOURS varchar(max),IsOverRunHours varchar(max),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(100),PHOTOURL NVARCHAR(1000),SystemId UNIQUEIDENTIFIER,SystemType NVARCHAR(1000), IsType bit)  
  Begin  
     --Declare @CsrSdate Date,@csrEdate date  
     CREATE  table #Temp (StartDate date,Enddate date)  
     ;with cte as  
     (  
       select @FROMDATE StartDate, DATEADD(wk, DATEDIFF(wk, 0, @FROMDATE), 5) EndDate  
       union all  
       select dateadd(ww, 1, StartDate),dateadd(ww, 1, EndDate)  
       from cte where dateadd(ww, 1, StartDate)<=  @TODATE  
     )  
     Insert Into #Temp  
     select StartDate,EndDate  
     from cte  
  --=============================== Check EmployeeId DepartmentId DesignationName null ======================================  
     --IF (@EmployeeId IS not NULL AND  @DepartmentId IS not NULL  AND @DesignationName IS not  NULL or (@EmployeeId<>'null' AND  @DepartmentId<>'null'  AND @DesignationName<>'null'))  
     BEGIN   
  --Insert Into @OUTPUT  
  ;WITH OutPut_Tbl AS  
  (  
      --============================================CaseGroup TimeLog Hours  ====================================  
     SELECT  E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate,  
    RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +  
             RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2)As TOTALHOURS,  
   '00.00' AS IsOverRunHours,E.Id AS EMPLOYEEID,e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,TLI.Id AS SystemId,TLI.SystemType ,0 as IsType,CG.Id as CASEID  
       FROM Common.TimeLog T (NOLOCK)  
            INNER JOIN Common.TimeLogDetail TLD (NOLOCK) ON T.Id=TLD.MasterId  
            INNER JOIN Common.TimeLogItem TLI (NOLOCK) ON TLI.Id=T.TimeLogItemId  
            LEFT JOIN WorkFlow.CaseGroup CG (NOLOCK) on TLI.SystemId = CG.Id  
            INNER JOIN Common.Employee E (NOLOCK) on T.EmployeeId = E.Id    
      --inner join Common.Department D ON D.ID=TLD.DepartmentId  
      inner join Common.DepartmentDesignation DD (NOLOCK) ON DD.ID=TLD.DesignationId  
            LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
      INNER JOIN #Temp TEP ON cast(tld.Date AS date) >= TEP.StartDate And cast(tld.Date AS date) <=TEP.EndDate  
        WHERE T.CompanyId = @CompanyId   
          AND CAST (E.Id  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@EmployeeId,','))  
       --AND CAST (TLD.DepartmentId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DepartmentId,','))   
       --AND CAST (DD.Code AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DesignationName,','))   
          AND t.Status=1 AND SystemType='CaseGroup' AND tld.Duration <> '00:00:00.0000000'   
                AND cast(tld.Date AS date) >= TEP.StartDate And cast(tld.Date AS date)<= TEP.EndDate --and CG.ServiceNatureType = 0  
        GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.Id, TLI.SystemType,MR.Small ,TEP.StartDate,TEP.EndDate,tld.Date,CG.Id  
  
 -------====================================LeaveApplication  TimeLog Hours ===========================================  
  UNION ALL  
     SELECT  E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate, CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOTALHOURS, '00.00' AS IsOverRunHours,  
  E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,TLI.SystemId AS SystemId, TLI.SystemType AS 'SystemType', 1 as IsType , NULL AS CASEID  
  from  Common.TimeLogItem TLI (NOLOCK)  
     INNER JOIN Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id  
     INNER JOIN Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId   
     --INNER JOIN [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id  
     --inner join Common.Department D (NOLOCK) ON D.ID=HR.DepartmentId  
     --inner join Common.DepartmentDesignation DD (NOLOCK) ON DD.ID=HR.DepartmentDesignationId  
     LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
     --LEFT JOIN hr.LeaveApplication as La (NOLOCK) on La.Id=TLI.SystemId  
     INNER JOIN #Temp TEP ON cast(TLI.StartDate AS date) >= TEP.StartDate And cast(TLI.EndDate AS date) <=TEP.EndDate  
     WHERE TLI.CompanyId = @CompanyId   
        --         AND ((cast(TLI.StartDate AS date) between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null  
        --then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETUTCDATE())+2)+'-'+'01'+'-'+'01'))  
        --else EffectiveTo end  as Date)) or (cast(TLI.EndDate AS date) between cast(EffectiveFrom as date) and  
        --cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),  
        --Year(GETUTCDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))   
        and  CAST (E.Id  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@EmployeeId,','))  
      --AND CAST (HR.DepartmentId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DepartmentId,','))   
      --AND CAST (dd.Code AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DesignationName,','))   
           AND  CAST(TLI.StartDate AS DATE) >= TEP.StartDate And CAST(TLI.EndDate AS DATE) <= TEP.EndDate AND TLI.Status=1  
           AND TLI.IsSystem=1 and TLI.SystemType='LeaveApplication'  and TLI.SystemSubTypeStatus in ('Approved','For Cancellation')  
      GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small   
   ,TEP.StartDate,TEP.EndDate  
  ----=====================================Calender ApplyToAll=0  TimeLog Hours =================================  
       UNION ALL  
       SELECT  E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate, CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOTALHOURS,'00.00' AS IsOverRunHours,  
    E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,  
    TLI.SystemId AS SystemId, TLI.SystemType AS 'SystemType', 2 as IsType , NULL AS CASEID  
    from  Common.TimeLogItem TLI (NOLOCK)  
        INNER JOIN  Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id  
        INNER JOIN Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId   
        INNER JOIN  [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id  
     inner join Common.Department D (NOLOCK) ON D.ID=HR.DepartmentId  
     inner join Common.DepartmentDesignation DD (NOLOCK) ON DD.ID=HR.DepartmentDesignationId  
        LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
    INNER JOIN #Temp TEP ON cast(TLI.StartDate AS date) >= TEP.StartDate And cast(TLI.EndDate AS date) <=TEP.EndDate  
      where TLI.CompanyId = @CompanyId    
        --AND ((cast(TLI.StartDate AS date) between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null  
        --then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETUTCDATE())+2)+'-'+'01'+'-'+'01'))  
        --else EffectiveTo end  as Date)) or (cast(TLI.EndDate AS date) between cast(EffectiveFrom as date) and  
        --cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),  
        --Year(GETUTCDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))   
        and  CAST (hr.EmployeeId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@EmployeeId,','))  
      --AND CAST (HR.DepartmentId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DepartmentId,','))   
      --AND CAST (dd.Code AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DesignationName,','))   
         AND TLI.Status=1 AND TLI.ApplyToAll=0   
            AND  CAST(TLI.StartDate AS DATE) >= TEP.StartDate And CAST(TLI.EndDate AS DATE)<= TEP.EndDate  
            AND TLI.IsSystem=1 and TLI.SystemType='Calender' and TLI.IsMain=0 ----  
      GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small   
   ,TEP.StartDate,TEP.EndDate  
  ---=====================================Calender ApplyToAll=1  TimeLog Hours  =================================  
     UNION ALL  
  select  E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate, CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOTALHOURS, '00.00' AS ISOVERRUNHOURS,  
  E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,  
  TLI.SystemId AS SystemId, TLI.SystemType AS 'System Type', 3 as IsType , NULL AS CASEID  
  from  Common.TimeLogItem TLI (NOLOCK)  
        inner join Common.Employee E (NOLOCK) on E.CompanyId = TLI.CompanyId  
        Inner Join [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id  
     inner join Common.Department D (NOLOCK) ON D.ID=HR.DepartmentId  
     inner join Common.DepartmentDesignation DD (NOLOCK) ON DD.ID=HR.DepartmentDesignationId  
        LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
     INNER JOIN #Temp TEP ON cast(TLI.StartDate AS date) >= TEP.StartDate And cast(TLI.EndDate AS date) <=TEP.EndDate  
            where TLI.CompanyId = @CompanyId   
          --AND ((cast(TLI.StartDate AS date) between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null  
          --then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETUTCDATE())+2)+'-'+'01'+'-'+'01'))  
          -- else EffectiveTo end  as Date)) or (cast(TLI.EndDate AS date) between cast(EffectiveFrom as date) and  
          -- cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),  
          -- Year(GETUTCDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))   
           and  CAST (hr.EmployeeId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@EmployeeId,','))  
         --AND CAST (HR.DepartmentId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DepartmentId,','))   
         -- AND CAST (dd.Code AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DesignationName,','))   
                AND  CAST(TLI.StartDate AS DATE) >= TEP.StartDate And CAST(TLI.EndDate AS DATE) <=TEP.EndDate  
                AND TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and TLI.IsMain=0 -- Need to Check   
         Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small   
      ,TEP.StartDate,TEP.EndDate  
  ---=====================================Time Log Item TimeLog Hours  =================================  
          UNION ALL  
    select E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate,  
       RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +  
          RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2)As TOTALHOURS, '00.00' AS IsOverRunHours,  
    E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,  
    TLI.SystemId AS SystemId, TLI.SystemType AS SystemType, 4 as IsType , NULL AS CASEID  
     from  Common.TimeLogItem TLI (NOLOCK)  
          Inner Join Common.TimeLog L (NOLOCK) on l.TimeLogItemId=TLI.id  
          Inner Join Common.TimeLogDetail TLD (NOLOCK) ON TLD.MasterId=L.Id  
          inner join Common.Employee E (NOLOCK) on E.Id = L.EmployeeId  
    --inner join Common.Department D ON  D.ID=TLD.DepartmentId    
     --inner join Common.DepartmentDesignation DD (NOLOCK) ON  DD.ID=TLD.DesignationId  
           LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
     INNER JOIN #Temp TEP ON cast(TLD.Date AS date) >= TEP.StartDate And cast(TLD.Date AS date) <=TEP.EndDate  
                 WHERE TLI.CompanyId = @CompanyId    
         AND CAST (E.Id  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@EmployeeId,','))  
           --AND CAST (TLD.DepartmentId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DepartmentId,','))   
           --AND CAST (DD.Code AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DesignationName,','))   
                    AND cast(TLD.Date AS date)  >= TEP.StartDate And cast(TLD.Date AS date)  <= TEP.EndDate  
                       AND TLI.SystemType='Time Log Item' and TLI.Status=1 and TLI.ApplyToAll is null and tld.Duration <> '00:00:00.0000000'  
           Group by E.FirstName,TLd.Date,E.Id,e.EmployeeId, TLI.Id, TLI.SystemType, TLI.Type,MR.Small,TLI.SubType, TLI.SystemId   
                       ,TEP.StartDate,TEP.EndDate  
  ---=====================================Time Log Item TimeLog Hours  =================================  
      Union All  
   SELECT  E.FirstName as EMPLOYEENAME,TEP.StartDate,TEP.EndDate, isnull(CAST(SUM(distinct TLI.ActualHours) AS VARCHAR(max)),'0.00') As TOTALHOURS,'00.00' AS IsOverRunHours,  
   E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER, MR.Small as PHOTOURL,  
   TLI.SystemId AS SystemId, TLI.SystemType AS 'SystemType', 5 as IsType , NULL AS CASEID  
      from  Common.TimeLogItem TLI (NOLOCK)  
         INNER JOIN  Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id  
         INNER JOIN Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId   
         --INNER JOIN  [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id  
      --inner join Common.Department D (NOLOCK) ON D.ID=HR.DepartmentId  
      --inner join Common.DepartmentDesignation DD (NOLOCK) ON DD.ID=HR.DepartmentDesignationId  
         LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
      INNER JOIN #Temp TEP ON cast(TLI.StartDate AS date) >= TEP.StartDate And cast(TLI.EndDate AS date) <=TEP.EndDate  
      WHERE TLI.CompanyId = @CompanyId    
       --AND ((cast(TLI.StartDate AS date) between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null  
       -- then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETUTCDATE())+2)+'-'+'01'+'-'+'01'))  
       -- else EffectiveTo end  as Date)) or (cast(TLI.EndDate AS date) between cast(EffectiveFrom as date) and  
       -- cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),  
       -- Year(GETUTCDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))   
        and  CAST (E.Id  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@EmployeeId,','))  
      --AND CAST (HR.DepartmentId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DepartmentId,','))   
      --AND CAST (dd.Code AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DesignationName,','))   
         AND TLI.Status=1   
            AND  CAST(TLI.StartDate AS DATE) >= TEP.StartDate And CAST(TLI.EndDate AS DATE) <= TEP.EndDate  
            AND TLI.IsSystem=1 and TLI.SystemType='Training'  
      GROUP BY E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small   
   ,TEP.StartDate,TEP.EndDate  
   )   
    
    Select   
  EMPLOYEENAME ,STARTDATE ,ENDDATE ,TOTALHOURS ,IsOverRunHours ,EMPLOYEEID ,EMPLOYEEAUTONUMBER ,PHOTOURL ,SystemId  ,SystemType , IsType,CASEID  
    From   
  OUTPUT_Tbl  
  
 END  
  
 DROP TABLE #Temp  
  End  
End  
  
   --Inner join  
   --  (  
   --  select D.Id As DepartmentId,HR.DepartmentDesignationId,e.Id  
   --  from Common.Employee e  
   --  INNER JOIN [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id  
   --  inner join Common.Department D ON D.ID=HR.DepartmentId  
   --inner join Common.DepartmentDesignation DD ON DD.ID=HR.DepartmentDesignationId  
   --     where    
   --  --((@Fromdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null  
   --  --then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETUTCDATE())+2)+'-'+'01'+'-'+'01'))  
   --  --else EffectiveTo end  as Date)) or (@ToDate between cast(EffectiveFrom as date) and  
   --  --cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),  
   --  --Year(GETUTCDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))   
   --   --(CAST (T.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%')  OR  
   --           CAST (hr.EmployeeId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@EmployeeId,','))-- )  
   --   AND --(CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%') OR   
   --       CAST (HR.DepartmentId  AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DepartmentId,',')) --)  
   --   AND --( CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%') OR  
   --        CAST (dd.Code AS NVARCHAR(max)) in (select items from dbo.SplitToTable(@DesignationName,',')) --)  
   --     Group by D.Id,HR.DepartmentDesignationId,e.Id  
   --  ) AS AA on AA.Id=E.Id and aa.DepartmentId=tld.DepartmentId and aa.DepartmentDesignationId=tld.DesignationId  
   
  




  
GO
