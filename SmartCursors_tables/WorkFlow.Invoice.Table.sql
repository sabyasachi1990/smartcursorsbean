USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[Invoice]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[Invoice](
	[Id] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[Number] [nvarchar](20) NULL,
	[InvDate] [datetime2](7) NULL,
	[InvType] [nvarchar](20) NULL,
	[TaxCodeId] [bigint] NULL,
	[ApplicableTaxCode] [nvarchar](254) NULL,
	[InoviceStatus] [nvarchar](20) NULL,
	[Fee] [money] NULL,
	[Currency] [nvarchar](50) NULL,
	[InvoiceGSTFee] [money] NULL,
	[InvoiceGSTCurrency] [nvarchar](50) NULL,
	[IncidentalFee] [money] NULL,
	[IncidentalCurrency] [nvarchar](50) NULL,
	[TotalFee] [money] NULL,
	[TotalFeeCurrency] [nvarchar](50) NULL,
	[BalanceFee] [money] NULL,
	[State] [nvarchar](20) NULL,
	[Approver] [nvarchar](254) NULL,
	[ApprovedDate] [datetime2](7) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version1] [smallint] NULL,
	[Status] [int] NULL,
	[OutStandingBalanceFee] [money] NULL,
	[IsGst] [bit] NULL,
	[DocToBaseExhRate] [decimal](15, 10) NULL,
	[Category] [nvarchar](50) NULL,
	[StateRemarks] [nvarchar](256) NULL,
	[InvoiceUrl] [nvarchar](500) NULL,
	[IsCreatedBeforeBeanActivate] [bit] NULL,
	[TempNumber] [nvarchar](20) NULL,
	[IncidentalGstTotal] [money] NULL,
	[MongoId] [nvarchar](500) NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[IsDone] [nvarchar](max) NULL,
	[BCSyncId] [uniqueidentifier] NULL,
	[BCSyncStatus] [nvarchar](100) NULL,
	[BCSyncDate] [datetime2](7) NULL,
	[BCSyncRemarks] [nvarchar](max) NULL,
	[SyncBCInvoiceId] [uniqueidentifier] NULL,
	[SyncBCInvoiceStatus] [nvarchar](100) NULL,
	[SyncBCInvoiceDate] [datetime2](7) NULL,
	[SyncBCInvoiceRemarks] [nvarchar](max) NULL,
	[TotalincidentalFee] [decimal](10, 2) NULL,
	[Filepath] [nvarchar](max) NULL,
	[URL] [nvarchar](max) NULL,
	[FileName] [nvarchar](max) NULL,
	[IsCreated] [bit] NULL,
	[ClientId] [uniqueidentifier] NULL,
	[XeroInvoiceId] [uniqueidentifier] NULL,
	[IsPostedToXero] [bit] NULL,
	[PeppolDocumentId] [nvarchar](50) NULL,
	[PeppolStatus] [nvarchar](20) NULL,
	[PeppolStatusCode] [nvarchar](20) NULL,
	[PeppolRemarks] [nvarchar](max) NULL,
	[XMLFileData] [nvarchar](max) NULL,
	[BaseFee] [money] NULL,
	[BaseOutStandingBalanceFee] [money] NULL,
	[BaseTotalFee] [money] NULL,
	[BaseIncidentalFee] [money] NULL,
	[BaseCurrency] [nvarchar](10) NULL,
	[TaxCurrency] [nvarchar](50) NULL,
	[DocToJudExhRate] [decimal](15, 10) NULL,
	[IsDocToJudExhRateChanged] [bit] NULL,
	[IsMultiCurrency] [bit] NULL,
	[IsDocToBaseExhRateChanged] [bit] NULL,
	[BillToId] [uniqueidentifier] NULL,
	[BillToName] [nvarchar](1000) NULL,
	[Version] [timestamp] NOT NULL,
	[VersionNotUpdate] [nvarchar](max) NULL,
	[InvoicendIncidentalFee] [decimal](7, 2) NULL,
 CONSTRAINT [PK_Invoice] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Incidental_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [WorkFlow].[Invoice] CHECK CONSTRAINT [FK_Incidental_Company]
GO
ALTER TABLE [WorkFlow].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_CaseGroup] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [WorkFlow].[Invoice] CHECK CONSTRAINT [FK_Invoice_CaseGroup]
GO
ALTER TABLE [WorkFlow].[Invoice]  WITH CHECK ADD  CONSTRAINT [FK_Invoice_TaxCode] FOREIGN KEY([TaxCodeId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [WorkFlow].[Invoice] CHECK CONSTRAINT [FK_Invoice_TaxCode]
GO
