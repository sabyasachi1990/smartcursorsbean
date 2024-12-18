USE [SmartCursorSTG]
GO
/****** Object:  Table [ClientCursor].[JobRisk_ToBeDeleted]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ClientCursor].[JobRisk_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[JobTypeId] [uniqueidentifier] NOT NULL,
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
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_JobRisk] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [ClientCursor].[JobRisk_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [ClientCursor].[JobRisk_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_JobRisk_JobType] FOREIGN KEY([JobTypeId])
REFERENCES [ClientCursor].[JobType_ToBeDeleted] ([Id])
GO
ALTER TABLE [ClientCursor].[JobRisk_ToBeDeleted] CHECK CONSTRAINT [FK_JobRisk_JobType]
GO
