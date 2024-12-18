USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_ChartOfAccount_Insertion_Subsidarycompany]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Declare @COAID bigint
--Exec Bean_ChartOfAccount_Insertion_Subsidarycompany 244,2087,275,'COM1 - SBI4844551(SGD)','SGD','System',@COAID out
--Select @COAID

CREATE   proc [dbo].[Bean_ChartOfAccount_Insertion_Subsidarycompany]
@companyId bigint,
@AccountTypeId bigint,
@SubComp bigint,
@COAName nvarchar(200),
@Currency nvarchar(200),
@UserCreated nvarchar(200),
@COAID bigint output
as
BEGIN
--Local Variables
Declare @ErrorMessage Nvarchar(4000)
--Declare @Class Nvarchar(100) = 'Assets'
--Declare @IsBank tinyint = 1
--Declare @ModuleType Nvarchar(100) = 'Bean'
--Declare @Nature Nvarchar(100) = 'Debit'
--Declare @Category Nvarchar(100) = 'Balance Sheet'
--Declare @SubCategory Nvarchar(100) = 'Current'
--Declare @CashflowType Nvarchar(100) = 'Cash and cash equivalent'
--Declare @IsSeedData tinyint = 0
--Declare @ShowRevaluation tinyint = 1
--Declare @Revaluation tinyint = 1
--Declare @Status tinyint = 1
--Declare @IsRealCOA tinyint = 1
--Declare @IsSystem tinyint = 0
--Declare @IsLinkedAccount tinyint = 1
Declare @Code nvarchar(30)
--Declare @Count int = 0
Declare @FRPATId uniqueidentifier
Declare @RecOrder bigint 
Declare @MaxId bigint
Declare @MaxNewCode nvarchar(200)
Declare @BaseCode nvarchar(50)
Declare @Length tinyint

	Begin Try
	Begin Transaction
		SET @FRPATId = (Select FRATId From Bean.AccountType Where Id = @AccountTypeId AND CompanyId = @CompanyId)
		SET @RecOrder = (Select MAX(RecOrder)+1 FROM [Bean].[ChartOfAccount](Nolock) where CompanyId = @companyId)
		SET @MaxId = ( Select MAX(COA.Id) FROM [Bean].[ChartOfAccount] COA(Nolock))
	--If Code is not exist
		IF Not Exists(Select Id From Bean.ChartofAccount where Code='BS100001' AND CompanyId = @companyId)
			Begin

		Insert into [Bean].[ChartofAccount] (Id, CompanyId, Code, Name, AccountTypeId, SubCategory, Category, Class,Nature, Currency, ShowRevaluation, CashflowType, IsSystem, RecOrder, UserCreated, CreatedDate, [Status], Revaluation,  ModuleType,IsSeedData,SubsidaryCompanyId,IsBank,IsLinkedAccount,IsRealCOA,FRCoaId,FRPATId)
		
					Select ROW_NUMBER() OVER(Order by Id ASC)+@MaxId As Id, @companyId As CompanyId, 'BS100001' As Code, @COAName As Name, @AccountTypeId As AccounttypeId,'Current' As SubCategory,'Balance Sheet' As Category,'Assets' As Class,'Debit' As Nature,@Currency As Currency,1 As ShowRevaluation,'Cash and cash equivalent' As CashflowType,0 As IsSystem,@RecOrder As RecOrder,@UserCreated As UserCreated,GetUTCDate() As CreatedDate,1 As Status,1 As Revaluation,'Bean' As ModuleType,0 As IsSeedData,@SubComp As SubsidaryCompanyId,1 As IsBank,1 As IsLinkedAccount,1 As IsRealCOA,NEWID() As FRCoaId,@FRPATId As FRPATId from Bean.ChartOfAccount where CompanyId=0 and Name = 'Trade receivables'

					SET @COAID = (Select ID From Bean.ChartOfAccount(nolock) Where CompanyId = @CompanyID and Name = @COAName and Code = 'BS100001' AND IsBank = 1)
			End
	-- If Bank Exists For Company
		Else
			Begin
				--Declare @MaxNewCode nvarchar(200)
				--Select @MaxNewCode = Max(Code) From Bean.ChartOfAccount Where CompanyId = @CompanyId AND IsBank = @IsBank AND Code like 'BS%'
				--Declare @BaseCode nvarchar(50) = (Select Right(@MaxNewCode,LEN(@MaxNewCode)-2))
				--Declare @NewCode BigInt = Convert(BigInt, @BaseCode)
				--SET @NewCode = @NewCode+1
				--SET @BaseCode = @NewCode
				--IF(LEN(@BaseCode) != LEN(Convert(nvarchar(50),@NewCode)))
				--	Begin
				--		Set @BaseCode = Convert(nvarchar(50),(SELECT FORMAT(@NewCode, '000000')))
				--	End
				
				Select @MaxNewCode = Max(Code) From Bean.ChartOfAccount Where CompanyId = @CompanyId AND Code like 'BS10%'
				SET @BaseCode = (Select Right(@MaxNewCode,LEN(@MaxNewCode)-2))
				SET @Length = Len(@BaseCode)

			SET @Code = (select Concat('BS',Concat(replicate('0',@Length - Len( RIGHT(@MaxNewCode,@Length)+1)),RIGHT(@MaxNewCode,@Length)+1)))

					Insert into [Bean].[ChartofAccount] (Id, CompanyId, Code, Name, AccountTypeId, SubCategory, Category, Class,Nature, Currency, ShowRevaluation, CashflowType, IsSystem, RecOrder, UserCreated, CreatedDate, Status, Revaluation,  ModuleType,IsSeedData,SubsidaryCompanyId,IsBank,IsLinkedAccount,IsRealCOA,FRCoaId,FRPATId)  
					Select ROW_NUMBER() OVER(Order by Id ASC)+@MaxId As Id, @companyId As CompanyId, @Code As Code, @COAName As Name, @AccountTypeId As AccounttypeId,'Current' As SubCategory,'Balance Sheet' As Category,'Assets' As Class,'Debit' As Nature,@Currency As Currency,1 As ShowRevaluation,'Cash and cash equivalent' As CashflowType,0 As IsSystem,@RecOrder As RecOrder,@UserCreated As UserCreated,GetUTCDate() As CreatedDate,1 As Status,1 As Revaluation,'Bean' As ModuleType,0 As IsSeedData,@SubComp As SubsidaryCompanyId,1 As IsBank,1 As IsLinkedAccount,1 As IsRealCOA,NEWID() As FRCoaId,@FRPATId As FRPATId from Bean.ChartOfAccount where CompanyId=0 and Name = 'Trade receivables'
					
					SET @COAID = (Select ID From Bean.ChartOfAccount(nolock) Where CompanyId = @CompanyID and Name = @COAName and Code = @Code AND IsBank =1)
			End
	Commit Transaction
	End Try
	Begin Catch
		RollBack
		Select @ErrorMessage=ERROR_MESSAGE()
			RAISERROR(@ErrorMessage,16,1);
	End Catch
END

GO
