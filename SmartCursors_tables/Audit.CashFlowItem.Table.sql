USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[CashFlowItem]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[CashFlowItem](
	[Id] [uniqueidentifier] NOT NULL,
	[CashFlowId] [uniqueidentifier] NOT NULL,
	[Name] [nvarchar](400) NULL,
	[Recorder] [int] NULL,
	[EditableName] [nvarchar](1000) NULL,
	[PyAmount] [decimal](25, 2) NULL,
	[CyAmount] [decimal](25, 2) NULL,
	[AmountChange] [decimal](25, 2) NULL,
	[PercentageChange] [decimal](25, 2) NULL,
	[IsPyAmountEditable] [bit] NULL,
	[IsRowEditable] [bit] NULL,
	[IsNameEditable] [bit] NULL,
	[IsHeader] [bit] NULL,
	[IsFooter] [bit] NULL,
	[ParentId] [uniqueidentifier] NULL,
	[IsNew] [bit] NULL,
 CONSTRAINT [PK_CashFlowItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[CashFlowItem]  WITH CHECK ADD  CONSTRAINT [FK_CashFlowItem_CashFlow] FOREIGN KEY([CashFlowId])
REFERENCES [Audit].[CashFlow] ([Id])
GO
ALTER TABLE [Audit].[CashFlowItem] CHECK CONSTRAINT [FK_CashFlowItem_CashFlow]
GO
