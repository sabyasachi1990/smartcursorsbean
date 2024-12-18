USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[AuditCompanyEngagement]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[AuditCompanyEngagement](
	[Id] [uniqueidentifier] NOT NULL,
	[AuditCompanyId] [uniqueidentifier] NOT NULL,
	[ProjectName] [nvarchar](100) NOT NULL,
	[YearEndDate] [datetime2](7) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[Description] [nvarchar](256) NULL,
	[DueDate] [datetime2](7) NULL,
	[EngagementType] [nvarchar](100) NULL,
	[EngagementFee] [money] NOT NULL,
	[EngagementReviewLevel] [nvarchar](500) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[PriorYearStart] [datetime2](7) NULL,
	[PriorYearEnd] [datetime2](7) NULL,
	[StatementBOrder] [nvarchar](max) NULL,
	[NoteNumber] [int] NULL,
	[EngagementTypeId] [uniqueidentifier] NULL,
	[GLStatus] [nvarchar](50) NULL,
	[PYMultiplier] [decimal](10, 2) NULL,
	[CYMultiplier] [decimal](10, 2) NULL,
	[IsPyMultiplierEnable] [bit] NULL,
	[IsCYMultiplierEnable] [bit] NULL,
	[FSTemplateId] [uniqueidentifier] NULL,
	[Year] [int] NULL,
	[AuditManualId] [uniqueidentifier] NULL,
	[Interim] [bit] NULL,
	[ComparisionWithFinal] [bit] NULL,
	[Type] [nvarchar](100) NULL,
 CONSTRAINT [PK_AuditCompanyEngagement] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[AuditCompanyEngagement] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[AuditCompanyEngagement]  WITH CHECK ADD  CONSTRAINT [FK_AuditCompanyEngagement_AuditCompany] FOREIGN KEY([AuditCompanyId])
REFERENCES [Audit].[AuditCompany] ([Id])
GO
ALTER TABLE [Audit].[AuditCompanyEngagement] CHECK CONSTRAINT [FK_AuditCompanyEngagement_AuditCompany]
GO
