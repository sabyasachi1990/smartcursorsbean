USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[Incidental]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[Incidental](
	[Id] [uniqueidentifier] NOT NULL,
	[InvoiceId] [uniqueidentifier] NOT NULL,
	[ClaimItemId] [uniqueidentifier] NOT NULL,
	[ItemDescription] [nvarchar](100) NULL,
	[ClaimItem] [nvarchar](100) NOT NULL,
	[Unit] [nvarchar](100) NULL,
	[Charge] [money] NULL,
	[MinCharge] [money] NULL,
	[Fee] [money] NULL,
	[IncidentalGSTFee] [money] NULL,
	[IncidentalGSTCurrency] [nvarchar](50) NULL,
	[GstAmount] [money] NULL,
	[TaxCode] [nvarchar](100) NULL,
	[TaxRate] [float] NULL,
	[Quantity] [int] NULL,
	[Total] [money] NULL,
	[IsByFee] [bit] NULL,
	[Category] [nvarchar](100) NULL,
	[Remarks] [nvarchar](4000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[TaxId] [bigint] NULL,
	[IncidentalType] [nvarchar](100) NULL,
	[RecOrder] [int] NULL,
	[DocCurrency] [nvarchar](10) NULL,
	[DocToBaseExhRate] [decimal](15, 10) NULL,
	[TaxCurrency] [nvarchar](50) NULL,
	[DocToJudExhRate] [decimal](15, 10) NULL,
	[BaseCurrency] [nvarchar](10) NULL,
	[BaseAmount] [money] NULL,
	[BaseTotal] [money] NULL,
 CONSTRAINT [PK_Incidental] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[Incidental]  WITH CHECK ADD  CONSTRAINT [FK_Incidental_IncidentalClaimItem] FOREIGN KEY([ClaimItemId])
REFERENCES [WorkFlow].[IncidentalClaimItem] ([Id])
GO
ALTER TABLE [WorkFlow].[Incidental] CHECK CONSTRAINT [FK_Incidental_IncidentalClaimItem]
GO
ALTER TABLE [WorkFlow].[Incidental]  WITH CHECK ADD  CONSTRAINT [FK_Incidental_Invoice] FOREIGN KEY([InvoiceId])
REFERENCES [WorkFlow].[Invoice] ([Id])
GO
ALTER TABLE [WorkFlow].[Incidental] CHECK CONSTRAINT [FK_Incidental_Invoice]
GO
