USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[TST_AllCursors_InsertandUpdatePowerbiDashboards_New_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- delete from Common.ReportWorkSpace where WorkSpaceId='71D8F589-B69E-436D-8558-A63721B885CB' and Id='1BE1733E-3475-4E42-A017-CFB9C9C60243'

--delete from Common.ReportWorkSpaceDetail where MasterId='1BE1733E-3475-4E42-A017-CFB9C9C60243'

CREATE Procedure [dbo].[TST_AllCursors_InsertandUpdatePowerbiDashboards_New_SP]
AS
BEGIN



 Declare @CCTSTId uniqueidentifier=Newid()
 Declare @WFTSTId uniqueidentifier=Newid()
 Declare @HRTSTId uniqueidentifier=Newid()
 Declare @BCTSTId uniqueidentifier=Newid()


-----=====================BC-TST


  INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@CCTSTId, '71d8f589-b69e-436d-8558-a63721b885cb', 'TST', 'CC-TST')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@WFTSTId, '5f01a88a-9091-4a67-8617-7b3714277989', 'TST', 'WF-TST')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@HRTSTId, '8b7576c9-32aa-4224-8c8c-c52c3d6ecba1', 'TST', 'HR-TST')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@BCTSTId, '32bbd93c-0522-427e-89d1-31298323560e', 'TST', 'BC-TST')

  



   --======================================================= Client Cursor TST ======================================================================================================
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCTSTId, '32c6ba6d-009e-4996-a719-829e6a768146', 'Accounts Inactive', '99cd360a-63b5-437d-8bad-6a83451aa6b4', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCTSTId, 'cc36a5bf-9ff1-47ad-acd8-019a6b887946', 'Accounts Lost', 'e24ddb27-7f0c-4ad2-91ad-27eaa1398923', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCTSTId, 'b3f495b9-9722-4015-9491-da2701498705', 'Accounts Now', 'f5bf2dcc-df8d-4d3b-b44e-e81de05f8f13', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCTSTId, '8b048bcd-30f9-4f42-8f7b-5fb8fa2b321e', 'Accounts Re-active', '3c21a073-ffde-45ec-bf80-5cd1ca32da77', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCTSTId, '9c00f093-a226-49f0-9436-62592c825a83', 'Accounts Won', '630ab6cd-ba6a-4f25-b481-fe7b070dec3a', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCTSTId, '61a41e27-a2e5-4d28-b67b-87028cb1f9f4', 'Campaign', '035f2be4-f339-4acc-b67b-d8dad1f21c8f', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCTSTId, 'd7765f76-df77-45b9-b666-3f699ce9d870', 'Individual leads-Accounts', 'dee875ef-97f2-4fd6-8fa2-c1f39e87b628', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCTSTId, 'c6cd370f-0f56-434c-a7fa-85c229b36ca1', 'Leads Createation', 'bcb7dd67-687f-4ad9-b282-af83a6e4ce74', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCTSTId, '64d9252c-b7c6-4631-9aeb-f7992dd55fe7', 'Leads Lost', 'a4a633f5-c2bb-4160-832e-08777d68695b', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCTSTId, '6f11fd37-def0-4690-a61c-e9096977a0b2', 'Leads Now', 'c6f6eddd-99de-4db7-83ab-3bf97b63ff4f', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCTSTId, 'ad6b1018-8e28-4963-81ab-88c8eba6db62', 'Leads Re-new', '583d0d7c-fa0e-40eb-8fc6-124da02c17da', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCTSTId, '53ba9445-3874-4716-b9e2-6d4f608e17b8', 'Leads Won', 'b09d1bd8-005a-44db-b146-6a70de6c9e8e', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCTSTId, 'e60fdc11-539b-4194-bbdb-8925dfbf0699', 'My Accounts Inactive', 'dc87cf9f-8686-478e-96d9-3f6ae2ea7711', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCTSTId, 'a8d9a041-aef1-41f4-baa6-0477943070bc', 'My Accounts Lost', '533da6f0-3d4b-42da-86a4-e01dcf4f69fb', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCTSTId, '04368289-c07e-44c1-afa9-5ae85c0f1558', 'My Accounts Now', 'a564e9af-7c84-4ccb-ada2-7260a0ed364c', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCTSTId, '5c72ab27-ef0b-4a09-8711-9190bb12c40f', 'My Accounts Re-active', '619dab83-ef33-44d4-9d74-7d36b143082d', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCTSTId, 'bac6b04f-d51d-4301-a40c-f11a36d32fad', 'My Accounts Won', '709904c3-ee9a-4df3-8df9-19aa3ea41a5b', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCTSTId, 'b60aea9d-a9c7-41e8-9ceb-d1b402dc80c4', 'My Leads Creation', '39b36bf5-bca6-4e30-9ff2-299236ae3f57', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCTSTId, 'c60f12ac-30a5-42cd-84f7-786fb745cca9', 'My Leads Lost', '3146fa18-e1ba-4d1c-8adb-92844ee2bc70', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCTSTId, 'b2a6ebfe-a861-45b8-bb88-15a07afb2d0a', 'My Leads Now', '5805a2c1-dcd9-448d-9d1d-698a349c1694', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCTSTId, '555b8ff9-7a89-4acb-a7e9-d6bbfc8ab07d', 'My Leads Re-new', '378c3696-547b-407c-a4b3-97a5fc83eec6', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCTSTId, 'aee5c9d3-3cd8-47d0-94f8-e55a4c9a9437', 'My Leads Won', 'f6c38105-9572-4280-b3da-df5eff23bb0c', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCTSTId, '25497236-bc87-43ee-8dcf-e2a00b1dfb37', 'Opportunities Cancelled', 'ec12a32e-f5d1-4d7f-97b7-7064ed052883', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCTSTId, 'e1d90123-4ff1-4940-ba45-09817cccc145', 'Opportunities Complete', '3c97b4bf-d56f-40fc-8326-3bd96aeafaee', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCTSTId, '52e4be37-7d43-4ea6-896a-19d482d4b12f', 'Opportunities Createtion', '7c357151-579f-4778-9566-fb80a04827f6', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCTSTId, 'd991f956-8d2f-42fa-9f3b-fd67dc3e5bb5', 'Opportunities Lost', 'dabdaae5-ba2a-4cd1-aebb-c9e9a7a4a907', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCTSTId, '4e7213d9-172b-47ad-b2a3-720e2bbb736e', 'Opportunities Now', '8a964c1a-163b-43aa-9930-0c9ff68ac72d', 'TST')



INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCTSTId, '8bff5a1d-08f9-4149-b027-d1a086b5b42d', 'Opportunities Pending', '74dcff1d-211a-43d4-9f3e-91a183301f95', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCTSTId, 'cc157ec4-9205-4b82-a53b-86e086f19bb9', 'Opportunities Recurring', '8bd50b50-18e1-46d4-b517-9e67efbf2759', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCTSTId, '083c7ec6-66b2-4e33-9447-b0e318cb7d6c', 'Opportunities Won', '6bff3c11-018a-47e8-85b7-ae292ea5a176', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCTSTId, '9c661d82-997f-4b88-98e2-7968cc0be013', 'Vendors', '2e406e37-93a5-4135-808e-c11016822f43', 'TST')

-------------My Opportunity---

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCTSTId, '306f854c-8f4d-42de-8f32-2bfab23f8e89', 'My Opportunities Cancelled', 'f8912e7b-5cd6-414f-ad5c-1e4de686d412', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCTSTId, '364c0172-c988-4bdc-b4b0-847286ead95a', 'My Opportunities Complete', 'b66478e5-00f0-45b6-8acc-2495a13653e5', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCTSTId, '7ed216ba-6a38-4991-88de-32e726d84aaf', 'My Opportunities Creation', 'a3cb6056-908e-4a69-b6a5-313259613f3c', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCTSTId, 'f534123c-df11-4c7d-ba3e-e3f70027fa08', 'My Opportunities Lost', '4d6488dd-c4c4-4c7d-9b59-7afcd0c2be12', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCTSTId, '28f6f80e-d885-4b48-a479-f989a7dc44d4', 'My Opportunities Now', '3747dc18-66c2-4e32-a275-7c896ff968dc', 'TST')



INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCTSTId, '4c9cbfea-1f07-4db6-87ea-981ce0925ee7', 'My Opportunities Pending', '56a17909-e44e-4ca3-89ed-c03c7a5fdb78', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCTSTId, '58540943-a232-49e7-a2d9-eb97fd9f107b', 'My Opportunities Recurring', '6ea77432-4ca5-4c71-8cfe-42d47c6e19db', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCTSTId, '3d6b5153-68b4-460b-bd25-a9b4687d24de', 'My Opportunities Won', '2be37c37-2da4-4dc0-b850-37d507dd796c', 'TST')



 --===========Work Flow TST---===============
 ----====================================================================

 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFTSTId, 'ff036413-8cb0-43b0-8f53-6634a044fe69', 'Actual Contribution', '7bd6203b-55b7-4473-aae5-f685cb87fc31', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFTSTId, '44f7fbd3-fdf6-4d41-bfff-d28875f40dfd', 'Actual Contribution DeptPOC','a52c755c-c38d-4599-913a-90073f553469', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFTSTId, '7ae7da29-3360-4a4c-8ec5-2ed1322bd2f1', 'Actual Contribution POC','167e0176-6aef-4ba9-94dc-0780cc55d422', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFTSTId, '67540438-03f0-4361-941e-3da1b806ddc0', 'Cases Approved', '227fd317-2cdc-40fa-84d2-8f2a194fd4cb', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFTSTId, '417b8142-715b-4925-8393-5656560f6e3d', 'Cases Cancelled', 'dbf841ce-3959-4727-b5a7-6fe7da29f2da', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFTSTId, '24a0de4b-37b5-4776-8899-704c51a72aaa', 'Cases Completed', 'e39f42f6-976c-4d33-b7d5-395b354acb8e', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFTSTId, '37c85ca2-2039-432b-bff4-6f839c4a7c21', 'Cases Created', 'e9ae8919-2b7f-4748-bd61-315245feb0e1', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFTSTId, 'ad255b26-5cf3-4f6d-b530-d41ddf2eb1d9', 'Cases For Approval', '1d8450d6-b293-4040-8c9f-656b39dc71e5', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFTSTId, '5cd6a358-7c13-427f-80cf-73bb306d18ab', 'Cases On Hold', '7d9d50dd-0075-460f-b43d-98b157d6ff67', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFTSTId, 'bfd2bb61-d074-4ca3-8566-4246b09bc54e', 'Cases Unassigned', '6ae73d87-0166-4c55-bc42-a4775acfe9fe', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFTSTId, '8e7d00ee-b4e2-498d-914c-91b0dfe78553', 'Chargeability', '926103c3-944f-485c-a246-92980aeef600', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFTSTId, '52ead55d-954e-471c-8666-610ff7581731', 'Claims Tracker', 'e40ec700-eee3-4e74-9a06-ccd6dd956aa4', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFTSTId, 'b4d417b1-dbbb-4ca6-aecc-b4c4064e08a1', 'Clients Created', 'bf267d57-fbd4-48c1-8bec-cc215e6812c7', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @WFTSTId, 'b4d417b1-dbbb-4ca6-aecc-b4c4064e08a1', 'Clients Inactive', 'ff0cc36c-1cd0-46ad-a791-793ebd82459b', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @WFTSTId, '2cebac58-d276-48f4-96f4-32dbade7d7f9', 'Clients Now', '5fb65869-adeb-48c4-be99-149f6e3253fe', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFTSTId, '6371cefb-daa6-481d-80c4-365b2cb04ad0', 'Clients Re-active', '1b3e55f8-05e2-4941-9137-4176acfb9d42', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFTSTId, 'f156f436-4c7f-4e70-b69e-f4099b75c023', 'Incidental and Claim Tracker', '097ed118-dbad-45c6-9401-a735e141ac90', 'TST')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
--VALUES (Newid(), @WFTSTId, 'cc340d4a-02e8-4d53-948d-918621bc8b45', 'Incidental Tracker', 'ff57792e-8afc-4bea-bac9-ed5e87b1a7ca', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @WFTSTId, '0da83844-e00e-4a94-9069-efdf6138a850', 'Individual Case', '8de2d5de-c610-4c48-b93f-3feb6c6c9c83', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @WFTSTId, 'ff85f5e1-81b0-43d4-a9e0-40f78b5a2a32', 'Individual Client', '5e84221f-85a3-47c6-8695-2639f1dc0df2', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFTSTId, '68e1ba7e-fc6f-401d-a59f-a37303383ec6', 'Invoices Generated', '0ae3f5b2-f04b-40a6-9128-3b132e1c5442', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFTSTId, 'a83261f0-40dc-4554-a3f1-8b41553a892b', 'Invoices Not Generated', '6af3c655-c9ca-4524-8b10-6ff0dd9011d9', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, 'ade554b2-24ec-40a1-8a79-788df9b4313e', 'My Cases Approved', '7c04f2a7-457d-4289-9a5f-675911c8c192', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, 'a645735a-dde3-4595-8c00-81c5e318887f', 'My Cases On Hold', '366a3544-8275-448c-aba8-5a4c1b47af21', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, 'b1ddcd1a-ddb8-476e-be61-1e12eac51491', 'My Cases Unassigned', '048b5e8a-6650-4906-9ed5-a800d01519b7', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, '4e2d6a9e-84f6-41c4-bcfc-7122acaacb97', 'My Invoice Claims Tracker', 'd09f8c29-f65c-4a5d-b92f-2047eeb13573', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, '1b88b440-7890-4ba0-b440-51b7d04a2da4', 'My Invoice Incidental Tracker', 'febc2a29-e64d-4767-b7d5-90bc5abed6f2', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, '8d523da7-9b91-4a44-8e16-5b89923ca572', 'My Invoice Unpaid Amount', 'cdb4f61e-a7be-41e4-9701-74caa6539478', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, 'dc2e0a91-a345-483b-8895-0d4ef1c5367d', 'My Invoice Generated', 'b771dd72-a83f-465d-a1eb-7ffac8f4c0ee', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, '8b3bf141-7859-4692-93ec-acde6a3f258a', 'My Invoice Not Generated', '7c81e465-03d5-441e-a0ef-09cdbd31a2e0', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, '82017505-a83e-4d92-82d0-9ce41814141a', 'My Leads Now', 'a15f88a6-d94f-4398-b8b1-6c9e1cd6ae04', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, 'b23a1499-6d86-4d65-bcc8-83febfba4048', 'My Schedule Actual Contribution', '84268df6-b0f0-4ea6-9340-afa605d62b3a', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, '98e76db7-b70f-4011-8d4a-60cb015e17fd', 'My Schedule Chargeability', '7e7358a6-e9d4-4439-aad0-4aee1feab887', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, '79a882d4-c84e-4cf8-9a6b-f824fa4f8430', 'My Schedule Planned Chargeability', 'e6451995-52d0-436b-bb8a-12e05bfe980a', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, 'cb0bf426-a048-4e43-93a2-2231788345a9', 'My Schedule  Planned Contribution', '90a9607d-10ef-4bfe-a169-0c36a73ea1bb', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFTSTId, '3988c453-f72a-4dc4-992e-52991f1175e6', 'My Schedule Recovery', '1cfdd1e8-aee9-4487-8991-128542b73bc4', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFTSTId, 'ac398348-94a4-4dbe-bdb8-e27ad12c8a92', 'Planned Chargeability', '48a43401-b193-4923-8b4e-cf8392ac1e60', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(), @WFTSTId, '1ea4b0ac-c785-4a81-a918-b8a70f3cc4bf', 'Planned Contribution', '35b23ece-334f-472b-a6d0-ffcafcd92a60', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFTSTId, '9e508f51-c87f-4dc1-8b1c-831779b159b1', 'Recovery', 'b6c894dc-8591-4242-9cc9-e7af20148dcd', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFTSTId, 'e3a6f3ed-c124-4edc-998d-8952097db4fc', 'Training', '0097bb0d-1594-4ff3-a153-8756ce41f2a2', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFTSTId, '0ad6d487-134b-4607-b4c9-be07ffc3dfcc', 'Unpaid Amount', '66b44cb8-9bf7-4497-938f-81b238472754', 'TST')


 --===========HR TST---===============
 --=============================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRTSTId, 'a8a3254e-872a-4742-ba81-e9f444f2786b', 'Attendance', '0d64cf3c-b6d7-48bd-ba2c-6281c6de7e0d', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRTSTId, '80c4689a-379d-436e-87d3-22dd4d198b1e', 'Attendance  Dept Poc', '3496b76a-4b7a-440c-8110-28fe5c17c3b9', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @HRTSTId, 'aee03e0c-4d4f-4971-bf27-0f17b10ecfa0', 'Claims', '61f8a33e-5733-45f5-ba31-0c79ddf562d3', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRTSTId, '45bb693b-876c-4471-a66e-55de023060d9', 'Employee & Department Detail', '3861ef21-0b3b-40bc-b12e-f6da021d1776', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRTSTId, '8e1c0b48-8cc9-4caf-b48f-1b270ce0a60a', 'Employee Details', '43146bcd-2d1b-42f5-a6ef-ca64a758c05b', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @HRTSTId, 'a15c8ebe-a136-4780-8de5-0bbb970ce317', 'Individual leads-Accounts', '96e81658-e619-4635-8083-520237b92270', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @HRTSTId, '921a303c-96fb-497f-af68-10cfac73b77f', 'Leads Creation', '71ee4fe7-29dc-4814-bcf6-9942616a1acd', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRTSTId, '8d466956-86b1-467d-8b35-79f9440cecda', 'Recruitment', '55663c07-2b6e-4db4-b969-e05f11d21e1b', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRTSTId, '4d1eb328-8cc4-4568-9865-d881df5badc8', 'Training', 'df12cd5e-8d2d-4e87-942e-ddc123b1b9f3', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRTSTId, '3a771d50-8962-46ac-92a8-26548813e66b','Payroll', '083f9aaa-f80e-4e0b-8026-bf815d140c53', 'TST')

--  --===========Bean TST---===============
-- ----====================================================================


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
--VALUES (Newid(), @BCPRDId, '5cbc20a8-5f22-4f9f-b671-4092d6786f9e', 'Bank', 'df15c9fa-444b-429d-81c2-a3d18e65b3ee', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @BCTSTId, '62a88587-c16d-4133-aea2-9f2d77c5c135', 'Bill', 'e36d7659-44ed-406a-b0ca-355f7f86ca26', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @BCTSTId, '67c33a63-3bd1-4f64-82a0-03f0bfaa013a','CASH AND BANK BALANCE','077cb52e-ba2a-41c4-8f1e-f7429d194325', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(),@BCTSTId, '383837c8-b9de-4e02-9700-9a1f11c47675','Cash And Bank Balances', 'a95a1372-443a-4d43-b6ee-80235f3149e3', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(),@BCTSTId, 'e8a94142-18e0-4d68-8bf9-bb2bf65f2d16', 'CASH AND BANK TRANSACTION', '88e62acd-7d62-4434-9c7d-ce6f04deab20', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(),@BCTSTId, '1243f472-39fb-46ec-983e-81199b9a0de4', 'Customer', '33b7d5c2-7e0f-4cd5-b808-785dbc07f1eb', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(),@BCTSTId, '0f852c7a-33d4-4264-8068-5ea31e826be4', 'Customer Aging', '8690336e-79ff-4ca1-9714-1e2a6fb19fa9', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(),@BCTSTId, 'a8e5e8a1-ebaf-4774-9df6-86a786d80397','CUSTOMER BALANCE', '81f06d86-ffc5-41bd-97dc-187a84e8b103', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(),@BCTSTId, 'b4cf5823-6d9a-427c-8fe4-8238f9ea5378', 'CUSTOMER TRANSACTION', 'fe02b462-77a5-4352-beca-0346879b3a8c', 'TST')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(),@BCTSTId, 'ccafde8d-ef2a-44f1-9a5b-d89e2795d1fb', 'Financials', 'a799c46b-549f-4f8a-9e36-aff8424b3713', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(),@BCTSTId, '10beb79b-1b6f-4ede-986b-2d079d5162dc', 'Vendor','d58b4dc1-8ac3-4573-9735-fdc3afff6ade', 'TST')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(),@BCTSTId, '8ae18640-151f-40b1-819d-0f3eed986d40', 'VENDOR BALANCE', 'fbe79c2d-f60b-4db1-862d-ad5271cf8df0', 'TST')



INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(),@BCTSTId, '6bc3f130-177d-4b71-8a8a-1ce424ed46bf', 'VENDOR TRANSACTION', '1e2fb068-5556-498a-8d3e-057199355a9b', 'TST')


End
GO
