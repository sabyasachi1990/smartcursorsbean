USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_DATAMASKING_STAGING_Functions]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[SP_DATAMASKING_STAGING_Functions]

As
Begin

-- Exec [dbo].[SP_DATAMASKING_STAGING_Functions]

------===========Notification.[NotificationSettings] ------[OtherRecipients]=========================

Select t.id,fn.data,OtherRecipients,LEFT(fn.data,CHARINDEX('@',fn.data))+'smartcursors.org' as OtherRecipients_New
into #Temp_OtherRecipients_New 
from 
Notification.[NotificationSettings] t
cross apply sample_split(t.OtherRecipients,',') fn 

-- Table 

Create table Temp1_OtherRecipients_New(id uniqueidentifier,OtherRecipients_New nvarchar(max))


Insert into Temp1_OtherRecipients_New
select * from 
(
SELECT id,OtherRecipients_New = 
    STUFF((SELECT DISTINCT ', ' + OtherRecipients_New
           FROM #Temp_OtherRecipients_New   b 
           WHERE b.id = a.id 
          FOR XML PATH('')), 1, 2, '')
FROM #Temp_OtherRecipients_New   a
where OtherRecipients<>'' 
GROUP BY id
)as AA

------===========Notification.[NotificationSettings] ------[OtherEmailRecipient]=========================

select t.id,fn.data,OtherEmailRecipient,LEFT(fn.data,CHARINDEX('@',fn.data))+'smartcursors.org' as OtherEmailRecipient_New
into #Temp_OtherEmailRecipient_New 
from 
Notification.[NotificationSettings] t
cross apply sample_split(t.OtherEmailRecipient,';') fn 


Create table Temp1_OtherEmailRecipient_New(id uniqueidentifier,OtherEmailRecipient_New nvarchar(max))


Insert into Temp1_OtherEmailRecipient_New
select * from 
(
SELECT id,OtherEmailRecipient_New = 
    STUFF((SELECT DISTINCT '; ' + OtherEmailRecipient_New
           FROM #Temp_OtherEmailRecipient_New   b 
           WHERE b.id = a.id 
          FOR XML PATH('')), 1, 2, '')

FROM #Temp_OtherEmailRecipient_New   a
where OtherEmailRecipient_New<>'' 
GROUP BY id
)as AA

------==================---Common.[Communication]--CMail----------=============================================


select t.id,fn.data,CCMail,LEFT(fn.data,CHARINDEX('@',fn.data))+'smartcursors.org' as CCMail_New
into #Temp_CCMail_New 
from Common.[Communication]t
cross apply sample_split(t.CCMail,';') fn 


Create table Temp1_CCMaill_New(id uniqueidentifier,CCMail_New nvarchar(max))

Insert into Temp1_CCMaill_New
select * from 
(
SELECT id,CCMail_New = 
    STUFF((SELECT DISTINCT '; ' + CCMail_New
           FROM #Temp_CCMail_New    b 
           WHERE b.id = a.id 
          FOR XML PATH('')), 1, 2, '')
FROM #Temp_CCMail_New    a
where CCMail_New<>'' 
GROUP BY id
)as AA


------==================---Common.[ReminderBatchList] --Recipient ----------=============================================


select t.id,fn.data,Recipient,LEFT(fn.data,CHARINDEX('@',fn.data))+'smartcursors.org' as Recipient_New
into #Temp_Recipient_New 
from Common.[ReminderBatchList]  t
cross apply sample_split(t.Recipient,',') fn 


Create table Temp1_Recipient_New(id uniqueidentifier,Recipient_New nvarchar(max))

Insert into Temp1_Recipient_New
select * from 
(
SELECT id,Recipient_New = 
    STUFF((SELECT DISTINCT ', ' + Recipient_New
           FROM #Temp_Recipient_New   b 
           WHERE b.id = a.id 
          FOR XML PATH('')), 1, 2, '')
FROM #Temp_Recipient_New   a
where Recipient_New<>'' 
GROUP BY id
)as AA


End
GO
