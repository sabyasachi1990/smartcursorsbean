USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[OpeningBalanceDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[OpeningBalanceDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[OpeningBalanceId] [uniqueidentifier] NOT NULL,
	[COAId] [bigint] NOT NULL,
	[BaseCurrency] [nvarchar](20) NULL,
	[BaseCredit] [money] NULL,
	[BaseDebit] [money] NULL,
	[DocCurrency] [nvarchar](20) NULL,
	[DocCredit] [money] NULL,
	[DocDebit] [money] NULL,
	[UserCreated] [varchar](50) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [varchar](50) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[IsOrginalAccount] [bit] NULL,
	[Recorder] [int] NOT NULL,
	[ClearingState] [nvarchar](50) NULL,
	[ReconciliationDate] [datetime2](7) NULL,
	[ReconciliationId] [uniqueidentifier] NULL,
	[ClearingDate] [datetime2](7) NULL,
 CONSTRAINT [PK_OpeningBalanceDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[OpeningBalanceDetail] ADD  DEFAULT ((0)) FOR [Recorder]
GO
ALTER TABLE [Bean].[OpeningBalanceDetail]  WITH CHECK ADD  CONSTRAINT [FK_OpeningBalanceDetail_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[OpeningBalanceDetail] CHECK CONSTRAINT [FK_OpeningBalanceDetail_ChartOfAccount]
GO
ALTER TABLE [Bean].[OpeningBalanceDetail]  WITH CHECK ADD  CONSTRAINT [FK_OpeningBalanceDetail_OpeningBalance] FOREIGN KEY([OpeningBalanceId])
REFERENCES [Bean].[OpeningBalance] ([Id])
GO
ALTER TABLE [Bean].[OpeningBalanceDetail] CHECK CONSTRAINT [FK_OpeningBalanceDetail_OpeningBalance]
GO
