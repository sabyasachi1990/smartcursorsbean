USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_NewCompany_Taxcode_Insertion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 --exec [dbo].[Bean_NewCompany_Taxcode_Insertion]

CREATE Proc [dbo].[Bean_NewCompany_Taxcode_Insertion]
AS
BEGIN

--Declare  @BeanTaxCode table (Id bigint,CompanyId bigint,Code nvarchar(100),Name nvarchar(250),
--Description nvarchar(2000),AppliesTo nvarchar(50),TaxType nvarchar(50),
--TaxRate float,EffectiveFrom [datetime2](7),IsSystem [bit],RecOrder [int],Remarks [nvarchar](500),UserCreated [nvarchar](500),
--CreatedDate [datetime2](7),ModifiedBy [nvarchar](500),ModifiedDate [datetime2](7),Version [smallint],Status [int]
--,TaxRateFormula [nvarchar](50),IsApplicable [bit],EffectiveTo [datetime2](7) ,
--XeroTaxName [nvarchar](500),XeroTaxType [nvarchar](500),XeroTaxComponentName [nvarchar](500),
--XeroTaxRate [nvarchar](500),IsFromXero [bit],IsSeedData [bit])

--Insert into  @BeanTaxCode
--select Id,CompanyId,Code,Name,Description,AppliesTo,TaxType,TaxRate,EffectiveFrom,IsSystem,RecOrder,Remarks,UserCreated,CreatedDate
--,ModifiedBy,ModifiedDate,Version,Status,TaxRateFormula,IsApplicable,EffectiveTo,XeroTaxName,XeroTaxType,XeroTaxComponentName
--,XeroTaxRate,IsFromXero,IsSeedData from Bean.TaxCode where CompanyId=0 and IsSeedData=1


Declare @id bigint--=707   
Declare @max bigint
Declare @CompanyGSTFeatures_Cnt BIGINT
Declare @Jurisdiction nvarchar(30)

Declare Company_Id Cursor For
select Distinct Id from Common.Company where Id<>0 and id not in (707)
		Open Company_Id
		fetch next from Company_Id Into @id
		While @@FETCH_STATUS=0
		Begin
		--Declare @Jurisdiction Nvarchar(200)=(select Distinct Jurisdiction from common.company  where parentid is null and id=@id )
	 select @CompanyGSTFeatures_Cnt=Count(*) from [Common].[Feature] a join [Common].[CompanyFeatures] b 
	on a.Id=b.FeatureId where a.Name='GST' and
	a.VisibleStyle ='SuperUser-CheckBox' and a.ModuleId is null and CompanyId=@id and b.Status=1

	Set @Jurisdiction = (select Jurisdiction from Common.Company Where Id = @id)

	IF @CompanyGSTFeatures_Cnt=1
	BEGIN
		IF @Jurisdiction <> (Select distinct (Jurisdiction) from Bean.Taxcode where Companyid = 0)
		Begin
			If Not Exists (SELECT CompanyId From  Bean.TaxCode  where CompanyId=@id) 
			Begin 
			set @max= (SELECT MAX(t.Id) FROM [Bean].TaxCode T(Nolock))

			Insert into Bean.TaxCode
			 (Id,CompanyId,Code,Name ,Description ,AppliesTo ,TaxType ,TaxRate ,EffectiveFrom ,IsSystem,RecOrder
			 ,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version ,Status,TaxRateFormula,IsApplicable,EffectiveTo,
              XeroTaxName,XeroTaxType,XeroTaxComponentName,XeroTaxRate,IsFromXero,IsSeedData,Jurisdiction)
          
			select  ROW_NUMBER() OVER(ORDER BY Id ASC)+@max
			,@id,Code,Name,Description,AppliesTo,TaxType,TaxRate,EffectiveFrom
            ,IsSystem,RecOrder,Remarks,UserCreated,CreatedDate,ModifiedBy,ModifiedDate,Version,Status,TaxRateFormula,IsApplicable
            ,EffectiveTo,XeroTaxName,XeroTaxType,XeroTaxComponentName,XeroTaxRate,IsFromXero,IsSeedData,Jurisdiction
			from Bean.TaxCode where CompanyId=0 --and Jurisdiction=@Jurisdiction
		
		END
		End
	   END
	Fetch Next From Company_Id Into @id
	End
	Close Company_Id
	Deallocate Company_Id
	
	
	END

	

	---GST Active Companys
	
	--select a.*,b.CompanyId,c.Name from [Common].[Feature] a join [Common].[CompanyFeatures] b 
	--Inner join Common.Company C on c.Id=b.CompanyId
	--on a.Id=b.FeatureId where a.Name='GST' and
	--a.VisibleStyle ='SuperUser-CheckBox' and a.ModuleId is null  and b.Status=1

	--select * from Bean.TaxCode where CompanyId=707
	
GO
