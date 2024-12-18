USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[HRControleCodeUpdateStatments]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[HRControleCodeUpdateStatments]
@Companyid int,
@CategoryName nvarchar(100),
@OldName nvarchar(200),
@NewName nvarchar(200)
--declare @Companyid int = 1,
--@CategoryName nvarchar(100)= 'FeeType',
--@OldName nvarchar(200)  = 'Fixed',
--@NewName nvarchar(200) = 'Fixed1'
AS
Begin

IF(@CategoryName = 'Claims Category') --1
Begin
	update Hr.ClaimItem set Category = @NewName where Category = @OldName and companyid = @Companyid
	update HR.ClaimSetup set Category = @NewName where Category = @OldName and companyid = @Companyid		
END

ELSE if(@CategoryName = 'Employee Designation') --2
Begin
   --- CODE AND Designation AND Department AND ENPLOYEE
	update TV SET TV.Name = @NewName FROM Common.DepartmentDesignation TV 
	Inner Join Common.Department V ON V.Id=TV.DepartmentId  where TV.Name = @OldName and V.CompanyId = @Companyid	 
		 
END

ELSE if(@CategoryName = 'Question Category') --3
Begin
	update HR.Question set Category = @NewName where Category = @OldName and companyid = @Companyid
END

--============================ PENDING   
--ELSE if(@CategoryName = 'Source Type') --4
--Begin
--  ----=====[Source]
--	update HR.JobApplication set [Source] = @NewName where [Source] = @OldName and companyid = @Companyid
--END

--============================ PENDING

----============================ PENDING
ELSE if(@CategoryName = 'ApplicationStatus') --5
Begin
   ----=====INTERVIEW
   	update HR.JobPosting set JobStatus = @NewName where JobStatus = @OldName and companyid = @Companyid
	update HR.JobApplication set ApplicationStatus = @NewName where ApplicationStatus = @OldName and companyid = @Companyid
END
----============================ PENDING

ELSE if(@CategoryName = 'Appraisal Cycle') --6
Begin
	update HR.Appraisal  set AppraisalCycle = @NewName where AppraisalCycle = @OldName and companyid = @Companyid
	update HR.Questionnaire  set AppraisalCycle = @NewName where AppraisalCycle = @OldName and companyid = @Companyid
END


ELSE if(@CategoryName = 'Asset') --7
Begin
	update  Hr.Assetsetup  set Category = @NewName where Category = @OldName and companyid = @Companyid
END

ELSE if(@CategoryName = 'AttendenceType') --8
Begin

    update AD SET AD.AttendanceType  = @NewName FROM Common.AttendanceDetails AD
	Inner Join Common.Attendance A ON A.Id=AD.AttendenceId  where AD.AttendanceType = @OldName and A.CompanyId = @Companyid	 
END

--============================ PENDING
--ELSE if(@CategoryName = 'BankNames') --9
--Begin
--	update HR.EmployeePayrollSetting set PayMode = @NewName where PayMode = @OldName and companyid = @Companyid
--END

--============================ PENDING

ELSE if(@CategoryName = 'CalendarSetUpTypes') --10
Begin
	update Common.Calender set CalendarType = @NewName where CalendarType = @OldName and companyid = @Companyid
END 

ELSE if(@CategoryName = 'Course Category') --11
Begin
	update HR.CourseLibrary  set CourseCategory = @NewName where CourseCategory = @OldName and companyid = @Companyid
END

ELSE if(@CategoryName = 'Funding') --12
Begin
	update HR.CourseLibrary  set Funding = @NewName where Funding = @OldName and companyid = @Companyid
END

ELSE if(@CategoryName = 'ID Type') --13
Begin
	update Common.Employee set IdType = @NewName where IdType = @OldName and companyid = @Companyid
END

ELSE if(@CategoryName = 'MaritalStatus') --14
Begin
	update Common.Employee set MaritalStatus = @NewName where MaritalStatus = @OldName and companyid = @Companyid
END

ELSE if(@CategoryName = 'Nationality') --15
Begin
	update Common.Employee set Nationality = @NewName where Nationality = @OldName and companyid = @Companyid
END

ELSE if(@CategoryName = 'Pay component Category')--16
Begin
	update HR.PayComponent  set Category = @NewName where  Category= @OldName and companyid = @Companyid
END


ELSE if(@CategoryName = 'Period') --17
Begin
	update HR.Employment set [Period] = @NewName where [Period] = @OldName and companyid = @Companyid

END

ELSE if(@CategoryName = 'Race') --18
Begin
	update Common.Employee set Race = @NewName where Race = @OldName and companyid = @Companyid
END

ELSE if(@CategoryName = 'Reason For Leaving') --19
Begin
	update HR.Employment set ReasonForLeaving = @NewName where ReasonForLeaving = @OldName and companyid = @Companyid

END

ELSE if(@CategoryName = 'Relation')--20
Begin

	update AD SET AD.RelationShip  = @NewName FROM HR.FamilyDetails AD
	Inner Join Common.Employee A ON A.Id=AD.EmployeeId  where AD.RelationShip = @OldName and A.CompanyId = @Companyid	 

END


ELSE if(@CategoryName = 'Tax Classification')--21
Begin
	update HR.PayComponent  set TaxClassification = @NewName where  TaxClassification= @OldName and companyid = @Companyid
END


ELSE if(@CategoryName = 'Venue')--22
Begin
	update HR.Training  set Venue = @NewName where  Venue= @OldName and companyid = @Companyid
END
--============= NO USE 
--ELSE if(@CategoryName = 'WorkProfile')--23
--Begin
--	update HR.WorkProfile set TotalWorkingDaysPerWeek = @NewName where TotalWorkingDaysPerWeek = @OldName and companyid = @Companyid
--END
--============= NO USE 

ELSE if(@CategoryName = 'CommunicationType')--24
Begin
	update Common.Employee set Communication = @NewName where Communication = @OldName and companyid = @Companyid
END

ELSE if(@CategoryName = 'VendorType') --25
Begin
	update HR.PayComponent  set DefaultVendor = @NewName where  DefaultVendor= @OldName and companyid = @Companyid
END

--- SALUTATION  ---26


END


 --SELECT DISTINCT ControlCodeCategoryCode FROM Common.ControlCodeCategory WHERE   CompanyId=1 ORDER BY ControlCodeCategoryCode

 --SELECT DISTINCT ControlCodeCategoryCode FROM Common.ControlCodeCategory WHERE   CompanyId=1 AND ModuleNamesUsing='HR Cursor' ORDER BY ControlCodeCategoryCode


































































GO
