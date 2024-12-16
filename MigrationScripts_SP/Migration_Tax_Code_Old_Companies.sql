USE SmartCursorSTG

IF EXISTS (SELECT 1 FROM sys.tables  WHERE name='TaxCode')
BEGIN
BEGIN TRY
BEGIN TRAN
Declare @companyId bigint
	SELECT c.Id into #tempTax
	from  Common.Company c
	join Common.CompanyModule CM
	on CM.CompanyId=c.Id
	where CM.SetUpDone=1 and CM.ModuleId=4 and CM.Status=1 and c.Status=1 and c.ParentId is null
	and c.UserCreated='System' and c.Id not in (1,19,158,237,242,256,324,326,341,459,487,507,509,
	570,622,646,674,689,932,1077,1085,1222,1517,1748,1804,1833,1839,1895,1940,1943,1945,1964,1968,1988,2005,2054)
	and c.Id not in(
	Select CompanyId  from Bean.TaxCode 
	where TaxRate in (8)
	group by CompanyId
	  )
DECLARE TaxCodeCsr Cursor for
Select Id from #tempTax
OPEN TaxCodeCsr
FETCH NEXT FROM TaxCodeCsr into @companyId
WHILE @@FETCH_STATUS=0
BEGIN
		IF EXISTS(select  1 from Bean.TaxCode where CompanyId=@companyId)
		BEGIN
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
					UPDATE Bean.TaxCode set EffectiveTo='2022-12-31 00:00:00.0000000' where CompanyId=@companyId AND TaxRate=7 and Status=1
				  END
			End
			--COMMIT TRAN
		END
FETCH NEXT FROM TaxCodeCsr into @companyId
END
Close TaxCodeCsr
Deallocate TaxCodeCsr
IF OBJECT_ID('tempdb..#tempTax') is not null
	DROP TABLE #tempTax
COMMIT TRAN
END TRY
BEGIN CATCH
     ROLLBACK TRAN;
	 IF OBJECT_ID('tempdb..#tempTax') is not null
		DROP TABLE #tempTax
     Declare @errormessage varchar(1000)
     SELECT  @errormessage= CAST(ERROR_NUMBER() as varchar(500)) +'-'+ ERROR_MESSAGE()
     RAISERROR (@errormessage ,16,1)
END CATCH;
END
GO