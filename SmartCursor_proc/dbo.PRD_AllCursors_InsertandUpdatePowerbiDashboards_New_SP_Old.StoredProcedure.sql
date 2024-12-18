USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PRD_AllCursors_InsertandUpdatePowerbiDashboards_New_SP_Old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [dbo].[PRD_AllCursors_InsertandUpdatePowerbiDashboards_New_SP_Old]
AS
BEGIN

---exec [dbo].[PRD_AllCursors_InsertandUpdatePowerbiDashboards_New_SP]

 Declare @CCPRDId uniqueidentifier=Newid()
 Declare @WFPRDId uniqueidentifier=Newid()
 Declare @HRPRDId uniqueidentifier=Newid()
 Declare @BCPRDId uniqueidentifier=Newid()
 Declare @DrfinPRDId uniqueidentifier=Newid()
 Declare @AuditPRDId uniqueidentifier=Newid()

  

-----=====================BC-PRD


  INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@CCPRDId, '407836f5-2c63-47c4-a214-31fd90a06198', 'PRD', 'Client-PRD')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@WFPRDId, '84bd8790-8441-4f93-be0b-793290609ad9', 'PRD', 'Workflow-PRD')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@HRPRDId, '3d4e9d69-27c3-49dc-bab6-c700b20bdf1c', 'PRD', 'HRC-PRD')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@BCPRDId, '256e81bc-7921-49b6-af78-cfe7930c0032', 'PRD', 'Bean-PRD')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@DrfinPRDId, 'c243cde9-6c44-4525-b62d-0989601064aa', 'PRD', 'DrFinances-PRD')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@AuditPRDId, 'e30761b9-67a2-4e0d-95d5-b2b8b3205b61', 'PRD', 'AuditCursor-PRD')





    --======================================================= Client Cursor ======================================================================================================
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCPRDId, 'ce611970-0e31-4d0c-8c0c-18163f4bb83d', 'Accounts Inactive', '01529ff4-33db-429e-8f46-12b33a709f33', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCPRDId, 'fac3aba6-91c5-4ba4-bd65-26f239235aa3', 'Accounts Inactive Report', '7b4da22e-590e-4e0b-b3c9-ce51faf3f186', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCPRDId, '0182b4ed-606e-403d-a000-30f9f1383b1b', 'Accounts Lost', '91645ef1-d524-43bc-817f-29e5bf5b3b1f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCPRDId, 'e7eba940-f295-4e34-a6d2-030025e99805', 'Accounts Lost Report', 'f298d7ab-e563-4316-8892-13af505efdfe', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCPRDId, 'd889024a-c15a-4764-98ce-fcc4f962c746', 'Accounts Now', 'ea81b2c3-e392-4602-9953-be073e7a8d1a', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCPRDId, '19cd1918-be7c-40a2-9491-7c970358e35c', 'Accounts Now Report', 'e6ee6006-fe87-4dfc-9a6e-300bfcdec01d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCPRDId, '3bda9c21-a5ec-4a5a-ba27-dc08f497456b', 'Accounts Re-active', '8e8caa47-da02-4767-b38e-04f14d31e407', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCPRDId, '24045bcc-883f-4913-900e-62abf72d440f', 'Accounts Re-active Report', '75e72a36-ec43-41df-b49f-35565ce317e8', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCPRDId, '95f91a88-7669-4c6a-be3b-7a00b0dce3d1', 'Accounts Won', 'abf29672-56f7-4749-af0a-2d8a04e8c4b5', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCPRDId, 'c7e41f4a-6ea4-40be-82d0-1a68b65cc519', 'Accounts Won Report', 'd923964a-bb5b-44b6-91a4-7af9bc437eea', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCPRDId, 'bdae67cb-aa7f-43ee-9370-7137df132027', 'Individual leads-Accounts', '54dc2e6a-2573-49eb-a735-95b4de3b5d9d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCPRDId, 'e0bfff2b-6192-4f81-aa70-79d15f51d460', 'Leads Created', 'b865cf27-dcc4-4ace-969b-3a38fc57a003', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCPRDId, '614c6011-45cc-4290-873f-4563ad4b20a6', 'Leads Creation Report', 'cd532f53-b090-4120-afe7-fb11b02a3efb', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCPRDId, 'dc759c8f-929b-4c78-b9e7-2f9962138d65', 'Leads Lost', 'd96a55bd-2382-4f04-88c0-803a212dafe8', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCPRDId, 'd2e71031-0b87-4c53-9781-a96ef5d0c01a', 'Leads Lost Report', '56e7b46c-d0b9-4304-b82e-2446f670ab55', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCPRDId, 'ed4b685a-346e-4643-abd5-fb40da90d4d6', 'Leads Now', '5ff28e29-d81b-41ae-883f-bd35e2ee1925', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCPRDId, 'd5c9ba5c-1a4d-49ba-9b27-87319f602c77', 'Leads Now Report', '2a3d40f3-c4e0-48f6-a51e-ef49c64455f1', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCPRDId, '0066bfc2-d75e-44ef-80cf-5db2fe4beb44', 'Leads Re-new', '8af06d36-652f-4290-ab2d-f2a8a7acf3b8', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCPRDId, '9d5e63d4-e0e6-49e2-8031-86022fe0a4b9', 'Leads Re-new Report', 'c0c3353d-ec95-405f-acb3-2ce9108bcc94', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCPRDId, 'ac134fd6-0051-461c-8594-7c3d77f55260', 'Leads Won', '51ac9bb3-a8a3-4a50-b911-92cf77cd140d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCPRDId, 'f3b40f28-eb44-4212-94a3-b4c91e5e223a', 'Leads Won Report', 'df991375-1b34-43ef-9d2e-7561426daf96', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCPRDId, '06157232-0b07-4dd4-80b9-652a99c5d457', 'Opportunities Cancelled', '72bff6e3-0026-47e8-9d5d-78bf5a99f7b8', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCPRDId, '8296530f-d003-4378-bd07-3e99196873eb', 'Opportunities Cancelled Report', '04e29f01-fddd-4e90-8c67-bbb2a99297ed', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCPRDId, '05ef1bd2-b1f8-440d-bd6a-7c4d8c589279', 'Opportunities Complete', 'decb68d6-f560-4c18-9c90-8ea2331bca07', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCPRDId, 'b31a2473-ac50-4509-8bc2-fcf0f286da25', 'Opportunities Completed Report', '40a6a3ea-bd1f-4758-8f8f-1138e517027d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCPRDId, 'd5e8f151-e89c-44db-9c61-3ca6ba495381', 'Opportunities Created', 'dbb1d56f-0d03-41d0-b7c6-83f1cfe75e80', 'PRD')---?

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCPRDId, 'ae943455-0ed5-487d-a69e-4df23301502d', 'Opportunities Created Report', '8d743a59-81d7-4000-8c23-6067169d47f9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCPRDId, 'd70823d8-9727-4db8-90c7-51948e80ae4a', 'Opportunities Lost', '366df5e6-380c-47aa-b1bf-ead850204b28', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCPRDId, '2bffa2b7-74a9-4d29-b302-89a5f568852f', 'Opportunities Lost Report', 'c81ca594-ce2b-42ac-9636-6b939ba52f37', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCPRDId, '5f168890-5883-4ffd-8e40-62765d691009', 'Opportunities Now', '658d60eb-27d1-444a-907e-9be5b1fec919', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCPRDId, '78eaa0f1-8b96-4583-a5a8-094b00d78528', 'Opportunities Now Report', 'e8b04c4f-68aa-4a27-89fa-31259d8d8746', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCPRDId, 'eab7681e-d55c-4383-a39c-45cdddb6e67c', 'Opportunities Pending', 'c6e33a88-566c-44a2-98a0-18df5c0b3098', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCPRDId, 'ffd1434f-6688-476e-a694-77615a36cf16', 'Opportunities Pending Report', '8804617c-b022-4d39-9f68-58bdcf32bc89', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCPRDId, '8030c8e0-c672-45bb-b2f1-e4bbdde41a5d', 'Opportunities Recurring', '60279c3b-865c-4405-80c8-e9319837ed8a', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCPRDId, '6ca1686f-bd22-4029-b174-2dbcec07cead', 'Opportunities Recurring Report', 'da2e4d48-8701-40a5-9bce-c16b49adaa06', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCPRDId, '7599a319-b611-43b1-a37c-312d886cc88d', 'Opportunities Won', '00a6ff7a-1879-4385-b18b-bdbb81eda41c', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCPRDId, 'a6d68354-6048-48e5-b6ad-60757384b21d', 'Opportunities Won Report', '0793c6d0-6964-456b-b712-8d6e153d34d2', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(),@CCPRDId, 'b6a74704-a7fd-46fa-9c2f-377233609d3d', 'Vendors', '9132353b-f639-43fe-a7eb-3e8896dca644', 'PRD')
 
 --===========Work Flow PRD---===============
 ----====================================================================

 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFPRDId, '274d467d-ee73-4f38-b522-800413d91456', 'Actual Contribution', '60754157-078f-4d02-8b22-8f7f6d7b65ed', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFPRDId, '9a68235e-8e11-470a-a2ed-8765f67c4f91', 'Actual Contribution Dept Poc', '2c35f2b6-beab-43c5-9509-a16dcc30e420', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFPRDId, 'bea26ab7-4b1c-4dc2-bf5e-af6b9ec9e9f5', 'Actual Contribution POC', '5e8de6a9-6328-4814-b9fc-507baf66b62c', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @WFPRDId, 'ad968250-dc7e-4828-b84d-2e68e5c2b7d9', 'Case Members Report', 'fba451f9-1529-42f2-909c-42d60d531c9a', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFPRDId, '5ec07979-1f7d-4036-9ffd-1339afe9966e', 'Cases Approved', 'acb8ee34-cdb8-4232-a840-1164488c8dcb', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFPRDId, 'f70c45df-6162-4b38-9230-10199a22b3d0', 'Cases Approved Report', '1d25a411-0d7c-4469-9d2f-026cd62dab67', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFPRDId, 'd802531d-260d-4240-b933-60a59dfd1f74', 'Cases Cancelled', 'd3e40148-d3ac-4948-9ea6-db626d2c6d72', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFPRDId, 'a2da18f5-732f-4155-b654-d5fccd03a2f2', 'Cases Cancelled Report', '5c6dbd09-38a5-47f1-a924-11486792df4b', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFPRDId, '73821773-2c63-4f88-ba30-78b71fdd579e', 'Cases Completed', 'f689e351-aeb7-40fc-a301-4de5f57bcfe0', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFPRDId, '08cd0e41-8698-4ba5-9489-edd64545a8d3', 'Cases Created', '1d78c521-feea-46e0-bc3f-2d82d226533c', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFPRDId, 'c0a07f50-0ad5-4063-b834-ef6dd1b6ad98', 'Cases Created Report', '8dc517b5-737d-4ae2-8ca8-b85db4a78552', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFPRDId, 'b9439097-057e-40d2-aa66-543d6bbd42d8', 'Cases For Approval', 'ae54ef19-5834-45ec-9034-0fd3d653c7db', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFPRDId, '55d77b84-3104-4b74-8618-ecd7ff9caf5e', 'Cases For Approval Report', 'a57d8ce5-805c-406f-aabc-bc73595834c3', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFPRDId, '24f9ae41-f99b-4a47-82f2-016f8b9c0d46', 'Cases On Hold', '1f9cfc68-103d-45b9-9a75-3669cafd84a7', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFPRDId, '33cf284a-5a6f-493c-a0da-ac0220fea16a', 'Cases On Hold Report', '3f3cd2e8-be58-4f6c-a518-831c36fbb6b9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFPRDId, 'e12a0b77-3c28-4dd5-a546-5f0aab5a1662', 'Cases Unassigned', '3fc72ed5-4468-401c-8f7d-e8c9d1cecf79', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFPRDId, 'e08c3cb7-4467-4fd9-826f-eeb7bc1cd277', 'Cases Unassigned Report', 'fa9d3504-b17c-426e-bcd4-9a4a0a80792f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, 'fe011680-7b44-4351-9bc7-db15baa6e84f', 'Actual Chargeability', '425dba7a-c958-4a4a-a0b3-8d1450080251', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, '40c82095-ae32-41cc-8a5f-82f77d33f240', 'Chargeability_Poc', '84a94ebf-773e-49e0-839b-55506b57aad1', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, 'cae0f997-6492-47de-929f-038e91b60756', 'Claims Tracker', '5c5c2985-85dd-4115-8f8b-488e519c890a', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, 'e67136ce-8520-4aa2-b98d-946709ab4eef', 'Client Contact Report', 'ca489338-7c12-44e9-93fb-350355f66e42', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFPRDId, '30932019-b6a8-4fb9-aac0-ed2d2533e301', 'Clients Created', '0eeeb51d-3057-4585-bc60-0045a02e8cf4', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFPRDId, '8480c400-ecf4-4614-9827-729abded5eec', 'Clients Created Report', 'ef2f7568-6425-4da7-a962-6833c1855e1e', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @WFPRDId, 'e7d4ab19-ecd7-4474-917e-abb20072649f', 'Clients Inactive', '7922f098-0afb-42f9-bcca-5e8d7ec7a178', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @WFPRDId, 'ea4be4d1-848a-4087-bf8b-723f3ec2c35b', 'Clients Inactive Report', '6734d066-2742-4d5f-b901-704d96c95c2f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @WFPRDId, '454617dc-f77b-46c4-90a4-0c26e5229a0a', 'Clients Now', '8d47e0fe-4864-41f8-b623-fe22db9622b4', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @WFPRDId, '0cc19ba3-fdbe-40de-82a8-74e790365f98', 'Clients Now Report', '050afc8e-9a93-49bf-b169-9ac22ed7b414', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFPRDId, '081b9b19-cde4-4b5c-b340-57d467f35f11', 'Clients Re-active', '6742e3c1-9c79-4194-97b7-c0a40770e676', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFPRDId, '851b97ca-a9f4-433e-9f55-6017b63b5349', 'Clients Re-active Report', '1b8d8dad-edbc-48de-9265-76aaf8f8d426', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFPRDId, '8e1076a3-2223-4254-9cd6-f9e51cae9dd5', 'Incidental and Claim Tracker', 'e3929efd-df40-47fa-954c-6bcabbc507af', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @WFPRDId, 'a750ede7-8642-40ea-bbda-a10fc14685e6', 'Incidental Tracker', 'bcc65e83-c181-4c8c-82c0-f9f63003abec', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @WFPRDId, '66786030-966f-4503-b12d-aa2d243aa172', 'Individual Case', 'efb4f57d-6ee0-4766-a398-7831dab881e7', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @WFPRDId, '392e12c1-73e7-4e47-b0f6-8c4d3dbf93c1', 'Individual Client', '58b93cf1-fbab-45d6-a2f0-32e356ff1b0a', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @WFPRDId, 'c3c0baf5-8c7c-4ad4-bdcb-4f2f2b981fde', 'Individual leads-Accounts', 'd67dad36-9a6b-45a7-bc56-0077f11d5d39', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFPRDId, '0cd74bc7-f380-4947-bdf9-7afb36ffb8c5', 'Invoices Generated', '14af38ed-66f2-48d1-9095-bb4d9e7ee056', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFPRDId, '83d7530d-41ec-4450-9559-12850f62ac56', 'Invoice Generated Report', 'f93d1df9-def8-4d03-ad3b-a632ecc07379', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFPRDId, '261db186-5f44-4d2c-98c6-6937c943a8ca', 'Invoices Not Generated', '5d036527-4912-491c-a595-c3f4e8dfa8f3', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFPRDId, '5889ac1f-6a4c-4120-a0b2-e82146848688', 'Planned Chargeability', 'c96221a5-ada5-4c05-937d-8eb9cdf0ad56', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(), @WFPRDId, '9ffc85cf-e3fc-4073-8b89-1dd75d835b92', 'Planned Contribution', '957ba8d3-cc39-450e-882c-be1fde626447', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFPRDId, 'd0d09ccc-3a2a-4fb5-b2a6-d0ca21efc225', 'Recovery', '95993133-26c1-42ce-a3b2-555294aa6442', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFPRDId, '84dbb029-488d-49e3-ba7f-e22c5e0a5db2', 'Timelog Detail Report', '390b3507-f3f3-4955-a8b1-5466d090e434', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFPRDId, '29543ad0-89c5-4475-8391-4ea9b05a9ce7', 'Unpaid Amount', 'a3dce353-c296-4811-94fc-610b3492429e', 'PRD')

 --===========HR PRD---===============
 --=============================================================


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRPRDId, 'bc52e8a9-dd06-4fd2-acc4-f10ef2b743d7', 'Attendance', 'dde2f1b1-78aa-44cb-8ba1-4b242c812f30', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @HRPRDId, '16dd1b8c-2a9f-4db6-bb5c-64443f79908d', 'Claims', '8ca6f8ed-3224-409e-815f-b9c642fc0cd5', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRPRDId, '88cdd03e-465b-479a-9a21-204731fe2e5d', 'Employee Details', '78cc520d-68dd-40bc-ad37-2ad1fab510e5', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @HRPRDId, 'c1850d66-ac72-4e86-a7ae-c99a5104bb8e', 'Leaves', 'd1420714-39fa-418c-8e77-10bcc9a9bb26', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @HRPRDId, '3f7c3eab-233a-4d4a-8dbf-bbbab245982b', 'Payroll', 'e7e1ec83-e26e-4d08-9def-6aa930fab466', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRPRDId, '9e491311-6ed4-4f83-864e-cd4e0b6c96e4', 'Recruitment', 'f3828743-7f34-4aa3-a3af-97aca19d03d2', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRPRDId, '7142d1e8-f628-442f-b9d9-f649950184cf', 'Training', 'ee71080c-10cd-421b-a125-89def691344c', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @HRPRDId, '8e1c0b48-8cc9-4caf-b48f-1b270ce0a60a', 'EmployeesDetails', '43146bcd-2d1b-42f5-a6ef-ca64a758c05b', 'PRD')



--  --===========Bean PRD---===============
-- ----====================================================================

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
--VALUES (Newid(), @BCPRDId, '5cbc20a8-5f22-4f9f-b671-4092d6786f9e', 'Bank', 'df15c9fa-444b-429d-81c2-a3d18e65b3ee', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCPRDId, '56f89e36-e4a5-4bf4-beb1-7bbfe6a70ac5', 'Bill', 'a80e1324-7af4-43cd-9951-8b1d39c1751f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @BCPRDId, '774eb9a4-e646-4fd0-af72-8d66a5799111', 'CASH AND BANK BALANCE', '1def229a-c8c7-4846-98f0-2a4e66093d93', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @BCPRDId, '28dc0f7c-6519-42d5-9a13-c68321e343b8', 'Cash and Bank Balances', '0d72d605-7fbf-44c8-bdd3-39ac9ba476f5', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @BCPRDId, '0c92e6fc-5a26-42f9-b0ba-e6f60d31c744', 'CASH AND BANK TRANSACTION', '4e1a5b88-d5a1-478f-9a16-be046d4b204e','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @BCPRDId, '1a8af625-d097-4c2a-909a-518f73d85472', 'Customer', 'acd41efe-fa8b-46cd-a454-db6d5cbb582a', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCPRDId, 'ee29b34a-4afa-4a0e-8357-e39d948ea3ad', 'Customer Aging', 'acd621ba-9c1b-41a5-9994-126112e0d18f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @BCPRDId, '698b49ca-5768-465e-b306-01383aff1294', 'CUSTOMER BALANCE', '2ba636c4-6dd1-47ab-9ec2-64721d6a5ec4','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @BCPRDId, '3acfb296-088e-4315-b7dd-b128e0b472d0', 'CUSTOMER TRANSACTION', '23db4921-82e9-4d4b-afac-a610ffe47412','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCPRDId, '749a85eb-73da-471d-bd5b-09b6345c85a9', 'Financials', '4d1e8407-b585-4db9-a53d-608d72ca83a1', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @BCPRDId, '3ee63c16-e59b-4467-a720-5a150f48eb26', 'INCOME STATEMENT', 'f1d95077-a3b7-4597-9215-6dd1b71a69e8','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCPRDId, '09fcc081-f6bc-4eeb-aece-f80e48f31014', 'Vendor', '3fa10beb-afd3-47e2-8efb-cdffe226b229', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @BCPRDId, 'f40422d7-7839-42ba-8da7-bae1fa91a240', 'VENDOR BALANCE', '85328a03-3244-4e51-bd1f-3a644e0dc0ef','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @BCPRDId, 'c51d8f2d-508c-4426-ad9d-5d8403f8e054', 'VENDOR TRANSACTION', '77e51a1f-69ad-46b2-ba2d-8b8f444e857d','PRD')

--  --===========Drfin PRD---===============
-- ----====================================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, 'd74f15ad-0603-4a75-bebd-30c1bc55f38d', 'Asset Analysis', '4ef0f3b8-5c49-4c02-9f98-dc04a335171d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @DrfinPRDId, '656ac26b-6906-4f33-b240-6c3c45c478a2', 'Debt Analysis', '3d73cdaa-6f2e-48d3-b892-ecfc0d326ace', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @DrfinPRDId, 'dab55428-11fb-4d59-a63a-d4a2b2da72d3', 'Expense Analysis', 'b52cc442-df93-41b1-bb19-ffdcdad8bdee', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, '64ba1bad-1a34-4f91-a951-62b79e0a0653', 'Financial Ratios', 'd29e533e-e783-419f-824a-39833bcfffab', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, 'b8e8e877-a47e-4541-9089-047a878950ab', 'Growth Analysis', '5d14d4cc-f3e6-4807-8b0d-942348310e1b', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, '51e35039-55a1-4476-8931-6c99a6ccd152', 'Liquidity Analysis', '4aad4e54-fced-44fb-9cf2-36ef79be8316', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, 'fd085204-1e2e-4bf3-aa9d-9377e0f6e675', 'Operating Cashflow Analysis', 'd928d1f5-58e6-4028-8cf6-5d7bf82cd5c7', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, 'ab537d6f-acc9-4ac1-9fe7-0be4aa40038e', 'Profitability Analysis', '69f4ab11-1244-4585-b320-39c71ca87137', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, '5e982eea-dab2-4dc4-bd7b-cefc0b832626', 'Revenue Analysis', 'ef5fb3a3-97dc-4cf7-9fcc-140c0390c8d8', 'PRD')



  --===========Audit PRD---===============
 ----====================================================================

 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @AuditPRDId, 'b0e9c4e7-427c-4bd0-9cd7-2a524f47d7cb', 'Profit & Loss Analysis', '692cbb69-b111-4155-a42f-403e8cbecc72', 'PRD')

--update [Common].[ReportWorkSpaceDetail] set ReportId='2de06ce0-6f6e-4aaa-a503-950de6cbdebf',DataSetId='7d3511c3-6412-4a23-88ea-cd7adf565f4c'
--where ReportName='WorkProgram'

END


--Update [Common].[ReportWorkSpaceDetail] set [ReportName]='My Trainings' where ReportName='My Training' and ReportId='d1c4713e-9e7b-47ce-88fe-6f397fce0d7a'



GO
