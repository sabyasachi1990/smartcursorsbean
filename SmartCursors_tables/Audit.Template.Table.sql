USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[Template]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[Template](
	[Id] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](4000) NULL,
	[Code] [nvarchar](100) NULL,
	[CompanyId] [bigint] NOT NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[FromEmailId] [nvarchar](100) NULL,
	[CcEmailIds] [nvarchar](500) NULL,
	[BccEmailIds] [nvarchar](500) NULL,
	[ToEmailId] [nvarchar](500) NULL,
	[Subject] [nvarchar](256) NULL,
	[TempletContent] [nvarchar](max) NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[ScreenName] [nvarchar](500) NULL,
	[GenericTemplateId] [uniqueidentifier] NULL,
	[IsTemplate] [bit] NULL,
	[IsMaster] [bit] NULL,
	[IsRollForward] [bit] NULL,
	[AuditCompanyId] [uniqueidentifier] NULL,
	[EngagementType] [nvarchar](100) NULL,
	[EngagementName] [nvarchar](max) NULL,
	[EffectiveFrom] [datetime2](7) NULL,
	[EffectiveTo] [datetime2](7) NULL,
	[SectionName] [nvarchar](400) NULL,
	[ReferenceId] [uniqueidentifier] NULL,
	[IsFinancialsTemplate] [bit] NULL,
	[FSTemplateId] [uniqueidentifier] NULL,
	[PartnerId] [uniqueidentifier] NULL,
	[IsSaved] [bit] NULL,
 CONSTRAINT [PK_Template] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[Template] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[Template]  WITH CHECK ADD  CONSTRAINT [FK_Template_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[Template] CHECK CONSTRAINT [FK_Template_Company]
GO
