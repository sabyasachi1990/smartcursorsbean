USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[SmartCursor_Syncing_Count]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[SmartCursor_Syncing_Count] 
	@CompanyId Bigint
As
Begin
	--IF Exists (Select CM.Id From Common.CompanyModule As CM
	--		Inner Join Common.ModuleMaster As MM On MM.Id=CM.ModuleId
	--		Where MM.Name='Bean Cursor' And CM.Status=1 And Cm.CompanyId=@CompanyId)
	--Begin

		--Declare @CompanyId Bigint=1
		Select 'HR.Employee' Source,'Bean.Entity' Destination, Count(Id) [Total Employees]
		From common.Employee Where CompanyId=@CompanyId And Status=1 

		Select 'HR.Employee' Source,'Bean.Entity' Destination, Count(EN.Id) as [Total Entity Employees]
		From Bean.Entity EN
		Inner join common.Employee Em On EM.id = En.DocumentId 
		Where EN.CompanyId=@CompanyId And EN.Status=1 And ExternalEntityType='Employee'

		Select 'HR.Employee' Source,'Bean.Entity' Destination, Count(Id) [Missing Employees]
		From common.Employee Where CompanyId=@CompanyId And Status=1 
		And Id Not In (Select DocumentId From Bean.Entity Where CompanyId=@CompanyId And Status=1 And ExternalEntityType='Employee')

		Select 'HR.Employee' Source,'Bean.Entity' Destination, DocumentId as [Duplicate Employee]
		From Bean.Entity EN
		Inner join common.Employee Em On EM.id = En.DocumentId 
		Where EN.CompanyId=@CompanyId And EN.Status=1 And ExternalEntityType='Employee'
		Group by DocumentId having Count(DocumentId)>1


		Select 'WF.Invoice' Source,'Bean.Invoice' Destination, Count(*) 'Total WF Invoice'
		from WorkFlow.invoice where companyId=@CompanyId and Documentid is not null and DocumentId not in 
		(Select Id from Bean.invoice where companyid=@CompanyId)

		Select 'WF.Invoice' Source,'Bean.Invoice' Destination, Count(*) Missing 
		from WorkFlow.invoice where companyId=@CompanyId and Documentid is not null and DocumentId not in 
		(Select Id from Bean.invoice where companyid=@CompanyId)

	--END
End

GO
