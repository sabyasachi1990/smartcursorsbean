USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[InvoiceState]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[InvoiceState](
	[Id] [uniqueidentifier] NOT NULL,
	[InvoiceId] [uniqueidentifier] NOT NULL,
	[FromState] [nvarchar](1) NULL,
	[ToState] [nvarchar](1) NULL,
	[CreatedBy] [nvarchar](1) NULL,
	[CreatedDate] [datetime2](7) NULL
) ON [PRIMARY]
GO
ALTER TABLE [WorkFlow].[InvoiceState]  WITH CHECK ADD  CONSTRAINT [Fk_InvoiceState_InvoiceId] FOREIGN KEY([InvoiceId])
REFERENCES [WorkFlow].[Invoice] ([Id])
GO
ALTER TABLE [WorkFlow].[InvoiceState] CHECK CONSTRAINT [Fk_InvoiceState_InvoiceId]
GO
