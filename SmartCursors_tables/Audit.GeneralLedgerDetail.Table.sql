USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[GeneralLedgerDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[GeneralLedgerDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[GeneralLedgerId] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[GLDate] [datetime2](7) NULL,
	[Debit] [decimal](17, 2) NULL,
	[Credit] [decimal](17, 2) NULL,
	[Balance] [decimal](17, 2) NULL,
	[EntityType] [nvarchar](300) NULL,
	[EntityName] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[DocNo] [nvarchar](100) NULL,
	[Currency] [nvarchar](50) NULL,
	[EntitySubType] [nvarchar](200) NULL,
 CONSTRAINT [PK_GeneralLedgerDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[GeneralLedgerDetail]  WITH CHECK ADD  CONSTRAINT [FK_GeneralLedgerDetail_GeneralLedger] FOREIGN KEY([GeneralLedgerId])
REFERENCES [Audit].[GeneralLedgerImport] ([Id])
GO
ALTER TABLE [Audit].[GeneralLedgerDetail] CHECK CONSTRAINT [FK_GeneralLedgerDetail_GeneralLedger]
GO
