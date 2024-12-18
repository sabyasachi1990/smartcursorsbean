USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[AttendanceData]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AttendanceData] (@StartDate DATETIME2(7), @EndDate DATETIME2(7), @CompanyId BIGINT, @EmployeeId nvarchar(max), @DepartmentId nvarchar(max), @DesignationId nvarchar(max))    
AS    
BEGIN    
 BEGIN TRANSACTION --1    
    
 BEGIN TRY --2    
  DECLARE @StartDateValue BIGINT = (cast((replace(convert(VARCHAR, @StartDate, 102), '.', '')) AS BIGINT))    
  DECLARE @EndDateValue BIGINT = (cast((replace(convert(VARCHAR, @EndDate, 102), '.', '')) AS BIGINT))    
  DECLARE @EmptyGuid UNIQUEIDENTIFIER = (CAST(0x0 AS UNIQUEIDENTIFIER))    
    
  IF ((@EmployeeId is null or @EmployeeId='') AND (@DepartmentId = '' or @DepartmentId is null) AND (@DesignationId is null or @DesignationId=''))    
  BEGIN --1
  print '1'
   SELECT DISTINCT DEMP.DATE, DEMP.datevalue, DEMP.Id, DEMP.FirstName, ATD.CheckInLocation, ATD.AttendanceType, ATD.CheckOutLocation, ATD.TimeFromString, ATD.TimeToString, ATD.TotalHours, ATD.AdminRemarks, ATD.LateIn, ATD.LateOut, ATD.Id, ATD.DepartmentId
  , ATD.DesignationId, ATD.Remarks, ATD.IsCheckInImage, ATD.IsCheckOutImage, ATD.CheckInRemarks, ATD.CheckOutRemarks, ATD.CompanyId, ATD.Id AS AttendanceId,ATD.LeaveApplicationId,ATD.CalanderId  
   FROM (    
    SELECT HAD.DATE, HAD.datevalue, EMP.id, EMP.FirstName, EMP.EndDate, EMP.STATUS, EMP.StartDate    
    FROM [Hr].[AttendanceDates] HAD    
    CROSS JOIN (    
     SELECT CE.Id, CE.FirstName, HEM.EndDate, CE.STATUS, HEM.StartDate    
     FROM Common.Employee CE    
     INNER JOIN hr.Employment HEM ON CE.Id = HEM.EmployeeId    
     WHERE CE.CompanyId = @CompanyId AND (CE.STATUS = 1 OR (HEM.EndDate <= @EndDate AND HEM.EndDate >= @StartDate))    
     ) EMP    
    WHERE HAD.DateValue <= @EndDateValue AND HAD.DateValue >= @StartDateValue AND EMP.StartDate <= @EndDate AND HAD.DATE >= EMP.StartDate AND ((EMP.EndDate IS NULL OR EMP.EndDate > @EndDate) OR (EMP.EndDate <= @EndDate AND EMP.EndDate >= @StartDate AND EMP.EndDate >= HAD.DATE))    
    ) DEMP    
   LEFT JOIN Common.AttendanceDetails ATD ON DEMP.DateValue = ATD.datevalue AND DEMP.Id = ATD.EmployeeId AND ATD.STATUS = 1    
   ORDER BY DEMP.FirstName, DEMP.DATE    
  END --1    
  ELSE IF ((@EmployeeId is null or @EmployeeId='') AND (@DepartmentId! = '' and @DepartmentId is not null) AND (@DesignationId is null or @DesignationId=''))    
  BEGIN --2 
  print '2'
   SELECT DISTINCT DEMP.DATE, DEMP.datevalue, DEMP.Id, DEMP.FirstName, ATD.CheckInLocation, ATD.AttendanceType, ATD.CheckOutLocation, ATD.TimeFromString, ATD.TimeToString, ATD.TotalHours, ATD.AdminRemarks, ATD.LateIn, ATD.LateOut, ATD.Id, ATD.DepartmentId
  
, ATD.DesignationId, ATD.Remarks, ATD.IsCheckInImage, ATD.IsCheckOutImage, ATD.CheckInRemarks, ATD.CheckOutRemarks, ATD.CompanyId, ATD.Id AS AttendanceId ,ATD.LeaveApplicationId,ATD.CalanderId  
   FROM (    
    SELECT HAD.DATE, HAD.datevalue, EMP.id, EMP.FirstName, EMP.EndDate, EMP.STATUS, EMP.StartDate    
    FROM [Hr].[AttendanceDates] HAD    
    CROSS JOIN (    
     SELECT CE.Id, CE.FirstName, HEM.EndDate, CE.STATUS, HEM.StartDate    
     FROM Common.Employee CE    
     INNER JOIN hr.Employment HEM ON CE.Id = HEM.EmployeeId    
     WHERE CE.CompanyId = @CompanyId
	 AND (CAST (CE.DepartmentId  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@DepartmentId,','))) 
	 AND (CE.STATUS = 1 OR (HEM.EndDate <= @EndDate AND HEM.EndDate >= @StartDate))    
     ) EMP    
    WHERE HAD.DateValue <= @EndDateValue AND HAD.DateValue >= @StartDateValue AND EMP.StartDate <= @EndDate AND HAD.DATE >= EMP.StartDate AND ((EMP.EndDate IS NULL OR EMP.EndDate > @EndDate) OR (EMP.EndDate <= @EndDate AND EMP.EndDate >= @StartDate AND EMP.EndDate >= HAD.DATE))    
    ) DEMP    
   LEFT JOIN Common.AttendanceDetails ATD ON DEMP.DateValue = ATD.datevalue AND DEMP.Id = ATD.EmployeeId AND ATD.STATUS = 1    
   ORDER BY DEMP.FirstName, DEMP.DATE    
  END --2    
  ELSE IF ((@EmployeeId is null or @EmployeeId='') AND (@DepartmentId = '' or @DepartmentId is null) AND (@DesignationId is not null and @DesignationId!=''))    
  BEGIN --3
  
  print '3'
   SELECT DISTINCT DEMP.DATE, DEMP.datevalue, DEMP.Id, DEMP.FirstName, ATD.CheckInLocation, ATD.AttendanceType, ATD.CheckOutLocation, ATD.TimeFromString, ATD.TimeToString, ATD.TotalHours, ATD.AdminRemarks, ATD.LateIn, ATD.LateOut, ATD.Id, ATD.DepartmentId
  
, ATD.DesignationId, ATD.Remarks, ATD.IsCheckInImage, ATD.IsCheckOutImage, ATD.CheckInRemarks, ATD.CheckOutRemarks, ATD.CompanyId, ATD.Id AS AttendanceId ,ATD.LeaveApplicationId ,ATD.CalanderId   FROM (    
    SELECT HAD.DATE, HAD.datevalue, EMP.id, EMP.FirstName, EMP.EndDate, EMP.STATUS, EMP.StartDate    
    FROM [Hr].[AttendanceDates] HAD    
    CROSS JOIN (    
     SELECT CE.Id, CE.FirstName, HEM.EndDate, CE.STATUS, HEM.StartDate    
     FROM Common.Employee CE    
     INNER JOIN hr.Employment HEM ON CE.Id = HEM.EmployeeId    
     WHERE CE.CompanyId = @CompanyId 
	 AND  (CAST (CE.DesignationId  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@DesignationId,','))) 
	 AND (CE.STATUS = 1 OR (HEM.EndDate <= @EndDate AND HEM.EndDate >= @StartDate))    
     ) EMP    
    WHERE HAD.DateValue <= @EndDateValue AND HAD.DateValue >= @StartDateValue AND EMP.StartDate <= @EndDate AND HAD.DATE >= EMP.StartDate AND ((EMP.EndDate IS NULL OR EMP.EndDate > @EndDate) OR (EMP.EndDate <= @EndDate AND EMP.EndDate >= @StartDate AND EMP.EndDate >= HAD.DATE))    
    ) DEMP    
   LEFT JOIN Common.AttendanceDetails ATD ON DEMP.DateValue = ATD.datevalue AND DEMP.Id = ATD.EmployeeId AND ATD.STATUS = 1    
   ORDER BY DEMP.FirstName, DEMP.DATE    
  END --3    
  ELSE IF ((@EmployeeId is null or @EmployeeId='') AND (@DepartmentId! = '' and @DepartmentId is not null) AND (@DesignationId is not null and @DesignationId!=''))    
  BEGIN --4 
  
  print '4'
   SELECT DISTINCT DEMP.DATE, DEMP.datevalue, DEMP.Id, DEMP.FirstName, ATD.CheckInLocation, ATD.AttendanceType, ATD.CheckOutLocation, ATD.TimeFromString, ATD.TimeToString, ATD.TotalHours, ATD.AdminRemarks, ATD.LateIn, ATD.LateOut, ATD.Id, ATD.DepartmentId
  
, ATD.DesignationId, ATD.Remarks, ATD.IsCheckInImage, ATD.IsCheckOutImage, ATD.CheckInRemarks, ATD.CheckOutRemarks, ATD.CompanyId, ATD.Id AS AttendanceId  ,ATD.LeaveApplicationId,ATD.CalanderId  
   FROM (    
    SELECT HAD.DATE, HAD.datevalue, EMP.id, EMP.FirstName, EMP.EndDate, EMP.STATUS, EMP.StartDate    
    FROM [Hr].[AttendanceDates] HAD    
    CROSS JOIN (    
     SELECT CE.Id, CE.FirstName, HEM.EndDate, CE.STATUS, HEM.StartDate    
     FROM Common.Employee CE    
     INNER JOIN hr.Employment HEM ON CE.Id = HEM.EmployeeId    
     WHERE CE.CompanyId = @CompanyId 
	 AND  (CAST (CE.DesignationId  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@DesignationId,','))) 
	 AND (CAST (CE.DepartmentId  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@DepartmentId,',')))  
	 AND (CE.STATUS = 1 OR (HEM.EndDate <= @EndDate AND HEM.EndDate >= @StartDate))    
     ) EMP    
    WHERE HAD.DateValue <= @EndDateValue AND HAD.DateValue >= @StartDateValue AND EMP.StartDate <= @EndDate AND HAD.DATE >= EMP.StartDate AND ((EMP.EndDate IS NULL OR EMP.EndDate > @EndDate) OR (EMP.EndDate <= @EndDate AND EMP.EndDate >= @StartDate AND EMP.EndDate >= HAD.DATE))    
    ) DEMP    
   LEFT JOIN Common.AttendanceDetails ATD ON DEMP.DateValue = ATD.datevalue AND DEMP.Id = ATD.EmployeeId AND ATD.STATUS = 1    
   ORDER BY DEMP.FirstName, DEMP.DATE    
  END --4    
  ELSE IF ((@EmployeeId is not null and @EmployeeId!='') AND (@DepartmentId! = '' and @DepartmentId is not null) AND (@DesignationId is  null or @DesignationId=''))    
  BEGIN --5  
  
  print '5'
   SELECT DISTINCT DEMP.DATE, DEMP.datevalue, DEMP.Id, DEMP.FirstName, ATD.CheckInLocation, ATD.AttendanceType, ATD.CheckOutLocation, ATD.TimeFromString, ATD.TimeToString, ATD.TotalHours, ATD.AdminRemarks, ATD.LateIn, ATD.LateOut, ATD.Id, ATD.DepartmentId
  
, ATD.DesignationId, ATD.Remarks, ATD.IsCheckInImage, ATD.IsCheckOutImage, ATD.CheckInRemarks, ATD.CheckOutRemarks, ATD.CompanyId, ATD.Id AS AttendanceId  ,ATD.LeaveApplicationId,ATD.CalanderId  
   FROM (    
    SELECT HAD.DATE, HAD.datevalue, EMP.id, EMP.FirstName, EMP.EndDate, EMP.STATUS, EMP.StartDate    
    FROM [Hr].[AttendanceDates] HAD    
    CROSS JOIN (    
     SELECT CE.Id, CE.FirstName, HEM.EndDate, CE.STATUS, HEM.StartDate    
     FROM Common.Employee CE    
     INNER JOIN hr.Employment HEM ON CE.Id = HEM.EmployeeId    
     WHERE CE.CompanyId = @CompanyId 
	AND  (CAST (CE.Id  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@EmployeeId,',')))
	 AND  (CAST (CE.DepartmentId  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@DepartmentId,',')))
	 AND (CE.STATUS = 1 OR (HEM.EndDate <= @EndDate AND HEM.EndDate >= @StartDate))    
     ) EMP    
    WHERE HAD.DateValue <= @EndDateValue AND HAD.DateValue >= @StartDateValue AND EMP.StartDate <= @EndDate AND HAD.DATE >= EMP.StartDate AND ((EMP.EndDate IS NULL OR EMP.EndDate > @EndDate) OR (EMP.EndDate <= @EndDate AND EMP.EndDate >= @StartDate AND EMP.EndDate >= HAD.DATE))    
    ) DEMP    
   LEFT JOIN Common.AttendanceDetails ATD ON DEMP.DateValue = ATD.datevalue AND DEMP.Id = ATD.EmployeeId AND ATD.STATUS = 1    
   ORDER BY DEMP.FirstName, DEMP.DATE    
  END --5    
  ELSE IF ((@EmployeeId is not null and @EmployeeId!='') AND (@DepartmentId = '' or @DepartmentId is null) AND (@DesignationId is  not null and @DesignationId!=''))    
  BEGIN --6   
  
  print '6'
   SELECT DISTINCT DEMP.DATE, DEMP.datevalue, DEMP.Id, DEMP.FirstName, ATD.CheckInLocation, ATD.AttendanceType, ATD.CheckOutLocation, ATD.TimeFromString, ATD.TimeToString, ATD.TotalHours, ATD.AdminRemarks, ATD.LateIn, ATD.LateOut, ATD.Id, ATD.DepartmentId
  
, ATD.DesignationId, ATD.Remarks, ATD.IsCheckInImage, ATD.IsCheckOutImage, ATD.CheckInRemarks, ATD.CheckOutRemarks, ATD.CompanyId, ATD.Id AS AttendanceId ,ATD.LeaveApplicationId ,ATD.CalanderId  
   FROM (    
    SELECT HAD.DATE, HAD.datevalue, EMP.id, EMP.FirstName, EMP.EndDate, EMP.STATUS, EMP.StartDate    
    FROM [Hr].[AttendanceDates] HAD    
    CROSS JOIN (    
     SELECT CE.Id, CE.FirstName, HEM.EndDate, CE.STATUS, HEM.StartDate    
     FROM Common.Employee CE    
     INNER JOIN hr.Employment HEM ON CE.Id = HEM.EmployeeId    
     WHERE CE.CompanyId = @CompanyId 
	AND  (CAST (CE.Id  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@EmployeeId,','))) 
	AND  (CAST (CE.DesignationId  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@DesignationId,',')))
	 AND (CE.STATUS = 1 OR (HEM.EndDate <= @EndDate AND HEM.EndDate >= @StartDate))    
     ) EMP    
    WHERE HAD.DateValue <= @EndDateValue AND HAD.DateValue >= @StartDateValue AND EMP.StartDate <= @EndDate AND HAD.DATE >= EMP.StartDate AND ((EMP.EndDate IS NULL OR EMP.EndDate > @EndDate) OR (EMP.EndDate <= @EndDate AND EMP.EndDate >= @StartDate AND EMP.EndDate >= HAD.DATE))    
    ) DEMP    
   LEFT JOIN Common.AttendanceDetails ATD ON DEMP.DateValue = ATD.datevalue AND DEMP.Id = ATD.EmployeeId AND ATD.STATUS = 1    
   ORDER BY DEMP.FirstName, DEMP.DATE    
  END --6    
  ELSE IF ((@EmployeeId is not null and @EmployeeId!='') AND (@DepartmentId = '' or @DepartmentId is null) AND (@DesignationId is   null or @DesignationId='')) 

  BEGIN --7   
    print '7'
  print @EmployeeId
   SELECT DISTINCT DEMP.DATE, DEMP.datevalue, DEMP.Id, DEMP.FirstName, ATD.CheckInLocation, ATD.AttendanceType, ATD.CheckOutLocation, ATD.TimeFromString, ATD.TimeToString, ATD.TotalHours, ATD.AdminRemarks, ATD.LateIn, ATD.LateOut, ATD.Id, ATD.DepartmentId
  
, ATD.DesignationId, ATD.Remarks, ATD.IsCheckInImage, ATD.IsCheckOutImage, ATD.CheckInRemarks, ATD.CheckOutRemarks, ATD.CompanyId, ATD.Id AS AttendanceId  ,ATD.LeaveApplicationId,ATD.CalanderId  
   FROM (    
    SELECT HAD.DATE, HAD.datevalue, EMP.id, EMP.FirstName, EMP.EndDate, EMP.STATUS, EMP.StartDate    
    FROM [Hr].[AttendanceDates] HAD    
    CROSS JOIN (    
     SELECT CE.Id, CE.FirstName, HEM.EndDate, CE.STATUS, HEM.StartDate    
     FROM Common.Employee CE    
     INNER JOIN hr.Employment HEM ON CE.Id = HEM.EmployeeId    
     WHERE CE.CompanyId = @CompanyId 
	 AND  (CAST (CE.Id  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@EmployeeId,','))) 
	 AND (CE.STATUS = 1 OR (HEM.EndDate <= @EndDate AND HEM.EndDate >= @StartDate))    
     ) EMP    
    WHERE HAD.DateValue <= @EndDateValue AND HAD.DateValue >= @StartDateValue AND EMP.StartDate <= @EndDate AND HAD.DATE >= EMP.StartDate AND ((EMP.EndDate IS NULL OR EMP.EndDate > @EndDate) OR (EMP.EndDate <= @EndDate AND EMP.EndDate >= @StartDate AND EMP.EndDate >= HAD.DATE))    
    ) DEMP    
   LEFT JOIN Common.AttendanceDetails ATD ON DEMP.DateValue = ATD.datevalue AND DEMP.Id = ATD.EmployeeId AND ATD.STATUS = 1    
   ORDER BY DEMP.FirstName, DEMP.DATE    
  END --7    
  ELSE IF ((@EmployeeId is not null and @EmployeeId!='') AND (@DepartmentId != '' and @DepartmentId is not null) AND (@DesignationId is   not null and @DesignationId!=''))    
  BEGIN --8
  
  print '8'
   SELECT DISTINCT DEMP.DATE, DEMP.datevalue, DEMP.Id, DEMP.FirstName, ATD.CheckInLocation, ATD.AttendanceType, ATD.CheckOutLocation, ATD.TimeFromString, ATD.TimeToString, ATD.TotalHours, ATD.AdminRemarks, ATD.LateIn, ATD.LateOut, ATD.Id, ATD.DepartmentId
  
, ATD.DesignationId, ATD.Remarks, ATD.IsCheckInImage, ATD.IsCheckOutImage, ATD.CheckInRemarks, ATD.CheckOutRemarks, ATD.CompanyId, ATD.Id AS AttendanceId ,ATD.LeaveApplicationId ,ATD.CalanderId  
   FROM (    
    SELECT HAD.DATE, HAD.datevalue, EMP.id, EMP.FirstName, EMP.EndDate, EMP.STATUS, EMP.StartDate    
    FROM [Hr].[AttendanceDates] HAD    
    CROSS JOIN (    
     SELECT CE.Id, CE.FirstName, HEM.EndDate, CE.STATUS, HEM.StartDate    
     FROM Common.Employee CE    
     INNER JOIN hr.Employment HEM ON CE.Id = HEM.EmployeeId    
     WHERE CE.CompanyId = @CompanyId 
	AND  (CAST (CE.Id  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@EmployeeId,','))) 
	 AND  (CAST (CE.DepartmentId  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@DepartmentId,','))) 
	 AND  (CAST (CE.DesignationId  AS NVARCHAR(max)) in ( select items from dbo.SplitToTable(@DesignationId,',')))
	 AND (CE.STATUS = 1 OR (HEM.EndDate <= @EndDate AND HEM.EndDate >= @StartDate))    
     ) EMP    
    WHERE HAD.DateValue <= @EndDateValue AND HAD.DateValue >= @StartDateValue AND EMP.StartDate <= @EndDate AND HAD.DATE >= EMP.StartDate AND ((EMP.EndDate IS NULL OR EMP.EndDate > @EndDate) OR (EMP.EndDate <= @EndDate AND EMP.EndDate >= @StartDate AND EMP.EndDate >= HAD.DATE))    
    ) DEMP    
   LEFT JOIN Common.AttendanceDetails ATD ON DEMP.DateValue = ATD.datevalue AND DEMP.Id = ATD.EmployeeId AND ATD.STATUS = 1    
   ORDER BY DEMP.FirstName, DEMP.DATE    
  END --8    
    
  COMMIT TRANSACTION --1    
 END TRY --2    
    
 BEGIN CATCH    
  ROLLBACK TRANSACTION    
    
  DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;    
    
  SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();    
    
  RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);    
 END CATCH    
END    
 --exec  [dbo].[AttendanceData1] '2021-08-01','2021-08-31',646,'00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000'    
  
  
GO
