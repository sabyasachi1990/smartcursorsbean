USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[BankReconciliationDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[BankReconciliationDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[BankReconciliationId] [uniqueidentifier] NOT NULL,
	[ClearingDate] [datetime2](7) NULL,
	[DocumentDate] [datetime2](7) NOT NULL,
	[DocumentType] [nvarchar](20) NOT NULL,
	[DocRefNo] [nvarchar](25) NULL,
	[RefernceNo] [nvarchar](25) NULL,
	[EntityId] [uniqueidentifier] NULL,
	[Ammount] [money] NOT NULL,
	[ClearingStatus] [nvarchar](25) NULL,
	[isWithdrawl] [bit] NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[IsDisable] [bit] NULL,
	[IsChecked] [bit] NULL,
	[Mode] [nvarchar](200) NULL,
	[RefNo] [nvarchar](200) NULL,
	[DocSubType] [nvarchar](100) NULL,
	[JournalDetailId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_BankReconciliationDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[BankReconciliationDetail] ADD  DEFAULT ('3AA13C20-2A47-488B-9063-55D8B08D24B1') FOR [DocumentId]
GO
ALTER TABLE [Bean].[BankReconciliationDetail]  WITH CHECK ADD  CONSTRAINT [FK_BankReconciliationDetail_BankReconciliation] FOREIGN KEY([BankReconciliationId])
REFERENCES [Bean].[BankReconciliation] ([Id])
GO
ALTER TABLE [Bean].[BankReconciliationDetail] CHECK CONSTRAINT [FK_BankReconciliationDetail_BankReconciliation]
GO
ALTER TABLE [Bean].[BankReconciliationDetail]  WITH CHECK ADD  CONSTRAINT [FK_BankReconciliationDetail_Entity] FOREIGN KEY([EntityId])
REFERENCES [Bean].[Entity] ([Id])
GO
ALTER TABLE [Bean].[BankReconciliationDetail] CHECK CONSTRAINT [FK_BankReconciliationDetail_Entity]
GO
