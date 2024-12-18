USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_General_Setting_Features]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [dbo].[Bean_General_Setting_Features]
@IsFinancial tinyint,
@IsRevaluation tinyint,
@IsNoSupportingDocuments tinyint,
@PeriodLockDatePassword nvarchar(100),
@PeriodLockStartDate DateTime2(7),
@PeriodLockEndDate DateTime2(7),
@CompanyId bigint,
@UserCreated nvarchar(200),
@ModifiedBy nvarchar(200)
as
begin
--Local Variables
Declare @ErrorMessage Nvarchar(4000)
Declare @Status tinyint = 1
Declare @IsPosted tinyint = 1
Declare @Id bigint
Declare @IsChecked tinyint
Declare @FinacialFeatureId UniqueIdentifier, @RevaluationFeatureId UniqueIdentifier, @IsNoSupportingDocFeatureId UniqueIdentifier
Declare @FRPATId Uniqueidentifier
	Begin Try
	Begin Transaction
	--FinancialSetting Block
		Begin
		IF Not Exists(Select Id from Bean.financialsetting(nolock) Where CompanyId = @CompanyId)
			Begin
				RAISERROR('Finance setting must be save',16,1)
			End
		End
		IF(@IsFinancial = 1)
		Begin
			Update Bean.FinancialSetting Set PeriodLockDate = @PeriodLockStartDate, PeriodEndDate = @PeriodLockEndDate, PeriodLockDatePassword = @PeriodLockDatePassword, ModifiedBy = @ModifiedBy, ModifiedDate = GetUTCDate() where CompanyId = @companyId --and Id = @Id

			select @IsChecked = cf.IsChecked,@FinacialFeatureId=cf.Id From common.feature(nolock) f JOIN common.companyfeatures(nolock) cf On f.id = cf.featureId Where companyid = @CompanyId and f.Name = 'Financial'
			IF (@IsChecked = 0 or @IsChecked is null)
			Begin
				Update Common.CompanyFeatures Set [Status] = @status, IsChecked =1,ModifiedDate = GetUTCDate(), ModifiedBy = @ModifiedBy Where CompanyId = @companyId and Id = @FinacialFeatureId
			End
		End
		--Revaluation Block
		IF(@IsRevaluation = 1)
		Begin
			--Chart Of Account Revaluation Inserting
			

				--Declare @temp Table (Id BigInt, Name Nvarchar(200))
				--Declare @CompanyId bigInt=2504
				Declare @COAList BigInt, @count BigInt=0,@AccountTypeName nvarchar(100),@AccountTypeIds bigint
				Declare COAList Cursor for
				Select id from Bean.ChartOfAccount where CompanyId=0 and Status=3;
				Open COAList
				Fetch next from COAList into @COAList
				While @@FETCH_STATUS=0
				Begin
				Declare @temp Table (Id BigInt, Name Nvarchar(200), Code nvarchar(80),AccountTypeId bigint, AccountTypeName Nvarchar(200))
    
				insert into @temp 
				Select COA.id, COA.Name,Code,COA.AccountTypeId,ACC.Name from Bean.ChartOfAccount COA Join Bean.AccountType Acc on Acc.Id=COA.AccountTypeId where COA.Id=@COAList
    
				If Not Exists(select Id from Bean.ChartOfAccount where CompanyId=@CompanyId  and Name in (select Name from @temp))
				Begin
				If Not Exists(select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and IsRevaluation=1 and Name in (select Name from @temp))
				Begin
					--Select @AccountTypeName = Name from bean.AccountType Where Id in (select AccountTypeId from @temp)
					Select @AccountTypeIds = Id,@FRPATId = FRATId from Bean.AccountType Where Name = (select AccountTypeName from @temp) and companyId = @companyId
					Insert into Bean.ChartofAccount
					Select ROW_NUMBER() OVER(ORDER BY  ID ASC) + (SELECT MAX(Id) FROM [Bean].[ChartOfAccount](Nolock)),@CompanyId,Code,Name,@AccountTypeIds,SubCategory,Category,class,Nature,Currency,ShowRevaluation,CashFlowType,AppliesTo,IsSystem,IsShowForCOA,RecOrder,Remarks,UserCreated,
					GETUTCDATE(),ModifiedBy,null,[Version],@Status,IsSubLedger,IsCodeEditable,ShowCurrency,ShowCashFlow,ShowAllowable,1,Revaluation,DisAllowable,RealisedExchangeGainOrLoss,UnrealisedExchangeGainOrLoss,ModuleType,IsSeedData,SubsidaryCompanyId,IsBank,IsDebt,IsAllowableNotAllowableActivated,IsLinkedAccount,IsRealCOA,NewId(),@FRPATId,FRRecOrder,CategoryId,SubCategoryId,TaxType,XeroCode,XeroName,XeroClass,XeroAccountTypeId,XeroAccountId,IsFromXero from bean.chartofaccount where Id in (Select Id from @temp)
				End
				End
     
				Delete from @temp
				Fetch Next from COAList into @COAList
				End
				Close COAList
				Deallocate COAList

			select @IsChecked = cf.IsChecked,@RevaluationFeatureId=cf.Id From common.feature f JOIN common.companyfeatures cf On f.id = cf.featureId Where companyid = @CompanyId and f.Name = 'Revaluation'
			IF (@IsChecked = 0 or @IsChecked is null)
			Begin
				Update Common.CompanyFeatures Set [Status] = @status, IsChecked =1,ModifiedDate = GetUTCDate(), ModifiedBy = @ModifiedBy Where CompanyId = @companyId and Id =@RevaluationFeatureId
				Update Bean.Multicurrencysetting Set [Revaluation] = 1 where Companyid = @CompanyId
			End

		End
		--No supporting Document Block
		IF (@IsNoSupportingDocuments = 1)
		Begin
			--No Supporting Document Updation
			select @IsChecked = cf.IsChecked,@IsNoSupportingDocFeatureId=cf.Id From common.feature f JOIN common.companyfeatures cf On f.id = cf.featureId Where companyid = @CompanyId and f.Name = 'No Supporting Documents'
			IF (@IsChecked = 0 or @IsChecked is null)
			Begin
				Update Common.CompanyFeatures Set [Status] = @status, IsChecked =1,ModifiedDate = GetUTCDate(), ModifiedBy = @ModifiedBy Where CompanyId = @companyId and Id = @IsNoSupportingDocFeatureId
			End
		End
	Commit Transaction
	End Try
	Begin Catch
		RollBack
		Select @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
	End Catch
End
GO
