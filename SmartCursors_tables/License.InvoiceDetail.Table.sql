USE [SmartCursorSTG]
GO
/****** Object:  Table [License].[InvoiceDetail]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [License].[InvoiceDetail](
	[Id] [uniqueidentifier] NOT NULL,
	[InvoiceId] [uniqueidentifier] NULL,
	[SubscriptionId] [uniqueidentifier] NULL,
	[ValidFrom] [datetime2](7) NULL,
	[ValidTo] [datetime2](7) NULL,
	[LicenseCount] [int] NULL,
	[LicensePrice] [money] NULL,
	[Amount] [money] NULL,
	[TaxId] [bigint] NULL,
	[TaxRate] [float] NULL,
	[TaxCode] [nvarchar](50) NULL,
	[TotalAmount] [money] NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_InvoiceDetail] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [License].[InvoiceDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDetail_Invoice] FOREIGN KEY([InvoiceId])
REFERENCES [License].[Invoice] ([Id])
GO
ALTER TABLE [License].[InvoiceDetail] CHECK CONSTRAINT [FK_InvoiceDetail_Invoice]
GO
ALTER TABLE [License].[InvoiceDetail]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDetail_Subscription] FOREIGN KEY([SubscriptionId])
REFERENCES [License].[Subscription] ([Id])
GO
ALTER TABLE [License].[InvoiceDetail] CHECK CONSTRAINT [FK_InvoiceDetail_Subscription]
GO
