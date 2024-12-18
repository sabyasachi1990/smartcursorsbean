USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_InterCO_I_C_I_B_COA]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create     PROCEDURE [dbo].[Bean_InterCO_I_C_I_B_COA]
@CompanyId int,
@NewIds nvarchar(500),
@EditIds nvarchar(500),
@IsIC bit
As
Begin
--exec [dbo].[Bean_InterCO_I_C_I_B_COA]  244,'1833,1832,1831','',1
--Declare @Ids varchar(256)='2,3,5,1754,1757'
		Declare @ServCompId Table(Id int)
		Declare @IsExist bit=0;
		Insert into @ServCompId Select  items from  [dbo].[SplitToTable](@NewIds,',')
		IF ( @NewIds IS NOT NULL AND @NewIds !='')
		BEGIN
		Declare @ServiceCompId Table(Id int)
		Declare @Name varchar(20)
		Declare @ICValue varchar(50)
		Declare @FinalData nvarchar(20)
		Set @Name=CASE WHEN @IsIC=1 THEN '%I/C - %' ELSE '%I/B - %' END
		IF(@IsIc=1)
			Begin
			Set @ICValue=(Select top 1 Code from Bean.ChartOfAccount where CompanyId=@CompanyId and Name like 'I/C%' order by Code desc)
			END
		Else
			Begin
			Set @ICValue=(Select top 1 Code from Bean.ChartOfAccount where CompanyId=@CompanyId and Name like 'I/B%' order by Code desc)
			END
		Set @FinalData=Case when @IsIc=1 Then 'BS150000' Else 'BS155000' End
		Insert into @ServiceCompId  Select distinct COA.SubsidaryCompanyId from Bean.ChartOfAccount COA where COA.CompanyId=@CompanyId and      COA.Name   LIKE @Name     
		If exists(Select SubsidaryCompanyId from Bean.ChartOfAccount COA where COA.CompanyId=@CompanyId and      COA.Name   LIKE Case When @IsIC=1 Then 'I/C%' Else 'I/B%' End)
			Begin
				Set @IsExist=1;
			End
	 
		--Declare  @companyId bigint=420;
				IF((Select CF.Status from Common.Feature F
					JOIN Common.CompanyFeatures CF on F.Id=CF.FeatureId
					where CF.Companyid=@CompanyId and F.Name='Inter-Company' and F.ModuleId is null)=1)
				BEGIN
				If Exists (Select   Id from @ServCompId where Id not in (Select Id from @ServiceCompId))
				BEGIN
					Declare @COACOUNT bigint =(Select Max(Id) from Bean.ChartOfAccount)
						Insert into Bean.ChartOfAccount (Id,CompanyId,Code,Name,AccountTypeId,SubCategory,Category,Class,Nature,CashflowType,IsSeedData,CreatedDate,UserCreated,ModuleType,Status,IsRealCOA,SubsidaryCompanyId,IsLinkedAccount,FRCoaId,FRPATId,IsSystem,ShowRevaluation)	

						  --Select (ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + 1 FROM [Bean].[ChartOfAccount])) as Id,c.ParentId as CompanyId,CONCAT('BS15000',Case When @IsExist=0 Then ROW_NUMBER()OVER(order by Id) Else  ROW_NUMBER()OVER(order by Id) +((Select Count(*) as Cnt from Bean.ChartOfAccount as COA where CompanyId=@CompanyId and (Name LIKE 'I/C%' Or Name LIKE 'I/B%')))End) as Code,CONCAT(CASE WHEN @IsIC=1 THEN 'I/C - ' ELSE 'I/B - 'END,C.ShortName) as Name,(Select Id from Bean.AccountType where CompanyId=@CompanyId and Name= CASE WHEN @IsIC=1 THEN 'Intercompany clearing' ELSE 'Intercompany billing' END) As AccountTypeId,'Current' as SubCategory,'Balance Sheet' AS Category,'Assets' as Class,'Debit' as Nature,'Operating' as CashflowType,0 as IsSeedData,GETUTCDATE() As CreatedDate,'System' as UserCreated,'Bean' As ModuleType,1 as Status,1 as IsRealCOA,C.Id as SubsidaryCompanyId,1 as IsLinkedAccount ,NEWID() as FRCoaId,(select FRATId from Bean.AccountType Where Name= CASE WHEN @IsIC=1 THEN 'Intercompany clearing' ELSE 'Intercompany billing' END and CompanyId=@CompanyId ) as FRPATId,0 as IsSystem from Common.Company C where Id IN


						  Select (ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(id) + 1 FROM [Bean].[ChartOfAccount])) as Id,c.ParentId as CompanyId,Case When @IsExist=0 Then 
	--CONCAT( Case When @IsIc=1 Then 'BS15000' Else 'BS15500' End,  ROW_NUMBER()OVER(order by Id)) Else 
	CONCAT( (substring(@FinalData,1, LEN(@FinalData)-PATINDEX('%[A-Z]%', Reverse(@FinalData))+1)),(Right(@FinalData, PATINDEX('%[A-Z]%', Reverse(@FinalData))-1)+ROW_NUMBER()OVER(order by Id))) 
	Else
	CONCAT( (substring(@ICValue,1, LEN(@ICValue)-PATINDEX('%[A-Z]%', Reverse(@ICValue))+1)),(Right(@ICValue, PATINDEX('%[A-Z]%', Reverse(@ICValue))-1)+ROW_NUMBER()OVER(order by Id))) End as Code,
	CONCAT(CASE WHEN @IsIC=1 THEN 'I/C - ' ELSE 'I/B - 'END,C.ShortName) as Name,(Select Id from Bean.AccountType where CompanyId=@CompanyId and Name= CASE WHEN @IsIC=1 THEN 'Intercompany clearing' ELSE 'Intercompany billing' END) As AccountTypeId,'Current' as SubCategory,'Balance Sheet' AS Category,'Assets' as Class,'Debit' as Nature,'Operating' as CashflowType,0 as IsSeedData,GETUTCDATE() As CreatedDate,'System' as UserCreated,'Bean' As ModuleType,1 as Status,1 as IsRealCOA,C.Id as SubsidaryCompanyId,1 as IsLinkedAccount ,NEWID() as FRCoaId,(select FRATId from Bean.AccountType Where Name= CASE WHEN @IsIC=1 THEN 'Intercompany clearing' ELSE 'Intercompany billing' END and CompanyId=@CompanyId ) as FRPATId,0 as IsSystem,Case when @IsIC=1 Then 0 Else 1 End as ShowRevaluation  from Common.Company C where Id IN
						  (
						  Select   Id from @ServCompId where Id not in (Select Id from @ServiceCompId)
						   ) AND ParentId=@CompanyId
					   END
					   ELSE
					   BEGIN
					   Update COA Set COA.IsLinkedAccount=1,COA.IsSystem=0  from Bean.AccountType Acc
                        Join Bean.ChartOfAccount COA ON Acc.Id=COA.AccountTypeId
                        Where COA.CompanyId=@companyId and Acc.Name=Case When @isIc=1 Then 'Intercompany clearing' Else 'Intercompany billing' END AND COA.SubsidaryCompanyId in (Select items from dbo.SplitToTable(@NewIds,',') )
						--Update Bean.ChartOfAccount set IsLinkedAccount=1   where SubsidaryCompanyId in (Select items from dbo.SplitToTable(@EditIds,',') )and CompanyId=@CompanyId
				       END
				BEGIN
				IF(@EditIds IS NOT NULL AND @EditIds !='')
					BEGIN
					Update COA Set COA.IsLinkedAccount=0,IsSystem=null  from Bean.AccountType Acc
                        Join Bean.ChartOfAccount COA ON Acc.Id=COA.AccountTypeId
                        Where COA.CompanyId=@companyId and Acc.Name=Case When @isIc=1 Then 'Intercompany clearing' Else 'Intercompany billing' END AND COA.SubsidaryCompanyId in (Select items from dbo.SplitToTable(@EditIds,',') )
						--Update Bean.ChartOfAccount set IsLinkedAccount=0   where SubsidaryCompanyId in (Select items from dbo.SplitToTable(@EditIds,',') )and CompanyId=@CompanyId
				END
			END
				END
			END
		ELSE
			BEGIN
				IF(@EditIds IS NOT NULL AND @EditIds !='')
					BEGIN
						Update COA Set COA.IsLinkedAccount=0,IsSystem=null  from Bean.AccountType Acc
                        Join Bean.ChartOfAccount COA ON Acc.Id=COA.AccountTypeId
                        Where COA.CompanyId=@companyId and Acc.Name=Case When @isIc=1 Then 'Intercompany clearing' Else 'Intercompany billing' END AND COA.SubsidaryCompanyId in (Select items from dbo.SplitToTable(@EditIds,',') )
						--Update Bean.ChartOfAccount set IsLinkedAccount=0 where SubsidaryCompanyId in (Select items from dbo.SplitToTable(@EditIds,',') )and CompanyId=@CompanyId
					END
			END

			--Entity Creation from Service Entity
	If(@IsIC=0)
	BEGIN
	Declare @Error_Message nvarchar(max)
	Declare @TOPId int
	Declare @ServiceEntityIds table(Id int)
	Begin Transaction
	Begin Try
	Insert into @ServiceEntityIds Select ServiceEntityId from Bean.Entity Ent where ServiceEntityId in (Select items from dbo.SplitToTable(@NewIds,','))
	SET @TOPId = (Select Id from Common.TermsOfPayment where CompanyId=@CompanyId and Name='Credit - 0')
	If Exists (Select   Id from @ServCompId where Id not in (Select Id from @ServiceEntityIds))
	 BEGIN
	INSERT INTO [Bean].[Entity]([Id],[CompanyId],[Name],[IsCustomer],[CustTOPId],[CustTOP],[CustTOPValue],[CustCurrency],[CustNature],[IsVendor],[VenTOPId],[VenTOP],[VenTOPValue],[VenCurrency],[VenNature],[AddressBookId],[UserCreated],[CreatedDate],[ModifiedBy],[ModifiedDate],[Status],[Communication],[VendorType],[IsShowPayroll],IsExternalData,ServiceEntityId) 

		Select NEWID() as Id,C.ParentId as CompanyId,C.Name as Name,1 as IsCustomer,@TOPId as CustTOPId,'Credit - 0' as CustTOP,0 as CustTOPValue,'SGD' as CustCurrency,'Interco' as CustNature,1 as IsVendor,@TOPId as VenTOPId,'Credit - 0' as VenTOP,0 as VenTOPValue,'SGD' as VenCurrency,'Interco' as VenNature,C.AddressBookId as AddressBookId,c.UserCreated as UserCreated,GETUTCDATE() as CreatedDate,C.ModifiedBy as ModifiedBy,C.ModifiedDate as ModifiedDate,C.Status as Status,C.Communication as Communication,'Supplier' as VendorType,1 as IsShowPayroll,1,C.Id
		from Common.Company C where Id in (Select Id from @ServCompId where Id not in (Select Id from @ServiceEntityIds))
	 END
	 BEGIN
	 IF(@NewIds IS NOT NULL AND @NewIds !='')
		 BEGIN
               Update Bean.Entity set  Status=1 where ServiceEntityId in (Select items from dbo.SplitToTable(@NewIds,',') )and CompanyId=@CompanyId
		 END
			END
	 BEGIN
    IF(@EditIds IS NOT NULL AND @EditIds !='')
		 BEGIN
               Update Bean.Entity set  Status=2 where ServiceEntityId in (Select items from dbo.SplitToTable(@EditIds,',') )and CompanyId=@CompanyId
		 END
			END

	--To insert the I/B Revaluation COA
	If ((Select Revaluation from Bean.MultiCurrencySetting where CompanyId = @CompanyId)=1)
	Begin
		If Not Exists(Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Name='Interco billing revaluation')
		Begin
			 Declare @IBAcTypeId BigInt, @IBFRatId UniqueIdentifier, @ISCodeExists Bit=0

			 Select @IBAcTypeId=Id,@IBFRatId=FRATId from Bean.AccountType(nolock) where CompanyId=@CompanyId and Name='Intercompany billing'

			 If Exists(Select Id from Bean.ChartOfAccount where CompanyId=@CompanyId and Code='BS155099')
			 Begin
				Set @ISCodeExists=1
			 End

		   	             
			INSERT INTO   [Bean].[ChartOfAccount] (Id, CompanyId, Code, Name, AccountTypeId, Class, Category, SubCategory, Nature, Currency, ShowRevaluation, CashflowType,
			AppliesTo, IsSystem, IsShowforCOA, RecOrder, Remarks, UserCreated, CreatedDate, ModifiedBy, ModifiedDate, Version, Status, IsSubLedger, IsCodeEditable,
			ShowCurrency, ShowCashFlow, ShowAllowable, IsRevaluation, Revaluation, DisAllowable, RealisedExchangeGainOrLoss, UnrealisedExchangeGainOrLoss, ModuleType,IsSeedData,IsDebt,IsLinkedAccount,IsRealCOA,FRCoaId,FRPATId)	

			SELECT ROW_NUMBER() OVER(ORDER BY ID) + (SELECT MAX(Id) FROM [Bean].[ChartOfAccount](Nolock)) AS Id, @CompanyId, Case When @ISCodeExists =1 Then
		
			Case When @IsExist=0 Then 
			CONCAT( (substring(@FinalData,1, LEN(@FinalData)-PATINDEX('%[A-Z]%', Reverse(@FinalData))+1)),(Right(@FinalData, PATINDEX('%[A-Z]%', Reverse(@FinalData))-1)+ROW_NUMBER()OVER(order by Id))) 
			Else
			CONCAT( (substring(@ICValue,1, LEN(@ICValue)-PATINDEX('%[A-Z]%', Reverse(@ICValue))+1)),(Right(@ICValue, PATINDEX('%[A-Z]%', Reverse(@ICValue))-1)+ROW_NUMBER()OVER(order by Id))) End 
			Else Code End as Code
			
			, Name, @IBAcTypeId, Class, Category, SubCategory,
			Nature, Currency, ShowRevaluation, CashflowType, AppliesTo, IsSystem, IsShowforCOA, RecOrder, Remarks,
			'System', GETUTCDATE(), null, null, Version, 1, IsSubLedger, IsCodeEditable, ShowCurrency, ShowCashFlow, ShowAllowable, 1, Revaluation, 
			DisAllowable, RealisedExchangeGainOrLoss, UnrealisedExchangeGainOrLoss, ModuleType,IsSeedData,IsDebt,IsLinkedAccount,IsRealCOA,NEWID(), @IBFRatId  FROM [Bean].[ChartOfAccount](Nolock) WHERE COMPANYID=0 AND Name ='Interco billing revaluation'
		
		End
	End



		Commit Transaction
	End Try
	Begin Catch
	 Select @Error_Message=Error_Message()
	 Rollback;
	End Catch
	BEGIN
    IF(@EditIds IS NOT NULL AND @EditIds !='')
		 BEGIN
               Update Bean.Entity set  Status=2 where ServiceEntityId in (Select items from dbo.SplitToTable(@EditIds,',') )and CompanyId=@CompanyId
		 END
			END
	END
END
GO
