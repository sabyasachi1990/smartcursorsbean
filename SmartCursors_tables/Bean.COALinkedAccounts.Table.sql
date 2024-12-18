USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[COALinkedAccounts]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[COALinkedAccounts](
	[CoaId] [int] NOT NULL,
	[CursorName] [nvarchar](250) NULL,
	[CompanyId] [bigint] NULL,
	[DocumentType] [nvarchar](250) NULL,
	[DocId] [nvarchar](250) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[CreatedBy] [nvarchar](250) NULL
) ON [PRIMARY]
GO
