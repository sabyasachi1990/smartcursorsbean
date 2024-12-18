USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[GeneralLedgerImport]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[GeneralLedgerImport](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[FileId] [uniqueidentifier] NULL,
	[AccountNumber] [nvarchar](100) NULL,
	[AccountName] [nvarchar](100) NOT NULL,
	[AccountClass] [nvarchar](50) NULL,
	[AccountCategory] [nvarchar](50) NULL,
	[AccountSubCategory] [nvarchar](50) NULL,
	[OpeningBalance] [money] NULL,
	[ClosingBalance] [money] NULL,
	[IsFlag] [bit] NULL,
	[RecOrder] [int] NULL,
	[UserCreated] [nvarchar](256) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](256) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_GeneralLedgerImport] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[GeneralLedgerImport] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[GeneralLedgerImport]  WITH CHECK ADD  CONSTRAINT [FK_GeneralLedgerImport_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Tax].[GeneralLedgerImport] CHECK CONSTRAINT [FK_GeneralLedgerImport_Company]
GO
ALTER TABLE [Tax].[GeneralLedgerImport]  WITH CHECK ADD  CONSTRAINT [FK_GeneralLedgerImport_GeneralLedgerFileDetails] FOREIGN KEY([FileId])
REFERENCES [Tax].[GeneralLedgerFileDetails] ([ID])
GO
ALTER TABLE [Tax].[GeneralLedgerImport] CHECK CONSTRAINT [FK_GeneralLedgerImport_GeneralLedgerFileDetails]
GO
ALTER TABLE [Tax].[GeneralLedgerImport]  WITH CHECK ADD  CONSTRAINT [FK_GeneralLedgerImport_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[GeneralLedgerImport] CHECK CONSTRAINT [FK_GeneralLedgerImport_TaxCompanyEngagement]
GO
