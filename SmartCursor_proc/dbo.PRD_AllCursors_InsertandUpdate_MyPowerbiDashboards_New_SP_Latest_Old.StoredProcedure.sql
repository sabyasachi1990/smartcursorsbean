USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PRD_AllCursors_InsertandUpdate_MyPowerbiDashboards_New_SP_Latest_Old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[PRD_AllCursors_InsertandUpdate_MyPowerbiDashboards_New_SP_Latest_Old]
AS
BEGIN


 Declare @WFPRDId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='PRD' and WorkSpaceName='Production-WF')
  Declare @CCPRDId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='PRD' and WorkSpaceName='Production-CC')
  Declare @HRPRDId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='PRD' and WorkSpaceName='Production-HR')

  -------- ==================================================MY WORKFLOW

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, '0998a69f-f859-4a0f-b369-1e1ecb0dff95', 'My Actual Chargeability', '216b865e-dd33-4203-8094-7eeae6c8419f', 'PRD')
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFPRDId, '42c7205a-afc6-4369-bb0b-4f717e6698b4', 'My Actual Contribution', 'ecf22787-a258-417b-9366-9b633ffa348d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFPRDId, 'b71a00ff-4417-425f-a5ff-36b22de3df16', 'My Cases Approved', 'dd749333-5edc-4764-9c6b-29a37b65cc74', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFPRDId, '84f296e1-fbb1-4a42-8a20-b5d17ebf4acc', 'My Cases Cancelled', 'd62380dc-6746-4450-adb0-e437fac28aa7', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFPRDId, 'e7fb4909-113f-4663-b395-4188aa74f819', 'My Cases Completed', '99ebf5a8-e6c7-4a83-82ad-0de8fa51cdaf', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFPRDId, 'd0b607d7-2cf8-4b61-b354-292c7aaec6dc', 'My Cases Created', '6224da5f-ea99-4c74-b2b6-9a2996825270', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFPRDId, '4d2ca0ca-9f1b-43e9-9315-ed9cfbe3c480', 'My Cases For Approval', '2936f997-e32d-41b3-8f29-72732d8c486f', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFPRDId, 'c566300d-6e79-4bf2-af59-fdb5fe0edeb5', 'My Cases On Hold', 'cb8d4829-7ccd-4640-993d-37c3acef0c2d', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFPRDId, '041b294a-03ac-4949-b3c6-a7518c16e6b8', 'My Cases Unassigned', 'f1041549-41cf-4943-9b01-03b3909f003e', 'PRD')



INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFPRDId, '5bf8071e-fceb-493a-a2fe-09fc699744ea', 'My Individual Case', '1f1b07c8-5d63-49eb-8095-04e131b8770b', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, '71951c68-d776-448f-8ab0-50b82da04cbf', 'My Claims Tracker', '1261fba6-42f5-43d2-a48a-fdd83f80ef42', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFPRDId, 'a9386d8b-bc1c-46fd-8a50-4a0c7d8caf2b', 'My Incidental Tracker', 'e23f0d65-10b0-471a-8e13-c33ede93ab55', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFPRDId, 'f16dc904-2b8c-4b61-826f-65ba4cd5c8ce', 'My Unpaid Amount', '2188ac5e-a193-4584-9f6d-3c300d2c5cf9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFPRDId, '7ce12624-1de4-4af0-be10-5ee2033c33e1', 'My Invoices Generated', '4b5c9114-3402-41cb-b250-fc6acf5ca206', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFPRDId, '310393b7-d1da-4e42-9d66-92aa22929499', 'My Invoices Not Generated', '3493927f-a00a-43c2-853c-bd2712a2e305', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFPRDId, 'fcc5be4a-e0de-49fb-acf6-e575ebaa6dc3', 'My Planned Chargeability', '369aa0ff-cbf8-47bc-8f66-37643f2c0590', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(), @WFPRDId, '8a2e67c8-7f68-4213-9864-a85063da25c3', 'My Planned Contribution', 'f1491f48-9b0b-413f-a42c-6a056fca706f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFPRDId, '8945a0ee-dbed-4309-bc61-dca84833ab9c', 'My Recovery', '643e2586-a33d-48ce-bf9e-68e6e8af25e1', 'PRD')

-------- ==================================================MY HR

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'7c8a8ec6-f696-4dac-876e-049e29fdfa65','My Attendance','5f346364-f0f3-4175-ab58-ec069a60fe77','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'2f9d4d67-3fda-41b3-89b3-aa4149a05f90','My Claims','36faf6d0-b4c2-4f0e-8ece-db8f4add4211','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'5afea8e9-b704-441f-b547-40ca55fe8ac3','My Leaves','7f381dda-aa23-4e61-846b-a7602656c98d','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'816bc32b-d278-4861-ae4b-820ca24ca945','My Trainings','c91469d1-19b3-4c4b-a392-590c7c8f08fb','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'e5f0e61a-05b2-4715-82d7-c2c448582789','Payroll','04da94d2-a617-4eba-b887-fd7ed98cb6f4','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'e568e916-d8f2-4ec8-9ece-a033f7c43c52','Recruitment','3e7c742d-184c-467c-b481-21322a1668bb','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'3d0a6bcb-a682-47a6-966b-48aa6b52b552','Training','47ca51be-deaa-4d15-8e5b-14888f78814c','PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'4a25538f-8fa7-45f3-98d9-86613360d4c1','Training_Poc','168c59a7-d4aa-4faa-93e1-759c8fe0c3b2','PRD')



---------------------===========================================MY Client cursor--------------
   
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCPRDId, '520a8de1-9d98-487d-a543-e66fefd6478a', 'My Accounts Inactive', '7d4c190b-1a08-45db-b570-03272ba950de', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCPRDId, 'da2db98c-6142-41b0-be20-46cf0fd9f2d7', 'My Accounts Lost', '6b69e935-28b2-4e2f-bb0a-a20cfc784cc1', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCPRDId, '14520397-8e65-4c43-97be-63ede9072e16', 'My Accounts Re-active', '9e563c98-ffff-4475-801d-4c8fcf5fe1c1', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCPRDId, 'b29802cf-38f8-4622-b1b2-44c56591e3f0', 'My Accounts Won', 'c252adbc-86f2-4e6a-8a08-eb806b3c6f3c', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCPRDId, '1169b4a1-c62a-48e7-8b5e-dd0f13b6f659', 'My Accounts Now', '0ee86509-a029-4fd4-bb35-9c4259315345', 'PRD')


----=============================================================My Leads----

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCPRDId, '78399ef0-e99d-4272-9e97-09d778c0f45c', 'My Leads Creation', '2b7fd75d-61f8-48d5-ba78-aae3c044f30d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCPRDId, '6bb6debe-56b9-47ef-91f5-1766f3a21552', 'My Leads Lost', '4924c75e-e0eb-46dc-acc9-2da1946321af', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCPRDId, 'e8fe7cfb-442d-487a-9eba-a5642d0647a1', 'My Leads Now', '8e4c67d7-e2f3-4d5a-98b6-1228255781c0', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCPRDId, '0edb4fcd-f3e9-49d6-a0e7-f2057f880db3', 'My Leads Re-new', 'df95db8f-162a-4202-8dca-08dca77f30eb', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCPRDId, 'c4cc26ae-e442-40f8-bc27-7b29f7e9392f', 'My Leads Won', '7ce72572-a580-4803-aa21-a37483a9618a', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCPRDId, 'a0edce20-2f4b-4da1-9974-2f138d001ef7', 'My Individual leads-Accounts', 'c2fb3732-9a3c-4acb-8bac-86d33dd19f84', 'PRD')

----========================================================MY opportunity--

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCPRDId, '15ea9367-f46b-46a7-ab65-64629f0f02c7', 'My Opportunities Cancelled', '9afa9595-ef66-4f1f-a355-3f063ec59ee3', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCPRDId, 'c9163d42-3edf-4019-9e3b-de12c18bc2fa', 'My Opportunities Complete', '112f8e54-e517-4a2a-9bde-c4e543738206', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCPRDId, '359b3ea6-a221-40f8-a382-6ceea219683f', 'My Opportunities Creation', '969aea48-533c-4a88-b6c4-3842866e6790', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCPRDId, 'ea4404d7-d2d9-4944-b6e3-0892a91a5abc', 'My Opportunities Lost', 'b318e305-94a1-4401-a877-9df7404cdf8b', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCPRDId, '35b9e6bb-281c-4656-a2fe-eade2cbefb8b', 'My Opportunities Now', 'cc45be40-5754-41be-bdb2-94a986ef80a1', 'PRD')



INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCPRDId, '9d663f3e-969f-41b7-a4fd-51c3157a68aa', 'My Opportunities Pending', '6d3cc5b7-6081-448b-b1fe-41094a9c9e6c', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCPRDId, 'ee4883f0-57e0-4149-8cae-e14871bbfcf8', 'My Opportunities Recurring', '9aa0ef99-4664-4f36-9970-79fc0aa2e2f3', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCPRDId, '86709f4f-2857-4548-b107-a11c64cd6936', 'My Opportunities Won', '314ae464-0291-47f9-9650-1c0af0af5128', 'PRD')








END





GO
