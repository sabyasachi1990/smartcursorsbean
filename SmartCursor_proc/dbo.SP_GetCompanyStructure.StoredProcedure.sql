USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SP_GetCompanyStructure]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create Procedure [dbo].[SP_GetCompanyStructure]
 @CompanyId Bigint,
 @IsEntity Int
 AS
 Begin

	 IF(@IsEntity=1)
	 Begin
		Select Pnt.Id As PartnerId,Pnt.Name As Partner, 
			CMP.Id As EntityId,CMP.Name As Entity,MM.Name As ModuleName,MM.ShortCode As [Cursor]
		From Common.CompanyModule As CM
		Inner Join Common.ModuleMaster As MM On MM.Id=CM.ModuleId
		Inner Join Common.Company As CMP On CMP.Id=CM.CompanyId
		Inner Join (Select comp1.AccountingFirmId As Id,Comp2.Name,Comp1.Id As CompanyId From Common.Company As Comp1 
					inner Join Common.Company As Comp2 On Comp1.AccountingFirmId=Comp2.Id 
					Where comp1.Id=@CompanyId) As Pnt 
		On Pnt.CompanyId=CMP.Id
		Where CM.CompanyId=@CompanyId and CM.Status=1

	 End

	 else

	  Begin

	  If((select Count(*) from Common.Company where AccountingFirmId=@CompanyId) > 0)
		Select CMP.Id As PartnerId,CMP.Name As Partner,Null As EntityId,Null As Entity,MM.Name As ModuleName,MM.ShortCode As [Cursor]
		From Common.CompanyModule As CM
		Inner Join Common.ModuleMaster As MM On MM.Id=CM.ModuleId
		Inner Join Common.Company As CMP On CMP.Id=CM.CompanyId
		--Left Join (Select Id,Name,AccountingFirmId From Common.Company Where AccountingFirmId=@CompanyId) As Ent 
		--On Ent.AccountingFirmId=CMP.Id
		Where CM.CompanyId=@CompanyId and CM.Status=1
		--Order By 
		Group By MM.Name,MM.ShortCode,CMP.Id,CMP.Name
		Union All
		Select CMP.Id As PartnerId,CMP.Name As Partner,Ent.Id As EntityId,Ent.Name As Entity,MM.Name As ModuleName,MM.ShortCode As [Cursor]
		From Common.CompanyModule As CM
		Inner Join Common.ModuleMaster As MM On MM.Id=CM.ModuleId
		Inner Join Common.Company As CMP On CMP.Id=CM.CompanyId
		Left Join (Select Id,Name,AccountingFirmId From Common.Company Where AccountingFirmId=@CompanyId) As Ent 
		On Ent.AccountingFirmId=CMP.Id
		Where CM.CompanyId=@CompanyId and CM.Status=1
		--Order By 
		Group By Ent.Id,MM.Name,MM.ShortCode,CMP.Id,CMP.Name,Ent.Name

		else 
			begin
		Select CMP.Id As PartnerId,CMP.Name As Partner,Ent.Id As EntityId,Ent.Name As Entity,MM.Name As ModuleName,MM.ShortCode As [Cursor]
		From Common.CompanyModule As CM
		Inner Join Common.ModuleMaster As MM On MM.Id=CM.ModuleId
		Inner Join Common.Company As CMP On CMP.Id=CM.CompanyId
		Left Join (Select Id,Name,AccountingFirmId From Common.Company Where AccountingFirmId=@CompanyId) As Ent 
		On Ent.AccountingFirmId=CMP.Id
		Where CM.CompanyId=@CompanyId and CM.Status=1
		--Order By 
		Group By Ent.Id,MM.Name,MM.ShortCode,CMP.Id,CMP.Name,Ent.Name
		  end
	  End

 END
GO
