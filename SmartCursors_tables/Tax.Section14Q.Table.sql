USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[Section14Q]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[Section14Q](
	[Id] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[FirstYAStart] [int] NOT NULL,
	[NumberOfYAForBlock] [int] NOT NULL,
	[MaximumClaimForBlock] [decimal](17, 2) NOT NULL,
	[RemainingClaim] [decimal](17, 0) NULL,
	[IsRollForward] [bit] NULL,
	[FunctionalCurrency] [nvarchar](10) NULL,
	[ExchangeRate] [decimal](17, 4) NULL,
	[TotalExchangeRate] [decimal](17, 2) NULL,
	[IsExchagerateEdit] [bit] NOT NULL,
 CONSTRAINT [PK_Section14Q] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[Section14Q] ADD  DEFAULT ((0)) FOR [IsExchagerateEdit]
GO
ALTER TABLE [Tax].[Section14Q]  WITH CHECK ADD  CONSTRAINT [FK_TaxCompanyEngagement_Section14Q] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[Section14Q] CHECK CONSTRAINT [FK_TaxCompanyEngagement_Section14Q]
GO
