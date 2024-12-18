USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[GetPartnerEngagementData]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[GetPartnerEngagementData] @userName Nvarchar(500)
As 
Begin
--Select CC.Id,CC.Name,Count(Eng.Id)as EngagementCount,convert(decimal(5,2),((Convert(float,Sum(EP.Percentage)))/convert(float,Count(Eng.Id)))) as FinalPercentage 
--				from
--				Audit.AuditCompanyEngagement ENG Join 
--				Audit.AuditCompanyEngagementDetails AD ON ENG.Id=AD.AuditCompanyEngagementId Join
--				Audit.EngagementPercentage EP  ON ENG.Id=EP.EngagementId join 
--				Audit.AuditCompany AC on AC.Id=ENG.AuditCompanyId join 
--				Common.Company CC on CC.Id=AC.CompanyId
--Where AD.UserName=@UserName And EP.GroupName='OverallPercentage' And EP.PercentageType='Percentage' And  ENG.Status=1 And CC.Status=1 
--Group by CC.Id,CC.Name order by CC.Id
 Select ENG.Id as EngagementId,CC.Id,Eng.ProjectName,CC.Name as CompanyName,EP.Percentage
				from
				Audit.AuditCompanyEngagement ENG Join 
				Audit.AuditCompanyEngagementDetails AD ON ENG.Id=AD.AuditCompanyEngagementId Join
				Audit.EngagementPercentage EP  ON ENG.Id=EP.EngagementId join 
				Audit.AuditCompany AC on AC.Id=ENG.AuditCompanyId join 
				Common.Company CC on CC.Id=AC.CompanyId
Where AD.UserName=@userName  And EP.GroupName='OverallPercentage' And EP.PercentageType='Percentage' And  ENG.Status=1 And CC.Status=1 order by Eng.ProjectName
End

GO
