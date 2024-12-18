USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[TickMarkSetup]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[TickMarkSetup](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NULL,
	[Code] [nvarchar](10) NOT NULL,
	[Description] [nvarchar](300) NOT NULL,
	[IsSystem] [bit] NOT NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[IsPlanning] [bit] NULL,
	[IsCompletion] [bit] NULL,
	[IsPartner] [bit] NULL,
	[ReferenceId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_TickMarkSetup] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[TickMarkSetup] ADD  DEFAULT ((0)) FOR [IsSystem]
GO
ALTER TABLE [Audit].[TickMarkSetup] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[TickMarkSetup]  WITH CHECK ADD  CONSTRAINT [FK_TickMarkSetUp_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[TickMarkSetup] CHECK CONSTRAINT [FK_TickMarkSetUp_AuditCompanyEngagement]
GO
