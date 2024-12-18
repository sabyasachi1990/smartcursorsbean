USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BC_Vendor_GRID_Aging_Final]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[BC_Vendor_GRID_Aging_Final]
@Tenantid bigint,
@AsOf DateTime,
@Customer Varchar(max),
@Nature Varchar(50),
@ServiceEntity Varchar(MAX),
@DocCurrency Varchar(MAX),
@Currency  VARCHAR(100)

AS
BEGIN

--DECLARE
--@Tenantid bigint = 1,
--@AsOf DateTime = GetUTCDate(),
--@Customer Varchar(max) ='def6b139-e5ae-447a-9a28-bec7f2755dae,9edc19bf-f7c9-466b-aa2d-61e74570061d,0a16e01b-b84b-4dd9-8d8e-310d4eadd4d6,ddb04a42-ad19-4f2f-9916-789abea88d05,a37e2b5b-4b97-408a-ab92-f1c29c714e02,a98646fe-88c5-4ae7-a5c7-029828264073,64de5856-16bd-4fcd-a7bc-4fb74f595597,9f84f8c3-44b7-44f3-9ce6-5a0decc4230b,dc970b20-bb89-47db-9a64-07e58eb29392,2498ae73-c837-4a74-b969-c3acd4fa6997,282e5f31-34f3-481b-87cc-807bbaac00d3,058135fb-771a-4b67-943d-394af6bfff6d,85cfbec9-5dcf-4cef-bd62-ecfaaba7398b,81a21a1b-11c9-4f35-a978-645f867897cb,642a1bfd-762b-4d20-8640-60e14293f7b3,7a55c909-82fd-44a3-9f4e-05c7f3fbd832,80b51afb-07c4-4a0e-b373-220c4fdc0259,86542695-3b8c-4848-8b7d-e36a9e9c31ab,acef34c6-d89a-4425-9835-d8fa15203470,1c22ca0a-c363-4a47-a730-0c45158c10d0,e5928f54-e626-4112-bf11-71da1f1f81d7,1df4e5c0-0244-4b16-b2d7-455c7828a27f,e354dfdc-c696-4a87-a9f9-30d766222ef6,d477e7ed-510d-4856-b426-d8a69b62d7ff,b017f5bb-d66d-43c0-b3e2-c4bd8556e290,b421136d-4f57-48c5-82a6-c1144dd4d769,83e87119-c31d-4adb-8355-e58700ffeca1,4e7de3da-cc12-45f6-a898-96b37256c5fb,9a3d915f-711d-48a3-afb9-3032d6a3e3b5,f0dd447b-7bab-497a-a56d-5f57957e3ec1,d773de8c-b706-4f63-9e12-041cf321fea4,3af38c5f-00a9-4365-af9a-51ae545800e7,c58ba6c8-442e-4844-ac11-fbfddc36c67c,4ef58cb5-58c5-43a7-a5cc-c6b397bba182,7e250d69-9551-49be-ae9b-881e024b717b,4c03b527-8eb8-448b-8edf-2fc8ce081075,07da99dd-1c0b-4a6d-a6e5-79e504b670c7,1cc5944e-53b9-45aa-8167-e39734ae0381,cb3ff13e-2a16-488b-b34c-356b5973d60e,130be480-7995-4949-be7c-487abe14885b,1e786005-1432-4e47-95c9-176ff7c5ca99,94551452-6831-463e-ac2e-7b23a8792db3,f157beaf-3859-42fe-bd52-5bd6d5ba6c7a,53c253b0-4e1d-4638-b667-a4c731693d6e,ecafa2b7-4bd7-4864-b8f6-3d2f5e5db18b,c0412f9f-66c3-40ee-85d1-053d6d5b88f5,6222075a-cf73-4f12-8b7f-f97009b2dffb,47d58a42-284a-4e83-869e-899e6ef1d4a2,6d834830-8091-43ab-93b4-1fc06389f550,acc9c439-cb15-435f-81ac-d641205f6953,3ce494f7-b0db-49a1-8707-8bdd8cb15c4e,9cc3ba64-8573-4d7f-affb-7ef96ca5911b,7afc9a0b-850a-413b-b1c5-49312897c9f5,df77b1c1-0f93-44b5-8c55-d00218b31628,6afeae9f-9d27-4eb3-aa86-a357b7609c4b,388aed47-2724-40f1-b481-572c4500ac52,1599eb9d-ceff-46e2-9c47-4ac56de6ddeb,21c76f44-ef71-48ea-b205-1a9db88a610f,0dfb83fc-10f5-424f-bb81-100d9a4acd03,e82068f5-f4d4-4118-ae85-6c60897a2c22,1e9a6ee8-8de6-470b-8621-d0ac7061a875,f4269de3-ee36-478b-abae-bc11fbb5f78a,d0819624-86ea-49c4-b450-7ac56637319d,c69a57d1-1499-4963-9b46-4c92761df068,05fc8954-8fe2-4cf1-96d8-bb573dcbe6db,5a289a41-1246-4162-b871-3c004883ef70,fa518540-ffe1-470a-afeb-4ed85344b689,cf4032f3-0976-4b7b-aba6-8cbf7e90ae65,926975b9-ca8a-4c3e-bcf7-53a692a0b7c2,92569319-6679-460b-80aa-7a00a2d85bb4,85908b28-2817-4e42-8cb4-4cff747885ea,5a451896-8cbc-4f93-9851-6abb6579b434,3f1a1626-f326-4ea6-b09c-cf09ee68e801,10b09252-028b-4b02-9e2f-43392c4b0f7f,54534371-db9f-4e04-8028-78981bbe929c,e6f68c4e-37bf-4033-9343-93049070aa24,9e51522a-69d9-413e-8fdb-0dbc2e8c20a0,e07a4367-21ae-41d3-8537-19299462204c,434f8b05-0e8f-4b53-9c9b-6cd047068502,6434bee1-3df6-4ec9-af93-6e601d4efa7a,991bc6a9-fc89-4fa9-baa5-da4d96b23f43,fb777e39-d873-4337-bfbb-a69eb4ae031e,bd205f26-3e2f-4ee3-bb7f-9d41cc58a0bd,1bb07752-38fe-4424-af2f-4994b5cd74ce,d47f8bc3-b858-4a73-ba7f-928a510f0709,55dd90fe-e4d1-4918-b5cd-77e4af1955c5,c80f99ac-f859-419e-b2cb-a2eb9e0996c6,d8b07f37-dbcf-45bd-b9f9-096f9c97f05f,403eaa5f-7c37-4410-ba15-e4e5ca547d23,2326c3f2-3741-46fa-84cd-351582def325,d4ed9194-19e2-4335-939e-c5da839f93e1,1ee62286-9e81-4bda-b77d-7f4f5a08f655,4bbff550-064a-4df9-9cfe-e4eccd93eada,bdea48b8-575b-462b-adbc-cebfeda1fec5,f0709ed7-74e3-4522-bcaa-25570d36eea4,deb87acc-d749-48f8-815e-c535fd4adca7,c5235f77-4020-4f5b-b2fe-c7d2f6256a25,cc0a8b0e-4b76-4c2c-a33a-7526e6f075a5,b108b2df-f37c-4b40-8845-49b35e474cf6,ead50375-aeb0-42b3-aeea-27b32fdc474b,bf49ccdb-f794-4374-bae7-13430d282eab,193cc66c-7841-4193-8bec-7259243c30b3,de7aab42-04b9-48d5-8256-192d0945f710,c2fd86a6-3e52-4025-9bc0-7077e94e07cd,501cbe4b-509e-445a-9d9e-d3122f6c1587,75676d34-b331-412b-9494-ab10fc5a296a,3a73eda6-53d7-4ec1-8f3a-4be0367b14f7,b8e2470c-bfaa-4c8a-aa7c-a770fa1f3605,488d07f0-ec00-4571-86c3-638e767fb431,32cfdabe-f22e-4d9f-b28a-9261cca55030,a51eefc8-695b-4b60-8eb1-5a855645b0a4,4bbab8ec-e8ab-4016-8ba4-395954772b4f,fe159dc4-21f3-4e08-9813-2635308bc35d,a482d198-7158-4f57-b5a5-306d42bfa2f4,99fbc426-98f0-470b-bb98-6bc2a4049899,19fde764-a7dc-4caf-87fe-5ec6c70322c8,0c893dd9-80c1-42a9-82ea-e95aef75364e,deaf4eec-2072-429d-bd07-30b08aecd689,3c09e98c-886f-46b4-aad6-38bb11e71d84,46aebab8-a1c0-4406-b436-8cbd8d1794dd,dfd5fe6d-57e2-4e85-a3ee-efcce7f8d288,7aa5c3dd-5b8d-403d-9120-1e46906c71a3,f5930ddf-96c1-4b80-91b3-945f0ac6b7d9,2e1b6343-1017-4ac7-95b1-b6e9bfe80613,02a0312b-6bb8-4e5f-88d1-b4f4db63b25a,a838fa3c-f1a9-4e3b-9d99-6dfcc90515d7,0178b0f8-b9d1-46fb-b31c-923c701e5682,387903bf-003a-4998-b5e4-8ef9023a6d88,ef078a17-f2c7-4a38-a785-ab400101f865,620ec338-819c-49ac-8ddb-5a536c7b313d,eae2e799-10bf-4005-a3a5-22c8111f043d,9ca57b4d-d0c3-4fd3-9893-c5afdfa28a17,038b2d6a-262c-4f84-8865-cca39522b760,53840190-12fb-4521-ac56-d672a75a7f9d,1e8681b2-98a8-45a8-aa9d-5f0bb1254093,cc9ed2ed-87c2-4a20-9707-12d3ae7db1c8,254423a1-13d5-41d3-b596-55076192e2ee,dee6a05b-e5fb-4024-9ba6-5f0218158ac8,2e8b115c-32bc-4615-9107-79802e6d5dff,5e498231-f9ba-4af6-a599-59a627d3cfae,3f4bd46a-b5a4-47ab-875e-1dbd0256dbc0,db70aeb9-9a67-48c9-995a-1544898a6f67,7c5a9dd7-8553-45b8-9ad1-fc830aa46afd,079bee45-2fb3-4a00-b07f-717826a41ed8,67dd5813-14ab-4341-b949-eee1cfbd2288,cb0cb6a2-f381-4eab-9038-910dc88664e2,863f772e-84aa-4930-aa7c-61d4cc3cc5d0,c1407dd2-1cad-471a-93b9-b47024a059ef,bd4613c3-5f96-46da-8b15-7f6b42a28e10,3b0cd432-df54-44ef-a47b-e5dfc4eb298f,49dd9d6d-aae9-4a67-939b-95f9489477e7,bdddaf6d-0d3a-4444-8271-cf46509d2e8c,787f7307-ea52-44ff-90d9-35f8b39471f0,1c8efb90-69bd-4a3c-b448-7a32f586cdbb,3c94041f-ab69-4a3c-b065-8e43815a5300,a9f9cac9-6423-4d08-9b65-f5f79139ff70,564dda7b-8977-4d34-a354-0b6ab675f9bf,3a469b20-08da-47c1-ba1d-adc0e1928208,67c588e3-5715-4b1a-9505-524d9546bd8b,9fc58423-3dc4-4e99-a3a1-714c7b3ebbee,03a45d89-b5c2-4515-bd18-0c94df5971a3,35d50723-58c9-45d9-a6cb-9484374e5009,bcf02023-1e45-476e-8ed6-e46a1c630729,753a1aab-af3f-46fa-8ce9-6b96f612ff68,f3bcdfad-4ed0-4caa-86f2-bc2a1665098f,a6d0b7ca-b526-4766-9a68-8f21e4e2cc40,23f88daf-9cb8-4ef0-8f66-97cfe8da8026,4c8cf953-05e4-4fa1-ae02-69d409eacee5,12961f05-b44b-4e3d-ad19-cf43f457a807,bb5fdc55-2628-4299-a495-8d4fc3618532,608a412c-941d-4474-b959-355f4e30579f,5df38b28-588b-49be-9ae3-18416ce18267,f055bf45-fbaa-4b65-aceb-ba66a6e36877,be33ed2c-fa42-4e03-aa8e-0ccf0c905787,b884aff2-fe85-4f10-8b83-3ebea86125b4,3c701b30-15b7-4a41-80cb-3d0daccef7e0,f0e98cae-5d87-44a7-af17-e7c299137eb0,5a3aaa2e-5ab8-40d5-b4ea-48088ca9c2d2,b8557c05-4211-4ca3-a8df-d8c4d0a5e8c6,334c1059-b5d3-497a-a1d9-389d25732db6,eeb14b07-96b2-4986-ae72-baf907366895,bf3caa34-c7f9-468b-9f2b-92b83c5ec5f9,2c687328-bd78-4649-addf-3b8a4213655f,e933db4d-a684-4a1d-92a5-00232769f948,2a43a5cb-99fe-4e8d-a2ba-c3626aaf58e1,70268337-fd16-4f72-80d2-36e35afd2a9f,08ee8f7a-2b2f-4e79-b66e-6a07d02dd174,e33d3ffb-da79-4aa0-a1fa-3eaea50918f6,0e6e635e-5e99-4745-87f0-5eca854a4ae6,36ebdb73-6f0e-4c32-8a34-f3d8307189ee,fef93e16-b7ea-40d3-b19e-a119c7af1606,f1d03fea-846c-4624-93cd-731b7f2b7bcb,5396bd8f-ff09-4570-8714-fb1592668f8f,2bef3a7d-08a0-4700-9c3b-60ed64b9da47,fb6a63e4-e121-4fa2-8947-daedfc1aee16,83feef7e-09f6-4880-9f18-a419bf3de59a,ccdfb681-a077-4d35-94bf-26abfb322b1a,f66ea074-2306-49da-b11d-e7c2cb429e1e,2476f404-2b7f-4af2-a7fc-807aebab43a6,d77266eb-1b08-4b1a-a3bb-1abc78b53b7c,622a2f20-b699-4c76-91a4-352d561fbbee,7827bb13-2d63-4ef8-85bb-3303f707c1e5,43fdf72c-6598-48d3-bbe1-861b121baa71,dda5849a-3b17-45bd-ac0c-fb55cc319c92,0b5f53b1-e881-4785-a1b3-cc4499014816,56a2c470-7279-43f0-8638-eaa160c9477b,1688bc8d-49f6-423e-bced-5407b365b6c8,aaa21c9b-0a71-44bc-ac3b-ad3a298d4984,8c691573-33c9-4cfd-8cf1-4b6e6557e255,7623f715-71bd-4b79-ba79-4977f68fb05d,2c3309fe-8217-4870-b115-c226860b4db8,43d07eb0-e160-4f95-8dac-18901b6a9d9a,76a2ad9a-beab-43e4-bdcc-877e23473d32,3839c319-d892-4a99-ab6c-13b1bdcf691d,7c1c6617-600a-468b-8f8c-f2f9c3f760b1,13de4e9c-5421-4b86-a81f-eba7983d1a28,fc937dbd-427a-4570-85a6-74d85e448f46,9ee60189-5576-4880-9611-a07561922d20,d15cb909-0850-4733-9cf1-04db1a60f75a,9d4b0819-61d4-4a9f-8538-787f9b417af3,b859730c-56a0-4da4-8d55-f3ee2726c161,412e4335-0df7-4212-9526-00990c7088c9,6ab61f41-e013-4e1e-984e-bf2c4f4705c7,1d25a6d4-96c3-42d5-b5b9-ca22befaef58,ad7e5893-eea0-4b2a-8594-9e2bd7663b77,2f453ace-05c8-4c86-93ab-58d8e47178ab,fe56f27c-905c-4e1a-909d-a94bf0967a36,742e7db9-30da-40da-b461-43c287c53dc6,8b25ce92-136d-4a89-99f5-876c17abbffc,607ca021-f876-4d3f-99d3-51bbad1f3db3,147bb616-0257-45ea-93da-5646ca27fbc5,a423dee4-6dbc-49c1-9042-26f3ddabe028,24cb46fd-56de-4112-8656-eb973c39c65c,c2ad4c0a-7f10-445b-9468-11e5421f1552,b5e12c0f-d1f6-45b7-ab69-67f3258a5aba,440143c6-e16d-452d-8fb4-8e5221a0513b,66b4123d-fc77-4d12-9fa0-6d7f7ae3e2ad,c8d4afde-272a-41a6-8b8d-835d5ec13ce5,a9f8209f-6038-45d0-b560-f03ab9aed7c2,82ede136-d128-4d31-8839-9408270cefe0,8af8fcff-17d0-4958-9af6-b345b177e3c5,6c7558a0-a6f0-40fb-b666-5693983079e9,2ae2959f-869b-495d-b37e-628f3ec9c6f9,956cd149-04e3-42a3-9db0-2fdf8d4b03c5,d5115eaf-18b8-4f37-b3cc-216fe89b82d0,3f47576e-1fdd-4ae3-a73c-1710e210cd35,9707db2c-be6e-4674-b665-2109ddc2e180,5bdc2420-9c4f-45e6-8620-83c28572f212,27cfbc14-60b4-4ca6-9810-8fff0f339a0c,92b6fa90-0c6a-46be-8445-959ff1554706,1e594cc7-0f3a-4015-82fa-224713723d69,fb803cf1-de8b-49a3-b24a-68c5bcc9d55c,6c93a492-b979-4a12-b8cd-ce681754d155,4e7d5bda-ced3-4d37-a197-dcec01278f32,162af62a-57f0-4dd7-9db7-51eeefeae831,8b6fe1c8-b84d-4adf-97cb-7bb324a98294,6623e3b5-1ebb-4b4b-aa55-1d09555337da,c5d471b1-0bd0-40a9-9cdb-a3044af7a6cc,0b6c99d7-7695-4761-9bc6-b6a58c05bb1c,be3c9720-ae0c-4c39-9e57-2a0dc98fb82f,53780ce3-0e25-4efb-b3a3-ea098b3ea1fb,09a0f70c-6afd-4724-92e3-6843da7e2d32,becf7a98-4a87-43a6-8659-6a95a42abf52,502fdb78-ec90-454f-86e3-55d20ee11daa,b436b073-1700-414c-b5d2-9b17b9e5521f,8d9f6279-7eab-4e90-af3f-d0d72c1086ec,3f5cb1c4-d59f-4d26-b21b-42f238043f2c,f27466ce-7324-4afa-bb3e-0fa0ca6863ca,fdea31a2-09af-4d26-ac16-b29882284dde,12c2404c-d5c8-46ce-aa5e-240e53ccf0c7,88a3a69f-920d-41b2-b006-5c9c697cab8e,acf0c266-f42d-4997-82f8-8377695969ea,39a51052-197e-4308-a812-7f33ee82e8da,005edd5a-926c-4813-bd6b-287ae4a91ddb',
--@Nature Varchar(50) = 'Trade,Others',
--@ServiceEntity Varchar(MAX) = N'3,9,4,5,6,7,2,8',
--@DocCurrency Varchar(MAX) =N'AED,AMD,ARS,AUD,AWG,AZN,BHD,BSD,BYR,CAD,CHF,CNY,DZD,EUR,GBP,HKD,IDR,INR,JPY,KWD,MYR,PAB,PHP,THB,TWD,USD',
--@Currency  VARCHAR(100) = N'Doc Currency'


DECLARE @Customer_TBL TABLE (Customer UNIQUEIDENTIFIER)

INSERT INTO @Customer_TBL
SELECT DISTINCT items
FROM dbo.SplitToTable(@Customer, ',')

DECLARE @Nature_TBL TABLE (Nature NVARCHAR(200))

INSERT INTO @Nature_TBL
SELECT DISTINCT items
FROM dbo.SplitToTable(@Nature, ',')

DECLARE @ServEnt_TBL TABLE (ServEntity NVARCHAR(200))

INSERT INTO @ServEnt_TBL
SELECT DISTINCT items
FROM dbo.SplitToTable(@ServiceEntity, ',')

SELECT Id, [Name] INTO #VEntity FROM Bean.entity(NOLOCK)
WHERE CompanyId = @Tenantid

SELECT Id, CompanyId INTO #VCOA FROM Bean.ChartOfAccount
WHERE CompanyId = @Tenantid

DECLARE @Aging Nvarchar(100)
SET @Aging = (SELECT 'Document History into Temporary Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

	SELECT Companyid, DocAppliedAmount, BaseAppliedAmount, TransactionId, DocumentId, DocState, PostingDate
	INTO #VendorHistory
	FROM Bean.DocumentHistory(NOLOCK)
	WHERE companyid = @Tenantid AND DocState IS NOT NULL AND (AgingState <> 'Deleted' OR AgingState IS NULL) AND PostingDate <= @AsOf

SET @Aging = (SELECT 'Document History into Temporary Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @AsOf = DATEADD(day, DATEDIFF(day, 0, @AsOf), '23:59:59')

SET @Aging = (SELECT 'Journal into Temp Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

	SELECT J.Id,J.DocNo,J.DocType,J.ServiceCompanyId,J.DueDate,J.DocumentState,J.CompanyId,J.Nature,J.EntityId,DATEDIFF (day,J.DueDate,@AsOf ) AS [Days] 
	INTO #VJournal
	FROM @Customer_TBL AS Cust
	INNER JOIN Bean.journal J (NOLOCK) ON Cust.Customer = J.EntityId
	WHERE J.CompanyId = @Tenantid AND J.DocumentState NOT IN ('Void')
		AND J.DocType IN ('Bill', 'Credit Memo', 'Bill Payment', 'Cash Payment', 'Payroll Bill', 'Payroll Payment') 

SET @Aging = (SELECT 'Journal into Temp Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @Aging = (SELECT 'Master Journal into Temp Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;
	SELECT J.*,DE.[Name], com.ShortName
	INTO #VMasterJournal
	FROM #VJournal AS J
	INNER JOIN @Nature_TBL As Ntr On Ntr.Nature = J.Nature
	INNER JOIN #VEntity AS DE on J.EntityId = de.Id
	INNER JOIN Common.Company com (NOLOCK) ON J.ServiceCompanyId = com.Id
	INNER JOIN @ServEnt_TBL AS Ser ON Ser.ServEntity = com.Id
	WHERE J.CompanyId = @Tenantid AND J.DocumentState NOT IN ('Void')
		AND J.DocType IN ('Bill', 'Credit Memo', 'Bill Payment', 'Cash Payment', 'Payroll Bill', 'Payroll Payment') 
SET @Aging = (SELECT 'Master Journal into Temp Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @Aging = (SELECT 'JournalDetail  into Temp Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;
	SELECT  ----- DISTINCT  -----> Removed Distinct By Sk Mustaq Ali on 29/11/2024
		JournalId,JD.DocType,Jd.DocDate, Jd.DocCurrency, JD.DocType AS JDDocType, 
		Jd.DocumentId, Jd.DocSubType,Jd.COAId,JD.BaseCurrency,k.PostingDate,k.DocState,
		Jd.DocumentDetailId,ISNULL(K.BaseAppliedAmount,0) AS BaseAppliedAmount,
		ISNULL(K.DocAppliedAmount,0) AS DocAppliedAmount,CMA.CreditMemoId,Jd.ClearingStatus
	INTO #VJournalDetail
	FROM  Bean.JournalDetail JD (NOLOCK) 
	INNER JOIN #VendorHistory AS K ON K.DocumentId = Jd.DocumentId 
	INNER JOIN #VCOA (NoLock) as c on c.Id=Jd.COAId
	LEFT JOIN Bean.CreditMemoApplication As CMA (NOLOCK) On CMA.Id=Jd.DocumentId
	WHERE JournalId IN ( SELECT Id FROM #VJournal) AND c.CompanyId = @Tenantid AND K.PostingDate  <= @AsOf 
		AND K.DocState IN ('Partial Applied', 'Fully Applied', 'Not Applied', 'Not Paid', 'Partial Paid', 'Fully Paid') 
		AND (JD.ClearingStatus <> ('Cleared') OR JD.ClearingStatus IS NULL)
		AND Jd.DocumentDetailId = '00000000-0000-0000-0000-000000000000'
SET @Aging = (SELECT 'JournalDetail  into Temp Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @Aging = (SELECT 'Journal and JournalDetail into Temporary Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging; 

	SELECT 
		J.[Name], Jd.DocDate, J.DocNo, Jd.DocCurrency,J.DocType, Jd.DocType as JDDocType, Jd.DocumentId, J.ShortName, J.ServiceCompanyId,JD.DocSubType,J.DueDate,
		JD.CreditMemoId, ISNULL(jd.BaseAppliedAmount,0) AS BaseAppliedAmount, ISNULL(jd.DocAppliedAmount,0) AS DocAppliedAmount,
		DATEDIFF (day,J.DueDate,@AsOf ) AS [Days], 
		CASE WHEN J.DocType IN ('Credit Memo','Payment','Payroll Payment') THEN  ISNULL(jd.BaseAppliedAmount,0)*(-1) ELSE ISNULL(jd.BaseAppliedAmount,0) END AS [DaysBaseAmount],
		CASE WHEN J.DocType IN ('Credit Memo','Payment','Payroll Payment') THEN ISNULL(jd.DocAppliedAmount,0)*(-1)  ELSE ISNULL(jd.DocAppliedAmount,0)  END AS [DaysDocAmount]
	INTO #VendorJournal
	FROM #VMasterJournal J (NOLOCK)
	JOIN #VJournalDetail JD (NOLOCK) ON  J.Id=JD.JournalId 
	WHERE J.CompanyId=@Tenantid and J.DocumentState Not in ('Void') AND j.CompanyId = @Tenantid AND jd.PostingDate <= @AsOf 
		AND jd.DocState IN ('Partial Applied', 'Fully Applied', 'Not Applied', 'Not Paid', 'Partial Paid', 'Fully Paid') 
		AND J.DocType IN ('Bill', 'Credit Memo', 'Bill Payment', 'Cash Payment', 'Payroll Bill', 'Payroll Payment') 
		AND (JD.ClearingStatus <> ('Cleared') OR JD.ClearingStatus IS NULL)
		AND Jd.DocumentDetailId = '00000000-0000-0000-0000-000000000000'

SET @Aging = (SELECT 'Journal and JournalDetail into Temporary Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

------>> Bill
SET @Aging = (SELECT 'Bill into Temporary Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

	SELECT 
		de.[Name], I.DocumentDate, I.DocNo, I.DocCurrency, I.DocType, com.ShortName, I.Id, I.DueDate,
		ISNULL(K.BaseAppliedAmount, 0) AS BaseAppliedAmount, ISNULL(K.DocAppliedAmount, 0) AS DocAppliedAmount,DATEDIFF(day, I.DueDate, @AsOf) AS [Days],
		I.ServiceCompanyId, I.DocSubType, I.DocumentState
	INTO #VendorBill
	FROM Bean.Bill(NOLOCK) I
	JOIN Bean.BillDetail(NOLOCK) ID ON I.Id = ID.BillId
	JOIN @Nature_TBL AS Ntr ON Ntr.Nature = I.Nature
	JOIN #VEntity de ON I.EntityId = de.Id
	JOIN @Customer_TBL AS Cust ON Cust.Customer = De.Id
	JOIN Common.Company com (NOLOCK) ON I.ServiceCompanyId = com.Id
	JOIN @ServEnt_TBL AS Ser ON Ser.ServEntity = com.Id
	JOIN #VCOA AS c ON c.Id = Id.COAId
	INNER JOIN #VendorHistory AS K ON K.DocumentId = I.Id
	WHERE I.CompanyId = @Tenantid AND I.DocumentState NOT IN ('Void') AND c.CompanyId = @Tenantid AND K.PostingDate <= @AsOf 
	AND K.DocState IN ('Partial Applied', 'Fully Applied', 'Not Applied', 'Not Paid', 'Partial Paid', 'Fully Paid') 
	AND I.DocType IN ('Bill') AND I.DocSubType IN ('Opening Bal') AND I.IsExternal = 1 AND I.OpeningBalanceId IS NOT NULL

SET @Aging = (SELECT 'Bill into Temporary Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @Aging = (SELECT 'Credit into Temporary Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;
------>> Credit
	SELECT 
		de.[Name], I.DocDate DocDate, I.DocNo, I.DocCurrency, I.DocType, com.ShortName, I.Id, ISNULL(K.BaseAppliedAmount, 0) AS BaseAppliedAmount, I.DocumentState,
		ISNULL(K.DocAppliedAmount, 0) AS DocAppliedAmount, DATEDIFF(day, I.DueDate, @AsOf) AS [Days], I.ServiceCompanyId, I.DocSubType, I.DueDate,
		CASE WHEN I.DocType IN ('Credit Memo') THEN ISNULL(K.BaseAppliedAmount, 0) * (- 1) END AS [DaysbaseAmount], 
		CASE WHEN I.DocType IN ('Credit Memo') THEN ISNULL(K.DocAppliedAmount, 0) * (- 1) END AS [DaysDocAmount]
	INTO #VendorCredit
	FROM Bean.CreditMemo I (NOLOCK)
	INNER JOIN Bean.CreditMemoDetail ID (NOLOCK) ON ID.CreditMemoId=I.Id
	JOIN @Nature_TBL AS Ntr ON Ntr.Nature = I.Nature
	JOIN #VEntity de ON I.EntityId = de.Id
	JOIN @Customer_TBL AS Cust ON Cust.Customer = De.Id
	JOIN Common.Company AS com (NOLOCK)  ON I.ServiceCompanyId = com.Id
	JOIN @ServEnt_TBL AS Ser ON Ser.ServEntity = com.Id
	JOIN #VCOA AS c ON c.Id = Id.COAId
	INNER JOIN #VendorHistory AS K ON K.DocumentId = I.Id
	WHERE C.CompanyId = @Tenantid AND K.PostingDate <= @AsOf 
	AND K.DocState IN ('Partial Applied', 'Fully Applied', 'Not Applied', 'Not Paid', 'Partial Paid', 'Fully Paid') 
	AND I.DocType IN ('Credit Memo') AND I.DocSubType IN ('Opening Bal') AND I.OpeningBalanceId IS NOT NULL

SET @Aging = (SELECT 'Credit into Temporary Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @Aging = (SELECT 'Query StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;
IF @Currency='Base Currency'--Base
BEGIN
	SELECT Entity, Date, DocNo, DocCurrency, DocType, ServiceEntity, CAST(SUM([Current]) AS DECIMAL(18, 2)) [Current], Cast(Sum([_1to30]) AS DECIMAL(18, 2)) [_1to30],
	Cast(SUM([_31to60]) AS DECIMAL(18, 2)) [_31to60], Cast(SUM([_61to90]) AS DECIMAL(18, 2)) [_61to90], Cast(SUM([_91to120]) AS DECIMAL(18, 2)) [_91to120],
	Cast(SUM([_120]) AS DECIMAL(18, 2)) [_120], DocumentId, DocBalanceAmount, BaseBalanceAmount, ServiceCompanyId, SubType, DueDate
	FROM (
		SELECT 
			[Name] as Entity, J.DocDate as Date, j.DocNo, J.DocCurrency, j.DocType, ShortName as ServiceEntity, 
			CASE WHEN J.DocType = 'Credit Memo' AND J.DocSubType = 'Application' THEN CreditMemoId ELSE J.DocumentId END AS DocumentId,
			SUM([DaysBaseAmount]) AS BaseBalanceAmount, SUM([DaysDocAmount]) AS DocBalanceAmount, 
			CASE WHEN [Days] <= 0 THEN SUM([DaysBaseAmount]) ELSE 0 END AS 'Current', 
			CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM([DaysBaseAmount]) ELSE 0 END AS '_1to30', 
			CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM([DaysBaseAmount]) ELSE 0 END AS '_31to60', 
			CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM([DaysBaseAmount]) ELSE 0 END AS '_61to90', 
			CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM([DaysBaseAmount]) ELSE 0 END AS '_91to120', 
			CASE WHEN [Days] > 120 THEN SUM([DaysBaseAmount]) ELSE 0 END AS '_120', 
			J.ServiceCompanyId, J.DocSubType as SubType, J.DueDate
		FROM #VendorJournal J
		GROUP BY [Name], J.DocDate, j.DocNo, J.DocCurrency, J.DueDate, JDDocType, j.DocNo, j.DocType, ShortName, J.DocType, J.DocumentId, 
			J.ServiceCompanyId, J.DocSubType, J.DueDate, J.DocSubType, CreditMemoId, [Days]

		UNION ALL

		SELECT
			I.[Name] as Entity, I.DocumentDate as Date, I.DocNo, I.DocCurrency, I.DocType, I.ShortName as ServiceEntity , I.Id DocumentId, 
			SUM(BaseAppliedAmount) BaseBalanceAmount, SUM(DocAppliedAmount) DocBalanceAmount, 
			CASE WHEN [Days] <= 0 THEN SUM(BaseAppliedAmount) ELSE 0 END AS 'Current', 
			CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM(BaseAppliedAmount) ELSE 0 END AS '_1to30',
			CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM(BaseAppliedAmount) ELSE 0 END AS '_31to60',
			CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM(BaseAppliedAmount) ELSE 0 END AS '_61to90', 
			CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM(BaseAppliedAmount) ELSE 0 END AS '_91to120',
			CASE WHEN [Days] > 120 THEN SUM(BaseAppliedAmount) ELSE 0 END AS '_120',
			I.ServiceCompanyId, I.DocSubType, I.DueDate
		FROM #VendorBill AS I
		GROUP BY I.[Name], I.DocumentDate, I.DocNo, I.DocCurrency, I.DueDate, I.DocType, I.DocNo, [Days],
			I.DocType, I.ShortName, I.DocType, I.Id, I.ServiceCompanyId, I.DocSubType, I.DueDate

		UNION ALL

		SELECT 
			I.[Name] as Entity, I.DocDate as Date, I.DocNo, I.DocCurrency, I.DocType, I.ShortName as ServiceEntity, I.Id DocumentId, 
			CASE WHEN I.DocType IN ('Credit Memo') THEN SUM(BaseAppliedAmount)*(- 1) END AS BaseBalanceAmount, 
			SUM(DocAppliedAmount) * (- 1)  AS DocBalanceAmount, 
			CASE WHEN [Days] <= 0 THEN SUM([DaysbaseAmount]) ELSE 0 END AS 'Current', 
			CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM([DaysbaseAmount]) ELSE 0 END AS '_1to30',
			CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM([DaysbaseAmount]) ELSE 0 END AS '_31to60', 
			CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM([DaysbaseAmount]) ELSE 0 END AS '_61to90',
			CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM([DaysbaseAmount]) ELSE 0 END AS '_91to120',
			CASE WHEN [Days] > 120 THEN SUM([DaysbaseAmount]) ELSE 0 END AS '_120', 
		I.ServiceCompanyId, I.DocSubType, I.DueDate
		FROM #VendorCredit AS I
		GROUP BY I.[Name], I.DocDate, I.DocNo, I.DocCurrency, I.DueDate, I.DocType, I.DocNo, I.ShortName,[Days],
		I.Id, I.ServiceCompanyId, I.DocSubType
	) AS A
	GROUP BY Entity, Date, DocNo, DocCurrency, DocType, ServiceEntity, DocumentId, BaseBalanceAmount, DocBalanceAmount, ServiceCompanyId, SubType, DueDate
	HAVING SUM([Current] + [_1to30] + [_31to60] + [_61to90] + [_91to120] + [_120]) <> 0
	ORDER BY Entity, DocCurrency, Date
END

ELSE
IF @Currency='Doc Currency'--DOC
BEGIN
	SELECT Entity, Date, DocNo, DocCurrency, DocType, ServiceEntity, Cast(SUM([Current]) AS DECIMAL(18, 2)) [Current], Cast(Sum([_1to30]) AS DECIMAL(18, 2)) [_1to30], Cast(SUM([_31to60]) AS DECIMAL(18, 2)) [_31to60], Cast(SUM([_61to90]) AS DECIMAL(18, 2)) [_61to90], Cast(SUM([_91to120]) AS DECIMAL(18, 2)) [_91to120], Cast(SUM([_120]) AS DECIMAL(18, 2)) [_120], DocumentId, DocBalanceAmount, BaseBalanceAmount, ServiceCompanyId, SubType, DueDate
	FROM (
		SELECT 
			[Name] as Entity , J.DocDate as Date, j.DocNo, J.DocCurrency, j.DocType, ShortName as ServiceEntity, 
			CASE WHEN J.DocType = 'Credit Memo' AND J.DocSubType = 'Application' THEN CreditMemoId ELSE J.DocumentId END AS DocumentId,
			SUM([DaysDocAmount]) AS DocBalanceAmount, SUM([DaysBaseAmount]) AS BaseBalanceAmount, 
			CASE WHEN [Days] <= 0 THEN SUM([DaysDocAmount]) ELSE 0 END AS 'Current', 
			CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM([DaysDocAmount]) ELSE 0 END AS '_1to30', 
			CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM([DaysDocAmount]) ELSE 0 END AS '_31to60', 
			CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM([DaysDocAmount]) ELSE 0 END AS '_61to90', 
			CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM([DaysDocAmount]) ELSE 0 END AS '_91to120', 
			CASE WHEN [Days] > 120 THEN SUM([DaysDocAmount]) ELSE 0 END AS '_120', 
			J.ServiceCompanyId, J.DocSubType as SubType, J.DueDate
		FROM #VendorJournal J
		WHERE J.DocCurrency IN (SELECT items FROM dbo.SplitToTable(@DocCurrency,','))
		GROUP BY [Name], J.DocDate, j.DocNo, J.DocCurrency, J.DueDate, JDDocType, j.DocNo, j.DocType, ShortName, J.DocType, J.DocumentId, 
			J.ServiceCompanyId, J.DocSubType, J.DueDate, J.DocSubType, CreditMemoId, [Days]

		UNION ALL

		SELECT
			I.[Name], I.DocumentDate DocDate, I.DocNo, I.DocCurrency AS Currency, I.DocType, I.ShortName, I.Id DocumentId, 		
			 SUM(DocAppliedAmount) DocBalanceAmount, SUM(BaseAppliedAmount) BaseBalanceAmount,
			CASE WHEN [Days] <= 0 THEN SUM(DocAppliedAmount) ELSE 0 END AS 'Current', 
			CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM(DocAppliedAmount) ELSE 0 END AS '_1to30',
			CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM(DocAppliedAmount) ELSE 0 END AS '_31to60',
			CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM(DocAppliedAmount) ELSE 0 END AS '_61to90', 
			CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM(DocAppliedAmount) ELSE 0 END AS '_91to120',
			CASE WHEN [Days] > 120 THEN SUM(DocAppliedAmount) ELSE 0 END AS '_120',
			I.ServiceCompanyId, I.DocSubType, I.DueDate
		FROM #VendorBill AS I
		WHERE I.DocumentState NOT IN ('Void')  
		AND I.DocCurrency IN (SELECT items FROM dbo.SplitToTable(@DocCurrency, ','))
		GROUP BY I.[Name], I.DocumentDate, I.DocNo, I.DocCurrency, I.DueDate, I.DocType, I.DocNo, [Days],
			I.DocType, I.ShortName, I.DocType, I.Id, I.ServiceCompanyId, I.DocSubType, I.DueDate

		UNION ALL

		SELECT 
			I.[Name], I.DocDate, I.DocNo, I.DocCurrency AS Currency, I.DocType, I.ShortName, I.Id DocumentId, 
			CASE WHEN I.DocType IN ('Credit Memo') THEN  SUM(DocAppliedAmount)*(-1) END AS DocBalanceAmount, SUM(BaseAppliedAmount)*(-1) AS BaseBalanceAmount,
			CASE WHEN [Days] <= 0 THEN SUM([DaysDocAmount]) ELSE 0 END AS 'Current', 
			CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM([DaysDocAmount]) ELSE 0 END AS '_1to30',
			CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM([DaysDocAmount]) ELSE 0 END AS '_31to60', 
			CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM([DaysDocAmount]) ELSE 0 END AS '_61to90',
			CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM([DaysDocAmount]) ELSE 0 END AS '_91to120',
			CASE WHEN [Days] > 120 THEN SUM([DaysDocAmount]) ELSE 0 END AS '_120', 
		I.ServiceCompanyId, I.DocSubType, I.DueDate
		FROM #VendorCredit AS I
		WHERE I.DocumentState Not in ('Void') AND I.DocCurrency in (select items from dbo.SplitToTable(@DocCurrency,','))
		GROUP BY I.[Name], I.DocDate, I.DocNo, I.DocCurrency, I.DueDate, I.DocType, I.DocNo, I.ShortName,[Days],
		I.Id, I.ServiceCompanyId, I.DocSubType
	) AS a
	GROUP BY Entity, Date, DocNo, DocCurrency, DocType, ServiceEntity, DocumentId, DocBalanceAmount, BaseBalanceAmount, ServiceCompanyId, SubType, DueDate
	HAVING SUM([Current] + [_1to30] + [_31to60] + [_61to90] + [_91to120] + [_120]) <> 0
	ORDER BY Entity, DocCurrency, Date
END

DROP TABLE #VJournal
DROP TABLE #VJournalDetail
DROP TABLE #VMasterJournal
DROP TABLE #VendorJournal
DROP TABLE #VendorBill
DROP TABLE #VendorCredit
DROP TABLE #VendorHistory
DROP TABLE #VEntity
DROP TABLE #VCOA

SET @Aging = (SELECT 'Query EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

END
GO
