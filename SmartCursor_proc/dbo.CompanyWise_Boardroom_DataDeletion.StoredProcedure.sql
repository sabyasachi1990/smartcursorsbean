USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[CompanyWise_Boardroom_DataDeletion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[CompanyWise_Boardroom_DataDeletion]
@CompanyId Int

AS
BEGIN

DECLARE @CompanyInfo TABLE (Id Int, RegistrationNo Nvarchar(150), Name Nvarchar(500))

INSERT INTO @CompanyInfo
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE Id = @CompanyId
UNION ALL
SELECT Id,RegistrationNo,Name FROM Common.Company WHERE ParentId = @CompanyId

----------------------==================================================================================================================================================================================================
----------------------/////////////////////////////////////////////////////////////////////////////// BOARDROOM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-----------------------==================================================================================================================================================================================================

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.AGMAndARReminders \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.AGMAndARRemindersTemplates WHERE AGMAndARRemindersId IN
(
SELECT Id FROM Boardroom.AGMAndARReminders WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.Remindersent WHERE ReminderId IN
(
SELECT Id FROM Boardroom.AGMAndARReminders WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.AGMAndARReminders WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.AGMReminder \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------------SELECT * FROM Boardroom.AGMReminder WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ------> No Data in Table

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.BRAGM \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.BRAGM WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.Changes \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.ActivityChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.AdressesActivity WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.AGMChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.AGMFillingChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.EntityChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.FYEChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.GenerateTemplate WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.InCharge WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.ChangesAppointmentDetails WHERE OfficerChangesId IN
(
SELECT Id FROM Boardroom.OfficerChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.OfficerChanges WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.SharesCurrentDetails WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.TransactionLog WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.[Transaction] WHERE ChangesId IN
(
SELECT Id FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.Changes WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.Charge \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.Charge WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.CompanyType \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.CompanyTypeSuffix WHERE CompanyTypeId IN
(
SELECT Id FROM Boardroom.CompanyType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.CompanyType WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.Contacts \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.AllotmentDetails WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.ChangesAppointmentDetails WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.ContactCommencementDetails WHERE DesignationId IN
(
SELECT Id FROM Boardroom.GenericContactDesignation WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.GenericContactDesignation WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.SharesCurrentDetails WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.TransactionLog WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.[Transaction] WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.TransactionLog WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.Contacts WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.EntityActivity \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.ActivityChanges WHERE EntityActivityId IN
(
SELECT Id FROM Boardroom.EntityActivity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.ActivityHistory WHERE EntityActivityId IN
(
SELECT Id FROM Boardroom.EntityActivity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.PricipalApprovalDetail WHERE EntityActivityId IN
(
SELECT Id FROM Boardroom.EntityActivity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.EntityActivity WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.GenericContact \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.AGMSignatory WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.AllotmentDetails WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.ChangesAppointmentDetails WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.GenericContactDesignation WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.SharesCurrentDetails WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Boardroom.TransactionLog WHERE TransactionId IN
(
SELECT Id FROM Boardroom.[Transaction] WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)
)

DELETE FROM Boardroom.[Transaction] WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.TransactionLog WHERE ContactId IN
(
SELECT Id FROM Boardroom.Contacts WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.Contacts WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.ContactCommencementDetails WHERE DesignationId IN
(
SELECT Id FROM Boardroom.GenericContactDesignation WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.GenericContactDesignation WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.GenericShareholderContact WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.ChangesAppointmentDetails WHERE OfficerChangesId IN
(
SELECT Id FROM Boardroom.OfficerChanges WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)
)

DELETE FROM Boardroom.OfficerChanges WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.SharesDetail WHERE GenericContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.Signatory WHERE ContactId IN
(
SELECT Id FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.GenericContact WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.GenericContactDesignation \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.ContactCommencementDetails WHERE DesignationId IN
(
SELECT Id FROM Boardroom.GenericContactDesignation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.GenericContactDesignation WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) 

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.Remindersent \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.Remindersent WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.Shares \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------SELECT * FROM Boardroom.Shares WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ----> No Data in Table

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.Signatory \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

----------SELECT * FROM Boardroom.Signatory WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo) ----> No Data in Table

--------------------//////////////////////////////////////////////////////////////////////// Boardroom.Suffix \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

DELETE FROM Boardroom.CompanyTypeSuffix WHERE SuffixId IN
(
SELECT Id FROM Boardroom.Suffix WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)
)

DELETE FROM Boardroom.Suffix WHERE CompanyId  IN (SELECT Id FROM @CompanyInfo)

END

GO
