USE [SmartCursorSTG]
GO
/****** Object:  Table [HR].[TempMultipleCliamProcess]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[TempMultipleCliamProcess](
	[Id] [uniqueidentifier] NOT NULL,
	[TransactionId] [uniqueidentifier] NOT NULL,
	[ClaimId] [uniqueidentifier] NOT NULL,
	[BillId] [uniqueidentifier] NOT NULL,
	[PostingDate] [datetime2](7) NULL,
	[IsVoid] [bit] NULL,
	[IsPayComponent] [bit] NULL,
	[VendorId] [uniqueidentifier] NULL,
	[ExchangeRate] [decimal](15, 10) NULL,
	[GstExchangeRate] [decimal](15, 10) NULL,
	[IsExchangeRateEditable] [bit] NULL,
	[CompanyId] [bigint] NULL,
 CONSTRAINT [PK_TempMultipleCliamProcess] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
