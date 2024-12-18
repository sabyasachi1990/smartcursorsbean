USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[LeadSheet]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[LeadSheet](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[WorkProgramId] [uniqueidentifier] NULL,
	[Index] [nvarchar](50) NOT NULL,
	[LeadsheetType] [nvarchar](50) NOT NULL,
	[AccountClass] [nvarchar](50) NOT NULL,
	[IsSystem] [bit] NULL,
	[LeadSheetName] [nvarchar](100) NULL,
	[FinancialStatementTemplate] [nvarchar](50) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[Disclosure] [nvarchar](max) NULL,
	[Section] [nvarchar](50) NULL,
	[SectionOrder] [int] NULL,
	[Nature] [nvarchar](20) NULL,
	[IsPartner] [bit] NULL,
	[ReferenceId] [uniqueidentifier] NULL,
	[EngagementId] [uniqueidentifier] NULL,
	[WorkProgramName] [nvarchar](256) NULL,
	[MasterId] [uniqueidentifier] NULL,
	[AuditManual] [nvarchar](256) NULL,
	[AuditManualId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_LeadSheet] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[LeadSheet] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[LeadSheet]  WITH CHECK ADD  CONSTRAINT [FK_Leadsheet_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[LeadSheet] CHECK CONSTRAINT [FK_Leadsheet_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[LeadSheet]  WITH CHECK ADD  CONSTRAINT [FK_LeadSheet_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[LeadSheet] CHECK CONSTRAINT [FK_LeadSheet_Company]
GO
ALTER TABLE [Audit].[LeadSheet]  WITH CHECK ADD  CONSTRAINT [FK_leadsheet_leadsheetMaster] FOREIGN KEY([MasterId])
REFERENCES [Audit].[LeadSheetSetupMaster] ([Id])
GO
ALTER TABLE [Audit].[LeadSheet] CHECK CONSTRAINT [FK_leadsheet_leadsheetMaster]
GO
ALTER TABLE [Audit].[LeadSheet]  WITH CHECK ADD  CONSTRAINT [FK_LeadSheet_WPSetup] FOREIGN KEY([WorkProgramId])
REFERENCES [Audit].[WPSetup] ([Id])
GO
ALTER TABLE [Audit].[LeadSheet] CHECK CONSTRAINT [FK_LeadSheet_WPSetup]
GO
