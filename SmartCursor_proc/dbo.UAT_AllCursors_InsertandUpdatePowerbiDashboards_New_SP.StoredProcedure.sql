USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[UAT_AllCursors_InsertandUpdatePowerbiDashboards_New_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[UAT_AllCursors_InsertandUpdatePowerbiDashboards_New_SP]
AS
BEGIN


 
 --Declare @AuditUATId uniqueidentifier=Newid()
 Declare @CCUATId uniqueidentifier=Newid()
 Declare @WFUATId uniqueidentifier=Newid()
 Declare @HRUATId uniqueidentifier=Newid()
 Declare @BCUATId uniqueidentifier=Newid()


-----=====================BC-UAT
 

  --INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
  --VALUES (@AuditUATId, 'd9cc1dd9-3ec3-4223-ad93-33b4bbb04b0d', 'UAT', 'Audit-UAT')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@CCUATId, '4abc05e1-b895-4382-bb85-7f6067732af4', 'UAT', 'CC-UAT')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@WFUATId, '3764882d-290f-4cca-ade4-e37bb5113e18', 'UAT', 'WF-UAT')

   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@HRUATId, 'bf4d11f5-dc4a-4085-83ed-b9b5eb77d433', 'UAT', 'HR-UAT')

    INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
  VALUES (@BCUATId, '91e204a8-4b25-42a6-b427-2212bd6742de', 'UAT', 'BC-UAT')




   --======================================================= Client Cursor ======================================================================================================
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCUATId, 'e8b1c740-5412-4223-8d29-53881704b9d9', 'Accounts Inactive', '2b3b64a2-535b-403f-bc89-b438acf15f90', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCUATId, '36c9038f-f5a9-4f85-b494-28fcb05d9713', 'Accounts Inactive Report', 'b44fc772-4842-4954-9d90-e6621153cac4', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCUATId, '2a988a04-fa0c-43c1-bd76-d39717ed07dd', 'Accounts Lost', '1c27b25a-53b9-4174-a445-8ee4a0b8b81e', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCUATId, '49ec6e95-47e1-4354-b706-742d145a5fbd', 'Accounts Lost Report', 'ac65ea6a-acec-439a-84a1-1d0dda65e3b2', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCUATId, 'b48d4d7f-33b7-4904-9ecd-2de0bb773464', 'Accounts Now', 'a6b613d8-951e-4635-a2f9-b480d3d7fcd1', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCUATId, '83455e30-d579-41ba-aba3-75233e691dea', 'Accounts Now Report', '131961ce-b61b-4b39-b44f-dcf18a28e9e9', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCUATId, 'a1d65460-e291-44bc-8be9-dffde82b26be', 'Accounts Re-active', '8aacc2de-4242-406c-a150-9ad38fa46ea6', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCUATId, '34217774-cac7-4333-95e5-17caa96a5f3e', 'Accounts Re-active Report', '7a2683ca-53bb-42f2-869a-7e3b085d91e6', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCUATId, '4f36c843-eeb7-43ed-b570-472e7f7b4028', 'Accounts Won', '1359c209-a8e7-4b57-94f2-3ab30d844d4a', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCUATId, '2c2aa032-d715-49e8-88d2-c07504990a19', 'Accounts Won Report', '1597af6f-0dc0-4d29-86ef-209ff31551e9', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCUATId, '62c2e077-962d-44b7-940e-d5da4ca39b51', 'Camapign', 'b001a387-7ede-4d16-8173-38a211f34301', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCUATId, '548c1544-abcd-433e-93f1-45a7d2223fe1', 'Individual leads-Accounts', '81037026-f2cd-4841-88e0-49a8b5dbd816', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCUATId, '6509cd18-5278-41cd-8d94-f901f074f1fe', 'Leads Created', '30f0d969-ffa1-420d-9ca2-ee25d1eca815', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCUATId, 'a3a0d906-ed51-436c-849e-11a26b97fe4d', 'Leads Creation Report', 'a3b31de8-8a31-4b62-9e9b-52d57c008db0', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCUATId, 'f2edc6fa-690f-4794-b9f5-4480c3ad3046', 'Leads Lost', '43eea1fd-12cb-4eac-b8ab-fefc063b77d0', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCUATId, 'a63445d5-fa83-4333-97db-4c2cd5cdc607', 'Leads Lost Report', '422f7471-c240-4169-a024-9bb8070c52ed', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCUATId, 'd0bc4324-9da8-404d-ad27-9b7d0c606b18', 'Leads Now', '4c2f652e-97ca-45d2-94e7-b4e0162d59e3', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCUATId, '163a5823-49fb-4e72-9bb6-20ab62757e40', 'Leads Now Report', 'bd925723-a81b-4448-8d3f-dfd7b95f3767', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCUATId, 'c49c7be4-1214-4f85-9038-b9608d7301c5', 'Leads Re-new', '502f3859-0135-47ac-ad18-ae46379775be', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCUATId, '417b3825-2d4e-470a-8671-83bf29516aff', 'Leads Re-new Report', '2a43811d-025c-403e-b8de-9b7fa88bf65e', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCUATId, '94fa3f63-98b0-4bb2-b68a-8e41c5bb9319', 'Leads Won', '874ff57f-64d2-4ced-8377-330165272827', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCUATId, '4fad954d-70cb-413d-beed-b61b9eeefa07', 'Leads Won Report', 'f0571d95-4203-41da-82b6-be7039d737c0', 'UAT')

------------============My Accounts-=============-----------------------

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCUATId, 'b54fbca2-8bd0-4785-a609-e74ace7abc34', 'My Accounts Inactive', '5106a2dd-2c65-4c6a-b273-7ef6e9f722d4', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCUATId, '66076d26-a8ad-4d2a-bd03-036a33cd31be', 'My Accounts Lost', 'd9de96af-c2af-4f3b-a055-cf412467a3b1', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCUATId, '4347a637-ef86-4a3d-b2d1-c92607d3ae79', 'My Accounts Now', 'a24fbaf5-f798-437b-b009-ec5cb48b87db', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCUATId, 'aa9f06c3-5135-4cad-a5ba-22ab255323ce', 'My Accounts Re-active', 'fd0d3339-2f33-4ee2-a509-81f507af221e', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCUATId, '3800cf5b-32d2-44f7-acf5-5fa9cf38c366', 'My Accounts Won', '3702ea17-327d-4fec-aca2-5ff106594514', 'UAT')


---=================My Leads==============-----------------


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCUATId, '4aa5ee39-e72a-4a48-9cbb-eea7f52771d5', 'My Leads Created', 'b540a5c5-b56e-4701-9dde-5d736c48525c', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCUATId, '1fd03002-ef92-47fb-898a-59f1b0d0db3e', 'My Leads Lost', 'cbbc41bc-c06f-42f6-8cff-aba3d1feaead', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCUATId, '156ce15a-db89-42cf-ae99-d2c70184ed6d', 'My Leads Now', '7c96c2ec-ec68-44eb-90e4-4a5b5aa183a0', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCUATId, 'e7a5b9f4-1b6f-40db-b7aa-ebf9b2510d80', 'My Leads Re-new', '53766a34-580b-4417-aa8a-e967219c5077', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCUATId, '246a0d33-f752-4637-8fd7-a0543e74aa51', 'My Leads Won', '6040fb6e-519c-49d9-a2ba-370b2c775813', 'UAT')


---------------==========================Opportunity---------------------------------

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCUATId, '0b18647e-40f4-49ed-92b8-4c146cec5f02', 'Opportunities Cancelled', 'a5b6a6df-031a-4c63-83cb-492e472ec0d1', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCUATId, '62a87053-fc9f-49e6-a4f6-2604ac20fbab', 'Opportunities Cancelled Report', 'd9efa3d2-6b1c-4138-8c3a-332f96f6d793', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCUATId, '0605c96e-40de-4e5f-8dc8-6870e5aad635', 'Opportunities Complete', 'eb752fe0-2ead-40b2-be07-fff139c7ddf4', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCUATId, '342347c6-d105-427e-850f-a604d07e503c', 'Opportunities Completed Report', '8cf8d6cd-d348-408f-8177-ba437050e43d', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCUATId, 'af78b65f-383e-4723-aaed-e7ef066c90cd', 'Opportunities Created', 'ea969436-c204-42a1-bcc8-b05eb1eed6e1', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCUATId, 'b68ccc9b-cbc8-4a05-8faa-54c908282895', 'Opportunities Created Report', '7d2d6cfd-e653-47ff-8f7d-64d63da73669', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCUATId, '1c54a3a1-0097-408b-8160-d83dbac0c3d7', 'Opportunities Lost', '645ebfc4-a2cc-45eb-a6c0-c95e217b1a67', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCUATId, '0e158068-bc4a-4a3b-a890-7edf3e21d86c', 'Opportunities Lost Report', '13549ed6-51ac-4700-90c4-47d7c08729fc', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCUATId, '2cc9605c-578d-47b4-889b-23479b1328d3', 'Opportunities Now', '50523a50-b472-42d2-92b2-aa592fdf9299', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCUATId, 'bba77315-9278-450a-a5b2-1c3e43715289', 'Opportunities Now Report', 'ad291aca-a4c5-4561-8bef-ea14bfabd77f', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCUATId, 'b717ab10-dbab-4dba-99eb-655d8b502685', 'Opportunities Pending', 'df3852ca-5e13-47f7-a16c-daafee9dbd48', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCUATId, 'e7321ecd-6ad5-457e-a1e8-05de3dc82ad0', 'Opportunities Pending Report', 'b19a0dfd-63ed-46b0-a61c-becf3c0ae6c4', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCUATId, '7e9fd6be-77aa-48db-af47-7f41ac9f1cc8', 'Opportunities Recurring', '564bcc94-f6fc-4f1a-bd53-20fa71dc16f7', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCUATId, '5e25cc6e-567a-4f7a-a73a-cba2daa984aa', 'Opportunities Recurring Report', '66f40627-0699-4a16-85f2-0d6e8e8d8e54', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCUATId, 'c2b65b3b-aa9d-4210-b9b0-b146abad59e6', 'Opportunities Won', 'b4d7b0c7-ef8e-40fa-8e3e-afb7750a90ff', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCUATId, '8e457f77-d868-4a2d-a022-6863fabe1040', 'Opportunities Won Report', '58a6987d-2906-4877-9315-f99c4fb606e0', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCUATId, '06830f6b-a811-4ac7-ac5f-91481592880d', 'vendors', '6bb4101a-9528-44ab-9c28-5c8f61f49345', 'UAT')

---------My Opportunity------

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCUATId, '90e0908d-797f-415a-83d4-07058bdac7a6', 'My Opportunities Cancelled', 'e5e5c735-b87d-456d-b33f-004f77bdf619', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCUATId, 'cc444d8c-2da8-406d-b73c-21cabdfa0f03', 'My Opportunities Complete', 'e4688432-8c64-4c3f-8f53-fadea7254c9f', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCUATId, 'be88b2c4-0bb4-437f-afd1-4940667eaac3', 'My Opportunities Creation', 'd70d3613-95d4-47aa-b68a-54f3c9af6fe6', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCUATId, '5453ed2b-36a2-41c0-9242-7948fedaf21e', 'My Opportunities Lost', 'fa827d8c-98bb-4036-ab7a-c428588286bd', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCUATId, '5f735913-9143-4a24-a674-355576492565', 'My Opportunities Now', '2b3ec851-1432-4c2d-acd8-68b7bccd9d96', 'UAT')



INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCUATId, 'a30b9a17-2b44-45cd-abf2-fef7c667db75', 'My Opportunities Pending', 'b020d330-7f08-4a28-a7d2-37799794849e', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCUATId, '60f8ad1d-16d7-49f1-bbab-7b837e5a2b16', 'My Opportunities Recurring', 'ff0edd8a-1313-4d2f-8ede-6017d1642167', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCUATId, '38defedb-3092-4a94-a365-f2ba22fd5822', 'My Opportunities Won', 'f24487ca-47c5-44c4-8576-a3a49135eb45', 'UAT')



 
 --===========Work Flow UAT---===============
 ----====================================================================

 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFUATId, '6205d032-63bc-4157-8850-b8055e09d869', 'Actual Contribution', '78ae2543-9b00-419c-891a-ffc538aa5835', 'UAT')

 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFUATId, 'a150a9ed-81a6-48e9-9ca4-53eb9fbd1897', 'Actual Contribution Dept Poc', '5a373256-1c44-423e-ba09-9ae64ba845dd', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFUATId, '68c9cc01-ecc5-4ca3-a6ee-8bb3ac5f3e02', 'Actual Contribution POC', '72e0e07a-217b-4b15-8dd0-aabbc445b24c', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @WFUATId, '978c6796-139f-4b01-a997-d64ddbf6ef72', 'Case Members Report', '2dc4198c-5d38-4b48-a010-6a382a01aae8', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFUATId, '14f99584-a8ca-41ea-85e4-2500cac339d4', 'Cases Approved', 'b5138455-55fa-4f97-b4e3-8815ed259d7d', 'UAT')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
--VALUES (Newid(), @WFUATId, '5dfc52e1-24a9-4ea2-babb-3e211a17c7ab', 'Cases Approved Report', '117d800f-c7a4-460b-902f-4dbdf4c472a2', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFUATId, '0acfa6dd-08ad-455f-ac02-a7c96144af00', 'Cases Cancelled', '53c0fb67-8fa4-46fa-b66c-e687c1251834', 'UAT')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
--VALUES (Newid(), @WFUATId, '3a02ff8c-463a-4e40-bd5c-5307c4799d79', 'Cases Cancelled Report', '10a1a5e9-ecec-49ec-9efe-18541fc0a261', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFUATId, '90393c22-af29-4f21-9a40-96792cd173e1', 'Cases Completed', '89f62e91-9084-4eb5-9b08-9cf1ed469105', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFUATId, 'e29b946f-1f23-4f03-85a4-99a4a0e21154', 'Cases Created', '8033725e-7e79-47ef-ac46-9bd70e40fa80', 'UAT')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
--VALUES (Newid(), @WFUATId, 'd2c8ae0d-de20-4df9-b682-107ce1667e4f', 'Cases Created Report', '5da1fcfd-4f54-432d-8e28-0b9313e26504', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFUATId, 'fd0823a7-f611-48e0-897b-acbffb84ce94', 'Cases For Approval', 'b61464cf-3f61-4ff8-88d6-a4f8a27a476e', 'UAT')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
--VALUES (Newid(), @WFUATId, '2222d02c-abb5-453c-990b-25f21ed30df4', 'Cases For Approval Report', '6853fc27-b8cd-4567-834f-b1e50abeae6e', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFUATId, 'fd70aa8e-703a-4df8-8daf-9fa254e05b33', 'Cases On Hold', '4bd50313-4a64-4ef1-9f9c-ac93719067db', 'UAT')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
--VALUES (Newid(), @WFUATId, '1f890cf0-bb97-4c77-a08f-b67d328f49ef', 'Cases On Hold Report', '90389c43-6ccb-4be5-87f1-41b3d9562f28', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFUATId, '18eb1a4f-f73e-474f-ab78-14447c24c415', 'Cases Unassigned', 'e688ab7f-80ea-49b2-b408-215306990a73', 'UAT')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
--VALUES (Newid(), @WFUATId, '5b11cf96-db43-464d-98cb-06ee019da1ee', 'Cases Unassigned Report', '0a15e186-150b-449f-8df9-b1c922b0fe32', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFUATId, '74de1c05-0997-4b4d-95ac-90305805d59d', 'Actual Chargeability', '3142b867-e8a8-445d-951d-4781ade24787', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFUATId, '0d929022-ada3-4803-8ffa-b5b80902772a', 'Claims Tracker', '3d91b7c7-71cf-46b5-aad6-f0780a0f4539', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFUATId, '1c9899e5-f99b-4392-b440-2882aaf6ecdc', 'Client Contact Report', 'd0852126-1ee3-4caa-a32e-d04428b0a953', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFUATId, '664fb701-1499-4aa6-959e-aee18f0f5977', 'Clients Created', '88a32cdf-7b26-4785-ba12-310d45b31f7b', 'UAT')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
--VALUES (Newid(), @WFUATId, '74011ee9-6854-4181-9071-96bfcac20bd1', 'Clients Created Report', 'f2702bdd-44be-423f-a80b-48556021368f', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @WFUATId, '9c9687ea-47b9-4863-83ad-7d2fb66a1ea6', 'Clients Inactive', '53819846-339b-416f-94e3-7498546aedc3', 'UAT')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
--VALUES (Newid(), @WFUATId, '05983284-4a9d-4c21-9de7-6465209e1bf8', 'Clients Inactive Report', 'af1d892b-9d6a-40cc-8085-57886a53c91d', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @WFUATId, 'f511e122-bf3d-496e-9fdc-95e51c002c5b', 'Clients Now', '12b467ad-81e4-48e8-a6ff-3ad4e45a3875', 'UAT')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
--VALUES (Newid(), @WFUATId, '91648f05-db04-4b20-8b74-ae67890e931d', 'Clients Now Report', '76a44de8-7658-4643-8e56-0215a1322dc8', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFUATId, '3915c734-0047-4ed8-9398-b78971845ed9', 'Clients Re-active', 'f42e2cbe-60b5-4396-9a4d-9f52dcebf484', 'UAT')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
--VALUES (Newid(), @WFUATId, '7dccc36c-62e1-4da6-bc25-603466a26089', 'Clients Re-active Report', '88f34d78-e548-4058-9115-515c79e007e8', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFUATId, '79aebcbb-ab63-4848-b00c-8a43cfc8886f', 'Incidental and Claim Tracker', 'c009f4a8-9946-4a68-8058-270e96b0676e', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @WFUATId, '17cf8653-815c-4f9d-bd0a-8c1fbd1db31a', 'Incidental Tracker', 'e0ae581a-146d-4658-b0f2-373b6dfbc1e5', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @WFUATId, '948c1d8d-e263-44ca-8c4e-07d75f9ec168', 'Individual Case', 'c72d602b-8eb0-4af3-a4fd-f24d03958d22', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @WFUATId, '3d1ebc42-3d27-400c-803f-0c675a862612', 'Individual Client', 'dcc7915a-1840-4f95-ab7a-91006ba37c12', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFUATId, 'c11196f9-e0ad-49c9-8d02-90a5fa19eb2f', 'Invoices Generated', '8f6c0b60-4fad-4d89-bef4-3ead50f73df1', 'UAT')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
--VALUES (Newid(), @WFUATId, 'f626ebdc-46b0-400b-8602-10e8ca4b86a8', 'Invoice Generated Report', 'd01fdc36-190f-4dd9-a67c-27d51574ea76', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFUATId, 'cc2196a7-cc53-451b-ae6c-cfc07d00bb7b', 'Invoices Not Generated', 'cd4d3841-b38c-4d34-96da-6fd2a2cc8a00', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFUATId, '736b82b6-46e8-4dc1-b4ed-23de7a585311', 'Planned Chargeability', 'fa738510-6446-4280-b2d3-e46d99ef2a53', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(), @WFUATId, '3b16c4a8-e52a-4e60-aab5-b3e508cd782f', 'Planned Contribution', 'a3d1c032-1ab9-4a5d-a49e-786916f5d026', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFUATId, '4d71ea31-9988-4f13-beb6-1546282266e3', 'Recovery', '8f16988e-d933-4e70-976c-7f5204920476', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFUATId, '21693deb-6335-480e-a99b-dea628ede5ad', 'Timelog Detail Report', '68cf6b26-72b3-438b-91be-8dfa8084e99a', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, '9623a279-b15a-425a-a20d-116b2cdb3273', 'Unpaid Amount', 'fd63a57f-96be-4c33-8e58-f10137ef92f2', 'UAT')
---==================My Case==============---------------------------
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, '40258c99-72f2-4117-8802-8d0addf6f0d2', 'My Cases Approved', 'a358dcb3-35a9-4131-aeb7-5a72cd1da57e', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, 'f5d2d7fc-e31a-44a8-a8e5-1614cf2d16cd', 'My Cases On Hold', '35e83dea-62bd-4213-8266-67118323a83c', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, '211af510-a8f9-45ff-9c18-49f50ea8f679', 'My Cases Unassigned', 'd3021ca9-7d3b-4fd6-b217-6ad525207d99', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, 'b344b9a6-ac6b-4c2b-9ac5-81fa71355816', 'My Invoice Claims Tracker', '1ac0b3a1-13d6-41d4-9810-c84490b638f9', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, 'e08ae167-45c7-4b17-a18e-747b821f8ef8', 'My Invoice Incidental Tracker', 'dc78f3a2-743f-4a41-9363-1b318b00a5b0', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, 'a337938a-cf1f-457c-b86f-cd7b80ed36d7', 'My Invoice Unpaid Amount', '4fe6292c-6ed1-4f1f-abf5-adc2bc360421', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, '33041c7a-afb4-4cf8-943c-754eef6182da', 'My Invoices Generated', 'f2c0bf5b-ee5d-4c3e-a867-f192a4d05516', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, '070cfc68-9d73-427b-8973-3a043281b3cd', 'My Invoices Not Generated', '11d09acb-55b9-4683-a679-ab1df6d579e6', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, '7060dcd3-bf01-4506-b2ad-3ff2f1bf0d33', 'My Schedule Actual Contribution', '41a28fb6-29de-44e5-9402-c26f46573e9c', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, 'b28036ed-86de-41ba-b160-b1f2254f2b5a', 'My Schedule Chargeability', '2315f164-acf1-480f-aee6-57600658b299', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, 'd66ed414-31c8-4c51-bea2-b093134ba419', 'My Schedule Planned Chargeability', 'afc7fbea-5dd5-42e7-ac5e-10350f990d35', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, 'a2a82c23-d16c-4ff4-af67-c033f15f9050', 'My Schedule Planned Contribution', '6ffe7f8a-a533-4411-adf9-f441e29457a0', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFUATId, '96b7aaba-45e7-4ea1-8a2e-208baa046682', 'My Schedule Recovery', '84c4126b-a37c-4885-b520-08c3a1893f3c', 'UAT')

 --===========HR UAT---===============
 --=============================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRUATId, '234304ab-3155-4231-b702-b10243c50252', 'Attendance', 'ae024d99-4f46-402f-b095-6b15f23bbf7d', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRUATId, '9d85c65e-09cd-4f33-8ee2-3ab5a3fe198b', 'Attendance Dept Poc', '2fe113b9-df03-4ca2-ac49-9850a081c120', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @HRUATId, '7c1fc2d8-7697-4207-8a71-7240f208f576', 'Claims', '4f3dd935-0434-452d-a57a-ca5b0176b8c2', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRUATId, '67a19fb8-5190-4bc5-9139-635acd0ba16e', 'Employee & Department Detail', '2f6dfbf6-4649-4947-976f-abe035c91708', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRUATId, '69ded6fc-48dc-47c4-9de2-85c1177f3178', 'Employee Details', '56bbcc54-6580-4e6c-b6cf-a3b141da99bf', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @HRUATId, '29f4678e-cece-4b87-9f4a-7b5f3c9ded38', 'Leaves', '4ce751c7-3652-4d1c-94c1-663f6a517161', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @HRUATId, '523a3522-b5f8-48e9-932a-c9f7a052611c', 'Payroll', '13054676-41d4-429f-bc4c-e3a739b1d151', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRUATId, '576af4f6-cbde-4c28-9779-35d81baf52e9', 'Recruitment', '40fd5f46-02ea-414c-bd94-e3a451cbd0a2', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRUATId, 'de1f740a-bd11-44f4-9ddf-3e61eb3a9e75', 'Training', '4d5fe41c-32be-4f63-93ba-f027b5c143d9', 'UAT')

--  --===========Bean UAT---===============
-- ----====================================================================



--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
--VALUES (Newid(), @BCUATId, '5cbc20a8-5f22-4f9f-b671-4092d6786f9e', 'Bank', 'df15c9fa-444b-429d-81c2-a3d18e65b3ee', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @BCUATId, '91f5f890-379b-4f19-b981-a3976cbe1e13', 'Cash and Bank Balances', 'f559a2ae-1428-4976-9ae4-ee65f04bab69', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @BCUATId, '931cc2d6-c36d-47ea-bf62-d7d42e8998ca', 'Customer', 'fb47bec7-7202-4d8d-b0fb-e403cc342dfb', 'UAT')


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
--VALUES (Newid(), @BCUATId, 'af583e86-0a24-4246-b0ee-ef37d67473b7', 'Customer Aging', '995d4710-9c2b-4b5d-9b88-d6b5e81bd835', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCUATId, '76e33cc1-9cbb-4ced-9466-7c1ec32f5150', 'Vendor', 'bd44440e-d9f4-47d2-b3e5-2e2e13febe20', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCUATId, '6fa8fb13-8d16-44c8-85d2-35e5a404e856', 'Financials', '4025a9d1-5bc7-4b05-a49f-c12ddcb7f562', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCUATId, '0d9a4715-32c3-4264-ae29-7f3c0c3dc90c', 'Bill', 'f3b20012-b59b-492a-9523-e716ecc29261', 'UAT')

--------


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCUATId, '28b62e79-5f09-4e5e-b5d1-996f832ffa5b', 'VENDOR TRANSACTION', '15a0d142-1e74-410d-8801-a055c8ff9f0f', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCUATId, 'e456348e-9774-41fa-ab3e-624f4862eea1', 'VENDOR BALANCE', '6ca6d389-0199-46bb-98ef-75aa48a5879b', 'UAT')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCUATId, '545eac5b-2028-4a0c-a471-c37b300dd699', 'CUSTOMER BALANCE', 'caf394f3-674b-4704-9028-0523310b7766', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCUATId, '4af7faf5-a9de-458a-bfd5-b42267505d52', 'CUSTOMER TRANSACTION', 'c26ee2e0-bd99-42d3-b045-d77d69fedf38', 'UAT')

----------------------=========================---------------------------

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCUATId, '459099d3-4028-4285-bc93-c6f63f652115', 'Cash And Bank Balance', '0c10c8c0-18ee-4c8a-a8b7-d29e3e68634b', 'UAT')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCUATId, '6479a219-6993-4c8e-9322-3c2f102df5f5', 'Cash And Bank Transaction', '4511ca3c-7389-48ad-a92a-25ef9975028a', 'UAT')

--  --===========Bean UAT---===============
-- ----====================================================================

-- INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
--VALUES (Newid(), @AuditUATId, 'e334e7a5-9e1e-4944-9bd0-1723d45ed05d', 'WorkProgram', '4f492e69-9bec-418a-99e6-c30c7805a872', 'UAT')


END


GO
