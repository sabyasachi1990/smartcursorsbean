USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_Opportunity_Cases]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Common_Sync_MasterData_Opportunity_Cases] ---- Exec [dbo].[Common_Sync_MasterData_Opportunity_Cases] 1,'FDF2278B-5346-A903-EB6A-12C816AFC606' ,'Add'
 @CompanyId  Int,
@OpportunityId uniqueidentifier,
@Action Varchar(50),
@Default Bit = 0
   as
   begin 


--Exec [dbo].[Common_Sync_MasterData_Opportunity_Cases] 19,'30103492-e30a-784e-882a-8b45bff3d021' ,'Add'

--Declare @OpportunityId uniqueidentifier ---- = '5C937237-A98A-39A1-E1C1-004B8E04CDB9'   ----'14940EA8-DA9C-EC7B-3299-0F53D6A94A3B'            --'5C937237-A98A-39A1-E1C1-004B8E04CDB9'
Declare @AccountId uniqueidentifier
Declare @ServiceId bigint
Declare @ClientId uniqueidentifier
Declare @NewCaseId uniqueidentifier
Declare @NewCaseId1 uniqueidentifier
Declare @ScopeOfWork Nvarchar(Max)
Declare @ScopeOfWork1 Nvarchar(Max)
--Declare @Action Varchar(50)
Declare @SysRef NVarchar(100)
Declare @GetDATE datetime2
Declare @MainServiceId bigint
Declare @SubServiceId bigint
Declare @ParentId uniqueidentifier
Declare @ParentId1 uniqueidentifier
Declare @ClientIName Nvarchar (max)
--Declare @CompanyId  Int=1

Declare  @CaseNumber table (CaseNumber Nvarchar (max),SecondaryCaseNumber  Nvarchar (max),ClientName Nvarchar (max))

 --Begin Transaction  
 --Begin Try  

    
	Declare CaseId_Csr Cursor For
      Select  ID as OpportunityId,AccountId,ServiceId from  ClientCursor.Opportunity WHERE CompanyId=@CompanyId and Id=@OpportunityId

	Open CaseId_Csr;
	Fetch Next From Caseid_Csr Into  @OpportunityId,@AccountId,@ServiceId
	While @@FETCH_STATUS=0
	Begin

	IF Exists (Select Id From Common.CompanyModule Where CompanyId=@CompanyId And ModuleId in (Select Id from Common.ModuleMaster Where Name='Workflow Cursor') And Status=1)
		Begin


	If(@Action='Add')
			Begin

            If Not Exists ( SELECT Id From WorkFlow.Client  where CompanyId=@CompanyId and SyncAccountId=@AccountId)
			Begin 
	
			EXEC  [dbo].[Common_Sync_MasterData] @CompanyId,'Account',@AccountId,'Add'

		    END
		    If  NOT  Exists ( SELECT Id From WorkFlow.CaseGroup  where CompanyId=@CompanyId and OpportunityId=@OpportunityId)
			Begin 
			    IF Exists( select Id from  Common.Service where IsSplitEnable=1 and id=@ServiceId)
				BEGIN
				  SET @ClientId =( select  SyncClientId from ClientCursor.Account where CompanyId=@CompanyId and id=@AccountId)
				   SET @ClientIName =( select  name from ClientCursor.Account where CompanyId=@CompanyId and id=@AccountId)
				  SET @MainServiceId =( select MainServiceId from  Common.Service where IsSplitEnable=1 and id=@ServiceId)
				  SET @SubServiceId =( select SubServiceId from  Common.Service where IsSplitEnable=1 and id=@ServiceId)
		         SET @ParentId=(SELECT cg.Id From ClientCursor.Opportunity op inner join WorkFlow.CaseGroup cg on cg.OpportunityId=op.ParentId where op.CompanyId=@CompanyId and op.Id=@OpportunityId  and (op.Type='ReOpening' or op.Type='ReOpen') and op.MainServiceFee is not null and IsMainService=1)
				  SET @ParentId1=(SELECT cg.Id From ClientCursor.Opportunity op inner join WorkFlow.CaseGroup cg on cg.OpportunityId=op.ParentId where op.CompanyId=@CompanyId and op.Id=@OpportunityId  and (op.Type='ReOpening' or op.Type='ReOpen') and SubServiceFee is not null and IsMainService=0 )
	               SET @NewCaseId=NewID()
				   SET @NewCaseId1=NewID()
				   SET @GetDATE=GETUTCDATE()

				      declare @SystemRefnum Nvarchar (max)=(

					      SELECT Case when (SELECT  COUNT(*) FROM WorkFlow.CaseGroup WHERE CompanyId=@CompanyId )=0 then 
    CAST( Replace(Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{MM/YYYY}',
	right('0'+cast(Month(Getdate()) as varchar(50)),2)+'/'+ cast (YEAR(Getdate()) as varchar(50))),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int) AS varchar(10)),CounterLength)
	
	 else 
	CAST(Replace( Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{MM/YYYY}',
	right('0'+cast(Month(Getdate()) as varchar(50)),2)+'/'+ cast (YEAR(Getdate()) as varchar(50))),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int)+1 AS varchar(10)),CounterLength) end  AS GenaratedNumber
				--	  SELECT Case when (SELECT  COUNT(*) FROM WorkFlow.CaseGroup WHERE CompanyId=@CompanyId )=0 then  CAST( Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	   --Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int) AS varchar(10)),CounterLength) else 
	   --CAST( Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	   --Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int)+1 AS varchar(10)),CounterLength) end  AS GenaratedNumber
					  
					  
					 -- select 
						--CAST( Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
						--  Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int)+1 AS varchar(10)),CounterLength) AS GenaratedNumber


						from  Common.ServiceGroup sg 
						inner join  Common.Service s on sg.id=s.ServiceGroupId
						inner join Common.Company c on c.Id=sg.CompanyId
						Inner join Common.AutoNumber A on A.CompanyId=c.Id
						Where sg.CompanyId=@CompanyId and s.Id=@ServiceId
						And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))

                    declare @mainservicecode nvarchar(10) = (select code from Common.Service where Id = @MainServiceId)
					set	@SystemRefnum = @SystemRefnum + '/'+ @mainservicecode

				  -- SET @SysRef= Right('0000000000'+Cast((@GeneratedNumber+2 ) As varchar),Len(@GeneratedNumber))
				  -- Declare @RefNumber varchar(100)= @SystemRefnum;
				  --Declare @RefNumber1 varchar(100)= CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+2 ) As varchar),Len(@GeneratedNumber)))

				   Insert into WorkFlow.CaseGroup (Id ,Name,CompanyId,ServiceCompanyId,ServiceGroupId,ServiceId,Type,Nature,FromDate,ToDate,FeeType,Fee  ,
	   Currency,RecommendedFee,RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,Remarks,
	   Status,OpportunityId,InvoiceState,ReasonForCancellation,ScopeOfWork,SyncOppId,SyncOppDate,CreatedDate,Stage,
	   ClientId,CaseNumber,IsMainService,MainOrSubCaseId,ModifiedBy,SystemRefNo,IsServiceNatureWOWF,ServiceNatureType,UserCreated,ParentId,BaseCurrency,BaseFee,DocToBaseExhRate,IsMultiCurrency,IsAllowQic,IsAllowJobDeadLine,IsAllowEmail,IsAllowMic)
	

	   SELECT @NewCaseId as CaseId,Name,CompanyId,ServiceCompanyId,ServiceGroupId,ServiceId,Type,Nature,FromDate,ToDate,FeeType,MainServiceFee, 
	   Currency,RecommendedFee,RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,Remarks,
	  Status,id as OpportunityId,'NotInvoiced' AS InvoiceState,ReasonForCancellation,( select RecurringScopeofWork from  Common.Service where  id=@MainServiceId),Id as OpportunityId,@GetDATE AS SyncOppDate ,@GetDATE AS CreatedDate,'Unassigned' AS Stage,
	  @ClientId as ClientId ,@SystemRefnum as CaseNumber ,1 as IsMainService,@NewCaseId1 as MainOrSubCaseId, ModifiedBy,@SystemRefnum as SystemRefNo
	  ,(select IsRecurringWOWF AS IsServiceNatureWOWF from  Common.Service where  id=@ServiceId),(select IsRecurringWOWF AS ServiceNatureType from  Common.Service where  id=@ServiceId),'System' as  UserCreated,
	  @ParentId,BaseCurrency,(MainServiceFee * DocToBaseExhRate),DocToBaseExhRate,IsMultiCurrency,(select IsAllowQic from  Common.Service where  id=@ServiceId),(select IsAllowJobDeadLine from  Common.Service where  id=@ServiceId),(select IsAllowEmail from  Common.Service where  id=@ServiceId),(select IsAllowMic from  Common.Service where  id=@ServiceId)
	  FROM ClientCursor.Opportunity WHERE CompanyId=@CompanyId AND  ID =@OpportunityId and MainServiceFee is not null



	   UPDATE Common.AutoNumber set  GeneratedNumber=  (select CASE WHEN (SELECT  COUNT(*) FROM WorkFlow.CaseGroup WHERE CompanyId=@CompanyId ) IN (0,1)  THEN Cast(Cast(A.GeneratedNumber AS int) AS varchar(10))
	    ELSE Cast(Cast(A.GeneratedNumber AS int)+1 AS varchar(10)) END  As NUmber
	  from Common.AutoNumber a
	   Where a.CompanyId=@CompanyId 
       And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))
	     
	   where CompanyId=@CompanyId And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor')
	   ----=========
	   insert into @CaseNumber (CaseNumber,ClientName)
	    select @SystemRefnum,@ClientIName
	   --================

	     Declare @SystemRefnum2 Nvarchar (max)=(

		     SELECT Case when (SELECT  COUNT(*) FROM WorkFlow.CaseGroup WHERE CompanyId=@CompanyId )=0 then 
    CAST( Replace(Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{MM/YYYY}',
	right('0'+cast(Month(Getdate()) as varchar(50)),2)+'/'+ cast (YEAR(Getdate()) as varchar(50))),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int) AS varchar(10)),CounterLength)
	
	 else 
	CAST(Replace( Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{MM/YYYY}',
	right('0'+cast(Month(Getdate()) as varchar(50)),2)+'/'+ cast (YEAR(Getdate()) as varchar(50))),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int)+1 AS varchar(10)),CounterLength) end  AS GenaratedNumber
		 --SELECT Case when (SELECT  COUNT(*) FROM WorkFlow.CaseGroup WHERE CompanyId=@CompanyId )=0  then  CAST( Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	  -- Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int) AS varchar(10)),CounterLength) else 
	  -- CAST( Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	  -- Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int)+1 AS varchar(10)),CounterLength) end  AS GenaratedNumber
		 
		 --SELECT 
	  -- CAST( Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	  -- Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int)+1 AS varchar(10)),CounterLength) AS GenaratedNumber
	  
	  from  Common.ServiceGroup sg 
	  inner join  Common.Service s on sg.id=s.ServiceGroupId
	  inner join Common.Company c on c.Id=sg.CompanyId
	  Inner join Common.AutoNumber A on A.CompanyId=c.Id
	   Where sg.CompanyId=@CompanyId and s.Id=@ServiceId
       And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))

	   declare @subservicecode nvarchar(10) = (select code from Common.Service where Id = @SubServiceId)
	   set	@SystemRefnum2 = @SystemRefnum2 + '/'+ @subservicecode

	          Insert into WorkFlow.CaseGroup (Id ,Name,CompanyId,ServiceCompanyId,ServiceGroupId,ServiceId,Type,Nature,FromDate,ToDate,FeeType,Fee ,
	   Currency,RecommendedFee,RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,Remarks,
	   Status,OpportunityId,InvoiceState,ReasonForCancellation,ScopeOfWork,SyncOppId,SyncOppDate,CreatedDate,Stage,
	   ClientId,CaseNumber,IsMainService,MainOrSubCaseId,ModifiedBy,SystemRefNo,IsServiceNatureWOWF,ServiceNatureType,UserCreated,ParentId,BaseCurrency,BaseFee,DocToBaseExhRate,IsMultiCurrency,IsAllowQic,IsAllowJobDeadLine,IsAllowEmail,IsAllowMic)
	  
	      SELECT @NewCaseId1 as CaseId,Name,CompanyId,ServiceCompanyId,ServiceGroupId,ServiceId,Type,Nature,FromDate,ToDate,FeeType,SubServiceFee, 
	  Currency,RecommendedFee,RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,Remarks,
	  Status,id as OpportunityId,'NotInvoiced' AS InvoiceState,ReasonForCancellation,( select RecurringScopeofWork from  Common.Service where  id=@SubServiceId),Id as OpportunityId,@GetDATE AS SyncOppDate ,@GetDATE AS CreatedDate,'Unassigned' AS Stage,
	  @ClientId as ClientId ,@SystemRefnum2 as CaseNumber ,0 as IsMainService,@NewCaseId as MainOrSubCaseId, ModifiedBy,@SystemRefnum2 as SystemRefNo
	  ,(select IsRecurringWOWF AS IsServiceNatureWOWF from  Common.Service where   id=@ServiceId),(select IsRecurringWOWF AS ServiceNatureType from  Common.Service where  id=@ServiceId),'System' as  UserCreated,
	  @ParentId1,BaseCurrency,(SubServiceFee * DocToBaseExhRate),DocToBaseExhRate,IsMultiCurrency,(select  IsAllowQic from  Common.Service where   id=@ServiceId),(select IsAllowJobDeadLine from  Common.Service where   id=@ServiceId),(select IsAllowEmail from  Common.Service where   id=@ServiceId),(select IsAllowMic from  Common.Service where   id=@ServiceId)
	  FROM ClientCursor.Opportunity WHERE CompanyId=@CompanyId AND  ID =@OpportunityId and SubServiceFee is not null

	   UPDATE Common.AutoNumber set  GeneratedNumber=  (select CASE WHEN (SELECT  COUNT(*) FROM WorkFlow.CaseGroup WHERE CompanyId=@CompanyId )IN (0,1)   THEN Cast(Cast(A.GeneratedNumber AS int) AS varchar(10))
	    ELSE Cast(Cast(A.GeneratedNumber AS int)+1 AS varchar(10)) END  As NUmber
	  from Common.AutoNumber a
	   Where a.CompanyId=@CompanyId 
       And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))
	   
	   where CompanyId=@CompanyId And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor')

		 Update ClientCursor.Opportunity Set CaseId=@NewCaseId,SyncCaseId=@NewCaseId,SyncCaseStatus='UpadeteCompleted',SyncCaseRemarks=null,SyncCaseDate=@GetDATE Where Id=@OpportunityId And CompanyId=@CompanyId

		 Insert Into WorkFlow.CaseStatusChange (ID ,CompanyId,CaseId,State,ModifiedBy,ModifiedDate)
		 Values(NEWID(),@CompanyId,@NewCaseId,'Unassigned','System',@GetDATE)
		  Insert Into WorkFlow.CaseStatusChange (ID ,CompanyId,CaseId,State,ModifiedBy,ModifiedDate)
		 Values(NEWID(),@CompanyId,@NewCaseId1,'Unassigned','System',@GetDATE)

	 -- UPDATE a set  GeneratedNumber=@SysRef From Common.AutoNumber A
		--Where CompanyId=@CompanyId And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor')


		 insert into Common.TimeLogItem  (id,CompanyId,type,SubType,ChargeType,SystemType,
	 SystemId,IsSystem,ApplyToAll,UserCreated,CreatedDate,Status,Hours,Days) 
		 
		 Values ( Newid() ,@CompanyId,@SystemRefnum, (select name  from  WorkFlow.client  where CompanyId=@CompanyId and id=@ClientId),'Chargeable','CaseGroup',
	     @NewCaseId,1,0,@GetDATE,@GetDATE,1,0,0  )


		 	 insert into Common.TimeLogItem  (id,CompanyId,type,SubType,ChargeType,SystemType,
	        SystemId,IsSystem,ApplyToAll,UserCreated,CreatedDate,Status,Hours,Days) 
		 
		 Values ( Newid() ,@CompanyId,@SystemRefnum2, (select name  from  WorkFlow.client  where CompanyId=@CompanyId and id=@ClientId),'Chargeable','CaseGroup',
	     @NewCaseId1,1,0,@GetDATE,@GetDATE,1,0,0  )

		 	   ----=========
	   insert into @CaseNumber (SecondaryCaseNumber,ClientName)
	    select @SystemRefnum2,@ClientIName
	   --================



	 --   INSERT INTO WorkFlow.CaseDesignation ( ID,CaseId,DefaultRate,Currency,BillingRate,BillCurrency,EstdHours,RecOrder,
		--Status,Designation,DepartmentDesignationId)
       

	 --  SELECT  NEWID() AS Id,@NewCaseId AS CaseId,d.DefaultRate,d.Currency,d.BillingRate,d.BillCurrency,d.EstdHours,d.RecOrder,d.Status,d.Designation,
  --     d.DepartmentDesignationId
  --     FROM ClientCursor.OpportunityDesignation D 
	 --  Inner join ClientCursor.Opportunity O On o.id=d.OpportunityId
	 --  WHERE  OpportunityId=@OpportunityId and FeeType='Variable'
	  

	  END
	   ELSE 
	   BEGIN 
	    SET @ClientId =( select  SyncClientId from ClientCursor.Account where CompanyId=@CompanyId and id=@AccountId)
		SET @ClientIName =( select  Name from ClientCursor.Account where CompanyId=@CompanyId and id=@AccountId)
		  SET @ParentId=(SELECT cg.Id From ClientCursor.Opportunity op inner join WorkFlow.CaseGroup cg on cg.OpportunityId=op.ParentId where op.CompanyId=@CompanyId and op.Id=@OpportunityId  and (op.Type='ReOpening' or op.Type='ReOpen'))
		SET @NewCaseId=NewID()
		SET @GetDATE=GetUTCDATE()
		             --declare @SystemRefnum1 Nvarchar (max)=( select replace( replace ((select replace ('CE-{SERVICEGROUP}{SERVICE}-{YYYY}-','{SERVICEGROUP}', (SELECT  SG.Code   FROM Common.Service S 
	              --    INNER JOIN Common.ServiceGroup SG ON SG.ID=S.ServiceGroupId
	              --    WHERE S.CompanyId=@CompanyId AND S.Id=@ServiceId))) ,'{SERVICE}', (SELECT  S.Code   FROM Common.Service S 
	              --    INNER JOIN Common.ServiceGroup SG ON SG.ID=S.ServiceGroupId
	              --    WHERE S.CompanyId=@CompanyId AND S.Id=@ServiceId)),'{YYYY}', (select year(getdate()))))

	                

				   SET @SysRef= (
				       SELECT Case when (SELECT  COUNT(*) FROM WorkFlow.CaseGroup WHERE CompanyId=@CompanyId )=0 then 
    CAST( Replace(Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{MM/YYYY}',
	right('0'+cast(Month(Getdate()) as varchar(50)),2)+'/'+ cast (YEAR(Getdate()) as varchar(50))),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int) AS varchar(10)),CounterLength)
	
	 else 
	CAST(Replace( Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{MM/YYYY}',
	right('0'+cast(Month(Getdate()) as varchar(50)),2)+'/'+ cast (YEAR(Getdate()) as varchar(50))),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int)+1 AS varchar(10)),CounterLength) end  AS GenaratedNumber
				--    SELECT Case when (SELECT  COUNT(*) FROM WorkFlow.CaseGroup WHERE CompanyId=@CompanyId )=0  then  CAST( Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	   --Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int) AS varchar(10)),CounterLength) else 
	   --CAST( Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	   --Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int)+1 AS varchar(10)),CounterLength) end  AS GenaratedNumber
				   
			--	   SELECT 
	  --CAST( Replace(Replace(REPLACE(A.Format,'{SERVICEGROUP}',sg.Code),'{SERVICE}',s.Code),'{YYYY}',YEAR(Getdate())) AS varchar(50))+
	  -- Right('0000000000'+Cast(Cast(A.GeneratedNumber AS int)+1 AS varchar(10)),CounterLength) AS GenaratedNumber
	  from  Common.ServiceGroup sg 
	  inner join  Common.Service s on sg.id=s.ServiceGroupId
	  inner join Common.Company c on c.Id=sg.CompanyId
	  Inner join Common.AutoNumber A on A.CompanyId=c.Id
	   Where sg.CompanyId=@CompanyId and s.Id=@ServiceId
       And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))



	   --declare @GeneratedNumber1 Nvarchar (max)=(Select GeneratedNumber From Common.AutoNumber 
				--	 Where CompanyId=@CompanyId And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))


		  Insert into WorkFlow.CaseGroup (Id ,Name,CompanyId,ServiceCompanyId,ServiceGroupId,ServiceId,Type,Nature,FromDate,ToDate,FeeType,Fee  ,
	   Currency,RecommendedFee,RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,Remarks,
	   Status,OpportunityId,InvoiceState,ReasonForCancellation,ScopeOfWork,SyncOppId,SyncOppDate,CreatedDate,Stage,
	   ClientId,CaseNumber, ModifiedBy,SystemRefNo,IsServiceNatureWOWF,ServiceNatureType,UserCreated,ParentId,BaseCurrency,BaseFee,DocToBaseExhRate,IsMultiCurrency,IsAllowQic,IsAllowJobDeadLine,IsAllowEmail,IsAllowMic)
			    

      SELECT @NewCaseId as CaseId,Name,CompanyId,ServiceCompanyId,ServiceGroupId,ServiceId,Type,Nature,FromDate,ToDate,FeeType,Fee, 
	  Currency,RecommendedFee,RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,Remarks,
	  Status,id as OpportunityId,'NotInvoiced' AS InvoiceState,ReasonForCancellation,RecurringScopeofWork,Id as OpportunityId,@GetDATE AS SyncOppDate ,@GetDATE AS CreatedDate ,'Unassigned' AS Stage,
	  @ClientId as ClientId ,@SysRef as CaseNumber , ModifiedBy,@SysRef as SystemRefNo
	  ,(select IsRecurringWOWF AS IsServiceNatureWOWF from  Common.Service where  id=@ServiceId),(select IsRecurringWOWF AS ServiceNatureType from  Common.Service where  id=@ServiceId),'System' as  UserCreated,
	  @ParentId,BaseCurrency,BaseFee,DocToBaseExhRate,IsMultiCurrency,(select IsAllowQic from  Common.Service where  id=@ServiceId),(select IsAllowJobDeadLine from  Common.Service where  id=@ServiceId),(select IsAllowEmail from  Common.Service where  id=@ServiceId),(select IsAllowMic from  Common.Service where  id=@ServiceId)
	  FROM ClientCursor.Opportunity WHERE CompanyId=@CompanyId AND  ID =@OpportunityId ---and SubServiceFee is not null	



	  Update ClientCursor.Opportunity Set CaseId=@NewCaseId,SyncCaseId=@NewCaseId,SyncCaseStatus='Completed',SyncCaseRemarks=null,SyncCaseDate=@GetDATE Where Id=@OpportunityId And CompanyId=@CompanyId

	   

		 Insert Into WorkFlow.CaseStatusChange (ID ,CompanyId,CaseId,State,ModifiedBy,ModifiedDate)
		 Values(NEWID(),@CompanyId,@NewCaseId,'Unassigned','System',@GetDATE)

		 INSERT INTO WorkFlow.CaseDesignation ( ID,CaseId,DefaultRate,Currency,BillingRate,BillCurrency,EstdHours,RecOrder,
		Status,Designation,DepartmentDesignationId)
       

	   SELECT  NEWID() AS Id,@NewCaseId AS CaseId,d.Rate,d.Currency,d.BillingRate,d.BillCurrency,d.EstdHours,d.RecOrder,d.Status,d.Designation,
       d.DepartmentDesignationId
       FROM ClientCursor.OpportunityDesignation D 
	   Inner join ClientCursor.Opportunity O On o.id=d.OpportunityId
	   WHERE  o.Id=@OpportunityId and o.CompanyId=@CompanyId and FeeType='Variable'

	    UPDATE Common.AutoNumber set  GeneratedNumber=  (select  CASE WHEN (SELECT  COUNT(*) FROM WorkFlow.CaseGroup WHERE CompanyId=@CompanyId )IN (0,1)   THEN Cast(Cast(A.GeneratedNumber AS int) AS varchar(10))
	    ELSE Cast(Cast(A.GeneratedNumber AS int)+1 AS varchar(10)) END  As NUmber
	  from Common.AutoNumber a
	   Where a.CompanyId=@CompanyId 
       And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))
	   
	   where CompanyId=@CompanyId And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor')


			 insert into Common.TimeLogItem  (id,CompanyId,type,SubType,ChargeType,SystemType,
	         SystemId,IsSystem,ApplyToAll,UserCreated,CreatedDate,Status,Hours,Days) 
		 
		 Values ( Newid() ,@CompanyId,@SysRef, (select name  from  WorkFlow.client  where CompanyId=@CompanyId and id=@ClientId),'Chargeable','CaseGroup',
	     @NewCaseId,1,0,@GetDATE,@GetDATE,1,0,0  )

		    ----=========
	   insert into @CaseNumber (CaseNumber,ClientName)
	    select @SysRef,@ClientIName
	   --================

	  END 
	  END

	  	-------------------------------------------Audit Logs Insert for CC Opportunity to Bean Entity --------------------------------------------------

				DECLARE @WFClientId NVARCHAR(40);
				DECLARE @BeanEntityId NVARCHAR(40);
				DECLARE @OppAction NVARCHAR(25);
				DECLARE @PreviousAction NVARCHAR(25);


				SET @PreviousAction = (
				SELECT State
				FROM ClientCursor.OpportunityStatusChange
				WHERE OpportunityId = @OpportunityId
				ORDER BY ModifiedDate DESC
				OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY);

				SELECT @WFClientId = C.Id,
					   @BeanEntityId = C.SyncEntityId,
					   @OppAction = OPP.Stage
				FROM ClientCursor.Opportunity AS OPP
				JOIN WorkFlow.Client AS C ON OPP.AccountId = C.AccountId
				WHERE OPP.Id = @OpportunityId;
	
				IF ((@PreviousAction = 'Pending' AND @OppAction = 'Won') OR (@PreviousAction = 'Won' AND @OppAction = 'Pending'))
				BEGIN
					EXEC [dbo].[UpdateAuditSyncing] @OpportunityId, @BeanEntityId, 'Success', @OppAction, NULL, NULL, NULL, NULL, NULL, 'CC Opportunity','Bean Entity';					
				END

				ELSE
				BEGIN
					EXEC [dbo].[InsertAuditSyncing] @OpportunityId,@BeanEntityId,'Success',@CompanyId,'CC Opportunity','Bean Entity',@OppAction,NULL,NULL,NULL,NULL,NULL;
				END



		--DECLARE @WFClientId NVARCHAR(40);
		--DECLARE @BeanEntityId NVARCHAR(40);
		--DECLARE @OppAction NVARCHAR(25);
		--SELECT  @WFClientId = C.Id,
		--		@BeanEntityId = C.SyncEntityId,
		--		@OppAction = OPP.Stage
		--FROM ClientCursor.Opportunity AS OPP JOIN 
		--WorkFlow.Client AS C ON OPP.AccountId = C.AccountId WHERE OPP.Id = @OpportunityId
		--BEGIN
		--EXEC [dbo].[InsertAuditSyncing] @WFClientId,@BeanEntityId,'Success',@CompanyId,'WF Client','Bean Entity',@OppAction,NULL,NULL,NULL,NULL,NULL
		--END
	   -------------------------------------------Audit Logs Insert for CC Opportunity to Bean Entity ------------------------------------------------------



	  	-------------------------------------------Audit Logs Update for CC Oppertunity to WF Cases ----------------------------------------------------
		Declare @OppStatus Nvarchar(30);
		Declare @WFCaseId uniqueidentifier;
		Declare @SyncingStatus Nvarchar(30);
		DECLARE @WFCaseIdOrZero UNIQUEIDENTIFIER;
		Set @WFCaseId =(select CaseId from ClientCursor.Opportunity where Id=@OpportunityId);
		Set @OppStatus =(select Stage from ClientCursor.Opportunity where Id=@OpportunityId);
		SET @SyncingStatus = CASE WHEN @OppStatus = 'Won' THEN 'Success' ELSE 'Pending'   END;
		SET @WFCaseIdOrZero = CASE WHEN @OppStatus = 'Won' THEN @WFCaseId  ELSE '00000000-0000-0000-0000-000000000000'  END;                 
		EXEC [dbo].[UpdateAuditSyncing] @OpportunityId,@WFCaseIdOrZero,@SyncingStatus,@OppStatus,Null,Null,Null,Null,Null,'CC Opportunity','WF Cases'
	   -------------------------------------------Audit Logs Update for CC Oppertunity to WF Cases------------------------------------------------------

	  END


	  Else If(@Action='Edit')
			Begin
				If Exists (Select Id From WorkFlow.Client Where SyncAccountId=@AccountId And CompanyId=@CompanyId)
				Begin
			   If  Exists ( SELECT Id From WorkFlow.CaseGroup  where CompanyId=@CompanyId and OpportunityId=@OpportunityId)
			   Begin 

				 IF Exists( select Id from  Common.Service where IsSplitEnable=1 and id=@ServiceId)
				BEGIN
				SET @GetDATE=GetUTCDATE()
		Update  cg set CG.BaseFee=(o.MainServiceFee * o.DocToBaseExhRate),CG.SyncOppStatus='UpdateCompleted',cg.SyncOppDate=@GetDATE,cg.SyncOppRemarks=null,
	    cg.ModifiedBy=o.ModifiedBy,cg.ModifiedDate=o.ModifiedDate ,CG.FromDate=O.FromDate , CG.ToDate=O.ToDate,
		cg.Currency=o.Currency,cg.DocToBaseExhRate=o.DocToBaseExhRate,cg.Fee=o.MainServiceFee
	    FROM WorkFlow.CaseGroup Cg
	    inner join ClientCursor.Opportunity O ON O.Id=CG.OpportunityId WHERE O.CompanyId=@CompanyId AND  O.Id =@OpportunityId and cg.IsMainService =1

	    Update ClientCursor.Opportunity Set SyncCaseStatus='UpdateCompleted',SyncCaseRemarks=null,SyncCaseDate=@GetDATE Where Id=@OpportunityId And CompanyId=@CompanyId


		   
		 Update cg set CG.BaseFee=(o.SubServiceFee * o.DocToBaseExhRate),CG.SyncOppStatus='UpdateCompleted',cg.SyncOppDate=@GetDATE,cg.SyncOppRemarks=null,
	    cg.ModifiedBy=o.ModifiedBy,cg.ModifiedDate=o.ModifiedDate,CG.FromDate=O.FromDate , CG.ToDate=O.ToDate,
		cg.Currency=o.Currency,cg.DocToBaseExhRate=o.DocToBaseExhRate,cg.Fee=o.SubServiceFee
	    FROM WorkFlow.CaseGroup Cg
	    inner join ClientCursor.Opportunity O ON O.Id=CG.OpportunityId WHERE O.CompanyId=@CompanyId AND  O.Id =@OpportunityId and cg.IsMainService=0

	    Update ClientCursor.Opportunity Set SyncCaseStatus='UpdateCompleted',SyncCaseRemarks=null,SyncCaseDate=@GetDATE Where Id=@OpportunityId And CompanyId=@CompanyId
	  	
		 END

		 ELSE 
	     BEGIN 
		 SET @GetDATE=GetUTCDATE()
	   	Update cg set CG.BaseFee=O.BaseFee,CG.SpecialRemarks=O.SpecialRemarks,CG.Remarks=O.Remarks,CG.SyncOppStatus='UpdateCompleted',cg.SyncOppDate=@GetDATE,cg.SyncOppRemarks=null,
	    cg.ScopeOfWork=o.RecurringScopeofWork,cg.ModifiedBy=o.ModifiedBy,cg.ModifiedDate=o.ModifiedDate, CG.FromDate=O.FromDate , CG.ToDate=O.ToDate ,
		cg.Currency=o.Currency,cg.DocToBaseExhRate=o.DocToBaseExhRate,cg.Fee=o.Fee
	    FROM WorkFlow.CaseGroup Cg
	    inner join ClientCursor.Opportunity O ON O.Id=CG.OpportunityId WHERE O.CompanyId=@CompanyId AND  O.Id =@OpportunityId and cg.IsMainService is null

	    Update ClientCursor.Opportunity Set SyncCaseStatus='UpdateCompleted',SyncCaseRemarks=null,SyncCaseDate=@GetDATE Where Id=@OpportunityId And CompanyId=@CompanyId

		Declare @Caseid uniqueidentifier;

		SET @Caseid = (select id from WorkFlow.CaseGroup where OpportunityId=@OpportunityId and CompanyId=@CompanyId)

		Delete WorkFlow.CaseDesignation where CaseId=@Caseid

		INSERT INTO WorkFlow.CaseDesignation ( ID,CaseId,DefaultRate,Currency,BillingRate,BillCurrency,EstdHours,RecOrder,
		Status,Designation,DepartmentDesignationId)
       

	   SELECT  NEWID() AS Id,@Caseid AS CaseId,d.Rate,d.Currency,d.BillingRate,d.BillCurrency,d.EstdHours,d.RecOrder,d.Status,d.Designation,
       d.DepartmentDesignationId
       FROM ClientCursor.OpportunityDesignation D 
	   Inner join ClientCursor.Opportunity O On o.id=d.OpportunityId
	   WHERE  o.Id=@OpportunityId and o.CompanyId=@CompanyId and FeeType='Variable'

	   END 
	   END
	   End
	   End
	  


	   END
	Fetch Next From CaseId_Csr Into @OpportunityId,@AccountId,@ServiceId
	End
	Close CaseId_Csr
	Deallocate CaseId_Csr

	IF (@Default = 0)
	BEGIN
	select * from @CaseNumber
	END
	  --COMMIT TRANSACTION;
   --   END TRY
   --   BEGIN CATCH
	  --Declare @ErrorMessage Nvarchar(4000)
	  --ROLLBACK;
	  --Select @ErrorMessage=error_message();
	  --Raiserror(@ErrorMessage,16,1);
   --   END CATCH

	end 
GO
