USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SeedDataFor_Service_InitialSetup]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



    CREATE Procedure [dbo].[Proc_SeedDataFor_Service_InitialSetup] --- exec [dbo].[Proc_SeedDataFor_Service_InitialSetup] @UNIQUE_COMPANY_ID ,@NEW_COMPANY_ID

 -- 	EXEC   [dbo].[Proc_SeedDataFor_Service_InitialSetup] 2439,1483
	--@NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID


     @NEW_COMPANY_ID bigint,
	 @UNIQUE_COMPANY_ID bigint

	 as
	  begin 

    Declare @CompanyId bigint;
	Declare @ServiceGroupid bigint;
	Declare @ServiceGroupidnew bigint;
	Declare @Serviceid bigint;
	Declare @code Nvarchar(100);
	Declare @name Nvarchar(100);
	Declare @CoaId bigint
	Declare @ChartOfAccount Nvarchar(max)
   Declare @CoaIdnew bigint
   Declare @Itemid uniqueidentifier
   	Declare @sercode Nvarchar(100)
    Declare @sername Nvarchar(100);
	Declare @serCoaId bigint
	Declare @sritemId uniqueidentifier
	Declare @Serviceidnew bigint
	 Declare @inid uniqueidentifier;
	Declare @IncidentalType nvarchar(200);
	Declare @Category nvarchar(200);
	Declare @Itemname nvarchar(200);
	Declare @inCOAId bigint;
	Declare @inChartOfAccount Nvarchar(100);
	Declare @inCOAIdnew bigint
	Declare @inChartOfAccountnew nvarchar(200)
	Declare @ChargeBy nvarchar(60)

  
      Declare ServiceGruop_Get Cursor For
	  select id,code,name,CompanyId from Common.ServiceGroup  where CompanyId=@UNIQUE_COMPANY_ID
	  Open ServiceGruop_Get
	fetch next from ServiceGruop_Get Into @ServiceGroupid,@code,@name,@CompanyId
	While @@FETCH_STATUS=0
    Begin

	If Not Exists( select id from Common.ServiceGroup  where CompanyId=@NEW_COMPANY_ID and Name=@name and code=@code)
	Begin 

--=======================select * from  Common.ServiceGroup where CompanyId=@UNIQUE_COMPANY_ID 

	 set @ServiceGroupidnew=( select max(Id)+1 as Id  FROM Common.ServiceGroup)

INSERT INTO Common.ServiceGroup  (Id, Code, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate,Version,Status,DefaultDays,bizappservicegrpid,
 CursorId ,ApprovalName,ApprovalDate,ApprovalDaysAndMonths)

SELECT @ServiceGroupidnew as Id, Code, Name, @NEW_COMPANY_ID as CompanyId, RecOrder, Remarks, 'system' as UserCreated, Getutcdate() as CreatedDate,Version,Status,DefaultDays,bizappservicegrpid,
 CursorId ,ApprovalName,ApprovalDate,ApprovalDaysAndMonths FROM Common.ServiceGroup
WHERE CompanyId=@CompanyId and id=@ServiceGroupid;	
--======================================================== cursor for sevice
     Declare Service_Get Cursor For
	  select id,code,name,CoaId,SyncItemId from Common.Service  WHERE 
	   ServiceGroupId in (select  id  from Common.ServiceGroup where CompanyId=@CompanyId and  id=@ServiceGroupid)
	  Open Service_Get
	fetch next from Service_Get Into @Serviceid,@sercode,@sername,@serCoaId,@sritemId
	While @@FETCH_STATUS=0
    Begin

--=======================select * from  [Bean].[Item] where CompanyId=@UNIQUE_COMPANY_ID and COAId=@CoaId

 set @CoaId= (select  Distinct CoaId  from  Common.Service WHERE id=@Serviceid and CoaId=@serCoaId and CoaId is not null)

 set @ChartOfAccount = (select Distinct Name from  Bean.ChartOfAccount where id=@CoaId and CompanyId=@UNIQUE_COMPANY_ID)
 
 set @CoaIdnew = (select Distinct Id from  Bean.ChartOfAccount where name=@ChartOfAccount and CompanyId=@NEW_COMPANY_ID)

 set @Serviceidnew=( select max(Id)+1 as Id  FROM Common.Service)

 --=========================== select * from  [Bean].[Item] where CompanyId=@UNIQUE_COMPANY_ID and COAId=@CoaId

    if @sritemId is not null
     begin
	    set @Itemid=Newid()

    	insert into  [Bean].[Item] (Id,CompanyId,Code,Description,UOM,UnitPrice,Currency,COAId,DefaultTaxcodeId,AllowableDis,Notes,
	RecOrder,Remarks,UserCreated,CreatedDate,Version,Status,AppliesTo,IsEditabled,IsAllowable,IsSaleItem,IsPurchaseItem,IsAccountEditable,IsAllowableNotAllowableActivated,
	IsPLAccount,IsExternalData,IsIncidental,DocumentId,SyncServiceId,SyncServiceStatus,SyncServicedate,SyncServiceRemarks,IncidentalType)

	 select  @Itemid as Id, @NEW_COMPANY_ID as CompanyId,Code,Description,UOM,UnitPrice,Currency,@CoaIdnew as COAId,DefaultTaxcodeId,AllowableDis,Notes,
	RecOrder,Remarks,'system' as UserCreated, Getutcdate() as CreatedDate,Version,Status,AppliesTo,IsEditabled,IsAllowable,IsSaleItem,IsPurchaseItem,IsAccountEditable,IsAllowableNotAllowableActivated,
	IsPLAccount,IsExternalData,IsIncidental,@Serviceidnew as DocumentId,@Serviceidnew as SyncServiceId,SyncServiceStatus,SyncServicedate,SyncServiceRemarks,IncidentalType from  [Bean].[Item] where CompanyId=@UNIQUE_COMPANY_ID and Id=@sritemId
     end 
--=============================select * from   Common.Service WHERE  ServiceGroupId in (select  id  from Common.ServiceGroup where CompanyId=@CompanyId and  id=@ServiceGroupid)


INSERT INTO Common.Service (Id, Code, Name, ServiceGroupId, RecOrder, Remarks, UserCreated, CreatedDate,
 Version,Status,IsRecurring,IsRenewal,IsAdHoc ,IsFixesFeeType,IsVariableFeeType,TargettedRecovery,IsAdHocFromToDate,AdhocScopeOfWork,
 RecurringScopeofWork,CompanyId,IsMonthly,IsQuarterly,IsSemiAnnually,IsAnnually,KeyTermsTemplateId,StandardTermsTemplateId,DefaultTemplateId,ApplicableTaxCode,
 IsSplitEnable,MainServiceId,SubServiceId,MainServiceCode,SubServiceCode,KeyTermsContent,StandardTermsContent,QuotationContent,IsRecurringWOWF,IsAdHocWOWF,
 IsGSTActivate,CoaId,TaxCodeId,ApprovalName,ApprovalDate,Days,ApprovalDaysAndMonths,SyncItemId,SyncItemStatus,SyncItemDate,SyncItemRemarks)

SELECT @Serviceidnew as Id, Code, Name, @ServiceGroupidnew as ServiceGroupId, RecOrder, Remarks, 'system' as UserCreated, GETUTCDATE() as CreatedDate,
 Version,Status,IsRecurring,IsRenewal,IsAdHoc ,IsFixesFeeType,IsVariableFeeType,TargettedRecovery,IsAdHocFromToDate,AdhocScopeOfWork,
 RecurringScopeofWork,@NEW_COMPANY_ID as CompanyId,IsMonthly,IsQuarterly,IsSemiAnnually,IsAnnually,KeyTermsTemplateId,StandardTermsTemplateId,DefaultTemplateId,ApplicableTaxCode,
 IsSplitEnable,MainServiceId,SubServiceId,MainServiceCode,SubServiceCode,KeyTermsContent,StandardTermsContent,QuotationContent,IsRecurringWOWF,IsAdHocWOWF,
 IsGSTActivate,@CoaIdnew as CoaId,TaxCodeId,ApprovalName,ApprovalDate,Days,ApprovalDaysAndMonths,@Itemid as SyncItemId, SyncItemStatus,GETUTCDATE() as SyncItemDate,SyncItemRemarks FROM Common.Service
WHERE  ServiceGroupId in (select  id  from Common.ServiceGroup where CompanyId=@CompanyId and  id=@ServiceGroupid)
 and id=@Serviceid and code=@sercode and name=@sername



 fetch next from Service_Get Into @Serviceid,@sercode,@sername,@serCoaId,@sritemId
				End
	Close Service_Get
	Deallocate Service_Get
	end

 fetch next from ServiceGruop_Get Into @ServiceGroupid,@code,@name,@CompanyId
				End
	Close ServiceGruop_Get
	Deallocate ServiceGruop_Get
	--=============================select * from   Common.Service WHERE  ServiceGroupId in (select  id  from Common.ServiceGroup where CompanyId=@CompanyId and  id=@ServiceGroupid)

	--===============================================================curosr for sevices
	If Not Exists( select Id from Common.TimeLogSettings where CompanyId=@NEW_COMPANY_ID )
	Begin 
 --========================SELECT * FROM  Common.TimeLogSettings where CompanyId=@UNIQUE_COMPANY_ID
  Insert into Common.TimeLogSettings (Id,CompanyId,TimeLockOpenPeriod,TimeLockClosePeriod,AllowLogOperator,AllowLogValue,
  AllowLogPeriod,UserCreated,CreatedDate,Version,Status)
  Select Newid(),@NEW_COMPANY_ID as CompanyId,TimeLockOpenPeriod,TimeLockClosePeriod,AllowLogOperator,AllowLogValue,
  AllowLogPeriod, 'system' as UserCreated, getutcdate() as CreatedDate,Version,Status from  Common.TimeLogSettings
  where CompanyId= @UNIQUE_COMPANY_ID
 --========================SELECT * FROM  Common.TimeLogSettings where CompanyId=@UNIQUE_COMPANY_ID
  end 

  	If Not Exists( select Id from [Common].[TimeLogItem] where CompanyId=@NEW_COMPANY_ID and SystemId is null   )
	Begin 

 --========================= SELECT * FROM [Common].[TimeLogItem] where CompanyId=@UNIQUE_COMPANY_ID

   Insert into [Common].[TimeLogItem](Id,CompanyId,Type,SubType,ChargeType,SystemType,SystemId,
   IsSystem,ApplyToAll,StartDate,EndDate,Remarks,RecOrder,UserCreated,CreatedDate,Version,
   Status,Hours,Days,FirstHalfFromTime,FirstHalfToTime,FirstHalfTotalHours,SecondHalfFromTime,SecondHalfToTime,SecondHalfTotalHours, IsMain)

   select   Newid(),@NEW_COMPANY_ID as CompanyId,Type,SubType,ChargeType, SystemType, SystemId,
    IsSystem, ApplyToAll,  StartDate,  EndDate,  Remarks,  RecOrder,'system' as UserCreated,Getutcdate() as CreatedDate, Version,
      Status, Hours, Days, FirstHalfFromTime, FirstHalfToTime, FirstHalfTotalHours,
    SecondHalfFromTime, SecondHalfToTime, SecondHalfTotalHours,  IsMain
    from  [Common].[TimeLogItem] where CompanyId= @UNIQUE_COMPANY_ID and SystemId is null  
	end
	 --========================= SELECT * FROM [Common].[TimeLogItem] where CompanyId=@UNIQUE_COMPANY_ID



	 --========================= SELECT * FROM WorkFlow.IncidentalClaimItem where CompanyId=@UNIQUE_COMPANY_ID

   Declare Incidental_Get Cursor For
	 select  id,IncidentalType,Category,Item,ChargeBy , COAId from WorkFlow.IncidentalClaimItem where CompanyId=@UNIQUE_COMPANY_ID 
	  Open Incidental_Get
	fetch next from Incidental_Get Into @inid,@IncidentalType,@Category,@Itemname,@ChargeBy,@inCOAId
	While @@FETCH_STATUS=0
    Begin
		If Not Exists(  select id from WorkFlow.IncidentalClaimItem where CompanyId= @NEW_COMPANY_ID  and IncidentalType=@IncidentalType
	and  Category=@Category and Item=@Itemname and ChargeBy= @ChargeBy  )
	Begin 

 set @inChartOfAccount = (select Distinct Name from  Bean.ChartOfAccount where id=@inCOAId and CompanyId=@UNIQUE_COMPANY_ID)
 
 set @inCOAIdnew = (select Distinct Id from  Bean.ChartOfAccount where name=@inChartOfAccount and CompanyId=@NEW_COMPANY_ID)
 set @inChartOfAccountnew = (select Distinct Id from  Bean.ChartOfAccount where name=@inChartOfAccount and CompanyId=@NEW_COMPANY_ID)
	
   Insert into WorkFlow.IncidentalClaimItem (Id,CompanyId,ItemDescription,ChargeBy,TaxCodeId,Tax,Charge,MinCharge,FeePercentage
   ,ClaimUnit,COAName,Category,Item,Remarks,RecOrder,UserCreated, CreatedDate,Version,Status,COAId,IncidentalType)

   select   Newid() as Id,@NEW_COMPANY_ID as CompanyId,ItemDescription,ChargeBy,TaxCodeId,Tax,Charge,MinCharge,FeePercentage
   ,ClaimUnit,@inChartOfAccountnew as COAName,Category,Item,Remarks,RecOrder,'system' as UserCreated, getutcdate() as CreatedDate,Version,Status,@inCOAIdnew as COAId,IncidentalType
    from  WorkFlow.IncidentalClaimItem where CompanyId= @UNIQUE_COMPANY_ID  and id=@inid and IncidentalType=@IncidentalType
	and  Category=@Category and Item=@Itemname and ChargeBy= @ChargeBy

	 end 
	 fetch next from Incidental_Get Into  @inid,@IncidentalType,@Category,@Itemname,@ChargeBy,@inCOAId
				End
	Close Incidental_Get
	Deallocate Incidental_Get
--===================================SELECT * FROM WorkFlow.IncidentalClaimItem where CompanyId=@UNIQUE_COMPANY_ID

	end




 

GO
