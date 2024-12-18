USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PRD_AllCursors_InsertandUpdatePowerbiDashboards_New_SP_Latest_Old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Proc [dbo].[PRD_AllCursors_InsertandUpdatePowerbiDashboards_New_SP_Latest_Old]
AS
BEGIN

 Declare @WFPRDId uniqueidentifier=Newid()
 Declare @HRPRDId uniqueidentifier=Newid()
 Declare @CCPRDId uniqueidentifier=Newid()
 Declare @DrfinPRDId uniqueidentifier=Newid()
 Declare @BeanPRDId uniqueidentifier=Newid()
 Declare @AuditPRDId uniqueidentifier=Newid()
  --Declare @EmedPRDId uniqueidentifier=Newid()


-----=====================[WorkSpaceId]----


   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@WFPRDId, 'c3491455-e3cb-41b3-bde4-ec4347a8c06a', 'PRD', 'Production-WF')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@HRPRDId,'f33cb895-ca27-4ddf-90c8-ba7f7652d25a', 'PRD', 'Production-HR')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@CCPRDId, '874e09c8-3c0a-4648-8e4f-affecf24efdc', 'PRD', 'Production-CC')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@DrfinPRDId, '4f090748-2b99-44ad-bc84-725bec28162b', 'PRD', 'Production-DrFin')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@BeanPRDId,'df90cfcd-f684-4302-9522-64f9228b0482', 'PRD', 'Production-BC')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@AuditPRDId,'bbf65336-4923-4692-8087-f58da68904f4', 'PRD', 'Production-Audit')

   -- INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   --VALUES (@EmedPRDId,'df99d1d1-164b-469b-95ef-c44fbe2f784e', 'PRD', 'Production-Emdevent')

 --===========Work Flow PRD---===============
 ----====================================================================

 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFPRDId, 'e7ca44d7-d59c-4dc4-a183-aaf3837377df', 'Actual Contribution', '7fea008e-aff6-4e93-898c-19f020377009', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFPRDId, '1e5d17f4-34e6-4112-bc92-43a2bd3e3570', 'Actual Contribution Dept Poc', '48a02409-0f30-4842-9ce0-75dfc0de95e2', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFPRDId, 'f5729039-8c2d-4819-9e4e-ae1b02ed4670', 'Actual Contribution POC', 'c48a07ec-31e9-4260-a88f-f7ebe12ab73e', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @WFPRDId, '4970b5a1-0f05-4ea5-a6a5-6810ec575c8d', 'Case Members Report', '3dd10a6d-47d1-44d2-b2fe-89dea06290ab', 'PRD')
 
 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
 VALUES (Newid(), @WFPRDId, '10cbbdb0-63e1-4b5c-a361-28a70d9c7a34', 'Case Details Report','b4ba0e88-6adc-41bc-8f05-481a3f11d9ce', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFPRDId, 'd5fc6117-8130-40f6-8f9a-2f5817a7651d', 'Cases Approved', '7463e61a-cf86-42d3-80b9-8991aeba7e7d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFPRDId, '2701570d-7d08-43e1-8c8d-3c7add0e3d7e', 'Cases Approved Report', 'f24130ef-646e-4785-a937-a68b078e93b6', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFPRDId, '40e3debd-0e3f-4555-8abe-066678ef1f60', 'Cases Cancelled', '7e051531-8d91-43fb-a023-d1ba68f1abf4', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFPRDId, '6c06883b-b7e9-43c2-ab68-b2e67714f37d', 'Cases Cancelled Report', '2615d327-9e0d-4e18-9329-e61de0245a7f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFPRDId, '04c3f9a1-dfe6-4794-a607-9a680a6b0bab', 'Cases Completed', 'b3d9bc69-3b27-4fae-82b2-bb12bc2a6e1f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFPRDId, '9dcacb99-e71b-4792-927d-9271fce42b0d', 'Cases Created', '2a720441-59ca-485f-bc91-6cb0380ff467', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFPRDId, '86faa5e0-ed64-4d98-b25f-487b13bd9e0e', 'Cases Created Report', '1d7b92db-203b-4209-89c8-41aa2bf84674', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFPRDId, '6af463fb-a1bf-43e2-8f68-49d331b73a66', 'Cases For Approval', '38b4a895-44a0-4f32-8f22-a8cf8b68ffc9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFPRDId, '6af7f0b2-8ba4-4ff4-ae25-85f5c779fdcf', 'Cases For Approval Report', '2d20f582-7daf-4a81-992c-ee3798cfa99e', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFPRDId, '95cb3270-a6cd-41bd-8e3d-96faa749acf4', 'Cases On Hold', '14d73a7c-a7fd-47fb-9c2d-c5dfefc486c6', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFPRDId, 'a270193e-76e5-4c21-88e9-845ebb90cc65', 'Cases On Hold Report', 'a6813a75-d58f-4f84-be98-f7d0e0935061', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFPRDId, 'e2757168-ebb1-4ee8-a74f-8c54db94a3c2', 'Cases Unassigned', '4c913ab8-eeda-491b-87e1-52662ddacae7', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFPRDId, 'acd9c19e-6587-4e33-b1f0-478304982e9c', 'Cases Unassigned Report', '429cea0c-42bb-49a9-95d3-11c81859e193', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, '91a0fafd-552b-4a96-8867-404c34ab5d2c', 'Actual Chargeability', '402ea813-16b1-4b69-9bb0-09427ad44409', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, '37aadd83-8697-488e-a184-28cc6700439e', 'Chargeability Dept Poc', '917c6219-6fbc-43c8-8317-1dc92873149e', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, '045dd33a-66e0-4017-a1d1-dc6711a99aeb', 'Chargeability_Poc', 'b9f8787b-a73a-47ce-94f2-83a3b039a3a4', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, 'b7eed044-d83a-431e-a255-ecece4bf127b', 'Claims Tracker', 'a67f311d-cb95-4707-9bae-4c0fb90b25e4', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, 'f202ce1a-ffae-4d0f-ac1b-94a314eaa4c9', 'Client Contact Report', 'd63facce-e3d5-49b9-ab6b-914825119294', 'PRD')

  INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
 VALUES (Newid(), @WFPRDId, '6aa43f61-e360-4fd4-9891-89f1c25f335f', 'Client Details Report','7a8a4612-3378-46a7-b4f4-c70788dab1ae', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFPRDId, '5112374c-ac18-4160-ac30-171bbbcf6938', 'Clients Created', '19ee3b77-5c33-48e1-a36b-5e429f1a197d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFPRDId, '10e6b9b4-3899-473c-8a33-62e462357f44', 'Clients Created Report', '3ac6752f-8f43-4555-88c9-2f1d9f51dad5', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @WFPRDId, 'f7c3b97b-f06a-4320-ba89-db35193b7a2f', 'Clients Inactive', '56c98102-50a3-4f43-acc9-148e40d698d1', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @WFPRDId, '004cf9ff-e55b-4566-b0cb-44da224f97dd', 'Clients Now', '26e2c9cf-b193-4882-a282-eb00740c3b6e', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @WFPRDId, 'ddc48838-2efe-424e-bf03-7aa41612b32b', 'Clients Now Report', 'c985455c-6b80-4108-8520-3570139e6e7c', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFPRDId, 'a788a7a6-aaac-4496-980b-2cce7702dd1d', 'Clients Re-active', 'dfc35af2-aa11-4875-a5bc-ffece462ce75', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFPRDId, '7662312b-26f9-4644-a372-be4cb6d992fe', 'Clients Re-active Report', 'c46b3da8-4d65-48f5-a127-6801a8bbdbe8', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFPRDId, '185712eb-39bd-4b9f-9b2a-e969a8e2a205', 'Incidental and Claim Tracker', '83d71556-e5ef-462e-a97f-136a8f536025', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @WFPRDId, '5f5ef567-8aad-4bb1-9b09-4fc32d2bea6f', 'Incidental Tracker', '0d718bf8-ce81-44da-a79f-47d161e093be', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @WFPRDId, 'ced9c0d9-9a3b-47e5-97ac-77850b28d6f5', 'Individual Case', '5ec4c22b-d0ba-460a-af2f-67db23af9e16', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @WFPRDId, '3a3e2cd0-4919-4b0f-a1d6-7409bd0c331d', 'Individual Client', '168a3059-a2b6-48ee-a000-bde2cbf34ab7', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @WFPRDId, '03785735-bcb5-48d1-9245-cc25569aead5', 'Individual leads-Accounts', 'e53bf3ed-df1c-408f-b181-b34329bb89c9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFPRDId, '0cd74bc7-f380-4947-bdf9-7afb36ffb8c5', 'Invoices Generated', '14af38ed-66f2-48d1-9095-bb4d9e7ee056', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFPRDId, 'fd49fa79-f9b1-4197-acc3-08db74e78487', 'Invoice Generated Report', '6aa70135-8108-4559-921e-008cd9f5c2ec', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFPRDId, 'ef6ae993-1858-4b1b-8dee-a525763c56cf', 'Invoices Not Generated', 'b2c888bd-fd36-41ad-8060-b53a9f79669f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFPRDId, 'd46afd26-3556-470b-8f8e-57170e0bd355', 'Planned Chargeability', '277c7f3c-b6c3-4f18-a5ec-ffb6150cdcdf', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(), @WFPRDId, '990c55e2-a061-4d72-94d8-d977d87fb57a', 'Planned Contribution', '9ddaaf0d-9bcd-449b-bda2-3be33f659dd8', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFPRDId, '0e8b1453-d216-42b9-be31-03ec30dd8488', 'Recovery', '4e71041c-4fea-4a2d-88aa-6a11171d04c3', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFPRDId, '7ecaa90f-c394-4535-bf73-341b4c0f1f17', 'Timelog Detail Report', '05ce2c4a-7157-4f2d-8b6c-449a75d7bb6f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFPRDId, '08782ada-73a1-4fdc-9d82-857cce9f7d60', 'Unpaid Amount', '092d48a0-940e-4a1c-bbd8-fa64f20f7494', 'PRD')



 --===========HR PRD---===============
 ----====================================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'5afd0516-62eb-4117-a4f6-13aa0ceb87e7','Attendance','5c867da3-f472-4ee8-b371-85d9e79ba86b','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'821cf307-f6c4-4af7-9548-a2e7264691b9','Attendance Dept Poc','acac9cda-b47b-4b5f-b491-1d2741809066','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'b597af12-1f2b-427e-b59f-91ad54e6dfef','Claims','d1c8f9f8-3d9b-4d06-baed-175e51310642','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'037d5cb0-b64f-4ba5-aa35-4d45664462b3','Claims POC','165ff652-9aac-445c-9f75-90d26d86341a','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'02656900-0af4-4b27-a7fb-061d6c1f7162','Claims-POC','4840aaa8-effe-435e-9b87-a0da1597438a','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'79cacb70-da7a-488b-9360-23aa399ef89d','Employee','ee9c5996-ab38-49d3-8ae1-084fcd312252','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'41b1de76-fc45-4411-85d5-252eb4bf20b0','Employee Dashboard','a6fad5e6-8b44-41e6-a16c-c4bd4f3f87dd','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'e647c556-84e2-42b9-bad9-e07713d10dfc','Employee Details','7a8cc4ee-60c3-4f1d-a37b-63dd774d2526','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'d2c1d235-f6de-4ce0-b215-66cfa7f98e06','EmployeesDetails','9d9a56c8-5b3e-4441-9685-c5af93f7ed26','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'e7b7aa2f-6d4f-4d11-9b9a-ebfce3a3ebae','Leaves','e6e07bd5-7bca-4678-9b83-7e38c745aff7','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@HRPRDId,'eb5354a6-dd0d-4fcd-980a-269651185018','Leaves POC','919f0a79-c936-4fd5-9a4f-5a04d448775a','PRD')


    --======================================================= Client Cursor ======================================================================================================
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCPRDId, '98caedbe-e91f-4dbd-8ce5-689022d73765', 'Accounts Inactive', 'd611ade8-ccd4-4c30-8ade-58ba24c53c8f', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
--VALUES (Newid(), @CCPRDId, 'b77b1aae-140e-46aa-a816-e28c9c9919c8', 'Accounts Inactive POC', '777574a9-a527-4aac-8c66-b1c729343727', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCPRDId, '791d2e60-058f-4d84-b1bd-a2a44c557f23', 'Accounts Lost', '2db622db-b650-4d27-97c4-a378e468d70b', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
--VALUES (Newid(), @CCPRDId, 'e7eba940-f295-4e34-a6d2-030025e99805', 'Accounts Lost Report', 'f298d7ab-e563-4316-8892-13af505efdfe', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCPRDId, 'bec3e8c5-fa1d-4175-a189-8630da97b3ba', 'Accounts Now', '15c24aac-c615-4d72-a842-1e3d5baa4d18', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
--VALUES (Newid(), @CCPRDId, '19cd1918-be7c-40a2-9491-7c970358e35c', 'Accounts Now Report', 'e6ee6006-fe87-4dfc-9a6e-300bfcdec01d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCPRDId, 'e1642efd-6258-4850-891f-045c5b509012', 'Accounts Re-active', '38607cc5-529d-45fa-90fd-728c5dd2c53e', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
--VALUES (Newid(), @CCPRDId, '24045bcc-883f-4913-900e-62abf72d440f', 'Accounts Re-active Report', '75e72a36-ec43-41df-b49f-35565ce317e8', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCPRDId, 'ec76195a-9c8a-4520-b193-a0e112ebaed0', 'Accounts Won', '47ac22e4-8c24-43e4-ac9e-ca53cdf63b17', 'PRD')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
--VALUES (Newid(), @CCPRDId, 'c7e41f4a-6ea4-40be-82d0-1a68b65cc519', 'Accounts Won Report', 'd923964a-bb5b-44b6-91a4-7af9bc437eea', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCPRDId, '99650681-a669-43e2-8666-013fac9917a7', 'Individual leads-Accounts', 'cfd856c3-d8ca-4dc4-a4c6-589dad9c9edb', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCPRDId, '4a311cc9-b367-47ed-825c-1d1a50998d43', 'Leads Creation', 'b32080d2-af9f-4826-95c2-f252b909a787', 'PRD')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
--VALUES (Newid(), @CCPRDId, '614c6011-45cc-4290-873f-4563ad4b20a6', 'Leads Creation Report', 'cd532f53-b090-4120-afe7-fb11b02a3efb', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCPRDId, '13eae4df-1696-4040-9129-386ff6534649', 'Leads Lost', '10f95547-d191-4091-bba9-044ff83b3987', 'PRD')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
--VALUES (Newid(), @CCPRDId, 'd2e71031-0b87-4c53-9781-a96ef5d0c01a', 'Leads Lost Report', '56e7b46c-d0b9-4304-b82e-2446f670ab55', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCPRDId, '96333749-4076-4093-929b-e5c627038033', 'Leads Now', '521d5aa0-097f-4320-aae2-351938040261', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
--VALUES (Newid(), @CCPRDId, 'd5c9ba5c-1a4d-49ba-9b27-87319f602c77', 'Leads Now Report', '2a3d40f3-c4e0-48f6-a51e-ef49c64455f1', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCPRDId, '3b2a3c9f-d3e4-4fb9-bac5-aa5f5693bb5d', 'Leads Re-new', 'f5614c34-fe65-4e70-8d46-3e5f1b70b6e4', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
--VALUES (Newid(), @CCPRDId, '9d5e63d4-e0e6-49e2-8031-86022fe0a4b9', 'Leads Re-new Report', 'c0c3353d-ec95-405f-acb3-2ce9108bcc94', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCPRDId, 'adb01e35-8ec1-468a-93a9-24f752241874', 'Leads Won', '18637299-f9a0-47fa-8bc0-fea733b60a1d', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
--VALUES (Newid(), @CCPRDId, 'f3b40f28-eb44-4212-94a3-b4c91e5e223a', 'Leads Won Report', 'df991375-1b34-43ef-9d2e-7561426daf96', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCPRDId, '6466b958-5bb6-4953-baa3-199eb31bdf56', 'Opportunities Cancelled', '2bd2d21d-750a-4687-b6fc-6a1f36a4436b', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
--VALUES (Newid(), @CCPRDId, '8296530f-d003-4378-bd07-3e99196873eb', 'Opportunities Cancelled Report', '04e29f01-fddd-4e90-8c67-bbb2a99297ed', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCPRDId, '58b5bf1e-f09d-4fb2-937f-3a1b5f158090', 'Opportunities Complete', '854022a6-8c1b-40df-b761-a58335f97f70', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
--VALUES (Newid(), @CCPRDId, 'b31a2473-ac50-4509-8bc2-fcf0f286da25', 'Opportunities Completed Report', '40a6a3ea-bd1f-4758-8f8f-1138e517027d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCPRDId, '2329d3b2-7d2f-475a-8f4d-28a41ab3d0d4', 'Opportunities Creation', 'd669b42d-a717-46f0-aed6-b40964eb4850', 'PRD')---?

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
--VALUES (Newid(), @CCPRDId, 'ae943455-0ed5-487d-a69e-4df23301502d', 'Opportunities Created Report', '8d743a59-81d7-4000-8c23-6067169d47f9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCPRDId, '6685fa7b-d8a5-4270-b213-a43e91bed411', 'Opportunities Lost', 'a449ba1e-0255-4b33-897d-fd0bd3b04420', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
--VALUES (Newid(), @CCPRDId, '2bffa2b7-74a9-4d29-b302-89a5f568852f', 'Opportunities Lost Report', 'c81ca594-ce2b-42ac-9636-6b939ba52f37', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCPRDId, '1fe769a3-a790-4683-af80-04201f3d2d1c', 'Opportunities Now', '524d5f0b-1dc1-4d36-b6e2-dca32cbfee18', 'PRD')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
--VALUES (Newid(), @CCPRDId, '78eaa0f1-8b96-4583-a5a8-094b00d78528', 'Opportunities Now Report', 'e8b04c4f-68aa-4a27-89fa-31259d8d8746', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCPRDId, '5572c369-632c-45e3-adff-30b8382034dc', 'Opportunities Pending', '426845fb-299b-4e98-a919-087c662ea13a', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
--VALUES (Newid(), @CCPRDId, 'ffd1434f-6688-476e-a694-77615a36cf16', 'Opportunities Pending Report', '8804617c-b022-4d39-9f68-58bdcf32bc89', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCPRDId, '75d6935a-7bfe-46ab-9e3a-9474292199bd', 'Opportunities Recurring', '2afa05cf-21ea-4a43-92fd-8e252e79c39f', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
--VALUES (Newid(), @CCPRDId, '6ca1686f-bd22-4029-b174-2dbcec07cead', 'Opportunities Recurring Report', 'da2e4d48-8701-40a5-9bce-c16b49adaa06', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCPRDId, 'f899ca21-b175-4e54-9ef2-7448acdf4e4b', 'Opportunities Won', 'cac903d6-7de2-4a3d-b802-39078e50c96e', 'PRD')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
--VALUES (Newid(), @CCPRDId, 'a6d68354-6048-48e5-b6ad-60757384b21d', 'Opportunities Won Report', '0793c6d0-6964-456b-b712-8d6e153d34d2', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(),@CCPRDId, '59903536-d600-40c9-a9b9-7c21a417b09a', 'Vendors', '9a0dd5e3-cc0e-4bb7-a65a-01ddd61b8331', 'PRD')

 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
 VALUES (Newid(), @CCPRDId, '58b0e153-5174-4810-b71b-5e818840a41f', 'Account Details Report','25c69e1f-6d21-42eb-87f6-53d37a19b857', 'STG')

 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
 VALUES (Newid(), @CCPRDId, 'a0ea6d48-5bc2-4cbd-a0fe-250cfadfc77a', 'Leads Details Report','11a0f84e-f1a2-4e66-aa1c-f4a276cc3611', 'STG')

--  --===========Drfin PRD---===============
-- ----====================================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, '7207f277-1aa5-4ec3-afa9-165f7bcc588a', 'Asset Analysis', '254838c6-2ced-419a-8c54-31e7cf2bb222', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @DrfinPRDId, '06ccfae2-32da-46c6-8cde-8666f8730a65', 'Debt Analysis', '47e9f0ea-a6b2-4390-a247-4c03d30bede7', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @DrfinPRDId, '4bb9aa21-bde1-48d5-9536-877961680c8f', 'Expense Analysis', '0387c64e-4715-461d-bd72-54a9ddc67d32', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, 'f0b66379-230a-4faa-ba87-a4926c4ccf68', 'Financial Ratios', 'fc7a6828-4a58-4b86-bdf3-2dbce565a6d1', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, 'a4af44cd-1d83-47ce-bb79-9dca06682b6e', 'Growth Analysis', 'f5d81785-e551-4e21-b959-f24421226a0c', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, 'fdad9c40-2b34-418d-bc6d-f7477b3e9c98', 'Liquidity Analysis', '9a8a5f18-1121-4fb1-bf62-9bbbea5630ef', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, '5d18695e-b68b-4a98-bc5e-d7ae9d0b9dbe', 'Operating Cashflow Analysis', '5f4108d9-573d-4391-8ad8-2498e58d09c8', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, '1823837b-9eb6-4000-b871-8b1be6c4ea91', 'Profitability Analysis', '9c5a39c1-a75b-4699-b3e8-2805b5fefbd9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrfinPRDId, 'ff0a7111-31c8-4a87-9e67-05c67e4cb8b9', 'Revenue Analysis', '8abf1709-7893-4f6f-8dfd-dc6bb445dbdc', 'PRD')


--  --===========Bean PRD---===============
-- ----====================================================================


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'d86daf4a-65d7-4f24-bd76-740689289d3b','BALANCE SHEET','c244ae9c-20a2-479d-84b9-ea90c7d3c182','PRD')
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'67d79941-1d02-4fc9-8f5f-9a6ee9402140','Bill','b148d2c1-ba09-4aaf-8800-e842e112172f','PRD')
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'2d225c64-d7cc-4b09-a8b5-2daa256b2067','CASH AND BANK BALANCE','553e3e4f-4477-489e-baa0-873416c0c418','PRD')
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'cc0a685d-88ac-4e09-ba2a-bcced2dca56d','Cash And Bank Balances','773accb0-47f2-4d14-a0cd-93146862c143','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'87948a55-fd56-4fd1-9a92-218b45ed9606','CASH AND BANK TRANSACTION','98d3b567-5ab2-4690-b7ca-0a3fb021f51c','PRD')
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'d55ef88e-890e-49d0-87a2-98db6effa553','Customer','7de8682b-f472-4b9f-a6c4-6af501bc4015','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'f6f5cefa-edef-4db4-895e-1398293e097c','Customer Aging','d35d17f1-ca74-4162-a402-8ed860258621','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'135c303b-284c-449c-95d0-0dd1747a92f0','CUSTOMER BALANCE','bf1d33b0-ec9c-49eb-aaef-7209ff6d26a7','PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'5abd87b6-3b95-4339-9590-bc593b6f9ab5','CUSTOMER TRANSACTION','36f330d3-eab5-4385-8c44-74000ca5e098','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'8fc18110-4456-45d6-bc14-2a31a49c24a1','Financials','9344e101-98b9-4678-aa7d-88d685f6b51c','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'759479fc-6922-4530-837a-6c98ca9f7d6e','INCOME STATEMENT','81d35ddc-d693-4a39-8f39-2728ba9bdeba','PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'dfa7b174-d216-444f-9acb-35100713db6e','Vendor','fc7ebb13-eab9-4775-a1a9-a3243f2bb067','PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'7d04202d-8838-4bac-a034-202575689c91','VENDOR BALANCE','9b00064a-1930-4833-8f1f-26db7c9d9ccb','PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@BeanPRDId,'5031d79d-9551-44c7-9b16-8e8883495c7a','VENDOR TRANSACTION','09eff46c-6ece-465f-9f5b-1a010065dd1f','PRD')


--------=============AuditPRDId---------------------------

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @AuditPRDId, '412ac58c-20fe-4c91-9f0b-ffa528e2fbf3', 'Profit & Loss Analysis', '5c5a4ddb-913d-4c4b-b3c9-0b2221485b27', 'PRD')

------============-----EmedPRDId-=============--------------------
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
--VALUES (Newid(), @EmedPRDId, '82c5bb95-e337-41f2-94dd-442c283e5487', 'Conferences Payments', 'f986135b-ffb5-4639-8193-5d46dcd5cee7', 'PRD')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
--VALUES (Newid(), @EmedPRDId, '8ea2aa99-ddf3-40ce-a773-6d08739bf8a8', 'Emedevent POC', 'bf7dc5d5-c27a-4183-ad8c-b39028240052', 'PRD')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
--VALUES (Newid(), @EmedPRDId, '3b90edec-8945-418e-9dc0-ec00544b8e57', 'Emedevents POC Dashboard', '8aa04c05-7fca-4d7c-b2c6-647e83423578', 'PRD')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
--VALUES (Newid(), @EmedPRDId, '68952137-254a-4da8-9d6c-2c69655a31ec', 'Emedevents POC Dashboard with Q&A', 'ba9b45cf-6ce9-42c0-9503-f64951bb3efe', 'PRD')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
--VALUES (Newid(), @EmedPRDId, '0b9cb1d8-de73-4d6d-a35e-cfc5aa28c328', 'My SQP Attendee POC', '92b00648-843a-4e46-a084-418a95210c1d', 'PRD')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
--VALUES (Newid(), @EmedPRDId, '8fdc8a61-ae99-4f09-9da8-d5a300198008', 'MySQL POC', '3bf7cf5b-b8b0-45b2-b6c9-7505b3b7d866', 'PRD')

END
GO
