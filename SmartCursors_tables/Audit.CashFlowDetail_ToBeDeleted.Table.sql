USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[CashFlowDetail_ToBeDeleted]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[CashFlowDetail_ToBeDeleted](
	[Id] [uniqueidentifier] NOT NULL,
	[CashFlowItemId] [uniqueidentifier] NULL,
	[LeadSheetId] [uniqueidentifier] NULL,
	[CashFlowHeadingId] [uniqueidentifier] NULL,
	[Amount] [decimal](10, 2) NULL,
	[Recorder] [int] NULL,
	[PYAmount] [decimal](10, 2) NULL,
	[CYAmount] [decimal](10, 2) NULL,
 CONSTRAINT [PK_CashFlowDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Audit].[CashFlowDetail_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_CashFlowDetail_CashFlowHeading] FOREIGN KEY([CashFlowHeadingId])
REFERENCES [Audit].[CashFlowHeadings_ToBeDeleted] ([Id])
GO
ALTER TABLE [Audit].[CashFlowDetail_ToBeDeleted] CHECK CONSTRAINT [FK_CashFlowDetail_CashFlowHeading]
GO
ALTER TABLE [Audit].[CashFlowDetail_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_CashFlowDetail_CashFlowItem] FOREIGN KEY([CashFlowItemId])
REFERENCES [Audit].[CashFlowItem] ([Id])
GO
ALTER TABLE [Audit].[CashFlowDetail_ToBeDeleted] CHECK CONSTRAINT [FK_CashFlowDetail_CashFlowItem]
GO
ALTER TABLE [Audit].[CashFlowDetail_ToBeDeleted]  WITH CHECK ADD  CONSTRAINT [FK_CashFlowDetail_LeadSheet] FOREIGN KEY([LeadSheetId])
REFERENCES [Audit].[LeadSheet] ([Id])
GO
ALTER TABLE [Audit].[CashFlowDetail_ToBeDeleted] CHECK CONSTRAINT [FK_CashFlowDetail_LeadSheet]
GO
