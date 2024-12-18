USE [SmartCursorSTG]
GO
/****** Object:  Table [Audit].[ForeignCurrencyAnalysis]    Script Date: 16-12-2024 9.30.55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Audit].[ForeignCurrencyAnalysis](
	[ID] [uniqueidentifier] NOT NULL,
	[ForeignExchangeID] [uniqueidentifier] NULL,
	[SecondaryFactorNA] [bit] NULL,
	[Conclusion] [nvarchar](max) NULL,
	[RecOrder] [int] NULL,
	[Remarks] [nvarchar](max) NULL,
	[UserCreated] [nvarchar](254) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedBy] [nvarchar](254) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Version] [smallint] NULL,
	[Status] [int] NULL,
	[NA] [bit] NULL,
	[PrimaryFactor_NA] [bit] NULL,
	[EngagementId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_FECurrencyAnalysis] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Audit].[ForeignCurrencyAnalysis] ADD  DEFAULT ((0)) FOR [SecondaryFactorNA]
GO
ALTER TABLE [Audit].[ForeignCurrencyAnalysis] ADD  DEFAULT ((1)) FOR [Status]
GO
ALTER TABLE [Audit].[ForeignCurrencyAnalysis]  WITH CHECK ADD  CONSTRAINT [FK_FECurrencyAnalysis_ForeignExchange] FOREIGN KEY([ForeignExchangeID])
REFERENCES [Audit].[ForeignExchange] ([ID])
GO
ALTER TABLE [Audit].[ForeignCurrencyAnalysis] CHECK CONSTRAINT [FK_FECurrencyAnalysis_ForeignExchange]
GO
