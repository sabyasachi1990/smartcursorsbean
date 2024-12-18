USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[STG_AllCursors_InsertandUpdate_MyPowerbiDashboards_SCM_SP_Old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[STG_AllCursors_InsertandUpdate_MyPowerbiDashboards_SCM_SP_Old]
AS
BEGIN


---exec [dbo].[PRD_AllCursors_InsertandUpdate_MyPowerbiDashboards_New_SP]

 Declare @WFSTGId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='STG' and WorkSpaceName='Staging-WF')
  Declare @CCSTGId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='STG' and WorkSpaceName='Staging-CC')
  Declare @HRSTGId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='STG' and WorkSpaceName='Staging-HR')


   ------------ ======================================================= MY Client Cursor STG ======================================================================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, '7faa2967-aab4-4cf7-8af5-dc17fb62d85c', 'My Accounts Inactive', 'e62e88d2-08a9-4210-8348-7f58337a8f3e', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, '4a430504-1a9a-413d-ad90-1652c3a0afe9', 'My Accounts Lost', '012871f3-e375-4d82-91b6-b221a6cbc6ef', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCSTGId, '7fcc7d29-c83a-4e7d-b310-5ccbc3082ef5', 'My Accounts Re-active', '5129c143-db11-46bd-98e6-c3a4a0aedae8', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCSTGId, '2809046d-be54-4bec-8564-600b9b77d8e3', 'My Accounts Won', '1fa6b8cf-ecf9-43d9-8e2b-be1e1a851386', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCSTGId, '81123a4f-2d37-4407-b7f3-ad38b7fa9339', 'My Accounts Now', 'bd947959-38d2-4cf5-ae66-acc735881098', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCSTGId, '6a15f9df-ab71-486a-98a2-2799a6c15bb8', 'My Leads Created', 'dec4574e-95d5-49c0-bb77-444bfbaf9197', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCSTGId, 'c680798f-9e88-4b00-91d9-ff32332c7fe5', 'My Leads Lost', '021683c5-b8d1-4c21-afb2-c653c60aa2a9', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCSTGId, '4eede916-9502-4087-a9db-4c559b146019', 'My Leads Now', 'dd6ad3db-3270-4a04-87e1-2ff33d48d049', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCSTGId, '19e364c4-70e7-4f6c-8c82-2639bd2e226c', 'My Leads Re-new', '9e8c5eb5-b7cb-405a-8626-b6b611b7a253', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCSTGId, 'fa131ba7-6ac2-479e-a6ae-2cad6cc14b59', 'My Leads Won', '530d516b-292a-455b-a4f1-ca2d5a3b57b8', 'STG')


 -----------MY opportunity--------

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCSTGId, '288eb825-c8b1-4f4d-aa54-cb6285659079', 'My Opportunities Cancelled', 'c2ab8de8-ab80-4dbb-9d3c-df04e0e24808', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCSTGId, '72ed779b-dc40-453b-b44e-274929e6d579', 'My Opportunities Complete', 'd6e0168d-4ab7-4477-b0f4-9fe01664febf', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCSTGId, 'a526b906-bcd1-4e81-962f-f11ca261c6b8', 'My Opportunities Created', '5e38d80d-91ee-4bf0-8ee7-a9f89aee0055', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCSTGId, '0f0ad667-de3b-4d0e-8658-6f07151fa84a', 'My Opportunities Lost', '2e9b672b-f65e-4535-8052-31254a35ee52', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCSTGId, 'da53722a-17d3-414e-bd55-d59d57bb0aae', 'My Opportunities Now', 'e155dcff-d011-4273-80a4-3bee1d59b44e', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCSTGId, '19cbb994-d694-483b-906a-ac928bf2e7a7', 'My Opportunities Pending', 'b7a5f60e-1a43-4e0c-af6b-4ca22543913a', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCSTGId, '8f02002f-68a5-4566-8e69-64984ca39ed8', 'My Opportunities Recurring', '1a3a81df-6f7a-4a6b-9888-6409477e7902', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCSTGId, '29ac81c4-918e-4f26-81a7-ae9911d56be1', 'My Opportunities Won', 'becbd33f-a9ec-4404-a45d-0729e19586ca', 'STG')





  -- ------------ ======================================================= MY Workflow Cursor STG ======================================================================================================



INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFSTGId, 'a7053b81-f973-41ff-8a01-40754d1e256a', 'My Cases Approved', '0378ab5d-5105-49e4-b168-553f88177cb9', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFSTGId, '87b21c35-058c-48b7-93a9-7128b5d1ee66', 'My Cases Cancelled', 'ccea5844-1ec7-49df-bddd-ce7b12738aef', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFSTGId, 'dcfd7929-39db-400a-9262-687ac43b4117', 'My Cases Completed', '04478ed3-821c-42bc-b726-4cc2e7e6ef68', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFSTGId, '1b7828ba-b221-4841-83bb-a336349ee5c3', 'My Cases Created', '01a557f1-5a68-48c0-b4a7-7122e6529f29', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFSTGId, '8eb327a3-4ca3-4f44-bf3e-497fc7e7a688', 'My Cases For Approval', '0a3e075e-f321-4a76-a583-640d0b82f24d', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFSTGId, 'c42727ae-82eb-4ee9-b5e8-9fdfa71b674a', 'My Cases On Hold', '07330c54-1661-47d9-acda-07ac3e81af42', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFSTGId, '5a9336a2-2c94-4abb-8ac5-9df4459cb2d8', 'My Cases Unassigned', '5081b0fc-86ff-4bde-944a-482e3586843d', 'STG')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
--VALUES (Newid(), @WFSTGId, '46a6bc23-e576-47ab-90f4-e76aa520eaca', 'My Individual Case', '0f8b9cea-b5ee-4965-a0db-7be243e74195', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFSTGId , 'cb2c1b1a-b241-45bd-afaa-6f39e5d3f90a', 'My Claims Tracker', '3c2c7d68-8fef-4729-af8c-02b076e466b2', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFSTGId , 'e610cdd3-ec3f-4a4c-aef7-ead626923f92', 'My Incidental Tracker', 'ccdb7c0e-b713-4a31-9fcb-2916b8490dca', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(),@WFSTGId , 'e9e91675-68f8-4ead-bed2-a1abbb780945', 'My Unpaid Amount', 'afd47cec-dce9-425b-b23e-17e525c2830e', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFSTGId, '04253206-4f1d-49a7-9c90-1beb8a69a466', 'My Invoices Generated', '419da2b3-0cd8-4b0a-b392-c3e5d43ccfdb', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFSTGId, 'c0310d72-84d8-4332-bbbe-8ace67c81b80', 'My Invoices Not Generated', 'a9d8402c-1572-4a57-b0c0-8da04092ed0e', 'STG')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFSTGId, 'e6a11cd8-a906-4fbf-be73-09658d59c68e', 'My Actual Chargeability', 'ab3b56dc-b11e-4be0-bc46-e4993649422b', 'STG')
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFSTGId, '12ed839a-054a-42b8-ada7-1d4806f5dc71', 'My Actual Contribution', 'da25b772-e961-4214-a1fa-ab0f4351a25c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFSTGId, '73f684bc-5dfd-4dce-a9bb-4efb70fb88cb', 'My Planned Chargeability', 'd7b70640-c359-4732-8177-b7fce960d4f4', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(),@WFSTGId, 'bed0269d-9054-4f81-a8a3-f992ab123458', 'My Planned Contribution', '2b6e3801-6e4c-4eb4-83eb-cf2a28b2e970', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(),@WFSTGId, '9b4bb9dc-9bce-431b-9d2f-db9f4d07e3af', 'My Recovery', 'bb16979a-d70f-4704-946f-3d5ed60c84df', 'STG')




----===============MY HR=====----------------

----select * from [Common].[ReportWorkSpace]

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRSTGId, '1e49b935-0553-4a04-9837-06c731f8c238', 'My Attendance', 'b57fe865-8013-4d65-b0b7-012154886c09', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRSTGId, '37a3eaac-eb42-435d-a287-9d9e7ce3d2af', 'My Claims', 'd945e1fb-f444-465d-935a-c9cf5dde52d3', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRSTGId, '8ada0f7b-7e30-4d02-a299-c4c0fe2ce59c', 'My Leaves', 'd655f19b-234b-4b63-8b31-7c3794f67c9a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRSTGId, '788a42ce-d8e3-430f-945e-0dee06c2c20f', 'My Trainings', '0073903e-92bc-4029-a04f-cd34c2907c7b', 'STG')

 
 END
GO
