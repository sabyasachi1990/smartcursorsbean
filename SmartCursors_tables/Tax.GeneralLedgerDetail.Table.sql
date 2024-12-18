USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[GeneralLedgerDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[GeneralLedgerDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[GeneralLedgerId] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](200) NULL,
	[GLDate] [datetime2](7) NULL,
	[Debit] [money] NULL,
	[Credit] [money] NULL,
	[Balance] [money] NULL,
	[EntityType] [nvarchar](100) NULL,
	[EntityName] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_GeneralLedgerDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[GeneralLedgerDetail]  WITH CHECK ADD  CONSTRAINT [FK_GeneralLedgerDetail_GeneralLedgerImport] FOREIGN KEY([GeneralLedgerId])
REFERENCES [Tax].[GeneralLedgerImport] ([Id])
GO
ALTER TABLE [Tax].[GeneralLedgerDetail] CHECK CONSTRAINT [FK_GeneralLedgerDetail_GeneralLedgerImport]
GO
