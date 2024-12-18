USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_Opportunity_Designation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc  [dbo].[Common_Sync_MasterData_Opportunity_Designation]

 

 @CompanyId  Int,
@CaseId uniqueidentifier,
@OpportunityId uniqueidentifier,
@Action Varchar(50)
as 
begin
If(@Action='Add')
begin

 

  INSERT INTO ClientCursor.OpportunityDesignation ( Id, OpportunityId,d.Rate,d.Currency,d.BillingRate,d.BillCurrency,d.EstdHours,d.RecOrder,d.Status,d.Designation,
       d.DepartmentDesignationId)

 

      SELECT NEWID(),@opportunityId,Isnull(DefaultRate,0.0),Currency,BillingRate,BillCurrency,EstdHours,RecOrder,
        Status,Designation,DepartmentDesignationId from WorkFlow.CaseDesignation   WHERE  CaseId=@CaseId 
        
        Update OP   Set OP.fee=CG.Fee,Op.BaseFee=CG.BaseFee from   WorkFlow.CaseGroup  as CG 
        inner join ClientCursor.Opportunity  as OP  on CG.Id=OP.CaseId 
        where  CG.CompanyId=@CompanyId and CG.Id=@CaseId

 

        End
        If(@Action='Edit')
        Begin
               Delete ClientCursor.OpportunityDesignation where OpportunityId=@opportunityId

 

      INSERT INTO ClientCursor.OpportunityDesignation 
      (Id, OpportunityId,d.DefaultRate,d.Currency,d.BillingRate,d.BillCurrency,d.EstdHours,d.RecOrder,d.Status,d.Designation,d.Rate,
       d.DepartmentDesignationId)

 

      SELECT NEWID(),@opportunityId,0.0,Currency,BillingRate,BillCurrency,EstdHours,RecOrder,
        Status,Designation,Isnull(DefaultRate,0.0),DepartmentDesignationId from WorkFlow.CaseDesignation   WHERE  CaseId=@CaseId 

 

        
        Update OP   Set OP.fee=CG.Fee,Op.BaseFee=CG.BaseFee from   WorkFlow.CaseGroup  as CG 
        inner join ClientCursor.Opportunity  as OP  on CG.Id=OP.CaseId 
        where  CG.CompanyId=@CompanyId and CG.Id=@CaseId
        

 

        End

 

        End





GO
