USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[InvestmentSchedule]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[InvestmentSchedule](
	[ID] [uniqueidentifier] NOT NULL,
	[InterestRestrictionId] [uniqueidentifier] NULL,
	[AccountName] [nvarchar](200) NULL,
	[Cost] [decimal](15, 0) NULL,
	[Adjustments] [decimal](15, 0) NULL,
	[NetAmount] [decimal](15, 0) NULL,
	[NonIncomeProducing] [decimal](15, 0) NULL,
	[IncomeProducing] [decimal](15, 0) NULL,
	[Remarks] [nvarchar](256) NULL,
	[RecOrder] [int] NULL,
 CONSTRAINT [PK_InvestmentSchedule] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[InvestmentSchedule]  WITH CHECK ADD  CONSTRAINT [FK_InvestmentSchedule_InterestRestrictionId] FOREIGN KEY([InterestRestrictionId])
REFERENCES [Tax].[InterestRestriction] ([ID])
GO
ALTER TABLE [Tax].[InvestmentSchedule] CHECK CONSTRAINT [FK_InvestmentSchedule_InterestRestrictionId]
GO
