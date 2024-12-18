USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SeedDataFor_ServiceGroup]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


    CREATE Procedure [dbo].[Proc_SeedDataFor_ServiceGroup] --- exec Proc_SeedDataFor_ServiceGroup @UNIQUE_COMPANY_ID ,@NEW_COMPANY_ID

 -- 	EXEC   [dbo].[Proc_SeedDataFor_ServiceGroup ]
	--@NEW_COMPANY_ID=@NEW_COMPANY_ID,@UNIQUE_COMPANY_ID=@UNIQUE_COMPANY_ID


     @NEW_COMPANY_ID bigint,
	 @UNIQUE_COMPANY_ID bigint

	 as
	  begin 

    Declare @CompanyId bigint;
	Declare @ServiceGroupid bigint;
	Declare @ServiceGroupidnew bigint;
	Declare @Serviceid bigint;
  
      Declare Service_Get Cursor For
	  select id,CompanyId from Common.ServiceGroup  where CompanyId=@UNIQUE_COMPANY_ID
	  Open Service_Get
	fetch next from Service_Get Into @ServiceGroupid,@CompanyId
	While @@FETCH_STATUS=0
    Begin

	 set @ServiceGroupidnew=( select max(Id)+1 as Id  FROM Common.ServiceGroup)

INSERT INTO Common.ServiceGroup  (Id, Code, Name, CompanyId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy,ModifiedDate,Version,Status,DefaultDays,bizappservicegrpid,
 CursorId ,ApprovalName,ApprovalDate,ApprovalDaysAndMonths)

SELECT @ServiceGroupidnew as Id, Code, Name, @NEW_COMPANY_ID as CompanyId, RecOrder, Remarks, UserCreated, Getutcdate() as CreatedDate, ModifiedBy,Getutcdate() as ModifiedDate,Version,Status,DefaultDays,bizappservicegrpid,
 CursorId ,ApprovalName,ApprovalDate,ApprovalDaysAndMonths FROM Common.ServiceGroup
WHERE CompanyId=@CompanyId and id=@ServiceGroupid;	

set @Serviceid=( select max(Id) as Id  FROM Common.Service)


INSERT INTO Common.Service (Id, Code, Name, ServiceGroupId, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy,ModifiedDate,
 Version,Status,IsRecurring,IsRenewal,IsAdHoc ,IsFixesFeeType,IsVariableFeeType,TargettedRecovery,IsAdHocFromToDate,AdhocScopeOfWork,
 RecurringScopeofWork,CompanyId,IsMonthly,IsQuarterly,IsSemiAnnually,IsAnnually,KeyTermsTemplateId,StandardTermsTemplateId,DefaultTemplateId,ApplicableTaxCode,
 IsSplitEnable,MainServiceId,SubServiceId,MainServiceCode,SubServiceCode,KeyTermsContent,StandardTermsContent,QuotationContent,IsRecurringWOWF,IsAdHocWOWF,
 IsGSTActivate,CoaId,TaxCodeId,ApprovalName,ApprovalDate,Days,ApprovalDaysAndMonths,SyncItemId,SyncItemStatus,SyncItemDate,SyncItemRemarks)

SELECT @Serviceid+ROW_NUMBER () Over (Order By Id) as Id, Code, Name, @ServiceGroupidnew as ServiceGroupId, RecOrder, Remarks, UserCreated, GETUTCDATE() as CreatedDate, ModifiedBy,GETUTCDATE() as ModifiedDate,
 Version,Status,IsRecurring,IsRenewal,IsAdHoc ,IsFixesFeeType,IsVariableFeeType,TargettedRecovery,IsAdHocFromToDate,AdhocScopeOfWork,
 RecurringScopeofWork,@NEW_COMPANY_ID as CompanyId,IsMonthly,IsQuarterly,IsSemiAnnually,IsAnnually,KeyTermsTemplateId,StandardTermsTemplateId,DefaultTemplateId,ApplicableTaxCode,
 IsSplitEnable,MainServiceId,SubServiceId,MainServiceCode,SubServiceCode,KeyTermsContent,StandardTermsContent,QuotationContent,IsRecurringWOWF,IsAdHocWOWF,
 IsGSTActivate,CoaId,TaxCodeId,ApprovalName,ApprovalDate,Days,ApprovalDaysAndMonths,SyncItemId,SyncItemStatus,SyncItemDate,SyncItemRemarks FROM Common.Service
WHERE  ServiceGroupId in (select  id  from Common.ServiceGroup where CompanyId=@CompanyId and  id=@ServiceGroupid)
 
 fetch next from Service_Get Into @ServiceGroupid,@CompanyId
				End
	Close Service_Get
	Deallocate Service_Get
	end
GO
