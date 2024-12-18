USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[ReOpenOpportunity_StateChange_SP]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ReOpenOpportunity_StateChange_SP]  -- EXEC [dbo].[ReOpenOpportunity_StateChange_SP] 689,'fa36a65b-d962-41c2-865a-983c0c438d33,aa3eccc8-9f79-45b8-9e4e-64d49158cb8d','john Ho' ,200       
 @CompanyId Int ,        
 @OpportunityId Nvarchar(Max) ,        
 @User Nvarchar(200) ,        
 --@Fee Decimal(32,18),  
 @IsReopen bit  
      
AS        
BEGIN        
        
    set @User =( select Top 1 FirstName from common.CompanyUser where Username=@User and companyId=@companyId)  
Declare  @Opportunity_TBL Table (Opportunity uniqueidentifier)        
Insert INTO @Opportunity_TBL         
select Distinct items from dbo.SplitToTable (@OpportunityId,',')        
        
DECLARE @TempTable TABLE        
(        
 id uniqueidentifier,        
 Name Nvarchar(Max),        
 AccountId Uniqueidentifier,        
 OpportunityNumber Nvarchar(200),        
 ServiceCode Nvarchar(200),        
 ServiceGroupCode Nvarchar(200),        
 AutoNumberCode Nvarchar(200),        
 QuoteNumber Nvarchar(200),        
 MainServiceId Bigint,        
 SubServiceId Bigint,        
 MainServiceFee Decimal(10,9),        
 SubServiceFee  Decimal(10,9),        
 KeyTemplateName Nvarchar(200),        
 ServiceGroupId bigint,        
 KeyTermsTemplateId uniqueidentifier,        
 KeyTermsContent Nvarchar(Max),        
 RecurringScopeofWork Nvarchar(4000),        
 TargettedRecovery Float,        
 IsAdHoc bit,        
 IsRecurring bit,        
 IsAdditionalSettings Bit,        
 IsMonthly Bit,        
 IsQuarterly Bit,        
 IsSemiAnnually Bit,        
 IsAnnually Bit,        
 AssuranceResignationDate datetime2,        
 PrecedingAuditor Nvarchar(Max),        
 SucceedingAuditor Nvarchar(Max),        
 ReasonForResignation Nvarchar(Max),        
 FeeType Nvarchar(200),        
 Nature Nvarchar(200),        
 --Fee Decimal (10,2),        
 DefaultTemplateId uniqueidentifier,        
 QuotationId Uniqueidentifier        
)        
        
        
DECLARE Migration_Cursor Cursor        
        
FOR        
        
SELECT         
 Opportunity         
FROM         
 @Opportunity_TBL         
        
        
        
OPEN Migration_Cursor        
        
        
FETCH NEXT FROM Migration_Cursor INTO @OpportunityId        
        
        
        
WHILE @@FETCH_STATUS = 0        
BEGIN        
        
---===============================================================================================================----        
        
DECLARE         
 @NextToDate DATETIME2,        
 @NextFromDate DATETIME2,        
 @ReOpeningDate DATETIME2,        
 @Frequency Nvarchar(100),        
 @StandardTemplateContent NVARCHAR(Max),        
 @QuotationId Uniqueidentifier,        
 @ErrorMessage1 Nvarchar(max),        
 @ErrorMessage2 Nvarchar(max),        
 @ErrorMessage3 Nvarchar(max),        
 @Default bit = 1,        
 @NewReOpenDate datetime2        
        
       
DECLARE @OppAuto nvarchar(250) = ( SELECT GeneratedNumber FROM Common.AutoNumber AS A WHERE  A.EntityType = 'Opportunity' AND A.CompanyId = @companyId )   
  
DECLARE @OppAutoLength nvarchar(250) = ( SELECT CounterLength FROM Common.AutoNumber AS A WHERE  A.EntityType = 'Opportunity' AND A.CompanyId = @companyId )   
  
Declare @NextAutoNumber nvarchar(250) =(select (SUBSTRING ( @OppAuto ,(CHARINDEX ( '-' ,@OppAuto)+1) ,(@OppAutoLength-LEN(CAST(SUBSTRING ( @OppAuto ,CHARINDEX ( '-' ,@OppAuto)+1,LEN(@OppAuto)) as int))))+CAST(CAST(SUBSTRING ( @OppAuto ,CHARINDEX ( '-' ,@OppAuto)+1,LEN(@OppAuto)) as int)+1 as varchar)) )  
  
DECLARE @QuoAuto nvarchar(250) = ( SELECT GeneratedNumber FROM Common.AutoNumber AS A WHERE  A.EntityType = 'Quotation' AND A.CompanyId = @CompanyId )  
  
DECLARE @QuoAutoLength nvarchar(250) = ( SELECT CounterLength FROM Common.AutoNumber AS A WHERE  A.EntityType = 'Quotation' AND A.CompanyId = @CompanyId )  
  
declare @NextQuoteAutoNumber nvarchar(250) = (select (SUBSTRING ( @QuoAuto ,(CHARINDEX ( '-' ,@QuoAuto)+1) ,(@QuoAutoLength-LEN(CAST(SUBSTRING ( @QuoAuto ,CHARINDEX ( '-' ,@QuoAuto)+1,LEN(@QuoAuto)) as int))))+CAST(CAST(SUBSTRING ( @QuoAuto ,CHARINDEX ( '
-' ,@QuoAuto)+1,LEN(@QuoAuto)) as int)+1 as varchar)) )  
    
DECLARE @OppFormat Nvarchar(200) = ( SELECT Format FROM Common.AutoNumber AS A WHERE  A.EntityType = 'Opportunity' AND A.CompanyId = @CompanyId )   
DECLARE @QuoFormat Nvarchar(100) = ( SELECT Format FROM Common.AutoNumber AS A WHERE  A.EntityType = 'Quotation' AND A.CompanyId = @CompanyId )     
    
DECLARE @OpLetters Nvarchar(100) = (SELECT LEFT(@OppFormat, CHARINDEX('-',@OppFormat)-1))    
DECLARE @QuoLetters Nvarchar(100) = (SELECT LEFT(@QuoFormat, CHARINDEX('-',@QuoFormat)-1))    
    
    
    
INSERT INTO @TempTable         
 SELECT         
  OPP.Id,        
  OPP.Name,        
  OPP.AccountId,        
  OPP.OpportunityNumber,          
  S.Code AS ServiceCode,        
  SG.Code AS ServiceGroupCode,  
  (select (replace(replace(replace(replace(@OppFormat, '{SERVICEGROUP}', sg.code), '{SERVICE}', s.code), '{YYYY}', CAST(YEAR(GETDATE()) AS Nvarchar(10))),'{MM/YYYY}',CAST(Month(GETDATE()) AS Nvarchar(10))+'/'+CAST(YEAR(GETDATE()) AS Nvarchar(10)))+@NextAutoNumber) AutoNumberCode),  
  
  --CASE     
  -- WHEN @OppFormat LIKE '%-{SERVICEGROUP}-%' THEN @OpLetters+'-'+SG.Code+'/'+s.Code+'-'+CAST(YEAR(GETDATE()) AS Nvarchar(10))+'-'+ '0' +CONVERT(varchar(100), (@OppAuto +1))     
  -- WHEN @OppFormat LIKE '%-{MM/YYYY}-%' THEN @OpLetters+'-'+'0'+CAST(Month(GETDATE()) AS Nvarchar(10))+'/'+CAST(YEAR(GETDATE()) AS Nvarchar(10))+'-'+ '0' +CONVERT(varchar(100), (@OppAuto +1))    
  -- WHEN @OppFormat LIKE '%-{YYYY}-%' THEN @OpLetters+'-'+CAST(YEAR(GETDATE()) AS Nvarchar(10)) + '-'+ '0' +CONVERT(varchar(100), (@OppAuto +1))    
  -- --WHEN @OppFormat = 'OPP-{SERVICEGROUP}-' THEN 'OPP'+'-'+SG.Code+'-'+'0' +CONVERT(varchar(100), (@OppAuto +1))    
  -- --WHEN @OppFormat = 'OP-{SERVICEGROUP}{SERVICE}-{YYYY}-' THEN 'OP-'+SG.Code+S.Code+'-'+CAST(YEAR(GETDATE()) AS Nvarchar(10)) + '-'+ '0' +CONVERT(varchar(100), (@OppAuto +1))    
  -- --WHEN @OppFormat = 'OP-{SERVICEGROUP}/{SERVICE}-{YYYY}-' THEN 'OP-'+SG.Code+ '/'+S.Code+'-'+CAST(YEAR(GETDATE()) AS Nvarchar(10)) + '-'+ '0' +CONVERT(varchar(100), (@OppAuto +1))     
  --END AS AutoNumberCode,      
      
  
  CASE   
  WHEN @QuoFormat LIKE '%-{MM/YYYY}-%' THEN @QuoLetters+'-'+'0'+CAST(Month(GETDATE()) AS Nvarchar(10))+'/'+CAST(YEAR(GETDATE()) AS Nvarchar(10))+'-'+@NextQuoteAutoNumber    
   WHEN @QuoFormat LIKE '%-{YYYY}-%' THEN @QuoLetters+'-'+CAST(YEAR(GETDATE()) AS Nvarchar(10))+'-'+@NextQuoteAutoNumber  
     
  END AS QuoteNumber,        
  CASE WHEN S.IsSplitEnable = 1  THEN S.MainServiceId ELSE NULL END AS MainServiceId,        
  CASE WHEN S.IsSplitEnable = 1  THEN S.SubServiceId ELSE NULL END AS SubServiceId,        
  CASE WHEN S.IsSplitEnable = 1  THEN OPP.Fee ELSE NULL END AS MainServiceFee,        
  CASE WHEN S.IsSplitEnable = 1  THEN 0 ELSE NULL END AS SubServiceFee,        
  CASE WHEN CAST(S.KeyTermsTemplateId AS Nvarchar(100)) NOT IN (NULL, '') THEN GT.Name ELSE '' END AS KeyTemplateName,        
  S.ServiceGroupId,        
  S.KeyTermsTemplateId,        
  S.KeyTermsContent,        
  S.RecurringScopeofWork,        
  S.TargettedRecovery,        
  S.IsAdHoc,        
  S.IsRecurring,        
  S.IsAdditionalSettings,        
  S.IsMonthly,        
  S.IsQuarterly,        
  S.IsSemiAnnually,        
  S.IsAnnually,        
  CASE WHEN OPP.IsAdditionalSettings IS NOT Null AND OPP.IsAdditionalSettings = 1 THEN OPP.AssuranceResignationDate ELSE NULL End As AssuranceResignationDate,        
  CASE WHEN OPP.IsAdditionalSettings IS NOT Null AND OPP.IsAdditionalSettings = 1 THEN OPP.PrecedingAuditor ELSE NULL End As PrecedingAuditor,        
  CASE WHEN OPP.IsAdditionalSettings IS NOT Null AND OPP.IsAdditionalSettings = 1  THEN OPP.SucceedingAuditor ELSE NULL End As SucceedingAuditor,        
  CASE WHEN OPP.IsAdditionalSettings IS NOT Null AND OPP.IsAdditionalSettings = 1  THEN OPP.ReasonForResignation ELSE NULL End As ReasonForResignation,        
  CASE         
   WHEN S.IsFixesFeeType = 1 THEN  'Fixed'        
   WHEN S.IsVariableFeeType = 1 THEN  'Variable'        
   WHEN S.IsFixesFeeType = 1 AND S.IsVariableFeeType = 1 THEN  'Fixed'        
  END AS FeeType,        
  CASE         
   WHEN S.IsRecurring = 1 THEN  'Recurring'        
   WHEN S.IsAdHoc = 1 THEN  'AdHoc'        
   WHEN S.IsRecurring = 1 AND S.IsAdHoc = 1 THEN  'Recurring'        
  END AS Nature,        
  --@Fee as Fee,        
  S.DefaultTemplateId,        
  NEWID() as QuotationId        
          
 FROM ClientCursor.Opportunity AS OPP        
  INNER JOIN Common.Service AS S        
   ON S.Id = OPP.ServiceId        
  INNER JOIN Common.ServiceGroup AS SG        
   ON SG.Id = OPP.ServiceGroupId        
  LEFT JOIN Common.GenericTemplate AS GT        
   ON GT.Id = S.KeyTermsTemplateId        
  JOIN (SELECT A.Id,A.ServiceId,A.CompanyId,a.CreatedDate,        
      ROW_NUMBER() OVER (ORDER BY A.CreatedDate DESC) AS RowNumber        
     FROM Common.CompanyService AS A        
       JOIN ClientCursor.Opportunity AS O        
      ON O.ServiceId = A.ServiceId AND O.Id = @OpportunityId        
     ) AS CS        
   ON CS.ServiceId = OPP.ServiceId           
  WHERE OPP.Id = @OpportunityId AND RowNumber = 1        
        
  declare @Autonumber nvarchar(200)  
set @Autonumber = (select AutoNumbercode from @TempTable WHERE id = @OpportunityId)  
      
SET @QuotationId = (SELECT QuotationId FROM @TempTable WHERE id = @OpportunityId)        
--> START        
IF EXISTS (SELECT * FROM @TempTable WHERE IsRecurring = 1 and id = @OpportunityId)        
 BEGIN        
 SET @Frequency = (        
  SELECT        
   CASE         
    WHEN IsMonthly = 1 THEN 'Monthly'        
    WHEN IsQuarterly = 1 THEN 'Quarterly'        
    WHEN IsSemiAnnually = 1 THEN 'SemiAnnually'        
    WHEN IsAnnually = 1 THEN 'Annually'        
   END AS Frequency        
  FROM @TempTable        
  WHERE        
   id = @OpportunityId        
  )        
        
IF  EXISTS (SELECT ToDate FROM ClientCursor.Opportunity WHERE Id = @OpportunityId)        
 BEGIN        
  ----========================================== NextFromDate ========================================================----        
  SET @NextFromDate  = ( SELECT DATEADD(DD,1,op.ToDate)  AS NextFromDate         
              FROM ClientCursor.Opportunity AS OP        
            WHERE OP.Id = @OpportunityId        
                )        
  ----========================================== NextToDate ======================================================----        
        
  DECLARE @ServiceRecurring Table  (   OppId Uniqueidentifier,Id BigInt, ServiceId BigInt, Frequency Nvarchar(100), FromToDate Nvarchar(200),        
           OperatorSymbol Nvarchar(20), NoOfDays BigInt, Period Nvarchar(50), Status Int, ToDate DateTime2)        
        
  INSERT INTO @ServiceRecurring  --------------> Inserting Service Recurring Setting Data into Temp Table        
        
   SELECT OP.Id,SRS.Id, SRS.ServiceId, SRS.Frequency, SRS.FromToDate, SRS.OperatorSymbol,        
       SRS.NoOfDays, SRS.Period,SRS.Status, OP.ToDate          
   FROM ClientCursor.Opportunity AS OP        
    INNER JOIN Common.Service AS SE        
     ON SE.Id = OP.ServiceId        
    INNER JOIN Common.ServiceRecuringSettings AS SRS        
     ON SRS.ServiceId = SE.Id AND OP.Frequency = SRS.Frequency        
   WHERE OP.Id = @OpportunityId  AND SRS.Id = (SELECT MAX(SRS.Id) AS Id        
              FROM ClientCursor.Opportunity AS OP        
                 INNER JOIN Common.Service AS SE        
                  ON SE.Id = OP.ServiceId        
                 INNER JOIN Common.ServiceRecuringSettings AS SRS        
                  ON SRS.ServiceId = SE.Id AND OP.Frequency = SRS.Frequency        
                WHERE OP.Id = @OpportunityId )--'c2d26fc1-5ae5-4f98-bb7a-f0c12a56ec8a'        
    GROUP BY OP.Id,SRS.Id, SRS.ServiceId, SRS.Frequency, SRS.FromToDate, SRS.OperatorSymbol, SRS.NoOfDays, SRS.Period,SRS.Status,op.ToDate        
           
        
---========================================================================================================================-----        
        
        
    IF   EXISTS (SELECT ID FROM @ServiceRecurring WHERE CAST(Frequency AS nvarchar(20))  <> '' AND Frequency IS NOT NULL AND OppId = @OpportunityId)        
     BEGIN        
      SET @NextToDate  =        
        (SELECT         
         CASE         
          WHEN @Frequency = 'Monthly' THEN (DATEADD(DD,-1,DATEADD(MONTH,1,@NextFromDate)))        
          WHEN @Frequency = 'Quarterly' THEN (DATEADD(DD,-1,DATEADD(MONTH,3,@NextFromDate)))        
          WHEN @Frequency = 'SemiAnnually' THEN (DATEADD(DD,-1,DATEADD(MONTH,6,@NextFromDate)))        
          WHEN @Frequency = 'Annually' THEN (DATEADD(DD,-1,DATEADD(YEAR,1,@NextFromDate)))        
         END AS NextToDate               
        )             
      ----==================================================================================================----        
        
      DECLARE @CalDate DateTime2= (SELECT CASE WHEN FromToDate = 'From Date_New Service Period' THEN @NextFromDate        
               ELSE ToDate        
               END AS CalDate        
           FROM @ServiceRecurring WHERE OppId = @OpportunityId)        
          
      DECLARE @FirstDayOfMonth DateTime2 = (SELECT CONVERT(DATE,DATEADD(DD,-(DAY(@CalDate)-1),@CalDate)) )        
      DECLARE @LastDayOfMonth DateTime2 = (SELECT DATEADD(DD,-1,DATEADD(MONTH,1,@FirstDayOfMonth))) --(SELECT DATEADD(S,-1,DATEADD(MM,DATEDIFF(M,0,@CalDate)+1,0)))         
        
        
        
      ----==================================================================================================----        
      IF EXISTS (SELECT Id FROM @ServiceRecurring WHERE NoOfDays IS NOT NULL AND OppId = @OpportunityId )--AND Period = 'Month')        
       BEGIN        
        IF EXISTS (SELECT Id FROM @ServiceRecurring WHERE Period = 'Months' AND OppId = @OpportunityId)        
         BEGIN        
          SET @ReOpeningDate  = (SELECT        
                 CASE         
                  WHEN OperatorSymbol = '+' THEN DATEADD(MM,+NoOfDays,@CalDate)        
                  WHEN OperatorSymbol = '-' THEN DATEADD(MM,-NoOfDays,@CalDate)        
                 END AS ReOpeningDate        
                FROM @ServiceRecurring WHERE OppId = @OpportunityId        
                )        
        
          IF (@CalDate = @LastDayOfMonth)        
          BEGIN        
           DECLARE @FirstDayOfMonth1 DateTime2 = (SELECT CONVERT(DATE,DATEADD(DD,-(DAY(@NextFromDate)-1),@NextFromDate)) )        
           DECLARE @LastDayOfMonth1 DateTime2 = (SELECT DATEADD(DD,-1,DATEADD(MONTH,1,@FirstDayOfMonth1)))         
           SET @ReOpeningDate = (SELECT @LastDayOfMonth1)        
          END        
         END        
        ELSE        
         BEGIN        
          SET @ReOpeningDate = (SELECT        
                 CASE         
                  WHEN OperatorSymbol = '+' THEN DATEADD(DD,+NoOfDays,@CalDate)        
                  WHEN OperatorSymbol = '-' THEN DATEADD(DD,-NoOfDays,@CalDate)        
                 END AS ReOpeningDate        
                  FROM @ServiceRecurring WHERE OppId = @OpportunityId        
                 )        
         END        
             
       END        
       ELSE         
        BEGIN        
         SET @ReOpeningDate = (SELECT CASE WHEN FromToDate = 'From Date_New Service Period' THEN @NextFromDate        
                 ELSE @NextToDate        
                  END AS ReOpeningDate        
                FROM @ServiceRecurring WHERE OppId = @OpportunityId        
                )        
        END        
        
     END        
        
    ELSE        
     BEGIN        
      SET @NextToDate = ( SELECT DATEADD(DD,1,@NextFromDate) )        
      SET @ReOpeningDate = ( SELECT DATEADD(DD,1,op.FromDate)  AS ReopeningDate         
            FROM ClientCursor.Opportunity AS OP        
             WHERE OP.Id = @OpportunityId        
            )        
                    
                     
     END        
  END        
 END        
ELSE        
BEGIN        
 SET @Frequency = NULL        
 SET @NextToDate = NULL        
 SET @NextFromDate= NULL        
 SET @ReOpeningDate= NULL        
        
END        
     
   if(@IsReopen=1)  
   begin  
UPDATE Common.AutoNumber        
 SET GeneratedNumber =  @NextAutoNumber        
WHERE        
 EntityType = 'Opportunity' AND CompanyId = @CompanyId        
    
UPDATE Common.AutoNumber        
 SET GeneratedNumber =  @NextQuoteAutoNumber        
WHERE        
 EntityType = 'Quotation' AND CompanyId = @CompanyId     
 end  
        
        
------=========================================================== UPDATE NEW REOPEN RECORD IN OPPORTUNITY TABLE =========================================================================================        
        
BEGIN TRANSACTION Reopen        
        
BEGIN TRY   
  
if(@IsReopen=1)  
Begin  
 IF EXISTS (SELECT CreatedId FROM ClientCursor.ReopenOpportunityHistory WHERE CreatedId IS NULL AND TranactionId = @OpportunityId)        
        
 UPDATE A        
  SET        
   QuoteNumber = 'ReOpened',        
   Type = 'ReOpen',        
   Stage = 'Created',        
   UserCreated = @User,        
   CreatedDate = GETDATE(),         
   OpportunityNumber = AA.AutoNumberCode,       
   ReOpen = A.ReOpeningDate  
   --NextFromDate = @NextFromDate,    
   --NextToDate = @NextToDate    
  FROM        
   ClientCursor.Opportunity A        
  INNER JOIN        
   @TempTable AA ON A.Id = AA.id        
  WHERE       
   A.Id = @OpportunityId        
        
   update ClientCursor.OpportunityStatusChange set State='Created',ModifiedBy=@User,ModifiedDate=GetDate() where OpportunityId=@OpportunityId  
  
     END  
    
  UPDATE ClientCursor.ReopenOpportunityHistory SET State = 'Created',CreatedId = NEWID(),QuotationId = @QuotationId WHERE TranactionId = @OpportunityId        
        
     
   
        
SET @StandardTemplateContent =        
(        
Select StandardTemplateContent from ClientCursor.Account where Id  in (Select AccountId from ClientCursor.Opportunity where Id = @OpportunityId)        
)        
        
---------=========================================================== INSERT NEW RECORD IN QUOTATION TABLE =========================================================================================        
        
INSERT INTO ClientCursor.Quotation        
SELECT AA.QuotationId as Id,@CompanyId as CompanyId,AA.Name,A.Fee as TotalFee,NULL as Revision,NULL as RecOrder,NULL as Remarks,@User as UserCreated,        
GETDATE() as CreatedDate,NULL as ModifiedBy,NULL as ModifiedDate,NULL as Version, 1 as Status,Null as SummaryAttachment,        
aa.AccountId,aa.QuoteNumber,NULL as IsEmailSent,        
@StandardTemplateContent as StandardTemplateContent ,NULL as RevisedCount,        
1 as IsTemparary,NULL as IsCreated        
        
 FROM        
   ClientCursor.Opportunity A        
  INNER JOIN        
   @TempTable AA ON A.Id = AA.id        
  WHERE       
   A.Id = @OpportunityId       
        
--------------=========================================================== INSERT NEW RECORD IN QUOTATIONSUMMARY TABLE =========================================================================================        
        
INSERT INTO ClientCursor.QuotationSummaryDetails        
SELECT         
 NEWID() as Id,@QuotationId as QuotationId,Name as TemplateName,Code as TemplateCode,TempletContent,IsLandscape         
FROM        
 Common.GenericTemplate         
WHERE         
 CompanyId = @CompanyId and TemplateType='Quotation Summary' and CursorName='Client Cursor' and Status=1        
        
-------------=========================================================== INSERT NEW RECORD IN QUOTATIONDETAIL TABLE =========================================================================================        
        
INSERT INTO ClientCursor.QuotationDetail        
SELECT         
 NEWID() as Id,QuotationId as MasterId,NULL as Revision,NULL as IsModified,NULL as RecOrder,        
 NULL as Remarks, NULL as UserCreated,GETDATE() as CreatedDate,NULL ModifiedBy,NULL as ModifiedDate,        
 NULL as Version, 1 as Status, NULL as QuoterAttachment, id as OpportunityId,DefaultTemplateId         
FROM        
 @TempTable WHERE id = @OpportunityId  
   
  
  
 -------------=========================================================== INSERT NEW RECORD IN QUOTATION History TABLE =========================================================================================        
        
INSERT INTO ClientCursor.QuotationHistory        
SELECT         
 NEWID() as Id,@CompanyId as CompanyId,QuotationId as QuotationId,@OpportunityId as OpportunityId,OpportunityNumber as Opportunity,NULL as MongoId,@User as [User],'Generate' as Type,  null as Attachments, @User as UserCreated,GetDate() as CreatedDate,null as ModifiedBy,null as ModifiedDate,null as Version,1 as Status,null as FilePath,null as FileName,null as AzurePath  
FROM        
 @TempTable WHERE id = @OpportunityId  
        
-------------=========================================================== INSERT NEW RECORD IN OPPORTUNITY HISTORY TABLE =========================================================================================        
        
INSERT INTO ClientCursor.OpportunityHistory        
SELECT        
 NEWID() as Id,B.Name,@CompanyId as CompanyId,@OpportunityId as OpportunityId,ServiceCompanyId,B.ServiceGroupId,ServiceId,B.QuoteNumber,B.Type,        
 B.Stage,B.Nature,B.FromDate,B.ToDate,        
 B.ReOpen,B.Frequency,B.FeeType,B.Fee,B.Currency,B.RecommendedFee,B.RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,RecOrder,Remarks,@User as UserCreated,        
 CreatedDate as OpportunityCreatedDate,NULL as ModifiedBy,NULL as ModifiedDate,Version,1 as Status,IsRecurring,IsAdHoc,OpportunityNumber,RecurringScopeofWork,        
 StandardTerms,KeyTerms,NULL as RevisionCreatedDate,BaseCurrency,BaseFee,B.DocToBaseExhRate        
FROM        
 ClientCursor.Opportunity B        
WHERE        
 B.Id = @OpportunityId        
        
        
        
---------------=========================================================== INSERT NEW RECORD IN OPPORTUNITY STATUS CHANGE TABLE =========================================================================================        
        
INSERT INTO ClientCursor.OpportunityStatusChange        
VALUES        
(        
 NEWID(), @CompanyId,@OpportunityId, 'Quoted',@User, GETDATE()        
)        
        
        
-----------------=========================================================== UPDATE OPPORTUNITY RECORD IN OPPORTUNITY TABLE =========================================================================================      
        
IF EXISTS (SELECT QuotedId FROM ClientCursor.ReopenOpportunityHistory WHERE QuotedId IS NULL and TranactionId = @OpportunityId)        
 UPDATE ClientCursor.Opportunity        
  SET        
   Stage = 'Quoted',        
   ModifiedBy = @User,        
   ModifiedDate = GETDATE()      
   --Fee=@Fee      
 WHERE        
  Id = @OpportunityId        
        
 UPDATE ClientCursor.ReopenOpportunityHistory SET State = 'Quoted',QuotedId = NEWID() WHERE TranactionId = @OpportunityId        
        
          
------------------=========================================================== INSERT NEW RECORD IN OPPORTUNITY STATUS CHANGE TABLE =========================================================================================        
        
INSERT INTO ClientCursor.OpportunityStatusChange        
VALUES        
(        
NEWID(), @CompanyId,@OpportunityId, 'Won',@User,GETDATE()        
)        
        
----------------=========================================================== UPDATE OPPORTUNITY RECORD IN OPPORTUNITY TABLE =========================================================================================        
        
IF EXISTS (SELECT WonId FROM ClientCursor.ReopenOpportunityHistory WHERE WonId IS NULL and TranactionId = @OpportunityId) 

 UPDATE ClientCursor.Opportunity        
  SET        
   Stage = 'Won',        
   ModifiedBy = @User,        
   ModifiedDate = GETDATE(),        
   Type = 'ReOpen',       
   QuoteNumber = 'ReOpened',      
   IsTemp = 0        
 WHERE        
  Id = @OpportunityId        
        
 UPDATE ClientCursor.ReopenOpportunityHistory SET State = 'Won',WonId = NEWID() WHERE TranactionId = @OpportunityId        
    
	update ClientCursor.Account set isAccount=1 where id in (select AccountId from ClientCursor.Opportunity where id=@OpportunityId)
        
        
DECLARE         
 @WFStatus int = (SELECT A.Status FROM common.companymodule A JOIN Common.ModuleMaster B ON A.ModuleId = B.Id        
 WHERE A.CompanyId = @CompanyId AND A.Status = 1 AND A.SetUpDone = 1 AND B.Heading = 'Workflow Cursor'),        
        
 @BeanStatus INT = (SELECT A.Status FROM common.companymodule A JOIN Common.ModuleMaster B ON A.ModuleId = B.Id        
 WHERE A.CompanyId = @CompanyId AND A.Status = 1 AND A.SetUpDone = 1 AND B.Heading = 'Bean Cursor'),        
        
 @IsDisable INT = (SELECT IsDisable FROM Common.AutoNumber WHERE EntityType = 'Account' AND CompanyId = @CompanyId),        
        
 @AccountId Uniqueidentifier = (SELECT AccountId FROM @TempTable WHERE id = @OpportunityId)        
        
         
        
IF (@WFStatus = 1)        
BEGIN        
 UPDATE ClientCursor.Opportunity        
     SET        
      SyncCaseStatus = 'InProgress',        
      SyncCaseDate = GETDATE()        
   WHERE        
    Id = @OpportunityId        
END        
        
        
--IF (@BeanStatus = 1)        
--BEGIN        
-- EXEC [dbo].[Common_Sync_MasterData] @CompanyId,'Account', @AccountId,'Add'        
--END         
        
IF (@IsDisable = 0)        
BEGIN        
UPDATE Common.AutoNumber SET IsDisable = 1 WHERE EntityType = 'Account' AND CompanyId = @CompanyId        
END        
        
IF (@WFStatus = 1)        
BEGIN        
 EXEC [dbo].[Common_Sync_MasterData_Opportunity_Cases] @CompanyId,@OpportunityId,'Add',@Default        
END        
        
SET @NewReOpenDate = (SELECT ReOpen FROM ClientCursor.Opportunity WHERE id = @OpportunityId)        
  Declare @ParentId Uniqueidentifier =(SELECT Id FROM ClientCursor.Opportunity Where Id = @OpportunityId And QuoteNumber Not in ('Open') And ReOpen Is not null And (Stage = 'Pending' OR Stage='Won'))  
  
  declare @Frequency1 nvarchar(200) = (select Frequency from ClientCursor.opportunity where id=@OpportunityId)
--IF NOT Exists (Select Id from ClientCursor.Opportunity where Id=@ParentId)  
if(@Frequency1 is not null or @Frequency1!='')
BEGIN        
 EXEC [dbo].[Insert_NewReOpening_Opportunity] @OpportunityId,@User        
END        
        
        
COMMIT        
        
END TRY        
        
BEGIN CATCH        
 IF (@@TRANCOUNT > 0)        
 ROLLBACK TRANSACTION        
 SET @ErrorMessage1 = ERROR_MESSAGE()        
 SET @ErrorMessage2 = ERROR_LINE()        
 UPDATE ClientCursor.ReopenOpportunityHistory SET ExceptionRemarks = @ErrorMessage1+' ,'+@ErrorMessage2 WHERE TranactionId = @OpportunityId        
 SELECT @ErrorMessage1,@ErrorMessage2        
        
END CATCH        
-------------===============================================================================================================----        
        
FETCH NEXT FROM Migration_Cursor INTO @OpportunityId        
        
END        
        
CLOSE Migration_Cursor;        
DEALLOCATE Migration_Cursor;        
        
 --BEGIN              
 -- SELECT               
 --  OpportunityNumber,a.AccountId as AccountId,          
 --  A.QuoteNumber as QuotationNumber,        
 --  CAST(A.Id as nvarchar(Max)) as TransactionId,STRING_AGG(CAST(C.CompanyUserId as nvarchar(MAX)),',') as InchargeId,        
 --  cg.CaseNumber as CaseNumber ,@WFStatus as IsWorkflowActivate,@BeanStatus as IsBeanActivate      
 --    FROM               
 --  ClientCursor.Opportunity A              
 -- JOIN              
 --  @Opportunity_TBL B              
 -- ON              
 --  A.id = B.Opportunity              
 -- JOIN              
 --  ClientCursor.OpportunityIncharge C              
 -- ON              
 --  A.Id = C.OpportunityId          
 --  Join WorkFlow.CaseGroup as cg        
 --  on C.OpportunityId  =cg.OpportunityId        
 -- GROUP BY              
 --  A.Id,OpportunityNumber,QuoteNumber,cg.CaseNumber,cg.Name,A.AccountId              
 --END        
        
END  
GO
