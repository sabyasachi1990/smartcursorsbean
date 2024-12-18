USE [SmartCursorSTG]
GO
/****** Object:  Table [Tax].[InterestRestriction]    Script Date: 16-12-2024 9.30.57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tax].[InterestRestriction](
	[ID] [uniqueidentifier] NOT NULL,
	[EngagementId] [uniqueidentifier] NOT NULL,
	[NonIncomeProducingAssets] [decimal](20, 0) NULL,
	[TotalAsserts] [decimal](20, 0) NULL,
	[TotalInterest] [decimal](20, 0) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](256) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[InterestAddbackAmt] [decimal](20, 0) NULL,
 CONSTRAINT [PK_InterestRestriction] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Tax].[InterestRestriction] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Tax].[InterestRestriction]  WITH CHECK ADD  CONSTRAINT [FK_InterestRestriction_TaxCompanyEngagement] FOREIGN KEY([EngagementId])
REFERENCES [Tax].[TaxCompanyEngagement] ([Id])
GO
ALTER TABLE [Tax].[InterestRestriction] CHECK CONSTRAINT [FK_InterestRestriction_TaxCompanyEngagement]
GO
