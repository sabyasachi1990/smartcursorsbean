USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[CreditMemoApplication]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[CreditMemoApplication](
	[Id] [uniqueidentifier] NOT NULL,
	[CreditMemoId] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[CreditMemoApplicationDate] [datetime2](7) NOT NULL,
	[CreditMemoApplicationResetDate] [datetime2](7) NULL,
	[IsNoSupportingDocumentActivated] [bit] NOT NULL,
	[IsNoSupportingDocument] [bit] NULL,
	[CreditAmount] [money] NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[CreditMemoApplicationNumber] [nvarchar](50) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NOT NULL,
	[ExchangeRate] [decimal](18, 0) NULL,
	[IsRevExcess] [bit] NULL,
	[DocumentId] [uniqueidentifier] NULL,
	[ClearingState] [nvarchar](200) NULL,
	[Version] [timestamp] NOT NULL,
	[RoundingAmount] [money] NULL,
	[ClearCount] [int] NULL,
	[IsLocked] [bit] NULL,
 CONSTRAINT [PK_CreditMemoApplication] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[CreditMemoApplication] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[CreditMemoApplication]  WITH CHECK ADD  CONSTRAINT [FK_CreditMemoApplication_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[CreditMemoApplication] CHECK CONSTRAINT [FK_CreditMemoApplication_Company]
GO
ALTER TABLE [Bean].[CreditMemoApplication]  WITH CHECK ADD  CONSTRAINT [FK_CreditMemoApplication_CreditMemo] FOREIGN KEY([CreditMemoId])
REFERENCES [Bean].[CreditMemo] ([Id])
GO
ALTER TABLE [Bean].[CreditMemoApplication] CHECK CONSTRAINT [FK_CreditMemoApplication_CreditMemo]
GO
