USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[OpeningBalanceDetailLineItem]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[OpeningBalanceDetailLineItem](
	[Id] [uniqueidentifier] NOT NULL,
	[OpeningBalanceDetailId] [uniqueidentifier] NOT NULL,
	[Date] [datetime2](7) NULL,
	[ServiceCompanyId] [bigint] NOT NULL,
	[COAId] [bigint] NOT NULL,
	[Description] [nvarchar](256) NULL,
	[BaseCurrency] [nvarchar](20) NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[BaseCredit] [money] NULL,
	[BaseDebit] [money] NULL,
	[DocumentCurrency] [nvarchar](20) NULL,
	[DocCredit] [money] NULL,
	[DoCDebit] [money] NULL,
	[EntityId] [uniqueidentifier] NULL,
	[SegmentMasterid1] [bigint] NULL,
	[SegmentMasterid2] [bigint] NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[UserCreated] [nvarchar](100) NULL,
	[ModifiedDate] [datetime2](7) NOT NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[SegmentDetailid1] [int] NULL,
	[SegmentDetailid2] [int] NULL,
	[SegmentCategory1] [nvarchar](20) NULL,
	[SegmentCategory2] [nvarchar](20) NULL,
	[DocumentReference] [nvarchar](254) NULL,
	[Recorder] [int] NOT NULL,
	[IsDisAllow] [bit] NULL,
	[DueDate] [datetime2](7) NULL,
	[IsEditable] [bit] NULL,
	[IsProcressed] [bit] NULL,
	[ProcressedRemarks] [nvarchar](512) NULL,
 CONSTRAINT [PK_OpeningBalanceDetailLineItem] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ADD SENSITIVITY CLASSIFICATION TO [Bean].[OpeningBalanceDetailLineItem].[BaseCurrency] WITH (label = 'Confidential', label_id = '281b9ab3-ecbb-4a57-8486-c702e44215d8', information_type = 'Financial', information_type_id = 'c44193e1-0e58-4b2a-9001-f7d6e7bc1373', rank = Medium);
GO
ALTER TABLE [Bean].[OpeningBalanceDetailLineItem] ADD  DEFAULT ((0)) FOR [Recorder]
GO
ALTER TABLE [Bean].[OpeningBalanceDetailLineItem]  WITH CHECK ADD  CONSTRAINT [FK_OpeningBalanceDetailLineItem_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[OpeningBalanceDetailLineItem] CHECK CONSTRAINT [FK_OpeningBalanceDetailLineItem_ChartOfAccount]
GO
ALTER TABLE [Bean].[OpeningBalanceDetailLineItem]  WITH CHECK ADD  CONSTRAINT [FK_OpeningBalanceDetailLineItem_Entity] FOREIGN KEY([EntityId])
REFERENCES [Bean].[Entity] ([Id])
GO
ALTER TABLE [Bean].[OpeningBalanceDetailLineItem] CHECK CONSTRAINT [FK_OpeningBalanceDetailLineItem_Entity]
GO
ALTER TABLE [Bean].[OpeningBalanceDetailLineItem]  WITH CHECK ADD  CONSTRAINT [FK_OpeningBalanceDetailLineItem_OpeningBalanceDetailId] FOREIGN KEY([OpeningBalanceDetailId])
REFERENCES [Bean].[OpeningBalanceDetail] ([Id])
GO
ALTER TABLE [Bean].[OpeningBalanceDetailLineItem] CHECK CONSTRAINT [FK_OpeningBalanceDetailLineItem_OpeningBalanceDetailId]
GO
