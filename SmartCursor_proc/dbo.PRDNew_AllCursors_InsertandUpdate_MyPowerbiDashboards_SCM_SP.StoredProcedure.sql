USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PRDNew_AllCursors_InsertandUpdate_MyPowerbiDashboards_SCM_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[PRDNew_AllCursors_InsertandUpdate_MyPowerbiDashboards_SCM_SP]
As
Begin


--exec [dbo].[PRDNew_AllCursors_InsertandUpdate_MyPowerbiDashboards_SCM_SP]

Declare @WFSTGId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='PRD' and WorkSpaceName='SCMPRD07_WF')
Declare @CCSTGId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='PRD' and WorkSpaceName='SCMPRD07_CC')
Declare @HRSTGId uniqueidentifier= (select id from [Common].[ReportWorkSpace] where Environment='PRD' and WorkSpaceName='SCMPRD07_HR')


   ------------ ======================================================= MY Client Cursor PRD ======================================================================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, '76d65a30-3405-475f-9eac-529c6d07c6fb', 'My Accounts Inactive', 'caddb08a-f606-4e7c-bf73-3ab116dfa45a', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, 'd07dd86f-a968-40cf-a379-3a9b0227b744', 'My Accounts Lost', 'd7275319-c89a-4412-868a-5a9cad2b0ecb', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCSTGId, '1e7af901-fd5d-4349-a2d6-9d9ab78d9d29', 'My Accounts Now', 'e8ea1afc-7ca3-4537-806e-58e58e348380', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCSTGId, 'b1fff343-5f46-46d1-91e3-7204e9251b53', 'My Accounts Re-active', '821d0781-bc4e-4028-83ce-002b7aa3b357', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCSTGId, 'bdb1faca-40ed-4168-aaf4-d7eeb1c10a66', 'My Accounts Won', '53ffd9a5-650e-42da-894c-c49d0124effb', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCSTGId, 'c43b19a0-f7e4-4e51-87fd-7782a2a6b2e2', 'My Individual leads-Accounts', '10bc3936-3275-43b5-b9be-166cb4f3307d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCSTGId, 'e919e7c7-9146-450a-bf11-eb4a903336dc', 'My Leads Created', '84908ef3-1ef6-4582-839e-be3b4425d6e9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCSTGId, '21ae3316-7611-42d8-9957-298458dea861', 'My Leads Lost', '950a5d94-d732-4f85-b5eb-591b88c2a13a', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCSTGId, '06364e1d-62e1-4c4c-b752-aebc544a149e', 'My Leads Now', 'a2b45a9e-ffa4-4de4-a582-d61318835b62', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCSTGId, '93588c57-9b53-4dce-ac73-18d48b4c4494', 'My Leads Re-new', '3966071d-a1c5-4378-9417-ac86ee6ce5b1', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCSTGId, '97ba0f53-caf8-4230-9d29-2734ccd6fe92', 'My Leads Won', '18b219c0-58e9-4f77-81e6-b77e7a560990', 'PRD')

 -----------MY opportunity--------

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCSTGId, 'e0c85ef1-cd6c-4d94-a391-800df22451a9', 'My Opportunities Cancelled', '574dac74-92a5-467d-940b-0035030aae16', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCSTGId, '92bce67e-d2e6-48e6-b999-e5437566168e', 'My Opportunities Complete', '8508f038-4a3c-4b65-a3d9-49f66d62f05b', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCSTGId, '73f01adf-4617-4ae6-b35a-418dcf04065d', 'My Opportunities Created', '52afe51b-40a9-454f-bcb9-cc8a60ef38f1', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCSTGId, '255d6a71-a2ae-4178-8b0c-6b5ab4c8e90b', 'My Opportunities Lost', '8dcd9ad5-fbdd-4105-9382-ff7a14ad3746', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCSTGId, '792768be-1deb-4045-8db0-42e65c48420a', 'My Opportunities Now', 'cae2b21f-37ec-4eeb-8f08-6ff720f13f64', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCSTGId, 'e4b5be73-d57f-4c93-960d-3ade1722431e', 'My Opportunities Pending', 'bf255ee3-0d00-4ea8-a20a-fa85ba42d019', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCSTGId, '58324946-0a63-499a-8c1a-1cef34ed9c2e', 'My Opportunities Recurring', 'a379cb39-35e8-43f9-8a87-30c3b36a9f01', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCSTGId, 'bb8544ed-6476-4b8b-a80b-eba96328192e', 'My Opportunities Won', '39ceda31-9f30-40f4-84aa-3afcefa1cc16', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
--VALUES (Newid(), @CCSTGId, '2451d72c-0006-4e75-87e5-25fc3f02681b', 'My Quotations', 'd5e28d37-d993-4167-ad29-058b1f39dddb', 'PRD')

  -- ------------ ======================================================= MY Workflow Cursor PRD ======================================================================================================


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3  
VALUES (Newid(), @WFSTGId, '6eabea8c-dbb0-4c08-ae0a-cb5b40ff4d0b', 'My Cases Approved', 'e70c77eb-e3d9-4045-90e2-a5d2ef751a00', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4  
VALUES (Newid(), @WFSTGId, '1609fed8-08a9-4642-8c18-2013ec2f923b', 'My Cases Cancelled', '984c9cf0-6078-4e53-879f-c9636b2ef0ed', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5  
VALUES (Newid(), @WFSTGId, '8144f44e-730f-4e8b-b3ea-cf2b4cc26013', 'My Cases Completed', '31ab81b7-2bdd-450f-839c-8dcbad02458a', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6  
VALUES (Newid(), @WFSTGId, '9ac29e3a-7249-4ed6-b317-c5d3f1684a67', 'My Cases Created', '9debb44e-9df3-4766-8c85-99cd7a126958', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7 
VALUES (Newid(), @WFSTGId, '5c22352f-5e00-492a-864a-acc31244cbac', 'My Cases For Approval', '2165ce71-3e36-4984-b163-70eaf95a08e0', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8  
VALUES (Newid(), @WFSTGId, 'cf9a40ef-1d1a-48dd-bcf8-2d1b1cc08d54', 'My Cases On Hold', '210b369e-4d48-417e-8b2b-a3a1edfd4eea', 'PRD')  
    
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9  
VALUES (Newid(), @WFSTGId, 'fe51716c-2320-47ee-8b57-20123fb94d0d', 'My Cases Unassigned', '63939dac-c1f7-4e7b-9fba-45204f9a7fcd', 'PRD')  
    
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24  
VALUES (Newid(), @WFSTGId, 'c20d5285-6a5b-4fb4-8300-ef9ac55ba98d', 'My Individual Case', '1a88eaf5-9de0-40bc-b518-3fa690dfe766', 'PRD')  
    
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10  
VALUES (Newid(), @WFSTGId , '37eee3a2-bfab-480f-84b8-c9f3c9cc2e3d', 'My Claims Tracker', 'c94403c9-7406-4940-995a-9e45ded0c971', 'PRD')  
    
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15  
VALUES (Newid(), @WFSTGId , '4e750a1b-8a6b-4d83-aca7-933bc6043136', 'My Incidental Tracker', '2f1ece77-69ba-4291-9d79-d4c753cae70b', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24  
VALUES (Newid(),@WFSTGId , 'c94ebaf9-aac4-4c84-882e-11e0f09cf72c', 'My Unpaid Amount', '920b0278-a39e-4286-8609-db2bb710729a', 'PRD')  
    
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19  
VALUES (Newid(), @WFSTGId, 'a8e644c2-ba41-4a36-ac31-200486ffb9c2', 'My Invoices Generated', 'baababaf-adc1-4650-89f6-40520ffa37d8', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19  
VALUES (Newid(), @WFSTGId, 'd1c91c99-6cd1-4119-b54f-efc50a3c4124', 'My Invoices Not Generated', 'eab397c0-2ddc-4791-84ab-8cea9cdba603', 'PRD')  
    
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10  
VALUES (Newid(), @WFSTGId, 'c0b7bb37-b6e2-4a18-a717-666638afe733', 'My Actual Chargeability', '11c7015f-eb11-4b7e-b0cc-22c40cf3842e', 'PRD')  
   
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1  
VALUES (Newid(), @WFSTGId, '551abd8b-56b7-4bd2-8199-d22427ec6c8b', 'My Actual Contribution', '56c49434-c313-44ae-ac56-d1a3657f5fbe', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21  
VALUES (Newid(), @WFSTGId, '7d2b1190-0ea7-42f1-a4ec-b808a792d5a9', 'My Planned Chargeability', '4a4797b4-eec9-4005-9417-cb0f345aab19', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22  
VALUES (Newid(),@WFSTGId, '8f957059-01b8-4376-bc68-7931d38a37af', 'My Planned Contribution', '45a7b608-ea39-4751-9401-b8f60948d590', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23  
VALUES (Newid(),@WFSTGId, '48c710e0-ef9b-4d3e-9895-d6a1c2ade430', 'My Recovery', 'c1f92c06-28b8-4834-aad4-a61f7be17f38', 'PRD')  


----===============MY HR PRD =====----------------

----select * from [Common].[ReportWorkSpace]

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRSTGId, '140adb8b-f70a-45b6-93e7-a6c8a678370e', 'My Attendance', 'b9aad3bc-657f-4948-8d9b-16aee52ca097', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRSTGId, '7065c7bf-aa2f-4458-9266-e4ddf12499a6', 'My Claims', '242ab6a5-a8a1-4496-a7cd-36bf03c2ba54', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRSTGId, '016e2117-19bb-4cfe-8622-7fba9d01afd1', 'My Leaves', '7142152b-fb7f-4e00-a9a6-6595f9da1c4f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRSTGId, 'd982fa72-9e7d-4cd1-b054-77702f5f0e54', 'My Trainings', '46f0892b-0b09-49c2-be38-b9ccb0778d7f', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
--VALUES (Newid(), @HRSTGId, '7555a1a9-1815-4083-b8ff-5fc894b5af60', 'My Profile', '021d7698-8b00-496e-ad5d-1b95cfd8b289', 'PRD')

END
GO
