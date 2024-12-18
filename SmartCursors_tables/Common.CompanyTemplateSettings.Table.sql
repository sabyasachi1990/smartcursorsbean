USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[CompanyTemplateSettings]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[CompanyTemplateSettings](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ServiceCompanyId] [bigint] NOT NULL,
	[HeaderContent] [nvarchar](4000) NULL,
	[FooterContent] [nvarchar](4000) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](254) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_CompanyTemplateSettings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[CompanyTemplateSettings] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[CompanyTemplateSettings]  WITH CHECK ADD  CONSTRAINT [FK_CompanyTemplateSettings_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Common].[CompanyTemplateSettings] CHECK CONSTRAINT [FK_CompanyTemplateSettings_Company]
GO
