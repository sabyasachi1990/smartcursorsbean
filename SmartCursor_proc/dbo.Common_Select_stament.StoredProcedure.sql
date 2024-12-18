USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Select_stament]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Common_Select_stament]
AS
BEGIN


-- Exec Common_Select_stament

-- Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


--Select * from Common.AccountBatch

Select Count(*),'Common.AccountSource' from Common.AccountSource
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.AccountType' from Common.AccountType
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.AccountTypeIdType' from Common.AccountTypeIdType ATIT
Inner Join Common.AccountType AT on AT.Id=ATIT.AccountTypeId
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.ActivityHistory'  from Common.ActivityHistory
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

--Select * from Common.ActivityRelatedTo

--Select * from Common.AddressBook

--Select * from Common.Addresses

--Select * from Common.AddressHistory

Select Count(*),'Common.AGMSetting' from Common.AGMSetting
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

--Select * from Common.AppsWorldPostalCode

Select Count(*),'Common.Attendance' from Common.Attendance
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.AttendanceAttachments' from Common.AttendanceAttachments
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.AttendanceDetails'  
from Common.AttendanceDetails AD

Inner Join Common.Attendance A on A.Id=AD.AttendenceId
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.AttendanceRules' from Common.AttendanceRules
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.AuditFirm' from Common.AuditFirm
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.AutoNumber' from Common.AutoNumber
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.AutoNumberCompany' from Common.AutoNumberCompany ANC
Inner Join Common.AutoNumber AN on AN.Id=ANC.AutonumberId
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.AutoNumberDetail'  
from Common.AutoNumberDetail ANDL

Inner Join Common.AutoNumber AN on AN.Id=ANDL.MasterId
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Bank'  from Common.Bank
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Bank'from Common.Blade B
Inner Join Common.ModuleDetail MD on MD.Id=B.ModuleDetailId
Where MD.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)



--Select * from Common.BladeDetail

--Select * from Common.BladeMaster

--Select * from Common.BladeType

--Select * from Common.Building

Select Count(*),'Common.ModuleDetail' from Common.ModuleDetail
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

--Select * from Common.ModuleMaster

Select Count(*),'Common.ModuleDetail' from Common.CacheKeys CK
Inner Join Common.ModuleDetail MD on MD.Id=CK.ModuleDetailId
Where MD.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Calender'  from Common.Calender
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.CalenderDetails'  from Common.CalenderDetails CD
Inner Join Common.Calender C on C.Id=CD.MasterId
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.ChangesHistory' from Common.ChangesHistory
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

--Select * from Common.Comment

--Select * from Common.Communication

Select Count(*),'Common.Company' from Common.Company
Where Id in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.CompanyFeatures' from Common.CompanyFeatures
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.CompanyGlobalSettings' from Common.CompanyGlobalSettings
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.CompanyModule' from Common.CompanyModule
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.CompanyModuleSetUp' from Common.CompanyModuleSetUp
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

--Select * from Common.CompanyNameHistory -- Common.EntityDetail (Id)

Select Count(*),'Common.CompanyService' from Common.CompanyService CS
Inner Join Common.Service S on S.Id=CS.ServiceId
Where S.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.CompanySetting'  from Common.CompanySetting
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

--Select * from Common.CompanyStatus

Select Count(*),'Common.CompanyTemplateSettings'  from Common.CompanyTemplateSettings
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.CompanyUser' from Common.CompanyUser
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Configuration' from Common.Configuration
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Contact' from Common.Contact
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.ContactDetails' from Common.ContactDetails CD
Inner Join Common.Contact C on C.Id=CD.ContactId
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.ControlCodeCategory' from Common.ControlCodeCategory
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.ControlCodeCategoryModule' from Common.ControlCodeCategoryModule
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.ControlCode' from Common.ControlCode CC
Inner Join Common.ControlCodeCategory CCC on CCC.Id=CC.ControlCategoryId
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Currency' from Common.Currency
Where CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Department' from Common.Department 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.DepartmentDesignation' from Common.DepartmentDesignation DD
Inner JOin Common.Department D on D.id=DD.DepartmentId
WHERE D.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Designation' from Common.Designation 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.DesignationHourlyRate' from Common.DesignationHourlyRate DH
Inner join  Common.Department  D ON D.id=DH.DepartmentId
WHERE D.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.DesignationLevel' from Common.DesignationLevel 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.DesignationLevelChargeoutRate' from Common.DesignationLevelChargeoutRate DLC
INNER JOIN Common.DesignationLevel DL ON DL.id=DLC.DesignationLevelId
WHERE DL.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.DocRepository' from Common.DocRepository 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Employee' from Common.Employee 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.EmployeeChargeRate' from Common.EmployeeChargeRate EC
INNER JOIN Common.Employee e ON e.id=EC.EmployeeId
WHERE e.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.EmployeeQualification' from Common.EmployeeQualification EQ
INNER JOIN Common.Employee e ON e.id=Eq.EmployeeId
WHERE e.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.EmployeeServiceGroup' from Common.EmployeeServiceGroup ESG
INNER JOIN Common.Employee e ON e.id=ESG.EmployeeId
WHERE e.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.EmployeeSkill' from Common.EmployeeSkill EK
INNER JOIN Common.Employee e ON e.id=EK.EmployeeId
WHERE e.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.EntityDetail' from Common.EntityDetail 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.EntityType' from Common.EntityType 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.EntityTypeVariables' from Common.EntityTypeVariables ETV
INNER JOIN Common.EntityType  ET ON ET.id=ETV.EntityTypeId
WHERE ET.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.Feature' from Common.Feature F
INNER JOIN  Common.ModuleMaster MM On MM.Id=F.ModuleId
WHERE MM.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.FeeRecoverySetting' from Common.FeeRecoverySetting 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.GenericTemplate' from Common.GenericTemplate 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.GenericTemplateDetail' from Common.GenericTemplateDetail GTD
INNER JOIN Common.GenericTemplate  GT ON GT.id=GTD.GenericTemplateId
WHERE GT.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.GenericTemplateRelatedTo' from Common.GenericTemplateRelatedTo GTR
INNER JOIN Common.GenericTemplate  GT ON GT.id=GTR.TemplateId
WHERE GT.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.GeoPC_Business' from Common.GeoPC_Business  --No Relation

Select Count(*),'Common.GeoPC_Places' from Common.GeoPC_Places --No Relation

Select Count(*),'Common.GenericTemplateRelatedTo' from Common.GeoPC_Regions --No Relation

Select Count(*),'Common.Common.GeoPC_Streets' from Common.GeoPC_Streets --No Relation

Select Count(*),'Common.GSTDetail' from Common.GSTDetail GD
INNER JOIN Common.ModuleMaster MM ON MM.Id =GD.ModuleMasterId
WHERE MM.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.GSTSetting' from Common.GSTSetting 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Holiday' from Common.Holiday 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.HRSettingdetails' from Common.HRSettingdetails HSD
INNER JOIN Common.HRSettings H ON H.Id=HSD.MasterId
WHERE H.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.HRSettings' from Common.HRSettings 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.HRSettings' from Common.IdType 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.IdType' from Common.IdType 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.Industry' from Common.Industry 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.InitialCursorSetup' from Common.InitialCursorSetup 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.LeadBatch' from Common.LeadBatch -- No Relations

Select Count(*),'Common.Level' from Common.Level  l
Inner join Common.DesignationLevel DL ON Dl.levelid=l.id
WHERE Dl.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Localization' from Common.Localization  
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.MediaRepositories' from Common.MediaRepositories MR
Inner join Common.MediaRepository M on M.Id=MR.MediaRepositoryId
WHERE M.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.MediaRepository' from Common.MediaRepository 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.MessageDetail' from Common.MessageDetail MD
Inner join Common.MessageMaster MM ON MM.Id=MD.MasterId
WHERE MM.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.MessageMaster' from Common.MessageMaster 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Milestone' from Common.Milestone M
Inner Join Common.ServiceGroup SG ON SG.Id=M.ServiceGroupId
WHERE SG.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.ModuleDetail' from Common.ModuleDetail MD
Inner Join Common.ModuleMaster MM ON MM.id=MD.ModuleMasterId
WHERE MM.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.ModuleMaster' from Common.ModuleMaster 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Postalcode' from Common.Postalcode  -- Preference

Select Count(*),'Common.Preference' from Common.Preference  --Preference

Select Count(*),'Common.ReminderBatchList' from Common.ReminderBatchList 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.ReminderSetting' from Common.ReminderSetting 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


--Select Count(*),'Common.Reply' from Common.Reply R 
--Inner join Common.Comment C On C.id=R.CommentId
--WHERE C.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261) -- NoRElation

Select Count(*),'Common.Service' from Common.Service S
Inner join Common.ServiceGroup SG ON SG.Id=S.ServiceGroupId
WHERE SG.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261) 

Select Count(*),'Common.ServiceGroup' from Common.ServiceGroup 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261) 

Select Count(*),'Common.ServiceRate' from Common.ServiceRate SR
Inner join Common.ServiceGroup SG ON SG.Id=SR.ServiceGroupId
WHERE SG.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261) 


Select Count(*),'Common.ServiceRateDetail' from Common.ServiceRateDetail SRD
Inner join Common.Designation D ON D.Id=SRD.DesignationId
WHERE D.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.ServiceRecuringSettings' from Common.ServiceRecuringSettings SRS
Inner join  Common.Service S on s.id=SRS.ServiceId
Inner join Common.ServiceGroup SG ON SG.id=S.ServiceGroupId
WHERE SG.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

Select Count(*),'Common.ServiceTemplate' from Common.ServiceTemplate SRS
Inner join  Common.Service S on s.id=SRS.ServiceId
Inner join Common.ServiceGroup SG ON SG.id=S.ServiceGroupId
WHERE SG.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

Select Count(*),'Common.StateChange' from Common.StateChange 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  


Select Count(*),'Common.Streets' from Common.Streets --No Relationa

Select Count(*),'Common.Suggestion' from Common.Suggestion 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  


Select Count(*),'Common.Task' from Common.Task T
Inner JOIN Common.ServiceGroup SG ON SG.Id=T.ServiceGroupId
WHERE SG.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

Select Count(*),'Common.Template' from Common.Template 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

Select Count(*),'Common.TemplateAttachment' from Common.TemplateAttachment TA
Inner join Common.Template T ON T.ID=TA.TemplateId
WHERE T.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

Select Count(*),'Common.TemplateDetail' from Common.TemplateDetail TA
Inner join Common.TemplateMaster TM ON TM.ID=TA.MasterId
WHERE TM.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  


Select Count(*),'Common.TemplateMaster' from Common.TemplateMaster 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  


Select Count(*),'Common.TemplateRelatedTo' from Common.TemplateRelatedTo TA
Inner join Common.Template T ON T.ID=TA.TemplateId
WHERE T.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  



Select Count(*),'Common.TemplateSent' from Common.TemplateSent TS
Inner join Common.Template T ON T.ID=TS.TemplateId
WHERE T.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

Select Count(*),'Common.TemplateSetUp' from Common.TemplateSetUp 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

Select Count(*),'Common.TemplateSetUp' from Common.TemplateSetUpDetail TSD
Inner join Common.TemplateSetUp TS ON TS.Id= TSD.TemplateSetUpId
WHERE TS.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

Select Count(*),'Common.TemplateType' from Common.TemplateType 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

Select Count(*),'Common.TemplateTypeDetail' from Common.TemplateTypeDetail  TT
Inner join Common.TemplateType T ON T.Id=TT.TemplateTypeId
WHERE T.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  

Select Count(*),'Common.TermsOfPayment' from Common.TermsOfPayment  
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.TimeLog' from Common.TimeLog  
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)  


Select Count(*),'Common.TimeLogDetail' from Common.TimeLogDetail TD
Inner join  Common.TimeLog  T on T.id=TD.MasterId
WHERE T.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261) 


Select Count(*),'Common.TimeLogDetailSplit' from Common.TimeLogDetailSplit TDS
Inner join Common.TimeLogDetail TD on TD.id=TDS.TimelogDetailId
Inner join  Common.TimeLog  T on T.id=TD.MasterId
WHERE T.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)   


Select Count(*),'Common.TimeLogItem' from Common.TimeLogItem 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)   


Select Count(*),'Common.TimeLogItemDetail' from Common.TimeLogItemDetail TID
Inner join Common.TimeLogItem T ON T.Id=TID.TimeLogItemId
WHERE T.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261) 

Select Count(*),'Common.TimeLogSchedule' from Common.TimeLogSchedule TID
Inner join Common.Employee e ON e.Id=TID.EmployeeId
WHERE e.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261) 

Select Count(*),'Common.TimeLogSettings' from Common.TimeLogSettings 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261) 

Select Count(*),'Common.UserAccountCursors' from Common.UserAccountCursors uac
Inner join Common.ModuleMaster mm on mm.id=uac.ModuleMasterId
WHERE mm.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261) 

Select Count(*),'Common.ViewPermission' from Common.ViewPermission VP
Inner join Common.ModuleMaster mm on mm.id=VP.ModuleDetailId
WHERE mm.CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

Select Count(*),'Common.Walkup' from Common.Walkup -- No Relations


Select Count(*),'Common.Widget' from Common.Widget 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)


Select Count(*),'Common.WorkWeekSetUp' from Common.WorkWeekSetUp 
WHERE CompanyId in (0,1,10,12,19,136,138,172,239,242,256,258,261)

END
GO
