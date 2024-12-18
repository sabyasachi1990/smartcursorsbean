USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[STG_AllCursors_InsertandUpdate_MyPowerbiDashboards_New_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--==========================================================SP=============================================================================================--
CREATE Procedure [dbo].[STG_AllCursors_InsertandUpdate_MyPowerbiDashboards_New_SP]
AS
BEGIN

--exec [dbo].[STG_AllCursors_InsertandUpdate_MyPowerbiDashboards_New_SP]

Declare @CCSTGId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='STG' and WorkSpaceName='CC_MC04')
Declare @WFSTGId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='STG' and WorkSpaceName='WF_MC04')
Declare @HRSTGId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='STG' and WorkSpaceName='HR_MC04')

--======================================================= MY Client Cursor STG ======================================================================================================
--Declare @CCSTGId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='STG' and WorkSpaceName='CC_MC04')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--1
VALUES (Newid(), @CCSTGId, '1526fb22-2290-43d2-9b7a-16a4566787d0', 'My Accounts Inactive', '26d60e94-7d63-4950-be79-4efc2507d0d4', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--2
VALUES (Newid(), @CCSTGId, 'd179d902-6fa6-40e1-83b7-4046664aa34b', 'My Accounts Lost', '56cb4598-e4c4-4d5f-8000-6976a02097c3', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCSTGId, 'bf7454f6-9df1-4a84-96a3-7ddd73258c3b', 'My Accounts Now', 'e5f50e3b-1295-4dc6-8e8e-416b7f4b36aa', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCSTGId, 'ffc30655-d674-42da-91f7-686d49978b05', 'My Accounts Re-active', 'e27e45df-717c-49ea-81d4-b1a6efdcc7f2', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @CCSTGId, '8138318f-7e75-4f61-9fa9-92ff27cc576f', 'My Accounts Won', '9ca2fb91-b9ca-434c-a392-09631552208e', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCSTGId, '18880a92-3812-4806-9a6c-c870700ac88f', 'My Individual leads-Accounts', '41cb72a7-f20f-48f8-8342-29113a3a713a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCSTGId, '1b3336e9-f699-4a1a-a517-1307bb7d6788', 'My Leads Created', '9266fdb9-532e-4a14-8209-ef6f036d9901', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCSTGId, '8283850f-321e-4e11-816f-e7eb360946a0', 'My Leads Lost', 'c1cf0d8e-93c4-401f-89c9-0d6579dac808', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCSTGId, 'cfee20bf-8961-4ace-b432-acd37a8d0f1f', 'My Leads Now', 'b07d41b7-7a77-4641-bd37-b52432d0fed9', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCSTGId, 'd58fd65a-d315-4b8e-820f-e789eb11bb93', 'My Leads Re-new', '0e78ca27-bf5c-45e8-9690-edc5a4fd0b80', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCSTGId, 'c123d243-cc2d-4b4f-9bbb-f677b0ba45a8', 'My Leads Won', '36f0b84f-c4e6-4721-8b3d-4e21657903b0', 'STG')

-----------MY opportunity----------

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCSTGId, '2994d37e-4a7f-48a6-81ed-ac7c7931aa33', 'My Opportunities Cancelled', '3d2da806-04b1-49ca-9a2a-138744cb0abf', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCSTGId, 'f8069b8b-1d13-4253-8274-721b54a54752', 'My Opportunities Complete', '8abe1528-626e-4d4e-bf42-149c2eff9609', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCSTGId, '3e3b7bb7-e92c-40ed-a3bb-9772548dfc0b', 'My Opportunities Created', '23e4a629-ab4c-45b6-aaf0-269fa53cb71c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCSTGId, 'fa620035-d249-497f-842f-956df489fd1e', 'My Opportunities Lost', 'bec86f59-b676-45be-a20b-35a8b29d038f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCSTGId, 'dfee419d-635c-4f4c-9dca-35c2978f09f2', 'My Opportunities Now', '10b260a9-5c96-41a1-992d-cb1e6a84c351', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCSTGId, '1cd8e33f-f944-4e56-abfd-6452f70607c6', 'My Opportunities Pending', '9e1d39ed-a1d1-47e8-82de-55dfbeb30a60', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCSTGId, '9fc61963-14f9-4a54-8c60-c32b8f23da1f', 'My Opportunities Recurring', '6683fbd8-3596-4175-bf5d-2eb6cf35bfcd', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCSTGId, 'e576bf26-46cb-4c54-bf9b-ac876499b93c', 'My Opportunities Won', '7025ff47-9a66-4d49-91b0-a2d60b5f9f39', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @CCSTGId, 'e7c49d39-132e-487d-9c1a-5a4bd6764658', 'My Quotations', 'df2699a5-fb4d-475e-85d7-6747bad0c458', 'STG')

--======================================================= MY Workflow Cursor STG ======================================================================================================
--Declare @WFSTGId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='STG' and WorkSpaceName='WF_MC04')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFSTGId, 'f1788d09-ccab-49ea-bbc4-d59744c908a5', 'My Cases Approved', 'af2df832-ddc8-412f-b0cf-405ec2eac784', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @WFSTGId, '8d318b9d-1a9c-4041-a3fd-7490dd278395', 'My Cases Cancelled', '6c3d199c-3cf8-4a96-8c2b-3dd15e858bbe', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFSTGId, '775abe52-295d-4e21-a5c7-b64fec4ec81c', 'My Cases Completed', 'de49f85a-bc75-4841-b890-03462fe33faf', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFSTGId, '4c594f72-ba58-43d3-8d25-f09ec6729d33', 'My Cases Created', 'daabb18a-1b87-4611-90fe-1020c7d9708f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFSTGId, 'eaee3cc8-0a1e-444e-9137-780324ed1f67', 'My Cases For Approval', 'f253a547-aea4-49ea-a00d-c30eeedd5554', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFSTGId, '2867b702-370a-4240-9d46-c5ed9df47662', 'My Cases On Hold', 'f024072c-b364-40f2-ad4d-7340c0c7cd44', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFSTGId, '4bcad4ec-8c24-4a1c-8a7f-ad27f014720c', 'My Cases Unassigned', 'b01e12f8-7b85-4541-aa36-953a66b7633c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFSTGId, '2b01bf0b-67f5-4793-a216-22fd8e9b9ea9', 'My Individual Case', '8d0aab89-96db-4e34-a0a3-25279ee562cd', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFSTGId , '5d6b4e55-8bdc-453e-8d52-4b806706d3e2', 'My Claims Tracker', 'f1785d1f-a5ea-4aac-8841-0647a354c751', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFSTGId , 'b932e146-6e18-4920-9078-434846d04083', 'My Incidental Tracker', '9fe27d26-bbd3-4752-bc10-6a0279ef3a9c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(),@WFSTGId , '7a0cb347-a75d-45eb-817a-c3cef9cc5abb', 'My Unpaid Amount', '277b9d0d-eaba-41e7-a092-2c0d8168bcac', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFSTGId, '2f34475f-4a65-4e73-8f2a-4f18fa88cd83', 'My Invoices Generated', 'f5e587b4-2dc0-4ef4-a212-11732be3d8bb', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @WFSTGId, 'cd48c4fb-947c-4610-a4fa-c4544f118106', 'My Invoices Not Generated', 'e8aff06c-6a19-407f-9f88-5a9c5cb69c32', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @WFSTGId, 'e16941ca-b42c-4047-99e2-1e904a9155e0', 'My Actual Contribution', 'de973092-690d-4d4e-af4d-01894eccc697', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFSTGId, '0433952a-ee3e-4b7e-9b78-b7fb2fb4bd3c', 'My Actual Chargeability', '139d8716-0a91-4da1-8e3d-0a173e68e26d', 'STG')
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @WFSTGId, 'ecba0200-362a-4384-84b3-41f296776cc8', 'My Planned Chargeability', 'faca70fa-e475-415f-9577-69c07dec2a1a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(),@WFSTGId, '386191bd-be94-442e-9844-c8b32cc45eaa', 'My Planned Contribution', '03f9aabd-0c2c-474c-b4f9-fec0a65b0bdb', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(),@WFSTGId, '1b475178-a8a3-4515-a700-56988fbd1db9', 'My Recovery', '357a9d25-cb50-414f-b105-8b3a50a83798', 'STG')

--==========================================================MY HR================================================================================--
--select * from [Common].[ReportWorkSpace]
--Declare @HRSTGId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='STG' and WorkSpaceName='HR_MC04')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRSTGId, '300d8718-158d-4578-8cb9-113c28fcf8a3', 'My Attendance', 'a4563c97-ef8b-4c74-bea0-2ed469739b87', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @HRSTGId, 'd06d31fe-6415-418c-a9f7-a05945323133', 'My Claims', 'fb1176e4-262c-48d9-8720-b2475c9f64b5', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRSTGId, '992e542d-c0e2-4677-8080-ecb6a1a8b6f4', 'My Leaves', '4a63078b-9fc3-4cd3-a3e9-9f0d56bdaa08', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @HRSTGId, '06a4641a-449a-4979-82b4-38677b9c2b32', 'My Profile', '37fd0b6d-265a-4b71-b91c-88ba13d77093', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @HRSTGId, 'cf24b8a2-5b7f-4533-919b-6995e2e1d369', 'My Trainings', '95c91dc0-1b22-4efe-a132-d4245b3589a3', 'STG')


END
GO
