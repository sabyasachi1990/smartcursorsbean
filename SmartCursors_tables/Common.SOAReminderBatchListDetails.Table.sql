USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[SOAReminderBatchListDetails]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[SOAReminderBatchListDetails](
	[Id] [uniqueidentifier] NOT NULL,
	[MasterId] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[CaseNumber] [nvarchar](50) NULL,
	[CaseFee] [money] NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[DocumentDate] [datetime2](7) NULL,
	[InvoiceNumber] [nvarchar](50) NULL,
	[InvType] [nvarchar](20) NULL,
	[InvoiceTaxCode] [nvarchar](256) NULL,
	[InvoiceFee] [money] NULL,
	[ApplicableTaxCode] [nvarchar](256) NULL,
	[InvoiceTaxCodeNames] [nvarchar](256) NULL,
	[InvoiceGSTFee] [money] NULL,
	[IncidentalsName] [nvarchar](100) NULL,
	[IncidentalFee] [money] NULL,
	[IncidentalsTaxCodes] [nvarchar](100) NULL,
	[IncidentalsGSTFee] [money] NULL,
	[InvoiceTotalFee] [money] NULL,
	[OutStandingBalanceFee] [money] NULL,
	[ScopeOfWork] [nvarchar](4000) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[Status] [int] NULL,
	[BaseCurrency] [nvarchar](10) NULL,
	[DocCurrency] [nvarchar](10) NULL,
	[DocToBaseExhRate] [decimal](15, 10) NULL,
	[IsMultiCurrency] [bit] NULL,
 CONSTRAINT [PK_RSOAReminderBatchListDetails] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[SOAReminderBatchListDetails] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Common].[SOAReminderBatchListDetails]  WITH CHECK ADD  CONSTRAINT [FK_SOAReminderBatchListDetail_SOAReminderBatchList] FOREIGN KEY([MasterId])
REFERENCES [Common].[SOAReminderBatchList] ([Id])
GO
ALTER TABLE [Common].[SOAReminderBatchListDetails] CHECK CONSTRAINT [FK_SOAReminderBatchListDetail_SOAReminderBatchList]
GO
