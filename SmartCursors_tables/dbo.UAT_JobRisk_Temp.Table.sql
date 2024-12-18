USE [SmartCursorSTG]
GO
/****** Object:  Table [dbo].[UAT_JobRisk_Temp]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UAT_JobRisk_Temp](
	[JobTypeId] [uniqueidentifier] NULL,
	[Risk] [nvarchar](20) NULL,
	[RiskPartner] [decimal](10, 2) NULL,
	[RiskManager] [decimal](10, 2) NULL,
	[RiskSenior] [decimal](10, 2) NULL,
	[RiskSeniorAssociate] [decimal](10, 2) NULL,
	[RiskJuniorAssociate] [decimal](10, 2) NULL,
	[VolPartner] [decimal](10, 2) NULL,
	[VolManager] [decimal](10, 2) NULL,
	[VolSenior] [decimal](10, 2) NULL,
	[VolSeniorAssociate] [decimal](10, 2) NULL,
	[VolJuniorAssociate] [decimal](10, 2) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL
) ON [PRIMARY]
GO
