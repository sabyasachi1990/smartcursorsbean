USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[CreditNoteApplication]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[CreditNoteApplication](
	[Id] [uniqueidentifier] NOT NULL,
	[InvoiceId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CreditNoteApplicationDate] [datetime2](7) NOT NULL,
	[CreditNoteApplicationResetDate] [datetime2](7) NULL,
	[IsNoSupportingDocumentActivated] [bit] NOT NULL,
	[IsNoSupportingDocument] [bit] NULL,
	[CreditAmount] [money] NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[CreditNoteApplicationNumber] [nvarchar](50) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[ExchangeRate] [decimal](18, 0) NULL,
	[IsRevExcess] [bit] NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[ClearingState] [nvarchar](200) NULL,
	[Version] [timestamp] NOT NULL,
	[RoundingAmount] [money] NULL,
	[ClearCount] [int] NULL,
	[IsLocked] [bit] NULL,
 CONSTRAINT [PK_CreditNoteApplication] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[CreditNoteApplication] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[CreditNoteApplication]  WITH CHECK ADD  CONSTRAINT [FK_CreditNoteApplication_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[CreditNoteApplication] CHECK CONSTRAINT [FK_CreditNoteApplication_Company]
GO
ALTER TABLE [Bean].[CreditNoteApplication]  WITH CHECK ADD  CONSTRAINT [FK_CreditNoteApplication_Invoice] FOREIGN KEY([InvoiceId])
REFERENCES [Bean].[Invoice] ([Id])
GO
ALTER TABLE [Bean].[CreditNoteApplication] CHECK CONSTRAINT [FK_CreditNoteApplication_Invoice]
GO
