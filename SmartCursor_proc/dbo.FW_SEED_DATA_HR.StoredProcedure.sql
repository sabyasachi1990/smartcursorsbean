USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[FW_SEED_DATA_HR]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[FW_SEED_DATA_HR](@UNIQUE_COMPANY_ID BIGINT,@NEW_COMPANY_ID BIGINT, @UNIQUE_ID uniqueidentifier)
AS
BEGIN         
	DECLARE @STATUS   INT
	DECLARE @CONTROLCODECATEGORY_ID_MODULE_MASTER_ID BIGINT
	DECLARE @MODULE_MASTER_ID_CONTROLCODECATEGORY_ID BIGINT
	DECLARE @IN_PROGRESS nvarchar(20) = 'In-Progress'
	DECLARE @COMPLETED nvarchar(20) = 'Completed'
	SET @STATUS = 1    
	--BEGIN TRANSACTION
	BEGIN TRY

	declare @ModuleId bigint = (select Id from Common.ModuleMaster where Name='HR Cursor')


	--=========== Control Code Category & Control Codes Insertion ====================================
	DECLARE @ControlCode_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@ControlCode_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_HR - ControlCodes Execution Started', GETUTCDATE() , '6.1' , NULL , @IN_PROGRESS )

		EXEC [dbo].[FW_CONTROL_CODE_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, 'HR Cursor'

	Update Common.DetailLog set Status = @COMPLETED where Id = @ControlCode_Unique_Identifier

	--=========== Module Detail Insertion ============================================================
	DECLARE @ModuleDetail_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@ModuleDetail_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_HR - ModuleDetail Execution Started', GETUTCDATE() , '6.2' , NULL , @IN_PROGRESS )

		EXEC [dbo].[FW_MODULE_DETAIL_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @ModuleId

	Update Common.DetailLog set Status = @COMPLETED where Id = @ModuleDetail_Unique_Identifier
   
    --=========== Initial Cursor Setup Insertion =====================================================
	DECLARE @InitialCursorSetup_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@InitialCursorSetup_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_HR - InitialCursorSetup Execution Started', GETUTCDATE() , '6.3' , NULL , @IN_PROGRESS )

		EXEC [dbo].[FW_INITIAL_CURSOR_SETUP_SEED] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @ModuleId


		update MD set status=2 from Common.ModuleDetail MD
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)

		update MD set status=1 from Common.ModuleDetail MD
		where MD.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)
		
		update ICS set Status=2 from Common.InitialCursorSetup ICS
		join Common.ModuleDetail MD on ICS.ModuleDetailId = MD.Id
		where ICS.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 2)

		update ICS set Status=1 from Common.InitialCursorSetup ICS
		join Common.ModuleDetail MD on ICS.ModuleDetailId = MD.Id
		where ICS.CompanyId=@NEW_COMPANY_ID and MD.GroupKey in (select f.GroupKey from Common.CompanyFeatures CF
		left join Common.Feature F on cf.FeatureId = F.Id 
		where CF.CompanyId=@NEW_COMPANY_ID and F.ModuleId=(select Id from Common.ModuleMaster where Name='Hr Cursor') and cf.Status = 1)

		Update Common.DetailLog set Status = @COMPLETED where Id = @InitialCursorSetup_Unique_Identifier

	--============ Auto number insertion===============================================================
	DECLARE @autoNumber_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@autoNumber_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_HR - AutoNumber Execution Started', GETUTCDATE() , '6.4' , NULL , @IN_PROGRESS )

	EXEC [dbo].[FW_AUTO_NUMBER_SEED_DATA] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @ModuleId

	Update Common.DetailLog set Status = @COMPLETED where Id = @autoNumber_Unique_Identifier

	--============================== GridMetaData ======================================================
	 DECLARE @gridmetadata_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@gridmetadata_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_HR - GridMetaData Execution Started', GETUTCDATE() , '6.5' , NULL , @IN_PROGRESS )

		EXEC [dbo].[FW_GRIDMETADATA_SEED_INSERTION] @UNIQUE_COMPANY_ID, @NEW_COMPANY_ID, @ModuleId

		Update Common.DetailLog set Status = @COMPLETED where Id = @gridmetadata_Unique_Identifier

	--=====================================================================================================



  --seed data querys
		DECLARE @evaluationDetail_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@evaluationDetail_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_HR - EvaluationDetails Execution Started', GETUTCDATE() , '6.6' , NULL , @IN_PROGRESS )

       Declare @EvaluationDetails_Cnt BIGINT;
	   select 	@EvaluationDetails_Cnt=Count(*)
       from 	[HR].[EvaluationDetails] where companyid=@NEW_COMPANY_ID	
	   IF @EvaluationDetails_Cnt=0
		   Begin
			  INSERT INTO  [HR].[EvaluationDetails] (Id, CompanyId, Name, Type, Value, Status,RecOrder)  
			  SELECT (NEWID()), @NEW_COMPANY_ID,Name, Type, Value, Status,RecOrder FROM [HR].[EvaluationDetails] WHERE COMPANYID=0
		   End

		 Update Common.DetailLog set Status = @COMPLETED where Id = @evaluationDetail_Unique_Identifier

	   ----------[HR].[WorkProfile]-----------------------------------------------

	   DECLARE @workProfile_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@workProfile_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_HR - WorkProfile Execution Started', GETUTCDATE() , '6.7' , NULL , @IN_PROGRESS )

       Declare @WorkProfile_Cnt BIGINT;
	   select 	@WorkProfile_Cnt=Count(*) from 	[HR].[WorkProfile] where companyid=@NEW_COMPANY_ID	
	   IF @WorkProfile_Cnt=0
   BEGIN

      INSERT INTO HR.WorkProfile (Id, CompanyId, WorkProfileName, WorkingHoursPerDay, Monday, Tuesday, Wednenday, Thursday, Friday, Saturday, Sunday, TotalWorkingDaysPerWeek, TotalWorkingHoursPerWeek, IsDefaultProfile, IsSuperUserRec, Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, Status, Version)
      SELECT NEWID(), @NEW_COMPANY_ID, WorkProfileName, WorkingHoursPerDay, Monday, Tuesday, Wednenday, Thursday, Friday, Saturday, Sunday, TotalWorkingDaysPerWeek, TotalWorkingHoursPerWeek, IsDefaultProfile, 1, Remarks, UserCreated, CreatedDate, null, null, RecOrder, Status, Version FROM HR.WorkProfile WHERE CompanyId=@UNIQUE_COMPANY_ID
	
   ------------- [Common].[AttendanceRules] ---------------------

     INSERT [Common].[AttendanceRules] ([Id], [CompanyId], [LateInTime], [LateInType], [LateInTimeType], [LateInStatus], [LateOutTime], [LateOutType], [LateOutTimeType], [LateOutStatus], [PreviousTime], [PreviousType], [PreviousTimeType], [PreviousStatus] ,[UserCreated]      ,[CreatedDate]      ,[ModifiedBy]      ,[ModifiedDate]      ,[Version]      ,[Status]) VALUES (NEWID(), @NEW_COMPANY_ID , 10, N'After', N'FromTime', 1, 240, N'After', N'ToTime', 1, 300, N'Before', N'FromTime', 0,'System',GETUTCDATE(),NULL,NULL,NULL,1)


---------[HR].[WorkProfileDetails]---------------------------------------

     INSERT INTO [HR].[WorkProfileDetails]  (Id, MasterId, Year, JanuaryDays, FebruaryDays, MarchDays, AprilDays, MayDays, JuneDays, JulyDays, AugustDays, SeptemberDays, OctoberDays, NovemberDays, DecemberDays, TotalWorkingHoursPerYear, TotalWorkingDaysPerYear,IsDefaultProfile,Remarks, UserCreated, CreatedDate, ModifiedDate, ModifiedBy, RecOrder, Status, Version)
     SELECT NEWID(), (SELECT Id FROM HR.WorkProfile WHERE CompanyId=@NEW_COMPANY_ID AND WorkProfileName = (select WorkProfileName FROM [HR].[WorkProfile] where Id = WD.MasterId and CompanyId = @UNIQUE_COMPANY_ID)) as [MasterId], WD.Year, WD.JanuaryDays, WD.FebruaryDays, WD.MarchDays, WD.AprilDays, WD.MayDays, WD.JuneDays, WD.JulyDays, WD.AugustDays, WD.SeptemberDays, WD.OctoberDays, WD.NovemberDays, WD.DecemberDays, WD.TotalWorkingHoursPerYear, WD.TotalWorkingDaysPerYear,WD.IsDefaultProfile, WD.Remarks, WD.UserCreated, GETUTCDATE() as [CreatedDate], null, null, WD.RecOrder, WD.Status, WD.Version 
     FROM [HR].[WorkProfileDetails] WD INNER JOIN [HR].[WorkProfile] W
     ON W.Id = WD.MasterId
     WHERE W.COMPANYID = @UNIQUE_COMPANY_ID
  END

	Update Common.DetailLog set Status = @COMPLETED where Id = @workProfile_Unique_Identifier

    ------------WorkProfile---

 update hr.WorkProfile set IsDefaultProfile=1 where WorkProfileName='5 Days/Week' and CompanyId=@NEW_COMPANY_ID

 update hr.WorkProfileDetails set IsDefaultProfile=1 where  MasterId in(select id from hr.WorkProfile where WorkProfileName='5 Days/Week' and CompanyId=@NEW_COMPANY_ID) and  [Year]=YEAR(GETUTCDATE())

 --============================================================
  IF exists(select * from Common.CompanyFeatures CF
			Join Common.Feature F on CF.FeatureId = F.Id
			where CF.CompanyId = @NEW_COMPANY_ID and F.Name='Payroll' and CF.Status=1)
	BEGIN
		IF exists(select * from Bean.ChartOfAccount where CompanyId=@NEW_COMPANY_ID and Name in (select distinct DefaultCOA from hr.PayComponent where CompanyId=0))
		BEGIN
			-- To update payroll COA - linked accounts
			update bean.ChartOfAccount set IsLinkedAccount=1, IsSystem=0 where CompanyId=@NEW_COMPANY_ID and name in (
			select distinct DefaultCOA from hr.PayComponent where CompanyId=@NEW_COMPANY_ID)
		END
	END

	--IF exists(select * from Common.CompanyFeatures CF
	--		Join Common.Feature F on CF.FeatureId = F.Id
	--		where CF.CompanyId = @NEW_COMPANY_ID and F.Name='Claim Management' and CF.Status=1)
	--BEGIN
	--    -- To insert claim COA
	--	If not exists(select * from Bean.ChartOfAccount where Name in ('Claims Clearing - Personal') and CompanyId=@NEW_COMPANY_ID)
	--	BEGIN
	--		insert into bean.ChartOfAccount ( Id,CompanyId,Code,Name,AccountTypeId,SubCategory,Category,Class,Nature,Currency,ShowRevaluation,CashflowType,AppliesTo,IsSystem,IsShowforCOA,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,IsSubLedger,IsCodeEditable,ShowCurrency,ShowCashFlow,ShowAllowable,IsRevaluation,Revaluation,DisAllowable,RealisedExchangeGainOrLoss,UnrealisedExchangeGainOrLoss,ModuleType,IsSeedData,SubsidaryCompanyId,IsBank,IsDebt,IsAllowableNotAllowableActivated,IsLinkedAccount,IsRealCOA,FRCoaId,FRPATId,FRRecOrder,CategoryId,SubCategoryId,TaxType,XeroCode,XeroName,XeroClass,XeroAccountTypeId,XeroAccountId,IsFromXero)

	--		select (SELECT MAX(Id) FROM Bean.ChartOfAccount)+ROW_NUMBER() OVER(ORDER BY ID)  AS Id,@NEW_COMPANY_ID,Code,Name,(Select Id from Bean.AccountType where Name='Other current assets' and CompanyId=@NEW_COMPANY_ID) as AccountTypeId, SubCategory,Category,Class,Nature,Currency,ShowRevaluation,CashflowType,AppliesTo,0,IsShowforCOA,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,IsSubLedger,IsCodeEditable,ShowCurrency,ShowCashFlow,ShowAllowable,IsRevaluation,Revaluation,DisAllowable,RealisedExchangeGainOrLoss,UnrealisedExchangeGainOrLoss,ModuleType,IsSeedData,SubsidaryCompanyId,IsBank,IsDebt,IsAllowableNotAllowableActivated,1,IsRealCOA,FRCoaId,FRPATId,FRRecOrder,CategoryId,SubCategoryId,TaxType,XeroCode,XeroName,XeroClass,XeroAccountTypeId,XeroAccountId,IsFromXero
	--			from Bean.ChartOfAccount where Name in ('Claims Clearing - Personal') and CompanyId=0 --and name not in (select Name from Bean.ChartOfAccount where Name in ('Claims Clearing - Personal') and CompanyId=@NEW_COMPANY_ID)
	--	END
	--	ELSE
	--	BEGIN
	--		update Bean.ChartOfAccount set IsLinkedAccount=1, IsSystem=0 where Name in ('Claims Clearing - Personal') and CompanyId=@NEW_COMPANY_ID
	--	END
	--END



 --====================== HR - Generic Templates Seed data ================================

 DECLARE @genericTemplates_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@genericTemplates_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_HR - Generic Templates Execution Started', GETUTCDATE() , '6.8' , NULL , @IN_PROGRESS )

	declare @cnt bigint = (select Count(GT.Id) from Common.GenericTemplate GT
							Join Common.TemplateType TT on TT.Id = GT.TemplateTypeId
							where TT.ModuleMasterId = (select Id from Common.ModuleMaster where Name='HR Cursor') and GT.CompanyId=@NEW_COMPANY_ID)
	If(@cnt = 0)
	BEGIN
		INSERT INTO Common.GenericTemplate ([Id],[CompanyId],[TemplateTypeId],[Name],[Code],[TempletContent],[IsSystem],[IsFooterExist],[IsHeaderExist],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[IsPartnerTemplate],[CursorName],[TemplateType],[Jurisdiction])

		SELECT NEWID(),@NEW_COMPANY_ID,GT.[TemplateTypeId],GT.[Name],GT.[Code],GT.[TempletContent],GT.[IsSystem],GT.[IsFooterExist],GT.[IsHeaderExist],GT.[RecOrder],GT.[Remarks],GT.[UserCreated],GETUTCDATE(),null,null,GT.[Version],1,GT.[IsPartnerTemplate],GT.[CursorName],GT.[TemplateType],[Jurisdiction]
		FROM Common.GenericTemplate GT
		Join Common.TemplateType TT on TT.Id = GT.TemplateTypeId 
		WHERE GT.CompanyId=@UNIQUE_COMPANY_ID and TT.ModuleMasterId = (select Id from Common.ModuleMaster where Name='HR Cursor') and TemplateType not in (select ISNULL(TemplateType,' ') from Common.GenericTemplate where CompanyId=@NEW_COMPANY_ID)
	END

	Declare @Jurisdiction nvarchar(250) = (select Jurisdiction from common.Company where Id=@NEW_COMPANY_ID)
	if(@Jurisdiction='India')
	Begin
		Delete Common.GenericTemplate where CompanyId=@NEW_COMPANY_ID and Name='PaySlip' and CursorName='HR Cursor' and Jurisdiction is null
	End
	else
	begin
		Delete Common.GenericTemplate where CompanyId=@NEW_COMPANY_ID and Name='PaySlip' and CursorName='HR Cursor' and Jurisdiction='India'
	end

    Update Common.DetailLog set Status = @COMPLETED where Id = @genericTemplates_Unique_Identifier
	----------hr pay component seed data sp-------	
	
	DECLARE @HrPayComponent_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@HrPayComponent_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_HR - HR Pay Component Execution Started', GETUTCDATE() , '6.9' , NULL , @IN_PROGRESS )

	Declare @CountryName nvarchar(250) = (select Jurisdiction from common.Company where Id=@NEW_COMPANY_ID)
	if(@CountryName='India')
	Begin
		Declare @PayComponent_Cnt BIGINT;
		select 	@PayComponent_Cnt=Count(*) from [Hr].[PayComponent] where companyid=@NEW_COMPANY_ID	and Juridication='India'   
		IF @PayComponent_Cnt=0
		BEGIN
			IF NOT EXISTS (SELECT * FROM [Hr].[PayComponent] WHERE  [CompanyId] = @NEW_COMPANY_ID and Juridication='India'   )
			BEGIN   
				INSERT INTO  [Hr].[PayComponent]  ( [Id],[CompanyId],[Name],[ShortCode],[Type],[WageType],[IsCPF],[IsNsPay],[IsTAX],[IsSDL],[IR8AItemSection],[PayMethod],[Amount],[PercentageComponent],[Percentage],[Formula],[IsAdjustable],[MaxCap],[ApplyTo],[IsExcludeFromGrossWage],[TaxClassification],[Reamrks],[UserCreated],[CreatedDate],[ModifiedDate],[ModifiedBy],[RecOrder],[Status],[IsSystem],[DefaultCOA],[COAId],[DefaultVendor], [Category],[Juridication], [IsDefault], [IsStatutoryComponent], [IsHide])  
					SELECT (NEWID()),@NEW_COMPANY_ID,[Name],[ShortCode],[Type],[WageType],[IsCPF],[IsNsPay],[IsTAX],[IsSDL],[IR8AItemSection],[PayMethod],[Amount],[PercentageComponent],[Percentage],[Formula],[IsAdjustable],[MaxCap],[ApplyTo],[IsExcludeFromGrossWage],[TaxClassification],[Reamrks],[UserCreated],GETUTCDATE(),null,null,[RecOrder],[Status],[IsSystem],[DefaultCOA],(select id from Bean.ChartOfAccount where CompanyId=@NEW_COMPANY_ID and [Name] = [DefaultCOA]),[DefaultVendor],[Category],'India', [IsDefault], [IsStatutoryComponent], [IsHide] FROM [Hr].[PayComponent]  WHERE COMPANYID=0 and Juridication='India'   
			END
		End;
	End
	else
	Begin
		Declare @PayComponent_CntNew BIGINT;
		select 	@PayComponent_CntNew=Count(*) from 	[Hr].[PayComponent]  where companyid=@NEW_COMPANY_ID	
		IF @PayComponent_CntNew=0
		BEGIN
			IF NOT EXISTS (SELECT * FROM [Hr].[PayComponent] WHERE  [CompanyId] = @NEW_COMPANY_ID)
			BEGIN   
				INSERT INTO  [Hr].[PayComponent]  ( [Id],[CompanyId],[Name],[ShortCode],[Type],[WageType],[IsCPF],[IsNsPay],[IsTAX],[IsSDL],[IR8AItemSection],[PayMethod],[Amount],[PercentageComponent],[Percentage],[Formula],[IsAdjustable],[MaxCap],[ApplyTo],[IsExcludeFromGrossWage],[TaxClassification],[Reamrks],[UserCreated],[CreatedDate],[ModifiedDate],[ModifiedBy],[RecOrder],[Status],[IsSystem],[DefaultCOA],[COAId],[DefaultVendor], [Category],[Juridication], [IsDefault], [IsStatutoryComponent], [IsHide])  
					SELECT (NEWID()),@NEW_COMPANY_ID,[Name],[ShortCode],[Type],[WageType],[IsCPF],[IsNsPay],[IsTAX],[IsSDL],[IR8AItemSection],[PayMethod],[Amount],[PercentageComponent],[Percentage],[Formula],[IsAdjustable],[MaxCap],[ApplyTo],[IsExcludeFromGrossWage],[TaxClassification],[Reamrks],[UserCreated],[CreatedDate],null,null,[RecOrder],[Status],[IsSystem],[DefaultCOA],(select id from Bean.ChartOfAccount where CompanyId=@NEW_COMPANY_ID and [Name] = [DefaultCOA]),[DefaultVendor],[Category],[Juridication], [IsDefault], [IsStatutoryComponent], [IsHide] FROM [Hr].[PayComponent]  WHERE COMPANYID=0 and Juridication != 'India'	     
			END
		END
	End
	Update Common.DetailLog set Status = @COMPLETED where Id = @HrPayComponent_Unique_Identifier

	--=============== Print Payroll ===================

	DECLARE @HrTemplate_PrintPayroll_Unique_Identifier uniqueidentifier = NEWID()
	INSERT INTO Common.DetailLog values(@HrTemplate_PrintPayroll_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_HR - HR Template PrintPayroll  Execution Started', GETUTCDATE() , '6.11' , NULL , @IN_PROGRESS )
	IF NOT EXISTS (SELECT * FROM [Common].[Template] WHERE  [CompanyId] = @NEW_COMPANY_ID and Name='PrintPayroll' and CursorName='HR Cursor')
	BEGIN   
		INSERT INTO  [Common].[Template]  ([Id],[Name],[Code],[CompanyId],[FromEmailId],[CCEmailIds],[BCCEmailIds],[TemplateType],[TempletContent],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[Subject],[TemplateMenu],[ToEmailId],[IsUnique], [LeadCategory],[CursorName], [IsLandscape], [IsCreated])  
			SELECT (NEWID()),[Name],[Code],@NEW_COMPANY_ID,[FromEmailId],[CCEmailIds],[BCCEmailIds],[TemplateType],[TempletContent],[RecOrder],[Remarks],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Version],[Status],[Subject],[TemplateMenu],[ToEmailId],[IsUnique], [LeadCategory],[CursorName], [IsLandscape], [IsCreated] FROM [Common].[Template]  WHERE [CompanyId] = @UNIQUE_COMPANY_ID and Name='PrintPayroll' and CursorName='HR Cursor'   
	END
	Update Common.DetailLog set Status = @COMPLETED where Id = @HrTemplate_PrintPayroll_Unique_Identifier

	--==================================

	BEGIN
	update WPD set WPD.IsDefaultProfile=0
	from HR.WorkProfileDetails WPD
	join hr.WorkProfile WP on WP.Id = WPD.MasterId
	where WP.CompanyId=@NEW_COMPANY_ID 

 

	update WPD set WPD.IsDefaultProfile=1 
	from HR.WorkProfileDetails WPD
	join hr.WorkProfile WP on WP.Id = WPD.MasterId
	where WP.CompanyId=@NEW_COMPANY_ID and WPD.Year=DatePart(YEAR, GETUTCDATE()) and WP.WorkProfileName='5 Days/Week'
	END
		--===================Leave Type===========
if not exists (select * from hr.LeaveType where companyid=@NEW_COMPANY_ID and name='Annual Leave')
BEGIN
	DECLARE @LeavetypeId uniqueidentifier = NEWID()
insert into hr.LeaveType([Id],[CompanyId],Name,IsShowToUser,LeaveAccuralType,IsCarryForward,IsAllowExcess,EnableLeaveRecommender,IsNoOfDays,UserCreated,CreatedDate,Status,EntitlementType,ApplyToAll,AllowProbationPeriod)
values(@LeavetypeId,@NEW_COMPANY_ID,'Annual Leave',0,'Yearly without proration',1,0,0,0,'System',GetDate(),1,'Days','',0)

insert into hr.LeaveTypeDetails(Id,LeaveTypeId,Status,CarryForwardDays,Entitlement)
values(NewId(),@LeavetypeId,1,5,12)
END

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
 --ROLLBACK TRANSACTION
 END CATCH
 BEGIN
	 --COMMIT TRANSACTION
	 Print 'HR Seed Data Insertion Completed'
 END

	--Notification seed data
	DECLARE @notificationSettings_Unique_Identifier uniqueidentifier = NEWID()
		INSERT INTO Common.DetailLog values(@notificationSettings_Unique_Identifier, @UNIQUE_Id , 'FW_SEED_DATA_HR - Notifications Execution Started', GETUTCDATE() , '6.10' , NULL , @IN_PROGRESS )
	Begin
		If Not Exists (Select Id From Notification.NotificationSettings WHere CompanyId=@NEW_COMPANY_ID And CursorName= 'HR Cursor')
		Begin
			Insert Into Notification.NotificationSettings (Id,CompanyId,CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,
			Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,ModifiedBy,ModifiedDate,UserCreated,NotificationTemplate,
			NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate)

			Select NEWID(),@NEW_COMPANY_ID,Null as CompanyUserId,CursorName,ScreenName,ScreenAction,Type,NotificationDescription,EmailDescription,FeatureName,Recipient,OtherRecipients,ReminderPeriod,ReminderPeriodDuration,IsOn,CreatedDate,null,null,UserCreated,NotificationTemplate,NotificationSubject,Status,Recorder,IsHidden,IsPersonalSetting,IsSelfNotification,EmailSubject,OtherEmailRecipient,EmailBodyTemplate
			From Notification.NotificationSettings Where CompanyId=@UNIQUE_COMPANY_ID And CursorName= 'HR Cursor'
		End
	END
	Update Common.DetailLog set Status = @COMPLETED where Id = @notificationSettings_Unique_Identifier

END
GO
