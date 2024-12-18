USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[PaymentDetail]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[PaymentDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[PaymentId] [uniqueidentifier] NOT NULL,
	[DocumentDate] [datetime2](7) NOT NULL,
	[DocumentType] [nvarchar](20) NOT NULL,
	[SystemReferenceNumber] [nvarchar](50) NOT NULL,
	[DocumentNo] [nvarchar](25) NOT NULL,
	[DocumentState] [nvarchar](25) NOT NULL,
	[Nature] [nvarchar](10) NOT NULL,
	[DocumentAmmount] [money] NOT NULL,
	[AmmountDue] [money] NOT NULL,
	[Currency] [nvarchar](5) NOT NULL,
	[PaymentAmount] [money] NOT NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[ServiceCompanyId] [bigint] NULL,
	[ClearingState] [nvarchar](50) NULL,
	[RoundingAmount] [money] NULL,
 CONSTRAINT [PK_PaymentDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[PaymentDetail]  WITH CHECK ADD  CONSTRAINT [FK_PaymentDetail_Payment] FOREIGN KEY([PaymentId])
REFERENCES [Bean].[Payment] ([Id])
GO
ALTER TABLE [Bean].[PaymentDetail] CHECK CONSTRAINT [FK_PaymentDetail_Payment]
GO
