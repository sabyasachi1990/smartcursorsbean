USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[GLClearingDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[GLClearingDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[GLClearingId] [uniqueidentifier] NOT NULL,
	[DocType] [nvarchar](50) NOT NULL,
	[DocDate] [datetime2](7) NOT NULL,
	[DocNo] [nvarchar](25) NOT NULL,
	[SystemRefNo] [nvarchar](50) NOT NULL,
	[DocAmount] [money] NOT NULL,
	[DocCurrency] [nvarchar](5) NOT NULL,
	[BaseAmount] [money] NOT NULL,
	[BaseCurrency] [nvarchar](5) NOT NULL,
	[CrDr] [nvarchar](250) NULL,
	[RecOrder] [int] NULL,
	[IsCheck] [bit] NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[DocCredit] [money] NULL,
	[DocDebit] [money] NULL,
	[BaseCredit] [money] NULL,
	[BaseDebit] [money] NULL,
	[EntityName] [nvarchar](250) NULL,
	[AccountDescription] [nvarchar](250) NULL,
	[ClearingDate] [datetime2](7) NULL,
	[JournalDetailId] [uniqueidentifier] NULL,
	[DocSubType] [nvarchar](100) NULL,
	[DocumentDetailId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_GLClearingDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[GLClearingDetail]  WITH CHECK ADD  CONSTRAINT [FK_GLClearingDetail_GLClearing] FOREIGN KEY([GLClearingId])
REFERENCES [Bean].[GLClearing] ([Id])
GO
ALTER TABLE [Bean].[GLClearingDetail] CHECK CONSTRAINT [FK_GLClearingDetail_GLClearing]
GO
