USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TaxCompanyEngagementDetails]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TaxCompanyEngagementDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[TaxCompanyEngagementId] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](254) NOT NULL,
	[Role] [nvarchar](50) NULL,
	[SignOffLevel] [nvarchar](500) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_TaxCompanyEngagementDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[TaxCompanyEngagementDetails] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[TaxCompanyEngagementDetails]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompanyEngagementDetails_TaxCompanyEngagement] FOREIGN KEY([TaxCompanyEngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[TaxCompanyEngagementDetails] CHECK CONSTRAINT [FK_TaxCompanyEngagementDetails_TaxCompanyEngagement]
GO
