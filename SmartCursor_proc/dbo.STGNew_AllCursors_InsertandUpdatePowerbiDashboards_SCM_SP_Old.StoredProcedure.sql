USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[STGNew_AllCursors_InsertandUpdatePowerbiDashboards_SCM_SP_Old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE Procedure [dbo].[STGNew_AllCursors_InsertandUpdatePowerbiDashboards_SCM_SP_Old]
AS
BEGIN

--Exec [dbo].[STGNew_AllCursors_InsertandUpdatePowerbiDashboards_SCM_SP]

 Declare @CCSTGId uniqueidentifier=Newid()
 Declare @WFSTGId uniqueidentifier=Newid()
 Declare @HRSTGId uniqueidentifier=Newid()
 --Declare @BCSTGId uniqueidentifier=Newid()


-----=====================BC-STG


  INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@CCSTGId, '2ee8a649-a138-42df-9829-21cdf4921010', 'STG', 'Staging-CC')

    INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
    VALUES (@WFSTGId, '375e2c21-53d2-4530-a899-d1b960589bcd', 'STG', 'Staging-WF')

    INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@HRSTGId, '7963cc98-86a4-4273-8bd0-c9c48c6520bd', 'STG', 'Staging-HR')

   --INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   --VALUES (@BCSTGId, 'ddd71a49-f56c-4e80-b549-c46bf02649f5', 'STG', 'BC-STG')
   
   
 

 -------------=================================== Client Cursor =======================================================================
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCSTGId, '7b061ff1-3678-4398-90d9-73f177486cd6', 'Accounts Inactive', '057fec47-9622-4ac8-a15f-9c16d82341e6', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCSTGId, '80a9a0dc-f684-4f79-a8c7-2e2abad7d37c', 'Accounts Lost', '8b1fe36a-b93f-48a9-8779-e162838d411b', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCSTGId, '08c0486a-6da6-42c8-821a-ff2c5d6a5005', 'Accounts Now', '22167df1-f1fc-4669-8904-8b363c687955', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCSTGId, '72cde13c-646e-485c-be94-1e783e47a4af', 'Accounts Re-active', '4d75e576-d7ff-4f99-b982-2c041966d451', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, '604bde4f-11dd-4d72-8e47-6709d28fe8f6', 'Accounts Won', '0c9cb5e8-34f2-4437-8d3b-efa69b6cc7e3', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, '9d5bfc72-050e-44a7-96be-8b73ffd67de6', 'Campaign', 'af84b853-bf97-4902-aa84-e99bf0aa0257', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCSTGId, '574ce83c-f497-4cdd-bab3-f5df2368613b', 'Individual leads-Accounts', '84ee6fc8-130e-4502-839f-9dd23eb2e049', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCSTGId, '7d6d93ed-e7d6-49ae-b769-9515304e5005', 'Leads Created', '8d5e2aa0-7bed-4bba-b297-f402887016dc', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCSTGId, 'dfc866c6-c67e-498e-99fe-3f9c97d1fd8b', 'Leads Lost', '6e6b9df4-7e8a-4bae-85b6-205780e11cb9', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCSTGId, '373e4ba0-16fe-4516-8c6b-720cbe6a299d', 'Leads Now', '065eec91-0a78-4477-baec-1cdc8c0c43ce', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCSTGId, 'a2a4d7e9-48f5-4720-ba09-58cc4bec01f8', 'Leads Re-new', '24fd8563-abd2-4290-be40-8d3b7b1bc612', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCSTGId, '2afd3404-51f6-46d7-9f1e-3f6daf1cfe23', 'Leads Won', '7dd9073c-e41d-4947-8c0c-120095423fa7', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCSTGId, '77a605dc-8075-42c8-923c-7d68f79e6fdb', 'Opportunities Cancelled', 'a72aa54b-c584-441e-b39e-50eb235ad4e3', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCSTGId, 'ccbac485-7022-4dfe-ad3f-af0765372cdc', 'Opportunities Complete', '1125bf49-18af-4d9f-9d3e-566e9b1480e4', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCSTGId, '71deb4c0-58a3-4960-bbce-4ea80618f07b', 'Opportunities Created', '0bbc1d85-3840-4f39-8500-c69a3434ffdb', 'STG')---?


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCSTGId, '1ac1351c-d400-465c-8874-3ff1aa18cda5', 'Opportunities Lost', '8f9da1f7-6d4f-48f3-a640-8edb43ccc98c', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCSTGId, 'dd088905-5ad6-456f-9446-49607a77a630', 'Opportunities Now', '960b20d7-621a-4d09-8049-edabb7d8cb51', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCSTGId, '63213799-f9fb-4fbb-a031-23301f929bfa', 'Opportunities Pending', 'a6d99b8b-04c6-4a5c-95d9-a24fcea7d648', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCSTGId, '6d0ca41f-9374-4e47-8150-43054c9c6b2d', 'Opportunities Recurring', '28222c8b-5f90-4657-9c43-3817fa063c2b', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCSTGId, '6b711c59-6ef6-4503-9dcd-a7d18f07cca9', 'Opportunities Won', '90322979-ad92-4e81-84d4-94b1bb1ee8d5', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @CCSTGId, 'a8f1204f-d0e0-4455-b217-72534ed6955e', 'Vendors', 'd8cf79ac-6bd9-4e13-85d9-8ef464e01f80', 'STG')

 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
 VALUES (Newid(), @CCSTGId, '58b0e153-5174-4810-b71b-5e818840a41f', 'Account Details Report','25c69e1f-6d21-42eb-87f6-53d37a19b857', 'STG')

  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
 VALUES (Newid(), @CCSTGId, 'a0ea6d48-5bc2-4cbd-a0fe-250cfadfc77a', 'Leads Details Report','11a0f84e-f1a2-4e66-aa1c-f4a276cc3611', 'STG')

 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
 VALUES (Newid(), @CCSTGId, 'bb38a1f9-b6f9-4439-b6a9-f6e56f2d6366', 'Contact Details Report','fb13f4de-10fe-4e3c-b85a-53d2887287f3', 'STG')
 --'7101f607-5723-4b43-bb37-66cf9ce1e570'

-- ------===========Work Flow STG---===============
-- ----====================================================================
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFSTGId, '28d6655b-ca99-4063-85ab-6827f7db74d3', 'Actual Contribution', '5f6df36f-e26b-48f9-acdb-19ca8a74ffcb', 'STG')
   
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
--VALUES (Newid(), @WFSTGId, '5177c123-78df-4a88-95c4-0bb5bf97602e', 'Actual Contribution DeptPOC','d25a7dcd-8cb6-45d2-b595-4cc8691396f7', 'STG')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
--VALUES (Newid(), @WFSTGId, '54838a3d-2135-4ec0-853d-16a6302e127f', 'Actual Contribution POC','10a9916f-0bb3-4cf9-a0b1-bc17130af103', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFSTGId, 'ecfcef36-ed37-4596-becc-912263bae90b', 'Cases Approved', 'b5e5892a-5cac-4041-b5fe-547959b78fca', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFSTGId, 'd8f97786-c144-43cb-9e61-72246cc473da', 'Cases Cancelled', '327233e8-a842-4c4e-91cf-e87f84ee1d3f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFSTGId, '8b1c3d08-cc72-43fb-90b0-db8539ee6dea', 'Cases Completed', '2352cc42-a210-41af-876e-e2b9ce0ef7d2', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFSTGId, 'e7ad833a-0abd-4582-8d19-b942037e694d', 'Cases Created', '4a8b1ed6-f2c5-41c8-b82f-aa02265fa63c', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFSTGId, '9019c9dc-06fe-4d00-bc27-cba9bc1e53b6', 'Cases For Approval', '8bb68c0b-aaa7-47d3-9963-2eb85fef36a9', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFSTGId, '848f59b2-577c-47de-9658-1ceb4437e3ff', 'Cases On Hold', 'b8ef7c5d-c689-4a41-a793-8a8579ed4b9b', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFSTGId, 'e2459040-8808-462a-b459-5dbeca996b08', 'Cases Unassigned', 'c1f5ee3d-83d8-4fc6-b24f-1b6cd0ef8416', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFSTGId, '248981c0-7846-47f8-81ac-e278c242e60b', 'Actual Chargeability', '2d185a57-d550-4c4c-8a71-3924e392ee93', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFSTGId, '216b9f66-45a4-4fba-a54e-70968065f1e4', 'Claims Tracker', '79cde86f-27f7-460c-a234-0af19c57e899', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFSTGId, '0010cd80-26eb-4bca-8a8e-1519e94af9a3', 'Clients Created', '3d8f7022-e9bf-4a14-a9f3-4cffb18aebca', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @WFSTGId, 'dc27a6f5-6bca-43f1-9480-46d7b0997bf1', 'Clients Inactive', '248610fa-05c1-482c-9255-00683efbf1e5', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @WFSTGId, 'cce09839-dcca-4748-8fe5-331baadb9914', 'Clients Now', 'f0c59192-a05f-4589-bd4f-5d9ed2a1304f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFSTGId, '017e4320-fab2-454c-90ab-7c752e82de00', 'Clients Re-active','1e283b4a-38cc-4658-932f-91d9dad5945f', 'STG')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
--VALUES (Newid(), @WFSTGId, '739d022f-3933-4732-b31f-5fb11d32d0a8', 'Incidental and Claim Tracker', 'c518ad2f-f0e4-49a4-9111-56cacee91604', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @WFSTGId, '71a80664-479d-4d33-9ce5-27a15c09d1e0', 'Incidental Tracker', '481e2b19-a89f-4722-81a9-18868c668a60', 'STG')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
--VALUES (Newid(), @WFSTGId, '9166212c-5357-408d-a13c-1051867d30f1', 'Individual Case', '7782d34a-8e30-45ea-abd3-63166e3e860a', 'STG')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
--VALUES (Newid(), @WFSTGId, '282a2da0-47f7-4d75-96f0-85afe6317fd4', 'Individual Client', '1b1597d6-0c90-4bff-b9e6-74fa8bc0a365', 'STG')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
--VALUES (Newid(), @WFSTGId, '4ad4ac72-c57d-4434-acda-3782976c6269', 'Individual leads-Accounts', '4d2f0072-c13d-4bf4-99fe-c9b33e201d9d', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFSTGId, '144a26bd-a809-4d9a-87ce-5435b42cb7c8', 'Invoices Generated','d74a2635-20a4-4ae2-aac1-5024921f8290', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFSTGId, '7a747f04-15ed-4ee9-a578-2d3d16659ca4', 'Invoices Not Generated', '827d1219-79e1-4ba4-81ab-a1552d75bb8d', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFSTGId, '43c025a9-bff9-4bcd-8fb0-0f73c2484bab', 'Planned Chargeability', 'c2fba228-6982-4ac3-8f28-a9eb89236800', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(), @WFSTGId, 'ce9f719d-34a0-4e57-a680-fe398210e899', 'Planned Contribution', '80ecda17-08b1-4431-a729-bb6ebe7d7379', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFSTGId, '357e325c-c701-4b67-a9a9-597ca0eae069', 'Recovery', 'd4ae457c-8a5e-4c75-9218-db806eeaedb5', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFSTGId, 'cb99ea70-c4d0-4215-9fa8-35e25c61a50b', 'Unpaid Amount', '0656cb9c-a973-4f79-8b85-41d1a14d4744', 'STG')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
--VALUES (Newid(), @WFSTGId, 'b144891f-5f41-4cc1-9774-c265ead1c01e', 'Timelog Detail Report', '0e51bd63-f391-4772-9ad4-b2a42b51af65', 'STG')

 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
 VALUES (Newid(), @WFSTGId, '80007ac1-7469-41fa-9fff-1cbc95fc99ae', 'Cases Members Report','7deb9cb2-1459-4c3b-9ed1-4f12cd60bb39', 'STG')

 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
 VALUES (Newid(), @WFSTGId, '10cbbdb0-63e1-4b5c-a361-28a70d9c7a34', 'Case Details Report','b4ba0e88-6adc-41bc-8f05-481a3f11d9ce', 'STG')

  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
 VALUES (Newid(), @WFSTGId, '6aa43f61-e360-4fd4-9891-89f1c25f335f', 'Client Details Report','7a8a4612-3378-46a7-b4f4-c70788dab1ae', 'STG')

 -- INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
 --VALUES (Newid(),@WFSTGId, 'e07adc6c-323d-439f-8764-56fac12de084', 'Client Contact Report','9a078c91-415c-4c8b-82cd-d86389f2ae6d', 'STG')

 

 -----===========HR STG---===============
----- =============================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRSTGId, '98521e75-1b45-4317-813e-7be3925c0a67', 'Attendance', 'be3eb5f6-fffc-454f-a280-5078d5b6517a', 'STG')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
--VALUES (Newid(), @HRSTGId, '8a109e9c-bb5f-4793-9a9e-a34aa2e1b953', 'Attendance  Dept Poc', 'd43cc00d-28b2-487e-861a-1fe7de25023a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @HRSTGId, '0f767b80-d779-4ba0-8689-a93f87ff68fe', 'Claims', '3e2a4ed3-f471-4bea-8242-b683d5bc717e', 'STG')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
--VALUES (Newid(), @HRSTGId, 'eac96a5a-90fb-4a08-a1fc-6c6144649a53', 'Employee & Department Detail', 'eef24503-dce9-41b3-bd5f-37f7d8edc1bb', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRSTGId, 'f7495cf7-8bcc-420d-b834-ec99c55bf145', 'Employee', '93333587-166a-4cc6-9fba-5c35274acbe3', 'STG')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
--VALUES (Newid(), @HRSTGId, '7108129f-0cc1-41bd-a944-00c766b9a908', 'Individual leads-Accounts', '4f9a7797-6b30-4d1e-aa1a-4940420b586d', 'STG')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
--VALUES (Newid(), @HRSTGId, '6c756404-0dfc-4b37-a534-97903987dcfc', 'Leads Creation', '6f02358d-6ebf-4918-939c-22da0b462298', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRSTGId, 'c3262949-0a74-4f18-bbfd-4501fa1b39fc', 'Leaves', '68e07f7c-7136-4ae7-aab7-efb0cab460a2', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRSTGId, 'db6b388b-5f4f-4963-b921-78682c16bf51', 'Recruitment', '1d44378a-cde7-4fa7-9e5b-40d7ddc945be', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRSTGId, '780abdda-b2c4-4af3-8e23-2cd9770d6654', 'Training', '418522fd-70ad-4894-8828-75f323f380a2', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRSTGId, '6401a3d9-de17-4b8c-ba53-c070d3cfeb95','Payroll', '86b2b812-aa14-47bf-8196-22ffbfc02038', 'STG')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
--VALUES (Newid(), @HRSTGId, '34ca09d1-cce4-4c4e-bd82-07e833c77042', 'Employee', '8b23c0e7-7304-4548-b161-d15caba5a33c', 'STG')





END
GO
