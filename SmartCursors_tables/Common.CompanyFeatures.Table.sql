USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CompanyFeatures]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CompanyFeatures](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[FeatureId] [uniqueidentifier] NOT NULL,
	[Status] [int] NULL,
	[IsChecked] [bit] NULL,
	[Remarks] [nvarchar](max) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](100) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[IsConfigured] [bit] NULL,
	[DefaultXeroOrganization] [uniqueidentifier] NULL,
 CONSTRAINT [PK_CompanyFeatures] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Common].[CompanyFeatures] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[CompanyFeatures]  WITH CHECK ADD  CONSTRAINT [PK_CompanyFeatures_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[CompanyFeatures] CHECK CONSTRAINT [PK_CompanyFeatures_Company]
GO
ALTER TABLE [Common].[CompanyFeatures]  WITH CHECK ADD  CONSTRAINT [PK_CompanyFeatures_Feature] FOREIGN KEY([FeatureId])
REFERENCES [Common].[Feature] ([Id])
GO
ALTER TABLE [Common].[CompanyFeatures] CHECK CONSTRAINT [PK_CompanyFeatures_Feature]
GO
