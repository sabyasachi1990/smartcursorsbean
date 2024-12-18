USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_TimeLog_AH_Detail_Pending]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Sp_TimeLog_AH_Detail_Pending]  -----  -- Detail (INSIDE)  
  
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
      ENDDATE DATE,TOATLHOURS varchar(max),IsOverRunHours varchar(max),CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000),SCHEDULETYPEID UNIQUEIDENTIFIER NULL,SUBTYPE NVARCHAR(1000), OppSTAGE NVARCHAR(50) ,SCHEDULETYPE NVARCHAR(100), IsType bit)  
  
  
--Insert Into @OUTPUT  
Begin  
Declare @CsrSdate Date,  
  @csrEdate date  
Declare @Temp table (StartDate date,Enddate date)  
  
  
;with cte as  
(  
  select @FROMDATE StartDate,   
    DATEADD(wk, DATEDIFF(wk, 0, @FROMDATE), 5) EndDate  
  union all  
  select dateadd(ww, 1, StartDate),  
    dateadd(ww, 1, EndDate)  
  from cte  
  where dateadd(ww, 1, StartDate)<=  @TODATE  
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
  
 SELECT DISTINCT EMPLOYEENAME,EMPLOYEEID,EMPLOYEEAUTONUMBER,CLIENTNAME,CASENUMBER,CASENAME,@CsrSdate,@csrEdate ,  
 TOATLHOURS As TOTALHOURS,'00.00' AS IsOverRunHours,  
 CASEID,PHOTOURL,SCHEDULETYPEID,NUll AS SUBTYPE,OppSTAGE,SCHEDULETYPE, 0 as IsType   
 FROM  
 (  
 SELECT E.FirstName as EMPLOYEENAME,E.Id AS EMPLOYEEID,e.EmployeeId AS EMPLOYEEAUTONUMBER,  
     Cg.NAME AS CLIENTNAME ,CG.SYSTEMREFNO AS CASENUMBER, Cg.NAME AS CASENAME,T.StartDate as STARTDATE,T.Enddate AS ENDDATE,  
       RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +  
       RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2) As TOATLHOURS,CG.ID AS CASEID,MR.Small as PHOTOURL,  
  CG.id AS SCHEDULETYPEID,o.stage as OppSTAGE,'CaseGroup' AS  SCHEDULETYPE--, 0 as  IsType   
        FROM Common.TimeLog T  
  INNER JOIN Common.TimeLogDetail TLD ON T.Id=TLD.MasterId  
  INNER JOIN Common.TimeLogItem TLI ON TLI.Id=T.TimeLogItemId  
  LEFT JOIN WorkFlow.CaseGroup CG on TLI.SystemId = CG.Id  
  LEFT join ClientCursor.Opportunity o on o.CaseId=cg.Id  
  --LEFT JOIN WORKFLOW.CLIENT C ON C.ID=CG.CLIENTID  --parvathi
  INNER JOIN Common.Employee E on T.EmployeeId = E.Id    
  INNER JOIN [HR].[EmployeeDepartment] as HR on HR.EmployeeId = E.Id  
  LEFT JOIN Common.MediaRepository as MR ON MR.Id=E.PhotoId  
  WHERE T.CompanyId =@CompanyId AND T.EmployeeId = @EmployeeId AND t.Status=1 And o.Stage='Pending'  
  AND   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null  
        then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+2)+'-'+'01'+'-'+'01'))   
        else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) and   
       cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),  
       Year(GETDATE())+2)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))  
  and T.StartDate >= @CsrSdate And T.EndDate <= @csrEdate --and CG.ServiceNatureType = 0  
  GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.SystemId, TLI.SystemType,MR.Small,Cg.NAME,CG.Id,cg.ClientId,CG.SYSTEMREFNO,o.stage    
  )AS AA  
   
  
  
  Fetch Next From Week_Csr into @CsrSdate,@csrEdate  
End  
  
close Week_Csr  
Deallocate Week_Csr  
    
  
  Select EMPLOYEENAME ,EMPLOYEEID ,EMPLOYEENUMBER , CLIENTNAME ,CASENUMBER ,CASENAME , STARTDATE , ENDDATE ,TOATLHOURS ,IsOverRunHours ,CASEID ,PHOTOURL ,SCHEDULETYPEID,SUBTYPE , OppSTAGE , SCHEDULETYPE , IsType   
  From @OUTPUT  
  End  
  
  
 END  
GO
