USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PRDInsertandUpdatePowerbiDashboards_Old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Exec [dbo].[PRDInsertandUpdatePowerbiDashboards]

CREATE Procedure [dbo].[PRDInsertandUpdatePowerbiDashboards_Old]
as
Begin
--===============================[Common].[ReportWorkSpace]===================================================
   Declare @CCPRDId uniqueidentifier=Newid()
   Declare @WFPRDId uniqueidentifier=Newid()
   Declare @HRPRDId uniqueidentifier=Newid()
   Declare @BCPRDId uniqueidentifier=Newid()
   Declare @AuditPRDId uniqueidentifier=Newid()
   Declare @DrFinanceRDId uniqueidentifier=Newid()
    --=====================Truncate [Common].[ReportWorkSpace] Table--====================================
	DELETE FROM   [Common].[ReportWorkSpace] WHERE [Environment]='PRD'
	--=====================Truncate [Common].[ReportWorkSpaceDetail] Table--====================================
	DELETE FROM   [Common].[ReportWorkSpaceDetail] WHERE [Environment]='PRD'

  --IF Not EXISTS(  select ID from [Common].[ReportWorkSpace]  WHERE  Environment='PRD' )
  --Begin

   --===========CC-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@CCPRDId, 'b17fdce0-7a35-4146-b261-70aba9c81d28', 'PRD', 'CC-PRD')

   --===========WF-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --2
   VALUES (@WFPRDId, 'd8537ab3-f12e-41ee-a42b-cbaf1fa79307', 'PRD', 'WF-PRD')

   --===========HR-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName])--3
   VALUES (@HRPRDId, 'fcebcb14-aef3-48fc-bcb7-489925ee177e', 'PRD', 'HR-PRD')
   
   --===========BC-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --4
   VALUES (@BCPRDId, '61fa3e07-82f8-4434-a101-e891219a24c1', 'PRD', 'BC-PRD')
   
   --===========Audit-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName])--5
   VALUES (@AuditPRDId, '2778d966-cdb8-498d-8575-ff44ee2ef2e3', 'PRD', 'Audit-PRD')

   --============DrFinance-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName])--6
   VALUES (@DrFinanceRDId, '2104a816-f47b-4e62-afa7-f831b8da018b', 'PRD', 'DrFinance-PRD')
  --End
  --===================================================[Common].[ReportWorkSpaceDetail]=========================================================================

   --======================================================= Client Cursor ======================================================================================================
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCPRDId, '5815b3a1-fc28-4b40-a240-b44eb261b8f5', 'Accounts Inactive', 'd106de47-a8c9-40e0-aaf3-75db5978fb3b', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCPRDId, '6e8da2fc-64c0-4f98-a775-5b611691cd99', 'Accounts Lost', 'eb2abd38-5844-449b-bde2-9327e6878e61', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCPRDId, 'a2680d97-4dab-41fe-b56b-a24bc4d4adee', 'Accounts Now', '4fed9baa-8d52-4a07-9077-d9eaf178550f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCPRDId, '55c1cd6f-1b50-4c54-9005-578e740904da', 'Accounts Re-active', '9875d3a3-00f3-41f9-bac5-bc0fd1052de6', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCPRDId, 'dce57ee5-5560-45b5-9dc8-a02763f3de4e', 'Accounts Won', '351f925f-092a-4702-bfd7-ee8aed187e8e', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCPRDId, 'b6c0a36e-6da4-4a8a-a3eb-db5a6ce9349f', 'Individual leads-Accounts', '77120865-12ba-4242-b200-5a800aa96f84', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCPRDId, '19ce994b-39b1-44b1-8d96-5c16c6c9dc7a', 'Leads Created', 'd7134175-d307-4877-b905-0ed567a0ebf7', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCPRDId, '9305c8e8-7c55-4360-8352-b91514e6504f', 'Leads Lost', '35bcfddd-9389-4404-a127-5899cacf4d0e', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCPRDId, '757c6d6d-fcce-4b91-a917-d90b51d2cd28', 'Leads Now', 'b923b484-7e23-4359-beba-92b9e1c9cc48', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCPRDId, 'd9456bae-e21d-42f7-a36b-89fea3349c51', 'Leads Re-new', '4c0ac9fe-767b-4bba-a9a1-5dd230c557a0', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCPRDId, 'a781ac12-0b35-4168-99d2-8c8400fdeebd', 'Leads Won', '744ea6f6-d910-4076-8774-1cd4905de156', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCPRDId, 'eef0c460-02dd-4a5f-a8d4-818485f30689', 'Opportunities Cancelled', 'bf0cc21c-b3f8-4b5b-8532-12e97842c332', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCPRDId, '4d8f5986-c580-4476-a0fa-aafe57ec715e', 'Opportunities Complete', '7fb82d44-d042-4d96-abab-89d6f02ed1fd', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCPRDId, '49b92b10-9a35-4584-9958-94d8b24b1abe', 'Opportunities Created', 'afbd40f9-d254-44a1-a977-4b45af42353e', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCPRDId, '9935410c-7510-4509-b9a6-2fc864be5cc3', 'Opportunities Lost', '77eda0f7-7b05-4de4-8e96-5345129ba57b', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCPRDId, 'd6cfed78-56c4-4fe1-bc8e-15d68c1096b0', 'Opportunities Now', '47ab4b0c-3712-45ac-ae55-769753591cbb', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCPRDId, '46ed6268-a22c-46c2-aefe-a14720e17a4d', 'Opportunities Pending', 'ec793508-4743-4fbe-a117-90cd67e90ca5', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCPRDId, '6f14d851-2165-48db-b118-21601cba6ee3', 'Opportunities Recurring', '3151436a-189c-409d-8bed-e0ccd9da6579', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCPRDId, '06c730ae-b198-4fbc-b10e-51cfeab66f44', 'Opportunities Won', '0021edb8-2d1b-4e3a-9279-e1092b640e2a', 'PRD')

  --======================================================= WorkFlow ======================================================================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFPRDId, '9228e688-9195-43ca-8ab3-3cae9208b7cc', 'Actual Contribution', '5be8c75b-27e4-4846-8afd-32c6eb4e3136', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @WFPRDId, '2d7e7840-0748-4cf2-9874-7a622e4a72f2', 'Case Members Report', '1a644bcc-29b5-4c03-823f-bd5523c892d2', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--3
VALUES (Newid(), @WFPRDId, 'afc1b9d2-e276-40af-ad50-ccdae8cf7786', 'Cases Approved', '8e3afa0a-8176-4338-979d-8859880452d9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--4
VALUES (Newid(), @WFPRDId, '19b5c0b6-d96d-431c-831f-272eb1541263', 'Cases Cancelled', 'f7d47cb4-8677-40eb-8db5-9ceb010302ab', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFPRDId, '108a565f-f724-45da-9965-d79e309c35c1', 'Cases Completed', 'e5b7ab15-4ae1-4c1e-b2da-7cce48b79377', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFPRDId, 'd2ce0ffc-47e1-410d-bb3b-02f35d96da85', 'Cases Created', '7efbdab9-576c-44f5-b610-141d16ee0bb8', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFPRDId, '18a81a8e-b4ed-413a-9a91-ca42d45dff49', 'Cases For Approval', 'fc2e8d4f-b5be-44fb-a070-6a3ac916a314', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFPRDId, '93bc2ecf-f98e-47fd-ace3-5d30fc085686', 'Cases On Hold', 'f4d426cd-385d-4c1d-8459-2c52a8bcbf42', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--9
VALUES (Newid(), @WFPRDId, 'ec3b89cd-90d5-431d-9b06-cf0e3c47d1d8', 'Cases Unassigned', '8a39e737-816f-4a95-8d85-a70690fed899', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, 'cb739509-9026-4d41-93c5-227c696c5fb3', 'Actual Chargeability', '98e2ea21-6db2-44ea-ac87-88f8380dda30', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--11
VALUES (Newid(), @WFPRDId, '29d94b31-b9a8-4b3b-8bcb-d3c866a863ff', 'Clients Created', 'da91e603-f0fa-4b40-be22-3a3c5468578d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFPRDId, 'e6ec6b6f-2e3d-4af6-9e94-0d587e7843d7', 'Clients Inactive', '6e27ba3c-ca1c-4572-bba9-d92fc802fdd8', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @WFPRDId, '13b7bb6a-e506-4470-878c-b727f6d9e01f', 'Clients Now', '2cf033fc-4ffd-46e1-9033-7890061ba4da', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @WFPRDId, '7e385a25-a754-4df0-bd45-b2cd8c822e67', 'Clients Re-active', 'aed41050-e9a6-4eae-8419-2ceec2eeaf93', 'PRD')
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFPRDId, 'adc5019b-ec23-473b-bbac-b98b98b5b104', 'Incidental Tracker', 'cd0d467d-b77f-4351-839e-46394faf5bf5', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @WFPRDId, 'db28e0ae-f41e-49c2-9d7b-6ec11b973b8b', 'Individual Case', '06b309ab-8aff-4a6f-bb6b-43cc683dff1b', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--17
VALUES (Newid(), @WFPRDId, '8e79fc2d-58cf-498e-a898-1f8e719856be', 'Individual Client', '48d24fac-6a22-44fd-90de-9d09f91766cd', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @WFPRDId, '5ff8e194-6f7c-4541-abd4-b0f7e8ed3b02', 'Invoices Generated', '4e60060d-24de-4aa7-b856-8d7d4ef93618', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFPRDId, 'cd3575d4-063f-4923-8d9f-7408eebfcc8a', 'Invoices Not Generated', '9f34a480-3e5f-48cf-a87e-3096140f4e97', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--20
VALUES (Newid(), @WFPRDId, 'b43a407c-c4f8-4c9c-a648-f2c32866ca42', 'Planned Chargeability', '2e6f547b-2878-4d4a-94bc-348e8fe4e509', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFPRDId, '1a3e9818-f0c4-4ae7-81f4-0a174bdda15f', 'Planned Contribution', '7be55e81-4b54-4450-84ea-b70a608a0b15', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(), @WFPRDId, '066a75ca-846d-4843-a94a-33c8d2b680af', 'Recovery', '87c6e7a9-95cf-46bd-b41b-9bd3faa2d8c6', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFPRDId, '1191f504-dc44-4b2f-bd3c-9c6db7aa6764', 'Unpaid Amount', '776d9399-3576-408f-b12d-711730377013', 'PRD')

 --======================================================= HR Cursor ======================================================================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRPRDId, 'e30847e2-c91c-4caf-8460-23123b8e2431', 'Attendance', '9168c761-b4ab-4f4e-a24a-0613574029c4', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @HRPRDId, '907bca72-7675-4e95-90c2-ab31ec4b0f58', 'Claims', '31b7fe1e-b713-4935-b6c6-e5b6a181ab57', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRPRDId, '8a141c46-83ae-4d06-a7e3-7d1bff9f2515', 'Leaves', '30cb1c37-80e4-4b48-8910-2e622ea3c381', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @HRPRDId, '3ae56e2a-8561-4152-b536-11fbc7e6d3b5', 'Payroll', '7a0eaf3b-b980-4d15-872b-0a2713000bb9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5 
VALUES (Newid(), @HRPRDId, 'db37b2f9-b999-4101-92db-082c09bdbac7', 'Recruitment', 'b4d58362-9b1b-4347-882c-dc0dee927181', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRPRDId, '8e22c1f0-6690-41d2-9db8-27b57153a43b', 'Training', 'f8cdb5b9-a8d2-41c8-8417-b06da4a6106b', 'PRD')

 --======================================================= Bean Cursor ======================================================================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--1
VALUES (Newid(), @BCPRDId, 'b5d533ea-6eff-45de-8937-e22308f21101', 'Bank', 'fbc8529b-ba1e-43e4-b848-af01e83bd8cd', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--2
VALUES (Newid(), @BCPRDId, 'b36365b3-91cb-4f99-9e24-efe3ad4fadbb', 'Customer', '31d1ec2e-2b01-40ac-a3de-99e633b2d508', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @BCPRDId, '45d81c08-ddb7-4483-865e-b2c1026fa394', 'Customer Aging', '99b501a0-3a02-4984-a5cf-36cc8449d16a', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--4
VALUES (Newid(), @BCPRDId, 'c43750f7-d9e2-4929-a6cd-a1b0585bc616', 'Finance', 'c89c7da7-7ca7-41c8-ba63-a12a955c95be', 'PRD')



INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @BCPRDId, '3a613872-f982-478f-a424-6759fcb062a4', 'Vendor', 'd6e10e54-e39c-4b80-9c74-7c18594e594e', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
--VALUES (Newid(), @BCPRDId, 'c99390a4-7c0b-4469-8e8e-43e022c84ae3', 'Vendor BillPayments', '6d61ee91-195e-4b69-8676-1d68f2e8cdd9', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
--VALUES (Newid(), @BCPRDId, '3a613872-f982-478f-a424-6759fcb062a4', 'Vendor BillPayments', 'd6e10e54-e39c-4b80-9c74-7c18594e594e', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--6
VALUES (Newid(), @BCPRDId, '410fa2df-5340-4e32-9fe1-7c34b2c1a520', 'Vendor Aging', '6076afc2-befa-4b5b-ab07-dbfad3d4c1da', 'PRD')


 --======================================================= Audit Cursor 
 insert into Common.ReportWorkSpaceDetail([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
  Values (Newid(),@AuditPRDId,'44deb86d-5fb8-413d-ba2c-61626ab8e544','WorkProgram','f1c79c1f-2fae-4288-b76e-94b72164b82d','PRD')
 
 ---======================================================================================================

 --======================================================= DrFinance-PRD Cursor ======================================================================================================

END
GO
