USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_EMPLOYEE_INACTIVE_REJOIN_JOB]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[HR_EMPLOYEE_INACTIVE_REJOIN_JOB]  
AS  
BEGIN  
 
 BEGIN TRY
 BEGIN TRANSACTION

 DECLARE @AllActiveEmployee_Tbl TABLE (S_No INT Identity(1, 1), CompanyId BIGINT, Id UNIQUEIDENTIFIER)  
 DECLARE @AllInActiveEmployee_Tbl TABLE (S_No INT Identity(1, 1), CompanyId BIGINT, Id UNIQUEIDENTIFIER)  
 Declare @StartTime Datetime2(7)=(getdate())  
  
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -1 Enter into [dbo].[HR_EMPLOYEE_INACTIVE_REJOIN_JOB]',@StartTime,getdate(),null,null,'')   
 
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -2',@StartTime,getdate(),null,null,'')
 UPDATE ce  
SET ce.[CurrentServiceEnittyId] = HEd.companyid, ce.[DepartmentId] = HED.[DepartmentId], [CE].[DesignationId] = HED.[DepartmentDesignationId], CE.[DepartmentCode] = Dept.[Code], CE.[DesignationCode] = Desig.[Code], CE.[DepartmentName] = Dept.[Name], CE.[DesignationName] = Desig.[Name]  
FROM [Common].[Employee] CE (NOLOCK)
JOIN [HR].[EmployeeDepartment] HED (NOLOCK) ON CE.Id = HEd.employeeid  
JOIN [Common].[Department] Dept (NOLOCK) ON HED.[DepartmentId] = Dept.Id  
JOIN [Common].[DepartmentDesignation] Desig (NOLOCK) ON HED.[DepartmentDesignationId] = Desig.Id  
WHERE (  
  Convert(DATE, HED.EffectiveFrom) <= Convert(DATE, GetDate())  
  AND (  
   Convert(DATE, HED.EffectiveTo) >= Convert(DATE, GetDate())  
   OR HED.EffectiveTo IS NULL  
   )  
  )  
 AND CE.STATUS = 1  
  
 --+++++++++++++++++++++++++==================In Active======================================+++++++++++++++++++++++++  
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -3 Inserting into @AllInActiveEmployee_Tbl',@StartTime,getdate(),null,null,'')

 INSERT INTO @AllInActiveEmployee_Tbl  
 SELECT CE.COMPANYID, CE.ID  
 FROM COMMON.EMPLOYEE CE (NOLOCK)  
 INNER JOIN HR.EMPLOYMENT E (NOLOCK) ON CE.ID = E.EMPLOYEEID  
 WHERE CONVERT(DATE, E.ENDDATE) <= CONVERT(DATE, DATEADD(DAY, - 1, Getutcdate())) AND CE.IDTYPE IS NOT NULL AND CE.STATUS = 1  
   Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -3 Inserting  @AllInActiveEmployee_Tbl Completed',@StartTime,getdate(),null,null,'')
 --==================Employee In Active======================================  
 
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -4 Inactivating the employee',@StartTime,getdate(),null,null,'')
 
 UPDATE CE  
 SET CE.STATUS = 2  
 FROM COMMON.EMPLOYEE CE (NOLOCK)  
 INNER JOIN HR.EMPLOYMENT E (NOLOCK) ON CE.ID = E.EMPLOYEEID  
 WHERE CONVERT(DATE, E.ENDDATE) <= CONVERT(DATE, DATEADD(DAY, - 1, Getutcdate())) AND CE.IDTYPE IS NOT NULL AND CE.STATUS = 1 --added to update only active employees   
Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -4 Inactivating the employee Completed',@StartTime,getdate(),null,null,'')  

Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -5 Deleting Employee Team Calender Details',@StartTime,getdate(),null,null,'')
    

Delete 
HR.TeamCalendarDetail where EmployeeId in ( Select EmployeeId from @AllInActiveEmployee_Tbl)

  Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -4 Deleting Employee Team Calender Details Completed',@StartTime,getdate(),null,null,'')  

 --==================Leave balance update -Leave entitlement ======================================  
 
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -5 Leave balance update -Leave entitlement',@StartTime,getdate(),null,null,'')  

 UPDATE le  
 SET le.YTDLeaveBalance = le.LeaveBalance  
 FROM [HR].[LeaveEntitlement] le (NOLOCK)  
 LEFT JOIN HR.Employment Emp (NOLOCK) ON le.employeeid = emp.employeeid  
 LEFT JOIN Common.Employee ce (NOLOCK) ON ce.id = emp.employeeid  
 WHERE CONVERT(DATE, Emp.ENDDATE) <= CONVERT(DATE, DATEADD(DAY, - 1, Getutcdate())) AND CE.IdType IS NOT NULL AND le.STATUS = 1  
  
   
   
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -5 Leave balance update -Leave entitlement Completed',@StartTime,getdate(),null,null,'')  
 --+++++++++++++++++++++++++==================Active======================================+++++++++++++++++++++++++  
 
  
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -6 @AllActiveEmployee_Tbl insertion',@StartTime,getdate(),null,null,'')  
 INSERT INTO @AllActiveEmployee_Tbl  
 SELECT CE.COMPANYID, CE.ID  
 FROM COMMON.EMPLOYEE CE (NOLOCK)  
 INNER JOIN HR.EMPLOYMENT E (NOLOCK) ON CE.ID = E.EMPLOYEEID  
 WHERE CONVERT(DATE, E.IsReJoined) = CONVERT(DATE, Getutcdate()) AND CE.IDTYPE IS NOT NULL  
 
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -6 @AllActiveEmployee_Tbl Completed',@StartTime,getdate(),null,null,'')  
 --================== Activating the Bean entity based on the Employee Activation ======================================   
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -7 Activating the Bean entity based on the Employee Activation',@StartTime,getdate(),null,null,'')  
 
 UPDATE BE  
 SET BE.STATUS = 1  
 FROM Bean.Entity BE (NOLOCK)  
 INNER JOIN HR.EMPLOYMENT E (NOLOCK) ON BE.SYNCEMPLOYEEID = E.EMPLOYEEID  
 INNER JOIN Common.Employee Emp (NOLOCK) ON E.EmployeeId = Emp.Id  
 WHERE CONVERT(DATE, E.IsReJoined) = CONVERT(DATE, Getutcdate()) AND Emp.STATUS = 2 
  

  Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -7 Activating the Bean entity based on the Employee Activation Completed',@StartTime,getdate(),null,null,'')  
 --================== Employee Active ======================================   
Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -8 Activating the Employee',@StartTime,getdate(),null,null,'')  

 UPDATE CE  
 SET CE.STATUS = 1  
 FROM COMMON.EMPLOYEE CE (NOLOCK)  
 INNER JOIN HR.EMPLOYMENT E (NOLOCK) ON CE.ID = E.EMPLOYEEID  
 WHERE CONVERT(DATE, E.IsReJoined) = CONVERT(DATE, Getutcdate()) AND CE.IDTYPE IS NOT NULL  

 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -8 Activating the Employee Completed',@StartTime,getdate(),null,null,'')  
  
 --================== Employement update ======================================   
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -9  Employement update',@StartTime,getdate(),null,null,'')  
 
 UPDATE E  
 SET /*E.StartDate = Getutcdate(),*/ E.NoticePeriodEnd = NULL, E.NoticePeriodStart = NULL, E.IsReJoined = NULL, E.EndDate = NULL, E.NoticePeriod = NULL, E.NoticePeriodRemarks = NULL, E.ReasonForLeaving = NULL  
 FROM COMMON.EMPLOYEE CE (NOLOCK)  
 INNER JOIN HR.EMPLOYMENT E (NOLOCK) ON CE.ID = E.EMPLOYEEID  
 WHERE CONVERT(DATE, E.IsReJoined) = CONVERT(DATE, Getutcdate()) AND CE.IDTYPE IS NOT NULL  
 
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -9  Employement update Completed',@StartTime,getdate(),null,null,'')  
 --================== Bean entity Inactive ======================================   
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -10  Bean entity Inactive',@StartTime,getdate(),null,null,'')  
 
 UPDATE BE  
 SET BE.STATUS = 2  
 FROM Bean.Entity BE (NOLOCK)  
 INNER JOIN HR.EMPLOYMENT E (NOLOCK) ON BE.SYNCEMPLOYEEID = E.EMPLOYEEID  
 INNER JOIN Common.Employee Emp (NOLOCK) ON E.EmployeeId = Emp.Id  
 WHERE CONVERT(DATE, E.ENDDATE) <= CONVERT(DATE, DATEADD(DAY, - 1, Getutcdate())) AND BE.STATUS = 1 AND Emp.STATUS = 2  
  
  Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -10  Bean entity Inactive Completed',@StartTime,getdate(),null,null,'')  
 --==================Employemnt ENd date Update======================================  
 
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -11 Employemnt ENd date Update',@StartTime,getdate(),null,null,'')  
 UPDATE empd  
 SET Empd.EffectiveTo = Emp.EndDate  
 FROM Common.Employee ce (NOLOCK)  
 INNER JOIN HR.Employment Emp (NOLOCK) ON ce.Id = Emp.EmployeeId  
 INNER JOIN hr.EmployeeDepartment Empd (NOLOCK) ON Emp.EmployeeId = Empd.EmployeeId  
 WHERE CONVERT(DATE, Emp.ENDDATE) <= CONVERT(DATE, DATEADD(DAY, - 1, Getutcdate())) AND CE.IDTYPE IS NOT NULL AND Empd.EffectiveTo IS NULL   
 
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -11 Employemnt ENd date Update Completed',@StartTime,getdate(),null,null,'')  
 --==================Employee History End date update  ======================================  
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -12 Employee History End date update',@StartTime,getdate(),null,null,'')  
 
 UPDATE EH  
 SET EH.[EndDate] = emp.enddate  
 FROM hr.EmployeeHistory EH (NOLOCK)  
 INNER JOIN HR.Employment Emp (NOLOCK) ON EH.EmployeeId = Emp.EmployeeId  
 INNER JOIN Common.Employee CE (NOLOCK) ON CE.Id = Emp.EmployeeId  
 WHERE EH.[EndDate] IS NULL AND EH.[StartDate] IS NOT NULL AND CONVERT(DATE, Emp.ENDDATE) <= CONVERT(DATE, DATEADD(DAY, - 1, Getutcdate())) AND CE.IDTYPE IS NOT NULL  
  
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
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -12 Employee History End date update Completed',@StartTime,getdate(),null,null,'')   
 --=====================================================SP for employeee Inactive   
Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -13 SP for employeee Inactive  ',@StartTime,getdate(),null,null,'')   

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

Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -13 SP for employeee Inactive  Completed',@StartTime,getdate(),null,null,'')     
 ----====================================SP for employeee Active   
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -13 SP for employeee Active',@StartTime,getdate(),null,null,'')     

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
 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Step -13 SP for employeee Active Completed',@StartTime,getdate(),null,null,'')     

 Insert into Common.JobStatus  (Id ,Module ,Jobname ,[Type] ,[Purpose] ,[StartDate] ,[EndDate] ,RecordsEffeted ,Remarks ,JobStatus ) values (newid(),'HRCursor','Employee Active InActive Job','Job','Employee Active InActive Job',@StartTime,getdate(),null,null,'Completed')  

COMMIT TRANSACTION
END TRY

BEGIN CATCH
        ROLLBACK TRANSACTION;

DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE();
RAISERROR (@ErrorMessage, 16, 1);
INSERT INTO Common.JobStatus  
    (Id, Module, Jobname, [Type], [Purpose], [StartDate], [EndDate], RecordsEffeted, Remarks, JobStatus)
VALUES 
    (NEWID(), 'HRCursor', 'Employee Active InActive Job', 'Job', 'Employee Active InActive Job', @StartTime, GETDATE(), NULL, 'Failed: ' + @ErrorMessage, 'Failed');

END CATCH

END  
GO
