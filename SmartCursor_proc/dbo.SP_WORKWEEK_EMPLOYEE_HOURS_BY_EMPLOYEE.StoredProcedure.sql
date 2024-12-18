USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_Both @FromDate='2018-05-27',@ToDate='2018-09-30',@CompanyId=3,@EmployeeId='fcd31c00-9905-4cc3-b276-0e869ecf14d8'
CREATE Procedure [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE]
 @FROMDATE DATE,
 @TODATE DATE, 
 @COMPANYID BIGINT, 
 @EMPLOYEEID UNIQUEIDENTIFIER
 As
 Begin
 
DECLARE @OUTPUT TABLE ( EMPLOYEENAME NVARCHAR (1000),EMPLOYEEID UNIQUEIDENTIFIER,EMPLOYEENUMBER NVARCHAR(100),
                        CLIENTNAME NVARCHAR(1000),CASENUMBER NVARCHAR(100),CASENAME NVARCHAR(1000), STARTDATE DATE,
						ENDDATE DATE,TOATLHOURS MONEY,IsOverRunHours Money,CASEID UNIQUEIDENTIFIER,PHOTOURL NVARCHAR(1000),SCHEDULETYPEID UNIQUEIDENTIFIER NULL, SCHEDULETYPE NVARCHAR(100), IsActualHrs bit)
Insert into @OUTPUT
Exec [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_Both] @FROMDATE =@FROMDATE,@TODATE=@TODATE,@COMPANYID=@COMPANYID,@EMPLOYEEID=@EMPLOYEEID
Insert into @OUTPUT
Exec [dbo].[SP_Planned_Hrs_Calc] @FROMDATE =@FROMDATE,@TODATE=@TODATE,@COMPANYID=@COMPANYID,@EMPLOYEEID=@EMPLOYEEID
Insert into @OUTPUT
Exec [dbo].[SP_WORKWEEK_EMPLOYEE_HOURS_BY_EMPLOYEE_ACTUALHOURSONLY] @FROMDATE =@FROMDATE,@TODATE=@TODATE,@COMPANYID=@COMPANYID,@EMPLOYEEID=@EMPLOYEEID

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
  Select EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SubType,Null,@CsrSdate,@csrEdate,SUM(TLI.Hours),0,null,null,null,SystemType,0
  From Common.TimeLogItem as TLI
  Inner join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
  Inner Join Common.Employee As EMP On EMP.Id=TLID.EmployeeId
  Where TLI.StartDate >= @CsrSdate And TLI.EndDate <= @csrEdate And Tli.CompanyId=@COMPANYID And TLID.EmployeeId=@EMPLOYEEID And       TLI.SystemType = 'LeaveApplication'
  Group by EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SystemType

Fetch Next From Week_Csr into @CsrSdate,@csrEdate
End

close Week_Csr
Deallocate Week_Csr
  
  
  --Select EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SubType,Null,@FROMDATE,@TODATE,SUM(TLI.Hours),0,null,null,SystemId,SystemType,0
  --From Common.TimeLogItem as TLI
  --Inner join Common.TimeLogItemDetail As TLID On TLID.TimeLogItemId=TLI.Id
  --Inner Join Common.Employee As EMP On EMP.Id=TLID.EmployeeId
  --Where TLI.StartDate >= @FROMDATE And TLI.EndDate <= @TODATE And Tli.CompanyId=@COMPANYID And TLID.EmployeeId=@EMPLOYEEID And TLI.Hours <> '0.00'
  --Group by EMP.FirstName,TLID.EmployeeId,EMP.EmployeeId,SubType,SystemId,SystemType 


  Select EMPLOYEENAME ,EMPLOYEEID ,EMPLOYEENUMBER , CLIENTNAME ,CASENUMBER ,CASENAME , STARTDATE ,	ENDDATE ,TOATLHOURS ,IsOverRunHours ,CASEID ,PHOTOURL ,SCHEDULETYPEID , SCHEDULETYPE , IsActualHrs 
  From @OUTPUT
 End

END







GO
