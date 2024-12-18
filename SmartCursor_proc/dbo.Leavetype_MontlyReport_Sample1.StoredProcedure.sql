USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Leavetype_MontlyReport_Sample1]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[Leavetype_MontlyReport_Sample1]
@CompanyValue varchar(max),
@FromDate varchar(max),
@Todate varchar(max)

 As
 Begin

--  Exec Leavetype_MontlyReport_Sample1 1,'01-01-2018','31-12-2018'

  SET @ToDate = CONVERT(DATETIME, CONVERT(varchar(11),@ToDate, 103 ) + ' 23:59:59', 103) 

--Declare @CompanyValue int=1,
--@FromDate Datetime='2018-01-01',
--@TODate Datetime='2018-12-31'


SELECT E.FirstName EmpName,YEAR(LA.StartDateTime) AS 'Year',
		SUM(CASE WHEN  EntitlementType='Hours' THEN CAST(ISNULL(LA.Hours,0) AS DECIMAL(18,2))/ ISNULL(DefaultWorkingHours,0) else ISNULL(LA.Days,0) end )Days, LA.CompanyId,lt.Name LeaveType, LEFT(DATENAME(MONTH,LA.StartDateTime),3)+'-'+RIGHT(YEAR(LA.StartDateTime),2) AS MonthYear,MONTH(LA.StartDateTime) AS 'Month' 
 FROM   HR.LeaveApplication LA 
 LEFT JOIN Common.localization A on A.CompanyId=LA.CompanyId
 INNER JOIN   HR.LeaveType LT on lt.Id=LA.LeaveTypeId 
 INNER JOIN Common.Employee E on E.Id=LA.EmployeeId
  WHERE  LA.CompanyId=@CompanyValue AND LA.LeaveStatus NOT IN ('Rejected','Cancelled')  
  --and E.FirstName='Anupama Gadipati'
	 AND CONVERT(DATE,LA.StartDateTime) BETWEEN   @FromDate and  @Todate
	AND LA.StartDateTime Between  CONVERT(datetime, @FromDate, 103) AND CONVERT(datetime, @ToDate, 103) 
 GROUP BY LA.CompanyId,lt.Name, LEFT(DATENAME(MONTH,LA.StartDateTime),3)+'-'+RIGHT(YEAR(LA.StartDateTime),2),MONTH(LA.StartDateTime),  
   YEAR(LA.StartDateTime),E.FirstName
ORDER BY Name ,YEAR(LA.StartDateTime) ,month(LA.StartDateTime)
END
GO
