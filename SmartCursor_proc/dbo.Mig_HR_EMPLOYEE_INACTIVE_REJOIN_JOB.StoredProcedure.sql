USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Mig_HR_EMPLOYEE_INACTIVE_REJOIN_JOB]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Mig_HR_EMPLOYEE_INACTIVE_REJOIN_JOB]    @companyId Bigint, @date Date    
AS        
BEGIN        
       
 DECLARE @AllActiveEmployee_Tbl TABLE (S_No INT Identity(1, 1), CompanyId BIGINT, Id UNIQUEIDENTIFIER)        
 DECLARE @AllInActiveEmployee_Tbl TABLE (S_No INT Identity(1, 1), CompanyId BIGINT, Id UNIQUEIDENTIFIER)        
 Declare @StartTime Datetime2(7)=(getdate())        
        
      
       
     
 UPDATE ce        
SET ce.[CurrentServiceEnittyId] = HEd.companyid, ce.[DepartmentId] = HED.[DepartmentId], [CE].[DesignationId] = HED.[DepartmentDesignationId], CE.[DepartmentCode] = Dept.[Code], CE.[DesignationCode] = Desig.[Code], CE.[DepartmentName] = Dept.[Name], CE.[DesignationName] = Desig.[Name]        
FROM [Common].[Employee] CE        
JOIN [HR].[EmployeeDepartment] HED ON CE.Id = HEd.employeeid        
JOIN [Common].[Department] Dept ON HED.[DepartmentId] = Dept.Id        
JOIN [Common].[DepartmentDesignation] Desig ON HED.[DepartmentDesignationId] = Desig.Id        
WHERE (        
  Convert(DATE, HED.EffectiveFrom) <= Convert(DATE,@date)        
  AND (        
   Convert(DATE, HED.EffectiveTo) >= Convert(DATE,@date)        
   OR HED.EffectiveTo IS NULL        
   )        
  )        
 AND CE.STATUS = 1   and ce.CompanyId=@companyId     
        
 --+++++++++++++++++++++++++==================In Active======================================+++++++++++++++++++++++++        
    
 INSERT INTO @AllInActiveEmployee_Tbl        
 SELECT CE.COMPANYID, CE.ID        
 FROM COMMON.EMPLOYEE CE        
 INNER JOIN HR.EMPLOYMENT E ON CE.ID = E.EMPLOYEEID        
 WHERE CONVERT(DATE, E.ENDDATE) <= CONVERT(DATE, DATEADD(DAY, - 1, @date)) AND CE.IDTYPE IS NOT NULL AND CE.STATUS = 1   and ce.CompanyId=@companyId      
     
 --==================Employee In Active======================================        
       
    
       
 UPDATE CE        
 SET CE.STATUS = 2        
 FROM COMMON.EMPLOYEE CE        
 INNER JOIN HR.EMPLOYMENT E ON CE.ID = E.EMPLOYEEID        
 WHERE CONVERT(DATE, E.ENDDATE) <= CONVERT(DATE, DATEADD(DAY, - 1, @date)) AND CE.IDTYPE IS NOT NULL AND CE.STATUS = 1 and ce.CompanyId=@companyId --added to update only active employees         
    
         
        
 --==================Leave balance update -Leave entitlement ======================================        
       
        
      
 UPDATE le        
 SET le.YTDLeaveBalance = le.LeaveBalance        
 FROM [HR].[LeaveEntitlement] le        
 LEFT JOIN HR.Employment Emp ON le.employeeid = emp.employeeid        
 LEFT JOIN Common.Employee ce ON ce.id = emp.employeeid        
 WHERE CONVERT(DATE, Emp.ENDDATE) <= CONVERT(DATE, DATEADD(DAY, - 1, @date)) AND CE.IdType IS NOT NULL AND le.STATUS = 1      and ce.CompanyId=@companyId    
        
         
         
     
 --+++++++++++++++++++++++++==================Active======================================+++++++++++++++++++++++++        
       
        
    
 INSERT INTO @AllActiveEmployee_Tbl        
 SELECT CE.COMPANYID, CE.ID        
 FROM COMMON.EMPLOYEE CE        
 INNER JOIN HR.EMPLOYMENT E ON CE.ID = E.EMPLOYEEID        
 WHERE CONVERT(DATE, E.IsReJoined) = CONVERT(DATE, @date) AND CE.IDTYPE IS NOT NULL   and ce.CompanyId=@companyId      
       
       
 --================== Activating the Bean entity based on the Employee Activation ======================================         
     
       
 UPDATE BE        
 SET BE.STATUS = 1        
 FROM Bean.Entity BE        
 INNER JOIN HR.EMPLOYMENT E ON BE.SYNCEMPLOYEEID = E.EMPLOYEEID        
 INNER JOIN Common.Employee Emp ON E.EmployeeId = Emp.Id        
 WHERE CONVERT(DATE, E.IsReJoined) = CONVERT(DATE, @date) AND Emp.STATUS = 1     and Emp.CompanyId=@companyId    
        
      
     
 --================== Employee Active ======================================         
    
      
 UPDATE CE        
 SET CE.STATUS = 1        
 FROM COMMON.EMPLOYEE CE        
 INNER JOIN HR.EMPLOYMENT E ON CE.ID = E.EMPLOYEEID        
 WHERE CONVERT(DATE, E.IsReJoined) = CONVERT(DATE, @date) AND CE.IDTYPE IS NOT NULL   and ce.CompanyId=@companyId  and ce.CompanyId=@companyId      
      
      
        
 --================== Employement update ======================================         
     
       
 UPDATE E        
 SET /*E.StartDate = @date,*/ E.NoticePeriodEnd = NULL, E.NoticePeriodStart = NULL, E.IsReJoined = NULL, E.EndDate = NULL, E.NoticePeriod = NULL, E.NoticePeriodRemarks = NULL, E.ReasonForLeaving = NULL        
 FROM COMMON.EMPLOYEE CE        
 INNER JOIN HR.EMPLOYMENT E ON CE.ID = E.EMPLOYEEID        
 WHERE CONVERT(DATE, E.IsReJoined) = CONVERT(DATE, @date) AND CE.IDTYPE IS NOT NULL    and ce.CompanyId=@companyId      
       
        
 --================== Bean entity Inactive ======================================         
     
       
 UPDATE BE        
 SET BE.STATUS = 2        
 FROM Bean.Entity BE        
 INNER JOIN HR.EMPLOYMENT E ON BE.SYNCEMPLOYEEID = E.EMPLOYEEID        
 INNER JOIN Common.Employee Emp ON E.EmployeeId = Emp.Id        
 WHERE CONVERT(DATE, E.ENDDATE) <= CONVERT(DATE, DATEADD(DAY, - 1, @date)) AND BE.STATUS = 1 AND Emp.STATUS = 2   and Emp.CompanyId=@companyId       
        
         
 --==================Employemnt ENd date Update======================================        
       
     
 UPDATE empd        
 SET Empd.EffectiveTo = Emp.EndDate        
 FROM Common.Employee ce        
 INNER JOIN HR.Employment Emp ON ce.Id = Emp.EmployeeId        
 INNER JOIN hr.EmployeeDepartment Empd ON Emp.EmployeeId = Empd.EmployeeId        
 WHERE CONVERT(DATE, Emp.ENDDATE) <= CONVERT(DATE, DATEADD(DAY, - 1, @date)) AND CE.IDTYPE IS NOT NULL AND Empd.EffectiveTo IS NULL  and ce.CompanyId=@companyId          
       
     
 --==================Employee History End date update  ======================================        
     
       
 UPDATE EH        
 SET EH.[EndDate] = emp.enddate        
 FROM hr.EmployeeHistory EH        
 INNER JOIN HR.Employment Emp ON EH.EmployeeId = Emp.EmployeeId        
 INNER JOIN Common.Employee CE ON CE.Id = Emp.EmployeeId        
 WHERE EH.[EndDate] IS NULL AND EH.[StartDate] IS NOT NULL AND CONVERT(DATE, Emp.ENDDATE) <= CONVERT(DATE, DATEADD(DAY, - 1, @date)) AND CE.IDTYPE IS NOT NULL     and ce.CompanyId=@companyId        
        
 DECLARE @INACTIVEEMPCOUNT INT        
 DECLARE @ACTIVEEMPCOUNT INT        
 DECLARE @ACTIVE INT = 1        
 DECLARE @INACTIVE INT = 1        
        
 SET @INACTIVEEMPCOUNT = (        
   SELECT COUNT(*)        
   FROM @AllInActiveEmployee_Tbl        
   )        
 SET @ACTIVEEMPCOUNT = (        
   SELECT COUNT(*)        
   FROM @AllActiveEmployee_Tbl        
   )        
        
 --=====================================================SP for employeee Inactive         
       
      
 WHILE @INACTIVEEMPCOUNT >= @INACTIVE        
 BEGIN --1        
  DECLARE @COMPANYID1 BIGINT = (        
    SELECT COMPANYID        
    FROM @AllInActiveEmployee_Tbl        
    WHERE S_No = @INACTIVE        
    )        
        
  EXEC [Common].[UpdateLicensesUsed] @COMPANYID1, 'HR Cursor', 'InActive', 'Employee';        
          
        
  SET @INACTIVE = @INACTIVE + 1        
 END --1        
      
      
 ----====================================SP for employeee Active         
        
      
 WHILE @ACTIVEEMPCOUNT >= @ACTIVE        
 BEGIN --1        
  DECLARE @COMPANYID2 BIGINT = (        
    SELECT COMPANYID        
    FROM @AllActiveEmployee_Tbl        
    WHERE S_No = @ACTIVE        
    )        
        
  EXEC [Common].[UpdateLicensesUsed] @COMPANYID2, 'HR Cursor', 'Active', 'Employee';          
        
  SET @ACTIVE = @ACTIVE + 1        
 END --1        
    
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Employee Active InActive Job',@StartTime,getdate(),null,null,'Completed')        
END  
GO
