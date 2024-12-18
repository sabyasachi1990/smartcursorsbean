USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[TaxMenu]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[TaxMenu](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[TaxCompanyId] [uniqueidentifier] NULL,
	[ModuleDetailId] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Code] [nvarchar](100) NULL,
	[TaxType] [nvarchar](100) NULL,
	[GroupName] [nvarchar](100) NULL,
	[Heading] [nvarchar](100) NULL,
	[PermissionKey] [nvarchar](100) NULL,
	[ModuleName] [nvarchar](100) NULL,
	[IsSystem] [bit] NOT NULL,
	[IsHide] [bit] NOT NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NOT NULL,
	[TemplateName] [nvarchar](100) NULL,
	[CssSprite] [nvarchar](100) NULL,
	[FontAwesome] [nvarchar](100) NULL,
	[IsAllowTemplate] [bit] NULL,
	[Url] [nvarchar](100) NULL,
	[IsDuplicate] [bit] NULL,
 CONSTRAINT [PK_TaxMenu] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[TaxMenu] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[TaxMenu]  WITH CHECK ADD  CONSTRAINT [FK_EngagementTypeMenuMapping_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Tax].[TaxMenu] CHECK CONSTRAINT [FK_EngagementTypeMenuMapping_ModuleDetail]
GO
ALTER TABLE [Tax].[TaxMenu]  WITH CHECK ADD  CONSTRAINT [FK_TaxMenu_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[TaxMenu] CHECK CONSTRAINT [FK_TaxMenu_Company]
GO
ALTER TABLE [Tax].[TaxMenu]  WITH CHECK ADD  CONSTRAINT [FK_TaxMenu_TaxCompany] FOREIGN KEY([TaxCompanyId])
REFERENCES [Tax].[TaxCompany] ([Id])
GO
ALTER TABLE [Tax].[TaxMenu] CHECK CONSTRAINT [FK_TaxMenu_TaxCompany]
GO
ALTER TABLE [Tax].[TaxMenu]  WITH CHECK ADD  CONSTRAINT [FK_TaxMenu_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[TaxMenu] CHECK CONSTRAINT [FK_TaxMenu_TaxCompanyEngagement]
GO
