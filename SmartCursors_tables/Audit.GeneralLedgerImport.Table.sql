USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[GeneralLedgerImport]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[GeneralLedgerImport](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[AccountNumber] [nvarchar](100) NULL,
	[AccountName] [nvarchar](2000) NULL,
	[AccountClass] [nvarchar](50) NULL,
	[AccountCategory] [nvarchar](50) NULL,
	[AccountSubCategory] [nvarchar](50) NULL,
	[OpeningBalance] [decimal](17, 2) NULL,
	[ClosingBalance] [decimal](17, 2) NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[GLType] [nvarchar](50) NULL,
	[CYorPYBalance] [decimal](17, 2) NULL,
 CONSTRAINT [PK_GeneralLedgerImport] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[GeneralLedgerImport] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[GeneralLedgerImport]  WITH CHECK ADD  CONSTRAINT [FK_GeneralLedgerImport_AuditCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Audit].[AuditCompanyEngagement] ([Id])
GO
ALTER TABLE [Audit].[GeneralLedgerImport] CHECK CONSTRAINT [FK_GeneralLedgerImport_AuditCompanyEngagement]
GO
ALTER TABLE [Audit].[GeneralLedgerImport]  WITH CHECK ADD  CONSTRAINT [FK_GeneralLedgerImport_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Audit].[GeneralLedgerImport] CHECK CONSTRAINT [FK_GeneralLedgerImport_Company]
GO
