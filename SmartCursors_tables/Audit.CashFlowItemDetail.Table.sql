USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[CashFlowItemDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[CashFlowItemDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[CashFlowItemId] [uniqueidentifier] NULL,
	[LeadSheetId] [uniqueidentifier] NULL,
	[Amount] [decimal](25, 2) NULL,
	[Recorder] [int] NULL,
	[CashFlowId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_CashFlowItemDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[CashFlowItemDetail]  WITH CHECK ADD  CONSTRAINT [FK_CashFlowItemDetail_CashFlowItem] FOREIGN KEY([CashFlowItemId])
REFERENCES [Audit].[CashFlowItem] ([Id])
GO
ALTER TABLE [Audit].[CashFlowItemDetail] CHECK CONSTRAINT [FK_CashFlowItemDetail_CashFlowItem]
GO
ALTER TABLE [Audit].[CashFlowItemDetail]  WITH CHECK ADD  CONSTRAINT [FK_CashFlowItemDetail_LeadSheet] FOREIGN KEY([LeadSheetId])
REFERENCES [Audit].[LeadSheet] ([Id])
GO
ALTER TABLE [Audit].[CashFlowItemDetail] CHECK CONSTRAINT [FK_CashFlowItemDetail_LeadSheet]
GO
