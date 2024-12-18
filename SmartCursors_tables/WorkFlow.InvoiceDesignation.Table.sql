USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[InvoiceDesignation]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[InvoiceDesignation](
	[Id] [uniqueidentifier] NOT NULL,
	[InvoiceId] [uniqueidentifier] NOT NULL,
	[CaseId] [uniqueidentifier] NOT NULL,
	[Rate] [money] NOT NULL,
	[Hours] [nvarchar](10) NULL,
	[Designation] [nvarchar](50) NULL,
	[RecOrder] [int] NULL,
	[Status] [int] NULL,
 CONSTRAINT [PK_InvoiceDesignation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[InvoiceDesignation] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [WorkFlow].[InvoiceDesignation]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDesignation_Case] FOREIGN KEY([CaseId])
REFERENCES [WorkFlow].[CaseGroup] ([Id])
GO
ALTER TABLE [WorkFlow].[InvoiceDesignation] CHECK CONSTRAINT [FK_InvoiceDesignation_Case]
GO
ALTER TABLE [WorkFlow].[InvoiceDesignation]  WITH CHECK ADD  CONSTRAINT [FK_InvoiceDesignation_Invoice] FOREIGN KEY([InvoiceId])
REFERENCES [WorkFlow].[Invoice] ([Id])
GO
ALTER TABLE [WorkFlow].[InvoiceDesignation] CHECK CONSTRAINT [FK_InvoiceDesignation_Invoice]
GO
