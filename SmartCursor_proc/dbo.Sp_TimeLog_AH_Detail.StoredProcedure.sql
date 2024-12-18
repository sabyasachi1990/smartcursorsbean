USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_TimeLog_AH_Detail]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Sp_TimeLog_AH_Detail] -----  -- Detail (INSIDE)  
@FROMDATE DATE ,   
@TODATE DATE ,  
@EMPLOYEEID  UNIQUEIDENTIFIER ,  
@COMPANYID INT   
  
 AS  
 BEGIN  
  
 CREATE TABLE #Output_Tbl  
   ( EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),  
                        CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),CASENAME NVARCHAR(1000), STARTDATE DATE,  
      ENDDATE DATE,TOATLHOURS varchar(max),IsOverRunHours varchar(max),CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000),  
      SCHEDULETYPEID UNIQUEIDENTIFIER NULL ,SUBTYPE NVARCHAR(1000), OppSTAGE NVARCHAR(50) ,SCHEDULETYPE NVARCHAR(100), IsType bit,  
      LeaveStatus NVARCHAR(100))  
  
  
  Begin  
   Declare @CsrSdate Date,@csrEdate date  
   --Declare @Temp table (StartDate date,Enddate date)  
   Create table #temp (StartDate date,Enddate date)  
  
  
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
  
WHILE (SELECT COUNT(*) FROM #Temp) > 0  
BEGIN  
  SELECT TOP 1 @CsrSdate = StartDate, @csrEdate = Enddate  
  FROM #Temp;  
    Begin  
      Insert Into #Output_Tbl  
  --=======================================Cases TimeLog Hours ===================================================  
   SELECT  E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID,e.EmployeeId AS EMPLOYEEAUTONUMBER, TLI.SubType AS CLIENTNAME ,CG.SYSTEMREFNO AS CASENUMBER, Cg.NAME AS CASENAME,@CsrSdate,@csrEdate,  
   RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +  
      RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2) As TOATLHOURS,  
   '00.00' AS IsOverRunHours,CG.ID AS CASEID,MR.Small as PHOTOURL,CG.id AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,o.stage as OppSTAGE,tli.SystemType AS  SCHEDULETYPE, 0 as  IsType,Null as LeaveStatus    
       FROM Common.TimeLog T (NOLOCK)  
         INNER JOIN Common.TimeLogDetail TLD (NOLOCK) ON T.Id=TLD.MasterId  
         INNER JOIN Common.TimeLogItem TLI (NOLOCK) ON TLI.Id=T.TimeLogItemId  
         LEFT JOIN WorkFlow.CaseGroup CG (NOLOCK) on TLI.SystemId = CG.Id  
         LEFT JOIN  ClientCursor.Opportunity o (NOLOCK) on o.CaseId=cg.Id  
         --LEFT JOIN  WORKFLOW.CLIENT C (NOLOCK) ON C.ID=CG.CLIENTID  
         INNER JOIN Common.Employee E (NOLOCK) on T.EmployeeId = E.Id    
         LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
           WHERE T.CompanyId =@CompanyId AND T.EmployeeId = @EmployeeId AND SystemType='CaseGroup' AND t.Status=1 AND tld.Duration <> '00:00:00.0000000'  
                 and Cast(Tld.Date as Date) >= @CsrSdate And Cast(Tld.Date as Date)<= @csrEdate --and CG.ServiceNatureType = 0  
        GROUP BY E.FirstName,Tld.Date,E.Id,e.EmployeeId,TLI.SystemId,TLI.SubType, TLI.SystemType,MR.Small,Cg.NAME,CG.Id,cg.ClientId,CG.SYSTEMREFNO,o.stage  
    
  --=======================================LeaveApplication TimeLog Hours ===================================================  
    UNION ALL  
       SELECT  E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER,TLI.SubType AS CASENAME ,TLI.SubType AS CASENUMBER, NULL AS  CLIENTNAME,@CsrSdate,@csrEdate,  
       CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,  
    MR.Small as PHOTOURL,TLI.SystemId AS SCHEDULETYPEID, TLI.SubType AS SUBTYPE,NULL as OppSTAGE,TLI.SystemType AS SCHEDULETYPE, 1 as IsType,TLI.SystemSubTypeStatus  
    from  Common.TimeLogItem TLI (NOLOCK)  
           INNER JOIN Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id  
           INNER JOIN Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId   
           --INNER JOIN [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id  
           LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
           --LEFT JOIN hr.LeaveApplication as La (NOLOCK) on La.Id=TLI.SystemId  
           WHERE TLI.CompanyId = @CompanyId AND TLD.EmployeeId  = @EmployeeId AND  TLI.Status=1  
            and  cast(TLI.StartDate  as Date)>= @CsrSdate And cast(TLI.EndDate as Date) <= @csrEdate  
            and TLI.IsSystem=1 and TLI.SystemType='LeaveApplication'  and TLI.SystemSubTypeStatus  in ('Approved','For Cancellation')  
        Group by E.FirstName,TLI.StartDate,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small ,TLI.SubType,TLI.SystemSubTypeStatus    
    
  --=======================================Calender ApplyToAll=0 TimeLog Hours ===================================================  
    UNION ALL  
       select  E.FirstName as EMPLOYEENAME, E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,  
    @CsrSdate,@csrEdate , CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS, '00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,  
    MR.Small as PHOTOURL,TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,2 as IsType,Null as LeaveStatus   
    from  Common.TimeLogItem TLI (NOLOCK)  
       inner join Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id  
       inner join Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId   
       --Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id  
       LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
       WHERE TLI.CompanyId = @CompanyId and TLD.EmployeeId  = @EmployeeId   
             and  CAST(TLI.StartDate AS Date) >= @CsrSdate And cast(TLI.EndDate as Date) <= @csrEdate  
             and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=0 and  TLI.IsMain=0  
       Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small   
    
  --=======================================Calender ApplyToAll=1 TimeLog Hours ===================================================  
   UNION ALL  
      select  E.FirstName as EMPLOYEENAME, E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,  
   @CsrSdate,@csrEdate , CAST(SUM(distinct TLI.Hours) AS VARCHAR(max)) As TOATLHOURS,'00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,  
   MR.Small as PHOTOURL,TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,3 as IsType,Null as LeaveStatus    
   from  Common.TimeLogItem TLI (NOLOCK)  
      inner join Common.Employee E (NOLOCK) on E.CompanyId = TLI.CompanyId  
      --Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id  
      LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
            Where TLI.CompanyId = @CompanyId and E.Id  = @EmployeeId    
            and  cast(TLI.StartDate AS Date) >= @CsrSdate And CAST(TLI.EndDate AS DATE)<= @csrEdate  
            and TLI.SystemType='Calender' and TLI.Status=1 and TLI.ApplyToAll=1 and  TLI.IsMain=0  
      Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small   
    
  --=======================================Time Log Item TimeLog Hours ===================================================  
   UNION ALL  
   SELECT   E.FirstName as EMPLOYEENAME, L.EmployeeId EMPLOYEEID, e.EmployeeId AS  EMPLOYEEAUTONUMBER,TLI.Type AS  CASENAME,TLI.Type AS CASENUMBER, null AS CLIENTNAME,@CsrSdate,@csrEdate,  
   RIGHT('0' + CAST(   isnull(Sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +  
      RIGHT('0' + CAST(( isnull(Sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2) As TOATLHOURS, '00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' 
AS CASEID,MR.Small as PHOTOURL,  
   TLI.Id AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE,TLI.SystemType AS SCHEDULETYPE,4 as IsType,Null as LeaveStatus --,tld.DepartmentId,tld.DesignationId  
   from  Common.TimeLogItem TLI (NOLOCK)  
      Inner Join Common.TimeLog L (NOLOCK) on l.TimeLogItemId=TLI.id  
      Inner Join Common.TimeLogDetail TLD (NOLOCK) ON TLD.MasterId=L.Id  
      inner join Common.Employee E (NOLOCK) on E.Id = L.EmployeeId  
      LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
      WHERE TLI.CompanyId = @CompanyId  AND E.Id  = @EmployeeId   
                  and  CAST(TLD.Date AS DATE) >= @CsrSdate And CAST(TLd.Date AS DATE) <= @csrEdate  
                  and TLI.SystemType='Time Log Item' and TLI.Status=1 and TLI.ApplyToAll is null and tld.Duration <> '00:00:00.0000000' --and tld.Date='2020-11-01'  
      Group by E.FirstName,L.EmployeeId,e.EmployeeId, TLI.Id, TLI.SystemType, TLI.Type,MR.Small,Tld.Date,TLI.SubType   
    
  --=======================================Time Training TimeLog Hours ===================================================  
      UNION ALL  
      select  E.FirstName as EMPLOYEENAME, E.Id AS EMPLOYEEID, e.EmployeeId AS  EMPLOYEENUMBER,TLI.SubType AS CLIENTNAME ,TLI.SubType AS CASENUMBER, null AS CASENAME,  
   @CsrSdate,@csrEdate , ISNULL(CAST(SUM(distinct TLI.ActualHours) AS VARCHAR(max)),'0.00') As TOATLHOURS, '00.00' AS IsOverRunHours,'00000000-0000-0000-0000-000000000000' AS CASEID,  
   MR.Small as PHOTOURL,TLI.SystemId AS SCHEDULETYPEID,TLI.SubType AS SUBTYPE,NULL as OppSTAGE, TLI.SystemType AS SCHEDULETYPE,5 as IsType,Null as LeaveStatus    
   from  Common.TimeLogItem TLI (NOLOCK)  
      inner join Common.TimeLogItemDetail TLD (NOLOCK) on TLD.TimelogitemId=TLI.Id  
      inner join Common.Employee E (NOLOCK) on E.Id = TLD.EmployeeId   
      --Inner Join [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id  
      LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId  
            WHERE TLI.CompanyId = @CompanyId and TLD.EmployeeId  = @EmployeeId   
                  and  CAST(TLI.StartDate AS DATE)>= @CsrSdate And CAST(TLI.EndDate AS DATE) <= @csrEdate  
            and TLI.SystemType='Training' and TLI.Status=1   
      Group by E.FirstName,TLI.StartDate,TLI.SubType,TLI.Enddate,E.Id,e.EmployeeId, TLI.SystemId, TLI.SystemType,MR.Small   
    
    
DELETE FROM #Temp  
  WHERE StartDate = @CsrSdate AND Enddate = @csrEdate  
  
      
 End  
  
END  
  
END  
Select EMPLOYEENAME ,EMPLOYEEID ,EMPLOYEENUMBER , CLIENTNAME ,CASENUMBER ,CASENAME , STARTDATE , ENDDATE ,TOATLHOURS ,IsOverRunHours ,CASEID ,PHOTOURL ,SCHEDULETYPEID,SUBTYPE , OppSTAGE , SCHEDULETYPE , IsType, LeaveStatus    
    From #Output_Tbl  
  
DROP TABLE #Output_Tbl  
DROP TABLE #temp  
END  
GO
