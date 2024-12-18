USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PRDNew_AllCursors_InsertandUpdatePowerbiDashboards_SCM_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[PRDNew_AllCursors_InsertandUpdatePowerbiDashboards_SCM_SP]
AS
BEGIN

--Exec [dbo].[PRDNew_AllCursors_InsertandUpdatePowerbiDashboards_SCM_SP]

 Declare @CCSTGId uniqueidentifier=Newid()
 Declare @WFSTGId uniqueidentifier=Newid()
 Declare @HRSTGId uniqueidentifier=Newid()
 Declare @BCSTGId uniqueidentifier=Newid()
 Declare @DrFinSTGId uniqueidentifier=Newid()
 Declare @AuditPRDId uniqueidentifier=Newid()
 Declare @Production_SupportsystemPRDId uniqueidentifier=Newid()
 Declare @AdminSTGID uniqueidentifier=Newid()


-----=============================================== workspace ids ==============================================================================--

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
VALUES (@CCSTGId, '744a5ec5-54eb-4189-871d-8b47e9058e96', 'PRD', 'SCMPRD07_CC')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
VALUES (@WFSTGId, 'ab730f47-8609-4dcb-b5c1-8a794d94f132', 'PRD', 'SCMPRD07_WF')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
VALUES (@HRSTGId, '41d5c37d-c5b2-47ab-b89b-e68a87934971', 'PRD', 'SCMPRD07_HR')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --7
VALUES (@BCSTGId, '13f73226-9176-4b81-a803-1b1bc3625eb4', 'PRD','SCMPRD07_BC')
   
INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
VALUES (@DrFinSTGId, 'eeb14b80-9deb-4d9f-b27f-5b8520e34ca8', 'PRD', 'SCMPRD07_DrFin')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --7
VALUES (@AuditPRDId, 'dc400766-6dd6-4da2-af23-6eaae045ea4b', 'PRD','SCMPRD07_Audit')

 INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
VALUES (@Production_SupportsystemPRDId, '5aecc8c8-1a7a-48f6-a633-66c8705195c2', 'PRD', 'SCMPRD07_SupportSystem')

INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
VALUES (@AdminSTGID, 'a0ffc7d5-11c1-49dd-a09b-6f9b05f0203a', 'PRD', 'SCMPRDO7_Admin')


---================================================ Client Cursor PRD =======================================================================


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCSTGId, '9dfa93eb-68d4-41c4-82d4-8f2c65e5a7c3', 'Accounts Detail Report', '0d1224bd-6cfb-439d-a1fe-658052235ae1', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCSTGId, '9c5e0c4a-fe91-4a07-922c-078a6a525bd6', 'Accounts Inactive', '4ac3fce3-07f7-46f6-bd79-1b7102cdeef5', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCSTGId, '08ac2270-bd35-44a9-904c-1ea72393551b', 'Accounts Lost', '0f01e97c-1045-46db-af09-b261a11eda7a', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCSTGId, 'c6f3343e-6d46-4660-a31c-2e2b2cb040af', 'Accounts Now', '9483980e-5801-4f86-befa-f3c848192c22', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCSTGId, 'b1fff343-5f46-46d1-91e3-7204e9251b53', 'Accounts Re-active', 'c52224d6-3edd-4f50-8b49-6d0af927f553', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, '99570e1a-a77e-4d07-ad0c-abab5ed46c39', 'Accounts Won', 'b6667a2f-4051-4de9-8162-61000b3b02ab', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, '2ed8c5e4-6c81-4093-aa74-4198acb501a1', 'Camapign', 'ec8d9fd9-96a0-4bb0-8673-f653403a7586', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, '96c0440a-34bb-41b1-a60a-4bf26554963a', 'Campaigns', 'c883c571-b753-4dde-bfba-2e34ee997b36', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, '66b6192a-4149-4ce7-a089-96106fcf3cf5', 'Contact Details Report', '181662d3-f90c-4f4c-aebd-b69537640745', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCSTGId, 'c63e9e2b-cde1-450d-836c-6bc2cf8113df', 'Delete Opportunities', '0cb48db7-9948-4dc3-b111-0d4ab23e59b0', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCSTGId, 'a295de05-499b-4b77-b6f2-029dbf5a9fd4', 'Individual leads-Accounts', '25029ed2-b545-4a0b-8f47-491307f0a65b', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCSTGId, '629e9061-c6d4-4c5b-a80b-3c5b28a107b5', 'Lead and Account Details Report', '0510fa04-912c-4d77-91e8-dda17ae77002', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCSTGId, 'be954ce8-d6a9-4115-a396-25a5cb704de5', 'Leads Created', 'e25303b8-50c2-482e-b300-af164297a8d0', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCSTGId, '078dd9f3-d1ed-4564-9f22-5e43333fed16', 'Leads Detail Report', '75ea1d91-7215-4c5b-a4ca-30e74a7e58c7', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCSTGId, 'f2c18f48-0f57-4ba7-a46d-300339448cee', 'Leads Lost', '8be9ae67-967b-4bf9-9585-ad5fbf6d7a88', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCSTGId, '230fafa3-6faf-4072-97fa-cc16ea16fcff', 'Leads Now', 'ef8376ef-0ed6-4452-b747-63f52b605f57', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCSTGId, '5aceb183-9e69-4826-9742-5fb5a57aeaf4', 'Leads Re-new', '44cd9634-44dc-491e-9187-6884b023916c', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCSTGId, '54d82820-3248-45e4-8b7f-3d5f9eb57946', 'Leads Won', 'cfef25ad-6112-4577-b642-88c0d8fcb2e5', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCSTGId, '39abc00f-c21e-402e-b26d-5f52d2457e2e', 'Opportunities Cancelled', '12061f6a-ffca-42a2-a3cb-2f74540f1c70', 'PRD') -----1

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCSTGId, '1115cc9b-522e-4a55-a02f-d1f3874148ad', 'Opportunities Complete', 'b9024be5-9d2d-461e-b3f2-07d39b618296', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCSTGId, '21c27de1-1ab8-4e83-a1b2-ec702088f58d', 'Opportunities Created', '5a87efda-413c-43dc-8982-dfc904ee22dd', 'PRD')---?


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCSTGId, '086915cc-9d5d-4504-9662-5a9a32c0c83c', 'Opportunities Detail Report', '3b0b3d0b-d9fb-4833-b502-b16a7eb3264e', 'PRD')---?


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCSTGId, '7666119f-5fdb-4d9d-9065-9b038df0e2ab', 'Opportunities Lost', 'cbaaa01e-e287-4a66-8a83-49aaa393e5a5', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCSTGId, '8a19cd75-e5b2-4b69-a6d0-712a623390f4', 'Opportunities Now', '49b10bb3-f134-403a-a85a-270c1a285220', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCSTGId, '4ceff860-c4fe-4380-81f8-fd211290f630', 'Opportunities Pending', '428b6bc1-00fb-4b2f-83cf-a78858287c28', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCSTGId, 'b590a9bf-fa6a-412d-9148-328d7359529e', 'Opportunities Recurring', '749a4cf3-6667-4192-a906-67388e8cdaaf', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCSTGId, 'a2925a58-f4a3-45da-9e66-f90389a293c5', 'Opportunities Won', '59668e2d-1180-4952-920d-558ca4d91da3', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @CCSTGId, '3de7fe41-9a42-4751-8256-5783b8c4bd77', 'Reminder Details Report', '82eacdf0-ca88-4a2b-bdf7-62e601e17fab', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @CCSTGId, 'd0cb985f-996c-4504-b3cf-ae50d3772c05', 'Vendors', '68afe44f-e6ae-41a7-9d8b-a320edd92fa9', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
--VALUES (Newid(), @CCSTGId, '33625406-5110-43c5-91fe-82dc43174ab2', 'Cold Accounts', '864345b0ef-c3d0-4599-bfaa-a7bf7170a1', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
--VALUES (Newid(), @CCSTGId, 'dd8d0e28-f7d3-4d22-a371-c30cc8c23b8b', 'Cold Leads', 'b220c6e6-e3fc-47ca-9e29-f464c3176ab9', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
--VALUES (Newid(), @CCSTGId, '256c39d3-01b3-408e-9f49-c7aff385578a', 'Quotations', '2c05b05d-df8c-4cca-af0e-1444f62c37be', 'PRD')




 -- ------=========================================Work Flow PRD---==================================================================================--
 

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1  
VALUES (Newid(), @WFSTGId, '159894ff-1fee-40f8-aa74-a587f3e3bde6', 'Actual Contribution', '295a6f62-1515-4b83-b2bc-477c61a087c1', 'PRD')  
     
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1  
--VALUES (Newid(), @WFSTGId, '5e465581-4031-4bc4-93f1-ec1cc2598a53', 'Actual Contribution DeptPOC','5abf7758-b143-466c-a6ab-443cc66589db', 'STG')  
  
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1  
--VALUES (Newid(), @WFSTGId, '36036047-9621-4c4d-97e5-a89836492831', 'Actual Contribution POC','e65f4ec3-1bea-4043-b00c-681ef4f8a5e6', 'STG')  

 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3  
 VALUES (Newid(), @WFSTGId, 'e2ac0b63-7fb9-49ea-8743-948e09edef3c', 'Case Members Report ','909d4cf6-8d2a-4e2b-ab83-a6502543d079', 'PRD')  
  
 --INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3  
 --VALUES (Newid(), @WFSTGId, '7dce18c7-dbf5-48ab-ad39-ac0fea0f0b51', 'Case Details Report','d8669cf4-4f46-45fb-a77a-f91a3feb149f', 'PRD')  
  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3  
VALUES (Newid(), @WFSTGId, '5dec06a9-a449-48b9-824b-b7f4e7cfb849', 'Cases Approved', '51b3b5d2-0599-49b3-8f02-8f0395966c51', 'PRD')  
    
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4  
VALUES (Newid(), @WFSTGId, 'aed8dc02-ae63-4593-90b9-b40848441305', 'Cases Cancelled', '1e7eb738-9ae1-4d45-b47e-a71cbeb0a5c6', 'PRD') 
  

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5  
VALUES (Newid(), @WFSTGId, 'c3693ce1-a14d-489e-ba9d-5995612ed769', 'Cases Completed', '9e8e7b4d-9653-4878-afbc-248b5df11f97', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6  
VALUES (Newid(), @WFSTGId, 'd6251a22-40ed-4025-a383-66b11b930db0', 'Cases Created', '74e2ddd7-bf47-4405-b587-db79ea51a20d', 'PRD')  

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7  
VALUES (Newid(), @WFSTGId, '4253f163-450a-4873-b0f5-ffba8e84defe', 'Cases Detail Report', '6518f6d2-cd3d-4c63-ba79-c153711e6474', 'PRD')  

  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7  
VALUES (Newid(), @WFSTGId, 'fe3bd639-92da-4feb-bba4-744b89c57365', 'Cases For Approval', 'ba9f4cdd-54fc-4600-a969-ef2434c4982f', 'PRD')  
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8  
VALUES (Newid(), @WFSTGId, 'bf83d467-7431-42e8-a76f-257d51874f3d', 'Cases On Hold', 'e8acd0bf-7eac-4c96-b870-4c7fb797162d', 'PRD') 
   
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9  
VALUES (Newid(), @WFSTGId, 'f2c7a899-ee24-47a3-994d-4b18b5b177e4', 'Cases Unassigned', '031f2ffc-392a-4a29-974a-b8f1b2e51eaf', 'PRD')  
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10  
VALUES (Newid(), @WFSTGId, 'ba7a14cd-ff2e-419f-bfe9-77515b8005c8', 'Actual Chargeability', '0b6f224c-5d8d-4c12-aef2-8d69417e67c4', 'PRD')  

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10  
--VALUES (Newid(), @WFSTGId, 'd1e54b74-fb35-4c3d-ba2e-f5406ca0365d', 'Chargeability TimeLogDetails', 'ee126c15-75ed-4307-a95c-2751bdb2e883', 'PRD')

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10  
--VALUES (Newid(), @WFSTGId, '04ec92d4-a866-4fbb-859b-254373c6825f', 'Chargeability TimeLogSummary', 'dea2b793-96ff-4eb7-829c-c1cda01f44f0', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10  
VALUES (Newid(), @WFSTGId, '21884e10-cea3-45b5-9bf6-92c6404ff255', 'Claims Tracker', '0cc6031f-51aa-486d-ad44-40c1ae953df6', 'PRD')  
   
 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3  
VALUES (Newid(),@WFSTGId, 'aa368edf-48e5-47b6-ae51-2c416ada95f3','Client Contact Report','59115e61-431a-4f21-b8cf-ebfb723c4d9d', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3  
VALUES (Newid(), @WFSTGId, 'ca449659-da5b-4058-b069-fdea288051338', 'Client Details Report','0fa0b1a1-2959-4836-8a80-3effb7f29953', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12  
VALUES (Newid(), @WFSTGId, 'ed233150-155f-4e69-9eda-cc076b5874d1', 'Clients Created', '5f9d29e3-9b72-483a-8b34-60e53984b7c2', 'PRD')  

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3  
VALUES (Newid(), @WFSTGId, '182dcbaa-8c0b-482c-ab0c-1bda37916f42', 'Clients Detail Report','48dc36dc-85cb-4064-9b41-201b6116ec73', 'PRD')  

   
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13  
VALUES (Newid(), @WFSTGId, '1440c5ac-7f13-4d1f-bc68-60d81fb5503e', 'Clients Inactive', '2c5fba76-a302-4350-baa2-e48a4a1c0c30', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14  
VALUES (Newid(), @WFSTGId, '77392cb0-172b-41ec-9fed-22f9cab1aca3', 'Clients Now', '2e008637-16df-4270-b7e3-5f3ebcd82acb', 'PRD')  -----------1
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15  
VALUES (Newid(), @WFSTGId, '39df1b35-38e9-46b2-b427-fd2879ccf41b', 'Clients Re-active','0c9fe1a6-de09-4c57-a236-85f42b21d931', 'PRD')  
   
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15  
--VALUES (Newid(), @WFSTGId, '01e772a0-6899-4c27-a1ce-6ebd925eab0a', 'Incidental and Claim Tracker', '64846726-aa87-4d5b-a939-8f48ef34a395', 'STG')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16  
VALUES (Newid(), @WFSTGId, '34da3d6c-0f95-4c21-a7d1-38d2ee10dd69', 'Incidental Tracker', 'c2a5df87-c8d2-46af-a966-c52864c6eb68', 'PRD')  

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17  
VALUES (Newid(), @WFSTGId, 'fdca7d0e-80fb-4181-a05c-01ee93343215', 'Individual Case', '0559abeb-2400-46ba-b99d-ede5ecd2ccb8', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18  
VALUES (Newid(), @WFSTGId, 'a5d430fa-7cf4-46cc-9121-d25cbc4ebb07', 'Individual Client', '85695928-2b32-4a69-b2cc-4010c61762b4', 'PRD')  ----------2
  
--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18  
--VALUES (Newid(), @WFSTGId, 'fa20354b-5e1c-4708-9a39-43a1ccfa7d79', 'Individual leads-Accounts', '60b2df9e-f2bf-47dd-91c8-b04f3246e6b4', 'STG')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19  
VALUES (Newid(), @WFSTGId, 'f9b257a3-16d7-4b53-a388-2ddbb2fcda09', 'Invoices Generated','b38a0afd-2f8f-4c19-8f10-9c61db865c00', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19  
VALUES (Newid(), @WFSTGId, 'ada46670-b0e9-47d9-843b-6c6bf662057a', 'Invoices Not Generated', 'cae627c4-eee6-4a8f-8895-92ddb28e63f0', 'PRD')  
  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21  
VALUES (Newid(), @WFSTGId, '3018adab-e105-4272-9918-4db85f48c237', 'Planned Chargeability', '908d0ee8-afbd-41c1-8a74-7b93971c7f16', 'PRD')  

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21  
--VALUES (Newid(), @WFSTGId, 'cd87d37e-f759-4fd5-b78c-6143e4de25f8', 'Planned Chargeability Timelog Details', '2a243f90-353a-4425-bc8d-295c3928b494', 'PRD') 

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21  
--VALUES (Newid(), @WFSTGId, '0e607ce3-4781-4c76-8f13-1b2589f7f7e1', 'Planned Chargeability Timelog Summary', 'af3303b1-cd0d-4546-8fd7-e00ccbf789fe', 'PRD') 

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22  
VALUES (Newid(), @WFSTGId, 'db572d86-c5c7-4859-a4da-4e9a4f371926', 'Planned Contribution', '3529ee04-ade6-4b02-bd3b-c0356fd52d73', 'PRD')  
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23  
VALUES (Newid(), @WFSTGId, '0c1a9654-5336-41e6-aafd-8e223bf062c2', 'Recovery', 'b0ab61ba-a796-421c-a9e2-38e221548276', 'PRD')  
   
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24  
VALUES (Newid(), @WFSTGId, '138701f1-4335-48c1-a451-dd5a3a93f8d6', 'Reminders Details Report', '9c52f4f3-220e-4682-847b-3b0478dcb4a8', 'PRD')  
  
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24  
VALUES (Newid(), @WFSTGId, '8d090765-ab7d-436a-a30b-66e6fafc5be6', 'Timelog Detail Report', '653bdb89-19c2-41b0-ad86-e0485421e03d', 'PRD')  


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24  
VALUES (Newid(), @WFSTGId, '8f0dd4ef-c22e-49a6-ab4d-1232085635ba', 'Unpaid Amount', '5dd033e7-cf8d-4868-8c13-56e67f14a9a8', 'PRD')  
  


   

 ---- ========================================================HR PRD---=========================================================================--

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRSTGId, 'd1ea2755-1873-4913-b232-3b3cc78551b3', 'Attendance', '29f62ad8-2970-4d86-a18a-3b4e87455132', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRSTGId, 'a32fca0c-4f8e-48ee-a140-fd8286e718fe', 'Attendance Details Report', 'b520f74c-1c91-46d0-aafb-b1d56c7978ef', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @HRSTGId, '89afe679-e794-4e1e-81bb-b252c415d35c', 'Claims', '161b7005-750f-45f7-8c28-42073a8c5fc4', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRSTGId, 'a04aa05a-16e6-41d4-bae5-a2ab31372bb0', 'Employee', '868494f8-a82f-4318-97f5-4ecee35a61cf', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRSTGId, '2baa161c-cc14-4e5f-9861-e6477898dd68', 'Employee Dashboard', '445a180a-07a4-4268-bfc8-9c6e91cf0c4f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRSTGId, '4fe8b9c4-b4ad-4447-b53d-af1bd6afb36a', 'Leaves', 'b9c5ab16-3c81-4c6f-adef-d693f8a389f4', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRSTGId, '783ed27b-f025-47dc-b13e-a92d81705af9','Payroll', '678d1cbc-a2ce-4477-8650-def58ff828da', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRSTGId, '11f65c97-8973-4166-ba17-880fdf29f6e1', 'Payroll Dashboard', 'e23f32c4-64e1-4e61-9946-6ae2d629f632', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRSTGId, '5ca28fb3-563e-4d43-a1c2-c04e54e18869', 'Payroll Matrix PBI_New', '52db8371-8175-47df-b8cb-223554d31c05', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRSTGId, '049e13b6-d2e4-49cd-b61f-5db66366d321', 'Recruitment', 'b27ff0cf-83e2-4f6a-930e-1ca283082246', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRSTGId, '8a9eea36-325e-4869-a9e6-6f36f93a0176', 'Training', 'd3ea12bb-c7e6-43cc-a0cf-3f5cdc6de52b', 'PRD')


-----=======================================================================BC PRD---======================================================================================--

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @BCSTGId, '855b6ead-79e0-4f99-a804-6b9e833bd398','CASH AND BANK BALANCE', 'dc6a4c7f-ee57-4fb6-92c8-c18165032dfb', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @BCSTGId, '2dea5d74-3db2-47be-95d7-3a2e1f8c0032','CASH AND BANK TRANSACTION', 'e5888371-f207-4436-ab79-3262700d0942', 'PRD')-----


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @BCSTGId, '2f775597-5e0b-47e3-ad26-09331eab53bf','CUSTOMER BALANCE', 'f391ebc2-2ea0-4c39-82a8-d3ba797097e5', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @BCSTGId, '4ba462a7-df6a-4b82-ab54-a5d417de6c80','CUSTOMER TRANSACTION', '1d8e5250-ac5f-484f-8a11-d99ef2c4775d', 'PRD')-----

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @BCSTGId, '1f668297-8b77-4ac0-ab16-998e8b43a6df','Entity Balance', '939be939-668c-4259-aedd-c4d831e55fa5', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @BCSTGId, '43d1735d-2b2c-4ffc-8f4b-a022353865bc','INCOME STATEMENT', '3b69e2aa-552c-47dc-910c-831bc055d1f3', 'PRD') 


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @BCSTGId, 'cf6a367a-5ec2-4809-a58b-af17bc6b2122','VENDOR BALANCE', '9027ab17-a08f-41e1-932a-d7c4f891dbae', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @BCSTGId, 'c806055b-38c7-4afb-acfd-4387c508d3ce','VENDOR TRANSACTION', 'fc5e47ff-cd16-435a-8d74-9458a2fa68ff', 'PRD')


-----===========DrFin PRD---===============

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @DrFinSTGId, 'dd5cbba3-82be-42b3-b857-b869b943da2c','Asset Analysis', '4d35d74b-f6e4-4f3f-9fa6-f8caa2e3964e', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @DrFinSTGId, '5e6d5a0d-5e24-46e8-bcd8-f34302e400f6','Debt Analysis', '89f0313c-b9d4-479d-8ca3-a8972e5e2185', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @DrFinSTGId, 'b09419d2-6c4e-42ad-92a5-24fb1b7b9ec6','Expense Analysis', '99bdcbbf-3706-41dc-bf2a-b7c27c805000', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @DrFinSTGId, 'd30d39e2-f2a5-47c7-9f63-6878a8c2cef1','Financial Ratios', '7ef5ddb9-7078-4b22-a5a3-8a1cd9e0f51a', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @DrFinSTGId, 'af8e9a76-273d-427b-a195-2e7f80206f1b','Growth Analysis', '63658830-5e2a-4102-90c2-6218ffdc4605', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @DrFinSTGId, 'ecc4548a-72fe-4fce-86ce-2e1e82571107','Liquidity Analysis', 'd64a8cea-aabc-4e0f-96cc-e45af23de7a1', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @DrFinSTGId, '0cf6f436-26f7-42a4-a37f-05e14dcbc32b','Operating Cashflow Analysis', 'e17768dd-44c6-47f8-b998-060d4c53bee9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @DrFinSTGId, 'df361a8a-adf7-4fe9-90ef-79eb1087284b','Profitability Analysis', 'd8f5696d-95f5-4ee5-90fb-d41ccba5ceee', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @DrFinSTGId, '5d34ca23-2301-4490-b3e3-08be9a29a9f8','Revenue Analysis', '740b7768-301b-450d-86a7-ec56b3580ea2', 'PRD')

-----===========Audit PRD

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @AuditPRDId, 'bc449118-d53c-4c93-8a61-d48752eb09ca','Balance Sheet', '82184dc8-1d21-483d-b086-c44ad1f83e39', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @AuditPRDId, '599a92c0-a1f1-4436-b008-7719dff523e0','WorkProgram', '78f3a287-46ae-4bfe-a2c8-42cf3196c3c8', 'PRD')

------=========Support System PRD

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @Production_SupportsystemPRDId, '1473f351-e2c9-47fe-93c2-866be09e6374', 'Support System Dashbaord', '160d42cd-c918-4b44-ae3e-99f9b6bb5b9c', 'PRD')


----======================= ADMIN  PRD

--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
--VALUES (Newid(), @AdminSTGID, '43f4bb96-3693-4ad7-85ac-6bf5f81a4205','Licenses Report', '2a01df34-2ac4-449e-b95d-443e057bab07', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @AdminSTGID, '11f4bd7e-a8a0-498f-bfe5-a53dd1ac13e3','Users and Roles', '3ddd77f9-7ad2-4400-9747-74e256ae9a73', 'PRD')




END

GO
