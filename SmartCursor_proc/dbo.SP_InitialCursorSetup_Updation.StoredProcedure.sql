USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_InitialCursorSetup_Updation]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [dbo].[SP_InitialCursorSetup_Updation](@NEW_COMPANY_ID BIGINT)
as 
begin

declare @count int 

set @count = (select COUNT(*) from Common.IdType where CompanyId = @NEW_COMPANY_ID)
if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Id Types' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Id Types' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


set @count = (select COUNT(*) from Common.TermsOfPayment where CompanyId = @NEW_COMPANY_ID)
if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Credit Terms' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Credit Terms' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID

 set @count = (select COUNT(*) from Common.ServiceGroup where CompanyId = @NEW_COMPANY_ID)
 if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Service Groups' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Service Groups' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


  set @count = (select COUNT(*) from Common.Service where CompanyId = @NEW_COMPANY_ID)
  if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Services' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Services' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID

   set @count = (select COUNT(*) from Common.AccountType where CompanyId = @NEW_COMPANY_ID)
   if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Account Types' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Account Types' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


    set @count = (select COUNT(*) from Common.AttendanceRules where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Attendance Setup' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Attendance Setup' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


     set @count = (select COUNT(*) from Common.AutoNumber where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Auto Numbering' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Auto Numbering' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


      set @count = (select COUNT(*) from Common.Calender where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Calendar' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Calendar' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


       set @count = (select COUNT(*) from Common.Calender where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Calendar Setups' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Calendar Setups' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


        set @count = (select COUNT(*) from HR.ClaimSetup where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Claim Setup' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Claim Setup' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


         set @count = (select COUNT(*) from Common.ControlCodeCategory where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Control Codes' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Control Codes' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


          set @count = (select COUNT(*) from Common.Department where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Departments' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Departments' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


           set @count = (select COUNT(*) from Common.Employee where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Employees' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Employees' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


            set @count = (select COUNT(*) from Common.Localization where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'General Settings' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'General Settings' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID




              set @count = (select COUNT(*) from WorkFlow.IncidentalClaimItem where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Incidental Setups' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Incidental Setups' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID



              set @count = (select COUNT(*) from hr.LeaveType  where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Leave Setup' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Leave Setup' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID




               set @count = (select COUNT(*) from Common.Employee where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Members Profile' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Members Profile' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID



                set @count = (select COUNT(*) from Notification.NotificationSettings where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Notification Settings' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Notification Settings' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


                 set @count = (select COUNT(*) from hr.CompanyPayrollSettings where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Payroll Setup' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Payroll Setup' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


                 set @count = (select COUNT(*) from Common.ReminderMaster where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Reminder Settings' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Reminder Settings' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


                 set @count = (select COUNT(*) from Common.HRSettings where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Setting' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Setting' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


                 set @count = (select COUNT(*) from Common.GenericTemplate where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Template Settings' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Template Settings' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID







                 set @count = (select COUNT(*) from Common.TimeLogItem where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Time Log Items' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Time Log Items' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


                  set @count = (select COUNT(*) from Common.TimeLogSettings where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Time Log Settings' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Time Log Settings' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID



                  set @count = (select COUNT(*) from Common.WorkWeekSetUp where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Working Hours' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'Working Hours' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID


                  set @count = (select COUNT(*) from HR.WorkProfile where CompanyId = @NEW_COMPANY_ID)
	if(@count > 0)
 update Common.InitialCursorSetup set issetupdone =1 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'WorkProfiles' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID
 else
  update Common.InitialCursorSetup set issetupdone =0 where ModuleDetailId in (select id from Common.ModuleDetail where Heading = 'WorkProfiles' and CompanyId = @NEW_COMPANY_ID) and CompanyId = @NEW_COMPANY_ID



 --CompanyModule SetupDone=1 & IntialCursorSetup =0
	Update CM Set SetUpDone=0  From Common.CompanyModule As CM
	Inner Join
	(
	Select CM.ModuleId,CM.CompanyId,ICS.IsSetUpDone,CM.SetUpDone From Common.CompanyModule As CM
	Inner Join Common.InitialCursorSetup As ICS On ICS.ModuleId=CM.ModuleId And ICS.CompanyId=CM.CompanyId
	Where ICS.IsSetUpDone=0 And CM.SetUpDone=1 And CM.CompanyId=@NEW_COMPANY_ID
	Group by CM.ModuleId,CM.CompanyId,ICS.IsSetUpDone,CM.SetUpDone --Order By Cm.CompanyId,CM.ModuleId
	) As A On A.CompanyId=CM.CompanyId And A.ModuleId=CM.ModuleId
	Where A.CompanyId=@NEW_COMPANY_ID

 --CompanyModule SetUpDone=0 And Intialcursorsetup<>0 or Not In Intial Cursorsetup
	Update CM Set SetUpDone=1 From Common.CompanyModule As CM
	Inner Join
	(
	Select CM.ModuleId,CM.CompanyId,ICS.ModuleId As IntialModuleid From Common.CompanyModule As CM
	Left Join (Select ModuleId,IsSetUpDone,CompanyId From Common.InitialCursorSetup Where IsSetUpDone=0) As ICS On ICS.ModuleId=CM.ModuleId And ICS.CompanyId=CM.CompanyId
	Where  CM.SetUpDone=0 And CM.CompanyId=@NEW_COMPANY_ID And ICS.ModuleId IS Null
	Group by CM.ModuleId,CM.CompanyId,ICS.ModuleId 
	) As A On A.CompanyId=CM.CompanyId And A.ModuleId=CM.ModuleId
	Where CM.CompanyId=@NEW_COMPANY_ID


 --Module Id In CompanyModule And Not In IntialSetup
	Update CM Set SetUpDone=1 From Common.CompanyModule As CM
	Inner Join
	(
	Select Cm.ModuleId,Cm.CompanyId,ICS.ModuleId As IntialModuleId From Common.CompanyModule As CM
	Left Join Common.InitialCursorSetup As ICS On ICS.ModuleId=CM.ModuleId And ICS.CompanyId=CM.CompanyId
	Where ICS.ModuleId Is Null And CM.CompanyId=@NEW_COMPANY_ID
	Group By Cm.ModuleId,Cm.CompanyId,ICS.ModuleId
	) As A On A.CompanyId=CM.CompanyId And A.ModuleId=CM.ModuleId
	Where CM.CompanyId=@NEW_COMPANY_ID



--update Common.InitialCursorSetup set issetupdone = 1 where CompanyId = @NEW_COMPANY_ID
END
GO
