USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HR_Dashboard_Emp_Calender_Details]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  procedure [dbo].[HR_Dashboard_Emp_Calender_Details]  
@Empid uniqueidentifier,  
@Companyid bigint  
As begin  
begin try  
  
  
Declare @LeaveTypeid uniqueidentifier  
  
  
declare @FromDate date = (SELECT DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0)),  
@ToDate date = (SELECT DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0)))  
  
   
select NEWID() ID,gg.EmpName,gg.DeptName,gg.Designation,'On Leave' Type,NUll AS Value1,Null AS Value2, LeaveType 'Item Name', gg.PhotoURL  
from   
(  
    select Distinct l.EmployeeId,lt.Name as LeaveType,mr.Small as PhotoURL  
    from hr.LeaveApplication l (NOLOCK)  
    inner join HR.LeaveType lt (NOLOCK) on l.LeaveTypeId=lt.Id  
 join Common.Employee e (NOLOCK) on l.EmployeeId=e.Id  
 Left Join   Common.MediaRepository as MR (NOLOCK) on MR.Id = e.PhotoId  
    --where l.CompanyId=@Companyid and e.Status=1 and Convert(date,StartDateTime) between @Fromdate and @Todate   
  where l.CompanyId=@Companyid /* and e.Status=1 */ and Convert(date,GETDATE()) between convert(Date,l.StartDateTime) and convert(Date, l.EndDateTime) and (l.LeaveStatus='Approved' or l.LeaveStatus='For Cancellation')  
)as AA  
inner join   
(  
    select EmployeeId,EmpName,DeptName,Designation,PhotoURL from   
    (  
        select rank() over(partition by ed.employeeid/*ed.departmentId*/ order by ( case when Ed.[EffectiveTo] is null then dateadd(d,-1,Convert(date,Convert(varchar(100),  
        Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else Ed.[EffectiveTo] end  ) desc) as rank,E.FirstName as EmpName,D.Code AS DeptName,DD.Name as Designation,e.Id as EmployeeId,E.CompanyId  
  ,MR.Small as PhotoURL  
        from   hr.EmployeeDepartment as ED (NOLOCK)  
        Join   hr.Employment emp (NOLOCK) on emp.employeeid=ed.employeeid  
        join   Common.Department as D (NOLOCK) on D.id=ED.DepartmentId   
        join   Common.DepartmentDesignation as DD (NOLOCK) on DD.Id=ED.DepartmentDesignationId  
        join   Common.Employee as E (NOLOCK) on E.Id=ED.EmployeeId   
  Left Join   Common.MediaRepository as MR (NOLOCK) on MR.Id = e.PhotoId  
  /* where  e.Status=1 */  
    )ff  
    where rank=1  
)gg on gg.EmployeeId=AA.EmployeeId  
      
Union All --My Leave   
  
  
SELECT  NEWID() ID,EmpName,DeptName,Designation ,'My Leave' as Type,Convert(Nvarchar(20),StartDateTime) as Value1,Convert(Nvarchar(20),EndDateTime) as Value1,LeaveType as 'Item Name',PhotoURL FROM   
(  
    select E.FirstName EmpName,D.Name DeptName,DD.name Designation,la.EmployeeId,LT.Name as LeaveType,StartDateTime,  
 EndDateTime,MR.Small as PhotoURL  
    from  hr.LeaveApplication LA (NOLOCK)  
    INNER join hr.EmployeeDepartment as ED (NOLOCK) on ED.EmployeeId=LA.EmployeeId  
    INNER Join hr.Employment emp (NOLOCK) on emp.employeeid=ed.employeeid  
    INNER join Common.Department as D (NOLOCK) on D.id=ED.DepartmentId   
    INNER join Common.DepartmentDesignation as DD (NOLOCK) on DD.Id=ED.DepartmentDesignationId  
    INNER join Common.Employee as E (NOLOCK) on E.Id=ED.EmployeeId  and E.Id=@Empid  
    INNER join hr.LeaveType LT (NOLOCK) on LT.Id = LA.LeaveTypeId  
 Left join   Common.MediaRepository as MR (NOLOCK) on MR.Id = e.PhotoId  
    and (Convert(Date,EffectiveFrom) <= Convert(date,GetDate()) and (Convert(Date,EffectiveTo) >= Convert(date,GetDate()) or EffectiveTo Is null))  
    WHERE la.EmployeeId=@Empid /* and e.Status=1 */ and LA.StartDateTime between @Fromdate and @Todate and LA.LeaveStatus IN ('Approved','For Cancellation')  
)HH  
  
  
Union all --My Holidays  
     SELECT  NEWID() ID, EmpName,DeptName,Designation,'My Holiday'  AS Type,Convert(Nvarchar(20),FromDateTime) as Value1,Convert(Nvarchar(20),ToDateTime) as Value2,Name as 'Item Name',  Null as PhotoURL FROM (     SELECT  E.FirstName EmpName,Null DeptName
,Null Designation,'My Holiday'  AS TYPE,FromDateTime,ToDateTime,la.Name     FROM Common.Calender la (NOLOCK)     left join Common.CalenderDetails as cad (NOLOCK) on la.Id=cad.MasterId     INNER join Common.Employee as E (NOLOCK) on E.companyid=la.CompanyId     INNER join hr.EmployeeDepartment as ED (NOLOCK) on ED.employeeid=E.id     where (Convert(Date,ED.EffectiveFrom) <= Convert(date,GetDate()) and ( EffectiveTo Is null or Convert(Date,ED.EffectiveTo) >= Convert(date,GetDate()))) and la.Status=1  and (la.ApplyTo='All'  or cad.EmployeeId=@Empid) and la.Status=1     /* and E.Status=1 */ and E.Id=@Empid and LA.FromDateTime between  @Fromdate and @Todate and la.CalendarType='Holidays' )HH   
--SELECT  NEWID() ID, EmpName,DeptName,Designation,'My Holiday'  AS Type,Convert(Nvarchar(20),FromDateTime) as Value1,Convert(Nvarchar(20),ToDateTime) as Value2,Name as 'Item Name',  
-- PhotoURL FROM   
--(  
--    SELECT  E.FirstName EmpName,D.Name DeptName,DD.Name Designation,'My Holiday'  AS TYPE,FromDateTime,ToDateTime,la.Name ,  
-- MR.Small as PhotoURL  
--    FROM Common.Calender la  
--    INNER join hr.EmployeeDepartment as ED on ED.CompanyId=la.CompanyId  
--    INNER Join hr.Employment emp on emp.employeeid=ed.employeeid  
--    INNER join Common.Department as D on D.id=ED.DepartmentId   
--    INNER join Common.DepartmentDesignation as DD on DD.Id=ED.DepartmentDesignationId  
--    INNER join Common.Employee as E on E.Id=ED.EmployeeId   
-- Left join  Common.MediaRepository as MR on MR.Id = e.PhotoId   
--    and (Convert(Date,EffectiveFrom) <= Convert(date,GetDate()) and (Convert(Date,EffectiveTo) >= Convert(date,GetDate()) or EffectiveTo Is null))  
--    WHERE e.Status=1 and E.Id=@Empid and LA.FromDateTime between  @Fromdate and @Todate --AND LA.CompanyId=@Companyid  
--)HH  
  
  
Union all  -- My Trainings  
  
  
--SELECT NEWID() ID, EmpName,DeptName,Designation, Type,Convert(Nvarchar(20),TrainingDate) as Value1,null as Value2, CourseName as 'Item Name',PhotoURL FROM   
--(  
--    SELECT E.FirstName EmpName,d.name DeptName,dd.Name Designation, 'My Training'  AS TYPE,B.EmployeeId,C.TrainingDate,CourseName,  
-- MR.Small as PhotoURL  
--    FROM     HR.Training A  
--    INNER JOIN HR.TrainingAttendee B ON B.TrainingId=A.Id  
--    INNER join hr.TrainingSchedule C ON C.TrainingId=A.Id  
--    INNER join hr.CourseLibrary li on li.Id=A.CourseLibraryId  
--    INNER join hr.EmployeeDepartment as ED on ED.EmployeeId=B.EmployeeId  
--    INNER Join hr.Employment emp on emp.employeeid=ed.employeeid  
--    INNER join Common.Department as D on D.id=ED.DepartmentId   
--    INNER join Common.DepartmentDesignation as DD on DD.Id=ED.DepartmentDesignationId  
--    INNER join Common.Employee as E on E.Id=ED.EmployeeId  and E.Id=@Empid  
-- Left join   Common.MediaRepository as MR on MR.Id = e.PhotoId   
--    and (Convert(Date,EffectiveFrom) <= Convert(date,GetDate()) and (Convert(Date,EffectiveTo) >= Convert(date,GetDate()) or EffectiveTo Is null))  
--    where  B.EmployeeId=@Empid and e.Status=1 and C.TrainingDate between @Fromdate and @Todate    
-- and   
-- ((B.EmployeeTrainigStatus='Invited' and A.TrainingStatus='Confirm')  
--   or  
--  (B.EmployeeTrainigStatus='Registered' and A.TrainingStatus='Confirm')  
-- )  
--)HH  
  
SELECT NEWID() ID, EmpName,DeptName,Designation, Type,Convert(Nvarchar(20),TrainingDate) as Value1,null as Value2, CourseName as 'Item Name',PhotoURL FROM   
(  
    SELECT E.FirstName EmpName,null DeptName,null Designation, 'My Training'  AS TYPE,B.EmployeeId,C.TrainingDate,CourseName,  
 MR.Small as PhotoURL  
    FROM     HR.Training A (NOLOCK)  
    INNER JOIN HR.TrainingAttendee B (NOLOCK) ON B.TrainingId=A.Id  
    INNER join hr.TrainingSchedule C (NOLOCK) ON C.TrainingId=A.Id  
    INNER join hr.CourseLibrary li (NOLOCK) on li.Id=A.CourseLibraryId  
    --INNER join hr.EmployeeDepartment as ED on ED.EmployeeId=B.EmployeeId  
    --INNER Join hr.Employment emp on emp.employeeid=ed.employeeid  
    --INNER join Common.Department as D on D.id=ED.DepartmentId   
    --INNER join Common.DepartmentDesignation as DD on DD.Id=ED.DepartmentDesignationId  
     INNER join Common.Employee as E (NOLOCK) on E.Id=@Empid  
 Left join   Common.MediaRepository as MR (NOLOCK) on MR.Id = e.PhotoId   
    --and (Convert(Date,EffectiveFrom) <= Convert(date,GetDate()) and (Convert(Date,EffectiveTo) >= Convert(date,GetDate()) or EffectiveTo Is null))  
    where  B.EmployeeId = @Empid /* and e.Status=1 */ and C.TrainingDate between @Fromdate and @Todate    
 and   
 ((B.EmployeeTrainigStatus='Invited' and A.TrainingStatus='Confirmed')  
   or  
  (B.EmployeeTrainigStatus='Registered' and A.TrainingStatus='Confirmed')  
 )  
)HH  
  
Union All --DOB---  
        
--select NEWID() ID,EmpName,DeptName,Designation,'DOB' Type,Convert(Nvarchar(20),DOB) AS Value1,Null Value2,Null as 'Item Name', PhotoURL from   
  
select NEWID() ID,EmpName,DeptName,Designation,'DOB' Type, Format(DOB,'MMMM') Value1,FORMAT(DOB,'dd') Value2,Null as 'Item Name', PhotoURL from   
(  
   select rank() over(partition by ed.employeeid/*ed.departmentId*/ order by ( case when Ed.[EffectiveTo] is null then dateadd(d,-1,Convert(date,Convert(varchar(100),  
   Year(GETDATE())+1)+'-'+'01'+'-'+'01')) else Ed.[EffectiveTo] end  ) desc) as rank,E.FirstName as EmpName,D.Name AS DeptName,DD.Name as Designation,e.Id as EmployeeId,E.CompanyId,E.DOB  
     ,MR.Small as PhotoURL from   hr.EmployeeDepartment as ED (NOLOCK)  
  Join   hr.Employment emp (NOLOCK) on emp.employeeid=ed.employeeid  
     join   Common.Department as D (NOLOCK) on D.id=ED.DepartmentId   
     join   Common.DepartmentDesignation as DD (NOLOCK) on DD.Id=ED.DepartmentDesignationId  
     join   Common.Employee as E (NOLOCK) on E.Id=ED.EmployeeId   
  Left Join   Common.MediaRepository as MR (NOLOCK) on MR.Id = e.PhotoId   
  Where e.Status=1  
)ff  
  where rank=1 and CompanyId=@Companyid and MONTH(ff.DOB)=MONTH(GETDATE())  
  order by Value1 , value2  
   
         
end try  
begin catch  
 Print 'Failed'  
 SELECT     
    ERROR_NUMBER() AS ErrorNumber    
    ,ERROR_MESSAGE() AS ErrorMessage;    
end catch  
end  
GO
