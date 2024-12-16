USE SmartCursorPRD
IF EXISTS (SELECT 1 FROM sys.tables  WHERE name='TaxCode')
BEGIN
BEGIN TRY
BEGIN TRAN
Declare @companies as Table(Id Int identity(1,1),CompanyId int,RECORDID int)
Declare @count int=1
Declare @RecCount int
Declare @companyId int
Declare @IDCount int
	Insert into @companies
	Select C.Id,COUNT(C.Id) from Common.Company C with (nolock)
	inner join Bean.TaxCode TX with (nolock)
	on TX.CompanyId=C.Id
	inner join Common.CompanyModule CM with (nolock)
	on CM.CompanyId=C.Id
	inner join Common.ModuleMaster MM with (nolock)
	on MM.Id=CM.ModuleId and MM.Name='Bean Cursor'
	Where MM.Name='Bean Cursor' and C.ParentId is NULL and C.Status=1 and C.Id<>0
	and C.IsClientCompany=1
	group by C.Id
	order by C.Id
	Select @RecCount=COUNT(*) from @companies
		WHILE(@RecCount>=@count)
		BEGIN
			SET @companyId=(Select CompanyId from @companies where Id=@count)
				IF NOT Exists(select  1 from Bean.TaxCode with (nolock) where CompanyId=@companyId AND TaxRate=8 and Status=1) 
				Begin 
					SET @IDCount=(SELECT Max(Id) from Bean.TaxCode with (nolock))
		  
					--INSERT [Bean].[TaxCode] ([Id], [CompanyId], [Code], [Name], [Description], [AppliesTo], [TaxType], [TaxRate], [EffectiveFrom], [IsSystem], [RecOrder], [UserCreated], [CreatedDate], [Status], [IsApplicable],[EffectiveTo],[IsSeedData],[Jurisdiction])
	 
				Select @companyId
					SELECT @IDCount+ROW_NUMBER() Over(order by Name) AS  [Id], [CompanyId], [Code], [Name],REPLACE(Description,'7%','8%') as [Description], [AppliesTo], [TaxType],8 AS [TaxRate],'2023-01-01 00:00:00.0000000' AS [EffectiveFrom], [IsSystem], [RecOrder], 
				  [UserCreated],GETUTCDATE() AS [CreatedDate], [Status], [IsApplicable],[EffectiveTo],0 AS [IsSeedData],[Jurisdiction]
				  from Bean.TaxCode where CompanyId=@companyId and TaxRate=7 and Status=1
					--IF Exists(select  1 from Bean.TaxCode where CompanyId=@companyId AND TaxRate=8)
					--BEGIN
					--	UPDATE Bean.TaxCode set EffectiveTo='2022-12-31 00:00:00.0000000' where CompanyId=@companyId AND TaxRate=7 and Status=1
					--END
				
				END
				SET @count=@count+1;
		END
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