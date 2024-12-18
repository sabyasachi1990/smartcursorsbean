USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[EngagementTypeMenuMapping]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[EngagementTypeMenuMapping](
	[Id] [uniqueidentifier] NOT NULL,
	[ModuleDetailId] [bigint] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Code] [nvarchar](20) NULL,
	[AuditType] [nvarchar](50) NULL,
	[GroupName] [nvarchar](100) NULL,
	[Heading] [nvarchar](100) NULL,
	[PermissionKey] [nvarchar](100) NULL,
	[ModuleName] [nvarchar](25) NULL,
	[IsSystem] [bit] NOT NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NOT NULL,
	[CssSprite] [nvarchar](100) NULL,
	[FontAwesome] [nvarchar](100) NULL,
	[Url] [nvarchar](100) NULL,
	[IsDuplicate] [bit] NULL,
 CONSTRAINT [PK_EngagementTypeMenuMapping] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[EngagementTypeMenuMapping] ADD  DEFAULT ((1)) FOR [IsSystem]
GO
ALTER TABLE [Audit].[EngagementTypeMenuMapping] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[EngagementTypeMenuMapping]  WITH CHECK ADD  CONSTRAINT [FK_EngagementTypeMenuMapping_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[EngagementTypeMenuMapping] CHECK CONSTRAINT [FK_EngagementTypeMenuMapping_Company]
GO
ALTER TABLE [Audit].[EngagementTypeMenuMapping]  WITH CHECK ADD  CONSTRAINT [FK_EngagementTypeMenuMappings_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Audit].[EngagementTypeMenuMapping] CHECK CONSTRAINT [FK_EngagementTypeMenuMappings_ModuleDetail]
GO
