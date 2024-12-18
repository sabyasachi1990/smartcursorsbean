USE [SmartCursorSTG]
GO
/****** Object:  Table [Common].[GSTDetail]    Script Date: 16-12-2024 9.30.56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[GSTDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[DocType] [nvarchar](50) NULL,
	[DocId] [uniqueidentifier] NOT NULL,
	[ModuleMasterId] [bigint] NOT NULL,
	[Amount] [money] NOT NULL,
	[TaxAmount] [money] NULL,
	[TotalAmount] [money] NOT NULL,
	[TaxId] [bigint] NULL,
 CONSTRAINT [PK_GSTDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Common].[GSTDetail]  WITH CHECK ADD  CONSTRAINT [FK_GSTDetail_ModuleMaster] FOREIGN KEY([ModuleMasterId])
REFERENCES [Common].[ModuleMaster] ([Id])
GO
ALTER TABLE [Common].[GSTDetail] CHECK CONSTRAINT [FK_GSTDetail_ModuleMaster]
GO
ALTER TABLE [Common].[GSTDetail]  WITH CHECK ADD  CONSTRAINT [FK_GSTDetail_TaxCode] FOREIGN KEY([TaxId])
REFERENCES [Bean].[TaxCode] ([Id])
GO
ALTER TABLE [Common].[GSTDetail] CHECK CONSTRAINT [FK_GSTDetail_TaxCode]
GO
