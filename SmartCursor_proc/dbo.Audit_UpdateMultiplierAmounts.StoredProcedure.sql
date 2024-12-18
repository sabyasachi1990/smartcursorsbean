USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_UpdateMultiplierAmounts]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Audit_UpdateMultiplierAmounts](@engagementId Uniqueidentifier,@type Nvarchar(100))  
AS  
BEGIN  
    
    Declare @PYMultiplier decimal(15,2);  
 Declare @CYMultiplier decimal(15,2);  
 declare @interim bit;
  
 set @PYMultiplier=(select PYMultiplier from audit.auditcompanyengagement where id=@engagementId)  
 set @CYMultiplier=(select CYMultiplier from audit.auditcompanyengagement where id=@engagementId)  
 set @interim=(select Interim from audit.auditcompanyengagement where id=@engagementId)  

 IF(@type='Py')  
  Begin  
  update tb set tb.PreviousYearBalance=(tb.ActualPYAmount * @PYMultiplier)  from audit.trialbalanceimport tb join audit.leadsheet ls on  tb.leadsheetid=ls.Id  
  where tb.engagementid=@engagementId and ls.engagementid=@engagementId and   
  (ls.leadsheettype ='Expenses' or ls.leadsheettype ='Income')  
  End  
  
 IF(@type='Cy' and @interim = 0)  
  Begin  
  Update tb  set tb.CYBalance=(tb.ActualCYAmount * @CYMultiplier), tb.PBCBalance=(tb.ActualCYAmount * @CYMultiplier)   
  from audit.trialbalanceimport tb join audit.leadsheet ls on  tb.leadsheetid=ls.Id  
  where tb.engagementid=@engagementId and ls.engagementid=@engagementId and   
  (ls.leadsheettype ='Expenses' or ls.leadsheettype ='Income')  
  End  


 IF(@type='CyPy' and @interim = 0)  
  Begin  
  Update tb  set  
  tb.PreviousYearBalance=(tb.ActualPYAmount * @PYMultiplier),  
  tb.CYBalance=(tb.ActualCYAmount * @CYMultiplier), tb.PBCBalance=(tb.ActualCYAmount * @CYMultiplier)   
  from audit.trialbalanceimport tb join audit.leadsheet ls on  tb.leadsheetid=ls.Id  
  where tb.engagementid=@engagementId and ls.engagementid=@engagementId and   
  (ls.leadsheettype ='Expenses' or ls.leadsheettype ='Income')  
  End 


  IF(@type='Cy' and @interim = 1)  
  Begin  
  Update tb  set tb.InterimMultiplierAmount=(tb.InterimBalance * @CYMultiplier)   
  from audit.trialbalanceimport tb join audit.leadsheet ls on  tb.leadsheetid=ls.Id  
  where tb.engagementid=@engagementId and ls.engagementid=@engagementId and   
  (ls.leadsheettype ='Expenses' or ls.leadsheettype ='Income')  
  End  
 IF(@type='CyPy' and @interim = 1)  
  Begin  
  Update tb  set  
  tb.PreviousYearBalance=(tb.ActualPYAmount * @PYMultiplier),  
   tb.InterimMultiplierAmount=(tb.InterimBalance * @CYMultiplier)   
  from audit.trialbalanceimport tb join audit.leadsheet ls on  tb.leadsheetid=ls.Id  
  where tb.engagementid=@engagementId and ls.engagementid=@engagementId and   
  (ls.leadsheettype ='Expenses' or ls.leadsheettype ='Income')  
  End 
End  
GO
