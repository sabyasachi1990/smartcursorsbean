USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditMenuMaster]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditMenuMaster](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[ModuleDetailId] [bigint] NOT NULL,
	[GroupName] [nvarchar](100) NULL,
	[PermissionKey] [nvarchar](100) NULL,
	[CssSprite] [nvarchar](100) NULL,
	[FontAwesome] [nvarchar](100) NULL,
	[Url] [nvarchar](100) NULL,
	[IsDuplicate] [bit] NULL,
	[IsSystem] [bit] NULL,
	[IsAllowTemplate] [bit] NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NOT NULL,
	[IsAnalytics] [bit] NULL,
	[HelpLink] [nvarchar](256) NULL,
 CONSTRAINT [PK_AuditMenuMaster] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[AuditMenuMaster] ADD  DEFAULT ((0)) FOR [IsAnalytics]
GO
ALTER TABLE [Audit].[AuditMenuMaster]  WITH CHECK ADD  CONSTRAINT [FK_AuditMenuMaster_ModuleDetail] FOREIGN KEY([ModuleDetailId])
REFERENCES [Common].[ModuleDetail] ([Id])
GO
ALTER TABLE [Audit].[AuditMenuMaster] CHECK CONSTRAINT [FK_AuditMenuMaster_ModuleDetail]
GO
