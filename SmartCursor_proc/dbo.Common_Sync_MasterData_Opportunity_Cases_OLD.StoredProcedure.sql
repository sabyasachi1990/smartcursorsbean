USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_Sync_MasterData_Opportunity_Cases_OLD]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  procedure [dbo].[Common_Sync_MasterData_Opportunity_Cases_OLD] ---- Exec [dbo].[Common_Sync_MasterData_Opportunity_Cases] 19,'D4B20B18-C208-FD9D-3D71-E4CADABC34E9' ,'Add'
@CompanyId  Int,
@OpportunityId uniqueidentifier,
@Action Varchar(50)
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
--Declare @CompanyId  Int=1
    
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

            If Not Exists ( SELECT Id From WorkFlow.Client  where CompanyId=@CompanyId and AccountId=@AccountId)
			Begin 
	
			EXEC  [dbo].[Common_Sync_MasterData] @CompanyId,'Account',@AccountId,'Add'

		    END
		    If  NOT  Exists ( SELECT Id From WorkFlow.CaseGroup  where CompanyId=@CompanyId and OpportunityId=@OpportunityId)
			Begin 
			    IF Exists( select Id from  Common.Service where IsSplitEnable=1 and id=@ServiceId)
				BEGIN
				  SET @ClientId =( select  ClientId from ClientCursor.Account where CompanyId=@CompanyId and id=@AccountId)
				  SET @MainServiceId =( select MainServiceId from  Common.Service where IsSplitEnable=1 and id=@ServiceId)
				  SET @SubServiceId =( select SubServiceId from  Common.Service where IsSplitEnable=1 and id=@ServiceId)
	               SET @NewCaseId=NewID()
				   SET @NewCaseId1=NewID()
				   SET @GetDATE=Getdate()

				      declare @SystemRefnum Nvarchar (max)=( select replace( replace ((select replace ('CE-{SERVICEGROUP}{SERVICE}-{YYYY}-','{SERVICEGROUP}', (SELECT  SG.Code   FROM Common.Service S 
	                  INNER JOIN Common.ServiceGroup SG ON SG.ID=S.ServiceGroupId
	                  WHERE S.CompanyId=@CompanyId AND S.Id=@ServiceId))) ,'{SERVICE}', (SELECT  S.Code   FROM Common.Service S 
	                  INNER JOIN Common.ServiceGroup SG ON SG.ID=S.ServiceGroupId
	                  WHERE S.CompanyId=@CompanyId AND S.Id=@ServiceId)),'{YYYY}', (select year(getdate()))))

	                 declare @GeneratedNumber Nvarchar (max)=(Select GeneratedNumber From Common.AutoNumber 
					 Where CompanyId=@CompanyId And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))

				   SET @SysRef= Right('0000000000'+Cast((@GeneratedNumber+2 ) As varchar),Len(@GeneratedNumber))
				  Declare @RefNumber varchar(100)= CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+1 ) As varchar),Len(@GeneratedNumber)))
				  Declare @RefNumber1 varchar(100)= CONCAT(@SystemRefnum,Right('0000000000'+Cast((@GeneratedNumber+2 ) As varchar),Len(@GeneratedNumber)))

				   Insert into WorkFlow.CaseGroup (Id ,Name,CompanyId,ServiceCompanyId,ServiceGroupId,ServiceId,Type,Nature,FromDate,ToDate,FeeType,Fee  ,
	   Currency,RecommendedFee,RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,Remarks,
	   Status,OpportunityId,ReasonForCancellation,ScopeOfWork,SyncOppId,SyncOppDate,CreatedDate,Stage,
	   ClientId,CaseNumber,IsMainService,MainOrSubCaseId,ModifiedBy,SystemRefNo,IsServiceNatureWOWF,ServiceNatureType,UserCreated)
	

	      SELECT @NewCaseId as CaseId,Name,CompanyId,ServiceCompanyId,ServiceGroupId,ServiceId,Type,Nature,FromDate,ToDate,FeeType,MainServiceFee, 
	   Currency,RecommendedFee,RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,Remarks,
	  Status,id as OpportunityId,ReasonForCancellation,( select RecurringScopeofWork from  Common.Service where  id=@MainServiceId),Id as OpportunityId,@GetDATE AS SyncOppDate ,@GetDATE AS CreatedDate,'Unassigned' AS Stage,
	  @ClientId as ClientId ,@RefNumber as CaseNumber ,1 as IsMainService,@NewCaseId1 as MainOrSubCaseId, ModifiedBy,@RefNumber as SystemRefNo
	  ,(select IsRecurringWOWF AS IsServiceNatureWOWF from  Common.Service where  id=@ServiceId),(select IsRecurringWOWF AS ServiceNatureType from  Common.Service where  id=@ServiceId),'System' as  UserCreated
	  FROM ClientCursor.Opportunity WHERE CompanyId=@CompanyId AND  ID =@OpportunityId and MainServiceFee is not null


	          Insert into WorkFlow.CaseGroup (Id ,Name,CompanyId,ServiceCompanyId,ServiceGroupId,ServiceId,Type,Nature,FromDate,ToDate,FeeType,Fee ,
	   Currency,RecommendedFee,RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,Remarks,
	   Status,OpportunityId,ReasonForCancellation,ScopeOfWork,SyncOppId,SyncOppDate,CreatedDate,Stage,
	   ClientId,CaseNumber,IsMainService,MainOrSubCaseId,ModifiedBy,SystemRefNo,IsServiceNatureWOWF,ServiceNatureType,UserCreated)
	  
	      SELECT @NewCaseId1 as CaseId,Name,CompanyId,ServiceCompanyId,ServiceGroupId,ServiceId,Type,Nature,FromDate,ToDate,FeeType,SubServiceFee, 
	  Currency,RecommendedFee,RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,Remarks,
	  Status,id as OpportunityId,ReasonForCancellation,( select RecurringScopeofWork from  Common.Service where  id=@SubServiceId),Id as OpportunityId,@GetDATE AS SyncOppDate ,@GetDATE AS CreatedDate,'Unassigned' AS Stage,
	  @ClientId as ClientId ,@RefNumber1 as CaseNumber ,0 as IsMainService,@NewCaseId as MainOrSubCaseId, ModifiedBy,@RefNumber1 as SystemRefNo
	  ,(select IsRecurringWOWF AS IsServiceNatureWOWF from  Common.Service where   id=@ServiceId),(select IsRecurringWOWF AS ServiceNatureType from  Common.Service where  id=@ServiceId),'System' as  UserCreated
	  FROM ClientCursor.Opportunity WHERE CompanyId=@CompanyId AND  ID =@OpportunityId and SubServiceFee is not null

		 Update ClientCursor.Opportunity Set CaseId=@NewCaseId,SyncCaseId=@NewCaseId,SyncCaseStatus='UpadeteCompleted',SyncCaseRemarks=null,SyncCaseDate=@GetDATE Where Id=@OpportunityId And CompanyId=@CompanyId

		 Insert Into WorkFlow.CaseStatusChange (ID ,CompanyId,CaseId,State,ModifiedBy,ModifiedDate)
		 Values(NEWID(),@CompanyId,@NewCaseId,'Unassigned','System',@GetDATE)
		  Insert Into WorkFlow.CaseStatusChange (ID ,CompanyId,CaseId,State,ModifiedBy,ModifiedDate)
		 Values(NEWID(),@CompanyId,@NewCaseId1,'Unassigned','System',@GetDATE)
	

	  UPDATE a set  GeneratedNumber=@SysRef From Common.AutoNumber A
		Where CompanyId=@CompanyId And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor')


		 insert into Common.TimeLogItem  (id,CompanyId,type,SubType,ChargeType,SystemType,
	 SystemId,IsSystem,ApplyToAll,UserCreated,CreatedDate,Status,Hours,Days) 
		 
		 Values ( Newid() ,@CompanyId,@RefNumber, (select name  from  WorkFlow.client  where CompanyId=@CompanyId and id=@ClientId),'Chargeable','CaseGroup',
	     @NewCaseId,1,0,@GetDATE,@GetDATE,1,0,0  )


		 	 insert into Common.TimeLogItem  (id,CompanyId,type,SubType,ChargeType,SystemType,
	        SystemId,IsSystem,ApplyToAll,UserCreated,CreatedDate,Status,Hours,Days) 
		 
		 Values ( Newid() ,@CompanyId,@RefNumber1, (select name  from  WorkFlow.client  where CompanyId=@CompanyId and id=@ClientId),'Chargeable','CaseGroup',
	     @NewCaseId1,1,0,@GetDATE,@GetDATE,1,0,0  )





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
	    SET @ClientId =( select  ClientId from ClientCursor.Account where CompanyId=@CompanyId and id=@AccountId)
		SET @NewCaseId=NewID()
		SET @GetDATE=Getdate()
		             declare @SystemRefnum1 Nvarchar (max)=( select replace( replace ((select replace ('CE-{SERVICEGROUP}{SERVICE}-{YYYY}-','{SERVICEGROUP}', (SELECT  SG.Code   FROM Common.Service S 
	                  INNER JOIN Common.ServiceGroup SG ON SG.ID=S.ServiceGroupId
	                  WHERE S.CompanyId=@CompanyId AND S.Id=@ServiceId))) ,'{SERVICE}', (SELECT  S.Code   FROM Common.Service S 
	                  INNER JOIN Common.ServiceGroup SG ON SG.ID=S.ServiceGroupId
	                  WHERE S.CompanyId=@CompanyId AND S.Id=@ServiceId)),'{YYYY}', (select year(getdate()))))

	                 declare @GeneratedNumber1 Nvarchar (max)=(Select GeneratedNumber From Common.AutoNumber 
					 Where CompanyId=@CompanyId And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor'))

				   SET @SysRef= Right('0000000000'+Cast((@GeneratedNumber1+1 ) As varchar),Len(@GeneratedNumber1))
	            Declare @RefNumber2 varchar(100)= CONCAT(@SystemRefnum1,Right('0000000000'+Cast((@GeneratedNumber1+1 ) As varchar),Len(@GeneratedNumber1)))

		  Insert into WorkFlow.CaseGroup (Id ,Name,CompanyId,ServiceCompanyId,ServiceGroupId,ServiceId,Type,Nature,FromDate,ToDate,FeeType,Fee  ,
	   Currency,RecommendedFee,RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,Remarks,
	   Status,OpportunityId,ReasonForCancellation,ScopeOfWork,SyncOppId,SyncOppDate,CreatedDate,Stage,
	   ClientId,CaseNumber, ModifiedBy,SystemRefNo,IsServiceNatureWOWF,ServiceNatureType,UserCreated)
			    

      SELECT @NewCaseId as CaseId,Name,CompanyId,ServiceCompanyId,ServiceGroupId,ServiceId,Type,Nature,FromDate,ToDate,FeeType,Fee, 
	  Currency,RecommendedFee,RecoCurrency,TargettedRecovery,TotalEstdHours,SpecialRemarks,Remarks,
	  Status,id as OpportunityId,ReasonForCancellation,RecurringScopeofWork,Id as OpportunityId,@GetDATE AS SyncOppDate ,@GetDATE AS CreatedDate ,'Unassigned' AS Stage,
	  @ClientId as ClientId ,@RefNumber2 as CaseNumber , ModifiedBy,@RefNumber2 as SystemRefNo
	  ,(select IsRecurringWOWF AS IsServiceNatureWOWF from  Common.Service where  id=@ServiceId),(select IsRecurringWOWF AS ServiceNatureType from  Common.Service where  id=@ServiceId),'System' as  UserCreated
	  FROM ClientCursor.Opportunity WHERE CompanyId=@CompanyId AND  ID =@OpportunityId ---and SubServiceFee is not null	


	  Update ClientCursor.Opportunity Set CaseId=@NewCaseId,SyncCaseId=@NewCaseId,SyncCaseStatus='Completed',SyncCaseRemarks=null,SyncCaseDate=@GetDATE Where Id=@OpportunityId And CompanyId=@CompanyId

	   

		 Insert Into WorkFlow.CaseStatusChange (ID ,CompanyId,CaseId,State,ModifiedBy,ModifiedDate)
		 Values(NEWID(),@CompanyId,@NewCaseId,'Unassigned','System',@GetDATE)

		 INSERT INTO WorkFlow.CaseDesignation ( ID,CaseId,DefaultRate,Currency,BillingRate,BillCurrency,EstdHours,RecOrder,
		Status,Designation,DepartmentDesignationId)
       

	   SELECT  NEWID() AS Id,@NewCaseId AS CaseId,d.DefaultRate,d.Currency,d.BillingRate,d.BillCurrency,d.EstdHours,d.RecOrder,d.Status,d.Designation,
       d.DepartmentDesignationId
       FROM ClientCursor.OpportunityDesignation D 
	   Inner join ClientCursor.Opportunity O On o.id=d.OpportunityId
	   WHERE  o.Id=@OpportunityId and o.CompanyId=@CompanyId and FeeType='Variable'

	    UPDATE a set  GeneratedNumber=@SysRef From Common.AutoNumber A
		Where CompanyId=@CompanyId And EntityType='WorkFlow Case' And ModuleMasterId=(Select Id From Common.ModuleMaster Where Name='Workflow Cursor')


			 insert into Common.TimeLogItem  (id,CompanyId,type,SubType,ChargeType,SystemType,
	         SystemId,IsSystem,ApplyToAll,UserCreated,CreatedDate,Status,Hours,Days) 
		 
		 Values ( Newid() ,@CompanyId,@RefNumber2, (select name  from  WorkFlow.client  where CompanyId=@CompanyId and id=@ClientId),'Chargeable','CaseGroup',
	     @NewCaseId,1,0,@GetDATE,@GetDATE,1,0,0  )



	  END 
	  END
	  END
	  Else If(@Action='Edit')
			Begin
				If Exists (Select Id From WorkFlow.Client Where AccountId=@AccountId And CompanyId=@CompanyId)
				Begin

				 IF Exists( select Id from  Common.Service where IsSplitEnable=1 and id=@ServiceId)
				BEGIN
				SET @GetDATE=Getdate()
		Update  cg set CG.Fee=O.MainServiceFee,CG.SyncOppStatus='UpdateCompleted',cg.SyncOppDate=@GetDATE,cg.SyncOppRemarks=null,
	    cg.ModifiedBy=o.ModifiedBy,cg.ModifiedDate=o.ModifiedDate , cg.ScopeOfWork=o.RecurringScopeofWork,CG.FromDate=O.FromDate , CG.ToDate=O.ToDate
	    FROM WorkFlow.CaseGroup Cg
	    inner join ClientCursor.Opportunity O ON O.Id=CG.OpportunityId WHERE O.CompanyId=@CompanyId AND  O.Id =@OpportunityId and cg.IsMainService =1

	    Update ClientCursor.Opportunity Set SyncCaseStatus='UpdateCompleted',SyncCaseRemarks=null,SyncCaseDate=@GetDATE Where Id=@OpportunityId And CompanyId=@CompanyId


		   
		 Update cg set CG.Fee=O.SubServiceFee,CG.SyncOppStatus='UpdateCompleted',cg.SyncOppDate=@GetDATE,cg.SyncOppRemarks=null,
	    cg.ScopeOfWork=o.RecurringScopeofWork,cg.ModifiedBy=o.ModifiedBy,cg.ModifiedDate=o.ModifiedDate,CG.FromDate=O.FromDate , CG.ToDate=O.ToDate
	    FROM WorkFlow.CaseGroup Cg
	    inner join ClientCursor.Opportunity O ON O.Id=CG.OpportunityId WHERE O.CompanyId=@CompanyId AND  O.Id =@OpportunityId and cg.IsMainService=0

	    Update ClientCursor.Opportunity Set SyncCaseStatus='UpdateCompleted',SyncCaseRemarks=null,SyncCaseDate=@GetDATE Where Id=@OpportunityId And CompanyId=@CompanyId
	  	
		 END

		 ELSE 
	     BEGIN 
		 SET @GetDATE=Getdate()
	   	Update cg set CG.Fee=O.Fee,CG.SpecialRemarks=O.SpecialRemarks,CG.Remarks=O.Remarks,CG.SyncOppStatus='UpdateCompleted',cg.SyncOppDate=@GetDATE,cg.SyncOppRemarks=null,
	    cg.ScopeOfWork=o.RecurringScopeofWork,cg.ModifiedBy=o.ModifiedBy,cg.ModifiedDate=o.ModifiedDate, CG.FromDate=O.FromDate , CG.ToDate=O.ToDate 
	    FROM WorkFlow.CaseGroup Cg
	    inner join ClientCursor.Opportunity O ON O.Id=CG.OpportunityId WHERE O.CompanyId=@CompanyId AND  O.Id =@OpportunityId and cg.IsMainService is null

	    Update ClientCursor.Opportunity Set SyncCaseStatus='UpdateCompleted',SyncCaseRemarks=null,SyncCaseDate=@GetDATE Where Id=@OpportunityId And CompanyId=@CompanyId
	   END 
	   END
	   END


	   END
	Fetch Next From CaseId_Csr Into @OpportunityId,@AccountId,@ServiceId
	End
	Close CaseId_Csr
	Deallocate CaseId_Csr
	end 

	   

GO
