USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BC_Customer_GRID_Aging_InvoiceUncheck]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--Declare @Tenantid bigint=1,@AsOf DateTime='2019-11-27 00:00:00',@Nature Varchar(50)='Trade,Other',@ServiceEntity Varchar(200)='2,3,4,5,6,7,8,9',@Currency Varchar(100)='Base Currency',@DocCurrency Varchar(100)=NULL
 
-- Declare @Customer NVarchar(MAX)='c6a655a6-e041-40b0-a191-d9d6ee4925e4,05001b01-6693-405a-a0c3-8bdd7449ed06,6af0ae56-84fa-4ef2-b8b3-e1e53287c91b,851a2ee6-0a5a-4ff5-a514-0ed2f6156d18,dbae307a-5470-43f9-8ea8-aef5e31a4c3e,def6b139-e5ae-447a-9a28-bec7f2755dae,9edc19bf-f7c9-466b-aa2d-61e74570061d,5ce0fd8e-945d-4678-a4b2-261e39323471,cd049246-44c6-4aff-b53e-adf63729634b,1083bf6f-7a74-461e-a970-f08ae1b482fb,694fad0d-55ef-4c24-b36d-7afd15411fb1,f8b353b0-e35a-430f-92e7-9b68a426e394,b1216c99-af73-4f72-8164-7e92a14122f1,750f265f-58bc-4b77-8bf2-cc3d89057405,a0dd5b71-794b-45aa-81c7-90a0ed68bf3e,64fd26e3-eb0c-45f3-9332-49b04862097d,9574486b-93a3-46f4-aaa6-8ede06b2557f,b0d7ef36-9856-4bba-99e6-ce1ea19bc1c2,e06b6246-ff89-4c1e-b64e-66d72d95144c,05b098b8-5d3e-4754-a871-a53e7f1ace40,f1bfd887-01e1-4dd7-8533-ac462543338f,ddb04a42-ad19-4f2f-9916-789abea88d05,a37e2b5b-4b97-408a-ab92-f1c29c714e02,8cf17b8e-f66f-457d-8bec-1ca6532b9664,2d1d7f55-0335-4802-9513-6bfdeebd1844,d9f674b2-a471-42a5-8049-0e4605721313,07907b24-e8e4-4880-b983-268290e30bd5,2adbf8e1-b85a-4815-a0d0-b064c749403b,a98646fe-88c5-4ae7-a5c7-029828264073,51aad2d3-e49e-464a-8159-e43067a62d0a,ff0341e6-0eeb-434f-8e33-0644284c6b9d,dc970b20-bb89-47db-9a64-07e58eb29392,ef9c1fa2-5e55-4434-b5a2-738eeeca8e72,e931fa96-f4d2-411c-aea2-8a4b7cd99fef,ca4260b4-5839-43c4-b6e2-760bee5686ef,519c1784-aeec-410d-ad7a-257c77f25c91,2498ae73-c837-4a74-b969-c3acd4fa6997,282e5f31-34f3-481b-87cc-807bbaac00d3,c83995b8-0550-4c7b-8dbd-e568f8d1cc53,695ead9f-b0f0-42b0-8f29-e78b0ab58765,ad5bb255-508d-46e7-82aa-dcba993386d2,99b2f056-0c77-44b9-adfb-c10484c0a0bf,85cfbec9-5dcf-4cef-bd62-ecfaaba7398b,6a2931bd-6739-4203-9621-6cc541a9f22d,1f2ca9c1-c331-4837-8234-cdf8f0b36274,54e35a4c-c9c1-4c13-be72-58ad4a09e783,192e13dc-1047-4c72-91fe-dcf31670a036,c9ba0398-c98f-440f-a4ef-3e3f0cc2ab6a,46828b42-c0e5-4098-ac6f-34974c718b84,7a55c909-82fd-44a3-9f4e-05c7f3fbd832,30eade1f-2979-4c13-979f-ec6c206c4c7a,e16ea43b-8d4e-4401-b5e4-92363ed24315,31661b03-3299-4426-9137-5188ec7b8314,1b3b3f42-e939-4ff9-bd4b-c7128cb78bfa,0064ab62-e8a1-4066-b3cf-6ad131775b83,e74d0ee5-66f4-4853-8e54-af8581fe8199,c98f542e-e312-4c29-8885-0925dd3b6ad9,9680d45d-a431-45ad-b3a0-dfa88c5f8b10,86542695-3b8c-4848-8b7d-e36a9e9c31ab,0bb3b228-46fe-4ec0-a5a5-5105c9fa8d60,acef34c6-d89a-4425-9835-d8fa15203470,540723a9-034f-4d32-98dd-4cc6209510f9,bb056568-2cfe-4ce7-8d78-a09a3c4c0a3a,c5d0f82f-a804-42de-9c7d-ec240d7acbb2,a302581b-20a8-4597-af0d-8df54acd93fd,036c2ae6-cc27-4314-8437-bbfc51aad687,1df4e5c0-0244-4b16-b2d7-455c7828a27f,16f0f2b1-fd06-4b58-8d9f-5b053957ffe9,e354dfdc-c696-4a87-a9f9-30d766222ef6,854e4762-bcac-4851-a2b9-b69d557e86d7,e4266ff5-3cc5-42bd-a506-b86bef32f4d4,917f6f2a-fb8e-4e30-b0c6-20aa3c3c09b8,e7559984-780e-4633-81cd-7cc0bdc8a62c,89341f99-60fc-4020-91ab-17487ffeaa5d,90cb335d-cd09-4e4b-a696-27031224dbfd,edb9807a-c8e8-4213-8315-e4a8a369a4e5,3a9462bd-7622-44db-a637-e30238197320,58d2ac78-fb75-4246-b3a9-8ee52a04adad,f30f7f62-2f83-4dfa-9c1b-1d41ca9c83ec,a91745d7-84f0-4265-807b-8dda87d0247c,e96af2dc-5940-479b-ad94-aca45bb3810d,df2ca1c6-c825-4b57-a0ee-afc3e8258393,4ee44267-16be-4f14-9716-c5fb3827a5d0,dda4f561-ba64-4d72-8baa-6581a7460ddc,2baa2fe2-595c-4085-a8c6-204952531fa4,43f1a0a9-3a77-4645-9f7f-4533ece80918,119c6dc7-c875-400d-827a-e9f3bf12b124,83e87119-c31d-4adb-8355-e58700ffeca1,4e7de3da-cc12-45f6-a898-96b37256c5fb,a34e2502-4335-4432-a102-1c7126bd1d7a,80e35b3e-9f6f-4a2a-b85f-32f0b9f91d0b,e5a9b726-dc6a-4ef7-bb84-1c7915778462,9a3d915f-711d-48a3-afb9-3032d6a3e3b5,2c1b365b-97ee-4e0f-96c6-bdfecbadfe0f,16179af9-3a8f-4691-ab30-782a72339f46,ea005754-27c6-4144-9697-c5a8ccdd26f2,b9c6a1ee-c94f-4c24-afea-a3643f0f1283,d29ebfbf-35b2-4336-9ad1-0ea7b30ad7e5,e0f33b53-b73d-48d8-9c15-88184c451737,1dadf534-1fcf-4644-96fa-5033a8c43025,2e1226c3-fe58-440e-baa3-66108235a9d8,eef75cbe-a3b9-4c30-9136-1fbc2519f1c9,767d7e8b-1b84-4a0c-ae1f-406ce06e7e82,e68700c1-f9ad-4536-b462-c8629adfec8c,42ef0d47-9829-4f5e-ab55-99a08b0b7d1f,3beeb135-2c59-48ef-9f0a-51978d8650c8,6e94f627-6e9a-49a1-be5f-1f35c89be439,09ec6ac4-4688-41d5-bd83-1b7257e93819,3a4caa88-750b-4a9a-b6ea-677d6e65d9bd,3af38c5f-00a9-4365-af9a-51ae545800e7,c58ba6c8-442e-4844-ac11-fbfddc36c67c,8c628640-9275-40d1-ba5b-436790dc4f2d,44a5a9e2-2e54-4e55-8249-94750742764c,6900205c-66f0-4e94-b498-7ed90b805a68,7ca3083d-ef2f-406a-a387-4525596c195c,dc34b045-7d60-4451-bfbf-5bca95530588,e402654c-e808-42e0-b41a-90c936bf0a8b,9ece936e-2b3b-4182-9487-05895d16e626,130be480-7995-4949-be7c-487abe14885b,c8199900-3ff6-435c-bbc7-915b8ab582b4,1e786005-1432-4e47-95c9-176ff7c5ca99,1e044c01-7727-49b8-aee4-5d800c18e861,67bc361e-fb18-4a53-ad4e-0b0de66dddf8,a85c4a5a-f503-4568-a1f7-19ce4aab6676,61ec2340-18db-4727-a93b-d007aee1c9ce,e9bcb4b1-b579-4e61-862c-a75bece9d069,592d5198-c935-4afc-bff3-3e75145a3777,6aa5b1d4-becb-437d-b6e9-08b1d571c47f,0006f231-ffef-4bbc-a3cf-195715fdf389,b2247336-e43e-481c-98ad-e370441134a2,7d358688-19ca-4f9a-9c26-dec05f922d3c,08ff81f5-b7a5-4f7f-a34f-f4d9b30038a9,569e8e71-fbd3-408d-b183-e01aaac2328d,0a70112a-8f5c-4a04-9de4-4f4b46371681,21f8a91a-3675-4122-9c98-cbfc0c95493d,47d58a42-284a-4e83-869e-899e6ef1d4a2,ab92a582-1609-401f-8fff-ea76aea3b193,d2e023dd-fcb2-4079-b593-3151f3876d36,f67bec18-5964-48ed-a38f-a7836aee7c8e,75a16088-4fe8-4031-8f4f-f900c960c199,ade47d9b-d3d5-4a87-b9e0-7700585194c5,3ce494f7-b0db-49a1-8707-8bdd8cb15c4e,7afc9a0b-850a-413b-b1c5-49312897c9f5,e4f177d3-5cbc-4c44-a90a-72a2a525991f,361f1c0b-e7a2-4754-86ac-8eab2c4e5453,687b60df-3afb-44fe-8f92-88011d5cf57f,388aed47-2724-40f1-b481-572c4500ac52,bdb2b2d8-a026-45c9-8e88-e1303eae783b,4cb3e973-fbb6-49a0-adcc-9c8b38d9e4f6,8cff9ad0-281e-4a31-8abd-6d29cafd0c35,528e59ad-6e7a-4ad5-96c3-a297dc160905,aba25f14-1bf1-497e-bb9b-c06337626193,1599eb9d-ceff-46e2-9c47-4ac56de6ddeb,a3a89e7f-7666-4e65-b64e-05328472ddf5,c590fdcb-08a8-4757-91ff-be89ba08466e,8786405c-cb41-4691-86b0-4fd282430d1b,ece97152-1520-4d5c-b0be-8b9c1b0740dc,c9b42e44-37c0-4123-af82-a1d7ff5a9fcc,eb966853-b5d1-466c-aed0-012e44cd377f,a796d6bd-b504-47f5-abb2-24b2753e4bb7,659c8bce-8419-4bf9-a374-4c14cb3f2d75,0f6b27fa-f952-4367-b40e-4ff869d8e35a,bbfa26f1-b570-4cf2-a705-c1309c99ff57,231c8adb-a19d-4219-aa5e-f4d7bdfdfd69,280bb260-0ee5-4562-89f3-a9a038ecc0a3,69c229d6-5005-44b4-9a92-09786648ff02,0dfb83fc-10f5-424f-bb81-100d9a4acd03,81991cdf-c838-4cf1-94c6-10be93dbe5c3,c26daf9e-82e5-49f1-99da-2e32ff8ae6c0,f0e28a98-d2ac-4791-8f0a-ca7338645623,1e9a6ee8-8de6-470b-8621-d0ac7061a875,f4269de3-ee36-478b-abae-bc11fbb5f78a,16c52b36-77d2-4578-b3a5-8168893178bb,3b0faa06-ed1e-40e4-b79a-4fbfe88892eb,7af46fba-3fcd-47fc-968c-1760992a477c,3ccd26f7-15ba-4f1d-a3aa-ac4c490efb58,ebd995c9-9617-4ab7-b549-15caadb38768,fae139cf-91a1-48d1-bd10-6f870502b798,40dcafab-bb7b-4b2c-9f6d-da66b054f07b,c1ef774a-69a5-458f-82ff-7529fc7676fe,c94e7380-63ec-46b1-beed-fb1b2e7c730b,5ae8737c-7dac-4ae8-92e4-35197336f93e,ccc9d970-1d40-4d32-b512-f0745de803f7,18f98e92-4cc6-41b0-aed9-fd5e8f4795a8,0a9cb8fe-cfeb-40d7-a585-ebbc0a2d91b8,a32f374a-b69f-41d5-ae23-b51d49a33682,84c5ed8a-a8e8-486d-8528-f2d7f6b372e0,aa424c27-9b12-44b3-8e55-e22bced22cf1,5a289a41-1246-4162-b871-3c004883ef70,d4713d4d-6660-41b7-82da-6fa5f3138ec9,6514eb68-e5ba-4e92-ad94-cea3c2d2420b,a3c97285-e425-4da2-b922-5321207a143d,b8fc81fb-f5af-4466-8faa-0c582c13d61e,fa518540-ffe1-470a-afeb-4ed85344b689,3f86fe5d-64ce-4d04-87ff-f1424b378b1f,092014d9-9ee7-4932-8d8c-54be3fb02602,a56b1fd5-8d90-45b4-a9b1-3591ea3bd30d,cf4032f3-0976-4b7b-aba6-8cbf7e90ae65,45352e7e-4165-46fa-a1f7-6f91857cc9c1,f5e79a7e-4ab0-4cdf-a86b-ba9c42e2d65b,52ac912c-04ea-4f15-9a37-8a9bf687e12d,92569319-6679-460b-80aa-7a00a2d85bb4,4b3ab442-31da-4989-acdd-bbf23b0e93f4,4d319af7-ec03-4554-b427-eedb143c654b,b51c90b9-4c1d-46d3-a713-298621e0052a,0358b966-ebae-4f2c-95b1-0027354649fd,17e137cd-843a-4567-81d4-9949c56748fe,7ea8693f-ff8b-45e5-8f17-139045d1f919,12db3f8a-4fa9-4740-a087-8bb3f3f229d0,37dc1dea-4f15-4334-867e-4fa88df3b0c9,18ae4137-efa4-4989-a1f4-1868f7f93bda,e4cb46fd-7109-4e4a-9e88-6a4843326b86,b6fafcbd-7b9b-496d-a1ed-e7c254e04dbf,728c401e-d455-4104-a583-6e919c4e96e8,01c8ea98-1ff7-4db7-9f8a-3469f203d11f,06828b94-4f7d-4cea-a15f-8e078de7419e,087cfb7f-1670-423b-b9b5-2f663b69d20a,3f1a1626-f326-4ea6-b09c-cf09ee68e801,35ab93af-59b0-4d55-b1a3-464858eb5c37,68ec12f2-722b-4438-baa4-32e9f4ab39ad,4cbaf588-b8fb-4eb5-85c7-35a2aa23bd2d,74978368-8ca8-42fc-bb90-c14c7b6d22f4,71f233aa-0cdf-453a-b291-1e894c5a41e1,7b12c02a-fb45-405c-ad75-25e23d2b8a78,126b6fbf-2b2f-45ed-a04b-7d76863df8b5,34b77925-b2b2-4f36-946e-cb6cd1f4f502,5906420d-9cbf-4605-99ea-4b0bb354042d,ae0f78a2-50fb-4498-942c-0a84d8d587dd,0fb6c9bb-9dd4-4106-82fd-bcb27a1cc9e4,54534371-db9f-4e04-8028-78981bbe929c,9ed0d89a-32b0-4da3-9bab-75a021f674c6,55cb6640-265b-46b4-9795-fb18f3b5aa86,155ca845-fd1c-4641-b6a0-441c168309b9,e6f68c4e-37bf-4033-9343-93049070aa24,d0e1c324-2cc9-4ac4-897a-f83bafcf1f4d,5b918e1c-b488-46ef-b1fc-4ee732d84b43,a00ef6ff-b7cd-4251-897e-71a5bbe53d66,141178eb-3078-42f7-ab98-769144367147,db3a45ac-5869-44cc-b4bf-5f17284896eb,24741118-9310-470c-bb1d-35e74613ac85,e07a4367-21ae-41d3-8537-19299462204c,e380a32e-a5e0-4b6d-85bc-415055374449,e135dbf3-2c60-4b6a-a9ba-2aa2117df3a9,8308d22c-26d7-4df0-93f8-0f278ec7a0f0,67de504d-dca1-48e6-9c44-e8ef7a269df2,68ed6caa-b80e-4e9d-97d8-465f16be2f18,30cd5bdc-1216-450a-9004-7abaefe2b9df,66dc1f9e-6cd3-449f-acef-186709e6ba35,18f804a9-ce64-4053-953d-a14c69f2e814,7d5b7291-f09f-4ea0-9651-f73e47266549,e96fcb73-262d-4826-9369-65c451e3f5eb,a6cde22f-8ae9-4a94-97f1-19425eaa20fa,6be3b72b-2fe8-42a2-a834-c01ebc189895,a1b62b49-2f0f-4634-8a21-a22de354584b,60a7837e-8d53-4b5c-b791-5892604b1c24,9d2ba46b-52f0-47a8-b1a3-38bc91139d58,4b80f066-0eaa-49bb-830c-34768b71dcd3,9287f787-16d0-4500-8626-e36296092133,1bb07752-38fe-4424-af2f-4994b5cd74ce,9d008e13-8d89-423d-922c-7f29cdeb6c3e,55dd90fe-e4d1-4918-b5cd-77e4af1955c5,44066f46-f335-41f8-83c2-7a096f554fd7,82e5d193-c61e-480d-8d00-b2ec1bb529a9,d93a783b-d5b5-4505-a062-772627f6cea1,02389c40-d640-4f8d-80ec-cb9c9647783c,4359a7bb-7b0a-4519-9ba6-d1af1a8593c8,3283b9c6-9c58-4971-8df8-ef2280b779b5,0db9bbca-234d-40b3-8e68-0a3cf88e05c3,55c4cf68-0d37-4d0b-987d-10621bc9f04c,1bd671d7-ce3e-404c-b01c-89fbf92e883f,61457921-a106-4257-a01b-c22c05d8782d,2107c6c3-53c6-4023-ba6e-10a330745dd4,a4c1240d-77d3-44a8-9b68-cad2317943e8,a5c5c403-04fa-46cd-b75d-fad5d85424e3,cdaf1aea-6bda-4f86-ac6f-e061cad39778,e6ec76d8-d289-47b2-8bd6-765307880d3d,42163b26-8c30-4de8-a0f7-7d6f199877d1,1edf19bf-2601-475b-99b6-789266327a66,ea8597a7-da89-4748-b078-edaeef23134e,3b2626e6-0e52-4e3b-88ab-4e8f7e427ba4,3c71a8da-dca1-4ce6-8bcd-c2923b2d599f,586da62f-c0eb-40e9-9339-9c832cc735dd,cc0a8b0e-4b76-4c2c-a33a-7526e6f075a5,4e781e05-04d5-4926-8aa1-85238e3f21bd,b108b2df-f37c-4b40-8845-49b35e474cf6,73c800cc-5cea-49a6-9a19-714bf034a31b,d562eceb-c977-465d-bd22-a64e0b43fa63,0b213b19-0ced-47e6-b31c-74bc6e191449,947470a6-ba76-4438-97d8-f087e76a0c24,c3d0c4d3-3d19-49be-a18c-72f7cd3c29d5,6bcd44f6-e223-4dbb-96c2-747e54213722,0ea13f22-a092-4d34-8d3b-1dc51c0ccdbb,6a10e25e-eaf8-44c0-b4b3-1a9629f1c6c7,ccff216d-ae11-4b5d-a792-dd10a34d48be,83110bc7-5000-45a2-988d-6e66844c386b,6326076f-2120-494c-8a30-d27375cd9f27,606e040a-7915-4dcf-a6d3-51706c9d59e9,bcc0d412-5e06-4e40-957c-f88346ec8d65,712bf2c8-d158-4e81-bd10-f85fe8e802e3,28d20e8a-86e9-4284-af6a-cf14f8fe1bd0,c0cd2a1b-4ff6-4d6a-a986-9e2cadb06060,5316336f-b65f-411d-94f7-e4626b85e403,0725e8e3-c2a3-402b-bc7d-339a82c00e2c,c4debc2e-48b1-4165-af39-95fbcb145975,2ee2bcb5-ccbf-4332-90ea-e4ec314fcc44,8366cc07-eba2-43db-8d37-6d628ce8c3d1,387903bf-003a-4998-b5e4-8ef9023a6d88,4c941ec2-1d12-4c8d-84a8-6852ba8d24e0,ea00d6cb-149e-4123-850b-be30b25f60ce,d079503b-baa1-4ad9-b8ca-74da61f18564,7ac47c84-ab7b-48f6-abb4-2b4dde306db6,d1af54db-3c76-4bf5-beb6-d9ad4947f41e,4c2a00b4-1640-414f-b336-0ac9ad454788,e851ea12-b1b9-44e1-b1f8-a95f87c6e3da,7eeb0a52-be0f-47b7-bb79-f0169b73be73,c283addf-9f07-49d5-a452-4f6da08effb5,620ec338-819c-49ac-8ddb-5a536c7b313d,d8b20572-c0fa-452a-bae0-fd5d42bc3a71,5c5b7706-33d8-446f-970b-cd7786916d31,66d753c7-4f2c-4d2e-b25f-c375b7ce01a0,63630a44-bb38-45e3-9745-a40b3a05a998,73ea2a04-924f-4c92-9b69-e2d3eb86bcee,be5d46ef-089c-4a1a-81b6-ff7d58637dec,31463fd8-3aab-4282-85ee-c96b760fab61,e99211c8-d5d9-4ede-9152-34933036c3a9,e445c9aa-fbad-42a7-88a7-ccb23473c1c8,9ca57b4d-d0c3-4fd3-9893-c5afdfa28a17,0bc3206f-bf49-46cc-a726-1a79ecdcc7c2,8066af3b-0d94-427f-9b72-b8e41be26d0e,ef46efc0-eb12-4224-9d0a-3509d649a41a,afe9d476-7407-4695-a656-3fd8ce6893fd,a9b4314d-1b90-44fa-9127-468dd8e7d078,bee0070a-7eb6-4851-b764-0553afa7d9ab,dee6a05b-e5fb-4024-9ba6-5f0218158ac8,f2824762-1695-4122-bab7-4eb2d6def765,4aa4e065-ec99-4098-a902-b3472191073b,1b40bf5b-31e4-42a3-918f-b6677ccb294b,3a7c8b34-abdb-493e-bb26-977da4846adb,3f4bd46a-b5a4-47ab-875e-1dbd0256dbc0,116d3035-b748-4db5-9c95-558f28dbbf21,477fdeae-ccff-4a5f-923a-e36af8060cc7,54823bf3-2de1-4509-a5f9-f4df7a8118eb,d3abafd9-26e0-4440-9ee3-e4bfa9fdd5f8,b7b79668-6556-4eec-acb2-a753443595b8,16308809-0efb-4708-a3ab-2c6853eab11d,079bee45-2fb3-4a00-b07f-717826a41ed8,e61da3e6-b4bf-4157-85e0-21ef01ab2ba4,7287d618-f642-413e-8bc4-07462d2f6f58,61ea1047-3c95-43cc-8c64-e413a17c22d9,87e0e4ed-6c2d-4397-95b1-db51b4cf7bd1,de0b3656-0b34-450c-9999-7525fbe9e377,9dd5d0ff-f494-4b2a-a506-1ddcbb05ac24,03aefcff-13fa-4541-b526-cbae652a66c3,2e953b9c-3120-4337-ac1e-3267b5356b31,36734bcf-e494-48ee-bbda-384fef37d257,393d24ce-5c1a-40ce-827d-a641e4c3fdac,830248d8-dbfb-4406-81b7-366fc32b7804,f2e15d96-90c7-4bd3-b57b-c253906a87a5,4f27da0e-e321-4614-869d-056153acc7e0,2e0c9988-7579-44ac-8f0f-f5b28dd426a3,19a7a0f3-f238-4db9-8d69-21faf8b46c33,a9f9cac9-6423-4d08-9b65-f5f79139ff70,564dda7b-8977-4d34-a354-0b6ab675f9bf,18c020a4-ed59-4baa-8642-71f71c0480f4,98b89567-d42c-423e-95e6-647a57356413,07e94c6d-ae83-41ee-bcef-aaab7fc0f1d9,a061b6c7-3d4c-4735-9778-8a265af57b49,0508b2c0-d0b1-455f-9c15-439f21e6816a,f3bcdfad-4ed0-4caa-86f2-bc2a1665098f,aca03783-7720-40d0-aec0-b6147ed1de40,05c6016b-d1bd-408d-a358-bd218407732e,6c541693-2cda-4477-b6f6-496c1a23d8fe,745cc5ac-5b5e-4193-8b86-ca1fc86a05a4,8277930c-08cf-4856-b7c0-628765c13554,f85586e4-f39e-4eca-a447-79729d8bc30e,7ac3f544-4855-4500-82db-e774aee82fe0,0e2873e6-f154-4db2-b1ba-59cc5023bdf3,e410fc3d-592a-487d-8748-200227d63b65,484c0b99-9941-4fae-8d7b-435e8ac45574,8c3ba019-7e35-445e-ad14-29d60b7dca23,1aa69118-149b-41ef-832c-d5479ae9969e,235a3abf-a117-498e-aaa7-a6f8fc3ebad8,ebd9ee41-89ea-4afe-94e9-9c3cd3aa3e88,f962804d-61c7-4fe3-9435-c881ec8d39b0,7a88394c-8d3f-496d-8f70-1a95d6b87078,090a91f0-f4f2-4198-8e40-391fd1ee6952,8ae2aba7-c7ce-426d-89df-7dbf2f6dd102,5df38b28-588b-49be-9ae3-18416ce18267,b884aff2-fe85-4f10-8b83-3ebea86125b4,41f4eb9c-d6fb-4f61-b689-0a9e64901728,73f813cc-65a8-4b6c-84ab-fbe4e556b5a8,7007668d-e500-4f8e-be80-1532b487a7c2,61dbf1f3-b658-4e82-b3e4-fdb2c06800cb,4207b986-8d37-48b1-8e15-e899f5f0e36b,3c701b30-15b7-4a41-80cb-3d0daccef7e0,d4df3432-6bad-4118-b0e3-2fc497a9af1c,78853112-507c-473d-9865-f96cae6c30c8,5a3aaa2e-5ab8-40d5-b4ea-48088ca9c2d2,e151a7f6-0846-4fef-8de2-289d83931697,38cca48d-9d8d-4eb3-ac41-374b2d53bb57,ed9cf55f-a4b8-4e3e-9189-339ff8c78d51,b16dafe0-a781-4e56-96c3-45e7bc7120b1,d26b955b-2a0c-4461-b3be-a8c845fdc3b5,4905c32a-375a-4fe4-aa0e-30d14f738585,9250e454-f54a-4b74-991a-fd0c2e6b214e,334c1059-b5d3-497a-a1d9-389d25732db6,460e75cd-fdc3-4e01-8031-c45a13ee48c2,a2a96949-2d6d-45c4-ad34-497019e7e6d0,9e58b82f-f6f6-431d-9cbb-b611608bf55f,53089b64-4f73-4268-b4e4-d30280fbe01e,36f07185-5eba-41df-886e-971c26f729ad,4816bbbb-41e0-4e1f-96ea-4f4c6da2b5f6,fea680aa-6abf-4bca-8891-02cf6ba44f77,88b98585-2476-4d38-95a2-f46a919d5d23,ec5fe734-ece2-4d4c-ad68-72a5c1925b3b,c7a075af-98a3-4a71-8c96-df97eec2ce6a,bf3caa34-c7f9-468b-9f2b-92b83c5ec5f9,2c687328-bd78-4649-addf-3b8a4213655f,fbc47d1d-8e8c-4f9e-b783-294384389680,e933db4d-a684-4a1d-92a5-00232769f948,26d0da51-eacd-43e5-8aab-c15519089f08,2a43a5cb-99fe-4e8d-a2ba-c3626aaf58e1,1c34d870-af27-4a9e-9d16-606696fc745e,588f5f10-48f4-45c4-8f6a-7a2dd1cc1873,70268337-fd16-4f72-80d2-36e35afd2a9f,e1b1fa6f-f241-400b-9e60-39ec80c43399,4e89be1b-c88b-4e07-bad4-06bc04629c3b,17b55851-c4d7-4397-9ba3-6033ae7ff74c,2315c835-a360-4140-b4c2-bb73f8e64d50,2b7a0fa6-3651-4e49-aa4c-be3126a96ef7,771f6927-bb2c-4746-8dd3-b12e6de0a404,a714b4ba-caf9-42e7-ad3f-51c299581405,3de5f698-c291-46c0-bc4b-09d0ab3d4f05,c3cd5d54-5757-4fea-8b36-ea2e1ab91be9,26fac7ae-49c9-468d-ada6-451e98b3c3af,38352d0f-6624-406e-a98e-a8bc595cd033,fef93e16-b7ea-40d3-b19e-a119c7af1606,cba12230-438e-407d-947a-30768a33a1c8,89321566-4bfb-4bb9-b991-3e735bc76f12,057fb205-0cbd-4cdf-be19-797158f3cbe6,4aee5cf3-d8b6-4609-9c26-3173b8b25083,4be1c89f-1d54-4baa-9a5f-98172ed97906,74bf192a-91cc-4235-998e-65f1c0e7ac66,e7e671ed-a310-409e-9317-e63cf58a44f3,c56f4e32-c78a-4697-a9dc-ae54a1d4acfd,277aec84-69e4-4f73-8b79-6e9e7f0a009c,6a3cdcb4-7cf5-421a-93fa-9a8092c59186,02929c28-02c6-4fd3-8c63-e5a2b406fbe9,13554702-1a3a-4e2c-840e-d51690462d06,57901cce-fb77-4997-8b4b-f297b1548e92,e55b8213-0cd7-4f97-94f4-2e279b94e983,3f682336-9b3d-4a63-a380-8ae2a83e8797,ccdfb681-a077-4d35-94bf-26abfb322b1a,ab7e72f3-81dc-4853-9739-99034c2cc427,c06c6721-9d07-4307-9d0f-142fa6dd926d,db816cef-b934-46f2-aa2f-48a77db28549,305a494e-cc7a-4394-8d45-27e0f1411fee,66e6bbfb-2985-4b9d-99d1-6214c58fccdb,c9279e31-3c40-4181-b855-76ad7ed9e318,b4253acd-dbfd-4e5a-9aa3-15eae88243ec,e397c7c6-512d-4388-a053-33407da6df3c,0fb10160-28a2-4e2b-964a-d3a5d4212b78,b4c2473a-273c-4f35-bec3-8244703dbf3c,d3603d55-ffea-44d9-9bb1-ab940708d358,652895e7-404a-4277-a7b8-b3ee0f57b4fb,068dcd71-bf4e-402b-9975-32123f2875a4,8c691573-33c9-4cfd-8cf1-4b6e6557e255,7623f715-71bd-4b79-ba79-4977f68fb05d,a87a1e3e-2536-409e-b981-d4ae97a11b40,1141507f-cfb8-4345-9786-efa7564c2ea9,8f3b32f9-eba6-4400-8e19-0455e0d2fa6a,43d07eb0-e160-4f95-8dac-18901b6a9d9a,5cf7e5f3-ea04-4fa4-92e5-eeafbc4c9f43,929d65f1-36c9-4af4-929a-96bdb479097b,3839c319-d892-4a99-ab6c-13b1bdcf691d,9639cf48-5085-499b-92cb-3cd35e2822d0,d83f5310-a780-42fa-94cf-111e4254b5a1,86a15b8c-9011-4ecf-91c9-d37917a36eb9,13f47d3f-0e15-428f-8d93-5c7176f7dad5,13de4e9c-5421-4b86-a81f-eba7983d1a28,0013a3ff-813e-491b-b2cf-8d853f8312d3,781b8fa8-f904-46c0-8a39-ac14df37e297,752fe88c-e1c7-404b-93d6-084cff8dfdc0,d66373c8-1c43-41c4-b2b5-813fb2b28fdb,5cd6c191-81f5-4a79-bced-447163a03cb1,d15cb909-0850-4733-9cf1-04db1a60f75a,273a088b-7bff-4bd7-a800-6619c6d43a60,8236b3e9-9f2b-4311-aa22-73581881ff89,4a25949a-60d2-49cb-8a14-21b842e27b1f,78bde46f-000c-4bfb-a857-0c2f71815a98,00f4bd4d-69bd-4945-8ce3-11e4baa7377d,15f6a338-e3bf-4b8b-b328-a47204bd4678,89a3e670-8c81-4125-8a60-cf29a9b43c38,361f5656-2632-4625-aa28-9eb2d1f1b326,deff69ac-b8f5-4e8b-a509-6d072100edac,5d382fd2-0d8d-4e0a-bb62-41dc61c1b3aa,9d4b0819-61d4-4a9f-8538-787f9b417af3,86f68b9e-9ebc-4af9-bec4-fc108b0efb3c,ca4a358c-55f6-4831-b11e-4fa4697b8406,cc1fc0e9-a664-4f2d-8727-05b487c26bee,91ced201-9460-4fc4-87a7-6e7afb3aaf84,e967668d-1ce4-426a-aa24-dcbd7cc0045d,0493cc71-1e53-4a82-906c-0bfdddffa25e,24cb46fd-56de-4112-8656-eb973c39c65c,a91f3665-7ec3-45c8-8953-bb7cbb18509c,d8416d91-53cc-402a-b017-f3534d05a536,ef4c71a9-b97b-426f-87ec-c06984c11d16,cc933286-26eb-4239-b240-fedd0a781c99,faac998f-5ff9-4c58-8614-a0214952c0f6,b5e12c0f-d1f6-45b7-ab69-67f3258a5aba,dd8bfd44-3894-4651-80a1-a49810247a95,24845f88-70d0-4c1a-96ce-bd742588aea4,18f419f9-f0c9-4392-aa33-ca6b317a8a68,ca0166df-e6c9-4599-a316-81a9c72c66d6,562d0193-bcaf-4f3b-9436-08f79fc6a83d,4dc5f6ce-9642-4d4b-a58f-e5e85f3fce53,f0c5747b-a104-444d-b15a-9aa50ebf92ea,956cd149-04e3-42a3-9db0-2fdf8d4b03c5,84efd25a-8953-4ddb-997b-1c9d9248b589,a03b0853-c972-43ed-836a-162febe75972,b656536e-f752-4837-91d9-1b2856909a53,57780ebb-8e35-4273-8612-07546b17c591,dbbe77b6-4358-49d7-a924-d6e40cde79f0,19e8a885-0269-4204-bfa0-aab36195dee6,b7f99b3c-336e-475b-9177-c2e7e80c3fc9,8de6402e-1358-414e-913d-21a9f17b5548,5a443ce0-fb10-4ce2-b605-acba80d82885,66ef363a-5660-4295-89ce-48e7c0a98a2f,5df0d120-00fa-4890-816c-c0685c6eec47,ef9aea7e-5ae4-407d-bc78-0486bd13de42,26d593d7-262e-4db5-954d-73dbd8ba8a6c,a406202d-eca7-43c6-a1f6-de04f9e2120e,d5801d70-022d-4ed2-8299-3136ef55b4b9,4cd38b18-f94e-47cd-a18c-56879f2504a6,94b37663-1dc9-4183-984a-c0f84ac2d77a,41abfdd0-0a4d-4adb-a719-78ebb664c39a,dfba1102-7ac4-4077-9857-170addbdaeb7,06c4bbdb-905d-4112-bc27-5fa5e2f4bdc2,bf5f279e-d2d0-43ed-9dac-af2afbc6a599,68f9502f-7b8b-4739-b1ca-bd2da0194ab3,3f47576e-1fdd-4ae3-a73c-1710e210cd35,9707db2c-be6e-4674-b665-2109ddc2e180,5bdc2420-9c4f-45e6-8620-83c28572f212,6c5789ff-7694-4623-8117-8e292eb6eb6b,edf0f9be-5da1-4225-8c3d-573274622a25,eff7da76-f235-4224-b58d-1a4c32cd1812,e64b61b8-682b-47ba-88f6-8420fae14279,c30a40ce-3c37-4a47-804b-11765e783efd,601e3ac3-f8b4-43aa-9b23-6d9541d96e5d,27cfbc14-60b4-4ca6-9810-8fff0f339a0c,45424361-57b9-4343-b4ee-9f4b6c221bb1,8443ca30-f3c2-4574-92dc-29830f20bf7c,c2e0d271-68f3-4c3f-970f-c7f66df544fc,79b59c07-31ba-442e-acdc-590a200b1ea8,913b5674-b022-4bb8-9924-e3f3d5acfec3,4470e2f5-1ded-45c1-b7af-3ee435a7c506,4e7d5bda-ced3-4d37-a197-dcec01278f32,ca1c6403-c72e-4836-a69f-27a9a2c60db8,c1909701-b468-4146-8ad1-552c9b178b29,50ae75f3-78c1-49e5-a47b-028b145107ad,162af62a-57f0-4dd7-9db7-51eeefeae831,d8a2d761-acfe-435b-8847-27d541ac1ee5,dc7947a5-e7d6-4eed-a37c-0db483b670dd,1c87f197-3e16-4fcc-a4af-ac86b78cd297,a788d62f-3ca2-4985-849a-5bcf8fb13ab1,b3c242a7-9d42-4bbf-99ed-00d5e739d769,be3c9720-ae0c-4c39-9e57-2a0dc98fb82f,02e29229-5a1a-4f50-847c-d750b807d0e3,ef97fe83-3635-4718-b554-2969912050af,becf7a98-4a87-43a6-8659-6a95a42abf52,502fdb78-ec90-454f-86e3-55d20ee11daa,b436b073-1700-414c-b5d2-9b17b9e5521f,590f7f26-653a-4410-a66b-a814c4be4794,17bb675c-cb46-4dab-9cb6-7a64daf91cc8,aa6c8163-cd01-475e-8d2d-54bc5edcf077,e67c5f8b-10db-4427-9dc1-011807024dd6,f562a871-1037-49d5-9d12-5b707b32063b,9d0f410e-bcc6-4c17-8324-c817df60d289,2bcdc0c6-103f-4d4a-9dd1-5c467bd39e34,bc72287d-e601-46e6-a0d8-f9a1386abcfe,cbccfbf1-1f18-4503-8118-8b4315e9c115,6e758ceb-2e3f-4d16-b8bd-c97dca8696d5,3f5cb1c4-d59f-4d26-b21b-42f238043f2c,491c6f96-4470-495c-887f-9750f287b0a0,7e832b3d-11aa-417e-ba61-cb6d3c27cc66,327b3150-d68e-4588-aede-d183e849f9d4,dadc62c0-835c-47c4-931e-f84f3e5c8b6c,87f2c25b-1712-4567-9a9b-5ae6d853deb9,3f365817-24c4-444f-be2c-e513e9f62691,253a8bb7-c928-4ba3-9d1d-8e1f289188b8,005edd5a-926c-4813-bd6b-287ae4a91ddb,c9ccc939-8cb5-44e9-97f3-43197cac7d2e'

--Declare @Tenantid bigint=1,@AsOf DateTime='2019-11-27 00:00:00',@Nature Varchar(50)='Trade,Other',@ServiceEntity Varchar(200)='2,3,4,5,6,7,8,9',@Currency Varchar(100)='Base Currency',@DocCurrency Varchar(100)=NULL

CREATE PROCEDURE [dbo].[BC_Customer_GRID_Aging_InvoiceUncheck]

@Tenantid bigint,
@AsOf DateTime,
@Customer NVarchar(MAX),
@Nature Varchar(50),
@ServiceEntity Varchar(200),
@DocCurrency Varchar(100),
@Currency VARCHAR(100)
AS
Begin
--Declare @Tenantid INT=244,@AsOf DateTime=GetDate(),@Customer Varchar(MAX)='94738faa-97b4-45db-b34f-0b8970e218b5,19402f30-f746-4b0b-8e4d-0d72ce1675c7,a9925319-f359-4b1f-8022-0e59bd836542,6454219e-a905-4acc-9e94-393a5650dba1,5bc6b5a3-ed90-41f9-860f-6775e003a892',
--@Nature Varchar(50)='Trade,Others',@ServiceEntity Varchar(50)='810,847,848,849,850,974,975,980,1114',@Currency Varchar(50)='Doc Currency',@DocCurrency Varchar(100)='SGD,USD'


Declare  @Customer_TBL Table (Customer uniqueidentifier)
Insert INTO @Customer_TBL 
select Distinct items from dbo.SplitToTable(@Customer,',')

Declare  @Nature_TBL Table (Nature NVarchar(200))
Insert INTO @Nature_TBL 
select Distinct items from dbo.SplitToTable(@Nature,',')

Declare  @ServEnt_TBL Table (ServEntity NVarchar(200))
Insert INTO @ServEnt_TBL 
select Distinct items from dbo.SplitToTable(@ServiceEntity,',')

Declare  @Transaction Table (DocumentId uniqueidentifier)
Insert INTO @Transaction 
select Distinct DocumentId from Bean.DocumentHistory(NoLock) where CompanyId=@Tenantid AND DocType='Debt Provision' 

Declare  @Transaction_DP Table (DocumentId uniqueidentifier)
Insert INTO @Transaction_DP 
Select Distinct DocumentId from Bean.DocumentHistory(NoLock) Where CompanyId=@Tenantid And DocType='Debt Provision' And DocSubType='Allocation'


SELECT Id, [Name] INTO #entity FROM Bean.entity(NOLOCK)
WHERE CompanyId = @Tenantid

SELECT Id, CompanyId INTO #COA FROM Bean.ChartOfAccount(NOLOCK)
WHERE CompanyId = @Tenantid

Set @AsOf = DATEADD(day, DATEDIFF(day, 0, @AsOf), '23:59:59')

DECLARE @Aging Nvarchar(100)
SET @Aging = (SELECT 'DocumentHistory into Temp Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

	SELECT Id,DocumentId,DocType,TransactionId,DocAppliedAmount,BaseAppliedAmount,DocState,PostingDate,Companyid,AgingState
	INTO #AgingDocumentHistory
	FROM Bean.DocumentHistory(NOLOCK)
	WHERE  CompanyId = @Tenantid AND DocState IS NOT NULL AND (AgingState <>'Deleted' OR AgingState IS NULL) AND PostingDate <= @AsOf 

SET @Aging = (SELECT 'DocumentHistory into Temp Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @Aging = (SELECT 'Journal into Temp Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

	SELECT J.Id, j.DocNo, j.DocType, CAST(J.DueDate AS Date) AS DueDate,  J.ServiceCompanyId, J.IsAddNote, J.Nature,J.EntityId,
	DATEDIFF (day,J.DueDate,@AsOf ) AS [Days]--- ,De.Name, com.ShortName
	INTO #Journal
	FROM @Customer_TBL AS Cust
	INNER JOIN Bean.journal J (NOLOCK) ON Cust.Customer = J.EntityId
	WHERE J.CompanyId = @Tenantid AND J.DocumentState NOT IN ('Void')
		AND J.DocType IN ('Invoice', 'Debit Note', 'Receipt', 'Cash Sale', 'Debt Provision', 'Credit Note') 

SET @Aging = (SELECT 'Journal into Temp Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @Aging = (SELECT 'Master Journal into Temp Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;
	SELECT J.*,DE.[Name], com.ShortName
	INTO #MasterJournal
	FROM #Journal AS J
	INNER JOIN @Nature_TBL As Ntr On Ntr.Nature = J.Nature
	INNER JOIN #entity AS DE on J.EntityId = de.Id
	INNER JOIN Common.Company com (NOLOCK) ON J.ServiceCompanyId = com.Id
	INNER JOIN @ServEnt_TBL AS Ser ON Ser.ServEntity = com.Id
SET @Aging = (SELECT 'Master Journal into Temp Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @Aging = (SELECT 'JournalDetail  into Temp Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;
	SELECT  DISTINCT JournalId,JD.DocType,Jd.DocDate, Jd.DocCurrency, JD.DocType AS JDDocType, Jd.DocumentId, Jd.DocSubType,Jd.COAId,JD.BaseCurrency,k.PostingDate,k.DocState,
		Jd.DocumentDetailId,ISNULL(K.BaseAppliedAmount,0) AS BaseAppliedAmount,ISNULL(K.DocAppliedAmount,0) AS DocAppliedAmount,CNA.InvoiceId ,DDA.InvoiceId AS DDAInvoiceId,
		Jd.ClearingStatus
	INTO #JournalDetail
	FROM  Bean.JournalDetail JD (NOLOCK) 
	INNER JOIN #AgingDocumentHistory AS K ON K.DocumentId = Jd.DocumentId  AND K.TransactionId NOT IN (SELECT DocumentId FROM @Transaction)
	INNER JOIN #COA (NoLock) as c on c.Id=Jd.COAId
	LEFT JOIN Bean.CreditNoteApplication As CNA (NOLOCK) On CNA.Id=Jd.DocumentId
	LEFT JOIN Bean.DoubtfulDebtAllocation As DDA (NOLOCK) On DDA.Id=Jd.DocumentId
	WHERE JournalId IN ( SELECT Id FROM #Journal) AND c.CompanyId = @Tenantid AND K.PostingDate  <= @AsOf 
		AND K.DocState in ('Partial Applied','Fully Applied','Not Applied','Not Paid','Partial Paid','Fully Paid')
		AND (Jd.ClearingStatus <> ('Cleared') OR Jd.ClearingStatus IS NULL)
		AND Jd.DocumentDetailId = '00000000-0000-0000-0000-000000000000'
SET @Aging = (SELECT 'JournalDetail  into Temp Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @Aging = (SELECT 'Creating Index StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;
	CREATE NONCLUSTERED INDEX JournalId_HashJournalDetail ON #JournalDetail (JournalId) INCLUDE (DocType,DocDate,DocCurrency,DocumentId,DocSubType,COAId,BaseCurrency)
SET @Aging = (SELECT 'Creating Index EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @Aging = (SELECT 'AgingCTE StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;
--->>> AgingCTE
	SELECT  J.[Name],Jd.DocDate, j.DocNo, Jd.DocCurrency, j.DocType,JD.DocType AS JDDocType, Jd.DocumentId, J.DueDate, J.ServiceCompanyId,Jd.DocSubType, J.IsAddNote, J.Nature,
			J.EntityId, Jd.COAId,jd.BaseCurrency,JD.BaseAppliedAmount,JD.DocAppliedAmount,[Days],
			JD.InvoiceId ,JD.DDAInvoiceId, J.ShortName,
			Case When J.DocType IN ('Credit Note') Then ISNULL(BaseAppliedAmount,0)*(-1) Else ISNULL(BaseAppliedAmount,0) End as DaysAmount
	INTO #AgingCTE
	FROM #MasterJournal J 
	JOIN #JournalDetail JD ON J.Id = JD.JournalId
	WHERE JD.PostingDate  <= @AsOf 
	AND JD.DocState in ('Partial Applied','Fully Applied','Not Applied','Not Paid','Partial Paid','Fully Paid')
	AND (Jd.ClearingStatus <> ('Cleared') OR Jd.ClearingStatus IS NULL)
	AND Jd.DocumentDetailId = '00000000-0000-0000-0000-000000000000'	

SET @Aging = (SELECT 'AgingCTE EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @Aging = (SELECT 'Invoice into Temp Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;
--->>> Invoice
	SELECT 
		de.[Name],I.DocDate,I.DocNo,I.DocCurrency, I.DocType, k.DocType AS KDocType,com.ShortName,I.Id, I.ServiceCompanyId,I.DocSubType,I.DueDate,
		ISNULL(K.BaseAppliedAmount,0) AS BaseAppliedAmount, ISNULL(K.DocAppliedAmount,0) AS DocAppliedAmount, COOO,
		DATEDIFF (day,I.DueDate,@AsOf ) AS [Days],k.TransactionId,K.DocState,
		CASE WHEN I.DocType IN ('Credit Note') THEN ISNULL(K.BaseAppliedAmount,0)*(-1) ELSE CASE WHEN I.DocType IN ('Invoice') THEN ISNULL(K.BaseAppliedAmount,0) ELSE 0 END END AS [DaysAmount],
		CASE WHEN I.DocType IN ('Credit Note') THEN  ISNULL(K.DocAppliedAmount,0)*(-1) ELSE CASE WHEN I.DocType IN ('Invoice') THEN ISNULL(K.DocAppliedAmount,0) ELSE 0 END End AS [DocDaysAmount]
	INTO #InvoiceCustomersAging
	FROM Bean.Invoice(NOLOCK) I
	INNER JOIN Bean.InvoiceDetail(NOLOCK) ID ON ID.InvoiceId = I.Id
	JOIN @Nature_TBL AS Ntr ON Ntr.Nature = I.Nature
	JOIN #entity(NOLOCK) de ON I.EntityId = de.Id
	JOIN @Customer_TBL AS Cust ON Cust.Customer = De.Id
	JOIN Common.Company(NOLOCK) com ON I.ServiceCompanyId = com.Id
	JOIN @ServEnt_TBL AS Ser ON Ser.ServEntity = com.Id
	JOIN #COA(NOLOCK) AS c ON c.Id = Id.COAId
	LEFT JOIN ( SELECT Count(Id) AS COOO, InvoiceId FROM Bean.InvoiceNote GROUP BY InvoiceId ) AS N ON N.InvoiceId = I.Id
	INNER JOIN #AgingDocumentHistory AS K ON K.DocumentId = I.Id
	WHERE I.CompanyId = @Tenantid AND C.CompanyId = @Tenantid AND K.PostingDate <= @AsOf 
		AND I.DocumentState NOT IN ('Void')
		AND I.DocType IN ('Invoice', 'Credit Note','Debt Provision')
		AND I.DocSubType IN ('Opening Bal') 
		AND I.IsOBInvoice = 1	
SET @Aging = (SELECT 'Invoice into Temp Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;

SET @Aging = (SELECT 'Journal into Temp Table StartTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;
--->>> Journal
	SELECT 
		de.[Name], '' ELimit, J.DocDate,K.TransactionId,K.DocType AS KDocType,J.DocType as JDocType,J.DocNo,J.DocCurrency,com.ShortName,J.DocSubType,DDA.InvoiceId,
		J.DocumentId,ISNULL(K.BaseAppliedAmount,0) as BaseAppliedAmount,ISNULL(K.DocAppliedAmount,0) AS DocAppliedAmount,J.PostingDate,ServiceCompanyId,
		DATEDIFF (day,J.DocDate,@AsOf ) AS [Days],J.DocumentState
	INTO #JournalCustomerAging
	FROM Bean.Journal J (NOLOCK)
	JOIN #entity de ON J.EntityId = de.Id
	JOIN @Customer_TBL AS Cust ON Cust.Customer = De.Id
	JOIN @Nature_TBL AS Ntr ON Ntr.Nature = J.Nature
	JOIN Common.Company com (NOLOCK) ON J.ServiceCompanyId = com.Id
	JOIN @ServEnt_TBL AS Ser ON Ser.ServEntity = com.Id
	INNER JOIN #AgingDocumentHistory AS K ON K.DocumentId = J.DocumentId 
	LEFT JOIN Bean.DoubtfulDebtAllocation AS DDA (NOLOCK) ON DDA.Id = J.DocumentId
	WHERE K.DocState NOT IN ('Void') 
	AND K.PostingDate <= @AsOf 
		AND J.DocType IN ('Debt Provision', 'Invoice', 'Debit Note') 
SET @Aging = (SELECT 'Journal into Temp Table EndTime'+' '+CAST(CAST(GETDATE() AS TIME)AS NVARCHAR(30)))
PRINT @Aging;


IF @Currency='Base Currency'--Base
BEGIN


	Select Name, Currency
	--, ELimit, DocDate, DocNo, DocType, ShortName,DocumentId,,BalanceAmount
	, Cast(SUM([Current])as decimal(18,2)) [Current], Cast(Sum([1 to 30])as decimal(18,2)) [1 to 30]
		,Cast(SUM([31 to 60])as decimal(18,2)) [31 to 60],Cast(SUM([61 to 90])as decimal(18,2)) [61 to 90],Cast(SUM([91 to 120])as decimal(18,2))
		 [91 to 120],Cast(SUM([> 120])as decimal(18,2)) [> 120],Cast(SUM(ISNULL(DocBalanceAmount,0))as decimal(18,2)) DocBalanceAmount,
		--Cast(SUM([Current])+Sum([1 to 30]) +SUM([31 to 60]) +SUM([61 to 90])+SUM([91 to 120]) +SUM([> 120])as decimal(18,2))  
		CAST( SUM(ISNULL(BaseBalanceAmount,0))as decimal(18,2))  AS BaseBalanceAmount
		
	From
	(
		SELECT 
			J.[Name], '' ELimit, J.DocDate, j.DocNo, J.DocCurrency AS Currency, j.DocType, J.ShortName, 
			CASE WHEN (J.JDDocType = 'Credit Note' AND j.DocSubType = 'Application') THEN J.InvoiceId 
				WHEN (J.JDDocType = 'Debt Provision' AND j.DocSubType = 'Allocation') THEN J.DDAInvoiceId ELSE J.DocumentId END AS DocumentId, 
			CASE WHEN J.DocType IN ('Credit Note') THEN SUM(ISNULL(j.BaseAppliedAmount, 0)) * (- 1) ELSE SUM(ISNULL(j.BaseAppliedAmount, 0)) END 'BaseBalanceAmount', 
			CASE WHEN J.JDDocType IN ('Credit Note') THEN SUM(ISNULL(j.DocAppliedAmount, 0)) * (- 1) ELSE SUM(ISNULL(j.DocAppliedAmount, 0)) END DocBalanceAmount, 
			CASE WHEN [Days] <= 0 THEN SUM(DaysAmount) ELSE 0 END AS 'Current', 
			CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM(DaysAmount) ELSE 0 END AS '1 to 30', 
			CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM(DaysAmount) ELSE 0 END AS '31 to 60', 
			CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM(DaysAmount) ELSE 0 END AS '61 to 90', 
			CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM(DaysAmount) ELSE 0 END AS '91 to 120', 
			CASE WHEN [Days] > 120 THEN SUM(DaysAmount) ELSE 0 END AS '> 120', 
			J.ServiceCompanyId, J.DocSubType, J.DueDate
		FROM #AgingCTE J
		WHERE J.DocType IN ('Invoice', 'Debit Note', 'Credit Note') 
		GROUP BY J.DocDate, j.DocNo, J.DocCurrency, J.DueDate, J.DocSubType, j.DocNo, j.ShortName, J.DocumentId, J.DocType, J.ServiceCompanyId, 
			J.InvoiceId, J.DDAInvoiceId, [Days], J.[Name], JDDocType

		Union All

		SELECT 
			[Name], '' ELimit, I.DocDate, I.DocNo, I.DocCurrency AS Currency, I.DocType, I.ShortName, I.Id AS DocumentId, 
			CASE WHEN I.DocType IN ('Credit Note') THEN Sum(ISNULL(I.BaseAppliedAmount, 0)) * (- 1) ELSE SUM(ISNULL(I.BaseAppliedAmount, 0)) END 'BalanceAmount', 
			CASE WHEN I.DocType IN ('Credit Note') THEN SUM(ISNULL(I.DocAppliedAmount, 0)) * (- 1) ELSE SUM(ISNULL(I.DocAppliedAmount, 0)) END DocBalanceAmount, 
			CASE WHEN [Days] <= 0 THEN SUM([DaysAmount]) ELSE 0 END AS 'Current',
			CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM([DaysAmount]) ELSE 0 END AS '1 to 30',
			CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM([DaysAmount]) ELSE 0 END AS '31 to 60', 
			CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM([DaysAmount]) ELSE 0 END AS '61 to 90', 
			CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM([DaysAmount]) ELSE 0 END AS '91 to 120', 
			CASE WHEN [Days] > 120 THEN SUM([DaysAmount]) ELSE 0 END AS '> 120', 
			I.ServiceCompanyId, I.DocSubType, I.DueDate
		FROM #InvoiceCustomersAging I
		WHERE I.DocState IN ('Partial Applied', 'Fully Applied', 'Not Applied', 'Not Paid', 'Partial Paid', 'Fully Paid') 
		AND I.DocType IN ('Invoice', 'Credit Note')
		GROUP BY I.[Name], I.DocDate, I.DocNo, I.DocCurrency, I.DueDate, I.DocType, I.DocNo, [Days], I.DocType, I.ShortName, I.Id, I.DocType, I.ServiceCompanyId, 
		I.DocSubType, I.DueDate



Union ALL


		SELECT [Name], '' ELimit, DocDate, 
			CASE 
				WHEN KDocType = 'Invoice' THEN (( SELECT DISTINCT I.DocNo FROM Bean.Invoice(NOLOCK) I INNER JOIN Bean.DocumentHistory(NOLOCK) D ON D.TransactionId = I.Id WHERE D.DocumentId = j.TransactionId) + ' (' + (J.DocNo) + ')')
				WHEN KDocType = 'Debit Note' THEN ( SELECT DISTINCT I.DocNo FROM Bean.Invoice(NOLOCK) I INNER JOIN Bean.DocumentHistory(NOLOCK) D ON D.TransactionId = I.Id WHERE D.DocumentId = j.TransactionId) + ' (' + (J.DocNo) + ')'
			ELSE J.Docno 
			END Docno, 
			DocCurrency AS Currency, 'Debt Provision' AS DocType, ShortName, 
			CASE WHEN (JDocType = 'Debt Provision' AND DocSubType = 'Allocation') THEN InvoiceId ELSE DocumentId END AS DocumentId, 
			CASE WHEN JDocType IN ('Debt Provision') AND DocSubType IN ('General') THEN SUM(BaseAppliedAmount) * (- 1) ELSE SUM(BaseAppliedAmount) * (- 1) END AS BaseBalanceAmount, 
			CASE WHEN JDocType IN ('Debt Provision') AND DocSubType IN ('General') THEN SUM(DocAppliedAmount) * (- 1) ELSE SUM(DocAppliedAmount) * (- 1) END AS DocBalanceAmount,
			CASE WHEN [Days] <= 0 THEN SUM(DaysAmount) ELSE 0 END AS 'Current', 
			CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM(DaysAmount) ELSE 0 END AS '1 to 30',
			CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM(DaysAmount) ELSE 0 END AS '31 to 60', 
			CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM(DaysAmount) ELSE 0 END AS '61 to 90',
			CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM(DaysAmount) ELSE 0 END AS '91 to 120', 
			CASE WHEN [Days] > 120 THEN SUM(DaysAmount) ELSE 0 END AS '> 120', 
			ServiceCompanyId, DocSubType, PostingDate as DueDate
		FROM 
			(	SELECT *,CASE WHEN JDocType IN ('Debt Provision') AND DocSubType IN('General') THEN ISNULL(BaseAppliedAmount,0)*(-1) ELSE ISNULL(BaseAppliedAmount,0)*(-1) END AS DaysAmount
				FROM #JournalCustomerAging 
				WHERE KDocType IN ('Debit Note', 'Invoice') AND TransactionId IN (SELECT DocumentId FROM @Transaction_DP )
			) AS J
		GROUP BY [Days],[Name], DocDate, DocNo, KDocType, DocumentId, DocCurrency, PostingDate, DocSubType, jDocType, ShortName, DocumentId, ServiceCompanyId, TransactionId, InvoiceId


		 --) As A
		 --Group By DocNo

Union All
---------------------------------------------------------------------------------------------------------------------------------------------
		SELECT [Name], '' ELimit, I.DocDate,  CASE WHEN KDocType = 'Invoice' THEN 
					(SELECT DISTINCT I2.DocNo  FROM Bean.Invoice(NOLOCK) I2  INNER JOIN Bean.DocumentHistory(NOLOCK) D 
					 ON D.TransactionId = I2.Id   WHERE D.DocumentId = I.TransactionId) + ' (' + I.DocNo + ')' ELSE I.DocNo 
			END AS DocNo, 
			 I.DocCurrency AS Currency, 'Debt Provision' AS DocType, I.ShortName, I.Id AS DocumentId, 
			 SUM(I.BaseAppliedAmount) * (- 1) 'BalanceAmount',
			 SUM(I.DocAppliedAmount) * (- 1) DocBalanceAmount, 
			 CASE WHEN [Days] <= 0 THEN SUM(I.BaseAppliedAmount) * (- 1) ELSE 0 END AS 'Current',
			 CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM(I.BaseAppliedAmount) * (- 1) ELSE 0 END AS '1 to 30', 
			 CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM(I.BaseAppliedAmount) * (- 1) ELSE 0 END AS '31 to 60',
			 CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM(I.BaseAppliedAmount) * (- 1) ELSE 0 END AS '61 to 90',
			 CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM(I.BaseAppliedAmount) * (- 1) ELSE 0 END AS '91 to 120',
			 CASE WHEN [Days] > 120 THEN SUM(I.BaseAppliedAmount) * (- 1) ELSE 0 END AS '> 120', 
			 I.ServiceCompanyId, I.DocSubType, I.DueDate
		FROM #InvoiceCustomersAging AS I
		WHERE I.DocType IN ('Invoice','Debt Provision') AND I.DocState NOT IN ('Void') 
			AND kDocType IN ('Debit Note','Invoice') AND TransactionId IN (SELECT DocumentId FROM @Transaction_DP)
		GROUP BY I.Id,[Name], I.DocDate, I.DocNo, I.DocCurrency, I.DueDate, DocType, I.DocNo, [Days], ShortName, I.ServiceCompanyId, I.DocSubType, I.DueDate, I.TransactionId, KDocType


UNION ALL
------------------------------------------------------------------------------------------------------------------
		SELECT [Name], '' ELimit, J.DocDate,
			CASE WHEN KDocType = 'Invoice' THEN (J.DocNo + ' (' + (SELECT DocNo FROM Bean.Invoice(NOLOCK) WHERE Id = J.DocumentId ) + ')' )
				 WHEN KDocType = 'Debit Note' THEN J.DocNo + ' (' + ( SELECT DocNo FROM Bean.DebitNote(NOLOCK) WHERE Id = J.DocumentId) + ')' 
				 ELSE J.Docno 
			END Docno, 
			J.DocCurrency AS Currency, J.JDocType, J.ShortName,
			CASE WHEN (J.JDocType = 'Debt Provision' AND J.DocSubType = 'Allocation') THEN J.InvoiceId ELSE J.DocumentId END AS DocumentId, 
			CASE WHEN J.JDocType IN ('Debt Provision') AND J.DocSubType IN ('General') THEN SUM(J.BaseAppliedAmount) * (- 1) ELSE SUM(J.BaseAppliedAmount) END AS BaseBalanceAmount, 
			CASE WHEN J.JDocType IN ('Debt Provision') AND J.DocSubType IN ('General') THEN SUM(J.DocAppliedAmount) * (- 1) ELSE SUM(J.DocAppliedAmount) END AS DocBalanceAmount, 
			CASE WHEN [Days] <= 0 THEN SUM(DaysAmount) ELSE 0 END AS 'Current',
			CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM(DaysAmount) ELSE 0 END AS '1 to 30', 
			CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM(DaysAmount) ELSE 0 END AS '31 to 60', 
			CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM(DaysAmount) ELSE 0 END AS '61 to 90', 
			CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM(DaysAmount) ELSE 0 END AS '91 to 120', 
			CASE WHEN [Days] > 120 THEN SUM(DaysAmount) ELSE 0 END AS '> 120', 
			J.ServiceCompanyId, J.DocSubType, J.PostingDate DueDate
		FROM (
				SELECT *, CASE WHEN JDocType IN ('Debt Provision') AND DocSubType IN ('General') THEN ISNULL(BaseAppliedAmount, 0) * (- 1) ELSE ISNULL(BaseAppliedAmount, 0) * (- 1) END AS DaysAmount
				FROM #JournalCustomerAging
				WHERE JDocType IN ('Debt Provision') AND DocSubType NOT IN ('Allocation') AND DocumentState NOT IN ('Void')
			) AS J
		GROUP BY [Days],J.[Name], J.DocDate, j.DocNo, J.KDocType, J.DocumentId, DocDate, J.DocCurrency, J.PostingDate, J.DocSubType, J.JDocType, J.ShortName, J.DocumentId, J.ServiceCompanyId, J.InvoiceId
		  

	) AS a
	WHERE ISNULL(BaseBalanceAmount,0) <>0 AND ISNULL(DocBalanceAmount,0) <>0
	Group By Name, Currency
	ORDER BY Name, Currency
End

Else


IF @Currency='Doc Currency'
BEGIN

	Select Name, Currency
	--, ELimit, DocDate, DocNo, DocType, ShortName,DocumentId,,BalanceAmount
	, Cast(SUM([Current])as decimal(18,2)) [Current], Cast(Sum([1 to 30])as decimal(18,2)) [1 to 30]
		,Cast(SUM([31 to 60])as decimal(18,2)) [31 to 60],Cast(SUM([61 to 90])as decimal(18,2)) [61 to 90],Cast(SUM([91 to 120])as decimal(18,2))
		 [91 to 120],Cast(SUM([> 120])as decimal(18,2)) [> 120],
		 Cast(SUM(IsNULL(DocBalanceAmount,0))as decimal(18,2)) DocBalanceAmount,
		--Cast(SUM([Current])+Sum([1 to 30]) +SUM([31 to 60]) +SUM([61 to 90])+SUM([91 to 120]) +SUM([> 120])as decimal(18,2))  AS DocBalanceAmount,
		Cast(SUM(ISNULL(BaseBalanceAmount,0))as decimal(18,2)) BaseBalanceAmount
		
	From
	(
		SELECT 
			J.[Name], '' ELimit, J.DocDate, j.DocNo, J.DocCurrency AS Currency, j.DocType, J.ShortName, 
			CASE WHEN (J.JDDocType = 'Credit Note' AND j.DocSubType = 'Application') THEN J.InvoiceId 
				WHEN (J.JDDocType = 'Debt Provision' AND j.DocSubType = 'Allocation') THEN J.DDAInvoiceId ELSE J.DocumentId END AS DocumentId, 
			CASE WHEN J.JDDocType IN ('Credit Note') THEN SUM(ISNULL(j.DocAppliedAmount, 0)) * (- 1) ELSE SUM(ISNULL(j.DocAppliedAmount, 0)) END DocBalanceAmount, 
			CASE WHEN J.DocType IN ('Credit Note') THEN SUM(ISNULL(j.BaseAppliedAmount, 0)) * (- 1) ELSE SUM(ISNULL(j.BaseAppliedAmount, 0)) END 'BaseBalanceAmount', 		
			CASE WHEN [Days] <= 0 THEN SUM(DaysAmount) ELSE 0 END AS 'Current', 
			CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM(DaysAmount) ELSE 0 END AS '1 to 30', 
			CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM(DaysAmount) ELSE 0 END AS '31 to 60', 
			CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM(DaysAmount) ELSE 0 END AS '61 to 90', 
			CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM(DaysAmount) ELSE 0 END AS '91 to 120', 
			CASE WHEN [Days] > 120 THEN SUM(DaysAmount) ELSE 0 END AS '> 120', 
			J.ServiceCompanyId, J.DocSubType, J.DueDate
		FROM #AgingCTE J
		WHERE J.DocType IN  ('Invoice', 'Debit Note', 'Receipt', 'Cash Sale', 'Debt Provision', 'Credit Note') 
		AND J.DocCurrency IN (SELECT items FROM dbo.SplitToTable(@DocCurrency, ','))
		GROUP BY J.DocDate, j.DocNo, J.DocCurrency, J.DueDate, J.DocSubType, j.DocNo, J.ShortName, J.DocumentId, J.DocType, J.ServiceCompanyId, 
			J.InvoiceId, J.DDAInvoiceId, [Days], J.[Name], JDDocType

	UNION ALL

	SELECT 
		[Name], '' ELimit, I.DocDate, I.DocNo, I.DocCurrency AS Currency, I.DocType, I.ShortName, I.Id AS DocumentId, 
		CASE WHEN I.DocType IN ('Credit Note') THEN SUM(ISNULL(I.DocAppliedAmount, 0)) * (- 1) ELSE SUM(ISNULL(I.DocAppliedAmount, 0)) END DocBalanceAmount, 
		CASE WHEN I.DocType IN ('Credit Note') THEN Sum(ISNULL(I.BaseAppliedAmount, 0)) * (- 1) ELSE SUM(ISNULL(I.BaseAppliedAmount, 0)) END 'BalanceAmount', 
		CASE WHEN [Days] <= 0 THEN SUM([DocDaysAmount]) ELSE 0 END AS 'Current',
		CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM([DocDaysAmount]) ELSE 0 END AS '1 to 30',
		CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM([DocDaysAmount]) ELSE 0 END AS '31 to 60', 
		CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM([DocDaysAmount]) ELSE 0 END AS '61 to 90', 
		CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM([DocDaysAmount]) ELSE 0 END AS '91 to 120', 
		CASE WHEN [Days] > 120 THEN SUM([DocDaysAmount]) ELSE 0 END AS '> 120', 
		I.ServiceCompanyId, I.DocSubType, I.DueDate
	FROM #InvoiceCustomersAging I
	WHERE I.DocState IN ('Partial Applied', 'Fully Applied', 'Not Applied', 'Not Paid', 'Partial Paid', 'Fully Paid') 
		AND I.DocType IN ('Invoice', 'Credit Note')
		AND I.DocCurrency IN (SELECT items FROM dbo.SplitToTable(@DocCurrency, ','))
	GROUP BY I.[Name], I.DocDate, I.DocNo, I.DocCurrency, I.DueDate, I.DocType, I.DocNo, [Days], I.DocType, I.ShortName, I.Id, I.DocType, I.ServiceCompanyId, 
	I.DocSubType, I.DueDate

	UNION ALL 

	SELECT [Name], '' ELimit, DocDate, 
		CASE 
			WHEN KDocType = 'Invoice' THEN (( SELECT DISTINCT I.DocNo FROM Bean.Invoice(NOLOCK) I INNER JOIN Bean.DocumentHistory(NOLOCK) D ON D.TransactionId = I.Id WHERE D.DocumentId = j.TransactionId) + ' (' + (J.DocNo) + ')')
			WHEN KDocType = 'Debit Note' THEN ( SELECT DISTINCT I.DocNo FROM Bean.Invoice(NOLOCK) I INNER JOIN Bean.DocumentHistory(NOLOCK) D ON D.TransactionId = I.Id WHERE D.DocumentId = j.TransactionId) + ' (' + (J.DocNo) + ')'
		ELSE J.Docno 
		END Docno, 
		DocCurrency AS Currency, 'Debt Provision' AS DocType, ShortName, 
		CASE WHEN (JDocType = 'Debt Provision' AND DocSubType = 'Allocation') THEN InvoiceId ELSE DocumentId END AS DocumentId, 
		CASE WHEN JDocType IN ('Debt Provision') AND DocSubType IN ('General') THEN SUM(DocAppliedAmount) * (- 1) ELSE SUM(DocAppliedAmount) * (- 1) END AS DocBalanceAmount,
		CASE WHEN JDocType IN ('Debt Provision') AND DocSubType IN ('General') THEN SUM(BaseAppliedAmount) * (- 1) ELSE SUM(BaseAppliedAmount) * (- 1) END AS BaseBalanceAmount, 
		CASE WHEN [Days] <= 0 THEN SUM(DaysAmount) ELSE 0 END AS 'Current', 
		CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM(DaysAmount) ELSE 0 END AS '1 to 30',
		CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM(DaysAmount) ELSE 0 END AS '31 to 60', 
		CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM(DaysAmount) ELSE 0 END AS '61 to 90',
		CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM(DaysAmount) ELSE 0 END AS '91 to 120', 
		CASE WHEN [Days] > 120 THEN SUM(DaysAmount) ELSE 0 END AS '> 120', 
		ServiceCompanyId, DocSubType, PostingDate asDueDate
	FROM 
		(	SELECT *,CASE WHEN JDocType IN ('Debt Provision') AND DocSubType IN('General') THEN ISNULL(DocAppliedAmount,0)*(-1) ELSE ISNULL(DocAppliedAmount,0)*(-1) END AS DaysAmount
			FROM #JournalCustomerAging 
			WHERE KDocType IN ('Debit Note', 'Invoice') AND TransactionId IN (SELECT DocumentId FROM @Transaction_DP ) 
				AND DocCurrency IN (SELECT items FROM dbo.SplitToTable(@DocCurrency,',')) 
		) AS J
	GROUP BY [Days],[Name], DocDate, DocNo, KDocType, DocumentId, DocCurrency, PostingDate, DocSubType, jDocType, ShortName, DocumentId, ServiceCompanyId, TransactionId, InvoiceId

	UNION ALL

	SELECT [Name], '' ELimit, I.DocDate,  CASE WHEN KDocType = 'Invoice' THEN 
				(SELECT DISTINCT I2.DocNo  FROM Bean.Invoice(NOLOCK) I2  INNER JOIN Bean.DocumentHistory(NOLOCK) D 
				 ON D.TransactionId = I2.Id   WHERE D.DocumentId = I.TransactionId) + ' (' + I.DocNo + ')' ELSE I.DocNo 
		END AS DocNo, 
		 I.DocCurrency AS Currency, 'Debt Provision' AS DocType, I.ShortName, I.Id AS DocumentId, 
		 SUM(I.BaseAppliedAmount) * (- 1) 'BalanceAmount',
		 SUM(I.DocAppliedAmount) * (- 1) DocBalanceAmount, 
		 CASE WHEN [Days] <= 0 THEN SUM(I.DocAppliedAmount) * (- 1) ELSE 0 END AS 'Current',
		 CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM(I.DocAppliedAmount) * (- 1) ELSE 0 END AS '1 to 30', 
		 CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM(I.DocAppliedAmount) * (- 1) ELSE 0 END AS '31 to 60',
		 CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM(I.DocAppliedAmount) * (- 1) ELSE 0 END AS '61 to 90',
		 CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM(I.DocAppliedAmount) * (- 1) ELSE 0 END AS '91 to 120',
		 CASE WHEN [Days] > 120 THEN SUM(I.DocAppliedAmount) * (- 1) ELSE 0 END AS '> 120', 
		 I.ServiceCompanyId, I.DocSubType, I.DueDate
	FROM #InvoiceCustomersAging AS I
	WHERE I.DocType IN ('Invoice','Debt Provision') AND I.DocState NOT IN ('Void') 
		AND kDocType IN (/*'Debit Note',*/'Invoice') AND TransactionId IN (SELECT DocumentId FROM @Transaction_DP)
	  AND  I.DocCurrency in (select items from dbo.SplitToTable(@DocCurrency,','))
	GROUP BY I.Id,[Name], I.DocDate, I.DocNo, I.DocCurrency, I.DueDate, DocType, I.DocNo, [Days], ShortName, I.ServiceCompanyId, I.DocSubType, I.DueDate, I.TransactionId, KDocType

	UNION ALL

	SELECT [Name], '' ELimit, J.DocDate,
		CASE WHEN KDocType = 'Invoice' THEN (J.DocNo + ' (' + (SELECT DocNo FROM Bean.Invoice(NOLOCK) WHERE Id = J.DocumentId ) + ')' )
			 WHEN KDocType = 'Debit Note' THEN J.DocNo + ' (' + ( SELECT DocNo FROM Bean.DebitNote(NOLOCK) WHERE Id = J.DocumentId) + ')' 
			 ELSE J.Docno 
		END Docno, 
		J.DocCurrency AS Currency, J.JDocType, J.ShortName,
		CASE WHEN (J.JDocType = 'Debt Provision' AND J.DocSubType = 'Allocation') THEN J.InvoiceId ELSE J.DocumentId END AS DocumentId,
		CASE WHEN J.JDocType IN ('Debt Provision') AND J.DocSubType IN ('General') THEN SUM(J.DocAppliedAmount) * (- 1) ELSE SUM(J.DocAppliedAmount) END AS DocBalanceAmount, 
		CASE WHEN J.JDocType IN ('Debt Provision') AND J.DocSubType IN ('General') THEN SUM(J.BaseAppliedAmount) * (- 1) ELSE SUM(J.BaseAppliedAmount) END AS BaseBalanceAmount, 	
		CASE WHEN [Days] <= 0 THEN SUM(DaysAmount) ELSE 0 END AS 'Current',
		CASE WHEN [Days] BETWEEN 1 AND 30 THEN SUM(DaysAmount) ELSE 0 END AS '1 to 30', 
		CASE WHEN [Days] BETWEEN 31 AND 60 THEN SUM(DaysAmount) ELSE 0 END AS '31 to 60', 
		CASE WHEN [Days] BETWEEN 61 AND 90 THEN SUM(DaysAmount) ELSE 0 END AS '61 to 90', 
		CASE WHEN [Days] BETWEEN 91 AND 120 THEN SUM(DaysAmount) ELSE 0 END AS '91 to 120', 
		CASE WHEN [Days] > 120 THEN SUM(DaysAmount) ELSE 0 END AS '> 120', 
		J.ServiceCompanyId, J.DocSubType, J.PostingDate DueDate
	FROM (
			SELECT *, CASE WHEN JDocType IN ('Debt Provision') AND DocSubType IN ('General') THEN ISNULL(DocAppliedAmount, 0) * (- 1) ELSE ISNULL(DocAppliedAmount, 0) * (- 1) END AS DaysAmount
			FROM #JournalCustomerAging
			WHERE JDocType IN ('Debt Provision') AND DocSubType NOT IN ('Allocation')
				AND DocCurrency IN (SELECT items FROM dbo.SplitToTable(@DocCurrency,',')) 
		) AS J
	GROUP BY [Days],J.[Name], J.DocDate, j.DocNo, J.KDocType, J.DocumentId, DocDate, J.DocCurrency, J.PostingDate, J.DocSubType, J.JDocType, J.ShortName, J.DocumentId, J.ServiceCompanyId, J.InvoiceId

	) AS a
	WHERE ISNULL(BaseBalanceAmount,0) <>0 AND ISNULL(DocBalanceAmount,0) <>0
	--WHERE Cast(ISNULL(DocBalanceAmount,0)as decimal(18,2)) <> 0.00 AND CAST( ISNULL(BaseBalanceAmount,0)as decimal(18,2)) <> 0.00 
	--Where Case When ELimit='' then 'Not Exceeded' ELSE  'Exceeded' End in (select items from dbo.SplitToTable(@CreditLimit,','))
	Group By Name, Currency
	--, ELimit, DocDate, DocNo, DocType, ShortName,DocumentId,BalanceAmount

	ORDER BY Name, Currency
End

END






GO
