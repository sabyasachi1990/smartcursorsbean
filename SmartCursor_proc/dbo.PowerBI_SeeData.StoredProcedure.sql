USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PowerBI_SeeData]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE Procedure [dbo].[PowerBI_SeeData]
  As
  Begin 

  --- DELETE FROM [Common].[ReportWorkSpace]

  --==============[Common].[ReportWorkSpace]

 IF NOT  EXISTS (SELECT TOP 1  ID  FROM   [Common].[ReportWorkSpace] )
 BEGIN

 INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName])
 VALUES (NEWID(), '98f41d71-cdfa-41f2-945d-a0abde778f90', 'TST', 'Audit-TST')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (Newid(), '9c3fe0b4-a3f1-45b1-86cd-5a949aa73e64', 'TST', 'CC-TST')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (Newid(), '82313541-1e1d-4239-9910-b8abcf61b6ac', 'TST', 'WF-TST')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (Newid(), '9ec24ba2-3ea2-41bf-ae97-10fe8ee0bcf8', 'TST', 'HR-TST')


INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (Newid(), '690ccc3f-7cd8-440e-ba62-cf9adb71e9ba', 'TST', 'BC-TST')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName])
 VALUES (Newid(), '793f9874-64c0-4c3e-8141-d5d888f8adf8', 'TST', 'DrFinance-TST')

 END

 --DELETE [Common].[ReportWorkSpaceDetail]


  IF NOT  EXISTS (SELECT TOP 1  ID  FROM   [Common].[ReportWorkSpaceDetail] )
 BEGIN


 ----================================================Client Cursor ============================================
 --Accounts Inactive
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', '44fd115d-049e-4a95-9ee8-bc8dca9ff8b3', 'Accounts Inactive','81a2f71e-554f-4d51-a8ec-360288cf923a', 'TST')

--Accounts Lost
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', 'be0b9834-8ecc-4c04-a039-f7a3f32f1af1', 'Accounts Lost','1d0feddc-02e2-4183-a302-b4e1808de4cd', 'TST')

---Accounts Now

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', 'a5607ad6-4508-4b80-9c97-a3ef0b03a297', 'Accounts Now','ceb6c6fb-6a89-47eb-a7c9-64af356d2aec', 'TST')

--Accounts Re-active

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', '97c0f0b0-7386-4770-ad86-7199433ce193', 'Accounts Re-active','cfa7eee9-2b84-4777-bb70-57600dbcd256', 'TST')

--Accounts Won

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', '4f4d56ae-819d-4aab-be4c-b918c2d569d5', 'Accounts Won','bbb2f5bb-a144-4942-b470-1791bebe82c0', 'TST')

--Individual leads-Accounts

 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', '2f6cc841-72c1-4167-ac78-a291a6edb4fc', 'Individual leads-Accounts','4ae24e52-1656-4edd-bc5d-834ea8ea66b4', 'TST')


--- Leads Creation
 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', '6fba9ca4-4258-4054-a997-6e9db5323a4a', 'Leads Creation','a2c77011-14e3-4909-b07b-14e77e9d3579', 'TST')


 --Leads Lost

  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633','c18e4dfb-36f7-49ad-89ea-1e04f751d086', 'Leads Lost','cb99e532-ec19-467f-b467-836fc751e480', 'TST')


 --Leads Now
 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633','0c3122b4-f22f-41d1-a977-3bd6040e81c9', 'Leads Now','b5c2428d-d259-40f3-86b0-2a1d392417c8', 'TST')

 --Leads Re-new
  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633','c0fddce0-3f05-47b7-8ffd-6ca729d80aa9', 'Leads Re-new','e821e27a-69a3-422b-97e1-080b6ffd2b26', 'TST')

 --Leads Won
   INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633','297718a3-946e-46fe-a963-3b25fc7ae756', 'Leads Won','19e26c87-c50f-457a-8542-2976d15b3b81', 'TST')



-- Opportunities Cancelled

  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633','925bee1f-d296-440f-96e4-81b4aef6bef6', 'Opportunities Cancelled','13219bfd-854e-4cd7-8e58-6f9ef9cd63dd', 'TST')

 --Opportunities Complete

  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', 'cbc1bbe4-8ecc-42ee-bb09-f297bb80cc70', 'Opportunities Complete','d1567dd1-f3f1-47c8-bf2b-86e9c8ff2e1e', 'TST')


 --Opportunities Creation

   INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', '8d1ac45f-537f-434d-acea-91513488318c', 'Opportunities Creation','62e569e8-5df2-4535-96d8-4a41fbc580f3', 'TST')


 --Opportunities Lost

    INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', '645604c2-d6f6-42ab-89f5-9311b60cdce6', 'Opportunities Lost','66bb6a9b-6f68-4573-909f-470235b9cd0f', 'TST')

 --Opportunities Now
 
    INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', 'd36e0c7a-c058-4355-9540-8102338445b9', 'Opportunities Now','c5d696a2-786e-4f4b-9d96-2d350e1ca522', 'TST')

 ---Opportunities Pending

     INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', '4d9dbf12-f25e-40f8-a5b0-2f519ff8d84b', 'Opportunities Pending','84069e55-df3f-491e-aa5f-9aa7b632655b', 'TST')

 --Opportunities Recurring

  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', '4ddc8726-4e90-45e1-9c06-64dbbdc414ed', 'Opportunities Recurring','0198f56c-7b9c-4abd-8218-be243e13a149', 'TST')

 --Opportunities Won

   INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), 'EAF3BD3B-6F41-4173-AFCC-B35FC78ED633', '3b3a442b-369a-47a3-bc79-9c489354c084', 'Opportunities Won','cb20fd9a-f5de-4177-8cb3-062f0de75eae', 'TST')


 --======================= ===================== WorkFlow cursors ======================================
-- Cases Approved
 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'a21915c1-37b1-4ab5-9d26-875541fd9d76', 'Cases Approved','66f4e376-3f12-403d-8b94-7052a1b6bf3f', 'TST')

 --Cases Cancelled
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '807ced92-74e0-4028-8c56-7e88ee971d95', 'Cases Cancelled', 'd72653a1-bbb7-435d-a090-e0a8a0be9618', 'TST')

 --Cases Completed
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '3bece52d-f7f9-490c-b3b4-0daf6896b420', 'Cases Completed', 'da142ab9-e15e-464a-8ba5-fb2f7ee5f6d8', 'TST')

--Cases Created
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'ec3eb267-4069-41b1-bb63-22f6b90a8cab', 'Cases Created', '04005f92-3fa6-44dd-8693-4152f2ae590d', 'TST')

--Cases For Approval
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '4c83d1af-ae6c-4b82-b4a8-df2675c8f7c6', 'Cases For Approval', '3fb2e11f-9ac1-48b7-9912-f779416976ab', 'TST')

 --Cases On Hold
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'a210c87d-ed27-4417-a475-0e4b206fb903', 'Cases On Hold', '315a4491-b12a-496a-bf52-781c4abb48d4', 'TST')

--Cases Unassigned
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '38eb65df-3e11-4351-8b8f-175adb767dfb','Cases Unassigned', '2ac38b79-0256-4367-98ca-cb22fe190275', 'TST')

--Chargeability
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'bfb0f51b-e5af-44c7-bc13-8023847bdfb9', 'Chargeability', '9d773199-b7cb-44ec-ba90-8af43802870a', 'TST')


--Clients Created

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '2d04025c-dc97-4c0b-a2be-bfede9c148b8', 'Clients Created', '9fa979fd-6372-4399-b192-8d0b52c73871', 'TST')

--Clients Inactive
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '68425a64-e477-4e01-9b4e-3a481b8de58d', 'Clients Inactive', 'e330d29c-d7bb-4f7d-ba33-8e3a626bd99d', 'TST')


 --Clients Now
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '775a4671-421d-47b9-81f5-6d4d70fd7971', 'Clients Now', '281cb620-2f12-4c35-b10c-649c54215d7a', 'TST')

 --Clients Re-active
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'b8fdb813-aef5-4a88-b695-08bf13bfebbf', 'Clients Re-active', 'b9430300-468d-4b59-ba1f-a49d6f53d415', 'TST')

 --Contribution
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '293b8b9c-0714-44fe-9cde-fb46ebb41e89', 'Contribution', 'ddb8695c-4e78-4c7c-9536-99ba70bcbf15', 'TST')

--Actual Contribution
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'e305e7f1-63e0-45f1-bc5c-0ad3f1dd6c33', 'Actual Contribution', 'ba2d15de-b952-4682-a26a-d7ddc57e676e', 'TST')

--Planned Contribution
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '79295186-aa90-46fb-985f-6ea695738b1f', 'Planned Contribution', 'd7fb79da-2e48-4c1b-ba3c-01e33a70738b', 'TST')

--Incidental Tracker
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '793a80bb-1bb9-4299-a353-1179f719d318', 'Incidental Tracker', '5a5838a0-a1fb-47b2-bf4f-767d5fa076d2', 'TST')

--Individual Case
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '9a096f21-f890-45ab-b9de-9a4d6b1fd71b', 'Individual Case', 'af5e92a4-641c-4837-93eb-ea4bbfbe4966', 'TST')

--Individual Client
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'f2761d62-3e6e-433c-8d86-180a1e6cab62', 'Individual Client', '3a7641b4-636c-431f-bb30-01cc713a2725', 'TST')

--Invoices Generated
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '7ba45567-b52a-44b2-8897-85d0b052f33a', 'Invoices Generated', 'd2086e62-7d90-446c-a47d-432522428efe', 'TST')

--Invoices Not Generated
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '68572e23-1026-4edb-9145-d7ea5e6ef4e3', 'Invoices Not Generated', '10d73cf9-423c-448f-88a1-55b73fe00989', 'TST')

--Planned Chargeability
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '79295186-aa90-46fb-985f-6ea695738b1f', 'Planned Chargeability', 'd7fb79da-2e48-4c1b-ba3c-01e33a70738b', 'TST')

--Recovery
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', '7371c0c4-087a-42f1-bd61-a292d029ef5d', 'Recovery', '5668bff4-ee79-479b-a1dc-34cd5afc1268', 'TST')

--Unpaid Amount
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '465428EC-04B7-475F-83AA-7D104DE7F366', 'dac5a5ad-c5b0-4ba1-8b33-0a8ec178ac6b', 'Unpaid Amount', '8938f487-5cb9-417b-bbd5-37a9d3fb4239', 'TST')

--=========================== HR
--Attendance
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), 'B08CBD23-8047-42B3-9158-998A54A55D21', '9f54c04e-ba38-4081-ac58-890ab94faaeb', 'Attendance', '7ddf4354-9762-476f-b9d5-4fbf8d75343b', 'TST')

--Claims
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), 'B08CBD23-8047-42B3-9158-998A54A55D21', 'ad5b0a40-c6da-4f98-b20d-8195dd1267fd', 'Claims', 'c948d658-0155-4a5a-be60-976723de31ca', 'TST')

--Leaves
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), 'B08CBD23-8047-42B3-9158-998A54A55D21', '996c998f-c8dc-48fe-88d6-e6de4e75ee7f', 'Leaves', '886c21e7-687f-442d-b264-f55edf08ab14', 'TST')

--Payroll
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), 'B08CBD23-8047-42B3-9158-998A54A55D21', '2f1508ad-d190-40eb-bad7-dee10fd2fea5', 'Payroll', '0a050b33-6333-4576-b86d-b6b8896059bd', 'TST')

--Recruitment
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), 'B08CBD23-8047-42B3-9158-998A54A55D21', 'b8ff88a7-cb59-4f9c-82ba-50b829e7fd33', 'Recruitment', '9421fa50-68fe-464c-975e-e9c0cd58f4d5', 'TST')

--Training
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), 'B08CBD23-8047-42B3-9158-998A54A55D21', 'f2885eee-2f26-44d8-8228-3fadcae5adc4', 'Training', 'abe793fa-24d2-4376-ab0c-e51f7d0a94e4', 'TST')

-- ===================================Bean 
--Bank
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '25BF80DF-AE93-4B66-B837-AFC870A58F20', 'c1395a9b-fb60-4d1c-9270-f36e4e7bb145', 'Bank', 'a609f1d9-4686-4546-b1aa-8a162b75c2ca', 'TST')

--Customer
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '25BF80DF-AE93-4B66-B837-AFC870A58F20', 'bd5d9060-7f35-45c8-a94b-a7e2b0342665', 'Customer', '326505de-3d91-4b68-be4b-340618575ab9', 'TST')

--Customer Aging
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '25BF80DF-AE93-4B66-B837-AFC870A58F20', 'd0f1243d-5ce0-4ef4-ad5c-4c493c0ad895', 'Customer Aging', '5cd93e43-ce41-4a45-a9c5-13ddf4cbfd27', 'TST')

--Finance
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '25BF80DF-AE93-4B66-B837-AFC870A58F20', '2c89913a-9f75-4412-b73b-5a33d3f3bad0', 'Finance', 'c9922363-e861-4d62-a93d-b68c9a01efaf', 'TST')

--Vendor Aging
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '25BF80DF-AE93-4B66-B837-AFC870A58F20', '09bd05e5-7fa1-4b1b-ad04-bcadcce07a09', 'Vendor Aging', '7b7050e7-3b6b-4295-b356-64d72ce7520e', 'TST')

--Vendor BillPayments
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '25BF80DF-AE93-4B66-B837-AFC870A58F20', '4f3e9944-0ad4-455b-b411-c88f20ec5aee', 'Vendor BillPayments', '864ed8c2-7685-4d0f-bf86-a0eb373b074f', 'TST')


--======================='DrFinance-PRD'

--Asset Analysis
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', '46716820-0e7d-4de2-bcab-a54d8df494c1', 'Asset Analysis','ee570978-0ef6-4aef-a330-cfdb2baf08e3', 'TST')

 --Debt Analysis
 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'dd7ce60a-cc18-4e6b-a5bc-261593af6050', 'Debt Analysis','aa2574f6-da9d-47a1-a96f-645a831f2cae', 'TST')


 --Expense Analysis
  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'dd7ce60a-cc18-4e6b-a5bc-261593af6050', 'Expense Analysis','c12fb110-0b95-4bac-80f9-af793b20ea09', 'TST')

 --Growth Analysis
  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'd707317e-29b9-4675-acef-e855e768f08d', 'Growth Analysis','bde00edd-cf65-4a2b-9e4b-ff1baf93b5c4', 'TST')

 --Summary Ratios
 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'a5a2263a-628a-40ac-a988-fcd8107196eb', 'Summary Ratios', '33f3da85-4fb8-4911-bccd-60263e6a3980', 'TST')

--Revenue Analysis
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'f2ac2628-2172-4ad2-90e3-db6c9c933a10', 'Revenue Analysis', 'a0924a17-feb4-480b-ba87-27af6fee66c1', 'TST')

--Profitability Analysis
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'c35fa27a-f0ee-4604-94c5-71a4c1fc8ad2', 'Profitability Analysis', '16edefd1-41fb-49ad-a385-f7f48ef2c414', 'TST')

--Operating Cash flow Analysis
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', 'f139e320-a0cf-4f2c-8366-42b45645fda4', 'Operating Cash flow Analysis', '91b8443f-414c-4f9f-b79b-0fcf10f48b2b', 'TST')

--Liquidity Analysis
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
VALUES (NEWID(), '3AA75187-1B13-48C9-AD1F-59377A231560', '1d0fba4b-d5b3-4f25-b971-9e085561c13a', 'Liquidity Analysis', '1d627bbc-661e-4c1a-867e-34d9767f94ca', 'TST')

END 

End 








GO
