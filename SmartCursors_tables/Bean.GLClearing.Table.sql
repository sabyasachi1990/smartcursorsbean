USE [SmartCursorSTG]
GO
/****** Object:  Table [Bean].[GLClearing]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bean].[GLClearing](
	[Id] [uniqueidentifier] NOT NULL,
	[CompanyId] [bigint] NOT NULL,
	[DocType] [nvarchar](50) NOT NULL,
	[DocDate] [datetime2](7) NULL,
	[DocNo] [nvarchar](25) NULL,
	[ServiceCompanyId] [bigint] NOT NULL,
	[COAId] [bigint] NOT NULL,
	[DocDescription] [nvarchar](253) NULL,
	[IsMultiCurrency] [bit] NOT NULL,
	[SystemRefNo] [nvarchar](50) NOT NULL,
	[Remarks] [nvarchar](1000) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Status] [int] NULL,
	[CrDr] [nvarchar](240) NULL,
	[CheckAmount] [money] NULL,
	[DocumentState] [nvarchar](20) NULL,
	[COAId2] [bigint] NULL,
	[ExCurrency] [nvarchar](5) NULL,
	[EntityId] [uniqueidentifier] NULL,
	[ClearingDate] [datetime2](7) NULL,
	[TransactionCount] [bigint] NULL,
	[Version] [timestamp] NOT NULL,
	[IsLocked] [bit] NULL,
 CONSTRAINT [PK_GLClearing] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Bean].[GLClearing] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Bean].[GLClearing]  WITH CHECK ADD  CONSTRAINT [FK_GLClearing_ChartOfAccount] FOREIGN KEY([COAId])
REFERENCES [Bean].[ChartOfAccount] ([Id])
GO
ALTER TABLE [Bean].[GLClearing] CHECK CONSTRAINT [FK_GLClearing_ChartOfAccount]
GO
ALTER TABLE [Bean].[GLClearing]  WITH CHECK ADD  CONSTRAINT [FK_GLClearing_Company] FOREIGN KEY([CompanyId])
REFERENCES [Common].[Company] ([Id])
GO
ALTER TABLE [Bean].[GLClearing] CHECK CONSTRAINT [FK_GLClearing_Company]
GO
