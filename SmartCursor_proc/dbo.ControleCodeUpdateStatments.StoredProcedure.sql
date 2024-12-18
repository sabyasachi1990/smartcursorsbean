USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ControleCodeUpdateStatments]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[ControleCodeUpdateStatments]    
@Companyid int,    
@CategoryName nvarchar(100),    
@OldName nvarchar(200),    
@NewName nvarchar(200)    
--declare @Companyid int = 1,    
--        @CategoryName nvarchar(100)= 'FeeType',    
--  @OldName nvarchar(200)  = 'Fixed',    
--  @NewName nvarchar(200) = 'Fixed1'    
AS    
Begin    
--EXEC [dbo].[ControleCodeUpdateStatments] @Companyid = 1,@CategoryName = 'CommunicationType' ,@OldName = 'Pe123',@NewName = 'Pe'    
    
    
If(@CategoryName = 'Fee Type')    
Begin    
--Begin    
--IF(@OldName='Fixed' AND @Companyid=1 )    
 update WorkFlow.CaseGroup set FeeType = @NewName where FeeType = @OldName and companyid = @Companyid    
    
 update clientcursor.opportunity set FeeType = @NewName where FeeType = @OldName and companyid = @Companyid    
End    
    
    
Else if(@CategoryName = 'Salutation')    
Begin     
 update Common.Contact set Salutation = @NewName where Salutation = @OldName and companyid = @Companyid    
    
 update Common.CompanyUser set Salutation = @NewName where Salutation = @OldName and companyid = @Companyid    
    
 update GC SET GC.Salutation=@NewName FROM Boardroom.GenericContact AS GC      
 INNER JOIN Boardroom.Contacts AS C ON GC.Id=C.GenericContactId      
 INNER JOIN Common.EntityDetail AS E ON C.EntityId=E.Id      
 Where GC.Salutation=@OldName and E.CompanyId=@Companyid      
  update Common.Contact set  Salutation=@NewName where Salutation=@OldName and Companyid=@Companyid    
    
END    
    
Else if(@CategoryName = 'Industries')    
Begin     
      update  WorkFlow.Client set Industry = @NewName where Industry = @OldName and companyid = @Companyid    
 update clientcursor.account set Industry = @NewName where Industry = @OldName and companyid = @Companyid    
     
    
END    
    
    
    
Else if(@CategoryName = 'LeadCategory')    
Begin     
  update C SET  C.Category = @NewName From common.communication C    
  Inner Join ClientCursor.Account A ON A.Id=C.LeadId  where C.Category = @OldName and A.companyid = @Companyid    
    
    
END    
    
    
Else if(@CategoryName = 'MileStone')    
Begin    
 update CSM SET  CSM.MilestoneGroup = @NewName From WorkFlow .CaseMileStone CSM    
 Inner Join [WorkFlow].[CaseGroup] CG ON CG.Id=CSM.CaseId  where CSM.MilestoneGroup = @OldName and CG.companyid = @Companyid    
    
    
 update WL SET  WL.MilestoneGroup = @NewName From Common.Milestone WL    
 Inner Join Common.ServiceGroup ICI ON ICI.Id=WL.ServiceGroupId  where WL.MilestoneGroup = @OldName and ICI.companyid = @Companyid    
    
     
END    
    
ELSE if(@CategoryName = 'Service Nature')    
Begin    
 update WorkFlow.CaseGroup set Nature = @NewName where Nature = @OldName and companyid = @Companyid    
    
 update clientcursor.opportunity set Nature = @NewName where Nature = @OldName and companyid = @Companyid    
    
END    
    
ELSE if(@CategoryName = 'Nationality')    
Begin    
 update Common.Employee set Nationality = @NewName where Nationality = @OldName and companyid = @Companyid    
    
 update WorkFlow.Client set CountryOfIncorporation = @NewName where CountryOfIncorporation = @OldName and companyid = @Companyid    
    
 update HR.JobApplication set Nationality = @NewName where Nationality = @OldName and companyid = @Companyid    
    
 update Boardroom.Genericcontact set Nationality = @NewName where Nationality = @OldName and companyid = @Companyid  
 
 update  OC  SET OC. CurrentNationality=@NewName FROM Boardroom.OfficerChanges as OC        
INNER JOIN Boardroom.Changes AS C ON  OC.ChangesId=c.Id      
INNER JOIN Common.EntityDetail AS E ON C.EntityId=E.Id      
where E.CompanyId=@Companyid     and Oc.CurrentNationality=@OldName 
      

	   update  OC  SET OC. ProposedNationality=@NewName FROM Boardroom.OfficerChanges as OC        
INNER JOIN Boardroom.Changes AS C ON  OC.ChangesId=c.Id      
INNER JOIN Common.EntityDetail AS E ON C.EntityId=E.Id      
where E.CompanyId=@Companyid     and Oc.ProposedNationality=@OldName 
END    
    
ELSE if(@CategoryName = 'Gender')    
Begin    
 update Common.Employee set Gender = @NewName where Gender = @OldName and companyid = @Companyid    
END    
    
    
--ELSE if(@CategoryName = 'CalenderSetUpTypes')    
ELSE if(@CategoryName = 'CalendarSetUpTypes')    ----------------------parvathi
Begin    
 update Common.Calender set CalendarType = @NewName where CalendarType = @OldName and companyid = @Companyid    
END     
    
ELSE if(@CategoryName = 'ChargeType')    
Begin    
 update Common.Calender set ChargeType = @NewName where ChargeType = @OldName and companyid = @Companyid    
END    
    
ELse if(@CategoryName = 'Time Log Item Type')    
Begin    
 update Common.TimeLogItem set Type = @NewName where Type = @OldName and companyid = @Companyid    
END    
    
    
    
ELSE if(@CategoryName = 'EntityAddress')    
Begin    
 update [Common].[Addresses] set AddSectionType = @NewName where AddSectionType = @OldName and companyid = @Companyid    
END    
    
ELSE if(@CategoryName = 'IndividualAddress')    
Begin    
 update [Common].[Addresses] set AddSectionType = @NewName where AddSectionType = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'ReasonForCancel')    
Begin    
 update WorkFlow.CaseGroup set ReasonForCancellation = @NewName where ReasonForCancellation = @OldName and companyid = @Companyid    
    
 update clientcursor.opportunity set ReasonForCancellation = @NewName where ReasonForCancellation = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'IncidentalClaimUnit')    
Begin    
    
 update WL SET  WL.Unit = @NewName From WorkFlow.Incidental WL    
 Inner Join WorkFlow.IncidentalClaimItem ICI ON ICI.Id=WL.ClaimItemId  where WL.Unit = @OldName and ICI.companyid = @Companyid    
    
     
 update WorkFlow.IncidentalClaimItem set ClaimUnit = @NewName where ClaimUnit = @OldName and companyid = @Companyid      
    
     
    
    
    
    
    
END    
    
    
    
ELSE if(@CategoryName = 'Task')    
Begin    
 update WorkFlow.ScheduleTask set Title = @NewName where Title = @OldName and companyid = @Companyid    
    
 Update SRS SET  SRS.TaskDescription = @NewName From Common.Task SRS    
 Inner Join Common.ServiceGroup S ON S.Id=SRS.ServiceGroupId  where SRS.TaskDescription = @OldName and S.companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'Reason')    
Begin    
 update CDC SET  CDC.Reason = @NewName From WorkFlow.CaseAmendDateOfCompletion CDC    
 Inner Join [WorkFlow].[CaseGroup] CG ON CG.Id=CDC.CaseId  where CDC.Reason = @OldName and CG.companyid = @Companyid    
END    
    
ELSE if(@CategoryName = 'TimeLogPeriod')    
Begin    
    
 update SRS SET  SRS.Period = @NewName From Common.ServiceRecuringSettings SRS    
 Inner Join Common.Service S ON S.Id=SRS.ServiceId  where SRS.Period = @OldName and S.companyid = @Companyid    
    
 Update Common.Service set ApprovalName = @NewName where ApprovalName = @OldName and companyid = @Companyid    
    
 Update Common.ServiceGroup set ApprovalName = @NewName where ApprovalName = @OldName and companyid = @Companyid    
    
    
END    
    
    
    
    
 Else if(@CategoryName = 'CommunicationType')    
    
Begin    
    
-- Update Common.Company table    
Update Common.Company Set Communication=REPLACE(Communication,@OldName,@NewName) Where Id=@Companyid    
-- Update Common.Contact table    
Update Common.Contact Set Communication=REPLACE(Communication,@OldName,@NewName) Where CompanyId=@Companyid    
-- Update Common.Employee table    
Update Common.Employee Set Communication=REPLACE(Communication,@OldName,@NewName) Where CompanyId=@Companyid    
-- Update Common.ContactDetails table    
Update CD Set CD.Communication=REPLACE(CD.Communication,@OldName,@NewName) From Common.ContactDetails As CD    
Inner join Common.Contact As C On C.Id=CD.ContactId     
Where C.CompanyId=@Companyid     
    
-- Update Audit.AuditCompanyContact table    
Update AC Set AC.Communication=REPLACE(AC.Communication,@OldName,@NewName) From Audit.AuditCompanyContact As AC    
Inner Join Common.Contact As C On C.Id=AC.ContactId    
Where C.CompanyId=@Companyid    
-- Update Tax.TaxCompanyContact table    
update TC Set TC.Communication=REPLACE(TC.Communication,@OldName,@NewName) From Tax.TaxCompanyContact As TC    
Inner Join Common.Contact As C On C.Id=TC.ContactId    
Where C.CompanyId=@Companyid    
-- Update Bean.Entity table    
Update Bean.Entity Set Communication=REPLACE(Communication,@OldName,@NewName) Where CompanyId=@Companyid    
-- Update WorkFlow.Client table    
Update WorkFlow.Client Set Communication=REPLACE(Communication,@OldName,@NewName) Where CompanyId=@Companyid    
    
---Update Common.EntityDetails table      
update Common.EntityDetail set Communication=REPLACE(Communication,@OldName,@NewName) Where CompanyId=@Companyid      
---Update Boardroom.Contact table      
update  GC  SET GC.Communication=REPLACE(GC.Communication,@OldName,@NewName) FROM Boardroom.GenericContact as GC        
INNER JOIN Boardroom.Contacts AS C ON  GC.Id=C.GenericContactId    
INNER JOIN Common.EntityDetail AS E ON C.EntityId=E.Id      
where E.CompanyId=@Companyid    
    
---update Boardroom.OfficerChnages table      
update  OC  SET OC. CurrentCommunication=REPLACE(OC.CurrentCommunication,@OldName,@NewName) FROM Boardroom.OfficerChanges as OC        
INNER JOIN Boardroom.Changes AS C ON  OC.ChangesId=c.Id      
INNER JOIN Common.EntityDetail AS E ON C.EntityId=E.Id      
where E.CompanyId=@Companyid      
      
---update Boardroom.OfficerChnages table      
      
update  OC   SET OC. ProposedCommunication=REPLACE(OC.ProposedCommunication,@OldName,@NewName) FROM Boardroom.OfficerChanges as OC        
INNER JOIN Boardroom.Changes AS C ON  OC.ChangesId=c.Id      
INNER JOIN Common.EntityDetail AS E ON C.EntityId=E.Id      
where E.CompanyId=@Companyid     
    
    
    
    
END    
    
--;with cte as    
--(    
--select id,case when ThirdName1 is null then  N1+':'+@NewName+','+SecondName    
--else N1+':'+@NewName+','+SecondName+','+ThirdName1 END 'New Communication'    
-- from     
--(    
--select dbo.UFN_SEPARATES_COLUMNS(FirstName, 1, ':') as N1,    
--dbo.UFN_SEPARATES_COLUMNS(FirstName, 2, ':') as N2,*,    
--case when ThirdName='' then Null else ThirdName End  ThirdName1 from     
--(    
--select id,Communication,    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 1, ',') as 'FirstName',    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 2, ',') as 'SecondName',    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 3, ',') as 'ThirdName'    
--from Common.Company where Communication is not null    
--) AS P    
--) AS PP    
--where REPLACE(N2, '"', '')=@OldName     
--)     
    
    
--Update Common.Company set communication = [New Communication]    
--from Common.Company as S    
--INner Join Cte as C On C.id=S.Id    
    
    
--;with cte as    
--(    
--select id,case when ThirdName1 is null then  N1+':'+@NewName+','+SecondName    
--else N1+':'+@NewName+','+SecondName+','+ThirdName1 END 'New Communication'    
-- from     
--(    
--select dbo.UFN_SEPARATES_COLUMNS(FirstName, 1, ':') as N1,    
--dbo.UFN_SEPARATES_COLUMNS(FirstName, 2, ':') as N2,*,    
--case when ThirdName='' then Null else ThirdName End  ThirdName1 from     
--(    
--select id,Communication,    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 1, ',') as 'FirstName',    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 2, ',') as 'SecondName',    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 3, ',') as 'ThirdName'    
--from common.contact where Communication is not null AND CompanyId=@CompanyId    
--) AS P    
--) AS PP    
--where REPLACE(N2, '"', '')=@OldName     
--)     
    
    
--Update common.contact set communication = [New Communication]    
--from common.contact as S    
--INner Join Cte as C On C.id=S.Id    
    
    
--;with cte as    
--(    
--select id,case when ThirdName1 is null then  N1+':'+@NewName+','+SecondName    
--else N1+':'+@NewName+','+SecondName+','+ThirdName1 END 'New Communication'    
-- from     
--(    
--select dbo.UFN_SEPARATES_COLUMNS(FirstName, 1, ':') as N1,    
--dbo.UFN_SEPARATES_COLUMNS(FirstName, 2, ':') as N2,*,    
--case when ThirdName='' then Null else ThirdName End  ThirdName1 from     
--(    
--select id,Communication,    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 1, ',') as 'FirstName',    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 2, ',') as 'SecondName',    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 3, ',') as 'ThirdName'    
--from Common.Employee where Communication is not null AND CompanyId=@CompanyId    
--) AS P    
--) AS PP    
--where REPLACE(N2, '"', '')=@OldName     
--)     
    
    
--Update Common.Employee set communication = [New Communication]    
--from Common.Employee as S    
--INner Join Cte as C On C.id=S.Id    
    
    
    
--;with cte as    
--(    
--select id,case when ThirdName1 is null then  N1+':'+@NewName+','+SecondName    
--else N1+':'+@NewName+','+SecondName+','+ThirdName1 END 'New Communication'    
-- from     
--(    
--select dbo.UFN_SEPARATES_COLUMNS(FirstName, 1, ':') as N1,    
--dbo.UFN_SEPARATES_COLUMNS(FirstName, 2, ':') as N2,*,    
--case when ThirdName='' then Null else ThirdName End  ThirdName1 from     
--(    
--select id,Communication,    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 1, ',') as 'FirstName',    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 2, ',') as 'SecondName',    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 3, ',') as 'ThirdName'    
--from Boardroom.Genericcontact where Communication is not null AND CompanyId=@CompanyId    
--) AS P    
--) AS PP    
--where REPLACE(N2, '"', '')=@OldName     
--)     
    
    
--Update Boardroom.Genericcontact set communication = [New Communication]    
--from Boardroom.Genericcontact as S    
--INner Join Cte as C On C.id=S.Id    
    
    
--;with cte as    
--(    
--select id,case when ThirdName1 is null then  N1+':'+@NewName+','+SecondName    
--else N1+':'+@NewName+','+SecondName+','+ThirdName1 END 'New Communication'    
-- from     
--(    
--select dbo.UFN_SEPARATES_COLUMNS(FirstName, 1, ':') as N1,    
--dbo.UFN_SEPARATES_COLUMNS(FirstName, 2, ':') as N2,*,    
--case when ThirdName='' then Null else ThirdName End  ThirdName1 from     
--(    
--select Acc.id,Acc.Communication,    
--dbo.UFN_SEPARATES_COLUMNS(Acc.Communication, 1, ',') as 'FirstName',    
--dbo.UFN_SEPARATES_COLUMNS(Acc.Communication, 2, ',') as 'SecondName',    
--dbo.UFN_SEPARATES_COLUMNS(Acc.Communication, 3, ',') as 'ThirdName'    
-- From audit.AuditCompanyContact ACC    
-- Inner Join common.contact C ON C.Id=ACC.ContactId where Acc.Communication is not null AND C.CompanyId=@CompanyId    
--) AS P    
--) AS PP    
--where REPLACE(N2, '"', '')=@OldName     
--)     
    
    
--Update audit.AuditCompanyContact set communication = [New Communication]    
--from audit.AuditCompanyContact as S    
--INner Join Cte as C On C.id=S.Id    
    
    
--;with cte as    
--(    
--select id,case when ThirdName1 is null then  N1+':'+@NewName+','+SecondName    
--else N1+':'+@NewName+','+SecondName+','+ThirdName1 END 'New Communication'    
-- from     
--(    
--select dbo.UFN_SEPARATES_COLUMNS(FirstName, 1, ':') as N1,    
--dbo.UFN_SEPARATES_COLUMNS(FirstName, 2, ':') as N2,*,    
--case when ThirdName='' then Null else ThirdName End  ThirdName1 from     
--(    
--select Acc.id,Acc.Communication,    
--dbo.UFN_SEPARATES_COLUMNS(Acc.Communication, 1, ',') as 'FirstName',    
--dbo.UFN_SEPARATES_COLUMNS(Acc.Communication, 2, ',') as 'SecondName',    
--dbo.UFN_SEPARATES_COLUMNS(Acc.Communication, 3, ',') as 'ThirdName'    
-- From Tax.TaxCompanyContact Acc    
-- Inner Join common.contact C ON C.Id=Acc.ContactId where Acc.Communication is not null AND C.CompanyId=@CompanyId    
--) AS P    
--) AS PP    
--where REPLACE(N2, '"', '')=@OldName     
--)     
    
    
--Update Tax.TaxCompanyContact set communication = [New Communication]    
--from Tax.TaxCompanyContact as S    
--INner Join Cte as C On C.id=S.Id    
    
    
--;with cte as    
--(    
--select id,case when ThirdName1 is null then  N1+':'+@NewName+','+SecondName    
--else N1+':'+@NewName+','+SecondName+','+ThirdName1 END 'New Communication'    
-- from     
--(    
--select dbo.UFN_SEPARATES_COLUMNS(FirstName, 1, ':') as N1,    
--dbo.UFN_SEPARATES_COLUMNS(FirstName, 2, ':') as N2,*,    
--case when ThirdName='' then Null else ThirdName End  ThirdName1 from     
--(    
--select id,Communication,    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 1, ',') as 'FirstName',    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 2, ',') as 'SecondName',    
--dbo.UFN_SEPARATES_COLUMNS(Communication, 3, ',') as 'ThirdName'    
--from Bean.Entity where Communication is not null    
--) AS P    
--) AS PP    
--where REPLACE(N2, '"', '')=@OldName     
--)     
    
    
--Update Bean.Entity set Communication = [New Communication]    
--from Bean.Entity as S    
--INner Join Cte as C On C.id=S.Id    
    
   
    
    
    
--ELSE if(@CategoryName = 'CommunicationType')    
--Begin    
 --update common.contact set Communication = @NewName where Communication = @OldName and companyid = @Companyid    
    
 --Common.Employee    
     
 --update Common.Company set Communication = @NewName where Communication = @OldName and id = @Companyid    
     
 --update ACC SET  ACC.Communication = @NewName From audit.AuditCompanyContact ACC    
 --Inner Join common.contact C ON C.Id=ACC.ContactId  where ACC.Communication = @OldName and C.companyid = @Companyid    
    
 --update TCC SET  TCC.Communication = @NewName From Tax.TaxCompanyContact TCC    
 --Inner Join common.contact C ON C.Id=TCC.ContactId  where TCC.Communication = @OldName and C.companyid = @Companyid    
     
 --update Boardroom.Genericcontact set Communication = @NewName where Communication = @OldName and companyid = @Companyid    
--END    
    
    
    
    
ELSE if(@CategoryName = 'Matters')    
Begin    
        
 update CD SET  CD.Matters = @NewName From common.contactDetails CD    
 Inner Join common.contact C ON C.Id=CD.ContactId  where CD.Matters = @OldName and C.companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'Source')    
Begin    
 update clientcursor.account set Source = @NewName where Source = @OldName and companyid = @Companyid    
    
 update HR.JobApplication set Source = @NewName where Source = @OldName and companyid = @Companyid    
    
END    
    
    
ELSE if(@CategoryName = 'Lead Status')    
Begin    
 update ClientCursor.Account set AccountStatus = @NewName where AccountStatus = @OldName and companyid = @Companyid    
END    
    
    
    
ELSE if(@CategoryName = 'Campaign Type')    
Begin    
 update ClientCursor.Campaign set CampaignType = @NewName where CampaignType = @OldName and companyid = @Companyid    
END    
    
    
    
ELSE if(@CategoryName = 'Designation')    
Begin    
 update ACC SET  ACC.Designation = @NewName From audit.AuditCompanyContact ACC    
 Inner Join common.contact C ON C.Id=ACC.ContactId  where ACC.Designation = @OldName and C.companyid = @Companyid    
    
 update CD SET  CD.Designation = @NewName From common.contactDetails CD    
 Inner Join common.contact C ON C.Id=CD.ContactId  where CD.Designation = @OldName and C.companyid = @Companyid    
    
END    
    
    
ELSE if(@CategoryName = 'Relationship')    
Begin    
 update MA SET MA.RelationShip = @NewName FROM ClientCursor.ManualAssociation MA     
 Inner Join ClientCursor.Account A ON A.Id=MA.FromAccountId  where MA.RelationShip = @OldName and A.CompanyId = @Companyid    
END    
    
ELSE if(@CategoryName = 'Source Type')    
Begin    
 update clientcursor.account set Source = @NewName where Source = @OldName and companyid = @Companyid    
END    
    
ELSE if(@CategoryName = 'IdType')    
Begin    
 update common.idtype set Name = @NewName where Name = @OldName and companyid = @Companyid    
    
 update Common.Employee set IDType = @NewName where IDType = @OldName and companyid = @Companyid    
    
 update HR.JobApplication set IDType = @NewName where IDType = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'Campaign Status')    
Begin    
 update ClientCursor.campaign set CampaignStatus = @NewName where CampaignStatus = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'Opportunity Type')    
Begin    
 update clientcursor.opportunity set Type = @NewName where Type = @OldName and companyid = @Companyid    
END    
    
    
    
ELSE if(@CategoryName = 'Frequency')    
Begin    
 update clientcursor.opportunity set Frequency = @NewName where Frequency = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'Stage')    
Begin    
 update clientcursor.opportunity set Stage = @NewName where Stage = @OldName and companyid = @Companyid    
END    
    
    
--ELSE if(@CategoryName = 'LeadCategory')    
--Begin    
-- update common.communication set Category = @NewName where Category = @OldName and companyid = @Companyid    
--END    
    
    
    
ELSE if(@CategoryName = 'Reminders')    
Begin    
 update ClientCursor.ReminderMaster set ReminderType = @NewName where ReminderType = @OldName and companyid = @Companyid  
 UPdate ClientCursor.Account set Reminders = replace( Reminders ,@OldName,@NewName) from ClientCursor.Account  where  CompanyId = @Companyid  
END    
    
    
ELSE if(@CategoryName = 'ResetLeaveBalance')    
Begin    
 update Common.HRSettings set ResetLeaveBalanceType = @NewName where ResetLeaveBalanceType = @OldName and companyid = @Companyid    
END    
    
ELSE if(@CategoryName = 'Claims Category')    
Begin    
 update Hr.ClaimItem set Category = @NewName where Category = @OldName and companyid = @Companyid    
 update HR.ClaimSetup set Category = @NewName where Category = @OldName and companyid = @Companyid    
     
 update WL SET  WL.Category = @NewName From WorkFlow.Incidental WL    
 Inner Join WorkFlow.IncidentalClaimItem ICI ON ICI.Id=WL.ClaimItemId  where WL.Category = @OldName and ICI.companyid = @Companyid    
    
 update WorkFlow.IncidentalClaimItem set Category = @NewName where Category = @OldName and companyid = @Companyid    
     
END    
    
    
    
    
ELSE if(@CategoryName = 'Short date Format')    
Begin    
 update Common.Localization set ShortDateFormat = @NewName where ShortDateFormat = @OldName and companyid = @Companyid    
END    
    
    
    
ELSE if(@CategoryName = 'Time Format')    
Begin    
 update Common.Localization set TimeFormat = @NewName where TimeFormat = @OldName and companyid = @Companyid    
END    
    
ELSE if(@CategoryName = 'Time Zone')    
Begin    
 update Common.Localization set TimeZone = @NewName where TimeZone = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'VendorType')    
Begin    
     
 update TV SET TV.VendorTypeName = @NewName FROM ClientCursor.VendorTypeVendor TV     
 Inner Join ClientCursor.Vendor V ON V.Id=TV.VendorId  where TV.VendorTypeName = @OldName and V.CompanyId = @Companyid  
 
 Update Bean.Entity set VendorType = @NewName where VendorType = @OldName and Companyid = @Companyid   

 Update HR.PayComponent set DefaultVendor = @NewName where DefaultVendor = @OldName and Companyid = @Companyid    ------parvathi
END    
    
    
---HR    
    
ELSE if(@CategoryName = 'Employee Designation')    
Begin    
 update Common.Department set Name = @NewName where Name = @OldName and companyid = @Companyid    
          
 update TV SET TV.Name = @NewName FROM Common.DepartmentDesignation TV     
 Inner Join Common.Department V ON V.Id=TV.DepartmentId  where TV.Name = @OldName and V.CompanyId = @Companyid      
       
END    
    
ELSE if(@CategoryName = 'Question Category')    
Begin    
 update HR.Question set Category = @NewName where Category = @OldName and companyid = @Companyid    
END    
    
ELSE if(@CategoryName = 'WorkProfile')    
Begin    
 update HR.WorkProfile set TotalWorkingDaysPerWeek = @NewName where TotalWorkingDaysPerWeek = @OldName and companyid = @Companyid    
END    
    
ELSE if(@CategoryName = 'Asset')    
Begin    
 --update HR.Asset set Name = @NewName where Name = @OldName and companyid = @Companyid  
 update HR.AssetSetup set Category = @NewName where Category=@OldName and CompanyId=@Companyid-----------------parvathi
END    
    
ELSE if(@CategoryName = 'Assets')    
Begin    
    
 update AA SET AA.AccountClass = @NewName FROM audit.AdjustmentAccount AA    
                 Inner Join Audit.Adjustment A ON A.Id=AA.AdjustmentID    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=A.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where AA.AccountClass = @OldName and AC.CompanyId = @Companyid    
        
 update audit.LeadSheet set AccountClass = @NewName where AccountClass = @OldName and companyid = @Companyid    
    
    
 update C SET C.AccountClass = @NewName FROM audit.Category C    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=C.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where C.AccountClass = @OldName and AC.CompanyId = @Companyid    
    
  update SC SET SC.AccountClass = @NewName FROM audit.SubCategory SC    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=SC.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where SC.AccountClass = @OldName and AC.CompanyId = @Companyid    
    
  update O SET O.AccountClass = @NewName FROM audit.[order] O    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=O.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where O.AccountClass = @OldName and AC.CompanyId = @Companyid         
    
  update AA SET AA.AccountClass = @NewName FROM audit.AccountAnnotation AA    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=AA.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where AA.AccountClass = @OldName and AC.CompanyId = @Companyid        
END    
    
    
ELSE if(@CategoryName = 'TypeOfEmployment')    
Begin    
 update HR.Employment set TypeOfEmployment = @NewName where TypeOfEmployment = @OldName and companyid = @Companyid    
END    
    
ELSE if(@CategoryName = 'PaymentMode')    
Begin    
 update HR.EmployeePayrollSetting set PayMode = @NewName where PayMode = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'QualificationType')    
Begin    
 update Q SET Q.QuaType = @NewName FROM HR.Qualification Q     
 Inner Join Common.Employee E ON E.Id=Q.EmployeeId  where Q.QuaType = @OldName and E.CompanyId = @Companyid    
    
    
END    
    
    
ELSE if(@CategoryName = 'Relation')    
Begin    
 Update FD SET FD.RelationShip = @NewName From HR.FamilyDetails FD    
 Inner Join Common.Employee E ON E.Id=FD.EmployeeId Where FD.RelationShip = @OldName and E.CompanyId = @Companyid    
END    
    
    
    
    
ELSE if(@CategoryName = 'MaritalStatus')    
Begin    
 update Common.Employee set MaritalStatus = @NewName where MaritalStatus = @OldName and companyid = @Companyid    
    
 update HR.JobApplication set MaritalStatus = @NewName where MaritalStatus = @OldName and companyid = @Companyid    
    
     
END    
    
    
ELSE if(@CategoryName = 'Race')    
Begin    
 update Common.Employee set Race = @NewName where Race = @OldName and companyid = @Companyid    
    
 update HR.JobApplication set Race = @NewName where Race = @OldName and companyid = @Companyid    
    
END    
    
    
    
ELSE if(@CategoryName = 'Period')    
Begin    
 update HR.Employment set ProbationPeriod = @NewName where ProbationPeriod = @OldName and companyid = @Companyid    
 Update HR.Employment Set  Period=REPLACE(Period,@OldName,@NewName) Where CompanyId=@Companyid    
   Update HR.Employment Set ProbationPeriod=REPLACE(ProbationPeriod,@OldName,@NewName) Where CompanyId=@Companyid    
   Update HR.Employment Set NoticePeriod=REPLACE(NoticePeriod,@OldName,@NewName) Where CompanyId=@Companyid    
END    
    
    
ELSE if(@CategoryName = 'Reason For Leaving')    
Begin    
 update HR.Employment set ReasonForLeaving = @NewName where ReasonForLeaving = @OldName and companyid = @Companyid    
END    
    
ELSE if(@CategoryName = 'ApplicationStatus')    
Begin    
 update HR.JobApplication set ApplicationStatus = @NewName where ApplicationStatus = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'AttendanceType')    
Begin    
 --update Common.Attendance set AttendanceType = @NewName where AttendanceType = @OldName and companyid = @Companyid
 update ATD set AttendanceType =@NewName  from Common.AttendanceDetails as ATD join common.Attendance as AT on AT.Id=ATD.AttendenceId where ATD.AttendanceType =@OldName and AT.CompanyId=@Companyid------------parvathi
END    
    
    
    
ELSE if(@CategoryName = 'Tax Classification')    
Begin    
 update HR.PayComponent  set TaxClassification = @NewName where TaxClassification = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'Course Category')    
Begin    
 update HR.CourseLibrary  set CourseCategory = @NewName where CourseCategory = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'Funding')    
Begin    
 update HR.CourseLibrary  set Funding = @NewName where Funding = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'Venue')    
Begin    
 update HR.Training  set Venue = @NewName where Venue = @OldName and companyid = @Companyid    
END    
    
ELSE if(@CategoryName = 'Appraisal Cycle')    
Begin  
update HR.Questionnaire set AppraisalCycle= @NewName where AppraisalCycle = @OldName and CompanyId = @Companyid------parvathi
 update HR.Appraisal  set AppraisalCycle = @NewName where AppraisalCycle = @OldName and companyid = @Companyid    
END    
    
    
    
--Audit    
  
    
ELSE if(@CategoryName = 'EngagementType')    
Begin    
   update ACE SET ACE.EngagementType = @NewName FROM  Audit.AuditCompanyEngagement ACE     
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where ACE.EngagementType = @OldName and AC.CompanyId = @Companyid     
    
   update ACE SET ACE.EngagementType = @NewName FROM  Tax.TaxCompanyEngagement ACE     
                 Inner Join Tax.TaxCompany AC ON AC.Id=ACE.TaxCompanyId      
     where ACE.EngagementType = @OldName and AC.CompanyId = @Companyid     
         
  update Audit.PlanningAndCompletionSetUp  set EngagementType = @NewName where EngagementType = @OldName and companyid = @Companyid           
END    
    
    
ELSE if(@CategoryName = 'EngagementReview')    
Begin    
   update ACE SET ACE.EngagementReviewLevel = @NewName FROM  Audit.AuditCompanyEngagement ACE     
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where ACE.EngagementReviewLevel = @OldName and AC.CompanyId = @Companyid     
    
    
    
END    
    
    
    
    
    
ELSE if(@CategoryName = 'Leadsheet Type')    
Begin    
 update audit.LeadSheet  set LeadsheetType = @NewName where LeadsheetType = @OldName and companyid = @Companyid    
    
    update O SET O.LeadSheetType = @NewName FROM audit.[order] O    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=O.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where O.LeadSheetType = @OldName and AC.CompanyId = @Companyid     
    
     update PMSD SET PMSD.LeadSheeType = @NewName FROM audit.PlanningMaterialitySetupDetail PMSD    
                 Inner Join Audit.PlanningMaterialitySetup PMS ON PMS.Id=PMSD.PlanningMaterialitySetupId     
     where PMSD.LeadSheeType = @OldName and PMS.CompanyId = @Companyid     
    
    
    
        
END    
    
    
    
    
    
    
ELSE if(@CategoryName = 'FEPrimaryParticulars')    
Begin    
    
    update FCAF SET FCAF.Particular = @NewName FROM audit.ForeignCurrencyAnalysisFactors FCAF    
       Inner Join Audit.ForeignCurrencyAnalysis FCA ON FCA.ID=FCAF.FCAnalysisID    
       Inner Join Audit.ForeignExchange FE ON FE.Id=FCA.ForeignExchangeID    
       Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=FE.EngagementID    
       Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId     
        where FCAF.Particular = @OldName and AC.CompanyId = @Companyid     
    
END    
    
    
    
    
    
    
ELSE if(@CategoryName = 'FESecondParticulars')    
Begin    
    
    update FCAF SET FCAF.Particular = @NewName FROM audit.ForeignCurrencyAnalysisFactors FCAF    
       Inner Join Audit.ForeignCurrencyAnalysis FCA ON FCA.ID=FCAF.FCAnalysisID    
       Inner Join Audit.ForeignExchange FE ON FE.Id=FCA.ForeignExchangeID    
       Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=FE.EngagementID    
       Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId     
        where FCAF.Particular = @OldName and AC.CompanyId = @Companyid     
    
END    
    
    
    
ELSE if(@CategoryName = 'Liabilities')    
Begin    
  update AA SET AA.AccountClass = @NewName FROM audit.AdjustmentAccount AA    
                 Inner Join Audit.Adjustment A ON A.Id=AA.AdjustmentID    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=A.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where AA.AccountClass = @OldName and AC.CompanyId = @Companyid    
        
 update audit.LeadSheet set AccountClass = @NewName where AccountClass = @OldName and companyid = @Companyid    
    
    
 update C SET C.AccountClass = @NewName FROM audit.Category C    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=C.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where C.AccountClass = @OldName and AC.CompanyId = @Companyid    
    
  update SC SET SC.AccountClass = @NewName FROM audit.SubCategory SC    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=SC.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where SC.AccountClass = @OldName and AC.CompanyId = @Companyid    
    
  update O SET O.AccountClass = @NewName FROM audit.[order] O    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=O.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where O.AccountClass = @OldName and AC.CompanyId = @Companyid         
    
  update AA SET AA.AccountClass = @NewName FROM audit.AccountAnnotation AA    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=AA.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where AA.AccountClass = @OldName and AC.CompanyId = @Companyid     
END    
    
    
    
ELSE if(@CategoryName = 'Income')    
Begin    
  update AA SET AA.AccountClass = @NewName FROM audit.AdjustmentAccount AA    
                 Inner Join Audit.Adjustment A ON A.Id=AA.AdjustmentID    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=A.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where AA.AccountClass = @OldName and AC.CompanyId = @Companyid    
    
   update audit.LeadSheet set AccountClass = @NewName where AccountClass = @OldName and companyid = @Companyid    
    
   update AA SET AA.AccountClass = @NewName FROM audit.AccountAnnotation AA    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=AA.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where AA.AccountClass = @OldName and AC.CompanyId = @Companyid     
    
      
  update Tax.Classification set AccountClass = @NewName where AccountClass = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'Expenses')    
Begin    
  update AA SET AA.AccountClass = @NewName FROM audit.AdjustmentAccount AA    
                 Inner Join Audit.Adjustment A ON A.Id=AA.AdjustmentID    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=A.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where AA.AccountClass = @OldName and AC.CompanyId = @Companyid    
    
   update audit.LeadSheet set AccountClass = @NewName where AccountClass = @OldName and companyid = @Companyid    
    
   update AA SET AA.AccountClass = @NewName FROM audit.AccountAnnotation AA    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=AA.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where AA.AccountClass = @OldName and AC.CompanyId = @Companyid     
    
      
  update Tax.Classification set AccountClass = @NewName where AccountClass = @OldName and companyid = @Companyid    
END    
    
    
ELSE if(@CategoryName = 'Equity')    
Begin    
  update AA SET AA.AccountClass = @NewName FROM audit.AdjustmentAccount AA    
                 Inner Join Audit.Adjustment A ON A.Id=AA.AdjustmentID    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=A.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where AA.AccountClass = @OldName and AC.CompanyId = @Companyid    
        
 update audit.LeadSheet set AccountClass = @NewName where AccountClass = @OldName and companyid = @Companyid    
    
    
 update C SET C.AccountClass = @NewName FROM audit.Category C    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=C.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where C.AccountClass = @OldName and AC.CompanyId = @Companyid    
    
  update SC SET SC.AccountClass = @NewName FROM audit.SubCategory SC    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=SC.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where SC.AccountClass = @OldName and AC.CompanyId = @Companyid    
    
  update O SET O.AccountClass = @NewName FROM audit.[order] O    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=O.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where O.AccountClass = @OldName and AC.CompanyId = @Companyid         
    
  update AA SET AA.AccountClass = @NewName FROM audit.AccountAnnotation AA    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=AA.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where AA.AccountClass = @OldName and AC.CompanyId = @Companyid     
END    
    
    
    
ELSE if(@CategoryName = 'Materiality Type')    
Begin    
  Update PMSD SET PMSD.Type= @NewName From audit.PlanningMaterialitySetupDetail PMSD     
             Inner Join Audit.PlanningMaterialitySetup PMS ON PMS.Id=PMSD.PlanningMaterialitySetupId    
    where PMSD.Type = @OldName and PMS.CompanyId = @Companyid    
        
  Update PMD SET PMD.Benchmark= @NewName From Audit.PlanningMaterialityDetail PMD     
             Inner Join Audit.PlanningMateriality PM ON PM.Id=PMD.PlanningMeterialityId    
    where PMD.Benchmark = @OldName and PM.CompanyId = @Companyid    
     
          
END    
    
    
ELSE if(@CategoryName = 'Predefined Type')    
Begin    
  Update PMSD SET PMSD.SystemType= @NewName From audit.PlanningMaterialitySetupDetail PMSD     
             Inner Join Audit.PlanningMaterialitySetup PMS ON PMS.Id=PMSD.PlanningMaterialitySetupId    
    where PMSD.SystemType = @OldName and PMS.CompanyId = @Companyid    
        
  Update PMD SET PMD.PreDefine= @NewName From Audit.PlanningMaterialityDetail PMD     
             Inner Join Audit.PlanningMateriality PM ON PM.Id=PMD.PlanningMeterialityId    
    where PMD.PreDefine = @OldName and PM.CompanyId = @Companyid    
     
          
END    
    
    
    
ELSE if(@CategoryName = 'Manual Notes')    
Begin    
  Update DD SET DD.Type= @NewName From Audit.DisclosureDetails DD    
             Inner Join Audit.Disclosure D On D.Id=DD.DisclosureId    
    where DD.Type = @OldName and D.CompanyId = @Companyid    
        
  Update DS SET DS.Type= @NewName From Audit.DisclosureSections DS    
             Inner Join Audit.Disclosure D On D.Id=DS.DisclosureId    
    where DS.Type = @OldName and D.CompanyId = @Companyid    
     
          
END    
    
    
    
    
    
ELSE if(@CategoryName = 'Account Class')    
Begin    
 update AA SET AA.AccountClass = @NewName FROM audit.AdjustmentAccount AA    
                 Inner Join Audit.Adjustment A ON A.Id=AA.AdjustmentID    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=A.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where AA.AccountClass = @OldName and AC.CompanyId = @Companyid    
        
 update audit.LeadSheet set AccountClass = @NewName where AccountClass = @OldName and companyid = @Companyid    
    
    
 update C SET C.AccountClass = @NewName FROM audit.Category C    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=C.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where C.AccountClass = @OldName and AC.CompanyId = @Companyid    
    
  update SC SET SC.AccountClass = @NewName FROM audit.SubCategory SC    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=SC.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where SC.AccountClass = @OldName and AC.CompanyId = @Companyid    
    
  update O SET O.AccountClass = @NewName FROM audit.[order] O    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=O.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where O.AccountClass = @OldName and AC.CompanyId = @Companyid         
    
  update AA SET AA.AccountClass = @NewName FROM audit.AccountAnnotation AA    
                 Inner Join Audit.AuditCompanyEngagement ACE ON ACE.Id=AA.EngagementID    
                 Inner Join Audit.AuditCompany AC ON AC.Id=ACE.AuditCompanyId      
     where AA.AccountClass = @OldName and AC.CompanyId = @Companyid     
END    
    
    
ELSE if(@CategoryName = 'Disclosure Item Description')    
Begin    
 Update Common.[Suggestion ] set ScreenName = @NewName where ScreenName = @OldName and Companyid = @Companyid    
    
END    
    
ELSE if(@CategoryName = 'Disclosure Lable Description')    
Begin    
 Update Common.[Suggestion ] set ScreenName = @NewName where ScreenName = @OldName and Companyid = @Companyid    
    
END    
    
ELSE if(@CategoryName = 'Disclosure Description')    
Begin    
 Update Common.[Suggestion ] set ScreenName = @NewName where ScreenName = @OldName and Companyid = @Companyid    
    
END    
    
ELSE if(@CategoryName = 'Suggestion Screenname')    
Begin    
 Update Common.[Suggestion ] set ScreenName = @NewName where ScreenName = @OldName and Companyid = @Companyid    
    
END    
    
ELSE if(@CategoryName = 'Foreign Exchange Analysis')    
Begin    
 Update Common.[Suggestion ] set ScreenName = @NewName where ScreenName = @OldName and Companyid = @Companyid    
    
END    
    
ELSE if(@CategoryName = 'Functional Currency Analysis')    
Begin    
 Update Common.[Suggestion ] set ScreenName = @NewName where ScreenName = @OldName and Companyid = @Companyid    
    
END    
    
    
ELSE if(@CategoryName = 'Additionallevels')    
Begin    
    
  Update CED SET CED.SignOffLevel = @NewName FROM audit.AuditCompanyEngagementDetails CED    
     Inner Join Audit.AuditCompanyEngagement CE ON CE.Id=CED.AuditCompanyEngagementId    
     Inner Join Audit.AuditCompany C ON C.Id=CE.AuditCompanyId    
     where CED.SignOffLevel = @OldName and C.CompanyId = @Companyid     
    
  Update CED SET CED.SignOffLevel = @NewName FROM TAX.TaxCompanyEngagementDetails CED    
     Inner Join TAX.TAXCompanyEngagement CE ON CE.Id=CED.TAXCompanyEngagementId    
     Inner Join TAX.TAXCompany C ON C.Id=CE.TAXCompanyId    
     where CED.SignOffLevel = @OldName and C.CompanyId = @Companyid     
    
END    
    
    
    
    
    
ELSE if(@CategoryName = 'AuditPrimaryRole')    
Begin    
    
  Update CED SET CED.Role = @NewName FROM audit.AuditCompanyEngagementDetails CED    
     Inner Join Audit.AuditCompanyEngagement CE ON CE.Id=CED.AuditCompanyEngagementId    
     Inner Join Audit.AuditCompany C ON C.Id=CE.AuditCompanyId    
     where CED.Role = @OldName and C.CompanyId = @Companyid     
    
  Update MP SET MP.Role = @NewName FROM audit.AuditMenuPermissions MP    
      Inner Join Audit.AuditCompanyMenuMaster MM ON MM.Id=MP.AuditCompanyMenuMasterId    
       where MP.Role = @OldName and MM.CompanyId = @Companyid     
    
END    
    
    
    
ELSE if(@CategoryName = 'CountryOfOrigin')    
Begin    
 Update audit.AuditCompany set CountryOfIncorporation = @NewName where CountryOfIncorporation = @OldName and Companyid = @Companyid    
    
 Update Tax.TaxCompany set CountryOfIncorporation = @NewName where CountryOfIncorporation = @OldName and Companyid = @Companyid    
     
 Update Boardroom.Genericcontact set CountryOfBirth = @NewName where CountryOfBirth = @OldName and Companyid = @Companyid    
END    
    
    
--Tax    
    
ELSE if(@CategoryName = 'TypeOfEntity')    
Begin    
    
 Update Tax.TaxCompany set TypeOfEntity = @NewName where TypeOfEntity = @OldName and Companyid = @Companyid    
    
END    
    
ELSE if(@CategoryName = 'TaxPrimaryRole')    
Begin    
    
  Update CED SET CED.Role = @NewName FROM TAX.TaxCompanyEngagementDetails CED    
     Inner Join TAX.TAXCompanyEngagement CE ON CE.Id=CED.TAXCompanyEngagementId    
     Inner Join TAX.TAXCompany C ON C.Id=CE.TAXCompanyId    
     where CED.Role = @OldName and C.CompanyId = @Companyid     
    
END    
    
    
    
    
ELSE if(@CategoryName = 'Asset Classification')    
Begin    
    
 Update Tax.SectionA set AssetClassification = @NewName where AssetClassification = @OldName and Companyid = @Companyid    
    
END    
    
    
    
    
ELSE if(@CategoryName = 'Appendix')    
Begin    
    
 Update Tax.AccountAnnotation set ReferScreenName = @NewName where ReferScreenName = @OldName and Companyid = @Companyid    
    
END    
    
    
    
    
    
ELSE if(@CategoryName = 'Appendix-1-Medical Exp')    
Begin    
    
 Update Tax.AccountAnnotation set ReferScreenType = @NewName where ReferScreenType = @OldName and Companyid = @Companyid    
    
END    
    
    
    
    
ELSE if(@CategoryName = 'StatementA')    
Begin    
    
   Update S SET S.FeatureSection = @NewName FROM  Tax.StatementA S    
     Inner Join Tax.TaxCompanyEngagement TE ON TE.Id= S.EngagementId    
     Inner Join Tax.TaxCompany TC On TC.Id=TE.TaxCompanyId    
     where S.FeatureSection = @OldName and TC.CompanyId = @Companyid     
    
         
     
    
END    
    
    
    
    
ELSE if(@CategoryName = 'Appendix-9-PIC Summary')    
Begin    
    
 Update Tax.AccountAnnotation set ReferScreenType = @NewName where ReferScreenType = @OldName and Companyid = @Companyid    
    
END    
    
ELSE if(@CategoryName = 'Appendix-5-Rental Income')    
Begin    
    
 Update Tax.AccountAnnotation set ReferScreenType = @NewName where ReferScreenType = @OldName and Companyid = @Companyid    
    
END    
    
    
    
    
ELSE if(@CategoryName = 'Classification type')    
Begin    
    
 Update Tax.Classification set ClassificationType = @NewName where ClassificationType = @OldName and Companyid = @Companyid    
    
END    
    
    
    
--BR    
    
    
    
    
ELSE if(@CategoryName = 'Gender')    
Begin    
    
 Update Boardroom.Genericcontact set Gender = @NewName where Gender = @OldName and Companyid = @Companyid    
    
END    
    
    
ELSE if(@CategoryName = 'Salutation')    
Begin    
    
 Update Boardroom.Genericcontact set Salutation = @NewName where Salutation = @OldName and Companyid = @Companyid    
    
END    
    
    
    
    
ELSE if(@CategoryName = 'Method of Allotment')    
Begin    
    
   Update A SET A.NatureofAllotment = @NewName FROM Boardroom.Allotment A    
      Inner Join Common.EntityDetail ED ON ED.Id=A.EntityId    
      where A.NatureofAllotment = @OldName and ED.CompanyId = @Companyid     
    
    
    
END    
    
    
ELSE if(@CategoryName = 'Approval Authority')    
Begin    
    
  Update Boardroom.InPrincpialApproval set NameofApprovalAuthority = @NewName where NameofApprovalAuthority = @OldName       
      Update Common.DocRepository set NameofApprovalAuthority = @NewName where NameofApprovalAuthority = @OldName and CompanyId=@Companyid      
    
END    
    
ELSE if(@CategoryName = 'Category')    
Begin    
    
 Update Boardroom.Genericcontact set Category = @NewName where Category = @OldName and Companyid = @Companyid    
    
END    
    
    
    
    
    
ELSE if(@CategoryName = 'Position')    
Begin    
    
 Update Boardroom.GenericContactDesignation set Position = @NewName where Position = @OldName and Companyid = @Companyid    
    
END    
    
    
ELSE if(@CategoryName = 'ID Type')    
Begin    
    
 Update Boardroom.GenericContact set IDType = @NewName where IDType = @OldName and Companyid = @Companyid    
    
END    
    
    
ELSE if(@CategoryName = 'Register')    
Begin    
    
 Update Common.EntityDetail set Register = @NewName where Register = @OldName and Companyid = @Companyid    
    
END    
    
    
ELSE if(@CategoryName = 'Company Type')    
Begin    
    
 Update Common.EntityDetail set CompanyType = @NewName where CompanyType = @OldName and Companyid = @Companyid    
    
 Update BoardRoom.GenericContact set CompanyType = @NewName where CompanyType = @OldName and Companyid = @Companyid    
    
END    
    
    
ELSE if(@CategoryName = 'No. of Hours')      
Begin      
      
 Update Common.EntityDetail set NoOfHours = @NewName where NoOfHours = @OldName and Companyid = @Companyid      
      
  Update BAA SET  BAA.CurrentNofHours = @NewName FROM  Boardroom.AdressesActivity as BAA      
 INNER JOIN Boardroom.Changes as C on BAA.ChangesId=C.Id      
 INNER JOIN Common.EntityDetail as E on C.EntityId=E.Id      
 where BAA.CurrentNofHours=@OldName and E.CompanyId=@Companyid      
       
          
  Update BAA SET  BAA.PraposedNofHours = @NewName FROM  Boardroom.AdressesActivity as BAA      
 INNER JOIN Boardroom.Changes as C on BAA.ChangesId=C.Id      
 INNER JOIN Common.EntityDetail as E on C.EntityId=E.Id      
 where BAA.PraposedNofHours=@OldName and E.CompanyId=@Companyid      
      
      
      
      
      
END    
    
ELSE if(@CategoryName = 'SSIC Code')    
Begin    
    
 Update Boardroom.EntityActivity set PASSICCode = @NewName where PASSICCode = @OldName and Companyid = @Companyid    
    
END    
    
ELSE if(@CategoryName = 'Shares Payable')    
Begin    
    
  Update A SET A.ModeofAllotment = @NewName FROM Boardroom.Allotment A    
      Inner Join Common.EntityDetail ED ON ED.Id=A.EntityId    
      where A.ModeofAllotment = @OldName and ED.CompanyId = @Companyid     
    
END    
    
    
ELSE if(@CategoryName = 'Boardroom ID Type')    
Begin    
    
 Update Boardroom.GenericContact set IDType = @NewName where IDType = @OldName and Companyid = @Companyid    
    
END    
    
    
    
    
ELSE if(@CategoryName = 'BR Address Type')    
Begin    
    
 Update Common.Addresses set AddSectionType = @NewName where AddSectionType = @OldName and Companyid = @Companyid    
    
END    
    
    
    
ELSE if(@CategoryName = 'Suffix')    
Begin    
    
 Update Common.EntityDetail set Suffix = @NewName where Suffix = @OldName and Companyid = @Companyid    
    
END    
    
    
    
    
--ELSE if(@CategoryName = 'Reminder Type')    
--Begin    
    
-- Update Boardroom.AGMDetail set Type = @NewName where Type = @OldName and Companyid = @Companyid    
    
--END    
    
    
    
    
    
ELSE if(@CategoryName = 'Activity')    
Begin    
    
    
 Update FC SET FC.State = @NewName FROM Boardroom.AGMFillingChanges FC    
        Inner Join Boardroom.Changes C ON C.Id=FC.ChangesId    
      where FC.State = @OldName and C.CompanyId = @Companyid     
END    
    
    
    
    
    
    
ELSE if(@CategoryName = 'BR Action')    
Begin    
    
 Update BoardRoom.Changes set Changein = @NewName where Changein = @OldName and Companyid = @Companyid    
    
END    
    
    
ELSE if(@CategoryName = 'BR Category')    
Begin    
    
 Update common.templatesetup set Category = @NewName where Category = @OldName and Companyid = @Companyid    
    
END    
    
    
    
    
    
ELSE if(@CategoryName = 'Nature of Allotment')    
Begin    
    
  Update A SET A.NatureofAllotment = @NewName FROM Boardroom.Allotment A    
      Inner Join Common.EntityDetail ED ON ED.Id=A.EntityId    
      where A.NatureofAllotment = @OldName and ED.CompanyId = @Companyid     
    
END    
    
    
    
    
ELSE if(@CategoryName = 'Share Type')    
Begin    
    
  Update A SET A.Type = @NewName FROM Boardroom.Allotment A    
      Inner Join Common.EntityDetail ED ON ED.Id=A.EntityId    
      where A.Type = @OldName and ED.CompanyId = @Companyid     
    
END    
    
    
    
    
ELSE if(@CategoryName = 'Transaction Type')    
Begin    
    
  Update T SET T.TransactionType = @NewName FROM Boardroom.[Transaction] T    
      Inner Join Boardroom.Allotment A ON A.Id=T.AllotmentId    
      Inner Join Common.EntityDetail ED ON ED.Id=A.EntityId    
      where T.TransactionType = @OldName and ED.CompanyId = @Companyid     
    
END    
    
    
    
    
    
ELSE if(@CategoryName = 'Reason for Cessation')    
Begin    
    
  Update OC SET OC.ReasonForCessation = @NewName FROM Boardroom.OfficerChanges OC    
       Inner Join Boardroom.Changes C ON C.Id=OC.ChangesId    
       Inner Join Common.EntityDetail ED ON ED.Id=C.EntityId    
      where OC.ReasonForCessation = @OldName and ED.CompanyId = @Companyid     
    
END    
    
    
    
ELSE if(@CategoryName = 'Disqualified Reasons')    
Begin    
    
  Update OC SET OC.DisqualifiedReasons = @NewName FROM Boardroom.OfficerChanges OC    
       Inner Join Boardroom.Changes C ON C.Id=OC.ChangesId    
       Inner Join Common.EntityDetail ED ON ED.Id=C.EntityId    
      where OC.DisqualifiedReasons = @OldName and ED.CompanyId = @Companyid     
    
END    
    
    
    
    
    
ELSE if(@CategoryName = 'Mode of Allotment')    
Begin    
    
  Update A SET A.ModeofAllotment = @NewName FROM Boardroom.Allotment A    
      Inner Join Common.EntityDetail ED ON ED.Id=A.EntityId    
      where A.ModeofAllotment = @OldName and ED.CompanyId = @Companyid     
    
END    
    
    
    
    
ELSE if(@CategoryName = 'ShareHolder Type')    
Begin    
    
  Update T SET T.TransactionType = @NewName FROM Boardroom.[Transaction] T    
      Inner Join Boardroom.Allotment A ON A.Id=T.AllotmentId    
      Inner Join Common.EntityDetail ED ON ED.Id=A.EntityId    
      where T.TransactionType = @OldName and ED.CompanyId = @Companyid     
    
END    
    
    
    
ELSE if(@CategoryName = 'Mode')    
Begin    
    
  Update T SET T.ModeOfTransaction = @NewName FROM Boardroom.[Transaction] T    
      Inner Join Boardroom.Allotment A ON A.Id=T.AllotmentId    
      Inner Join Common.EntityDetail ED ON ED.Id=A.EntityId    
      where T.ModeOfTransaction = @OldName and ED.CompanyId = @Companyid     
    
END    
    
    
    
    
ELSE if(@CategoryName = 'Mode Of Alteration')    
Begin    
    
  Update T SET T.TransactionType = @NewName FROM Boardroom.[Transaction] T    
      Inner Join Boardroom.Allotment A ON A.Id=T.AllotmentId    
      Inner Join Common.EntityDetail ED ON ED.Id=A.EntityId    
      where T.TransactionType = @OldName and ED.CompanyId = @Companyid     
    
END    
    
ELSE if(@CategoryName = 'Nature Of Acquisition')    
Begin    
    
  Update T SET T.TransactionType = @NewName FROM Boardroom.[Transaction] T    
      Inner Join Boardroom.Allotment A ON A.Id=T.AllotmentId    
      Inner Join Common.EntityDetail ED ON ED.Id=A.EntityId    
      where T.TransactionType = @OldName and ED.CompanyId = @Companyid     
    
END    
    
    
    
    
    
    
    
    
    
ELSE if(@CategoryName = 'AGM Dates')    
Begin    
    
 Update Boardroom.AGMAndARReminders set CalculationBasedOn = @NewName where CalculationBasedOn = @OldName and Companyid = @Companyid    
    
END    
    
    
    
    
    
    
ELSE if(@CategoryName = 'Officers Changes')    
Begin    
    
 Update BoardRoom.Changes set Changein = @NewName where Changein = @OldName and Companyid = @Companyid    
    
END    
    
    
    
    
ELSE if(@CategoryName = 'Cessation Reason')    
Begin    
    
  Update OC SET OC.ReasonForCessation = @NewName FROM Boardroom.OfficerChanges OC    
       Inner Join Boardroom.Changes C ON C.Id=OC.ChangesId    
       Inner Join Common.EntityDetail ED ON ED.Id=C.EntityId    
      where OC.ReasonForCessation = @OldName and ED.CompanyId = @Companyid     
    
END    
    
    
    
    
    
ELSE if(@CategoryName = 'AGM Changes')    
Begin    
    
 Update BoardRoom.Changes set Changein = @NewName where Changein = @OldName and Companyid = @Companyid    
    
END    
    
    
    
ELSE if(@CategoryName = 'Reason for Extension')    
Begin    
    
 Update BoardRoom.Changes set Changein = @NewName where Changein = @OldName and Companyid = @Companyid    
    
END    
    
    
    
ELSE if(@CategoryName = 'Type of Extension')    
Begin    
    
  Update AC SET AC.TypeOfExtension = @NewName FROM Boardroom.AGMChanges AC     
      Inner Join Boardroom.Changes C ON C.Id=AC.ChangesId    
      where AC.TypeOfExtension = @OldName and C.CompanyId = @Companyid     
    
END    
    
ELSE if(@CategoryName = 'Entity State')    
Begin    
    
 Update Common.EntityDetail set State = @NewName where State = @OldName and Companyid = @Companyid    
    
END    
    
    
    
    
ELSE if(@CategoryName = 'Country')    
Begin    
    
 Update Common.Company set Jurisdiction = @NewName where Jurisdiction = @OldName and Id = @Companyid    
    
END    
    
--Bean    
    
ELSE if(@CategoryName = 'VendorType')    
Begin    
    
 Update Bean.Entity set VendorType = @NewName where VendorType = @OldName and Companyid = @Companyid    
    
END    
    
ELSE if(@CategoryName = 'Cashflow Type')    
Begin    
    
 Update Bean.ChartOfAccount set CashflowType = @NewName where CashflowType = @OldName and Companyid = @Companyid    
    
END    
    
ELSE if(@CategoryName = 'Units')    
Begin    
    
 Update Bean.Item set UOM = @NewName where UOM = @OldName and Companyid = @Companyid    
    
END    
    
    
ELSE if(@CategoryName = 'Nature')    
Begin    
    
 Update Bean.Invoice set Nature = @NewName where Nature = @OldName and Companyid = @Companyid    
    
 Update Bean.DebitNote set Nature = @NewName where Nature = @OldName and Companyid = @Companyid    
    
 Update Bean.Bill set Nature = @NewName where Nature = @OldName and Companyid = @Companyid    
    
 Update Bean.CreditMemo set Nature = @NewName where Nature = @OldName and Companyid = @Companyid    
     
    
END    
    
ELSE if(@CategoryName = 'ModeOfTransfer')    
Begin    
    
 Update Common.TermsOfPayment set Name = @NewName where Name = @OldName and Companyid = @Companyid     
 Update Bean.CashSale set ModeOfReceipt=@NewName where ModeOfReceipt=@OldName and CompanyId=@Companyid    
 Update Bean.Receipt set ModeOfReceipt=@NewName where ModeOfReceipt=@OldName and CompanyId=@Companyid    
 Update Bean.Payment set ModeOfReceipt=@NewName where ModeOfReceipt=@OldName and CompanyId=@Companyid     
 Update Bean.WithDrawal set ModeOfWithDrawal=@NewName where ModeOfWithDrawal=@OldName and CompanyId=@Companyid    
 Update Bean.BankTransfer set ModeOfTransfer=@NewName where ModeOfTransfer=@OldName and CompanyId=@Companyid    
 Update Bean.Receipt set ModeOfReceipt=@NewName where ModeOfReceipt=@OldName and CompanyId=@Companyid    
 Update Bean.Journal set ModeOfReceipt=@NewName where ModeOfReceipt=@OldName and CompanyId=@Companyid    
 ----Update the BRC mode    
 Update BRCD Set BRCD.Mode=@NewName from Bean.BankReconciliation BRC    
Join Bean.BankReconciliationDetail BRCD on BRC.Id=BRCD.BankReconciliationId    
where BRC.CompanyId=@Companyid and Mode=@OldName     
    
END    
    
ELSE if(@CategoryName = 'IdType')    
Begin    
    
 Update Common.IdType set Name = @NewName where Name = @OldName and Companyid = @Companyid    
    
END  


ELSE if(@CategoryName = 'Training Mode')    ---------------------------parvathi
Begin    
    
 Update HR.Training set TrainingMode = @NewName where TrainingMode = @OldName and Companyid = @Companyid    
    
END  

--ELSE if(@CategoryName = 'VendorType')  -----------------------------------parvathi  
--Begin    
    
-- Update HR.PayComponent set DefaultVendor = @NewName where DefaultVendor = @OldName and Companyid = @Companyid    
    
--END  

ELSE if(@CategoryName = 'WorkPassType')  -----------------------------------parvathi  
Begin    
    
 Update common.Employee set WorkPassType = @NewName where WorkPassType = @OldName and Companyid = @Companyid    
    
END  

ELSE if(@CategoryName = 'Audit Manual')    
Begin    
    
 Update Audit.AuditManual set Name = @NewName where Name = @OldName and Companyid = @Companyid    
 Update Audit.FSTemplates set AuditManual = @NewName where AuditManual = @OldName and Companyid = @Companyid   
 Update Audit.LeadSheet set AuditManual = @NewName where AuditManual = @OldName and Companyid = @Companyid  
 Update Audit.LeadSheetSetupMaster set AuditManual = @NewName where AuditManual = @OldName and Companyid = @Companyid   
 Update Audit.PlanningMaterialitySetup set AuditManual = @NewName where AuditManual = @OldName and Companyid = @Companyid   
    
END  

    
    
END    
GO
