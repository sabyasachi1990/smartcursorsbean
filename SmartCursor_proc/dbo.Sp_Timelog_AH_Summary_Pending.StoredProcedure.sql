USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_Timelog_AH_Summary_Pending]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[Sp_Timelog_AH_Summary_Pending]  -----  -- Summary (OUTSIDE )

 @Fromdate date, 
 @ToDate date,
 @DepartmentId uniqueidentifier,
 @DesignationId uniqueidentifier,
 @EmployeeId  uniqueidentifier, 
 @CompanyId int

 AS
 BEGIN

 ----exec [dbo].[Sp_Timelog_AH_Summary_Pending] '2019-01-06','2019-01-12',null,null,null,1
	 --  Declare @Fromdate date='2018-12-30'
  --      Declare @ToDate date='2019-01-05'
		--Declare @EmployeeId  uniqueidentifier=null
		--Declare @DepartmentId uniqueidentifier=NUll
		----'B72E0F75-0361-45CD-83AB-42C891E84552'
		--Declare @DesignationId uniqueidentifier=NUll
		----'DEB181C7-7362-4197-9A5A-B907DDC5CC0A'
  --      Declare @CompanyId int=1

	--------------TImeLog=cases=0
	 DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),STARTDATE DATE,
						ENDDATE DATE,TOTALHOURS varchar(max),ISOVERRUNHOURS varchar(max),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEEAUTONUMBER NVARCHAR(100),
                        PHOTOURL NVARCHAR(1000),SystemId UNIQUEIDENTIFIER NULL,SystemType NVARCHAR(50), IsType int)


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

--======================================  Pending STEP 1  ====================================
	SELECT E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate,--SUM(DATEDIFF(MINUTE,0,TLD.Duration))/60.0 As TOATLHOURS,0 AS IsOverRunHours,
		   RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
           RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2) As TOTALHOURS,'00.00' AS IsOverRunHours,E.Id AS EMPLOYEEID,
		   e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,TLI.SystemId,TLI.SystemType ,0 as IsType
		   FROM Common.TimeLog T (NOLOCK)
		        INNER JOIN Common.TimeLogDetail TLD (NOLOCK) ON T.Id=TLD.MasterId
		        INNER JOIN Common.TimeLogItem TLI (NOLOCK) ON TLI.Id=T.TimeLogItemId
		        LEFT JOIN WorkFlow.CaseGroup CG (NOLOCK) on TLI.SystemId = CG.Id
                left Join ClientCursor.Opportunity o (NOLOCK) on o.Id=cg.OpportunityId
		        INNER JOIN Common.Employee E (NOLOCK) on T.EmployeeId = E.Id  
		        INNER JOIN [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
		        LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		    WHERE T.CompanyId = @CompanyId and t.Status=1 AND o.Stage='Pending' 
			      --AND CAST (T.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
			      --AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%')
			      --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
                  AND   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
                        else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
			      AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		          AND T.StartDate >= @CsrSdate And T.EndDate <= @csrEdate --and CG.ServiceNatureType = 0
		    GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.SystemId, TLI.SystemType,MR.Small  
			END 
			ELSE
			BEGIN 
			Insert Into @OUTPUT

--======================================  Pending STEP 1  ====================================
	SELECT E.FirstName as EMPLOYEENAME,@CsrSdate,@csrEdate,--SUM(DATEDIFF(MINUTE,0,TLD.Duration))/60.0 As TOATLHOURS,0 AS IsOverRunHours,
		   RIGHT('0' + CAST(   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 3600 AS VARCHAR),2) + '.' +
           RIGHT('0' + CAST((   isnull(sum(DATEPART(SECOND, tld.Duration) + 60 *  DATEPART(MINUTE, tld.Duration) + 3600 * DATEPART(HOUR, tld.Duration )),0) / 60) % 60 AS VARCHAR),2) As TOTALHOURS,'00.00' AS IsOverRunHours,E.Id AS EMPLOYEEID,
		   e.EmployeeId AS EMPLOYEEAUTONUMBER,MR.Small as PHOTOURL,TLI.SystemId,TLI.SystemType ,0 as IsType
		   FROM Common.TimeLog T (NOLOCK)
		        INNER JOIN Common.TimeLogDetail TLD (NOLOCK) ON T.Id=TLD.MasterId
		        INNER JOIN Common.TimeLogItem TLI (NOLOCK) ON TLI.Id=T.TimeLogItemId
		        LEFT JOIN WorkFlow.CaseGroup CG (NOLOCK) on TLI.SystemId = CG.Id
                left Join ClientCursor.Opportunity o (NOLOCK) on o.Id=cg.OpportunityId
		        INNER JOIN Common.Employee E (NOLOCK) on T.EmployeeId = E.Id  
		        INNER JOIN [HR].[EmployeeDepartment] as HR (NOLOCK) on HR.EmployeeId = E.Id
		        LEFT JOIN Common.MediaRepository as MR (NOLOCK) ON MR.Id=E.PhotoId
		    WHERE T.CompanyId = @CompanyId and t.Status=1 AND o.Stage='Pending' 
			      AND CAST (T.EmployeeId  AS NVARCHAR(50)) LIKE ISNULL(CAST(@EmployeeId  as NVARCHAR(50)),'%%') 
			      --AND CAST (hr.DepartmentId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DepartmentId as NVARCHAR(50)),'%%')
			      --AND CAST (hr.DepartmentDesignationId AS NVARCHAR(50)) LIKE ISNULL(CAST(@DesignationId as NVARCHAR(50)),'%%')
                  AND   ((@CsrSdate between cast(EffectiveFrom as date) and cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) 
                        else EffectiveTo end  as Date)) or (@csrEdate between cast(EffectiveFrom as date) 
			      AND cast(case when EffectiveTo is null then dateadd(d,-1,Convert(date,Convert(varchar(100),Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else EffectiveTo end  as Date)))
		          AND T.StartDate >= @CsrSdate And T.EndDate <= @csrEdate --and CG.ServiceNatureType = 0
		    GROUP BY E.FirstName,T.StartDate,T.Enddate,E.Id,e.EmployeeId,TLI.SystemId, TLI.SystemType,MR.Small  

			END 

			Fetch Next From Week_Csr into @CsrSdate,@csrEdate
End

close Week_Csr
Deallocate Week_Csr
  

  Select EMPLOYEENAME ,STARTDATE ,
						ENDDATE ,TOTALHOURS ,ISOVERRUNHOURS ,EMPLOYEEID ,EMPLOYEEAUTONUMBER ,
                       PHOTOURL ,SystemId ,SystemType , IsType 
  From @OUTPUT
 End
end 	
GO
