USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[Disclosure]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[Disclosure](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[LeadSheetId] [uniqueidentifier] NULL,
	[IsDisclosure] [bit] NULL,
	[IsPublish] [bit] NULL,
	[YearDates] [nvarchar](100) NULL,
	[NAME] [nvarchar](4000) NULL,
	[RecOrder] [nvarchar](max) NULL,
	[TemplateName] [nvarchar](126) NULL,
	[BaseCurrency] [nvarchar](100) NULL,
	[IsChanged] [bit] NULL,
	[ScreenName] [nvarchar](256) NULL,
	[YearType] [nvarchar](20) NULL,
 CONSTRAINT [PK_Disclosure] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[Disclosure]  WITH CHECK ADD  CONSTRAINT [FK_Disclosure_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[Disclosure] CHECK CONSTRAINT [FK_Disclosure_Company]
GO
