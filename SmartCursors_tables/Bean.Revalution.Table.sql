USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[Revalution]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[Revalution](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[RevalutionDate] [datetime2](7) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[DocState] [nvarchar](20) NULL,
	[Status] [int] NULL,
	[ExchangeRate] [decimal](18, 0) NULL,
	[ServiceCompanyId] [bigint] NULL,
	[SystemRefNo] [nvarchar](50) NULL,
	[IsMultiCurrency] [bit] NULL,
	[IsNoSupportingDocument] [bit] NULL,
	[IsAllowableDisAllowable] [bit] NULL,
	[IsSegmentReporting] [bit] NULL,
	[NetAmount] [money] NULL,
	[Version] [timestamp] NOT NULL,
	[IsLocked] [bit] NULL,
 CONSTRAINT [PK_Revalution] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[Revalution]  WITH CHECK ADD  CONSTRAINT [FK_Revalution_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[Revalution] CHECK CONSTRAINT [FK_Revalution_Company]
GO
