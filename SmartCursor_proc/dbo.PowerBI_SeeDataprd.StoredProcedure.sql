USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PowerBI_SeeDataprd]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE Procedure [dbo].[PowerBI_SeeDataprd]
  As
  Begin 

  ---  select *  from  [Common].[ReportWorkSpace]

  --update a set a.ReportName='Leads Created' from  [Common].[ReportWorkSpaceDetail] a  where a.id='A62AD8A2-62FA-47DD-87D9-8464A443C6A0'

  --==============[Common].[ReportWorkSpace]

 IF NOT  EXISTS (SELECT TOP 1  ID  FROM   [Common].[ReportWorkSpace] )
 BEGIN

 INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName])
 VALUES (NEWID(), '2778D966-CDB8-498D-8575-FF44EE2EF2E3', 'PRD', 'Audit-PRD')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (Newid(), 'B17FDCE0-7A35-4146-B261-70ABA9C81D28', 'PRD', 'CC-PRD')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (Newid(), 'D8537AB3-F12E-41EE-A42B-CBAF1FA79307', 'PRD', 'WF-PRD')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (Newid(), 'FCEBCB14-AEF3-48FC-BCB7-489925EE177E', 'PRD', 'HR-PRD')


INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (Newid(), '61FA3E07-82F8-4434-A101-E891219A24C1', 'PRD', 'BC-PRD')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName])
 VALUES (Newid(), '2104A816-F47B-4E62-AFA7-F831B8DA018B', 'PRD', 'DrFinance-PRD')

 END

 -- select * from   [Common].[ReportWorkSpaceDetail]


  IF NOT  EXISTS (SELECT TOP 1  ID  FROM   [Common].[ReportWorkSpaceDetail] )
 BEGIN


 ----================================================Client Cursor ============================================
-- --Accounts Inactive
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
-- VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', '5815b3a1-fc28-4b40-a240-b44eb261b8f5', 'Accounts Inactive','d106de47-a8c9-40e0-aaf3-75db5978fb3b', 'PRD')

----Accounts Lost
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
-- VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', '6e8da2fc-64c0-4f98-a775-5b611691cd99', 'Accounts Lost','eb2abd38-5844-449b-bde2-9327e6878e61', 'PRD')

---Accounts Now

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
-- VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', 'a2680d97-4dab-41fe-b56b-a24bc4d4adee', 'Accounts Now','4fed9baa-8d52-4a07-9077-d9eaf178550f', 'PRD')

--Accounts Re-active

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
-- VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', '55c1cd6f-1b50-4c54-9005-578e740904da', 'Accounts Re-active','9875d3a3-00f3-41f9-bac5-bc0fd1052de6', 'PRD')

--Accounts Won

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
-- VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', 'dce57ee5-5560-45b5-9dc8-a02763f3de4e', 'Accounts Won','351f925f-092a-4702-bfd7-ee8aed187e8e', 'PRD')

--Individual leads-Accounts

 --INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', 'b6c0a36e-6da4-4a8a-a3eb-db5a6ce9349f', 'Individual leads-Accounts','77120865-12ba-4242-b200-5a800aa96f84', 'PRD')


--- Leads Creation
 --INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', '19ce994b-39b1-44b1-8d96-5c16c6c9dc7a', 'Leads Created','d7134175-d307-4877-b905-0ed567a0ebf7', 'PRD')


 --Leads Lost

 -- INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625','9305c8e8-7c55-4360-8352-b91514e6504f', 'Leads Lost','35bcfddd-9389-4404-a127-5899cacf4d0e', 'PRD')


 --Leads Now
 --INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625','757c6d6d-fcce-4b91-a917-d90b51d2cd28', 'Leads Now','b923b484-7e23-4359-beba-92b9e1c9cc48', 'PRD')

 --Leads Re-new
 -- INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625','d9456bae-e21d-42f7-a36b-89fea3349c51', 'Leads Re-new','4c0ac9fe-767b-4bba-a9a1-5dd230c557a0', 'PRD')

 ----Leads Won
 --  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625','a781ac12-0b35-4168-99d2-8c8400fdeebd', 'Leads Won','744ea6f6-d910-4076-8774-1cd4905de156', 'PRD')



-- Opportunities Cancelled

 -- INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625','eef0c460-02dd-4a5f-a8d4-818485f30689', 'Opportunities Cancelled','bf0cc21c-b3f8-4b5b-8532-12e97842c332', 'PRD')

 --Opportunities Complete

 -- INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', '4d8f5986-c580-4476-a0fa-aafe57ec715e', 'Opportunities Complete','7fb82d44-d042-4d96-abab-89d6f02ed1fd', 'PRD')


 --Opportunities Created

 --  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', '49b92b10-9a35-4584-9958-94d8b24b1abe', 'Opportunities Created','afbd40f9-d254-44a1-a977-4b45af42353e', 'PRD')


 --Opportunities Lost

 --   INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', '9935410c-7510-4509-b9a6-2fc864be5cc3', 'Opportunities Lost','77eda0f7-7b05-4de4-8e96-5345129ba57b', 'PRD')

 --Opportunities Now
 
 --   INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', 'd6cfed78-56c4-4fe1-bc8e-15d68c1096b0', 'Opportunities Now','47ab4b0c-3712-45ac-ae55-769753591cbb', 'PRD')

 ---Opportunities Pending

 --    INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', '46ed6268-a22c-46c2-aefe-a14720e17a4d', 'Opportunities Pending','ec793508-4743-4fbe-a117-90cd67e90ca5', 'PRD')

 --Opportunities Recurring

 -- INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', '6f14d851-2165-48db-b118-21601cba6ee3', 'Opportunities Recurring','3151436a-189c-409d-8bed-e0ccd9da6579', 'PRD')

 --Opportunities Won

 --  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 --VALUES (NEWID(), '95B0B4C2-70FD-47F8-A7EC-7A47A2F5F625', '06c730ae-b198-4fbc-b10e-51cfeab66f44', 'Opportunities Won','0021edb8-2d1b-4e3a-9279-e1092b640e2a', 'PRD')


 --======================= ===================== WorkFlow cursors ======================================
-- Cases Approved
 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'a21915c1-37b1-4ab5-9d26-875541fd9d76', 'Cases Approved','66f4e376-3f12-403d-8b94-7052a1b6bf3f', 'PRD')

 --Cases Cancelled
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '807ced92-74e0-4028-8c56-7e88ee971d95', 'Cases Cancelled', 'd72653a1-bbb7-435d-a090-e0a8a0be9618', 'PRD')

 --Cases Completed
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '3bece52d-f7f9-490c-b3b4-0daf6896b420', 'Cases Completed', 'da142ab9-e15e-464a-8ba5-fb2f7ee5f6d8', 'PRD')

--Cases Created
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'ec3eb267-4069-41b1-bb63-22f6b90a8cab', 'Cases Created', '04005f92-3fa6-44dd-8693-4152f2ae590d', 'PRD')

--Cases For Approval
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '4c83d1af-ae6c-4b82-b4a8-df2675c8f7c6', 'Cases For Approval', '3fb2e11f-9ac1-48b7-9912-f779416976ab', 'PRD')

 --Cases On Hold
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'a210c87d-ed27-4417-a475-0e4b206fb903', 'Cases On Hold', '315a4491-b12a-496a-bf52-781c4abb48d4', 'PRD')

--Cases Unassigned
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '38eb65df-3e11-4351-8b8f-175adb767dfb','Cases Unassigned', '2ac38b79-0256-4367-98ca-cb22fe190275', 'PRD')

----Chargeability
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
--VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'bfb0f51b-e5af-44c7-bc13-8023847bdfb9', 'Chargeability', '9d773199-b7cb-44ec-ba90-8af43802870a', 'PRD')


--Clients Created

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '2d04025c-dc97-4c0b-a2be-bfede9c148b8', 'Clients Created', '9fa979fd-6372-4399-b192-8d0b52c73871', 'PRD')

--Clients Inactive
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '68425a64-e477-4e01-9b4e-3a481b8de58d', 'Clients Inactive', 'e330d29c-d7bb-4f7d-ba33-8e3a626bd99d', 'PRD')


-- --Clients Now
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
-- VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '775a4671-421d-47b9-81f5-6d4d70fd7971', 'Clients Now', '281cb620-2f12-4c35-b10c-649c54215d7a', 'PRD')

 --Clients Re-active
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'b8fdb813-aef5-4a88-b695-08bf13bfebbf', 'Clients Re-active', 'b9430300-468d-4b59-ba1f-a49d6f53d415', 'PRD')

-- --Contribution
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
--VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '293b8b9c-0714-44fe-9cde-fb46ebb41e89', 'Contribution', 'ddb8695c-4e78-4c7c-9536-99ba70bcbf15', 'PRD')

----Actual Contribution
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
--VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'e305e7f1-63e0-45f1-bc5c-0ad3f1dd6c33', 'Actual Contribution', 'ba2d15de-b952-4682-a26a-d7ddc57e676e', 'PRD')

----Planned Contribution
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
--VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '79295186-aa90-46fb-985f-6ea695738b1f', 'Planned Contribution', 'd7fb79da-2e48-4c1b-ba3c-01e33a70738b', 'PRD')

----Incidental Tracker
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
--VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '793a80bb-1bb9-4299-a353-1179f719d318', 'Incidental Tracker', '5a5838a0-a1fb-47b2-bf4f-767d5fa076d2', 'PRD')

--Individual Case
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '9a096f21-f890-45ab-b9de-9a4d6b1fd71b', 'Individual Case', 'af5e92a4-641c-4837-93eb-ea4bbfbe4966', 'PRD')

--Individual Client
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'f2761d62-3e6e-433c-8d86-180a1e6cab62', 'Individual Client', '3a7641b4-636c-431f-bb30-01cc713a2725', 'PRD')

----Invoices Generated
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
--VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '7ba45567-b52a-44b2-8897-85d0b052f33a', 'Invoices Generated', 'd2086e62-7d90-446c-a47d-432522428efe', 'PRD')

----Invoices Not Generated
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
--VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '68572e23-1026-4edb-9145-d7ea5e6ef4e3', 'Invoices Not Generated', '10d73cf9-423c-448f-88a1-55b73fe00989', 'PRD')

----Planned Chargeability
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
--VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '79295186-aa90-46fb-985f-6ea695738b1f', 'Planned Chargeability', 'd7fb79da-2e48-4c1b-ba3c-01e33a70738b', 'PRD')

----Recovery
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
--VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '7371c0c4-087a-42f1-bd61-a292d029ef5d', 'Recovery', '5668bff4-ee79-479b-a1dc-34cd5afc1268', 'PRD')

----Unpaid Amount
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
--VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'dac5a5ad-c5b0-4ba1-8b33-0a8ec178ac6b', 'Unpaid Amount', '8938f487-5cb9-417b-bbd5-37a9d3fb4239', 'PRD')

--=========================== HR
--Attendance
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), 'B08CBD23-8047-42B3-9158-998A54A55D21', '9f54c04e-ba38-4081-ac58-890ab94faaeb', 'Attendance', '7ddf4354-9762-476f-b9d5-4fbf8d75343b', 'PRD')

--Claims
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), 'B08CBD23-8047-42B3-9158-998A54A55D21', 'ad5b0a40-c6da-4f98-b20d-8195dd1267fd', 'Claims', 'c948d658-0155-4a5a-be60-976723de31ca', 'PRD')

--Leaves
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), 'B08CBD23-8047-42B3-9158-998A54A55D21', '996c998f-c8dc-48fe-88d6-e6de4e75ee7f', 'Leaves', '886c21e7-687f-442d-b264-f55edf08ab14', 'PRD')

--Payroll
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), 'B08CBD23-8047-42B3-9158-998A54A55D21', '2f1508ad-d190-40eb-bad7-dee10fd2fea5', 'Payroll', '0a050b33-6333-4576-b86d-b6b8896059bd', 'PRD')

--Recruitment
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), 'B08CBD23-8047-42B3-9158-998A54A55D21', 'b8ff88a7-cb59-4f9c-82ba-50b829e7fd33', 'Recruitment', '9421fa50-68fe-464c-975e-e9c0cd58f4d5', 'PRD')

--Training
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), 'B08CBD23-8047-42B3-9158-998A54A55D21', 'f2885eee-2f26-44d8-8228-3fadcae5adc4', 'Training', 'abe793fa-24d2-4376-ab0c-e51f7d0a94e4', 'PRD')

-- ===================================Bean 
--Bank
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '25BF80DF-AE93-4B66-B837-AFC870A58F20', 'c1395a9b-fb60-4d1c-9270-f36e4e7bb145', 'Bank', 'a609f1d9-4686-4546-b1aa-8a162b75c2ca', 'PRD')

--Customer
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '25BF80DF-AE93-4B66-B837-AFC870A58F20', 'bd5d9060-7f35-45c8-a94b-a7e2b0342665', 'Customer', '326505de-3d91-4b68-be4b-340618575ab9', 'PRD')

--Customer Aging
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '25BF80DF-AE93-4B66-B837-AFC870A58F20', 'd0f1243d-5ce0-4ef4-ad5c-4c493c0ad895', 'Customer Aging', '5cd93e43-ce41-4a45-a9c5-13ddf4cbfd27', 'PRD')

--Finance
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '25BF80DF-AE93-4B66-B837-AFC870A58F20', '2c89913a-9f75-4412-b73b-5a33d3f3bad0', 'Finance', 'c9922363-e861-4d62-a93d-b68c9a01efaf', 'PRD')

--Vendor Aging
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '25BF80DF-AE93-4B66-B837-AFC870A58F20', '09bd05e5-7fa1-4b1b-ad04-bcadcce07a09', 'Vendor Aging', '7b7050e7-3b6b-4295-b356-64d72ce7520e', 'PRD')

--Vendor BillPayments
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '25BF80DF-AE93-4B66-B837-AFC870A58F20', '4f3e9944-0ad4-455b-b411-c88f20ec5aee', 'Vendor BillPayments', '864ed8c2-7685-4d0f-bf86-a0eb373b074f', 'PRD')


--======================='DrFinance-PRD'

--Asset Analysis
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', '46716820-0e7d-4de2-bcab-a54d8df494c1', 'Asset Analysis','ee570978-0ef6-4aef-a330-cfdb2baf08e3', 'PRD')

 --Debt Analysis
 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'dd7ce60a-cc18-4e6b-a5bc-261593af6050', 'Debt Analysis','aa2574f6-da9d-47a1-a96f-645a831f2cae', 'PRD')


 --Expense Analysis
  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'dd7ce60a-cc18-4e6b-a5bc-261593af6050', 'Expense Analysis','c12fb110-0b95-4bac-80f9-af793b20ea09', 'PRD')

 --Growth Analysis
  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'd707317e-29b9-4675-acef-e855e768f08d', 'Growth Analysis','bde00edd-cf65-4a2b-9e4b-ff1baf93b5c4', 'PRD')

 --Summary Ratios
 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'a5a2263a-628a-40ac-a988-fcd8107196eb', 'Summary Ratios', '33f3da85-4fb8-4911-bccd-60263e6a3980', 'PRD')

--Revenue Analysis
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'f2ac2628-2172-4ad2-90e3-db6c9c933a10', 'Revenue Analysis', 'a0924a17-feb4-480b-ba87-27af6fee66c1', 'PRD')

--Profitability Analysis
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'c35fa27a-f0ee-4604-94c5-71a4c1fc8ad2', 'Profitability Analysis', '16edefd1-41fb-49ad-a385-f7f48ef2c414', 'PRD')

--Operating Cash flow Analysis
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'f139e320-a0cf-4f2c-8366-42b45645fda4', 'Operating Cash flow Analysis', '91b8443f-414c-4f9f-b79b-0fcf10f48b2b', 'PRD')

--Liquidity Analysis
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', '1d0fba4b-d5b3-4f25-b971-9e085561c13a', 'Liquidity Analysis', '1d627bbc-661e-4c1a-867e-34d9767f94ca', 'PRD')

END 

End 








GO
