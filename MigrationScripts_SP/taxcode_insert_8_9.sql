USE SmartCursorSTG
IF EXISTS (SELECT 1 FROM sys.tables  WHERE name='TaxCode')
BEGIN
BEGIN TRY
BEGIN TRAN
Declare @companyId int=0
IF NOT Exists(select  1 from Bean.TaxCode where CompanyId=@companyId AND TaxRate=8 and Status=1) 
Begin 
		 Declare @count int
		 SET @count=(SELECT Max(Id) from Bean.TaxCode nolock)
		  
      INSERT [Bean].[TaxCode] ([Id], [CompanyId], [Code], [Name], [Description], [AppliesTo], [TaxType], [TaxRate], [EffectiveFrom], [IsSystem], [RecOrder], [UserCreated], [CreatedDate], [Status], [IsApplicable],[EffectiveTo],[IsSeedData],[Jurisdiction])
	 

	  SELECT @count+ROW_NUMBER() Over(order by Name) AS  [Id], [CompanyId], [Code], [Name],REPLACE(Description,'7%','8%') as [Description], [AppliesTo], [TaxType],8 AS [TaxRate],'2023-01-01 00:00:00.0000000' AS [EffectiveFrom], [IsSystem], [RecOrder], 
	  [UserCreated],GETUTCDATE() AS [CreatedDate], [Status], [IsApplicable],[EffectiveTo],0 AS [IsSeedData],[Jurisdiction]
	  from Bean.TaxCode where CompanyId=@companyId and TaxRate=7 and Status=1
	  IF Exists(select  1 from Bean.TaxCode where CompanyId=@companyId AND TaxRate=8)
	  BEGIN
		UPDATE Bean.TaxCode set EffectiveTo='2023-12-31 00:00:00.0000000' where CompanyId=@companyId AND TaxRate=8 and Status=1
		UPDATE Bean.TaxCode set EffectiveTo='2022-12-31 00:00:00.0000000' where CompanyId=@companyId AND TaxRate=7 and Status=1
	  END

End
IF NOT Exists(select  1 from Bean.TaxCode where CompanyId=@companyId AND TaxRate=9 and Status=1) 
Begin 
		 Declare @count1 int
		 SET @count1=(SELECT Max(Id) from Bean.TaxCode nolock)
		 
      INSERT [Bean].[TaxCode] ([Id], [CompanyId], [Code], [Name], [Description], [AppliesTo], [TaxType], [TaxRate], [EffectiveFrom], [IsSystem], [RecOrder], [UserCreated], [CreatedDate], [Status], [IsApplicable],[EffectiveTo],[IsSeedData],[Jurisdiction])
	 

	  SELECT @count1+ROW_NUMBER() Over(order by Name) AS  [Id], [CompanyId], [Code], [Name],REPLACE(Description,'7%','9%') as [Description], [AppliesTo], [TaxType],9 AS [TaxRate],'2024-01-01 00:00:00.0000000' AS [EffectiveFrom], [IsSystem], [RecOrder], 
	  [UserCreated],GETUTCDATE() AS [CreatedDate], [Status], [IsApplicable],[EffectiveTo],0 AS [IsSeedData],[Jurisdiction]
	  from Bean.TaxCode where CompanyId=@companyId and TaxRate=7 and Status=1
	  IF Exists(select  1 from Bean.TaxCode where CompanyId=@companyId AND TaxRate=9)
	  BEGIN
		UPDATE Bean.TaxCode set EffectiveTo=NULL where CompanyId=@companyId AND TaxRate=9 and Status=1
	  END
End
COMMIT TRAN

END TRY
BEGIN CATCH
     ROLLBACK TRAN;
     Declare @errormessage varchar(1000)
     SELECT  @errormessage= ERROR_NUMBER() +'-'+ ERROR_MESSAGE()
     RAISERROR (@errormessage ,16,1)
END CATCH;
END
GO


