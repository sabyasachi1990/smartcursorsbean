USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[ReceiptDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[ReceiptDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[ReceiptId] [uniqueidentifier] NOT NULL,
	[DocumentDate] [datetime2](7) NOT NULL,
	[DocumentType] [nvarchar](20) NOT NULL,
	[SystemReferenceNumber] [nvarchar](50) NOT NULL,
	[DocumentNo] [nvarchar](25) NOT NULL,
	[DocumentState] [nvarchar](25) NOT NULL,
	[Nature] [nvarchar](10) NOT NULL,
	[DocumentAmmount] [money] NOT NULL,
	[AmmountDue] [money] NOT NULL,
	[Currency] [nvarchar](5) NOT NULL,
	[ReceiptAmount] [money] NOT NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[RecOrder] [int] NULL,
	[ServiceCompanyId] [bigint] NULL,
	[ClearingState] [nvarchar](50) NULL,
	[RoundingAmount] [money] NULL,
 CONSTRAINT [PK_ReceiptDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[ReceiptDetail] ADD  DEFAULT ('55972946-8625-406D-ACCB-00E9FE1A1FEB') FOR [DocumentId]
GO
ALTER TABLE [Bean].[ReceiptDetail]  WITH CHECK ADD  CONSTRAINT [FK_ReceiptDetail_Receipt] FOREIGN KEY([ReceiptId])
REFERENCES [Bean].[Receipt] ([Id])
GO
ALTER TABLE [Bean].[ReceiptDetail] CHECK CONSTRAINT [FK_ReceiptDetail_Receipt]
GO
