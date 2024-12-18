USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FullyInvoicedANDComplete]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





 CREATE  PROCEDURE [dbo].[FullyInvoicedANDComplete]  --Exec FullyInvoicedANDComplete
 AS 
 BEGIN
  Declare @CompanyId int
  Declare @Caseid uniqueidentifier
  Declare @CaseNumber Nvarchar(Max)
  Declare @Stage Nvarchar(Max)
  Declare @CreatedDate datetime2
  Declare @ModifiedDate datetime2
  Declare @ApprovedDate datetime2
  Declare @FullyInvoicedDate datetime2

	   Declare CaseId_Csr Cursor For
       Select Distinct CG.Id,CG.CaseNumber,CG.Stage,cg.CreatedDate,cg.CompanyId,cg.FullyInvoicedDate
       from WorkFlow.CaseGroup CG
       inner Join Workflow.Invoice I on I.CaseId=CG.Id
       where CG.CompanyId=1 and InvoiceState='Fully Invoiced' AND CG.CreatedDate<='2019-12-31' AND I.InvDate<='2019-12-31'
	   and CG.Stage not in ('Complete','Cancelled')
       Order By CG.Stage
    Open CaseId_Csr;
	Fetch Next From Caseid_Csr Into  @Caseid,@CaseNumber,@Stage,@CreatedDate,@CompanyId,@FullyInvoicedDate
	While @@FETCH_STATUS=0
	Begin
	  set @ModifiedDate =(select ModifiedDate from  WorkFlow.CaseStatusChange where CaseId=@Caseid and State=@Stage and CompanyId=@CompanyId)
      if Not Exists ( select Id from WorkFlow.CaseStatusChange where CompanyId=@CompanyId and CaseId=@Caseid and State='Approve')
	  Begin 
          Insert into WorkFlow.CaseStatusChange (Id,CompanyId,CaseId,State,ModifiedBy,ModifiedDate )
	      Values( Newid(),@CompanyId,@Caseid,'Approve','System',DATEADD(HOUR,1,@ModifiedDate))
	      --SELECT  Newid(),@CompanyId,@Caseid,'Approve','System',DATEADD(HOUR,1,@ModifiedDate)
	  END  
	  if Not Exists ( select Id from WorkFlow.CaseStatusChange where CompanyId=@CompanyId and CaseId=@Caseid and State='Complete')
	  Begin 
	      Insert into WorkFlow.CaseStatusChange (Id,CompanyId,CaseId,State,ModifiedBy,ModifiedDate )
	      Values( Newid(),@CompanyId,@Caseid,'Complete','System',DATEADD(HOUR,2,@ModifiedDate))
		  --SELECT  Newid(),@CompanyId,@Caseid,'Complete','System',DATEADD(HOUR,1,@FullyInvoicedDate)
		  end
     if Not Exists ( select Id from WorkFlow.CaseGroup where CompanyId=@CompanyId and Id=@Caseid and Stage='Complete')
	  Begin 
          update WorkFlow.CaseGroup set 
		  --SELECT 
		  Stage='Complete',ModifiedBy='System',
	      ModifiedDate=DATEADD(HOUR,2,@ModifiedDate),ApprovedDate= case when ApprovedDate is null then DATEADD(HOUR,1,@ModifiedDate) else ApprovedDate  end 
	     -- FROM WorkFlow.CaseGroup
		  where CompanyId=@CompanyId and id=@Caseid and Stage=@Stage
      End 
      Fetch Next From CaseId_Csr Into @Caseid,@CaseNumber,@Stage,@CreatedDate,@CompanyId,@FullyInvoicedDate
	End
	Close CaseId_Csr
	Deallocate CaseId_Csr
END 

    --   Select Distinct CG.Id,CG.CaseNumber,CG.Stage,cg.CreatedDate,cg.CompanyId,I.ModifiedDate,CG.FullyInvoicedDate
    --   from WorkFlow.CaseGroup CG
    --   inner Join Workflow.CaseStatusChange I on I.CaseId=CG.Id
    --   where CG.CompanyId=1 and InvoiceState='Fully Invoiced' AND I.State='Complete'
	   --and CG.Stage ='Complete' AND I.ModifiedDate<=CG.FullyInvoicedDate


	   --       Select Distinct CG.Id,CG.CaseNumber,CG.Stage,cg.CreatedDate,cg.CompanyId,CG.ModifiedDate,CG.FullyInvoicedDate
    --   from WorkFlow.CaseGroup CG
    --   where CG.CompanyId=1 and InvoiceState='Fully Invoiced' 
	   --and CG.Stage ='Complete' AND CG.ModifiedDate<=CG.FullyInvoicedDate


	   --          Select Distinct CG.Id,CG.CaseNumber,CG.Stage,cg.CreatedDate,cg.CompanyId,CG.ModifiedDate,CG.FullyInvoicedDate
    --   from WorkFlow.CaseGroup CG
    --   inner Join Workflow.CaseStatusChange I on I.CaseId=CG.Id
    --   where CG.CompanyId=1 and InvoiceState='Fully Invoiced' AND I.State='Complete'
	   --and CG.Stage ='Complete' AND CG.ModifiedDate<>I.ModifiedDate


	   --  update CG set cg.ModifiedDate=DATEADD(HOUR,1,cg.FullyInvoicedDate)
    --   from WorkFlow.CaseGroup CG
    --   where CG.CompanyId=1 and InvoiceState='Fully Invoiced' 
	   --and CG.Stage ='Complete' AND cg.ModifiedDate<=CG.FullyInvoicedDate


	   --     update i set I.ModifiedDate=DATEADD(HOUR,1,cg.FullyInvoicedDate)
    --   from WorkFlow.CaseGroup CG
    --   inner Join Workflow.CaseStatusChange I on I.CaseId=CG.Id
    --   where CG.CompanyId=1 and InvoiceState='Fully Invoiced' AND I.State='Complete'
	   --and CG.Stage ='Complete' AND I.ModifiedDate<=CG.FullyInvoicedDate


	   --Select  count(Distinct cg.id),cg.Stage
    --   from WorkFlow.CaseGroup CG
    --   inner Join Workflow.Invoice I on I.CaseId=CG.Id
    --   where CG.CompanyId=1 and InvoiceState='Fully Invoiced' AND CG.CreatedDate<='2019-12-31' AND I.InvDate<='2019-12-31'
	   --and CG.Stage not in ('Complete','Cancelled')
	   -- group by cg.Stage


		
	   --Select distinct    cg.id,cg.Stage
    --   from WorkFlow.CaseGroup CG
    --   inner Join Workflow.Invoice I on I.CaseId=CG.Id
    --   where CG.CompanyId=1 and InvoiceState='Fully Invoiced' AND CG.CreatedDate<='2019-12-31' AND I.InvDate<='2019-12-31'
	   --and CG.Stage in ('For Approval')


	 --   select * from WorkFlow.CaseStatusChange where caseid in 
		--( '2B98A0DF-6B3B-427C-8664-14E3E518166A',
  --        '2AAF82B2-911E-4538-9ED1-65E93F7B9BBD',
  --        '30390E3C-8FB5-44BE-8B07-FAFE8D63E4A1') order by State
	    


		

 --   select  distinct cg.id,Stage,caseid,state,cg.ModifiedDate,s.ModifiedDate,cg.FullyInvoicedDate,cg.ApprovedDate from  WorkFlow.CaseGroup cg
	--inner join WorkFlow.CaseStatusChange s on s.CaseId=cg.Id
	--where cg.CompanyId=1 and stage='Complete' and cg.Id not in 
	--(
	-- select  distinct  CaseId  from 
 --  (
 --     SELECT caseid,Rank()over(Partition by caseid order by Modifieddate DESC) AS Rank,State
 --     FROM    WorkFlow.CaseStatusChange 
 --     WHERE CompanyId=1 

 --     ) AS H
 --  where rank=1 and state='complete'
 --  )
 --  order by cg.id,s.ModifiedDate
    

		 --select  State,  count( distinct CaseId) count  from 
   --(
   --   SELECT caseid,Rank()over(Partition by caseid order by Modifieddate DESC) AS Rank,State
   --   FROM    WorkFlow.CaseStatusChange 
   --   WHERE CompanyId=1 

   --   ) AS H
   --where rank=1 
   --group by State
   --order by State

   -- select Stage,COUNT(Id) as count from WorkFlow.CaseGroup where CompanyId=1
   --group by Stage
   --order by Stage
GO
