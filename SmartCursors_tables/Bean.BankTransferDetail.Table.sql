USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[BankTransferDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[BankTransferDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[BankTransferId] [uniqueidentifier] NOT NULL,
	[COAId] [bigint] NOT NULL,
	[ServiceCompanyId] [bigint] NOT NULL,
	[Currency] [nvarchar](5) NULL,
	[Amount] [money] NOT NULL,
	[Type] [nvarchar](25) NOT NULL,
	[BankClearingDate] [datetime2](7) NULL,
	[RecOrder] [int] NULL,
	[ClearingState] [nvarchar](50) NULL,
 CONSTRAINT [PK_BankTransferDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[BankTransferDetail]  WITH CHECK ADD  CONSTRAINT [FK_BankTransferDetail_BankTransfer] FOREIGN KEY([BankTransferId])
REFERENCES [Bean].[BankTransfer] ([Id])
GO
ALTER TABLE [Bean].[BankTransferDetail] CHECK CONSTRAINT [FK_BankTransferDetail_BankTransfer]
GO
ALTER TABLE [Bean].[BankTransferDetail]  WITH CHECK ADD  CONSTRAINT [FK_BankTransferDetail_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[BankTransferDetail] CHECK CONSTRAINT [FK_BankTransferDetail_ChartOfAccount]
GO
