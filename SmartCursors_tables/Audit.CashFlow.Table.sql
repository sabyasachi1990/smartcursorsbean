USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[CashFlow]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[CashFlow](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AuditCompanyId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[Heading] [nvarchar](400) NULL,
	[Footer] [nvarchar](400) NULL,
	[Remarks] [nvarchar](max) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[Recorder] [int] NULL,
	[TempletContent] [nvarchar](max) NULL,
	[EditableHeading] [nvarchar](1000) NULL,
	[EditableFooter] [nvarchar](1000) NULL,
	[FixFooterIndex] [int] NULL,
	[FixIndex] [int] NULL,
	[FooterAmount] [decimal](17, 2) NULL,
	[IsEdit] [bit] NULL,
 CONSTRAINT [PK_CashFlow] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[CashFlow] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[CashFlow]  WITH CHECK ADD  CONSTRAINT [FK_CashFlow_AuditCompany] FOREIGN KEY([AuditCompanyId])
REFERENCES [Audit].[AuditCompany] ([Id])
GO
ALTER TABLE [Audit].[CashFlow] CHECK CONSTRAINT [FK_CashFlow_AuditCompany]
GO
ALTER TABLE [Audit].[CashFlow]  WITH CHECK ADD  CONSTRAINT [FK_CashFlow_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[CashFlow] CHECK CONSTRAINT [FK_CashFlow_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[CashFlow]  WITH CHECK ADD  CONSTRAINT [FK_CashFlow_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[CashFlow] CHECK CONSTRAINT [FK_CashFlow_Company]
GO
