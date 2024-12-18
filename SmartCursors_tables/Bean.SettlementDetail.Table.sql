USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[SettlementDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[SettlementDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[BankTransferId] [uniqueidentifier] NULL,
	[SettlemetType] [nvarchar](50) NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[DocumentType] [nvarchar](20) NULL,
	[DocumentDate] [datetime2](7) NULL,
	[DocumentNo] [nvarchar](25) NULL,
	[DocumentState] [nvarchar](25) NULL,
	[Currency] [nvarchar](5) NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[ServiceCompanyId] [bigint] NULL,
	[DocumentAmmount] [money] NULL,
	[AmmountDue] [money] NULL,
	[SettledAmount] [money] NULL,
	[RecOrder] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[SettlementDetail]  WITH CHECK ADD  CONSTRAINT [Bean_SettlementDetail_Transfer_Id] FOREIGN KEY([BankTransferId])
REFERENCES [Bean].[BankTransfer] ([Id])
GO
ALTER TABLE [Bean].[SettlementDetail] CHECK CONSTRAINT [Bean_SettlementDetail_Transfer_Id]
GO
