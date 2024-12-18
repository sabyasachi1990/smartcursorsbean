USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TaxCompanyMenuMaster]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TaxCompanyMenuMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[TaxMenuMasterId] [uniqueidentifier] NOT NULL,
	[Code] [nvarchar](10) NULL,
	[Heading] [nvarchar](100) NULL,
	[IsHide] [bit] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NOT NULL,
	[TemplateName] [nvarchar](50) NULL,
	[AdditionalReviewer] [nvarchar](50) NULL,
	[AdditionalReviewer1] [nvarchar](100) NULL,
	[IsReviewer1] [bit] NULL,
	[IsReviewer] [bit] NULL,
	[TaxManualId] [uniqueidentifier] NULL,
	[ReferenceId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_TaxCompanyMenuMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[TaxCompanyMenuMaster] ADD  DEFAULT ((0)) FOR [IsReviewer]
GO
ALTER TABLE [Tax].[TaxCompanyMenuMaster]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompanyMenuMaster_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[TaxCompanyMenuMaster] CHECK CONSTRAINT [FK_TaxCompanyMenuMaster_TaxCompanyEngagement]
GO
ALTER TABLE [Tax].[TaxCompanyMenuMaster]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompanyMenuMaster_TaxMenuMaster] FOREIGN KEY([TaxMenuMasterId])
REFERENCES [Tax].[TaxMenuMaster] ([Id])
GO
ALTER TABLE [Tax].[TaxCompanyMenuMaster] CHECK CONSTRAINT [FK_TaxCompanyMenuMaster_TaxMenuMaster]
GO
