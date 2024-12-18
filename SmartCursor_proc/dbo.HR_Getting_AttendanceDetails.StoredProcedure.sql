USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Getting_AttendanceDetails]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[HR_Getting_AttendanceDetails]    ---- Exec [HR_Getting_AttendanceDetails] 689,'2021-05-01 00:00:00.000','2021-05-31 00:00:00.000'
@CompanyId BIGINT,
@StartDate DATETIME2(7) ,
@EndDate DATETIME2(7) 
AS
Begin
--DECLARE @StartDate DATETIME2(7) = '2021-05-01 00:00:00.000'
--DECLARE @EndDate DATETIME2(7) = '2021-05-31 00:00:00.000';
--DECLARE @CompanyId BIGINT = 689;
---========================================================== Declare tables ===========================================
  DECLARE @EmployeeAttendance TABLE (S_No INT Identity(1, 1), AttendanceDate DATETIME, CompanyId BIGINT);
  DECLARE @attendance TABLE (S_No INT Identity(1, 1), AttendanceDate DATETIME, CompanyId BIGINT, Employeename Nvarchar(200),EmployeeId UNIQUEIDENTIFIER,Departmentid UNIQUEIDENTIFIER,Designationid UNIQUEIDENTIFIER );
  --==============================================================Using CTC Getting One Month Dates===========================================================
  WITH Date_range (calc_date)
  AS (
    
    SELECT DATEADD(DAY, DATEDIFF(DAY, 0, @EndDate) - DATEDIFF(DAY, @StartDate, @EndDate), 0)
    
    UNION ALL
    SELECT DATEADD(DAY, 1, calc_date)
    FROM date_range
    WHERE DATEADD(DAY, 1, calc_date) <= @EndDate
    ) 

 --===========================================================Insert One Month Dates into @EmployeeAttendance ==============================================
 insert into @EmployeeAttendance
 SELECT calc_date,@CompanyId FROM date_range    
 option (maxrecursion 365);
 --========================================================= Insert  One Company all Active Employess Into @attendance=============================================
 INSERT INTO @attendance
 select B.AttendanceDate ,A.CompanyId,A.FirstName AS Employeename,A.ID AS EmployeeId,A.DepartmentId,A.DesignationId from Common.Employee A
 INNER JOIN @EmployeeAttendance B ON B.CompanyId=A.CompanyId
 where A.CompanyId=@CompanyId and a.Status=1  ORDER BY A.ID, B.AttendanceDate


   SELECT B.AttendanceId,B.AttendancedatailId,A.AttendanceDate AS Date,a.EmployeeId, a.Employeename,a.Departmentid,a.Designationid,b.TimeFrom,b.LateIn,b.CheckInLocation,b.TimeTo,b.LateOut,b.CheckOutLocation,b.CheckInRemarks,b.CheckOutRemarks,case when TotalHours is null then '00:00:00'else TotalHours end as TotalHours,
   case when hh.Reason is not null then hh.Reason   when  kk.WSetUp is not  null then kk.WSetUp when  jj.cal is not  null then jj.cal  end Reason,b.Remarks,b.AdminRemarks

  FROM @attendance A
  --====================================================== Here Getting all employees AttendanceDetails===========================================
  left join 
  (
  SELECT  B.EmployeeId AS EMPID,cast(A.DATE as Date) AS Date,a.CompanyId as cmpid,A.id as AttendanceId,B.ID AS AttendancedatailId,convert(varchar(5),b.TimeFrom,108) as TimeFrom ,b.LateIn,b.CheckInLocation,convert(varchar(5),b.TimeTo,108) as TimeTo,b.LateOut,b.CheckOutLocation,b.CheckInRemarks,b.CheckOutRemarks,b.Remarks,b.AdminRemarks,dbo.TimeDifference(TimeFrom, TimeTo) as TotalHours
  From  [Common].[Attendance] A
  inner join [Common].[AttendanceDetails] B ON A.ID=B.AttendenceId
  WHERE A.CompanyId=@CompanyId and a.Date between @StartDate and @EndDate  ----49 767
  )B ON A.EmployeeId=B.EMPID and cast(a.AttendanceDate as date)=B.Date and a.CompanyId=B.cmpid

   --====================================================== Here Getting all employees Approved Leaves =====================================================
  left join 
  (
  select A.EmployeeId,CAST(A.StartDateTime AS DATE) AS StartDateTime,CAST(A.EndDateTime AS DATE) AS EndDateTime,a.companyid as compid,concat(B.NAME,' (',a.StartDateType,')') AS Reason from hr.LeaveApplication A 
  INNER JOIN hr.leavetype B ON B.ID=A.LeaveTypeId
  where A.CompanyId=@CompanyId  and A.LeaveStatus in ('Approved')
  )hh on hh.EmployeeId=a.EmployeeId and cast(a.AttendanceDate as date) between StartDateTime and EndDateTime    and a.CompanyId=hh.compid
     
	 --====================================================== Here Getting One CompanyId Calender =====================================================
  left join 
  (
  select distinct cl.companyid as comyid,convert(date,CL.FromDateTime,103) as FromDateTime,[ChargeType] as Cal from Common.Calender CL where cl.status=1
  )jj on jj.comyid=a.CompanyId and cast(a.AttendanceDate as date)=jj.FromDateTime 
  --====================================================== Here Getting One CompanyId WorkWeekSetUp =====================================================
 left join 
  (
  select distinct cl.companyid as comyid,WeekDay,'Non-Working' as WSetUp from Common.WorkWeekSetUp CL  
  where  CL.EmployeeId is null and cl.WorkingHours='00:00:00.0000000' and cl.IsWorkingDay=0 and  cl.status=1
  )kk on kk.comyid=a.CompanyId and kk.WeekDay=FORMAT(a.AttendanceDate, 'dddd')
--where a.Employeename='John Ho'

END


GO
