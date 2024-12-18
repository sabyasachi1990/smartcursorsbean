USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[MultiCompanyFeatureInsertion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  PROC [Common].[MultiCompanyFeatureInsertion]  @CompanyId bigint
AS
BEGIN
declare @Localizationcount bigint = (select Count(Id) from Common.Localization where CompanyId=@CompanyId)
 declare @IsMultiCompany bit = (select IsMultiCompany from Common.Company where Id=@CompanyId)
 if(@Localizationcount is not null and @IsMultiCompany is not null)
BEGIN
	If Not Exists (Select Id From Common.CompanyFeatures WHere CompanyId=@CompanyId And FeatureId=(select Id from Common.Feature where Name='Multi-Company' and VisibleStyle='SuperUser-CheckBox'))
	BEGIN
		INSERT INTO Common.CompanyFeatures( Id, CompanyId, FeatureId, Status,  Remarks,IsChecked,UserCreated,CreatedDate)
		select  NEWID(),@CompanyId,b.FeatureId,2,b.Remarks,b.IsChecked,'System',GETUTCDATE() from [Common].[Feature] a join [Common].[CompanyFeatures] b on a.Id=b.FeatureId where a.Name='Multi-Company' and a.VisibleStyle='SuperUser-CheckBox' and CompanyId=0
 
	END
	END
End
GO
