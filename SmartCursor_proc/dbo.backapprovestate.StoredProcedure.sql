USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[backapprovestate]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
 CREATE procedure  [dbo].[backapprovestate]
  as
   begin 
 --====1st one 
 ----------
   
--   update a set stage='Approve',ModifiedDate=ApprovedDate from  WorkFlow.CaseGroup a where CompanyId=1
--	 --update a set stage='complete',ModifiedDate=dateadd(hour,1,FullyInvoicedDate) from  WorkFlow.CaseGroup a where CompanyId=1
--    --select *from  WorkFlow.CaseGroup where CompanyId=1
--  and CaseNumber in 
--  (
--'CE-AUDSTA-2019-04246',
--'CE-AUDSTA-2019-04243',
--'CE-AUDSTA-2019-04084',
--'CE-AUDSTA-2019-04969',
--'CE-ACCAAA-2019-05252',
--'CE-PYRCPL-2019-05218',
----'CE-ACCACT-2019-05015',
--'CE-AUDSTA-2019-04809',
--'CE-AUDSTA-2019-04499'
--  ) and  Stage='complete'


--   delete  from WorkFlow.CaseStatusChange where CompanyId=1
---- select * from  WorkFlow.CaseStatusChange where CompanyId=1
--  and caseid in 
-- (
--'B087D366-EF13-4E02-814F-055BB2D60C7F',
--'798C55D7-1269-4135-AD43-3EAAB6D08B23',
--'BF59E2CC-DC51-429B-BB5C-40FECA56096F',
--'51D0F131-7B55-40C0-A899-4F585FFCC8B5',
--'80BF3576-0003-48B4-9C3B-683EF06DBC60',
--'5F4E7CC3-CA34-417B-857A-6C16E75521A5',
--'0E2F8D43-1FD5-4F7F-A847-6E87443319BD',
--'01A4BEE0-4D6B-421D-B470-9D67C03063D0'
----'6A5055CC-DA49-4F47-8D29-DF85A818D278'
 
-- )
-- and id in 
-- (
--'D29FF478-D663-4418-8216-5D0E80C677CF',
--'086F1E0C-1B41-4DA4-890A-803BC6447302',
--'17C3B57C-A150-452E-8277-D2832E664B97',
--'FB4E475C-12CD-4A12-9015-BD5CFB8C6F96',
--'FBDFE770-ED83-424B-ADF0-D74C25C65BAD',
--'CC79F92C-E944-4D67-A423-854C801E4913',
--'955506CC-4918-454F-A7FC-CCB6992E4032',
--'47719E4E-DE0D-4775-AD6E-0785B2F81319'
-- ) and 
-- State='complete'
    
------============2nd 


--     update a set stage='Approve',ModifiedDate='2019-10-31 09:43:53.5286651', ApprovedDate='2019-10-31 09:43:53.5286651',ModifiedBy='System' from  WorkFlow.CaseGroup a where CompanyId=1
--	 --update a set stage='complete',ModifiedDate=dateadd(hour,1,FullyInvoicedDate) from  WorkFlow.CaseGroup a where CompanyId=1
--    --select *from  WorkFlow.CaseGroup where CompanyId=1
--  and CaseNumber in 
--  (

--'CE-ACCACT-2019-05015'

--  )



--    insert into WorkFlow.CaseStatusChange
--      select newid(),CompanyId,id,'Approve','System','2019-10-31 09:43:53.5286651'from  WorkFlow.CaseGroup where CompanyId=1
--  and CaseNumber in 
--  (
--'CE-ACCACT-2019-05015'

--  )




   
   --update a set stage='Approve',ModifiedDate=ApprovedDate from  WorkFlow.CaseGroup a where CompanyId=1
	 --update a set stage='complete',ModifiedDate=dateadd(hour,1,FullyInvoicedDate) from  WorkFlow.CaseGroup a where CompanyId=1
    select *from  WorkFlow.CaseGroup where CompanyId=1
  and CaseNumber in 
  (
'CE-AUDSTA-2019-04246',
'CE-AUDSTA-2019-04243',
'CE-AUDSTA-2019-04084',
'CE-AUDSTA-2019-04969',
'CE-ACCAAA-2019-05252',
'CE-PYRCPL-2019-05218',
'CE-ACCACT-2019-05015',
'CE-AUDSTA-2019-04809',
'CE-AUDSTA-2019-04499'
  )


    -- insert into WorkFlow.CaseStatusChange

    --select * from  WorkFlow.CaseStatusChange where caseid='6A5055CC-DA49-4F47-8D29-DF85A818D278'
    select newid(),CompanyId,id,'complete','System',dateadd(hour,1,FullyInvoicedDate) from  WorkFlow.CaseGroup where CompanyId=1
  and CaseNumber in 
  (
'CE-AUDSTA-2019-04246',
'CE-AUDSTA-2019-04243',
'CE-AUDSTA-2019-04084',
'CE-AUDSTA-2019-04969',
'CE-ACCAAA-2019-05252',
'CE-PYRCPL-2019-05218',
'CE-ACCACT-2019-05015',
'CE-AUDSTA-2019-04809',
'CE-AUDSTA-2019-04499'
  )


        Select Distinct CG.Id,CG.CaseNumber,CG.Stage,cg.CreatedDate,cg.CompanyId
       from WorkFlow.CaseGroup CG
       Join WorkFlow.Client C on C.Id=CG.ClientId
       inner Join Workflow.Invoice I on I.CaseId=CG.Id
       where CG.CompanyId=1 and InvoiceState='Fully Invoiced' and CG.CreatedDate <= '2019-12-31'
       and I.InvDate <= '2019-12-31' and CG.Stage not in ('Complete')
   -- and cg.id in ('1C252DE8-224A-4803-9868-FECE25090873','1D4BE77B-4808-4BE8-BEBE-00A62FE274B6')
       Order By CG.Stage







	   Select Distinct CG.Id,CG.CaseNumber,CG.Stage,cg.CreatedDate,cg.CompanyId,FullyInvoicedDate,cg.ModifiedDate,h.ModifiedDate
       from WorkFlow.CaseGroup CG
	   inner join WorkFlow.CaseStatusChange h on h.CaseId=cg.Id
       Join WorkFlow.Client C on C.Id=CG.ClientId
       inner Join Workflow.Invoice I on I.CaseId=CG.Id
       where CG.CompanyId=1 and InvoiceState='Fully Invoiced' and CG.CreatedDate <= '2019-12-31'
       and I.InvDate <= '2019-12-31' and CG.Stage ='complete' and h.State='complete'
       and h.ModifiedDate<=cg.FullyInvoicedDate
       Order By CG.Stage










  end 



  --select * from  WorkFlow.CaseStatusChange where caseid='6A5055CC-DA49-4F47-8D29-DF85A818D278'
  -- select * from WorkFlow.CaseGroup where id='6A5055CC-DA49-4F47-8D29-DF85A818D278'
GO
