USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [Common].[InterCompanyActivation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create
 procedure [Common].[InterCompanyActivation] @CompanyId bigint
 As
 Begin
 Update Common.CompanyFeatures set Status=1 where CompanyId=@CompanyId and FeatureId =(select Id from Common.Feature where Name='Inter-Company' and VisibleStyle='SuperUser-CheckBox') 
 End
GO
