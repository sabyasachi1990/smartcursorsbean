USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[PRDInsertandUpdatePowerbiDashboards_New_SP_Old]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE Procedure [dbo].[PRDInsertandUpdatePowerbiDashboards_New_SP_Old]  
---EXEC [dbo].[PRDInsertandUpdatePowerbiDashboards_New_SP]  
AS
BEGIN
 
   Declare @WFPRDId uniqueidentifier=Newid()
   Declare @HRPRDId uniqueidentifier=Newid()
   Declare @DrFinanceRDId uniqueidentifier=Newid()
   Declare @CCPRDId uniqueidentifier=Newid()
   Declare @BCPRDId uniqueidentifier=Newid()
    Declare @AuditPRDId uniqueidentifier=Newid()

	 


   --===========WF-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
   VALUES (@WFPRDId, '061fb7cf-b382-422e-8619-7cd50b18fcbe', 'PRD', 'WF-PRD')

 ---=============HR-PRD
    INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --2
   VALUES (@HRPRDId, '5e2d76e9-c9f7-48ac-8375-1302d55998b3', 'PRD', 'HR-PRD')

 --============DrFinance-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName])--6
   VALUES (@DrFinanceRDId, '9b33c710-db7b-4c6e-916b-89730a6cc53a', 'PRD', 'DrFinance-PRD')

-----=====================CC-PRD
  INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
  VALUES (@CCPRDId, '8075a1d3-b639-44d4-adad-8cef7ad7ad00', 'PRD', 'CC-PRD')


  
-----=====================BC-PRD
  INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
  VALUES (@BCPRDId, '721d34fe-e74e-46c7-9ac3-fc7ac8423006', 'PRD', 'BC-PRD')

  -----=====================Audit-PRD
   INSERT [Common].[ReportWorkSpace] ([Id], [WorkSpaceId], [Environment], [WorkSpaceName]) --1
  VALUES (@AuditPRDId, 'dfd5cda2-26ac-417a-b44c-c4bc35cee7c1', 'PRD', 'Audit-PRD')

 
 --===========Work Flow PRD---===============
 ----====================================================================

 
INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @WFPRDId, '02b49035-af8a-4e40-9090-2d316896dadd', 'Actual Contribution', 'f4aae434-5b27-43ce-8525-b35316a24f96', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @WFPRDId, 'd907e635-82f8-489a-bdb8-bd2d2fa3883c', 'Case Members Report', '03949440-0dcb-44b6-90d3-7c37075fd524', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @WFPRDId, '5c5b0685-e67b-436f-94e1-ad860e2b0111', 'Cases Approved', 'c868404e-a079-4ebf-b652-e2e720d137f6', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @WFPRDId, '09336ded-3270-43bf-93e2-1e65eac9914c', 'Cases Cancelled', 'a6c9b15d-c2da-4cd3-a3ba-927b1c450a10', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @WFPRDId, 'e22cd7f7-c531-4759-9a0b-b5b666b82ede', 'Cases Completed', 'ca320302-8770-406e-be0d-e59664be6af6', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @WFPRDId, 'dd87571d-2574-40f8-8253-f674baa28a5f', 'Cases Created', 'c6d69f06-0d9b-463d-92c3-c6eb60734478', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @WFPRDId, 'e63035af-87e6-44d2-bb42-e80882d4bce0', 'Cases For Approval', 'f9b7610b-cfcb-455a-8e04-ef665324dd88', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @WFPRDId, '7bce29f2-7377-4715-befb-ca5191e90ea2', 'Cases On Hold', '8bbd7a31-2e51-4594-b71f-496b6c2950c6', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @WFPRDId, '407d0010-bff2-4417-9f85-e9b307c10692', 'Cases Unassigned', '60b47a34-fb85-4a59-a68e-48b04c314731', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --10
VALUES (Newid(), @WFPRDId, '8578cd7a-5afb-4942-a1f3-9501dde39207', 'Chargeability', '966ee6fe-75ea-4d2c-b4d4-476cfe14e325', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --11
VALUES (Newid(), @WFPRDId, 'f7b0d4be-d4f2-4790-aebb-5463ca3e7bbc', 'Client Contact Report', 'e76b8207-c442-4a0e-b778-6f6e42f1b18f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --12
VALUES (Newid(), @WFPRDId, '9378e1ed-e71c-4b28-a000-56d33bd0750a', 'Clients Created', 'ab654f38-f87a-4ac3-8ab1-179f53761a1f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --13
VALUES (Newid(), @WFPRDId, 'd3d13c73-49eb-42db-8acb-715bb9477a49', 'Clients Inactive', 'e7a4cc43-20a5-484e-be55-554024cee3ab', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --14
VALUES (Newid(), @WFPRDId, 'd66b8968-dfcc-4629-9a93-6fc341548b50', 'Clients Now', 'dab6c1b2-4873-4a5b-a372-e8b624a5ed29', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --15
VALUES (Newid(), @WFPRDId, '1558df3a-03b1-4187-972e-5f25ac10c1d8', 'Clients Re-active', 'c7c26e67-17bc-4459-9591-cd6d9cc4916f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --16
VALUES (Newid(), @WFPRDId, '8259d83b-ad3e-4906-a1ab-e9caea533c63', 'Incidental Tracker', '7a4b672a-c5bd-44d7-ba53-6b10fda753ef', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --17
VALUES (Newid(), @WFPRDId, 'a4f5dd3a-769e-42d1-aa28-35933d720937', 'Individual Case', '6b050e3d-ebc1-4ebb-9ead-d51e2e615152', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --18
VALUES (Newid(), @WFPRDId, 'b98ee2e2-bbba-498d-8255-7703c7ad6dbc', 'Individual Client', 'f010807e-68e4-402d-95cc-37c5417c2ed9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --19
VALUES (Newid(), @WFPRDId, 'c7084a2d-8bf4-406f-a23f-7e9f2b5490a1', 'Invoices Generated', '04f92371-612a-4fcf-8c94-bb4dcb9e75d9', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --20
VALUES (Newid(), @WFPRDId, '865f278d-3f75-4584-a728-c55b6661696e', 'Invoices Not Generated', 'cc42b564-5c97-4d70-9bef-07421750eaed', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --21
VALUES (Newid(), @WFPRDId, '7e1aa470-2a1b-48be-ab5a-43025f858c94', 'Planned Chargeability', '3027539a-471d-478c-a226-5a5893ab1d5f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --22
VALUES (Newid(), @WFPRDId, 'feab4023-1f51-43b5-b572-dd8314108677', 'Planned Contribution', 'dedb4260-5b16-49ae-9055-02e9dad3fc87', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --23
VALUES (Newid(), @WFPRDId, 'baccca48-5fb7-4ef3-abef-e5f0917a8023', 'Recovery', 'd87ee5cd-3734-4db4-8d56-20ce312ab87d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --24
VALUES (Newid(), @WFPRDId, 'd6a9951f-1504-4916-854d-1b43dff10a72', 'Unpaid Amount', '2aa3bd2f-e326-4559-a1ae-82a7f3795fba', 'PRD')


 --===========HR PRD---===============
 --=============================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @HRPRDId, '114d829e-00e3-4cc2-b5f4-784caeb3e9c9', 'Attendance', '72fa58a5-0aea-4702-8475-f1b2c1eefde3', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @HRPRDId, '0e42a19d-52c2-4972-bc3b-004f189f5caf', 'Claims', '0651c3ac-dbe9-452d-97ce-3604386855ec', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @HRPRDId, 'a40db012-53ea-4a30-a667-55daafd152ac', 'Employee Details', '3ba60183-5873-4bcd-ba34-f1bd182c464c', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @HRPRDId, '8ee61698-8731-46de-b1cf-b3af805c9105', 'Leaves', 'b0e114f0-50f4-4040-8d68-46e895632601', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @HRPRDId, 'f1b3597e-3bde-4e97-a1a0-afbb0e8424bf', 'Payroll', 'baf9c6be-714f-4a5a-bc18-413bd4853221', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @HRPRDId, '5797a860-2fa6-4cf0-ad5f-f5f19619b7d6', 'Recruitment', '2e607a4e-70b4-41a4-9ac2-dd41c5274c42', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @HRPRDId, '6e72a3fc-06b0-4c32-9369-077509addc78', 'Training', 'cf0bfae0-4b13-448f-8660-cb0eb719a577', 'PRD')


 --============================================= DrFinance PRD===============
 ---=======================================================================================

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
VALUES (Newid(), @DrFinanceRDId, '3e098337-ecf4-4b4a-8976-7247bed8d051', 'Asset Analysis', '5a1a0466-3924-4ec5-8df8-4d7c1e3feda7', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @DrFinanceRDId, 'f76a0a0a-e437-4435-a016-1f19a1e5f3b0', 'Debt Analysis', '5ac7d3e4-6282-469e-9d1b-70e67c60471f', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @DrFinanceRDId, '9605f09b-a4eb-47c6-a736-a87e02b89cfa', 'Expense Analysis', '57f7f43e-8634-4fc2-9f8d-6a5fb0d9f5a4', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @DrFinanceRDId, '6f7d71ba-8c74-43ae-a802-abccf56c2408', 'Financial Ratios', '948a2646-faaa-4f7f-90f7-a68280c5276d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @DrFinanceRDId, 'd913002e-c5e1-4760-bea3-10328516b934', 'Growth Analysis', 'fecac5bd-dcdc-4f9a-bbb3-cf83d8173b46', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @DrFinanceRDId, '09825e53-19b5-4c19-923e-63c93633f7e4', 'Liquidity Analysis', 'aa6d31a0-73a4-4abc-829b-a9259c50cf5c', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @DrFinanceRDId, '5538c3d7-6e8f-4c8c-92da-1c0d4a21f4d7', 'Operating Cashflow Analysis', '1f085baa-8d5f-46db-b58e-9fb5c074095d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --8
VALUES (Newid(), @DrFinanceRDId, '01ba722c-3bcc-4cba-90de-c6e216f3ac3f', 'Profitability Analysis', '20a5726d-7a2b-4641-81e0-c6c80ffa9650', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --9
VALUES (Newid(), @DrFinanceRDId, 'f8864b58-40f4-44fc-a555-487a6f409776', 'Revenue Analysis', 'f5ca3d40-dfda-4d81-a3e5-23c52c6cf99b', 'PRD')

 --============================================= CC PRD===============
 ---=======================================================================================


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'1b403f0b-29b0-4624-82d8-2cadc7f96e4f','Accounts Inactive','d2edfe82-4dea-4637-bac2-53dd4a55a086','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
 Values(Newid(),@CCPRDId,'ce4af180-f7d6-4565-be54-1a519754a1fc','Accounts Inactive Report','f35c270c-1c3b-4574-b681-b92c7fe359df','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'1d1e4d72-fad4-4a42-8e02-060fc21181f2','Accounts Lost','824bc31c-8252-457e-bab4-058639552954','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'f8b834e1-32e8-42d4-85c7-1dc36792b21e','Accounts Lost Report','76c9cf9c-7674-4908-97f2-58ab464db730','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'9beb6d39-88e4-4142-8b4d-ad97326395ea','Accounts Now','51fa9a29-430f-4ae4-a071-ea2520148034','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'84ef854c-f66c-47c2-beb8-a6149b4fbfd1','Accounts Now Report','77f8ca68-fe44-4915-8a96-8ec227984362','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'0985d0a8-40d5-4069-9f84-5e4f0251b4fc','Accounts Re-active','541f29f1-efb2-417f-ba48-b76db0034a2f','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'88e2f5dd-f0ff-4929-a861-2396286a290a','Accounts Re-active Report','dfc4beb5-3448-4d5a-8384-3d5d1339e6bd','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'6cb31bc3-fc87-4c99-8e01-8739f7dd5f61','Accounts Won','a92a0a72-820b-43a6-9e3c-3837bf62a7ee','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'3706f266-454e-42b4-a2bc-482857b12b78','Accounts Won Report','a0dd49aa-0638-4f5e-88b1-6ff698651d7b','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'947988c0-c04f-4744-b962-320b6ebbfef9','Individual leads-Accounts','2fc59a4c-279c-4817-b3d0-f9eb8a7597ac','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'67bd0dbf-951e-4484-b267-af6fc125a00f','Leads Creation','6f6764fc-1427-48ab-a165-46f8d48412b6','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'f38f03c4-8b3c-4122-9ad8-322a0f92b29e','Leads Creation Report','0ccb501e-73e6-4d9d-bbbe-e2329e06e2b2','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'b3ff60f0-a4dd-4898-b239-984dc32f77d0','Leads Lost','82795edd-9de0-42b9-bf7a-d09a7699dd88','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'761df5f5-6f00-49d2-a889-fb7776446173','Leads Lost Report','293efde4-2a35-4a21-9165-decd1220fc29','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'741f7a68-14ce-448e-b5ee-89363a0436ef','Leads Now','30600142-2ac5-46c7-b3b2-d00a8c0faab4','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'e3942297-a41f-439b-8ef8-820bd5460dea','Leads Now Report','11931549-d2ac-40c8-b9fd-de16f96ff7a6','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'b7c47606-ba1c-4237-bfc7-cbc34f330cf1','Leads Re-new','f9adbe0c-5f52-44ef-b82f-272732c5f505','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'d821fbeb-649c-40ac-9e5a-65931109c456','Leads Re-new Report','a201351d-6c5a-4269-b47a-a4d2c01c549e','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'c9ad4f68-6d05-4122-b857-2bb53da761d1','Leads Won','a61605f7-3105-4086-94f6-1cd8ecf546ac','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'7a0a52b4-f73c-457e-a41f-0715f9147645','Leads Won Report','bea40d31-aaf4-4c4e-b9b1-bb73a7fb0472','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) 
Values(Newid(),@CCPRDId,'8b2af61c-36ee-4101-97f2-6268ea175c23','Opportunities Cancelled','391237b0-f45e-4e4c-8d31-4fdb10a7991a','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'1c035fe8-3d3b-4f4a-92cc-1ad44b6ea085','Opportunities Cancelled Report','d06a72d4-dcdc-40d2-8de3-9ee5467cd939','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'32a58a56-48b1-4c05-aa57-72bc4025c9f9','Opportunities Complete','ec32d53d-55f9-405b-83b0-6b0a7848c3b1','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values(Newid(),@CCPRDId,'f22dd96d-d6d1-48a0-8d8b-15718cba03ad','Opportunities Created Report','0b9e9fea-23de-4959-b400-2b3495bc1a61','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'1fbfd340-5c2d-47a3-8c8b-d040fdced7f8','Opportunities Creation','a1bc63db-4365-4914-9162-c211a6c651fc','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'9b14957e-35cc-4e00-a0c7-af5ff782f338','Opportunities Lost','59e7679a-103a-4bb2-9158-b853039e2280','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'70c09ef3-2f3a-40e9-b33a-9bee18b44f10','Opportunities Lost Report','5f6c12b3-b2fb-4127-ab53-64c21cf0e202','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'ea86b518-617e-4e70-8d16-1dcdbc3116b5','Opportunities Now','e0756c18-09f1-438b-a01a-20c09afa7184','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'5ad7935e-6e6f-40a5-9633-07377ca70cfb','Opportunities Now Report','563f02b7-0ff5-4b68-b8ae-3355d684c43e','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'5de744d5-e9f7-4979-b035-0ec877844523','Opportunities Pending','ad6afcc8-6e09-4a22-a0b0-dc061a16fa35','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values (Newid(),@CCPRDId,'7078bb5b-b2ab-44a0-ba77-2c89b321ad4d','Opportunities Pending Report','f1d0c49f-9516-48c5-9669-2f5736eaf611','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
values (Newid(),@CCPRDId,'effafb53-460f-41bc-a698-be6f81a3b58f','Opportunities Recurring Report','c6156694-5c51-4d4f-9538-f740e44d5e63','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values(Newid(),@CCPRDId,'b38f0268-512c-4fe8-99e2-0c29cee39319','Opportunities Recurring','c64658fc-b683-46bf-bab2-a2cea971af10','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values(Newid(),@CCPRDId,'e92ab8bc-955d-48da-8628-fad002cacc67','Opunities Won','a68ffa43-acba-49a9-9737-ab31d6736c53','PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment])
Values(Newid(),@CCPRDId,'aac3145a-b0c8-432d-87bf-af9464acec57','Opportunities Won Report','9301b650-cb1d-4b3d-8a6a-eb1db14e27f9','PRD')



 --===========Bean PRD---===============
 ----====================================================================


--INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --1
--VALUES (Newid(), @BCPRDId, '97ae1373-6932-43b8-868d-d217b7c04b8b', 'Cash and Bank Balances', '203f6d86-99c1-4d45-acef-81d48c3b587d', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --2
VALUES (Newid(), @BCPRDId, '496085d8-cc54-499f-9600-280809c49932', 'Cash and Bank Balances', '22dc13cc-5f68-44d3-a135-4ca673fcd2dd', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --3
VALUES (Newid(), @BCPRDId, '7123ba57-ecd2-48df-901d-7ca46e5dad8d', 'Customer', 'bbf50a3b-9f45-41b5-bfca-3f399448f2cd', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @BCPRDId, 'af583e86-0a24-4246-b0ee-ef37d67473b7', 'Customer Aging', '995d4710-9c2b-4b5d-9b88-d6b5e81bd835', 'PRD')


INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --5
VALUES (Newid(), @BCPRDId, 'd6238745-9f54-41d8-83f0-ee13c5563ce9', 'Vendor', '13ec17f1-877e-430c-9abe-c0ad1f5e0445', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --6
VALUES (Newid(), @BCPRDId, '20bcffe1-874f-4e87-9c8c-24bef32c058c', 'Financials', 'a712c1c3-654a-4b33-9a56-0c316229e170', 'PRD')

INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --7
VALUES (Newid(), @BCPRDId, 'a07dca01-5b42-48bd-abca-248cc0eaa491', 'Bill', 'bb22a565-d6d7-461f-9492-b6672341b844', 'PRD')


  --===========Audit STG---===============
 ----====================================================================

 INSERT [Common].[ReportWorkSpaceDetail] ([Id ], [MasterId], [ReportId], [ReportName], [DataSetId], [Environment]) --4
VALUES (Newid(), @AuditPRDId, '52d71f30-1f43-4410-abc6-032788d59ba5', 'WorkProgram', '76889ba7-0216-4f6c-a173-6b79eed8ffb8', 'PRD')

END
GO
