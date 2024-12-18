USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[CashFlowHeadings_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[CashFlowHeadings_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AuditCompanyId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[Heading] [nvarchar](400) NULL,
	[Remarks] [nvarchar](max) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Recorder] [int] NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_CashFlowHeadings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[CashFlowHeadings_ToBeDeleted] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[CashFlowHeadings_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_CashFlowHeadings_AuditCompany] FOREIGN KEY([AuditCompanyId])
REFERENCES [Audit].[AuditCompany] ([Id])
GO
ALTER TABLE [Audit].[CashFlowHeadings_ToBeDeleted] CHECK CONSTRAINT [FK_CashFlowHeadings_AuditCompany]
GO
ALTER TABLE [Audit].[CashFlowHeadings_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_CashFlowHeadings_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[CashFlowHeadings_ToBeDeleted] CHECK CONSTRAINT [FK_CashFlowHeadings_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[CashFlowHeadings_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_CashFlowHeadings_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[CashFlowHeadings_ToBeDeleted] CHECK CONSTRAINT [FK_CashFlowHeadings_Company]
GO
