USE [SmartCursorSTG]
GO
/****** Object:  Table [WorkFlow].[InvoiceStatusChange]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [WorkFlow].[InvoiceStatusChange](
	[Id] [uniqueidentifier] NULL,
	[CompanyId] [bigint] NULL,
	[InvoiceId] [uniqueidentifier] NULL,
	[State] [nvarchar](200) NULL,
	[ModifiedBy] [nvarchar](508) NULL,
	[ModifiedDate] [datetime2](7) NULL
) ON [PRIMARY]
GO
