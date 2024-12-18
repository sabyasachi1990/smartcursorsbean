USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[STG_AllCursors_InsertandUpdatePowerbiDashboards_New_SP_Old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE Procedure [dbo].[STG_AllCursors_InsertandUpdatePowerbiDashboards_New_SP_Old]
AS
BEGIN


 
 --Declare @AuditSTGId uniqueidentifier=Newid()
 Declare @CCSTGId uniqueidentifier=Newid()
 Declare @WFSTGId uniqueidentifier=Newid()
 Declare @HRSTGId uniqueidentifier=Newid()
 Declare @BCSTGId uniqueidentifier=Newid()


-----=====================BC-PRD
 

  --INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
  --VALUES (@AuditSTGId, 'd9cc1dd9-3ec3-4223-ad93-33b4bbb04b0d', 'STG', 'Audit-STG')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@CCSTGId, 'f3126b45-ea01-42ec-8de7-b8db2f420b97', 'STG', 'CC-Staging')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@WFSTGId, '51aef36d-747e-4812-843a-050ced08bacb', 'STG', 'WF-Staging')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@HRSTGId, 'eb328f9d-4259-4616-8c0e-5c359ddc3d54', 'STG', 'HR-Staging')

    INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
  VALUES (@BCSTGId, 'aa104a9e-1921-4804-939e-bb00a82b3e34', 'STG', 'BC-Staging')




   --======================================================= Client Cursor ======================================================================================================
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCSTGId, 'e43e0de0-d247-4334-8410-6d19c529d061', 'Accounts Inactive', '4021b73b-1bfa-4302-ac66-de47719fb0c6', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCSTGId, '15b2c413-ca2a-42c7-bad1-e5e453309a68', 'Accounts Inactive Report', '55b7795c-9e23-42a9-a59b-1fa4a5708ee8', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCSTGId, '3bf647a0-6fa1-42f3-b84a-e1c53537dffe', 'Accounts Lost', '5068f90c-69fa-4769-818c-d1bda9fb9d22', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCSTGId, 'daaaf74d-49c9-416f-ada1-4a434d027846', 'Accounts Lost Report', 'c191e24b-66c7-4b5e-bdf7-ab725c2a9277', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCSTGId, '2a0f5aea-b6eb-4cde-9c44-397135f52b07', 'Accounts Now', '322ba9d4-93f9-486a-9201-cc84652e766b', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCSTGId, '76dd0239-368d-4376-9f61-08b05e2d7655', 'Accounts Now Report', 'cef0600c-89a0-4fd6-89a3-50063610a80a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCSTGId, '18ed9f53-2ef9-43e4-9c88-be6a8949cf82', 'Accounts Re-active', '413952ec-be9e-4b94-8711-649a1171e237', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCSTGId, 'd0bb69c1-9185-4b9a-8b5a-0ce7e3b13efa', 'Accounts Re-active Report', '1ee1b374-9dbb-4991-95f5-ccb0bbc52691', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, '627945b4-dabe-4266-afb6-61c5b89f07be', 'Accounts Won', '385c2671-1593-4c81-9324-a168923cde84', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, '4b3f82b7-d80e-42ff-b440-0f03970e7015', 'Accounts Won Report', 'a6a64ae4-0566-453c-af82-f13d3cb3f56f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCSTGId, 'fefdb705-e3cc-436b-b536-c703ba22baef', 'Individual leads-Accounts', '8682c694-40b6-4121-a861-31c7fe29c9e9', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCSTGId, 'c65a0cd4-74a5-463e-adc7-82d5f655f8cd', 'Leads Created', '232c77d6-a275-42b8-bade-ecaf0c65509e', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCSTGId, 'ff3384d2-877e-4a68-ba8e-4e7cbfec29c4', 'Leads Creation Report', 'ce29dc23-a905-4dd0-afdf-0928625fd728', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCSTGId, '1baf6af3-2e3c-48b4-8762-ec6c461c19f0', 'Leads Lost', '75af6b93-1fa4-4304-9d5f-7385fc7cd3b5', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCSTGId, 'df2a1593-7cae-41e3-8b82-f5e68ebaee8f', 'Leads Lost Report', '192fdd2c-656e-40df-91e4-ce72fee235be', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCSTGId, '2b6ff3d1-4ec1-4aa9-8092-ca0e1ab5c132', 'Leads Now', '1c525baa-e725-4bc2-a6e5-43077bebd855', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCSTGId, '474006f8-9371-43e9-9c33-9b36a0c97db9', 'Leads Now Report', '85f2e819-0fb1-4fcf-aa93-fe2d4a63ba90', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCSTGId, '75225687-0fac-4112-8e82-cd14a9b2554b', 'Leads Re-new', '6d54a0fe-7642-42c4-95d4-713f644c015c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCSTGId, 'c5384dc2-790f-4f86-a47c-675d5d30b5ba', 'Leads Re-new Report', '231fcefd-ce0d-481a-acb3-a7e0d64a22e6', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCSTGId, '7d5279d8-2223-4ff1-91ce-0f7fcc7884ee', 'Leads Won', '830686ed-8548-4983-9cb3-7188a3f2b7fe', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCSTGId, '3628dae3-a7e4-461e-aaae-9deee9c4641b', 'Leads Won Report', 'c9539770-31c0-45d2-8cc7-831784e92e12', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCSTGId, 'cf14873f-5d7b-4d7b-af88-4415e83a22d3', 'Opportunities Cancelled', '8b24835c-8e1e-4c2e-9e2e-a0f6d4d3356a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCSTGId, '09bcf9fa-2d31-46a6-badf-a4f4c12598a9', 'Opportunities Cancelled Report', '35c4266c-6a8e-4490-97d7-ea264dc5e4b3', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCSTGId, 'd7820901-6996-45e8-8a09-7b327992629b', 'Opportunities Complete', 'c1aa3494-32c3-4e16-aa6b-9de81141d019', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCSTGId, '243f300d-4b46-4b3a-9867-7cd0bc597656', 'Opportunities Completed Report', '5ddfa742-6692-48c1-8fd9-4d3cc7654f50', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCSTGId, '4e12e389-0dc9-47cd-9314-962bcd14f45c', 'Opportunities Created', 'a8d86c07-bc7c-4ce9-af3e-49241270c80d', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCSTGId, '44683d7f-31f8-4b31-ace2-a29bcbf9ed79', 'Opportunities Created Report', '1f127d38-9e25-44f0-be62-aa1f2f999a25', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCSTGId, 'e74e15d6-118c-4655-97e6-282c65b511be', 'Opportunities Lost', '326e7adc-5d68-4c30-85b4-e6ed1b097bb8', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCSTGId, '4d965524-924f-4e25-9d3d-4def3bf8124f', 'Opportunities Lost Report', 'a28b9653-ba93-4911-9e45-fdc78a87dd89', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCSTGId, '42a552c1-37cf-42f2-8da0-b3fa3e4a5436', 'Opportunities Now', '11a9f6f8-a321-4b1c-93be-4c662d3dae8f', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCSTGId, 'f4fe9793-89a7-4026-8786-5669b27e3e49', 'Opportunities Now Report', '16dcdef3-8155-453a-b5bd-86e3682b3efc', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCSTGId, '32c817e0-79a3-4aa3-993c-fc7094fba4e1', 'Opportunities Pending', '10026947-4c62-4f55-9986-3c058f16d713', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCSTGId, '0a4b62a8-9f3d-4cd0-a6db-c354371bcd06', 'Opportunities Pending Report', 'dbd8159f-e528-40b0-a8cf-b7f9c340c104', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCSTGId, '545fcf53-b13f-409d-97d4-0b755e80a713', 'Opportunities Recurring', 'e1840f6e-c725-4b49-91ce-31eef08cb856', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCSTGId, '43f64bc6-0996-4958-a422-4a8a00c0abbc', 'Opportunities Recurring Report', '87aea838-130d-4a04-abef-cff6ae64c797', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCSTGId, '9e1fbf40-d9aa-4f3a-ba30-2bf913213b3c', 'Opportunities Won', '8d9a5f0d-5589-40b1-9404-98b302559efb', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCSTGId, 'dde20e6a-41e1-42a2-88bd-7879432b401c', 'Opportunities Won Report', 'f1426f66-f134-43ba-927e-1661616585cb', 'STG')

 
 --===========Work Flow PRD---===============
 ----====================================================================

 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFSTGId, '86ac489d-28a7-40ca-b9fa-657b38c9a9d3', 'Actual Contribution', 'e0cead89-3ea7-4c35-8a49-48fd2837481f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFSTGId, 'e856cc9a-183f-4d9e-9dee-875bd85ba4ef', 'Actual Contribution POC', '962afb82-bbde-4551-8500-79f051935ff9', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @WFSTGId, '5ea0cdde-70ec-41d5-a019-bfc88a496003', 'Case Members Report', '29301565-fa5c-4dec-bfef-8848327b83c9', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFSTGId, 'dd687002-08fc-4113-960b-65135ae7db77', 'Cases Approved', 'dd2c4a9a-0570-4234-aa0d-10582916f719', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFSTGId, '5dfc52e1-24a9-4ea2-babb-3e211a17c7ab', 'Cases Approved Report', '117d800f-c7a4-460b-902f-4dbdf4c472a2', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFSTGId, '5e5f8e58-f7e2-4325-ba1a-9ba02b0ebf51', 'Cases Cancelled', 'fee29433-cbce-4f3a-8c25-dc08c033492a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFSTGId, '3a02ff8c-463a-4e40-bd5c-5307c4799d79', 'Cases Cancelled Report', '10a1a5e9-ecec-49ec-9efe-18541fc0a261', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFSTGId, '0fcef0af-3f4f-429a-a8be-17bbbfd09624', 'Cases Completed', '2ec779ef-1463-48ab-a591-475de1b03068', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFSTGId, '328ab635-eeae-4862-bbfb-0ed7f75d5db2', 'Cases Created', '3bc6c5a6-0ad5-4a6d-8581-30009faacd67', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFSTGId, 'd2c8ae0d-de20-4df9-b682-107ce1667e4f', 'Cases Created Report', '5da1fcfd-4f54-432d-8e28-0b9313e26504', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFSTGId, '30e5faec-0403-46b1-92d2-3adbfe3a3957', 'Cases For Approval', '6c40c2e5-f88d-4fd7-8a64-061f68f1f015', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFSTGId, '2222d02c-abb5-453c-990b-25f21ed30df4', 'Cases For Approval Report', '6853fc27-b8cd-4567-834f-b1e50abeae6e', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFSTGId, 'f5c1f055-51eb-4c4b-b518-2173babd6f09', 'Cases On Hold', 'fc10ef96-14c4-411f-ab63-413ec90e15b6', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFSTGId, '1f890cf0-bb97-4c77-a08f-b67d328f49ef', 'Cases On Hold Report', '90389c43-6ccb-4be5-87f1-41b3d9562f28', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFSTGId, '0aa13a99-ea78-41de-8a77-2417ae474f50', 'Cases Unassigned', '72e476ba-bbbe-4212-a4ac-c722ef64bedc', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFSTGId, '5b11cf96-db43-464d-98cb-06ee019da1ee', 'Cases Unassigned Report', '0a15e186-150b-449f-8df9-b1c922b0fe32', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFSTGId, 'f16cb314-5865-415c-bbb0-762c1b174f5a', 'Actual Chargeability', 'c5a2ccf1-2422-4a5c-b10e-bfff751af55a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFSTGId, 'd7e24011-9694-4339-a97c-5edf956f278b', 'Claims Tracker', '1330ec64-233b-4ecf-a297-0b9fabb3f6f6', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFSTGId, '8953a19e-75b5-4c05-a369-86040e7bc6f8', 'Client Contact Report', '9e3207c2-6a00-4c80-bdee-1416c088ee69', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFSTGId, '7a1f402f-2cc0-499d-9e69-5bf78328cc9e', 'Clients Created', '04d75559-f8d0-43f0-b064-3e8de18255f3', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFSTGId, '74011ee9-6854-4181-9071-96bfcac20bd1', 'Clients Created Report', 'f2702bdd-44be-423f-a80b-48556021368f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @WFSTGId, 'f98c13ea-d751-4eb2-b309-9f06c764cdcd', 'Clients Inactive', 'b53578dc-3bff-4f7d-84ed-87fe6a8a0754', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @WFSTGId, '05983284-4a9d-4c21-9de7-6465209e1bf8', 'Clients Inactive Report', 'af1d892b-9d6a-40cc-8085-57886a53c91d', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @WFSTGId, '0d0a2eaf-63a4-4fab-9d74-a4631e5d5d03', 'Clients Now', 'aa3a0752-7f1e-49ed-8f00-01feb58dc8d9', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @WFSTGId, '91648f05-db04-4b20-8b74-ae67890e931d', 'Clients Now Report', '76a44de8-7658-4643-8e56-0215a1322dc8', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFSTGId, 'e9d858de-2b7a-476a-b142-98dc53d482ab', 'Clients Re-active', '1dd73682-4d9a-436b-9839-8e48fb24cf0e', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFSTGId, '7dccc36c-62e1-4da6-bc25-603466a26089', 'Clients Re-active Report', '88f34d78-e548-4058-9115-515c79e007e8', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFSTGId, 'e5e5723e-d6ba-4fbc-8f70-92cba9afd359', 'Incidental and Claim Tracker', '0e61bf40-03b4-4a23-a1a1-e343c2257b03', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @WFSTGId, '9621f2a9-b695-4b91-a3a1-3e36019be752', 'Incidental Tracker', 'ec1116dc-e40a-403f-a2e9-7f6516f26d7d', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @WFSTGId, '05db0fdb-40da-420a-92ce-6cfb4c370790', 'Individual Case', '4f6a42d7-e586-4172-adaf-e0bc51fb5c0e', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @WFSTGId, '719d1fd8-b68b-4e5a-9db6-d4eb3edaa235', 'Individual Client', '0157de79-74d1-4d97-bdde-776f448b07bf', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFSTGId, '72a49f6e-c138-44f9-9bfe-460af27531f4', 'Invoices Generated', '9208dbe7-5d59-4283-a942-48a89aa04498', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFSTGId, 'f626ebdc-46b0-400b-8602-10e8ca4b86a8', 'Invoice Generated Report', 'd01fdc36-190f-4dd9-a67c-27d51574ea76', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFSTGId, 'e2af36d4-8833-4955-9920-367f91d82473', 'Invoices Not Generated', '121f67f2-9c13-4dd0-b0e2-5543c7372d6d', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFSTGId, 'e82f92fc-fcdd-4393-a534-ef6d23d5f2e4', 'Planned Chargeability', '2451f2ce-cc36-46a7-808a-d8c5d54b85f2', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(), @WFSTGId, '9d4f7026-f5a9-4192-83b3-959e6e28e6d2', 'Planned Contribution', '1ebdeff8-e907-4c69-a994-c4e14b6b99df', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFSTGId, '55df38a0-6903-4aa6-b306-cf97cc8823e4', 'Recovery', 'd922cd16-10d7-4661-883c-95eddb2101f8', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFSTGId, '7b2d0b40-3153-4b64-b6df-d157f55e2b6d', 'Timelog Detail Report', '404bbc5e-bcc6-4b92-97c1-cba682d7978e', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFSTGId, '07e9f906-f68e-47d5-8eb9-8da05e30eef9', 'Unpaid Amount', 'cb8926d2-1465-4762-afcd-b2319c1b948b', 'STG')


 --===========HR STG---===============
 --=============================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRSTGId, '5dded5b8-308f-4c6e-b4cf-e4ac83770763', 'Attendance', 'e33e1d79-fbe9-4fa4-a43f-bf7f26eb568c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @HRSTGId, '2d15545c-7d31-4317-bf68-cdd47b5af0fd', 'Claims', '7d3cf163-f419-4257-bc5c-410e0183d332', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRSTGId, '839a593b-97d9-4552-baff-fad55a5d3859', 'Employee Details', 'd68e4d40-e669-4eb0-a8ff-6802a82b8a9b', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @HRSTGId, '0a89e1ff-f954-4d01-bdb2-aa0c3d6da343', 'Leaves', '36f79183-91e3-46d5-ad09-5124b0b15d57', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @HRSTGId, 'b44f7355-babd-4027-be17-a131e9ce7a54', 'Payroll', '6f88df36-c629-453a-8960-9ed2340cbc54', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRSTGId, 'a0d07785-2204-4711-a5b9-7a042668c3a2', 'Recruitment', '5b98c4ec-4f84-4ace-b8e4-74a03017e95c', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRSTGId, '501292d9-4034-4f75-b26b-c2fbffb303c7', 'Training', '603f77f4-7e94-4603-8716-86391c8d2878', 'STG')

--  --===========Bean STG---===============
-- ----====================================================================



INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @BCSTGId, '5cbc20a8-5f22-4f9f-b671-4092d6786f9e', 'Bank', 'df15c9fa-444b-429d-81c2-a3d18e65b3ee', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @BCSTGId, '91f5f890-379b-4f19-b981-a3976cbe1e13', 'Cash and Bank Balances', 'f559a2ae-1428-4976-9ae4-ee65f04bab69', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @BCSTGId, 'd2c87571-314b-4464-945d-7e0d9ae62d22', 'Customer', '4d1ecb65-5402-41aa-be11-2372ad379b23', 'STG')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
--VALUES (Newid(), @BCSTGId, 'af583e86-0a24-4246-b0ee-ef37d67473b7', 'Customer Aging', '995d4710-9c2b-4b5d-9b88-d6b5e81bd835', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCSTGId, '1ebc20d1-7719-44cf-bdae-8d669a764ab0', 'Vendor', '2e72d226-ac54-43ee-8517-c12b59bc2949', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCSTGId, '9cfcd8e2-32da-46f5-9f11-c4ada2852880', 'Financials', '642f1500-2dbf-46ea-bc1e-b7fde28c567c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCSTGId, '81a52e6f-6209-4634-9aff-df18c125fac3', 'Bill', '2308c6d5-2712-41f2-8d54-ec216ee336cb', 'STG')

--------


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCSTGId, 'c5e0de64-9cf3-488f-95b3-750edc8523ad', 'VENDOR TRANSACTION', '1c851257-60dd-44ea-8f85-7356e2037098', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCSTGId, '53346538-9145-4891-9b9a-0083fd36971b', 'VENDOR BALANCE', '0558e769-e74a-426b-9fbd-6d043dbc9c3b', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCSTGId, 'd1ea5e2f-cf6a-4c28-9a74-50db26f1a3e9', 'CUSTOMER BALANCE', 'd47d5bd0-8230-4800-b5d5-58878bb85add', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCSTGId, 'c393f98e-774f-4209-b9b6-5509f4faf4cf', 'CUSTOMER TRANSACTION', '8139d7bc-599d-4bf7-bf42-ea9dfa30aebf', 'STG')

----------------------=========================---------------------------

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCSTGId, '4fea657f-07a5-4c07-8c62-58ddc9b21799', 'Cash And Bank Balance', '725ff95b-4759-4fc3-998a-5224373cfe54', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCSTGId, '252887f4-184c-4706-afbb-1e004c7b8e18', 'Cash And Bank Transaction', 'da2dd57e-818d-4a31-a8cd-c070dbd40bb9', 'STG')

--  --===========Bean STG---===============
-- ----====================================================================

-- INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
--VALUES (Newid(), @AuditSTGId, 'e334e7a5-9e1e-4944-9bd0-1723d45ed05d', 'WorkProgram', '4f492e69-9bec-418a-99e6-c30c7805a872', 'STG')


END


GO
