USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[InvoiceNote]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[InvoiceNote](
	[Id] [uniqueidentifier] NOT NULL,
	[InvoiceId] [uniqueidentifier] NOT NULL,
	[ExpectedPaymentDate] [datetime2](7) NULL,
	[Notes] [nvarchar](512) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_InvoiceNotes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[InvoiceNote]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceNotes_Invoice] FOREIGN KEY([InvoiceId])
REFERENCES [Bean].[Invoice] ([Id])
GO
ALTER TABLE [Bean].[InvoiceNote] CHECK CONSTRAINT [FK_InvoiceNotes_Invoice]
GO
