USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PRD_AllCursors_InsertandUpdate_MyPowerbiDashboards_New_SP_Old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE Procedure [dbo].[PRD_AllCursors_InsertandUpdate_MyPowerbiDashboards_New_SP_Old]
AS
BEGIN


---exec [dbo].[PRD_AllCursors_InsertandUpdate_MyPowerbiDashboards_New_SP]

 Declare @WFPRDId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='PRD' and WorkSpaceName='Workflow-PRD')
  Declare @CCPRDId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='PRD' and WorkSpaceName='Client-PRD')
  Declare @HRPRDId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='PRD' and WorkSpaceName='HRC-PRD')
  -------- ==================================================MY WORKFLOW

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, '71e8ed7c-b7f1-4e2b-8e33-10853c47e5a5', 'My Actual Chargeability', '747cd957-ff62-480e-a2f6-d2f1ae81feb8', 'PRD')
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFPRDId, 'd03a9b8a-b426-49f5-9b5c-eb920d65141f', 'My Actual Contribution', 'c0af64ac-4362-4a14-bc1a-5810d62b9912', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFPRDId, 'd0a0e95b-e463-4930-8367-719f7070d8a9', 'My Cases Approved', '39f41227-f28a-4812-9187-8726a9bcd72d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFPRDId, '4cc54232-ae8f-4257-9efb-5d75fa5a73b0', 'My Cases Cancelled', '7b16596e-f2f3-44de-ab63-055f3278e820', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFPRDId, '0a411c66-0dfd-44da-8269-d3b91e48a7aa', 'My Cases Completed', 'aa3aab2f-9912-4604-b730-3f442910913f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFPRDId, 'a9ab0c7e-0117-43a8-b113-ffd499e06dd4', 'My Cases Created', '97c0dd48-0a6a-43a4-afdf-bdea83d9d073', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFPRDId, '1dea661e-5a44-4465-bc1a-0d1c3fab6eab', 'My Cases For Approval', '53870f29-c16b-4048-82e4-6d54dff705a2', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFPRDId, '1f946bc1-7299-4b20-8320-9ec1df2f898b', 'My Cases On Hold', 'f61c66eb-b2aa-463a-8d5b-9ba117067f77', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFPRDId, '7b2a7921-e31b-4769-8642-0de011aaaf7e', 'My Cases Unassigned', '57326f54-ad67-4828-bb6f-7688f2458988', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, 'c0012156-10a5-4591-b6d6-2d4b4df48947', 'My Claims Tracker', '2a511151-88cb-43ab-85f4-b5fa04e3c33e', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFPRDId, 'd0c38ad9-e4d5-4a3e-b9b6-6b1c6c2bc0e0', 'My Individual Case', 'f366d89a-4bd5-4be6-ad06-48b79a9f6086', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFPRDId, '42fc56c9-2f68-4ede-ac95-fa0d413b9a5a', 'My Claims Tracker', '0ba6f27c-31c7-4554-846e-1ca1de8f3dbf', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFPRDId, 'dacf5dfe-0fce-49a0-8d3a-ca72883fe8c7', 'My Incidental Tracker', '61c652d2-c4ab-4755-87b4-c0f0fe249827', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFPRDId, 'd50a73fe-985f-4252-9d7a-e9127280b8fc', 'My Invoices Generated', '50fb15ab-59c0-416d-a942-bc570e118f07', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFPRDId, '05c525ad-59fa-4fbe-b70d-39b956991e2d', 'My Invoices Not Generated', '15e0630a-b0d8-4292-9d44-a687564166b6', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFPRDId, 'e040c8c8-bb44-4986-b64c-545c6db67507', 'My Planned Chargeability', 'f0ba8c3f-8a7e-4510-b825-be2c16163a8d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(), @WFPRDId, '643d97f5-1217-4cc4-958c-647461e0baa8', 'My Planned Contribution', '42097ce5-1aae-441b-a382-e8cf676a1054', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFPRDId, '43d3f9bd-5657-4049-939f-97527f670275', 'My Recovery', '46e23821-20bd-4134-8cfe-2a8116f3b695', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFPRDId, '95e01348-40d8-4930-8263-6139f4456cfa', 'My Unpaid Amount', 'f6fb71d7-b2ea-4819-81f1-a440ff920639', 'PRD')




---------------------===========================================MY Client cursor--------------
   
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCPRDId, 'f3188713-c7a2-4e31-b565-d40b21731072', 'My Accounts Inactive', 'd42478d3-8fca-4841-965e-1ad8ebf61245', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCPRDId, 'c021ea0d-e592-4e08-a543-59c3e658caf1', 'My Accounts Lost', '296fb71b-2f10-4df7-a8df-25a0fa150a1e', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCPRDId, 'ac801ba3-b388-4821-8a97-0dd09c65cc4f', 'My Accounts Re-active', '74baedd3-787d-4c0d-b830-81f05265e522', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCPRDId, '87a28763-784c-491b-b961-a9e1978ba16a', 'My Accounts Won', '8f9ca036-5650-4090-a0ca-af70f801c6dc', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCPRDId, '74502a17-62c8-4302-8fa8-72253f177195', 'My Accounts Now', 'c7eddf29-c9fb-427e-8379-78c2ceb77bc3', 'PRD')


----=============================================================My Leads----

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCPRDId, '0f5b9bef-a2f5-4b43-bf90-0feafe5be844', 'My Leads Created', '86453ccd-18b9-48da-82b3-e86f64a8468c', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCPRDId, 'b53f0ff2-2e5a-434f-9094-54cd8d4d2100', 'My Leads Lost', 'c85f070e-c4ad-498c-bed8-a7ba77165336', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCPRDId, '6b2ba8fd-06b5-4bf7-902a-d36241ce682f', 'My Leads Now', '17cac462-cb19-473f-9636-33b60bb771c6', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCPRDId, 'f262aa58-ea6d-4d26-875a-bb84b7b782e3', 'My Leads Re-new', '2cabca86-fa9a-4ffd-aa7a-438b5e978640', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCPRDId, 'feffaeea-e8fa-4953-a8a8-7581c47add7d', 'My Leads Won', 'fbb98185-208d-424a-8686-12a584e95fa7', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCPRDId, '501569f3-98a0-451b-8ae5-3ed98ca13425', 'My Individual leads-Accounts', '142f49cc-bf7c-4de5-96b0-50e77afd9dcf', 'PRD')

----========================================================MY opportunity--

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCPRDId, '10fd6c7a-1b64-4b92-886c-d4a1106132ee', 'My Opportunities Cancelled', '78b6bf6f-835b-4e64-a25c-c25985848d8a', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCPRDId, '7b2897e5-e416-4b00-95e3-3b9ac678d830', 'My Opportunities Complete', 'a4bc29e0-5c1b-41e5-a1e4-d9d705329e34', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCPRDId, '0370b5bb-b6c1-4a11-a14e-1b17b387d02a', 'My Opportunities Created', 'c7af0386-c548-4e17-b035-8297bf2a9180', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCPRDId, '9df53e97-6b77-4fc5-8fe6-d277b7c7dcf8', 'My Opportunities Lost', 'ad4e6644-2151-4285-9f1e-9e4c2bf08ed0', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCPRDId, '427b5491-06d5-4229-9dee-f99f48579d11', 'My Opportunities Now', '14e5fd6b-112c-479a-84aa-f25a5197aca6', 'PRD')



INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCPRDId, '644056ea-9dbc-41cb-9a51-bec007b91f67', 'My Opportunities Pending', '07b0dd69-ca40-489a-b81f-374d3d538a44', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCPRDId, '6627f5a8-e494-4134-929e-ef74bb748d55', 'My Opportunities Recurring', '2f4f3161-f888-4487-87fa-9f79953aa1d2', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCPRDId, '8c03e837-5c1b-4888-9eed-66ab21701432', 'My Opportunities Won', 'c09a93bd-1ebc-4e56-8f25-8e72a71b330e', 'PRD')

----==================================================MY HR=====----------------

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRPRDId, '0b9151ba-e5a4-461e-a47f-28ba37a364fa', 'My Attendance', 'a407bfbc-a770-4597-82cc-1ce4f2677184', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRPRDId, '91885ce9-e349-4cf7-8f54-3d801022b64d', 'My Claims', 'e90bebae-1620-494c-a3ec-c7237502a2ce', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRPRDId, '115fcc87-9cdb-4bec-87fd-834a11d5397f', 'My Leaves', '77ae16b4-b264-4d07-a6ac-295740c245ea', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRPRDId, 'c074ab63-dee0-4359-8500-76d9f96cee7d', 'My Trainings', '4563eb92-a756-4604-a575-874e1e55581c', 'PRD')
 
END








GO
