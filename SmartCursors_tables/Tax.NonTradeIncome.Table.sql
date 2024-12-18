USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[NonTradeIncome]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[NonTradeIncome](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[TotalAmount] [decimal](15, 0) NULL,
	[Description] [nvarchar](max) NULL,
	[LinkTo] [nvarchar](max) NULL,
	[Status] [int] NULL,
	[UserCreated] [nvarchar](100) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](100) NULL,
	[ModifiedDate] [datetime2](7) NULL,
 CONSTRAINT [PK_NonTradeIncome] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Tax].[NonTradeIncome]  WITH CHECK ADD  CONSTRAINT [FK_NonTradeIncome_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[NonTradeIncome] CHECK CONSTRAINT [FK_NonTradeIncome_TaxCompanyEngagement]
GO
