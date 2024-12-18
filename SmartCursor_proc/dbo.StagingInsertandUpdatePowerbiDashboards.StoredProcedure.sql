USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[StagingInsertandUpdatePowerbiDashboards]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Procedure [dbo].[StagingInsertandUpdatePowerbiDashboards]  
---EXEC [dbo].[StagingInsertandUpdatePowerbiDashboards]
as
Begin
--===============================[Common].[ReportWorkSpace]===================================================
   Declare @CCPRDId uniqueidentifier=Newid()
   Declare @WFPRDId uniqueidentifier=Newid()
   Declare @HRPRDId uniqueidentifier=Newid()
   Declare @BCPRDId uniqueidentifier=Newid()
   Declare @AuditPRDId uniqueidentifier=Newid()
   Declare @DrFinanceRDId uniqueidentifier=Newid()


   	--=====================Truncate [Common].[ReportWorkSpaceDetail] Table--====================================
	DELETE FROM   [Common].[ReportWorkSpaceDetail] WHERE [Environment]='STG'
    --=====================Truncate [Common].[ReportWorkSpace] Table--====================================
	DELETE FROM   [Common].[ReportWorkSpace] WHERE [Environment]='STG'
  --IF Not EXISTS(  select ID from [Common].[ReportWorkSpace]  WHERE  Environment='PRD' )
  --Begin

   --===========CC-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@CCPRDId, 'ca4eb88f-78ba-4505-a9f0-58525bec869a', 'STG', 'CC-STG')

   --===========WF-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --2
   VALUES (@WFPRDId, '55ac8469-d594-4e67-a5da-284623b80cea', 'STG', 'WF-STG')

   --===========HR-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName])--3
   VALUES (@HRPRDId, '3b0221af-67ef-4f9b-af0e-baa9d04c7897', 'STG', 'HR-STG')
   
   --===========BC-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --4
   VALUES (@BCPRDId, 'ec732893-405b-4951-88f1-dc224c69a8a5', 'STG', 'BC-STG')
   
   --===========Audit-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName])--5
   VALUES (@AuditPRDId, 'cef62b18-fdb1-47a8-b835-5a8ff620b9f8', 'STG', 'Audit-STG')

   --============DrFinance-PRD
   --INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName])--6
   --VALUES (@DrFinanceRDId, '2104a816-f47b-4e62-afa7-f831b8da018b1254', 'STG', 'DrFinance-STG')
  --End
  --===================================================[Common].[ReportWorkSpaceDetail]=========================================================================

   --======================================================= Client Cursor ======================================================================================================
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @CCPRDId, '883e7cee-cf16-4ebf-9db2-ad7898d589f0', 'Accounts Inactive', '33329f80-b920-4ed9-9279-2c8295830a67', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @CCPRDId, '76a0bf28-e957-47d9-ac77-2821a3d91ff5', 'Accounts Lost', 'f33912d6-c277-4a72-b692-1b8c45496fe0', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @CCPRDId, 'abd63cb4-6d43-45f2-bd34-ddc16e993243', 'Accounts Now', '2cef9d04-5132-4497-b80d-6ffef9907b49', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @CCPRDId, 'e811b063-58b7-4836-ab59-e511121713ea', 'Accounts Re-active', 'a2cff323-beac-4386-a19f-403afaabd253', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @CCPRDId, '82789344-c62d-4808-93be-99d0e9a679ed', 'Accounts Won', '75b6f187-cbc8-404e-a710-6be22ef63947', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @CCPRDId, '2a7dd2ca-fa8d-4b66-9a24-5a630e857493', 'Individual leads-Accounts', '6f9360e7-d97f-46c8-84b6-a3ec4fe7e65d', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @CCPRDId, '7be4cc90-6919-4645-8ede-9ef265d45315', 'Leads Created', '311d409f-db9f-4c86-b0bf-23a6445b2af6', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--8
VALUES (Newid(), @CCPRDId, 'f961bd3a-8b71-45f8-93af-c205a5cda12d', 'Leads Lost', '0da77688-60d0-466b-a633-7afec416d8ce', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @CCPRDId, '9b9d1154-84bc-487c-9ab1-87ca0dccec48', 'Leads Now', '96564171-bf84-4421-8ad0-632dd38cc23d', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @CCPRDId, 'a1c7d68d-fa36-44f5-843f-056e6ab877dc', 'Leads Re-new', 'b4e9f888-0847-4173-a80c-b883b30a38ac', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @CCPRDId, 'ae58d1a1-d2f3-414f-8640-695caabcab56', 'Leads Won', 'eaafe8d6-f8ab-4816-8f8b-7499b32c8294', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--12 
VALUES (Newid(), @CCPRDId, 'effdbc24-95b4-4eac-9af9-82dc512c0e14', 'Opportunities Cancelled', '4c1cf370-a2a8-4cb3-9fb7-d6261df50b09', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--13 
VALUES (Newid(), @CCPRDId, '4b55dfda-27e3-4447-9b61-1bbe8e14ade6', 'Opportunities Complete', '7bdcd7d8-055b-4d0d-a5ce-53545765cddd', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @CCPRDId, 'f2bb0401-b532-4f2f-b961-5f10e55c8c27', 'Opportunities Created', 'f2139424-3118-4936-916b-9e6eb86e3b2e', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @CCPRDId, '53c6973d-7b36-4c96-9563-eabfafbad187', 'Opportunities Lost', '270fa8d0-4642-4ae7-863b-0b5c88cde242', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @CCPRDId, 'e1d8fb3c-5ba2-42ab-b637-d0cdb011d851', 'Opportunities Now', 'e5a68706-71b5-4fd7-9d6b-b1350181c5e9', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @CCPRDId, '69dc8d9b-79d7-429f-af8b-fbc86731ab37', 'Opportunities Pending', '76da260f-01ff-40ee-b5c4-bcb3c53b3714', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @CCPRDId, 'b65ecc51-c181-47af-ad29-c08d9066c182', 'Opportunities Recurring', 'd935a863-f967-4532-9a23-c3fffb12d400', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @CCPRDId, 'ec3cffbe-56d2-4861-ae9e-2f9286886964', 'Opportunities Won', '98239e9d-f6f5-40b3-a498-8418a2554f9b', 'STG')

  --======================================================= WorkFlow ======================================================================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFPRDId, 'c7f54f2a-321f-4616-ac33-e759a32d3a6f', 'Actual Contribution', '136dd424-acfe-4722-8d92-1872f6edcdb5', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @WFPRDId, '27df8f03-0cca-45ad-af16-922d4f746d0e', 'Case Members Report', '6b7cf451-791c-47a2-91b8-a68cea8f399a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--3
VALUES (Newid(), @WFPRDId, '60d63538-1573-4fc0-9bb3-e23b16e27f69', 'Cases Approved', '28042632-854f-4b15-876e-023e08ea463e', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--4
VALUES (Newid(), @WFPRDId, 'ebad3226-6a17-405b-8f63-a46a35cf39d8', 'Cases Cancelled', '8d65e391-13de-4dc4-830d-0053870b21d8', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFPRDId, '5c468249-308b-4bd5-9715-4746bc920eb9', 'Cases Completed', '6d07db84-f61a-4e6b-9771-fa4a99cdb01a', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFPRDId, 'ad5b758d-77a9-44a8-9a79-099020f9725b', 'Cases Created', '4fd0afe1-9e18-4705-a37a-d9d44d598843', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFPRDId, '468f3b51-1976-416f-81d6-89cedc8b09ae', 'Cases For Approval', 'fae5e653-4fba-49c1-8e2d-b1e54325e3ec', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFPRDId, '8f034629-5a96-4172-a609-88d6fa045ea1', 'Cases On Hold', '4c3823f7-7688-4d71-9286-5b105f2c5e1c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--9
VALUES (Newid(), @WFPRDId, 'dfe657c1-539b-49e3-9828-718f2448f751', 'Cases Unassigned', 'b62c3f24-5b67-47d9-ab4d-4afecf65b086', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, 'dc127e66-7a86-48fe-bc5e-16df822b094c', 'Actual Chargeability', 'c4a26775-f872-415a-a1fc-72dfdc297c29', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--11
VALUES (Newid(), @WFPRDId, 'e756854f-d913-4820-beae-555b97e3bc89', 'Clients Created', 'eae38341-186e-4ef2-b8b0-ad881766b971', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFPRDId, '14fa89d5-e498-4b20-bba5-5ac2afbc7c1e', 'Clients Inactive', '9d374ec5-9780-48e9-af97-c45f1e587910', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @WFPRDId, '2c3aa137-4608-482b-b769-8247e6547ffd', 'Clients Now', '5a8dbf5e-ff3c-4d2a-9c97-44fd8bb7deb6', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--14
VALUES (Newid(), @WFPRDId, '0c0bfaeb-77e9-4fd0-9008-fc6a32610c9e', 'Clients Re-active', '10f00d00-b07c-4e4c-9b3b-6636218cc086', 'STG')
 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFPRDId, '8c9f1d96-a71a-473b-9fe5-ab57ce87e556', 'Incidental Tracker', 'd6fe809b-f497-42a7-9333-d4184653bc0c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @WFPRDId, '1c22998b-3848-428d-ba56-96fe6a22d364', 'Individual Case', '3478d0fc-2f24-4748-9bd2-ac0a51d12439', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--17
VALUES (Newid(), @WFPRDId, '845d93f3-f0ff-4336-aaaf-6efbbc007c08', 'Individual Client', '80a21aa2-782d-4e2c-9195-9b992291248e', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @WFPRDId, '031c36c7-0ab4-4cf8-a7c6-b72d066a8756', 'Invoices Generated', '227d6f8b-338e-417d-9d61-d04890356aaf', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFPRDId, '59c743a0-f1e5-4728-a799-8e5d8e660e4b', 'Invoices Not Generated', '20e63b3a-46b5-45e4-92c2-31866c493db7', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--20
VALUES (Newid(), @WFPRDId, 'ba56dada-99aa-4554-9772-853c8f5d2384', 'Planned Chargeability', '58aff2da-b027-4545-87f4-36268be5d4d0', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFPRDId, '161ace98-965b-49a9-bf9f-5c28ca7ff710', 'Planned Contribution', '719f7cb3-388a-4586-8f3a-7d7488a3d989', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(), @WFPRDId, '15442c39-8d46-4f58-ab7e-33a5bd5f9d4e', 'Recovery', 'd3f2c308-98af-4197-80a8-0b477cc159ea', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFPRDId, '0ec49a91-403e-40ef-9333-8d06c48d55f0', 'Unpaid Amount', 'd44cd97f-e800-42ea-bcf5-de87b2b6feda', 'STG')

 --======================================================= HR Cursor ======================================================================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRPRDId, '7744a9e0-abd0-41d7-ba01-12696ac343e4', 'Attendance', '42e5aab7-a8cc-4cef-bc62-5bbfc72b5d1c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @HRPRDId, '93e8abdb-ddde-4a81-803d-26711a885c93', 'Claims', '21fb288c-6e40-4094-9fb5-cee86417c366', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRPRDId, 'f4c58b3d-7ad8-4ad1-ba1d-54c5621f3d96', 'Leaves', '28a4ed7f-d015-4b93-b3a6-4a978b132c6c', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @HRPRDId, '34b89334-c13a-4122-b98a-d910424f8449', 'Payroll', 'a785ec5e-3e2d-4a56-87cf-c319a6dae9f2', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5 
VALUES (Newid(), @HRPRDId, '86a40d1c-4c6f-4759-8036-8824fc48911a', 'Recruitment', '48c6b2c5-2a37-44bf-9d08-95250142d0ad', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRPRDId, '657f4120-8c4a-4fd1-baf2-a6a187fe16a8', 'Training', '2b37f1d2-bd22-4775-82c4-31b020445fcc', 'STG')

 --======================================================= Bean Cursor ======================================================================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--1
VALUES (Newid(), @BCPRDId, '5cbc20a8-5f22-4f9f-b671-4092d6786f9e', 'Bank', 'df15c9fa-444b-429d-81c2-a3d18e65b3ee', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--2
VALUES (Newid(), @BCPRDId, 'bf22d92a-4d30-4587-b2cd-8d614eed2d6e', 'Customer', '3fff8008-c209-4f45-b5fa-774a7176be73', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @BCPRDId, 'bec9cfdb-4539-4d3c-a9f2-43fcb74b531a', 'Customer Aging', 'f1cd2b2d-17f1-48b4-9600-95234db18f24', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--4
VALUES (Newid(), @BCPRDId, '7c9efd4e-e915-4273-99ef-e5005180d45a', 'Financials', '6edfe26c-7fac-465c-92e6-e2b35d88ea9b', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--5
VALUES (Newid(), @BCPRDId, '11d32714-f9d2-4f33-9285-dea05f0b7075', 'Vendor BillPayments', '101ca526-9634-4642-aaab-30c122733277', 'STG')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])--6
VALUES (Newid(), @BCPRDId, '488ebdde-3e38-4f17-a035-90c3ba72dd81', 'Vendor', 'bec8dd07-d47a-4fcf-968d-660f0d5b5ec9', 'STG')


 --======================================================= Audit Cursor ======================================================================================================

 --======================================================= DrFinance-PRD Cursor ======================================================================================================

END
GO
