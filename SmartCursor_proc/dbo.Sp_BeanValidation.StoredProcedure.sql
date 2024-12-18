USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_BeanValidation]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


  
  
  
CREATE  Procedure[dbo].[Sp_BeanValidation]   
@CaseId Uniqueidentifier,   
@CompanyId int,  
@InvoiceId Uniqueidentifier  
As  
Begin  
 Declare @ClientId Uniqueidentifier,  
   @serviceId  BigInt,  
   @ServiceCode Nvarchar(500),  
   @Code Nvarchar(500),  
   @Count  Bigint ,  
   @BeanCount Bigint,  
   @CountBean Bigint,  
  
   @Item_Incdtl_Count Int,  
   @WF_Incdtl_Count Int  
  
   set @Count=0  
   Set @BeanCount = 0  
   set @CountBean=0  
  
   Set @WF_Incdtl_Count=(Select Count(Distinct IncidentalType) From WorkFlow.Incidental where InvoiceId=@invoiceid)  
   Set @Item_Incdtl_Count=(select Count(Distinct IncidentalType) from Bean.Item i where i.CompanyId=@CompanyId and i.IsIncidental=1   
   And IncidentalType In (Select distinct IncidentalType From WorkFlow.Incidental where InvoiceId=@invoiceid))  
  
  
  
 Select @ClientId=clientId,@serviceId=serviceid from WorkFlow.caseGroup where Id=@caseId    
 Select @ServiceCode=Code from Common.service where Id=@serviceId  
  
 Select @BeanCount=Count(*) from Bean.entity    where SyncClientId= @ClientId    
 if(@BeanCount=0)  
 Begin  
 update  Bean.entity  set SyncClientId=@ClientId where SyncAccountId=(select Id from ClientCursor.Account where SyncClientId=@ClientId)
   update  workflow.Client  set SyncEntityId= (select Id from  Bean.entity where SyncClientId= @ClientId)
   where SyncAccountId=(select Id from ClientCursor.Account where SyncClientId=@ClientId)
    Select @BeanCount=Count(*) from Bean.entity    where SyncClientId= @ClientId    
	if(@BeanCount=0)  
 Begin  
  THROW 50000,'This client is not present in Bean Entity',1  
 End 
 end
   
 Select @Count= Count(*) from Bean.Item where DocumentId=@serviceId  
 if(@Count=0)  
 Begin  
  THROW 50000,'You should complete the Bean Cursor Settings for this Service',1  
 End     
  
         IF (@Item_Incdtl_Count <>@WF_Incdtl_Count Or @WF_Incdtl_Count IS null)-- or @Inc_COAId is null  
   Begin  
    THROW 50000, 'Selected incidental category type does not exist in the Bean Cursor setup. Please contact the system administrator for assistance.',1  
     
   END  
   END  
  
  
GO
