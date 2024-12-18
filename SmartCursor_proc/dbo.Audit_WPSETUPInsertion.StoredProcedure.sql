USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_WPSETUPInsertion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



  CREATE procedure [dbo].[Audit_WPSETUPInsertion] (@NEW_COMPANY_ID bigint,@UNIQUE_COMPANY_ID bigint,@isAudit bit)    
       
 AS       
 BEGIN      
  DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT      
 DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT      
 DECLARE @STATUS   INT      
 DECLARE @CREATED_DATE DATETIME       
 SET @STATUS = 1          
 SET @CREATED_DATE =GETUTCDATE()         
 DECLARE @IS_ACCOUNTING_FIRM bit      
 SET @IS_ACCOUNTING_FIRM = (select IsAccountingFirm  from Common.Company where Id=@NEW_COMPANY_ID)      
 DECLARE @PARTNER_COMPANYID BIGINT      
 SET @PARTNER_COMPANYID = (select AccountingFirmId  from Common.Company where Id=@NEW_COMPANY_ID)      
  BEGIN TRANSACTION      
   BEGIN TRY    

                  --------WorkProgram setup-----------      
      
  Declare @WPSetup_Cnt int;      
 select @WPSetup_Cnt=Count(*) from [Audit].[WPSetup] where companyid=@NEW_COMPANY_ID       
 IF @WPSetup_Cnt=0      
 Begin      
 IF @IS_ACCOUNTING_FIRM=1      
   Begin      
      INSERT INTO [Audit].[WPSetup] (Id,CompanyId,Code,[Description],Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,[Version],[Status],ShortCode,IsPartner,ReferenceId)      
      select NewID(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL as [ModifiedBy],NULL as [ModifiedDate],[Version],[Status],[ShortCode],1,[Id]      
      From [Audit].[WPSetup] Where CompanyId = @UNIQUE_COMPANY_ID;      
   End       
 Else      
    Begin       
      IF @PARTNER_COMPANYID IS not NULL      
   Begin       
    INSERT INTO [Audit].[WPSetup] (Id,CompanyId,Code,[Description],Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,[Version],[Status],ShortCode,IsPartner,ReferenceId)      
          select NewID(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL as [ModifiedBy],NULL as [ModifiedDate],[Version],[Status],[ShortCode],0,Id      
          From [Audit].[WPSetup] Where CompanyId = @PARTNER_COMPANYID AND Status=1;      
          
       declare @ID uniqueidentifier,@WPSetupId uniqueidentifier,@TickMark_Id uniqueidentifier;      
       DECLARE WPSETUPCSR CURSOR FOR SELECT ID,WPSetupId,TickMarkId FROM AUDIT.WPSETUPTICKMARK WHERE WPSetupId in(select Id from Audit.WPSetup where CompanyId=@PARTNER_COMPANYID )      
       OPEN WPSETUPCSR;      
       FETCH NEXT FROM WPSETUPCSR INTO @ID,@WPSetupId,@TickMark_Id      
       WHILE (@@FETCH_STATUS=0)      
       BEGIN      
       INSERT INTO AUDIT.WPSETUPTICKMARK (ID,WPSETUPID,TICKMARKID,STATUS)      
    SELECT NEWID(),(select id from Audit.WPSetup where ReferenceId=@WPSetupId and CompanyId=@NEW_COMPANY_ID),(select Id from audit.TickMarkSetup where companyid=@NEW_COMPANY_ID and referenceid=@TickMark_Id),STATUS FROM  AUDIT.WPSETUPTICKMARK WHERE Id=@ID 
  
    
     
       FETCH NEXT FROM WPSETUPCSR INTO @ID,@WPSetupId,@TickMark_Id      
       END      
       CLOSE WPSETUPCSR      
       DEALLOCATE WPSETUPCSR      
      
         End      
   Else      
   Begin       
    INSERT INTO [Audit].[WPSetup] (Id,CompanyId,Code,[Description],Remarks,RecOrder,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,[Version],[Status],ShortCode,IsPartner,[ReferenceId])      
          select NewId(),@NEW_COMPANY_ID as CompanyId,[Code],[Description],[Remarks],[RecOrder],[UserCreated],GETUTCDATE() as [CreatedDate],NULL as [ModifiedBy],NULL as [ModifiedDate],[Version],[Status],[ShortCode],0,Id   
          From [Audit].[WPSetup] Where CompanyId = @UNIQUE_COMPANY_ID;      
         End      
 End       
 end      
      
--       -----------------------Leadsheet Setup------------------      
   Declare @Leadsheet_Cnt bigint;      
   select @Leadsheet_Cnt=Count(*) from [Audit].[Leadsheet] where companyid=@NEW_COMPANY_ID       
    If @Leadsheet_Cnt=0      
 Begin      
 IF @IS_ACCOUNTING_FIRM=1      
    Begin      
  Insert Into [Audit].[Leadsheet] (Id, CompanyId, WorkProgramId, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status,IsPartner,ReferenceId )      
select Newid() as leadsheetid, @NEW_COMPANY_ID as newcompanyid,pp.Newcompanyid, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, GETUTCDATE(),NULL AS ModifiedBy,NULL AS ModifiedDate
  
    
, Version, Status ,1,[ReferenceId] from  [Audit].[LeadSheet]  as L      
INNER JOIN      
(      
select P.Id as 'Newcompanyid',w.Id as 'Oldcompanyid' from audit.WPSetup as w      
INNER JOIN       
(      
      
select id,code,Description from audit.WPSetup where companyid =@NEW_COMPANY_ID      
      
) as p ON P.Code=w.Code and P.Description=w.Description      
      
where companyid in (@UNIQUE_COMPANY_ID)      
) as PP On PP.Oldcompanyid=WorkProgramId      
      
where CompanyId=@UNIQUE_COMPANY_ID      
End      
      
Else      
    Begin       
      IF @PARTNER_COMPANYID IS not NULL      
   BEGIN       
 Declare @LeadsheetID uniqueidentifier,@WorkprogramId uniqueidentifier      
   Declare Leadsheet_CSR Cursor for Select Id,WorkProgramId From Audit.leadsheet Where companyid=@PARTNER_COMPANYID      
   Open Leadsheet_CSR      
   Fetch next from Leadsheet_CSR into @LeadsheetID ,@WorkprogramId      
   while @@FETCH_STATUS=0      
     Begin      
      Insert Into [Audit].[Leadsheet] (Id, CompanyId, WorkProgramId, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status ,IsPartner,ReferenceId )      
                   select Newid() as leadsheetid, @NEW_COMPANY_ID as newcompanyid,(Select id from audit.WPSetup where companyid=@NEW_COMPANY_ID  and         ReferenceId=@WorkprogramId), [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName,   FinancialStatementTemplate,    Remarks,     RecOrder, UserCreated, GETUTCDATE(),NULL AS ModifiedBy,NULL AS ModifiedDate,   Version, Status,0,Id from  [Audit].   [LeadSheet]        
                  where id=@LeadsheetID AND Status=1       
     Fetch next from Leadsheet_CSR into @LeadsheetID ,@WorkprogramId      
    End      
    Close Leadsheet_CSR      
    Deallocate Leadsheet_CSR      
      
        End      
  ELSE      
  BEGIN      
   Insert Into [Audit].[Leadsheet] (Id, CompanyId, WorkProgramId, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status )      
         select Newid() as leadsheetid, @NEW_COMPANY_ID as newcompanyid,pp.Newcompanyid, [Index], LeadsheetType, AccountClass, IsSystem, LeadSheetName, FinancialStatementTemplate, Remarks, RecOrder, UserCreated, GETUTCDATE(),NULL AS ModifiedBy,NULL AS ModifiedDate, Version, Status from  [Audit].[LeadSheet]  as L      
         INNER JOIN      
         (      
         select P.Id as 'Newcompanyid',w.Id as 'Oldcompanyid' from audit.WPSetup as w      
         INNER JOIN       
         (      
               
         select id,code,Description from audit.WPSetup where companyid =@NEW_COMPANY_ID      
               
         ) as p ON P.Code=w.Code and P.Description=w.Description      
               
         where companyid in (@UNIQUE_COMPANY_ID)      
         ) as PP On PP.Oldcompanyid=WorkProgramId      
               
         where CompanyId=@UNIQUE_COMPANY_ID      
         end       
   END      
  END      
  ------------------------------LeadSheetCategories---------------------------------      
  Declare @LeadSheetCategories_Cnt bigint;      
    select @LeadSheetCategories_Cnt=Count(*) from [Audit].[LeadSheetCategories] where LeadsheetId in (select Id from audit.leadsheet where CompanyId= @NEW_COMPANY_ID)      
    If @LeadSheetCategories_Cnt=0      
    Begin      
   IF @PARTNER_COMPANYID IS not NULL      
    begin       
    Insert Into [Audit].[LeadSheetCategories]      
  ([Id],[LeadsheetID],[Name],[RecOrder],[Status])      
  SELECT newid() as Id      
,(select ID FROM [Audit].[LeadSheet] where CompanyId = @NEW_COMPANY_ID and LeadSheetName = (select LeadSheetName FROM [Audit].[LeadSheet] where Id = cat.[LeadsheetID] and CompanyId = @PARTNER_COMPANYID))   as [LeadsheetID]      
   ,cat.[Name]        
   ,cat.[RecOrder]      
   ,cat.[Status]      
  FROM [Audit].[LeadSheetCategories] cat inner join [Audit].[LeadSheet] ld      
  on ld.Id = cat.LeadsheetID       
  where ld.CompanyId = @PARTNER_COMPANYID AND LD.Status=1      
  end       
  ELSE       
  BEGIN      
      
 Insert Into [Audit].[LeadSheetCategories]      
  ([Id],[LeadsheetID],[Name],[RecOrder],[Status])      
  SELECT newid() as Id      
,(select ID FROM [Audit].[LeadSheet] where CompanyId = @NEW_COMPANY_ID and LeadSheetName = (select LeadSheetName FROM [Audit].[LeadSheet] where Id = cat.[LeadsheetID] and CompanyId = @UNIQUE_COMPANY_ID))   as [LeadsheetID]      
   ,cat.[Name]        
   ,cat.[RecOrder]      
   ,cat.[Status]      
  FROM [Audit].[LeadSheetCategories] cat inner join [Audit].[LeadSheet] ld      
  on ld.Id = cat.LeadsheetID       
  where ld.CompanyId = @UNIQUE_COMPANY_ID      
  End      
      
  End      
      
      
       COMMIT TRANSACTION      
          
  END TRY      
 BEGIN CATCH      
   DECLARE      
     @ErrorMessage NVARCHAR(4000),      
     @ErrorSeverity INT,      
     @ErrorState INT;      
SELECT      
     @ErrorMessage = ERROR_MESSAGE(),      
     @ErrorSeverity = ERROR_SEVERITY(),      
     @ErrorState = ERROR_STATE();      
   RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);      
  ROLLBACK TRANSACTION      
 END CATCH      
 END
GO
