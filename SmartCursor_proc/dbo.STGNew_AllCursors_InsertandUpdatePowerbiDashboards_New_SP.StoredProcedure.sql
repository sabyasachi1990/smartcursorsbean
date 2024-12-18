USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[STGNew_AllCursors_InsertandUpdatePowerbiDashboards_New_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXEC [dbo].[STGNew_AllCursors_InsertandUpdatePowerbiDashboards_New_SP]
--==========================================================SP=========================================================================================--
CREATE Procedure [dbo].[STGNew_AllCursors_InsertandUpdatePowerbiDashboards_New_SP]
AS
BEGIN

 Declare @CCSTGId uniqueidentifier=Newid()
 Declare @WFSTGId uniqueidentifier=Newid()
 Declare @HRSTGId uniqueidentifier=Newid()
 Declare @BCSTGId uniqueidentifier=Newid()
 Declare @AdminSTGID uniqueidentifier=Newid()
 Declare @AuditSTGID uniqueidentifier=Newid()
 --Declare @NeoBankSTGID uniqueidentifier=Newid()
--=======================================================WORKSPACE IDS=================================================================================--

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (@CCSTGId, 'f5b1e1ea-fc1d-44be-876b-28e4062ae2dc', 'STG', 'CC_MC04')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (@WFSTGId, '89004625-5040-4d77-a82e-6e611372a135', 'STG', 'WF_MC04')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (@HRSTGId, '14c35a1d-66ac-4ee6-b2d1-5df4c108ae5f', 'STG', 'HR_MC04')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName])
VALUES (@BCSTGId, 'a27c184a-1ccd-462e-8c66-6d1a03f2707b', 'STG', 'BC_MC04')
  
INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (@AdminSTGID, '6bff3f45-080d-473a-bd3a-8072fc0eddd7', 'STG', 'Admin_MC04')
   
Insert [common].[ReportWorkspace] ([id],[workspaceid],[environment],[workspacename])   
values (@auditstgid,'c3f25329-80b5-47ff-ac6d-f9d425708573','STG','Audit_MC04')

/*INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) 
VALUES (@NeoBankSTGID, 'f5b1e1ea-fc1d-44be-876b-28e4062ae2dc', 'STG', 'CC_MC04')*/
--================================================= Client Cursor =======================================================================
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCSTGId, '0a66f8c2-0923-41c5-a196-6dfec8d52164', 'Accounts Detail Report','8ca742a1-3cd0-41d1-96fa-c0b26598399f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCSTGId, '1088fe7b-9e7a-4e0d-8de2-00ff0a6a38d1', 'Accounts Inactive', '351e2f93-446f-4cdf-bfde-2512c8c7868f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCSTGId, '47330bf8-2687-4044-96ad-356197b39871', 'Accounts Lost', 'fcf290b4-0088-45df-866b-ed443c1f4246', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCSTGId, 'd14b4ac6-247c-4c52-af29-c54033daabe4', 'Accounts Now', '70d87a99-5c60-4901-a5cf-e6b668d59a34', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @CCSTGId, '5e309673-f15f-4709-8c5d-d45ead830c4b', 'Accounts Re-active', '64c912a3-de4b-429b-8cb4-b0981b0b8e01', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--6
VALUES (Newid(), @CCSTGId, '4e7d6da8-b3c2-4dbf-82c5-0649c976aac0', 'Accounts Won', 'f204eb0c-f909-44fc-a577-ea5b9d5fcb6a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(),@CCSTGId, '0c1e7372-451a-4e85-99bc-11534b763549', 'Campaigns', '817302eb-d99c-423d-8a1b-80bf9ccc1398', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @CCSTGId, '31149dea-1c65-4893-846b-e4978843dbb4', 'Cold Accounts', 'ae092251-128d-4fb1-bab4-e31b9425ea90', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCSTGId, '36ad6769-0b90-40b0-bb77-4bb40a7c2403', 'Cold Leads', 'e4fc6d26-1045-4554-8c5f-eca2e63868aa', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(),@CCSTGId,'6d31a8f4-a1c2-44d6-9275-cd33989ef635','Contact Details Report', '8bee2a3e-50f2-43c8-91c5-5b73bbca1960', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCSTGId, '18b0c6f9-367b-48df-8a8f-964ba90a09bd', 'Delete Opportunities', 'e42c19f7-c585-4b0e-bf8d-f25782c91f2c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @CCSTGId, '6317cef7-7aed-48c9-95d3-802dc83d5cbd', 'Excel KT', '1629f757-07d6-4912-ad0c-582cded45ea3', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @CCSTGId, 'be6a9abb-f27c-4264-bf15-328e7ed79428', 'Import KT', '159ed5d5-f8ae-4bfd-aaa8-f0f208db4ee4', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @CCSTGId, '62f720dc-d6cf-426d-a4f7-131f5014a49b', 'Individual leads-Accounts', 'b4202068-80e1-49ce-b585-82bf70c5fa41', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCSTGId, 'ed476b93-7e43-4f93-829c-70ffbccb657c', 'Leads Created', '5a516e73-0517-4a08-9d55-ae764f1d5e2e', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCSTGId, '477e180e-a46b-4dc1-8103-f2db95094f99', 'Leads Detail Report','0ee15816-2a2e-43da-bd14-301cc4612eb5', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--17
VALUES (Newid(), @CCSTGId, '71b17d8b-7690-4507-9c84-af2763f60528', 'Leads Lost', '9729d5ac-2417-4936-8ca3-4c67b25676d7', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCSTGId, '5e4b6c5d-71f8-4dd7-8650-9ba2f9c6914a', 'Leads Now', 'aeda466f-e6cf-40fc-afc0-2c3b77096bd4', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCSTGId, 'e46a9684-d78c-4e98-9cce-c56ee2062550', 'Leads Re-new', '080c64b9-e5c1-4b9a-8a2a-32629005e0f5', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @CCSTGId, '6dfe3258-9906-4ae2-b7b9-924cd3e9b59f', 'Leads Won', 'c22eb3de-d315-4ba8-bd08-e92d2a06d27f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @CCSTGId, '08e82854-9216-4dd7-89d2-bae50dd5ecdd', 'Licenses Report', 'ad67ecbf-9097-4c12-aa86-535a30fa1ef5', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--22 
VALUES (Newid(), @CCSTGId, '0bcce17a-f730-42b6-9113-def5e5e42b96', 'Opportunities Cancelled', '6be433cb-deed-4a23-a897-b28663a01d5f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--23 
VALUES (Newid(), @CCSTGId, '0aab4833-b07e-4e72-b184-069b4d25dbb4', 'Opportunities Complete', '18b35e17-a6de-4a2a-8aa6-80d565a4cf85', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--24
VALUES (Newid(), @CCSTGId, 'd788c1c3-99a6-4a11-8c77-46048a2d0248', 'Opportunities Created', '99236082-8291-4b73-a16a-1969ac06850a', 'STG')---?

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --25
VALUES (Newid(), @CCSTGId, '091c8eb4-149f-4a2c-a959-36faccf46aad', 'Opportunities Detail Report','d6bc1371-9081-49c2-9217-baa0df6f2a06', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --26
VALUES (Newid(), @CCSTGId, '6dcd6e25-ea67-43b5-aaac-07c809d8bd1c', 'Opportunities Lost', '6690b261-a37b-4aac-b1c6-8e96f0167e78', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --27
VALUES (Newid(), @CCSTGId, 'a623e2e3-46ad-4e73-bfa9-c4f6e6c8ebc4', 'Opportunities Now', '92746f28-50df-4a1d-a51c-55120357b220', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --28
VALUES (Newid(), @CCSTGId, 'da1b0206-8809-4d2c-bbb6-a7b9b73348e1', 'Opportunities Pending', '84509485-b4ea-4d7f-ac5d-f2524cfc3b1f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --30
VALUES (Newid(), @CCSTGId, '66126d6d-a18a-4ad5-be34-8eb6c682bb09', 'Opportunities Recurring', 'cbdb82af-17d5-45a5-a7bf-8905ba82061a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --31
VALUES (Newid(), @CCSTGId, '00a72a17-fe03-41d0-b526-e775e5f3b436', 'Opportunities Won', 'bffab179-7c10-4018-89c0-8ce8105f6f8f', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --32
VALUES (Newid(), @CCSTGId, 'da9bdf25-a629-4441-b6f4-76aae732484d', 'Remainder Details Report', 'f7155f65-3678-4f30-8a1e-848885527b68', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --33
VALUES (Newid(), @CCSTGId, '3a55107b-230c-4f31-996c-12f073b36207', 'User Roles Dashboard', 'a9c7a67c-1103-4056-9f7d-3007ae8a0856', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --34
VALUES (Newid(), @CCSTGId, 'da20fcbb-7ead-4d88-ab9b-7245a01de016', 'Vendors', '1bee836e-171c-4250-8819-ffee9dd0fe47', 'STG')

--=====================================================Work Flow STG=======================================================================================--
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFSTGId, '09e9290a-aea4-4f04-ba9c-ff336973223a', 'Actual Contribution', '9744f145-ede9-4b50-bff1-685dfb3e7d6f', 'STG')
   
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @WFSTGId, '457b2dc4-232c-4ba1-9468-6be3c9b23a5e', 'Case Members Report','7343a922-b60b-4422-b60a-1363ee86da02', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFSTGId, '4709d0b7-3f87-4243-a713-edf57d477e32', 'Cases Approved', '24e78965-cfad-4044-80ce-f5e9250461bb', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFSTGId, '1cf04bb6-d581-4926-9557-5674ac974208', 'Cases Cancelled', 'ed9460eb-c50e-4dcb-8dcf-c69e840d9504', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFSTGId, 'c7e46451-f9ba-4059-af4f-6158e6d5075d', 'Cases Completed', '09f83a92-39ce-49a8-b966-713633928cc9', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFSTGId, '86d57c56-743b-4598-81cd-46e99db16c00', 'Cases Created', 'd3eea7b8-764f-4a8a-8b6f-495cd9ce4593', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFSTGId, '02f8e9e3-68e8-465d-931e-fd9a04da9536', 'Cases Detail Report','f50adfe8-06a3-4a24-80fe-71700cabc84c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFSTGId, '12d179f5-9f49-41e9-8037-f9fd307770fd', 'Cases For Approval', '21a9dac7-ad1b-415e-949b-2069ef507674', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFSTGId, '74b4616a-dbfa-4b8a-9bd0-1ec34de841a1', 'Cases On Hold', '9f55481a-3bbd-44d7-9841-937c39ec2450', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFSTGId, '6a360d5a-11bc-4323-b0a5-64dbf859393f', 'Cases Unassigned', 'ea2cceb8-4484-478f-9f48-5000ddda873d', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @WFSTGId, 'c09025f0-44ca-4698-9a29-aafaddb5e8b9', 'Actual Chargeability', '7faba1ee-0cb3-4d65-9432-3731474603a7', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFSTGId, '1ad1a4ed-d637-4c8e-befc-d2151ddc0308', 'Claims Tracker', 'a11450c0-cf61-42d9-a5ad-3c304a053fb1', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(),@WFSTGId, '685fb5f9-e4cc-4341-89a3-2b7187cce254', 'Client Contact Report','a92da67d-88f5-4a61-995b-0b7545d85a4d', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @WFSTGId, '6a164eaa-e789-472b-8b49-adce0b192a7e', 'Clients Created', '60010c33-a729-4f51-80e0-c495f6d2a0d4', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15 
VALUES (Newid(), @WFSTGId, '653dfd3c-9257-4da0-bad3-2dac642a7682', 'Clients Detail Report','10a6458a-ca64-4986-8247-18b4d0c75cef', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @WFSTGId, '7da55ee9-2684-40b7-95eb-c8a83e5de91c', 'Clients Inactive', 'fe3a70c2-cc4a-4f47-913f-4ac018c46e5a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @WFSTGId, '27517a05-9776-44c0-89f9-82e962e8d688', 'Clients Now', '4268b871-fceb-4989-bfe8-636a5a3823e3', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @WFSTGId, '80f33e67-ecf9-43f6-9536-11106a0e8ffa', 'Clients Re-active','8918fc3d-e0c9-4f10-a08f-fce4181fe056', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFSTGId, 'f3b8aa61-b354-4e92-9fad-c3cce2c67afb', 'Incidental Tracker', '437c69f2-e9cb-4427-8860-4ecbad5bfd2e', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFSTGId, '429b2279-8631-44b0-b478-4dcf75a67002', 'Individual Case', '5ba6f984-2e8e-4eb8-be0e-276d3d8338f2', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFSTGId, 'c0ed16d2-7016-4ef3-925f-7b17819c88cf', 'Individual Client', '14e49564-ed64-4853-8dc1-0e4eb2f657a7', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(), @WFSTGId, '1a72fcb6-debc-48f1-833d-2f7a14f568da', 'Invoices Generated','18d6e9be-a37d-4989-b131-8ca944704cb6', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFSTGId, 'b48daf04-11b7-41f7-b70e-2ccb3f217603', 'Invoices Not Generated', 'e93293bc-c905-42e9-bef8-c368c9d49f80', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFSTGId, 'f1854e07-ce5b-43e3-b181-37abe63cd33a', 'Planned Chargeability', '1a686f5d-aca8-455a-9970-4cc0ce3ecc30', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --25
VALUES (Newid(), @WFSTGId, 'e150108d-a518-4e75-90c8-962556532990', 'Planned Contribution', '6f8e96fe-b709-4cea-a33b-3e73beb75765', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --26
VALUES (Newid(), @WFSTGId, '78977685-42ee-4032-8222-224840b54b10', 'Recovery', '860d4255-283a-4c5c-97d7-211746488876', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --27
VALUES (Newid(),@WFSTGId, '17cff53f-7054-42fe-b757-2c67b077030d', 'Reminders Details Report','08f616e4-1804-4018-a661-96b3ad017f60', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --28
VALUES (Newid(), @WFSTGId, 'cec9140c-2a4c-467a-9ab8-d4af46fa285f', 'Timelog Detail Report', '76d07d35-6463-41a3-9bf4-0b983e406071', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --29
VALUES (Newid(), @WFSTGId, '5f96f72f-ce4b-4cab-9325-800c8af47936', 'Unpaid Amount', '584556c0-69cd-47bd-a6cb-19717f0d4ba3', 'STG')

--========================================================HR STG=========================================================================================--
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRSTGId, 'b67967ea-ff38-404c-8db5-84d30c24aaa5', 'Appraisals', 'd087d157-2850-4492-ad42-cc43f4f66ea9', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @HRSTGId, '00f0aa4f-a33f-4e3b-aa71-2c656021ff91', 'Attendance Details Report', '898b1ef9-c50c-4316-be4c-38b749cbbfac', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @HRSTGId, 'a7727574-c2b9-455a-a07c-0eff55d3748c', 'Attendance', 'a8833fcd-8881-47e4-9224-adc4c6668475', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRSTGId, '7b9c67d3-5e76-4182-9d19-c5e63611476d', 'Claims', 'bad640c7-ae6d-476c-9098-6711faefefaa', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @HRSTGId, 'b196bb34-83b1-4bbf-9bd0-cca6b3bbea4d', 'Employee', '412fa620-2450-4f2e-ab7a-1ce57e7330e6', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @HRSTGId, '75d9bdb9-8dba-438b-8e76-2895fd97cc21', 'Employee Dashboard', '45d3cff1-80b6-47da-b90c-96762089411c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRSTGId, '116209a6-5386-4b73-80f6-aa17622fd35f', 'Leaves', 'eff2ecee-30d7-42ca-a178-eb819036a458', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRSTGId, 'eeedd7b6-1997-4a26-a12a-b126fde1ea9c','Payroll', '97ca1515-4533-4cca-a742-9c3443e619a3', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @HRSTGId, 'a7f563f7-a879-4844-8db0-6dd93274403e', 'Payroll Dashboard', '0baa8fb4-d6b3-415e-8f84-f1923c102edd', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @HRSTGId, '60e1cbeb-2746-4c17-8acc-d5384e850225', 'Payroll Matrix PBI_New', '2dcf18e5-10d3-4e44-9e19-c901cf7ebba5', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @HRSTGId, '8caf399b-c1ce-43a3-b190-5af3a0723342', 'Recruitment', '3f640e31-bc27-4bfd-9c96-0fee058f489b', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @HRSTGId, '93d495a5-2dea-4dfe-83e5-31dde75951b7', 'Training', '61e2dfc4-1c83-4416-81a4-9d3bd13594f3', 'STG')

---========================================================Bean STG====================================================================================--

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @BCSTGId, '16bd2ee6-836f-4e72-ae51-8dd234af3ceb','CASH AND BANK BALANCE','23af97e2-ac8a-472b-b862-f9959560ab2a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(),@BCSTGId, 'c27bf550-a8fe-498a-9f5e-7a7db0b82b9d', 'CASH AND BANK TRANSACTION', '5c8cc948-43c1-453e-831b-83f7ef1e7e6c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(),@BCSTGId, '1ace4d42-86b6-4f85-8cbd-abc7110f40c4','CUSTOMER BALANCE', '0c49de80-5e56-4a44-a365-da851ffe8f64', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(),@BCSTGId, 'a7662b19-0b47-4de4-827d-444e4b494935', 'CUSTOMER TRANSACTION', '4fd26dcb-0fbe-49b9-a299-c74926611434', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(),@BCSTGId, '08558ad4-21d2-4254-b49a-137369489c5b', 'Entity Balance', '3c6344e0-cd89-4de9-bbdf-44c6f6f157bf', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(),@BCSTGId, '7fe64bb1-b729-4a2a-916e-5a113b896f8c', 'INCOME STATEMENT', 'c5552bce-9035-45e6-bb05-b78eb36db5d0', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(),@BCSTGId, 'd5d91d8a-abf3-4d70-b6c8-b51566f05147', 'VENDOR BALANCE', 'd17a8c34-fdeb-4f4d-8140-db08358fdab7', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(),@BCSTGId, '4af79835-8ace-4050-9cf0-d4819813c946', 'VENDOR TRANSACTION', '44b18d67-0723-417f-a657-0c0e4aae413f', 'STG')

--============================================================== ADMIN =======================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @AdminSTGID, '1c918453-382c-4344-8d3d-3fdfc18cc6c0','Licenses Report', '3aca41df-5669-4616-bd12-e7bec976746b', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @AdminSTGID, '662bb45f-2eee-432d-8e5d-787626c6344f','User Roles Dashboard', '83d6cd05-99a1-44f5-91c6-fade78a40990', 'STG')

--=================================================AUDIT=======================================================
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
VALUES (Newid(), @AuditSTGid,'e2144a43-6854-420c-85c8-7e33a7a6c9dc','Balance Sheet','ff1034d3-df26-4a3a-8220-9975090f97fc','STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
VALUES (Newid(), @AuditSTGid,'457ec83d-6f18-49c9-ae4e-704ce2cacb61','Work Program ','9fe746da-d76a-465c-9133-69861dd4a0b2','STG')

--=================================================NeoBank=====================================================
--Declare @NeoBankSTGID uniqueidentifier=Newid()

/*INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@NeoBankSTGID,'7ecc93cb-19f9-4a07-a3c1-d75ca0201a79','Buy and Sell','610036df-0818-4d67-9249-4d57c79a79bb','stg')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@NeoBankSTGID,'47bd285b-92d5-4009-833c-49fe1b847e84','Buy and Sell and Swap Transaction','610036df-0818-4d67-9249-4d57c79a79bb','stg')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@NeoBankSTGID,'7451d2ae-c525-42a9-b55e-9134c5bc02cb','Buying and Selling','3f40bf81-e55c-400e-a631-59b1d2178216','stg')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@NeoBankSTGID,'7f75ce41-6d4b-46d1-b48a-4133ece90809','Coins','a8c36123-474c-43f8-9bb7-7c56cdfbd0e3','stg')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@NeoBankSTGID,'1cdd0f49-f34e-4b71-85d1-1ccbf3f2e427','CryptoPowerBIModel','610036df-0818-4d67-9249-4d57c79a79bb','stg')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@NeoBankSTGID,'5c22598d-ff3a-4d90-821c-093440a47307','Customer Details','b56741a0-6bb2-41c2-ad65-dfdc506ec724','stg')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@NeoBankSTGID,'ad0d09f9-81a9-4e09-8318-1ee023d54f77','Customers','5bea4df8-a435-4541-98b2-7446e95a6df8','stg')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@NeoBankSTGID,'ddc3b85d-5935-4d9b-b4f8-a65d1ba2ff44','Deposits withdrawals Dashboards','5b1f5c04-fd0c-40b7-8994-78f37c80e5ab','stg')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@NeoBankSTGID,'802238a1-4005-41e7-93bb-3adbb2581ce8','Transactions','edc46124-2e67-42af-a86b-12bc031afee0','stg')*/

END
GO
